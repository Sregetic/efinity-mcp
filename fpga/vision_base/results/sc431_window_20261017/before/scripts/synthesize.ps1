param(
    [ValidateSet('roi_axi_scaler','frame_pool','frame_render_engine','frame_memory_system','flyhash_encoder','board')][string]$Top='roi_axi_scaler',
    [ValidateSet('map','interface','pnr','pgm','compile')][string]$Flow='map',
    [ValidateSet('camera','pattern','timing_probe')][string]$VideoMode='camera',
    [ValidateSet('sc431hai','sc2210')][string]$Sensor='sc431hai',
    [string]$SensorProfile='',
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
if($Top -ne 'board' -and $Sensor -ne 'sc431hai'){throw 'Sensor selection applies to -Top board.'}
$sensorConfig=Join-Path $root 'board/ti60f225_v4/rtl/vision_sensor_config.vh'
$sensorDefaults=[IO.File]::ReadAllBytes($sensorConfig)
$sensorDefaultsHash=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($sensorDefaults))
$sensorHeader=[Text.Encoding]::UTF8.GetString($sensorDefaults)
$sensorFiles=@()
$selectedProfile=$null
if($Sensor -eq 'sc2210'){
    if(!$SensorProfile){throw 'SC2210 requires -SensorProfile with an explicit module/mode initialization table.'}
    $profileFile=Get-Item -LiteralPath $SensorProfile
    $selectedProfile=Get-Content -LiteralPath $profileFile.FullName -Raw | ConvertFrom-Json
    if($selectedProfile.sensor -ne 'sc2210' -or $selectedProfile.width -ne 1920 -or $selectedProfile.height -ne 1080 -or $selectedProfile.raw_bits -ne 10 -or $selectedProfile.bayer -ne 'BGGR' -or $selectedProfile.lanes -notin @(2,4)){
        throw 'Current SC2210 input contract: 1920x1080 BGGR RAW10, 2 or 4 MIPI lanes.'
    }
    $initFile=Get-Item -LiteralPath (Join-Path $profileFile.DirectoryName $selectedProfile.init_file)
    if((Get-FileHash -LiteralPath $initFile.FullName).Hash -ne $selectedProfile.init_sha256){throw 'SC2210 initialization table hash mismatch.'}
    $words=@(Get-Content -LiteralPath $initFile.FullName)
    if($words.Count -ne $selectedProfile.init_length -or $words.Count -lt 3){throw 'SC2210 initialization length mismatch.'}
    $registers=@{}
    foreach($word in $words){
        if($word -notmatch '^[0-1][0-9a-fA-F]{6}$'){throw 'SC2210 table requires 25-bit hexadecimal write words.'}
        $packed=[Convert]::ToUInt32($word,16)
        if($packed -band 1){throw 'SC2210 boot table requires write entries.'}
        $registers[[int]($packed -shr 9)]=[int](($packed -shr 1) -band 255)
    }
    if($registers[0x0100] -ne 1 -or $registers[0x3031] -ne 10 -or (($registers[0x3018] -shr 5)+1) -ne $selectedProfile.lanes -or (($registers[0x320e] -shl 8) -bor $registers[0x320f]) -ne $selectedProfile.vts){throw 'SC2210 table/profile format, lane count, stream or VTS mismatch.'}
    if($selectedProfile.exposure_min -lt 1 -or $selectedProfile.exposure_max -gt ($selectedProfile.vts-4) -or $selectedProfile.exposure_initial -lt $selectedProfile.exposure_min -or $selectedProfile.exposure_initial -gt $selectedProfile.exposure_max -or $selectedProfile.hs_byteclk_mhz -le 0 -or $selectedProfile.mclk_hz -lt 6000000 -or $selectedProfile.mclk_hz -gt 27000000){throw 'SC2210 clock or exposure profile out of datasheet range.'}
    if($selectedProfile.mipi_clock_mode -notin @('Continuous','Discontinuous') -or !($registers.ContainsKey(0x4800)) -or (($registers[0x4800] -band 0x20) -ne 0) -ne ($selectedProfile.mipi_clock_mode -eq 'Discontinuous')){throw 'SC2210 table/profile MIPI clock mode mismatch (4800[5]).'}
    $initPath=$initFile.FullName.Replace('\','/')
    $sensorHeader="// Sensor: sc2210, explicit profile`n``define VISION_SENSOR_SC2210 1`n``define VISION_SENSOR_LANES $($selectedProfile.lanes)`n``define VISION_SENSOR_BYTECLK_MHZ $($selectedProfile.hs_byteclk_mhz)`n``define VISION_SENSOR_DPHY_CLOCK_MODE `"$($selectedProfile.mipi_clock_mode)`"`n``define VISION_SENSOR_INIT_LENGTH $($selectedProfile.init_length)`n``define VISION_SENSOR_INIT_FILE `"$initPath`"`n``define VISION_SENSOR_EXPOSURE_MIN $($selectedProfile.exposure_min)`n``define VISION_SENSOR_EXPOSURE_MAX $($selectedProfile.exposure_max)`n``define VISION_SENSOR_EXPOSURE_INITIAL $($selectedProfile.exposure_initial)`n"
    $sensorFiles=@($profileFile,$initFile)
}
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
$wns=$null
$whs=$null
$boardConfig=Join-Path $root 'board/ti60f225_v4/rtl/vision_board_config.vh'
$originalConfig=$null
if($Top -eq 'board') {
    $originalConfig=[IO.File]::ReadAllBytes($boardConfig)
    $modeBit=if($VideoMode -ne 'camera'){1}else{0}
    $probeBit=if($VideoMode -eq 'timing_probe'){1}else{0}
    [IO.File]::WriteAllText($boardConfig,"// Build mode: $VideoMode`n``define VISION_TEST_PATTERN $modeBit`n``define VISION_TIMING_PROBE $probeBit`n")
    [IO.File]::WriteAllText($sensorConfig,$sensorHeader)
}
$inputFiles=@(Get-ChildItem -LiteralPath (Join-Path $root 'rtl') -File)
if($Top -eq 'board') {
    $inputFiles+=@(Get-ChildItem -LiteralPath (Join-Path $projectDir 'rtl') -Recurse -File)
    $inputFiles+=@(Get-ChildItem -LiteralPath $projectDir -File | Where-Object {$_.Extension -in @('.xml','.sdc')})
    $inputFiles+=$sensorFiles
} else {
    $inputFiles+=@(Get-Item -LiteralPath (Join-Path $projectDir "$projectName.xml"),(Join-Path $projectDir 'core.sdc'))
}
if($Top -eq 'flyhash_encoder'){$inputFiles+=Get-Item -LiteralPath (Join-Path $root 'models/flyhash_projection.mem')}
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
        foreach($file in $inputFiles) {
            $relative=[IO.Path]::GetRelativePath($root,$file.FullName).Replace('\','/')
            $outputHash=(Get-FileHash -LiteralPath $file.FullName).Hash.ToLowerInvariant()
            if($outputHash -ne $inputHashes[$relative]) {
                $normalizationOnly=$false
                if($xmlSemantics.ContainsKey($relative)) {
                    [xml]$outputXml=Get-Content -LiteralPath $file.FullName -Raw
                    $normalizationOnly=$outputXml.OuterXml -eq $xmlSemantics[$relative]
                }
                if(!$normalizationOnly) { Write-Output "Source changed during compilation: $relative"; $exitCode=1 }
                else {$inputHashes[$relative]=$outputHash} # Bind accepted XML normalization to the actual saved bytes.
            }
        }
    } finally { Pop-Location }
} finally {
    foreach($key in $old.Keys) { [Environment]::SetEnvironmentVariable($key,$old[$key],'Process') }
    if($null -ne $originalConfig) { [IO.File]::WriteAllBytes($boardConfig,$originalConfig) }
    if($Top -eq 'board') { [IO.File]::WriteAllBytes($sensorConfig,$sensorDefaults) }
}
foreach($suffix in @('map.rpt','map.out','err.log','warn.log','route.rpt.xml','timing.rpt','pt.rpt.xml','place.rpt','cdc.rpt')) {
    $report=Join-Path $projectDir "outflow/$projectName.$suffix"
    if(Test-Path -LiteralPath $report) {
        Copy-Item -LiteralPath $report -Destination (Join-Path $root "results/$Top.$suffix") -Force
    }
}
if($Top -eq 'board' -and $VideoMode -eq 'camera' -and $exitCode -eq 0 -and $Flow -in @('map','compile','pnr')){
    # warn.log accumulates previous builds; map.out belongs to this mapping run.
    $warnings=Get-Content -LiteralPath (Join-Path $projectDir "outflow/$projectName.map.out") -Raw
    if($warnings -match "net '(?:sc2210_input|sc431hai_input)\.[^']+' does not have a driver"){
        Write-Output 'Sensor input branch has an undriven signal; camera artifact rejected.'; $exitCode=1
    }
}
$unassigned=$null
$routeReport=Join-Path $projectDir "outflow/$projectName.route.rpt.xml"
if($Top -eq 'board' -and $Flow -in @('compile','pnr') -and $exitCode -eq 0) {
    if(!(Test-Path -LiteralPath $routeReport) -or (Get-Item -LiteralPath $routeReport).LastWriteTimeUtc -lt [DateTime]::Parse($started).ToUniversalTime()) {
        Write-Output 'Fresh final route report is required.'; $exitCode=1
    }
}
if($Top -eq 'board' -and $Flow -in @('compile','pnr','pgm') -and $exitCode -eq 0 -and (Test-Path -LiteralPath $routeReport)) {
    [xml]$routeXml=Get-Content -LiteralPath $routeReport -Raw
    $pinNode=$routeXml.SelectSingleNode("//*[local-name()='group_data' and @name='Unassigned Core Pins']")
    if($null -ne $pinNode) {
        $unassigned=[int]$pinNode.value
        if($unassigned -gt 0) { Write-Output "Unassigned core pins remain: $unassigned"; $exitCode=1 }
    }
    $timingNode=$routeXml.SelectSingleNode("//*[local-name()='group' and @name='Timing (Final)']")
    if($null -eq $timingNode) { Write-Output 'Final timing report is missing.'; $exitCode=1 }
    else {
        $wnsNode=$timingNode.SelectSingleNode("*[local-name()='group_data' and @name='Worst Negative Slack (WNS)']")
        $whsNode=$timingNode.SelectSingleNode("*[local-name()='group_data' and @name='Worst Hold Slack (WHS)']")
        $wns=[double]::Parse(($wnsNode.value -replace ' ns$',''),[Globalization.CultureInfo]::InvariantCulture)
        $whs=[double]::Parse(($whsNode.value -replace ' ns$',''),[Globalization.CultureInfo]::InvariantCulture)
        if($wns -lt 0 -or $whs -lt 0) { Write-Output "Final timing failed: WNS=$wns ns WHS=$whs ns"; $exitCode=1 }
    }
}
if($Top -eq 'board' -and $Flow -eq 'compile' -and $exitCode -eq 0) {
    $artifactMode=if($Sensor -eq 'sc2210'){"${VideoMode}_sc2210"}else{$VideoMode}
    $artifact=Join-Path $root "artifacts/$artifactMode"
    New-Item -ItemType Directory -Path $artifact -Force | Out-Null
    Get-ChildItem -LiteralPath (Join-Path $projectDir 'outflow') -File |
        Where-Object {$_.Name -match '\.(bit|hex|timing\.rpt|route\.rpt\.xml|map\.rpt)$'} |
        Copy-Item -Destination $artifact -Force
    $hashes=[ordered]@{}
    Get-ChildItem -LiteralPath $artifact -File | Where-Object {$_.Name -ne 'manifest.json'} | ForEach-Object {$hashes[$_.Name]=(Get-FileHash -LiteralPath $_.FullName).Hash}
    [ordered]@{video_mode=$VideoMode;sensor=$Sensor;sensor_profile=$selectedProfile;sensor_config_header=$sensorHeader;sensor_defaults_sha256=$sensorDefaultsHash;test_pattern=$modeBit;timing_probe=$probeBit;wns_ns=$wns;whs_ns=$whs;finished_utc=[DateTime]::UtcNow.ToString('o');files=$hashes;source_sha256=$inputHashes;hardware_programmed=$false} |
        ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $artifact 'manifest.json') -Encoding utf8
}
[ordered]@{target=$Top;flow=$Flow;video_mode=$VideoMode;sensor=$Sensor;started_utc=$started;finished_utc=[DateTime]::UtcNow.ToString('o');exit_code=$exitCode;unassigned_core_pins=$unassigned;wns_ns=$wns;whs_ns=$whs;source_sha256=$inputHashes;hardware_programmed=$false} |
    ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $root "results/$Top.$Flow.status.json") -Encoding utf8
if($exitCode -ne 0){exit $exitCode}
Write-Output "PASS Efinity target=$Top flow=$Flow (no board programming)"
