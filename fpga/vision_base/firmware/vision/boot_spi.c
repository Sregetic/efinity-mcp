#include <stdint.h>
#ifndef ROM
#define ROM __attribute__((section(".boot.text")))
#endif
#ifndef BOOT_SPI_TEST
#define GPIO(off) (*(volatile uint32_t *)(0xf8100200u+((off)==0?0x50:(off)==4?0x48:0x4c)))
#define STATUS ((volatile uint32_t *)0x07621000u)
#define BOOT_DEST(part) ((volatile uint8_t *)(part?0x07400000u:0x07000000u))
#define BOOT_CONTROL_MAGIC (*(volatile uint32_t *)0x07620200u)
/* Existing control APB:0x48 SCK/CS/MOSI,0x4c pad-enable,0x50 synchronized MISO. */
static ROM uint8_t spi_byte(uint8_t v){
 uint8_t r=0;
 for(unsigned i=0;i<8;i++){
  unsigned out=(v&128)?4:0;GPIO(4)=out;GPIO(4)=out|1;
  r=(r<<1)|((GPIO(0)>>3)&1);GPIO(4)=out;v<<=1;
 }
 return r;
}
#endif
static ROM uint32_t crc_byte(uint32_t crc,uint8_t v){
 crc^=v;for(unsigned i=0;i<8;i++)crc=(crc>>1)^((0u-(crc&1))&0xedb88320u);return crc;
}
#ifndef BOOT_SPI_TEST
static ROM void fail(unsigned code){GPIO(4)=2;GPIO(8)=0;STATUS[1]=code;for(;;);}
#endif
/* Returns zero only for a blank application region (USER1 development boot). */
ROM uint32_t boot_spi(void){
 uint32_t h[8],crc=~0u;STATUS[0]=0x56424f31u;STATUS[1]=1;
 BOOT_CONTROL_MAGIC=0;GPIO(4)=2;GPIO(8)=15;GPIO(4)=0;
 spi_byte(0x9f);unsigned id=spi_byte(0);id=(id<<8)|spi_byte(0);id=(id<<8)|spi_byte(0);GPIO(4)=2;
 STATUS[2]=id;if(id!=0xef6017u)fail(3); // U14 fitted on this board, measured through GPIO and vendor JTAG bridge.
 GPIO(4)=0;spi_byte(3);spi_byte(0x70);spi_byte(0);spi_byte(0);
 for(unsigned n=0;n<8;n++){
  uint32_t v=0;for(unsigned i=0;i<4;i++){uint8_t b=spi_byte(0);v|=(uint32_t)b<<(8*i);if(n<7)crc=crc_byte(crc,b);}h[n]=v;
 }
 if(h[0]==~0u){GPIO(4)=2;GPIO(8)=0;STATUS[1]=2;return 0;}
 if(h[0]!=0x56424f31u||h[1]!=1||h[7]!=~crc||!h[2]||h[2]>0x400000u||h[3]!=0x07000000u||h[4]>0x200000u||h[2]+h[4]>0x100000u-32)fail(4);
 for(unsigned part=0;part<2;part++){
  volatile uint8_t *dst=BOOT_DEST(part);
  unsigned length=h[part?4:2];crc=~0u;
  /* Cold DDR stores use aligned words, as the proven ROM and USER1 loaders do. */
  for(unsigned i=0;i<length;i+=4){
   uint32_t word=0;for(unsigned k=0;k<4&&i+k<length;k++){uint8_t b=spi_byte(0);word|=(uint32_t)b<<(8*k);crc=crc_byte(crc,b);}
   ((volatile uint32_t *)dst)[i/4]=word;
  }
  STATUS[3+part]=length;if(h[5+part]!=~crc)fail(5+part);
 }
 GPIO(4)=2;GPIO(8)=0;
 /* The SPI copy uses cached DDR stores; publish them before instruction fetch. */
#ifndef BOOT_SPI_TEST
 __asm__ volatile("fence rw,rw\n.word 0x500f\nfence.i":::"memory");
#endif
 STATUS[1]=7;return h[3];
}
