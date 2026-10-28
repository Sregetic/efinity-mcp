#include "geometry_letters.h"
#include "geometry_letter_templates.h"

/* Share the current contour job's bitmap; the service does not replace it until done. */
static const uint32_t *image;
struct candidate {struct m7_box box;uint16_t reference,other_case,score,other_score;uint8_t accepted,paired,dotted;};
static struct candidate candidates[M7_CONTOURS];
static unsigned count,phase,index,x,y,reference,aspect,pixels,scale,group_i,group_j,group_count,proposals,base_count;
static uint16_t parent[M7_CONTOURS],original[M7_CONTOURS];
static unsigned root(unsigned n){while(parent[n]!=n){parent[n]=parent[parent[n]];n=parent[n];}return n;}
static uint16_t scores[52],references[52];
static uint32_t rows[32],near[32],envelope[32];
static uint8_t xmap[M7_W];
static unsigned absdiff(unsigned a,unsigned b){return a>b?a-b:b-a;}
static unsigned pop(unsigned v){
 v=v-((v>>1)&0x55555555u);v=(v&0x33333333u)+((v>>2)&0x33333333u);
 v=(v+(v>>4))&0x0f0f0f0fu;v+=v>>8;v+=v>>16;return v&63;
}
static unsigned height(const struct m7_box *b){return b->y1-b->y0+1;}
static unsigned same_line(const struct m7_box *a,const struct m7_box *b){
 unsigned h=height(a),k=height(b),top=a->y0>b->y0?a->y0:b->y0,bottom=a->y1<b->y1?a->y1:b->y1;
 return bottom>=top&&(bottom-top+1)*2>=(h<k?h:k)&&absdiff(a->x0,b->x0)<8*(h>k?h:k);
}
void m7_letters_begin(const uint32_t *edges){
 image=edges;count=0;index=0;phase=6;group_i=1;group_j=0;group_count=0;proposals=0;m7_count=m7_more=0;
 for(unsigned n=0;n<m7_contour_count;n++){
  const struct m7_contour *c=m7_contours+n;if(c->klass==M7_INNER_CONTOUR||c->y1-c->y0<7)continue;
  unsigned k=group_count++;parent[k]=k;original[k]=n;
  candidates[k]=(struct candidate){.box={c->x0,c->y0,c->x1,c->y1,0,c->klass}};
 }
}
unsigned m7_letters_step(unsigned budget){
 while(budget--){
  if(phase==6){
   if(group_i>=group_count){phase=1;continue;}
   const struct m7_contour *a=m7_contours+original[group_i],*b=m7_contours+original[group_j];
   unsigned contained=(a->x0>=b->x0&&a->y0>=b->y0&&a->x1<=b->x1&&a->y1<=b->y1)||
                      (b->x0>=a->x0&&b->y0>=a->y0&&b->x1<=a->x1&&b->y1<=a->y1);
   /* Join intersecting fragments, not a surrounding page/frame or a nested object. */
   if(!contained&&
      a->x0<=b->x1+1&&b->x0<=a->x1+1&&a->y0<=b->y1+1&&b->y0<=a->y1+1){
    unsigned ar=root(group_i),br=root(group_j);
    if(ar!=br){if(ar>br){unsigned t=ar;ar=br;br=t;}parent[br]=ar;
     struct m7_box *dst=&candidates[ar].box,*src=&candidates[br].box;
     if(src->x0<dst->x0)dst->x0=src->x0;if(src->y0<dst->y0)dst->y0=src->y0;
     if(src->x1>dst->x1)dst->x1=src->x1;if(src->y1>dst->y1)dst->y1=src->y1;dst->klass=0;
    }
   }
   if(++group_j==group_i){group_i++;group_j=0;}
  }else if(phase==1){
   if(index==group_count){index=0;phase=2;continue;}
   unsigned n=index++;if(root(n)!=n)continue;
   struct m7_box initial=candidates[n].box;const struct m7_box *c=&initial;
   unsigned w=c->x1-c->x0+1,h=c->y1-c->y0+1;
   if(w*4>h*7)continue;
   struct m7_box b={c->x0,c->y0,c->x1,c->y1,w*h,c->klass};
   /* Dotted i/j have a detached, narrow component immediately above the stem. */
   if(w*2<h)for(unsigned j=0;j<m7_contour_count;j++){
    const struct m7_contour *d=&m7_contours[j];unsigned dw=d->x1-d->x0+1,dh=d->y1-d->y0+1;
    if(d->klass!=M7_INNER_CONTOUR&&d->y1<c->y0&&c->y0-d->y1<=h/3&&dw<=h/3&&dh<=h/3&&
       absdiff(d->x0+d->x1,c->x0+c->x1)<=(w>h/3?w:h/3)){
     b.y0=d->y0;if(d->x0<b.x0)b.x0=d->x0;if(d->x1>b.x1)b.x1=d->x1;break;
    }
   }
   /* Include detached serif tips within two input cells of the traced contour. */
   unsigned x0=b.x0>2?b.x0-2:0,y0=b.y0>2?b.y0-2:0,x1=b.x1+2<M7_W?b.x1+2:M7_W-1,y1=b.y1+2<M7_H?b.y1+2:M7_H-1;
   unsigned oldx0=b.x0,oldy0=b.y0,oldx1=b.x1,oldy1=b.y1;
   for(unsigned yy=y0;yy<=y1;yy++)for(unsigned xx=x0;xx<=x1;xx++){
    if(xx>=oldx0&&xx<=oldx1&&yy>=oldy0&&yy<=oldy1){xx=oldx1;continue;}
    unsigned p=yy*M7_W+xx;if(!(image[p>>5]&m7_bit_mask[p&31]))continue;
    if(xx<b.x0)b.x0=xx;if(xx>b.x1)b.x1=xx;if(yy<b.y0)b.y0=yy;if(yy>b.y1)b.y1=yy;
   }
   unsigned duplicate=0;
   for(unsigned j=0;j<count;j++){
    const struct m7_box *a=&candidates[j].box;
    if(absdiff(a->x0,b.x0)<=2&&absdiff(a->y0,b.y0)<=2&&absdiff(a->x1,b.x1)<=2&&absdiff(a->y1,b.y1)<=2){duplicate=1;break;}
   }
   if(!duplicate){unsigned dotted=b.y0+2<c->y0;if(dotted)b.klass=0;candidates[count++]=(struct candidate){.box=b,.dotted=dotted};}
  }else if(phase==2){
   if(index==count){if(!proposals){base_count=count;group_i=1;group_j=0;phase=8;}else{index=0;phase=5;}continue;}
   struct m7_box *b=&candidates[index].box;unsigned w=b->x1-b->x0+1;
   aspect=w*100/height(b);pixels=0;scale=w>height(b)?w:height(b);
   for(unsigned n=0;n<32;n++)rows[n]=0;
   for(unsigned n=0;n<52;n++)scores[n]=65535;
   for(unsigned n=0;n<w;n++)xmap[n]=n*32/scale;
   x=b->x0;y=b->y0;phase=3;
  }else if(phase==3){
   const struct m7_box *b=&candidates[index].box;unsigned p=y*M7_W+x;
   if(image[p>>5]&m7_bit_mask[p&31])rows[(y-b->y0)*32/scale]|=m7_bit_mask[xmap[x-b->x0]];
   if(++x>b->x1){x=b->x0;if(++y>b->y1){
    /* Four directional extrema retain stroke shape when small inner loops are filtered. */
    for(unsigned n=0;n<32;n++){
     unsigned v=rows[n],spread=v;spread|=spread>>1;spread|=spread>>2;spread|=spread>>4;spread|=spread>>8;spread|=spread>>16;
     envelope[n]=(v&-v)|(spread^(spread>>1));
    }
    for(unsigned col=0;col<32;col++){
     unsigned first=32,last=0,mask=m7_bit_mask[col];
     for(unsigned n=0;n<32;n++)if(rows[n]&mask){if(first==32)first=n;last=n;}
     if(first!=32){envelope[first]|=mask;envelope[last]|=mask;}
    }
    for(unsigned n=0;n<32;n++)rows[n]=envelope[n];
    for(unsigned n=0;n<32;n++){
     pixels+=pop(rows[n]);unsigned v=rows[n]|(n?rows[n-1]:0)|(n<31?rows[n+1]:0);near[n]=v|(v<<1)|(v>>1);
    }
    reference=0;phase=4;
   }}
  }else if(phase==4){
   if(reference<M7_LETTER_TEMPLATES){
    const struct m7_letter_template *t=&m7_letter_templates[reference++];
    if(candidates[index].dotted&&t->letter!=34&&t->letter!=35)continue;
    unsigned da=absdiff(aspect,t->aspect);if(da*3>(aspect>t->aspect?aspect:t->aspect))continue;
    unsigned miss=0,diff=0;
    for(unsigned n=0;n<32;n++){miss+=pop(rows[n]&~t->near[n])+pop(t->edge[n]&~near[n]);diff+=pop(rows[n]^t->edge[n]);}
    unsigned score=(miss*1000+diff*100)/(pixels+t->count)+da;
    if(score<scores[t->letter]){scores[t->letter]=score;references[t->letter]=reference-1;}
   }else{
    unsigned best=0;for(unsigned n=1;n<52;n++)if(scores[n]<scores[best])best=n;
    unsigned bar=(best==8||best==34||best==37)&&!candidates[index].dotted;
    unsigned second=65535;for(unsigned n=0;n<52;n++)if(n%26!=best%26&&!(bar&&(n==8||n==34||n==37))&&scores[n]<second)second=scores[n];
    struct candidate *c=&candidates[index];unsigned other=(best+26)%52;
    c->reference=references[best];c->score=scores[best];
    if(scores[best]<=100&&scores[best]*100<second*85){
     c->accepted=1;
     unsigned family=best%26,similar=family==2||family==9||family==14||family==18||family==20||family==21||family==22||family==23||family==25;
     c->paired=bar?2:!c->dotted&&scores[other]<=scores[best]+(similar?80:20);
     if(c->paired==1){c->other_case=references[other];c->other_score=scores[other];}
    }
    index++;phase=2;
   }
  }else if(phase==5){
   if(index==count){index=0;phase=7;continue;}
   struct candidate *c=&candidates[index++];if(!c->accepted)continue;
   const struct m7_letter_template *t=&m7_letter_templates[c->reference];
   unsigned caps=0,anchors=0;int bases=0;
   for(unsigned j=0;j<count;j++)if(candidates+j!=c&&candidates[j].accepted&&!candidates[j].paired&&same_line(&c->box,&candidates[j].box)){
    const struct m7_letter_template *at=&m7_letter_templates[candidates[j].reference];
    unsigned cap=height(&candidates[j].box)*100/at->cap_height;
    caps+=cap;bases+=(int)candidates[j].box.y1-at->baseline*(int)cap/100;anchors++;
   }
   // shortcut: a ring/bar alone also denotes a circle/rectangle; text-row context is required to relabel it.
   if((c->box.klass==M7_CIRCLE||c->box.klass==M7_RECTANGLE)&&!anchors)continue;
   unsigned letter=t->letter;
   if(c->paired==2){
    if(anchors&&height(&c->box)*100/(caps/anchors)<85)c->box.klass=M7_LOWER+8;
    else if(c->box.klass==M7_RECTANGLE||letter==34)c->box.klass=M7_BAR;
    else c->box.klass=M7_UPPER+letter;
   }
   else if(c->paired){
    unsigned resolved=0;
    if(anchors){
     unsigned cap=caps/anchors,ratio=height(&c->box)*100/cap;
     int baseline=((int)c->box.y1-bases/(int)anchors)*100/(int)cap;
     const struct m7_letter_template *ot=&m7_letter_templates[c->other_case];
     int da=baseline-t->baseline,db=baseline-ot->baseline;
     unsigned a=c->score+4*absdiff(ratio,t->cap_height)+4*(da<0?-da:da);
     unsigned b=c->other_score+4*absdiff(ratio,ot->cap_height)+4*(db<0?-db:db);
     if(absdiff(a,b)>12){if(b<a)letter=(letter+26)%52;resolved=1;}
    }
    c->box.klass=resolved?M7_UPPER+letter:M7_CASE_PAIR+letter%26;
   }else c->box.klass=M7_UPPER+letter;
   c->box.area=(c->box.x1-c->box.x0+1)*height(&c->box);
  }else if(phase==8){
   if(group_i>=base_count){proposals=1;index=base_count;phase=2;continue;}
   struct candidate *a=candidates+group_i,*b=candidates+group_j;
   unsigned contained=(a->box.x0>=b->box.x0&&a->box.y0>=b->box.y0&&a->box.x1<=b->box.x1&&a->box.y1<=b->box.y1)||
                      (b->box.x0>=a->box.x0&&b->box.y0>=a->box.y0&&b->box.x1<=a->box.x1&&b->box.y1<=a->box.y1);
   /* Keep originals: only a successful glyph fit can join two disconnected fragments. */
   if(!(a->accepted&&b->accepted)&&!contained&&a->box.x0<=b->box.x1+3&&b->box.x0<=a->box.x1+3&&a->box.y0<=b->box.y1+3&&b->box.y0<=a->box.y1+3){
    struct m7_box v={a->box.x0<b->box.x0?a->box.x0:b->box.x0,a->box.y0<b->box.y0?a->box.y0:b->box.y0,
                    a->box.x1>b->box.x1?a->box.x1:b->box.x1,a->box.y1>b->box.y1?a->box.y1:b->box.y1,0,0};
    unsigned duplicate=0;for(unsigned j=0;j<count;j++){
     const struct m7_box *q=&candidates[j].box;
     if(absdiff(q->x0,v.x0)<=1&&absdiff(q->y0,v.y0)<=1&&absdiff(q->x1,v.x1)<=1&&absdiff(q->y1,v.y1)<=1){duplicate=1;break;}
    }
    if(!duplicate){if(count<M7_CONTOURS)candidates[count++]=(struct candidate){.box=v};else m7_complex++;}
   }
   if(++group_j==group_i){group_i++;group_j=0;}
  }else if(phase==7){
   if(index==count+m7_contour_count){phase=0;return 1;}
   struct m7_box b;
   if(index<count){b=candidates[index++].box;if(b.klass<M7_UPPER)continue;}
   else{
    const struct m7_contour *c=m7_contours+(index++-count);
    if(c->klass!=M7_CIRCLE&&c->klass!=M7_RECTANGLE)continue;
    b=(struct m7_box){c->x0,c->y0,c->x1,c->y1,c->area2/2,c->klass};
   }
   unsigned child=0;
   for(unsigned j=0;j<count;j++){
    const struct m7_box *a=&candidates[j].box;
    if(a->klass>=M7_UPPER&&a->area>b.area&&b.x0>=a->x0&&b.y0>=a->y0&&b.x1<=a->x1&&b.y1<=a->y1){child=1;break;}
   }
   if(!child)m7_retain(m7_boxes,&m7_count,&m7_more,b);
  }else return 1;
 }
 return 0;
}
