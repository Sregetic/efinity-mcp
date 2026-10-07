#include <stdint.h>
#define REG(o) (*(volatile uint32_t*)(0xf8100000u+(o)))
#define DMA(o) REG(0x100u+(o))
volatile uint32_t dma_only_result[3];
void main(void){uint32_t last=REG(0x30)-10000000u;REG(4)=1;
DMA(0x14)=640u|(300u<<16);DMA(0x18)=640u|(480u<<16);
for(;;){uint32_t s=DMA(4);if(s&2){dma_only_result[0]++;dma_only_result[1]+=(s&4)!=0;dma_only_result[2]=DMA(0x20);DMA(0)=2;}
else if(!(s&1)&&(uint32_t)(REG(0x30)-last)>=10000000u){last=REG(0x30);DMA(0)=5;}}
}
void trap(void){REG(4)=3;for(;;);}
