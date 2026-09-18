param([string]$Url='ftdi://0x0403:0x6011:4:3/2')
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$art=Join-Path $root 'artifacts/camera'
$manifest=Get-Content -Raw -LiteralPath (Join-Path $art 'manifest.json') | ConvertFrom-Json
$gate=Get-Content -Raw -LiteralPath (Join-Path $root 'results/board.compile.status.json') | ConvertFrom-Json
if($gate.exit_code -ne 0 -or $gate.video_mode -ne 'camera' -or $gate.unassigned_core_pins -ne 0 -or $null -eq $gate.wns_ns -or $null -eq $gate.whs_ns -or $gate.wns_ns -lt 0 -or $gate.whs_ns -lt 0){throw 'Fresh camera build and nonnegative setup/hold timing required.'}
foreach($p in $manifest.files.PSObject.Properties){
 if((Get-FileHash -LiteralPath (Join-Path $art $p.Name)).Hash -ne $p.Value){throw "Artifact hash mismatch: $($p.Name)"}
}
foreach($p in $manifest.source_sha256.PSObject.Properties){
 if($p.Name -eq 'board/ti60f225_v4/rtl/vision_board_config.vh'){
  # synthesize.ps1 temporarily generates this header, then restores its comment.
  $expected="// Build mode: camera`n``define VISION_TEST_PATTERN 0`n``define VISION_TIMING_PROBE 0`n"
  $builtHash=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($expected)))
  $current=Get-Content -LiteralPath (Join-Path $root $p.Name) | Where-Object {$_ -notmatch '^\s*(//|$)'}
  if($builtHash -ne $p.Value -or (($current -join "`n").Trim()) -ne (($expected -split "`n" | Select-Object -Skip 1) -join "`n").Trim()){throw 'Camera build header mismatch.'}
  continue
 }
 if((Get-FileHash -LiteralPath (Join-Path $root $p.Name)).Hash -ne $p.Value){throw "Source changed after camera build: $($p.Name)"}
}
. "$PSScriptRoot/efinity_env.ps1"
$out=Join-Path $root ('results/programming/'+(Get-Date -Format 'yyyyMMdd_HHmmss'))
New-Item -ItemType Directory -Path $out -Force | Out-Null
$started=[DateTime]::UtcNow.ToString('o')
$bit=Join-Path $art 'ti60f225_oob.bit'
# SRAM only; leave existing Flash contents intact.
$log=& "$env:PYTHONHOME/bin/python.exe" "$env:EFXPGM_HOME/bin/efx_pgm/ftdi_program.py" $bit -m jtag -u $Url --jtag_clock_freq 1000000 2>&1
$code=$LASTEXITCODE
$log | Tee-Object -FilePath (Join-Path $out 'program.log')
$ok=$code -eq 0 -and ($log -join "`n") -match 'finished with JTAG programming'
@{started_utc=$started;finished_utc=[DateTime]::UtcNow.ToString('o');url=$Url;operation='JTAG SRAM';frequency_hz=1000000;exit_code=$code;programmer_completed=$ok;bit_sha256=(Get-FileHash -LiteralPath $bit).Hash;visual_acceptance='pending user'} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $out 'program.json')
if(!$ok){throw 'JTAG programming did not complete. Inspect program.log and enumerate the current USB target.'}
Start-Sleep -Seconds 12
& "$PSScriptRoot/control_vision.ps1" -Url $Url -Mode 3 -Memory 0 -Index 0 -Threshold 64 -Median 1
