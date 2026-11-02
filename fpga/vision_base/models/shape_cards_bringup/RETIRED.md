# Retired BASE bring-up model

BASE was removed from the current camera application and all model-selection entry points on 2026-10-31. The current build offers FOMO (wire ID 1) and M7 geometry (wire ID 2); ID 0 is retired.

These training fixtures, the old 4400-byte weights and `model_selftest.c` remain only for reproducing dated bring-up results and recovery. `build_fomo_firmware.py --camera --cfu-kernels` does not load or validate these weights. Its current VBO1 package has a zero-length external weights section. Current FOMO weights are embedded in the application.
