param([string]$OutputDirectory='results/a_controls_quality_20261009/standalone')
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
& "$PSScriptRoot/program_vision_sram.ps1" -ValidateOnly
$out=if([IO.Path]::IsPathRooted($OutputDirectory)){$OutputDirectory}else{Join-Path $root $OutputDirectory}
New-Item -ItemType Directory -Path $out -Force | Out-Null
Copy-Item -Path "$root/artifacts/camera/*" -Destination $out -Force
Copy-Item -LiteralPath "$root/docs/BOARD_BUTTON_DEMO_20261009.md" -Destination $out -Force
[ordered]@{
 device='Ti60F225';sensor='SC431HAI';hdmi='1920x1080@60Hz'
 control_boot='8KB embedded ROM copies control/FlyHash firmware into DDR'
 boot_defaults=@{mode=3;median=0;sobel=128;canny=128;shape=32;memory=0;menu=0;roi_enabled=0}
 functions=@('camera','median','Sobel','Canny','overlay','A6 geometry','six-frame history','freeze','ROI zoom/pan/place','physical-key menu')
 requires_host_configuration=$false;full_int8_autoload=$false
 flash_written=$false;physical_power_cycle_verified=$false;real_card_acceptance=$false
} | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $out 'startup_contract.json') -Encoding utf8
@'
# Standalone control/A6 release
The bitstream embeds the control/FlyHash firmware. No USER1 application download
or computer-side configuration is needed for the listed control/A6 functions.
Use program_vision_sram.ps1 -BootOnly for a configuration-load startup test.
Full INT8 application/weights still need their existing loader; this is not an AI
autonomous-boot release. Flash is unchanged. Physical card/button/power-cycle
acceptance precedes Flash installation, as specified in the team plan.
'@ | Set-Content -LiteralPath (Join-Path $out 'README.md') -Encoding utf8
Write-Output "Prepared standalone control/A6 release: $out (Flash unchanged)"
