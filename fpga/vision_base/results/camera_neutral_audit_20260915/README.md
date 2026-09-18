# Neutral-color audit
Current unity-gain, horizontal Bayer-phase diagnostic retained. No RTL or bitstream change in this turn.
Actual current debayer chain tested with a two-dimensional linear grayscale RAW ramp. 260 interior output pairs checked, all six RGB components preserve neutral gray within each pixel; 0 mismatches. This is a synthetic linear-ramp test, not full demosaic correctness or physical sensor phase proof.
Fresh JTAG snapshots: discard first stale observation. Seven subsequent snapshots show scene means R25.4 G35.3 B29.7 approximately; green maximum 255 in all seven, red max167..171 blue213..221. These extrema may occur at different coordinates. This proves some green samples reach digital full scale, not the size or location of clipped regions, and does not measure white-window RGB.
No coefficient derived from whole-scene mean. A non-clipped neutral target or spatially identified ROI is still needed for white balance calibration.
