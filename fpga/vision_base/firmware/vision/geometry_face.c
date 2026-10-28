#include "geometry_face.h"

/* Private snapshots allow the common contour extractor to process newer frames. */
static uint32_t edge[M7_WORDS];
static struct m7_contour parts[M7_CONTOURS];
static unsigned npart,part,phase,px,py,ey,mid,my,best;
static unsigned x0,y0,w,h;
static uint8_t grid[32][32],map_x[M7_W],map_y[M7_H];
static uint16_t integral[33][33];
static uint32_t eyes[32],lips[32];
struct m7_box m7_face_boxes[4];
unsigned m7_face_count,m7_face_more;
static unsigned absdiff(unsigned a,unsigned b){return a>b?a-b:b-a;}
static unsigned rect(unsigned l,unsigned t,unsigned r,unsigned b){
 return integral[b][r]+integral[t][l]-integral[t][r]-integral[b][l];
}
static unsigned landmark(const uint32_t rows[32],unsigned l,unsigned t,unsigned r,unsigned b){
 uint32_t mask=(m7_bit_mask[r]-1u)&~(m7_bit_mask[l]-1u);
 for(unsigned y=t;y<b;y++)if(rows[y]&mask)return 1;
 return 0;
}
static unsigned head(void){
 const struct m7_contour *p=&parts[part];
 x0=p->x0;y0=p->y0;w=p->x1-x0+1;h=p->y1-y0+1;
 /* A face proposal is a non-circular/non-rectangular contour with internal features. */
 return !p->klass&&w>=24&&h>=24&&w*2>=h&&h*3>=w*2;
}
static void prepare(void){
 for(unsigned y=0;y<32;y++){eyes[y]=lips[y]=0;for(unsigned x=0;x<32;x++)grid[y][x]=0;}
 for(unsigned x=0;x<=32;x++)integral[0][x]=0;
 for(unsigned y=0;y<=32;y++)integral[y][0]=0;
 for(unsigned x=0;x<w;x++)map_x[x]=x*32/w;
 for(unsigned y=0;y<h;y++)map_y[y]=y*32/h;
 for(unsigned i=0;i<npart;i++){
  const struct m7_contour *p=&parts[i];
  if(p->x0<x0||p->y0<y0||p->x1>=x0+w||p->y1>=y0+h)continue;
  unsigned pw=p->x1-p->x0+1,ph=p->y1-p->y0+1;
  unsigned cx=(p->x0+p->x1+1-2*x0)*16/w,cy=(p->y0+p->y1+1-2*y0)*16/h;
  unsigned nw=pw*32/w;
  if(pw>=3&&ph>=2&&pw>=ph&&pw<=4*ph&&2*p->area2>=pw*ph&&nw>=3&&nw<=10)eyes[cy]|=m7_bit_mask[cx];
  if(pw>=5&&pw*2>=ph*3&&16*p->area2>=pw*ph&&nw>=5&&nw<=21&&ph*32<=h*10)lips[cy]|=m7_bit_mask[cx];
 }
 px=py=0;phase=2;best=0;
}
static unsigned pose(void){
 unsigned le=rect(mid-10,ey-2,mid-2,ey+3),re=rect(mid+2,ey-2,mid+10,ey+3);
 unsigned small=le<re?le:re,large=le>re?le:re,gap=rect(mid-1,ey-2,mid+2,ey+2);
 if(small<7||large>3*small||gap*2>small+2)return 0;
 if(!landmark(eyes,mid-10,ey-3,mid-1,ey+4)&&!landmark(eyes,mid+2,ey-3,mid+11,ey+4))return 0;
 if(!landmark(lips,mid-4,my-3,mid+5,my+4))return 0;
 unsigned mouth=rect(mid-7,my-1,mid+7,my+2),nose=rect(mid-3,ey+2,mid+4,my-1);
 unsigned below=rect(mid-7,my+3,mid+7,my+6>32?32:my+6),forehead=rect(mid-5,ey-7,mid+5,ey-3);
 if(mouth<11||nose<3||nose>36||forehead>small*2||below>mouth*2)return 0;
 unsigned left=0,right=0;
 for(unsigned y=ey;y<my+3;y++){left+=rect(1,y,8,y+1)!=0;right+=rect(24,y,31,y+1)!=0;}
 if(left*2<my-ey||right*2<my-ey)return 0;
 int score=(int)(small*4+mouth*2)-(int)(gap*3+absdiff(le,re)+forehead);
 return score>0?(unsigned)score:0;
}
void m7_face_begin(const uint32_t *bits,const struct m7_contour *contours,unsigned count){
 for(unsigned i=0;i<M7_WORDS;i++)edge[i]=bits[i];
 for(unsigned i=0;i<count;i++)parts[i]=contours[i];
 npart=count;part=0;phase=1;m7_face_count=m7_face_more=0;
}
unsigned m7_face_step(unsigned budget){
 while(budget--){
  if(phase==1){
   if(part==npart){phase=0;return 1;}
   if(!head()){part++;continue;}prepare();
  }else if(phase==2){
   unsigned p=(y0+py)*M7_W+x0+px;
   if(edge[p>>5]&m7_bit_mask[p&31])grid[map_y[py]][map_x[px]]=1;
   if(++px==w){px=0;if(++py==h){px=py=0;phase=3;}}
  }else if(phase==3){
   integral[py+1][px+1]=grid[py][px]+integral[py][px+1]+integral[py+1][px]-integral[py][px];
   if(++px==32){px=0;if(++py==32){ey=10;mid=13;my=20;phase=4;}}
  }else if(phase==4){
   unsigned score=pose();if(score>best)best=score;
   if(++my==28){
    if(++mid==20){mid=13;ey++;}
    my=ey+6>20?ey+6:20;
    if(ey==19){
     if(best)m7_retain(m7_face_boxes,&m7_face_count,&m7_face_more,(struct m7_box){x0,y0,x0+w-1,y0+h-1,w*h,M7_FACE});
     part++;phase=1;
    }
   }
  }else return 1;
 }
 return 0;
}
