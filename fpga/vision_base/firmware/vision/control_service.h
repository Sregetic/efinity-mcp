#pragma once
#include <stdint.h>
#ifndef CONTROL_TEST
#define CTRL_R(off) (*(volatile uint32_t *)(0xf8100200u+(off)))
#define CTRL_W(off,value) (CTRL_R(off)=(value))
#endif
struct vision_control_state {
 uint32_t magic,settings,feature_dirty,feature_wait;
 uint32_t serial,pending,enabled,good,warming,dirty,capture,freeze,reject;
 uint32_t roi[4],commit[4],roi_enable,commit_enable,ai_policy;
 uint32_t menu,key_roi_dirty,shape_threshold;
 uint32_t ai_manual,ai_request,selftest_request;
};
#ifndef CONTROL_TEST
#define CONTROL_STATE ((struct vision_control_state *)0x07620200u)
#endif
#define CONTROL_MAGIC 0x434f4e34u
#ifdef VISION_FOMO
#define CONTROL_LAST_MENU 10
#else
#define CONTROL_LAST_MENU 9
#endif
static uint32_t threshold_up(uint32_t v){return v>2031?2047:v+16;}
static uint32_t threshold_down(uint32_t v){return v<32?16:v-16;}
static void control_threshold(struct vision_control_state *s,unsigned shift,uint32_t value){
 if(value<16)value=16;s->settings=(s->settings&~(2047u<<shift))|((value&2047)<<shift);s->feature_dirty=1;
}
static uint32_t control_bound(int value,unsigned limit){return value<0?0:(unsigned)value>limit?limit:(unsigned)value;}
static void control_submit(struct vision_control_state *s){
 s->serial++;s->pending=1;s->reject=0;s->commit_enable=s->roi_enable;
 for(unsigned i=0;i<4;i++)s->commit[i]=s->roi[i];
 CTRL_W(0x3c,s->serial);CTRL_W(0x38,1);
}
static void control_roi_key(struct vision_control_state *s,unsigned up){
 unsigned x=s->roi[0]>>12,y=s->roi[0]&4095,w=s->roi[1]>>12,h=s->roi[1]&4095;
 unsigned dw=s->roi[2]>>12,dh=s->roi[2]&4095,dx=s->roi[3]>>12,dy=s->roi[3]&4095;
 int step=up?32:-32;
 if(s->menu==2){
  unsigned nw=up?(w>240?(w+1)/2:w):(w<960?w*2:1920);
  unsigned nh=up?(h>135?(h+1)/2:h):(h<540?h*2:1080);
  x=control_bound((int)x+((int)w-(int)nw)/2,1920-nw);y=control_bound((int)y+((int)h-(int)nh)/2,1080-nh);w=nw;h=nh;
 }else if(s->menu==3)x=control_bound((int)x+step,1920-w);
 else if(s->menu==4)y=control_bound((int)y+step/2,1080-h);
 else if(s->menu==5){dw=up?(dw<960?dw*2:1920):(dw>240?(dw/2)&~7u:dw);dh=up?(dh<540?dh*2:1080):(dh>135?dh/2:dh);}
 else if(s->menu==6)dx=control_bound((int)dx+step,1920-dw);
 else if(s->menu==7)dy=control_bound((int)dy+step/2,1080-dh);
 dx=control_bound(dx,1920-dw);dy=control_bound(dy,1080-dh);
 s->roi[0]=(x<<12)|y;s->roi[1]=(w<<12)|h;s->roi[2]=(dw<<12)|dh;s->roi[3]=(dx<<12)|dy;
 s->roi_enable=w!=1920||h!=1080||dw!=1920||dh!=1080;s->key_roi_dirty=1;
}
static uint32_t control_ui(struct vision_control_state *s){
 unsigned m=s->menu,v=0;
 if(m==1)v=(s->settings>>3)&1;
 else if(m==2)v=s->roi[1]>>12;
 else if(m==3)v=s->roi[0]>>12;
 else if(m==4)v=s->roi[0]&4095;
 else if(m==5)v=s->roi[2]>>12;
 else if(m==6)v=s->roi[3]>>12;
 else if(m==7)v=s->roi[3]&4095;
 else if(m==8)v=s->ai_policy;
 else if(m==10)v=(s->ai_manual>>1)&1;
 return (s->shape_threshold<<15)|(m<<11)|v;
}
static void control_event(uint32_t event){
 struct vision_control_state *s=CONTROL_STATE;
 unsigned op=event>>24;uint32_t v=event&0xffffff,old_settings=s->settings;
 unsigned mode=s->settings&7,mem=(s->settings>>4)&3,index=(s->settings>>6)&7;
 if(op==255||op==0x62){
  if(v&1)s->settings=(s->settings&~7u)|((mode+1)&7);
  if(v&8)s->menu=s->menu==CONTROL_LAST_MENU?0:s->menu+1;
  for(unsigned key=1;key<=2;key++)if(v&(1u<<key)){
   if(s->menu==8){
    if(key==1){s->ai_policy=(s->ai_policy+1)%3;s->ai_manual=(s->ai_manual&2)|(s->ai_policy==1);}
    else if(s->ai_policy)s->ai_request++;
   }else if(s->menu==9){if(key==1)s->selftest_request++;}
   else if(s->menu==10)s->ai_manual^=2; // Reuse bit1; bit0 remains single-shot.
   else if(s->menu==1)s->settings=(s->settings&~8u)|(key==1?8:0);
   else if(s->menu>=2)control_roi_key(s,key==1);
   else if(mem>=2){unsigned last=mem==2?6:5;unsigned next=key==1?(index>=last?0:index+1):(index==0||index>last?last:index-1);s->settings=(s->settings&~(7u<<6))|(next<<6);}
   else if(mode==7){unsigned t=s->shape_threshold;s->shape_threshold=key==1?(t>239?255:t+16):(t<=17?1:t-16);}
   else {unsigned shift=(mode==5||mode==6)?20:9;uint32_t t=(old_settings>>shift)&2047;control_threshold(s,shift,key==1?threshold_up(t):threshold_down(t));}
  }
  unsigned next_mem=mem;
  if(v&16)next_mem=mem==0?1:0;
  if(v&32){next_mem=mem==0||mem==3?1:mem+1;s->settings&=~(7u<<6);}
  s->settings=(s->settings&~(3u<<4))|(next_mem<<4);s->feature_dirty=1;
 }else switch(op){
  case 1:s->settings=(s->settings&~7u)|(v&7);s->feature_dirty=1;break;
  case 2:if(mode==7){s->shape_threshold=v<1?1:v>255?255:v;s->feature_dirty=1;}else control_threshold(s,mode==5||mode==6?20:9,v&2047);break;
  case 23:s->shape_threshold=v<1?1:v&255;s->feature_dirty=1;break;
  case 0x28:control_threshold(s,9,v&2047);break;
  case 0x29:control_threshold(s,20,v&2047);break;
  case 3:s->settings=(s->settings&~8u)|((v&1)<<3);s->feature_dirty=1;break;
  case 4:s->settings=(s->settings&~48u)|((v&3)<<4);s->feature_dirty=1;break;
  case 5:s->settings=(s->settings&~(7u<<6))|(((v&7)>(mem==2?6:5)?0:v&7)<<6);s->feature_dirty=1;break;
  case 0x30:s->roi[0]=v;break;case 0x31:s->roi[1]=v;break;
  case 0x32:s->roi[2]=v;break;case 0x33:s->roi[3]=v;break;
  case 0x34:s->roi_enable=v&1;break;
  // Development view policy remains continuous; the board FIX page is single-shot.
  case 0x60:if(v<=2){s->ai_policy=v;s->ai_manual&=2;s->feature_dirty=1;}break;
  case 0x61:if(v<=CONTROL_LAST_MENU){s->menu=v;s->feature_dirty=1;}break;
  case 0x35:
   if(s->pending){s->reject=1;CTRL_W(0x38,3);break;}
   control_submit(s);break;
 }
}
static void control_init(void){
 struct vision_control_state *s=CONTROL_STATE;
 for(unsigned i=0;i<sizeof(*s)/4;i++)((volatile uint32_t*)s)[i]=0;
 s->settings=5|8u|(128u<<9)|(80u<<20);s->roi[1]=(1920u<<12)|1080;s->roi[2]=s->roi[1];
 s->capture=CTRL_R(0x14);s->feature_dirty=1;s->shape_threshold=32;s->magic=CONTROL_MAGIC;
}
static void control_service_step(void){
 struct vision_control_state *s=CONTROL_STATE;
 while(CTRL_R(0x0c)&2)control_event(CTRL_R(4));
 uint32_t flags=CTRL_R(0x0c);
 if(flags>>31)return; // Observable queue fault; main reports it instead of losing commands silently.
 if(s->feature_wait&&!(flags&1))s->feature_wait=0;
 if(s->feature_dirty&&!s->feature_wait&&!(flags&1)){
  CTRL_W(0x44,control_ui(s));
  CTRL_W(8,s->settings);s->feature_wait=1;s->feature_dirty=0;
 }
 uint32_t hw=CTRL_R(0x10),capture=CTRL_R(0x14),freeze=(hw>>6)&1;
 if(capture!=s->capture){s->capture=capture;s->dirty=1;s->warming=0;}
 if(freeze!=s->freeze){s->freeze=freeze;s->dirty=1;}
 // RAW_TO_POOL keeps a published source before ROI is enabled. Freezing pins
 // that source; waiting for another capture here would deadlock the commit.
 if(freeze&&capture!=0)s->warming=0;
 if((hw&(1u<<11))&&(s->good||s->pending==2)){s->good=0;if(s->pending!=1){s->pending=0;CTRL_W(0x38,s->reject<<1);}}
 if(s->pending==2&&!(hw&16)&&CTRL_R(0x18)==s->serial){s->pending=0;s->good=1;CTRL_W(0x38,s->reject<<1);}
 if(s->key_roi_dirty&&!s->pending){s->key_roi_dirty=0;control_submit(s);}
 if(hw&16)return; // Engine still owns the latched geometry; no partial overwrite.
 if(s->pending==1){
  uint32_t dx=s->commit[3]>>12,dy=s->commit[3]&4095,dw=s->commit[2]>>12,dh=s->commit[2]&4095;
  unsigned bad=dx+dw>1920||dy+dh>1080;
  if(!s->commit_enable||bad){
   CTRL_W(0x34,s->serial);
   if(bad&&s->commit_enable){CTRL_W(0x40,s->serial);CTRL_W(0x38,4);}
   else {CTRL_W(0x30,12);CTRL_W(0x38,0);s->enabled=0;s->warming=0;}
   s->pending=0;s->good=0;return;
  }
  if(!s->enabled){s->enabled=1;s->warming=!(freeze&&capture!=0);s->capture=capture;CTRL_W(0x30,5);}
  if(!s->warming&&(hw&(1u<<8))){
   CTRL_W(0x20,s->commit[0]);CTRL_W(0x24,s->commit[1]);CTRL_W(0x28,s->commit[2]);CTRL_W(0x2c,s->commit[3]);
   CTRL_W(0x34,s->serial);CTRL_W(0x30,7);s->pending=2;s->dirty=0;
  }
 }else if(s->enabled&&s->good&&(hw&(1u<<8))&&((freeze&&!(hw&(1u<<7)))||(!freeze&&s->dirty))){CTRL_W(0x30,3);s->dirty=0;}
}
