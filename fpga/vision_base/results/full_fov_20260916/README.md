# Full-FOV diagnostic 2026-09-16
Goal: compare actual camera field of view, independent of phone lens or monitor zoom.
Sensor window expanded from1920x1080 to2560x1440, ROI starts4/4 with full array Y bounds0..1447. Exposure, mirror, numerical white balance and Gamma retained. Bayer phase may need revalidation because sensor window origin changed; this is not a final color-calibrated build.
RX pixel clock50->100MHz (PLL output divider12->6; SDC20->10ns) to provision full-frame throughput; HDMI clocks and output1920x1080 remain unchanged.
New bayer_fov_reduce.sv selects three of each four Bayer2x2 blocks in both axes, then compacts MSB-first4-pixel words. This nearest-block decimation preserves CFA parity but may alias; not a high-quality anti-aliased production scaler. No crop-to-center or added black borders.
Full2560x1440 input simulation with valid gaps:518400 output words,2073600 output pixels, all source-coordinate comparisons passed.
Fresh build WNS+0.451ns WHS+0.026ns, zero unassigned pins. JTAG SRAM programmed at1MHz.
Post-program USER2 A7: discarded first read,9 matching valid snapshots. RX640 beats/line,4pixels/beat,1440 lines,921600 beats/frame ->2560x1440. HDMI preencoder min/max line1920/1920,1080 lines,2073600 pixels. Frame rate not directly measured. FIFO error-free long-run operation and visual FOV expansion still require validation; counters alone are not visual proof.
Previous artifact folder and all modified pre-test files preserved under previous_artifacts/ and backup/. New artifact identity recorded in manifest.json and bit_hash.json.
Expected same-lens same-position object linear size about0.75 of prior cropped display, subject to window alignment; full-field view contains more surroundings. Physical lens FOV itself unchanged. User visual result pending.
