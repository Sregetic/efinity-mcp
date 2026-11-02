#include "geometry_fine_edges.h"

/* CPU-only local Canny: median/gaussian, the existing Sobel ratio, NMS, hysteresis.
   Small eye/lip components remain available; the display Canny plane is untouched. */
uint8_t m7_fine_gray[M7_FINE_W*M7_FINE_H];
uint32_t m7_fine_edges[M7_WORDS];
static uint8_t filtered[M7_FINE_W*M7_FINE_H],state[M7_FINE_W*M7_FINE_H];
static uint16_t magnitude[M7_FINE_W*M7_FINE_H],queue[M7_FINE_W*M7_FINE_H];
static unsigned phase,index,x,y,threshold,median_on,head,tail;
static const uint8_t *smooth;

static void window(const uint8_t *image,unsigned px,unsigned py,uint8_t a[9]){
 unsigned l=px?px-1:0,r=px+1<M7_FINE_W?px+1:px,t=py?py-1:0,b=py+1<M7_FINE_H?py+1:py;
 const uint8_t *top=image+t*M7_FINE_W,*mid=image+py*M7_FINE_W,*bottom=image+b*M7_FINE_W;
 a[0]=top[l];a[1]=top[px];a[2]=top[r];a[3]=mid[l];a[4]=mid[px];a[5]=mid[r];a[6]=bottom[l];a[7]=bottom[px];a[8]=bottom[r];
}
static uint8_t median9(unsigned px,unsigned py){
 uint8_t a[9];window(m7_fine_gray,px,py,a);
 /* Same 19 compare/exchanges as vision_median9.sv. */
#define ORDER(l,r) do{if(a[l]>a[r]){uint8_t t=a[l];a[l]=a[r];a[r]=t;}}while(0)
 ORDER(0,7);ORDER(1,2);ORDER(3,5);ORDER(4,8);
 ORDER(0,2);ORDER(1,5);ORDER(3,8);ORDER(4,7);
 ORDER(0,3);ORDER(1,4);ORDER(2,8);ORDER(5,7);
 ORDER(3,4);ORDER(5,6);ORDER(2,5);ORDER(4,6);ORDER(2,3);ORDER(4,5);ORDER(3,4);
#undef ORDER
 return a[4];
}
static void accepted(unsigned px,unsigned py){
 unsigned p=(M7_FINE_Y+py)*M7_W+M7_FINE_X+px;
 m7_fine_edges[p>>5]|=m7_bit_mask[p&31];
}
static void advance(void){if(++x==M7_FINE_W){x=0;y++;}index++;}
void m7_fine_edges_begin(unsigned high,unsigned median){
 threshold=high;median_on=median;phase=1;index=x=y=head=tail=0;
}
unsigned m7_fine_edges_step(unsigned budget){
 while(budget--){
  if(phase==1){
   m7_fine_edges[index++]=0;
   if(index==M7_WORDS){index=0;phase=median_on?2:3;}
  }else if(phase==2){
   filtered[index]=median9(x,y);advance();
   if(index==M7_FINE_W*M7_FINE_H){index=x=y=0;phase=3;}
  }else if(phase==3){
   const uint8_t *src=median_on?filtered:m7_fine_gray;
   uint8_t a[9];window(src,x,y,a);
   unsigned value=a[0]+2*a[1]+a[2]+2*a[3]+4*a[4]+2*a[5]+a[6]+2*a[7]+a[8];
   (median_on?m7_fine_gray:filtered)[index]=(value+8)>>4;advance();
   if(index==M7_FINE_W*M7_FINE_H){smooth=median_on?m7_fine_gray:filtered;index=x=y=0;phase=4;}
  }else if(phase==4){
   unsigned mag=0,dir=0;
   if(x&&y&&x+1<M7_FINE_W&&y+1<M7_FINE_H){
    unsigned p=index;
    int gx=smooth[p-M7_FINE_W+1]+2*smooth[p+1]+smooth[p+M7_FINE_W+1]-smooth[p-M7_FINE_W-1]-2*smooth[p-1]-smooth[p+M7_FINE_W-1];
    int gy=smooth[p+M7_FINE_W-1]+2*smooth[p+M7_FINE_W]+smooth[p+M7_FINE_W+1]-smooth[p-M7_FINE_W-1]-2*smooth[p-M7_FINE_W]-smooth[p-M7_FINE_W+1];
    unsigned ax=gx<0?-gx:gx,ay=gy<0?-gy:gy;mag=ax+ay;
    dir=ay*256<ax*106?0:ax*256<ay*106?2:((gx<0)!=(gy<0)?3:1);
   }
   magnitude[index]=mag;state[index]=dir;advance();
   if(index==M7_FINE_W*M7_FINE_H){index=x=y=0;phase=5;}
  }else if(phase==5){
   unsigned mag=magnitude[index],kind=0;
   if(x&&y&&x+1<M7_FINE_W&&y+1<M7_FINE_H&&mag){
    static const int16_t offset[4]={1,M7_FINE_W+1,M7_FINE_W,M7_FINE_W-1};int step=offset[state[index]];
    if(mag>=magnitude[index-step]&&mag>magnitude[index+step]){
     if(mag>=threshold){kind=2;queue[tail++]=(y<<8)|x;accepted(x,y);}
     else if(mag>=threshold/2)kind=1;
    }
   }
   state[index]=kind;advance();
   if(index==M7_FINE_W*M7_FINE_H)phase=6;
  }else if(phase==6){
   if(head==tail){phase=0;return 1;}
   unsigned p=queue[head++],px=p&255,py=p>>8;
   for(int dy=-1;dy<=1;dy++)for(int dx=-1;dx<=1;dx++){
    int nx=(int)px+dx,ny=(int)py+dy;
    if(nx<=0||nx>=M7_FINE_W-1||ny<=0||ny>=M7_FINE_H-1)continue;
    unsigned next=ny*M7_FINE_W+nx;
    if(state[next]==1){state[next]=2;queue[tail++]=(ny<<8)|nx;accepted(nx,ny);}
   }
  }else return 1;
 }
 return 0;
}
