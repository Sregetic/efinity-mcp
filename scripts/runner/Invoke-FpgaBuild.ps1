param([string]$EfinityHome='F:/Efinity/2026.1',[string]$WorkRoot='F:/efinity-ci/jobs',[string]$CommitSha,[string]$BuildRunId='local',[ValidateSet('camera')][string]$Mode='camera',[switch]$SmokeOnly)
$ErrorActionPreference='Stop'
$PSNativeCommandUseErrorActionPreference=$false
$repo=Split-Path (Split-Path $PSScriptRoot)
if(!$CommitSha){$CommitSha=git -C $repo rev-parse HEAD}
if($CommitSha -notmatch '^[a-f0-9]{40}$' -or $BuildRunId -notmatch '^[a-zA-Z0-9_-]+$'){throw 'Invalid run identity.'}
if($env:GITHUB_ACTIONS -eq 'true') {
    if((git -C $repo rev-parse HEAD) -ne $CommitSha){throw 'Checkout does not match event commit.'}
    git -C $repo diff --quiet HEAD -- fpga/vision_base scripts/runner
    if($LASTEXITCODE -ne 0){throw 'Checked-out build inputs have local modifications.'}
}
$run=Join-Path $WorkRoot ("$BuildRunId-"+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory "$run/upload/diagnostics" -Force | Out-Null
if($env:GITHUB_OUTPUT){"upload_dir=$run/upload" >> $env:GITHUB_OUTPUT}
$mutex=[Threading.Mutex]::new($false,'Global\Efinity-Ti60-device')
$locked=$false
$ok=$false
$failure=$null
$started=[datetime]::UtcNow
try {
    try {$locked=$mutex.WaitOne(0)} catch [Threading.AbandonedMutexException] {throw 'Previous device job ended abnormally; inspect local processes before retrying.'}
    if(!$locked){throw 'Another managed build/program job owns the device lock.'}
    & pwsh -NoProfile -File "$PSScriptRoot/Test-RunnerHost.ps1" -EfinityHome $EfinityHome *> "$run/upload/diagnostics/host.log"
    if($LASTEXITCODE -ne 0){throw 'Runner host smoke failed.'}
    if(!$SmokeOnly) {
        $project="$run/vision_base"
        & robocopy "$repo/fpga/vision_base" $project /E /XD outflow results artifacts backups build tmp work_syn work_pnr work_dbg work_sim /NFL /NDL /NJH /NJS /NP /R:1 /W:1 > "$run/upload/diagnostics/copy.log"
        if($LASTEXITCODE -ge 8){throw 'Isolated source copy failed.'}
        [xml]$xml=Get-Content "$project/board/ti60f225_v4/ti60f225_oob.xml" -Raw
        foreach($node in $xml.SelectNodes("//*[local-name()='design_file']")) {
            $path=[IO.Path]::GetFullPath((Join-Path "$project/board/ti60f225_v4" $node.name))
            if(!$path.StartsWith([IO.Path]::GetFullPath($project)+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw 'Project dependency leaves isolated source tree.'}
            if(!(Test-Path -LiteralPath $path)){throw "Missing project dependency: $($node.name)"}
            if((Get-Content -LiteralPath $path -TotalCount 1) -eq 'version https://git-lfs.github.com/spec/v1'){throw "Fetch this exact LFS dependency before building: $($node.name)"}
        }
        $checks=@(@('verify.ps1','-Suite','full'),@('verify_vision_features.ps1','-Full'),@('verify_natural_camera.ps1'))
        $simulationFailed=$false
        foreach($check in $checks) {
            $name=$check[0];$arguments=@($check | Select-Object -Skip 1)
            & pwsh -NoProfile -File "$project/scripts/$name" @arguments *> "$run/upload/diagnostics/$name.log"
            if($LASTEXITCODE -ne 0){$simulationFailed=$true}
        }
        if($simulationFailed){throw 'RTL simulation failed; compilation and programming blocked.'}
        & pwsh -NoProfile -File "$project/scripts/synthesize.ps1" -Top board -Flow compile -VideoMode $Mode -EfinityHome $EfinityHome -TimeoutSeconds 1800 *> "$run/upload/diagnostics/compile-invocation.log"
        if($LASTEXITCODE -ne 0){throw 'Efinity build failed; inspect invocation and status.'}
        . "$PSScriptRoot/BuildGate.ps1"
        $gate=Assert-FpgaBuild -ProjectRoot $project -StartedUtc $started -Mode $Mode
        New-Item -ItemType Directory "$run/upload/deploy" | Out-Null
        Copy-Item "$project/board/ti60f225_v4/outflow/ti60f225_oob.bit" "$run/upload/deploy/"
        Copy-Item "$project/results/board.compile.status.json" "$run/upload/deploy/"
        Copy-Item "$project/board/ti60f225_v4/outflow/ti60f225_oob.route.rpt.xml" "$run/upload/deploy/"
        $gate.repository='Sregetic/efinity-mcp';$gate.commit_sha=$CommitSha;$gate.build_run_id=$BuildRunId
        $gate.status_sha256=(Get-FileHash "$run/upload/deploy/board.compile.status.json").Hash
        $gate.route_sha256=(Get-FileHash "$run/upload/deploy/ti60f225_oob.route.rpt.xml").Hash
        $gate.deployable=$true;$gate.hardware_programmed=$false
        $gate | ConvertTo-Json | Set-Content "$run/upload/deploy/manifest.json"
    }
    $ok=$true
} catch {$failure=$_.Exception.Message;Write-Output $failure} finally {
    if(Test-Path "$run/vision_base/results") {
        Copy-Item "$run/vision_base/results" "$run/upload/diagnostics/results" -Recurse
        $out="$run/vision_base/board/ti60f225_v4/outflow"
        if(Test-Path $out){Get-ChildItem $out -File | Where-Object Name -match '\.(log|rpt|rpt.xml|out)$' | Copy-Item -Destination "$run/upload/diagnostics"}
    }
    @{passed=$ok;failure=$failure;commit_sha=$CommitSha;build_run_id=$BuildRunId;smoke_only=[bool]$SmokeOnly;started_utc=$started.ToString('o');finished_utc=[datetime]::UtcNow.ToString('o');hardware_programmed=$false} | ConvertTo-Json | Set-Content "$run/upload/result.json"
    $summary="FPGA run $BuildRunId on ${env:COMPUTERNAME}: passed=$ok; smoke=$SmokeOnly; commit=$CommitSha; error=$failure; hardware not programmed."
    if($env:GITHUB_STEP_SUMMARY){$summary >> $env:GITHUB_STEP_SUMMARY}
    Write-Output "$summary Outputs: $run/upload"
    if($locked){$mutex.ReleaseMutex()};$mutex.Dispose()
}
if(!$ok){exit 1}
