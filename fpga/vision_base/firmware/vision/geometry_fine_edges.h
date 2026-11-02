#pragma once
#include "geometry_m7.h"
enum {M7_FINE_W=192,M7_FINE_H=240,M7_FINE_X=144,M7_FINE_Y=15};
/* Caller fills a private ROI before begin; filtering may reuse this buffer. */
extern uint8_t m7_fine_gray[M7_FINE_W*M7_FINE_H];
extern uint32_t m7_fine_edges[M7_WORDS];
void m7_fine_edges_begin(unsigned high,unsigned median);
unsigned m7_fine_edges_step(unsigned budget);
