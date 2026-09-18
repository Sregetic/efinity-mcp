$ErrorActionPreference = 'Stop'
trap { $_.Exception.Message | Set-Content 'F:/efinity-ci/service-install-error.log'; exit 1 }
$runnerRoot = 'C:\actions-runner-efinity'
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw 'Run this installer elevated through UAC.' }
if (Test-Path "$runnerRoot/.runner") { throw 'Already configured; inspect before changing registration.' }
# The service must not depend on access to the interactive user's private profile.
$profileRoot=Join-Path $runnerRoot 'efinity-profile'
if(Test-Path $profileRoot){throw 'Dedicated Efinity profile exists; inspect before replacing it.'}
New-Item -ItemType Directory $profileRoot | Out-Null
foreach($name in @('app.ini','hw_tools.json','style.ini','ipm','pt')) {
    $source=Join-Path "$env:USERPROFILE/.efinity" $name
    if(Test-Path -LiteralPath $source){Copy-Item -LiteralPath $source -Destination $profileRoot -Recurse}
}
$ini=Join-Path $runnerRoot 'efinity-user-dir.ini'
@('[General]',('EFINITY_USER_DIR='+$profileRoot.Replace('\','\\'))) | Set-Content -LiteralPath $ini -Encoding utf8NoBOM
$envFile=Join-Path $runnerRoot '.env'
$settings=@()
if(Test-Path $envFile) {
    Copy-Item $envFile (Join-Path $runnerRoot ('.env.before-profile-'+(Get-Date -Format 'yyyyMMddHHmmss')))
    $settings=@(Get-Content $envFile | Where-Object {$_ -notmatch '^EFINITY_USER_DIR(_INI)?='})
}
$settings+=@("EFINITY_USER_DIR_INI=$ini","EFINITY_USER_DIR=$profileRoot")
[IO.File]::WriteAllLines($envFile,$settings)
New-Item -ItemType Directory 'F:\efinity-ci\jobs','C:\ProgramData\efinity-runner' -Force | Out-Null
& icacls.exe $runnerRoot /grant '*S-1-5-20:(OI)(CI)M' | Out-Null
if($LASTEXITCODE -ne 0){throw 'Runner directory permission setup failed.'}
& icacls.exe 'F:\efinity-ci\jobs' /grant '*S-1-5-20:(OI)(CI)M' | Out-Null
if($LASTEXITCODE -ne 0){throw 'Job directory permission setup failed.'}
# Approval files are administrator-owned. The service can read/consume, not authorize.
& icacls.exe 'C:\ProgramData\efinity-runner' /inheritance:r /grant:r '*S-1-5-18:(OI)(CI)F' '*S-1-5-32-544:(OI)(CI)F' '*S-1-5-20:(OI)(CI)RX' | Out-Null
if($LASTEXITCODE -ne 0){throw 'Local approval directory protection failed.'}
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
