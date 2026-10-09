param([string]$Url='ftdi://0x0403:0x6011:4:3/2',
 [ValidateSet('camera','pattern')][string]$VideoMode='camera',
 [ValidateSet('sc431hai','sc2210')][string]$Sensor='sc431hai',
 [switch]$ValidateOnly,[switch]$BootOnly)
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$artifactMode=if($Sensor -eq 'sc2210'){"${VideoMode}_sc2210"}else{$VideoMode}
$art=Join-Path $root "artifacts/$artifactMode"
$manifest=Get-Content -Raw -LiteralPath (Join-Path $art 'manifest.json') | ConvertFrom-Json
if($manifest.video_mode -ne $VideoMode -or $null -eq $manifest.wns_ns -or $null -eq $manifest.whs_ns -or $manifest.wns_ns -lt 0 -or $manifest.whs_ns -lt 0){throw 'Selected build and nonnegative setup/hold timing required.'}
if($manifest.sensor -ne $Sensor){throw 'Selected sensor and artifact do not match.'}
foreach($p in $manifest.files.PSObject.Properties){
 if((Get-FileHash -LiteralPath (Join-Path $art $p.Name)).Hash -ne $p.Value){throw "Artifact hash mismatch: $($p.Name)"}
}
# Validate the selected artifact's own route report, independent of the last
# compiled mode. The manifest binds this report and bitstream by their hashes.
[xml]$route=Get-Content -Raw -LiteralPath (Join-Path $art 'ti60f225_oob.route.rpt.xml')
$pins=$route.SelectSingleNode("//*[local-name()='group_data' and @name='Unassigned Core Pins']")
if($null -eq $pins -or [int]$pins.value -ne 0){throw 'Selected route report requires zero unassigned core pins.'}
foreach($p in $manifest.source_sha256.PSObject.Properties){
 if($p.Name -eq 'board/ti60f225_v4/rtl/vision_sensor_config.vh'){
  $builtHash=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($manifest.sensor_config_header)))
  if($builtHash -ne $p.Value -or (Get-FileHash -LiteralPath (Join-Path $root $p.Name)).Hash -ne $manifest.sensor_defaults_sha256){throw 'Selected sensor header or restored sensor defaults mismatch.'}
  continue
 }
 if($p.Name -eq 'board/ti60f225_v4/rtl/vision_board_config.vh'){
  # synthesize.ps1 generates the selected header, then restores camera defaults.
  $patternBit=if($VideoMode -eq 'pattern'){1}else{0}
  $expected="// Build mode: $VideoMode`n``define VISION_TEST_PATTERN $patternBit`n``define VISION_TIMING_PROBE 0`n"
  $builtHash=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($expected)))
  $current=Get-Content -LiteralPath (Join-Path $root $p.Name) | Where-Object {$_ -notmatch '^\s*(//|$)'}
  $restored="``define VISION_TEST_PATTERN 0`n``define VISION_TIMING_PROBE 0"
  if($builtHash -ne $p.Value -or (($current -join "`n").Trim()) -ne $restored){throw 'Selected build header or restored camera defaults mismatch.'}
  continue
 }
 if((Get-FileHash -LiteralPath (Join-Path $root $p.Name)).Hash -ne $p.Value){throw "Source changed after selected build: $($p.Name)"}
}
if($ValidateOnly){Write-Output "PASS artifact/source/timing validation: $VideoMode $Sensor (no board programming)";return}
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
@{started_utc=$started;finished_utc=[DateTime]::UtcNow.ToString('o');url=$Url;operation='JTAG SRAM';video_mode=$VideoMode;sensor=$Sensor;flash_written=$false;boot_only=[bool]$BootOnly;frequency_hz=1000000;exit_code=$code;programmer_completed=$ok;bit_sha256=(Get-FileHash -LiteralPath $bit).Hash;visual_acceptance='pending user'} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $out 'program.json')
if(!$ok){throw 'JTAG programming did not complete. Inspect program.log and enumerate the current USB target.'}
Start-Sleep -Seconds 12
if($VideoMode -eq 'camera' -and !$BootOnly){
 & "$PSScriptRoot/control_vision.ps1" -Url $Url -Sensor $Sensor -Mode 3 -Memory 0 -Index 0 -Threshold 64 -Median 1
}
