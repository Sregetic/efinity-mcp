param([int]$TimeoutSeconds=1800,[switch]$ValidateOnly,[string]$ReleaseDir="$PSScriptRoot/outflow")
$ErrorActionPreference='Stop'
$root=(Resolve-Path "$PSScriptRoot/../..").Path
. "$root/scripts/efinity_env.ps1"
$ReleaseDir=[IO.Path]::GetFullPath($ReleaseDir)
Push-Location $PSScriptRoot
try {
 if(!$ValidateOnly){
 $python="$env:PYTHONHOME/bin/python.exe"
 & $python "$env:EFINITY_HOME/scripts/efx_run.py" vision_hdmi.xml --flow interface --timeout 300
 if($LASTEXITCODE){throw 'HDMI-only interface failed'}
 & $python ./update_timing.py
 if($LASTEXITCODE){throw 'HDMI timing generation failed'}
 & $python "$env:EFINITY_HOME/scripts/efx_run.py" vision_hdmi.xml --flow compile --timeout $TimeoutSeconds
 if($LASTEXITCODE){throw 'HDMI-only full compile failed'}
 }
 Get-Item -LiteralPath "$ReleaseDir/vision_hdmi.bit","$ReleaseDir/vision_hdmi.hex" | Out-Null
 [xml]$route=Get-Content -LiteralPath "$ReleaseDir/vision_hdmi.route.rpt.xml" -Raw
 if($route.DocumentElement.project -ne 'vision_hdmi'){throw 'Not a vision_hdmi native release'}
 $timing=$route.SelectSingleNode("//*[local-name()='group' and @name='Timing (Final)']")
 foreach($name in @('Worst Negative Slack (WNS)','Worst Hold Slack (WHS)')){
  $node=$timing.SelectSingleNode("*[local-name()='group_data' and @name='$name']")
  if(!$node -or [double]::Parse(($node.value -replace ' ns$',''),[Globalization.CultureInfo]::InvariantCulture) -lt 0){throw "Final timing failed: $name"}
 }
 $pins=$route.SelectSingleNode("//*[local-name()='group_data' and @name='Unassigned Core Pins']")
 if(!$pins -or [int]$pins.value){throw 'HDMI project has unassigned core pins'}
 Write-Output 'PASS HDMI-only native release and final timing; no board or Flash programming'
} finally {Pop-Location}
