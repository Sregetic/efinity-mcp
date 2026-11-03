#include <stdint.h>
#include "int8.h"
#define REG(off) (*(volatile uint32_t *)(0xf8100000u+(off)))
extern const uint8_t __weights_start[];
/* Explicit ROM data, not BSS: exercises an ELF payload beyond 3840 bytes. */
static const volatile uint8_t payload[8192] = {[0]=17,[4095]=23,[8191]=31};
static volatile uint8_t zeroed[257];
volatile uint32_t loader_result[8];
void main(void) {
 uint32_t start=REG(0x30),data=0,weights=0,bss=0;
 for(unsigned i=0;i<sizeof(payload);i++)data+=payload[i];
 for(unsigned i=0;i<8192;i++)weights+=__weights_start[i];
 for(unsigned i=0;i<sizeof(zeroed);i++)bss+=zeroed[i];
 loader_result[1]=data;loader_result[2]=weights;loader_result[3]=bss;
 loader_result[4]=int8_dot4(0x80808080u,0x80808080u);
 loader_result[5]=REG(0x30)-start;loader_result[6]=sizeof(payload);
 loader_result[7]=(uint32_t)__weights_start;
 loader_result[0]=0x4c445231u;REG(4)=4;
 for(;;);
}
void trap(void) {REG(4)=3;for(;;);}
