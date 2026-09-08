"""Local setup has no vendor, client-config or hardware side effects."""
from __future__ import annotations

import json
import os
import subprocess
import sys
import tomllib
from pathlib import Path

import pytest

from efinity_mcp.config import EfinityError, load_settings
from efinity_mcp.onboarding import CODEX_TOOLS, codex_config, write_config


def cli(*args):
    env = dict(os.environ, PYTHONPATH=str(Path(__file__).parents[1] / "src"))
    return subprocess.run([sys.executable, "-m", "efinity_mcp", *args], env=env,
                          capture_output=True, text=True, timeout=15)


def test_init_registers_project_without_authorizing_it(settings, tmp_path):
    config = tmp_path / "local.toml"
    write_config(config, str(settings.workspace), str(settings.home), "edge/demo.xml",
                 vendor_python=str(settings.vendor_python))
    loaded = load_settings(config)
    assert loaded.home == settings.home
    # Configuration canonicalizes paths; Linux runners expose python as a symlink.
    assert loaded.vendor_python == settings.vendor_python.resolve()
    assert loaded.projects["edge"].xml == settings.projects["edge"].xml
    assert loaded.projects["edge"].trusted is False
    assert loaded.allow_programming is False
    assert not loaded.state_dir.exists()
    assert not loaded.projects["edge"].output.exists()


def test_init_without_efinity_supports_protocol_only(tmp_path):
    config = write_config(tmp_path / "local.toml", str(tmp_path))
    loaded = load_settings(config)
    assert loaded.projects == {} and not loaded.allow_programming


def test_existing_config_is_not_overwritten(tmp_path):
    config = tmp_path / "local.toml"
    config.write_text("existing operator config")
    with pytest.raises(EfinityError, match="not overwritten"):
        write_config(config, str(tmp_path))
    assert config.read_text() == "existing operator config"


@pytest.mark.parametrize("case", ["workspace", "home", "python", "escape", "extension", "id"])
def test_init_rejects_invalid_inputs_without_creating_file(tmp_path, case):
    target = tmp_path / "config.toml"
    text = tmp_path / "not-xml.txt"
    text.write_text("not a project")
    args = {"filename": target, "workspace": str(tmp_path)}
    if case == "workspace":
        args["workspace"] = str(tmp_path / "missing")
    elif case == "home":
        args["home"] = str(tmp_path / "missing")
    elif case == "python":
        args["vendor_python"] = str(tmp_path / "missing.exe")
    elif case == "escape":
        args["project_xml"] = "../project.xml"
    elif case == "extension":
        args["project_xml"] = str(text)
    else:
        args["project_id"] = "unsafe.name"
    with pytest.raises(EfinityError):
        write_config(**args)
    assert not target.exists()


def test_codex_snippet_keeps_virtualenv_and_excludes_hardware(tmp_path, monkeypatch):
    config = write_config(tmp_path / "local.toml", str(tmp_path))
    # Deliberately a venv-shaped path; resolving it could discard a Unix venv symlink.
    executable = str(tmp_path / ".venv" / "bin" / "python")
    monkeypatch.setattr(sys, "executable", executable)
    text = codex_config(config)
    table = tomllib.loads(text)["mcp_servers"]["efinity"]
    assert table["command"] == executable
    assert table["args"] == ["-m", "efinity_mcp", "--config", str(config)]
    assert table["enabled_tools"] == CODEX_TOOLS
    assert not {"scan_devices", "preview_program", "program_device"} & set(CODEX_TOOLS)


def test_cli_setup_and_snippet(tmp_path):
    config = tmp_path / "config.toml"
    result = cli("--config", str(config), "--init-config", "--workspace", str(tmp_path))
    assert result.returncode == 0, result.stderr
    result = cli("--config", str(config), "--print-codex-config")
    assert result.returncode == 0, result.stderr
    assert tomllib.loads(result.stdout)["mcp_servers"]["efinity"]["command"] == sys.executable
    result = cli("--config", str(config), "--doctor")
    assert result.returncode == 1
    assert json.loads(result.stdout)["board_validated"] is False


@pytest.mark.parametrize("args", [["--init-config"], ["--workspace", "."],
                                 ["--doctor", "--check-mcp"]])
def test_cli_rejects_invalid_mode_arguments(args):
    result = cli(*args)
    assert result.returncode == 2 and not result.stdout
