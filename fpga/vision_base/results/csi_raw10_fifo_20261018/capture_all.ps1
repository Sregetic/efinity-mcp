$ErrorActionPreference='Stop'
Set-Location 'F:/Project/fpga/vision_base'
. ./scripts/efinity_env.ps1
$python="$env:PYTHONHOME/bin/python.exe"
$out='results/csi_raw10_fifo_20261018'
$url='ftdi://0x0403:0x6011:4:a/2'
try {
 & $python scripts/vision_control.py --url $url --roi-status --ai-policy 0 --menu 0 --mode 5 --median 1 --sobel-threshold 128 --canny-threshold 80 --roi 0 0 1920 1080 --output-size 1920 1080 --position 0 0 --roi-enable 1 --memory 1 > "$out/frozen_start.json"
 if($LASTEXITCODE -ne 0){throw 'Acquire frozen source failed'}
 Start-Sleep -Seconds 1
 & $python scripts/capture_edge_probe.py --url $url --output "$out/edge_before" --keep-held
 if($LASTEXITCODE -ne 0){throw 'Initial Canny plane export failed'}
 & $python scripts/capture_mode_images.py --url $url --output-dir "$out/images" --current-view
 if($LASTEXITCODE -ne 0){throw 'Nine-mode export failed'}
 & $python scripts/capture_edge_probe.py --url $url --output "$out/edge_after"
 if($LASTEXITCODE -ne 0){throw 'Final Canny plane export failed'}
} finally {
 & $python scripts/vision_control.py --url $url --roi-status --ai-policy 0 --menu 0 --mode 5 --median 1 --sobel-threshold 128 --canny-threshold 80 --roi 0 0 1920 1080 --output-size 1920 1080 --position 0 0 --roi-enable 0 --memory 0 > "$out/final_status.json"
 if($LASTEXITCODE -ne 0){throw 'Restore live view failed'}
}
& 'C:/Users/Sregetic/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' -E -X utf8 "$out/check_images.py"
if($LASTEXITCODE -ne 0){throw 'Same-frame image comparison failed'}
