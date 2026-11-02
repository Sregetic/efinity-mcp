#pragma once
#include "geometry_face.h"
enum {M7_CACHE_W=960,M7_CACHE_H=540};
/* Exact-frame immutable cache; M7 threshold16..255, local normalized Sobel threshold=T/2. */
unsigned m7_face_refine_begin(const uint8_t *gray,unsigned high,unsigned median);
unsigned m7_face_refine_step(void);
