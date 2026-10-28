#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include "../firmware/vision/geometry_m7.h"
#include "../firmware/vision/geometry_face.h"
static void test_retention(void){
 m7_count=m7_more=0;
 for(unsigned i=0;i<6;i++)m7_retain(m7_boxes,&m7_count,&m7_more,(struct m7_box){10+i*60,20,40+i*60,60,100+i,3});
 assert(m7_count==4&&m7_more);
 for(unsigned i=1;i<4;i++)assert(m7_boxes[i-1].area>=m7_boxes[i].area);
}
int main(int argc,char **argv){
 test_retention();
 assert(argc==2);FILE *f=fopen(argv[1],"rb");assert(f);
 uint32_t bits[M7_WORDS];static uint8_t gray[M7_W*M7_H];
 while(fread(bits,sizeof(bits),1,f)==1){
  assert(fread(gray,sizeof(gray),1,f)==1);
  m7_begin(bits);unsigned slices=0;
  while(!m7_step(512))assert(++slices<1000000);
  unsigned geometry_slices=slices;
  m7_face_begin(bits,m7_contours,m7_contour_count);
  while(!m7_face_step(32))assert(++slices<1000000);
  for(unsigned i=0;i<m7_face_count;i++)m7_retain(m7_boxes,&m7_count,&m7_more,m7_face_boxes[i]);
  m7_more|=m7_face_more;
  printf("{\"more\":%u,\"complex\":%u,\"slices\":%u,\"geometry_slices\":%u,\"contours\":%u,\"boxes\":[",m7_more,m7_complex,slices,geometry_slices,m7_contour_count);
  for(unsigned i=0;i<m7_count;i++){
   const struct m7_box *b=&m7_boxes[i];
   assert(b->x0<=b->x1&&b->x1<M7_W&&b->y0<=b->y1&&b->y1<M7_H&&b->klass>=1&&b->klass<=3);
   printf("%s[%u,%u,%u,%u,%u]",i?",":"",b->klass,b->x0,b->y0,b->x1,b->y1);
  }
  puts("]}");
  if(m7_face_count){
   unsigned expected_count=m7_face_count,expected_more=m7_face_more;
   struct m7_box expected[4];for(unsigned i=0;i<expected_count;i++)expected[i]=m7_face_boxes[i];
   m7_face_begin(bits,m7_contours,m7_contour_count);
   // New geometry may overwrite both its bitmap and contour table before face completion.
   for(unsigned i=0;i<M7_WORDS;i++)bits[i]=0;
   m7_begin(bits);while(!m7_step(512));while(!m7_face_step(512));
   assert(m7_face_count==expected_count&&m7_face_more==expected_more);
   for(unsigned i=0;i<expected_count;i++){
    const struct m7_box*a=&expected[i],*b=&m7_face_boxes[i];
    assert(a->klass==b->klass&&a->x0==b->x0&&a->y0==b->y0&&a->x1==b->x1&&a->y1==b->y1);
   }
  }

 }
 assert(feof(f));fclose(f);return 0;
}
