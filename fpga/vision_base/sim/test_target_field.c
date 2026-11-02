#include <assert.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include "target_track.h"
static uint32_t accepted[4050];static uint8_t ink[480*270],gray[4096];static uint64_t edges[64];
static struct target_track tracker;
static unsigned pixel(int x,int y){if(x<0||x>=1920||y<0||y>=1080)return 0;return ink[y/4*480+x/4];}
int main(int argc,char**argv){
 assert(argc==2);FILE*f=fopen(argv[1],"rb");assert(f&&fread(accepted,4,4050,f)==4050);fclose(f);
 // Reconstruct a binary printed stroke between its real camera Canny boundary pairs.
 for(unsigned y=95;y<=139;y++){
  unsigned begin=0,runs=0,last=0,was=0;
  for(unsigned x=200;x<=242;x++){
   unsigned p=y*480+x,on=x<=241&&(accepted[p>>5]>>(p&31)&1);
   if(on&&!was){if(!(runs&1))begin=x;runs++;}
   if(was&&!on&&(runs&1)==0)for(unsigned k=begin;k<x;k++)ink[y*480+k]=255;
   was=on;last=x;
  }
  (void)last;
 }
 struct tt_reference r;tt_reference_edges(&r,accepted,800,380,168,180,1,100);tt_select(&tracker,&r);assert(tracker.state==TT_LOCKED);
 int original_x=tracker.x,original_y=tracker.y;
 for(unsigned n=0;n<20;n++){
  int dx=n<10?(int)n*7:(19-(int)n)*7,dy=n<10?(int)n*8:(19-(int)n)*8;
  for(unsigned y=0;y<64;y++)for(unsigned x=0;x<64;x++)gray[y*64+x]=pixel(tracker.x+((int)x-32)*(int)tracker.sx-dx,tracker.y+((int)y-32)*(int)tracker.sy-dy);
  tt_sobel(gray,edges,40);assert(tt_begin(&tracker,edges,n+2,167+67*n,0));while(!tt_step(&tracker,16));
  printf("{\"sample\":%u,\"expected\":[%d,%d],\"measured\":[%d,%d],\"state\":%u,\"score\":%u}\n",n,original_x+dx,original_y+dy,tracker.x,tracker.y,tracker.state,tracker.best);
  assert(tracker.state==TT_LOCKED&&abs(tracker.x-original_x-dx)<=14&&abs(tracker.y-original_y-dy)<=16);
 }
}
