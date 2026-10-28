#pragma once
#include <stdint.h>

enum { M7_W=480, M7_H=270, M7_WORDS=4050, M7_CIRCLE=1, M7_RECTANGLE=2, M7_FACE=3 };
struct m7_box { uint16_t x0,y0,x1,y1; uint32_t area,klass; };
extern struct m7_box m7_boxes[4];
extern unsigned m7_count,m7_more,m7_complex;
void m7_begin(const uint32_t *edges);
unsigned m7_step(unsigned budget);
void m7_add_face(unsigned x0,unsigned y0,unsigned x1,unsigned y1);
