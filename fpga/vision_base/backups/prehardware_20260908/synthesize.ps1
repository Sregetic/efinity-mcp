param(
    [ValidateSet('roi_axi_scaler','frame_pool','board')][string]$Top='roi_axi_scaler',
    [ValidateSet('map','interface','pnr','pgm','compile')][string]$Flow='map',
    [int]$TimeoutSeconds=600,
    [string]$EfinityHome='F:\Efinity\2026.1'
)
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
$homePath=(Resolve-Path -LiteralPath $EfinityHome).Path
$python=Join-Path $homePath 'python311/bin/python.exe'
$runner=Join-Path $homePath 'scripts/efx_run.py'
$projectDir=Join-Path $root 'efinity'
$projectName=$Top
if($Top -eq 'board') {
    $projectDir=Join-Path $root 'board/ti60f225_v4'
    $projectName='ti60f225_oob'
} elseif($Flow -ne 'map') { throw 'Portable core projects support map only; choose -Top board for physical flows.' }
$started=[DateTime]::UtcNow.ToString('o')
$vars=@{
    EFINITY_HOME=$homePath.Replace('\','/');PYTHONHOME=(Join-Path $homePath 'python311');
    EFXPT_HOME=(Join-Path $homePath 'pt');EFXIPM_HOME=(Join-Path $homePath 'ipm');
    EFXDBG_HOME=(Join-Path $homePath 'debugger');EFXPGM_HOME=(Join-Path $homePath 'pgm');
    EFXSVF_HOME=(Join-Path $homePath 'debugger/svf_player');
    EFINITY_USER_DIR_INI=($env:LOCALAPPDATA+'/efinity/user_dir.ini');
    PATH=((Join-Path $homePath 'python311/bin')+';'+(Join-Path $homePath 'bin')+';'+(Join-Path $homePath 'debugger/bin')+';'+(Join-Path $homePath 'pgm/bin')+';'+$env:PATH)
}
$old=@{}
$exitCode=1
New-Item -ItemType Directory -Path (Join-Path $root 'results') -Force | Out-Null
try {
    foreach($key in $vars.Keys) {
        $old[$key]=[Environment]::GetEnvironmentVariable($key,'Process')
        [Environment]::SetEnvironmentVariable($key,$vars[$key],'Process')
    }
    Push-Location $projectDir
    try {
        & $python $runner "$projectName.xml" --flow $Flow --timeout $TimeoutSeconds 2>&1 |
            Tee-Object -FilePath (Join-Path $root "results/$Top.$Flow.console.log")
        $exitCode=$LASTEXITCODE
    } finally { Pop-Location }
} finally {
    foreach($key in $old.Keys) { [Environment]::SetEnvironmentVariable($key,$old[$key],'Process') }
}
foreach($suffix in @('map.rpt','map.out','err.log','warn.log','route.rpt.xml','timing.rpt','pt.rpt.xml','place.rpt','cdc.rpt')) {
    $report=Join-Path $projectDir "outflow/$projectName.$suffix"
    if(Test-Path -LiteralPath $report) {
        Copy-Item -LiteralPath $report -Destination (Join-Path $root "results/$Top.$suffix") -Force
    }
}
$unassigned=$null
$routeReport=Join-Path $projectDir "outflow/$projectName.route.rpt.xml"
if($Top -eq 'board' -and $Flow -in @('compile','pnr','pgm') -and $exitCode -eq 0 -and (Test-Path -LiteralPath $routeReport)) {
    [xml]$routeXml=Get-Content -LiteralPath $routeReport -Raw
    $pinNode=$routeXml.SelectSingleNode("//*[local-name()='group_data' and @name='Unassigned Core Pins']")
    if($null -ne $pinNode) {
        $unassigned=[int]$pinNode.value
        if($unassigned -gt 0) { Write-Output "Unassigned core pins remain: $unassigned"; $exitCode=1 }
    }
}
[ordered]@{target=$Top;flow=$Flow;started_utc=$started;finished_utc=[DateTime]::UtcNow.ToString('o');exit_code=$exitCode;unassigned_core_pins=$unassigned;hardware_programmed=$false} |
    ConvertTo-Json | Set-Content -LiteralPath (Join-Path $root "results/$Top.$Flow.status.json") -Encoding utf8
if($exitCode -ne 0){exit $exitCode}
Write-Output "PASS Efinity target=$Top flow=$Flow (no board programming)"
