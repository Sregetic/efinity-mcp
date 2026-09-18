# MacroSilicon D7 (VID:PID 345f:2109) — 720p firmware

Chip reports `0xD7` at XDATA `F800`, not the `0xA7` upstream ms-tools expects for
MS2109. It shares the ROM ABI in broad strokes but not in detail, so MS2109
firmware images cannot be flashed as-is.

## What the firmware does

* USB/UVC default frame index → 7 for both MJPEG and YUYV, with frame 7
  rewritten from the stock 1024x768 to 1024x600 everywhere the chip keeps it.
* HDMI sink advertises 1024x600 only, via a custom 256-byte EDID.

The `720p` target does the same with frame index 6, which already is 1280x720 in
stock, so it only has to force the default index.

## EEPROM layout (24C16, 2048 bytes)

```
0x0000..0x002F  USERCONFIG (48 bytes)
    [0:2]  magic 5A A5          (MS2109 uses A5 5A — this is why upstream
                                 EEPROMIsLoaded() does not recognise a D7)
    [2:4]  firmware length, big endian
    [4]    hook enable bits     bit0 = normal hook @ CC00
                                bit2 = IRQ hook @ CC20
                                bit4 = IRQ hook @ CC40
    [5]    feature gate bits    see table below
0x0030..     firmware payload, copied to XDATA 0xCC00 at boot
after        [+0:+2] sum16 of USERCONFIG[2:48]
             [+2:+4] sum16 of the payload
```

Both checksums are plain additive 16-bit sums. A wrong payload checksum makes
the ROM silently ignore the user firmware.

## CBD5 feature gates

Each bit replaces one ROM routine with a call to the normal user hook, passing
an event id in `R7`. The ROM reads `CBD5` live, so changes take effect without a
reboot — but only at the point the relevant ROM path next runs.

| bit | value | event `R7` | replaces |
|-----|-------|-----------|----------|
| 0 | 0x01 | 0x04 | `0x7BB7` |
| 1 | 0x02 | 0x05 | `0x41A9` |
| 2 | 0x04 | 0x06 | `0x61F9` |
| 3 | 0x08 | 0x07 | `0x6C15` |
| 4 | 0x10 | 0x08 | **EDID load** |
| 5 | 0x20 | 0x09 | `0x36BE` |
| 6 | 0x40 | 0x17 | `0x3472` |
| 7 | 0x80 | 0x24 | `0x470C` |

Stock D7 ships `0x40`; the vendor firmware handles event `0x17`. This firmware
uses `0x50` so event `0x08` is delivered too.

## EDID path

`0x72CF` decides where the EDID comes from:

```
72D4  MOV DPTR,#0xCBD5
72D7  MOVX A,@DPTR
72D8  JNB  ACC.4,0x72E2      ; gate clear -> ROM's own EDID
72DB  MOV  R7,#0x08
72DD  LCALL 0x7F91           ; gate set -> ask the user hook
72E0  SJMP 0x72EB
72E2  MOV  R3,#0xFF          ; factory EDID lives in mask ROM at 0x847C
72E4  MOV  R2,#0x84
72E6  MOV  R1,#0x7C
72E8  LCALL 0x73F7
```

`0x73F7` copies 256 bytes from the generic pointer `R3:R2:R1` into the DDC
buffer at XDATA `0xFB00`, holding `F819` bit0 set for the duration. That bit
also gates *reads* of `FB00`, which is why the buffer looks like `FF` otherwise:

```python
dev.poke(0xF819, b"\x01"); edid = dev.ram(0xFB00, 256); dev.poke(0xF819, b"\x00")
```

This is the verification oracle — it returns exactly what an HDMI source reads
over DDC, with no external hardware involved.

`0x72CF` is reached only from init (`0x3E5F`) and the soft-reset path
(`0x4DF2`), so the EDID is loaded once per chip boot. Replugging HDMI does *not*
reload it. `0x72CF` itself drops HPD (`0x7325(0)`), reloads, then raises HPD
again (`0x7512`), so calling it makes a connected source re-read the EDID.

Useful ROM entry points, none of which match the MS2109 ROM:

| address | purpose |
|---------|---------|
| `0x73F7` | load EDID from `R3:R2:R1` |
| `0x7F91` | call normal user hook (checks `CBD4` bit0) |
| `0x80AC` | `LJMP 0xCC00` — the hook itself |
| `0x8073` | set bits: `reg[R6:R7] \|= R5` |
| `0x000E` | clear bits: `reg[R6:R7] &= ~R5` |
| `0x847C` | factory EDID, 256 bytes |

On MS2109 the EDID loader sits at `0x6345`; on D7 that address is `SETB 0x21.3 / RET`.
Calling it succeeds and does nothing, which is a convincing false positive.

## Code space above 0xC000 is RAM

A `dump-rom` image is 64 KiB of *code space*, and only 0x0000..~0xBFFF of it is
mask ROM. Everything above 0xC000 is the on-chip RAM that XDATA also addresses —
which is why user firmware loaded to XDATA 0xCC00 executes as code at all.
Confirmed by diffing: the dump at 0xCC00 is the EEPROM payload (1002 of 1018
bytes identical; the rest is the entry vector `dump-rom` redirects while running).

So everything the ROM builds up there is writable from the hook. What lives
there, and where it comes from:

| XDATA | contents | source in mask ROM |
|-------|----------|--------------------|
| `C0A2` | UVC MJPEG format descriptor, `bDefaultFrameIndex` at `C0A8` | rebuilt on USB reset |
| `C0AD` + 46·(n−1) | `VS_FRAME_MJPEG` descriptor n | rebuilt on USB reset |
| `C2AD` | UVC uncompressed format descriptor, `bDefaultFrameIndex` at `C2C3` | rebuilt on USB reset |
| `C2C8` + 34·(n−1) | `VS_FRAME_UNCOMPRESSED` descriptor n (stride holds to n=7) | rebuilt on USB reset |
| `C575` | 11 × `{index, W be, H be, 0xEA}` | `0x83F9` |
| `C5B7` | 11 × `{index, W be, H be, byte}` | `0x843B` |
| `C60C` | 11 × 21-byte raster record | `0x1886` |
| `C6FE` | raster currently being streamed | measured/derived |
| `C71A` | raster measured on the HDMI input | measured |

Inside a frame descriptor: `wWidth` at +5, `wHeight` at +7,
`dwMaxVideoFrameBufferSize` at +17 (stock value is always W·H·2).

## The mode table at C60C

One 21-byte record per UVC frame index — the whole raster, not just the frame
size. This is what the ROM matches an incoming HDMI timing against:

```
+0      flag, 0x07 on every stock entry
+1      htotal          be16
+3      vtotal          be16
+5      hactive         be16
+7      vactive         be16
+9      pixel clock     be16, units of 10 kHz
+11     refresh         be16, hundredths of a Hz
+13     hsync + hback   be16
+15     vsync + vback   be16
+17     hsync width     be16
+19     vsync width     be16
```

Reconstructing CEA 1280x720p60 from its parameters reproduces record 6 byte for
byte, which is what pins the layout down (`tools/videomode.py`).

The flag byte is not sync polarity in *this* table — every stock entry is 0x07
including the ones with negative sync — but the measured record at `C71A` does
carry it: a source sending -hsync +vsync shows up as 0x05. The ROM matches
regardless, so the flag is left at 0x07 when a slot is rewritten.

Stock contents:

| n | mode | n | mode |
|---|------|---|------|
| 1 | 1920x1080 @ 148.35 MHz | 7 | 1024x768 @ 65.00 MHz |
| 2 | 1600x1200 @ 162.00 MHz | 8 | 800x600 @ 40.00 MHz |
| 3 | 1360x768 @ 85.50 MHz | 9 | 720x576 @ 27.00 MHz |
| 4 | 1280x1024 @ 108.00 MHz | 10 | 720x480 @ 27.00 MHz |
| 5 | 1280x960 @ 102.00 MHz | 11 | 640x480 @ 25.17 MHz |
| 6 | 1280x720 @ 74.25 MHz | | |

There is no twelfth slot, so a mode that is not in this list can only be added
by overwriting one that is — for 1024x600 that is slot 7. Rewriting the two size
tables and this record is enough for the chip to lock onto the new input timing
and encode it; the descriptor writes are only there so the host is told the same
thing.

## Payload layout

```
CC00        LJMP 0xD000            (native entry LJMP 0xCD6E is relocated)
CC03..CFF9  vendor firmware, byte-identical to stock
D000..D096  hook: forced mode bytes + event 8 -> EDID  (151 bytes for 1024x600,
            25 for the 720p target)
D100..D1FF  the 256-byte EDID
```

D200 and up is not free: the ROM uses it, so the payload stops at D200 and the
hook has to fit in the 256 bytes below the EDID.

`CFEC..CFF9` in the stock payload is dead SDCC crt0 (clear IRAM, `MOV SP,#41`,
`SJMP $`). The earlier 720p-only firmware overwrote it, which worked but left no
room; this build keeps it intact and appends instead.

## Tools

* `videomode.py` — the modes themselves; generates both the EDID detailed timing
  and the chip's raster record, so the two cannot disagree.
* `mcs51.py` — 8051 disassembler and a small assembler.
* `d7image.py` — EEPROM image: fields, payload, both checksums.
* `dev.py` — msctl wrapper for RAM/USERCONFIG access.
* `build_fw.py` — builds an image from the stock backup + an EDID. The forced
  bytes are derived from the mode, checked against `rom/d7-rom.bin`, and reduced
  to the ones that actually differ from what the ROM writes itself.
* `tryit.py` — applies a target to RAM only, so a mode can be tried before it is
  flashed. A power cycle undoes it.
* `verify.py` — post-flash check, including what the chip measured on its input
  and what the host now sees in the USB descriptors.

## Flashing

The chip's ROM exposes the external EEPROM over the HID interface, so no
external programmer is needed. **`--eeprom-size` must be 2048.** Passing 4096
makes addressing wrap and every read returns `0xA5`, which looks exactly like a
broken access path.

```sh
./msctl --pid 2109 --no-patch --eeprom-size 2048 --log-level 2 \
        write-file --verify EEPROM 0 eeprom-1024x600.bin
```

`--no-patch` is required: upstream's runtime patcher does not recognise the
`5A A5` magic, assumes a 256-byte payload and allocates its blobs at `0xCD00`,
in the middle of the vendor firmware.

The EEPROM path also dies on its own partway through a session: reads start
returning `01` for the whole image, and a write then reports
`Failed to verify write` having changed nothing. RAM, USERCONFIG and the chip
itself keep working normally throughout, and only a power cycle brings the
EEPROM back. Observed after a stretch of RAM pokes and a capture run; the
trigger is not pinned down. Read the image back and compare it yourself instead
of trusting the exit status.

## Images

| file | sha256 | what |
|------|--------|------|
| `eeprom-stock-backup.bin` | `22e7e445…` | untouched factory EEPROM |
| `eeprom-1024x600.bin` | `28b5e85c…` | UVC + EDID 1024x600 (current, flashed) |
| `eeprom-720p-edid.bin` | `d42efa96…` | UVC 720p + 720p EDID |
| `eeprom-720p-uvc-only.bin` | `2d78f96e…` | UVC 720p only, no EDID change |
| `edid-1024x600.bin` | `85e4c780…` | the EDID served over DDC (current) |
| `edid-720-tight.bin` | `40fe0956…` | 720p EDID |
| `edid-720-strict.bin` | `57871809…` | same, before the range descriptor was narrowed |
| `card-edid.bin` | `e09e2c16…` | factory EDID, == ROM `0x847C` |
| `d7-rom.bin` | `427c7581…` | 64 KiB code space dump; above `0xC000` it is RAM |

To revert, flash `eeprom-stock-backup.bin` the same way and power-cycle USB.
