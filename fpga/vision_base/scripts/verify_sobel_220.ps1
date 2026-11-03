param()
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
. "$PSScriptRoot/efinity_env.ps1"
$project=Join-Path $root 'efinity/sobel_220'
$out=Join-Path $root 'results/canny_sobel_20260919'
$source=Join-Path $root 'board/ti60f225_v4/rtl/vision/vision_sobel.sv'
$before=(Get-FileHash $source).Hash
$started=[DateTime]::UtcNow
& "$env:PYTHONHOME/bin/python.exe" "$PSScriptRoot/create_sobel_timing_project.py" 2>&1 | Tee-Object "$out/sobel_220.interface.log"
if($LASTEXITCODE -ne 0){throw 'Interface generation failed'}
Push-Location $project
try {
 & "$env:PYTHONHOME/bin/python.exe" "$env:EFINITY_HOME/scripts/efx_run.py" sobel_220.xml --flow compile --timeout 600 2>&1 | Tee-Object "$out/sobel_220.compile.log"
 $vendorExit=$LASTEXITCODE
} finally {Pop-Location}
[xml]$r=Get-Content "$project/outflow/sobel_220.route.rpt.xml"
$final=@($r.tool_report.group|Where-Object name -eq 'Timing (Final)')[0]
$wns=[double](($final.group_data|Where-Object name -eq 'Worst Negative Slack (WNS)').value -replace ' ns','')
$whs=[double](($final.group_data|Where-Object name -eq 'Worst Hold Slack (WHS)').value -replace ' ns','')
$freq=[double](($final.group_data|Where-Object name -eq 'clk').value -replace ' MHz','')
$iface=@($r.tool_report.group|Where-Object name -eq 'Interface')[0]
$unassigned=[int](($iface.group_data|Where-Object name -eq 'Unassigned Core Pins').value)
$missing=[int](($iface.group_data|Where-Object name -eq 'Missing Interface Pins').value)
$pll=Get-Content "$project/pll_220.json" -Raw|ConvertFrom-Json
$unchanged=$before -eq (Get-FileHash $source).Hash
$fresh=(Get-Item "$project/outflow/sobel_220.route.rpt.xml").LastWriteTimeUtc -ge $started
$pass=$vendorExit -eq 0 -and $unchanged -and $fresh -and $wns -ge 0 -and $whs -ge 0 -and $freq -ge 220 -and $unassigned -eq 0 -and $missing -eq 0 -and [double]$pll.CLKOUT0_FREQ -eq 220
$hashes=[ordered]@{}
foreach($f in @($source,"$project/sobel_timing_top.sv","$project/sobel_220.sdc","$project/sobel_220.xml","$project/sobel_220.peri.xml","$project/outflow/sobel_220.timing.rpt","$project/outflow/sobel_220.route.rpt.xml")){$hashes[[IO.Path]::GetRelativePath($root,$f)]=(Get-FileHash $f).Hash}
@{passed=$pass;started_utc=$started.ToString('o');vendor_exit=$vendorExit;source_unchanged=$unchanged;report_fresh=$fresh;wns_ns=$wns;whs_ns=$whs;analyzed_fmax_mhz=$freq;target_mhz=220;pll_output_mhz=[double]$pll.CLKOUT0_FREQ;unassigned_pins=$unassigned;missing_pins=$missing;scope='Isolated Ti60F225 I3 Sobel post-route capacity proof, not 220 MHz full-camera runtime';sha256=$hashes}|ConvertTo-Json -Depth 5|Set-Content "$out/sobel_220.status.json"
if(!$pass){throw '220 MHz timing acceptance failed'}
Write-Output "PASS Sobel 220 MHz post-route: WNS=$wns WHS=$whs Fmax=$freq MHz"
