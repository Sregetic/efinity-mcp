#include <stdint.h>
#define CONTROL_TEST
#define VISION_GEOMETRY_M7
#define M7_SERVICE_TEST
static uint32_t control[32],geo[32],dma[32],ticks,request,publication,reads,face_calls,tag;
#define CTRL_R(o) control[(o)/4]
#define CTRL_W(o,v) (control[(o)/4]=(v))
#define CONTROL_STATE (&state)
extern struct vision_control_state state;
static void geo_write(unsigned off,uint32_t value){
 if(off==4)request=value;
 else if(off==0x24){publication=2;geo[1]|=8;}
 else geo[off/4]=value;
}
static unsigned late_ready;
static uint32_t geo_read(unsigned off){
 if(off==8&&late_ready){late_ready=0;geo[1]|=1;geo[2]^=1;}
 return geo[off/4];
}
#define M7_R(o) geo_read(o)
#define M7_W(o,v) geo_write(o,v)
#define M7_DMA(o) dma[(o)/4]
#define M7_TICKS ticks
#include "control_service.h"
#include "geometry_m7.h"
#include "geometry_face.h"
static uint32_t fly_read_word(unsigned i){reads++;return i^0x12340000u^tag;}
#include "geometry_m7_service.c"
struct vision_control_state state;
struct m7_box m7_boxes[4],m7_face_boxes[4];
struct m7_contour m7_contours[M7_CONTOURS];
unsigned m7_count,m7_more,m7_complex,m7_contour_count,m7_face_count,m7_face_more;
static unsigned face_left,face_tag,face_duration=1000;
static void finish(unsigned ok){*(volatile unsigned*)0x100000=ok?0x5555:0x3333;for(;;);}
static void text(const char*s){while(*s)*(volatile unsigned char*)0x10000000=*s++;}
static void check(unsigned ok,unsigned line){if(!ok){text("FAIL service line ");char v[12];unsigned n=0;do{v[n++]='0'+line%10;line/=10;}while(line);while(n)*(volatile unsigned char*)0x10000000=v[--n];text("\n");finish(0);}}
#define CHECK(x) check((x),__LINE__)
void m7_retain(struct m7_box *b,unsigned*n,unsigned*more,struct m7_box v){
 if(*n==4){*more=1;return;}unsigned i=(*n)++;while(i&&b[i-1].area<v.area){b[i]=b[i-1];i--;}b[i]=v;
}
void m7_begin(const uint32_t *bits){
 CHECK(bits[0]==(0x12340000u^tag)&&bits[4049]==(0x12340000u^4049^tag));
 m7_count=2;m7_boxes[0]=(struct m7_box){20+tag,25,60+tag,70,100,2};m7_boxes[1]=(struct m7_box){100+tag,80,150+tag,140,90,1};
 m7_contour_count=1;m7_contours[0]=(struct m7_contour){tag,10,100,120,123,0};
}
unsigned m7_step(unsigned b){CHECK(b==2048);return 1;}
void m7_face_begin(const uint32_t *bits,const struct m7_contour *c,unsigned n){
 CHECK(bits[0]==(0x12340000u^tag)&&n==1&&c[0].x0==tag);face_tag=tag;face_left=face_duration;face_calls++;
}
unsigned m7_face_step(unsigned b){
 CHECK(b==128);if(--face_left)return 0;
 m7_face_count=1;m7_face_more=0;m7_face_boxes[0]=(struct m7_box){200+face_tag,100,240+face_tag,160,300,3};return 1;
}
static unsigned step(void){
 if(publication&&!--publication)geo[1]=(geo[1]&~8u)|4;
 ticks+=100;return geometry_m7_service_step(1);
}
static void snapshot(unsigned frame,unsigned value,unsigned good){
 tag=value;geo[6]=frame;geo[2]^=1;geo[1]=(geo[1]&12)|16|2|(good?1:0);
}
static void new_geometry(unsigned frame,unsigned value){
 unsigned seq=geometry.sequence;geo[0x34/4]++;
 for(unsigned n=0;!request;n++){step();CHECK(n<10);}
 snapshot(frame,value,1);
 for(unsigned n=0;geometry.sequence==seq;n++){step();CHECK(n<100);}
 CHECK(!request&&!geo[0x28/4]&&!dma[0]);
}
void main(void){
 state.settings=7;geo[1]=16;geo[0x2c/4]=96;geo[7]=6;geo[8]=9;geo[0x34/4]=1;
 geo[0x28/4]=1;dma[1]=1;CHECK(step()==1&&!request);dma[1]=2;CHECK(step()==0&&dma[0]==2&&!geo[0x28/4]);dma[0]=dma[1]=0;
 CHECK(!geometry_m7_service_step(0)&&!request);
 CHECK(step()==1&&request);snapshot(100,1,0);CHECK(!step()&&!request);
 new_geometry(101,2);
 CHECK(reads==4050&&face_calls==1&&face_running&&geometry.sequence==1&&face.sequence==0);
 CHECK(geo[0x60/4]==101&&geo[0x78/4]==(2|(1<<4)|(1<<7)));
 new_geometry(102,3);new_geometry(103,4);
 CHECK(geometry.sequence==3&&face.sequence==0&&face_calls==1&&geo[0x60/4]==103&&face_tag==2);
 // A new snapshot can miss during VBlank without invalidating completed/independent work.
 unsigned saved_geo_seq=geometry_m7_lane_record[0],saved_face_calls=face_calls;
 geo[0x34/4]++;while(!request)step();snapshot(104,6,0);step();
 CHECK(geometry.valid&&face_running&&geometry_m7_lane_record[0]==saved_geo_seq&&face_calls==saved_face_calls);
 for(unsigned n=0;n<3;n++){step();CHECK(geometry.valid&&face_running);}
 while(!request)step();snapshot(103,4,1);while(phase!=IDLE)step();
 // Finish the old face while newer circle/rectangle data stays in the publication.
 for(unsigned n=0;!face.valid;n++){step();CHECK(n<1100);}
 for(unsigned n=0;dirty;n++){step();CHECK(n<10);}
 CHECK(geometry.frame==103&&face.frame==101&&geometry_m7_lane_record[1]==103&&geometry_m7_lane_record[9]==101);
 CHECK(geo[0x60/4]==101&&geo[0x78/4]==(3|(1<<4)|(1<<7)|(1<<10)));
 CHECK(geometry_m7_record[0]==0x4d374733&&geometry_m7_record[2]==101);
 // Frozen unchanged edges do not restart either classifier; changed edges do.
 unsigned gs=geometry.sequence,fc=face_calls;geo[0x34/4]++;
 while(!request)step();snapshot(103,4,1);while(phase!=IDLE)step();CHECK(geometry.sequence==gs&&face_calls==fc);
 new_geometry(103,5);CHECK(geometry.sequence==gs+1&&face_calls==fc+1);
 // Independent threshold change cancels both lanes and does not retain an old face.
 unsigned canceled=geometry_m7_record[22];geo[0x2c/4]=112;step();CHECK(geometry_m7_record[22]==canceled+1&&!face_running&&!face.valid&&!geometry.valid);
 while(!request)step();snapshot(104,6,1);while(phase!=IDLE)step();CHECK(geometry.valid&&!face.valid&&face_running);
 // A cancelled shared read never publishes a partial/new-frame result.
 geo[0x34/4]++;while(!request)step();tag=7;geo[6]=105;geo[1]&=~1u;late_ready=1;step();CHECK(phase==COPY);
 geo[1]&=~1u;step();CHECK(geometry.valid&&geometry.frame==104&&!face.valid&&face_running&&face_job.frame==104);
 // View/ROI context changes invalidate both independent sources.
 geo[7]++;geo[8]++;step();CHECK(!geometry.valid&&!face.valid);
 while(!request)step();snapshot(106,8,1);while(phase!=IDLE)step();
 // Frozen/history source changes cancel an older face even without a settings change.
 state.settings=7|16;step();while(!request)step();snapshot(200,9,1);while(phase!=IDLE)step();
 CHECK(face_running&&face_job.frame==200);unsigned before_faces=face_calls;
 new_geometry(201,10);CHECK(face_running&&face_job.frame==201&&face_calls==before_faces+1&&!face.valid);
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

 CHECK(!step()&&!request&&!face_running);
 text("PASS RV32I M7 independent geometry advances during slow face work; VBlank miss/copy rejection preserve completed lanes; late token/status ordering; lane source IDs; primary metadata; frozen cache; cancellation/context/threshold; no new DMA lease; original UI threshold controls\n");finish(1);
}
void trap(void){text("TRAP\n");finish(0);}
