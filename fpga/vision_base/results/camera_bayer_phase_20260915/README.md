# Bayer horizontal phase diagnostic
One-pixel right shift before gain/linebuffer, preserving inter-pair ordering: interior (x-1,x); first-pair border reflects current pair, last source pixel omitted. This is an experimental RGGB-to-GRBG alignment, not a completed border-correct production demosaic.
Original GRBG-contract pipeline fed RGGB uniform color: 260/260 interior pairs failed. Aligned version: 260/260 passed; green and yellow RGGB fixtures each passed 260/260. This establishes behavior for synthetic RGGB, not physical sensor phase.
Camera bitstream built WNS +0.402ns WHS +0.026ns, SRAM programmed successfully. Primed post-download RGB means ~21.4,25.5,33.8. Scene changed since previous measurement, so no controlled before/after color conclusion. Three channels nonzero; statistics alone do not establish correct color.
User's desk-versus-purple-screen photo pair arrived BEFORE this variant was programmed and is evidence for previous version only. Actual image feedback on new variant pending.
No crop, exposure, numerical gain, clock or corrected four-pixel packing change.
