"""Local setup helpers. These are CLI-only and never exposed as MCP write tools."""
from __future__ import annotations

import asyncio
import json
import os
import re
import sys
from pathlib import Path

from .config import EfinityError, inside, load_settings, portable_path

CODEX_TOOLS = [
    "doctor", "list_projects", "get_project", "preview_build", "run_build",
    "get_job", "cancel_job", "get_job_log", "list_reports", "read_report",
]


def write_config(filename: str | Path, workspace: str, home: str | None = None,
                 project_xml: str | None = None, project_id: str = "edge",
                 vendor_python: str | None = None) -> Path:
    """Create one new config; never overwrite one or implicitly authorize execution."""
    root = portable_path(Path(workspace).expanduser().resolve())
    if not root.is_dir():
        raise EfinityError("workspace must be an existing directory.")
    if not re.fullmatch(r"[A-Za-z0-9_-]{1,64}", project_id):
        raise EfinityError("Project ID must use letters, numbers, underscores or hyphens.")
    target = Path(filename).expanduser().absolute()
    # Refuse symlinks, too: opening in exclusive mode below prevents replacing a config.
    if target.exists() or target.is_symlink():
        raise EfinityError(f"Configuration already exists; not overwritten: {target}")
    if not target.parent.is_dir():
        raise EfinityError("Create the configuration's parent directory first.")
    lines = ["# Generated locally. Review the project before enabling trusted.",
             f"workspace = {json.dumps(str(root))}", ""]
    if home or vendor_python:
        lines += ["[efinity]"]
        for key, value in [("home", home), ("python", vendor_python)]:
            if value:
                path = portable_path(Path(value).expanduser().resolve())
                if not (path.is_dir() if key == "home" else path.is_file()):
                    raise EfinityError(f"Efinity {key} path does not exist: {path}")
                lines.append(f"{key} = {json.dumps(str(path))}")
        lines.append("")
    lines += ["[hardware]", "allow_programming = false", ""]
    if project_xml:
        xml = inside(root, Path(project_xml).expanduser(), exists=True)
        if xml.suffix.lower() != ".xml":
            raise EfinityError("Project paths must end in .xml.")
        lines += [f"[projects.{project_id}]", f"xml = {json.dumps(str(xml.relative_to(root)))}",
                  'output_dir = "outflow"', "trusted = false", ""]
    text = "\n".join(lines)
    # Content is constructed from validated values, not caller-supplied TOML.
    with target.open("x", encoding="utf-8", newline="\n") as handle:
        handle.write(text)
    return target


def codex_config(filename: str | Path) -> str:
    """Print an isolated table for manual merge; do not edit a client's configuration."""
    config = Path(filename).expanduser().resolve()
    load_settings(config)
    # Do NOT resolve symlinks on sys.executable: that can discard a venv on Unix.
    python = str(Path(sys.executable).absolute())
    args = ["-m", "efinity_mcp", "--config", str(config)]
    return "\n".join([
        "# Merge this table into your local Codex config; it does not enable programming.",
        "[mcp_servers.efinity]", f"command = {json.dumps(python)}",
        f"args = {json.dumps(args)}", "startup_timeout_sec = 30", "tool_timeout_sec = 30",
        f"enabled_tools = {json.dumps(CODEX_TOOLS)}", "",
    ])


def check_mcp(filename: str | Path, timeout: float = 30) -> dict:
    """Real stdio handshake and read-only calls. Never starts vendor tools or scans USB."""
    # Imported lazily so --init-config/--doctor work without the MCP SDK.
    from mcp import ClientSession, StdioServerParameters
    from mcp.client.stdio import stdio_client

    config = Path(filename).expanduser().resolve()
    load_settings(config)
    parameters = StdioServerParameters(
        command=sys.executable,
        args=["-m", "efinity_mcp", "--config", str(config)],
        env=dict(os.environ),
    )

    async def call(session, name):
        result = await session.call_tool(name, {})
        if result.isError:
            raise EfinityError(f"MCP {name} failed: {result.content}")
        return json.loads(result.content[0].text)

    async def inspect():
        async with stdio_client(parameters) as (reader, writer):
            async with ClientSession(reader, writer) as session:
                initialized = await session.initialize()
                tools = await session.list_tools()
                names = sorted(tool.name for tool in tools.tools)
                missing = set(CODEX_TOOLS) - set(names)
                if missing:
                    raise EfinityError(f"MCP server missing tools: {sorted(missing)}")
                doctor = await call(session, "doctor")
                projects = await call(session, "list_projects")
                return {
                    "protocol_ok": True, "protocol_version": initialized.protocolVersion,
                    "server": initialized.serverInfo.name, "tool_count": len(names),
                    "tools": names, "toolchain_available": doctor["toolchain_available"],
                    "programming_enabled": doctor["programming_enabled"],
                    "projects": projects["projects"], "vendor_commands_executed": False,
                    "hardware_accessed": False,
                    "note": "MCP connection works; Efinity compilation and board operation are not tested.",
                }

    async def bounded():
        return await asyncio.wait_for(inspect(), timeout=timeout)

    try:
        return asyncio.run(bounded())
    except Exception as exc:
        # anyio may wrap process/transport errors in ExceptionGroups; expose useful leaves.
        def messages(error):
            if isinstance(error, BaseExceptionGroup):
                return "; ".join(messages(item) for item in error.exceptions)
            return f"{type(error).__name__}: {error}"
        raise EfinityError(f"MCP connection check failed: {messages(exc)}") from exc
