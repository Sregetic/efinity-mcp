#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "geometry_m7.h"
static struct m7_context a,b;
static uint32_t bits[2][M7_WORDS];
static void equal(const struct m7_context *c){
 assert(c->count==m7_count&&c->more==m7_more&&c->complex==m7_complex&&c->contour_count==m7_contour_count);
 assert(!memcmp(c->boxes,m7_boxes,m7_count*sizeof(m7_boxes[0])));assert(!memcmp(c->contours,m7_contours,m7_contour_count*sizeof(m7_contours[0])));
}
int main(int argc,char **argv){
 assert(argc==2);FILE *f=fopen(argv[1],"rb");assert(f);unsigned count=0;
 while(fread(bits,sizeof(bits),1,f)==1){
  m7_context_begin(&a,bits[0]);m7_context_begin(&b,bits[1]);unsigned ad=0,bd=0;
  while(!ad||!bd){if(!ad)ad=m7_context_step(&a,7);if(!bd)bd=m7_context_step(&b,11);}
  m7_begin(bits[0]);while(!m7_step(17));equal(&a);m7_begin(bits[1]);while(!m7_step(23));equal(&b);count+=2;
 }
 assert(feof(f));fclose(f);printf("PASS %u interleaved independent/default contour contexts including descriptors and boxes\n",count);
}
