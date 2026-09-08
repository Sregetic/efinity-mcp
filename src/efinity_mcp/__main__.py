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
    parser.add_argument("--doctor", action="store_true", help="Print setup checks; do not start MCP")
    args = parser.parse_args()
    try:
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
