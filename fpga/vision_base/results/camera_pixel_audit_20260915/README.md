# Camera pixel audit 2026-09-15
Changed only raw_to_rgb.v w_r_00_00_h0 / w_b_00_00_h0 neighbor selection. Backup: raw_to_rgb.before.v.
Uniform-color Bayer test phase0: 104/260 interior pairs failed before, 0/260 after. Red, green, blue and gray fixtures each passed 260 interior pairs after fix. Border pixels and physical sensor Bayer phase are not established by this test.
Unpacker extracted from actual top: 128 pixels, 0 errors for tested clock alignment. Not an exhaustive physical-clock check.
Actual line-buffer + project RAM: 5760 pairs, 0 errors, previous-two-row identity checked after warmup.
No zoom, sensor exposure, gamma, gains, HDMI clock or pin changes. Hardware visual confirmation pending.
