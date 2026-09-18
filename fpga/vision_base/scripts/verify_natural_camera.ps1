param()
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
Push-Location $root
try {
 $out='results/natural_camera_20260916';New-Item -ItemType Directory $out -Force|Out-Null
 $tests=@(
 @{name='chroma_tone';src='board/ti60f225_v4/rtl/vision/rgb_chroma_tone.sv'},
 @{name='chroma_shadow';src='board/ti60f225_v4/rtl/vision/rgb_chroma_tone.sv'},
 @{name='camera_auto_exposure';src='board/ti60f225_v4/rtl/vision/camera_auto_exposure.sv'},
 @{name='sensor_exposure_writer';src='board/ti60f225_v4/rtl/vision/sensor_exposure_writer.sv'},
 @{name='i2c_readback';src='board/ti60f225_v4/rtl/cam_i2c_ctrl/i2c/i2c_16addr_8data.v'})
 foreach($t in $tests){
  $exe="$out/$($t.name).vvp"
  & C:/iverilog/bin/iverilog.exe -g2012 -s tb -o $exe "sim/vision/tb_$($t.name).sv" $t.src
  if($LASTEXITCODE -ne 0){throw "Compile failed: $($t.name)"}
  & C:/iverilog/bin/vvp.exe $exe | Tee-Object "$out/$($t.name).log"
  if($LASTEXITCODE -ne 0){throw "Test failed: $($t.name)"}
  Remove-Item -LiteralPath (Join-Path $root $exe)
 }
} finally {Pop-Location}
