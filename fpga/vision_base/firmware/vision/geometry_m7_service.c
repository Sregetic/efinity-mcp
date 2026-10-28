#include "geometry_m7_service.h"
#include "geometry_m7.h"
#include "geometry_face.h"
#include "control_service.h"
#ifndef M7_SERVICE_TEST
#include "flyhash_service.h"
#define M7_DMA(off) (*(volatile uint32_t *)(0xf8100100u+(off)))
#define M7_TICKS (*(volatile uint32_t *)0xf8100030u)
#endif

uint32_t geometry_m7_bitmap[M7_WORDS];
/* GEO3: publication/primary identity, boxes, independent lane timing/sequences. */
volatile uint32_t geometry_m7_record[24];
/* Per lane: sequence/frame/render/context/cycles/count+more/complex/edge epoch. */
volatile uint32_t geometry_m7_lane_record[16];
struct m7_lane {
 struct m7_box boxes[4];
 unsigned count,more,complex,valid;
 uint32_t frame,render,context,cycles,sequence,epoch;
};
static struct m7_lane geometry,face;
static struct {uint32_t frame,render,context,epoch,start;} job,face_job;
static unsigned initialized,phase,word,unchanged,face_running,dirty,have_epoch;
static uint32_t token,start,pub_sequence,last_epoch,settings,threshold,render,context;
enum {IDLE,WAIT_SNAPSHOT,COPY,CONTOURS,DRAIN};
static void reject_snapshot(void){
 M7_W(4,0);phase=IDLE;geometry_m7_record[20]=IDLE;geometry_m7_record[23]++;
}
static void cancel(void){
 M7_W(4,0);phase=IDLE;face_running=dirty=have_epoch=0;
 geometry.valid=face.valid=0;geometry_m7_record[1]=geometry_m7_lane_record[0]=geometry_m7_lane_record[8]=0;
 geometry_m7_record[20]=geometry_m7_record[21]=0;geometry_m7_record[22]++;
}
static void save_lane(struct m7_lane *lane,const struct m7_box *boxes,unsigned count,unsigned more,unsigned complex,unsigned index){
 for(unsigned i=0;i<count;i++)lane->boxes[i]=boxes[i];
 lane->count=count;lane->more=more;lane->complex=complex;lane->valid=1;lane->sequence++;
 volatile uint32_t *r=geometry_m7_lane_record+index*8;r[0]=0;
 r[1]=lane->frame;r[2]=lane->render;r[3]=lane->context;r[4]=lane->cycles;
 r[5]=count|(more<<3);r[6]=complex;r[7]=lane->epoch;
 __asm__ volatile("fence rw,rw":::"memory");r[0]=lane->sequence;dirty=1;
}
static void publish(void){
 struct m7_box boxes[4];unsigned count=0,more=0;
 if(geometry.valid){count=geometry.count;more=geometry.more;for(unsigned i=0;i<count;i++)boxes[i]=geometry.boxes[i];}
 if(face.valid){
  more|=face.more;
  for(unsigned i=0;i<face.count;i++){
   struct m7_box b=face.boxes[i];
   if(geometry.valid&&face.frame==geometry.frame)m7_retain(boxes,&count,&more,b);
   else{
    /* Results from different source frames are not deduplicated as one object. */
    if(count==4){more=1;if(b.area<=boxes[3].area)continue;}else count++;
    unsigned n=count-1;while(n&&boxes[n-1].area<b.area){boxes[n]=boxes[n-1];n--;}boxes[n]=b;
   }
  }
 }
 const struct m7_lane *primary=count&&boxes[0].klass==M7_FACE?&face:&geometry;
 uint32_t meta[4]={primary->frame,primary->render,primary->context,count|(more<<3)};
 geometry_m7_record[1]=0;
 for(unsigned i=0;i<4;i++){
  uint64_t value=0;
  if(i<count){const struct m7_box*b=&boxes[i];value=((uint64_t)b->klass<<36)|((uint64_t)b->x0<<27)|((uint64_t)b->y0<<18)|((uint32_t)b->x1<<9)|b->y1;meta[3]+=1u<<(b->klass*3+1);}
  uint32_t low=value&0x7ffff,high=value>>19;M7_W(0x40+i*8,low);M7_W(0x44+i*8,high);
  geometry_m7_record[8+i*2]=low;geometry_m7_record[9+i*2]=high;
 }
 for(unsigned i=0;i<4;i++){M7_W(0x60+i*8,meta[i]&0x7ffff);M7_W(0x64+i*8,meta[i]>>19);}
 geometry_m7_record[0]=0x4d374733;geometry_m7_record[2]=meta[0];geometry_m7_record[3]=meta[1];geometry_m7_record[4]=meta[2];
 geometry_m7_record[5]=meta[3];geometry_m7_record[6]=primary->cycles;geometry_m7_record[7]=geometry.complex;
 geometry_m7_record[16]=geometry.cycles;geometry_m7_record[17]=face.cycles;
 geometry_m7_record[18]=geometry.sequence;geometry_m7_record[19]=face.sequence;
 __asm__ volatile("fence rw,rw":::"memory");geometry_m7_record[1]=++pub_sequence;
 M7_W(0x24,0);dirty=0;
}
unsigned geometry_m7_service_step(unsigned available){
 struct vision_control_state *s=CONTROL_STATE;
 uint32_t status=M7_R(4),now_render=M7_R(0x1c),now_context=M7_R(0x20),now_threshold=M7_R(0x2c);
 if(!initialized){
  M7_W(4,0);phase=M7_R(0x28)?DRAIN:IDLE;initialized=1;
  settings=s->settings;threshold=now_threshold;render=now_render;context=now_context;
 }
 /* Retire an old firmware's persistent DMA lease before using the shared engine. */
 if(phase==DRAIN){
  uint32_t d=M7_DMA(4);if(d&1)return 1;
  if(d&2)M7_DMA(0)=2;M7_W(0x28,0);phase=IDLE;return 0;
 }
 if(settings!=s->settings||threshold!=now_threshold||render!=now_render||context!=now_context){
  cancel();settings=s->settings;threshold=now_threshold;render=now_render;context=now_context;
 }
 if((s->settings&7)!=7||!(status&16)||s->feature_wait||s->pending){
  if(phase||geometry.valid||face.valid||face_running)cancel();return 0;
 }
 /* Snapshot validity protects the shared copy, not previously copied lane inputs. */
 if(phase==COPY&&!(status&1)){reject_snapshot();return 0;}

 /* Face geometry has its own immutable edges/contours; it never owns the raw-frame DMA. */
 if(face_running&&m7_face_step(128)){
  face.frame=face_job.frame;face.render=face_job.render;face.context=face_job.context;face.epoch=face_job.epoch;face.cycles=M7_TICKS-face_job.start;
  save_lane(&face,m7_face_boxes,m7_face_count,m7_face_more,0,1);face_running=0;
 }
 if(phase==IDLE){
  uint32_t epoch=M7_R(0x34);
  if(available&&!(M7_DMA(4)&3)&&!(status&8)&&epoch&&(!have_epoch||epoch!=last_epoch)){
   token=M7_R(8);start=M7_TICKS;M7_W(4,1);phase=WAIT_SNAPSHOT;
  }
 }else if(phase==WAIT_SNAPSHOT){
  if(M7_R(8)!=token){
   /* The token may advance after the status read at function entry. */
   if(!(M7_R(4)&1)){reject_snapshot();return 0;}
   job.frame=M7_R(0x18);job.render=M7_R(0x1c);job.context=M7_R(0x20);job.epoch=M7_R(0x34);job.start=start;
   /* A frozen/history view cannot combine different displayed source frames. */
   if(((s->settings>>4)&3)&&((face_running&&face_job.frame!=job.frame)||(face.valid&&face.frame!=job.frame))){face_running=0;face.valid=0;geometry_m7_lane_record[8]=0;}
   unchanged=geometry.valid&&geometry.frame==job.frame;word=0;phase=COPY;
  }
 }else if(phase==COPY){
  for(unsigned i=0;i<128&&word<M7_WORDS;i++,word++){
   uint32_t value=fly_read_word(word);if(value!=geometry_m7_bitmap[word])unchanged=0;geometry_m7_bitmap[word]=value;
  }
  if(word==M7_WORDS){
   M7_W(4,0);last_epoch=job.epoch;have_epoch=1;
   if(unchanged)phase=IDLE;else{m7_begin(geometry_m7_bitmap);phase=CONTOURS;}
  }
 }else if(phase==CONTOURS){
  if(m7_step(2048)){
   geometry.frame=job.frame;geometry.render=job.render;geometry.context=job.context;geometry.epoch=job.epoch;geometry.cycles=M7_TICKS-job.start;
   save_lane(&geometry,m7_boxes,m7_count,m7_more,m7_complex,0);
   if(!face_running){m7_face_begin(geometry_m7_bitmap,m7_contours,m7_contour_count);face_job=job;face_running=1;}
   phase=IDLE;
  }
 }
 /* The existing VS bank swap is atomic; never publish during descriptor settling. */
 if(dirty&&phase!=WAIT_SNAPSHOT&&!(M7_R(4)&8)&&(M7_R(4)&1))publish();
 geometry_m7_record[20]=phase;geometry_m7_record[21]=face_running;
 return phase!=IDLE;
}
