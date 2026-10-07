#pragma once
#include <stdint.h>
#include "int8.h"
/* ponytail: fixed128->32->4 FC graph; use TFLM when the selected application
   needs another graph. Layout matches train_shape_cards.py's little-endian blob. */
struct shape_model {
 uint32_t magic;int32_t input_zero,hidden_zero,output_zero,m0,s0,m1,s1;
 int32_t b0[32],b1[4];int8_t w0[32*128],w1[4*32];
};
static int32_t shape_requant(int32_t x,int32_t m,int32_t shift) {
 /* TFLITE_SINGLE_ROUNDING; producer exports a positive Q31 multiplier. */
#ifdef VISION_MULHI_CFU
 /* Producer requires shift<=-2: the discarded low32 cannot change this
    rounding. This preserves single rounding, not a second Q31 rounding. */
 int right=-1-shift;
 return (int8_mulhi(x,m)+(1<<(right-1)))>>right;
#else
 int total_shift=31-shift;
 return (int32_t)(((int64_t)x*m+(1ll<<(total_shift-1)))>>total_shift);
#endif
}
static void shape_dense(const int8_t *x,unsigned in,const int8_t *w,const int32_t *bias,unsigned out,
 int32_t iz,int32_t oz,int32_t mult,int32_t shift,unsigned relu,int8_t *y) {
 for(unsigned o=0;o<out;o++) {
  const int8_t *row=w+o*in;int32_t acc=bias[o],sum=0;
  for(unsigned j=0;j<in;j+=4){uint32_t a=0,b=0;
   for(unsigned k=0;k<4;k++){a|=(uint32_t)(uint8_t)x[j+k]<<(8*k);b|=(uint32_t)(uint8_t)row[j+k]<<(8*k);sum+=row[j+k];}
   acc+=int8_dot4(a,b);
  }
  acc-=iz*sum;int32_t q=shape_requant(acc,mult,shift)+oz;int32_t low=relu?oz:-128;
  y[o]=q<low?low:(q>127?127:q);
 }
}
static void shape_features(const uint8_t *g,int8_t *f) {
 for(unsigned by=0;by<8;by++)for(unsigned bx=0;bx<8;bx++){
  unsigned sum=0,count=0;
  for(unsigned y=4*by;y<4*by+4;y++)for(unsigned x=4*bx;x<4*bx+4;x++){
   int v=g[y*32+x],dx=x?v-g[y*32+x-1]:0,dy=y?v-g[(y-1)*32+x]:0;
   sum+=v;count+=((dx<0?-dx:dx)+(dy<0?-dy:dy))>=32;
  }
  f[8*by+bx]=(sum/16)-128;f[64+8*by+bx]=(count*255/16)-128;
 }
}
