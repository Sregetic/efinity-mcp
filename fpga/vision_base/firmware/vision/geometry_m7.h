#pragma once
#include <stdint.h>

enum { M7_W=480, M7_H=270, M7_WORDS=4050, M7_CIRCLE=1, M7_RECTANGLE=2, M7_FACE=3 };
struct m7_box { uint16_t x0,y0,x1,y1; uint32_t area,klass; };
enum { M7_CONTOURS=512, M7_INNER_CONTOUR=256 };
struct m7_contour { uint16_t x0,y0,x1,y1; uint32_t area2,klass; };
extern struct m7_contour m7_contours[M7_CONTOURS];
extern unsigned m7_contour_count;
extern const uint32_t m7_bit_mask[32];
extern struct m7_box m7_boxes[4];
extern unsigned m7_count,m7_more,m7_complex;
void m7_begin(const uint32_t *edges);
unsigned m7_step(unsigned budget);
void m7_retain(struct m7_box boxes[4],unsigned *count,unsigned *more,struct m7_box box);
