"""Thin wrapper around ms-tools' msctl for talking to the D7 over HID.

msctl is located via $MSCTL, then a few usual places.  Everything here uses
--no-patch: upstream's runtime patcher does not recognise the D7's 5A A5 magic
and would allocate its blobs on top of the vendor firmware.
"""
import os
import subprocess
import tempfile

EEPROM_SIZE = 2048          # 24C16.  Passing 4096 makes reads return 0xA5.

_CANDIDATES = [
    os.environ.get("MSCTL"),
    os.path.expanduser("~/Desktop/ms-tools/msctl"),
    os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "msctl"),
    "msctl",
]


def _msctl():
    for c in _CANDIDATES:
        if not c:
            continue
        if os.path.sep in c:
            if os.path.isfile(c) and os.access(c, os.X_OK):
                return c
        else:
            from shutil import which
            found = which(c)
            if found:
                return found
    raise RuntimeError(
        "msctl not found. Build it from https://github.com/BertoldVdb/ms-tools "
        "and point $MSCTL at the binary.")


def _base():
    return [_msctl(), "--pid", "2109", "--no-patch", "--eeprom-size", str(EEPROM_SIZE)]


def _run(args):
    r = subprocess.run(_base() + args, capture_output=True, text=True)
    if r.returncode != 0:
        raise RuntimeError("msctl %s failed:\n%s%s" % (" ".join(args), r.stdout, r.stderr))
    return r.stdout


def read(region, addr, n):
    fd, path = tempfile.mkstemp(suffix=".bin")
    os.close(fd)
    try:
        _run(["read", region, hex(addr), str(n), "--filename=" + path])
        with open(path, "rb") as f:
            return f.read()
    finally:
        os.unlink(path)


def write(region, addr, data):
    fd, path = tempfile.mkstemp(suffix=".bin")
    with os.fdopen(fd, "wb") as f:
        f.write(bytes(data))
    try:
        _run(["write-file", region, hex(addr), path])
    finally:
        os.unlink(path)


def ram(addr, n=1):
    return read("RAM", addr, n)


def poke(addr, data):
    write("RAM", addr, data)


def cfg(n=48):
    return read("USERCONFIG", 0, n)


def cfg_set(off, val):
    write("USERCONFIG", off, bytes([val]))


def eeprom_read(n=EEPROM_SIZE):
    return read("EEPROM", 0, n)


def alive():
    return ram(0xF800, 1)[0] == 0xD7


def ddc_edid():
    """Read the EDID the card actually serves over DDC.

    The buffer at XDATA 0xFB00 is only visible while F819 bit0 is set -- the
    same gate the ROM's own loader raises while it fills the buffer.
    """
    poke(0xF819, b"\x01")
    try:
        return ram(0xFB00, 256)
    finally:
        poke(0xF819, b"\x00")
