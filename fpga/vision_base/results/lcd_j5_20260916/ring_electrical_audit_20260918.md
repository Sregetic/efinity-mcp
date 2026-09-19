# LCD local ring investigation 2026-09-18
Reviewed panel specification page 6/7 and MIPI DSI Driver schematic.
- Panel VCC 3.0..3.6 V (typ 3.3 V); VSP +5..+7 V (typ +6); VSN -7..-5 V (typ -6).
- Adapter VGH/VGL labels feed panel VSP/VSN; do not confuse these schematic net labels with separately named internal panel VGH/VGL maximum ratings. Nominal schematic annotations are +5/-5 V; these are within but at the panel operating bounds. Actual assembly and measured ripple are unverified. R19=510k, R20=120k with printed VFB=1.3 formula implies ~6.825 V before output drops, conflicting with the +5 label. Do not diagnose or change resistor values from the label alone.
- STBYB pin26 pulled up via R32 10k to VDD_3V3; RESET_N driven through Q1 inverter by J5 reset control. LCD_BLK_EN drives SGM3752 CTRL. Power-on blanking control is not the panel main supply enable.
- Backlight specification 40 mA typical, 24 V typical (22.4..27.2); ~0.96 W typical LED power. Board schematic uses SGM3752, R24 4.7 ohm and optional parallel R23 NC. Driver feedback voltage/actual BOM still needs verification; schematic is not measurement.
- User confirms local ring visibly flickers to naked eye on reference image while the rest of image is stable. Physical cause remains unproven; panel bias/stability, panel initialization and physical assembly remain candidates. Global backlight flicker not established.
- No VCOM/inversion register map located in supplied panel specification, so undocumented panel writes are not justified by these files.
