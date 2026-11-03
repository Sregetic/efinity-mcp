# Archived pico runtime

Unmodified upstream MIT source, Nenad Markus:
https://github.com/nenadmarkus/pico/tree/346881039e5d1f5abe64733a49886bdfd5ab2d51

The edge-only M7 firmware no longer links this runtime or the pixel-intensity cascade. Circles, rectangles and frontal-face outlines now share the accepted Canny plane and the contour extractor in `geometry_m7.c`. Independent AI modes are unchanged.

The prior Pico path, its per-scale offset-cache experiment and FP32 tests are historical evidence in `results/geometry_latency_20261028/` and `results/geometry_edge_split_20261028/before/`. The current Flash release uses shared edge-contour geometry. These upstream files remain only for recovery of earlier releases.
