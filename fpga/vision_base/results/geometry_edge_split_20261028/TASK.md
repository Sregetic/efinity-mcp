# Current handoff

Flash configuration and the206480B edge-only M7 application/4400B weights are programmed and fully verified. ROM-autoloaded DDR bytes match. User confirmed menu and picture after CONFIG or power reload; subsequent FTDI enumeration returned no interfaces, so no new post-reload automatic version read was attempted. Full evidence: flash_20261028/REPORT.md and acceptance.json.

Use release/vision.elf (or flash_20261028/firmware/vision.elf), not firmware_final/vision.elf. The board fix preserves completed lanes when the next snapshot is rejected during VBlank and rereads validity after the token changes. It is covered by RV32I reproduction/regression and current hardware observations. Canny sources remain unchanged; no Pico in M7. Do not rewrite old release receipts.

Remaining: actual objects/motion/lighting and exact-source AI interaction under independently aged face results. GitHub source/evidence synchronization follows the existing isolated worktree/PR6 policy; binaries, raw DDR and full Flash backup stay local.

Earlier intermediate cleanup was blocked by execution policy; no alternate deletion route was used. Intermediate builds are not releases.
