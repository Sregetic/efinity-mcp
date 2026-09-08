from __future__ import annotations

import json
import os
import subprocess
import sys
import time
from dataclasses import replace
from pathlib import Path

import pytest

from efinity_mcp.adapter import Adapter, FLOWS, cmd_quote
from efinity_mcp.config import EfinityError, inside, load_settings, portable_path
from efinity_mcp.service import Service

from conftest import wait

TARGET = "ftdi://ftdi:4232h:TEST123/1"


def mark(settings, value):
    settings.projects["edge"].xml.write_text(f'<project name="demo"><!--{value}--></project>')


def test_doctor_checks_files_not_license(service):
    result = service.adapter.doctor()
    assert result["toolchain_available"]
    assert result["license_validated"] is False
    assert result["board_validated"] is False


def test_doctor_offline(settings):
    result = Adapter(replace(settings, home=None, vendor_python=None)).doctor()
    assert result["toolchain_available"] is False


def test_project_metadata(service):
    info = service.project_info("edge")
    assert info["device_fields"] == [{"name": "Ti60F225"}]
    assert len(info["sha256"]) == 64


def test_unknown_project(service):
    with pytest.raises(EfinityError):
        service.run_build("../../other")


@pytest.mark.parametrize("flow", FLOWS)
def test_preview_and_execution(service, flow):
    preview = service.preview_build("edge", flow)
    assert preview["programs_hardware"] is False
    assert not service.settings.projects["edge"].output.exists()
    job = wait(service, service.run_build("edge", flow)["id"])
    assert job["status"] == "succeeded", job
    assert job["returncode"] == 0
    assert job["timing_pass"] is None
    assert any(f["path"] == "demo.bit" for f in job["changed_artifacts"])
    assert "SYNTHETIC flow completed" in service.jobs.log(job["id"])["text"]


@pytest.mark.parametrize("flow", ["program", "full", "compile; rm -rf /", "map --pgm_opts", ""])
def test_unsafe_flow_rejected(service, flow):
    with pytest.raises(EfinityError):
        service.run_build("edge", flow)


def test_untrusted_project(settings):
    settings = replace(settings, projects={"edge": replace(settings.projects["edge"], trusted=False)})
    service = Service(settings)
    try:
        assert service.preview_build("edge")["trusted"] is False
        with pytest.raises(EfinityError, match="trusted"):
            service.run_build("edge")
    finally:
        service.close()


def test_failure_exit_code(service):
    mark(service.settings, "FAIL")
    job = wait(service, service.run_build("edge")["id"])
    assert job["status"] == "failed"
    assert job["returncode"] == 7
    assert "synthetic compiler error" in service.jobs.log(job["id"])["text"]


def test_cancel_and_busy_lock(service):
    mark(service.settings, "SLEEP")
    job = service.run_build("edge")
    with pytest.raises(EfinityError, match="busy"):
        service.run_build("edge")
    time.sleep(0.2)
    assert service.jobs.cancel(job["id"])["cancel_requested"]
    assert wait(service, job["id"])["status"] == "cancelled"
    assert not service.jobs.lockfile.exists()


def test_timeout(settings):
    instance = Service(replace(settings, timeout_seconds=1))
    mark(settings, "SLEEP")
    try:
        job = wait(instance, instance.run_build("edge")["id"])
        assert job["status"] == "timed_out"
    finally:
        instance.close()


def test_log_limit(settings):
    instance = Service(replace(settings, max_log_bytes=1024))
    mark(settings, "LOUD")
    try:
        job = wait(instance, instance.run_build("edge")["id"])
        assert job["status"] == "log_limit_exceeded"
        log = instance.jobs.log(job["id"], 100)
        assert len(log["text"]) <= 100 and log["truncated"]
    finally:
        instance.close()


def test_stale_reports_not_new_evidence(service):
    p = service.settings.projects["edge"]
    p.output.mkdir()
    (p.output / "old.timing.rpt").write_text("OLD REPORT")
    job = wait(service, service.run_build("edge")["id"])
    reports = service.list_reports("edge", "timing", job["id"])
    assert [f["path"] for f in reports["files"]] == ["demo.timing.rpt"]
    (p.output / "demo.timing.rpt").write_text("edited after build")
    assert service.list_reports("edge", "timing", job["id"])["files"][0]["changed_since_job"]


def test_raw_reports_no_fake_timing_pass(service):
    wait(service, service.run_build("edge")["id"])
    report = service.read_report("edge", "demo.timing.rpt", 2, 1)
    assert report["lines"][0] == {"line": 2, "text": "WNS: -0.125 ns"}
    assert report["timing_pass"] is None
    assert report["untrusted_tool_output"] is True


def test_report_escape(service, tmp_path):
    output = service.settings.projects["edge"].output
    output.mkdir()
    secret = tmp_path / "secret.txt"
    secret.write_text("secret")
    with pytest.raises(EfinityError):
        service.read_report("edge", str(secret))
    with pytest.raises(EfinityError):
        service.read_report("edge", "../demo.xml")


def test_symlink_escape(service, tmp_path):
    output = service.settings.projects["edge"].output
    output.mkdir()
    secret = tmp_path / "secret.txt"
    secret.write_text("secret")
    link = output / "link.txt"
    try:
        link.symlink_to(secret)
    except OSError:
        pytest.skip("Symlink privilege is unavailable on this Windows runner")
    with pytest.raises(EfinityError):
        service.read_report("edge", "link.txt")
    assert service.list_reports("edge")["files"] == []


def test_xml_entities_rejected(service):
    service.settings.projects["edge"].xml.write_text(
        '<!DOCTYPE x [<!ENTITY bad SYSTEM "file:///etc/passwd">]><project>&bad;</project>')
    with pytest.raises(EfinityError, match="safely parse"):
        service.project_info("edge")


def test_scan_is_not_programming(service):
    job = wait(service, service.scan_devices()["id"])
    assert job["status"] == "succeeded"
    assert TARGET in service.jobs.log(job["id"])["text"]


def make_bit(service):
    p = service.settings.projects["edge"]
    p.output.mkdir(exist_ok=True)
    (p.output / "demo.bit").write_bytes(b"SYNTHETIC-NOT-FOR-HARDWARE")


def test_programming_disabled(service):
    with pytest.raises(EfinityError, match="disabled"):
        service.program_device("edge", "demo.bit", TARGET, "fake", True)


def test_programming_requires_approval_and_hash(settings):
    service = Service(replace(settings, allow_programming=True))
    make_bit(service)
    try:
        preview = service.preview_program("edge", "demo.bit", TARGET)
        with pytest.raises(EfinityError, match="approval"):
            service.program_device("edge", "demo.bit", TARGET, preview["sha256"])
        with pytest.raises(EfinityError, match="hash mismatch"):
            service.program_device("edge", "demo.bit", TARGET, "0"*64, True)
        job = wait(service, service.program_device("edge", "demo.bit", TARGET,
                                                   preview["sha256"], True)["id"])
        assert job["status"] == "succeeded", job
        assert job["evidence"]["bitstream_sha256"] == preview["sha256"]
        assert "NO HARDWARE TOUCHED" in service.jobs.log(job["id"])["text"]
    finally:
        service.close()


@pytest.mark.parametrize("target", ["", "ftdi://ftdi:4232h/1", TARGET+";bad", "https://bad"])
def test_program_needs_explicit_target(service, target):
    make_bit(service)
    with pytest.raises(EfinityError):
        service.preview_program("edge", "demo.bit", target)


def test_hex_not_accepted_for_jtag(service):
    make_bit(service)
    p = service.settings.projects["edge"]
    (p.output / "bad.hex").write_text("00")
    with pytest.raises(EfinityError, match=".bit"):
        service.preview_program("edge", "bad.hex", TARGET)


@pytest.mark.parametrize("path", ["a&b", "a%b", "a!b", "a^b", "a|b", "a>b", 'a"b', "中文"])
def test_nonportable_paths_rejected(path):
    with pytest.raises(EfinityError):
        portable_path(Path(path))


def test_cmd_quoting_spaces():
    assert cmd_quote("C:/Program Files/Efinity") == '"C:/Program Files/Efinity"'


def test_job_persistence_and_limits(service):
    job = wait(service, service.run_build("edge")["id"])
    second = Service(service.settings)
    try:
        assert second.jobs.get(job["id"])["returncode"] == 0
        with pytest.raises(EfinityError):
            second.jobs.log(job["id"], 70000)
        with pytest.raises(EfinityError):
            second.jobs.get("../invalid")
    finally:
        second.close()


def test_stale_lock_not_removed(service):
    service.jobs.lockfile.write_text('{"server_pid": -1}')
    with pytest.raises(EfinityError, match="interrupted"):
        service.run_build("edge")
    assert service.jobs.lockfile.exists()


def test_config_parse(tmp_path):
    config = tmp_path / "cfg.toml"
    config.write_text(f'workspace = {json.dumps(str(tmp_path))}\n'
                      '[projects.edge]\nxml="edge/demo.xml"\ntrusted=false\n')
    loaded = load_settings(config)
    assert loaded.projects["edge"].trusted is False
    assert loaded.allow_programming is False


@pytest.mark.parametrize("value", ['"false"', "1"])
def test_config_boolean_is_strict(tmp_path, value):
    config = tmp_path / "cfg.toml"
    config.write_text(f'workspace = {json.dumps(str(tmp_path))}\n'
                      f'[hardware]\nallow_programming={value}\n')
    with pytest.raises(EfinityError, match="boolean"):
        load_settings(config)


def test_config_escape(tmp_path):
    config = tmp_path / "cfg.toml"
    config.write_text(f'workspace = {json.dumps(str(tmp_path))}\n'
                      '[projects.edge]\nxml="../bad.xml"\n')
    with pytest.raises(EfinityError):
        load_settings(config)


def test_cli_missing_config_stderr_only(tmp_path):
    env = dict(os.environ, PYTHONPATH=str(Path(__file__).parents[1] / "src"))
    result = subprocess.run([sys.executable, "-m", "efinity_mcp", "--config", str(tmp_path/"no.toml")],
                            env=env, capture_output=True, text=True, timeout=10)
    assert result.returncode == 2
    assert not result.stdout
    assert "Cannot load configuration" in result.stderr


def test_read_window_validation(service):
    wait(service, service.run_build("edge")["id"])
    with pytest.raises(EfinityError):
        service.read_report("edge", "demo.timing.rpt", 0)
    with pytest.raises(EfinityError):
        service.read_report("edge", "demo.bit")


def test_inside_rejects_parent_even_if_it_returns_inside(tmp_path):
    with pytest.raises(EfinityError):
        inside(tmp_path, Path("sub/../other"))
