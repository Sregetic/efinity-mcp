#include "geometry_letters.h"
#include "geometry_letter_templates.h"
#ifdef VISION_MULHI_CFU
#include "int8.h"
#endif

/* Share the current contour job's bitmap; the service does not replace it until done. */
enum letter_phase {
    LETTERS_DONE = 0,
    LETTERS_BUILD_CANDIDATES = 1,
    LETTERS_PREPARE_GLYPH = 2,
    LETTERS_RASTERIZE_POSE = 3,
    LETTERS_SCORE_COARSE = 4,
    LETTERS_RESOLVE_CASE = 5,
    LETTERS_PUBLISH = 7,
    LETTERS_PROPOSE_FRAGMENTS = 8,
    LETTERS_PREPARE_POSE = 9,
    LETTERS_MEASURE_POSE = 10,
    LETTERS_CHOOSE_CLASS = 11,
    LETTERS_SCORE_FINE = 14,
    LETTERS_GATHER_GLYPH = 15,
    LETTERS_LINK_FRAGMENTS = 16,
    LETTERS_BUILD_FRAGMENT_GROUPS = 17,
    LETTERS_SEED_COMPONENTS = 19,
    LETTERS_FLOOD_COMPONENT = 20,
    LETTERS_BUILD_CONTOUR_GROUPS = 21,
    LETTERS_REFIT_ROW = 23
};
static const uint32_t *image;
struct candidate {
    struct m7_box box;
    uint16_t reference, other_case, score, other_score, fit_height, bar_width, fit_score, searched;
    uint8_t accepted, paired, dotted, pose, geometric_bar, bar_dot, dense, outline;
};
static struct candidate candidates[M7_CONTOURS];
static struct candidate prior;
static unsigned row_refined, refitting, refit_angle;
static uint32_t members[M7_CONTOURS][M7_CONTOURS / 32], visited[M7_WORDS];
static uint16_t component[M7_W * M7_H], contour_component[M7_CONTOURS];
static uint16_t parent[M7_CONTOURS];
static unsigned initial_count, seed_index, point_overflow, component_count, scan_x, scan_y,
    have_text, direction_pose;
static unsigned root(unsigned n) {
    while (parent[n] != n) {
        parent[n] = parent[parent[n]];
        n = parent[n];
    }
    return n;
}
static unsigned count, phase, index, reference, aspect, pixels, pose, group_i, group_j, group_count,
    proposals, base_count;
static uint16_t scores[52], references[52];
static uint8_t poses[52];
static uint32_t rows[M7_LETTER_WORDS], near[M7_LETTER_WORDS];
static uint32_t fine[32], fine_near[32];
static unsigned verifying, best_letter, fine_score, fine_reference, verify_pose, verify_try,
    fine_bound;
enum { GLYPH_POINTS = 16384, FINE_LIMIT = 170 };
static uint32_t points[GLYPH_POINTS];
static unsigned point_count, point_index;
static int16_t xcos[M7_W], xsin[M7_W], row_cos[M7_H], row_sin[M7_H];
static int xmin, xmax, ymin, ymax, cosine, sine;
static unsigned xscale, yscale;
/* Q6 rotations cover +/-24 degrees in six-degree steps, with no floating point. */
static const int8_t rotations[9][2] = {{64, 0},  {63, -13}, {63, 13},  {58, -26}, {58, 26},
                                       {64, -7}, {64, 7},   {61, -20}, {61, 20}};
static const int8_t refine_poses[9][2] = {{5, 6}, {7, 5}, {8, 6}, {7, -1}, {8, -1},
                                          {1, 0}, {2, 0}, {3, 1}, {4, 2}};
static unsigned cell(unsigned v, unsigned reciprocal) {
#ifdef VISION_MULHI_CFU
    return (unsigned)int8_mulhi(v << 8, reciprocal);
#else
    return (uint64_t)v * reciprocal >> 24;
#endif
}
static void enqueue(unsigned xx, unsigned yy) {
    unsigned p = yy * M7_W + xx, mask = m7_bit_mask[p & 31];
    if (!(image[p >> 5] & mask) || (visited[p >> 5] & mask))
        return;
    // shortcut: match the contour engine's16384-point limit; denser components are rejected, never
    // truncated.
    if (point_count == GLYPH_POINTS) {
        point_overflow = 1;
        return;
    }
    visited[p >> 5] |= mask;
    component[p] = component_count - 1;
    points[point_count++] = xx | (yy << 9);
}
static void accumulate(unsigned local, int cy, int sy) {
    int xx = xcos[local] + sy, yy = cy - xsin[local];
    if (phase == LETTERS_MEASURE_POSE) {
        if (xx < xmin)
            xmin = xx;
        if (xx > xmax)
            xmax = xx;
        if (yy < ymin)
            ymin = yy;
        if (yy > ymax)
            ymax = yy;
    } else {
        unsigned row = cell(yy - ymin, yscale), col = cell(xx - xmin, xscale);
        if (verifying)
            fine[row] |= m7_bit_mask[col];
        else
            rows[row >> 1] |= m7_bit_mask[col + ((row & 1) << 4)];
    }
}
static unsigned absdiff(unsigned a, unsigned b) {
    return a > b ? a - b : b - a;
}
static unsigned pop(unsigned v) {
    v = v - ((v >> 1) & 0x55555555u);
    v = (v & 0x33333333u) + ((v >> 2) & 0x33333333u);
    v = (v + (v >> 4)) & 0x0f0f0f0fu;
    v += v >> 8;
    v += v >> 16;
    return v & 63;
}
static unsigned height(const struct m7_box *b) {
    return b->y1 - b->y0 + 1;
}
static unsigned same_line(const struct m7_box *a, const struct m7_box *b) {
    unsigned h = height(a), k = height(b);
    if (k > h)
        h = k;
    if (absdiff(a->x0, b->x0) >= 8 * h)
        return 0;
    /* This is only an early exclusion; accepted anchors use their fitted text axis. */
    for (unsigned p = 0; p < 9; p++) {
        int d = rotations[p][0] * ((int)a->y0 + a->y1 - b->y0 - b->y1) -
                rotations[p][1] * ((int)a->x0 + a->x1 - b->x0 - b->x1);
        if ((unsigned)(d < 0 ? -d : d) <= h * 64)
            return 1;
    }
    return 0;
}
static int text_base(const struct candidate *c, unsigned angle) {
    const struct m7_box *b = &c->box;
    return (rotations[angle][0] * (b->y0 + b->y1) - rotations[angle][1] * (b->x0 + b->x1) +
            c->fit_height) /
           2;
}
static unsigned text_line(const struct candidate *a, const struct candidate *b) {
    int delta = text_base(a, b->pose) - text_base(b, b->pose);
    unsigned h = a->fit_height > b->fit_height ? a->fit_height : b->fit_height;
    return (unsigned)(delta < 0 ? -delta : delta) * 2 <= h &&
           absdiff(a->box.x0, b->box.x0) * 64 < 8 * h;
}
static unsigned row_anchor(const struct m7_box *b, unsigned limit, unsigned excluded) {
    unsigned anchor = M7_CONTOURS, best = 65536;
    for (unsigned n = 0; n < limit; n++) {
        const struct candidate *c = &candidates[n];
        if (n == excluded || !c->accepted || c->geometric_bar || c->paired || c->fit_score >= best)
            continue;
        unsigned h = height(b) * 64;
        if (h * 3 < c->fit_height || h > c->fit_height * 2)
            continue;
        int base = (rotations[c->pose][0] * (b->y0 + b->y1) -
                    rotations[c->pose][1] * (b->x0 + b->x1) + (int)h) /
                   2;
        int delta = base - text_base(c, c->pose);
        if ((unsigned)(delta < 0 ? -delta : delta) * 2 < c->fit_height) {
            best = c->fit_score;
            anchor = n;
        }
    }
    return anchor;
}
static unsigned partial_j(void) {
    if (best_letter != 35)
        return 0;
    for (unsigned n = 1; n < 11; n++)
        if (!fine[n])
            return 0;
    unsigned n = row_anchor(&candidates[index].box, count, index);
    if (n == M7_CONTOURS)
        return 0;
    const struct candidate *a = &candidates[n];
    if (a->pose != pose)
        return 0;
    const struct m7_letter_template *t = &m7_letter_templates[candidates[index].reference],
                                    *at = &m7_letter_templates[a->reference];
    unsigned cap = a->fit_height * 100 / at->cap_height;
    const struct m7_box *b = &candidates[index].box;
    int base = (rotations[pose][0] * (b->y0 + b->y1) - rotations[pose][1] * (b->x0 + b->x1) +
                (ymax - ymin + 64)) /
               2;
    int line = text_base(a, pose) - at->baseline * (int)cap / 100,
        delta = (base - line) * 100 - t->baseline * (int)cap;
    return (unsigned)(delta < 0 ? -delta : delta) <= 15 * cap;
}
static void next_candidate(void) {
    if (refitting) {
        if (!candidates[index].accepted)
            candidates[index] = prior;
        candidates[index].searched |= m7_bit_mask[refit_angle];
        refitting = 0;
        index++;
        phase = LETTERS_REFIT_ROW;
    } else {
        index++;
        phase = LETTERS_PREPARE_GLYPH;
    }
}
void m7_letters_begin(const uint32_t *edges) {
    image = edges;
    count = 0;
    index = 0;
    phase = LETTERS_SEED_COMPONENTS;
    group_count = 0;
    proposals = 0;
    m7_count = m7_more = 0;
    component_count = seed_index = 0;
    for (unsigned n = 0; n < M7_WORDS; n++)
        visited[n] = 0;
    row_refined = refitting = 0;
}
unsigned m7_letters_step(unsigned budget) {
    while (budget--) {
        if (phase == LETTERS_SEED_COMPONENTS) {
            if (seed_index == m7_contour_count) {
                seed_index = 0;
                phase = LETTERS_BUILD_CONTOUR_GROUPS;
                continue;
            }
            unsigned n = seed_index++, p = m7_contours[n].seed;
            if (visited[p >> 5] & m7_bit_mask[p & 31])
                contour_component[n] = component[p];
            else {
                component_count++;
                contour_component[n] = component_count - 1;
                point_count = point_index = point_overflow = 0;
                enqueue(p % M7_W, p / M7_W);
                phase = LETTERS_FLOOD_COMPONENT;
            }
        } else if (phase == LETTERS_FLOOD_COMPONENT) {
            for (unsigned n = 0; n < 32 && point_index < point_count && !point_overflow;
                 n++, point_index++) {
                unsigned p = points[point_index];
                int xx = p & 511, yy = p >> 9;
                for (int dy = -1; dy <= 1; dy++)
                    for (int dx = -1; dx <= 1; dx++)
                        if ((dx || dy) && xx + dx >= 0 && xx + dx < M7_W && yy + dy >= 0 &&
                            yy + dy < M7_H)
                            enqueue(xx + dx, yy + dy);
            }
            if (point_overflow) {
                m7_complex++;
                count = index = 0;
                phase = LETTERS_PUBLISH;
            } else if (point_index == point_count)
                phase = LETTERS_SEED_COMPONENTS;
        } else if (phase == LETTERS_BUILD_CONTOUR_GROUPS) {
            if (seed_index == m7_contour_count) {
                index = 0;
                phase = LETTERS_BUILD_CANDIDATES;
                continue;
            }
            unsigned n = seed_index++;
            const struct m7_contour *c = m7_contours + n;
            if (c->klass == M7_INNER_CONTOUR || c->y1 - c->y0 < 7)
                continue;
            unsigned k = group_count++, id = contour_component[n];
            candidates[k] = (struct candidate){.box = {c->x0, c->y0, c->x1, c->y1, 0, c->klass},
                                               .outline = c->area2 != 0};
            for (unsigned j = 0; j < M7_CONTOURS / 32; j++)
                members[k][j] = 0;
            members[k][id >> 5] |= m7_bit_mask[id & 31];
        } else if (phase == LETTERS_BUILD_CANDIDATES) {
            if (index == group_count) {
                initial_count = count;
                for (unsigned j = 0; j < count; j++)
                    parent[j] = j;
                group_i = 1;
                group_j = 0;
                phase = LETTERS_LINK_FRAGMENTS;
                continue;
            }
            unsigned n = index++;
            struct m7_box initial = candidates[n].box;
            const struct m7_box *c = &initial;
            unsigned outline = candidates[n].outline;
            unsigned w = c->x1 - c->x0 + 1, h = c->y1 - c->y0 + 1;
            if (w * 4 > h * 7)
                continue;
            struct m7_box b = {c->x0, c->y0, c->x1, c->y1, w * h, c->klass};
            /* Dotted i/j have a detached, narrow component immediately above the stem. */
            if (w * 2 < h)
                for (unsigned j = 0; j < m7_contour_count; j++) {
                    const struct m7_contour *d = &m7_contours[j];
                    unsigned dw = d->x1 - d->x0 + 1, dh = d->y1 - d->y0 + 1;
                    if (d->klass != M7_INNER_CONTOUR && d->y1 < c->y0 && c->y0 - d->y1 <= h / 3 &&
                        dw <= h / 3 && dh <= h / 3 &&
                        absdiff(d->x0 + d->x1, c->x0 + c->x1) <= (w > h / 3 ? w : h / 3)) {
                        b.y0 = d->y0;
                        if (d->x0 < b.x0)
                            b.x0 = d->x0;
                        if (d->x1 > b.x1)
                            b.x1 = d->x1;
                        break;
                    }
                }
            /* Include detached serif tips within two input cells of the traced contour. */
            unsigned x0 = b.x0 > 2 ? b.x0 - 2 : 0, y0 = b.y0 > 2 ? b.y0 - 2 : 0,
                     x1 = b.x1 + 2 < M7_W ? b.x1 + 2 : M7_W - 1,
                     y1 = b.y1 + 2 < M7_H ? b.y1 + 2 : M7_H - 1;
            unsigned oldx0 = b.x0, oldy0 = b.y0, oldx1 = b.x1, oldy1 = b.y1;
            for (unsigned yy = y0; yy <= y1; yy++)
                for (unsigned xx = x0; xx <= x1; xx++) {
                    if (xx >= oldx0 && xx <= oldx1 && yy >= oldy0 && yy <= oldy1) {
                        xx = oldx1;
                        continue;
                    }
                    unsigned p = yy * M7_W + xx;
                    if (!(image[p >> 5] & m7_bit_mask[p & 31]))
                        continue;
                    if (xx < b.x0)
                        b.x0 = xx;
                    if (xx > b.x1)
                        b.x1 = xx;
                    if (yy < b.y0)
                        b.y0 = yy;
                    if (yy > b.y1)
                        b.y1 = yy;
                }
            unsigned duplicate = 0;
            for (unsigned j = 0; j < count; j++) {
                const struct m7_box *a = &candidates[j].box;
                if (absdiff(a->x0, b.x0) <= 2 && absdiff(a->y0, b.y0) <= 2 &&
                    absdiff(a->x1, b.x1) <= 2 && absdiff(a->y1, b.y1) <= 2) {
                    duplicate = 1;
                    break;
                }
            }
            if (!duplicate) {
                unsigned dotted = b.y0 + 2 < c->y0;
                if (dotted)
                    b.klass = 0;
                for (unsigned j = 0; j < M7_CONTOURS / 32; j++)
                    members[count][j] = members[n][j];
                for (unsigned j = 0; j < m7_contour_count; j++) {
                    const struct m7_contour *d = m7_contours + j;
                    if (d->x0 >= b.x0 && d->y0 >= b.y0 && d->x1 <= b.x1 && d->y1 <= b.y1) {
                        unsigned id = contour_component[j];
                        members[count][id >> 5] |= m7_bit_mask[id & 31];
                    }
                }
                candidates[count++] =
                    (struct candidate){.box = b, .dotted = dotted, .outline = outline};
            }
        } else if (phase == LETTERS_LINK_FRAGMENTS) {
            if (group_i >= initial_count) {
                index = 0;
                phase = LETTERS_BUILD_FRAGMENT_GROUPS;
                continue;
            }
            const struct m7_box *a = &candidates[group_i].box, *b = &candidates[group_j].box;
            unsigned contained =
                (a->x0 >= b->x0 && a->y0 >= b->y0 && a->x1 <= b->x1 && a->y1 <= b->y1) ||
                (b->x0 >= a->x0 && b->y0 >= a->y0 && b->x1 <= a->x1 && b->y1 <= a->y1);
            if (!contained && a->x0 <= b->x1 + 3 && b->x0 <= a->x1 + 3 && a->y0 <= b->y1 + 3 &&
                b->y0 <= a->y1 + 3) {
                unsigned ar = root(group_i), br = root(group_j);
                if (ar != br)
                    parent[br] = ar;
            }
            if (++group_j == group_i) {
                group_i++;
                group_j = 0;
            }
        } else if (phase == LETTERS_BUILD_FRAGMENT_GROUPS) {
            if (index == initial_count) {
                index = 0;
                phase = LETTERS_PREPARE_GLYPH;
                continue;
            }
            unsigned n = index++;
            if (root(n) != n)
                continue;
            struct m7_box b = candidates[n].box;
            unsigned joined = 0;
            uint32_t mask[M7_CONTOURS / 32] = {0};
            for (unsigned j = 0; j < initial_count; j++)
                if (root(j) == n) {
                    const struct m7_box *a = &candidates[j].box;
                    joined++;
                    if (a->x0 < b.x0)
                        b.x0 = a->x0;
                    if (a->y0 < b.y0)
                        b.y0 = a->y0;
                    if (a->x1 > b.x1)
                        b.x1 = a->x1;
                    if (a->y1 > b.y1)
                        b.y1 = a->y1;
                    for (unsigned k = 0; k < M7_CONTOURS / 32; k++)
                        mask[k] |= members[j][k];
                }
            if (joined > 1) {
                if (count < M7_CONTOURS) {
                    b.klass = 0;
                    candidates[count] = (struct candidate){.box = b, .outline = 1};
                    for (unsigned k = 0; k < M7_CONTOURS / 32; k++)
                        members[count][k] = mask[k];
                    count++;
                } else
                    m7_complex++;
            }
        } else if (phase == LETTERS_PREPARE_GLYPH) {
            if (index == count) {
                if (!proposals && !row_refined) {
                    base_count = count;
                    row_refined = 1;
                    index = 0;
                    phase = LETTERS_REFIT_ROW;
                } else {
                    index = 0;
                    phase = LETTERS_RESOLVE_CASE;
                }
                continue;
            }
            const struct m7_box *b = &candidates[index].box;
            if (b->klass == M7_CIRCLE || b->klass == M7_RECTANGLE) {
                unsigned anchor = 0;
                for (unsigned n = 0; n < count; n++)
                    if (n != index && !candidates[n].box.klass &&
                        same_line(b, &candidates[n].box)) {
                        anchor = 1;
                        break;
                    }
                if (!anchor) {
                    next_candidate();
                    continue;
                }
            }
            for (unsigned n = 0; n < 52; n++)
                scores[n] = 65535;
            if (refitting && prior.accepted && !prior.geometric_bar) {
                unsigned letter = m7_letter_templates[prior.reference].letter;
                scores[letter] = prior.score;
                references[letter] = prior.reference;
                poses[letter] = prior.pose;
                if (prior.paired == 1) {
                    unsigned other = (letter + 26) % 52;
                    scores[other] = prior.other_score;
                    references[other] = prior.other_case;
                    poses[other] = prior.pose;
                }
            }
            unsigned w = b->x1 - b->x0, h = b->y1 - b->y0;
            xscale = w ? ((31u << 24) + w - 1) / w : 0;
            yscale = ((31u << 24) + h - 1) / h;
            for (unsigned n = 0; n <= w; n++)
                xcos[n] = cell(n, xscale);
            for (unsigned n = 0; n < 32; n++)
                fine[n] = 0;
            point_count = point_index = point_overflow = 0;
            scan_x = b->x0;
            scan_y = b->y0;
            phase = LETTERS_GATHER_GLYPH;
        } else if (phase == LETTERS_GATHER_GLYPH) {
            const struct m7_box *b = &candidates[index].box;
            unsigned p = scan_y * M7_W + scan_x, end = (scan_x | 31) + 1;
            if (end > b->x1 + 1u)
                end = b->x1 + 1u;
            uint32_t bits = image[p >> 5] & visited[p >> 5] & ~(m7_bit_mask[p & 31] - 1u),
                     last = m7_bit_mask[(end - 1) & 31];
            bits &= last | (last - 1u);
            if (bits) {
                unsigned base = scan_x & ~31u, row = cell(scan_y - b->y0, yscale);
                do {
                    unsigned bit = __builtin_ctz(bits), xx = base + bit,
                             absolute = scan_y * M7_W + xx, id = component[absolute];
                    if (members[index][id >> 5] & m7_bit_mask[id & 31]) {
                        fine[row] |= m7_bit_mask[xcos[xx - b->x0]];
                        if (point_count < GLYPH_POINTS)
                            points[point_count++] = (xx - b->x0) | ((scan_y - b->y0) << 9);
                        else
                            point_overflow = 1;
                    }
                    bits &= bits - 1;
                } while (bits);
            }
            scan_x = end;
            if (scan_x > b->x1) {
                scan_x = b->x0;
                if (++scan_y > b->y1) {
                    unsigned density = 0;
                    for (unsigned n = 0; n < 32; n++)
                        density += pop(fine[n]);
                    /* Printed outlines allow 50% beyond reference density, not dense scene texture.
                     */
                    if (point_overflow) {
                        m7_complex++;
                        next_candidate();
                    } else if (density > M7_LETTER_MAX_DENSITY) {
                        candidates[index].dense = 1;
                        next_candidate();
                    } else {
                        direction_pose = 9;
                        if (b->x1 - b->x0 < b->y1 - b->y0) {
                            unsigned sx[2] = {0}, sy[2] = {0}, amount[2] = {0}, h = height(b);
                            for (unsigned n = 0; n < point_count; n++) {
                                unsigned p = points[n], yy = p >> 9;
                                if (yy * 2 >= h)
                                    continue;
                                unsigned half = yy * 4 >= h;
                                sx[half] += p & 511;
                                sy[half] += yy;
                                amount[half]++;
                            }
                            if (amount[0] && amount[1]) {
                                int vx = (int)((sx[0] << 8) / amount[0]) -
                                         (int)((sx[1] << 8) / amount[1]);
                                int vy = (int)((sy[1] << 8) / amount[1]) -
                                         (int)((sy[0] << 8) / amount[0]);
                                unsigned best = 0xffffffffu;
                                for (unsigned n = 0; n < 9; n++) {
                                    int e = vx * rotations[n][0] - vy * rotations[n][1];
                                    unsigned d = e < 0 ? -e : e;
                                    if (d < best) {
                                        best = d;
                                        direction_pose = n;
                                    }
                                }
                            }
                        }
                        pose = verifying = 0;
                        phase = LETTERS_PREPARE_POSE;
                    }
                }
            }
        } else if (phase == LETTERS_PREPARE_POSE) {
            unsigned wanted = refitting ? pose == refit_angle
                              : !candidates[index].outline
                                  ? pose == direction_pose
                                  : pose == 0 || pose == 7 || pose == 8 || pose == direction_pose;
            if (!verifying && !wanted) {
                pose++;
                phase = pose < 9 ? LETTERS_PREPARE_POSE : LETTERS_CHOOSE_CLASS;
                continue;
            }
            const struct m7_box *b = &candidates[index].box;
            unsigned w = b->x1 - b->x0 + 1;
            cosine = rotations[pose][0];
            sine = rotations[pose][1];
            int cx = 0, sx = 0;
            for (unsigned n = 0; n < w; n++) {
                xcos[n] = cx;
                xsin[n] = sx;
                cx += cosine;
                sx += sine;
            }
            cx = sx = 0;
            for (unsigned n = 0; n < height(b); n++) {
                row_cos[n] = cx;
                row_sin[n] = sx;
                cx += cosine;
                sx += sine;
            }
            xmin = ymin = 65536;
            xmax = ymax = -65536;
            point_index = 0;
            phase = LETTERS_MEASURE_POSE;
        } else if (phase == LETTERS_RASTERIZE_POSE || phase == LETTERS_MEASURE_POSE) {
            const struct m7_box *b = &candidates[index].box;
            for (unsigned n = 0; n < 32 && point_index < point_count; n++, point_index++) {
                unsigned p = points[point_index];
                accumulate(p & 511, row_cos[p >> 9], row_sin[p >> 9]);
            }
            if (point_index == point_count) {
                if (phase == LETTERS_MEASURE_POSE) {
                    unsigned dx = xmax - xmin, dy = ymax - ymin;
                    struct candidate *c = &candidates[index];
                    if (!verifying && dy >= 14 * 64 && dx * 5 <= dy &&
                        point_count * 64 <= 3 * dy + 16 * 64 &&
                        (!c->geometric_bar || dx * c->fit_height < c->bar_width * dy)) {
                        c->geometric_bar = 1;
                        c->bar_width = dx;
                        c->fit_height = dy + 64;
                        c->pose = pose;
                    }
                    if (xmax == xmin || ymax == ymin) {
                        if (verifying) {
                            fine_bound = FINE_LIMIT;
                            fine_score = fine_bound + 1;
                            reference = M7_LETTER_TEMPLATES / 52;
                            phase = LETTERS_SCORE_FINE;
                        } else {
                            pose++;
                            phase = pose < 9 ? LETTERS_PREPARE_POSE : LETTERS_CHOOSE_CLASS;
                        }
                        continue;
                    }
                    unsigned span = verifying ? 31 : 15;
                    xscale = ((span << 24) + dx - 1) / dx;
                    yscale = ((span << 24) + dy - 1) / dy;
                    aspect = dx * 100 / dy;
                    for (unsigned n = 0; n < M7_LETTER_WORDS; n++)
                        rows[n] = 0;
                    if (verifying)
                        for (unsigned n = 0; n < 32; n++)
                            fine[n] = 0;
                    point_index = 0;
                    phase = LETTERS_RASTERIZE_POSE;
                } else {
                    pixels = 0;
                    if (verifying) {
                        for (unsigned n = 0; n < 32; n++) {
                            pixels += pop(fine[n]);
                            unsigned v =
                                fine[n] | (n ? fine[n - 1] : 0) | (n < 31 ? fine[n + 1] : 0);
                            fine_near[n] = v | (v << 1) | (v >> 1);
                        }
                        /* Canny may remove j's dot; its hooked stem still needs the row's descender
                         * geometry. */
                        fine_bound = partial_j() ? 200 : FINE_LIMIT;
                        fine_score = fine_bound + 1;
                        reference = 0;
                        phase = LETTERS_SCORE_FINE;
                    } else {
                        struct candidate *c = &candidates[index];
                        if (c->geometric_bar && c->pose == pose) {
                            c->bar_dot = 0;
                            for (unsigned n = 1; n < 15; n++)
                                if (!((rows[n >> 1] >> ((n & 1) << 4)) & 65535))
                                    c->bar_dot = 1;
                        }
                        for (unsigned n = 0; n < M7_LETTER_WORDS; n++) {
                            uint32_t r = rows[n],
                                     v = r | (r << 16) | (r >> 16) | (n ? rows[n - 1] >> 16 : 0) |
                                         (n + 1 < M7_LETTER_WORDS ? rows[n + 1] << 16 : 0);
                            pixels += pop(r);
                            near[n] = v | ((v << 1) & 0xfffefffeu) | ((v >> 1) & 0x7fff7fffu);
                        }
                        /* Three coarse orientations plus one measured stem axis, then same-class
                         * refinement. */
                        if (!candidates[index].outline && !refitting) {
                            pose++;
                            phase = pose < 9 ? LETTERS_PREPARE_POSE : LETTERS_CHOOSE_CLASS;
                        } else {
                            candidates[index].searched |= m7_bit_mask[pose];
                            reference = 0;
                            phase = LETTERS_SCORE_COARSE;
                        }
                    }
                }
            }
        } else if (phase == LETTERS_SCORE_COARSE) {
            if (reference < M7_COARSE_TEMPLATES) {
                unsigned ti = m7_coarse_templates[reference++];
                const struct m7_letter_template *t = &m7_letter_templates[ti];
                if (candidates[index].dotted && t->letter != 34 && t->letter != 35)
                    continue;
                unsigned da = absdiff(aspect, t->aspect);
                if (da * 2 > (aspect > t->aspect ? aspect : t->aspect))
                    continue;
                unsigned distance = 0, total = pixels + t->count,
                         limit = (scores[t->letter] < 101 ? scores[t->letter] : 101) * total;
                /* Stop when the nonnegative distance cannot improve this class or pass acceptance.
                 */
                for (unsigned n = 0; n < M7_LETTER_WORDS && distance < limit; n++) {
                    distance += (pop(rows[n] & ~t->near[n]) + pop(t->edge[n] & ~near[n])) * 1000 +
                                pop(rows[n] ^ t->edge[n]) * 100;
                }
                if (distance < limit) {
                    scores[t->letter] = distance / total;
                    references[t->letter] = ti;
                    poses[t->letter] = pose;
                }
            } else {
                pose++;
                phase = pose < 9 ? LETTERS_PREPARE_POSE : LETTERS_CHOOSE_CLASS;
            }
        } else if (phase == LETTERS_CHOOSE_CLASS) {
            unsigned best = 0;
            for (unsigned n = 1; n < 52; n++)
                if (scores[n] < scores[best])
                    best = n;
            unsigned bar = (best == 8 || best == 37) && !candidates[index].dotted;
            struct candidate *c = &candidates[index];
            unsigned other = (best + 26) % 52;
            c->reference = references[best];
            c->score = scores[best];
            if (scores[best] <= 100 && best != 8 && best != 37)
                c->geometric_bar = 0;
            if (c->geometric_bar) {
                c->accepted = 1;
                c->paired = 2;
                c->reference = 8;
                next_candidate();
            } else if (scores[best] <= 100) {
                unsigned family = best % 26, similar = family == 2 || family == 9 || family == 14 ||
                                                       family == 18 || family == 20 ||
                                                       family == 21 || family == 22 ||
                                                       family == 23 || family == 25;
                c->paired =
                    bar ? 2 : !c->dotted && scores[other] <= scores[best] + (similar ? 80 : 20);
                if (c->paired == 1) {
                    c->other_case = references[other];
                    c->other_score = scores[other];
                }
                best_letter = best;
                verifying = 1;
                pose = verify_pose = poses[best];
                verify_try = 0;
                phase = LETTERS_PREPARE_POSE;
            } else
                next_candidate();
        } else if (phase == LETTERS_SCORE_FINE) {
            if (reference < M7_LETTER_TEMPLATES / 52) {
                unsigned ti = best_letter + 52 * reference++;
                const struct m7_letter_template *t = &m7_letter_templates[ti];
                unsigned total = pixels + t->fine_count, distance = 0, limit = fine_score * total;
                for (unsigned n = 0; n < 32 && distance < limit; n++) {
                    unsigned v =
                        t->fine[n] | (n ? t->fine[n - 1] : 0) | (n < 31 ? t->fine[n + 1] : 0);
                    v |= (v << 1) | (v >> 1);
                    distance += (pop(fine[n] & ~v) + pop(t->fine[n] & ~fine_near[n])) * 1000 +
                                pop(fine[n] ^ t->fine[n]) * 100;
                }
                if (distance < limit) {
                    fine_score = distance / total;
                    fine_reference = ti;
                }
            } else {
                if (fine_score <= fine_bound) {
                    candidates[index].accepted = 1;
                    candidates[index].reference = fine_reference;
                    candidates[index].pose = pose;
                    candidates[index].fit_height = ymax - ymin + 64;
                    candidates[index].fit_score = fine_score;
                    next_candidate();
                }
                /* Coarse16 can alias adjacent poses; fine32 checks only the winning class. */
                else if (verify_try < 2 && refine_poses[verify_pose][verify_try] >= 0) {
                    pose = refine_poses[verify_pose][verify_try++];
                    phase = LETTERS_PREPARE_POSE;
                } else
                    next_candidate();
            }
        } else if (phase == LETTERS_REFIT_ROW) {
            if (index == count) {
                have_text = 0;
                for (unsigned n = 0; n < count; n++)
                    if (candidates[n].accepted && !candidates[n].geometric_bar)
                        have_text = 1;
                group_i = 1;
                group_j = 0;
                phase = LETTERS_PROPOSE_FRAGMENTS;
                continue;
            }
            struct candidate *c = &candidates[index];
            unsigned anchor = row_anchor(&c->box, count, index),
                     angle = anchor == M7_CONTOURS ? 9 : candidates[anchor].pose;
            if (c->dense || angle == 9 || (c->searched & m7_bit_mask[angle])) {
                index++;
                continue;
            }
            prior = *c;
            refitting = 1;
            refit_angle = angle;
            c->accepted = c->paired = c->geometric_bar = c->bar_dot = 0;
            phase = LETTERS_PREPARE_GLYPH;
        } else if (phase == LETTERS_RESOLVE_CASE) {
            if (index == count) {
                index = 0;
                phase = LETTERS_PUBLISH;
                continue;
            }
            struct candidate *c = &candidates[index++];
            if (!c->accepted)
                continue;
            const struct m7_letter_template *t = &m7_letter_templates[c->reference];
            unsigned caps = 0, anchors = 0, text_pose = c->pose;
            int bases = 0;
            for (unsigned j = 0; j < count; j++)
                if (candidates + j != c && candidates[j].accepted && !candidates[j].paired &&
                    text_line(c, candidates + j)) {
                    const struct m7_letter_template *at =
                        &m7_letter_templates[candidates[j].reference];
                    if (!anchors)
                        text_pose = candidates[j].pose;
                    unsigned cap = candidates[j].fit_height * 100 / at->cap_height;
                    caps += cap;
                    bases += text_base(candidates + j, text_pose) - at->baseline * (int)cap / 100;
                    anchors++;
                }
            // shortcut: a ring/bar alone also denotes a circle/rectangle; text-row context is
            // required to relabel it.
            if ((c->geometric_bar || t->letter % 26 == 14 || c->box.klass == M7_CIRCLE ||
                 c->box.klass == M7_RECTANGLE) &&
                !anchors)
                continue;
            unsigned letter = t->letter;
            if (c->geometric_bar && c->bar_dot)
                c->box.klass = M7_LOWER + 8;
            else if (c->paired == 2) {
                if (anchors && c->fit_height * 100 / (caps / anchors) < 85)
                    c->box.klass = M7_LOWER + 8;
                else if (c->geometric_bar || c->box.klass == M7_RECTANGLE)
                    c->box.klass = M7_BAR;
                else
                    c->box.klass = M7_UPPER + letter;
            } else if (c->paired) {
                unsigned resolved = 0;
                if (anchors) {
                    unsigned cap = caps / anchors, ratio = c->fit_height * 100 / cap;
                    int baseline =
                        (text_base(c, text_pose) - bases / (int)anchors) * 100 / (int)cap;
                    const struct m7_letter_template *ot = &m7_letter_templates[c->other_case];
                    int da = baseline - t->baseline, db = baseline - ot->baseline;
                    unsigned a =
                        c->score + 4 * absdiff(ratio, t->cap_height) + 4 * (da < 0 ? -da : da);
                    unsigned b = c->other_score + 4 * absdiff(ratio, ot->cap_height) +
                                 4 * (db < 0 ? -db : db);
                    if (absdiff(a, b) > 12) {
                        if (b < a)
                            letter = (letter + 26) % 52;
                        resolved = 1;
                    }
                }
                c->box.klass = resolved ? M7_UPPER + letter : M7_CASE_PAIR + letter % 26;
            } else
                c->box.klass = M7_UPPER + letter;
            c->box.area = (c->box.x1 - c->box.x0 + 1) * height(&c->box);
        } else if (phase == LETTERS_PROPOSE_FRAGMENTS) {
            if (group_i >= base_count) {
                proposals = 1;
                index = base_count;
                phase = LETTERS_PREPARE_GLYPH;
                continue;
            }
            struct candidate *a = candidates + group_i, *b = candidates + group_j;
            unsigned contained = (a->box.x0 >= b->box.x0 && a->box.y0 >= b->box.y0 &&
                                  a->box.x1 <= b->box.x1 && a->box.y1 <= b->box.y1) ||
                                 (b->box.x0 >= a->box.x0 && b->box.y0 >= a->box.y0 &&
                                  b->box.x1 <= a->box.x1 && b->box.y1 <= a->box.y1);
            /* Keep originals: only a successful glyph fit can join two disconnected fragments. */
            unsigned ah = height(&a->box), bh = height(&b->box);
            if (have_text && !a->dense && !b->dense && !contained && ah <= bh * 2 && bh <= ah * 2 &&
                a->box.x0 <= b->box.x1 + 3 && b->box.x0 <= a->box.x1 + 3 &&
                a->box.y0 <= b->box.y1 + 3 && b->box.y0 <= a->box.y1 + 3) {
                struct m7_box v = {a->box.x0 < b->box.x0 ? a->box.x0 : b->box.x0,
                                   a->box.y0 < b->box.y0 ? a->box.y0 : b->box.y0,
                                   a->box.x1 > b->box.x1 ? a->box.x1 : b->box.x1,
                                   a->box.y1 > b->box.y1 ? a->box.y1 : b->box.y1,
                                   0,
                                   0};
                unsigned duplicate = (v.x1 - v.x0 + 1) * 4 > height(&v) * 7 ||
                                     row_anchor(&v, base_count, M7_CONTOURS) == M7_CONTOURS;
                for (unsigned j = 0; j < count; j++) {
                    const struct m7_box *q = &candidates[j].box;
                    if (absdiff(q->x0, v.x0) <= 1 && absdiff(q->y0, v.y0) <= 1 &&
                        absdiff(q->x1, v.x1) <= 1 && absdiff(q->y1, v.y1) <= 1) {
                        duplicate = 1;
                        break;
                    }
                }
                if (!duplicate) {
                    if (count < M7_CONTOURS) {
                        candidates[count] = (struct candidate){.box = v, .outline = 1};
                        for (unsigned k = 0; k < M7_CONTOURS / 32; k++)
                            members[count][k] = members[group_i][k] | members[group_j][k];
                        count++;
                    } else
                        m7_complex++;
                }
            }
            if (++group_j == group_i) {
                group_i++;
                group_j = 0;
            }
        } else if (phase == LETTERS_PUBLISH) {
            if (index == count + m7_contour_count) {
                phase = LETTERS_DONE;
                return 1;
            }
            struct m7_box b;
            if (index < count) {
                b = candidates[index++].box;
                if (b.klass < M7_UPPER)
                    continue;
            } else {
                const struct m7_contour *c = m7_contours + (index++ - count);
                if (c->klass != M7_CIRCLE && c->klass != M7_RECTANGLE)
                    continue;
                b = (struct m7_box){c->x0, c->y0, c->x1, c->y1, c->area2 / 2, c->klass};
            }
            unsigned child = 0;
            for (unsigned j = 0; j < count; j++) {
                const struct m7_box *a = &candidates[j].box;
                if (a->klass >= M7_UPPER && a->area > b.area && b.x0 >= a->x0 && b.y0 >= a->y0 &&
                    b.x1 <= a->x1 && b.y1 <= a->y1) {
                    child = 1;
                    break;
                }
            }
            if (!child)
                m7_retain(m7_boxes, &m7_count, &m7_more, b);
        } else
            return 1;
    }
    return 0;
}
