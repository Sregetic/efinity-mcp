"""Exercise vendor launching on each host; Windows CI uses the real cmd.exe."""
from __future__ import annotations

import os

from conftest import wait


def test_windows_commandline_avoids_crt_quote_escaping(service):
    command = service.adapter.build(service.settings.projects["edge"], "map")
    if os.name == "nt":
        assert isinstance(command.popen_args, str)
        assert ' /s /c "call "' in command.popen_args
        assert '\\"' not in command.popen_args
        assert 'vendor tools' in command.popen_args
    else:
        assert command.popen_args == command.argv
    job = wait(service, service.run_build("edge", "map")["id"])
    assert job["status"] == "succeeded", service.jobs.log(job["id"])


def test_setup_failure_does_not_run_vendor_script(service):
    home = service.settings.home
    if os.name == "nt":
        (home / "bin/setup.bat").write_text('@echo off\nexit /b 23\n')
    else:
        (home / "bin/setup.sh").write_text('return 23\n')
    job = wait(service, service.run_build("edge", "map")["id"])
    assert job["status"] == "failed", service.jobs.log(job["id"])
    assert job["returncode"] == 23, service.jobs.log(job["id"])
    assert "code 23" in job["error"]
    assert not service.settings.projects["edge"].output.exists()
    assert not service.jobs.lockfile.exists()
