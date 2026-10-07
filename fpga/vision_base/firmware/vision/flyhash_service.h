#pragma once
#include "flyhash.h"
#include "control_service.h"
#define FLY_REG(off) (*(volatile uint32_t *)(0xf8100000u+(off)))
struct flyhash_record {
 uint32_t magic,sequence,nonce,frame,config,epoch,errors,cycles;
 uint8_t features[64];uint32_t hash[8];
};
#define FLY_RECORD ((volatile struct flyhash_record *)0x07620000u)
#define FLY_INPUT ((const volatile uint8_t *)0x07620100u)
static uint32_t fly_read_word(unsigned i){if(!(i&63))control_service_step();FLY_REG(0x1c)=i;return FLY_REG(0x20);}
static void flyhash_service_step(void){
 static uint16_t handled=0;static uint32_t sequence=0;
 uint32_t job=FLY_REG(8);uint16_t token=job;
 if(!(job>>31)||token==handled)return;
 uint8_t f[64];uint32_t h[8],start=FLY_REG(0x30);
 uint32_t frame=FLY_REG(0x0c),config=FLY_REG(0x10),epoch=FLY_REG(0x14),errors=FLY_REG(0x18);
 FLY_REG(0x2c)=token;FLY_RECORD->sequence=0;
 if(job&(1u<<30))flyhash_bitmap(fly_read_word,f);
 else for(unsigned i=0;i<64;i++)f[i]=FLY_INPUT[i];
 flyhash_encode(f,h);if(FLY_REG(8)!=job)return;
 for(unsigned i=0;i<64;i++)FLY_RECORD->features[i]=f[i];
 for(unsigned i=0;i<8;i++)FLY_RECORD->hash[i]=h[i];
 uint32_t cycles=FLY_REG(0x30)-start;
 FLY_RECORD->magic=0x464c5932;FLY_RECORD->nonce=token;FLY_RECORD->frame=frame;
 FLY_RECORD->config=config;FLY_RECORD->epoch=epoch;FLY_RECORD->errors=errors;FLY_RECORD->cycles=cycles;
 __asm__ volatile("fence rw,rw":::"memory");FLY_RECORD->sequence=++sequence;
 FLY_REG(0x24)=cycles;FLY_REG(0x28)=token;handled=token;
}
