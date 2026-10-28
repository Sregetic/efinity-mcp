#pragma once
#include "geometry_m7.h"
extern struct m7_box m7_face_boxes[4];
extern unsigned m7_face_count,m7_face_more;
/* Uses the same accepted edge plane and contour geometry as circles/rectangles. */
void m7_face_begin(const uint32_t *edges,const struct m7_contour *contours,unsigned count);
unsigned m7_face_step(unsigned budget);
