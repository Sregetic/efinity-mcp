"""Synthetic vendor executables: NEVER evidence of actual Efinity or board validation."""
from __future__ import annotations

import sys
import time
from dataclasses import replace

import pytest

from efinity_mcp.config import Project, Settings
from efinity_mcp.jobs import TERMINAL
from efinity_mcp.service import Service

FAKE_FLOW = r"""
import argparse, os, pathlib, sys, time
p=argparse.ArgumentParser()
p.add_argument('xml')
p.add_argument('--flow', required=True)
p.add_argument('--output_dir', required=True)
a=p.parse_args()
assert os.environ.get('EFINITY_MCP_TEST_SETUP') == 'ready'
xml=pathlib.Path(a.xml).read_text()
if 'SLEEP' in xml:
    print('SYNTHETIC long-running process', flush=True)
    time.sleep(60)
if 'FAIL' in xml:
    print('ERROR: synthetic compiler error', flush=True)
    sys.exit(7)
if 'LOUD' in xml:
    print('x'*65536, flush=True)
    time.sleep(60)
out=pathlib.Path(a.output_dir)
out.mkdir(parents=True, exist_ok=True)
(out/'demo.timing.rpt').write_text('SYNTHETIC REPORT, NOT REAL EFINITY\nWNS: -0.125 ns\n')
(out/'demo.map.rpt').write_text('SYNTHETIC RESOURCE REPORT\nLUTs: 12 / 100\n')
(out/'demo.bit').write_bytes(b'SYNTHETIC-NOT-A-REAL-BITSTREAM')
print('SYNTHETIC flow completed', a.flow, flush=True)
"""
FAKE_PROGRAM = r"""
import argparse, os, pathlib
p=argparse.ArgumentParser()
p.add_argument('bitstream', nargs='?')
p.add_argument('--list_usb', action='store_true')
p.add_argument('-m')
p.add_argument('--url')
p.add_argument('--aurl')
a=p.parse_args()
assert os.environ.get('EFINITY_MCP_TEST_SETUP') == 'ready'
if a.list_usb:
    print('SYNTHETIC ftdi://ftdi:4232h:TEST123/1')
else:
    assert a.m == 'jtag'
    assert a.url == a.aurl == 'ftdi://ftdi:4232h:TEST123/1'
    assert pathlib.Path(a.bitstream).name == 'approved.bit'
    print('SYNTHETIC programmer; NO HARDWARE TOUCHED')
"""


@pytest.fixture
def settings(tmp_path):
    workspace = tmp_path / "work space"
    workspace.mkdir()
    home = tmp_path / "vendor tools"
    for d in ["bin", "scripts", "pgm/bin/efx_pgm"]:
        (home / d).mkdir(parents=True)
    (home / "bin/setup.sh").write_text('export EFINITY_MCP_TEST_SETUP=ready\n')
    (home / "bin/setup.bat").write_text('@echo off\nset EFINITY_MCP_TEST_SETUP=ready\n')
    (home / "scripts/efx_run.py").write_text(FAKE_FLOW)
    (home / "pgm/bin/efx_pgm/ftdi_program.py").write_text(FAKE_PROGRAM)
    project_dir = workspace / "edge"
    project_dir.mkdir()
    xml = project_dir / "demo.xml"
    xml.write_text('<efx:project xmlns:efx="http://www.efinixinc.com/enf_proj" name="demo">'
                   '<efx:device name="Ti60F225"/></efx:project>')
    project = Project("edge", xml, project_dir / "outflow", True)
    from pathlib import Path
    return Settings(workspace, home, Path(sys.executable), {"edge": project}, timeout_seconds=15)


@pytest.fixture
def service(settings):
    instance = Service(settings)
    yield instance
    instance.close()


def wait(service, job_id, timeout=12):
    end = time.monotonic() + timeout
    while time.monotonic() < end:
        job = service.jobs.get(job_id)
        if job["status"] in TERMINAL:
            # Finished_at is saved only after artifact scanning and lock release.
            if job.get("finished_at"):
                return job
        time.sleep(0.025)
    raise AssertionError(f"Job did not finish: {service.jobs.get(job_id)}")


def changed(settings, **kwargs):
    return replace(settings, **kwargs)
