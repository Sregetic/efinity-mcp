param(
 [Parameter(Mandatory=$true)][string]$Url,
 [Parameter(Mandatory=$true)][string]$ReleaseDir,
 [Parameter(Mandatory=$true)][string]$OutputDir
)
$ErrorActionPreference='Stop'
$root=(Resolve-Path "$PSScriptRoot/../..").Path
$release=(Resolve-Path $ReleaseDir).Path
$out=[IO.Path]::GetFullPath($OutputDir)
& "$PSScriptRoot/build.ps1" -ValidateOnly -ReleaseDir $release
Get-Item -LiteralPath "$release/vision_hdmi.bit","$release/vision.elf" | Out-Null
New-Item -ItemType Directory -Force $out | Out-Null
. "$root/scripts/efinity_env.ps1"
$python="$env:PYTHONHOME/bin/python.exe"
Push-Location $root
try{
 & $python "$env:EFXPGM_HOME/bin/efx_pgm/ftdi_program.py" "$release/vision_hdmi.bit" -m jtag -u $Url --jtag_clock_freq 1000000 *> "$out/program_sram.log"
 if($LASTEXITCODE){throw 'HDMI SRAM programming failed'}
 # The unchanged boot ROM first finishes its existing autonomous Flash application load.
 Start-Sleep -Seconds 35
 & $python scripts/load_vision_ddr.py --url $Url --elf "$release/vision.elf" --jtag-khz 1000 --chunk-bytes 1024 --output-dir "$out/app" *> "$out/load_app.log"
 if($LASTEXITCODE){throw 'HDMI application load/readback failed; CPU is halted'}
 & $python scripts/vision_control.py --url $Url --sensor hq12 --page 34 --samples 3 > "$out/input.json"
 if($LASTEXITCODE){throw 'HDMI input diagnostic failed'}
 $inputSamples=Get-Content "$out/input.json" -Raw | ConvertFrom-Json
 foreach($sample in $inputSamples){
  if(!$sample.source_present -or !$sample.input_pll_locked -or !$sample.input_aligned -or !$sample.avi_seen -or $sample.input_frame_bad -or $sample.input_format -ne 2 -or $sample.colorimetry -ne 2 -or $sample.ycc_quantization -ne 0 -or $sample.input_fifo_overflows){throw 'HQ12 input is not receiving the validated YCbCr444/BT709 limited stream'}
 }
 if($inputSamples[-1].source_frame -le $inputSamples[0].source_frame){throw 'HDMI source frames are not advancing'}
 & $python scripts/vision_control.py --url $Url --sensor hq12 --roi-status > "$out/roi.json"
 if($LASTEXITCODE){throw 'HDMI backend startup check failed'}
 $roi=Get-Content "$out/roi.json" -Raw | ConvertFrom-Json
 if(!$roi.rgb_capture_count -or $roi.recognition_model -ne 2 -or $roi.config_error -or $roi.render_error -or $roi.scan_error -or $roi.canny_fault){throw 'HDMI backend/application startup is not healthy'}
 Write-Output "HDMI SRAM + DDR application loaded. Flash not written. Evidence: $out"
} finally {Pop-Location}
