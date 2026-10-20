# Synthetic bring-up readout — not a real-camera classifier

The frozen MaleCNS 80-state circuit feeds a trained 80→4 INT8 linear head.
Only the head is learned. Labels are blank, circle, rectangle, triangle.

- Training: 400 generated outlines, seed2210. Test:160 independently generated outlines, seed107.
- Quantization calibration uses training only. The test set never selects weights/scales.
- Synthetic held-out INT8 accuracy:158/160; this is not physical-card accuracy.
- Four separately delivered FOMO fixed images:2/4 correct. The external-domain failures are retained in the host test report.
- `connectome_readout.bin`:364-byte CRD1, graph version0x00010001, readout version0x00010001, training_kind1.
- `heldout.npz`:160 feature/state/score/label fixtures used to test production C arithmetic.
- `training.json`:scales, confusion matrix, same-eight-bin direct-feature float baseline and acceptance scope.

Regenerate with `scripts/train_connectome_readout.py --synthetic-bringup --model-version 0x00010001 --output-dir models/connectome_readout_bringup` from the project root. Use `--manifest` with independently collected train/test card and session IDs for the real-data path. No claim of biological-topology advantage is made.
