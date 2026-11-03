#include <stdio.h>
#include <stdlib.h>
#include "geometry_letters.c"
int main(int argc, char **argv) {
    uint32_t bits[M7_WORDS];
    for (int a = 1; a < argc; a++) {
        FILE *f = fopen(argv[a], "rb");
        if (!f)
            return 2;
        if (fread(bits, 4, M7_WORDS, f) != M7_WORDS)
            return 3;
        fclose(f);
        m7_begin(bits);
        while (!m7_step(2048))
            ;
        m7_letters_begin(bits);
        unsigned steps = 0;
        while (!m7_letters_step(64))
            steps++;
        printf("{\"path\":\"%s\",\"steps\":%u,\"more\":%u,\"boxes\":[", argv[a], steps, m7_more);
        for (unsigned i = 0; i < m7_count; i++)
            printf("%s[%u,%u,%u,%u,%u]", i ? "," : "", m7_boxes[i].klass, m7_boxes[i].x0,
                   m7_boxes[i].y0, m7_boxes[i].x1, m7_boxes[i].y1);
        printf("],\"candidates\":[");
        for (unsigned i = 0; i < count; i++) {
            const struct candidate *c = candidates + i;
            printf("%s[%u,%u,%u,%u,%u,%u,%u,%u,%u]", i ? "," : "", c->box.x0, c->box.y0,
                   c->box.klass, c->accepted, c->score, c->paired,
                   m7_letter_templates[c->reference].letter, c->box.x1, c->box.y1);
        }
        puts("]}");
    }
}
