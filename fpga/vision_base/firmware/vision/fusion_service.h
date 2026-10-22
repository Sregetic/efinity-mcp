#pragma once
#include "control_service.h"
#ifndef FUSION_TEST
#define FUS_R(off) (*(volatile uint32_t *)(0xf8100300u+(off)))
#define FUS_W(off,v) (FUS_R(off)=(v))
#endif
enum { FUS_NONE=0,FUS_WAIT=1,FUS_TEST=2,FUS_AGREE=3,FUS_CONFLICT=4,FUS_UNKNOWN=5,FUS_ERROR=6 };
struct fusion_geometry { uint32_t sequence,frame,render,context,hi,lo; };
struct fusion_job {
 struct fusion_geometry g;uint32_t xy,wh,box0,box1,model,test,minimum_margin,geometry_class,exact,automatic;
 uint32_t telemetry,timing0,timing1;
 uint32_t map[8]; // Latch the analyzed frame's source/display transform, not the next UI setting.
};
static struct fusion_geometry fusion_geometry_read(void){
 struct fusion_geometry g;
 do {g.sequence=FUS_R(0x10);g.frame=FUS_R(0x14);g.render=FUS_R(0x18);g.context=FUS_R(0x1c);
  g.hi=FUS_R(0x20);g.lo=FUS_R(0x24);
 }while(g.sequence!=FUS_R(0x10)); // Completed video record can change between APB reads.
 return g;
}
static uint32_t fusion_max(uint32_t a,uint32_t b){return a>b?a:b;}
static uint32_t fusion_min(uint32_t a,uint32_t b){return a<b?a:b;}
static void fusion_map_box(struct fusion_job *j,uint32_t x,uint32_t y,uint32_t w,uint32_t h){
 uint32_t sx=j->map[0],sy=j->map[1],sw=j->map[2],sh=j->map[3],dw=j->map[4],dh=j->map[5],px=j->map[6],py=j->map[7];
 uint32_t l=fusion_max(x,sx),t=fusion_max(y,sy),r=fusion_min(x+w,sx+sw),b=fusion_min(y+h,sy+sh);
 if(l<r&&t<b){
  j->box0=(px+2+(l-sx)*dw/sw)|((py+2+(t-sy)*dh/sh)<<16);
  j->box1=(px+1+(r-sx)*dw/sw)|((py+1+(b-sy)*dh/sh)<<16);
 }else {j->box0=0xffffffffu;j->box1=0;} // Empty display intersection; the source ROI remains valid.
}
// Classifier coordinates include the two frontend window-center offsets.
// Convert a padded display rectangle into a half-open source rectangle.
static unsigned fusion_roi(struct fusion_job *j,unsigned automatic,uint32_t manual_xy,uint32_t manual_wh){
 struct vision_control_state *s=CONTROL_STATE;
 uint32_t sx=0,sy=0,sw=1920,sh=1080,dw=1920,dh=1080,px=0,py=0;
 if(j->g.render){
  if(!s->good||s->pending||j->g.render!=s->serial)return 0;
  sx=s->commit[0]>>12;sy=s->commit[0]&4095;sw=s->commit[1]>>12;sh=s->commit[1]&4095;
  dw=s->commit[2]>>12;dh=s->commit[2]&4095;px=s->commit[3]>>12;py=s->commit[3]&4095;
 }
 const uint32_t map[8]={sx,sy,sw,sh,dw,dh,px,py};
 for(unsigned i=0;i<8;i++)j->map[i]=map[i];
 unsigned valid=(j->g.hi>>30)&1;
 uint32_t x0=(j->g.hi>>4)&4095,y0=((j->g.hi&15)<<8)|(j->g.lo>>24);
 uint32_t x1=(j->g.lo>>12)&4095,y1=j->g.lo&4095;
 // A clipped object/letterbox boundary is not a complete geometry candidate.
 unsigned eligible=valid&&x0>px+2&&y0>py+2&&x1>=x0&&y1>=y0&&x1<px+dw+1&&y1<py+dh+1;
 j->geometry_class=eligible?(j->g.hi>>28)&3:0;
 if(!automatic){
  j->xy=manual_xy;j->wh=manual_wh;
  uint32_t x=manual_xy&65535,y=manual_xy>>16,w=manual_wh&65535,h=manual_wh>>16;
  if(eligible){
   uint32_t gx=sx+(x0-px-2)*sw/dw,gy=sy+(y0-py-2)*sh/dh;
   uint32_t gr=sx+((x1-px-1)*sw+dw-1)/dw,gb=sy+((y1-py-1)*sh+dh-1)/dh;
   if(gx<x||gy<y||gr>x+w||gb>y+h)j->geometry_class=0;
  }
  fusion_map_box(j,x,y,w,h);
  return 1;
 }
 if(!eligible)return 0;
 x0-=px+2;y0-=py+2;x1-=px+1;y1-=py+1;
 uint32_t pad_x=fusion_max(4,(x1-x0+7)>>3),pad_y=fusion_max(4,(y1-y0+7)>>3);
 x0=x0>pad_x?x0-pad_x:0;y0=y0>pad_y?y0-pad_y:0;
 x1=fusion_min(dw,x1+pad_x);y1=fusion_min(dh,y1+pad_y);
 uint32_t left=sx+x0*sw/dw,top=sy+y0*sh/dh;
 uint32_t right=sx+(x1*sw+dw-1)/dw,bottom=sy+(y1*sh+dh-1)/dh;
 j->xy=left|(top<<16);j->wh=(right-left)|((bottom-top)<<16);
 j->box0=(px+x0+2)|((py+y0+2)<<16);j->box1=(px+x1+1)|((py+y1+1)<<16);
 return 1;
}
static uint32_t fusion_flags(const struct fusion_job *j,unsigned label,const int8_t scores[4]){
 int best=scores[label],runner=-128;
 for(unsigned i=0;i<4;i++)if(i!=label&&scores[i]>runner)runner=scores[i];
 unsigned state=j->test?FUS_TEST:FUS_UNKNOWN;
 if(!j->test&&j->minimum_margin&&best-runner>=(int)j->minimum_margin&&j->geometry_class){
  if((j->geometry_class==1&&label==1)||(j->geometry_class==2&&label==2))state=FUS_AGREE;
  else if(j->geometry_class<=2&&label!=j->geometry_class)state=FUS_CONFLICT;
 }
 return 1u|(j->test<<1)|((j->geometry_class!=0)<<2)|(j->geometry_class<<4)|(label<<6)|(state<<8);
}
extern volatile uint32_t fusion_result[16];
static void fusion_publish(const struct fusion_job *j,uint32_t source_config,uint32_t flags,uint32_t scores){
 flags|=(j->automatic<<3)|j->telemetry;
 const uint32_t words[11]={flags,j->g.frame,source_config,j->g.render,j->model,j->g.context,j->box0,j->box1,scores,j->timing0,j->timing1};
 static uint32_t sequence=0;
 fusion_result[15]=1;fusion_result[0]=0x46555331u;
 for(unsigned i=0;i<9;i++)fusion_result[2+i]=words[i];
 fusion_result[11]=j->xy;fusion_result[12]=j->wh;fusion_result[13]=j->g.sequence;
 __asm__ volatile("fence rw,rw":::"memory");fusion_result[1]=++sequence;fusion_result[15]=0;
 for(unsigned i=0;i<11;i++)FUS_W(0x80+4*i,words[i]);
 FUS_W(8,1);
}

/* One-shot display crop. No frame copying and no continuous target tracking. */
static void control_center_finish(unsigned status){
 struct vision_control_state *s=CONTROL_STATE;
 s->center_status=status;s->center_stage=0;s->feature_dirty=1;
}
static unsigned control_center_box(uint32_t x,uint32_t y,uint32_t w,uint32_t h,
                                  uint32_t frame,uint32_t render,uint32_t context){
 struct vision_control_state *s=CONTROL_STATE;
 if(!w||!h||x+w>1920||y+h>1080)return 0;
 if(s->pending||s->key_roi_dirty||s->serial!=s->center_serial||s->settings!=s->center_settings||s->shape_threshold!=s->center_shape){control_center_finish(CENTER_STALE);return 0;}
 unsigned z=s->center_zoom?s->center_zoom:8;
 // Fit the entire object plus25% breathing room; manual zoom is an upper bound.
 while(z>1&&((w+(w+3)/4)*z>1920||(h+(h+3)/4)*z>1080))z>>=1;
 unsigned cx2=2*x+w,cy2=2*y+h,step=8/z;
 // Trim both sides about the target, then center the output with equal margins.
 unsigned cw=fusion_min(1920/z,fusion_min(cx2,3840-cx2));
 unsigned ch=fusion_min(1080/z,fusion_min(cy2,2160-cy2));
 // Round width up for the8-pixel writer contract without cutting odd-size targets.
 cw=(cw+step-1)&-step;
 if(step==1&&((cw^w)&1))cw--;
 if(z==1)ch=(ch+1)&~1u;else if((ch^h)&1)ch--;
 unsigned left=control_bound(((int)cx2-(int)cw)/2,1920-cw);
 unsigned top=control_bound(((int)cy2-(int)ch)/2,1080-ch);
 s->roi[0]=(left<<12)|top;s->roi[1]=(cw<<12)|ch;
 s->roi[2]=((cw*z)<<12)|(ch*z);s->roi[3]=(((1920-cw*z)/2)<<12)|((1080-ch*z)/2);
 s->roi_enable=1;s->center_frame=frame;s->center_render=render;s->center_context=context;
 control_submit(s);s->center_serial=s->serial;s->center_stage=2;
 return 1;
}
static void control_center_step(void){
 struct vision_control_state *s=CONTROL_STATE;
 if(s->center_seen!=s->center_request){
  s->center_seen=s->center_request;s->center_serial=s->serial;s->center_settings=s->settings;s->center_shape=s->shape_threshold;
  if(s->pending||s->key_roi_dirty||((s->settings>>4)&3)>=2){control_center_finish(CENTER_BUSY);return;}
  if(FUS_R(0)!=0x26101003u){control_center_finish(CENTER_ERROR);return;}
  s->center_stage=1;
 }
 if(!s->center_stage)return;
 if(s->center_stage==2){
  if(!s->pending){control_center_finish(s->good&&s->serial==s->center_serial?CENTER_DONE:CENTER_ERROR);}
  return;
 }
 if(s->pending||s->key_roi_dirty||s->serial!=s->center_serial||s->settings!=s->center_settings||s->shape_threshold!=s->center_shape||((s->settings>>4)&3)>=2){control_center_finish(CENTER_STALE);return;}
#ifdef VISION_FOMO
 if(s->center_stage==3){if(!s->ai_policy||!(s->ai_manual&2))control_center_finish(CENTER_STALE);return;}
#endif
 if(s->feature_dirty||s->feature_wait)return;
 if(s->center_stage==1){
  s->center_sequence=FUS_R(0x10);s->center_stage=4;
#ifdef VISION_FOMO
  if((s->ai_manual&2)&&s->ai_policy){s->center_stage=3;s->ai_request++;}
#endif
  return;
 }
 struct fusion_job j;struct fusion_geometry g=fusion_geometry_read();
 for(unsigned i=0;i<sizeof(g)/4;i++)((volatile uint32_t*)&j.g)[i]=((const uint32_t*)&g)[i];
 if(j.g.sequence==s->center_sequence||!j.g.frame)return;
 if(j.g.render!=(s->enabled?s->serial:0)){control_center_finish(CENTER_STALE);return;}
 if(!fusion_roi(&j,1,0,0)||!j.geometry_class){control_center_finish(CENTER_NONE);return;}
 if(!control_center_box(j.xy&65535,j.xy>>16,j.wh&65535,j.wh>>16,j.g.frame,j.g.render,j.g.context)&&s->center_stage)
  control_center_finish(CENTER_NONE);
}
#ifdef VISION_FOMO
static void control_center_fomo(uint32_t nonce,const struct fusion_job *j,
                                unsigned valid,uint32_t x,uint32_t y,uint32_t w,uint32_t h){
 // Invoke polls key events before returning; honor cancellation/new requests first.
 control_center_step();
 struct vision_control_state *s=CONTROL_STATE;
 if(!nonce||nonce!=s->center_seen||s->center_stage!=3)return;
 struct fusion_geometry latest=fusion_geometry_read();
 if(j->g.render!=(s->enabled?s->serial:0)||j->g.context!=latest.context||
    (((s->settings>>4)&3)==1&&j->g.frame!=latest.frame)){control_center_finish(CENTER_STALE);return;}
 if(!valid){control_center_finish(CENTER_NONE);return;}
 if(!control_center_box(x,y,w,h,j->g.frame,j->g.render,j->g.context)&&s->center_stage)
  control_center_finish(CENTER_NONE);
}
#endif
