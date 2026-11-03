enum follow_phase {
    FOLLOW_IDLE = 0,
    FOLLOW_WAIT_SOURCE = 1,
    FOLLOW_COPY_PATCH = 2,
    FOLLOW_BUILD_EDGES = 3,
    FOLLOW_MATCH_EDGES = 4
};
/* Included by the M7 service: one owner arbitrates its existing raw-frame DMA lease. */
static struct target_track followed;
static uint8_t follow_gray[4096];
static uint64_t follow_edges[64], follow_rows[67];
static const volatile uint16_t *follow_source;
static unsigned follow_phase, follow_pixel, follow_dirty, follow_flags, follow_state;
static uint32_t follow_seen, follow_canceled, follow_last, follow_frame, follow_ms, follow_start,
    follow_serial, follow_settings, follow_view = ~0u;
static uint32_t follow_roi[4];
static uint32_t follow_roi_observation;
static unsigned motion_published_revision;
static uint32_t motion_fade_ms;
/* TRK1: measured frame/time/center/state, elapsed job cycles and ROI request/effective. */
volatile uint32_t geometry_m7_track_record[24];
static void follow_release(void) {
    M7_DMA(RAW_DMA_REG_COMMAND) = RAW_DMA_ACK;
    M7_W(M7_REG_RAW_LEASE, 0);
    follow_dma = 0;
}
static void follow_word(unsigned index, uint64_t value) {
    M7_W(M7_REG_TRACK_INDEX, index);
    M7_W(M7_REG_TRACK_LOW, (uint32_t)value & M7_RECORD_HALF_MASK);
    M7_W(M7_REG_TRACK_HIGH, (uint32_t)(value >> M7_RECORD_HALF_BITS));
}
static unsigned follow_map(int x, int y, unsigned *dx, unsigned *dy) {
    struct vision_control_state *s = CONTROL_STATE;
    if (!s->enabled) {
        if (x < 0 || x >= 1920 || y < 0 || y >= 1080)
            return 0;
        *dx = x;
        *dy = y;
        return 1;
    }
    unsigned sx = s->commit[0] >> 12, sy = s->commit[0] & 4095, sw = s->commit[1] >> 12,
             sh = s->commit[1] & 4095;
    if (x < (int)sx || x >= (int)(sx + sw) || y < (int)sy || y >= (int)(sy + sh))
        return 0;
    *dx = (s->commit[3] >> 12) + (x - sx) * (s->commit[2] >> 12) / sw;
    *dy = (s->commit[3] & 4095) + (y - sy) * (s->commit[2] & 4095) / sh;
    return 1;
}
static unsigned segment_code(int x, int y, int l, int t, int r, int b) {
    return (x < l ? 1 : x > r ? 2 : 0) | (y < t ? 4 : y > b ? 8 : 0);
}
static unsigned follow_segment(const struct tt_point *a, const struct tt_point *b, uint64_t *word,
                               unsigned shade) {
    struct vision_control_state *s = CONTROL_STATE;
    int l = 0, t = 0, r = 1919, bottom = 1079;
    if (s->enabled) {
        l = s->commit[0] >> 12;
        t = s->commit[0] & 4095;
        r = l + (s->commit[1] >> 12) - 1;
        bottom = t + (s->commit[1] & 4095) - 1;
    }
    int x0 = a->x, y0 = a->y, x1 = b->x, y1 = b->y;
    for (;;) {
        unsigned c0 = segment_code(x0, y0, l, t, r, bottom),
                 c1 = segment_code(x1, y1, l, t, r, bottom);
        if (c0 & c1)
            return 0;
        if (!(c0 | c1))
            break;
        unsigned c = c0 ? c0 : c1;
        int x, y;
        if (c & 12) {
            y = c & 4 ? t : bottom;
            x = x0 + (x1 - x0) * (y - y0) / (y1 - y0);
        } else {
            x = c & 1 ? l : r;
            y = y0 + (y1 - y0) * (x - x0) / (x1 - x0);
        }
        if (c0) {
            x0 = x;
            y0 = y;
        } else {
            x1 = x;
            y1 = y;
        }
    }
    unsigned ax, ay, bx, by;
    follow_map(x0, y0, &ax, &ay);
    follow_map(x1, y1, &bx, &by);
    *word = (ax >> 2) | ((uint64_t)(ay >> 2) << 9) | ((uint64_t)(bx >> 2) << 18) |
            ((uint64_t)(by >> 2) << 27) | ((uint64_t)shade << 36);
    return 1;
}
static void follow_publish(struct vision_control_state *s) {
    if (s->pending || s->key_roi_dirty || (M7_R(M7_REG_TRACK_PUBLISH) & 1))
        return;
    uint32_t view = s->enabled && s->good ? s->serial : 0, flags = s->follow | (s->trail << 1);
    if (view != follow_view || flags != follow_flags || follow_state != followed.state ||
        motion_published_revision != all_targets.revision)
        follow_dirty = 1;
    if (!follow_dirty)
        return;
    unsigned count = 0, w = followed.reference.w, h = followed.reference.h, x0, y0, x1, y1;
    unsigned visible = followed.state == TT_LOCKED || followed.state == TT_HOLD;
    visible = visible && follow_map(followed.x - (int)w / 2, followed.y - (int)h / 2, &x0, &y0) &&
              follow_map(followed.x + (int)(w - 1) / 2, followed.y + (int)(h - 1) / 2, &x1, &y1);
    follow_rows[0] = visible ? x0 | ((uint64_t)y0 << 11) | ((uint64_t)followed.state << 22) : 0;
    follow_rows[1] = visible ? x1 | ((uint64_t)y1 << 11) | (1u << 22) : 0;
    for (unsigned row = 0; row < 16; row++)
        follow_rows[2 + row] = m7_label_row(s->track_class, row);
    uint32_t now = M7_R(M7_REG_NOW_MS);
    if (s->trail)
        for (unsigned target = 0; target < 4; target++)
            for (unsigned n = 0; n < all_targets.targets[target].count; n++) {
                const struct mt_target *t = all_targets.targets + target;
                unsigned at = (t->head + n) % MT_POINTS;
                const struct tt_point *p = &t->points[at], *a = p;
                if (n && (t->links & (1u << at)))
                    a = &t->points[(at + MT_POINTS - 1) % MT_POINTS];
                uint32_t age = now - p->ms, old = now - a->ms;
                if (age >= 3000)
                    continue;
                if (old >= 3000)
                    a = p;
                else if (old > age)
                    age = old;
                uint64_t value;
                if (follow_segment(a, p, &value, age < 1000 ? 3 : age < 2000 ? 2 : 1))
                    follow_rows[18 + count++] = value;
            }
    follow_rows[66] = view | ((uint64_t)count << 32);
    for (unsigned n = 0; n < 18; n++)
        follow_word(n, follow_rows[n]);
    for (unsigned n = 0; n < count; n++)
        follow_word(18 + n, follow_rows[18 + n]);
    follow_word(66, follow_rows[66]);
    M7_W(M7_REG_TRACK_PUBLISH, 3);
    follow_dirty = 0;
    follow_view = view;
    follow_flags = flags;
    follow_state = followed.state;
    motion_published_revision = all_targets.revision;
}
static unsigned follow_motion_hint(struct vision_control_state *s) {
    uint32_t hint = M7_R(M7_REG_MOTION_HINT);
    if (!(hint & 8))
        return 0;
    unsigned xy = M7_R(M7_REG_MOTION_XY), br = M7_R(M7_REG_MOTION_BR), x = xy & 4095, y = xy >> 12,
             r = br & 4095, b = br >> 12;
    if (s->enabled) {
        unsigned dx = s->commit[3] >> 12, dy = s->commit[3] & 4095;
        x = (s->commit[0] >> 12) +
            (x > dx ? x - dx : 0) * (s->commit[1] >> 12) / (s->commit[2] >> 12);
        r = (s->commit[0] >> 12) +
            (r > dx ? r - dx : 0) * (s->commit[1] >> 12) / (s->commit[2] >> 12);
        y = (s->commit[0] & 4095) +
            (y > dy ? y - dy : 0) * (s->commit[1] & 4095) / (s->commit[2] & 4095);
        b = (s->commit[0] & 4095) +
            (b > dy ? b - dy : 0) * (s->commit[1] & 4095) / (s->commit[2] & 4095);
    }
    if (followed.x < x || followed.x >= r || followed.y < y || followed.y >= b)
        return 0;
    return hint & 7;
}
static void follow_step(struct vision_control_state *s, unsigned available) {
    uint32_t now = M7_R(M7_REG_NOW_MS);
    if (motion_enabled && (uint32_t)(now - motion_fade_ms) >= 33) {
        motion_fade_ms = now;
        follow_dirty = 1;
    }
    if (followed.state)
        tt_expire(&followed, now);
    if (follow_canceled != s->track_cancel || control_model(s) != CONTROL_MODEL_M7 ||
        !s->ai_policy) {
        follow_canceled = s->track_cancel;
        follow_seen = s->track_request;
        if (followed.state) {
            followed.state = TT_OFF;
            followed.count = 0;
            follow_dirty = 1;
        }
    }
    if (follow_seen != s->track_request) {
        follow_seen = s->track_request;
        if (picker_reference_sequence == s->track_sequence &&
            picker_references[s->track_index].frame) {
            tt_select(&followed, &picker_references[s->track_index]);
            followed.start_ms = followed.last_good = now;
            for (unsigned n = 0; n < 4; n++)
                follow_roi[n] = s->roi[n];
            follow_serial = s->serial;
            follow_settings = s->settings;
            follow_last = now - TT_PERIOD_MS;
            follow_roi_observation = 0;
        } else {
            followed = (struct target_track){.state = TT_LOST};
        }
        follow_dirty = 1;
    }
    unsigned active = (s->follow || s->trail) && !s->target_session &&
                      control_model(s) == CONTROL_MODEL_M7 && s->ai_policy;
    if (!s->follow && !s->trail && followed.state) {
        followed.state = TT_OFF;
        followed.count = 0;
        follow_dirty = 1;
    }
    if (!active || followed.state == TT_OFF || followed.state == TT_LOST) {
        if (follow_dma) {
            if (!(M7_DMA(RAW_DMA_REG_STATUS) & 2))
                return;
            follow_release();
        }
        follow_phase = FOLLOW_IDLE;
    } else {
        tt_expire(&followed, now);
        // A frozen/history source is not a new observation; changed edge semantics need
        // reselection.
        if ((s->settings & 48u) || ((s->settings ^ follow_settings) & ((2047u << 20) | 8u)))
            followed.state = TT_LOST;
        if (!follow_phase && followed.state != TT_LOST && available &&
            (uint32_t)(now - follow_last) >= TT_PERIOD_MS && cache_state != M7_CACHE_DRAIN &&
            !cache_queued && !M7_R(M7_REG_RAW_LEASE) && !(M7_DMA(RAW_DMA_REG_STATUS) & 3)) {
            follow_last = now;
            follow_start = M7_TICKS;
            follow_dma = 1;
            follow_phase = FOLLOW_WAIT_SOURCE;
            M7_W(M7_REG_RAW_LEASE, 1);
            M7_DMA(RAW_DMA_REG_XY) = 0;
            M7_DMA(RAW_DMA_REG_WH) = 1920u | (1080u << 16);
            M7_DMA(RAW_DMA_REG_COMMAND) = RAW_DMA_START | RAW_DMA_HOLD_SOURCE | RAW_DMA_LATEST;
        } else if (follow_phase == FOLLOW_WAIT_SOURCE) {
            uint32_t status = M7_DMA(RAW_DMA_REG_STATUS);
            if (!(status & RAW_DMA_DONE))
                return;
            follow_frame = M7_DMA(RAW_DMA_REG_FRAME);
            follow_ms = now;
            if ((status & RAW_DMA_ERROR) || follow_frame == followed.frame) {
                follow_release();
                follow_phase = FOLLOW_IDLE;
            } else {
                follow_source = (const volatile uint16_t *)(uintptr_t)M7_DMA(RAW_DMA_REG_SOURCE);
#ifndef M7_SERVICE_TEST
                /* Camera DMA reuses source banks; discard the previous bank contents in the CPU
                 * cache. */
                __asm__ volatile("fence rw,rw\n.word 0x500f\nfence rw,rw" ::: "memory");
#endif
                follow_pixel = 0;
                follow_phase = FOLLOW_COPY_PATCH;
            }
        } else if (follow_phase == FOLLOW_COPY_PATCH) {
            for (unsigned n = 0; n < 512 && follow_pixel < 4096; n++, follow_pixel++) {
                int x = followed.x + ((int)(follow_pixel & 63) - 32) * (int)followed.sx,
                    y = followed.y + ((int)(follow_pixel >> 6) - 32) * (int)followed.sy;
                unsigned value = 0;
                if (x >= 0 && x < 1920 && y >= 0 && y < 1080) {
                    uint8_t rgb[3];
                    fomo_rgb(follow_source[y * 1920 + x], rgb);
                    value = (77u * rgb[0] + 150u * rgb[1] + 29u * rgb[2]) >> 8;
                }
                follow_gray[follow_pixel] = value;
            }
            if (follow_pixel == 4096) {
                follow_release();
                follow_phase = FOLLOW_BUILD_EDGES;
            }
        } else if (follow_phase == FOLLOW_BUILD_EDGES) {
            unsigned high = (s->settings >> 20) & 2047;
            tt_sobel(follow_gray, follow_edges, high / 2);
            // Zero-padding outside the sensor must not become a measured object edge.
            for (unsigned y = 0; y < 64; y++)
                for (unsigned x = 0; x < 64; x++) {
                    int sx = followed.x + ((int)x - 32) * (int)followed.sx,
                        sy = followed.y + ((int)y - 32) * (int)followed.sy;
                    if (sx < (int)followed.sx || sx >= 1920 - (int)followed.sx ||
                        sy < (int)followed.sy || sy >= 1080 - (int)followed.sy)
                        follow_edges[y] &= ~((uint64_t)1 << x);
                }
            unsigned hint = follow_motion_hint(s);
            geometry_m7_track_record[15] = hint;
            if (hint)
                geometry_m7_track_record[16]++;
            follow_phase = tt_begin(&followed, follow_edges, follow_frame, follow_ms, hint)
                               ? FOLLOW_MATCH_EDGES
                               : FOLLOW_IDLE;
        } else if (follow_phase == FOLLOW_MATCH_EDGES && tt_step(&followed, 16)) {
            follow_phase = FOLLOW_IDLE;
            follow_dirty = 1;
            geometry_m7_track_record[7] = M7_TICKS - follow_start;
        }
    }
    // A completed old observation is real history, but must not move the current ROI.
    tt_expire(&followed, now);
    if (s->track_status != followed.state) {
        s->track_status = followed.state;
        s->feature_dirty = 1;
        follow_dirty = 1;
    }
    if (followed.state == TT_LOST)
        s->center_status = CENTER_STALE;
    if (active && s->follow && followed.state == TT_LOCKED &&
        followed.observations != follow_roi_observation && !follow_phase && !s->pending &&
        !s->key_roi_dirty && !s->center_stage) {
        follow_roi_observation = followed.observations;
        if (s->serial != follow_serial) {
            s->follow = 0;
            s->feature_dirty = 1;
        } else {
            uint32_t xy;
            if (tt_roi(&followed, follow_roi[1] >> 12, follow_roi[1] & 4095, s->roi[0] >> 12,
                       s->roi[0] & 4095, &xy)) {
                s->roi[0] = xy;
                for (unsigned n = 1; n < 4; n++)
                    s->roi[n] = follow_roi[n];
                s->roi_enable = 1;
                control_submit(s);
                follow_serial = s->serial;
                geometry_m7_track_record[8] = s->serial;
                geometry_m7_track_record[9] = followed.ms;
            }
        }
    }
    if (geometry_m7_track_record[8] &&
        CTRL_R(CONTROL_REG_APPLIED_CONFIG) == geometry_m7_track_record[8] &&
        M7_R(M7_REG_VIEW_CONFIG) == geometry_m7_track_record[8] &&
        geometry_m7_track_record[10] != geometry_m7_track_record[8]) {
        geometry_m7_track_record[10] = geometry_m7_track_record[8];
        geometry_m7_track_record[11] = now - geometry_m7_track_record[9];
    }
    geometry_m7_track_record[0] = 0x54524b31;
    geometry_m7_track_record[1] = followed.observations;
    geometry_m7_track_record[2] = followed.frame;
    geometry_m7_track_record[3] = followed.ms;
    geometry_m7_track_record[4] = followed.x;
    geometry_m7_track_record[5] = followed.y;
    geometry_m7_track_record[6] = followed.state;
    geometry_m7_track_record[12] = followed.count;
    geometry_m7_track_record[13] = followed.misses;
    geometry_m7_track_record[14] = followed.ambiguities;
    if (followed.state || follow_dirty || motion_enabled ||
        motion_published_revision != all_targets.revision)
        follow_publish(s);
}
