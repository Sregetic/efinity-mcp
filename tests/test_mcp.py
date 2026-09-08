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


def project_config(settings, tmp_path):
    from efinity_mcp.onboarding import write_config
    config = write_config(tmp_path / "mcp.toml", str(settings.workspace), str(settings.home),
                          "edge/demo.xml", vendor_python=str(settings.vendor_python))
    # Test operator authorization, for SYNTHETIC scripts only.
    config.write_text(config.read_text().replace("trusted = false", "trusted = true"))
    return config


@pytest.mark.parametrize("fails", [False, True])
def test_stdio_build_poll_logs_and_reports(settings, tmp_path, fails):
    from efinity_mcp.jobs import TERMINAL
    config = project_config(settings, tmp_path)
    if fails:
        xml = settings.projects["edge"].xml
        xml.write_text(xml.read_text() + "<!-- FAIL -->")
    env = dict(os.environ, PYTHONPATH=str(Path(__file__).parents[1] / "src"))
    params = StdioServerParameters(command=sys.executable,
                                  args=["-m", "efinity_mcp", "--config", str(config)], env=env)

    async def run():
        async with stdio_client(params) as (reader, writer):
            async with ClientSession(reader, writer) as session:
                await session.initialize()

                async def call(name, **arguments):
                    response = await session.call_tool(name, arguments)
                    assert not response.isError, response.content
                    return json.loads(response.content[0].text)

                preview = await call("preview_build", project_id="edge", flow="map")
                assert preview["programs_hardware"] is False
                job = await call("run_build", project_id="edge", flow="map")
                while True:
                    job = await call("get_job", job_id=job["id"])
                    if job["status"] in TERMINAL and job.get("finished_at"):
                        break
                    await asyncio.sleep(0.05)
                log = await call("get_job_log", job_id=job["id"])
                if fails:
                    assert job["status"] == "failed" and job["returncode"] == 7, log
                    assert "synthetic compiler error" in log["text"]
                else:
                    assert job["status"] == "succeeded" and job["returncode"] == 0, log
                    assert "SYNTHETIC flow completed" in log["text"]
                    reports = await call("list_reports", project_id="edge", kind="timing", job_id=job["id"])
                    assert [item["path"] for item in reports["files"]] == ["demo.timing.rpt"]
                    report = await call("read_report", project_id="edge", path="demo.timing.rpt")
                    assert report["timing_pass"] is None
                    assert report["untrusted_tool_output"] is True
                    assert "SYNTHETIC" in report["lines"][0]["text"]
                rejected = await session.call_tool("run_build", {"project_id": "edge", "flow": "program"})
                assert rejected.isError

    asyncio.run(asyncio.wait_for(run(), timeout=30))
    assert not (settings.state_dir / "execution.lock").exists()


def test_cli_mcp_check_is_read_only(settings, tmp_path):
    import subprocess
    config = project_config(settings, tmp_path)
    env = dict(os.environ, PYTHONPATH=str(Path(__file__).parents[1] / "src"))
    result = subprocess.run([sys.executable, "-m", "efinity_mcp", "--config", str(config),
                             "--check-mcp"], env=env, capture_output=True, text=True, timeout=40)
    assert result.returncode == 0, result.stderr
    data = json.loads(result.stdout)
    assert data["protocol_ok"] and data["tool_count"] == 13
    assert data["vendor_commands_executed"] is False and data["hardware_accessed"] is False
    assert not settings.projects["edge"].output.exists()
    assert not (settings.state_dir / "execution.lock").exists()
