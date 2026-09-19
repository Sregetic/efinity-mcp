# HDMI and advanced features acceptance — 2026-09-18

Scope: Ti60F225I3 + SC431HAI, HDMI 1920x1080@60 output. Implements advanced challenges A1–A5; A6 shape recognition excluded. LCD DSI instance removed from build; pins held inactive. Canny ping-pong edge planes restored. Camera ISP/AE retained; raw diagnostic snapshot remains disabled.

| Challenge | Implementation | Acceptance |
|---|---|---|
| A1 Median | 3x3 parallel comparison network, gray/Sobel branch, runtime enable | RTL tested; physical noise/edge comparison pending |
| A2 Threshold | Debounced short/long buttons and JTAG, frame-boundary settings | RTL tested; hardware readback and buttons pending |
| A3 DDR | Eight slots, six completed frames, live/freeze/replay/alternating comparison | RTL tested; runtime frame-ID checks pending |
| A4 Canny | 480x270 area-downsampled input; Gaussian/gradient/NMS/dual threshold/exact 8-connectivity | 129600-pixel reference test passed,2061 edges,0 mismatches; double-buffer publication restored |
| A5 Overlay | M4 Sobel red overlay, M6 Canny red overlay | Source present; motion/frame alignment must be observed |

Modes: M0 color/M1 gray/M2 Sobel/M3 gray-Sobel split/M4 Sobel overlay/M5 Canny/M6 Canny overlay/M7 color-gray split.
Storage: F0 live/F1 frozen/F2 six-frame replay/F3 alternating two-history-frame comparison. Replay is not a video recorder. Comparison is alternating, not simultaneous two-image display.
Buttons per existing mapped board labels: KEY0 short next mode, long median; KEY2 short threshold+16 (F0/F1) or history index+ (F2/F3), long toggle live/freeze; KEY3 short threshold-16 or history index-, long cycle freeze/replay/compare; KEY1 existing reset. Check physical labels against actual board before use.
Canny result rate is scene-dependent and separate from60Hz HDMI refresh. The four-stage220MHz Sobel optimization and zero-frame-delay direct path are not claimed verified by this restoration. Canny overlay may lag moving source objects because it uses a previously completed result.

Use scripts/verify_hdmi_runtime.ps1 for hardware mode/median/threshold readback, live/frozen/replayed frame IDs and Canny activity. Physical stable HDMI, actual button operation, color and overlay alignment remain separate checks.

## Verified build and runtime
Build identity page0 26091706; SRAM programming completed on ID0x10660A79. Full source-checked compile PASS: WNS+0.339ns,WHS+0.026ns,0 unassigned core pins,RAM216/256. Bit SHA256 5CCB070FE628E6350DC2AB3026D3D8C34A6D939664EBE222838A15D3E059207D.
All ten feature RTL tests passed including full Canny comparison and preservation of old displayed edge plane before publication. Runtime verification passed all8 modes, median0/1, thresholds32/128, live advancing frameIDs, frozen constant frameID, replay/comparison changing historyIDs, Canny publications with fault0.
AE enabled,25 applied updates observed,exposure request/applied1776 and readback006f00 agree,AE fault0,shadow_boost1. This confirms control activity, not final image-quality calibration.
A short2.384s scene sample measured30.20 capture frames/s and7.97 Canny results/s; HDMI raster is60Hz. This is not a worst-case benchmark or a claim of improved Canny speed. Further throughput optimization remains required.
Final state M0/F0/T64/MED1. Physical HDMI image, actual button operation, overlay alignment and long-run visual stability awaiting user verification. Evidence: results/hdmi_restore_20260918/.


## 2026-09-19 follow-up

Four-stage Sobel now passes an isolated Ti60F225 I3 220 MHz post-route target.
Canny prefetch and frame scheduling are integrated and SRAM-programmed; current-scene
result publications increased from 20.045 to 29.953 fps, with unchanged 480x270
analysis and 1080p60 HDMI. See [the optimization evidence](CANNY_SOBEL_220_20260919.md)
for scope, test results and the retained write-frame counter exception. The
220 MHz claim is core timing capacity, not a 220 MHz whole-camera clock change.
