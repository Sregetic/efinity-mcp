#pragma once
#include "int8.h"
#include "connectome_data.h"
static int32_t connectome_mul(int16_t a,int16_t b){
#ifdef VISION_MULHI_CFU
 return int8_mulhi((int32_t)((uint32_t)(int32_t)a<<16),(int32_t)((uint32_t)(int32_t)b<<16));
#else
 return (int32_t)a*b;
#endif
}
static int32_t connectome_round(int32_t v){return v<0?-((-v+8192)>>14):(v+8192)>>14;}
static int16_t connectome_activation(int32_t v){
 unsigned a=v<0?-v:v,i=a>>8,f=a&255;
 int32_t y=(connectome_tanh[i]*(256-f)+connectome_tanh[i+1]*f+128)>>8;return v<0?-y:y;
}
/* Snapshot descriptor only: fixed circuit, no trained category output. */
static void connectome_snapshot(const int8_t *x,int16_t out[80]){
 int16_t u[8],h[80],n[80];for(unsigned i=0;i<80;i++)h[i]=0;
 for(unsigned r=0;r<2;r++)for(unsigned c=0;c<4;c++){
  unsigned sum=0;for(unsigned y=4*r;y<4*r+4;y++)for(unsigned a=2*c;a<2*c+2;a++)sum+=(int)x[64+8*y+a]+128;
  int32_t v=((int)sum*2-2040)*16384;u[4*r+c]=v<0?-((-v+1020)/2040):(v+1020)/2040;
 }
 for(unsigned step=0;step<3;step++){
  for(unsigned i=0;i<80;i++){
   int32_t acc=0;for(unsigned e=connectome_row[i];e<connectome_row[i+1];e++)acc+=connectome_mul(connectome_weight[e],h[connectome_pre[e]]);
   int32_t drive=connectome_input[i]<0?0:u[connectome_input[i]];
   int16_t t=connectome_activation(drive+connectome_round(connectome_mul(22938,connectome_round(acc))));
   n[i]=connectome_round(connectome_mul(4915,h[i])+connectome_mul(11469,t));
  }
  for(unsigned i=0;i<80;i++)h[i]=n[i];
 }
 for(unsigned i=0;i<80;i++)out[i]=h[i];
}
