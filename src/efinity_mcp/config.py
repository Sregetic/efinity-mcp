"""Local operator configuration; never writable through MCP."""
from __future__ import annotations

import os
import re
import tomllib
from dataclasses import dataclass
from pathlib import Path


class EfinityError(ValueError):
    """An actionable configuration, safety, or workflow error."""


def portable_path(path: Path) -> Path:
    text = str(path)
    if not text.isascii() or any(c in text for c in '%!^&|<>"\r\n\x00'):
        raise EfinityError("Use ASCII paths without shell metacharacters (spaces are supported).")
    return path


def inside(root: Path, path: Path, *, exists: bool = False) -> Path:
    """Check canonical containment, including symlink escapes and Windows junctions."""
    root = root.resolve()
    path = path if path.is_absolute() else root / path
    if ".." in path.parts:
        raise EfinityError("Parent traversal is not allowed.")
    resolved = path.resolve()
    if not resolved.is_relative_to(root):
        raise EfinityError("Path is outside its permitted directory.")
    if exists and not resolved.is_file():
        raise EfinityError(f"File not found: {resolved}")
    return portable_path(resolved)


def bounded_int(value: object, name: str, minimum: int, maximum: int) -> int:
    if type(value) is not int or not minimum <= value <= maximum:
        raise EfinityError(f"{name} must be an integer in [{minimum}, {maximum}].")
    return value


def boolean(value: object, name: str) -> bool:
    if type(value) is not bool:
        raise EfinityError(f"{name} must be a TOML boolean, not a string.")
    return value


@dataclass(frozen=True)
class Project:
    id: str
    xml: Path
    output: Path
    trusted: bool = False


@dataclass(frozen=True)
class Settings:
    workspace: Path
    home: Path | None
    vendor_python: Path | None
    projects: dict[str, Project]
    timeout_seconds: int = 3600
    max_log_bytes: int = 16 * 1024 * 1024
    allow_programming: bool = False

    @property
    def state_dir(self) -> Path:
        return inside(self.workspace, Path(".efinity-mcp"))

    def project(self, project_id: str, *, execute: bool = False) -> Project:
        if project_id not in self.projects:
            raise EfinityError("Unknown project ID; register it in the local TOML configuration.")
        p = self.projects[project_id]
        inside(self.workspace, p.xml, exists=True)
        inside(p.xml.parent, p.output)
        if execute and not p.trusted:
            raise EfinityError("Project execution is disabled; review it and set trusted = true locally.")
        return p


def load_settings(filename: str | Path) -> Settings:
    try:
        with Path(filename).expanduser().open("rb") as handle:
            data = tomllib.load(handle)
    except (OSError, tomllib.TOMLDecodeError) as exc:
        raise EfinityError(f"Cannot load configuration: {exc}") from exc
    allowed = {"workspace", "efinity", "projects", "limits", "hardware"}
    if set(data) - allowed:
        raise EfinityError(f"Unknown configuration keys: {sorted(set(data) - allowed)}")
    raw_root = data.get("workspace")
    if not isinstance(raw_root, str) or not Path(raw_root).expanduser().is_absolute():
        raise EfinityError("workspace must be an absolute directory path.")
    root = portable_path(Path(raw_root).expanduser().resolve())
    if not root.is_dir():
        raise EfinityError("Create the workspace directory before starting the server.")
    ef = data.get("efinity", {})
    limits = data.get("limits", {})
    hardware = data.get("hardware", {})
    for section, keys in [(ef, {"home", "python"}),
                          (limits, {"timeout_seconds", "max_log_bytes"}),
                          (hardware, {"allow_programming"})]:
        if not isinstance(section, dict) or set(section) - keys:
            raise EfinityError("Unknown keys or invalid table in local configuration.")

    def absolute(value: object) -> Path | None:
        if value is None or value == "":
            return None
        if not isinstance(value, str) or not Path(value).expanduser().is_absolute():
            raise EfinityError("Efinity home/python paths must be absolute.")
        return portable_path(Path(value).expanduser().resolve())

    projects = {}
    entries = data.get("projects", {})
    if not isinstance(entries, dict):
        raise EfinityError("projects must be a TOML table.")
    for name, spec in entries.items():
        if not re.fullmatch(r"[A-Za-z0-9_-]{1,64}", name):
            raise EfinityError("Project IDs may contain only letters, numbers, underscores and hyphens.")
        if not isinstance(spec, dict) or set(spec) - {"xml", "output_dir", "trusted"}:
            raise EfinityError(f"Invalid project table: {name}")
        if not isinstance(spec.get("xml"), str):
            raise EfinityError(f"Project {name} needs an XML path.")
        xml = inside(root, Path(spec["xml"]))
        if xml.suffix.lower() != ".xml":
            raise EfinityError("Project paths must end in .xml.")
        output_name = spec.get("output_dir", "outflow")
        if not isinstance(output_name, str):
            raise EfinityError("output_dir must be a string.")
        output = inside(xml.parent, Path(output_name))
        if output == xml.parent or any(p in {".git", ".efinity-mcp"} for p in output.parts):
            raise EfinityError("Output must be a separate project subdirectory, not internal state.")
        projects[name] = Project(name, xml, output, boolean(spec.get("trusted", False), "trusted"))
    home = absolute(ef.get("home") or os.environ.get("EFINITY_HOME"))
    return Settings(
        root, home, absolute(ef.get("python")), projects,
        bounded_int(limits.get("timeout_seconds", 3600), "timeout_seconds", 1, 14400),
        bounded_int(limits.get("max_log_bytes", 16777216), "max_log_bytes", 1024, 67108864),
        boolean(hardware.get("allow_programming", False), "allow_programming"),
    )
