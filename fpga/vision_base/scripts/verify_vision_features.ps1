param([switch]$Full)
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
Push-Location $root
try {
 $out='results/vision_features';New-Item -ItemType Directory $out -Force|Out-Null
 $rtl='board/ti60f225_v4/rtl/vision/'
 $tests=@(
  @{name='frontend';src=@('vision_window3.sv','vision_median9.sv','vision_sobel.sv','vision_frontend.sv')},
  @{name='color';src=@('vision_window3.sv','vision_median9.sv','vision_sobel.sv','vision_frontend.sv')},
  @{name='median9';src=@('vision_median9.sv')},
  @{name='chroma_tone';src=@('rgb_chroma_tone.sv')},
  @{name='controls';src=@('vision_controls.sv')},
  @{name='hysteresis';src=@('vision_hysteresis.sv')},
  @{name='hysteresis_sweep';src=@('vision_hysteresis_sweep.sv','vision_hysteresis.sv')},
  @{name='history';src=@('vision_frame_history.sv')},
  @{name='commit';src=@('vision_write_commit.sv')}
 )
 if($Full){$tests+=@{name='canny';src=@('vision_canny.sv','vision_hysteresis_sweep.sv','vision_hysteresis.sv','vision_sparse_window.sv','vision_sobel.sv')}}
 $report=@();$ok=$true;$hashes=[ordered]@{}
 foreach($f in (Get-ChildItem $rtl -Filter '*.sv')){$hashes[$f.Name]=(Get-FileHash $f.FullName).Hash}
 foreach($t in $tests){
  $src=@($t.src|ForEach-Object{$rtl+$_});$exe="$out/$($t.name).vvp"
  & C:/iverilog/bin/iverilog.exe -g2012 -s tb -o $exe "sim/vision/tb_$($t.name).sv" @src 2>&1|Tee-Object "$out/$($t.name).compile.log"
  $ce=$LASTEXITCODE;$re=-1
  if($ce -eq 0){& C:/iverilog/bin/vvp.exe $exe 2>&1|Tee-Object "$out/$($t.name).run.log";$re=$LASTEXITCODE}
  $pass=$ce -eq 0 -and $re -eq 0;$report+=@{test=$t.name;passed=$pass;compile_exit=$ce;run_exit=$re}
  if(Test-Path $exe){Remove-Item -LiteralPath (Join-Path $root $exe)}
  if(!$pass){$ok=$false;break}
 }
 foreach($f in (Get-ChildItem $rtl -Filter '*.sv')){if((Get-FileHash $f.FullName).Hash -ne $hashes[$f.Name]){$ok=$false}}
 @{generated_utc=[DateTime]::UtcNow.ToString('o');passed=$ok;full=[bool]$Full;scope='RTL simulation, not physical display acceptance';tests=$report;source_sha256=$hashes}|ConvertTo-Json -Depth 8|Set-Content "$out/verification.json"
 if(!$ok){throw 'Vision verification failed'}
 Write-Output 'PASS vision feature verification'
} finally {Pop-Location}
