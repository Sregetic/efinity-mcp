#include "flyhash.h"
#include <stddef.h>
// Freestanding GCC emits this call for the zero-initialized local arrays.
__attribute__((used)) void *memset(void *dst,int value,size_t count) {
    unsigned char *p=dst;for(size_t i=0;i<count;i++)p[i]=value;return dst;
}

void flyhash_encode(const uint8_t features[64], uint32_t hash[8]) {
    uint16_t state=0x2210, best[13]={0};
    uint8_t ids[13]={0}, count=0;
    for(unsigned n=0;n<256;n++) {
        uint8_t selected[6]; unsigned used=0,score=0;
        while(used<6) {
            state=(state>>1)^((state&1)?0xb400:0);
            uint8_t index=state&63; unsigned j=0;
            while(j<used && selected[j]!=index)j++;
            if(j==used){selected[used++]=index;score+=features[index];}
        }
        unsigned pos=0;
        while(pos<count && score<=best[pos])pos++;
        if(pos<13) {
            for(unsigned j=12;j>pos;j--){best[j]=best[j-1];ids[j]=ids[j-1];}
            best[pos]=score;ids[pos]=n;
        }
        if(count<13)count++;
    }
    for(unsigned j=0;j<8;j++)hash[j]=0;
    for(unsigned j=0;j<13;j++)hash[ids[j]>>5]|=1u<<(ids[j]&31);
}

void flyhash_counts(const uint16_t counts[64], uint8_t features[64]) {
    for(unsigned i=0;i<64;i++) {
        unsigned row=i>>3, h=(270*(row+1)/8)-(270*row/8);
        unsigned area=60*h;
        features[i]=(((unsigned)counts[i]<<8)-counts[i]+area/2)/area;
    }
}

void flyhash_bitmap(uint32_t (*read_word)(unsigned), uint8_t features[64]) {
    uint16_t counts[64]={0};
    unsigned x=0,y=0,bx=0,by=0,next_y=33;
    for(unsigned i=0;i<4050;i++) {
        uint32_t word=read_word(i);
        for(unsigned bit=0;bit<32;bit++) {
            counts[(by<<3)+bx]+=word&1;word>>=1;
            x++;
            if(x==60*(bx+1))bx++;
            if(x==480) {
                x=0;bx=0;y++;
                if(y==next_y){by++;next_y=270*(by+1)/8;}
            }
        }
    }
    flyhash_counts(counts,features);
}
