#include <assert.h>
#include <stdio.h>
#include <time.h>
#include "geometry_m7.h"
#include "geometry_face.h"
#include "geometry_letters.h"

static void boxes(const struct m7_box *b,unsigned count){
 printf("[");
 for(unsigned i=0;i<count;i++)printf("%s[%u,%u,%u,%u,%u]",i?",":"",b[i].klass,b[i].x0,b[i].y0,b[i].x1,b[i].y1);
 printf("]");
}
int main(int argc,char **argv){
 assert(argc==2);FILE *f=fopen(argv[1],"rb");assert(f);uint32_t bits[M7_WORDS];
 while(fread(bits,sizeof(bits),1,f)==1){
  unsigned geo=0,face=0,letters=0;clock_t start=clock();
  m7_begin(bits);while(!m7_step(2048))assert(++geo<1000000);
  m7_face_begin(bits,m7_contours,m7_contour_count);
  clock_t fs=clock();while(!m7_face_step(128))assert(++face<1000000);clock_t fe=clock();
  m7_letters_begin(bits);while(!m7_letters_step(64))assert(++letters<1000000);
  printf("{\"face_boxes\":");boxes(m7_face_boxes,m7_face_count);
  for(unsigned i=0;i<m7_face_count;i++)m7_retain(m7_boxes,&m7_count,&m7_more,m7_face_boxes[i]);
  printf(",\"merged_boxes\":");boxes(m7_boxes,m7_count);
  printf(",\"face_more\":%u,\"more\":%u,\"complex\":%u,\"geometry_slices\":%u,\"face_slices\":%u,\"letter_slices\":%u,\"host_face_ms\":%.3f,\"host_total_ms\":%.3f,\"contours\":[",m7_face_more,m7_more|m7_face_more,m7_complex,geo+1,face+1,letters+1,1000.0*(fe-fs)/CLOCKS_PER_SEC,1000.0*(clock()-start)/CLOCKS_PER_SEC);
  for(unsigned i=0;i<m7_contour_count;i++){
   const struct m7_contour *p=&m7_contours[i];
   printf("%s[%u,%u,%u,%u,%u,%u]",i?",":"",p->klass,p->x0,p->y0,p->x1,p->y1,p->area2);
  }
  puts("]}");
 }
 assert(feof(f));fclose(f);return 0;
}
