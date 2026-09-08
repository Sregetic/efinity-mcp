"""CLI entry point. Server stdout is reserved exclusively for MCP messages."""
from __future__ import annotations

import argparse
import json
import sys

from . import __version__
from .adapter import Adapter
from .config import EfinityError, load_settings


def main() -> int:
    parser = argparse.ArgumentParser(description="Local Efinity MCP server (stdio)")
    parser.add_argument("--version", action="version", version=__version__)
    parser.add_argument("--config", default="efinity-mcp.local.toml")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--doctor", action="store_true", help="Print setup checks; do not start MCP")
    mode.add_argument("--init-config", action="store_true", help="Create a new local configuration")
    mode.add_argument("--print-codex-config", action="store_true", help="Print a client config snippet")
    mode.add_argument("--check-mcp", action="store_true", help="Test real stdio, without running Efinity")
    parser.add_argument("--workspace", help="Existing workspace directory, for --init-config")
    parser.add_argument("--efinity-home", help="Efinity installation directory, for --init-config")
    parser.add_argument("--vendor-python", help="Vendor Python override, for --init-config")
    parser.add_argument("--project-xml", help="Project XML inside workspace, for --init-config")
    parser.add_argument("--project-id", help="Registered project name; defaults to edge")
    args = parser.parse_args()
    setup_args = (args.workspace, args.efinity_home, args.vendor_python,
                  args.project_xml, args.project_id)
    if any(value is not None for value in setup_args) and not args.init_config:
        parser.error("Setup path arguments require --init-config.")
    if args.init_config and not args.workspace:
        parser.error("--init-config requires --workspace.")
    try:
        if args.init_config:
            from .onboarding import write_config
            path = write_config(args.config, args.workspace, args.efinity_home,
                                args.project_xml, args.project_id or "edge", args.vendor_python)
            print(f"Created {path}. Project execution and hardware programming remain disabled.")
            return 0
        if args.print_codex_config:
            from .onboarding import codex_config
            print(codex_config(args.config), end="")
            return 0
        if args.check_mcp:
            from .onboarding import check_mcp
            print(json.dumps(check_mcp(args.config), indent=2))
            return 0
        settings = load_settings(args.config)
        if args.doctor:
            report = Adapter(settings).doctor()
            print(json.dumps(report, indent=2))
            return 0 if report["toolchain_available"] else 1
        from .server import create_server
        from .service import Service
        service = Service(settings)
        try:
            create_server(service).run(transport="stdio")
        finally:
            service.close()
        return 0
    except (EfinityError, OSError, ImportError) as exc:
        print(f"efinity-mcp: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
