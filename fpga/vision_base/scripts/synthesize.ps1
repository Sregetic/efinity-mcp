param(
    [ValidateSet('roi_axi_scaler','frame_pool','frame_render_engine','board')][string]$Top='roi_axi_scaler',
    [ValidateSet('map','interface','pnr','pgm','compile')][string]$Flow='map',
    [ValidateSet('camera','pattern','timing_probe')][string]$VideoMode='camera',
    [int]$TimeoutSeconds=600,
    [string]$EfinityHome='F:\Efinity\2026.1'
)
$ErrorActionPreference='Stop'
$PSNativeCommandUseErrorActionPreference=$false
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
    EFINITY_USER_DIR_INI=$(if($env:EFINITY_USER_DIR_INI){$env:EFINITY_USER_DIR_INI}else{$env:LOCALAPPDATA+'/efinity/user_dir.ini'});
    PATH=((Join-Path $homePath 'python311/bin')+';'+(Join-Path $homePath 'bin')+';'+(Join-Path $homePath 'debugger/bin')+';'+(Join-Path $homePath 'pgm/bin')+';'+$env:PATH)
}
$old=@{}
$exitCode=1
$vendorExitCode=$null
$sourceChanges=@()
$failureReason=$null
$wns=$null
$whs=$null
$boardConfig=Join-Path $root 'board/ti60f225_v4/rtl/vision_board_config.vh'
$originalConfig=$null
$inputHashes=[ordered]@{}
New-Item -ItemType Directory -Path (Join-Path $root 'results') -Force | Out-Null
try {
if($Top -eq 'board') {
    $originalConfig=[IO.File]::ReadAllBytes($boardConfig)
    $modeBit=if($VideoMode -ne 'camera'){1}else{0}
    $probeBit=if($VideoMode -eq 'timing_probe'){1}else{0}
    [IO.File]::WriteAllText($boardConfig,"// Build mode: $VideoMode`n``define VISION_TEST_PATTERN $modeBit`n``define VISION_TIMING_PROBE $probeBit`n")
}
$inputFiles=@(Get-ChildItem -LiteralPath (Join-Path $root 'rtl') -File)
if($Top -eq 'board') {
    $inputFiles+=@(Get-ChildItem -LiteralPath (Join-Path $projectDir 'rtl') -Recurse -File)
    $inputFiles+=@(Get-ChildItem -LiteralPath $projectDir -File | Where-Object {$_.Extension -in @('.xml','.sdc')})
} else {
    $inputFiles+=@(Get-Item -LiteralPath (Join-Path $projectDir "$projectName.xml"),(Join-Path $projectDir 'core.sdc'))
}
$inputHashes=[ordered]@{}
$xmlSemantics=@{}
foreach($file in $inputFiles) {
    $relative=[IO.Path]::GetRelativePath($root,$file.FullName).Replace('\','/')
    $inputHashes[$relative]=(Get-FileHash -LiteralPath $file.FullName).Hash.ToLowerInvariant()
    if($file.Extension -eq '.xml') {
        [xml]$inputXml=Get-Content -LiteralPath $file.FullName -Raw
        $xmlSemantics[$relative]=$inputXml.OuterXml
    }
}
New-Item -ItemType Directory -Path (Join-Path $root 'results') -Force | Out-Null
    foreach($key in $vars.Keys) {
        $old[$key]=[Environment]::GetEnvironmentVariable($key,'Process')
        [Environment]::SetEnvironmentVariable($key,$vars[$key],'Process')
    }
    Push-Location $projectDir
    try {
        & $python $runner "$projectName.xml" --flow $Flow --timeout $TimeoutSeconds 2>&1 |
            Tee-Object -FilePath (Join-Path $root "results/$Top.$Flow.console.log")
        $vendorExitCode=$LASTEXITCODE
        $exitCode=$vendorExitCode
        foreach($file in $inputFiles) {
            $relative=[IO.Path]::GetRelativePath($root,$file.FullName).Replace('\','/')
            if((Get-FileHash -LiteralPath $file.FullName).Hash.ToLowerInvariant() -ne $inputHashes[$relative]) {
                $normalizationOnly=$false
                if($xmlSemantics.ContainsKey($relative)) {
                    [xml]$outputXml=Get-Content -LiteralPath $file.FullName -Raw
                    $normalizationOnly=$outputXml.OuterXml -eq $xmlSemantics[$relative]
                }
                if(!$normalizationOnly) { $sourceChanges+=$relative; Write-Output "Source changed during compilation: $relative"; $exitCode=1 }
            }
        }
    } finally { Pop-Location }
} catch {
    $exitCode=1
    $failureReason=$_.Exception.Message
    Write-Output "Build invocation failed: $failureReason"
} finally {
    foreach($key in $old.Keys) { [Environment]::SetEnvironmentVariable($key,$old[$key],'Process') }
    if($null -ne $originalConfig) { [IO.File]::WriteAllBytes($boardConfig,$originalConfig) }
}
foreach($suffix in @('map.rpt','map.out','err.log','warn.log','route.rpt.xml','timing.rpt','pt.rpt.xml','place.rpt','cdc.rpt')) {
    $report=Join-Path $projectDir "outflow/$projectName.$suffix"
    if(Test-Path -LiteralPath $report) {
        Copy-Item -LiteralPath $report -Destination (Join-Path $root "results/$Top.$suffix") -Force
    }
}
$unassigned=$null
$routeReport=Join-Path $projectDir "outflow/$projectName.route.rpt.xml"
if($Top -eq 'board' -and $Flow -in @('compile','pnr') -and $exitCode -eq 0) {
    if(!(Test-Path -LiteralPath $routeReport) -or (Get-Item -LiteralPath $routeReport).LastWriteTimeUtc -lt [DateTime]::Parse($started).ToUniversalTime()) {
        Write-Output 'Fresh final route report is required.'; $exitCode=1
    }
}
if($Top -eq 'board' -and $Flow -in @('compile','pnr','pgm') -and (Test-Path -LiteralPath $routeReport)) {
  try {
    [xml]$routeXml=Get-Content -LiteralPath $routeReport -Raw
    $pinNode=$routeXml.SelectSingleNode("//*[local-name()='group_data' and @name='Unassigned Core Pins']")
    if($null -ne $pinNode) {
        $unassigned=[int]$pinNode.value
        if($unassigned -gt 0) { Write-Output "Unassigned core pins remain: $unassigned"; $exitCode=1 }
    }
    else { throw 'Unassigned Core Pins report field is missing.' }
    $timingNode=$routeXml.SelectSingleNode("//*[local-name()='group' and @name='Timing (Final)']")
    if($null -eq $timingNode) { Write-Output 'Final timing report is missing.'; $exitCode=1 }
    else {
        $wnsNode=$timingNode.SelectSingleNode("*[local-name()='group_data' and @name='Worst Negative Slack (WNS)']")
        $whsNode=$timingNode.SelectSingleNode("*[local-name()='group_data' and @name='Worst Hold Slack (WHS)']")
        $wns=[double]::Parse(($wnsNode.value -replace ' ns$',''),[Globalization.CultureInfo]::InvariantCulture)
        $whs=[double]::Parse(($whsNode.value -replace ' ns$',''),[Globalization.CultureInfo]::InvariantCulture)
        if($wns -lt 0 -or $whs -lt 0) { Write-Output "Final timing failed: WNS=$wns ns WHS=$whs ns"; $exitCode=1 }
    }
  } catch { $exitCode=1; $failureReason=$_.Exception.Message; Write-Output "Report validation failed: $failureReason" }
}
if($Top -eq 'board' -and $Flow -eq 'compile') {
    $bitPath=Join-Path $projectDir "outflow/$projectName.bit"
    if(!(Test-Path $bitPath) -or (Get-Item $bitPath).Length -eq 0 -or (Get-Item $bitPath).LastWriteTimeUtc -lt [DateTime]::Parse($started).ToUniversalTime()) {
        $exitCode=1; if(!$failureReason){$failureReason='Fresh nonempty bitstream is required.'}
    }
}
if($Top -eq 'board' -and $Flow -eq 'compile' -and $exitCode -eq 0) {
    $artifact=Join-Path $root "artifacts/$VideoMode"
    New-Item -ItemType Directory -Path $artifact -Force | Out-Null
    Get-ChildItem -LiteralPath (Join-Path $projectDir 'outflow') -File |
        Where-Object {$_.Name -match '\.(bit|hex|timing\.rpt|route\.rpt\.xml|map\.rpt)$'} |
        Copy-Item -Destination $artifact -Force
    $hashes=[ordered]@{}
    Get-ChildItem -LiteralPath $artifact -File | Where-Object {$_.Name -ne 'manifest.json'} | ForEach-Object {$hashes[$_.Name]=(Get-FileHash -LiteralPath $_.FullName).Hash}
    [ordered]@{video_mode=$VideoMode;test_pattern=$modeBit;timing_probe=$probeBit;wns_ns=$wns;whs_ns=$whs;finished_utc=[DateTime]::UtcNow.ToString('o');files=$hashes;source_sha256=$inputHashes;hardware_programmed=$false} |
        ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $artifact 'manifest.json') -Encoding utf8
}
[ordered]@{target=$Top;flow=$Flow;video_mode=$VideoMode;started_utc=$started;finished_utc=[DateTime]::UtcNow.ToString('o');exit_code=$exitCode;vendor_exit_code=$vendorExitCode;source_changes=$sourceChanges;failure_reason=$failureReason;unassigned_core_pins=$unassigned;wns_ns=$wns;whs_ns=$whs;source_sha256=$inputHashes;hardware_programmed=$false} |
    ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $root "results/$Top.$Flow.status.json") -Encoding utf8
if($exitCode -ne 0){exit $exitCode}
Write-Output "PASS Efinity target=$Top flow=$Flow (no board programming)"
