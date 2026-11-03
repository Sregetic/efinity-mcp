# Standalone control/A6 release
The bitstream embeds the control/FlyHash firmware. No USER1 application download
or computer-side configuration is needed for the listed control/A6 functions.
Use program_vision_sram.ps1 -BootOnly for a configuration-load startup test.
Full INT8 application/weights still need their existing loader; this is not an AI
autonomous-boot release. Flash is unchanged. Physical card/button/power-cycle
acceptance precedes Flash installation, as specified in the team plan.
