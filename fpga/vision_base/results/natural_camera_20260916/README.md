# Natural camera mode: build 26091700

## Implemented and programmed
- Preserve measured BGGR interpretation, physical R/B output mapping, BLC16 and calibrated physical WB162/161/256. No guessed color-correction matrix, no unmeasured sensor-specific calibration claim.
- Restrict highlight neutralization to at least two channels near RAW clipping (RAW239..253) AND all channels bright (RAW160..216). Ordinary colors remain on the common RGB gain path, avoiding independent-channel Gamma desaturation.
- Added a monotone, zero-preserving shadow tone curve (up to6x near black) alongside the existing4x curve. Central RAW mean controls selection with hysteresis48/60; selection is synchronized and committed at frame boundary. This is global shadow tone mapping, not local HDR.
- RAW metering uses4080 sparse pairs/frame and1024 central samples before WB/black correction. AE updates at most once per8 fresh source-frame settling interval, using1/16 exposure steps, exposure limits112..1776 half-line units, target/deadband and highlight constraints. Repeated frozen/replayed source ID does not drive changes.
- Startup I2C table retains exclusive bus ownership until finished. Runtime writes3e00/01/02 then reads all three bytes back before acknowledging exposure. Readback mismatch or200ms timeout latches fault and halts further AE writes.
- Fixed previously undriven i2c_16addr_8data.dout with correctly delayed synchronous RX capture.
- No changes to FOV, video timing, DDR/history or Canny algorithm. White balance remains fixed calibration, not automatic white balance.

## Evidence
Five focused RTL tests pass: standard tone800 samples, shadow tone800 samples, AE direction/deadband/freeze/fault/manual, writer sequencing/readback/mismatch/timeout, synchronous I2C RX timing. Both256-entry curves are monotone with zero/white endpoints.
Fresh build: WNS+0.262ns, WHS+0.026ns, exit0. Source135 hashes match manifest (generated header comment normalized).
SRAM programming completed with correct10660A79 ID; USER2 build26091700 read back. Current M0/live.
Initial live scene: request/applied exposure1776,25 verified updates, sensor readback006f00, AEfault0. This shows autonomous increase from444 with actual sensor readback, not just a host-side setting. Center RAW mean~47, saturation0/4080, shadow boost active. Capture/display IDs advance, Cannyfault0; write_errors1 stable over sampled interval (not a zero-error claim).
Bright-window downward response, return-to-interior behavior, perceived neutral white and color fidelity await user scene positioning/visual acceptance. No claim that phone multi-frame HDR or complete color-chart calibration is achieved.

## Controls
Use Efinity environment then scripts/vision_control.py:
--page11: applied/request exposure, verified update count, readback, AE fault/busy/enabled/shadow
--page12: center mean, counts, clipping fraction, last AE decision
--ae0 --exposure444: manual hold; --ae1: restore autonomous mode
Exposure manual range112..1776. Manual settings also wait for a fresh displayed frame and readback confirmation.

Backups: backups/natural_camera_20260916. Earlier full artifact baseline: results/highlight_color_20260916. Current immutable build identity: manifest.json and build_status.json in this directory. SRAM only; power-off does not persist this bitstream.
