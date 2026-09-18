$ErrorActionPreference='Stop'
. "$PSScriptRoot/../scripts/runner/BuildGate.ps1"
$root=Join-Path ([IO.Path]::GetTempPath()) ('efinity-gate-test-'+[guid]::NewGuid().ToString('N'))
$out="$root/board/ti60f225_v4/outflow"
New-Item -ItemType Directory $out,"$root/results" -Force | Out-Null
$started=[datetime]::UtcNow.AddSeconds(-2)
$status=@{exit_code=0;vendor_exit_code=0;video_mode='camera';target='board';flow='compile';started_utc=[datetime]::UtcNow.ToString('o');source_changes=@();failure_reason=$null}
$route='<report><group name="Interface"><group_data name="Unassigned Core Pins" value="0"/><group_data name="Missing Interface Pins" value="0"/></group><group name="Timing (Final)"><group_data name="Worst Negative Slack (WNS)" value="0.1 ns"/><group_data name="Worst Hold Slack (WHS)" value="0.02 ns"/>'
foreach($clock in @('core_clk','vid_clk_dvi2','sdram_clk','hdmi_tx_slow_clk')){$route+="<group_data name='$clock' value='100 MHz'/>"}
$route+='</group></report>'
function Reset-Fixture {
    $status | ConvertTo-Json | Set-Content "$root/results/board.compile.status.json"
    $route | Set-Content "$out/ti60f225_oob.route.rpt.xml"
    foreach($name in @('ti60f225_oob.bit','ti60f225_oob.place.rpt','ti60f225_oob.timing.rpt')){'synthetic test fixture'|Set-Content "$out/$name"}
    @('core_clk','vid_clk_dvi2','sdram_clk','hdmi_tx_slow_clk') | ForEach-Object {"create_clock -period 10 -name $_ [get_ports $_]"} | Set-Content "$root/board/ti60f225_v4/ti60f225_oob.sdc"
    '<project><family name="Titanium"/><device name="Ti60F225"/><timing_model name="I3"/><top_module name="ti60f225_oob_top"/></project>' | Set-Content "$root/board/ti60f225_v4/ti60f225_oob.xml"
}
$cases=@(
    @{name='vendor failure';change={$v=$status.Clone();$v.vendor_exit_code=1;$v|ConvertTo-Json|Set-Content "$root/results/board.compile.status.json"}},
    @{name='missing vendor result';change={$v=$status.Clone();$v.Remove('vendor_exit_code');$v|ConvertTo-Json|Set-Content "$root/results/board.compile.status.json"}},
    @{name='negative timing';change={($route -replace '0.1 ns','-0.1 ns')|Set-Content "$out/ti60f225_oob.route.rpt.xml"}},
    @{name='missing final timing';change={($route -replace 'Timing \(Final\)','Timing (Placement)')|Set-Content "$out/ti60f225_oob.route.rpt.xml"}},
    @{name='missing pins';change={($route -replace 'name="Missing Interface Pins" value="0"','name="Missing Interface Pins" value="11"')|Set-Content "$out/ti60f225_oob.route.rpt.xml"}},
    @{name='stale bitstream';change={(Get-Item "$out/ti60f225_oob.bit").LastWriteTimeUtc=$started.AddMinutes(-1)}},
    @{name='empty bitstream';change={[IO.File]::WriteAllBytes("$out/ti60f225_oob.bit",[byte[]]@())}},
    @{name='source mutation';change={$v=$status.Clone();$v.source_changes=@('rtl/changed.sv');$v|ConvertTo-Json|Set-Content "$root/results/board.compile.status.json"}},
    @{name='missing constraints';change={''|Set-Content "$root/board/ti60f225_v4/ti60f225_oob.sdc"}}
)
Reset-Fixture
$null=Assert-FpgaBuild $root $started
foreach($case in $cases){
    Reset-Fixture
    & $case.change
    $blocked=$false
    try{$null=Assert-FpgaBuild $root $started}catch{$blocked=$true}
    if(!$blocked){throw "Gate incorrectly accepted: $($case.name)"}
    Write-Output "PASS blocks $($case.name)"
}
Write-Output 'PASS 9 negative build gates; synthetic tests only, no hardware acceptance.'
