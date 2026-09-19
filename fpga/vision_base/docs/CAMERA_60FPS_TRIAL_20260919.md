# Current deployment: full-resolution 30fps retained

User decision on2026-09-19: stop60fps experiments and keep30fps.
The final30fps-default diagnostic build was programmed to SRAM successfully.
No60fps register writes were performed after this decision. Flash was untouched.

- Sensor:2560x1440 RAW10; measured frame-sync30.062fps, completed DDR frames29.970fps.
- All sampled raw frames:640 words/line,1440 lines,921600 four-pixel words.
- FOV output:480 words/line,1080 lines,518400 words; late0.
- Overruns0→0; cumulative DDR write errors1→1(no increase during observation).
- M0 live, tone3, AE enabled, median1, threshold64. Canny fault remained0.
- Sensor clock registers restored and read back:36EB=0D,36EC=65.
- CSI debug clock wiring repaired. Observed flags8000/8002 mean initialized,
  FIFO sometimes empty; no CRC/ECC/undersize/initialization error flags observed.
- P&R WNS+0.355ns, WHS+0.026ns, unassigned pins0.
- Bitstream SHA256:cf5355cd1dbc8736e3d05e69bbc7acfe45393e2e24e46eb54d37bad24a6809aa.
- Hardware counters pass; current physical image quality remains user-observed.

Canny prefetch/frame scheduling and four-stage Sobel changes remain intact.
Sobel220MHz is the earlier isolated synthesis/timing result, not the whole-board
runtime clock. Raising camera FPS is deferred; the experiments below are evidence,
not production60fps presets. The rejected receiver soft-reset operation was removed.

Current evidence:`results/camera_60fps_20260919/final30_summary.json` and
`final30_capture.json`, `final30_raw.json`, `final30_fov.json`, `final30_errors.json`.

---
# SC431HAI 60fps trial — 2026-09-19

## Earlier checkpoint (historical)

Full 2560x1440 RAW10 60fps is NOT accepted. The final board is restored to the
original sensor mode with the new diagnostic bridge, M0/live, tone3 and AE enabled.
Sensor boot ROM is byte-identical to the pre-trial ROM.

Final raw input: 29.993 fps; completed DDR frames:
30.014 fps. Every sampled raw frame has 640 words/line,
1440 lines, 921600 four-pixel words and datatype 0x2B. FOV output is 480 words/line,
1080 lines, 518400 four-pixel words, late=0. Overrun counter:
[0, 0]; write-error counter: [1, 1].
The pre-existing cumulative write-error count is retained, not reset or hidden.

Bitstream SHA256: `79342ba89d485aa8fc8a5866f3f87240f8df8b46d79d5a3637a58ac240f11bd2`.
Diagnostic build P&R: WNS +0.353 ns, WHS +0.026 ns, RAM221/256, unassigned pins0.

## Observations

Read-back: sensor ID0xCD6B, preset0x301F=0x10, width2560, height1440,
HTS0x320C/D=0x0578 (1400), VTS0x320E/F=0x05DC (1500).
The counter before ISP/DDR proves the original mode is approximately30fps.
VTS is already close to active height; halving VTS is not a full-height60fps solution.

- Complete high-throughput clock subset from the same-model OpenIPC driver:
  approximately53.315 syncs/s but zero complete raw pixel frames. Rejected.
- Live0x36EB 0x0D→0x0C: approximately59.985 syncs/s, but only720 lines and
  460800 words/frame. This is half the required payload. Rejected, not reported as60fps.
- Adding0x37FC 0x21→0x20: approximately59.922 syncs/s, still720 lines. Rejected.
- Adding0x37FB 0x54→0x44: approximately59.940 syncs/s, still720 lines. Rejected.
- Complete clock subset applied live: approximately53.367 syncs/s, incomplete
  geometry. The conditional HTS adjustment was NOT executed because geometry failed.

Stopping/gating and restarting the sensor during one trial left the receiver
without valid pixels even after register restoration. Reprogramming the verified
30fps-default diagnostic bitstream restored complete frames. Live divider-only
changes were reversible through register writes. These observations do not prove
whether the remaining high-speed limitation is inside sensor mode programming or
receiver timing; they localize it before the Canny/HDMI processing stages.

## Changes retained

- Single-owner I2C bridge in sensor_exposure_writer; diagnostic read/write plus
  verified write readback, timeout response, and arbitration with AE.
- JTAG op16 read/op17 write; page9 transaction status; page13 raw frame count and
  geometry; page14 FOV geometry and overrun counter.
- Exposure regression and diagnostic transaction tests passed, including concurrent
  AE arbitration, readback mismatch, timeout and retry.
- No sensor60fps boot preset was committed. ISP/Canny/HDMI arithmetic unchanged.
- `scripts/sensor_register_control.py` is the retained host interface. The three
  trial scripts are labeled rejected experiments, not production presets.

## Source boundary and continued investigation

SmartSens product list specifies SC431HAI60fps:
https://www.smartsenstech.com/en/products_list

Clock-only candidate source (the full WDR configuration was NOT copied):
https://github.com/OpenIPC/openhisilicon/blob/main/libraries/sensor/hi3516cv6xx/smart_sc431hai/sc431hai_cfg.h

The OpenIPC driver is a 30fps linear / 30fps two-exposure WDR driver, NOT a validated
60fps linear initialization for this module. Its clock subset was a bounded
experiment only. Reference HDMI V1/V6 and DSI examples inspected use the same
clock register group as the working30fps baseline.

Additional user-supplied material is not a prerequisite for further diagnosis.
The follow-up uses the existing archive, physical byte-clock/burst counters,
receiver-delay calibration, and a cold-start clock-profile experiment. Full60fps
remains unaccepted until raw geometry, DDR publications, error deltas and visual
quality pass. See the follow-up section below for current findings.

Evidence and trial data: `results/camera_60fps_20260919/`.
Exact prior stable backup: `backups/camera_60fps_20260919/`.


## Follow-up: existing-materials investigation

The summary above describes the earlier restored checkpoint, not every later
experimental bitstream. All follow-up evidence is under `link_probe/`.

- Archive inventory covers HDMI V1/V3/V4/V5/V6 and DSI V3.4/V3.5; the same
  sensor PLL group is used by each. No second validated linear60 table was found.
- Only36EB=0C doubles frame-sync rate while physical burst rate stays ~43.3k/s
  and byte-clock peak stays40MHz: the resulting720-line frame is incomplete.
- Paired36EB=0C/36EC=55 doubles byte-clock peak to79MHz and physical burst rate
  to~86.5k/s, but live transition produces no complete decoded frame.
- Dynamic input-delay interface compiled with WNS+0.341ns/WHS+0.026ns and no
  unassigned pins. Exact tap-count simulation covered0/1/8/17/63 and clock pauses.
- A newly introduced combined receiver/FIFO soft reset invalidated even the30fps
  baseline. Isolated A/B evidence (`reset_isolation.json`) shows baseline and
  delay-only complete, reset-after-delay empty. The soft-reset connection was
  withdrawn; `delay_scan.json` is rejected as a contaminated experiment.
- The corrected scan (`delay_scan_no_reset.json`) starts with full30fps geometry,
  then scans16 common input-delay settings without reset. No full60 candidate.
- Next controlled experiment initializes the paired high-rate clock values from
  sensor startup rather than changing active clocks. ISP/Canny/HDMI arithmetic
  is unchanged. Separate DE/HS counts and CSI error flags are observational only.

Cold-start follow-up: full paired-clock cold start still yielded only the first
640-word line; all64 common dynamic taps were scanned without a full frame.
The zero-valued CSI debug flags in this run are invalid as error evidence:
`axi_clk` and `axi_reset_n` were tied to0 in the inherited integration, whereas
Efinix's CSI2 RX UG v3.2 Table8 places debug status in the AXI clock/reset domain.
The next build connects the debug/CSR domain to core_clk/i_arstn and restores the
original30fps boot ROM. No claim of error-free high-speed traffic is made.
Source: https://www.efinixinc.com/docs/mipi-csi2-rx-core-ug-v3.2.pdf

