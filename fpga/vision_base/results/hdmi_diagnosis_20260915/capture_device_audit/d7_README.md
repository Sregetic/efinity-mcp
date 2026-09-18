# 📺 MS2109-D7-1024x600

![Python](https://img.shields.io/badge/Python_3-3776AB?logo=python&logoColor=white)
![8051](https://img.shields.io/badge/MCS--51-assembly-6E4C13)
![Go](https://img.shields.io/badge/msctl-Go-00ADD8?logo=go&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-only-FCC624?logo=linux&logoColor=black)
![MacroSilicon](https://img.shields.io/badge/MacroSilicon-D7_(345f%3A2109)-0A7E8C)
![HDMI](https://img.shields.io/badge/HDMI-EDID_1.3_%2B_CTA--861-1D1D1D)
![UVC](https://img.shields.io/badge/USB-UVC_MJPEG_%2F_YUYV-005EB8)
![Raspberry Pi](https://img.shields.io/badge/tested_source-Raspberry_Pi-C51A4A?logo=raspberrypi&logoColor=white)
![Claude Code](https://img.shields.io/badge/Made_with-Claude_Code-D97757?logo=claude&logoColor=white)

**MS2109-D7-1024x600** is a firmware for the cheap HDMI→USB capture stick sold as
"HD TO USB" (`345f:2109`, MacroSilicon D7). Stock, the card is 1080p on both
sides: it advertises 1080p over HDMI and enumerates as a 1920×1080 USB camera.
This firmware makes both sides **1024×600**, so the source picks that mode by
itself and capture software opens it without being told to.

The constraint the whole design follows from: the chip has exactly eleven
resolutions, burned into its USB descriptors *and* into its own mode table, and
there is no twelfth slot. 1024×600 is not one of them, so it cannot be added —
only swapped in. Frame index 7 (stock 1024×768) is rewritten in place, and
because the chip identifies an incoming HDMI signal by matching its raster
against that table, the EDID the card serves and the table entry have to describe
the same timing down to the sync widths. Both are generated from one mode
definition so they cannot drift apart.

## 📦 Dependencies

| what | why |
|---|---|
| MacroSilicon D7 card | `lsusb \| grep 345f:2109` |
| [`ms-tools`](https://github.com/BertoldVdb/ms-tools) | provides `msctl`, the only way in and out of the card |
| Python 3 | everything here; no external packages |
| Linux | sysfs, `hidraw`, `v4l2-ctl` |

No external programmer is needed. The EEPROM hangs off the chip's own I²C
master, and the ROM exposes that bus through a vendor HID interface.

Upstream `msctl` does not recognise chip id `0xD7`. Patch `mshal/hal.go` —
`case 0xa7:` becomes `case 0xa7, 0xd7:` — then build it:

```sh
git clone https://github.com/BertoldVdb/ms-tools
cd ms-tools
sed -i 's/case 0xa7:/case 0xa7, 0xd7:/' mshal/hal.go
go build -o msctl ./cli
export MSCTL=$PWD/msctl
```

Without the udev rule everything needs `sudo`, and the card gets replugged a lot:

```sh
sudo cp udev/70-macrosilicon.rules /etc/udev/rules.d/
sudo udevadm control --reload && sudo udevadm trigger
```

## ⚠️ This is not an ordinary MS2109

The chip reports `0xD7` at XDATA `F800`, not the `0xA7` upstream expects. It
shares the ROM ABI in broad strokes and not in detail: different EEPROM magic,
different ROM entry points, different hook events.

**Do not flash MS2109 images onto it.** Tried: the card boots, HPD never comes
up, and the EDID ends up zero length. The full account is in
[`docs/reverse-engineering.md`](docs/reverse-engineering.md).

## 🚀 Flashing

Back up your own EEPROM first. `firmware/eeprom-stock-backup.bin` is a dump of
one specific card; yours may differ in serial or calibration.

```sh
$MSCTL --pid 2109 --no-patch --eeprom-size 2048 \
       read EEPROM 0 2048 --filename=my-stock-backup.bin
sha256sum my-stock-backup.bin
```

If that matches `firmware/eeprom-stock-backup.bin`, the prebuilt image fits your
card. If it does not, rebuild from your own dump (see 🔧 Configuration).

```sh
$MSCTL --pid 2109 --no-patch --eeprom-size 2048 --log-level 2 \
       write-file --verify EEPROM 0 firmware/eeprom-1024x600.bin
```

`Verification OK` is expected. Then **physically unplug and replug USB** — the
firmware is copied from EEPROM into RAM only when the chip powers up, and a bus
reset is not enough.

Revert the same way, with your backup:

```sh
$MSCTL --pid 2109 --no-patch --eeprom-size 2048 --log-level 2 \
       write-file --verify EEPROM 0 my-stock-backup.bin
```

Nothing but the EEPROM is ever touched. The mask ROM stays as it was, and a bad
payload checksum only makes the ROM ignore the user firmware, so the card cannot
be bricked this way.

## 🧪 Verifying

```sh
python3 tools/verify.py
```

```
1024x600@60 CVT  1024x600  1312/624 total  49.00 MHz  37.348 kHz  59.85 Hz, frame index 7

[ok] device responds                    chip id D7
[ok] USERCONFIG magic                   5aa5
[ok] firmware length                    0x0600
[ok] normal hook enabled                CBD4=0x01
[ok] EDID gate (CBD5 bit4)              CBD5=0x50
[ok] hook installed
[ok] EDID in XDATA
[ok] EDID served over DDC               85e4c780c2b5337e...
[ok] range limits                       23-61 Hz, 17-38 kHz, max 50 MHz
[ok] chip mode table                    0705200270040002581324176100f800150068000a
[ok] HDMI input locked                  1024x600 @ 59.84 Hz
[ok] UVC MJPEG default frame            index 7
[ok] UVC MJPEG frame 7 size             1024x600
[ok] UVC YUYV default frame             index 7
[ok] UVC YUYV frame 7 size              1024x600

ALL GOOD
```

The source should land on exactly the advertised raster — on a Raspberry Pi:

```sh
kmsprint
# Crtc 3 (89) 1024x600@59.85 49.000 1024/40/104/144/- 600/3/10/11/+ 60 (59.85)
```

And on the host the card is plugged into, a capture is exactly frame-sized:

```sh
v4l2-ctl -d /dev/video0 --set-fmt-video=width=1024,height=600,pixelformat=YUYV \
         --stream-mmap --stream-count=2 --stream-to=cap.yuv
ls -l cap.yuv    # 2457600 bytes = 1024*600*2*2
```

## 🔧 Configuration

Two build targets. `720p` is what this project started as; its image still
reproduces byte for byte.

| target | frame index | EDID | image |
|---|---|---|---|
| `1024x600` (default) | 7, rewritten from 1024×768 | `edid/edid-1024x600.bin` | `firmware/eeprom-1024x600.bin` |
| `720p` | 6, already 1280×720 in stock | `edid/edid-720-tight.bin` | `firmware/eeprom-720p-edid.bin` |

```sh
python3 edid/make_edid.py                      # edid/edid-1024x600.bin
python3 tools/build_fw.py                      # firmware/eeprom-1024x600.bin
python3 tools/build_fw.py --target 720p        # firmware/eeprom-720p-edid.bin
```

`--check` compares against the shipped file instead of writing it; `--stock`,
`--edid` and `--out` override paths.

`build_fw.py` copies the vendor firmware in unchanged, appends the hook and the
EDID next to it, sets `CBD4=0x01` / `CBD5=0x50`, and recomputes **both** additive
checksums. The bytes the hook forces are derived from the mode rather than typed
out: `patch_list()` spreads the mode across descriptors and tables,
`check_reference()` confirms every address against `rom/d7-rom.bin`, and only the
bytes that actually differ from what the ROM writes itself survive. For 1024×600
that is 27 bytes and 151 bytes of code.

### EDID

`edid/make_edid.py` builds the EDID whole. Identity — manufacturer, model,
serial, physical size, chromaticity — is kept from the factory EDID so the card
still looks like itself; everything about timing is written fresh.

| field | value |
|---|---|
| preferred / native DTD | 1024×600@60 CVT, 49.00 MHz (`cvt 1024 600 60`) |
| CTA SVDs | VIC 1 (640×480@60) only, as a fallback for CEA-only sources |
| established timings | 800×600@60, 640×480@60 |
| range limits | 23–61 Hz, 17–38 kHz, max 50 MHz |
| audio | LPCM 2ch, 32 / 44.1 / 48 kHz |

The range limits carry weight here. EDID 1.3 defines only flags `0x00` ("default
GTF") and `0x02`; the "range limits only, no formula" value `0x01` arrived in
1.4, so a source cannot be stopped from synthesising modes — only boxed in. A
38 kHz ceiling clears 800×600@60 (37.879) and 1024×600@60 (37.348) but not
1024×768@60 (48.363), which matters: the card can no longer capture 1024×768,
because that slot is now 1024×600.

## 🧠 How it works

The chip loads a small "user firmware" from EEPROM into XDATA `0xCC00` and calls
it from fixed points in the mask ROM, passing an event id in `R7`. `CBD5` decides
which events fire; **bit 4** switches where the EDID comes from — clear, the ROM
uses its own copy at `0x847C`; set, it raises event `0x08` and expects the hook
to call `0x73F7` with a pointer to its own 256 bytes.

The second thing that makes this possible: **code space above `0xC000` is RAM**,
not mask ROM — which is why user firmware at `CC00` executes at all. Everything
the ROM builds up there can be rewritten from the hook with plain `MOVX`:

| XDATA | contents |
|---|---|
| `C0A8` / `C2C3` | `bDefaultFrameIndex`, MJPEG and YUYV |
| `C0AD` + 46·(n−1) | MJPEG frame descriptor n |
| `C2C8` + 34·(n−1) | YUYV frame descriptor n (stride holds through n=7) |
| `C575`, `C5B7` | two 11×6 tables: index, width, height |
| `C60C` | mode table, 11×21: the full raster per frame index |
| `C6FE`, `C71A` | raster being streamed / raster measured on the input |

So the hook forces 27 bytes and hands control on:

```asm
        MOV DPTR,#0xC0A8      ; bDefaultFrameIndex -> 7
        MOV A,#0x07
        MOVX @DPTR,A
        ...                   ; 26 more: descriptors, size tables, raster record
        CJNE R7,#0x08,native  ; event 8 = "hand me the EDID"
        MOV R3,#0xFF
        MOV R2,#0xD1          ; our 256 bytes live at XDATA D100
        MOV R1,#0x00
        LJMP 0x73F7           ; ROM: copy into the DDC buffer
native:
        LJMP 0xCD6E           ; on to the vendor's own handler
```

All of it is reapplied on every event rather than patched once, because the ROM
regenerates the USB descriptors on each USB reset.

The other ten resolutions still work — ask for 1080p and the chip scales
1024×600 up to it.

Registers, the `CBD5` bit map, ROM entry points, the layout of a raster record
and how each of it was established are in
[`docs/reverse-engineering.md`](docs/reverse-engineering.md).

## 🔬 Debugging without extra hardware

A mode can be tried without flashing anything: `tools/tryit.py` writes the same
state straight into XDATA and swaps the DDC buffer, and a power cycle undoes all
of it.

```sh
python3 tools/tryit.py           # apply the target in RAM
# replug HDMI so the source re-reads the EDID
python3 tools/tryit.py --show    # what the chip locked onto
```

`input detected` is the raster the chip actually measured. What it encodes is
visible in the JPEG itself, regardless of what the host thinks it asked for:

```sh
v4l2-ctl -d /dev/video0 --set-fmt-video=width=1024,height=768,pixelformat=MJPG \
         --stream-mmap --stream-count=3 --stream-to=cap.mjpg
```

The EDID the card serves over DDC can be read back from the host. The buffer at
XDATA `0xFB00` is only visible while bit 0 of `F819` is up — the same gate the
ROM holds open while filling it:

```sh
python3 -c "import sys; sys.path.insert(0,'tools'); import dev, hashlib; \
print(hashlib.sha256(dev.ddc_edid()).hexdigest())"
```

That returns exactly the bytes a source will see. No Raspberry Pi or monitor
needed to check an EDID.

### Gotchas

- **EEPROM access dies mid-session.** Reads start returning `01` across the whole
  image, and a write then "succeeds" while changing nothing —
  `write-file --verify` reports `Failed to verify write`. RAM, USERCONFIG and the
  chip itself stay perfectly healthy. Only a power cycle brings it back. Always
  read the image back and compare it yourself instead of trusting the exit status.
- `--eeprom-size` must be **2048**. The 24C16 is 2 KiB; at 4096 addressing wraps
  and every read returns `A5`, which looks exactly like a broken access path.
- `--no-patch` is required. Upstream's runtime patcher does not know the `5A A5`
  magic, assumes a 256-byte payload, and drops its blobs at `0xCD00` — the middle
  of the vendor firmware.
- The EDID is loaded **once, at chip init**. Replugging HDMI does not reload it;
  that takes a USB power cycle.
- On MS2109 the EDID loader sits at `0x6345`. On the D7 that address is
  `SETB 0x21.3 / RET` — the call succeeds and does nothing. A very convincing
  false lead.

## 📁 Source layout

```
firmware/
  eeprom-stock-backup.bin    factory EEPROM              22e7e445…
  eeprom-1024x600.bin        UVC + EDID 1024x600         28b5e85c…   <- flashed
  eeprom-720p-edid.bin       UVC + EDID 720p             d42efa96…
  eeprom-720p-uvc-only.bin   UVC 720p only               2d78f96e…
edid/
  card-edid.bin              factory EDID                e09e2c16…
  edid-1024x600.bin          current                     85e4c780…
  edid-720-tight.bin         720p                        40fe0956…
  edid-720-strict.bin        720p, wider range window    57871809…
  make_edid.py               EDID generator
rom/
  d7-rom.bin                 64 KiB code space dump      427c7581…
                             (above 0xC000 it is RAM, not ROM)
tools/
  videomode.py               mode definitions: EDID and chip table in one place
  mcs51.py                   8051 disassembler and assembler
  d7image.py                 EEPROM image: fields, payload, checksums
  dev.py                     msctl wrapper
  build_fw.py                image builder
  tryit.py                   try a mode in RAM, no flashing
  verify.py                  post-flash check
udev/
  70-macrosilicon.rules
docs/
  reverse-engineering.md     the full account
```

Re-dumping code space leaves the EEPROM alone; hooks are disabled for the
duration and restored afterwards:

```sh
$MSCTL --pid 2109 --no-patch --eeprom-size 2048 dump-rom rom/d7-rom.bin
```
