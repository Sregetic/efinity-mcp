# Low-resource Canny and reference-style edge display

2026-10-08. Implemented in the current SC431HAI/Ti60F225 build and programmed to SRAM. Flash unchanged.

## Actual whole-system resources

| | Previous deployed | This deployment | Delta |
|---|---:|---:|---:|
| XLR | 56818 | 57838 / 60800 | +1020 |
| RAM | 245 | 247 / 256 | +2 |
| DSP | 58 | 59 / 160 | +1 |

Final I3 timing: WNS +0.121ns, WHS +0.026ns; unassigned core pins0. Same IMAGE_DEBUG2, Sapphire, unified RAW pool, analysis DMA, no whole-display latency probe, seed1. Remaining2962XLR and9RAM. This is an image-quality improvement with a small resource increase, not a resource-count reduction. See resources.json and the native release route report.

## Implemented changes

- `vision_canny_nms` reuses the accepted front bitplane as a position hint. A previous pixel must still pass the current weak threshold and two-sided near-peak check (8 gradient units). A second sparse selection window removes a competing strict peak only when its neighbor has a validated same-direction anchor. Strong movement is immediate; flat/weak frames acquire no historical strong seed.
- Front-plane history reads use its idle write port; HDMI and blanking-time JTAG use the other port. The back plane remains writable. No extra full-frame history is allocated. The additional selection lines account for2RAM.
- `vision_canny_raster` adds64-level diagonal coverage around255-level cores using its existing nine-node cache. Binary masks used by shape recognition and FlyHash remain separate from presentation. Detection is still480x270; display is1920x1080. This softens diagonal presentation but retains the4-pixel detector grid.
- M2/M3 reuse the existing full-resolution Sobel magnitude for saturated8-bit strength (`mag/2`) after the current threshold. This borrows the reference project's continuous-strength presentation, not its four-direction operator or line-shift implementation. Threshold controls and binary classification are preserved. M4 remains the strong red overlay.
- The existing SC431HAI initialization now explicitly writes digital gain3e06/3e07=00/80 and starts0100=01 only after geometry, analog gain and orientation.166 entries replace164. Existing analog gain80/2a, exposure control, RAW10, lanes, clocks, pins, FOV and SC2210 external initialization are preserved. The local manufacturer SDK's gain table and cmos_gains_update establish the digital1x encoding. OV5640 RGB ISP registers are sensor-specific and were not transplanted.

## Measured live result

M6,Canny80,Sobel128,median0,memory0,ROIoff. Before and after are consecutive deployment stages at the same camera view; no manual lighting or camera adjustment.

| y320 live sampling | Before | After |
|---|---:|---:|
| Samples | 320 | 320 |
| Duration | 58.656s | 58.500s |
| Changed core positions among319 adjacent comparisons | 56 | 0 |
| Distinct core-position sets | 3 | 1 |
| Source rate | 30.005fps | 30.000fps |

Each after sample retained9 red core pixels; this was not an empty edge mask. Before positions248/252 and1864/1868 fluctuated; after positions252 and1868 stayed fixed. See before/live and after/live JSON and time-strip PNGs. These are sampled rows, not every pixel or frame.

A separate15s unheld M5 check after image export verified all four contour bands present, source13881→14324 and Canny epoch1527→1969. Canny continues publishing at about29.97fps; HDMI remains1080p60. A stable mask is not a frozen source or stopped Canny processor. See canny_progress.json.

The purple-background report remains outside optical acceptance. This turn's sampled source/display rows had no pixels meeting the recorded magenta criterion; the digital frozen overlay background also matches its source exactly. This does not substitute for observing the physical HDMI receiver over time.

## Simulation and actual image checks

- Production stable NMS at480x270:129600 pixels exactly match the original first-frame reference (2061 edges); next uniform frame has no stale edge, and publication immediately rearms capture.
- Production median/stable pipeline:10 noise/geometry cases,36864 pixel comparisons, noise-floor retry holds the accepted plane and later removes noisy flat output.
- Focused peak-noise/motion/flat/weak sparse tests; binary raster equivalence and antialias; history read concurrent with back writes, HDMI and JTAG probe; exact component pruning and threshold/overlay isolation. See verification.json.
- Current CPU/DMA still matches host for1024 gray pixels,128 features,32 hidden outputs,4 logits and256-bit FlyHash. DMA1.856ms, network2.808ms, total CPU6.796ms. This is the existing synthetic bring-up model, not actual-card recognition accuracy. See ai_check/validation.json.
- Five full1920x1080 images share frozen source3899/config1/Canny epoch27: source-before-Gamma, M0, M2, M5, M6. M5 has16442 core pixels,1395 halo pixels,12 components; smallest visible component365pixels. Overlay core and halo match the expected colors; every tested background pixel equals M0 with its established2x2 frontend coordinate offset. No background or halo blend mismatch. Sobel has119 grayscale levels outside OSD. See images/validation.json.
- Image export restored live M6,Canny80,Sobel128,median0,memory0,ROIoff. Sensor readback confirmed stream1 and gains00/80,80/2a. Images are digital pre-TMDS snapshots without a capture card; source.png is RGB before Gamma, not sensor RAW Bayer.

## Reference and upload scope

The user-supplied edge example was reviewed read-only: OV5640 RGB565→1280x720 four-direction Sobel→8-bit strength. No archive script was executed. Our full Canny, hysteresis, component filtering, source binding, AI, history and image readback remain present. The detailed prior review is in results/reference_review_20261008/REVIEW.md.

Snapshot upload contains modified source/tests and measured evidence only. Licensed generated SoC/IP and binary bitstreams/ELFs are excluded; guarded deployment scripts and CI workflows are preserved. PR remains draft pending physical display acceptance.
