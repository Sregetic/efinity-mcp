# Display gamma correction
Prior camera output bypassed gamma. Existing 2P2.mem maps 8-bit64->12 and128->56 (darkening), so was not enabled. Added distinct display_gamma_2p2.mem: 1024-entry 10-bit LUT round(1023*(i/1023)^(1/2.2)). Existing LUT preserved.
Enabled gamma_sel=1; debugger probe routed to unused wire to avoid multiple drivers. Camera RGB and sync selected through existing gamma block. Calibrated gains R256 G230 B256, sensor exposure, crop, Bayer alignment, pixel ordering and HDMI clocks unchanged.
Simulation uses actual gamma_correction and project RAM, allows 4096 cycles LUT preload; all256 grayscale inputs and blanking/control checks passed. Example 8-bit mappings19->78,64->136,128->187,255->255. Pure power-law display curve, not exact sRGB or measured monitor calibration.
Fresh P&R WNS+0.510ns WHS+0.026ns; JTAG SRAM download completed. Hardware visual confirmation pending. Existing A6 ROI telemetry is PRE-gamma; do not interpret its RGB means as post-gamma brightness.
