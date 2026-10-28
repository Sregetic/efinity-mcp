#include "geometry_m7_service.h"
#include "geometry_m7.h"
#include "geometry_face.h"
#include "control_service.h"
#ifndef M7_SERVICE_TEST
#include "flyhash_service.h"
#endif
#include "fomo_pixels.h"

#ifndef M7_SERVICE_TEST
#define M7_DMA(off) (*(volatile uint32_t *)(0xf8100100u+(off)))
#define M7_TICKS (*(volatile uint32_t *)0xf8100030u)
#endif
extern const uint8_t m7_facefinder[];
uint32_t geometry_m7_bitmap[M7_WORDS];
static uint8_t gray[M7_W*M7_H];
static uint16_t map_x[M7_W],map_y[M7_H];
/* GEO2: sequence, frame/render/context, count, CPU cycles, boxes, source config. */
volatile uint32_t geometry_m7_record[24];

unsigned geometry_m7_service_step(unsigned available){
 enum {IDLE,WAIT_SNAPSHOT,ACQUIRE,COPY,CONTOURS,MAP,GRAY,FACES,PUBLISH,DRAIN};
 static unsigned initialized=0,phase=IDLE,word,map_index,gx,gy,have_result,unchanged;
 static uint32_t token,start,sequence,last_frame,last_render,last_context,last_epoch,epoch,done_frame,done_render,done_context,roi[4],use_roi;
 static const volatile uint16_t *source;
 struct vision_control_state *s=CONTROL_STATE;
 if(!initialized){
  M7_W(4,0);phase=M7_R(0x28)?DRAIN:IDLE;initialized=1;
 }
 geometry_m7_record[20]=phase;
 if(phase==IDLE){
  if((s->settings&7)!=7||!available||s->feature_wait||s->pending||(M7_DMA(4)&3))return 0;
  uint32_t status=M7_R(4);epoch=M7_R(0x34);
  if(!(status&16)||(status&8)||!epoch||(have_result&&epoch==last_epoch&&(status&4)))return 0;
  token=M7_R(8);start=M7_TICKS;M7_W(4,1);phase=WAIT_SNAPSHOT;geometry_m7_record[20]=phase;return 1;
 }
 uint32_t status=M7_R(4);
 if(phase!=DRAIN&&(!(status&16)||(phase>=ACQUIRE&&!(status&1)))){
  M7_W(4,0);geometry_m7_record[22]++;
  phase=M7_R(0x28)?DRAIN:IDLE;
 }
 if(phase==IDLE){geometry_m7_record[20]=0;return 0;}
 if(phase==DRAIN){
  uint32_t d=M7_DMA(4);if(d&1)return 1;
  if(d&2)M7_DMA(0)=2;
  M7_W(0x28,0);phase=IDLE;geometry_m7_record[20]=0;return 0;
 }
 if(phase==WAIT_SNAPSHOT){
  if(M7_R(8)==token)return 1;
  if(!(status&1)){M7_W(4,0);phase=IDLE;return 0;}
  last_frame=M7_R(0x18);last_render=M7_R(0x1c);last_context=M7_R(0x20);
  unchanged=have_result&&last_frame==done_frame&&last_render==done_render&&last_context==done_context&&(status&4);
  geometry_m7_record[1]=0;
  geometry_m7_record[2]=last_frame;geometry_m7_record[3]=last_render;geometry_m7_record[4]=last_context;
  for(unsigned i=0;i<4;i++)roi[i]=s->commit[i];use_roi=s->enabled&&s->good;
  // The persistent owner bit lets a USER1 replacement retire this lease safely.
  M7_W(0x28,1);M7_DMA(8)=last_frame;M7_DMA(0x14)=0;M7_DMA(0x18)=1920u|(1080u<<16);M7_DMA(0)=9;
  phase=ACQUIRE;return 1;
 }
 if(phase==ACQUIRE){
  uint32_t d=M7_DMA(4);if(!(d&2))return 1;
  if(d&4){geometry_m7_record[21]++;geometry_m7_record[23]=M7_DMA(0x24);M7_W(4,0);phase=DRAIN;return 1;}
  source=(const volatile uint16_t *)M7_DMA(0x38);geometry_m7_record[17]=M7_DMA(0x10);
#ifndef M7_SERVICE_TEST
  __asm__ volatile("fence rw,rw\n.word 0x500f\nfence rw,rw":::"memory");
#endif
  word=0;phase=COPY;
 }
 if(phase==COPY){
  for(unsigned i=0;i<128&&word<M7_WORDS;i++,word++){
   uint32_t value=fly_read_word(word);if(value!=geometry_m7_bitmap[word])unchanged=0;geometry_m7_bitmap[word]=value;
  }
  if(word<M7_WORDS)return 1;
  M7_W(4,0);
  // Frozen pixels can still produce a newer calibrated Canny plane.
  if(unchanged){last_epoch=epoch;geometry_m7_record[1]=sequence;phase=DRAIN;return 1;}
  m7_begin(geometry_m7_bitmap);phase=CONTOURS;geometry_m7_record[18]=M7_TICKS-start;
 }
 if(phase==CONTOURS){
  if(!m7_step(2048))return 1;
  geometry_m7_record[16]=(M7_TICKS-start)/100000u;phase=MAP;map_index=0;
 }
 if(phase==MAP){
  for(unsigned n=0;n<32&&map_index<M7_W+M7_H;n++,map_index++){
   unsigned axis=map_index>=M7_W,index=axis?map_index-M7_W:map_index,v=index*4+2;
   unsigned mapped=v;
   if(use_roi){
    unsigned start=axis?(roi[0]&4095):(roi[0]>>12),length=axis?(roi[1]&4095):(roi[1]>>12);
    unsigned dst=axis?(roi[3]&4095):(roi[3]>>12),size=axis?(roi[2]&4095):(roi[2]>>12);
    mapped=v<dst||v>=dst+size?65535:start+(v-dst)*length/size;
   }
   if(axis)map_y[index]=mapped;else map_x[index]=mapped;
  }
  if(map_index<M7_W+M7_H)return 1;
  gx=gy=0;phase=GRAY;
 }
 if(phase==GRAY){
  for(unsigned n=0;n<512&&gy<M7_H;n++){
   unsigned value=0;
   if(map_x[gx]!=65535&&map_y[gy]!=65535){
    uint8_t rgb[3];fomo_rgb(source[map_y[gy]*1920u+map_x[gx]],rgb);
    value=(77u*rgb[0]+150u*rgb[1]+29u*rgb[2]+128)>>8;
   }
   gray[gy*M7_W+gx]=value;
   if(++gx==M7_W){gx=0;gy++;}
  }
  if(gy<M7_H)return 1;
  geometry_m7_record[16]|=((M7_TICKS-start)/100000u)<<16;
  m7_face_begin(gray,(void*)m7_facefinder);phase=FACES;
 }
 if(phase==FACES){
  if(!m7_face_step(32))return 1;
  for(unsigned i=0;i<m7_count;i++){
   const struct m7_box *b=&m7_boxes[i];
   uint64_t box=((uint64_t)b->klass<<36)|((uint64_t)b->x0<<27)|((uint64_t)b->y0<<18)|((uint32_t)b->x1<<9)|b->y1;
   uint32_t low=box&0x7ffff,high=box>>19;
   M7_W(0x40+i*8,low);M7_W(0x44+i*8,high);
   geometry_m7_record[8+i*2]=low;geometry_m7_record[9+i*2]=high;
  }
  geometry_m7_record[0]=0x4d374732;geometry_m7_record[5]=m7_count|(m7_more<<3);
  geometry_m7_record[6]=M7_TICKS-start;geometry_m7_record[7]=m7_complex;
  __asm__ volatile("fence rw,rw":::"memory");geometry_m7_record[1]=++sequence;
  uint32_t meta[4]={last_frame,last_render,last_context,m7_count|(m7_more<<3)};
  for(unsigned i=0;i<m7_count;i++)meta[3]+=1u<<(m7_boxes[i].klass*3+1);
  for(unsigned i=0;i<4;i++){M7_W(0x60+i*8,meta[i]&0x7ffff);M7_W(0x64+i*8,meta[i]>>19);}
  M7_W(0x24,0);phase=PUBLISH;
 }
 if(phase==PUBLISH){
  if(M7_R(4)&8)return 1;
  geometry_m7_record[19]=M7_TICKS-start;
  done_frame=last_frame;done_render=last_render;done_context=last_context;last_epoch=epoch;have_result=1;phase=DRAIN;
 }
 geometry_m7_record[20]=phase;return 1;
}
