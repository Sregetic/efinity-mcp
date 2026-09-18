# Pixel order finding and fix
Official Efinix CSI2 RX v3.2 Table 19: first RAW10 pixel is DATA[9:0], then [19:10], [29:20], [39:30].
Source: https://www.efinixinc.com/docs/mipi-csi2-rx-core-ug-v3.2.pdf
Actual project ser2par_v1 + vid_par2ser, ideal FIFO/DDR storage model, top input/output byte wiring: input 0,1,2,3,4,5,6,7 produced 3,2,1,0,7,6,5,4. Before: 32/32 pairs failed. Fix reverses input 32-bit concatenation only. After: 32/32 pairs passed; full 1920 pixel row (8-bit modulo counter) 960 pairs passed. This is packing-order proof, not physical DDR integrity proof.
Backup top.before.v. Current board SRAM loaded corrected camera bitstream; visual result pending. Sensor window, color controls and clocks unchanged.
Sensor config window: 3208/09=0x0780, 320a/b=0x0438, 3210/11=0x0144, 3212/13=0x0005. SC431HAI manufacturer datasheet v1.0 Table 2-12 defines these as output width, height, column start, row start; effective full array 2560x1440. Configured crop uses 75 percent of full width/height, not full-field resampling. Relative full-array crop factor 4/3; not a measured magnification versus user's phone, and no sensor register readback performed.
