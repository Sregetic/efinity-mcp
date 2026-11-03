#include "geometry_m7.h"
#ifdef VISION_MULHI_CFU
#include "int8.h"
#endif

/* The input is the accepted Canny bitmap, never RGB or display coverage. */
static struct m7_context default_context;
/* Sapphire shifts serially; bitmap membership uses a tiny constant mask table. */
const uint32_t m7_bit_mask[32] = {
    0x00000001u, 0x00000002u, 0x00000004u, 0x00000008u, 0x00000010u, 0x00000020u, 0x00000040u,
    0x00000080u, 0x00000100u, 0x00000200u, 0x00000400u, 0x00000800u, 0x00001000u, 0x00002000u,
    0x00004000u, 0x00008000u, 0x00010000u, 0x00020000u, 0x00040000u, 0x00080000u, 0x00100000u,
    0x00200000u, 0x00400000u, 0x00800000u, 0x01000000u, 0x02000000u, 0x04000000u, 0x08000000u,
    0x10000000u, 0x20000000u, 0x40000000u, 0x80000000u};
static const int8_t step_x[8] = {1, 1, 0, -1, -1, -1, 0, 1};
static const int8_t step_y[8] = {0, 1, 1, 1, 0, -1, -1, -1};
static const int16_t step_pixel[8] = {1, 481, 480, 479, -1, -481, -480, -479};
struct m7_contour m7_contours[M7_CONTOURS];
unsigned m7_contour_count;
struct m7_box m7_boxes[4];
unsigned m7_count, m7_more, m7_complex;

static unsigned on(struct m7_context *g, int x, int y, unsigned p) {
    if (x < 0 || x >= M7_W || y < 0 || y >= M7_H)
        return 0;
    return !!(g->image[p >> 5] & m7_bit_mask[p & 31]);
}
static int point_x(struct m7_context *g, unsigned n) {
    return g->points[n == g->npoints ? 0 : n] & 511;
}
static int point_y(struct m7_context *g, unsigned n) {
    return g->points[n == g->npoints ? 0 : n] >> 9;
}
static int coordinate_product(int a, int b) {
    if (!a || !b)
        return 0;
#ifdef VISION_MULHI_CFU
    // Coordinate deltas fit signed16: high32((a*65536)*(b*65536)) is exactly a*b.
    int32_t x = (uint32_t)a << 16, y = (uint32_t)b << 16;
    return int8_mulhi(x, y);
#else
    return a * b;
#endif
}
static unsigned norm(int x, int y) {
    return coordinate_product(x, x) + coordinate_product(y, y);
}
static unsigned distance(struct m7_context *g, unsigned a, unsigned b) {
    return norm(point_x(g, a) - point_x(g, b), point_y(g, a) - point_y(g, b));
}
static int absolute(int v) {
    return v < 0 ? -v : v;
}
static unsigned box_area(const struct m7_box *b) {
    return (b->x1 - b->x0 + 1u) * (b->y1 - b->y0 + 1u);
}
void m7_retain(struct m7_box boxes[4], unsigned *count, unsigned *more, struct m7_box b) {
    for (unsigned i = 0; i < (*count); i++) {
        struct m7_box *a = &boxes[i];
        int overlap_x = (a->x1 < b.x1 ? a->x1 : b.x1) - (int)(a->x0 > b.x0 ? a->x0 : b.x0) + 1;
        int overlap_y = (a->y1 < b.y1 ? a->y1 : b.y1) - (int)(a->y0 > b.y0 ? a->y0 : b.y0) + 1;
        /* A recognized printed glyph owns its inner/dotted contour fragments. */
        unsigned a_in_b = a->x0 >= b.x0 && a->y0 >= b.y0 && a->x1 <= b.x1 && a->y1 <= b.y1;
        unsigned b_in_a = b.x0 >= a->x0 && b.y0 >= a->y0 && b.x1 <= a->x1 && b.y1 <= a->y1;
        if (a->klass >= M7_UPPER && b.klass != M7_FACE && b_in_a && box_area(a) > box_area(&b))
            return;
        if (b.klass >= M7_UPPER && a->klass != M7_FACE && a_in_b && box_area(&b) > box_area(a)) {
            for (unsigned j = i; j + 1 < (*count); j++)
                boxes[j] = boxes[j + 1];
            (*count)--;
            i--;
            continue;
        }
        unsigned close = absolute((int)a->x0 - b.x0) <= 3 && absolute((int)a->y0 - b.y0) <= 3 &&
                         absolute((int)a->x1 - b.x1) <= 3 && absolute((int)a->y1 - b.y1) <= 3;
        unsigned face_pair = (a->klass == M7_FACE || b.klass == M7_FACE) && overlap_x > 0 &&
                             overlap_y > 0 &&
                             (unsigned)(overlap_x * overlap_y) * 10 >= box_area(a) * 7 &&
                             (unsigned)(overlap_x * overlap_y) * 10 >= box_area(&b) * 7;
        if (close || face_pair) {
            if (!(b.klass == M7_FACE || (a->klass != M7_FACE && b.area > a->area)))
                return;
            for (unsigned j = i; j + 1 < (*count); j++)
                boxes[j] = boxes[j + 1];
            (*count)--;
            break;
        }
    }
    if ((*count) == 4) {
        (*more) = 1;
        if (b.area <= boxes[3].area)
            return;
    } else
        (*count)++;
    unsigned i = (*count) - 1;
    while (i && boxes[i - 1].area < b.area) {
        boxes[i] = boxes[i - 1];
        i--;
    }
    boxes[i] = b;
}
static void polygon_result(struct m7_context *g) {
    unsigned klass = 0, w = g->xmax - g->xmin + 1, h = g->ymax - g->ymin + 1;
    /* Closed RDP must also simplify the arbitrary first point on an edge. */
    for (unsigned i = 0; i < g->nv && g->nv > 3;) {
        unsigned a = g->polygon[(i + g->nv - 1) % g->nv], b = g->polygon[i],
                 c = g->polygon[(i + 1) % g->nv];
        int dx = point_x(g, c) - point_x(g, a), dy = point_y(g, c) - point_y(g, a);
        int ux = point_x(g, b) - point_x(g, a), uy = point_y(g, b) - point_y(g, a);
        int cross = coordinate_product(dx, uy) - coordinate_product(dy, ux),
            dot = coordinate_product(dx, ux) + coordinate_product(dy, uy);
        unsigned length = distance(g, a, c);
        if (dot >= 0 && (unsigned)dot <= length &&
            (uint64_t)((int64_t)cross * cross) * 65536 <=
                (uint64_t)g->epsilon * g->epsilon * length) {
            for (unsigned j = i; j + 1 < g->nv; j++)
                g->polygon[j] = g->polygon[j + 1];
            g->nv--;
            if (i)
                i--;
        } else
            i++;
    }
    if (g->nv == 4) {
        unsigned good = 1;
        int sign = 0;
        for (unsigned i = 0; i < 4; i++) {
            unsigned a = g->polygon[i], b = g->polygon[(i + 1) & 3], c = g->polygon[(i + 2) & 3];
            int ux = point_x(g, a) - point_x(g, b), uy = point_y(g, a) - point_y(g, b);
            int vx = point_x(g, c) - point_x(g, b), vy = point_y(g, c) - point_y(g, b);
            int cross = coordinate_product(ux, vy) - coordinate_product(uy, vx),
                dot = coordinate_product(ux, vx) + coordinate_product(uy, vy);
            uint64_t lengths = (uint64_t)norm(ux, uy) * norm(vx, vy);
            if (!cross || !lengths || (sign && ((cross > 0) != (sign > 0))))
                good = 0;
            if ((uint64_t)((int64_t)dot * dot) * 100 > lengths * 18)
                good = 0;
            sign = cross;
        }
        if (good)
            klass = M7_RECTANGLE;
    } else if (g->nv >= 6 && g->nv <= 16 && w * 8 >= h * 7 && h * 8 >= w * 7) {
        int cx2 = g->xmin + g->xmax, cy2 = g->ymin + g->ymax, r2 = (w + h - 2) / 2;
        unsigned expected = r2 * r2, tolerance = expected / 4, miss = 0;
        if (tolerance < (unsigned)(4 * r2 + 4))
            tolerance = 4 * r2 + 4;
        for (unsigned i = 0; i < g->npoints; i++) {
            int x = 2 * point_x(g, i) - cx2, y = 2 * point_y(g, i) - cy2;
            if ((unsigned)absolute((int)norm(x, y) - (int)expected) > tolerance)
                miss++;
        }
        if (miss * 10 <= g->npoints)
            klass = M7_CIRCLE;
    }
    if (g->contour_index < M7_CONTOURS)
        g->contours[g->contour_index].klass = klass;
    if (klass)
        m7_retain(
            g->boxes, &g->count, &g->more,
            (struct m7_box){g->xmin, g->ymin, g->xmax, g->ymax, (unsigned)g->area2 / 2, klass});
}
void m7_context_begin(struct m7_context *g, const uint32_t *edges) {
    g->image = edges;
    g->phase = M7_SCAN_SEEDS;
    g->scan = 0;
    g->count = g->more = g->complex = g->contour_count = 0;
    for (unsigned i = 0; i < M7_WORDS; i++)
        g->visited[i] = 0;
}
unsigned m7_context_step(struct m7_context *g, unsigned budget) {
    while (budget--) {
        if (g->phase == M7_SCAN_SEEDS) {
            if (g->scan == M7_W * M7_H) {
                g->phase = M7_CONTOUR_IDLE;
                return 1;
            }
            unsigned p = g->scan++;
            if (!(p & 31) && !g->image[p >> 5]) {
                g->scan = p + 32;
                continue;
            }
            if (!(g->image[p >> 5] & m7_bit_mask[p & 31]) ||
                (g->visited[p >> 5] & m7_bit_mask[p & 31]))
                continue;
#ifdef VISION_MULHI_CFU
            /* ceil(2^32/480), exact for all 129600 input indices. Reuse the installed CFU. */
            unsigned y = (unsigned)int8_mulhi(p, 8947849), x = p - y * M7_W;
#else
            unsigned x = p % M7_W, y = p / M7_W;
#endif
            if (x && (g->image[(p - 1) >> 5] & m7_bit_mask[(p - 1) & 31]))
                continue;
            g->px = g->startx = x;
            g->py = g->starty = y;
            g->back = 4;
            g->first_set = 0;
            g->xmin = g->xmax = x;
            g->ymin = g->ymax = y;
            g->area2 = 0;
            g->npoints = g->perimeter = g->overflow = g->walk_steps = 0;
            g->phase = M7_TRACE_CONTOUR;
        } else if (g->phase == M7_TRACE_CONTOUR) {
            unsigned dir = g->back, k, p = g->py * M7_W + g->px;
            for (k = 0; k < 8; k++, dir = (dir + 1) & 7)
                if (on(g, g->px + step_x[dir], g->py + step_y[dir], p + step_pixel[dir]))
                    break;
            if (k == 8) {
                g->visited[p >> 5] |= m7_bit_mask[p & 31];
                g->phase = M7_SCAN_SEEDS;
                continue;
            }
            int nx = g->px + step_x[dir], ny = g->py + step_y[dir];
            if (g->first_set && g->px == g->startx && g->py == g->starty && nx == g->firstx &&
                ny == g->firsty) {
                g->contour_index = M7_CONTOURS;
                if (!g->overflow && g->npoints >= 2 && (g->xmax > g->xmin || g->ymax > g->ymin)) {
                    if (g->contour_count < M7_CONTOURS) {
                        g->contour_index = g->contour_count++;
                        g->contours[g->contour_index] =
                            (struct m7_contour){g->xmin,
                                                g->ymin,
                                                g->xmax,
                                                g->ymax,
                                                (unsigned)absolute(g->area2),
                                                g->area2 < 0 ? M7_INNER_CONTOUR : 0u,
                                                g->starty * M7_W + g->startx};
                    } else
                        g->complex++; // shortcut: retain 512 contour descriptors; enlarge DDR table
                                      // for denser scenes.
                }
                if (g->overflow || g->npoints < 8 || g->area2 < 32 || g->xmax - g->xmin < 3 ||
                    g->ymax - g->ymin < 3 || g->xmin == 0 || g->ymin == 0 || g->xmax == M7_W - 1 ||
                    g->ymax == M7_H - 1) {
                    g->phase = M7_SCAN_SEEDS;
                    continue;
                }
                g->best_distance = g->best_index = 0;
                g->pi = 1;
                g->phase = M7_FIND_DIAMETER;
                continue;
            }
            if (!g->first_set) {
                g->firstx = nx;
                g->firsty = ny;
                g->first_set = 1;
            }
            unsigned mask = m7_bit_mask[p & 31];
            g->visited[p >> 5] |= mask;
            if (g->npoints < 16384)
                g->points[g->npoints++] = (unsigned)g->px | ((unsigned)g->py << 9);
            else if (!g->overflow) {
                g->overflow = 1;
                g->complex++;
            } // shortcut: reject >16384-point contours; enlarge DDR scratch if needed.
            if ((unsigned)g->px < g->xmin)
                g->xmin = g->px;
            if ((unsigned)g->px > g->xmax)
                g->xmax = g->px;
            if ((unsigned)g->py < g->ymin)
                g->ymin = g->py;
            if ((unsigned)g->py > g->ymax)
                g->ymax = g->py;
            // Unit Moore steps reduce the area determinant to signed coordinate additions.
            int ax = step_y[dir] ? (step_y[dir] > 0 ? g->px : -g->px) : 0;
            int ay = step_x[dir] ? (step_x[dir] > 0 ? g->py : -g->py) : 0;
            g->area2 += ax - ay;
            g->perimeter += (dir & 1) ? 362 : 256;
            g->px = nx;
            g->py = ny;
            g->back = (((dir >> 1) * 2) + 6) & 7;
            /* Eight directed states per pixel bound a Moore traversal. */
            if (++g->walk_steps > 8 * M7_W * M7_H) {
                g->complex++;
                g->phase = M7_SCAN_SEEDS;
            }
        } else if (g->phase == M7_FIND_DIAMETER) {
            unsigned d = distance(g, 0, g->pi);
            if (d > g->best_distance) {
                g->best_distance = d;
                g->best_index = g->pi;
            }
            if (++g->pi == g->npoints) {
                g->polygon[0] = 0;
                g->polygon[1] = g->best_index;
                g->polygon[2] = g->npoints;
                g->nv = 2;
                g->segment = 0;
                g->pi = 1;
                g->best_distance = 0;
                g->epsilon = g->perimeter / 50;
                if (g->epsilon < 128)
                    g->epsilon = 128;
                g->phase = M7_SIMPLIFY_POLYGON;
            }
        } else if (g->phase == M7_SIMPLIFY_POLYGON) {
            unsigned a = g->polygon[g->segment], b = g->polygon[g->segment + 1];
            if (g->pi < b) {
                int dx = point_x(g, b) - point_x(g, a), dy = point_y(g, b) - point_y(g, a);
                int cross = coordinate_product(dx, point_y(g, g->pi) - point_y(g, a)) -
                            coordinate_product(dy, point_x(g, g->pi) - point_x(g, a));
                unsigned v = absolute(cross);
                if (v > g->best_distance) {
                    g->best_distance = v;
                    g->best_index = g->pi;
                }
                g->pi++;
                continue;
            }
            uint64_t lhs = (uint64_t)g->best_distance * g->best_distance * 65536;
            uint64_t rhs = (uint64_t)g->epsilon * g->epsilon * distance(g, a, b);
            if (lhs > rhs) {
                if (g->nv == 64) {
                    g->phase = M7_SCAN_SEEDS;
                    continue;
                }
                for (unsigned i = g->nv + 1; i > g->segment + 1; i--)
                    g->polygon[i] = g->polygon[i - 1];
                g->polygon[g->segment + 1] = g->best_index;
                g->nv++;
            } else
                g->segment++;
            if (g->segment == g->nv) {
                polygon_result(g);
                g->phase = M7_SCAN_SEEDS;
                continue;
            }
            g->pi = g->polygon[g->segment] + 1;
            g->best_distance = 0;
        } else
            return 1;
    }
    return 0;
}

void m7_begin(const uint32_t *edges) {
    m7_context_begin(&default_context, edges);
    m7_count = m7_more = m7_complex = m7_contour_count = 0;
}
unsigned m7_step(unsigned budget) {
    unsigned done = m7_context_step(&default_context, budget);
    if (done) {
        m7_count = default_context.count;
        m7_more = default_context.more;
        m7_complex = default_context.complex;
        m7_contour_count = default_context.contour_count;
        for (unsigned i = 0; i < m7_count; i++)
            m7_boxes[i] = default_context.boxes[i];
        for (unsigned i = 0; i < m7_contour_count; i++)
            m7_contours[i] = default_context.contours[i];
    }
    return done;
}
