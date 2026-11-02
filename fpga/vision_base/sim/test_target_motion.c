#include <assert.h>
#include <stdio.h>
#include "target_motion.h"
static struct target_motion m;
static unsigned slots[4];
static void observe(struct mt_detection *d, unsigned n, unsigned frame, unsigned ms) {
    mt_observe(&m, d, n, frame, ms, slots);
}
int main(void) {
    struct mt_detection d[4] = {{100, 100, 80, 80, 2},
                                {1000, 100, 80, 80, 2},
                                {100, 700, 80, 80, 1},
                                {1000, 700, 80, 80, 4}};
    observe(d, 4, 10, 100);
    unsigned id = m.targets[slots[0]].id;
    assert(id && m.targets[slots[0]].count == 1);
    struct mt_detection swap = d[0];
    d[0] = d[1];
    d[1] = swap;
    d[1].x += 40;
    d[0].x -= 40;
    d[2].y -= 40;
    d[3].y += 40;
    observe(d, 4, 11, 350);
    assert(m.targets[slots[1]].id == id && m.targets[slots[1]].direction == 3);
    assert(m.targets[slots[0]].direction == 2 && m.targets[slots[2]].direction == 4 &&
           m.targets[slots[3]].direction == 5);
    observe(d, 4, 12, 600);
    for (unsigned i = 0; i < 4; i++)
        assert(m.targets[slots[i]].direction == 1);
    unsigned revision = m.revision;
    observe(d, 4, 12, 700);
    assert(m.revision == revision);
    // A short miss adds no manufactured position and a uniquely associated return keeps identity.
    observe(d, 0, 13, 850);
    observe(d, 4, 14, 1100);
    assert(m.targets[slots[1]].id == id);
    for (unsigned i = 0; i < 4; i++)
        assert(m.targets[slots[i]].count == 4);
    for (unsigned i = 0; i < 4; i++) {
        struct mt_target *t = m.targets + slots[i];
        assert(!(t->links & (1u << ((t->head + t->count - 1) % MT_POINTS))));
    }
    // Two equally plausible same-class positions may not inherit either old trajectory.
    m = (struct target_motion){0};
    d[0] = (struct mt_detection){400, 200, 80, 80, 2};
    d[1] = (struct mt_detection){600, 200, 80, 80, 2};
    observe(d, 2, 1, 0);
    unsigned a = m.targets[slots[0]].id, b = m.targets[slots[1]].id;
    d[0].x = 498;
    d[1].x = 502;
    observe(d, 2, 2, 1000);
    assert(m.targets[slots[0]].id != a && m.targets[slots[0]].id != b &&
           m.targets[slots[1]].id != a && m.targets[slots[1]].id != b);
    assert(m.targets[slots[0]].count == 1 && m.targets[slots[1]].count == 1);
    mt_expire(&m, 4000);
    for (unsigned i = 0; i < 4; i++)
        assert(!m.targets[i].count);
    // The fixed display budget retains three seconds for all four objects at <=4 samples/s each.
    m = (struct target_motion){0};
    for (unsigned f = 0; f < 200; f++) {
        d[0] = (struct mt_detection){f % 180, 0, 80, 80, 2};
        d[1] = (struct mt_detection){1000, 900, 80, 80, 1};
        observe(d, 2, f, 0xfffff000u + f * 67u);
        for (unsigned i = 0; i < 4; i++)
            assert(m.targets[i].count <= 12);
    }
    unsigned total = 0;
    for (unsigned i = 0; i < 4; i++)
        total += m.targets[i].count;
    assert(total > 0 && total <= 48);
    mt_expire(&m, 0xfffff000u + 200u * 67u + 3000);
    for (unsigned i = 0; i < 4; i++)
        assert(!m.targets[i].count);
    printf("PASS MTK1 reorder, four directions/stop, frame dedup, miss/return, ambiguous crossing, "
           "expiry, frame edges and timestamp wrap; workspace=%zu bytes\n",
           sizeof(m));
}
