param([Parameter(Mandatory=$true)][string]$Url,[Parameter(Mandatory=$true)][string]$BackupDir)
$ErrorActionPreference='Stop'
$root=(Resolve-Path "$PSScriptRoot/../..").Path
$backup=(Resolve-Path $BackupDir).Path
if((Get-Item -LiteralPath "$backup/flash_before.bin").Length -ne 8388608){throw 'A complete prior8MiB Flash backup is required'}
Get-Item -LiteralPath "$backup/flash_before.hex" | Out-Null
. "$root/scripts/efinity_env.ps1"
$p="$env:PYTHONHOME/bin/python.exe";$pgm="$env:EFXPGM_HOME/bin/efx_pgm/ftdi_program.py"
& $p $pgm "$env:EFXPGM_HOME/fli/titanium/u10660A79.bit" -m jtag -u $Url --jtag_clock_freq 1000000 *> "$backup/recovery_bridge.log"
if($LASTEXITCODE){throw 'Recovery bridge failed'}
& $p $pgm "$backup/flash_before.hex" -m jtag_bridge --jtag_bridge_mode all --verify_method hostx1 -u $Url --jtag_clock_freq 1000000 --address 0 *> "$backup/recovery_write.log"
if($LASTEXITCODE){throw 'Prior Flash restoration/verification failed; preserve logs'}
Write-Output 'Prior complete Flash restored. Press CONFIG to start it; no application was supplemented through USER1.'
