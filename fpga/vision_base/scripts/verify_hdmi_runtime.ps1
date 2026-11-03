param([string]$Url='ftdi://0x0403:0x6011:4:3/2',[string]$OutputDirectory='results/hdmi_restore_20260918')
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
. "$PSScriptRoot/efinity_env.ps1"
$out=Join-Path $root $OutputDirectory
New-Item -ItemType Directory -Force $out|Out-Null
function Read-Control([string]$name,[string[]]$arguments) {
 $lines=& "$env:PYTHONHOME/bin/python.exe" "$PSScriptRoot/vision_control.py" --url $Url @arguments
 if($LASTEXITCODE -ne 0){throw "JTAG failed: $name"}
 $lines|Set-Content (Join-Path $out "$name.json")
 $records=($lines -join "`n")|ConvertFrom-Json
 foreach($r in $records){if($r.magic -ne '56495331'){throw "Invalid signature: $name"}}
 return $records
}
$checks=@()
try {
 foreach($m in 0..7){
  $r=Read-Control "mode$m" @('--mode',"$m",'--samples','2')
  if($r[-1].mode -ne $m){throw "Mode mismatch $m"}
  $checks+= "mode$m readback passed"
 }
 foreach($med in 0,1){
  $r=Read-Control "median$med" @('--median',"$med",'--samples','2')
  if($r[-1].median -ne $med){throw 'Median mismatch'}
 }
 foreach($t in 32,128){
  $r=Read-Control "threshold$t" @('--threshold',"$t",'--samples','2')
  if($r[-1].threshold -ne $t){throw 'Threshold mismatch'}
 }
 $r=Read-Control 'live' @('--memory','0','--samples','8')
 if($r[-1].capture_id -le $r[0].capture_id -or $r[-1].display_id -le $r[0].display_id){throw 'Live counters stalled'}
 $r=Read-Control 'freeze' @('--memory','1','--samples','12')
 $stable=@($r|Select-Object -Skip 3)
 if(@($stable.display_id|Select-Object -Unique).Count -ne 1){throw 'Frozen frame changed'}
 $checks+='live advances and frozen frame holds'
 $r=Read-Control 'history2_static' @('--menu','0','--memory','2','--index','0','--samples','60')
 if(@(($r|Select-Object -Skip 3).display_id|Select-Object -Unique).Count -ne 1){throw 'F2 static frame changed'}
 $static=@();$r=Read-Control 'history2_index0' @('--samples','5');$static+=$r[-1].display_id
 foreach($i in 1..5){
  $r=Read-Control "history2_index$i" @('--key-event','2','--samples','5')
  if($r[-1].index -ne $i){throw "F2 key index mismatch $i"}
  $static+=$r[-1].display_id
 }
 if(@($static|Select-Object -Unique).Count -ne 6){throw 'F2 did not select six distinct frames'}
 $r=Read-Control 'history2_auto' @('--key-event','2','--samples','24')
 if($r[-1].index -ne 6 -or @($r.display_id|Select-Object -Unique).Count -lt 3){throw 'F2 explicit autoplay stalled'}
 $r=Read-Control 'history2_stop' @('--key-event','4','--samples','18')
 if($r[-1].index -ne 5 -or @(($r|Select-Object -Skip 3).display_id|Select-Object -Unique).Count -ne 1){throw 'F2 autoplay failed to stop'}
 $checks+='F2 static frame, six distinct key-selected frames, explicit index6 autoplay and stop'
 foreach($f in 3){
  $r=Read-Control "history$f" @('--memory',"$f",'--index','0','--samples','18')
  if(@($r.display_id|Select-Object -Unique).Count -lt 2){throw "History $f did not advance"}
  $checks+="history$f frame IDs change"
 }
 $r=Read-Control 'canny' @('--memory','0','--mode','5','--samples','12')
 if($r[-1].canny_fault -ne 0 -or $r[-1].canny_completed -le $r[0].canny_completed){throw 'Canny fault or stalled'}
 $checks+='Canny publishes with fault0'
 @{passed=$true;checks=$checks;scope='Register and DDR frame-ID validation; physical image and buttons require observation'}|ConvertTo-Json|Set-Content (Join-Path $out 'runtime_checks.json')
 $checks
} finally {
 Read-Control 'final_m0' @('--memory','0','--mode','0','--threshold','64','--median','1','--samples','2')|Out-Null
}

