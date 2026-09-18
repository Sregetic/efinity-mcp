# Live geometry measurement
2026-09-15. Camera build with observational USER2 A4 telemetry only; no image arithmetic, crop, gain or HDMI timing change.
Discarded first unprimed JTAG read. Nine subsequent snapshots agree:
RX maximum accepted beats/line 480; lines/frame 1080; accepted beats/frame 518400; pixel_per_clk 4; datatype 0x2b.
RX counts therefore correspond to 1920 x 1080 and 2073600 pixel slots/frame.
HDMI pre-encoder minimum/maximum DE width 1920/1920, lines/frame 1080, DE samples/frame 2073600.
Counts do not prove distinct pixels, correct ordering, sensor optical resolution, or absence of internal sensor crop/binning.
P&R WNS +0.436 ns, WHS +0.026 ns. JTAG SRAM programming succeeded. Existing Bayer fix retained.
Further audit: top writes four RAW samples in descending bus-slice order; DDR unpack emits most-significant 16-bit segments first; top swaps the two bytes before debayer. Need verify CSI output pixel ordering before declaring this a defect or changing it.
