#define main previous_service_main
#include "test_geometry_m7_service.c"
#undef main
static unsigned scene_x = 700, scene_y = 400;
static void value(uint32_t v) {
    const char *h = "0123456789abcdef";
    for (int n = 28; n >= 0; n -= 4)
        *(volatile unsigned char *)0x10000000 = h[v >> n & 15];
}
static void vector(unsigned n) {
    text("TRACK ");
    value(n);
    uint32_t row[12] = {
        scene_x,         scene_y,        96, 96, state.commit[0], state.commit[1], state.commit[2],
        state.commit[3], followed.frame, 0,  0,  state.serial};
    for (unsigned i = 0; i < 12; i++) {
        text(" ");
        value(row[i]);
    }
    text("\n");
    text("TRAIL ");
    value(n);
    for (unsigned i = 0; i < 67; i++) {
        text(" ");
        value(follow_rows[i]);
        text(" ");
        value(follow_rows[i] >> 32);
    }
    text("\n");
}
static void scene(unsigned x, unsigned y) {
    scene_x = x;
    scene_y = y;
    for (unsigned i = 0; i < 1920 * 1080; i++)
        raw_pixels[i] = 0x8000;
    for (unsigned yy = 0; yy < 96; yy++)
        for (unsigned xx = 0; xx < 96; xx++)
            if (xx < 8 || xx >= 88 || yy < 8 || yy >= 88 ||
                (yy >= 24 && yy < 64 && xx >= yy - 8 && xx < yy))
                raw_pixels[(y + yy) * 1920 + x + xx] = 0xffff;
}
static struct tt_reference seed(void) {
    struct tt_reference r = {.frame = 10, .ms = 0, .x = scene_x, .y = scene_y, .w = 96, .h = 96};
    for (unsigned yy = 0; yy < 64; yy++)
        for (unsigned xx = 0; xx < 64; xx++) {
            int x = (int)scene_x + 48 + ((int)xx - 32) * 4,
                y = (int)scene_y + 48 + ((int)yy - 32) * 4;
            uint8_t rgb[3];
            fomo_rgb(raw_pixels[y * 1920 + x], rgb);
            follow_gray[yy * 64 + xx] = rgb[0];
        }
    tt_sobel(follow_gray, follow_edges, 40);
    for (unsigned y = 0; y < 32; y++)
        r.edges[y] = follow_edges[y + 16] >> 16;
    return r;
}
static void advance_follow(unsigned ms, unsigned frame) {
    geo[0xa0 / 4] = ms;
    mock_latest_frame = frame;
    for (unsigned n = 0; n < 100; n++) {
        dma_update();
        ticks += 100;
        follow_step(&state, 1);
        dma_update();
        if (!follow_phase && followed.frame == frame)
            break;
        CHECK(n < 99);
    }
    // Completed geometry observations feed the automatic overlay independently of the selected
    // tracker.
    if (state.trail && followed.state == TT_LOCKED) {
        struct mt_detection d = {scene_x, scene_y, 96, 96, M7_RECTANGLE};
        unsigned slots[4];
        mt_observe(&all_targets, &d, 1, frame, ms, slots);
        follow_dirty = 1;
        for (unsigned n = 0; n < 3; n++) {
            dma_update();
            follow_step(&state, 0);
        }
    }
}
void main(void) {
    mock_dma = 1;
    state.ai_policy = 2;
    state.ai_manual = CONTROL_MODEL_M7 << 1;
    state.settings = 5 | (80u << 20);
    state.follow = state.trail = 1;
    state.track_request = 1;
    state.track_sequence = picker_reference_sequence = 7;
    state.track_class = M7_RECTANGLE;
    scene(700, 400);
    picker_references[0] = seed();
    state.roi[0] = (508u << 12) | 313;
    state.roi[1] = (480u << 12) | 270;
    state.roi[2] = (1920u << 12) | 1080;
    state.serial = 1;
    state.enabled = state.good = 1;
    for (unsigned n = 0; n < 4; n++)
        state.commit[n] = state.roi[n];
    control[0x18 / 4] = 1;
    geo[0x1c / 4] = 1;
    geo[1] = 16;
    geo[0x2c / 4] = 80;
    advance_follow(1, 11);
    CHECK(followed.state == TT_LOCKED && followed.observations == 1 && !follow_dma &&
          acquires == acks);
    for (unsigned n = 1; n <= 10; n++) {
        scene(700 + n * 8, 400 + n * 4);
        advance_follow(1 + n * 67, 11 + n);
        CHECK(followed.state == TT_LOCKED && followed.x == 748 + (int)n * 8 &&
              followed.y == 448 + (int)n * 4);
        CHECK(state.roi[1] == ((480u << 12) | 270) && state.roi[2] == ((1920u << 12) | 1080));
        CHECK(state.pending == 1 && state.serial == follow_serial);
        state.pending = 0;
        state.good = 1;
        for (unsigned k = 0; k < 4; k++)
            state.commit[k] = state.roi[k];
        control[0x18 / 4] = geo[0x1c / 4] = state.serial;
        follow_step(&state, 1);
        if (n == 1 || n == 2 || n == 4 || n == 6 || n == 8 || n == 10)
            vector(n);
    }
    CHECK(geometry_m7_track_record[11] <= 67 && followed.count == 11);
    unsigned saved = followed.count;
    advance_follow(750, 21);
    CHECK(followed.count == saved); // HDMI repeats do not append.
    // Trail-only observes the same target while the user moves to a full panorama.
    state.follow = 0;
    state.enabled = 0;
    state.roi_enable = 0;
    state.serial++;
    scene(780, 440);
    advance_follow(820, 22);
    CHECK(followed.state == TT_LOCKED && followed.count == saved + 1 && !state.pending);
    unsigned last_x = followed.x;
    for (unsigned n = 0; n < 1920 * 1080; n++)
        raw_pixels[n] = 0x8000;
    advance_follow(887, 23);
    CHECK(followed.state == TT_HOLD && followed.x == last_x && followed.count == saved + 1);
    scene(780, 440);
    advance_follow(954, 24);
    CHECK(followed.state == TT_LOCKED && followed.count == saved + 2);
    for (unsigned n = 0; n < 1920 * 1080; n++)
        raw_pixels[n] = 0x8000;
    advance_follow(1021, 25);
    CHECK(followed.state == TT_HOLD);
    geo[0xa0 / 4] = 1500;
    follow_step(&state, 0);
    CHECK(followed.state == TT_HOLD && !follow_dma && state.track_status == TT_HOLD);
    scene(780, 440);
    advance_follow(1600, 26);
    CHECK(followed.state == TT_LOCKED && followed.count == saved + 3);
    geo[0xa0 / 4] = 4701;
    follow_step(&state, 1);
    CHECK(followed.state == TT_LOST && !follow_dma && state.track_status == TT_LOST);
    unsigned seq = followed.observations;
    scene(788, 440);
    geo[0xa0 / 4] = 4800;
    follow_step(&state, 1);
    CHECK(followed.observations == seq && followed.state == TT_LOST);
    // Reselection clears the old trajectory and uses the selected descriptor, not a moving row
    // number.
    picker_references[2] = seed();
    state.track_index = 2;
    state.track_request++;
    state.track_sequence = picker_reference_sequence = 9;
    advance_follow(5667, 30);
    CHECK(followed.state == TT_LOCKED && followed.count == 1 && followed.x == 836);
    state.track_index = 0;
    scene(796, 440);
    advance_follow(5734, 31);
    CHECK(followed.x == 844 && followed.count == 2);
    // Own ROI commits do not restart copied slow classification or its private face job.
    state.follow = 1;
    state.serial = follow_serial = 100;
    state.pending = 1;
    follow_roi_observation = followed.observations;
    initialized = 1;
    phase = M7_RUN_LETTERS;
    letter_left = 3;
    face_credit = 0;
#ifndef VISION_M7_NO_FACE
    face_running = M7_FACE_COARSE;
    face_left = 1000;
#endif
    job.frame = 900;
    job.render = 99;
    job.context = 99;
    face_job = job;
    settings = state.settings;
    threshold = geo[0x2c / 4];
    render = 99;
    context = 99;
    geo[0x1c / 4] = geo[0x20 / 4] = 100;
    run_policy = state.ai_policy;
    run_model = CONTROL_MODEL_M7;
    run_picker = config_wait = 0;
    m7_count = 1;
    m7_boxes[0] = (struct m7_box){20, 20, 40, 40, 400, M7_RECTANGLE};
    unsigned canceled = geometry_m7_record[22], class_sequence = geometry.sequence;
    for (unsigned n = 0; n < 3; n++)
        geometry_m7_service_step(1);
    CHECK(geometry.sequence == class_sequence + 1 && geometry.frame == 900 &&
          geometry_m7_record[22] == canceled);
#ifndef VISION_M7_NO_FACE
    CHECK(face_running && face_job.frame == 900);
#else
    CHECK(!face_running && !face_calls && !refine_calls);
#endif
    CHECK((geometry_m7_record[5] & 7) == 0); // Old-view boxes are never placed on the new crop.
    state.pending = 0;
    state.good = 1;
    state.settings = (state.settings & ~7u) | 2;
    state.settings ^= 256u << 9;
    follow_step(&state, 1);
    CHECK(followed.state ==
          TT_LOCKED); // Sobel display mode/threshold does not redefine the shared Canny reference.
    // A different ROI config cannot be silently treated as an automatic follow commit.
    state.follow = 1;
    state.serial++;
    advance_follow(5801, 32);
    CHECK(!state.follow);
    state.settings |= 16;
    follow_step(&state, 1);
    CHECK(followed.state == TT_LOST);
    state.follow = state.trail = 0;
    follow_step(&state, 1);
    CHECK(followed.state == TT_OFF && !followed.count && acquires == acks);
    // Completing an old source job may add a real historical point, never a stale ROI commit.
    state.settings &= ~48u;
    state.follow = state.trail = 1;
    state.pending = 0;
    state.enabled = state.good = 1;
    state.serial = 200;
    state.roi[0] = (650u << 12) | 350;
    for (unsigned i = 0; i < 4; i++)
        state.commit[i] = state.roi[i];
    picker_references[0] = seed();
    state.track_index = 0;
    state.track_sequence = picker_reference_sequence = 13;
    state.track_request++;
    geo[0xa0 / 4] = 7000;
    mock_latest_frame = 100;
    for (unsigned n = 0; follow_phase != 4; n++) {
        dma_update();
        follow_step(&state, 1);
        CHECK(n < 30);
    }
    unsigned serial_before = state.serial;
    geo[0xa0 / 4] = 7700;
    for (unsigned n = 0; follow_phase; n++) {
        dma_update();
        follow_step(&state, 1);
        CHECK(n < 50);
    }
    CHECK(followed.state == TT_HOLD && followed.observations == 1 &&
          followed.points[followed.head].ms == 7000 && state.serial == serial_before &&
          !state.pending);
    advance_follow(7770, 101);
    CHECK(followed.state == TT_LOCKED && followed.observations == 2 &&
          state.serial == serial_before + 1 && state.pending);
    // ROI boundary invalidates display edges, not the follower's shared raw DMA ownership.
    state.pending = state.feature_wait = 0;
    state.good = 1;
    geo[0xa0 / 4] = 7900;
    mock_latest_frame = 102;
    for (unsigned n = 0; follow_phase != 2; n++) {
        dma_update();
        follow_step(&state, 1);
        CHECK(n < 10);
    }
    CHECK(follow_dma && (dma[1] & 2));
    geo[1] = 0;
    CHECK(geometry_m7_service_step(1));
    geo[1] = 16;
    phase = M7_COPY_BITMAP;
    CHECK(geometry_m7_service_step(1));
    state.feature_wait = config_wait = 1;
    CHECK(geometry_m7_service_step(1));
    for (unsigned n = 0; follow_dma; n++) {
        dma_update();
        unsigned busy = geometry_m7_service_step(1);
        dma_update();
        CHECK(!follow_dma || busy);
        CHECK(n < 10);
    }
    CHECK(!geo[0x28 / 4] && acquires == acks);
    text("PASS TRK1 actual packed raw/Sobel, shared lease release, fixed zoom/ROI, measured "
         "timestamps/frame dedup, panorama trail-only, hold/lost/reselection/list reordering, "
         "independent slow work across own ROI and manual ROI ownership\n");
    finish(1);
}
