# White-target ROI calibration
User supplied white-paper screen photograph. Central ROI x[832,1088), y[412,668), 256x256 pixels. Frame-held sum/min/max read over JTAG USER2 A6; first snapshot discarded. Target assumed to remain in ROI per user setup; no direct HDMI capture available.
Before gain: 7 stable ROI means approximately R18.98 G21.76 B18.87; maxima <=28, no digital clipping. Not full-frame averages.
Changed only green gain from Q8.8 256 to 230 (0.8984375), leaving red/blue256. Existing 8-bit truncation means observed ratio differs from ideal multiplication. Retained RGGB alignment diagnostic, corrected packing, crop, exposure, Gamma-off, clocks.
After: 7 stable ROI means approximately R18.984 G18.751 B18.873; max channel mean spread about1.24 percent of mean. No claim of full scene colorimetry, alternate lighting calibration, or resolved crop.
Build WNS+0.454ns WHS+0.026ns, JTAG SRAM programming passed. Artifacts manifest and SHA256 saved. User visual confirmation pending. Existing sensor black-level/exposure and diagnostic border behavior remain separate work.
