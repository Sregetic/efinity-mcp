#pragma once
#include "geometry_m7.h"
extern struct m7_box m7_face_boxes[4];
extern unsigned m7_face_count,m7_face_more;
enum {M7_HEAD_PROPOSALS=8};
extern struct m7_box m7_head_proposals[M7_HEAD_PROPOSALS];
extern unsigned m7_head_count;
/* Outline proposals may request M7-local fine edges; final faces need eyes/nose/mouth. */
void m7_face_begin(const uint32_t *edges,const struct m7_contour *contours,unsigned count);
void m7_face_begin_fine(const uint32_t *edges,const struct m7_contour *contours,unsigned count,struct m7_box prior);
unsigned m7_face_step(unsigned budget);
