#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "target_track.h"
static struct target_track t;
static uint64_t grid[64];
static struct tt_reference reference(void) {
    struct tt_reference r = {.frame = 10, .ms = 100, .x = 400, .y = 300, .w = 96, .h = 96};
    for (unsigned y = 4; y < 28; y++) {
        r.edges[y] = (1u << 5) | (1u << 26);
        if (y == 4 || y == 27)
            r.edges[y] = 0x07ffffe0;
        if (y >= 9 && y < 19)
            r.edges[y] |= 1u << (y - 2);
    }
    return r;
}
static void exact_scores(void) {
    for (unsigned row = 0; row < 25; row++)
        for (unsigned col = 0; col < 25; col++) {
            unsigned misses = 0, extras = 0, pixels = 0, difference = 0, shift = 4 + col,
                     top = 4 + row;
            for (unsigned y = 0; y < 32; y++) {
                uint32_t v = grid[top + y] >> shift,
                         near = (grid[top + y - 1] | grid[top + y] | grid[top + y + 1]) >> shift;
                near |= near << 1 | near >> 1;
                misses += __builtin_popcount(t.reference.edges[y] & ~near);
                extras += __builtin_popcount(v & ~t.near[y]);
                pixels += __builtin_popcount(v);
                difference += __builtin_popcount(v ^ t.reference.edges[y]);
            }
            assert(t.scores[row * 25 + col] == (misses * 2000 + extras * 1000 + difference * 100) /
                                                   (t.reference_count + pixels));
        }
}
static void shape(int dx, int dy) {
    for (unsigned y = 0; y < 32; y++)
        grid[16 + y + dy] |= (uint64_t)t.reference.edges[y] << (16 + dx);
}
static void observation(int dx, int dy, unsigned frame, unsigned ms) {
    memset(grid, 0, sizeof(grid));
    shape(dx, dy);
    assert(tt_begin(&t, grid, frame, ms, frame % 6));
    unsigned calls = 0;
    while (!tt_step(&t, 16))
        assert(++calls < 50);
    exact_scores();
}
int main(void) {
    struct tt_reference r = reference();
    tt_select(&t, &r);
    assert(t.state == TT_LOCKED);
    int origin = t.x;
    for (unsigned n = 1; n <= 20; n++) {
        observation(2, 1, 10 + n, 100 + 67 * n);
        assert(t.state == TT_LOCKED && t.x == origin + 8 * (int)n);
    }
    int stopped = t.x;
    for (unsigned n = 21; n <= 35; n++) {
        observation(0, 0, 10 + n, 100 + 67 * n);
        assert(t.state == TT_LOCKED && t.x == stopped);
    }
    for (unsigned n = 36; n <= 55; n++) {
        observation(-2, -1, 10 + n, 100 + 67 * n);
        assert(t.state == TT_LOCKED);
    }
    assert(t.x == origin && t.count <= 46);
    for (unsigned n = 0; n < t.count; n++)
        assert(t.ms - t.points[(t.head + n) % TT_POINTS].ms < 3000);
    unsigned measured = t.observations;
    tt_expire(&t, t.ms + 600);
    assert(t.state == TT_HOLD && t.observations == measured && !t.misses);
    observation(0, 0, 90, t.ms + 667);
    assert(t.state == TT_LOCKED && t.observations == measured + 1);
    unsigned count = t.count;
    assert(!tt_begin(&t, grid, t.frame, t.ms + 33, 0) && t.count == count);
    unsigned before = t.observations;
    memset(grid, 0, sizeof(grid));
    assert(tt_begin(&t, grid, 100, t.ms + 67, 0));
    while (!tt_step(&t, 100))
        ;
    assert(t.state == TT_HOLD && t.observations == before && t.count == count);
    observation(1, 0, 101, t.ms + 67);
    assert(t.state == TT_LOCKED && t.observations == before + 1);
    unsigned x = t.x;
    memset(grid, 0, sizeof(grid));
    assert(tt_begin(&t, grid, 102, t.ms + 600, 0));
    while (!tt_step(&t, 100))
        ;
    assert(t.state == TT_HOLD && t.x == x);
    assert(tt_begin(&t, grid, 103, t.ms + 400, 0));
    while (!tt_step(&t, 100))
        ;
    assert(t.state == TT_HOLD);
    assert(tt_begin(&t, grid, 104, t.ms + 600, 0));
    while (!tt_step(&t, 100))
        ;
    assert(t.state == TT_LOST && t.x == x);
    assert(!tt_begin(&t, grid, 105, t.ms + 1, 0));
    tt_select(&t, &r);
    assert(!t.count);
    memset(grid, 0, sizeof(grid));
    shape(-10, 0);
    shape(10, 0);
    assert(tt_begin(&t, grid, 20, 167, 3));
    while (!tt_step(&t, 100))
        ;
    assert(t.state == TT_LOST && t.ambiguities == 1 && !t.count);
    // Two indistinguishable targets converge/cross: once ambiguous, even a single merged peak
    // cannot silently relock.
    for (int crossing = -6; crossing <= 6; crossing += 2) {
        memset(grid, 0, sizeof(grid));
        shape(crossing, 0);
        shape(-crossing, 0);
        assert(!tt_begin(&t, grid, 30 + crossing, 300 + crossing * 10, 3) && t.state == TT_LOST &&
               !t.count);
    }
    tt_select(&t, &r);
    t.x = 1;
    t.y = 1079;
    uint32_t xy;
    assert(tt_roi(&t, 240, 136, 500, 500, &xy));
    assert((xy >> 12) <= 1680 && (xy & 4095) <= 944);
    for (unsigned n = 0; n < 20; n++)
        if (tt_roi(&t, 240, 136, xy >> 12, xy & 4095, &xy))
            assert((xy >> 12) <= 1680 && (xy & 4095) <= 944);
    tt_select(&t, &r);
    observation(0, 0, 200, 167);
    tt_expire(&t, 3167);
    assert(!t.count);
    tt_expire(&t, 3268);
    assert(t.state == TT_LOST);
    // A slow classifier must not discard a valid position job merely because it took over 500ms.
    tt_select(&t, &r);
    memset(grid, 0, sizeof(grid));
    shape(1, 0);
    assert(tt_begin(&t, grid, 210, 200, 0));
    assert(!tt_step(&t, 16));
    tt_expire(&t, 800);
    assert(t.state == TT_HOLD);
    while (!tt_step(&t, 100))
        ;
    assert(t.state == TT_LOCKED && t.observations == 1 && t.points[t.head].ms == 200);
    tt_expire(&t, 800);
    assert(t.state == TT_HOLD);
    observation(0, 0, 211, 867);
    assert(t.state == TT_LOCKED && t.observations == 2);
    tt_select(&t, &r);
    memset(grid, 0, sizeof(grid));
    assert(tt_begin(&t, grid, 201, 200, 3));
    assert(!tt_step(&t, 1) && t.best_index == 24);
    tt_select(&t, &r);
    assert(tt_begin(&t, grid, 202, 200, 5));
    assert(!tt_step(&t, 1) && t.best_index == 600);
    uint8_t gray[4096] = {0};
    for (unsigned y = 20; y < 44; y++)
        for (unsigned x0 = 20; x0 < 44; x0++)
            gray[y * 64 + x0] = 255;
    tt_sobel(gray, grid, 80);
    assert(grid[20] && grid[19]);
    puts("PASS measured edges: moving/turn/stop, duplicate frames, 3-second aging, hold/loss, "
         "identical-target ambiguity, reselection, ROI bounds and Sobel");
}
