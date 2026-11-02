#pragma once
#include "target_track.h"

enum { MT_TARGETS = 4, MT_POINTS = 12, MT_SAMPLE_MS = 250, MT_NONE = 65535 };
struct mt_detection {
    uint16_t x, y, w, h, klass;
};
struct mt_target {
    struct tt_point points[MT_POINTS];
    struct mt_detection box;
    uint32_t id, frame, ms;
    unsigned head, count, direction, links, gap;
};
struct target_motion {
    struct mt_target targets[MT_TARGETS];
    uint32_t next_id, frame;
    unsigned seen, revision;
};
static unsigned mt_abs(int x) {
    return x < 0 ? -x : x;
}
static void mt_expire(struct target_motion *m, uint32_t now) {
    for (unsigned i = 0; i < MT_TARGETS; i++) {
        struct mt_target *t = m->targets + i;
        while (t->count && (uint32_t)(now - t->points[t->head].ms) >= 3000) {
            t->head = (t->head + 1) % MT_POINTS;
            t->count--;
            m->revision++;
        }
    }
}
static unsigned mt_cost(const struct mt_target *t, const struct mt_detection *d, uint32_t ms) {
    if (!t->id || t->box.klass != d->klass || (uint32_t)(ms - t->ms) >= 3000)
        return MT_NONE;
    unsigned w = t->box.w, h = t->box.h;
    if (d->w > w * 2 || w > d->w * 2 || d->h > h * 2 || h > d->h * 2)
        return MT_NONE;
    int dx = (int)d->x + d->w / 2 - (int)t->box.x - w / 2,
        dy = (int)d->y + d->h / 2 - (int)t->box.y - h / 2;
    unsigned range = (w > h ? w : h) + ((uint32_t)(ms - t->ms) * 160) / 1000;
    if (mt_abs(dx) > range || mt_abs(dy) > range)
        return MT_NONE;
    return mt_abs(dx) * 256 / (w + 16) + mt_abs(dy) * 256 / (h + 16) +
           mt_abs((int)d->w - w) * 128 / (w + 16) + mt_abs((int)d->h - h) * 128 / (h + 16);
}
static void mt_observe(struct target_motion *m, const struct mt_detection *d, unsigned n,
                       uint32_t frame, uint32_t ms, unsigned slots[4]) {
    for (unsigned j = 0; j < n; j++)
        slots[j] = MT_TARGETS;
    if (m->seen && frame == m->frame)
        return;
    m->seen = 1;
    m->frame = frame;
    mt_expire(m, ms);
    unsigned costs[4][4], used = 0;
    for (unsigned i = 0; i < 4; i++)
        for (unsigned j = 0; j < n; j++)
            costs[i][j] = mt_cost(m->targets + i, d + j, ms);
    /* A mutual, separated best match survives list reordering; ambiguous crossings start new
     * identities. */
    for (unsigned j = 0; j < n; j++) {
        unsigned best = MT_NONE, second = MT_NONE, k = 4;
        for (unsigned i = 0; i < 4; i++) {
            unsigned c = costs[i][j];
            if (c < best) {
                second = best;
                best = c;
                k = i;
            } else if (c < second)
                second = c;
        }
        if (k == 4)
            continue;
        unsigned other = MT_NONE;
        for (unsigned q = 0; q < n; q++)
            if (q != j && costs[k][q] < other)
                other = costs[k][q];
        if (second < best + 48 || other < best + 48)
            continue;
        slots[j] = k;
        used |= 1u << k;
    }
    for (unsigned j = 0; j < n; j++)
        if (slots[j] == 4) {
            unsigned k = 4;
            for (unsigned i = 0; i < 4; i++)
                if (!(used & (1u << i)) &&
                    (k == 4 || !m->targets[i].id ||
                     (uint32_t)(ms - m->targets[i].ms) > (uint32_t)(ms - m->targets[k].ms)))
                    k = i;
            used |= 1u << k;
            slots[j] = k;
            m->targets[k] = (struct mt_target){.id = ++m->next_id};
        }
    for (unsigned i = 0; i < 4; i++)
        if (!(used & (1u << i)))
            m->targets[i].gap = 1;
    for (unsigned j = 0; j < n; j++) {
        struct mt_target *t = m->targets + slots[j];
        int x = d[j].x + d[j].w / 2, y = d[j].y + d[j].h / 2;
        unsigned direction = MOTION_UNKNOWN;
        if (t->count) {
            int dx = x - (int)t->box.x - t->box.w / 2, dy = y - (int)t->box.y - t->box.h / 2;
            unsigned dead = (d[j].w < d[j].h ? d[j].w : d[j].h) / 16;
            if (dead < 4)
                dead = 4;
            if (mt_abs(dx) <= dead && mt_abs(dy) <= dead)
                direction = MOTION_STILL;
            else if (mt_abs(dx) >= mt_abs(dy))
                direction = dx < 0 ? MOTION_LEFT : MOTION_RIGHT;
            else
                direction = dy < 0 ? MOTION_UP : MOTION_DOWN;
        }
        t->box = d[j];
        t->frame = frame;
        t->ms = ms;
        t->direction = direction;
        if (!t->count ||
            (uint32_t)(ms - t->points[(t->head + t->count - 1) % MT_POINTS].ms) >= MT_SAMPLE_MS) {
            if (t->count == MT_POINTS) {
                t->head = (t->head + 1) % MT_POINTS;
                t->count--;
            }
            unsigned p = (t->head + t->count) % MT_POINTS;
            t->links = (t->links & ~(1u << p)) | ((t->count && !t->gap) << p);
            t->points[p] = (struct tt_point){frame, ms, x, y};
            t->count++;
            t->gap = 0;
        }
    }
    m->revision++;
}
