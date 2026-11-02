#pragma once
#include <stdint.h>

enum {
    M7_W = 480,
    M7_H = 270,
    M7_WORDS = 4050,
    M7_CIRCLE = 1,
    M7_RECTANGLE = 2,
    M7_FACE = 3,
    M7_UPPER = 4,
    M7_LOWER = 30,
    M7_CASE_PAIR = 56,
    M7_BAR = 82
};
struct m7_box {
    uint16_t x0, y0, x1, y1;
    uint32_t area, klass;
};
enum { M7_CONTOURS = 512, M7_INNER_CONTOUR = 256 };
struct m7_contour {
    uint16_t x0, y0, x1, y1;
    uint32_t area2, klass, seed;
};
/* Independent contour workspaces share one engine; the default API stays below. */
enum m7_contour_phase {
    M7_CONTOUR_IDLE = 0,
    M7_SCAN_SEEDS = 1,
    M7_TRACE_CONTOUR = 2,
    M7_FIND_DIAMETER = 3,
    M7_SIMPLIFY_POLYGON = 4
};
struct m7_context {
    const uint32_t *image;
    uint32_t visited[M7_WORDS], points[16384];
    uint16_t polygon[65];
    unsigned phase, scan, npoints, walk_steps;
    int px, py, startx, starty, firstx, firsty;
    unsigned back, first_set, xmin, ymin, xmax, ymax, perimeter, overflow;
    int32_t area2;
    unsigned nv, segment, pi, best_index, best_distance, epsilon, contour_index;
    struct m7_contour contours[M7_CONTOURS];
    unsigned contour_count;
    struct m7_box boxes[4];
    unsigned count, more, complex;
};
void m7_context_begin(struct m7_context *work, const uint32_t *edges);
unsigned m7_context_step(struct m7_context *work, unsigned budget);
extern struct m7_contour m7_contours[M7_CONTOURS];
extern unsigned m7_contour_count;
extern const uint32_t m7_bit_mask[32];
extern struct m7_box m7_boxes[4];
extern unsigned m7_count, m7_more, m7_complex;
void m7_begin(const uint32_t *edges);
unsigned m7_step(unsigned budget);
void m7_retain(struct m7_box boxes[4], unsigned *count, unsigned *more, struct m7_box box);

static inline unsigned m7_symbol(unsigned k) {
    return k >= M7_CASE_PAIR ? 63
           : k >= M7_LOWER   ? 97 + k - M7_LOWER
           : k >= M7_UPPER   ? 65 + k - M7_UPPER
                             : 0;
}
