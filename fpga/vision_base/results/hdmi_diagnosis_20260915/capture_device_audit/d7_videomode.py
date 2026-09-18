"""Video modes that the EDID and the chip's own mode table have to agree on.

The ROM keeps 11 modes in XDATA at 0xC60C (copied at init from mask ROM 0x1886),
one 21-byte record per UVC frame index.  A record is the whole raster -- totals,
pixel clock, sync widths -- not just the frame size, so a mode the card streams
has to be described identically in two places:

    * the EDID served over DDC, which is what the source actually generates;
    * the chip's record for the frame index we stream.

Both are generated from the modes below so they cannot drift apart.
"""


class Mode:
    """One progressive video mode."""

    def __init__(self, name, pclk_khz, hact, hfp, hsw, hbp,
                 vact, vfp, vsw, vbp, hsync_pos, vsync_pos):
        self.name = name
        self.pclk_khz = pclk_khz
        self.hact, self.hfp, self.hsw, self.hbp = hact, hfp, hsw, hbp
        self.vact, self.vfp, self.vsw, self.vbp = vact, vfp, vsw, vbp
        self.hsync_pos, self.vsync_pos = hsync_pos, vsync_pos

    @property
    def htotal(self):
        return self.hact + self.hfp + self.hsw + self.hbp

    @property
    def vtotal(self):
        return self.vact + self.vfp + self.vsw + self.vbp

    @property
    def hblank(self):
        return self.hfp + self.hsw + self.hbp

    @property
    def vblank(self):
        return self.vfp + self.vsw + self.vbp

    @property
    def hfreq_khz(self):
        return self.pclk_khz / float(self.htotal)

    @property
    def refresh_hz(self):
        return self.pclk_khz * 1000.0 / (self.htotal * self.vtotal)

    def chip_record(self):
        """The 21-byte entry of the ROM mode table, leading flag byte included.

        Layout, all 16-bit big endian after the flag:

            07  flag (0x07 on every stock entry, sync polarity is not in here)
            htotal, vtotal, hactive, vactive
            pixel clock in units of 10 kHz
            refresh in hundredths of a Hz
            hsync+hback, vsync+vback, hsync width, vsync width
        """
        def be(v):
            assert 0 <= v <= 0xFFFF, "%s: field out of range: %d" % (self.name, v)
            return bytes([v >> 8, v & 0xFF])

        return bytes([0x07]) + b"".join([
            be(self.htotal), be(self.vtotal), be(self.hact), be(self.vact),
            be(int(round(self.pclk_khz / 10.0))),
            be(int(round(self.refresh_hz * 100))),
            be(self.hsw + self.hbp), be(self.vsw + self.vbp),
            be(self.hsw), be(self.vsw),
        ])

    def __str__(self):
        return "%s  %dx%d  %d/%d total  %.2f MHz  %.3f kHz  %.2f Hz" % (
            self.name, self.hact, self.vact, self.htotal, self.vtotal,
            self.pclk_khz / 1000.0, self.hfreq_khz, self.refresh_hz)


# CEA-861 format 4.  Matches the stock table entry for frame index 6 byte for
# byte, which is what confirms the record layout above.
MODE_720P60 = Mode("1280x720p60", 74250,
                   1280, 110, 40, 220,
                   720, 5, 5, 20,
                   hsync_pos=True, vsync_pos=True)

# VESA CVT, i.e. what `cvt 1024 600 60` produces:
#   49.00 MHz, 1024 1064 1168 1312, 600 603 613 624, -hsync +vsync
# 1024x600 has no CEA VIC and no standard-timing aspect code, so it can only be
# advertised as a detailed timing.  59.85 Hz is the honest refresh at 49.00 MHz.
MODE_1024X600 = Mode("1024x600@60 CVT", 49000,
                     1024, 40, 104, 144,
                     600, 3, 10, 11,
                     hsync_pos=False, vsync_pos=True)

MODES = {
    "720p": MODE_720P60,
    "1024x600": MODE_1024X600,
}
