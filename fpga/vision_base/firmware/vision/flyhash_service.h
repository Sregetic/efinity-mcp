#pragma once
#include "flyhash.h"
#define FLY_REG(off) (*(volatile uint32_t *)(0xf8100000u+(off)))
static uint32_t fly_read_word(unsigned i){FLY_REG(0x1c)=i;return FLY_REG(0x20);}
/* Shared existing USER2 mailbox service, retained while AI uses its own DMA. */
static void flyhash_service_step(void){
 static uint16_t handled=0;
 uint32_t job=FLY_REG(8);uint16_t token=job;
 if(!(job>>31)||token==handled||(!(job&(1u<<30))&&((job>>16)&127)!=64))return;
 uint8_t f[64];uint32_t h[8],start=FLY_REG(0x30);FLY_REG(0x2c)=token;
 if(job&(1u<<30))flyhash_bitmap(fly_read_word,f);
 else for(unsigned i=0;i<16;i++){
  uint32_t word=FLY_REG(0x80+4*i);for(unsigned j=0;j<4;j++){f[4*i+j]=word;word>>=8;}
 }
 flyhash_encode(f,h);if((uint16_t)FLY_REG(8)!=token)return;
 for(unsigned i=0;i<8;i++)FLY_REG(0x40+4*i)=h[i];
 for(unsigned i=0;i<16;i++)FLY_REG(0xc0+4*i)=f[4*i]|((uint32_t)f[4*i+1]<<8)|((uint32_t)f[4*i+2]<<16)|((uint32_t)f[4*i+3]<<24);
 FLY_REG(0x24)=FLY_REG(0x30)-start;FLY_REG(0x28)=token;handled=token;
}
