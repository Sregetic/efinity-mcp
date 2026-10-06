#pragma once
#include <stdint.h>
void flyhash_encode(const uint8_t features[64], uint32_t hash[8]);
void flyhash_counts(const uint16_t counts[64], uint8_t features[64]);
void flyhash_bitmap(uint32_t (*read_word)(unsigned), uint8_t features[64]);
