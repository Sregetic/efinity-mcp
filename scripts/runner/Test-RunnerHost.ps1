param([string]$EfinityHome='F:/Efinity/2026.1')
$ErrorActionPreference='Stop'
$PSNativeCommandUseErrorActionPreference=$false
$repo=Split-Path (Split-Path $PSScriptRoot)
foreach($file in @("$EfinityHome/python311/bin/python.exe","$EfinityHome/scripts/efx_run.py",'C:/iverilog/bin/iverilog.exe','C:/iverilog/bin/vvp.exe')) {
    if(!(Test-Path -LiteralPath $file)){throw "Missing dependency: $file"}
}
if($PSVersionTable.PSVersion.Major -lt 7){throw 'PowerShell 7 required.'}
. "$repo/fpga/vision_base/scripts/efinity_env.ps1" -EfinityHome $EfinityHome
if(!(Test-Path -LiteralPath $env:EFINITY_USER_DIR_INI)){throw 'Efinity user profile is not accessible under the service identity.'}
# Readability only; never print profile/license contents.
$null=[IO.File]::ReadAllText($env:EFINITY_USER_DIR_INI)
& "$EfinityHome/python311/bin/python.exe" --version
if($LASTEXITCODE -ne 0){throw 'Vendor Python failed.'}
& C:/iverilog/bin/iverilog.exe -V 2>&1 | Select-Object -First 1
if($LASTEXITCODE -ne 0){throw 'Icarus compiler failed.'}
& C:/iverilog/bin/vvp.exe -V 2>&1 | Select-Object -First 1
if($LASTEXITCODE -ne 0){throw 'Icarus runtime failed.'}
$usb=& "$EfinityHome/python311/bin/python.exe" "$EfinityHome/pgm/bin/efx_pgm/ftdi_program.py" --list_usb 2>&1
if($LASTEXITCODE -ne 0){throw 'Read-only USB enumeration failed.'}
$usb
Write-Output "Host=$env:COMPUTERNAME Identity=$([Security.Principal.WindowsIdentity]::GetCurrent().Name) PS=$($PSVersionTable.PSVersion) Architecture=$([Runtime.InteropServices.RuntimeInformation]::OSArchitecture)"
Write-Output 'Efinity license acceptance is verified by a real compile, not by this smoke check.'
