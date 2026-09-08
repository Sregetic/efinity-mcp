"""Non-blocking build jobs with bounded logs, cancellation and an exclusive workspace lock."""
from __future__ import annotations

import json
import os
import re
import signal
import subprocess
import threading
import time
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import Callable

from .adapter import Command
from .config import EfinityError, Settings, bounded_int, inside
from .reports import catalog

TERMINAL = {"succeeded", "failed", "cancelled", "timed_out", "log_limit_exceeded"}


def timestamp() -> str:
    return datetime.now(timezone.utc).isoformat()


def stop_process(proc: subprocess.Popen) -> None:
    """Best-effort process-tree termination; not an OS sandbox."""
    if os.name == "nt":
        if proc.poll() is None:
            taskkill = Path(os.environ.get("SystemRoot", "C:/Windows")) / "System32/taskkill.exe"
            try:
                subprocess.run([str(taskkill), "/PID", str(proc.pid), "/T", "/F"],
                               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                               timeout=5, check=False)
            except (OSError, subprocess.TimeoutExpired):
                proc.kill()
    else:
        try:
            os.killpg(proc.pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
        try:
            proc.wait(timeout=2)
        except subprocess.TimeoutExpired:
            pass
        # The group can still contain children after the parent has exited.
        try:
            os.killpg(proc.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
    try:
        proc.wait(timeout=5)
    except subprocess.TimeoutExpired:
        proc.kill()
        proc.wait(timeout=5)


class Jobs:
    def __init__(self, settings: Settings):
        self.settings = settings
        self.directory = settings.state_dir / "jobs"
        self.directory.mkdir(parents=True, exist_ok=True)
        self.lockfile = settings.state_dir / "execution.lock"
        self.guard = threading.RLock()
        self.live: dict[str, tuple[dict, threading.Event, threading.Thread]] = {}
        self.closed = False

    def _path(self, job_id: str) -> Path:
        if not re.fullmatch(r"[0-9a-f]{32}", job_id):
            raise EfinityError("Invalid job ID.")
        return inside(self.settings.state_dir, self.directory / job_id)

    def _save(self, record: dict) -> None:
        directory = self._path(record["id"])
        temporary = directory / "record.tmp"
        temporary.write_text(json.dumps(record, indent=2), encoding="utf-8")
        os.replace(temporary, directory / "record.json")

    def submit(self, factory: Callable[[Path], Command], *, operation: str, project_id: str | None,
               output: Path | None = None, timeout: int | None = None,
               evidence: dict | None = None) -> dict:
        duration = timeout if timeout is not None else self.settings.timeout_seconds
        bounded_int(duration, "timeout_seconds", 1, self.settings.timeout_seconds)
        with self.guard:
            if self.closed:
                raise EfinityError("Job service is shutting down.")
            job_id = uuid.uuid4().hex
            try:
                fd = os.open(self.lockfile, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
            except FileExistsError as exc:
                raise EfinityError("Workspace is busy or has an interrupted-run lock. "
                                   "Wait/cancel the active job. After a crash, inspect vendor processes "
                                   "before removing execution.lock manually.") from exc
            with os.fdopen(fd, "w") as stream:
                json.dump({"job_id": job_id, "server_pid": os.getpid()}, stream)
            directory = self._path(job_id)
            try:
                directory.mkdir()
                record = {"id": job_id, "operation": operation, "project_id": project_id,
                          "status": "queued", "created_at": timestamp(), "started_at": None,
                          "finished_at": None, "returncode": None, "error": None,
                          "timeout_seconds": duration, "evidence": evidence or {},
                          "changed_artifacts": [], "timing_pass": None,
                          "verification": "Process exit status only; not functional/timing/board validation."}
                cancel = threading.Event()
                thread = threading.Thread(target=self._run,
                                          args=(record, cancel, factory, output), daemon=True)
                self.live[job_id] = (record, cancel, thread)
                self._save(record)
                thread.start()
                return dict(record)
            except Exception:
                self.lockfile.unlink(missing_ok=True)
                raise

    def _run(self, record: dict, cancel: threading.Event, factory: Callable, output: Path | None) -> None:
        proc = None
        retain_lock = False
        start = time.monotonic()
        directory = self._path(record["id"])
        log = directory / "console.log"
        try:
            before = catalog(output) if output is not None else {"files": [], "truncated": False}
            command = factory(directory)
            with self.guard:
                record.update(status="running", started_at=timestamp(), command=command.argv,
                              cwd=str(command.cwd), output_dir=str(output) if output else None)
                self._save(record)
            env = os.environ.copy()
            # Efinity setup controls its own Python runtime; do not leak the MCP venv setup.
            for key in ("PYTHONHOME", "PYTHONPATH", "VIRTUAL_ENV"):
                env.pop(key, None)
            with log.open("wb") as handle:
                if cancel.is_set():
                    record["status"] = "cancelled"
                else:
                    proc = subprocess.Popen(command.argv, cwd=command.cwd, env=env,
                                            stdin=subprocess.DEVNULL, stdout=handle,
                                            stderr=subprocess.STDOUT, shell=False,
                                            start_new_session=os.name != "nt",
                                            creationflags=(subprocess.CREATE_NEW_PROCESS_GROUP
                                                           if os.name == "nt" else 0))
                    while proc.poll() is None:
                        if cancel.is_set():
                            record["status"] = "cancelled"
                        elif time.monotonic() - start >= record["timeout_seconds"]:
                            record["status"] = "timed_out"
                        elif log.stat().st_size > self.settings.max_log_bytes:
                            record["status"] = "log_limit_exceeded"
                        else:
                            time.sleep(0.05)
                            continue
                        stop_process(proc)
                        break
                    record["returncode"] = proc.wait()
                    if record["status"] == "running":
                        if log.stat().st_size > self.settings.max_log_bytes:
                            record["status"] = "log_limit_exceeded"
                        else:
                            record["status"] = "succeeded" if proc.returncode == 0 else "failed"
            if output is not None:
                after = catalog(output)
                old = {f["path"]: f for f in before["files"]}
                record["changed_artifacts"] = [f for f in after["files"] if f != old.get(f["path"])]
                record["artifact_scan_truncated"] = before["truncated"] or after["truncated"]
                record["artifact_scan_skipped"] = before.get("skipped", 0) + after.get("skipped", 0)
        except Exception as exc:
            record.update(status="failed", error=f"{type(exc).__name__}: {exc}")
        finally:
            if proc is not None and proc.poll() is None:
                try:
                    stop_process(proc)
                except Exception as exc:
                    retain_lock = True
                    record.update(status="failed", error=f"Process cleanup failed: {exc}")
            with self.guard:
                record.update(finished_at=timestamp(), elapsed_seconds=round(time.monotonic()-start, 3))
                try:
                    self._save(record)
                finally:
                    if not retain_lock:
                        self.lockfile.unlink(missing_ok=True)

    def get(self, job_id: str) -> dict:
        with self.guard:
            path = self._path(job_id)
            if job_id in self.live:
                return json.loads(json.dumps(self.live[job_id][0]))
            file = inside(self.settings.state_dir, path / "record.json", exists=True)
            result = json.loads(file.read_text(encoding="utf-8"))
            if result["status"] not in TERMINAL:
                result["status"] = "interrupted_unknown"
                result["error"] = "Server restarted; old vendor process may still exist. No auto-unlock."
            return result

    def cancel(self, job_id: str) -> dict:
        with self.guard:
            record = self.get(job_id)
            if job_id in self.live and record["status"] not in TERMINAL:
                self.live[job_id][1].set()
                return {"id": job_id, "cancel_requested": True}
            return {"id": job_id, "cancel_requested": False, "status": record["status"]}

    def log(self, job_id: str, tail_bytes: int = 16384) -> dict:
        bounded_int(tail_bytes, "tail_bytes", 1, 65536)
        self.get(job_id)
        path = self._path(job_id) / "console.log"
        if not path.exists():
            return {"text": "", "pending": True, "untrusted_tool_output": True}
        path = inside(self.settings.state_dir, path, exists=True)
        size = path.stat().st_size
        offset = max(0, size - tail_bytes)
        with path.open("rb") as handle:
            handle.seek(offset)
            text = handle.read(tail_bytes).decode("utf-8", errors="replace")
        return {"text": text, "offset": offset, "bytes_on_disk": size,
                "truncated": offset > 0, "untrusted_tool_output": True}

    def close(self) -> None:
        with self.guard:
            self.closed = True
            pending = list(self.live.values())
            for _, event, _ in pending:
                event.set()
        for _, _, thread in pending:
            thread.join(timeout=10)
