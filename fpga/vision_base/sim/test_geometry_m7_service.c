#include <stdint.h>
#define CONTROL_TEST
#define VISION_GEOMETRY_M7
#define M7_SERVICE_TEST
static uint32_t control[32],geo[32],dma[32],ticks,request,publication,reads,face_calls,roi_case,bit_change;
#define CTRL_R(o) control[(o)/4]
#define CTRL_W(o,v) (control[(o)/4]=(v))
#define CONTROL_STATE (&state)
extern struct vision_control_state state;
static void geo_write(unsigned off,uint32_t value){
 if(off==4)request=value;
 else if(off==0x24){publication=2;geo[1]|=8;}
 else geo[off/4]=value;
}
#define M7_R(o) geo[(o)/4]
#define M7_W(o,v) geo_write(o,v)
#define M7_DMA(o) dma[(o)/4]
#define M7_TICKS ticks
#include "control_service.h"
#include "geometry_m7.h"
#include "geometry_face.h"
static uint32_t fly_read_word(unsigned i){reads++;return i^0x12340000u^((bit_change&&i==1)?1u:0u);}
#include "geometry_m7_service.c"
struct vision_control_state state;
const uint8_t m7_facefinder[]={0};
struct m7_box m7_boxes[4];unsigned m7_count,m7_more,m7_complex;
static uint16_t pixels[1920*1080];
static void finish(unsigned ok){*(volatile unsigned*)0x100000=ok?0x5555:0x3333;for(;;);}
static void text(const char*s){while(*s)*(volatile unsigned char*)0x10000000=*s++;}
static void check(unsigned ok,unsigned line){if(!ok){text("FAIL service line ");char v[12];unsigned n=0;do{v[n++]='0'+line%10;line/=10;}while(line);while(n)*(volatile unsigned char*)0x10000000=v[--n];text("\n");finish(0);}}
#define CHECK(x) check((x),__LINE__)
void m7_begin(const uint32_t *bits){CHECK(bits[0]==0x12340000&&bits[4049]==(0x12340000^4049));m7_count=2;m7_boxes[0]=(struct m7_box){20,25,60,70,100,2};m7_boxes[1]=(struct m7_box){100,80,150,140,100,1};}
unsigned m7_step(unsigned b){CHECK(b==2048);return 1;}
void m7_face_begin(const uint8_t*g,void *m){CHECK(m==(void*)m7_facefinder);face_calls++;if(roi_case){CHECK(g[0]==0&&g[129599]==0&&g[135*480+240]==255&&map_x[120]==102&&map_y[67]==200&&map_x[119]==65535);}else CHECK(g[0]==255&&g[129599]==255);}
unsigned m7_face_step(unsigned b){CHECK(b==32);m7_boxes[2]=(struct m7_box){200,100,240,160,100,3};m7_count=3;return 1;}
static unsigned step(void){ticks+=100;return geometry_m7_service_step(1);}
static void snapshot(unsigned frame,unsigned render,unsigned context,unsigned good){
 geo[6]=frame;geo[7]=render;geo[8]=context;geo[2]^=1;geo[1]=(geo[1]&4)|16|2|(good?1:0);
}
static void acknowledge(void){if(dma[0]==2){dma[0]=0;dma[1]=0;}}
static void run(void){
 unsigned n=0;
 do{
  if(dma[0]==9){dma[0]=0;dma[1]=2;dma[0x38/4]=(uint32_t)pixels;dma[0x10/4]=99;}
  if(publication&&!--publication){geo[1]=(geo[1]&~8u)|4;}
  step();acknowledge();CHECK(++n<10000);
 }while(geo[0x28/4]||geometry_m7_record[20]);
}
void main(void){
 state.settings=7;geo[1]=16;geo[0x34/4]=1;geo[0x28/4]=1;dma[1]=1;
 CHECK(step()==1&&!request);dma[1]=2;CHECK(step()==0&&dma[0]==2&&!geo[0x28/4]);acknowledge();
 CHECK(!geometry_m7_service_step(0));CHECK(!request);
 CHECK(step()==1&&request);snapshot(100,2,7,0);CHECK(!step()&&!request);CHECK(!geo[0x28/4]);
 CHECK(step()==1&&request);snapshot(100,2,7,1);CHECK(step()==1&&dma[0]==9&&geo[0x28/4]);
 dma[0]=0;dma[1]=6;dma[0x24/4]=0x55;CHECK(step()==1&&!request);CHECK(!step()&&!geo[0x28/4]);acknowledge();CHECK(geometry_m7_record[21]==1&&geometry_m7_record[23]==0x55);
 CHECK(step()==1);snapshot(101,3,8,1);CHECK(step()==1&&dma[8/4]==101&&geometry_m7_record[1]==0);dma[0]=0;dma[1]=2;dma[0x38/4]=(uint32_t)pixels;
 CHECK(step()==1&&reads==128);geo[1]&=~1u;CHECK(!step()&&!request&&!geo[0x28/4]);acknowledge();
 for(unsigned i=0;i<1920*1080;i++)pixels[i]=65535;
 reads=0;CHECK(step()==1);snapshot(102,6,9,1);CHECK(step()==1);run();
 CHECK(reads==4050&&face_calls==1&&geometry_m7_record[1]==1&&geometry_m7_record[17]==99);
 CHECK(geo[0x60/4]==102&&geo[0x68/4]==6&&geo[0x70/4]==9&&geo[0x78/4]==(3|(1<<4)|(1<<7)|(1<<10)));
 CHECK(!step()&&!request);geo[0x34/4]++;CHECK(step()==1);snapshot(102,6,9,1);geo[1]|=4;
 CHECK(step()==1);run();CHECK(!request&&reads==8100&&face_calls==1&&geometry_m7_record[1]==1);
 bit_change=1;geo[0x34/4]++;CHECK(step()==1);snapshot(102,6,9,1);CHECK(step()==1);run();CHECK(face_calls==2&&reads==12150);
 geo[1]&=~4u;CHECK(step()==1&&request);snapshot(102,6,9,1);CHECK(step()==1);run();CHECK(face_calls==3);
 geo[0x34/4]++;geo[1]&=~4u;state.enabled=state.good=1;roi_case=1;
 state.commit[0]=(100u<<12)|200;state.commit[1]=state.commit[2]=(960u<<12)|540;state.commit[3]=(480u<<12)|270;
 CHECK(step()==1);snapshot(103,7,10,1);CHECK(step()==1);run();CHECK(face_calls==4);
 // Independent live edge parameter; old gray threshold and other modes retain their data.
 state.shape_threshold=32;geo[0x2c/4]=96;control_geometry_threshold_set(&state,112);
 CHECK(geo[0x2c/4]==112&&state.shape_threshold==32);control_geometry_threshold_set(&state,1);CHECK(geo[0x2c/4]==16);
 control_geometry_threshold_set(&state,999);CHECK(geo[0x2c/4]==255&&state.shape_threshold==32);
 state.settings=7|(96u<<9)|(80u<<20);geo[0x2c/4]=96;state.sidebar_open=0;
 control_event((255u<<24)|2);CHECK(geo[0x2c/4]==112&&state.shape_threshold==32);
 control_event((255u<<24)|4);CHECK(geo[0x2c/4]==96);
 state.sidebar_open=2;state.sidebar_item=SIDE_THRESHOLD;state.sidebar_edit=0;control_sidebar_keys(&state,1);CHECK(state.edit_mode==7&&state.edit_value==96);
 control_sidebar_adjust(&state,1);CHECK(geo[0x2c/4]==112&&state.sidebar_edit);
 control_sidebar_adjust(&state,1);CHECK(geo[0x2c/4]==128&&state.sidebar_edit);control_sidebar_confirm(&state);
 CHECK(!state.sidebar_edit&&geo[0x2c/4]==128&&state.shape_threshold==32);
 state.sidebar_open=0;control_event((2u<<24)|144);CHECK(geo[0x2c/4]==144);
 state.settings=(state.settings&~7u)|6;control_event((2u<<24)|160);
 CHECK(((state.settings>>20)&2047)==160&&geo[0x2c/4]==144&&state.shape_threshold==32);
 CHECK(!step()&&!request);
 text("PASS RV32I M7 DMA owner recovery, bad snapshot, exact-lease failure, copy cancellation, 4050 shared reads, distinct source/render/context, result metadata, cache invalidation, independent threshold\n");finish(1);
}
void trap(void){text("TRAP\n");finish(0);}
