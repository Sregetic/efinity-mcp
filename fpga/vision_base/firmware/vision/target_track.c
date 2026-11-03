#include "target_track.h"
static unsigned pop(uint32_t x) {
    x -= x >> 1 & 0x55555555u;
    x = (x & 0x33333333u) + (x >> 2 & 0x33333333u);
    x = (x + (x >> 4)) & 0x0f0f0f0fu;
    x += x >> 8;
    x += x >> 16;
    return x & 63;
}
static unsigned absolute(int x) {
    return x < 0 ? -x : x;
}
static int bound(int v, int maximum) {
    return v < 0 ? 0 : v > maximum ? maximum : v;
}
void tt_reference_edges(struct tt_reference *r, const uint32_t *edges, unsigned x, unsigned y,
                        unsigned w, unsigned h, uint32_t frame, uint32_t ms) {
    *r = (struct tt_reference){.frame = frame, .ms = ms, .x = x, .y = y, .w = w, .h = h};
    unsigned sx = (w + 23) / 24, sy = (h + 23) / 24;
    if (sx < 2)
        sx = 2;
    if (sy < 2)
        sy = 2;
    int cx = x + w / 2, cy = y + h / 2, l = cx - 16 * (int)sx, top = cy - 16 * (int)sy;
    for (int yy = bound(top / 4, 269); yy < 270 && yy * 4 < top + 32 * (int)sy; yy++)
        for (int xx = bound(l / 4, 479); xx < 480 && xx * 4 < l + 32 * (int)sx; xx++) {
            unsigned p = yy * 480 + xx;
            if (!(edges[p >> 5] & (1u << (p & 31))))
                continue;
            int gx = (xx * 4 - l) / (int)sx, gy = (yy * 4 - top) / (int)sy;
            if (gx >= 0 && gx < 32 && gy >= 0 && gy < 32)
                r->edges[gy] |= 1u << gx;
        }
}
void tt_select(struct target_track *t, const struct tt_reference *r) {
    *t = (struct target_track){.reference = *r,
                               .x = r->x + r->w / 2,
                               .y = r->y + r->h / 2,
                               .state = TT_LOCKED,
                               .frame = r->frame,
                               .ms = r->ms,
                               .last_good = r->ms,
                               .start_ms = r->ms};
    t->sx = (r->w + 23) / 24;
    t->sy = (r->h + 23) / 24;
    if (t->sx < 2)
        t->sx = 2;
    if (t->sy < 2)
        t->sy = 2;
    for (unsigned n = 0; n < 32; n++) {
        uint32_t v = r->edges[n] | (n ? r->edges[n - 1] : 0) | (n < 31 ? r->edges[n + 1] : 0);
        t->near[n] = v | (v << 1) | (v >> 1);
        t->reference_count += pop(r->edges[n]);
    }
    if (t->reference_count < 12)
        t->state = TT_LOST;
}
void tt_expire(struct target_track *t, uint32_t now) {
    while (t->count && (uint32_t)(now - t->points[t->head].ms) >= 3000) {
        t->head = (t->head + 1) % TT_POINTS;
        t->count--;
    }
    if (t->state == TT_LOCKED || t->state == TT_HOLD) {
        uint32_t input_ms = t->frame == t->reference.frame ? t->start_ms : t->ms;
        if ((uint32_t)(now - input_ms) > TT_SOURCE_LOST_MS)
            t->state = TT_LOST;
        else if ((uint32_t)(now - t->last_good) > TT_HOLD_MS)
            t->state = TT_HOLD;
    }
}
unsigned tt_begin(struct target_track *t, const uint64_t *edges, uint32_t frame, uint32_t ms,
                  unsigned hint) {
    if (t->state == TT_OFF || t->state == TT_LOST || frame == t->frame)
        return 0;
    t->frame = frame;
    t->ms = ms;
    t->cursor = 0;
    t->best = 65535;
    t->best_rank = 625;
    t->hint = hint;
    // Reuse each shifted row across all 25 vertical candidates, with exact integer scores.
    for (unsigned y = 0; y < 64; y++) {
        uint64_t bits = edges[y] >> 4,
                 near = (edges[y] | (y ? edges[y - 1] : 0) | (y < 63 ? edges[y + 1] : 0)) >> 4;
        for (unsigned col = 0; col < 25; col++, bits >>= 1, near >>= 1) {
            uint32_t v = near;
            t->columns[col][y] = bits;
            t->near_columns[col][y] = v | (v << 1) | (v >> 1);
        }
    }
    for (unsigned col = 0; col < 25; col++) {
        t->density[col][0] = 0;
        for (unsigned y = 0; y < 64; y++)
            t->density[col][y + 1] = t->density[col][y] + pop(t->columns[col][y]);
    }
    return 1;
}
unsigned tt_step(struct target_track *t, unsigned budget) {
    if (t->state == TT_LOST)
        return 1;
    while (budget-- && t->cursor < 625) {
        unsigned n = t->cursor++, column = n / 25, row = n % 25;
        // Motion only changes search order; every displacement is scored from measured edges.
        if (t->hint == MOTION_RIGHT)
            column = 24 - column;
        if (t->hint == MOTION_DOWN)
            row = 24 - row;
        unsigned id = row * 25 + column, top = 4 + row, miss = 0, extra = 0, difference = 0;
        unsigned pixels = t->density[column][top + 32] - t->density[column][top];
        for (unsigned y = 0; y < 32; y++) {
            uint32_t v = t->columns[column][top + y], near = t->near_columns[column][top + y];
            miss += pop(t->reference.edges[y] & ~near);
            extra += pop(v & ~t->near[y]);
            difference += pop(v ^ t->reference.edges[y]);
        }
        unsigned score =
            (miss * 2000 + extra * 1000 + difference * 100) / (t->reference_count + pixels);
        t->scores[id] = score;
        unsigned rank = (t->hint == MOTION_DOWN ? 24 - row : row) * 25 +
                        (t->hint == MOTION_RIGHT ? 24 - column : column);
        if (score < t->best || (score == t->best && rank < t->best_rank)) {
            t->best = score;
            t->best_index = id;
            t->best_rank = rank;
        }
    }
    if (t->cursor < 625)
        return 0;
    unsigned bx = t->best_index % 25, by = t->best_index / 25, second = 65535;
    for (unsigned n = 0; n < 625; n++)
        if (absolute((int)(n % 25) - (int)bx) > 4 || absolute((int)(n / 25) - (int)by) > 4)
            if (t->scores[n] < second)
                second = t->scores[n];
    if (t->best <= 280 && second < t->best + 60) {
        t->ambiguities++;
        t->state = TT_LOST;
        return 1;
    }
    if (t->best > 280) {
        t->misses++;
        t->miss_run++;
        t->state =
            t->miss_run >= 3 && (uint32_t)(t->ms - t->last_good) > TT_LOST_MS ? TT_LOST : TT_HOLD;
        return 1;
    }
    t->x = bound(t->x + ((int)bx - 12) * (int)t->sx, 1919);
    t->y = bound(t->y + ((int)by - 12) * (int)t->sy, 1079);
    t->last_good = t->ms;
    t->state = TT_LOCKED;
    t->miss_run = 0;
    t->observations++;
    tt_expire(t, t->ms);
    // shortcut: 48 measured points cover 3 seconds at the service's <=15Hz acquisition rate.
    if (t->count == TT_POINTS) {
        t->head = (t->head + 1) % TT_POINTS;
        t->count--;
    }
    unsigned n = (t->head + t->count++) % TT_POINTS;
    t->points[n] = (struct tt_point){t->frame, t->ms, t->x, t->y};
    return 1;
}
void tt_sobel(const uint8_t *g, uint64_t *edges, unsigned threshold) {
    for (unsigned y = 0; y < 64; y++) {
        edges[y] = 0;
        if (!y || y == 63)
            continue;
        for (unsigned x = 1; x < 63; x++) {
            unsigned p = y * 64 + x;
            int gx = g[p - 63] + 2 * g[p + 1] + g[p + 65] - g[p - 65] - 2 * g[p - 1] - g[p + 63];
            int gy = g[p + 63] + 2 * g[p + 64] + g[p + 65] - g[p - 65] - 2 * g[p - 64] - g[p - 63];
            if (absolute(gx) + absolute(gy) >= threshold)
                edges[y] |= (uint64_t)1 << x;
        }
    }
}
unsigned tt_roi(const struct target_track *t, unsigned w, unsigned h, unsigned ox, unsigned oy,
                uint32_t *xy) {
    int x = bound(t->x - (int)w / 2, 1920 - w), y = bound(t->y - (int)h / 2, 1080 - h),
        dx = x - (int)ox, dy = y - (int)oy;
    if (absolute(dx) < (t->sx / 2 > 2 ? t->sx / 2 : 2))
        dx = 0;
    if (absolute(dy) < (t->sy / 2 > 2 ? t->sy / 2 : 2))
        dy = 0;
    if (!dx && !dy)
        return 0;
    x = ox + (dx + (dx > 0 ? 1 : -1)) / 2;
    y = oy + (dy + (dy > 0 ? 1 : -1)) / 2;
    *xy = ((unsigned)x << 12) | (unsigned)y;
    return 1;
}
