# 2026-09-16 bright-window exposure trial

Baseline build 2609160d: exposure 1776 half-line units. Reproduced bright-window RAW sample (240 Bayer tiles): near-saturated fractions B/G1/G2/R = 35.42/47.92/47.50/46.25 percent; all maxima 255. Global highlight guard hits approximately 1,123,800 pixels/frame.

Trial build 2609160e: only image-affecting change is exposure 444 half-line units (registers 3e00/3e01/3e02 = 00/1b/c0), one quarter of prior integration. Version tags and host parser support updated. White balance, tone3, FOV, DDR and feature logic unchanged. Source backups in backups/exposure_window_20260916; baseline artifacts preserved in results/highlight_color_20260916.

Fresh compile exit0, WNS +0.434ns, WHS +0.026ns; programmer read ID 10660A79 and completed SRAM programming; USER2 confirms 2609160e, M0/live, tone3 and RGB gains 162/161/256. Capture/display IDs advance.

Post-program RAW sample near-saturated fractions B/G1/G2/R = 5.00/15.00/14.58/12.92 percent; all maxima still255. Highlight hits approximately307,000 pixels/frame. This is a material reduction, not elimination of clipping. Before/after are separate live captures, not an identical stored frame; camera/lighting stability depends on the user's maintained setup. Outdoor detail and indoor shadow acceptability remain pending visual feedback. Do not claim HDR or automatic exposure implemented.
