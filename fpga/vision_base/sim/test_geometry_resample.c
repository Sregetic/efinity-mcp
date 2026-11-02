#include <assert.h>
#include <stdio.h>
#include "../firmware/vision/geometry_face_refine.c"
static uint8_t image[M7_CACHE_W*M7_CACHE_H];
static uint32_t rng=77;
static uint32_t random_value(void){rng=rng*1664525u+1013904223u;return rng;}
int main(void){
 for(unsigned i=0;i<sizeof(image);i++)image[i]=random_value()>>24;cache=image;
 for(unsigned i=0;i<100000;i++){
  int x=(int)(random_value()%(1200*256))-100*256,y=(int)(random_value()%(740*256))-100*256;
  struct sample_axis ax={x>>8,x&255},ay={y>>8,y&255};unsigned fx=x&255,fy=y&255;
  unsigned a=gray_at(x>>8,y>>8)*(256-fx)+gray_at((x>>8)+1,y>>8)*fx,b=gray_at(x>>8,(y>>8)+1)*(256-fx)+gray_at((x>>8)+1,(y>>8)+1)*fx;
  assert(bilinear(&ax,&ay)==(a*(256-fy)+b*fy+32768)>>16);
 }
 m7_face_count=m7_face_more=0;m7_head_count=1;m7_head_proposals[0]=(struct m7_box){1,1,35,60,35*60,M7_FACE};
 assert(m7_face_refine_begin(image,96,1));while(phase==5)m7_face_refine_step();assert(phase==1);
 for(unsigned p=0;p<M7_FINE_W;p++){int q=left*256+(int)(((2*p+1)*width*128)/M7_FINE_W)-128;assert(xs[p].base==(q>>8)&&xs[p].fraction==(q&255));}
 for(unsigned p=0;p<M7_FINE_H;p++){int q=top*256+(int)(((2*p+1)*height*128)/M7_FINE_H)-128;assert(ys[p].base==(q>>8)&&ys[p].fraction==(q&255));}
 puts("PASS 100000 exact bilinear samples including borders; separable axes equal original pixel mapping");
}
