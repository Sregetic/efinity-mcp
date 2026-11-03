param(
 [Parameter(Mandatory=$true)][string]$Url,
 [Parameter(Mandatory=$true)][string]$ReleaseDir,
 [Parameter(Mandatory=$true)][string]$OutputDir
)
$ErrorActionPreference='Stop'
$root=(Resolve-Path "$PSScriptRoot/../..").Path
$release=(Resolve-Path $ReleaseDir).Path
$out=[IO.Path]::GetFullPath($OutputDir)
& "$PSScriptRoot/build.ps1" -ValidateOnly -ReleaseDir $release
if(Test-Path -LiteralPath "$out/flash_before.bin"){throw 'Preserve the existing Flash backup; use a new output directory'}
New-Item -ItemType Directory -Force $out | Out-Null
. "$root/scripts/efinity_env.ps1"
$python="$env:PYTHONHOME/bin/python.exe";$pgm="$env:EFXPGM_HOME/bin/efx_pgm/ftdi_program.py"
Push-Location $root
try {
 & $python scripts/pack_vision_boot.py --elf "$release/vision.elf" --output "$out/vision_boot.bin" *> "$out/package.log"
 if($LASTEXITCODE){throw 'Boot package failed before Flash access'}
 & $python -c 'import sys;from pathlib import Path;d=bytes.fromhex(Path(sys.argv[1]).read_text());assert 0<len(d)<0x700000,"Configuration overlaps application partition"' "$release/vision_hdmi.hex"
 if($LASTEXITCODE){throw 'Flash configuration extent invalid'}
 $bridgeLoaded=$false;$written=$false
 try {
  & $python $pgm "$env:EFXPGM_HOME/fli/titanium/u10660A79.bit" -m jtag -u $Url --jtag_clock_freq 1000000 *> "$out/bridge.log"
  if($LASTEXITCODE){throw 'Flash bridge load failed'}
  $bridgeLoaded=$true
  for($offset=0;$offset -lt 8388608;$offset+=1048576){
   $part=$offset.ToString('x6')
   & $python $pgm "$release/vision_hdmi.hex" -m jtag_bridge --jtag_bridge_mode read -u $Url --jtag_clock_freq 1000000 --address $offset --num_bytes 1048576 -o "$out/before_$part.hex" *> "$out/before_$part.log"
   if($LASTEXITCODE){throw "Flash backup failed at0x$part; no erase issued"}
  }
  & $python -c 'import sys,struct;from pathlib import Path;sys.path.insert(0,"scripts");from pack_vision_boot import validate_package;p=Path(sys.argv[1]);d=b"".join(bytes.fromhex((p/f"before_{o:06x}.hex").read_text())for o in range(0,0x800000,0x100000));assert len(d)==0x800000;h=struct.unpack_from("<8I",d,0x700000);validate_package(d[0x700000:0x700000+32+h[2]+h[4]]);(p/"flash_before.bin").write_bytes(d);(p/"flash_before.hex").write_text(d.hex())' $out
  if($LASTEXITCODE){throw 'Prior Flash package/layout invalid; no erase issued'}
  # Both partitions use the board-proven vendor host readback, not bridge CRC mode.
  foreach($job in @(@{file="$out/vision_boot.hex";address=0x700000;name='application'},@{file="$release/vision_hdmi.hex";address=0;name='configuration'})){
   & $python $pgm $job.file -m jtag_bridge --jtag_bridge_mode all --verify_method hostx1 -u $Url --jtag_clock_freq 1000000 --address $job.address *> "$out/write_$($job.name).log"
   if($LASTEXITCODE -or !(Select-String -LiteralPath "$out/write_$($job.name).log" -SimpleMatch 'Flash verify successful' -Quiet)){throw "Flash $($job.name) write/readback failed"}
  }
  $written=$true
 } finally {
  if($bridgeLoaded){
   if($written){
    & $python $pgm "$release/vision_hdmi.bit" -m jtag -u $Url --jtag_clock_freq 1000000 *> "$out/start_configuration.log"
    if($LASTEXITCODE){throw 'Flash written, SRAM start failed; use CONFIG to reload Flash'}
   }else{
    # A failed Flash operation must leave a usable tested SRAM/DDR runtime.
    & "$PSScriptRoot/load_sram.ps1" -Url $Url -ReleaseDir $release -OutputDir "$out/runtime_recovery" *> "$out/runtime_recovery.log"
    if($LASTEXITCODE){throw 'Flash operation failed and runtime recovery failed; preserve backup and logs'}
   }
  }
 }
 Start-Sleep -Seconds 35
 & $python scripts/verify_vision_boot.py --url $Url --elf "$release/vision.elf" --jtag-khz 1000 --chunk-bytes 1024 --timeout-seconds 300 --output-dir "$out/autoboot" *> "$out/autoboot.log"
 if($LASTEXITCODE){throw 'Flash contents written but autonomous application startup not verified'}
 & $python scripts/vision_control.py --url $Url --sensor hq12 --mode 0 --key-event 8 --roi-status > "$out/menu.json"
 if($LASTEXITCODE){throw 'Flash boot menu/input check failed'}
 @{passed=$true;configuration_flash_written=$true;application_flash_written=$true;configuration_address=0;application_address=0x700000;release=$release;backup="$out/flash_before.bin";vendor_readback_verified=$true;autonomous_app_ddr_verified=$true;user1_program_download=$false;physical_power_cycle_verified=$false} | ConvertTo-Json | Set-Content "$out/result.json"
 Write-Output "PASS SDI configuration/menu + application Flash; autonomous boot bytes verified. Evidence: $out"
} finally {Pop-Location}
