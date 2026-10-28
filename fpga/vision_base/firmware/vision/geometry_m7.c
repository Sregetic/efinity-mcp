#include "geometry_m7.h"
#ifdef VISION_MULHI_CFU
#include "int8.h"
#endif

/* The input is the accepted Canny bitmap, never RGB or display coverage. */
static const uint32_t *image;
static uint32_t visited[M7_WORDS],points[16384];
static uint16_t polygon[65];
static unsigned phase,scan,npoints,walk_steps;
static int px,py,startx,starty,firstx,firsty;
static unsigned back,first_set,xmin,ymin,xmax,ymax,perimeter,overflow;
static int32_t area2;
static unsigned nv,segment,pi,best_index,best_distance,epsilon;
/* Sapphire shifts serially; bitmap membership uses a tiny constant mask table. */
static const uint32_t bit_mask[32]={
 0x00000001u,0x00000002u,0x00000004u,0x00000008u,0x00000010u,0x00000020u,0x00000040u,0x00000080u,
 0x00000100u,0x00000200u,0x00000400u,0x00000800u,0x00001000u,0x00002000u,0x00004000u,0x00008000u,
 0x00010000u,0x00020000u,0x00040000u,0x00080000u,0x00100000u,0x00200000u,0x00400000u,0x00800000u,
 0x01000000u,0x02000000u,0x04000000u,0x08000000u,0x10000000u,0x20000000u,0x40000000u,0x80000000u
};
static const int8_t step_x[8]={1,1,0,-1,-1,-1,0,1};
static const int8_t step_y[8]={0,1,1,1,0,-1,-1,-1};
struct m7_box m7_boxes[4];
unsigned m7_count,m7_more,m7_complex;

static unsigned on(int x,int y){
 if(x<0||x>=M7_W||y<0||y>=M7_H)return 0;
 unsigned p=(unsigned)y*M7_W+(unsigned)x;
 return !!(image[p>>5]&bit_mask[p&31]);
}
static int point_x(unsigned n){return points[n==npoints?0:n]&511;}
static int point_y(unsigned n){return points[n==npoints?0:n]>>9;}
static unsigned distance(unsigned a,unsigned b){
 int dx=point_x(a)-point_x(b),dy=point_y(a)-point_y(b);
 return (unsigned)(dx*dx+dy*dy);
}
static int absolute(int v){return v<0?-v:v;}
static unsigned box_area(const struct m7_box *b){return (b->x1-b->x0+1u)*(b->y1-b->y0+1u);}
static void retain(struct m7_box b){
 for(unsigned i=0;i<m7_count;i++){
  struct m7_box *a=&m7_boxes[i];
  int overlap_x=(a->x1<b.x1?a->x1:b.x1)-(int)(a->x0>b.x0?a->x0:b.x0)+1;
  int overlap_y=(a->y1<b.y1?a->y1:b.y1)-(int)(a->y0>b.y0?a->y0:b.y0)+1;
  unsigned close=absolute((int)a->x0-b.x0)<=3&&absolute((int)a->y0-b.y0)<=3&&
                 absolute((int)a->x1-b.x1)<=3&&absolute((int)a->y1-b.y1)<=3;
  unsigned face_pair=(a->klass==M7_FACE||b.klass==M7_FACE)&&
     overlap_x>0&&overlap_y>0&&(unsigned)(overlap_x*overlap_y)*10>=box_area(a)*7&&(unsigned)(overlap_x*overlap_y)*10>=box_area(&b)*7;
  if(close||face_pair){
   if(!(b.klass==M7_FACE||(a->klass!=M7_FACE&&b.area>a->area)))return;
   for(unsigned j=i;j+1<m7_count;j++)m7_boxes[j]=m7_boxes[j+1];
   m7_count--;break;

  }
 }
 if(m7_count==4){
  m7_more=1;
  if(b.area<=m7_boxes[3].area)return;
 }else m7_count++;
 unsigned i=m7_count-1;
 while(i&&m7_boxes[i-1].area<b.area){m7_boxes[i]=m7_boxes[i-1];i--;}
 m7_boxes[i]=b;
}
static void polygon_result(void){
 unsigned klass=0,w=xmax-xmin+1,h=ymax-ymin+1;
 /* Closed RDP must also simplify the arbitrary first point on an edge. */
 for(unsigned i=0;i<nv&&nv>3;){
  unsigned a=polygon[(i+nv-1)%nv],b=polygon[i],c=polygon[(i+1)%nv];
  int dx=point_x(c)-point_x(a),dy=point_y(c)-point_y(a);
  int ux=point_x(b)-point_x(a),uy=point_y(b)-point_y(a);
  int cross=dx*uy-dy*ux,dot=dx*ux+dy*uy;
  unsigned length=distance(a,c);
  if(dot>=0&&(unsigned)dot<=length&&(uint64_t)((int64_t)cross*cross)*65536<=(uint64_t)epsilon*epsilon*length){
   for(unsigned j=i;j+1<nv;j++)polygon[j]=polygon[j+1];
   nv--;if(i)i--;
  }else i++;
 }
 if(nv==4){
  unsigned good=1;int sign=0;
  for(unsigned i=0;i<4;i++){
   unsigned a=polygon[i],b=polygon[(i+1)&3],c=polygon[(i+2)&3];
   int ux=point_x(a)-point_x(b),uy=point_y(a)-point_y(b);
   int vx=point_x(c)-point_x(b),vy=point_y(c)-point_y(b);
   int cross=ux*vy-uy*vx,dot=ux*vx+uy*vy;
   uint64_t lengths=(uint64_t)(ux*ux+uy*uy)*(vx*vx+vy*vy);
   if(!cross||!lengths||(sign&&((cross>0)!=(sign>0))))good=0;
   if((uint64_t)((int64_t)dot*dot)*100>lengths*18)good=0;
   sign=cross;
  }
  if(good)klass=M7_RECTANGLE;
 }else if(nv>=6&&nv<=16&&w*8>=h*7&&h*8>=w*7){
  int cx2=xmin+xmax,cy2=ymin+ymax,r2=(w+h-2)/2;
  unsigned expected=r2*r2,tolerance=expected/4,miss=0;
  if(tolerance<(unsigned)(4*r2+4))tolerance=4*r2+4;
  for(unsigned i=0;i<npoints;i++){
   int x=2*point_x(i)-cx2,y=2*point_y(i)-cy2;
   if((unsigned)absolute(x*x+y*y-(int)expected)>tolerance)miss++;
  }
  if(miss*10<=npoints)klass=M7_CIRCLE;
 }
 if(klass)retain((struct m7_box){xmin,ymin,xmax,ymax,(unsigned)area2/2,klass});
}
void m7_add_face(unsigned x0,unsigned y0,unsigned x1,unsigned y1){
 unsigned support=0;
 for(unsigned y=y0;y<=y1;y++)for(unsigned x=x0;x<=x1;x++)support+=on(x,y);
 if(support<(x1-x0+y1-y0)/2)return;
 retain((struct m7_box){x0,y0,x1,y1,(x1-x0+1)*(y1-y0+1),M7_FACE});
}
void m7_begin(const uint32_t *edges){
 image=edges;phase=1;scan=0;
 m7_count=m7_more=m7_complex=0;
 for(unsigned i=0;i<M7_WORDS;i++)visited[i]=0;
}
unsigned m7_step(unsigned budget){
 while(budget--){
  if(phase==1){
   if(scan==M7_W*M7_H){phase=0;return 1;}
   unsigned p=scan++;
   if(!(p&31)&&!image[p>>5]){scan=p+32;continue;}
#ifdef VISION_MULHI_CFU
   /* ceil(2^32/480), exact for all 129600 input indices. Reuse the installed CFU. */
   unsigned y=(unsigned)int8_mulhi(p,8947849),x=p-y*M7_W;
#else
   unsigned x=p%M7_W,y=p/M7_W;
#endif
   if(!on(x,y)||on((int)x-1,y)||(visited[p>>5]&bit_mask[p&31]))continue;
   px=startx=x;py=starty=y;back=4;first_set=0;
   xmin=xmax=x;ymin=ymax=y;area2=0;npoints=perimeter=overflow=walk_steps=0;phase=2;
  }else if(phase==2){
   unsigned dir=back,k;
   for(k=0;k<8;k++,dir=(dir+1)&7)if(on(px+step_x[dir],py+step_y[dir]))break;
   if(k==8){unsigned p=py*M7_W+px;visited[p>>5]|=bit_mask[p&31];phase=1;continue;}
   int nx=px+step_x[dir],ny=py+step_y[dir];
   if(first_set&&px==startx&&py==starty&&nx==firstx&&ny==firsty){
    if(overflow||npoints<8||area2<32||xmax-xmin<3||ymax-ymin<3||xmin==0||ymin==0||xmax==M7_W-1||ymax==M7_H-1){phase=1;continue;}
    best_distance=best_index=0;pi=1;phase=3;continue;
   }
   if(!first_set){firstx=nx;firsty=ny;first_set=1;}
   unsigned p=py*M7_W+px,mask=bit_mask[p&31];
   visited[p>>5]|=mask;
   if(npoints<16384)points[npoints++]=(unsigned)px|((unsigned)py<<9);
   else if(!overflow){overflow=1;m7_complex++;} // shortcut: reject >16384-point contours; enlarge DDR scratch if needed.
   if((unsigned)px<xmin)xmin=px;if((unsigned)px>xmax)xmax=px;
   if((unsigned)py<ymin)ymin=py;if((unsigned)py>ymax)ymax=py;
   area2+=px*ny-nx*py;perimeter+=(dir&1)?362:256;
   px=nx;py=ny;back=(((dir>>1)*2)+6)&7;
   /* Eight directed states per pixel bound a Moore traversal. */
   if(++walk_steps>8*M7_W*M7_H){m7_complex++;phase=1;}
  }else if(phase==3){
   unsigned d=distance(0,pi);if(d>best_distance){best_distance=d;best_index=pi;}
   if(++pi==npoints){
    polygon[0]=0;polygon[1]=best_index;polygon[2]=npoints;nv=2;segment=0;pi=1;best_distance=0;
    epsilon=perimeter/50;if(epsilon<128)epsilon=128;phase=4;
   }
  }else if(phase==4){
   unsigned a=polygon[segment],b=polygon[segment+1];
   if(pi<b){
    int dx=point_x(b)-point_x(a),dy=point_y(b)-point_y(a);
    int cross=dx*(point_y(pi)-point_y(a))-dy*(point_x(pi)-point_x(a));
    unsigned v=absolute(cross);if(v>best_distance){best_distance=v;best_index=pi;}
    pi++;continue;
   }
   uint64_t lhs=(uint64_t)best_distance*best_distance*65536;
   uint64_t rhs=(uint64_t)epsilon*epsilon*distance(a,b);
   if(lhs>rhs){
    if(nv==64){phase=1;continue;}
    for(unsigned i=nv+1;i>segment+1;i--)polygon[i]=polygon[i-1];
    polygon[segment+1]=best_index;nv++;
   }else segment++;
   if(segment==nv){polygon_result();phase=1;continue;}
   pi=polygon[segment]+1;best_distance=0;
  }else return 1;
 }
 return 0;
}
