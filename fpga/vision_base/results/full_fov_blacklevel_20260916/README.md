# Full-FOV black-level correction
User explicitly confirmed fully covered lens. Before:7 primed A6 centralROI samples, pre-gamma meansR~15.96..16 G~13.96..14 B~15.96..16. Consistent with RAW8 pedestal16 and greengain230/256.
Inserted max(raw8-16,0) per Bayer sample after horizontal phase alignment and before gain/debayer. Full-FOV reduction, clocks, exposure, gamma and existing gain values unchanged. Old white-balance calibration included pedestal; neutral calibration may need reevaluation after this change.
Actual gain+debayer synthetic RAW16 dark test:260 checked internal pairs zero. Fresh P&R WNS+0.487ns WHS+0.026ns. JTAG SRAM programmed.
User kept lens covered for postprogram7 primed snapshots:RGB means all less0.001 at pre-gamma observation, sparse maximaR1 G0..1 B1..3. No claim of zero sensor noise, full image color correctness, or all haze eliminated. User told to uncover lens after capture. Await actual-scene contrast feedback.
Artifacts manifest/hash, backups and covered before/after evidence retained.
