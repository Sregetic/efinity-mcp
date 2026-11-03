#include <assert.h>
#include <stdio.h>
#include <time.h>
#include "geometry_face_refine.h"
#include "geometry_letters.h"
static uint32_t bits[M7_WORDS];
static uint8_t gray[M7_CACHE_W*M7_CACHE_H];
static void boxes(const struct m7_box *a,unsigned n){printf("[");for(unsigned i=0;i<n;i++)printf("%s[%u,%u,%u,%u,%u]",i?",":"",a[i].klass,a[i].x0,a[i].y0,a[i].x1,a[i].y1);printf("]");}
int main(int argc,char **argv){
 assert(argc==2);FILE *f=fopen(argv[1],"rb");assert(f);
 while(fread(bits,sizeof(bits),1,f)==1){
  assert(fread(gray,sizeof(gray),1,f)==1);clock_t start=clock();
  m7_begin(bits);while(!m7_step(2048));m7_letters_begin(bits);while(!m7_letters_step(64));
  m7_face_begin(bits,m7_contours,m7_contour_count);unsigned coarse=0;while(!m7_face_step(128))assert(++coarse<1000000);
  printf("{\"coarse_faces\":");boxes(m7_face_boxes,m7_face_count);printf(",\"head_proposals\":");boxes(m7_head_proposals,m7_head_count);
  clock_t middle=clock();m7_face_refine_begin(gray,96,1);unsigned steps=0;while(!m7_face_refine_step())assert(++steps<1000000);
  printf(",\"face_boxes\":");boxes(m7_face_boxes,m7_face_count);
  for(unsigned i=0;i<m7_face_count;i++)m7_retain(m7_boxes,&m7_count,&m7_more,m7_face_boxes[i]);
  printf(",\"merged_boxes\":");boxes(m7_boxes,m7_count);
  printf(",\"face_more\":%u,\"more\":%u,\"refine_slices\":%u,\"host_refine_ms\":%.3f,\"host_total_ms\":%.3f}\n",m7_face_more,m7_more|m7_face_more,steps+1,1000.0*(clock()-middle)/CLOCKS_PER_SEC,1000.0*(clock()-start)/CLOCKS_PER_SEC);
 }
 assert(feof(f));fclose(f);
}
