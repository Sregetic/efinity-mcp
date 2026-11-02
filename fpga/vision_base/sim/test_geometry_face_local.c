#include <assert.h>
#include <stdio.h>
#include "geometry_face.h"
int main(int argc,char **argv){
 assert(argc==2);FILE*f=fopen(argv[1],"rb");assert(f);uint32_t bits[M7_WORDS],v[5];unsigned n=0;
 while(fread(bits,sizeof(bits),1,f)==1){
  assert(fread(v,sizeof(v),1,f)==1);m7_begin(bits);while(!m7_step(512));
  struct m7_box prior={v[0],v[1],v[2],v[3],0,M7_FACE};m7_face_begin_fine(bits,m7_contours,m7_contour_count,prior);unsigned steps=0;while(!m7_face_step(128))assert(++steps<1000000);
  if(m7_face_count!=v[4]){printf("FAIL local case%u got%u expected%u\n",n,m7_face_count,v[4]);return 1;}n++;
 }
 assert(feof(f));fclose(f);printf("PASS %u bounded local face cases: isolated open lips/eyelids, missing features and non-face lines\n",n);
}
