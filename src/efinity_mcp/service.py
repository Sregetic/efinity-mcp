"""MCP-independent application layer, testable without an Efinity installation."""
from __future__ import annotations

import hashlib
import re
from pathlib import Path

from .adapter import Adapter
from .config import EfinityError, Settings, inside
from .jobs import Jobs
from .reports import MAX_FILE, catalog, project_info, read_report, sha256


class Service:
    def __init__(self, settings: Settings):
        self.settings = settings
        self.adapter = Adapter(settings)
        self.jobs = Jobs(settings)

    def list_projects(self) -> dict:
        return {"projects": [{"id": p.id, "xml": str(p.xml), "exists": p.xml.is_file(),
                              "trusted": p.trusted} for p in self.settings.projects.values()]}

    def project_info(self, project_id: str) -> dict:
        return project_info(self.settings.project(project_id))

    def preview_build(self, project_id: str, flow: str = "compile") -> dict:
        p = self.settings.project(project_id)
        command = self.adapter.build(p, flow)
        return {"command": command.argv, "cwd": str(command.cwd), "flow": flow,
                "programs_hardware": False, "trusted": p.trusted,
                "note": "Dry run only. No vendor command executed."}

    def run_build(self, project_id: str, flow: str = "compile") -> dict:
        p = self.settings.project(project_id, execute=True)
        info = project_info(p)
        command = self.adapter.build(p, flow)
        return self.jobs.submit(lambda _: command, operation=flow, project_id=project_id,
                                output=p.output, evidence={"project_xml_sha256": info["sha256"]})

    def list_reports(self, project_id: str, kind: str = "all", job_id: str | None = None) -> dict:
        p = self.settings.project(project_id)
        current = catalog(p.output, kind)
        if job_id is not None:
            job = self.jobs.get(job_id)
            if job.get("project_id") != project_id:
                raise EfinityError("Job belongs to another project.")
            produced = {f["path"]: f for f in job.get("changed_artifacts", [])}
            current["files"] = [dict(f, changed_since_job=f != produced[f["path"]])
                                for f in current["files"] if f["path"] in produced]
            current["job_status"] = job["status"]
        return dict(current, classification="Filename heuristics; use kind=all if a report is missing.",
                    timing_pass=None)

    def read_report(self, project_id: str, path: str, start_line: int = 1, max_lines: int = 200) -> dict:
        p = self.settings.project(project_id)
        return read_report(p.output, path, start_line, max_lines)

    def scan_devices(self) -> dict:
        # Enumerates USB only. Does not select a default target or program the board.
        command = self.adapter.scan()
        return self.jobs.submit(lambda _: command, operation="list_usb", project_id=None,
                                timeout=min(30, self.settings.timeout_seconds))

    def preview_program(self, project_id: str, bitstream: str, target_url: str) -> dict:
        p = self.settings.project(project_id)
        file = inside(p.output, Path(bitstream), exists=True)
        if file.suffix.lower() != ".bit":
            raise EfinityError("JTAG mode requires a .bit file; .hex is not accepted or auto-converted.")
        if not re.fullmatch(r"ftdi://ftdi:(?:232h|2232h|4232h):[A-Za-z0-9_-]+/[1-4]", target_url):
            raise EfinityError("Use an explicit FTDI URL including chip type, serial and interface.")
        if not 0 < file.stat().st_size <= MAX_FILE:
            raise EfinityError("Bitstream must be nonempty and no larger than 128 MiB.")
        command = self.adapter.program(file, target_url)
        return {"project_id": project_id, "file": str(file), "sha256": sha256(file),
                "target_url": target_url, "mode": "jtag", "command": command.argv,
                "enabled": self.settings.allow_programming, "hardware_validated": False,
                "warning": "Reconfigures a physical FPGA and changes its I/O immediately. "
                           "Operator must verify board, pins, voltages and exact file before approval. "
                           "A hash acknowledgement is NOT proof of human consent."}

    def program_device(self, project_id: str, bitstream: str, target_url: str,
                       expected_sha256: str, confirm: bool = False) -> dict:
        if not self.settings.allow_programming:
            raise EfinityError("Hardware programming is disabled in local configuration.")
        self.settings.project(project_id, execute=True)
        if confirm is not True:
            raise EfinityError("Explicit operator approval is required; pass confirm=true only after approval.")
        preview = self.preview_program(project_id, bitstream, target_url)
        if expected_sha256 != preview["sha256"]:
            raise EfinityError("Bitstream hash mismatch; preview again and obtain fresh approval.")
        # Snapshot exactly the approved bytes; do not race a subsequent build modifying the original.
        with Path(preview["file"]).open("rb") as stream:
            data = stream.read(MAX_FILE + 1)
        if len(data) > MAX_FILE or hashlib.sha256(data).hexdigest() != expected_sha256:
            raise EfinityError("Bitstream changed while preparing the programming job.")

        def factory(directory: Path):
            snapshot = directory / "approved.bit"
            with snapshot.open("xb") as stream:
                stream.write(data)
            return self.adapter.program(snapshot, target_url)

        return self.jobs.submit(factory, operation="program_jtag", project_id=project_id,
                                timeout=min(120, self.settings.timeout_seconds),
                                evidence={"bitstream_sha256": expected_sha256, "target_url": target_url,
                                          "mode": "jtag"})

    def close(self) -> None:
        self.jobs.close()
