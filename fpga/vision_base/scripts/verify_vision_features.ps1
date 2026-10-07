param([switch]$Full)
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
Push-Location $root
try {
 $out='results/vision_features';New-Item -ItemType Directory $out -Force|Out-Null
 & C:/Users/Sregetic/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe -E scripts/reference_noise.py > "$out/noise_reference.log"
 if($LASTEXITCODE -ne 0){throw 'Noise reference checks failed'}
 $rtl='board/ti60f225_v4/rtl/vision/'
 $tests=@(
  @{name='osd';src=@('vision_osd.sv')},
  @{name='line_direct';src=@('vision_line_direct.sv','vision_window3_pair.sv','vision_line_metrics.sv','vision_frontend.sv','vision_window3.sv','vision_median9.sv','vision_sobel.sv')},
  @{name='shape_classifier';src=@('vision_shape_classifier.sv')},
  @{name='shadow_chroma';src=@('../rgb_shadow_denoise.sv')},
  @{name='sobel';src=@('vision_sobel.sv')},
  @{name='canny_stability';src=@('vision_canny.sv','vision_sparse_window.sv')},
  @{name='edge_strength';src=@('vision_display.sv','vision_frontend.sv','vision_window3.sv','vision_median9.sv','vision_sobel.sv','vision_shape_classifier.sv','vision_osd.sv')},
  @{name='sensor_init';src=@('../cam_i2c_ctrl/i2c/i2c_master_reg_rom.v')},
  @{name='canny_raster';src=@('vision_canny_raster.sv','vision_sparse_window.sv')},
  @{name='line_snapshot';src=@('vision_line_snapshot.sv')},
  @{name='hysteresis_random';src=@('vision_hysteresis_sweep.sv','vision_hysteresis.sv')},
  @{name='edge_probe';src=@('vision_hysteresis_sweep.sv','vision_hysteresis.sv')},
  @{name='canny_denoise';src=@('vision_canny_denoise.sv','vision_sparse_window.sv','vision_median9.sv')},
  @{name='canny_noise';src=@('vision_canny.sv','vision_canny_denoise.sv','vision_median9.sv','vision_hysteresis_sweep.sv','vision_hysteresis.sv','vision_sparse_window.sv','vision_sobel.sv')},
  @{name='edge_components';src=@('vision_hysteresis_sweep.sv','vision_hysteresis.sv')},
  @{name='edge_overlay';src=@('vision_display.sv','vision_frontend.sv','vision_window3.sv','vision_median9.sv','vision_sobel.sv','vision_shape_classifier.sv','vision_osd.sv')},
  @{name='frontend';src=@('vision_window3.sv','vision_median9.sv','vision_sobel.sv','vision_frontend.sv')},
  @{name='color';src=@('vision_window3.sv','vision_median9.sv','vision_sobel.sv','vision_frontend.sv')},
  @{name='color_denoise';src=@('vision_window3.sv','vision_median9.sv','vision_sobel.sv','vision_frontend.sv')},
  @{name='packed_rgb';src=@('vision_rgb_capture.sv','../../../../rtl/stream_cdc.sv')},
  @{name='median9';src=@('vision_median9.sv')},
  @{name='chroma_tone';src=@('rgb_chroma_tone.sv')},
  @{name='chroma_thresholds';src=@('rgb_chroma_tone.sv')},
  @{name='controls';src=@('vision_controls.sv','vision_keys.sv')},
  @{name='hysteresis';src=@('vision_hysteresis.sv')},
  @{name='hysteresis_sweep';src=@('vision_hysteresis_sweep.sv','vision_hysteresis.sv')},
  @{name='history';src=@('vision_frame_history.sv')},
  @{name='commit';src=@('vision_write_commit.sv')}
 )
 if($Full){
  $tests+=@{name='bayer_fov_reduce';src=@('../bayer_fov_reduce.sv')}
  $tests+=@{name='canny';src=@('vision_canny.sv','vision_canny_denoise.sv','vision_median9.sv','vision_hysteresis_sweep.sv','vision_hysteresis.sv','vision_sparse_window.sv','vision_sobel.sv')}
 }
 $report=@();$ok=$true
 foreach($t in $tests){
  $src=@($t.src|ForEach-Object{$rtl+$_});$exe="$out/$($t.name).vvp"
  & C:/iverilog/bin/iverilog.exe -g2012 -s tb -o $exe "sim/vision/tb_$($t.name).sv" @src 2>&1|Tee-Object "$out/$($t.name).compile.log"
  $ce=$LASTEXITCODE;$re=-1
  if($ce -eq 0){& C:/iverilog/bin/vvp.exe $exe 2>&1|Tee-Object "$out/$($t.name).run.log";$re=$LASTEXITCODE}
  $pass=$ce -eq 0 -and $re -eq 0;$report+=@{test=$t.name;passed=$pass;compile_exit=$ce;run_exit=$re}
  if(Test-Path $exe){Remove-Item -LiteralPath (Join-Path $root $exe)}
  if(!$pass){$ok=$false;break}
 }
 @{generated_utc=[DateTime]::UtcNow.ToString('o');passed=$ok;full=[bool]$Full;scope='RTL simulation, not physical display acceptance';tests=$report}|ConvertTo-Json -Depth 8|Set-Content "$out/verification.json"
 if(!$ok){throw 'Vision verification failed'}
 Write-Output 'PASS vision feature verification'
} finally {Pop-Location}

