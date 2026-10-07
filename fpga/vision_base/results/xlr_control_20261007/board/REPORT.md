# SRAM deployment and Canny/color incident

2026-10-07. User approved SRAM deployment and subsequently reported jumping
Canny contours and intermittent purple backgrounds. The two photos retain
`CANNY OV T0080 MED0 F0 I0 C1 R0080` while the background changes color.
**The reported visual regression remains open.** A successful build, a reset,
or the absence of purple pixels in a sampled row is not optical acceptance.

## Deployed version

- SRAM: `../release_freeze_fix/ti60f225_oob.bit`; Flash unchanged.
- DDR: `../control_ai_freeze_fix/vision.elf`, 5868 program bytes, with the
  existing 4400-byte synthetic bring-up model. Actual load/readback passed.
- ROM bootstrap: `../control_firmware_freeze_fix/vision.elf`, text3760 bytes;
  application remains inside the existing3840-byte limit.
- 56818 XLR,245 RAM,58 DSP; final WNS+0.074ns/WHS+0.026ns, unassigned pins0.
  Resource counts match the optimization candidate. Regenerated SoC RTL is
  byte-identical to its predecessor; only ROM initialization data changed.
- Final display: M6,Canny80,Sobel128,median0,memory0,ROIoff. Real-time source
  acquisition restored; no detector, HDMI timing, pin or clock changes.

## Confirmed control bug and fix

Entering ROI and freeze together from ROIoff could wait forever for a fresh
capture: the source had already been published and freeze pinned it. CPU state
showed `warming=1,pending=1`, hardware job_ready1/freeze1/capture3367. Firmware
now submits the frozen published source without waiting for the next capture.

The production RV32I test covers this entry path. Board verification passed
both after loading the updated AI application (`cold_freeze_fix.json`) and
from the newly rebuilt ROM before loading AI
(`permanent_fix_rom_cold_freeze.json`, source427/config1). This fixes the
diagnostic freeze deadlock, not the original purple photo in live F0 mode.

## Pixel evidence

`live_color60/rows.json` contains320 pre-Gamma source rows and320 final M6
rows, all at y480, over58.531 seconds. Display source IDs10370→12125 advanced
at about29.99fps. RGB averages stayed within the recorded narrow ranges;
no sampled pixel met R>G+30 and B>G+30. This is a sparse temporal sample,
not inspection of every pixel or every output frame.

The red contour count stayed9 per row, but two positions alternated
236/240 and1448/1452. Of319 successive comparisons,211 changed. This
4-display-pixel step matches the480×270 analysis grid; it does not establish
that all visual instability has the same cause. With median1 at the same
Canny80,93 of159 comparisons changed: median alone did not eliminate it.
See `canny_median_comparison.json`.

On frozen source2706, all32 pre-Gamma rows and all32 final color/contour rows
were byte-identical (`frozen_rows_after_fix`). This separates input-dependent
position changes from nondeterministic rendering on that fixed source.

## Other runtime checks

- Initial optimized deployment: `live60.json`,59.563 seconds, about29.985fps
  source acquisition; RAW overflow, capture discard and scan-bad increments0.
- ROI full/zoom/pan/small placement reused source12353, configs3–6
  (`roi/board.verification.json`). Full-frame render exceeded the60Hz budget;
  source acquisition rate is not full-frame ROI rendering rate.
- DDR FlyHash after the freeze fix:64 FPGA occupancy features and256-bit hash
  exactly matched the host, source2706/config2. This is encoding, not trained
  recognition accuracy (`flyhash_after_freeze_fix/result.json`).
- Final loaded AI: source/config6332, all1024 gray pixels,128 features,
  32 hidden outputs,4 logits and256-bit hash matched the host. DMA2.27509ms,
  network2.78377ms, total CPU6.28395ms (`final_ai_result/validation.json`).
  Synthetic labels are not real-card accuracy evidence.

## Unresolved observations

Before reinitialization, camera frame-start count advanced but accepted RX
width/lines/words were0, and the CPU code readback matched the ROM application
instead of the previously loaded AI application. The initiating reset/event
was not established. Reprogramming the same optimized design restored payload
reception. Preserve `incident_*` evidence; do not call this a purple-root fix.

An immediate post-program USER1 load returned mismatched/zero memory and was
kept halted. Reprogramming, waiting12 seconds and observing firmware state1
before loading passed. No automatic retry or speculative loader change was
added. The first failure is retained in `ai_freeze_fix_load/`.

The six-history test's strict descending-ID assumption was invalid: memory2
is automatic replay and rotates every half second during multi-page reads.
Its six IDs were unique, but this run is not recorded as a chronological
history acceptance. Actual physical key and sustained HDMI visual acceptance
remain pending. Canny position refinement and the purple source/output split
remain the next image-quality work; no extra frame RAM was added here.

## Independent full-image review, after the user left the hardware

The FPGA exported and the agent visually inspected four complete1920×1080
images: pre-Gamma source, M0 camera, M5 Canny and M6 overlay. All rows bound
source18546/config3; the Canny plane stayed at epoch26. Export passed and
automatically restored M6/Canny80/median0/memory0/ROIoff. Files and binding
checks are in `full_image_review/`.

The current frozen background has no purple cast. Excluding the OSD, the M6
red mask exactly equals the M5 white mask. M6 uses the existing two-window RGB
frontend while median-off M0 bypasses it: after compensating that2×2 center
coordinate delay, every checked non-overlay background pixel equals M0.
The unaligned difference count in `review.json` is not color corruption.

Outside the OSD, the Canny frame has16619 white pixels in15 connected
components, minimum181 pixels. There are no independent tiny components in
this specific frame. Stair steps and occasional kinks on the long contours
remain visible; this is not recorded as a completed Canny-quality fix.

After restoring live operation, an additional58-second run captured640 rows
across y120/360/600/900, alternating source and final M6 output. All four
positions advanced source IDs; none of the sampled rows showed purple pixels
by the recorded R/G/B rule. See `final_live_multirow/summary.json` and the
reproducible `final_live_multirow_check.py`. Digital inspection continues to
distinguish these sampled pixels from physical HDMI receiver behavior.
