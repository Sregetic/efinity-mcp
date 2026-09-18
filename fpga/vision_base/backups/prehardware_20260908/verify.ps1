param(
    [ValidateSet('quick','full')][string]$Suite='quick',
    [string]$Iverilog='C:\iverilog\bin\iverilog.exe',
    [string]$Vvp='C:\iverilog\bin\vvp.exe'
)
$ErrorActionPreference='Stop'
$root = Split-Path -Parent $PSScriptRoot
$build = Join-Path $root 'build'
$results = Join-Path $root 'results'
New-Item -ItemType Directory -Path $build,$results -Force | Out-Null
if (-not (Test-Path -LiteralPath $Iverilog) -or -not (Test-Path -LiteralPath $Vvp)) {
    throw 'Set -Iverilog and -Vvp to the installed Icarus executables.'
}
$tests = @(
    @{ Name='tb_board_bank_switch'; Sources=@('board/ti60f225_v4/rtl/frame_buffer_V3/bank_switch.v','sim/tb_board_bank_switch.sv') },
    @{ Name='tb_frame_pool'; Sources=@('rtl/frame_pool.sv','sim/tb_frame_pool.sv') },
    @{ Name='tb_axi_line_reader'; Sources=@('rtl/axi_line_reader.sv','sim/tb_axi_line_reader.sv') },
    @{ Name='tb_roi_scaler'; Sources=@('rtl/roi_scaler.sv','sim/tb_roi_scaler.sv') },
    @{ Name='tb_roi_axi_scaler'; Sources=@('rtl/axi_line_reader.sv','rtl/roi_scaler.sv','rtl/roi_axi_scaler.sv','sim/tb_roi_axi_scaler.sv') }
)
$records = [System.Collections.Generic.List[object]]::new()
$allOk = $true
foreach ($test in $tests) {
    $name = $test.Name
    $program = Join-Path $build "$name.vvp"
    $compileLog = Join-Path $results "$name.compile.log"
    $runLog = Join-Path $results "$name.$Suite.log"
    $sources = @($test.Sources | ForEach-Object { Join-Path $root $_ })
    $watch = [Diagnostics.Stopwatch]::StartNew()
    $compileText = @(& $Iverilog -g2012 -Wall -s $name -o $program @sources 2>&1)
    $compileExit = $LASTEXITCODE
    $compileText | Set-Content -LiteralPath $compileLog -Encoding utf8
    $runExit = $null
    $passed = $false
    if ($compileExit -eq 0) {
        $runArgs = @($program)
        if ($Suite -eq 'full' -and $name -eq 'tb_roi_scaler') { $runArgs += '+FULL=1' }
        $runText = @(& $Vvp @runArgs 2>&1)
        $runExit = $LASTEXITCODE
        $runText | Set-Content -LiteralPath $runLog -Encoding utf8
        $runText | Write-Output
        $passed = $runExit -eq 0 -and (($runText -join "`n") -match "PASS $name")
    } else {
        $compileText | Write-Output
        'Simulation skipped because compilation failed.' | Set-Content -LiteralPath $runLog -Encoding utf8
    }
    $watch.Stop()
    $records.Add([ordered]@{
        test=$name;passed=$passed;compile_exit=$compileExit;simulation_exit=$runExit;
        host_elapsed_seconds=[Math]::Round($watch.Elapsed.TotalSeconds,3)
    })
    if (-not $passed) { $allOk=$false }
}
$identity = [ordered]@{}
@($tests | ForEach-Object {$_.Sources}) | Sort-Object -Unique | ForEach-Object {
        $identity[$_.Replace('\','/')]=(Get-FileHash -LiteralPath (Join-Path $root $_) -Algorithm SHA256).Hash.ToLowerInvariant()
    }
$report = [ordered]@{
    generated_utc=[DateTime]::UtcNow.ToString('o');suite=$Suite;passed=$allOk;
    verification_scope='RTL simulation with behavioral memory; no Efinity P&R or hardware acceptance';
    tests=@($records.ToArray());source_sha256=$identity
}
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $results "verification.$Suite.json") -Encoding utf8
if (-not $allOk) { exit 1 }
Write-Output "PASS vision_base suite=$Suite"
