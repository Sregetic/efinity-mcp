function Assert-FpgaBuild {
    param([string]$ProjectRoot,[datetime]$StartedUtc,[string]$Mode='camera')
    $statusPath=Join-Path $ProjectRoot 'results/board.compile.status.json'
    $status=Get-Content -LiteralPath $statusPath -Raw | ConvertFrom-Json
    if($status.exit_code -ne 0 -or $null -eq $status.vendor_exit_code -or $status.vendor_exit_code -ne 0){throw 'Build or vendor exit code failed/missing.'}
    if($status.video_mode -ne $Mode -or $status.target -ne 'board' -or $status.flow -ne 'compile'){throw 'Build identity mismatch.'}
    if([datetime]$status.started_utc -lt $StartedUtc){throw 'Stale build status.'}
    if($status.source_changes.Count -gt 0 -or $status.failure_reason){throw 'Build source changed or validation failed.'}
    $out=Join-Path $ProjectRoot 'board/ti60f225_v4/outflow'
    foreach($name in @('ti60f225_oob.bit','ti60f225_oob.route.rpt.xml','ti60f225_oob.place.rpt','ti60f225_oob.timing.rpt')) {
        $f=Get-Item -LiteralPath (Join-Path $out $name)
        if($f.Length -eq 0 -or $f.LastWriteTimeUtc -lt $StartedUtc){throw "Missing, empty or stale output: $name"}
    }
    [xml]$route=Get-Content -LiteralPath "$out/ti60f225_oob.route.rpt.xml" -Raw
    foreach($field in @('Unassigned Core Pins','Missing Interface Pins')) {
        $node=$route.SelectSingleNode("//*[local-name()='group_data' and @name='$field']")
        if($null -eq $node -or $node.value -ne '0'){throw "Unconfirmed pin coverage: $field = $($node.value). Do not program."}
    }
    $timing=$route.SelectSingleNode("//*[local-name()='group' and @name='Timing (Final)']")
    if($null -eq $timing){throw 'Final timing is missing.'}
    $slacks=@()
    foreach($field in @('Worst Negative Slack (WNS)','Worst Hold Slack (WHS)')) {
        $node=$timing.SelectSingleNode("*[local-name()='group_data' and @name='$field']")
        if($null -eq $node){throw "Missing $field"}
        $v=[double]::Parse(($node.value -replace ' ns$',''),[Globalization.CultureInfo]::InvariantCulture)
        if([double]::IsNaN($v) -or [double]::IsInfinity($v) -or $v -lt 0){throw "Failed timing: $field"}
        $slacks+=$v
    }
    $sdc=Get-Content -LiteralPath "$ProjectRoot/board/ti60f225_v4/ti60f225_oob.sdc" -Raw
    foreach($clock in @('core_clk','vid_clk_dvi2','sdram_clk','hdmi_tx_slow_clk')) {
        if($sdc -notmatch "(?m)^create_clock[^\r\n]*-name $clock\s"){throw "Required clock constraint missing: $clock"}
        if($null -eq $timing.SelectSingleNode("*[local-name()='group_data' and @name='$clock']")){throw "Required clock absent from final timing: $clock"}
    }
    [xml]$project=Get-Content "$ProjectRoot/board/ti60f225_v4/ti60f225_oob.xml" -Raw
    foreach($pair in @(@('family','Titanium'),@('device','Ti60F225'),@('timing_model','I3'),@('top_module','ti60f225_oob_top'))) {
        if($project.SelectSingleNode("//*[local-name()='$($pair[0])']").name -ne $pair[1]){throw "Wrong board identity: $($pair[0])"}
    }
    return @{wns_ns=$slacks[0];whs_ns=$slacks[1];bit_sha256=(Get-FileHash "$out/ti60f225_oob.bit").Hash;video_mode=$Mode}
}
