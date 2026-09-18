$ErrorActionPreference = 'Stop'
trap { $_.Exception.Message | Set-Content 'F:/efinity-ci/service-install-error.log'; exit 1 }
$runnerRoot = 'C:\actions-runner-efinity'
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw 'Run this installer elevated through UAC.' }
if (Test-Path "$runnerRoot/.runner") { throw 'Already configured; inspect before changing registration.' }
New-Item -ItemType Directory 'F:\efinity-ci\jobs','C:\ProgramData\efinity-runner' -Force | Out-Null
& icacls.exe $runnerRoot /grant '*S-1-5-20:(OI)(CI)M' | Out-Null
& icacls.exe 'F:\efinity-ci\jobs' /grant '*S-1-5-20:(OI)(CI)M' | Out-Null
# Approval files are administrator-owned. The service can read/consume, not authorize.
& icacls.exe 'C:\ProgramData\efinity-runner' /inheritance:r /grant:r '*S-1-5-18:(OI)(CI)F' '*S-1-5-32-544:(OI)(CI)F' '*S-1-5-20:(OI)(CI)RX' | Out-Null
$registration = & gh api --method POST repos/Sregetic/efinity-mcp/actions/runners/registration-token | ConvertFrom-Json
if ($LASTEXITCODE -ne 0 -or -not $registration.token) { throw 'Unable to obtain repository runner registration token.' }
$env:ACTIONS_RUNNER_INPUT_TOKEN = $registration.token
try {
    Push-Location $runnerRoot
    try {
        & .\config.cmd --unattended --url https://github.com/Sregetic/efinity-mcp --name efinity-ti60-win --labels efinity,ti60 --work _work --runasservice --windowslogonaccount 'NT AUTHORITY\NETWORK SERVICE' 2>&1 | Tee-Object -FilePath 'F:/efinity-ci/service-config.log'
        if ($LASTEXITCODE -ne 0) { throw "Runner config failed: $LASTEXITCODE" }
    } finally { Pop-Location }
} finally {
    Remove-Item Env:ACTIONS_RUNNER_INPUT_TOKEN -ErrorAction SilentlyContinue
    $registration = $null
}
Get-CimInstance Win32_Service | Where-Object Name -like 'actions.runner.Sregetic-efinity-mcp.*' | Select-Object Name,StartName,StartMode,State | ConvertTo-Json | Set-Content 'F:\efinity-ci\service-install-result.json'
