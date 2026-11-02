#include <assert.h>
#include <stdio.h>
#include "geometry_m7.c"
int main(void) {
    static struct m7_context g;
    g.npoints = 2;
    g.points[0] = 0;
    for (unsigned y = 0; y < M7_H; y++)
        for (unsigned x = 0; x < M7_W; x++) {
            g.points[1] = x | (y << 9);
            assert(distance(&g, 0, 1) == x * x + y * y);
            assert(distance(&g, 1, 0) == x * x + y * y);
            assert(coordinate_product(x, y) == (int)(x * y));
            assert(coordinate_product(-(int)x, y) == -(int)(x * y));
            assert(coordinate_product(x, -(int)y) == -(int)(x * y));
            assert(coordinate_product(-(int)x, -(int)y) == (int)(x * y));
        }
    puts("PASS M7 signed coordinate products/norms across the full input domain");
}
