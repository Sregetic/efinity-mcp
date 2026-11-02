#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "../firmware/vision/geometry_fine_edges.c"
static unsigned rng=19;
static unsigned random_byte(void){rng=rng*1664525u+1013904223u;return rng>>24;}
static unsigned count(void){unsigned n=0;for(unsigned i=0;i<M7_WORDS;i++)n+=__builtin_popcount(m7_fine_edges[i]);return n;}
static void run(unsigned high,unsigned median){m7_fine_edges_begin(high,median);unsigned calls=0;while(!m7_fine_edges_step(73))assert(++calls<10000);}
int main(void){
 for(unsigned test=0;test<30512;test++){
  uint8_t a[9];for(unsigned i=0;i<9;i++)a[i]=m7_fine_gray[(i/3)*M7_FINE_W+i%3]=test<512?((test>>i)&1)*255:random_byte();
  for(unsigned i=1;i<9;i++){unsigned j=i;uint8_t v=a[i];while(j&&a[j-1]>v){a[j]=a[j-1];j--;}a[j]=v;}
  assert(median9(1,1)==a[4]);
 }
 for(unsigned median=0;median<2;median++){
  memset(m7_fine_gray,127,sizeof(m7_fine_gray));run(1,median);assert(!count());
  for(unsigned y=0;y<M7_FINE_H;y++)for(unsigned x=0;x<M7_FINE_W;x++)m7_fine_gray[y*M7_FINE_W+x]=x<96?0:255;
  run(96,median);assert(count()==M7_FINE_H-2);
  for(unsigned y=0;y<M7_FINE_H;y++)for(unsigned x=0;x<M7_FINE_W;x++)m7_fine_gray[y*M7_FINE_W+x]=y<120?0:255;
  run(96,median);assert(count()==M7_FINE_W-2);
 }
 memset(state,0,sizeof(state));memset(m7_fine_edges,0,sizeof(m7_fine_edges));
 head=0;tail=1;queue[0]=(10<<8)|10;state[10*M7_FINE_W+10]=2;accepted(10,10);
 for(unsigned p=11;p<=40;p++)state[p*M7_FINE_W+p]=1;
 state[100*M7_FINE_W+100]=1;phase=6;while(!m7_fine_edges_step(7));assert(count()==31);assert(state[100*M7_FINE_W+100]==1);
 for(unsigned i=0;i<sizeof(m7_fine_gray);i++)m7_fine_gray[i]=random_byte();run(1,1);
 for(unsigned y=0;y<M7_H;y++)for(unsigned x=0;x<M7_W;x++)if(x<=M7_FINE_X||x>=M7_FINE_X+M7_FINE_W-1||y<=M7_FINE_Y||y>=M7_FINE_Y+M7_FINE_H-1){unsigned p=y*M7_W+x;assert(!(m7_fine_edges[p>>5]&m7_bit_mask[p&31]));}
 puts("PASS 30512 median cases, flat/axis edges, connected weak edges, ROI bounds and dense ASan/UBSan");
}
