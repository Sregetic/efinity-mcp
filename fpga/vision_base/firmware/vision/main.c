#include "flyhash.h"
#include "int8.h"
#define REG(off) (*(volatile uint32_t *)(0xf8100000u+(off)))
static uint32_t read_word(unsigned i) { REG(0x1c)=i;return REG(0x20); }
static uint32_t cycles(void) { return REG(0x30); }
void main(void) {
    if(int8_dot4(0x80808080u,0x80808080u)!=65536){REG(4)=2;for(;;);}
    REG(4)=1;
    uint16_t handled=0;
    for(;;) {
        uint32_t job=REG(8);uint16_t token=job;
        if(!(job>>31)||token==handled||(!(job&(1u<<30))&&((job>>16)&127)!=64))continue;
        uint8_t features[64];uint32_t hash[8],start=cycles();
        REG(0x2c)=token;
        if(job&(1u<<30))flyhash_bitmap(read_word,features);
        else for(unsigned i=0;i<16;i++) {
            uint32_t word=REG(0x80+4*i);
            for(unsigned j=0;j<4;j++){features[4*i+j]=word;word>>=8;}
        }
        flyhash_encode(features,hash);
        if((uint16_t)REG(8)!=token)continue;
        for(unsigned i=0;i<8;i++)REG(0x40+4*i)=hash[i];
        for(unsigned i=0;i<16;i++)REG(0xc0+4*i)=
            features[4*i]|((uint32_t)features[4*i+1]<<8)|((uint32_t)features[4*i+2]<<16)|((uint32_t)features[4*i+3]<<24);
        REG(0x24)=cycles()-start;REG(0x28)=token;handled=token;
    }
}
void trap(void) {REG(4)=3;for(;;);}
