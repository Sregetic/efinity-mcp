param(
    [ValidateSet('quick','full','hdmi')][string]$Suite='quick',
    [string]$Iverilog='C:\iverilog\bin\iverilog.exe',
    [string]$Vvp='C:\iverilog\bin\vvp.exe',
    [string]$ModelSim='E:\modeltech64_2020.4\win64',
    [string]$EfinityHome='F:\Efinity\2026.1',
    [string]$Python=(Join-Path $env:USERPROFILE '.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe')
)
$ErrorActionPreference='Stop'
$root = Split-Path -Parent $PSScriptRoot
$build = Join-Path $root 'build'
$results = Join-Path $root 'results'
New-Item -ItemType Directory -Path $build,$results -Force | Out-Null
if($Suite -eq 'hdmi') {
    # The existing vendor HDMI RTL is IEEE 1735 protected; use its Mentor key.
    $work=Join-Path $build 'hdmi'
    $logs=Join-Path $results 'hdmi'
    New-Item -ItemType Directory -Path $work,$logs -Force | Out-Null
    $board=Join-Path $root 'board/ti60f225_v4'
    [xml]$xml=Get-Content -LiteralPath (Join-Path $board 'ti60f225_oob.xml') -Raw
    $sources=@($xml.SelectNodes("//*[local-name()='design_file']") |
        Where-Object {$_.name -like 'rtl/dvi_tx/*' -or $_.name -eq 'rtl/simple_dual_port_ram.v'} |
        ForEach-Object {Join-Path $board $_.name})
    $sources+=@(Join-Path $EfinityHome 'sim_models/verilog/efx_srl8.v')
    $sources+=@(Join-Path $root 'sim/vision/tb_hdmi_avi.sv'; Join-Path $root 'sim/vision/tb_hdmi_protocol.sv')
    Push-Location $work
    try {
        & (Join-Path $ModelSim 'vlib.exe') work 2>&1 | Set-Content (Join-Path $logs 'compile.log')
        if($LASTEXITCODE){throw 'ModelSim work library creation failed.'}
        & (Join-Path $ModelSim 'vlog.exe') -sv -work work @sources 2>&1 | Add-Content (Join-Path $logs 'compile.log')
        if($LASTEXITCODE){throw 'HDMI RTL compilation failed; inspect results/hdmi/compile.log.'}
        foreach($test in @(@{top='tb';marker='HDMI AVI PASS'},@{top='tb_hdmi_protocol';marker='HDMI PROTOCOL PASS'})) {
            $log=Join-Path $logs ($test.top+'.log')
            $output=& (Join-Path $ModelSim 'vsim.exe') -c -onfinish exit -l $log -do 'run -all; quit -code 0' ('work.'+$test.top) 2>&1
            $code=$LASTEXITCODE
            $output | Set-Content (Join-Path $logs ($test.top+'.console.log'))
            if($code -ne 0 -or ($output -join "`n") -notmatch $test.marker){throw "HDMI simulation failed: $($test.top); inspect $log"}
            $output | Select-String $test.marker | ForEach-Object {$_.Line}
        }
    } finally {Pop-Location}
    @{passed=$true;generated_utc=[DateTime]::UtcNow.ToString('o');suite='hdmi';
      verification_scope='Vendor RTL TMDS word simulation; no physical link acceptance'} |
        ConvertTo-Json -Depth 5 | Set-Content (Join-Path $results 'verification.hdmi.json')
    Write-Output 'PASS vision_base suite=hdmi'
    exit 0
}
if (-not (Test-Path -LiteralPath $Iverilog) -or -not (Test-Path -LiteralPath $Vvp)) {
    throw 'Set -Iverilog and -Vvp to the installed Icarus executables.'
}
# The encoder uses a deterministic projection ROM and standard-library reference.
& $Python -E (Join-Path $root 'models/flyhash.py') --fixtures (Join-Path $root 'results/flyhash_20261004')
if($LASTEXITCODE -ne 0){throw 'FlyHash reference verification failed.'}
$tests = @(
    @{ Name='tb_vision_flyhash_mailbox'; Sources=@('rtl/vision_flyhash_mailbox.sv','sim/tb_vision_flyhash_mailbox.sv') },
    @{ Name='tb_vision_control_bridge'; Sources=@('rtl/vision_control_bridge.sv','rtl/stream_cdc.sv','board/ti60f225_v4/rtl/vision/vision_keys.sv','sim/tb_vision_control_bridge.sv') },
    @{ Name='tb_compute_lease'; Sources=@('rtl/frame_pool.sv','sim/tb_compute_lease.sv') },
    @{ Name='tb_analysis_dma'; Sources=@('rtl/vision_packed_rgb.sv','rtl/vision_analysis_dma.sv','sim/tb_analysis_dma.sv') },
    @{ Name='tb_packed_decode'; Sources=@('rtl/vision_packed_rgb.sv','sim/tb_packed_decode.sv') },
    @{ Name='tb_flyhash_encoder'; Sources=@('rtl/flyhash_encoder.sv','models/flyhash_projection.mem','sim/tb_flyhash_encoder.sv') },
    @{ Name='tb_board_bank_switch'; Sources=@('board/ti60f225_v4/rtl/frame_buffer_V3/bank_switch.v','sim/tb_board_bank_switch.sv') },
    @{ Name='tb_stream_cdc'; Sources=@('rtl/stream_cdc.sv','sim/tb_stream_cdc.sv') },
    @{ Name='tb_axi_burst_qos'; Sources=@('rtl/axi_burst_arbiter.sv','sim/tb_axi_burst_qos.sv') },
    @{ Name='tb_frame_memory_system'; Sources=@('rtl/frame_pool.sv','rtl/frame_render_control.sv','rtl/roi_scaler.sv','rtl/axi_line_reader.sv','rtl/roi_axi_scaler.sv','rtl/axi_frame_writer.sv','rtl/frame_render_engine.sv','rtl/axi_frame_reader.sv','rtl/axi_burst_arbiter.sv','rtl/frame_memory_system.sv','sim/tb_frame_memory_system.sv') },
    @{ Name='tb_frame_pool'; Sources=@('rtl/frame_pool.sv','sim/tb_frame_pool.sv') },
    @{ Name='tb_frame_render_control'; Sources=@('rtl/frame_pool.sv','rtl/frame_render_control.sv','sim/tb_frame_render_control.sv') },
    @{ Name='tb_video_test_pattern'; Sources=@('rtl/video_test_pattern.sv','sim/tb_video_test_pattern.sv') },
    @{ Name='tb_axi_frame_writer'; Sources=@('rtl/axi_frame_writer.sv','sim/tb_axi_frame_writer.sv') },
    @{ Name='tb_axi_line_reader'; Sources=@('rtl/axi_line_reader.sv','sim/tb_axi_line_reader.sv') },
    @{ Name='tb_roi_scaler'; Sources=@('rtl/roi_scaler.sv','sim/tb_roi_scaler.sv') },
    @{ Name='tb_roi_axi_scaler'; Sources=@('rtl/axi_line_reader.sv','rtl/roi_scaler.sv','rtl/roi_axi_scaler.sv','sim/tb_roi_axi_scaler.sv') },
    @{ Name='tb_frame_render_engine'; Sources=@('rtl/frame_pool.sv','rtl/frame_render_control.sv','rtl/roi_scaler.sv','rtl/axi_line_reader.sv','rtl/roi_axi_scaler.sv','rtl/axi_frame_writer.sv','rtl/frame_render_engine.sv','sim/tb_frame_render_engine.sv') }
)
$records = [System.Collections.Generic.List[object]]::new()
$allOk = $true
foreach ($test in $tests) {
    $name = $test.Name
    $program = Join-Path $build "$name.vvp"
    $compileLog = Join-Path $results "$name.compile.log"
    $runLog = Join-Path $results "$name.$Suite.log"
    $sources = @($test.Sources | Where-Object {$_ -notlike '*.mem'} | ForEach-Object { Join-Path $root $_ })
    $watch = [Diagnostics.Stopwatch]::StartNew()
    $compileText = @(& $Iverilog -g2012 -Wall -s $name -o $program @sources 2>&1)
    $compileExit = $LASTEXITCODE
    $compileText | Set-Content -LiteralPath $compileLog -Encoding utf8
    $runExit = $null
    $passed = $false
    if ($compileExit -eq 0) {
        $runArgs = @($program)
        if ($Suite -eq 'full' -and $name -in @('tb_roi_scaler','tb_roi_axi_scaler','tb_axi_frame_writer','tb_frame_render_engine','tb_frame_memory_system')) { $runArgs += '+FULL=1' }
        Push-Location $root
        try { $runText = @(& $Vvp @runArgs 2>&1); $runExit = $LASTEXITCODE } finally { Pop-Location }
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
$report = [ordered]@{
    generated_utc=[DateTime]::UtcNow.ToString('o');suite=$Suite;passed=$allOk;
    verification_scope='RTL simulation with behavioral memory; no Efinity P&R or hardware acceptance';
    tests=@($records.ToArray())
}
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $results "verification.$Suite.json") -Encoding utf8
if (-not $allOk) { exit 1 }
Write-Output "PASS vision_base suite=$Suite"
