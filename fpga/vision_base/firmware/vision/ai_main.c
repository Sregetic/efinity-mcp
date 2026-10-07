#include "shape_model.h"
#include "flyhash_service.h"
#define REG(off) (*(volatile uint32_t *)(0xf8100000u+(off)))
#define DMA(off) REG(0x100u+(off))
extern const uint8_t __weights_start[];
/* Host reads only complete records: sequence written last. Model1 is synthetic
   bring-up; its scores do not establish real-card recognition accuracy. */
volatile uint32_t analysis_result[24];
volatile int8_t analysis_features[128],analysis_hidden[32],analysis_logits[4];
volatile uint8_t analysis_gray[1024];
volatile uint32_t analysis_hash[8];
/* USER1 edits this five-word control while CPU is halted. Flags: enabled bit0,
   latest bit1; otherwise request the exact source frame in word1. */
volatile uint32_t analysis_control[5]={3,0,640u|(300u<<16),640u|(480u<<16),10000000u};
void main(void){
 const struct shape_model *m=(const struct shape_model *)__weights_start;
 if(m->magic!=0x53434d31u||DMA(0x2c)!=3||CTRL_R(0)!=0x26100802u||CONTROL_STATE->magic!=CONTROL_MAGIC){REG(4)=3;for(;;);}
#ifdef VISION_MULHI_CFU
 if(m->s0>-2||m->s1>-2||m->s0<-30||m->s1<-30){REG(4)=3;for(;;);}
#endif
 uint32_t last=REG(0x30)-10000000u,sequence=0,failures=0;
 REG(4)=1;
 for(;;){
  control_service_step();if(CTRL_R(0x0c)>>31){REG(4)=3;for(;;);}
  flyhash_service_step();
  uint32_t status=DMA(4);
  if(status&2){
   if(status&4){failures++;analysis_result[22]=DMA(0x24);analysis_result[23]=failures;DMA(0)=2;continue;}
   const volatile uint16_t *input=(const volatile uint16_t *)DMA(0x1c);
   analysis_result[17]=1; // Producer owns arrays until the complete record is published.
   __asm__ volatile("fence rw,rw\n.word 0x500f\nfence rw,rw":::"memory");
   uint8_t f[64];int8_t x[128],h[32],o[4];uint32_t hash[8],start=REG(0x30),sum=0;
   for(unsigned i=0;i<1024;i++){uint8_t v=input[i];analysis_gray[i]=v;sum+=v;}
   shape_features((const uint8_t*)analysis_gray,x);uint32_t t0=REG(0x30);
   shape_dense(x,128,m->w0,m->b0,32,m->input_zero,m->hidden_zero,m->m0,m->s0,1,h);uint32_t t1=REG(0x30);
   shape_dense(h,32,m->w1,m->b1,4,m->hidden_zero,m->output_zero,m->m1,m->s1,0,o);uint32_t t2=REG(0x30);
   for(unsigned i=0;i<64;i++)f[i]=x[64+i]+128;flyhash_encode(f,hash);uint32_t end=REG(0x30);
   unsigned label=0;for(unsigned i=1;i<4;i++)if(o[i]>o[label])label=i;
   for(unsigned i=0;i<128;i++)analysis_features[i]=x[i];for(unsigned i=0;i<32;i++)analysis_hidden[i]=h[i];
   for(unsigned i=0;i<4;i++)analysis_logits[i]=o[i];for(unsigned i=0;i<8;i++)analysis_hash[i]=hash[i];
   analysis_result[0]=0x41494d31;analysis_result[2]=DMA(0x0c);analysis_result[3]=DMA(0x10);analysis_result[4]=1;
   analysis_result[5]=label;analysis_result[6]=DMA(0x30);analysis_result[7]=DMA(0x34);analysis_result[8]=DMA(0x1c);
   analysis_result[9]=DMA(0x20);analysis_result[10]=t0-start;analysis_result[11]=t1-t0;analysis_result[12]=t2-t1;
   analysis_result[13]=end-t2;analysis_result[14]=end-start;analysis_result[15]=sum;
   analysis_result[16]=(uint8_t)o[0]|((uint32_t)(uint8_t)o[1]<<8)|((uint32_t)(uint8_t)o[2]<<16)|((uint32_t)(uint8_t)o[3]<<24);
   analysis_result[18]=start;analysis_result[19]=end;
   __asm__ volatile("fence rw,rw":::"memory");analysis_result[1]=++sequence;analysis_result[17]=0;DMA(0)=2;
  }else if(!(status&1)&&(analysis_control[0]&1)&&(uint32_t)(REG(0x30)-last)>=analysis_control[4]){
   last=REG(0x30);DMA(8)=analysis_control[1];DMA(0x14)=analysis_control[2];DMA(0x18)=analysis_control[3];
   DMA(0)=1|((analysis_control[0]&2)<<1);
  }
 }
}
void trap(void){REG(4)=3;for(;;);}
