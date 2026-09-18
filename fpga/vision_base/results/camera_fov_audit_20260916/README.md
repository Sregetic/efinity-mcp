# FOV scope audit
Current sensor window registers 0x3200..0x3213 match both supplied SC431HAI camera-to-HDMI and camera-to-DSI reference examples exactly. Exposure/gain/mirror differ; no claim that those differences are zoom.
Window width1920 height1080 column-start324 row-start5. Prior live geometry confirmed1920x1080; four-pixel order defect fixed and visual clarity confirmed by user.
Top sensor_clipper instantiation is commented out. No active zoom/scaler found in current camera top path. Source check alone does not measure lens FOV or sensor internal register readback.
Configured crop relative documented2560x1440 full active array has linear factor4/3, not several-fold zoom. Phone-relative magnification remains unquantified because lens focal length, sensor size, phone lens mode and matched orientation are not established.
Priority changed by user to FOV. No black-level, Gamma, color or bitstream change this turn. Full-field acquisition with reduction to1080p would require matching sensor timing/readout, memory row sizing and reduction; do not merely alter HDMI mode or sensor dimensions and call it complete.
