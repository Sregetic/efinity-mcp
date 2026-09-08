"""Bounded, source-preserving report access. Unknown timing is never reported as PASS."""
from __future__ import annotations

import hashlib
import os
from pathlib import Path

from defusedxml import ElementTree

from .config import EfinityError, Project, bounded_int, inside

TEXT_SUFFIXES = {".rpt", ".log", ".txt", ".json", ".simlog"}
ARTIFACT_SUFFIXES = TEXT_SUFFIXES | {".bit", ".hex"}
MAX_FILE = 128 * 1024 * 1024


def sha256(path: Path) -> str:
    if path.stat().st_size > MAX_FILE:
        raise EfinityError("File exceeds the 128 MiB hashing limit.")
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(65536), b""):
            digest.update(block)
    return digest.hexdigest()


def project_info(project: Project) -> dict:
    if project.xml.stat().st_size > 2 * 1024 * 1024:
        raise EfinityError("Project XML exceeds 2 MiB.")
    try:
        root = ElementTree.parse(project.xml).getroot()
    except Exception as exc:
        raise EfinityError(f"Cannot safely parse project XML: {exc}") from exc
    if root.tag.rsplit("}", 1)[-1] != "project":
        raise EfinityError("Not an Efinity project XML (expected project root).")
    devices = [dict(node.attrib) for node in root.iter()
               if node.tag.rsplit("}", 1)[-1] in {"device", "family", "timing_model"}]
    return {"id": project.id, "xml": str(project.xml), "sha256": sha256(project.xml),
            "attributes": dict(root.attrib), "device_fields": devices,
            "output_dir": str(project.output), "trusted": project.trusted,
            "note": "Metadata only; schema, I/O assignments and hardware compatibility are not validated."}


def catalog(output: Path, kind: str = "all") -> dict:
    if kind not in {"all", "timing", "utilization", "log", "bitstream"}:
        raise EfinityError("kind must be all, timing, utilization, log or bitstream.")
    result = []
    scanned = 0
    skipped = 0
    if not output.exists():
        return {"files": [], "truncated": False, "skipped": 0}
    for parent, dirs, names in os.walk(output, followlinks=False):
        dirs[:] = sorted(d for d in dirs if not (Path(parent) / d).is_symlink())
        for name in sorted(names):
            scanned += 1
            if scanned > 2048 or len(result) >= 256:
                return {"files": result, "truncated": True, "skipped": skipped}
            candidate = Path(parent) / name
            if candidate.suffix.lower() not in ARTIFACT_SUFFIXES:
                continue
            try:
                path = inside(output, candidate, exists=True)
                if candidate.is_symlink() or path.stat().st_size > MAX_FILE:
                    skipped += 1
                    continue
                lower = name.lower()
                matches = (kind == "all" or
                           kind == "timing" and any(s in lower for s in ("timing", ".sta.", "slack")) or
                           kind == "utilization" and any(s in lower for s in ("util", "resource", ".map.rpt")) or
                           kind == "log" and path.suffix.lower() in {".log", ".simlog"} or
                           kind == "bitstream" and path.suffix.lower() in {".bit", ".hex"})
                if matches:
                    stat = path.stat()
                    result.append({"path": path.relative_to(output).as_posix(), "bytes": stat.st_size,
                                   "mtime_ns": stat.st_mtime_ns, "sha256": sha256(path)})
            except (OSError, EfinityError):
                skipped += 1
    return {"files": result, "truncated": False, "skipped": skipped}


def read_report(output: Path, relative_path: str, start_line: int = 1, max_lines: int = 200) -> dict:
    bounded_int(start_line, "start_line", 1, 1000000)
    bounded_int(max_lines, "max_lines", 1, 1000)
    path = inside(output, Path(relative_path), exists=True)
    if path.suffix.lower() not in TEXT_SUFFIXES:
        raise EfinityError("Only report/log text formats can be read.")
    if path.stat().st_size > 4 * 1024 * 1024:
        raise EfinityError("Report exceeds 4 MiB; reduce vendor report detail or inspect it locally.")
    text = path.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()
    selected = []
    length = 0
    for number in range(start_line, min(len(lines), start_line + max_lines - 1) + 1):
        line = lines[number - 1]
        if len(line) > 32768:
            raise EfinityError("A report line exceeds 32 KiB; inspect this file locally.")
        if length + len(line) > 65536:
            break
        selected.append({"line": number, "text": line})
        length += len(line)
    end = start_line + len(selected) - 1
    return {"path": path.relative_to(output).as_posix(), "sha256": sha256(path),
            "lines": selected, "total_lines": len(lines),
            "next_line": end + 1 if end < len(lines) else None,
            "timing_pass": None, "untrusted_tool_output": True}
