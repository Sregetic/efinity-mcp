# Archived M7 pixel-comparison model

This 239632-byte pico cascade is retained for the previously deployed firmware and recovery. It is no longer embedded in the edge-only M7 release. M7 now uses the same accepted edge contours for circle, rectangle and frontal-face geometry; no trained face model is loaded.

Original source (MIT): https://github.com/nenadmarkus/pico/blob/346881039e5d1f5abe64733a49886bdfd5ab2d51/rnt/cascades/facefinder
Original paper: https://arxiv.org/abs/1305.4537

Independent TinyML/FOMO/connectome models and modes remain unchanged. Candidate status and tests: `results/geometry_edge_split_20261028/REPORT.md`.
