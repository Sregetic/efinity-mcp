#pragma once
#include <stdint.h>
void m7_face_begin(const uint8_t *gray,void *cascade);
unsigned m7_face_step(unsigned budget);
