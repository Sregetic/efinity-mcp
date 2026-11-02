#include <stdio.h>
#include <assert.h>
#include "../firmware/vision/geometry_fine_edges.h"
int main(int argc,char **argv){
 assert(argc==3);FILE *f=fopen(argv[1],"rb"),*o=fopen(argv[2],"wb");assert(f&&o);unsigned high,n=0;
 while(fread(&high,4,1,f)==1){
  assert(fread(m7_fine_gray,sizeof(m7_fine_gray),1,f)==1);m7_fine_edges_begin(high,1);unsigned calls=0;
  while(!m7_fine_edges_step(256))assert(++calls<100000);
  assert(fwrite(m7_fine_edges,sizeof(m7_fine_edges),1,o)==1);printf("%u high%u calls%u\n",n++,high,calls+1);
 }
 assert(feof(f));fclose(f);fclose(o);return 0;
}
