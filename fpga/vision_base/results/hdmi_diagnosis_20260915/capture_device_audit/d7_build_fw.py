#!/usr/bin/env python3
"""Build the D7 EEPROM image: native firmware + a forced UVC mode + custom EDID.

Payload layout in XDATA:

    CC00        LJMP HOOK                (native entry LJMP CD6E is relocated)
    CC03..CFF9  native vendor firmware, untouched
    CFFA..CFFF  padding
    D000        our hook
    D100..D1FF  256-byte EDID served over DDC

USERCONFIG:

    [4] = 0x01  normal user hook enabled  (ROM checks this in 0x7F91)
    [5] = 0x50  bit6 = vendor event 0x17 (stock), bit4 = event 0x08 = custom EDID

ROM entry points used:

    0x73F7  load EDID: copies 256 bytes from generic pointer R3:R2:R1
            into the DDC buffer at XDATA 0xFB00, gated by F819 bit0.
    0xCD6E  native firmware's own event dispatcher.

Two targets:

    720p       frame index 6 is already 1280x720, so only the default index
               has to be forced.
    1024x600   no such frame exists.  Index 7 (stock 1024x768) is rewritten in
               place -- USB descriptors *and* the chip's own tables -- so the
               card both advertises and captures 1024x600.
"""
import os
import sys

import d7image
import mcs51
from videomode import MODES

HOOK = 0xD000
EDID = 0xD100
PAYLOAD_END = 0xD200

NATIVE_ENTRY = 0xCD6E
ROM_LOAD_EDID = 0x73F7
EVENT_EDID = 0x08

# --- what the ROM builds in XDATA, and where -------------------------------
# Everything above 0xC000 in a `dump-rom` image is RAM, not mask ROM: the ROM
# copies these tables up from 0x83F9 / 0x843B / 0x1886 during init and rebuilds
# the USB descriptors from them on every USB reset.  So all of it is writable,
# and all of it has to be reapplied on every hook event.
UVC_MJPEG_DEFAULT_FRAME = 0xC0A8
UVC_YUYV_DEFAULT_FRAME = 0xC2C3

MJPEG_FRAME1, MJPEG_STRIDE = 0xC0AD, 46      # VS_FRAME_MJPEG descriptors
# VS_FRAME_UNCOMPRESSED.  The stride only holds through index 7; 800x600 and
# below advertise more frame intervals and so are longer.  check_reference()
# catches it if a future slot moves past that.
YUYV_FRAME1, YUYV_STRIDE = 0xC2C8, 34
FRAME_WIDTH, FRAME_HEIGHT, FRAME_BUFSIZE = 5, 7, 17   # offsets inside one

SIZE_TABLE_A = 0xC575        # 11 x {index, W be, H be, 0xEA}
SIZE_TABLE_B = 0xC5B7        # 11 x {index, W be, H be, per-mode byte}
MODE_TABLE = 0xC60C          # 11 x 21-byte raster record, see videomode.py
SIZE_ENTRY, MODE_ENTRY = 6, 21

REFERENCE = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                         "rom", "d7-rom.bin")

TARGETS = {
    "1024x600": dict(mode=MODES["1024x600"], slot=7,
                     edid="edid/edid-1024x600.bin",
                     out="firmware/eeprom-1024x600.bin"),
    "720p": dict(mode=MODES["720p"], slot=6,
                 edid="edid/edid-720-tight.bin",
                 out="firmware/eeprom-720p-edid.bin"),
}


def le16(v):
    return [v & 0xFF, v >> 8]


def be16(v):
    return [v >> 8, v & 0xFF]


def patch_list(mode, slot):
    """Every XDATA byte the hook has to force, as {address: value}."""
    p = {}

    def put(addr, values):
        for i, v in enumerate(values):
            p[addr + i] = v

    put(UVC_MJPEG_DEFAULT_FRAME, [slot])
    put(UVC_YUYV_DEFAULT_FRAME, [slot])

    for first, stride in ((MJPEG_FRAME1, MJPEG_STRIDE), (YUYV_FRAME1, YUYV_STRIDE)):
        d = first + (slot - 1) * stride
        put(d + FRAME_WIDTH, le16(mode.hact))
        put(d + FRAME_HEIGHT, le16(mode.vact))
        # dwMaxVideoFrameBufferSize: one uncompressed frame, 16 bits per pixel.
        n = mode.hact * mode.vact * 2
        put(d + FRAME_BUFSIZE, [n & 0xFF, (n >> 8) & 0xFF, (n >> 16) & 0xFF, n >> 24])

    for table in (SIZE_TABLE_A, SIZE_TABLE_B):
        put(table + (slot - 1) * SIZE_ENTRY + 1, be16(mode.hact) + be16(mode.vact))

    put(MODE_TABLE + (slot - 1) * MODE_ENTRY, mode.chip_record())
    return p


def check_reference(ram, slot):
    """Assert the addresses above still land where we think they do.

    `ram` is a dump-rom image: above 0xC000 that is RAM as the ROM left it.
    """
    for first, stride, sub in ((MJPEG_FRAME1, MJPEG_STRIDE, 7),
                               (YUYV_FRAME1, YUYV_STRIDE, 5)):
        d = first + (slot - 1) * stride
        assert ram[d + 1] == 0x24 and ram[d + 2] == sub and ram[d + 3] == slot, \
            "no frame descriptor (subtype %d, index %d) at %04X" % (sub, slot, d)
    for table in (SIZE_TABLE_A, SIZE_TABLE_B):
        e = table + (slot - 1) * SIZE_ENTRY
        assert ram[e] == slot, "size table entry %d not at %04X" % (slot, e)
    m = MODE_TABLE + (slot - 1) * MODE_ENTRY
    assert ram[m] == 0x07, "mode table record %d not at %04X" % (slot, m)
    assert (ram[m + 5] << 8 | ram[m + 6]) == (ram[SIZE_TABLE_A + (slot - 1) * SIZE_ENTRY + 1] << 8
                                              | ram[SIZE_TABLE_A + (slot - 1) * SIZE_ENTRY + 2]), \
        "mode table and size table disagree about slot %d" % slot


def drop_unchanged(patches, ram):
    """Keep only the bytes that differ from what the ROM puts there itself."""
    return {a: v for a, v in patches.items() if ram[a] != v}


def emit(patches):
    """Straight-line writes: A and DPTR only, no registers the ROM might want."""
    out, prev_addr, acc = [], None, None
    for addr in sorted(patches):
        val = patches[addr]
        out.append("INC DPTR" if prev_addr == addr - 1 else "MOV DPTR,#0x%04X" % addr)
        if acc != val:
            out.append("MOV A,#0x%02X" % val)
            acc = val
        out.append("MOVX @DPTR,A")
        prev_addr = addr
    return out


def hook_code(mode, slot, reference=REFERENCE):
    patches = patch_list(mode, slot)
    if reference and os.path.exists(reference):
        with open(reference, "rb") as f:
            ram = f.read()
        check_reference(ram, slot)
        patches = drop_unchanged(patches, ram)
    src = "\n".join([
        # Runs on every user-hook event.  The ROM regenerates the USB
        # descriptors on each USB reset and reloads its tables from mask ROM at
        # init, so this is reapplied every time rather than patched once.
    ] + emit(patches) + [
        # Event 8 = "user firmware supplies the EDID" (enabled by CBD5 bit 4).
        "CJNE R7,#0x%02X,native" % EVENT_EDID,
        "MOV R3,#0xFF",
        "MOV R2,#0x%02X" % (EDID >> 8),
        "MOV R1,#0x%02X" % (EDID & 0xFF),
        "LJMP 0x%04X" % ROM_LOAD_EDID,
        "native:",
        "LJMP 0x%04X" % NATIVE_ENTRY,
    ])
    return mcs51.asm(src, org=HOOK), patches


def build(original, edid_path, out, mode, slot):
    img = d7image.Image.load(original)
    assert img.magic == d7image.MAGIC, "not a D7 image"
    assert img.verify(), "source image checksums are bad"

    native = bytearray(img.fw)
    assert bytes(native[:3]) == bytes([0x02, NATIVE_ENTRY >> 8, NATIVE_ENTRY & 0xFF]), \
        "unexpected native entry %s" % native[:3].hex()

    with open(edid_path, "rb") as f:
        edid = f.read()
    assert len(edid) == 256, "EDID must be exactly 256 bytes"
    for blk in (0, 1):
        assert sum(edid[blk * 128:(blk + 1) * 128]) % 256 == 0, "EDID block %d checksum bad" % blk

    code, patches = hook_code(mode, slot)
    assert HOOK + len(code) <= EDID, \
        "hook is %d bytes, only %d fit before the EDID" % (len(code), EDID - HOOK)

    payload = bytearray(b"\xff" * (PAYLOAD_END - d7image.FW_BASE))
    payload[0:len(native)] = native
    payload[0:3] = bytes([0x02, HOOK >> 8, HOOK & 0xFF])
    payload[HOOK - d7image.FW_BASE:HOOK - d7image.FW_BASE + len(code)] = code
    payload[EDID - d7image.FW_BASE:EDID - d7image.FW_BASE + 256] = edid

    img.set_fw(bytes(payload))
    img.hooks = 0x01
    img.cfg5 = 0x50
    img.fix_csums()

    assert img.csum_off + 4 <= 2048, "image does not fit in the 2 KiB EEPROM"
    img.save(out)
    return img, code, patches


if __name__ == "__main__":
    import argparse

    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    ap = argparse.ArgumentParser()
    ap.add_argument("--target", default="1024x600", choices=sorted(TARGETS))
    ap.add_argument("--stock", default=os.path.join(root, "firmware", "eeprom-stock-backup.bin"))
    ap.add_argument("--edid", default=None)
    ap.add_argument("--out", default=None)
    a = ap.parse_args()

    t = TARGETS[a.target]
    edid = a.edid or os.path.join(root, t["edid"])
    out = a.out or os.path.join(root, t["out"])
    img, code, patches = build(a.stock, edid, out, t["mode"], t["slot"])

    print(t["mode"])
    print("frame index %d, %d forced bytes" % (t["slot"], len(patches)))
    print()
    print(img.describe())
    print()
    print("hook @ %04X (%d bytes):" % (HOOK, len(code)))
    print(mcs51.disasm(code, base=HOOK))
    print()
    print("wrote", out)
