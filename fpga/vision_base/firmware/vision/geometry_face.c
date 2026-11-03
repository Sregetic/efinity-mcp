#include "geometry_face.h"
static const int16_t outline[48][4]={
 {128,0,256,0},
 {145,1,254,33},
 {161,4,247,66},
 {177,10,237,98},
 {192,17,222,128},
 {206,26,203,156},
 {219,37,181,181},
 {230,50,156,203},
 {239,64,128,222},
 {246,79,98,237},
 {252,95,66,247},
 {255,111,33,254},
 {256,128,0,256},
 {255,145,-33,254},
 {252,161,-66,247},
 {246,177,-98,237},
 {239,192,-128,222},
 {230,206,-156,203},
 {219,219,-181,181},
 {206,230,-203,156},
 {192,239,-222,128},
 {177,246,-237,98},
 {161,252,-247,66},
 {145,255,-254,33},
 {128,256,-256,0},
 {111,255,-254,-33},
 {95,252,-247,-66},
 {79,246,-237,-98},
 {64,239,-222,-128},
 {50,230,-203,-156},
 {37,219,-181,-181},
 {26,206,-156,-203},
 {17,192,-128,-222},
 {10,177,-98,-237},
 {4,161,-66,-247},
 {1,145,-33,-254},
 {0,128,0,-256},
 {1,111,33,-254},
 {4,95,66,-247},
 {10,79,98,-237},
 {17,64,128,-222},
 {26,50,156,-203},
 {37,37,181,-181},
 {50,26,203,-156},
 {64,17,222,-128},
 {79,10,237,-98},
 {95,4,247,-66},
 {111,1,254,-33}
};

/* Complete contours, paired landmarks and crown arcs propose the same head geometry.
   Tangent-aligned outline/eye/nose/mouth checks reject unrelated texture and glyphs.
   Immutable lane input lets geometry process newer frames without waiting for a face. */
static uint32_t edge[M7_WORDS],direction[4][M7_WORDS];
enum {PAD_H=M7_H+8,PAD_WORDS=PAD_H*16};
/* Exact packed-word cache of the existing radius1..4 stencil, CPU DDR only. */
static uint32_t horizontal[5][PAD_WORDS],expanded[4][4][PAD_WORDS];
static unsigned dil_kind,dil_stage,dil_word;
static const uint8_t stencil[5][5]={{0},{1,0},{2,1,0},{3,2,2,0},{4,3,3,2,0}};
/* Normalized cells contain at most 16x8 pixels; modulo-65536 prefixes preserve their exact counts. */
static uint16_t sum[(M7_W+1)*(M7_H+1)];
struct feature {uint16_t x,y,w,h;};
static struct feature features[1024],cache[2048],direct[M7_CONTOURS];
static struct feature simple[M7_CONTOURS];
static unsigned ns;
static uint8_t feature_shape[1024];
static uint32_t eye_marks[40],eye_all[40],mouth_marks[40];
static unsigned nf,nd,di,resume,phase,px,py,row_sum,fi,fj,fm,variant,probe;
static unsigned cap_i,cap_width,cap_variant,required_hits;
static unsigned proposal_only,head_quality[M7_HEAD_PROPOSALS];
static unsigned head_open;
static unsigned fine_mode;
static struct m7_box fine_prior;
static unsigned fine_variant;
static unsigned edge_word,edge_x,edge_y;
static uint32_t pending_edges;
static int center,eye_y,separation,mouth_distance;
static unsigned x0,y0,w,h,hits,outer_hits,quadrant[4],best,occupied;
static uint16_t grid_sum[41][33],col0[32],col1[32],row0[40],row1[40];
static unsigned pose_y,pose_x,pose_m,quality[4];
static uint16_t ring_label[1280],ring_queue[1280];
static uint8_t ring_hits[1281],ring_seen[1281];
static uint16_t ring_sectors[1281];
static uint8_t ring_x0[1281],ring_x1[1281],ring_y0[1281],ring_y1[1281];

/* Streaming 8-connected horizontal-edge components: only two label rows are live. */
struct component {uint16_t x0,y0,x1,y1;uint32_t area;};
static struct component components[481];
static uint16_t parent[481],previous[M7_W],current[M7_W],remap[481];
static uint8_t active[481];
static unsigned labels;

struct m7_box m7_face_boxes[4];
unsigned m7_face_count,m7_face_more;
struct m7_box m7_head_proposals[M7_HEAD_PROPOSALS];
unsigned m7_head_count;
static int absolute(int x){return x<0?-x:x;}
static unsigned minimum(unsigned a,unsigned b){return a<b?a:b;}
static unsigned maximum(unsigned a,unsigned b){return a>b?a:b;}
static unsigned pixel(int x,int y){
 if(x<0||x>=M7_W||y<0||y>=M7_H)return 0;
 unsigned p=y*M7_W+x;return !!(edge[p>>5]&m7_bit_mask[p&31]);
}
static void feature(unsigned x,unsigned y,unsigned fw,unsigned fh,unsigned area,unsigned isolated){
 if(fw<3||fw>64||fh<1||fh>fw)return;
 for(unsigned i=0;i<nf;i++)if(features[i].x==x&&features[i].y==y&&features[i].w==fw&&features[i].h==fh)return;
 // shortcut: retain 1024 edge landmarks; denser scenes need streamed landmark pairing.
 if(nf<1024){feature_shape[nf]=(2*area>=fw*fh?1:0)|(16*area>=fw*fh?2:0)|(isolated?4:0);features[nf++]=(struct feature){x,y,fw,fh};}
}
static void orientation(unsigned x,unsigned y){
 int n=0,sx=0,sy=0,xx=0,yy=0,xy=0;
 for(int dy=-2;dy<=2;dy++)for(int dx=-2;dx<=2;dx++)if(pixel((int)x+dx,(int)y+dy)){
  n++;sx+=dx;sy+=dy;xx+=dx*dx;yy+=dy*dy;xy+=dx*dy;
 }
 if(n<3)return;
 int vx=xx*n-sx*sx,vy=yy*n-sy*sy,cov=xy*n-sx*sy;
 int a=vx-vy,b=2*cov,trace=vx+vy;
 unsigned spread=(unsigned)(a*a+b*b);
 if(spread*10<(unsigned)(trace*trace)*3)return;
 int dots[4]={a,b,-a,-b};unsigned p=y*M7_W+x;
 for(unsigned k=0;k<4;k++)if(dots[k]>=0&&(unsigned)(dots[k]*dots[k])*4>=spread)direction[k][p>>5]|=m7_bit_mask[p&31];
}
static unsigned root(unsigned v){while(parent[v]!=v){parent[v]=parent[parent[v]];v=parent[v];}return v;}
static unsigned unite(unsigned a,unsigned b){
 a=root(a);b=root(b);if(a==b)return a;
 if(a>b){unsigned t=a;a=b;b=t;}parent[b]=a;
 struct component *p=&components[a],*q=&components[b];
 p->x0=minimum(p->x0,q->x0);p->y0=minimum(p->y0,q->y0);p->x1=maximum(p->x1,q->x1);p->y1=maximum(p->y1,q->y1);p->area+=q->area;
 return a;
}
static void component_pixel(unsigned x,unsigned y){
 unsigned p=y*M7_W+x,v=0;current[x]=0;
 if(!(direction[0][p>>5]&m7_bit_mask[p&31]))return;
 unsigned near[4]={x?current[x-1]:0,x?previous[x-1]:0,previous[x],x+1<M7_W?previous[x+1]:0};
 for(unsigned i=0;i<4;i++)if(near[i])v=v?unite(v,near[i]):root(near[i]);
 if(!v){v=++labels;parent[v]=v;components[v]=(struct component){x,y,x,y,0};}
 struct component *c=&components[v];c->x0=minimum(c->x0,x);c->x1=maximum(c->x1,x);c->y1=y;c->area++;current[x]=v;
}
static void component_row(unsigned last){
 for(unsigned i=1;i<=labels;i++)active[i]=0;
 for(unsigned x=0;x<M7_W;x++)if(current[x]){current[x]=root(current[x]);if(!last)active[current[x]]=1;}
 unsigned count=0;
 for(unsigned i=1;i<=labels;i++)if(parent[i]==i){
  struct component c=components[i];
  if(!active[i]){if(c.area>=3)feature(c.x0,c.y0,c.x1-c.x0+1,c.y1-c.y0+1,0,0);}
  else{remap[i]=++count;components[count]=c;parent[count]=count;}
 }
 for(unsigned x=0;x<M7_W;x++)previous[x]=last||!current[x]?0:remap[current[x]];
 labels=count;
}
static unsigned row_has(unsigned k,int left,int right,int y){
 if(y<0||y>=M7_H||right<0||left>=M7_W)return 0;
 if(left<0)left=0;if(right>=M7_W)right=M7_W-1;
 unsigned a=y*M7_W+left,b=y*M7_W+right,lo=a&31,hi=b&31;
 uint32_t lower=~(m7_bit_mask[lo]-1u),upper=(m7_bit_mask[hi]-1u)|m7_bit_mask[hi];
 if((a>>5)==(b>>5))return !!(direction[k][a>>5]&lower&upper);
 return !!((direction[k][a>>5]&lower)||(direction[k][b>>5]&upper));
}
static unsigned sparse_nearby(unsigned k,int x,int y,unsigned radius){
 /* Circular integer stencils keep a dense rectangle from satisfying a curved arc. */
 for(int dy=-(int)radius;dy<=(int)radius;dy++){
  unsigned r=stencil[radius][absolute(dy)];if(row_has(k,x-r,x+r,y+dy))return 1;
 }
 return 0;
}
static unsigned nearby(unsigned k,int x,int y,unsigned radius){
 if(fine_mode)return sparse_nearby(k,x,y,radius);
 if(x< -4||x>=M7_W+4||y< -4||y>=M7_H+4)return 0;
 unsigned p=(y+4)*512+x+16;return !!(expanded[k][radius-1][p>>5]&m7_bit_mask[p&31]);
}
static unsigned arc(unsigned i,unsigned outside){
 int u=outline[i][0],v=outline[i][1];
 if(outside){u=(u*6-128)/5;v=(v*6-128)/5;}
 int x=(int)x0+(u*(int)(w-1)+128)/256,y=(int)y0+(v*(int)(h-1)+128)/256;
 int tx=outline[i][2]*(int)w,ty=outline[i][3]*(int)h,ax=absolute(tx),ay=absolute(ty);
 unsigned k=ay*12<=ax*5?0:ax*12<=ay*5?2:((tx<0)==(ty<0)?1:3);
 unsigned radius=minimum(4,maximum(1,(w+12)/24));
 return nearby(k,x,y,radius);
}
static unsigned rect(unsigned l,unsigned t,unsigned r,unsigned b){return grid_sum[b][r]+grid_sum[t][l]-grid_sum[t][r]-grid_sum[b][l];}
static unsigned oriented(unsigned k,unsigned l,unsigned t,unsigned r,unsigned b){
 for(unsigned y=row0[t];y<row1[b-1];y++)if(row_has(k,col0[l],col1[r-1]-1,y))return 1;return 0;
}
static unsigned mark(const uint32_t rows[40],unsigned l,unsigned t,unsigned r,unsigned b){
 uint32_t mask=(m7_bit_mask[r]-1u)&~(m7_bit_mask[l]-1u);
 for(unsigned y=t;y<b;y++)if(rows[y]&mask)return 1;return 0;
}
static unsigned pose(void){
 unsigned ey=pose_y,mid=pose_x,my=pose_m;
 unsigned le=rect(mid-11,ey-2,mid-3,ey+3),re=rect(mid+3,ey-2,mid+11,ey+3);
 unsigned small=minimum(le,re),large=maximum(le,re),gap=rect(mid-2,ey-2,mid+3,ey+2);
 if(small<5||large>3*small||gap>small)return 0;
 if(!mark(mouth_marks,mid-(fine_mode?3:5),my-3,mid+(fine_mode?4:6),minimum(my+4,40)))return 0;
 if(hits<36){
  if(!mark(eye_marks,mid-11,ey-3,mid-2,ey+4)&&!mark(eye_marks,mid+3,ey-3,mid+12,ey+4))return 0;
 }
 unsigned forehead=rect(mid-6,ey-9,mid+6,ey-4);if(forehead>small*2)return 0;
 unsigned mouth=rect(mid-7,my-1,mid+7,my+2),nose=rect(mid-3,ey+2,mid+4,my-1);
 if(mouth<7||(!fine_mode&&nose<2)||nose>48||rect(mid-7,my+3,mid+7,minimum(my+6,40))>mouth*2)return 0;
 /* Eyelids and lips are transverse features, not the vertical sides of a glyph. */
 if(!oriented(0,mid-11,ey-2,mid-3,ey+3)||!oriented(0,mid+3,ey-2,mid+11,ey+3)||!oriented(0,mid-7,my-1,mid+7,my+2))return 0;
 /* A front-lit nose may have no edge; fine head/paired-eye/lip geometry still applies. */
 if(!fine_mode&&!oriented(2,mid-4,ey+2,mid+5,my-1))return 0;
 if(fine_mode){
  /* Fine pixels must resolve two bounded eyelids at the same height. */
  unsigned paired=0;
  for(unsigned y=ey-2;y<=ey+2&&!paired;y++){
   uint32_t left=eye_all[y]&((m7_bit_mask[mid-3]-1u)&~(m7_bit_mask[mid-11]-1u));
   while(left&&!paired){
    unsigned x=__builtin_ctz(left),mirror=2*mid-x;left&=left-1;
    unsigned l=maximum(mid+3,mirror-2),right=minimum(mid+11,mirror+2);
    uint32_t mask=(m7_bit_mask[right+1]-1u)&~(m7_bit_mask[l]-1u);
    for(unsigned r=y-1;r<=y+1;r++)if((eye_all[r]&mask)&&((eye_marks[y]&m7_bit_mask[x])||(eye_marks[r]&mask))){paired=1;break;}
   }
  }
  if(!paired)return 0;
 }
 int score=(int)(small*4+mouth*2)-(int)(gap*3+absolute((int)le-re)+forehead);
 return score>0?(unsigned)score:0;
}
static unsigned coherent_outline(void){
 const unsigned radius=31*31*39*39;
 for(unsigned y=0;y<40;y++)for(unsigned x=0;x<32;x++){
  unsigned cell=y*32+x;ring_label[cell]=0;
  if(!rect(x,y,x+1,y+1))continue;
  int dx=2*(int)x-31,dy=2*(int)y-39;
  unsigned r=dx*dx*39*39+dy*dy*31*31;
  if(r*10<radius*7||r*10>radius*13)continue;
  int tx=-dy*(int)w*31,ty=dx*(int)h*39,ax=absolute(tx),ay=absolute(ty);
  unsigned k=ay*12<=ax*5?0:ax*12<=ay*5?2:((tx<0)==(ty<0)?1:3);
  if(oriented(k,x,y,x+1,y+1))ring_label[cell]=0xffff;
 }
 unsigned components=0;
 for(unsigned cell=0;cell<1280;cell++)if(ring_label[cell]==0xffff){
  unsigned id=++components,head=0,tail=1;ring_queue[0]=cell;ring_label[cell]=id;
  ring_x0[id]=ring_x1[id]=cell%32;ring_y0[id]=ring_y1[id]=cell/32;ring_hits[id]=ring_seen[id]=0;ring_sectors[id]=0;
  while(head<tail){
   unsigned p=ring_queue[head++],x=p%32,y=p/32;
   ring_x0[id]=minimum(ring_x0[id],x);ring_x1[id]=maximum(ring_x1[id],x);ring_y0[id]=minimum(ring_y0[id],y);ring_y1[id]=maximum(ring_y1[id],y);
   /* Join a single missing normalized cell, without changing the accepted Canny plane. */
   for(int dy=-2;dy<=2;dy++)for(int dx=-2;dx<=2;dx++){
    int nx=(int)x+dx,ny=(int)y+dy;if(nx<0||nx>=32||ny<0||ny>=40)continue;
    unsigned n=ny*32+nx;if(ring_label[n]==0xffff){ring_label[n]=id;ring_queue[tail++]=n;}
   }
  }
 }
 for(unsigned i=0;i<48;i++){
  int cx=(outline[i][0]*31+128)/256,cy=(outline[i][1]*39+128)/256;
  for(int dy=-2;dy<=2;dy++)for(int dx=-2;dx<=2;dx++){
   int x=cx+dx,y=cy+dy;if(x<0||x>=32||y<0||y>=40)continue;
   unsigned id=ring_label[y*32+x];
   if(id&&ring_seen[id]!=i+1){ring_seen[id]=i+1;ring_hits[id]++;ring_sectors[id]|=m7_bit_mask[i/3];}
  }
 }
 for(unsigned i=1;i<=components;i++)if(ring_hits[i]>=26&&ring_x1[i]-ring_x0[i]>=23&&ring_y1[i]-ring_y0[i]>=23)return 1;
 /* Hair and jaw often form separate arcs. Together they must explain at least 3/4 of the head. */
 for(unsigned i=1;i<=components;i++)if(ring_hits[i]>=12)for(unsigned j=i+1;j<=components;j++)if(ring_hits[j]>=12){
  unsigned sectors=ring_sectors[i]|ring_sectors[j],count=0;while(sectors){sectors&=sectors-1;count++;}
  if(count>=12&&maximum(ring_x1[i],ring_x1[j])-minimum(ring_x0[i],ring_x0[j])>=23&&maximum(ring_y1[i],ring_y1[j])-minimum(ring_y0[i],ring_y0[j])>=23)return 1;
 }
 return 0;
}
static void retain(unsigned score){
 struct m7_box box={x0,y0,x0+w-1,y0+h-1,w*h,M7_FACE};
 for(unsigned i=0;i<m7_face_count;i++){
  struct m7_box *a=&m7_face_boxes[i];
  int iw=minimum(a->x1,box.x1)-(int)maximum(a->x0,box.x0)+1,ih=minimum(a->y1,box.y1)-(int)maximum(a->y0,box.y0)+1;
  if(iw>0&&ih>0&&(unsigned)(iw*ih)*2>minimum(a->area,box.area)&&score<=quality[i])return;
 }
 /* One connected crown/jaw chain must explain the outline, not unrelated nearby strokes. */
 if(!coherent_outline())return;
 for(unsigned i=0;i<m7_face_count;i++){
  struct m7_box *a=&m7_face_boxes[i];
  int iw=minimum(a->x1,box.x1)-(int)maximum(a->x0,box.x0)+1,ih=minimum(a->y1,box.y1)-(int)maximum(a->y0,box.y0)+1;
  if(iw>0&&ih>0&&(unsigned)(iw*ih)*2>minimum(a->area,box.area)){
   if(score<=quality[i])return;
   for(unsigned j=i;j+1<m7_face_count;j++){m7_face_boxes[j]=m7_face_boxes[j+1];quality[j]=quality[j+1];}m7_face_count--;break;
  }
 }
 if(m7_face_count==4){m7_face_more=1;if(box.area<=m7_face_boxes[3].area)return;}else m7_face_count++;
 unsigned i=m7_face_count-1;while(i&&m7_face_boxes[i-1].area<box.area){m7_face_boxes[i]=m7_face_boxes[i-1];quality[i]=quality[i-1];i--;}
 m7_face_boxes[i]=box;quality[i]=score;
}
static void head_proposal(void){
 // shortcut: below 128 display pixels head width, the 2x cache lost reliable eyes; use native-resolution ROI sampling before expanding this bound.
 if(w<32)return;
 if(hits<26||hits<outer_hits+4||quadrant[0]<3||quadrant[1]<3||quadrant[2]<3||quadrant[3]<3)return;
 unsigned score=hits*800-outer_hits*400;
 unsigned l=x0+w*2/10,r=x0+w*8/10,t=y0+h*35/100,b=y0+h*58/100,mid=x0+w/2;
 unsigned le=(uint16_t)(sum[b*(M7_W+1)+mid-w/10]+sum[t*(M7_W+1)+l]-sum[t*(M7_W+1)+mid-w/10]-sum[b*(M7_W+1)+l]);
 unsigned re=(uint16_t)(sum[b*(M7_W+1)+r]+sum[t*(M7_W+1)+mid+w/10]-sum[t*(M7_W+1)+r]-sum[b*(M7_W+1)+mid+w/10]);
 t=y0+h*20/100;b=y0+h*32/100;l=x0+w*3/10;r=x0+w*7/10;
 unsigned forehead=(uint16_t)(sum[b*(M7_W+1)+r]+sum[t*(M7_W+1)+l]-sum[t*(M7_W+1)+r]-sum[b*(M7_W+1)+l]);
 unsigned eyes=minimum(le,re)&&maximum(le,re)<=3*minimum(le,re)&&forehead<minimum(le,re);
 if(head_open&&!eyes)return;
 if(eyes)score+=8000;
 struct m7_box box={x0,y0,x0+w-1,y0+h-1,w*h,M7_FACE};
 for(unsigned i=0;i<m7_head_count;i++){
  struct m7_box *a=&m7_head_proposals[i];
  int iw=minimum(a->x1,box.x1)-(int)maximum(a->x0,box.x0)+1,ih=minimum(a->y1,box.y1)-(int)maximum(a->y0,box.y0)+1;
  if(iw>0&&ih>0&&(unsigned)(iw*ih)*10>=3*(a->area+box.area-iw*ih)){
   if(score<=head_quality[i])return;
   for(unsigned j=i;j+1<m7_head_count;j++){m7_head_proposals[j]=m7_head_proposals[j+1];head_quality[j]=head_quality[j+1];}m7_head_count--;break;
  }
 }
 if(m7_head_count==M7_HEAD_PROPOSALS){if(score<=head_quality[M7_HEAD_PROPOSALS-1])return;}else m7_head_count++;
 unsigned i=m7_head_count-1;while(i&&head_quality[i-1]<score){m7_head_proposals[i]=m7_head_proposals[i-1];head_quality[i]=head_quality[i-1];i--;}
 m7_head_proposals[i]=box;head_quality[i]=score;
}
static unsigned start_outline(int x,int y){
 if(w<24||h<24||w*2<h||h*3<w*2||x<1||y<1||x+(int)w>=M7_W-1||y+(int)h>=M7_H-1)return 0;
 if(fine_mode&&h*20<w*23)return 0;
 x0=x;y0=y;
 unsigned index=(((x0*31+y0)*31+w)*31+h)&2047;
 struct feature *c=&cache[index];if(c->x==x0&&c->y==y0&&c->w==w&&c->h==h)return 0;
 *c=(struct feature){x0,y0,w,h};hits=outer_hits=probe=proposal_only=head_open=0;for(unsigned i=0;i<4;i++)quadrant[i]=0;return 1;
}
static unsigned candidate(void){
 static const uint8_t widths[4]={22,25,28,32},heights[3]={28,32,36},tops[3]={8,7,9};
 w=separation*widths[variant/9]/10;h=mouth_distance*heights[variant/3%3]/10;
 if(h<w||h*5>w*9)return 0;
 return start_outline(center-(int)w/2,eye_y-(int)h*tops[variant%3]/16);
}
static unsigned simple_outline(void){
 for(unsigned i=0;i<ns;i++){
  struct feature f=simple[i];
  int iw=minimum(x0+w,f.x+f.w)-(int)maximum(x0,f.x),ih=minimum(y0+h,f.y+f.h)-(int)maximum(y0,f.y);
  if(iw>0&&ih>0&&(unsigned)(iw*ih)*10>=w*h*7&&(unsigned)(iw*ih)*10>=f.w*f.h*7)return 1;
 }
 return 0;
}
static void next_candidate(void){if(resume==6)variant++;phase=resume;}
void m7_face_begin(const uint32_t *bits,const struct m7_contour *contours,unsigned count){
 fine_mode=0;
 unsigned any=0;for(unsigned i=0;i<M7_WORDS;i++){edge[i]=bits[i];any|=bits[i];}
 m7_face_count=m7_face_more=m7_head_count=0;
 if(!any){phase=0;return;}
 nf=nd=ns=0;for(unsigned i=0;i<count;i++){
  unsigned cw=contours[i].x1-contours[i].x0+1,ch=contours[i].y1-contours[i].y0+1;
  feature(contours[i].x0,contours[i].y0,cw,ch,contours[i].area2,1);
  if(!contours[i].klass&&cw>=24&&ch>=24)direct[nd++]=(struct feature){contours[i].x0,contours[i].y0,cw,ch};
  if(contours[i].klass==M7_CIRCLE||contours[i].klass==M7_RECTANGLE)simple[ns++]=(struct feature){contours[i].x0,contours[i].y0,cw,ch};
 }
 for(unsigned i=0;i<2048;i++)cache[i].w=0;
 for(unsigned x=0;x<=M7_W;x++)sum[x]=0;
 for(unsigned x=0;x<M7_W;x++)previous[x]=0;
 px=py=row_sum=labels=0;phase=1;
}
void m7_face_begin_fine(const uint32_t *bits,const struct m7_contour *contours,unsigned count,struct m7_box prior){m7_face_begin(bits,contours,count);fine_mode=1;fine_prior=prior;fine_variant=0;}
unsigned m7_face_step(unsigned budget){
 while(budget--){
  if(phase==1){
   for(unsigned k=0;k<4;k++)direction[k][px]=0;
   if(++px==M7_WORDS){px=0;phase=2;}
  }else if(phase==2){
   /* A linear word is one bounded unit; directional fitting visits only set bits. */
   uint32_t bits=edge[(py*M7_W+px)>>5];
   for(unsigned i=0;i<32;i++){
    row_sum+=!!(bits&m7_bit_mask[i]);sum[(py+1)*(M7_W+1)+px+i+1]=sum[py*(M7_W+1)+px+i+1]+row_sum;
   }
   px+=32;
   if(px==M7_W){px=row_sum=0;sum[(++py)*(M7_W+1)]=0;if(py==M7_H){px=py=edge_word=pending_edges=0;phase=12;}}
  }else if(phase==3){
   for(unsigned i=0;i<32;i++)component_pixel(px+i,py);
   px+=32;
   if(px==M7_W){component_row(py+1==M7_H);px=0;if(++py==M7_H){fi=0;fj=1;di=0;phase=fine_mode?13:10;}}
  }else if(phase==4){
   if(fi>=nf||fj>=nf){if(++fi+1>=nf){cap_i=cap_variant=0;cap_width=24;phase=11;continue;}fj=fi+1;continue;}
   struct feature a=features[fi],b=features[fj++];
   int ax=a.x+a.w/2,bx=b.x+b.w/2,ay=a.y+a.h/2,by=b.y+b.h/2;
   unsigned gap=absolute(ax-bx);
   if(minimum(a.w,b.w)*2<maximum(a.w,b.w)||absolute(ay-by)>(int)maximum(a.w,b.w)/3+1||gap<maximum(5,(a.w+b.w)/2)||gap>(a.w+b.w)*3)continue;
   center=(ax+bx)/2;eye_y=(ay+by)/2;separation=gap;fm=0;phase=5;
  }else if(phase==5){
   if(fm==nf){phase=4;continue;}struct feature m=features[fm++];
   int mx=m.x+m.w/2,my=m.y+m.h/2,d=my-eye_y;
   if(d<separation/2||d>separation*3/2||absolute(mx-center)>separation/3+1||m.w<separation/2||m.w>separation*2||m.h*4>m.w*3)continue;
   mouth_distance=d;variant=0;phase=6;
  }else if(phase==6){
   if(variant==36){phase=5;continue;}
   if(!candidate()){variant++;continue;}required_hits=30;resume=6;phase=7;
  }else if(phase==7){
   unsigned hit=arc(probe,0),quarter=probe/12;hits+=hit;quadrant[quarter]+=hit;probe++;
   unsigned propose=!fine_mode&&w>=32,needed=propose?26:required_hits;
   /* Only reject when the unchanged final acceptance rules can no longer pass. */
   if((probe%12==0&&quadrant[quarter]<(propose?3:5))||hits+48-probe<needed){next_candidate();continue;}
   if(probe==48){probe=0;phase=14;}
  }else if(phase==14){
   outer_hits+=arc(probe,1);
   if(hits<outer_hits+(!fine_mode&&w>=32?4:8)){next_candidate();continue;}
   if(++probe==48){
    if(!fine_mode)head_proposal();
    if(proposal_only||w<24||h<24||(fine_mode&&h*20<w*23)){next_candidate();continue;}
    if(hits<required_hits||quadrant[0]<5||quadrant[1]<5||quadrant[2]<5||quadrant[3]<5||hits<outer_hits+8){next_candidate();continue;}
    for(unsigned i=0;i<32;i++){col0[i]=x0+i*w/32;col1[i]=x0+((i+1)*w+31)/32;grid_sum[0][i]=0;}grid_sum[0][32]=0;
    for(unsigned i=0;i<40;i++){row0[i]=y0+i*h/40;row1[i]=y0+((i+1)*h+39)/40;grid_sum[i+1][0]=0;}
    for(unsigned i=0;i<40;i++)eye_marks[i]=eye_all[i]=mouth_marks[i]=0;
    for(unsigned i=0;i<nf;i++){
     struct feature f=features[i];
     if(f.x<x0||f.y<y0||f.x+f.w>x0+w||f.y+f.h>y0+h)continue;
     unsigned cx=(f.x+f.w/2-x0)*32/w,cy=(f.y+f.h/2-y0)*40/h,nw=f.w*32/w,nh=f.h*40/h;
     /* Thin, separate Canny eyelids/lips need not enclose a filled region. */
     if(((feature_shape[i]&1)||(fine_mode&&(feature_shape[i]&4)))&&f.w<=f.h*(fine_mode?32:4)&&nw>=3&&nw<=10&&(!fine_mode||nh<=6))eye_marks[cy]|=m7_bit_mask[cx];
     if(f.w<=f.h*32&&nw>=3&&nw<=10&&nh<=6)eye_all[cy]|=m7_bit_mask[cx];
     if(((feature_shape[i]&2)||(fine_mode&&(feature_shape[i]&4)))&&f.w*2>=f.h*3&&nw>=5&&nw<=(fine_mode?18:21)&&f.h*4<=h&&(!fine_mode||nh<=6))mouth_marks[cy]|=m7_bit_mask[cx];
    }
    px=py=occupied=0;phase=8;
   }
  }else if(phase==8){
   unsigned l=col0[px],r=col1[px],t=row0[py],b=row1[py];
   unsigned on=(uint16_t)(sum[b*(M7_W+1)+r]+sum[t*(M7_W+1)+l]-sum[t*(M7_W+1)+r]-sum[b*(M7_W+1)+l]);on=on!=0;occupied+=on;
   grid_sum[py+1][px+1]=on+grid_sum[py][px+1]+grid_sum[py+1][px]-grid_sum[py][px];
   if(++px==32){px=0;if(++py==40){if(occupied>850)next_candidate();else{pose_y=14;pose_x=14;pose_m=27;best=0;phase=9;}}}
  }else if(phase==9){
   unsigned score=pose();if(score>best)best=score;
   if(++pose_m==36){if(++pose_x==19){pose_x=14;pose_y++;}pose_m=maximum(pose_y+7,27);
    if(pose_y==24){
     if(best)retain(hits*800-outer_hits*400+best*48);
     next_candidate();
    }
   }
  }else if(phase==10){
   if(di==nd){phase=4;continue;}
   struct feature b=direct[di++];w=b.w;h=b.h;
   if(start_outline(b.x,b.y)){required_hits=30;resume=10;phase=7;}
  }else if(phase==11){
   if(cap_i==nf){phase=0;return 1;}
   struct feature f=features[cap_i];
   if(f.h*2>f.w){cap_i++;cap_width=24;cap_variant=0;continue;}
   static const uint8_t ratios[7]={11,12,13,14,15,16,17};
   w=cap_width;h=w*ratios[cap_variant%7]/10;
   int cx=f.x+f.w/2+((int)(cap_variant/7)-2)*(int)w/16;
   if(++cap_variant==35){cap_variant=0;cap_width+=maximum(4,cap_width/8);if(cap_width>256){cap_width=24;cap_i++;}}
   /* A crown fragment must span a measurable part of the proposed head. */
   if(w<f.w||w>16*f.w)continue;
   if(!start_outline(cx-(int)w/2,f.y))continue;
   /* A crown arc alone does not overrule an already recognized simple object. */
   proposal_only=simple_outline();
   unsigned right=arc(12,0),left=arc(36,0),bottom=arc(24,0)||arc(21,0)||arc(27,0);
   if(fine_mode){if(!right||!left||!bottom)continue;}
   else{
    /* A missing coarse cheek/chin is a refinement request, not a final face. */
    if((!right&&!arc(9,0)&&!arc(15,0))||(!left&&!arc(33,0)&&!arc(39,0)))continue;
    head_open=!right||!left||!bottom;proposal_only|=head_open;
   }
   required_hits=36;resume=11;phase=7;
  }else if(phase==13){
   /* A fine pass corrects one known head; it does not rescan the entire frame. */
   if(fine_variant==81){phase=0;return 1;}
   unsigned v=fine_variant++,pw=fine_prior.x1-fine_prior.x0+1,ph=fine_prior.y1-fine_prior.y0+1;
   w=pw*(76+24*(v%3))/100;h=ph*(76+24*(v/3%3))/100;
   int x=(fine_prior.x0+fine_prior.x1+1)/2-(int)w/2+((int)(v/9%3)-1)*(int)pw/10;
   int y=(fine_prior.y0+fine_prior.y1+1)/2-(int)h/2+((int)(v/27)-1)*(int)ph/10;
   if(start_outline(x,y)){required_hits=30;resume=13;phase=7;}
  }else if(phase==12){
   if(!pending_edges){
    if(edge_word==M7_WORDS){px=py=0;dil_kind=dil_stage=dil_word=0;phase=fine_mode?3:15;continue;}
    pending_edges=edge[edge_word++];edge_x=px;edge_y=py;px+=32;if(px==M7_W){px=0;py++;}
    if(!pending_edges)continue;
   }
   unsigned bit=__builtin_ctz(pending_edges);pending_edges&=pending_edges-1;orientation(edge_x+bit,edge_y);
  }else if(phase==15){
   for(unsigned n=0;n<4&&phase==15;n++){
    unsigned word=dil_word&15,y=dil_word>>4;
    if(!dil_stage){
     uint32_t value=0;
     if(y>=4&&y<M7_H+4){
      unsigned base=(y-4)*15;
      if(word)value|=direction[dil_kind][base+word-1]>>16;
      if(word<15)value|=direction[dil_kind][base+word]<<16;
     }
     horizontal[0][dil_word]=value;
    }else{
     uint32_t v=horizontal[0][dil_word],a=word?horizontal[0][dil_word-1]:0,b=word<15?horizontal[0][dil_word+1]:0;
     unsigned r=dil_stage;horizontal[r][dil_word]=horizontal[r-1][dil_word]|(v<<r)|(v>>r)|(a>>(32-r))|(b<<(32-r));
    }
    if(++dil_word==PAD_WORDS){dil_word=0;if(++dil_stage==5){dil_stage=1;phase=16;}}
   }
  }else if(phase==16){
   for(unsigned n=0;n<4&&phase==16;n++){
    unsigned word=dil_word&15,r=dil_stage;int y=dil_word>>4;uint32_t value=0;
    for(int dy=-(int)r;dy<=(int)r;dy++)if(y+dy>=0&&y+dy<PAD_H)value|=horizontal[stencil[r][absolute(dy)]][(y+dy)*16+word];
    expanded[dil_kind][r-1][dil_word]=value;
    if(++dil_word==PAD_WORDS){dil_word=0;if(++dil_stage==5){dil_stage=0;if(++dil_kind==4){px=py=0;phase=3;}else phase=15;}}
   }
  }else return 1;
 }
 return 0;
}
