#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include "../firmware/vision/geometry_m7.h"
#include "../firmware/vision/geometry_face.h"
static void test_retention(void){
 uint32_t bits[M7_WORDS];for(unsigned i=0;i<M7_WORDS;i++)bits[i]=~0u;
 m7_begin(bits);m7_add_face(20,20,40,40);m7_add_face(100,20,118,38);m7_add_face(200,20,216,36);
 m7_add_face(198,18,218,38);m7_add_face(300,20,319,39);m7_add_face(400,20,419,39);
 assert(m7_count==4&&m7_more);
 for(unsigned i=1;i<4;i++)assert(m7_boxes[i-1].area>=m7_boxes[i].area);
}
int main(int argc,char **argv){
 test_retention();
 assert(argc==3);FILE *f=fopen(argv[1],"rb");assert(f);
 void *model=malloc(239632);assert(model&&fread(model,239632,1,f)==1);fclose(f);
 f=fopen(argv[2],"rb");assert(f);
 uint32_t bits[M7_WORDS];static uint8_t gray[M7_W*M7_H];
 while(fread(bits,sizeof(bits),1,f)==1){
  assert(fread(gray,sizeof(gray),1,f)==1);
  m7_begin(bits);unsigned slices=0;
  while(!m7_step(512))assert(++slices<1000000);
  m7_face_begin(gray,model);
  while(!m7_face_step(32))assert(++slices<1000000);
  printf("{\"more\":%u,\"complex\":%u,\"slices\":%u,\"boxes\":[",m7_more,m7_complex,slices);
  for(unsigned i=0;i<m7_count;i++){
   const struct m7_box *b=&m7_boxes[i];
   assert(b->x0<=b->x1&&b->x1<M7_W&&b->y0<=b->y1&&b->y1<M7_H&&b->klass>=1&&b->klass<=3);
   printf("%s[%u,%u,%u,%u,%u]",i?",":"",b->klass,b->x0,b->y0,b->x1,b->y1);
  }
  puts("]}");
 }
 assert(feof(f));fclose(f);free(model);return 0;
}
