
#include <stdint.h>
#define CONTROL_TEST
#define FUSION_TEST
#define VISION_FOMO
static uint32_t c[32],f[64];
static uint32_t cr(unsigned o){return c[o/4];}
static void cw(unsigned o,uint32_t v){c[o/4]=v;if(o==8)c[3]|=1;if(o==0x30){c[4]=(c[4]&~32u)|((v&1)<<5);if(v&2)c[4]|=16;if(v&4)c[4]&=~(1u<<11);if(v&8)c[6]=c[0x34/4];}}
#define CTRL_R(o) cr(o)
#define CTRL_W(o,v) cw(o,v)
#define FUS_R(o) (f[(o)/4])
#define FUS_W(o,v) (f[(o)/4]=(v))
#define CONTROL_STATE (&state)
extern struct vision_control_state state;
#include "fusion_service.h"
struct vision_control_state state;volatile uint32_t fusion_result[16];
static unsigned checks=0;
static void puts(const char*s){while(*s)*(volatile unsigned char*)0x10000000=*s++;}
static void hex(uint32_t v){const char*s="0123456789abcdef";for(int k=28;k>=0;k-=4)*(volatile unsigned char*)0x10000000=s[(v>>k)&15];}
static void finish(unsigned ok){*(volatile unsigned*)0x100000=ok?0x5555:0x3333;for(;;);}
static void check_line(unsigned ok,unsigned line){checks++;if(!ok){puts("FAIL ");hex(line);puts("\n");finish(0);}}
#define check(x) check_line((x),__LINE__)
static void key(unsigned bits){control_event(0xff000000u|bits);}
static void trace(const char*name){puts("UI ");puts(name);puts(" ");hex(control_ui(&state));puts(" ");hex(state.settings);puts("\n");}
static void reset(void){for(unsigned i=0;i<32;i++)c[i]=0;for(unsigned i=0;i<64;i++)f[i]=0;c[4]=(1<<8)|(1<<6);c[5]=100;f[0]=0x26101003;f[4]=10;f[5]=100;f[7]=5;control_init();state.settings=(state.settings&~48u)|16;}
static void apply(void){control_service_step();c[3]&=~1u;control_service_step();}
static void accept(void){c[4]&=~16u;c[4]|=1u<<7;c[6]=c[0x34/4];control_service_step();}
static void select(unsigned item){
 if(state.sidebar_edit)key(8);
 if(state.sidebar_open==2&&control_sidebar_group(state.sidebar_item)!=control_sidebar_group(item))key(8);
 if(!state.sidebar_open)key(8);
 if(state.sidebar_open==1){while(control_sidebar_group(state.sidebar_item)!=control_sidebar_group(item))key(4);key(1);}
 while(state.sidebar_item!=item)key(4);check(state.sidebar_open==2);
}
static void action(unsigned item){select(item);key(1);check(state.sidebar_edit);key(1);check(!state.sidebar_edit);}
static void geometry(unsigned x,unsigned y,unsigned w,unsigned h,unsigned render,unsigned valid){
 uint64_t box=(1ull<<63)|((uint64_t)valid<<62)|(2ull<<60)|((uint64_t)(x+2)<<36)|((uint64_t)(y+2)<<24)|((uint64_t)(x+w+1)<<12)|(y+h+1);
 f[4]++;f[6]=render;f[8]=box>>32;f[9]=box;
}
static void verify_box(unsigned x,unsigned y,unsigned w,unsigned h,unsigned maxz){
 reset();state.center_zoom=maxz;state.center_serial=state.serial;state.center_settings=state.settings;state.center_shape=state.shape_threshold;
 check(control_center_box(x,y,w,h,100,0,5));
 unsigned sx=state.roi[0]>>12,sy=state.roi[0]&4095,sw=state.roi[1]>>12,sh=state.roi[1]&4095;
 unsigned dw=state.roi[2]>>12,dh=state.roi[2]&4095,dx=state.roi[3]>>12,dy=state.roi[3]&4095,z=dw/sw;
 check(sw&&sh&&dw&&dh&&sx+sw<=1920&&sy+sh<=1080&&dx+dw<=1920&&dy+dh<=1080&&!(dw&7));
 check(z>=1&&z<=8&&(!maxz||z<=maxz)&&dw==sw*z&&dh==sh*z);
 int cx=(int)(dx+(x+w/2-sx)*z)-960,cy=(int)(dy+(y+h/2-sy)*z)-540;
 check(cx>=-4&&cx<=4&&cy>=-4&&cy<=4);
 check(x>=sx&&x+w<=sx+sw&&y>=sy&&y+h<=sy+sh);
 check(state.center_frame==100&&state.center_context==5&&state.center_stage==2&&state.pending==1);
}
void main(void){
 uint32_t isa;__asm__ volatile("csrr %0,misa":"=r"(isa));check((isa&(1u<<8))&&!(isa&0x102du));
 reset();check(offsetof(struct vision_control_state,sidebar_open)==120);
 state.roi[0]=123;state.ai_policy=2;state.sidebar_open=1;state.center_stage=3;control_sidebar_reset();check(state.roi[0]==123&&state.ai_policy==2&&!state.sidebar_open&&!state.center_stage);reset();
 unsigned original=state.settings;key(8);check(state.sidebar_open==1&&!state.sidebar_edit);trace("root");
 key(2);check(state.sidebar_item==SIDE_AI&&state.sidebar_open==1);key(4);check(state.sidebar_item==SIDE_MODE);
 key(1);check(state.sidebar_open==2&&!state.sidebar_edit&&state.settings==original);trace("image");
 key(2);check(state.sidebar_item==SIDE_MEDIAN);key(4);check(state.sidebar_item==SIDE_MODE);
 key(1);key(2);check(state.edit_value==6&&state.settings==original);trace("edit_mode");
 key(8);check(!state.sidebar_edit&&state.sidebar_open==2&&state.settings==original);trace("cancel");
 key(8);check(state.sidebar_open==1&&!state.sidebar_edit);key(8);check(!state.sidebar_open);
 for(unsigned group=0;group<4;group++){
  reset();unsigned saved=state.settings;key(8);for(unsigned j=0;j<group;j++)key(4);
  check(control_sidebar_group(state.sidebar_item)==group&&state.sidebar_open==1&&((control_ui(&state)>>23)&7)==7);
  key(1);check(state.sidebar_open==2&&!state.sidebar_edit&&state.settings==saved&&!state.pending);
  unsigned first=control_sidebar_first(group),count=control_sidebar_count(group);
  for(unsigned j=0;j<count;j++){check(state.sidebar_item==first+j&&!state.pending&&state.settings==saved);key(4);}
  check(state.sidebar_item==first);key(2);check(state.sidebar_item==first+count-1);
  key(8);check(state.sidebar_open==1&&!state.sidebar_edit);key(8);check(!state.sidebar_open);
 }
 reset();
 select(SIDE_MODE);key(1);key(2);check(state.sidebar_edit&&state.settings==original);key(1);check((state.settings&7)==6);
 select(SIDE_THRESHOLD);key(1);for(unsigned i=0;i<200;i++)key(4);check(state.edit_value==16&&((state.settings>>20)&2047)==80);key(1);check(((state.settings>>20)&2047)==16&&((state.settings>>9)&2047)==128);
 key(1);for(unsigned i=0;i<200;i++)key(2);check(state.edit_value==2047);key(8);check(((state.settings>>20)&2047)==16);
 select(SIDE_MEDIAN);key(1);key(4);check(state.settings&8);key(1);check(!(state.settings&8));
 select(SIDE_ZOOM);trace("view");key(1);key(2);check(state.edit_value==960&&state.roi[1]==((1920u<<12)|1080)&&!state.pending);trace("edit_zoom");
 key(8);check(state.roi[1]==((1920u<<12)|1080));key(1);key(2);key(1);check(state.key_roi_dirty&&state.roi[1]==((960u<<12)|540));
 apply();check(state.pending==2);accept();check(state.good&&!state.pending);
 select(SIDE_PAN_X);key(1);key(2);check((state.edit_roi[0]>>12)==512&&(state.roi[0]>>12)==480);key(8);check((state.roi[0]>>12)==480);
 select(SIDE_AI);key(1);key(2);check(!state.ai_policy);key(1);check(state.ai_policy==1&&state.ai_manual==1);
 action(SIDE_RUN);check(state.ai_request==1);action(SIDE_SELFTEST);check(state.selftest_request==1);
 select(SIDE_MODEL);key(1);key(2);check(state.ai_manual==1);key(1);check(state.ai_manual==3);
 select(SIDE_TARGET_ZOOM);key(1);for(unsigned i=0;i<6;i++)key(2);check(state.edit_value==8&&!state.center_zoom);key(1);check(state.center_zoom==8);
 key(16);check(((state.settings>>4)&3)==0&&state.sidebar_open);key(32);check(((state.settings>>4)&3)==1&&state.sidebar_open);
 action(SIDE_FULL_VIEW);apply();check(!state.enabled&&!state.pending&&state.roi[0]==0&&state.roi[3]==0);
 // New geometry is required after confirmation, even when AI is OFF.
 reset();action(SIDE_CENTER);check(state.center_request==1);apply();control_center_step();check(state.center_stage==4&&!state.pending);
 control_center_step();check(!state.pending);geometry(700,400,160,120,0,1);control_center_step();check(state.center_stage==2&&state.pending==1&&state.center_frame==100);
 apply();check(state.pending==2);accept();control_center_step();check(state.center_status==CENTER_DONE&&!state.center_stage);trace("center_done");
 unsigned serial=state.serial;for(unsigned i=0;i<10;i++){geometry(710,410,160,120,state.serial,1);control_center_step();}check(state.serial==serial);
 // A target in an already panned/scaled viewport is mapped back to the source.
 reset();state.enabled=state.good=1;state.freeze=1;c[4]|=128;state.serial=7;
 state.commit[0]=(480u<<12)|270;state.commit[1]=state.commit[2]=(960u<<12)|540;state.commit[3]=(400u<<12)|200;
 action(SIDE_CENTER);apply();control_center_step();geometry(700,400,160,120,7,1);control_center_step();
 check(state.center_stage==2&&state.center_render==7&&state.center_frame==100);
 check(state.roi[0]==((620u<<12)|395)&&state.roi[1]==((480u<<12)|270)&&state.roi[2]==((1920u<<12)|1080)&&!state.roi[3]);
 // No target, stale transform, history mode and busy renderer do not alter the view.
 reset();action(SIDE_CENTER);apply();control_center_step();geometry(700,400,160,120,0,0);control_center_step();check(state.center_status==CENTER_NONE&&!state.pending);trace("no_target");
 reset();action(SIDE_CENTER);apply();control_center_step();geometry(700,400,160,120,99,1);control_center_step();check(state.center_status==CENTER_STALE&&!state.pending);
 reset();state.pending=1;action(SIDE_CENTER);control_center_step();check(state.center_status==CENTER_BUSY&&state.pending==1&&state.serial==0);
 reset();state.settings=(state.settings&~48u)|32;action(SIDE_CENTER);control_center_step();check(state.center_status==CENTER_BUSY&&!state.pending&&((state.settings>>4)&3)==2);
 reset();action(SIDE_CENTER);apply();control_center_step();state.shape_threshold++;geometry(700,400,160,120,0,1);control_center_step();check(state.center_status==CENTER_STALE&&!state.pending);
 // A FOMO selection requests a fresh job, not a previously published model result.
 reset();state.ai_manual=3;state.ai_policy=1;action(SIDE_CENTER);apply();control_center_step();check(state.center_stage==3&&state.ai_request==1);
 static struct fusion_job j;j.g.frame=100;j.g.context=5;
 control_center_fomo(0,&j,1,700,400,160,120);check(state.center_stage==3&&!state.pending);
 control_center_fomo(state.center_seen,&j,1,700,400,160,120);check(state.pending==1&&state.center_stage==2);
 reset();state.ai_manual=3;state.ai_policy=1;action(SIDE_CENTER);apply();control_center_step();control_center_fomo(state.center_seen,&j,0,0,0,0,0);check(state.center_status==CENTER_NONE);
 reset();state.ai_manual=3;state.ai_policy=1;action(SIDE_CENTER);apply();control_center_step();j.g.context=4;control_center_fomo(state.center_seen,&j,1,700,400,160,120);check(state.center_status==CENTER_STALE);
 reset();state.ai_manual=3;state.ai_policy=2;action(SIDE_CENTER);apply();control_center_step();state.ai_policy=0;control_center_step();check(state.center_status==CENTER_STALE&&!state.pending);
 static const unsigned zs[5]={0,1,2,4,8};
 for(unsigned iz=0;iz<5;iz++)for(unsigned iy=0;iy<9;iy++)for(unsigned ix=0;ix<9;ix++){
  unsigned w=40+ix*13,h=30+iy*9,x=(1920-w)*ix/8,y=(1080-h)*iy/8;verify_box(x,y,w,h,zs[iz]);
 }
 verify_box(0,0,1920,1080,0);verify_box(100,0,1600,1080,8);
 puts("PASS sidebar_center checks=");hex(checks);puts(" geometry_cases=407\n");finish(1);
}
void trap(void){puts("TRAP\n");finish(0);}
