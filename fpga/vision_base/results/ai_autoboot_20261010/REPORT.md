# Autonomous boot evidence

See ../../docs/AI_AUTOBOOT_AND_CONNECTOME_20261010.md.

Final FPGA: release/, native_aperture.log.
Boot parser: boot_test/result.json;9 RV32I cases.
CPU write lanes: cpu_alignment/before.log and after.log.
Static code/weights: final_rom_boot/result.json, then ../connectome_20261010/autoboot/result.json for final application.
Cached ROI: ai_verified_5khz/validation.json.
Flash configuration: config_flash/write.log and result.json.
Original Flash backup: flash/flash_before.bin.
Failed candidates/logs are retained but are not deployed.
Physical power-cycle acceptance remains unverified.
