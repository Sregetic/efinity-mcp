#include "flyhash_service.h"
#include "int8.h"
#define REG(off) (*(volatile uint32_t *)(0xf8100000u+(off)))
void main(void) {
    if(int8_dot4(0x80808080u,0x80808080u)!=65536){REG(4)=2;for(;;);}
    if(CTRL_R(0)!=0x26101002u){REG(4)=3;for(;;);}
    control_init();REG(4)=1;
    for(;;){control_service_step();if(CTRL_R(0x0c)>>31){REG(4)=3;for(;;); }flyhash_service_step();}
}
void trap(void) {REG(4)=3;for(;;);}
