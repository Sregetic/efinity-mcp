$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../..'))
Push-Location $root
try {
 . scripts/efinity_env.ps1
 $out='results/geometry_m7_20261028/flash_20261028/config'
 New-Item -ItemType Directory -Path $out -Force | Out-Null
 $backup='results/geometry_m7_20261028/flash_20261028/app/flash_before.bin'
 if((Get-Item -LiteralPath $backup).Length -ne 8388608){throw 'Full prior Flash backup required'}
 $app=Get-Content results/geometry_m7_20261028/flash_20261028/app/result.json -Raw | ConvertFrom-Json
 if(!$app.byte_readback_verified){throw 'Matched application Flash verification required'}
 $python="$env:PYTHONHOME/bin/python.exe";$programmer="$env:EFXPGM_HOME/bin/efx_pgm/ftdi_program.py"
 $bridgeLoaded=$false
 try {
  $log=& $python $programmer "$env:EFXPGM_HOME/fli/titanium/u10660A79.bit" -m jtag -u ftdi://0x0403:0x6011:4:b/2 --jtag_clock_freq 1000000 2>&1
  $log | Set-Content "$out/bridge.log"
  if($LASTEXITCODE){throw 'Flash bridge failed'}
  $bridgeLoaded=$true
  $log=& $python $programmer artifacts/camera/ti60f225_oob.hex -m jtag_bridge --jtag_bridge_mode all --verify_method onchipx1 -u ftdi://0x0403:0x6011:4:b/2 --jtag_clock_freq 1000000 --address 0 2>&1
  $code=$LASTEXITCODE;$log | Set-Content "$out/write.log"
  if($code -ne 0 -or ($log -join "`n") -notmatch 'Flash verify successful'){throw 'Configuration Flash write/verification failed'}
  @{passed=$true;configuration_flash_written=$true;address=0;onchip_verification=$true;full_old_flash_backup=$backup;physical_power_cycle_verified=$false;input='artifacts/camera/ti60f225_oob.hex';finished_utc=[DateTime]::UtcNow.ToString('o')} | ConvertTo-Json | Set-Content "$out/result.json"
 } finally {
  if($bridgeLoaded){& scripts/program_vision_sram.ps1 -Url ftdi://0x0403:0x6011:4:b/2 -BootOnly *> "$out/sram_restart.log"}
 }
 Get-Content "$out/write.log" -Last 13
} finally {Pop-Location}
