#include "geometry_face_refine.h"
#include "geometry_fine_edges.h"

static struct m7_context work;
static struct m7_box proposals[M7_HEAD_PROPOSALS],result[4];
static unsigned count,more,proposal_count,candidate,phase,index,px,py,high,median_on;
static int left,top;
static unsigned width,height;
static const uint8_t *cache;
struct sample_axis {int16_t base;uint16_t fraction;};
static struct sample_axis xs[M7_FINE_W],ys[M7_FINE_H];
static unsigned minimum(unsigned a,unsigned b){return a<b?a:b;}
static unsigned maximum(unsigned a,unsigned b){return a>b?a:b;}
static unsigned intersection(struct m7_box a,struct m7_box b){
 int w=minimum(a.x1,b.x1)-(int)maximum(a.x0,b.x0)+1,h=minimum(a.y1,b.y1)-(int)maximum(a.y0,b.y0)+1;
 return w>0&&h>0?w*h:0;
}
static unsigned known_head(struct m7_box b){
 for(unsigned i=0;i<count;i++)if(intersection(b,result[i])*2>=minimum(b.area,result[i].area))return 1;
 return 0;
}
static void next(void){
 while(candidate<proposal_count){
  struct m7_box b=proposals[candidate];
  if(known_head(b)){candidate++;continue;}
  width=(b.x1-b.x0+1)*16/5;height=(b.y1-b.y0+1)*16/5;
  if(width*M7_FINE_H<height*M7_FINE_W)width=(height*M7_FINE_W+M7_FINE_H-1)/M7_FINE_H;
  else height=(width*M7_FINE_H+M7_FINE_W-1)/M7_FINE_W;
  left=b.x0+b.x1+1-(int)width/2;top=b.y0+b.y1+1-(int)height/2;
  index=px=py=0;phase=5;return;
 }
 for(unsigned i=0;i<count;i++)m7_face_boxes[i]=result[i];m7_face_count=count;m7_face_more=more;phase=0;
}
static unsigned gray_at(int x,int y){return x<0||y<0||x>=M7_CACHE_W||y>=M7_CACHE_H?0:cache[y*M7_CACHE_W+x];}
static unsigned bilinear(const struct sample_axis *x,const struct sample_axis *y){
 int ix=x->base,iy=y->base,fx=x->fraction,fy=y->fraction;
 int a=gray_at(ix,iy),b=gray_at(ix,iy+1);
 a=(a<<8)+((int)gray_at(ix+1,iy)-a)*fx;b=(b<<8)+((int)gray_at(ix+1,iy+1)-b)*fx;
 return ((a<<8)+(b-a)*fy+32768)>>16;
}
static unsigned coordinate(int value,unsigned limit){if(value<0)return 0;return (unsigned)value>=limit?limit-1:value;}
static struct m7_box mapped(struct m7_box b){
 int x0=(left*M7_FINE_W+((int)b.x0-M7_FINE_X)*(int)width)/(2*M7_FINE_W),y0=(top*M7_FINE_H+((int)b.y0-M7_FINE_Y)*(int)height)/(2*M7_FINE_H);
 int x1=(left*M7_FINE_W+((int)b.x1-M7_FINE_X+1)*(int)width)/(2*M7_FINE_W)-1,y1=(top*M7_FINE_H+((int)b.y1-M7_FINE_Y+1)*(int)height)/(2*M7_FINE_H)-1;
 b.x0=coordinate(x0,M7_W);b.y0=coordinate(y0,M7_H);b.x1=coordinate(x1,M7_W);b.y1=coordinate(y1,M7_H);b.area=(b.x1-b.x0+1u)*(b.y1-b.y0+1u);return b;
}
unsigned m7_face_refine_begin(const uint8_t *gray,unsigned threshold,unsigned median){
 cache=gray;high=threshold;median_on=median;count=m7_face_count;more=m7_face_more;
 for(unsigned i=0;i<count;i++)result[i]=m7_face_boxes[i];
 proposal_count=m7_head_count;for(unsigned i=0;i<proposal_count;i++)proposals[i]=m7_head_proposals[i];candidate=0;next();return phase!=0;
}
unsigned m7_face_refine_step(void){
 if(phase==5){
  for(unsigned i=0;i<256&&index<M7_FINE_W+M7_FINE_H;i++,index++){
   unsigned vertical=index>=M7_FINE_W,p=vertical?index-M7_FINE_W:index;
   int q=vertical?top*256+(int)(((2*p+1)*height*128)/M7_FINE_H)-128:left*256+(int)(((2*p+1)*width*128)/M7_FINE_W)-128;
   (vertical?ys:xs)[p]=(struct sample_axis){q>>8,q&255};
  }
  if(index==M7_FINE_W+M7_FINE_H){index=0;phase=1;}
 }else if(phase==1){
  for(unsigned i=0;i<256&&index<M7_FINE_W*M7_FINE_H;i++){
   m7_fine_gray[index++]=bilinear(&xs[px],&ys[py]);if(++px==M7_FINE_W){px=0;py++;}
  }
  if(index==M7_FINE_W*M7_FINE_H){
   /* Head scale is normalized here: larger displayed faces must not raise the local threshold. */
   m7_fine_edges_begin(high/2,median_on);phase=2;
  }
 }else if(phase==2){if(m7_fine_edges_step(256)){m7_context_begin(&work,m7_fine_edges);phase=3;}}
 else if(phase==3){if(m7_context_step(&work,512)){
  struct m7_box p=proposals[candidate];
  struct m7_box prior={M7_FINE_X+((int)p.x0*2-left)*M7_FINE_W/(int)width,M7_FINE_Y+((int)p.y0*2-top)*M7_FINE_H/(int)height,
   M7_FINE_X+(((int)p.x1+1)*2-left)*M7_FINE_W/(int)width-1,M7_FINE_Y+(((int)p.y1+1)*2-top)*M7_FINE_H/(int)height-1,0,M7_FACE};
  m7_face_begin_fine(m7_fine_edges,work.contours,work.contour_count,prior);phase=4;
 }}
 else if(phase==4&&m7_face_step(128)){
  /* A local pass refines this head, not an unrelated face elsewhere in the crop. */
  unsigned best=0;struct m7_box found={0};
  for(unsigned i=0;i<m7_face_count;i++){
   struct m7_box b=mapped(m7_face_boxes[i]),p=proposals[candidate];unsigned common=intersection(b,p),total=b.area+p.area-common;
   if(common*5>=total*2){unsigned score=common*4096u/total;if(score>best){best=score;found=b;}}
  }
  if(best&&!known_head(found))m7_retain(result,&count,&more,found);
  candidate++;next();
 }
 return phase==0;
}
