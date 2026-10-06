# SC2210 sensor profiles

The default build still uses SC431HAI. SC2210 requires an explicit `-SensorProfile`;
no profile is selected automatically by the sensor name.

`sc2210_1080p30_2lane_24mhz_reference.json` and its `.mem` are a traceable SDK
reference, **not a confirmed configuration of the user's future camera module**.
The 253 write entries come unchanged from the linked commit and mode array.
The reference expects 24MHz sensor MCLK supplied by the module/adapter; the
current FPGA top has no camera MCLK output. It uses 1920x1080, RAW10, BGGR,
two MIPI lanes and nominal30fps. HDMI remains1080p60.

For the actual module, supply a profile with its manufacturer's initialization
sequence and timing. Supported input contract: 1920x1080 RAW10 BGGR, 2/4 lanes.
`init_file` is relative to the JSON file; each line is a seven-digit hexadecimal
25-bit word `{16-bit register,8-bit value,write_flag=0}`. `init_length` and
`init_sha256` bind the exact ordered sequence. Include `sensor`, `mode`,
`width`, `height`, `raw_bits`, `bayer`, `lanes`, `mclk_hz`, `fps`,
`hs_byteclk_mhz`, `vts`, `exposure_min`, `exposure_max`, `exposure_initial`,
`init_file`, `init_length`, `init_sha256` and source/validation provenance.

Exposure values are raw register units, encoded into3e00..3e02. The reference
uses the datasheet normal-mode ceiling VTS−4; it does not reuse SC431HAI's2950
half-line ceiling. Changes to lane count, MCLK, RAW format or FPS require a
matching register sequence, not just editing metadata.
