# HDMI 黑屏诊断：当前验收未通过

## 当前结果

已完成板级核对、针对性修改、完整编译与布局布线、时序检查、JTAG SRAM 下载和采集卡实际抓图。采集图仍为均匀黑屏；目标尚未完成。时序通过、FPGA 内部帧计数递增，不等于 HDMI 接收端已经锁定。

本文件与 current_state.json 是本次复核状态。board_mapping_audit.md、diagnosis.json 是早期只读检查快照，其中“未修改/未下载”等描述只适用于当时。

## 保留的主工程修改

- 工程 device=Ti60F225，timing_model=I3。手册 Sensor 表的 J4 时钟、D0、D2 与当前工程映射相符。
- LED2 从与原理图 UART_RX 用途冲突的 GPIOR_28 调整为 GPIOL_P_12、1.8 V。
- HDMI AVI video_VIC 设置为 16，对应主工程 1080p60。
- USER2 增加诊断读口：复位、三个 PLL 锁定、核心活动和测试图帧计数。跨时钟计数采用源域寄存 Gray 编码与两级同步；诊断端单独约束。
- 修改前备份保留在 backups/hdmi_debug_20260915。未修改算法和帧处理核心；未写 Flash。

## 主工程证据

- results/board.compile.status.json：pattern 完整编译成功，WNS +0.460 ns，WHS +0.026 ns，未分配核心引脚 0。该编译记录的 hardware_programmed=false 仅表示编译脚本本身未执行下载。
- final_main_program.log：Ti60 ID 0x10660A79，指定主工程 bit 通过 JTAG 下载完成。
- recheck_main_status.json：有效读数 marker=0xB6，三个 PLL 均锁定，复位均释放；舍弃首个旧快照后帧计数 101、132、162、192、223，间隔约 0.5 秒。该观测是内部帧活动，不是采集端测得帧率。
- recheck_main_capture.png/.log：重新打开 UGREEN 25854 后抓取 1920×1080 MJPEG 图像；实际查看仍黑，全部像素 RGB=(7,7,7)。
- current_state.json 保存当前 bit SHA256 和复核状态；capture_inventory.json 保存抓图像素范围与 SHA256。

## 隔离实验及边界

已保留纯 DVI、完整 HDMI/AVI、1080p、720p、P/N 极性以及串行位序的实验抓图。各次均为黑屏，未据此确诊物理损坏。MJPEG 与 YUY2 两条采集解码路径均未显示测试图。

board/hdmi_bringup 已恢复为 25 MHz 输入的原始极性、1080p 纯 DVI 诊断配置，并重新完整编译通过：WNS +3.569 ns、WHS +0.095 ns。恢复后的诊断版本没有再次下载；板上继续保留主工程 pattern。诊断像素时钟 148.75 MHz 与主工程 148.5 MHz 不同，因此诊断工程不是最终交付替代品。

## 尚缺的决定性证据

采集卡 USB 取帧正常，但 HDMI 输入锁定状态尚未得到证实。软件内的 PLL 和帧计数不覆盖连接器、板外电平、HDMI 线缆、供电或接收器兼容性。

下一项高信息量测试是物理交叉连接：保持同一采集卡与 HDMI 线，用已知正常 HDMI 信号源测试；或者将开发板 TX 直连已知正常显示器。这需要现场改变接线。其结果才能把排查范围继续缩小到开发板输出侧或线缆/采集卡侧。当前没有支持继续盲改 RTL、随机换引脚或重复下载同一 bit 的新证据。


## 2026-09-15 08:21 更新：RX/TX 对照及编码链路观测

用户将线接 RX 对照时，采集图显示 No Signal；接回 TX 后恢复均匀黑屏。这表明采集端响应有差别，但不足以证明 HDMI 输入已锁定。

新增 64-bit USER2 观测读取到：每帧有效像素 2073600，RGB 分量均出现非零，三个 TMDS 并行数据通道均有变化，时钟编码字非全零/全一，pattern 模式有效。观察跨时钟总线采用完整帧保持及两级同步，丢弃首读，并检查多次一致快照；不参与功能控制。该检查是活动检测，不是 TMDS 编码合法性或串行波形验证。

发现原主工程 video_format 和音频输入未驱动/位宽不匹配。已显式绑定 RGB 和 audio_valid=0、零音频数据以及正确位宽常量。完整编译、布局布线通过：WNS +0.401 ns、WHS +0.026 ns，未分配核心引脚 0；通过 JTAG SRAM 下载后再次抓图仍黑。因此此缺陷的修正没有解决当前黑屏。

当前板上版本为以上显式输入及编码观测版本，不再是早期 32-bit 诊断版本。早期 read_main_status.py 的低 32-bit 状态仍兼容；完整观测使用 encoder_probe_20260915/read_encoder_status.py。基线与改后下载日志、读数、图像均在该目录，current_state.json 已刷新 bit 身份。备份在 backups/hdmi_encoder_probe_20260915。


## 08:34 Serializer reset experiment

Added 256 pixel-clock TX serializer reset after PLL lock. Full P&R passed: WNS 0.231 ns, WHS 0.026 ns. JTAG SRAM programming succeeded; capture still uniform black. This experiment did not resolve the issue. Current FPGA retains this experiment; prior source and bit backup: backups/hdmi_serializer_reset_20260915. Evidence: serializer_reset_20260915/.

MIPI cable orientation remains unverified: Sensor manual shows pin 1, not insulation-up/down. Need connector close-ups at both ends. Test pattern is camera-data independent; indirect electrical effects are not physically excluded.


## 08:48 TMDS snapshot and programmer isolation

USER2 expanded to 192 bits, marker changed from B6 to D7 and upper marker A1. Three consecutive samples inside the white first line have B/G/R codes 200, 0ff, 200 respectively on all lanes; inverse transition-minimization decoding yields 255 on all channels. Clock code is 3e0. This validates these sampled active pixels, not every control period or physical serial waveform. New marker read from FPGA demonstrates updated design loaded. Reader: tmds_snapshot_20260915/read_snapshot.py.

Unmodified vendor archive hdmi_tx.bit SHA256 076476bf4bc7810045cfce302dc95d1239c57f67aca213aa95d0b70ada68f022 was temporarily programmed via SRAM. Capture also black. Its adjacent source uses 1920x1536 and C4, so negative result is inconclusive and is not an I3 timing validation. Restored main design via JTAG lowered from 6 MHz to 1 MHz; D7/A1 and white pixel codes read back correctly, capture remains black. Evidence in vendor_bit_test/. This reduces suspicion of download transport failure but is not a full configuration readback comparison.

AN044 recommends parallel slow-clock PLL feedback for LVDS alignment. A proposed equivalent-frequency multiplier 11/predivider 2 setting failed Interface Designer: valid multiplier 1/2/4 and minimum divided input 16 MHz. Rejected configuration never downloaded; original peripheral XML restored and full build repeated. Failure evidence retained in pll_feedback_attempt/. No conclusion that existing PLL is the proven cause.


## 08:58 Horizontal blanking and pure DVI main-path isolation

A2 snapshot records three horizontal blanking positions at 80, 110 and 170 cycles after first-line DE ends. Upper 10-bit field is DE/VS/HS, not clock data. HDMI auxiliary encoder returned non-control symbols at those positions; this alone is not a protocol fault.

Switched only main encoder implementation to vendor unencrypted pure DVI, retaining main 148.5/742.5 MHz clocks, pin placement and serializer reset. Imported modules renamed dvi_encoder_pure and dvi_encode_pure to avoid collisions; prior top/project preserved in backups/hdmi_main_pure_dvi_20260915. Complete P&R passed. Pure DVI snapshots: HS=0 gives B/G/R 354/354/354; HS=1 gives 0ab/354/354; HS=0 returns 354/354/354. Thus these control symbols follow expected HS states. Actual capture still uniform black.

Current FPGA and source remain the pure DVI diagnostic variant, not a completed HDMI/camera delivery. Read snapshot.json using control classifications; generic pixel inverse values are not meaningful for blanking and were removed in mode-correct analysis. No Flash write.


## 09:18 Exact 720p and TX-disabled negative control

Main pure DVI tested at 74.25 MHz pixels / 371.25 MHz serializer, 1280x720 active and 1650x750 total. Board active pixel counter read 921600. Capture stayed uniform black. The generic A2 reader's pixel/clock labels are not applicable to blanking snapshots; at the 720p HS edge an observation can precede encoder pipeline latency. Do not treat this edge sample as a failed control code.

Next set all four TX_OE=0, confirmed four zero assignments in mapped netlist, compiled and programmed. Capture after about 8 seconds remained uniform black. Therefore the prior RX No Signal versus TX black distinction does not prove valid TMDS or receiver lock. This negative control invalidates that inference; it does not identify the defective component.

Restored original 1080p pattern, clock constraints, peripheral configuration and TX_OE=1 from backups/hdmi_main720_20260915. Rebuilt and downloaded at 1 MHz. Main remains pure DVI diagnostic, not completed camera/HDMI delivery; final capture is black. Evidence in main720_20260915, tx_disabled_20260915, restored1080_after_negative. No Flash writes.


## Manual and output swing audit

Manual cover explicitly names TI60F225I3. PDF page 47 tutorial table names clock GPIOR_PN_11, inconsistent with hardware pin table and schematic clock GPIOR_PN_10. Do not blindly switch to tutorial mapping. Same tutorial specifies VOD large for all TX lanes; main D0/D1 were typical. Changed only D0/D1 VOD to large; full P&R and SRAM programming succeeded, capture remained black. Current variant retains all-large output swing. Main compiled timing WNS 0.505 ns, WHS 0.026 ns. Evidence: vod_large_20260915. This did not resolve black output; actual PCB revision still needs physical evidence rather than chip suffix inference.


## Capture-side read-only HID access established

HidD_GetManufacturerString returned MACROSILICON; feature length=9, usage page FF00. Factory B5 XDATA read protocol echo verified. F800 returns D7; consistent with the publicly researched MS2109-D7 family, not upstream A7. No B6/register writes, firmware patches, EEPROM writes or capture-card resets were executed. Host SetFeature carries a B5 read request, not a configuration write.

C71A raster record decoded as 1920x1080, total2200x1125, pixel148.35 MHz,60Hz,HS44,VS5, but was byte-identical with FPGA TX disabled. Treat it as retained/template state, NOT proof of current lock. An unrelated application's MS2109S RAM timing map produced implausible values on this firmware and was not used as measurement evidence.

Controlled FPGA TX on/off/on at unchanged physical wiring produced receiver-side transitions: FD9D 0D/0C/0D, FDA6 07/04/07, FD90 60/67/60; FDC3 33/00/55 and FDC4 77/44/77. FD9C stayed0D. Exact undocumented bit semantics remain unproven; observations demonstrate receiver sensitivity to output state, not valid video decoding. Restored main all-large1080p pure DVI diagnostic via 1MHz JTAG; capture remains uniform black.

Evidence: capture_device_audit/hid_metadata.json, chip_probe.json, tx_on_status_block.json, tx_off_status_block.json, tx_restored_status_block.json, on_off_difference.json, tx_restore_program.log, restored_capture.png. Source references: https://github.com/BertoldVdb/ms-tools ; https://github.com/NKTKLN/ms2109-d7-1024x600 ; https://github.com/TechxArtisanStudio/Openterface_QT/blob/main/video/ms2109s.h . Do not execute downloaded firmware utilities: only the locally written read_xdata.py B5-only helper was run.


## Read-only firmware-reference and camera-control audit

Analyzed public reference D7 ROM locally only. Function at 8021 returns FD9C bit0; reference callers cache it in C74B/C8D3. Actual C74B=0, C8D3=1 while hardware FD9C=0D, so reference scratch-RAM semantics are not sufficient for reliable live lock/mute interpretation. No firmware code or patches sent to device, no write opcodes. Do not use public firmware's writable offsets as a fix.

DirectShow IAMCameraControl GetRange for exposure(4), scan mode(7), privacy(8) returned 80070490 (not supported/not found); this interface does not expose a privacy switch to inspect. No Set calls executed. Current TX remains enabled; post_readonly_audit.png still black. Next high-information action is a capture-card-only USB power cycle while retaining board/HDMI wiring, then requery with B5 read-only helper; actual power removal is a physical operation, not achieved by closing ffmpeg.


## 15:56 Capture format isolation

With capture card present, tested advertised MJPEG 1920x1080 requested60fps and uncompressed YUY2 640x480 requested30fps without FPGA changes or HID accesses. Both opens completed and frames were saved. The MJPEG60 sample is uniform black; the first YUY2 sample shows the UGREEN logo, not source video. After about 13 seconds of capture, delayed YUY2 frame is uniform black. 640x480 is the USB output size only, not a change to FPGA HDMI timing. No source video has been observed in either mode; the first YUY2 logo alone is not proof of correct HDMI input. Capture modes and image extrema saved in capture_modes_20260915_155618. No device/driver changes.
