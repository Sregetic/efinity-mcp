#include "geometry_face.h"
#include "geometry_m7.h"
#include "pico/picornt.h"
#ifdef VISION_MULHI_CFU
#include "int8.h"
#endif

static const uint8_t *image;
static void *model;
static float scale,row,col,delta,origin,last_row,last_col,detections[1024*4];
static unsigned count,finished;
static int offset_scale;
#ifdef VISION_MULHI_CFU
static uint32_t basis[4];static unsigned scale_high;
#else
static int offset[256];
#endif
/* Pinned leaves are finite normal/zero; every prefix stays normal/zero. */
static const uint32_t shift_factor[32]={
 0,0x80000000u,0x40000000u,0x20000000u,0x10000000u,0x08000000u,0x04000000u,0x02000000u,
 0x01000000u,0x00800000u,0x00400000u,0x00200000u,0x00100000u,0x00080000u,0x00040000u,0x00020000u,
 0x00010000u,0x00008000u,0x00004000u,0x00002000u,0x00001000u,0x00000800u,0x00000400u,0x00000200u,
 0x00000100u,0x00000080u,0x00000040u,0x00000020u,0x00000010u,0x00000008u,0x00000004u,0x00000002u
};
static const uint32_t shift_mask[32]={
 0x00000000u,0x00000001u,0x00000003u,0x00000007u,0x0000000fu,0x0000001fu,0x0000003fu,0x0000007fu,
 0x000000ffu,0x000001ffu,0x000003ffu,0x000007ffu,0x00000fffu,0x00001fffu,0x00003fffu,0x00007fffu,
 0x0000ffffu,0x0001ffffu,0x0003ffffu,0x0007ffffu,0x000fffffu,0x001fffffu,0x003fffffu,0x007fffffu,
 0x00ffffffu,0x01ffffffu,0x03ffffffu,0x07ffffffu,0x0fffffffu,0x1fffffffu,0x3fffffffu,0x7fffffffu
};
static unsigned exponent(uint32_t bits){
#ifdef VISION_MULHI_CFU
 return (unsigned)int8_mulhi((int32_t)bits,512)&255;
#else
 return (bits>>23)&255;
#endif
}
static uint32_t positive_right(uint32_t value,unsigned n){
#ifdef VISION_MULHI_CFU
 uint32_t q=(uint32_t)int8_mulhi(value,(int32_t)shift_factor[n]);
 return n==1?q+value:q;
#else
 return value>>n;
#endif
}
/* IEEE binary32 round-to-nearest/even, with seven guard/sticky bits. */
static float score_add(float a,float b){
 union{float f;uint32_t u;}x={a},y={b},result;
 if((x.u&0x7fffffff)<(y.u&0x7fffffff)){uint32_t t=x.u;x.u=y.u;y.u=t;}
 if(!(y.u&0x7fffffff)){
  result.u=(x.u&0x7fffffff)?x.u:x.u&y.u;return result.f;
 }
 unsigned e=exponent(x.u),d=e-exponent(y.u);
 uint32_t sx=((x.u&0x7fffff)|0x800000)<<7,sy=((y.u&0x7fffff)|0x800000)<<7;
 if(d>=32)sy=1;
 else if(d)sy=positive_right(sy,d)|!!(sy&shift_mask[d]);
 uint32_t sum;
 if(!((x.u^y.u)&0x80000000)){
  sum=sx+sy;
  if(sum&0x80000000){sum=(sum>>1)|(sum&1);e++;}
 }else{
  sum=sx-sy;if(!sum)return 0;
  while(!(sum&0x40000000)){sum<<=1;e--;}
 }
 uint32_t fraction=sum>>7,round=sum&127;
 if(round>64||(round==64&&(fraction&1)))fraction++;
 if(fraction==0x1000000){fraction>>=1;e++;}
 result.u=(x.u&0x80000000)|(e<<23)|(fraction&0x7fffff);return result.f;
}
/* Scanner coordinates are positive normal floats below 512. */
static int pixel_coordinate(float value){
 union{float f;uint32_t u;}v={value};
 return positive_right((v.u&0x7fffff)|0x800000,150-exponent(v.u));
}
/* All scores are finite in the pinned cascade; compare their ordered bits. */
static int finite_le(float a,float b){
 union{float f;uint32_t u;}x={a},y={b};
 if(!((x.u|y.u)&0x7fffffff))return 1;
 return (int32_t)x.u<0?((int32_t)y.u<0?x.u>=y.u:1):((int32_t)y.u<0?0:x.u<=y.u);
}
/* Pico evaluator (c) 2013 Nenad Markus, MIT: pico/LICENSE. Pinned depth-6/468-tree model; the installed dot4 unit scales packed node offsets. */
/* The CPU has a 2 KiB instruction cache; keep the scanner outside this kernel. */
static __attribute__((noinline)) int window_score(float *score,int r,int c,int s){
 if(offset_scale!=s){
  #ifdef VISION_MULHI_CFU
  uint32_t low=s&127;basis[0]=low;basis[1]=low<<8;basis[2]=low<<16;basis[3]=low<<24;scale_high=(unsigned)s>>7;
#else
  for(unsigned i=0;i<256;i++)offset[i]=(int8_t)i*s;
#endif
  offset_scale=s;
 }
 r*=256;c*=256;
 if((r+128*s)/256>=M7_H||(r-128*s)/256<0||
    (c+128*s)/256>=M7_W||(c-128*s)/256<0)return -1;
 const uint8_t *tree=(const uint8_t*)model+16;
 float threshold=0;*score=0;
 for(unsigned i=0;i<468;i++,tree+=512){
  unsigned idx=1;
  for(unsigned j=0;j<6;j++){
#ifdef VISION_MULHI_CFU
   uint32_t codes=((const uint32_t*)tree)[idx-1];
   int ar=int8_dot4(codes,basis[0]),ac=int8_dot4(codes,basis[1]);
   int br=int8_dot4(codes,basis[2]),bc=int8_dot4(codes,basis[3]);
   if(scale_high){
    int ah=int8_dot4(codes,0x80),ch=int8_dot4(codes,0x8000);
    int bh=int8_dot4(codes,0x800000),dh=int8_dot4(codes,0x80000000);
    if(scale_high==2){ah+=ah;ch+=ch;bh+=bh;dh+=dh;}
    ar-=ah;ac-=ch;br-=bh;bc-=dh;
   }
#else
   const int8_t *codes=(const int8_t*)tree-4;
   int ar=offset[(uint8_t)codes[4*idx]],ac=offset[(uint8_t)codes[4*idx+1]];
   int br=offset[(uint8_t)codes[4*idx+2]],bc=offset[(uint8_t)codes[4*idx+3]];
#endif
   /* The scale scanner keeps both sample coordinates nonnegative. */
   unsigned a=((uint32_t)(r+ar)>>8)*M7_W+
              ((uint32_t)(c+ac)>>8);
   unsigned b=((uint32_t)(r+br)>>8)*M7_W+
              ((uint32_t)(c+bc)>>8);
   idx=2*idx+(image[a]<=image[b]);
  }
  *score=score_add(*score,((const float*)(tree+252))[idx-64]);
  threshold=*(const float*)(tree+508);
  if(finite_le(*score,threshold))return -1;
 }
 *score-=threshold;return 1;
}

void m7_face_begin(const uint8_t *gray,void *cascade){
 image=gray;model=cascade;offset_scale=0;scale=24;row=col=13;delta=2.4f;origin=13;last_row=M7_H-13;last_col=M7_W-13;count=finished=0;
}
unsigned m7_face_step(unsigned budget){
 if(finished)return 1;
 while(budget--&&finite_le(scale,M7_H-2)){
  float score;
  if(window_score(&score,pixel_coordinate(row),pixel_coordinate(col),pixel_coordinate(scale))==1){
   // shortcut: retain 1024 positive windows; enlarge DDR storage for dense crowds.
   if(count<1024){
    detections[count*4]=row;detections[count*4+1]=col;
    detections[count*4+2]=scale;detections[count*4+3]=score;count++;
   }
  }
  col=score_add(col,delta);
  if(!finite_le(col,last_col)){col=origin;row=score_add(row,delta);}
  if(!finite_le(row,last_row)){
   scale*=1.2f;origin=scale/2+1;row=col=origin;delta=scale*.1f;
   last_row=M7_H-scale/2-1;last_col=M7_W-scale/2-1;
  }
 }
 if(finite_le(scale,M7_H-2))return 0;
 count=cluster_detections(detections,count);
 for(unsigned i=0;i<count;i++)if(detections[i*4+3]>=5){
  float r=detections[i*4],c=detections[i*4+1],s=detections[i*4+2];
  m7_add_face(c-s/2,r-s/2,c+s/2,r+s/2);
 }
 finished=1;return 1;
}
