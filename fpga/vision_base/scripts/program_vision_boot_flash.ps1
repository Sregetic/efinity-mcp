param([string]$Url='ftdi://0x0403:0x6011:4:9/2',
 [string]$AiElf='artifacts/vision_soc/ddr_firmware/vision.elf',
 [string]$Weights='models/shape_cards_bringup/shape_cards_weights.bin',
 [string]$OutputDirectory='',
 [switch]$ValidateOnly)
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
Push-Location $root
try {
 & "$PSScriptRoot/program_vision_sram.ps1" -ValidateOnly
 . "$PSScriptRoot/efinity_env.ps1"
 $python="$env:PYTHONHOME/bin/python.exe"
 $out=if(!$OutputDirectory){Join-Path $root ('results/programming/boot_flash_'+(Get-Date -Format 'yyyyMMdd_HHmmss'))}elseif([IO.Path]::IsPathRooted($OutputDirectory)){$OutputDirectory}else{Join-Path $root $OutputDirectory}
 if(!$ValidateOnly -and (Test-Path -LiteralPath "$out/flash_before.bin")){throw 'Choose a new output directory to preserve the existing Flash backup.'}
 New-Item -ItemType Directory -Force -Path $out | Out-Null
 & $python "$PSScriptRoot/pack_vision_boot.py" --elf $AiElf --weights $Weights --output "$out/vision_boot.bin"
 if($LASTEXITCODE){throw 'Boot package failed'}
 if($ValidateOnly){return}
 $programmer="$env:EFXPGM_HOME/bin/efx_pgm/ftdi_program.py"
 $bridge="$env:EFXPGM_HOME/fli/titanium/u10660A79.bit"
 $bridgeLoaded=$false
 try {
  $log=& $python $programmer $bridge -m jtag -u $Url --jtag_clock_freq 1000000 2>&1
  $log | Set-Content "$out/bridge.log"
  if($LASTEXITCODE){throw 'Flash bridge programming failed'}
  $bridgeLoaded=$true
  $log=& $python $programmer "$out/vision_boot.hex" -m jtag_bridge --jtag_bridge_mode read -u $Url --jtag_clock_freq 1000000 --address 0 --num_bytes 8388608 -o "$out/flash_before.hex" 2>&1
  $log | Set-Content "$out/read_before.log"
  if($LASTEXITCODE){throw 'Flash backup failed'}
  & $python -c 'import sys,struct;from pathlib import Path;sys.path.insert(0,"scripts");from pack_vision_boot import validate_package;p=Path(sys.argv[1]);d=bytes.fromhex((p/"flash_before.hex").read_text());assert len(d)==0x800000;(p/"flash_before.bin").write_bytes(d);tail=d[0x700000:];h=struct.unpack_from("<8I",tail);assert all(b==255 for b in tail) or tail[:32]==(p/"vision_boot.bin").read_bytes()[:32] or (h[0]==0x56424f31 and validate_package(tail[:32+h[2]+h[4]])),"Reserved application region contains unrelated data"' $out
  if($LASTEXITCODE){throw 'Flash layout validation failed; no erase/write issued'}
  # This board's validated path uses host readback, not the bridge CRC mode.
  $log=& $python $programmer "$out/vision_boot.hex" -m jtag_bridge --jtag_bridge_mode all --verify_method hostx1 -u $Url --jtag_clock_freq 1000000 --address 0x700000 2>&1
  $log | Set-Content "$out/write.log"
  if($LASTEXITCODE){throw 'Flash application write failed'}
  $length=(Get-Item -LiteralPath "$out/vision_boot.bin").Length
  $log=& $python $programmer "$out/vision_boot.hex" -m jtag_bridge --jtag_bridge_mode read -u $Url --jtag_clock_freq 1000000 --address 0x700000 --num_bytes $length -o "$out/readback.hex" 2>&1
  $log | Set-Content "$out/read_after.log"
  if($LASTEXITCODE){throw 'Flash application readback failed'}
  & $python -c 'import json,sys;from pathlib import Path;p=Path(sys.argv[1]);d=bytes.fromhex((p/"readback.hex").read_text());assert d==(p/"vision_boot.bin").read_bytes(),"Flash application byte mismatch";(p/"result.json").write_text(json.dumps(dict(address=0x700000,bytes=len(d),byte_readback_verified=True,configuration_flash_written=False,physical_power_cycle_verified=False),indent=2))' $out
  if($LASTEXITCODE){throw 'Flash application verification failed'}
 } finally {
  if($bridgeLoaded){& "$PSScriptRoot/program_vision_sram.ps1" -Url $Url -BootOnly}
 }
 Write-Output "PASS Flash application/weights at0x700000; FPGA configuration Flash preserved; SRAM rebooted"
} finally {Pop-Location}
