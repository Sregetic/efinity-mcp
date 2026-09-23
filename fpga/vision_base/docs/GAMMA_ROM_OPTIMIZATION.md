# Gamma direct-ROM optimization

## Scope

Based on `sync/current-fpga-20260919` at `141bfd1` (PR #4), not the older
FPGA snapshot on main. Only the gamma RTL implementation changes in hardware.
The original curve files, top-level tone 0/1/2/3 selection, three legacy delay
registers, clocks, pins, camera settings, Canny and programming gates are unchanged.
This work does not authorize or perform a JTAG/Flash operation.

## Change

The original module continuously copied a fixed 1024x10 ROM into a writable
register array, then read that array at three independent RGB addresses. Its
saved module-level synthesis estimate was 19,576 LUT, 8,246 FF and one RAM;
these are synthesis categories, not a directly subtractable XLR count.

The replacement uses two instances of the existing true_dual_port_ram wrapper:
R/G use both read ports of one ROM, and B uses one read port of the second.
All write enables are tied low. OUTPUT_REG is FALSE: the wrapper already has
one synchronous read stage. No higher clock, RGB serialization, interpolation,
curve refitting or 256-entry compression is introduced in this first change.

The 10-bit lookup remains T[x]. The board's 8-bit lookup remains
T[(x << 2) | (x >> 6)][9:2]. Three channels accept different addresses on every
pixel clock. Registered valid/HS/VS are sampled with the ROM addresses. Outputs
are black while registered valid is low, without a second output pipeline stage.
The existing legacy_delay1/2/3 in the top level must remain unchanged.

## Startup boundary

The new curve is initialized by FPGA configuration, so the first valid sample
after synchronous reset has a defined lookup result. The legacy reference has
a runtime fill interval, and a short reset can disturb its copy pipeline. Exact
legacy comparisons therefore start only after its table refill; the NEW module
is checked independently against the source table on every tested cycle,
including startup, reset, blanking and reference warm-up. Undefined legacy
startup pixels are not a functional requirement. No runtime curve-update port
existed or is removed.

## Regression

Run with Python 3.10+ and Icarus (the script also checks C:/iverilog/bin):

```powershell
python fpga/vision_base/scripts/verify_gamma.py
# Or specify executables explicitly:
python fpga/vision_base/scripts/verify_gamma.py --iverilog C:/iverilog/bin/iverilog.exe --vvp C:/iverilog/bin/vvp.exe
```

Six configurations cover 8/10-bit inputs with the actual display curve, the
original 2P2 curve, and a deliberately nonmonotonic address-test table. Checks:

- every input code on each color channel, at independent simultaneous addresses;
- deterministic random RGB, continuous valid and DE bubbles, changing HS/VS;
- original-reference cycle comparison after refill, independent golden lookup
  from the first tested clock, midstream synchronous reset and black blanking;
- actual rgb_chroma_tone plus the top-level three-delay/tone-selection harness
  for 8-bit inputs; frame-boundary mode cycling through all four modes.

This is a focused integration harness, not a complete board simulation. The
legacy fixture is test-only and must never be added to the board XML. Missing
curves, unknown table values, simulator errors, timeouts or missing PASS markers
fail the script. Logs go to a new temporary directory or a new --output directory.
The cloud workflow prints a small Job Summary and does not upload artifacts.

## Real Efinity acceptance remains required

Saved baseline, 2026-09-19: whole board XLR 58,264/60,800, RAM 221/256,
DSP 68/160; final WNS +0.243 ns, WHS +0.026 ns. These are OLD measurements,
not results for this change. The replacement's mapped BRAM count, area savings,
packing and setup/hold must be measured by a new Efinity build.

After review, use an isolated source copy, run the gamma regression and existing
full vision regressions, then the existing compile-only command:

```powershell
pwsh -NoProfile -File fpga/vision_base/scripts/synthesize.ps1 -Top board -Flow compile -VideoMode camera -EfinityHome F:/Efinity/2026.1
```

Confirm the current script parameter names locally, preserve the existing source
mutation and release gates, and compare the same tool/device/constraints. Collect
the new gamma hierarchy, whole-board XLR/RAM/DSP, final WNS/WHS and interface
coverage. Do not change clocks, exceptions or coverage gates to obtain a pass.
The existing main-only Runner policy is not relaxed and PR #4 is not implicitly
merged. Real-board visual acceptance and any first download require separate
operator confirmation. Do not report an expected reduction as a measured result.
