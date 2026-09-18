param([int]$Mode=-1,[int]$Threshold=-1,[int]$Median=-1,[int]$Memory=-1,[int]$Index=-1,[int]$Page=0,[string]$Url='ftdi://0x0403:0x6011:4:3/2')
$ErrorActionPreference='Stop'
. "$PSScriptRoot/efinity_env.ps1"
$a=@("$PSScriptRoot/vision_control.py",'--url',$Url,'--page',[string]$Page)
foreach($p in @(@('--mode',$Mode),@('--threshold',$Threshold),@('--median',$Median),@('--memory',$Memory),@('--index',$Index))){if($p[1] -ge 0){$a+=@($p[0],[string]$p[1])}}
& "$env:PYTHONHOME/bin/python.exe" @a
if($LASTEXITCODE -ne 0){throw 'Vision control failed; list current JTAG URL before retrying'}
