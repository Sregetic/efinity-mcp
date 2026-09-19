# J5 LCD integration, 2026-09-16

User confirms LCD and adapter match supplied reference. Target JJX035FHD05-V9 with MIPI DSI Driver22-to30pin board. Camera remains J4.

## Verified physical mapping
Crosschecked board schematic sheet10 (PDFpage11), LCD Driver schematic and supplied CSI2DSI V3.5 second DSI peripheral mapping:
J5 pin2 LCD reset control GPIOR_12; pin3 backlight enable GPIOR_15; pin1 VCC5V.
DSI clock GPIOT_PN_13; data0 PN17; data1 PN16; data2 PN14; data3 PN12.
Existing J7 DSI assignments replaced; J4 CSI and HDMI pin assignments unchanged.

## Implementation
One vendor DSI IP, four lanes at1Gbps/lane, byte clock125MHz, control100MHz. 1920active pixels RGB888, vendor Panel_1080p_reg.mem retained. The copied active IP wrapper is version5.15 (settings), not the stale5.3 define file. Pixel FIFO4096->2048 for Ti60 memory budget; sustained operation requires runtime/display verification.
RGB8881PPC at148.5MHz is packed into two pixels every other valid clock, then sent to the DSI IP pixel domain at148.5MHz. No unsupported combinational clock division. DSI IP crosses to its own byte clock. Line packing is checked at960pairs per1920pixel line. Reset/source change discards partial frames until next VS.
LCD defaults to diagnostic color bars. JTAG op13 selects bars1/current video0; source switch at frame boundary, next complete frame begins capture. HDMI remains existing output.
Diagnostic page13 reports panel config state/completion, video enable, packed-frame counter, pairs/line and sticky framing fault. Controller configuration completion is not panel-acknowledged image acceptance.

## Evidence
Source/reference PDFs and rendered schematic pages in this directory. Pack test passes2880pairs, independent RGB order,960pairs/line, partial-source discard and odd/truncated-line detection. Fresh full Efinity build, resource/timing results and physical acceptance to be appended.
Backup previous HDMI sources/peripheral/constraints/host scripts and artifacts in backups/lcd_j5_20260916.

## Integration corrections before programming
Initial fit exceeded capacity (264/256 RAM blocks,60827/60800 XLR). Removed legacy USER1 analyzer, replaced with minimalID shift register; USER2 stays. Reduced only RAW diagnostic grid80x45->40x23, spacing24->48; image/Canny sizes unchanged. Compact RAW packing/bounds simulation passed. Next synthesis memory count250 blocks.
Reference panel ROM contains80000000-cycle delay but original controller used22-bit timer/operand, truncating it. Expanded timer/comparison to32bits; regression exercises crossing2^22. Used169 valid ROM words and explicit end marker. No bitstream from failing/interrupted builds was programmed.


## Fresh build and hardware evidence
Build26091702: full compile PASS, WNS+0.197ns, WHS+0.026ns. RAM246+4=250/256. Correct FPGA ID10660A79 before and during SRAM programming. Source identity check passed.
USER2 page13 returns config_done1,video_ready1,pack_fault0,960pairs/line. Packed-source frame counter885->937 over~0.86s, approximately60Hz. These are input/controller observations, not proof of visible panel output or DSI FIFO status. Camera capture/display continue; Cannyfault0; write_errors1 stable.
Compact RAW probe successfully captured60tiles at step4 with new40x23 grid. Previous80x45 grid supported by host parser for older builds.
Physical LCD color bars and camera image acceptance pending user observation. Initial stateLCD bars,HDMI M0 camera.

## Runtime control (no rebuild)
After loading scripts/efinity_env.ps1 use its Efinity Python to run scripts/vision_control.py:
--page13 --lcd-test1 : LCD diagnostic bars
--page13 --lcd-test0 --mode0 : LCD current camera image (HDMI also M0)
M1..M7 remain existing algorithm modes when lcd-test0. --page13 alone is read-only status apart from diagnostic page selection.
Power-off clears SRAM; reprogram current camera artifact to restart. LCD defaults to bars on each configuration. Old HDMI-only artifact/source backup retained in backups/lcd_j5_20260916; it is not erased or overwritten by this integration.

## Follow-up: fixed light ring, no image
User reports no visible image and requests HDMI removed. Build26091703 disables all four HDMI output enables and holds serializers in reset (pixel clocks retained for ISP). LCD reset held83.9ms after system release, before vendor command startup; backlight enabled only after configuration and video startup delay. Reset release is a magnitude comparison, not a toggling counter bit. Focused simulation checks threshold crossing and no reassertion. Final WNS+0.205ns,WHS+0.023ns; SRAM program correctID10660A79 and USER2 build verified.
Runtime switched LCD source to camera (lcd_test0), M0. Page13 frames40912->40951,960pairs/line,pack_fault0,config_done1,video_ready1. This does not establish panel image acceptance. User asked whether new reset sequence/camera source changed visible ring; awaiting response. Native2PPC reference timing/BIST remains a potential next diagnostic, not implemented in this version.


## BIST isolation build26091704
User confirms26091703 still fixed light ring, no image. HDMI remains disabled. Added reference-comment BIST sequence (page1 via0x76,write0x0B=0x6C,page0 restore) at ROM index165; original commands preserved, normal mode repeats page1 select instead of enabling BIST. This is a diagnostic command from supplied reference, not a verified panel readback.
JTAG op14 toggles BIST and restarts LCD only; op15 controls backlight without resetting camera. Page14 reports requested mode, reset/backlight output and sticky DSI OE/LP-input activity. BIST ROM selection test passed. WNS+0.286ns,WHS+0.026ns; JTAG ID10660A79,program complete,build readback26091704. Page14 reset0/backlight1/BIST1,activityFF; page13 config_done1,ready1,960pairs,line fault0. Activity is FPGA-side and not evidence of panel reception. User-visible selftest result pending. Camera image not claimed functional on LCD.

## Root-cause isolation and native 2PPC build 26091705
User observed the BIST cycling through colors including a complete color-bar image. This confirms panel pixels, panel-side pattern generation, power/reset and the LP command path; external DSI video remained the failing boundary.

The supplied CSI-to-DSI reference drives the DSI `clk_pixel` from `vid_clk_dvi2` and presents two RGB888 pixels on every active cycle. Builds 26091702-04 instead clocked the DSI pixel interface at 148.5 MHz and asserted a two-pixel word only every other active cycle. Equal average pixel throughput is not an equivalent DSI pixel-interface contract.

Build26091705 replaces only this boundary with the supplied native pattern structure: 74.25 MHz, 2PPC every active cycle, HST/HBP/HFP=4/88/120 and VST/VBP/VFP=2/20/20. BIST defaults off. `lcd_test=1` selects the native FPGA bars; `lcd_test=0` selects the existing debayer `rgb_datax2` camera stream, also native 2PPC. HDMI stays disabled.

The small 2PPC regression checks paired RGB identity and 960 active pairs for a 1920-pixel line. Fresh Efinity compile passes with WNS +0.266 ns, WHS +0.026 ns and zero unassigned pins. SRAM programming read ID 10660A79 and USER2 build26091705. Page13 shows config/ready=1, 960 pairs/line, sticky fault0 and a rising native-frame counter; page14 shows BIST0, backlight1 and DSI activity. Visible fixed-bar acceptance is pending user observation; internal counters alone are not panel-reception evidence.


## 2026-09-18 verification correction
The user confirmed that the unmodified supplied reference bit displayed camera video on J5. A fixed/faint light ring was still reported. This demonstrates working video transfer in that tested configuration, but does not independently identify the ring as backlight damage or phone flare.
The 4096-entry FIFO restoration is a candidate fix, not an isolated proven cause. The current LCD source mux selects native 2PPC bars or debayer camera RGB; algorithm mode selection is not yet connected to this mux. Earlier statements claiming LCD M1-M7 acceptance were premature.
The previous single-plane Canny change removes frame-atomic edge publication. In-place changes may be visible throughout capture and hysteresis sweeps, not merely one display frame. Raw snapshot commands currently return zeros because their diagnostic RAM was retired. These are recorded functional tradeoffs.
The last build status before this session had exit_code=1 despite an older positive timing report. A new single compile is being run with source identity checks; stale outflow files are not accepted as new build evidence.

## 2026-09-18 fresh build and hardware readback
Full compile and source hash validation passed at 10:08 local time. WNS +0.472 ns, WHS +0.026 ns; unassigned core pins 0; memory 248/256. Programmed through scripts/program_vision_sram.ps1 with its manifest/source/timing gates and observed ID 0x10660A79.
LCD page13 decoded as 260917f5: initial camera selection 0, config_done 1, video_ready 1, line_pairs 960, fault 0, advancing frame counter. Commands 0 -> 1 -> 0 all read back correctly, confirming the dedicated toggle synchronizer works. Switching produced sticky line fault 1: the two input rasters have different phase and are switched at the pattern VS only. Source switching still needs frame/line alignment; it is not accepted as glitch-free. Reloading the same verified artifact restores the default camera path for physical observation.
The host decoder now recognizes 260917f5 by selected diagnostic page. Source identity is the artifact manifest hash, since older page0 build labels were retained.
Physical camera display on this custom artifact remains pending the user's observation; reference-bit camera display was previously confirmed.

## Reference initialization experiment, 2026-09-18 10:18
User rejected the FIFO4096 + selector-sync version: only light ring, no picture. FIFO restoration is therefore not a sufficient fix. Restored exactly 169 active command words from vendor Panel_1080p_reg.mem, removed inserted BIST commands and set BIST_INDEX=-1. Other datapath/reset settings unchanged. BIST control is inactive in this experimental build.
Full build PASS, source hashes checked, final WNS +0.308 ns, WHS +0.026 ns, unassigned pins 0. Programmed with the gated SRAM script, ID 0x10660A79. See reference_init_runtime_20260918.json for post-program status. Visible acceptance pending.
