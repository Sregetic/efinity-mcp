[CmdletBinding(DefaultParameterSetName='CiArtifact')]
param(
    [Parameter(Mandatory,ParameterSetName='CiArtifact')][string]$ArtifactDirectory,
    [Parameter(Mandatory,ParameterSetName='CiArtifact')][string]$BuildRunId,
    [Parameter(Mandatory,ParameterSetName='CiArtifact')][string]$CommitSha,
    [Parameter(Mandatory,ParameterSetName='CiArtifact')]
    [Parameter(ParameterSetName='Local')][string]$Url,
    [Parameter(Mandatory,ParameterSetName='CiArtifact')][string]$OutputDirectory,
    [Parameter(ParameterSetName='CiArtifact')][ValidateSet('camera')][string]$Mode='camera',
    [Parameter(ParameterSetName='CiArtifact')][string]$EfinityHome='F:/Efinity/2026.1',
    [Parameter(ParameterSetName='CiArtifact')][switch]$ConfirmSram,
    [Parameter(ParameterSetName='Local')][ValidateSet('camera','pattern')][string]$VideoMode='camera',
    [Parameter(ParameterSetName='Local')][ValidateSet('sc431hai','sc2210')][string]$Sensor='sc431hai',
    [Parameter(ParameterSetName='Local')][switch]$ValidateOnly,
    [Parameter(ParameterSetName='Local')][switch]$BootOnly
)
$ErrorActionPreference='Stop'
if($PSCmdlet.ParameterSetName -eq 'Local') {
    & "$PSScriptRoot/program_vision_local_sram.ps1" @PSBoundParameters
    return
}
$PSNativeCommandUseErrorActionPreference=$false
if(!$ConfirmSram){throw 'Explicit SRAM confirmation is required.'}
if($BuildRunId -notmatch '^\d+$' -or $CommitSha -notmatch '^[a-f0-9]{40}$'){throw 'Invalid build identity.'}
$repo=Split-Path (Split-Path (Split-Path $PSScriptRoot))
$manifest=Get-Content "$ArtifactDirectory/manifest.json" -Raw | ConvertFrom-Json
$gate=Get-Content "$ArtifactDirectory/board.compile.status.json" -Raw | ConvertFrom-Json
if($manifest.deployable -ne $true -or $manifest.repository -ne 'Sregetic/efinity-mcp' -or $manifest.build_run_id -ne $BuildRunId -or $manifest.commit_sha -ne $CommitSha -or $manifest.video_mode -ne $Mode){throw 'Artifact provenance mismatch.'}
if((Get-FileHash "$ArtifactDirectory/board.compile.status.json").Hash -ne $manifest.status_sha256 -or (Get-FileHash "$ArtifactDirectory/ti60f225_oob.route.rpt.xml").Hash -ne $manifest.route_sha256){throw 'Artifact report digest mismatch.'}
if($gate.exit_code -ne 0 -or $null -eq $gate.vendor_exit_code -or $gate.vendor_exit_code -ne 0 -or $gate.unassigned_core_pins -ne 0 -or $gate.video_mode -ne $Mode -or $null -eq $gate.wns_ns -or $null -eq $gate.whs_ns -or $gate.wns_ns -lt 0 -or $gate.whs_ns -lt 0){throw 'Build gate failed.'}
[xml]$route=Get-Content "$ArtifactDirectory/ti60f225_oob.route.rpt.xml" -Raw
foreach($field in @('Unassigned Core Pins','Missing Interface Pins')) {
    $node=$route.SelectSingleNode("//*[local-name()='group_data' and @name='$field']")
    if($null -eq $node -or $node.value -ne '0'){throw 'Pin coverage not confirmed.'}
}
$timing=$route.SelectSingleNode("//*[local-name()='group' and @name='Timing (Final)']")
if($null -eq $timing){throw 'Missing final timing.'}
foreach($field in @('Worst Negative Slack (WNS)','Worst Hold Slack (WHS)')) {
    $node=$timing.SelectSingleNode("*[local-name()='group_data' and @name='$field']")
    if($null -eq $node){throw 'Missing timing field.'}
    $slack=[double]::Parse(($node.value -replace ' ns$',''),[Globalization.CultureInfo]::InvariantCulture)
    if([double]::IsNaN($slack) -or [double]::IsInfinity($slack) -or $slack -lt 0){throw 'Final timing failed.'}
}
$bytes=[IO.File]::ReadAllBytes((Join-Path $ArtifactDirectory 'ti60f225_oob.bit'))
$hash=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($bytes))
if($bytes.Length -eq 0 -or $hash -ne $manifest.bit_sha256){throw 'Bitstream digest mismatch.'}
$permitPath="C:/ProgramData/efinity-runner/approve-$BuildRunId.json"
$permit=Get-Content -LiteralPath $permitPath -Raw | ConvertFrom-Json
if($permit.build_run_id -ne $BuildRunId -or $permit.commit_sha -ne $CommitSha -or $permit.bit_sha256 -ne $hash -or $permit.url -ne $Url -or $permit.mode -ne $Mode -or [datetime]$permit.expires_utc -le [datetime]::UtcNow){throw 'Local operator approval missing, expired, or mismatched.'}
if(Test-Path $OutputDirectory){throw 'Use a new output directory for every programming attempt.'}
New-Item -ItemType Directory $OutputDirectory | Out-Null
$mutex=[Threading.Mutex]::new($false,'Global\Efinity-Ti60-device')
$locked=$false;$completed=$false;$code=$null;$failure=$null
try {
    try {$locked=$mutex.WaitOne(0)} catch [Threading.AbandonedMutexException] {throw 'Previous device job ended abnormally; inspect before programming.'}
    if(!$locked){throw 'Another managed device job is active.'}
    . "$PSScriptRoot/efinity_env.ps1" -EfinityHome $EfinityHome
    $devices=@((& "$env:PYTHONHOME/bin/python.exe" "$repo/scripts/runner/enumerate_usb.py") | ConvertFrom-Json)
    if($LASTEXITCODE -ne 0){throw 'USB descriptor enumeration failed.'}
    $matches=@($devices | Where-Object {$Url -in $_.urls})
    if($matches.Count -ne 1){throw 'The approved USB target is absent or ambiguous.'}
    if($matches[0].serial) {
        if($permit.serial -ne $matches[0].serial -or $Url -notlike "*:$($permit.serial)/*"){throw 'Use the verified serial-number URL and interface.'}
    } else {
        if(!$permit.pnp_instance_id){throw 'No serial number: explicit physical USB interface binding is required.'}
        $device=Get-PnpDevice -PresentOnly -InstanceId $permit.pnp_instance_id
        if($device.Status -ne 'OK' -or $permit.pnp_instance_id -notlike 'USB\VID_0403&PID_6011&MI_01\*' -or $Url -notmatch '/2$'){throw 'Approved physical interface is unavailable.'}
        if(@($devices | Where-Object {$_.vid -eq 0x0403 -and $_.pid -eq 0x6011}).Count -ne 1){throw 'Multiple FTDI boards require a new explicit binding.'}
    }
    $devices | ConvertTo-Json -Depth 4 | Set-Content "$OutputDirectory/usb.json"
    $bit=Join-Path $OutputDirectory 'approved.bit'
    [IO.File]::WriteAllBytes($bit,$bytes)
    # Service can consume this administrator-created file, not create new approvals.
    Remove-Item -LiteralPath $permitPath
    $log=& "$env:PYTHONHOME/bin/python.exe" "$env:EFXPGM_HOME/bin/efx_pgm/ftdi_program.py" $bit -m jtag -u $Url --jtag_clock_freq 1000000 2>&1
    $code=$LASTEXITCODE
    $log | Set-Content "$OutputDirectory/program.log"
    $completed=$code -eq 0 -and ($log -join "`n") -match 'finished with JTAG programming'
    if(!$completed){throw 'Programmer did not confirm SRAM completion.'}
} catch {$failure=$_.Exception.Message;Write-Output $failure} finally {
    @{build_run_id=$BuildRunId;commit_sha=$CommitSha;bit_sha256=$hash;mode=$Mode;url=$Url;operation='JTAG SRAM';flash_written=$false;exit_code=$code;programmer_completed=$completed;failure=$failure;visual_acceptance='pending user'} | ConvertTo-Json | Set-Content "$OutputDirectory/program.json"
    if($locked){$mutex.ReleaseMutex()};$mutex.Dispose()
}
if(!$completed){exit 1}
# Display mode changes remain a separate explicit control_vision.ps1 operation.
