#include "shape_model.h"
#include "flyhash_service.h"
#include "fusion_service.h"
#include "connectome.h"
#include "ai_selftest.h"
#ifdef VISION_GEOMETRY_M7
#include "geometry_m7_service.h"
#endif
#ifdef VISION_CONNECTOME_READOUT
#include "connectome_readout.h"
extern const struct connectome_readout_model connectome_readout_weights;
volatile int8_t analysis_connectome_scores[4];
/* CRD1: sequence/frame/source-config/render/context/graph/model/kind/scores/label/times/busy. */
volatile uint32_t connectome_readout_result[14];
#endif
#ifdef VISION_FOMO
#include "fomo_pixels.h"
#endif
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
/* state, selftest, completed sequence, INT8/FlyHash/network us, frame, context. */
volatile uint32_t ai_runtime[8];
static uint32_t ai_us(uint32_t cycles){uint32_t us=cycles/100;return us>65535?65535:us;}
static void ai_publish(struct fusion_job *j,uint32_t config,uint32_t flags,uint32_t scores){
 j->telemetry=(ai_runtime[0]<<11)|(ai_runtime[1]<<13)|((ai_runtime[2]&65535)<<16);
 j->timing0=ai_runtime[0]==2?ai_runtime[3]|(ai_runtime[4]<<16):0;
 j->timing1=ai_runtime[0]==2?ai_runtime[5]:0;
#ifdef VISION_FOMO
 if(ai_runtime[0]==2&&j->model==FOMO_MODEL_ID){
  j->timing0=(fomo_camera_status[8]/100000)|((fomo_camera_status[9]/100000)<<16);
  j->timing1=fomo_camera_status[10]/100000;
 }
#endif
 fusion_publish(j,config,flags|(j->test<<1),scores);
}
void main(void){
 const struct shape_model *m=(const struct shape_model *)__weights_start;
 if(CONTROL_STATE->magic==0)control_init(); // SPI boot clears it; USER1 replacement preserves the live UI.
 if(m->magic!=0x53434d31u||DMA(0x2c)!=3||CTRL_R(0)!=0x26101002u||CONTROL_STATE->magic!=CONTROL_MAGIC||FUS_R(0)!=0x26101003u
#ifdef VISION_GEOMETRY_M7
 ||M7_R(0)!=0x26102871u||M7_R(0x3c)!=0x4d374c31u
#endif
 ){REG(4)=3;for(;;);}
#ifdef VISION_CONNECTOME_READOUT
 if(!connectome_readout_valid(&connectome_readout_weights)){REG(4)=3;for(;;);}
#endif
#ifdef VISION_MULHI_CFU
 if(m->s0>-2||m->s1>-2||m->s0<-30||m->s1<-30){REG(4)=3;for(;;);}
#endif
 control_sidebar_reset();
 uint32_t last=REG(0x30)-10000000u,sequence=0,failures=0,seen=0,policy=3,policy_geometry_sequence=0;
 struct fusion_job job={.model=1,.test=1},completed={.model=1,.test=1};
 uint32_t key[13]={0},ui_request=0,selftest_request=0,completed_flags=0,completed_config=0,completed_scores=0;
#ifdef VISION_FOMO
 unsigned job_fomo=0;uint32_t legacy_model=1,center_job=0;
 fomo_camera_init();
#endif
 ai_runtime[1]=1;ai_publish(&job,0,0,0);
 ai_runtime[1]=ai_selftest(m);ai_publish(&job,0,0,0);
 REG(4)=1;
 for(;;){
  control_service_step();if(CTRL_R(0x0c)>>31){REG(4)=3;for(;;);}
  flyhash_service_step();control_center_step();
  unsigned current_policy=CONTROL_STATE->ai_policy;
  if(policy!=current_policy){
   policy=current_policy;seen=0;policy_geometry_sequence=FUS_R(0x10);FUS_W(4,policy!=0);
   if(!policy){ui_request=CONTROL_STATE->ai_request;ai_runtime[0]=0;ai_publish(&job,0,0,0);}
  }
  #ifdef VISION_GEOMETRY_M7
  if(geometry_m7_service_step(ai_runtime[0]!=1))continue;
  #endif
  uint32_t status=DMA(4);
  if(status&2){
   if(status&4){if(CONTROL_STATE->center_stage==3)control_center_finish(CENTER_ERROR);failures++;analysis_result[22]=DMA(0x24);analysis_result[23]=failures;
    ai_runtime[0]=3;ai_publish(&job,0,FUS_ERROR<<8,0);DMA(0)=2;continue;}
   if(job.exact&&DMA(0x0c)!=job.g.frame){REG(4)=3;for(;;);}
   volatile uint16_t *input=(volatile uint16_t *)DMA(0x1c);
   analysis_result[17]=1;connectome_result[9]=1; // Producer owns arrays until the complete record is published.
#ifdef VISION_CONNECTOME_READOUT
   connectome_readout_result[13]=1;
#endif
   __asm__ volatile("fence rw,rw\n.word 0x500f\nfence rw,rw":::"memory");
   uint8_t f[64];int8_t x[128],h[32],o[4];uint32_t hash[8],start=REG(0x30),sum=0;
#ifdef VISION_FOMO
   if(job_fomo){
    fomo_gray_roi((const volatile uint16_t*)DMA(0x38),job.xy,job.wh,analysis_gray);
    for(unsigned i=0;i<1024;i++)input[i]=analysis_gray[i]; // Preserve the legacy gray tensor/readback contract.
   }
#endif
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
#ifdef VISION_CONNECTOME_READOUT
   int8_t circuit_scores[4];uint32_t head_start=REG(0x30);
   connectome_readout(&connectome_readout_weights,neurons,circuit_scores);
   uint32_t head_cycles=REG(0x30)-head_start;unsigned circuit_label=0;uint32_t packed_scores=0;
   for(unsigned i=0;i<4;i++){
    analysis_connectome_scores[i]=circuit_scores[i];packed_scores|=(uint32_t)(uint8_t)circuit_scores[i]<<(8*i);
    if(circuit_scores[i]>circuit_scores[circuit_label])circuit_label=i;
   }
   const uint32_t head_record[11]={DMA(0x0c),DMA(0x10),job.g.render,job.g.context,CONNECTOME_VERSION,
       connectome_readout_weights.version,connectome_readout_weights.training_kind,packed_scores,
       circuit_label,head_cycles,network_end-end};
   connectome_readout_result[0]=0x43524431;
   for(unsigned i=0;i<11;i++)connectome_readout_result[2+i]=head_record[i];
#endif
   unsigned label=0;for(unsigned i=1;i<4;i++)if(o[i]>o[label])label=i;
   for(unsigned i=0;i<128;i++)analysis_features[i]=x[i];for(unsigned i=0;i<32;i++)analysis_hidden[i]=h[i];
   for(unsigned i=0;i<4;i++)analysis_logits[i]=o[i];for(unsigned i=0;i<8;i++)analysis_hash[i]=hash[i];
   analysis_result[0]=0x41494d31;analysis_result[2]=DMA(0x0c);analysis_result[3]=DMA(0x10);analysis_result[4]=job.model;
#ifdef VISION_FOMO
   analysis_result[4]=legacy_model;
#endif
   analysis_result[5]=label;analysis_result[6]=DMA(0x30);analysis_result[7]=DMA(0x34);analysis_result[8]=DMA(0x1c);
   analysis_result[9]=DMA(0x20);analysis_result[10]=t0-start;analysis_result[11]=t1-t0;analysis_result[12]=t2-t1;
   analysis_result[13]=end-t2;analysis_result[14]=network_end-start;analysis_result[15]=sum;
   analysis_result[16]=(uint8_t)o[0]|((uint32_t)(uint8_t)o[1]<<8)|((uint32_t)(uint8_t)o[2]<<16)|((uint32_t)(uint8_t)o[3]<<24);
   analysis_result[18]=start;analysis_result[19]=network_end;
   analysis_result[20]=job.g.render;analysis_result[21]=job.g.context;
   if(job.g.frame!=DMA(0x0c))job.geometry_class=0;job.g.frame=DMA(0x0c);
   ai_runtime[0]=2;ai_runtime[2]=sequence+1;ai_runtime[3]=ai_us(t2-t0);
   ai_runtime[4]=ai_us(end-t2);ai_runtime[5]=ai_us(network_end-end);
   ai_runtime[6]=job.g.frame;ai_runtime[7]=job.g.context;
#ifdef VISION_FOMO
   if(job_fomo){
    fomo_camera_run(DMA(0x38),job.xy,job.wh);
    unsigned cell=0,count=fomo_camera_status[12];
    label=fomo_camera_status[14];
    if(count){
     const volatile struct fomo_detection *b=&fomo_detections[fomo_camera_status[13]];
     cell=b->peak_cell;
     unsigned x=job.xy&65535,y=job.xy>>16,w=job.wh&65535,h=job.wh>>16;
     unsigned left=x+b->left*w/96,top=y+b->top*h/96;
     unsigned right=x+(b->right*w+95)/96,bottom=y+(b->bottom*h+95)/96;
     fusion_map_box(&job,left,top,right-left,bottom-top);
     control_center_fomo(center_job,&job,1,left,top,right-left,bottom-top);
    }else{
     for(unsigned i=1;i<144;i++)if(fomo_camera_output[i*4]>fomo_camera_output[cell*4])cell=i;
     job.box0=0xffffffffu;job.box1=0;
     control_center_fomo(center_job,&job,0,0,0,0,0);
    }
    for(unsigned i=0;i<4;i++)o[i]=fomo_camera_output[cell*4+i];
    fomo_camera_status[3]=job.g.frame;fomo_camera_status[4]=DMA(0x10);
    fomo_camera_status[5]=job.g.render;fomo_camera_status[6]=job.g.context;
   }
#endif
   // Volatile byte copy keeps this freestanding build independent of libc memcpy.
   for(unsigned i=0;i<sizeof(job);i++)((volatile uint8_t*)&completed)[i]=((const uint8_t*)&job)[i];
   completed_config=DMA(0x10);completed_flags=fusion_flags(&job,label,o);
   completed_scores=(uint8_t)o[0]|((uint32_t)(uint8_t)o[1]<<8)|((uint32_t)(uint8_t)o[2]<<16)|((uint32_t)(uint8_t)o[3]<<24);
   ai_publish(&completed,completed_config,completed_flags,completed_scores);
   __asm__ volatile("fence rw,rw":::"memory");connectome_result[1]=sequence+1;connectome_result[9]=0;analysis_result[1]=++sequence;analysis_result[17]=0;
#ifdef VISION_CONNECTOME_READOUT
   connectome_readout_result[1]=sequence;connectome_readout_result[13]=0;
#endif
#ifdef VISION_FOMO
   if(job_fomo){fomo_camera_status[2]=sequence;__asm__ volatile("fence rw,rw":::"memory");fomo_camera_status[1]=3;}
#endif
   DMA(0)=2;
  }else if(!(status&1)&&selftest_request!=CONTROL_STATE->selftest_request){
   selftest_request=CONTROL_STATE->selftest_request;ai_runtime[1]=1;if(sequence)ai_runtime[0]=2;
   ai_publish(&completed,completed_config,completed_flags,completed_scores);
   ai_runtime[1]=ai_selftest(m);ai_publish(&completed,completed_config,completed_flags,completed_scores);
  }else if(!(status&1)&&policy&&(analysis_control[0]&1)&&(uint32_t)(REG(0x30)-last)>=analysis_control[4]){
   unsigned request=ui_request!=CONTROL_STATE->ai_request;
   if((CONTROL_STATE->ai_manual&1)&&!request)continue;
   if(CONTROL_STATE->feature_wait||CONTROL_STATE->pending||CONTROL_STATE->key_roi_dirty)continue;
   struct fusion_geometry g=fusion_geometry_read();if(!g.sequence||!g.frame||g.sequence==policy_geometry_sequence)continue;
   if(request&&policy==1){
    struct vision_control_state *s=CONTROL_STATE;
    unsigned x=640,y=300,w=640,h=480;
    if(s->enabled&&s->good){x=s->commit[0]>>12;y=s->commit[0]&4095;w=s->commit[1]>>12;h=s->commit[1]&4095;}
    analysis_control[2]=x|(y<<16);analysis_control[3]=w|(h<<16);analysis_control[8]++;
   }
   // Background calibration can complete on a later scan of the same frozen
   // source/context. Dedup geometry contents, not just frame IDs or sequence.
   uint32_t next[13]={g.frame,g.render,g.context,analysis_control[5],analysis_control[2],analysis_control[3],analysis_control[8],policy,analysis_control[6],analysis_control[7],g.hi,g.lo,(CONTROL_STATE->ai_manual>>1)&1};
   unsigned changed=!seen;for(unsigned i=0;i<13;i++)if(key[i]!=next[i])changed=1;
   if(!changed&&!request)continue;
   unsigned announce=request||!seen||key[3]!=next[3]||key[7]!=next[7]||key[8]!=next[8]||key[12]!=next[12];
   seen=1;for(unsigned i=0;i<13;i++)key[i]=next[i];last=REG(0x30);
   job=(struct fusion_job){.g=g,.model=analysis_control[5],.test=analysis_control[6],.minimum_margin=analysis_control[7],.exact=request||policy==2||!(analysis_control[0]&2),.automatic=policy==2};
#ifdef VISION_FOMO
   job_fomo=next[12];legacy_model=job.model;
   if(job_fomo){job.model=FOMO_MODEL_ID;job.test=0;}
#endif
   if(!request&&policy==1&&!(analysis_control[0]&4)&&!(analysis_control[0]&2)){
    if(job.g.frame!=analysis_control[1])job.g.hi&=~(1u<<30);job.g.frame=analysis_control[1];
   }
   if(!fusion_roi(&job,policy==2,analysis_control[2],analysis_control[3])){
#ifdef VISION_FOMO
     if(job_fomo&&CONTROL_STATE->center_stage==3)control_center_finish(CENTER_NONE);
#endif
    ui_request=CONTROL_STATE->ai_request;ai_runtime[0]=0;ai_publish(&job,0,FUS_NONE<<8,0);continue;
   }
   ui_request=CONTROL_STATE->ai_request;ai_runtime[0]=1;
   if(announce)ai_publish(&job,0,FUS_WAIT<<8,0);
#ifdef VISION_FOMO
   center_job=job_fomo&&CONTROL_STATE->center_stage==3?CONTROL_STATE->center_seen:0;
#endif
   DMA(8)=job.g.frame;DMA(0x14)=job.xy;DMA(0x18)=job.wh;
   DMA(0)=1|((!request&&policy==1&&(analysis_control[0]&2))?4:0)
#ifdef VISION_FOMO
       |(job_fomo?8:0)
#endif
       ;
  }
 }
}
void trap(void){REG(4)=3;for(;;);}
