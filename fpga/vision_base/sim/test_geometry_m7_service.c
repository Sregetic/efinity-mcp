#include <stdint.h>
void *memset(void *p, int v, unsigned n) {
    volatile unsigned char *b = p;
    while (n--)
        *b++ = v;
    return p;
}
#define CONTROL_TEST
#define VISION_GEOMETRY_M7
#define M7_SERVICE_TEST
static uint32_t control[32], geo[64], dma[32], ticks, request, publication, reads, face_calls, tag;
#define CTRL_R(o) control[(o) / 4]
#define CTRL_W(o, v) (control[(o) / 4] = (v))
#define CONTROL_STATE (&state)
extern struct vision_control_state state;
static uint32_t label_rows[64][2], label_cursor;
static unsigned track_publication;
static void geo_write(unsigned off, uint32_t value) {
    if (off == 0x38)
        label_cursor = value;
    else if (off == 0x80)
        label_rows[label_cursor][0] = value;
    else if (off == 0x84)
        label_rows[label_cursor++][1] = value;
    else if (off == 4)
        request = value;
    else if (off == 0x24) {
        publication = 2;
        geo[1] ^= 32;
        geo[1] |= 8;
    } else if (off == 0x9c) {
        track_publication = 2;
        geo[off / 4] = 1;
    } else
        geo[off / 4] = value;
}
static unsigned late_ready;
static uint32_t geo_read(unsigned off) {
    if (off == 8 && late_ready) {
        late_ready = 0;
        geo[1] |= 1;
        geo[2] ^= 1;
    }
    return geo[off / 4];
}
#define M7_R(o) geo_read(o)
#define M7_W(o, v) geo_write(o, v)
#define M7_DMA(o) dma[(o) / 4]
#define M7_TICKS ticks
#include "control_service.h"
#include "geometry_m7.h"
#include "geometry_face.h"
static uint32_t fly_read_word(unsigned i) {
    reads++;
    return i ^ 0x12340000u ^ tag;
}
#include "geometry_m7_service.c"
struct vision_control_state state;
struct m7_box m7_boxes[4], m7_face_boxes[4];
struct m7_contour m7_contours[M7_CONTOURS];
unsigned m7_count, m7_more, m7_complex, m7_contour_count, m7_face_count, m7_face_more;
struct m7_box m7_head_proposals[M7_HEAD_PROPOSALS];
unsigned m7_head_count;
static uint16_t raw_pixels[1920 * 1080];
static unsigned mock_dma, mock_fault, mock_mismatch, mock_delay, acquires, acks;
static unsigned mock_latest_frame;
static unsigned refine_enabled, refine_left, refine_calls, refine_keep_white;
static const uint8_t *refine_gray;
static unsigned face_left, face_tag, face_duration = 1000;
static unsigned face_work_ticks, geometry_work_ticks, letter_duration, letter_left, face_steps;
static void finish(unsigned ok) {
    *(volatile unsigned *)0x100000 = ok ? 0x5555 : 0x3333;
    for (;;)
        ;
}
static void text(const char *s) {
    while (*s)
        *(volatile unsigned char *)0x10000000 = *s++;
}
static void check(unsigned ok, unsigned line) {
    if (!ok) {
        text("FAIL service line ");
        char v[12];
        unsigned n = 0;
        do {
            v[n++] = '0' + line % 10;
            line /= 10;
        } while (line);
        while (n)
            *(volatile unsigned char *)0x10000000 = v[--n];
        text("\n");
        finish(0);
    }
}
#define CHECK(x) check((x), __LINE__)
void m7_retain(struct m7_box *b, unsigned *n, unsigned *more, struct m7_box v) {
    if (*n == 4) {
        *more = 1;
        return;
    }
    unsigned i = (*n)++;
    while (i && b[i - 1].area < v.area) {
        b[i] = b[i - 1];
        i--;
    }
    b[i] = v;
}
void m7_begin(const uint32_t *bits) {
    CHECK(bits[0] == (0x12340000u ^ tag) && bits[4049] == (0x12340000u ^ 4049 ^ tag));
    m7_count = 2;
    m7_boxes[0] = (struct m7_box){20 + tag, 25, 60 + tag, 70, 100, 2};
    m7_boxes[1] = (struct m7_box){100 + tag, 80, 150 + tag, 140, 90, 1};
    m7_contour_count = 1;
    m7_contours[0] = (struct m7_contour){tag, 10, 100, 120, 123, 0, 0};
}
void m7_letters_begin(const uint32_t *bits) {
    CHECK(bits[0] == (0x12340000u ^ tag));
    letter_left = letter_duration;
}
unsigned m7_letters_step(unsigned b) {
    CHECK(b == 64);
    ticks += geometry_work_ticks;
    return !letter_left || !--letter_left;
}
unsigned m7_step(unsigned b) {
    CHECK(b == 2048 || ((state.follow || state.trail) && b == 256));
    ticks += geometry_work_ticks;
    return 1;
}
void m7_face_begin(const uint32_t *bits, const struct m7_contour *c, unsigned n) {
    CHECK(bits[0] == (0x12340000u ^ tag) && n == 1 && c[0].x0 == tag);
    face_tag = tag;
    face_left = face_duration;
    face_calls++;
}
unsigned m7_face_step(unsigned b) {
    CHECK(b == 128);
    ticks += face_work_ticks;
    face_steps++;
    if (--face_left)
        return 0;
    m7_face_count = 1;
    m7_face_more = 0;
    m7_face_boxes[0] = (struct m7_box){200 + face_tag, 100, 240 + face_tag, 160, 300, 3};
    return 1;
}
unsigned m7_face_refine_begin(const uint8_t *gray, unsigned high, unsigned median) {
    CHECK(high == geo[0x2c / 4] && median == ((state.settings >> 3) & 1));
    refine_calls++;
    if (!refine_enabled)
        return 0;
    refine_gray = gray;
    refine_left = 400;
    return 1;
}
unsigned m7_face_refine_step(void) {
    CHECK(!geo[0x28 / 4] && cache_state == M7_CACHE_READY);
    if (refine_keep_white) {
        CHECK(refine_gray[100 * M7_CACHE_W + 200] == 255 &&
              refine_gray[369 * M7_CACHE_W + 679] == 255 && refine_gray[0] == 0);
    }
    if (--refine_left)
        return 0;
    m7_face_count = 2;
    m7_face_boxes[1] = (struct m7_box){270, 120, 300, 170, 200, 3};
    return 1;
}
static void dma_update(void) {
    if (track_publication && !--track_publication)
        geo[0x9c / 4] = 0;
    if (!mock_dma)
        return;
    if (dma[0] == 9 || dma[0] == 13) {
        CHECK(!(dma[1] & 3) && geo[0x28 / 4] && dma[0x14 / 4] == 0 &&
              dma[0x18 / 4] == (1920u | (1080u << 16)));
        unsigned frame = dma[0] == 13 ? mock_latest_frame : dma[2] + mock_mismatch;
        acquires++;
        dma[0] = 0;
        dma[1] = mock_delay ? 1 : mock_fault ? 6 : 2;
        dma[3] = frame;
        dma[4] = 77;
        dma[0x24 / 4] = mock_fault;
        dma[0x38 / 4] = (uint32_t)(uintptr_t)raw_pixels;
    } else if (dma[0] == 2) {
        CHECK(dma[1] & 2);
        acks++;
        dma[0] = dma[1] = 0;
    }
}
static unsigned step(void) {
    dma_update();
    if (publication && !--publication)
        geo[1] = (geo[1] & ~8u) | 4;
    ticks += 100;
    unsigned result = geometry_m7_service_step(1);
    dma_update();
    return result;
}
static void snapshot(unsigned frame, unsigned value, unsigned good) {
    tag = value;
    geo[6] = frame;
    geo[2] ^= 1;
    geo[1] = (geo[1] & 44) | 16 | 2 | (good ? 1 : 0);
}
static void new_geometry(unsigned frame, unsigned value) {
    unsigned seq = geometry.sequence;
    geo[0x34 / 4]++;
    for (unsigned n = 0; !request; n++) {
        step();
        CHECK(n < 10);
    }
    snapshot(frame, value, 1);
    for (unsigned n = 0; geometry.sequence == seq; n++) {
        step();
        CHECK(n < 100);
    }
    CHECK(!request && !dma[0]);
    if (geo[0x28 / 4])
        CHECK(dma[1] & 3);
}
#ifndef VISION_M7_NO_FACE
void main(void) {
    state.ai_policy = 2;
    state.ai_manual = CONTROL_MODEL_M7 << 1;
    state.settings = 5;
    geo[1] = 16;
    geo[0x2c / 4] = 96;
    geo[7] = 6;
    geo[8] = 9;
    geo[0x34 / 4] = 1;
    geo[0x28 / 4] = 1;
    dma[1] = 1;
    CHECK(step() == 1 && !request);
    dma[1] = 2;
    CHECK(step() == 0 && dma[0] == 2 && !geo[0x28 / 4]);
    dma[0] = dma[1] = 0;
    mock_dma = 1;
    for (unsigned i = 0; i < 1920 * 1080; i++)
        raw_pixels[i] = 0xffff;
    CHECK(!geometry_m7_service_step(0) && !request);
    CHECK(step() == 1 && request);
    snapshot(100, 1, 0);
    CHECK(!step() && !request);
    new_geometry(101, 2);
    CHECK(label_cursor == 64 &&
          ((uint64_t)label_rows[0][1] << 19 | label_rows[0][0]) == m7_label_row(2, 0));
    CHECK(reads == 4050 && face_calls == 1 && face_running && geometry.sequence == 1 &&
          face.sequence == 0);
    CHECK(geo[0x60 / 4] == 101 && (geo[0x78 / 4] & 8191) == (2 | (1 << 4) | (1 << 7)));
    new_geometry(102, 3);
    new_geometry(103, 4);
    CHECK(geometry.sequence == 3 && face.sequence == 0 && face_calls == 1 && geo[0x60 / 4] == 103 &&
          face_tag == 2);
    // A new snapshot can miss during VBlank without invalidating completed/independent work.
    unsigned saved_geo_seq = geometry_m7_lane_record[0], saved_face_calls = face_calls;
    geo[0x34 / 4]++;
    while (!request)
        step();
    snapshot(104, 6, 0);
    CHECK(step() && geo[0x28 / 4]);
    CHECK(geometry.valid && face_running && geometry_m7_lane_record[0] == saved_geo_seq &&
          face_calls == saved_face_calls);
    for (unsigned n = 0; n < 3; n++) {
        step();
        CHECK(geometry.valid && face_running);
    }
    while (!request)
        step();
    snapshot(103, 4, 1);
    while (phase != M7_SERVICE_IDLE)
        step();
    // Finish the old face while newer circle/rectangle data stays in the publication.
    for (unsigned n = 0; !face.valid; n++) {
        step();
        CHECK(n < 1100);
    }
    for (unsigned n = 0; dirty; n++) {
        step();
        CHECK(n < 10);
    }
    CHECK(geometry.frame == 103 && face.frame == 101 && geometry_m7_lane_record[1] == 103 &&
          geometry_m7_lane_record[9] == 101);
    CHECK(geo[0x60 / 4] == 101 && (geo[0x78 / 4] & 8191) == (3 | (1 << 4) | (1 << 7) | (1 << 10)));
    CHECK(geometry_m7_record[0] == 0x4d374733 && geometry_m7_record[2] == 101);
    // Frozen unchanged edges do not restart either classifier; changed edges do.
    unsigned gs = geometry.sequence, fc = face_calls;
    geo[0x34 / 4]++;
    while (!request)
        step();
    snapshot(103, 4, 1);
    while (phase != M7_SERVICE_IDLE)
        step();
    CHECK(geometry.sequence == gs && face_calls == fc);
    new_geometry(103, 5);
    CHECK(geometry.sequence == gs + 1 && face_calls == fc + 1);
    // Independent threshold change cancels both lanes and does not retain an old face.
    unsigned canceled = geometry_m7_record[22];
    geo[0x2c / 4] = 112;
    step();
    CHECK(geometry_m7_record[22] == canceled + 1 && !face_running && !face.valid &&
          !geometry.valid);
    while (!request)
        step();
    snapshot(104, 6, 1);
    while (phase != M7_SERVICE_IDLE)
        step();
    CHECK(geometry.valid && !face.valid && face_running);
    // A cancelled shared read never publishes a partial/new-frame result.
    geo[0x34 / 4]++;
    while (!request)
        step();
    tag = 7;
    geo[6] = 105;
    geo[1] &= ~1u;
    late_ready = 1;
    step();
    CHECK(phase == M7_COPY_BITMAP);
    geo[1] &= ~1u;
    step();
    CHECK(geometry.valid && geometry.frame == 104 && !face.valid && face_running &&
          face_job.frame == 104);
    // View/ROI context changes invalidate both independent sources.
    geo[7]++;
    geo[8]++;
    step();
    CHECK(!geometry.valid && !face.valid);
    while (!request)
        step();
    snapshot(106, 8, 1);
    while (phase != M7_SERVICE_IDLE)
        step();
    // Frozen/history source changes cancel an older face even without a settings change.
    state.settings = 5 | 16;
    step();
    while (!request)
        step();
    snapshot(200, 9, 1);
    while (phase != M7_SERVICE_IDLE)
        step();
    CHECK(face_running && face_job.frame == 200);
    unsigned before_faces = face_calls;
    new_geometry(201, 10);
    CHECK(face_running && face_job.frame == 201 && face_calls == before_faces + 1 && !face.valid);
    CHECK(cache_for_job && (cache_queued || dma[2] == 201));
    // Display selection does not select or disable recognition. Canny owns its threshold.
    state.settings = 5 | (96u << 9) | (80u << 20);
    state.sidebar_open = 0;
    control_event((255u << 24) | 2);
    CHECK(((state.settings >> 20) & 2047) == 96);
    control_event((255u << 24) | 4);
    CHECK(((state.settings >> 20) & 2047) == 80);
    state.sidebar_open = 2;
    state.sidebar_item = SIDE_THRESHOLD;
    state.sidebar_edit = 0;
    control_sidebar_keys(&state, 1);
    CHECK(state.edit_mode == 5 && state.edit_value == 80);
    control_sidebar_adjust(&state, 1);
    control_sidebar_adjust(&state, 1);
    control_sidebar_confirm(&state);
    CHECK(((state.settings >> 20) & 2047) == 112 && !state.sidebar_edit);
    state.sidebar_open = 0;
    control_event((23u << 24) | 144);
    CHECK(((state.settings >> 20) & 2047) == 144);
    control_event((1u << 24) | 2);
    control_event((2u << 24) | 160);
    CHECK(((state.settings >> 9) & 2047) == 160 && ((state.settings >> 20) & 2047) == 144);
    for (unsigned mode = 2; mode <= 6; mode++) {
        state.settings = (state.settings & ~7u) | mode;
        CHECK(control_geometry_enabled(&state));
    }
    state.ai_policy = 0;
    CHECK(!step() && !request && !face_running);
    state.ai_policy = 2;
    state.settings = 5;
    geo[1] = 17;
    step();
    new_geometry(300, 11);
    geometry.boxes[0].klass = M7_LOWER;
    face.valid = 0;
    dirty = 1;
    while (dirty)
        step();
    CHECK(geometry_m7_classes[0] == M7_LOWER && geometry_m7_classes[1] == M7_CIRCLE);
    CHECK((geometry_m7_record[5] >> 17) == 97 && ((geometry_m7_record[5] >> 14) & 7) == 1);
    CHECK((geometry_m7_record[9] >> 17) == 0 && label_cursor == 64);
    for (unsigned row = 0; row < 16; row++)
        CHECK(((uint64_t)label_rows[row][1] << 19 | label_rows[row][0]) ==
              m7_label_row(M7_LOWER, row));
    // Cache owns only an exact-frame short lease. Geometry advances while copying and refining.
    state.settings = 5 | 8;
    step();
    face_duration = 2;
    refine_enabled = 1;
    state.enabled = state.good = 1;
    state.commit[0] = (320u << 12) | 180;
    state.commit[1] = (640u << 12) | 360;
    state.commit[2] = (960u << 12) | 540;
    state.commit[3] = (400u << 12) | 200;
    new_geometry(400, 14);
    unsigned first_sequence = face.sequence;
    for (unsigned n = 0; face_running != M7_FACE_WAIT_CACHE; n++) {
        step();
        CHECK(n < 20);
    }
    CHECK(face.valid && face.frame == 400 && geo[0x28 / 4] && dma[2] == 400);
    new_geometry(401, 15);
    new_geometry(402, 16);
    CHECK(face.frame == 400 && geometry.frame == 402);
    for (unsigned n = 0; face_running != M7_FACE_FINE; n++) {
        unsigned busy = step();
        CHECK(busy || face_running == M7_FACE_FINE);
        CHECK(n < 1200);
    }
    CHECK(!geo[0x28 / 4] && !dma[1] && cache_index == sizeof(gray_cache));
    CHECK(map_x[199] == 65535 && map_x[200] == 320 && map_x[679] == 959 && map_x[680] == 65535);
    CHECK(map_y[99] == 65535 && map_y[100] == 180 && map_y[369] == 539 && map_y[370] == 65535);
    CHECK(geometry_m7_fine_record[2] == 400 && geometry_m7_fine_record[11] == 77);
    refine_keep_white = 1;
    for (unsigned i = 0; i < 1920 * 1080; i++)
        raw_pixels[i] = 0;
    unsigned left = refine_left;
    dma[1] = 1;
    CHECK(!geometry_m7_service_step(0) && refine_left == left - 1 && dma[1] == 1 && !geo[0x28 / 4]);
    dma[1] = 0;
    CHECK(!step() && face_running == M7_FACE_FINE);
    new_geometry(403, 17);
    for (unsigned n = 0; face_running; n++) {
        step();
        CHECK(n < 500);
    }
    CHECK(face.frame == 400 && geometry.frame == 403 && face.count == 2 &&
          face.sequence >= first_sequence + 1 && geometry_m7_fine_record[1] == 1);
    // An expired or mismatched exact frame keeps only coarse results, never substitutes latest.
    refine_keep_white = 0;
    mock_fault = 1;
    unsigned calls = refine_calls;
    new_geometry(500, 18);
    while (face_running)
        step();
    CHECK(!geo[0x28 / 4] && geometry_m7_fine_record[12] == 1 && refine_calls == calls &&
          dma[2] == 500);
    mock_fault = 0;
    mock_mismatch = 1;
    new_geometry(501, 19);
    while (face_running)
        step();
    CHECK(geometry_m7_fine_record[12] == 128 && !geo[0x28 / 4] && refine_calls == calls);
    mock_mismatch = 0;
    mock_delay = 1;
    new_geometry(502, 20);
    CHECK(geo[0x28 / 4] && dma[1] == 1);
    state.ai_policy = 0;
    CHECK(step() && !face.valid && !geometry.valid && cache_state == M7_CACHE_DRAIN);
    dma[1] = 2;
    mock_delay = 0;
    CHECK(!step() && !geo[0x28 / 4] && !dma[1]);
    // An unrelated AI completion is neither consumed nor acknowledged by inactive M7.
    dma[1] = 2;
    unsigned old_acks = acks;
    CHECK(!geometry_m7_service_step(0) && dma[1] == 2 && acks == old_acks);
    dma[1] = 0;
    CHECK(acquires == acks);
    // Fixed M7 performs one source transaction per explicit request, including a frozen repeat.
    state.ai_policy = 1;
    state.ai_manual = CONTROL_MODEL_M7 << 1;
    state.ai_request = 900;
    refine_enabled = 0;
    geo[1] = 16;
    geo[0x2c / 4] = 96;
    new_geometry(600, 21);
    while (face_running)
        step();
    unsigned fixed_seq = geometry.sequence, fixed_faces = face_calls;
    for (unsigned i = 0; i < 50; i++)
        step();
    CHECK(!request && geometry.sequence == fixed_seq && face_calls == fixed_faces);
    state.ai_request++;
    while (!request)
        step();
    snapshot(600, 21, 1);
    while (phase != M7_SERVICE_IDLE)
        step();
    while (face_running)
        step();
    CHECK(geometry.sequence == fixed_seq + 1 && face_calls == fixed_faces + 1);
    // Live picker consumes independent lane publications without waiting for a same-frame face.
    while (dirty || publication)
        step();
    state.target_session = 1;
    state.center_stage = CENTER_TARGET_SCAN;
    state.target_index = 4;
    state.target_sequence = state.target_ready = 0;
    face.frame--;
    dirty = 1;
    publish();
    publication = 0;
    geo[1] = (geo[1] & ~8u) | 4;
    snapshot_targets(&state);
    CHECK(state.target_ready && state.target_count == 3 && state.target_index == 0);
    CHECK(state.target_frames[0] == 599 && state.target_frames[1] == 600 &&
          state.target_context == geometry.context);
    CHECK((state.target_sequence & 1) == ((geo[1] >> 5) & 1));
    // Same physical rectangle remains selected after face removal and area-order changes.
    state.center_stage = CENTER_TARGET_PICK;
    state.target_index = 1;
    face_duration = 1000;
    new_geometry(601, 22);
    while (dirty || publication)
        step();
    snapshot_targets(&state);
    CHECK(state.target_count == 2 && state.target_index == 0 && state.target_frames[0] == 601);
    new_geometry(602, 23);
    while (dirty || publication)
        step();
    snapshot_targets(&state);
    CHECK(state.target_count == 2 && state.target_frames[0] == 602 && state.target_index == 0);
    // UI-only VS commits do not cancel the private face job or geometry.
    unsigned cancels = geometry_m7_record[22], left_face = face_left;
    state.feature_wait = 1;
    for (unsigned i = 0; i < 4; i++)
        step();
    CHECK(geometry_m7_record[22] == cancels && face_running && face_left <= left_face);
    state.feature_wait = 0;
    // Reordering by area keeps the selected rectangle, not the old row number.
    struct m7_box selected_box = geometry.boxes[0];
    geometry.boxes[0] = geometry.boxes[1];
    geometry.boxes[0].area = 200;
    geometry.boxes[1] = selected_box;
    dirty = 1;
    publish();
    publication = 0;
    geo[1] = (geo[1] & ~8u) | 4;
    snapshot_targets(&state);
    CHECK(state.target_index == 1 && ((state.target_classes >> 7) & 127) == M7_RECTANGLE);
    // Equally plausible same-class overlaps cancel selection instead of choosing arbitrarily.
    state.target_index = 0;
    selected_box = geometry.boxes[0];
    geometry.boxes[1] = selected_box;
    geometry.boxes[0].x0 -= 4;
    geometry.boxes[0].x1 -= 4;
    geometry.boxes[1].x0 += 4;
    geometry.boxes[1].x1 += 4;
    dirty = 1;
    publish();
    publication = 0;
    geo[1] = (geo[1] & ~8u) | 4;
    snapshot_targets(&state);
    CHECK(state.target_index == 4);
    // Disappearance clears selection; new arrivals do not silently become the old selection.
    geometry.count = 0;
    face.valid = 0;
    dirty = 1;
    publish();
    publication = 0;
    geo[1] = (geo[1] & ~8u) | 4;
    snapshot_targets(&state);
    CHECK(!state.target_count && state.target_index == 4 && state.target_ready);
    geometry.count = 2;
    dirty = 1;
    publish();
    publication = 0;
    geo[1] = (geo[1] & ~8u) | 4;
    snapshot_targets(&state);
    CHECK(state.target_count == 2 && state.target_index == 4 && !(control_ui(&state) & (4u << 19)));
    state.sidebar_edit = 1;
    state.sidebar_item = SIDE_CENTER;
    control_sidebar_keys(&state, 1);
    CHECK(state.center_stage == CENTER_TARGET_PICK);
    control_sidebar_keys(&state, 4);
    CHECK(state.target_index == 0);
    control_sidebar_keys(&state, 2);
    CHECK(state.target_index == 1);
    // Closing a picker entered from fixed policy stops its temporary continuous acquisition.
    state.target_session = 0;
    state.ai_policy = 1;
    step();
    unsigned closed_sequence = geometry.sequence;
    for (unsigned i = 0; i < 40; i++)
        step();
    CHECK(!request && geometry.sequence == closed_sequence);
    state.sidebar_edit = 0;
    state.ai_policy = 0;
    step();
    CHECK(!geometry.valid && !face.valid && !request && acquires == acks);
    // Logical independence must also bound shared-CPU interference from an expensive face slice.
    state.ai_policy = 2;
    state.settings = 5;
    face_duration = 100000;
    letter_duration = 20;
    face_work_ticks = 50000;
    geometry_work_ticks = 1000;
    geo[0x34 / 4]++;
    while (!request)
        step();
    snapshot(700, 22, 1);
    for (unsigned n = 0; phase != M7_RUN_LETTERS; n++) {
        step();
        CHECK(n < 100);
    }
    unsigned faces_before = face_steps;
    for (unsigned n = 0; phase != M7_SERVICE_IDLE; n++) {
        step();
        CHECK(n < 25);
    }
    CHECK(geometry.valid && geometry.frame == 700 && face_running);
    CHECK(face_steps - faces_before <= 2);
    face_work_ticks = geometry_work_ticks = 0;
    state.ai_policy = 0;
    for (unsigned n = 0; step(); n++)
        CHECK(n < 10);
    CHECK(!geometry.valid && !face.valid && !request && acquires == acks);
    text("PASS RV32I independent geometry/face, exact raw lease/cache release, immutable ROI gray, "
         "AI ownership, missing/mismatched frame, cancellation, source IDs, VS publication and "
         "original UI controls\n");
    finish(1);
}
#endif
void trap(void) {
    text("TRAP\n");
    finish(0);
}
