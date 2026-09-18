param([Parameter(Mandatory)][string]$BuildRunId,[Parameter(Mandatory)][string]$CommitSha,[Parameter(Mandatory)][string]$BitSha256,[Parameter(Mandatory)][string]$Url,[string]$Serial='', [string]$PnpInstanceId='',[ValidateSet('camera')][string]$Mode='camera')
$ErrorActionPreference='Stop'
if(!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){throw 'Local operator must run approval elevated; never run this from Actions.'}
if($BuildRunId -notmatch '^\d+$' -or $CommitSha -notmatch '^[a-f0-9]{40}$' -or $BitSha256 -notmatch '^[a-fA-F0-9]{64}$'){throw 'Invalid exact build identity.'}
if(!$Serial -and !$PnpInstanceId){throw 'Explicit USB identity is required.'}
$path="C:/ProgramData/efinity-runner/approve-$BuildRunId.json"
if(Test-Path $path){throw 'An approval already exists; inspect it rather than overwrite.'}
@{build_run_id=$BuildRunId;commit_sha=$CommitSha;bit_sha256=$BitSha256;url=$Url;serial=$Serial;pnp_instance_id=$PnpInstanceId;mode=$Mode;expires_utc=[datetime]::UtcNow.AddMinutes(30).ToString('o')} | ConvertTo-Json | Set-Content $path
& icacls.exe $path /grant '*S-1-5-20:(R,D)' | Out-Null
if($LASTEXITCODE -ne 0){throw 'Could not grant one-use approval access.'}
Write-Output "One-use SRAM approval created for build $BuildRunId; expires in 30 minutes."
