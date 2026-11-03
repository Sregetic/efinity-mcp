#include <assert.h>
#include <stdio.h>
#include "geometry_m7.h"
#include "geometry_letters.h"
static uint32_t bits[M7_WORDS];
int main(void){
 for(unsigned y=20;y<250;y++)for(unsigned x=20;x<460;x++){unsigned p=y*M7_W+x;bits[p>>5]|=m7_bit_mask[p&31];}
 m7_begin(bits);unsigned calls=0;while(!m7_step(512))assert(++calls<100000);
 assert(m7_count==1&&m7_boxes[0].klass==M7_RECTANGLE);
 m7_letters_begin(bits);calls=0;while(!m7_letters_step(64))assert(++calls<100000);
 assert(m7_complex&&m7_count==1&&m7_boxes[0].klass==M7_RECTANGLE);
 assert(m7_boxes[0].x0==20&&m7_boxes[0].y0==20&&m7_boxes[0].x1==459&&m7_boxes[0].y1==249);
 puts("PASS bounded component overflow rejects incomplete letters and preserves the geometric rectangle");
}
