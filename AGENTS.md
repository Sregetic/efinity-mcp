# Repository instructions

This repository maintains the Ti60 real-time vision project under `fpga/vision_base`.

- Read that project's `AGENTS.md`, `docs/PROJECT_MASTER_STATUS.md` and relevant `docs/SYSTEM_SCOPE_AND_ROADMAP.md` sections before vision changes. Dated evidence is not the current deployment state.
- Keep original/gray/Sobel/Canny, menu, frame pool, DDR/ROI, M7, tracking and independent AI contracts intact unless the user explicitly changes scope.
- Preserve native-file `.gitattributes`, third-party notices and required build dependencies. Do not commit licenses, credentials, vendor tool binaries, local backups or rebuildable caches.
- Keep `scripts/runner`, the manual hardware workflows and the guarded synthesis/programming entrypoints. Do not change pins, clocks, voltage standards, programming defaults or approval checks without explicit operator authorization.
- The retained Runner builds the original camera target; use `fpga/vision_base/board/ti60_hdmi` for the current HDMI-input system. Do not present the two targets as interchangeable.
- Keep Efinity's vendor Python separate from the host Python environment. `pgm` generates programming files; SRAM and Flash programming are separate explicit operations.
- Deployment-tool checks: `python -m pytest -q tests/test_runner_entrypoints.py`, `pwsh -NoProfile -File tests/Test-RunnerGates.ps1`, and `python -m compileall -q fpga/vision_base/scripts scripts/runner`. These checks never access hardware.
- Use the vision project's existing tests for changed RTL/firmware behavior. Software tests, synthesis/P&R, board readback and physical acceptance are different evidence.
- Do not automatically dispatch self-hosted builds, program a board, rewrite Git history or upload local-only artifacts as part of source maintenance.
