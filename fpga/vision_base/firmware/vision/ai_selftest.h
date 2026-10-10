#pragma once
#include "shape_model.h"
#include "connectome.h"
#include "flyhash.h"
#include "ai_selftest_data.h"
/* Three independent fixed inputs; never replace the published camera tensors. */
static unsigned ai_selftest(const struct shape_model *m){
 if(int8_dot4(0x80808080u,0x80808080u)!=65536||int8_mulhi(-2147483647,2147483647)!=-1073741824)return 3;
 uint8_t gray[1024],occupancy[64];int8_t f[128],h[32],o[4];int16_t n[80];uint32_t hash[8];
 for(unsigned v=0;v<3;v++){
  for(unsigned i=0;i<1024;i++)gray[i]=v==0?0:v==1?(uint8_t)i:((i/32+i%32)&1)?255:0;
  shape_features(gray,f);
  for(unsigned i=0;i<128;i++)if(f[i]!=selftest_features[v][i])return 3;
  shape_dense(f,128,m->w0,m->b0,32,m->input_zero,m->hidden_zero,m->m0,m->s0,1,h);
  shape_dense(h,32,m->w1,m->b1,4,m->hidden_zero,m->output_zero,m->m1,m->s1,0,o);
  for(unsigned i=0;i<32;i++)if(h[i]!=selftest_hidden[v][i])return 3;
  for(unsigned i=0;i<4;i++)if(o[i]!=selftest_logits[v][i])return 3;
  for(unsigned i=0;i<64;i++)occupancy[i]=f[64+i]+128;
  flyhash_encode(occupancy,hash);connectome_snapshot(f,n);
  for(unsigned i=0;i<8;i++)if(hash[i]!=selftest_hash[v][i])return 3;
  for(unsigned i=0;i<80;i++)if(n[i]!=selftest_neurons[v][i])return 3;
 }
 return 2;
}
