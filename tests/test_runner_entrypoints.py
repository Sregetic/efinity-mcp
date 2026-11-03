"""Windows Runner entrypoints: dispatch and rejection only, never hardware access."""

from __future__ import annotations

import json
import os
import shutil
import subprocess
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "fpga/vision_base/scripts"
pytestmark = pytest.mark.skipif(os.name != "nt", reason="Windows self-hosted Runner")


def run_script(path, *args, github_actions=False):
    return subprocess.run(
        ["pwsh", "-NoProfile", "-NonInteractive", "-File", str(path), *map(str, args)],
        capture_output=True,
        text=True,
        encoding="utf-8",
        env={**os.environ, "GITHUB_ACTIONS": str(github_actions).lower()},
        timeout=20,
    )


def test_sram_entrypoint_preserves_ci_approval_and_local_arguments(tmp_path):
    entry = tmp_path / "program_vision_sram.ps1"
    shutil.copyfile(SCRIPTS / entry.name, entry)
    (tmp_path / "program_vision_local_sram.ps1").write_text(
        "param($Url='local-default',$VideoMode='camera',$Sensor='sc431hai',"
        "[switch]$ValidateOnly,[switch]$BootOnly)\n"
        "@{local_dispatch=$true;url=$Url;mode=$VideoMode;sensor=$Sensor;"
        "validate=[bool]$ValidateOnly;boot=[bool]$BootOnly}|ConvertTo-Json -Compress\n"
    )
    result = run_script(entry)
    assert result.returncode != 0
    assert "local_dispatch" not in result.stdout
    result = run_script(entry, "-ValidateOnly")
    assert result.returncode == 0, result.stderr
    assert json.loads(result.stdout)["validate"] is True
    result = run_script(
        entry,
        "-Url",
        "ftdi://fixture/2",
        "-VideoMode",
        "pattern",
        "-Sensor",
        "sc2210",
        "-BootOnly",
    )
    assert result.returncode == 0, result.stderr
    assert json.loads(result.stdout) == {
        "local_dispatch": True,
        "url": "ftdi://fixture/2",
        "mode": "pattern",
        "sensor": "sc2210",
        "validate": False,
        "boot": True,
    }
    artifact_args = [
        "-ArtifactDirectory",
        tmp_path / "absent-artifact",
        "-BuildRunId",
        "42",
        "-CommitSha",
        "0" * 40,
        "-Url",
        "ftdi://fixture/2",
        "-OutputDirectory",
        tmp_path / "must-not-exist",
    ]
    result = run_script(entry, *artifact_args)
    assert result.returncode != 0
    assert "Explicit SRAM confirmation is required" in result.stderr
    assert "local_dispatch" not in result.stdout
    result = run_script(entry, *artifact_args, "-ValidateOnly")
    assert result.returncode != 0
    assert "local_dispatch" not in result.stdout
    invalid_args = artifact_args.copy()
    invalid_args[invalid_args.index("-CommitSha") + 1] = "invalid"
    result = run_script(entry, *invalid_args, "-ConfirmSram")
    assert result.returncode != 0
    assert "Invalid build identity" in result.stderr
    assert not (tmp_path / "must-not-exist").exists()
    result = run_script(
        SCRIPTS / "program_vision_local_sram.ps1", "-BootOnly", github_actions=True
    )
    assert result.returncode != 0
    assert "GitHub Actions must use the approved artifact entrypoint" in result.stderr


def test_runner_environment_honors_home_and_preserves_user_settings(tmp_path):
    home = tmp_path / "vendor home"
    home.mkdir()
    probe = tmp_path / "environment.ps1"
    probe.write_text(
        "param($EnvironmentScript,$HomePath)\n"
        "$env:EFINITY_USER_DIR='keep-user';$env:EFINITY_USER_DIR_INI='keep-ini'\n"
        ". $EnvironmentScript -EfinityHome $HomePath\n"
        "@{home=$env:EFINITY_HOME;user=$env:EFINITY_USER_DIR;"
        "ini=$env:EFINITY_USER_DIR_INI}|ConvertTo-Json -Compress\n"
    )
    result = run_script(probe, SCRIPTS / "efinity_env.ps1", home)
    assert result.returncode == 0, result.stderr
    assert json.loads(result.stdout) == {
        "home": home.resolve().as_posix(),
        "user": "keep-user",
        "ini": "keep-ini",
    }
