#define main previous_service_main
#include "test_geometry_m7_service.c"
#undef main
static void geometry_at(unsigned frame, unsigned ms, unsigned tag_value) {
    geo[0xa0 / 4] = ms + 100;
    geo[0xa8 / 4] = ms;
    new_geometry(frame, tag_value);
    for (unsigned n = 0; dirty; n++) {
        step();
        CHECK(n < 10);
    }
    for (unsigned n = 0; motion_published_revision != all_targets.revision; n++) {
        step();
        CHECK(n < 10);
    }
}
void main(void) {
    state.ai_policy = 2;
    state.ai_manual = CONTROL_MODEL_M7 << 1;
    state.settings = 5 | (80u << 20) | (1u << 31);
    state.trail = 1;
    state.sidebar_item = SIDE_TRAIL;
    state.track_status = TT_LOST;
    CHECK(control_sidebar_value(&state) == 1);
    state.track_status = 0;
    geo[1] = 16;
    geo[0x2c / 4] = 80;
    geo[0x34 / 4] = 1;
    geometry_at(100, 1000, 0);
    CHECK(!state.follow && !state.track_request && !state.center_request && !state.serial &&
          !acquires);
    CHECK((follow_rows[66] >> 32) == 2 && !follow_rows[0]);
    CHECK(geometry_m7_motion_record[2] == 1000);
    geometry_at(101, 1500, 5);
    CHECK((follow_rows[66] >> 32) == 4 && geometry.directions == (3 | (3 << 3)));
    CHECK(!state.serial && !state.pending && !state.target_session && !acquires);
    // An ROI-only transform cannot become target motion in panoramic source coordinates.
    job.frame = 102;
    job.ms = 2000;
    job.render = 4;
    job.map[0] = 0;
    job.map[1] = (960u << 12) | 540;
    job.map[2] = (1920u << 12) | 1080;
    job.map[3] = 0;
    struct m7_box boxes[2] = {{50, 50, 131, 141, 100, 2}, {210, 160, 311, 281, 90, 1}};
    observe_targets(boxes, 1);
    CHECK(geometry.directions == 1);
    unsigned rectangle = 0;
    while (all_targets.targets[rectangle].box.klass != 2)
        rectangle++;
    CHECK(all_targets.targets[rectangle].box.x == 100 &&
          all_targets.targets[rectangle].box.y == 100);
    // Keeping the same source point visible through a crop changes its raster location, not stored
    // history.
    state.enabled = state.good = 1;
    state.serial = 4;
    for (unsigned i = 0; i < 4; i++)
        state.commit[i] = job.map[i];
    follow_dirty = 1;
    geo[0x9c / 4] = 0;
    follow_publish(&state);
    CHECK((follow_rows[66] & 0xffffffffu) == 4);
    unsigned mapped = 0;
    for (unsigned i = 0; i < (follow_rows[66] >> 32); i++)
        if ((follow_rows[18 + i] & 511) == 81 && ((follow_rows[18 + i] >> 9) & 511) == 96)
            mapped = 1;
    CHECK(mapped);
    struct tt_point a = {.x = 0, .y = 100}, b = {.x = 1919, .y = 100};
    uint64_t clipped;
    CHECK(follow_segment(&a, &b, &clipped, 3) && (clipped & 511) == 0 &&
          ((clipped >> 18) & 511) == 479);
    geo[0xa0 / 4] = 2400;
    follow_dirty = 1;
    geo[0x9c / 4] = 0;
    follow_publish(&state);
    unsigned medium = 0;
    for (unsigned i = 0; i < (follow_rows[66] >> 32); i++)
        medium |= (follow_rows[18 + i] >> 36) == 2;
    CHECK(medium);
    geo[0xa0 / 4] = 3400;
    follow_dirty = 1;
    geo[0x9c / 4] = 0;
    follow_publish(&state);
    unsigned dim = 0;
    for (unsigned i = 0; i < (follow_rows[66] >> 32); i++)
        dim |= (follow_rows[18 + i] >> 36) == 1;
    CHECK(dim);
    state.trail = 0;
    follow_dirty = 1;
    geo[0x9c / 4] = 0;
    follow_publish(&state);
    CHECK(!(follow_rows[66] >> 32));
    state.trail = 1;
    state.enabled = 0;
    geo[0xa0 / 4] = 5100;
    for (unsigned i = 0; i < 5; i++)
        step();
    CHECK(!(follow_rows[66] >> 32));
    text("PASS MTK1 automatic all-target history without selection/ROI/DMA; source timestamps, "
         "direction payload, crop inverse/forward transform and switch/expiry\n");
    finish(1);
}
