#include "geometry_m7_service.h"
#include "geometry_m7.h"
#include "geometry_labels.h"
#include "geometry_letters.h"
#include "geometry_face.h"
#include "geometry_face_refine.h"
#include "fomo_pixels.h"
#include "control_service.h"
#include "target_track.h"
#include "target_motion.h"
#ifndef M7_SERVICE_TEST
#include "flyhash_service.h"
#define M7_DMA(off) (*(volatile uint32_t *)(0xf8100100u + (off)))
#define M7_TICKS (*(volatile uint32_t *)0xf8100030u)
#endif

uint32_t geometry_m7_bitmap[M7_WORDS];
/* GEO3: publication/primary identity, boxes, independent lane timing/sequences. */
volatile uint32_t geometry_m7_record[24];
/* Full class IDs accompany the legacy two-bit boxes under the same publication sequence. */
volatile uint32_t geometry_m7_classes[4];
/* Per lane: sequence/frame/render/context/cycles/count+more/complex/edge epoch. */
volatile uint32_t geometry_m7_lane_record[16];
/* M7FR: source identity, short raw lease/cache timing, coarse/fine timing and failures. */
volatile uint32_t geometry_m7_fine_record[16];
struct m7_lane {
    struct m7_box boxes[4];
    unsigned count, more, complex, valid;
    uint32_t frame, render, context, cycles, sequence, epoch, directions;
    struct tt_reference references[4];
};
static struct m7_lane geometry, face;
static struct {
    uint32_t frame, render, context, epoch, start, ms, map[4];
} job, face_job;
static struct target_motion all_targets;
static unsigned motion_enabled, motion_semantics;
/* MTK1: observed source/time, association cycles, directions and stored point count. */
volatile uint32_t geometry_m7_motion_record[8];
static void observe_targets(const struct m7_box *boxes, unsigned count) {
    struct mt_detection detections[4];
    unsigned indices[4], slots[4], n = 0;
    geometry.directions = 0;
    if (!motion_enabled)
        return;
    uint32_t motion_start = M7_TICKS;
    unsigned sx = 0, sy = 0, sw = 1920, sh = 1080, dw = 1920, dh = 1080, px = 0, py = 0;
    if (job.render) {
        if (!job.map[1])
            return;
        sx = job.map[0] >> 12;
        sy = job.map[0] & 4095;
        sw = job.map[1] >> 12;
        sh = job.map[1] & 4095;
        dw = job.map[2] >> 12;
        dh = job.map[2] & 4095;
        px = job.map[3] >> 12;
        py = job.map[3] & 4095;
    }
    for (unsigned i = 0; i < count; i++) {
        const struct m7_box *b = boxes + i;
        unsigned x = b->x0 * 4, y = b->y0 * 4, r = (b->x1 + 1) * 4, bottom = (b->y1 + 1) * 4;
        if (x < px || y < py || r > px + dw || bottom > py + dh)
            continue;
        unsigned left = sx + (x - px) * sw / dw, top = sy + (y - py) * sh / dh;
        detections[n] = (struct mt_detection){left, top, sx + (r - px) * sw / dw - left,
                                              sy + (bottom - py) * sh / dh - top, b->klass};
        indices[n++] = i;
    }
    mt_observe(&all_targets, detections, n, job.frame, job.ms, slots);
    for (unsigned i = 0; i < n; i++)
        if (slots[i] < 4)
            geometry.directions |= all_targets.targets[slots[i]].direction << (indices[i] * 3);
    unsigned points = 0;
    for (unsigned i = 0; i < 4; i++)
        points += all_targets.targets[i].count;
    geometry_m7_motion_record[0] = 0x4d544b31;
    geometry_m7_motion_record[1] = job.frame;
    geometry_m7_motion_record[2] = job.ms;
    geometry_m7_motion_record[3] = M7_TICKS - motion_start;
    geometry_m7_motion_record[4] = geometry.directions;
    geometry_m7_motion_record[5] = n;
    geometry_m7_motion_record[6] = points;
    geometry_m7_motion_record[7] = all_targets.revision;
}
static unsigned initialized, phase, word, unchanged, face_running, dirty, have_epoch;
static uint32_t token, start, pub_sequence, last_epoch, settings, threshold, render, context,
    run_request;
static unsigned single_pending, run_policy, run_model, run_picker, config_wait;
static int32_t face_credit;
static int32_t follow_credit;
static unsigned cache_state, cache_for_job, cache_queued;
#ifndef VISION_M7_NO_FACE
static uint8_t gray_cache[M7_CACHE_W * M7_CACHE_H];
static uint16_t map_x[M7_CACHE_W], map_y[M7_CACHE_H];
static const volatile uint16_t *raw_source;
static unsigned map_index, cache_x, cache_y, cache_index, use_roi, face_high, face_median;
static uint32_t cache_start, refine_start, roi[4];
#endif
static unsigned follow_dma;
#ifndef VISION_M7_NO_FACE
static uint32_t face_follow_edges[M7_WORDS];
#endif
static struct tt_reference published_references[4], picker_references[4];
static uint32_t picker_reference_sequence;
enum {
    M7_CACHE_NONE,
    M7_CACHE_ACQUIRE,
    M7_CACHE_MAP,
    M7_CACHE_COPY,
    M7_CACHE_READY,
    M7_CACHE_FAILED,
    M7_CACHE_DRAIN
};
enum { M7_FACE_INACTIVE, M7_FACE_COARSE, M7_FACE_WAIT_CACHE, M7_FACE_FINE, M7_FACE_RESERVED };
enum {
    M7_SERVICE_IDLE,
    M7_WAIT_SNAPSHOT,
    M7_COPY_BITMAP,
    M7_RUN_CONTOURS,
    M7_DRAIN_LEASE,
    M7_RUN_LETTERS
};
#ifndef VISION_M7_NO_FACE
static void abort_cache(void) {
    cache_for_job = cache_queued = 0;
    cache_state = !follow_dma && M7_R(M7_REG_RAW_LEASE) ? M7_CACHE_DRAIN : M7_CACHE_NONE;
}
static void start_cache(void) {
    cache_start = M7_TICKS;
    cache_state = M7_CACHE_ACQUIRE;
    cache_for_job = 1;
    cache_queued = 0;
    M7_W(M7_REG_RAW_LEASE, 1);
    M7_DMA(RAW_DMA_REG_REQUEST_FRAME) = face_job.frame;
    M7_DMA(RAW_DMA_REG_XY) = 0;
    M7_DMA(RAW_DMA_REG_WH) = 1920u | (1080u << 16);
    M7_DMA(RAW_DMA_REG_COMMAND) = RAW_DMA_START | RAW_DMA_HOLD_SOURCE;
    geometry_m7_fine_record[5] = cache_state;
}
static unsigned cache_step(void) {
    if (cache_state == M7_CACHE_DRAIN) {
        uint32_t d = M7_DMA(RAW_DMA_REG_STATUS);
        if (d & RAW_DMA_BUSY)
            return 1;
        if (d & RAW_DMA_DONE)
            M7_DMA(RAW_DMA_REG_COMMAND) = RAW_DMA_ACK;
        M7_W(M7_REG_RAW_LEASE, 0);
        cache_state = M7_CACHE_NONE;
        return cache_queued;
    }
    if (cache_queued && cache_state == M7_CACHE_NONE)
        start_cache();
    if (cache_state == M7_CACHE_ACQUIRE) {
        uint32_t d = M7_DMA(RAW_DMA_REG_STATUS);
        if (!(d & RAW_DMA_DONE))
            return 1;
        if ((d & RAW_DMA_ERROR) || M7_DMA(RAW_DMA_REG_FRAME) != face_job.frame) {
            geometry_m7_fine_record[10]++;
            geometry_m7_fine_record[12] = (d & RAW_DMA_ERROR) ? M7_DMA(RAW_DMA_REG_FAULT) : 128;
            M7_DMA(RAW_DMA_REG_COMMAND) = RAW_DMA_ACK;
            M7_W(M7_REG_RAW_LEASE, 0);
            cache_state = M7_CACHE_FAILED;
        } else {
            raw_source = (const volatile uint16_t *)(uintptr_t)M7_DMA(RAW_DMA_REG_SOURCE);
            geometry_m7_fine_record[11] = M7_DMA(RAW_DMA_REG_CONFIG);
#ifndef M7_SERVICE_TEST
            __asm__ volatile("fence rw,rw\n.word 0x500f\nfence rw,rw" ::: "memory");
#endif
            map_index = 0;
            cache_state = M7_CACHE_MAP;
        }
    } else if (cache_state == M7_CACHE_MAP) {
        for (unsigned n = 0; n < 32 && map_index < M7_CACHE_W + M7_CACHE_H; n++, map_index++) {
            unsigned axis = map_index >= M7_CACHE_W,
                     index = axis ? map_index - M7_CACHE_W : map_index, v = index * 2 + 1,
                     mapped = v;
            if (use_roi) {
                unsigned start = axis ? (roi[0] & 4095) : (roi[0] >> 12),
                         length = axis ? (roi[1] & 4095) : (roi[1] >> 12);
                unsigned dst = axis ? (roi[3] & 4095) : (roi[3] >> 12),
                         size = axis ? (roi[2] & 4095) : (roi[2] >> 12);
                mapped = v < dst || v >= dst + size ? 65535 : start + (v - dst) * length / size;
            }
            if (axis)
                map_y[index] = mapped;
            else
                map_x[index] = mapped;
        }
        if (map_index == M7_CACHE_W + M7_CACHE_H) {
            cache_x = cache_y = cache_index = 0;
            cache_state = M7_CACHE_COPY;
        }
    } else if (cache_state == M7_CACHE_COPY) {
        /* A larger bounded copy slice releases the shared source before long face fitting. */
        for (unsigned n = 0; n < 2048 && cache_index < sizeof(gray_cache); n++) {
            unsigned value = 0;
            if (map_x[cache_x] != 65535 && map_y[cache_y] != 65535) {
                uint8_t rgb[3];
                fomo_rgb(raw_source[map_y[cache_y] * 1920u + map_x[cache_x]], rgb);
                value = (77u * rgb[0] + 150u * rgb[1] + 29u * rgb[2]) >> 8;
            }
            gray_cache[cache_index++] = value;
            if (++cache_x == M7_CACHE_W) {
                cache_x = 0;
                cache_y++;
            }
        }
        geometry_m7_fine_record[14] = cache_index;
        if (cache_index == sizeof(gray_cache)) {
            M7_DMA(RAW_DMA_REG_COMMAND) = RAW_DMA_ACK;
            M7_W(M7_REG_RAW_LEASE, 0);
            cache_state = M7_CACHE_READY;
            geometry_m7_fine_record[6] = M7_TICKS - cache_start;
        }
    }
    geometry_m7_fine_record[5] = cache_state;
    return M7_R(M7_REG_RAW_LEASE) != 0;
}
static void reserve_face(struct vision_control_state *s, unsigned available) {
    face_job = job;
    face_running = M7_FACE_RESERVED;
    face_high = threshold;
    face_median = (settings >> 3) & 1;
    geometry_m7_fine_record[0] = 0x4d374652;
    geometry_m7_fine_record[2] = job.frame;
    geometry_m7_fine_record[3] = job.render;
    geometry_m7_fine_record[4] = job.context;
    geometry_m7_fine_record[6] = geometry_m7_fine_record[7] = geometry_m7_fine_record[8] =
        geometry_m7_fine_record[9] = 0;
    geometry_m7_fine_record[11] = geometry_m7_fine_record[12] = geometry_m7_fine_record[13] =
        geometry_m7_fine_record[14] = 0;
    cache_for_job = cache_queued = 0;
    unsigned translated = s->follow && !s->target_session;
    for (unsigned i = 0; i < 4; i++)
        roi[i] = translated ? job.map[i] : s->commit[i];
    use_roi = translated ? job.render != 0 : s->enabled && s->good;
    if (available && cache_state != M7_CACHE_DRAIN && !(M7_DMA(RAW_DMA_REG_STATUS) & 3)) {
        start_cache();
    } else if (available && cache_state == M7_CACHE_DRAIN) {
        /* A frozen-view source change waits for our old lease, rather than losing refinement. */
        cache_queued = cache_for_job = 1;
    } else {
        geometry_m7_fine_record[10]++;
        geometry_m7_fine_record[12] = 129;
    }
    geometry_m7_fine_record[5] = cache_for_job ? cache_state : M7_CACHE_FAILED;
}
#else
static void abort_cache(void) {
    cache_for_job = cache_queued = 0;
    cache_state = M7_CACHE_NONE;
}
/* The follower still owns this shared raw lease when the face cache is disabled. */
static unsigned cache_step(void) {
    return M7_R(M7_REG_RAW_LEASE) != 0;
}
#endif
static void reject_snapshot(void) {
    if (face_running == M7_FACE_RESERVED && face_job.frame == job.frame) {
        face_running = M7_FACE_INACTIVE;
        abort_cache();
    }
    M7_W(M7_REG_SNAPSHOT, 0);
    phase = M7_SERVICE_IDLE;
    geometry_m7_record[20] = M7_SERVICE_IDLE;
    geometry_m7_record[23]++;
}
static void cancel(void) {
    M7_W(M7_REG_SNAPSHOT, 0);
    phase = M7_SERVICE_IDLE;
    face_running = M7_FACE_INACTIVE;
    dirty = have_epoch = 0;
    face_credit = 0;
    abort_cache();
    geometry.valid = face.valid = 0;
    geometry_m7_record[1] = geometry_m7_lane_record[0] = geometry_m7_lane_record[8] = 0;
    geometry_m7_record[20] = geometry_m7_record[21] = 0;
    geometry_m7_record[22]++;
}
static void save_lane(struct m7_lane *lane, const struct m7_box *boxes, unsigned count,
                      unsigned more, unsigned complex, unsigned index) {
    for (unsigned i = 0; i < count; i++)
        lane->boxes[i] = boxes[i];
    if (!index)
        observe_targets(boxes, count);
    if ((CONTROL_STATE->follow || CONTROL_STATE->trail) && !lane->render)
        for (unsigned i = 0; i < count; i++) {
            const struct m7_box *b = boxes + i;
            const uint32_t *edges = geometry_m7_bitmap;
#ifndef VISION_M7_NO_FACE
            if (index)
                edges = face_follow_edges;
#endif
            tt_reference_edges(&lane->references[i], edges, b->x0 * 4, b->y0 * 4,
                               (b->x1 - b->x0 + 1) * 4, (b->y1 - b->y0 + 1) * 4, lane->frame,
                               M7_R(M7_REG_NOW_MS));
        }
    lane->count = count;
    lane->more = more;
    lane->complex = complex;
    lane->valid = 1;
    lane->sequence++;
    volatile uint32_t *r = geometry_m7_lane_record + index * 8;
    r[0] = 0;
    r[1] = lane->frame;
    r[2] = lane->render;
    r[3] = lane->context;
    r[4] = lane->cycles;
    r[5] = count | (more << 3);
    r[6] = complex;
    r[7] = lane->epoch;
    __asm__ volatile("fence rw,rw" ::: "memory");
    r[0] = lane->sequence;
    dirty = 1;
}
#ifndef VISION_M7_NO_FACE
static void save_face(void) {
    face.frame = face_job.frame;
    face.render = face_job.render;
    face.context = face_job.context;
    face.epoch = face_job.epoch;
    face.cycles = M7_TICKS - face_job.start;
    save_lane(&face, m7_face_boxes, m7_face_count, m7_face_more, 0, 1);
}
#endif
static void publish(void) {
    struct m7_box boxes[4];
    unsigned count = 0, more = 0;
    if (geometry.valid && geometry.render == M7_R(M7_REG_VIEW_CONFIG) &&
        geometry.context == M7_R(M7_REG_VIEW_CONTEXT)) {
        count = geometry.count;
        more = geometry.more;
        for (unsigned i = 0; i < count; i++)
            boxes[i] = geometry.boxes[i];
    }
    if (face.valid && face.render == M7_R(M7_REG_VIEW_CONFIG) &&
        face.context == M7_R(M7_REG_VIEW_CONTEXT)) {
        more |= face.more;
        for (unsigned i = 0; i < face.count; i++) {
            struct m7_box b = face.boxes[i];
            if (geometry.valid && face.frame == geometry.frame)
                m7_retain(boxes, &count, &more, b);
            else {
                /* Results from different source frames are not deduplicated as one object. */
                if (count == 4) {
                    more = 1;
                    if (b.area <= boxes[3].area)
                        continue;
                } else
                    count++;
                unsigned n = count - 1;
                while (n && boxes[n - 1].area < b.area) {
                    boxes[n] = boxes[n - 1];
                    n--;
                }
                boxes[n] = b;
            }
        }
    }
    const struct m7_lane *primary = count && boxes[0].klass == M7_FACE ? &face : &geometry;
    uint32_t meta[4] = {primary->frame, primary->render, primary->context,
                        count | (more << 3) | (1u << 13) |
                            ((count ? m7_symbol(boxes[0].klass) : 0) << 17)};
    geometry_m7_record[1] = 0;
    for (unsigned i = 0; i < 4; i++) {
        geometry_m7_classes[i] = i < count ? boxes[i].klass : 0;
        if (i < count && (CONTROL_STATE->follow || CONTROL_STATE->trail)) {
            const struct m7_lane *lane = boxes[i].klass == M7_FACE ? &face : &geometry;
            for (unsigned n = 0; n < lane->count; n++)
                if (boxes[i].klass == lane->boxes[n].klass && boxes[i].x0 == lane->boxes[n].x0 &&
                    boxes[i].y0 == lane->boxes[n].y0 && boxes[i].x1 == lane->boxes[n].x1 &&
                    boxes[i].y1 == lane->boxes[n].y1)
                    published_references[i] = lane->references[n];
        }
        uint64_t value = 0;
        if (i < count) {
            const struct m7_box *b = &boxes[i];
            value = ((uint64_t)(b->klass <= M7_FACE ? b->klass : 0) << 36) |
                    ((uint64_t)b->x0 << 27) | ((uint64_t)b->y0 << 18) | ((uint32_t)b->x1 << 9) |
                    b->y1;
            meta[3] += 1u << (b->klass <= M7_FACE ? b->klass * 3 + 1 : 14);
        }
        uint32_t low = value & M7_RECORD_HALF_MASK, high = value >> M7_RECORD_HALF_BITS;
        M7_W(M7_REG_BOX_LOW + i * 8, low);
        M7_W(M7_REG_BOX_HIGH + i * 8, high);
        geometry_m7_record[8 + i * 2] = low;
        geometry_m7_record[9 + i * 2] = high;
    }
    M7_W(M7_REG_LABEL_INDEX, 0);
    for (unsigned i = 0; i < 4; i++)
        for (unsigned row = 0; row < 16; row++) {
            uint64_t data = m7_label_row(i < count ? boxes[i].klass : 0, row);
            M7_W(M7_REG_LABEL_LOW, (uint32_t)data & M7_RECORD_HALF_MASK);
            M7_W(M7_REG_LABEL_HIGH, (uint32_t)(data >> M7_RECORD_HALF_BITS));
        }
    for (unsigned i = 0; i < 4; i++) {
        uint64_t value = meta[i];
        if (i == 3 && motion_enabled && (CONTROL_STATE->settings >> 31))
            value |= ((uint64_t)geometry.directions << 24) | (1ull << 36);
        M7_W(M7_REG_META_LOW + i * 8, value & M7_RECORD_HALF_MASK);
        M7_W(M7_REG_META_HIGH + i * 8, value >> M7_RECORD_HALF_BITS);
    }
    geometry_m7_record[0] = 0x4d374733;
    geometry_m7_record[2] = meta[0];
    geometry_m7_record[3] = meta[1];
    geometry_m7_record[4] = meta[2];
    geometry_m7_record[5] = meta[3];
    geometry_m7_record[6] = primary->cycles;
    geometry_m7_record[7] = geometry.complex;
    geometry_m7_record[16] = geometry.cycles;
    geometry_m7_record[17] = face.cycles;
    geometry_m7_record[18] = geometry.sequence;
    geometry_m7_record[19] = face.sequence;
    __asm__ volatile("fence rw,rw" ::: "memory");
    geometry_m7_record[1] = ++pub_sequence;
    M7_W(M7_REG_PUBLISH, 0);
    dirty = 0;
}
static void snapshot_targets(struct vision_control_state *s) {
    if ((s->center_stage != CENTER_TARGET_SCAN && s->center_stage != CENTER_TARGET_PICK) || dirty ||
        (M7_R(M7_REG_SNAPSHOT) & (M7_RESULT_CURRENT | M7_PUBLISH_BUSY)) != M7_RESULT_CURRENT ||
        !geometry_m7_record[1] || s->target_sequence == geometry_m7_record[1])
        return;
    uint32_t boxes[8], frames[4], classes = 0;
    unsigned count = geometry_m7_record[5] & 7, selected = 4, best = 49, ties = 0;
    if (!s->target_ready && count)
        selected = 0;
    for (unsigned i = 0; i < count; i++) {
        uint64_t b =
            geometry_m7_record[8 + i * 2] | ((uint64_t)geometry_m7_record[9 + i * 2] << 19);
        unsigned x = ((b >> 27) & 511) * 4, y = ((b >> 18) & 511) * 4;
        unsigned w = (((b >> 9) & 511) + 1) * 4 - x, h = ((b & 511) + 1) * 4 - y;
        boxes[i * 2] = x | (y << 16);
        boxes[i * 2 + 1] = w | (h << 16);
        unsigned klass = geometry_m7_classes[i];
        classes |= klass << (i * 7);
        frames[i] = klass == M7_FACE ? face.frame : geometry.frame;
        if (s->target_index < s->target_count &&
            klass == ((s->target_classes >> (s->target_index * 7)) & 127)) {
            unsigned old = s->target_index, ox = s->target_boxes[old * 2] & 65535,
                     oy = s->target_boxes[old * 2] >> 16;
            unsigned ow = s->target_boxes[old * 2 + 1] & 65535,
                     oh = s->target_boxes[old * 2 + 1] >> 16;
            unsigned left = x > ox ? x : ox, top = y > oy ? y : oy,
                     right = x + w < ox + ow ? x + w : ox + ow,
                     bottom = y + h < oy + oh ? y + h : oy + oh;
            if (left < right && top < bottom) {
                unsigned common = (right - left) * (bottom - top),
                         score = common * 100 / (w * h + ow * oh - common);
                if (score > best) {
                    best = score;
                    selected = i;
                    ties = 0;
                } else if (score == best)
                    ties = 1;
            }
        }
    }
    if (ties)
        selected = 4;
    for (unsigned i = 0; i < count; i++) {
        s->target_boxes[i * 2] = boxes[i * 2];
        s->target_boxes[i * 2 + 1] = boxes[i * 2 + 1];
        s->target_frames[i] = frames[i];
        picker_references[i] = published_references[i];
    }
    picker_reference_sequence = geometry_m7_record[1];
    s->target_frame = geometry_m7_record[2];
    s->target_render = geometry_m7_record[3];
    s->target_context = geometry_m7_record[4];
    s->target_ready = 1;
    s->target_count = count;
    s->target_classes = classes;
    s->target_index = selected;
    s->target_sequence = geometry_m7_record[1];
    s->center_status = !count ? CENTER_NONE : selected < count ? CENTER_READY : CENTER_STALE;
    s->feature_dirty = 1;
}
#include "target_follow_service.h"
unsigned geometry_m7_service_step(unsigned available) {
    struct vision_control_state *s = CONTROL_STATE;
    unsigned enabled = control_model(s) == CONTROL_MODEL_M7 && s->ai_policy &&
                       !(s->settings & 48u) && (s->trail || (s->settings >> 31));
    unsigned semantics = s->settings & ((2047u << 20) | 8u);
    if (enabled != motion_enabled || semantics != motion_semantics) {
        all_targets = (struct target_motion){0};
        motion_enabled = enabled;
        motion_semantics = semantics;
        follow_dirty = 1;
    }
    mt_expire(&all_targets, M7_R(M7_REG_NOW_MS));
    uint32_t status = M7_R(M7_REG_SNAPSHOT), now_render = M7_R(M7_REG_VIEW_CONFIG),
             now_context = M7_R(M7_REG_VIEW_CONTEXT), now_threshold = M7_R(M7_REG_EDGE_THRESHOLD);
    if (!initialized) {
        M7_W(M7_REG_SNAPSHOT, 0);
        phase = M7_R(M7_REG_RAW_LEASE) ? M7_DRAIN_LEASE : M7_SERVICE_IDLE;
        pub_sequence = (M7_R(M7_REG_SNAPSHOT) >> 5) & 1;
        initialized = 1;
        settings = s->settings;
        threshold = now_threshold;
        render = now_render;
        context = now_context;
    }
    /* Retire an old firmware's persistent DMA lease before using the shared engine. */
    if (phase == M7_DRAIN_LEASE) {
        uint32_t d = M7_DMA(RAW_DMA_REG_STATUS);
        if (d & RAW_DMA_BUSY)
            return 1;
        if (d & RAW_DMA_DONE)
            M7_DMA(RAW_DMA_REG_COMMAND) = RAW_DMA_ACK;
        M7_W(M7_REG_RAW_LEASE, 0);
        phase = M7_SERVICE_IDLE;
        return 0;
    }
    uint32_t follow_start_tick = M7_TICKS;
    follow_step(s, available);
    unsigned fast =
        follow_phase != FOLLOW_IDLE && (followed.state == TT_LOCKED || followed.state == TT_HOLD);
    if (fast)
        follow_credit += (int32_t)((M7_TICKS - follow_start_tick) / 3);
    else
        follow_credit = 0;
    unsigned following = s->follow && !s->target_session &&
                         (followed.state == TT_LOCKED || followed.state == TT_HOLD);
    unsigned tracking = (s->follow || s->trail) && !s->target_session &&
                        (followed.state == TT_LOCKED || followed.state == TT_HOLD);
    unsigned model = control_model(s),
             picker = s->target_session && s->center_stage != CENTER_WAIT_ROI,
             single = model == CONTROL_MODEL_M7 && s->ai_policy == 1 && !picker;
    if (run_policy != s->ai_policy || run_model != model || run_picker != picker) {
        cancel();
        run_policy = s->ai_policy;
        run_model = model;
        run_picker = picker;
        single_pending = 0;
        config_wait = 1;
    }
    if (single && run_request != s->ai_request) {
        cancel();
        single_pending = 1;
    }
    run_request = s->ai_request;
    if (settings != s->settings || threshold != now_threshold || render != now_render ||
        context != now_context) {
        if (!following || settings != s->settings || threshold != now_threshold) {
            cancel();
            config_wait = 1;
        }
        settings = s->settings;
        threshold = now_threshold;
        render = now_render;
        context = now_context;
    }
    if (!s->feature_wait)
        config_wait = 0;
    if (!control_geometry_enabled(s) || !(status & M7_ENABLED) || config_wait ||
        (s->pending && !following)) {
        if (phase || geometry.valid || face.valid || face_running)
            cancel();
        return cache_step();
    }
    /* Snapshot validity protects the shared copy, not previously copied lane inputs. */
    if (phase == M7_COPY_BITMAP && !(status & M7_SNAPSHOT_VALID)) {
        reject_snapshot();
        return cache_step();
    }

    /* Reserve three quarters of busy-target CPU time; copied classifiers keep their jobs. */
    if (fast && (follow_phase == FOLLOW_WAIT_SOURCE || follow_credit < 0))
        return 1;
    uint32_t ordinary_start = M7_TICKS;
    cache_step();
    if (s->target_session && s->center_stage == CENTER_TARGET_APPLY)
        return 0;
    /* Both lanes share RV32: repay face CPU time with runnable geometry CPU time. */
    unsigned foreground =
        phase == M7_COPY_BITMAP || phase == M7_RUN_CONTOURS || phase == M7_RUN_LETTERS;
    uint32_t face_ticks = 0, foreground_start;
#ifndef VISION_M7_NO_FACE
    if (!foreground || face_credit >= 0) {
        if (face_credit > 0)
            face_credit = 0;
        uint32_t face_start = M7_TICKS;
        if (face_running == M7_FACE_COARSE && m7_face_step(128)) {
            geometry_m7_fine_record[7] = M7_TICKS - face_job.start;
            geometry_m7_fine_record[9] = m7_head_count;
            save_face();
            if (cache_for_job && cache_state != M7_CACHE_FAILED &&
                m7_face_refine_begin(gray_cache, face_high, face_median))
                face_running = M7_FACE_WAIT_CACHE;
            else {
                face_running = M7_FACE_INACTIVE;
                abort_cache();
            }
        }
        if (face_running == M7_FACE_WAIT_CACHE) {
            if (cache_state == M7_CACHE_READY) {
                refine_start = M7_TICKS;
                face_running = M7_FACE_FINE;
            } else if (cache_state == M7_CACHE_FAILED) {
                face_running = M7_FACE_INACTIVE;
                abort_cache();
            }
        }
        if (face_running == M7_FACE_FINE) {
            geometry_m7_fine_record[13]++;
            if (m7_face_refine_step()) {
                geometry_m7_fine_record[8] = M7_TICKS - refine_start;
                save_face();
                face_running = M7_FACE_INACTIVE;
                abort_cache();
                geometry_m7_fine_record[1]++;
            }
        }
        face_ticks = M7_TICKS - face_start;
    }
#endif
    foreground_start = M7_TICKS;
    if (phase == M7_SERVICE_IDLE) {
        uint32_t epoch = M7_R(M7_REG_EDGE_EPOCH);
        if (!s->pending && (!single || single_pending) && available &&
            (M7_R(M7_REG_RAW_LEASE) || !(M7_DMA(RAW_DMA_REG_STATUS) & 3)) &&
            !(status & M7_PUBLISH_BUSY) && epoch &&
            (!have_epoch || epoch != last_epoch || single_pending)) {
            token = M7_R(M7_REG_SNAPSHOT_TOKEN);
            start = M7_TICKS;
            M7_W(M7_REG_SNAPSHOT, 1);
            phase = M7_WAIT_SNAPSHOT;
        }
    } else if (phase == M7_WAIT_SNAPSHOT) {
        if (M7_R(M7_REG_SNAPSHOT_TOKEN) != token) {
            /* The token may advance after the status read at function entry. */
            if (!(M7_R(M7_REG_SNAPSHOT) & M7_SNAPSHOT_VALID)) {
                reject_snapshot();
                return M7_R(M7_REG_RAW_LEASE) || cache_queued;
            }
            job.frame = M7_R(M7_REG_SOURCE_FRAME);
            job.render = M7_R(M7_REG_VIEW_CONFIG);
            job.context = M7_R(M7_REG_VIEW_CONTEXT);
            job.epoch = M7_R(M7_REG_EDGE_EPOCH);
            job.start = start;
            job.ms = M7_R(M7_REG_SOURCE_MS);
            if (following && job.render) {
                if (job.render == s->serial && !s->pending && s->good) {
                    for (unsigned i = 0; i < 4; i++)
                        job.map[i] = s->commit[i];
                } else {
                    if (s->render_maps[job.render & 3][0] != job.render) {
                        reject_snapshot();
                        return cache_step();
                    }
                    for (unsigned i = 0; i < 4; i++)
                        job.map[i] = s->render_maps[job.render & 3][i + 1];
                }
            } else if (job.render) {
                job.map[1] = 0;
                if (job.render == s->serial && s->good) {
                    for (unsigned i = 0; i < 4; i++)
                        job.map[i] = s->commit[i];
                } else if (s->render_maps[job.render & 3][0] == job.render) {
                    for (unsigned i = 0; i < 4; i++)
                        job.map[i] = s->render_maps[job.render & 3][i + 1];
                }
            } else {
                job.map[0] = job.map[3] = 0;
                job.map[1] = job.map[2] = (1920u << 12) | 1080;
            }
            /* A frozen/history view cannot combine different displayed source frames. */
            if (((s->settings >> 4) & 3) && ((face_running && face_job.frame != job.frame) ||
                                             (face.valid && face.frame != job.frame))) {
                face_running = M7_FACE_INACTIVE;
                face.valid = 0;
                geometry_m7_lane_record[8] = 0;
                abort_cache();
            }
#ifndef VISION_M7_NO_FACE
            if (!face_running && (!geometry.valid || geometry.frame != job.frame))
                reserve_face(s, available);
#endif
            unchanged = !single_pending && geometry.valid && geometry.frame == job.frame;
            word = 0;
            phase = M7_COPY_BITMAP;
        }
    } else if (phase == M7_COPY_BITMAP) {
        for (unsigned i = 0; i < 128 && word < M7_WORDS; i++, word++) {
            uint32_t value = fly_read_word(word);
            if (value != geometry_m7_bitmap[word])
                unchanged = 0;
            geometry_m7_bitmap[word] = value;
        }
        if (word == M7_WORDS) {
            M7_W(M7_REG_SNAPSHOT, 0);
            last_epoch = job.epoch;
            have_epoch = 1;
            if (single)
                single_pending = 0;
            if (unchanged) {
                phase = M7_SERVICE_IDLE;
                if (face_running == M7_FACE_RESERVED && face_job.frame == job.frame) {
                    face_running = M7_FACE_INACTIVE;
                    abort_cache();
                }
            } else {
                m7_begin(geometry_m7_bitmap);
                phase = M7_RUN_CONTOURS;
            }
        }
    } else if (phase == M7_RUN_CONTOURS) {
        if (m7_step(tracking ? 256 : 2048)) {
#ifndef VISION_M7_NO_FACE
            if (!face_running)
                reserve_face(s, available);
            if (face_running == M7_FACE_RESERVED && face_job.frame == job.frame) {
                for (unsigned i = 0; i < M7_WORDS; i++)
                    face_follow_edges[i] = geometry_m7_bitmap[i];
                m7_face_begin(geometry_m7_bitmap, m7_contours, m7_contour_count);
                face_running = M7_FACE_COARSE;
            }
#endif
            m7_letters_begin(geometry_m7_bitmap);
            phase = M7_RUN_LETTERS;
        }
    } else if (phase == M7_RUN_LETTERS) {
        if (m7_letters_step(64)) {
            geometry.frame = job.frame;
            geometry.render = job.render;
            geometry.context = job.context;
            geometry.epoch = job.epoch;
            geometry.cycles = M7_TICKS - job.start;
            save_lane(&geometry, m7_boxes, m7_count, m7_more, m7_complex, 0);
            phase = M7_SERVICE_IDLE;
        }
    }
    if (foreground)
        face_credit += (int32_t)(M7_TICKS - foreground_start) - (int32_t)face_ticks;
    else
        face_credit = 0;
    /* The existing VS bank swap is atomic; never publish during descriptor settling. */
    if (dirty && phase != M7_WAIT_SNAPSHOT && !(M7_R(M7_REG_SNAPSHOT) & M7_PUBLISH_BUSY) &&
        (M7_R(M7_REG_SNAPSHOT) & M7_SNAPSHOT_VALID))
        publish();
    if (s->target_session)
        snapshot_targets(s);
    geometry_m7_record[20] = phase;
    geometry_m7_record[21] = face_running != 0;
    geometry_m7_fine_record[15] = face_running;
    if (fast)
        follow_credit -= (int32_t)(M7_TICKS - ordinary_start);
    return phase != M7_SERVICE_IDLE || M7_R(M7_REG_RAW_LEASE) || cache_queued;
}
