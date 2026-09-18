#!/usr/bin/env python3
"""Check that the flashed firmware is live and doing its job.

Run it after a USB power cycle -- everything it reports must have come from the
EEPROM, not from a RAM experiment.

    python3 tools/verify.py                 # the 1024x600 build
    python3 tools/verify.py --target 720p
"""
import argparse
import glob
import hashlib
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import build_fw  # noqa: E402
import d7image  # noqa: E402
import dev  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

ok = True


def check(label, good, detail=""):
    global ok
    ok = ok and good
    print("[%s] %-34s %s" % ("ok" if good else "FAIL", label, detail))


def uvc_frames():
    """Default frame index and the frame sizes, straight from sysfs."""
    path = next(d for d in glob.glob("/sys/bus/usb/devices/*")
                if os.path.exists(d + "/idVendor")
                and open(d + "/idVendor").read().strip() == "345f"
                and open(d + "/idProduct").read().strip() == "2109")
    raw = open(path + "/descriptors", "rb").read()
    out, fmt, subclass, i = {}, None, None, 0
    while i < len(raw):
        ln, t = raw[i], raw[i + 1]
        if ln == 0:
            break
        if t == 0x04:                                   # INTERFACE
            subclass = raw[i + 6] if raw[i + 5] == 0x0E else None
        elif t == 0x24 and subclass == 2:               # CS_INTERFACE on VideoStreaming
            st = raw[i + 2]
            if st == 0x06:                              # FORMAT_MJPEG
                fmt = "MJPEG"
                out[fmt] = {"default": raw[i + 6], "frames": {}}
            elif st == 0x04:                            # FORMAT_UNCOMPRESSED
                fmt = "YUYV"
                out[fmt] = {"default": raw[i + 22], "frames": {}}
            elif st in (0x05, 0x07) and fmt:            # FRAME_*
                out[fmt]["frames"][raw[i + 3]] = (raw[i + 5] | raw[i + 6] << 8,
                                                  raw[i + 7] | raw[i + 8] << 8)
        i += ln
    return out


ap = argparse.ArgumentParser()
ap.add_argument("--target", default="1024x600", choices=sorted(build_fw.TARGETS))
args = ap.parse_args()

target = build_fw.TARGETS[args.target]
mode, slot = target["mode"], target["slot"]
img = d7image.Image.load(os.path.join(ROOT, target["out"]))
edid = img.at(build_fw.EDID, 256)

print("%s, frame index %d" % (mode, slot))
print()

check("device responds", dev.alive(), "chip id D7")

cfg = dev.cfg(6)
check("USERCONFIG magic", cfg[0:2] == b"\x5a\xa5", cfg[0:2].hex())
check("firmware length", (cfg[2] << 8 | cfg[3]) == img.fw_len, "0x%04X" % (cfg[2] << 8 | cfg[3]))
check("normal hook enabled", cfg[4] & 0x01 == 1, "CBD4=0x%02X" % cfg[4])
check("EDID gate (CBD5 bit4)", cfg[5] & 0x10 == 0x10, "CBD5=0x%02X" % cfg[5])

hook_len = build_fw.EDID - build_fw.HOOK
check("hook installed", dev.ram(build_fw.HOOK, hook_len) == img.at(build_fw.HOOK, hook_len))
check("EDID in XDATA", dev.ram(build_fw.EDID, 256) == edid)

live = dev.ddc_edid()
check("EDID served over DDC", live == edid, hashlib.sha256(live).hexdigest()[:16] + "...")

r = live[72:90]
check("range limits", True, "%d-%d Hz, %d-%d kHz, max %d MHz"
      % (r[5], r[6], r[7], r[8], r[9] * 10))

# The chip's own mode table: what it will try to match the incoming HDMI
# timing against, and configure the scaler from.
record = dev.ram(build_fw.MODE_TABLE + (slot - 1) * build_fw.MODE_ENTRY, build_fw.MODE_ENTRY)
check("chip mode table", record == mode.chip_record(), record.hex())

detected = dev.ram(0xC71A, build_fw.MODE_ENTRY)
w, h = (detected[5] << 8) | detected[6], (detected[7] << 8) | detected[8]
check("HDMI input locked", (w, h) == (mode.hact, mode.vact),
      "%dx%d @ %.2f Hz" % (w, h, ((detected[11] << 8) | detected[12]) / 100.0))

try:
    for fmt, info in sorted(uvc_frames().items()):
        check("UVC %s default frame" % fmt, info["default"] == slot, "index %s" % info["default"])
        check("UVC %s frame %d size" % (fmt, slot),
              info["frames"].get(slot) == (mode.hact, mode.vact),
              "%sx%s" % info["frames"].get(slot, ("?", "?")))
except StopIteration:
    check("UVC descriptors", False, "device not found in sysfs")

print()
print("ALL GOOD" if ok else "SOMETHING IS WRONG")
sys.exit(0 if ok else 1)
