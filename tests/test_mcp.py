"""Real MCP SDK / subprocess transport test; no actual Efinity tool or FPGA required."""
from __future__ import annotations

import asyncio
import json
import os
import sys
from pathlib import Path

import pytest

if os.environ.get("EFINITY_REQUIRE_MCP") == "1":
    import mcp
else:
    mcp = pytest.importorskip("mcp", reason="MCP SDK unavailable locally; CI requires it")

from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client


def test_stdio_handshake_tools_and_safe_calls(tmp_path):
    config = tmp_path / "config.toml"
    config.write_text(f"workspace = {json.dumps(str(tmp_path))}\n")
    env = dict(os.environ, PYTHONPATH=str(Path(__file__).parents[1] / "src"))
    params = StdioServerParameters(command=sys.executable,
                                  args=["-m", "efinity_mcp", "--config", str(config)], env=env)

    async def run():
        async with stdio_client(params) as (reader, writer):
            async with ClientSession(reader, writer) as session:
                await session.initialize()
                tools = await session.list_tools()
                names = {tool.name for tool in tools.tools}
                assert {"run_build", "doctor", "read_report", "program_device"} <= names
                result = await session.call_tool("doctor", {})
                assert not result.isError
                data = json.loads(result.content[0].text)
                assert data["toolchain_available"] is False
                result = await session.call_tool("program_device", {
                    "project_id": "bad", "bitstream": "bad.bit", "target_url": "bad",
                    "expected_sha256": "bad", "confirm": True})
                assert result.isError
                assert "disabled" in result.content[0].text

    asyncio.run(asyncio.wait_for(run(), timeout=20))
