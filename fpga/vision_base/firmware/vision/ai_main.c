#include "shape_model.h"
#include "flyhash_service.h"
#include "fusion_service.h"
#include "connectome.h"
#define REG(off) (*(volatile uint32_t *)(0xf8100000u+(off)))
#define DMA(off) REG(0x100u+(off))
extern const uint8_t __weights_start[];
/* Host reads only complete records: sequence written last. Model1 is synthetic
   bring-up; its scores do not establish real-card recognition accuracy. */
volatile uint32_t analysis_result[24];
volatile int8_t analysis_features[128],analysis_hidden[32],analysis_logits[4];
volatile uint8_t analysis_gray[1024];
volatile uint32_t analysis_hash[8];
/* Flags bit0=run, bit1=latest, bit2=displayed source. Model/test/margin and
   explicit request nonce follow the original five-word diagnostic controls. */
volatile uint32_t analysis_control[9]={5,0,640u|(300u<<16),640u|(480u<<16),0,1,1,16,0};
volatile uint32_t fusion_result[16];
volatile int16_t analysis_connectome[80];
volatile uint32_t connectome_result[10];
void main(void){
 const struct shape_model *m=(const struct shape_model *)__weights_start;
 if(CONTROL_STATE->magic==0)control_init(); // SPI boot clears it; USER1 replacement preserves the live UI.
 if(m->magic!=0x53434d31u||DMA(0x2c)!=3||CTRL_R(0)!=0x26100802u||CONTROL_STATE->magic!=CONTROL_MAGIC||FUS_R(0)!=0x26100803u){REG(4)=3;for(;;);}
#ifdef VISION_MULHI_CFU
 if(m->s0>-2||m->s1>-2||m->s0<-30||m->s1<-30){REG(4)=3;for(;;);}
#endif
 uint32_t last=REG(0x30)-10000000u,sequence=0,failures=0,seen=0,policy=3,policy_geometry_sequence=0;
 struct fusion_job job={0};uint32_t key[12]={0};
 REG(4)=1;
 for(;;){
  control_service_step();if(CTRL_R(0x0c)>>31){REG(4)=3;for(;;);}
  flyhash_service_step();
  unsigned current_policy=CONTROL_STATE->ai_policy;
  if(policy!=current_policy){policy=current_policy;seen=0;policy_geometry_sequence=FUS_R(0x10);FUS_W(4,policy!=0);}
  uint32_t status=DMA(4);
  if(status&2){
   if(status&4){failures++;analysis_result[22]=DMA(0x24);analysis_result[23]=failures;
    fusion_publish(&job,0,FUS_ERROR<<8,0);DMA(0)=2;continue;}
   if(job.exact&&DMA(0x0c)!=job.g.frame){REG(4)=3;for(;;);}
   const volatile uint16_t *input=(const volatile uint16_t *)DMA(0x1c);
   analysis_result[17]=1;connectome_result[9]=1; // Producer owns arrays until the complete record is published.
   __asm__ volatile("fence rw,rw\n.word 0x500f\nfence rw,rw":::"memory");
   uint8_t f[64];int8_t x[128],h[32],o[4];uint32_t hash[8],start=REG(0x30),sum=0;
   for(unsigned i=0;i<1024;i++){uint8_t v=input[i];analysis_gray[i]=v;sum+=v;}
   shape_features((const uint8_t*)analysis_gray,x);uint32_t t0=REG(0x30);
   shape_dense(x,128,m->w0,m->b0,32,m->input_zero,m->hidden_zero,m->m0,m->s0,1,h);uint32_t t1=REG(0x30);
   shape_dense(h,32,m->w1,m->b1,4,m->hidden_zero,m->output_zero,m->m1,m->s1,0,o);uint32_t t2=REG(0x30);
   for(unsigned i=0;i<64;i++)f[i]=x[64+i]+128;flyhash_encode(f,hash);uint32_t end=REG(0x30);
   int16_t neurons[80];connectome_snapshot(x,neurons);uint32_t network_end=REG(0x30);
   for(unsigned i=0;i<80;i++)analysis_connectome[i]=neurons[i];
   connectome_result[0]=0x434f4e31;connectome_result[2]=DMA(0x0c);connectome_result[3]=DMA(0x10);
   connectome_result[4]=job.g.render;connectome_result[5]=job.g.context;connectome_result[6]=CONNECTOME_VERSION;
   connectome_result[7]=3;connectome_result[8]=network_end-end;
   unsigned label=0;for(unsigned i=1;i<4;i++)if(o[i]>o[label])label=i;
   for(unsigned i=0;i<128;i++)analysis_features[i]=x[i];for(unsigned i=0;i<32;i++)analysis_hidden[i]=h[i];
   for(unsigned i=0;i<4;i++)analysis_logits[i]=o[i];for(unsigned i=0;i<8;i++)analysis_hash[i]=hash[i];
   analysis_result[0]=0x41494d31;analysis_result[2]=DMA(0x0c);analysis_result[3]=DMA(0x10);analysis_result[4]=job.model;
   analysis_result[5]=label;analysis_result[6]=DMA(0x30);analysis_result[7]=DMA(0x34);analysis_result[8]=DMA(0x1c);
   analysis_result[9]=DMA(0x20);analysis_result[10]=t0-start;analysis_result[11]=t1-t0;analysis_result[12]=t2-t1;
   analysis_result[13]=end-t2;analysis_result[14]=network_end-start;analysis_result[15]=sum;
   analysis_result[16]=(uint8_t)o[0]|((uint32_t)(uint8_t)o[1]<<8)|((uint32_t)(uint8_t)o[2]<<16)|((uint32_t)(uint8_t)o[3]<<24);
   analysis_result[18]=start;analysis_result[19]=network_end;
   analysis_result[20]=job.g.render;analysis_result[21]=job.g.context;
   if(job.g.frame!=DMA(0x0c))job.geometry_class=0;job.g.frame=DMA(0x0c);
   fusion_publish(&job,DMA(0x10),fusion_flags(&job,label,o),analysis_result[16]);
   __asm__ volatile("fence rw,rw":::"memory");connectome_result[1]=sequence+1;connectome_result[9]=0;analysis_result[1]=++sequence;analysis_result[17]=0;DMA(0)=2;
  }else if(!(status&1)&&policy&&(analysis_control[0]&1)&&(uint32_t)(REG(0x30)-last)>=analysis_control[4]){
   struct fusion_geometry g=fusion_geometry_read();if(!g.sequence||!g.frame||g.sequence==policy_geometry_sequence)continue;
   // Background calibration can complete on a later scan of the same frozen
   // source/context. Dedup geometry contents, not just frame IDs or sequence.
   uint32_t next[12]={g.frame,g.render,g.context,analysis_control[5],analysis_control[2],analysis_control[3],analysis_control[8],policy,analysis_control[6],analysis_control[7],g.hi,g.lo};
   unsigned changed=!seen;for(unsigned i=0;i<12;i++)if(key[i]!=next[i])changed=1;
   if(!changed)continue;
   unsigned announce=!seen||key[3]!=next[3]||key[7]!=next[7]||key[8]!=next[8];
   seen=1;for(unsigned i=0;i<12;i++)key[i]=next[i];last=REG(0x30);
   job=(struct fusion_job){.g=g,.model=analysis_control[5],.test=analysis_control[6],.minimum_margin=analysis_control[7],.exact=policy==2||!(analysis_control[0]&2),.automatic=policy==2};
   if(policy==1&&!(analysis_control[0]&4)&&!(analysis_control[0]&2)){
    if(job.g.frame!=analysis_control[1])job.g.hi&=~(1u<<30);job.g.frame=analysis_control[1];
   }
   if(!fusion_roi(&job,policy==2,analysis_control[2],analysis_control[3])){
    fusion_publish(&job,0,FUS_NONE<<8,0);continue;
   }
   if(announce)fusion_publish(&job,0,FUS_WAIT<<8,0);
   DMA(8)=job.g.frame;DMA(0x14)=job.xy;DMA(0x18)=job.wh;
   DMA(0)=1|((policy==1&&(analysis_control[0]&2))?4:0);
  }
 }
}
void trap(void){REG(4)=3;for(;;);}
