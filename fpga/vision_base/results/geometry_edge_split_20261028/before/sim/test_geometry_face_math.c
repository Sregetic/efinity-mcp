#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "../firmware/vision/geometry_face.c"
static uint32_t rng=12345;
static uint32_t next(void){rng^=rng<<13;rng^=rng>>17;rng^=rng<<5;return rng;}
static int addition_test(void){
 for(unsigned n=0;n<2000000;n++){
  union{float f;uint32_t u;}a,b,c,d;
  a.u=(next()&0x807fffff)|((96+next()%48)<<23);b.u=(next()&0x807fffff)|((96+next()%48)<<23);
  if(n%8==0)b.u=a.u^0x80000000;
  if(n%16==0){a.u=(n&16)?0x80000000:0;b.u=(n&32)?0x80000000:0;}
  volatile float ref=a.f+b.f;c.f=ref;d.f=score_add(a.f,b.f);
  if(c.u!=d.u){printf("FAIL %08x + %08x = %08x/%08x\n",a.u,b.u,c.u,d.u);return 1;}
 }
 puts("PASS 2000000 finite FP32 sums bit-exact including cancellation, signed zero and exponent gaps");return 0;
}

int run_cascade(void*,float*,int,int,int,void*,int,int,int);
static uint8_t blob[239632] __attribute__((aligned(16))),pixels[129600];
static uint32_t edges[4050];
static int equal_float(float a,float b){return !memcmp(&a,&b,4);}
int main(int argc,char **argv){
 if(argc!=3||addition_test())return 1;
 FILE*f=fopen(argv[1],"rb");if(!f||fread(blob,1,sizeof(blob),f)!=sizeof(blob))return 2;fclose(f);
 if(((int*)blob)[2]!=6||((int*)blob)[3]!=468)return 3;
 for(unsigned i=0;i<468;i++){
  const uint32_t *leaf=(const uint32_t*)(blob+16+i*512+252);
  for(unsigned j=0;j<64;j++){
   uint32_t magnitude=leaf[j]&0x7fffffff;
   if(magnitude&&((magnitude>>23)<24||magnitude>0x3f800000))return 9;
  }
  if((leaf[64]&0x7f800000)==0x7f800000)return 10;
 }
 f=fopen(argv[2],"rb");if(!f)return 4;unsigned checks=0,scan_checks=0;
 for(unsigned n=0;n<17;n++){
  if(fread(edges,1,sizeof(edges),f)!=sizeof(edges)||fread(pixels,1,sizeof(pixels),f)!=sizeof(pixels))return 5;
  m7_face_begin(pixels,blob);
  for(float z=24;z<=268;z*=1.2f)for(float r=z/2+1;r<=270-z/2-1;r+=z*.1f)
   for(float c=z/2+1;c<=480-z/2-1;c+=z*.1f){
    float a=0,b=0;int ra=run_cascade(blob,&a,r,c,z,pixels,270,480,480),rb=window_score(&b,r,c,z);
    if(ra!=rb||!equal_float(a,b)){printf("FAIL window case%u r%f c%f size%f\n",n,r,c,z);return 6;}
    checks++;
   }
  m7_begin(edges);m7_face_begin(pixels,blob);
  float z=24,r=13,c=13,delta_ref=2.4f;
  while(z<=268){
   if(!equal_float(z,scale)||!equal_float(r,row)||!equal_float(c,col))return 7;
   m7_face_step(1);scan_checks++;
   c+=delta_ref;
   if(c>480-z/2-1){c=z/2+1;r+=delta_ref;}
   if(r>270-z/2-1){z*=1.2f;r=c=z/2+1;delta_ref=z*.1f;}
  }
  if(!finished)return 8;
 }
 fclose(f);
 printf("PASS %u Pico windows: decisions and FP32 scores bit-identical to upstream; %u scan positions bit-identical\n",checks,scan_checks);
 return 0;
}
