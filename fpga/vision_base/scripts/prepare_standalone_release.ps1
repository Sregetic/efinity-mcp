param([string]$OutputDirectory='results/connectome_20261010/standalone',
 [Parameter(Mandatory=$true)][string]$AiElf,
 [string]$Weights='')
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
& "$PSScriptRoot/program_vision_sram.ps1" -ValidateOnly
$out=if([IO.Path]::IsPathRooted($OutputDirectory)){$OutputDirectory}else{Join-Path $root $OutputDirectory}
New-Item -ItemType Directory -Path $out -Force | Out-Null
Copy-Item -Path "$root/artifacts/camera/*" -Destination $out -Force
Copy-Item -LiteralPath "$root/docs/M7_FOLLOW_TRAJECTORY.md" -Destination $out -Force
. "$PSScriptRoot/efinity_env.ps1"
$weightArgs=if($Weights){@('--weights',$Weights)}else{@()}
Push-Location $root
try {
 & "$env:PYTHONHOME/bin/python.exe" "$PSScriptRoot/pack_vision_boot.py" --elf $AiElf @weightArgs --output "$out/vision_boot.bin"
 if($LASTEXITCODE){throw 'AI startup package failed'}
} finally {Pop-Location}
[ordered]@{
 device='Ti60F225';sensor='SC431HAI';hdmi='1920x1080@60Hz'
 control_boot='8KB ROM reads validated AI program/weights from Flash0x700000; erased application header boots embedded control/FlyHash for USER1 development'
 boot_defaults=@{mode=5;median=1;sobel=128;canny=80;shape=32;memory=0;menu=0;roi_enabled=0;ai_policy=0;model=2}
 functions=@('camera','median','Sobel','Canny','overlay','A6 geometry','six-frame history','freeze','ROI zoom/pan/place','physical-key menu')
 requires_host_configuration=$false;full_int8_autoload=$true
 flash_application_address='0x700000';preparation_only=$true
 connectome_snapshot=$true;connectome_trained_readout=$false
 supported_models=@('FOMO','M7');external_weights_required=$false
 physical_power_cycle_verified=$false;real_card_acceptance=$false
} | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $out 'startup_contract.json') -Encoding utf8
@'
# Autonomous AI startup release
Install vision_boot.hex using program_vision_boot_flash.ps1. It writes only the
reserved application partition0x700000..0x7fffff, backs up the Flash first, then
reboots the current validated FPGA bitstream into SRAM with -BootOnly.
The ROM loads the program and weights into DDR without a USER1 program download.
The camera application offers FOMO and M7 edge geometry; BASE is retired.
FOMO is embedded in the application. No separate BASE weights are required.
This preparation script neither writes Flash nor power-cycles the board.
FPGA configuration Flash installation and physical power-cycle acceptance remain
separate from the application-partition programming/startup check.
'@ | Set-Content -LiteralPath (Join-Path $out 'README.md') -Encoding utf8
Write-Output "Prepared autonomous AI release: $out (preparation only)"
