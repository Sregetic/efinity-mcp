#pragma once
#include <stdint.h>
#include "vision_protocol.h"
enum {
    TT_GRID = 64,
    TT_TEMPLATE = 32,
    TT_RADIUS = 12,
    TT_POINTS = 48,
    TT_PERIOD_MS = 67,
    TT_HOLD_MS = 300,
    TT_LOST_MS = 1500,
    TT_SOURCE_LOST_MS = 3000
};
struct tt_point {
    uint32_t frame, ms;
    uint16_t x, y;
};
struct tt_reference {
    uint32_t edges[32], frame, ms;
    uint16_t x, y, w, h;
};
struct target_track {
    struct tt_reference reference;
    struct tt_point points[TT_POINTS];
    uint32_t frame, ms, last_good, start_ms, observations, misses, ambiguities;
    int x, y;
    unsigned sx, sy, state, head, count, miss_run;
    uint32_t near[32];
    uint16_t scores[625];
    uint32_t columns[25][64], near_columns[25][64];
    uint16_t density[25][65];
    unsigned cursor, best, best_index, best_rank, reference_count, hint;
};
void tt_reference_edges(struct tt_reference *r, const uint32_t *edges, unsigned x, unsigned y,
                        unsigned w, unsigned h, uint32_t frame, uint32_t ms);
void tt_select(struct target_track *t, const struct tt_reference *r);
unsigned tt_begin(struct target_track *t, const uint64_t *edges, uint32_t frame, uint32_t ms,
                  unsigned motion_hint);
unsigned tt_step(struct target_track *t, unsigned budget);
void tt_expire(struct target_track *t, uint32_t now);
void tt_sobel(const uint8_t gray[4096], uint64_t edges[64], unsigned threshold);
unsigned tt_roi(const struct target_track *t, unsigned w, unsigned h, unsigned old_x,
                unsigned old_y, uint32_t *xy);
