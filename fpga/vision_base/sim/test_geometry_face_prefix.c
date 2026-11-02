#include <assert.h>
#include <stdio.h>
#include "../firmware/vision/geometry_face.c"

int main(void){
 uint32_t bits[M7_WORDS],rng=20261029;
 for(unsigned pattern=0;pattern<3;pattern++){
  for(unsigned i=0;i<M7_WORDS;i++){
   rng=rng*1664525u+1013904223u;
   bits[i]=pattern==0?~0u:pattern==1?(rng|0xaaaaaaaa):0xffffff00u;
  }
  m7_face_begin(bits,0,0);unsigned steps=0;
  while(phase!=12){assert(phase==1||phase==2);m7_face_step(1);assert(++steps<10000);}
  for(unsigned i=0;i<10000;i++){
   rng=rng*1664525u+1013904223u;unsigned l=rng%465;
   rng=rng*1664525u+1013904223u;unsigned t=rng%263;
   unsigned r=l+1+(rng>>16)%16,b=t+1+(rng>>24)%8,expected=0;
   for(unsigned y=t;y<b;y++)for(unsigned x=l;x<r;x++)expected+=pixel(x,y);
   unsigned value=(uint16_t)(sum[b*(M7_W+1)+r]+sum[t*(M7_W+1)+l]-sum[t*(M7_W+1)+r]-sum[b*(M7_W+1)+l]);
   assert(value==expected);
  }
 }
 puts("PASS 30000 bounded-cell queries through wrapped production prefix sums, including dense planes above 65535 edges");
 return 0;
}
