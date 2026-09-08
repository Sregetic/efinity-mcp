"""Commands based on UG-EFN-CLI v1.1 and UG-EFN-PGM v4.3 (2026).

Only the vendor setup script is sourced. No caller-supplied shell, Tcl, or flags.
"""
from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path

from .config import EfinityError, Project, Settings, portable_path

FLOWS = ("compile", "map", "interface", "pnr", "pgm", "rtlsim", "mapsim")


@dataclass(frozen=True)
class Command:
    argv: list[str]
    cwd: Path
    windows_line: str | None = None

    @property
    def popen_args(self) -> list[str] | str:
        # cmd.exe does not follow the C runtime quoting rules used by list2cmdline.
        return self.windows_line if self.windows_line is not None else self.argv


def cmd_quote(value: str) -> str:
    portable_path(Path(value))
    # CALL has an extra expansion pass: reject all expansion/control characters above.
    return '"' + value + '"'


class Adapter:
    def __init__(self, settings: Settings):
        self.settings = settings

    def paths(self) -> dict[str, Path | None]:
        home = self.settings.home
        if home is None:
            return dict(home=None, setup=None, python=None, flow=None, programmer=None)
        candidates = ([home / "python3/python.exe", home / "python3/bin/python.exe",
                       home / "bin/python3.exe"] if os.name == "nt" else
                      [home / "python3/bin/python3", home / "bin/python3"])
        python = self.settings.vendor_python or next((p for p in candidates if p.is_file()), None)
        return dict(home=home, setup=home / ("bin/setup.bat" if os.name == "nt" else "bin/setup.sh"),
                    python=python, flow=home / "scripts/efx_run.py",
                    programmer=home / "pgm/bin/efx_pgm/ftdi_program.py")

    def doctor(self) -> dict:
        paths = self.paths()
        available = {key: bool(path and (path.is_dir() if key == "home" else path.is_file()))
                     for key, path in paths.items()}
        return {
            "toolchain_available": all(available[k] for k in ("home", "setup", "python", "flow")),
            "paths": {key: str(path) if path else None for key, path in paths.items()},
            "exists": available, "platform": os.name,
            "programming_enabled": self.settings.allow_programming,
            "license_validated": False, "board_validated": False,
            "hint": "Set [efinity].python to the real vendor Python executable if auto-detection fails. "
                    "File existence does not validate the Efinity license or board connection.",
        }

    def command(self, script: str, args: list[str], cwd: Path) -> Command:
        paths = self.paths()
        required = ("home", "setup", "python", script)
        for key in required:
            path = paths[key]
            if path is None or not (path.is_dir() if key == "home" else path.is_file()):
                raise EfinityError(f"Missing Efinity {key}; run doctor and check local configuration.")
        home, setup, python, executable = (paths[k] for k in required)
        assert home is not None and setup is not None and python is not None and executable is not None
        program = [str(python), "-u", str(executable), *args]
        for value in [str(home), str(setup), str(cwd), *program]:
            portable_path(Path(value))
        if os.name == "nt":
            system = Path(os.environ.get("SystemRoot", "C:/Windows")) / "System32/cmd.exe"
            line = (f"call {cmd_quote(str(setup))} >nul && cd /d {cmd_quote(str(cwd))} && "
                    + " ".join(cmd_quote(arg) for arg in program))
            # Pass the complete command line unchanged to CreateProcess. A list would
            # escape embedded quotes as \"; cmd.exe treats those backslashes literally.
            windows_line = f'{cmd_quote(str(system))} /d /v:off /s /c "{line}"'
            return Command([str(system), "/d", "/v:off", "/s", "/c", line], home,
                           windows_line=windows_line)
        # Positional arguments, not interpolation, keep even spaces literal to bash.
        line = 'source "$1" >/dev/null && cd -- "$2" && shift 2 && exec "$@"'
        return Command(["/bin/bash", "--noprofile", "--norc", "-c", line,
                        "efinity-mcp", str(setup), str(cwd), *program], home)

    def build(self, project: Project, flow: str) -> Command:
        if flow not in FLOWS:
            raise EfinityError(f"Unsupported flow. Allowed: {', '.join(FLOWS)}. "
                               "pgm GENERATES a bitstream; program is deliberately forbidden here.")
        return self.command("flow", [str(project.xml), "--flow", flow,
                                    "--output_dir", str(project.output)], project.xml.parent)

    def scan(self) -> Command:
        if self.settings.home is None:
            raise EfinityError("Efinity home is not configured.")
        return self.command("programmer", ["--list_usb"], self.settings.home)

    def program(self, bitstream: Path, target_url: str) -> Command:
        return self.command("programmer", [str(bitstream), "-m", "jtag", "--url", target_url,
                                           "--aurl", target_url], bitstream.parent)
