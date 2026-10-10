# Autonomous AI startup release
Install vision_boot.hex using program_vision_boot_flash.ps1. It writes only the
reserved application partition0x700000..0x7fffff, backs up the Flash first, then
reboots the current validated FPGA bitstream into SRAM with -BootOnly.
The ROM loads the program and weights into DDR without a USER1 program download.
The supplied model is synthetic TEST, not real-card recognition acceptance.
This preparation script neither writes Flash nor power-cycles the board.
FPGA configuration Flash installation and physical power-cycle acceptance remain
separate from the application-partition programming/startup check.
