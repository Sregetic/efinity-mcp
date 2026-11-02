#include <assert.h>
#include <stdio.h>
#include "../firmware/vision/geometry_face.c"
static uint32_t rng=519;
static uint32_t random_value(void){rng=rng*1664525u+1013904223u;return rng;}
int main(void){
 for(unsigned k=0;k<4;k++)for(unsigned i=0;i<M7_WORDS;i++){
  uint32_t v=~0u;for(unsigned n=0;n<5;n++)v&=random_value();direction[k][i]=v;
 }
 fine_mode=0;dil_kind=dil_stage=dil_word=0;phase=15;while(phase!=3)m7_face_step(128);
 unsigned checked=0;
 for(unsigned k=0;k<4;k++)for(unsigned r=1;r<=4;r++)for(int y=-5;y<=M7_H+4;y++)for(int x=-5;x<=M7_W+4;x++){
  assert(nearby(k,x,y,r)==sparse_nearby(k,x,y,r));checked++;
 }
 printf("PASS %u exact stencil-cache queries, all directions/radii/pixels including padded borders\n",checked);
}
