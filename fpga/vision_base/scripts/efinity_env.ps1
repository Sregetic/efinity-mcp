param([string]$EfinityHome='F:/Efinity/2026.1')
# Process-local environment; invoke callers in a separate pwsh process.
$env:EFINITY_HOME=(Resolve-Path -LiteralPath $EfinityHome).Path.Replace('\','/')
$env:EFXPGM_HOME="$env:EFINITY_HOME/pgm"
$env:EFXPT_HOME="$env:EFINITY_HOME/pt"
$env:EFXIPM_HOME="$env:EFINITY_HOME/ipm"
$env:EFXDBG_HOME="$env:EFINITY_HOME/debugger"
$env:EFXSVF_HOME="$env:EFXDBG_HOME/svf_player"
if(!$env:EFINITY_USER_DIR_INI){$env:EFINITY_USER_DIR_INI="$env:LOCALAPPDATA/efinity/user_dir.ini"}
if(!$env:EFINITY_USER_DIR){$env:EFINITY_USER_DIR="$env:USERPROFILE/.efinity"}
$env:PYTHONHOME="$env:EFINITY_HOME/python311"
$env:PYTHONPATH="$env:EFXDBG_HOME/bin;$env:EFXPGM_HOME/bin"
$env:PATH="$env:PYTHONHOME/bin;$env:EFINITY_HOME/bin;$env:EFXPGM_HOME/bin;$env:EFXDBG_HOME/bin;$env:PATH"
