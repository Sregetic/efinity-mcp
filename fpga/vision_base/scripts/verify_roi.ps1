param([switch]$Full)
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
Push-Location $root
try {
 $out=Join-Path $root 'results/roi_live_20261004'
 New-Item -ItemType Directory $out -Force|Out-Null
 $src=@('rtl/frame_pool.sv','rtl/frame_render_control.sv','rtl/roi_scaler.sv','rtl/axi_line_reader.sv','rtl/roi_axi_scaler.sv','rtl/axi_frame_writer.sv','rtl/frame_render_engine.sv','rtl/axi_frame_reader.sv','rtl/axi_burst_arbiter.sv','rtl/frame_memory_system.sv','rtl/stream_cdc.sv','board/ti60f225_v4/rtl/vision/vision_rgb_capture.sv','board/ti60f225_v4/rtl/vision/vision_rgb_scanout.sv','board/ti60f225_v4/rtl/vision/vision_roi_control.sv','sim/vision/tb_roi_live.sv')
 $hash=[ordered]@{};foreach($f in $src){$hash[$f]=(Get-FileHash -LiteralPath $f).Hash}
 $name=if($Full){'roi_full'}else{'roi_live'}
 $exe=Join-Path $out ($name+'.vvp');$params=@()
 if($Full){$params=@('-Ptb_roi_live.W=1920','-Ptb_roi_live.H=1080')}
 & C:/iverilog/bin/iverilog.exe -g2012 -s tb_roi_live @params -o $exe @src 2>&1|Tee-Object (Join-Path $out ($name+'.compile.log'))
 if($LASTEXITCODE){throw 'ROI compile failed'}
 $output=@(& C:/iverilog/bin/vvp.exe $exe 2>&1);$code=$LASTEXITCODE
 $output|Set-Content (Join-Path $out ($name+'.test.log'));$output|Write-Output
 foreach($f in $src){if((Get-FileHash -LiteralPath $f).Hash -ne $hash[$f]){throw "Source changed during ROI verification: $f"}}
 if($code -or ($output -join "`n") -notmatch 'PASS ROI'){throw 'ROI simulation failed'}
 @{passed=$true;full=[bool]$Full;source_sha256=$hash;generated_utc=[DateTime]::UtcNow.ToString('o')}|ConvertTo-Json -Depth 4|Set-Content (Join-Path $out ($name+'.verification.json'))
 Remove-Item -LiteralPath $exe
} finally {Pop-Location}
