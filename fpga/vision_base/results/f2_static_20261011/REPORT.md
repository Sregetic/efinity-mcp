# F2静态历史浏览修复与上板验证

日期：2026-10-11。屏幕F2是历史浏览，不是总目标表中编号F2的连接组方法。完整系统范围保持。

## 结论与操作

修复已写入SRAM并通过真实帧号、像素与控制固件联调。F2默认I0，I0–I5分别静态显示六张受保护历史帧；I0最新，I5最旧。I6显式启用原有自动回放，不是第七张历史帧。

正常菜单中，F0下KEY3长按到F1，再长按到F2/I0。KEY2短按按0→1→2→3→4→5→6→0切换，KEY3反向。I6下KEY3短按回I5或KEY2短按回I0，立即选择静态历史帧；KEY3长按进入F3相邻帧交替比较，KEY2长按回F0。长按约1秒后松开，短按约0.2秒后松开。

I6保留原自动计时相位；进入I6时按当前循环相位继续，不承诺从最新帧开始，也不是暂停后保持上一个播放位置。静态查看选择I0–I5。

## 根因与最小完整改动

原统一帧池F2选择公式始终把`play`加到`history_index`，60Hz显示每30个vblank推进一次，所有索引都在循环。按键只改循环起点。这不是此次已证明的按键抖动或历史覆盖故障。

在统一帧池和旧DDR历史分支中，仅I6贡献`play`偏移，I0–I5贡献0；保留原计时器、模历史数选址、帧持有和scratch采集保护。控制固件与无CPU分支允许F2索引0–6，F3仍0–5；CLI、面板说明、RV32I策略/RTL/板上测试同步更新。没有增加帧数组、RAM端口或控制结构字段。F1冻结、F3比较、全部图像模式、分析DMA和AI路径保留。

原容量接近上限，若干布局候选未通过路由，均未安装。最终将扫描与ROI读FIFO由16缩为8个AXI beat，复用既有RREADY背压，突发长度/DDR仲裁/时钟/引脚不变。相应FIFO8满幅仿真和真实ROI复测已完成；这是为本次物理构建腾挪的内部FIFO，不是减少历史帧数量。

## 实测资源与制品

|项目|前次发布|本次发布|变化|
|---|---:|---:|---:|
|XLR|60082/60800|60400/60800|+318，余400|
|RAM|252/256|252/256|0，余4|
|DSP|59/160|59/160|0，余101|
|最终WNS|+0.077ns|+0.015ns|最终时序通过|
|最终WHS|+0.026ns|+0.026ns|保持|

本次不是净资源释放。无新增片上帧RAM，但实际整机XLR增加318。原生Efinity2026.1、TIMING_3/seed5完成map/interface/P&R/bitstream，未分配核心引脚0；XML中早期负时序值不是最终结果。证据：`native_compile.json`、`resources.json`和`fifo8_compile.log`。

当前位流：`F:/Project/fpga/vision_base/artifacts/camera/ti60f225_oob.bit`，发布拷贝在本目录`release/`。内嵌8KB启动ROM文本6240B，完整DDR应用18768B（原18740B，+28B），权重4400B保持。`app_load/result.json`记录USER1实际字节核对与恢复执行；不是Flash自主加载证据。

## 验证层次

### 离线逻辑与固件

- 新静态测试在旧RTL失败（`red.run.log`），修复后逐周期通过（`green.run.log`）；覆盖130048个扫描像素、181次静态刷新、I6六帧/相位继续、F3比较、F2同源ROI重渲染、F1冻结与实时恢复。
- 旧DDR历史分支、无CPU实体消抖/短长按、RV32I/QEMU控制策略通过，日志分别为`history.run.log`、`controls.run.log`、`control.run.log`。
- 最终FIFO8完整核心套件19项通过，包含1080p系统共享DDR/渲染/扫描、CPU/多个AXI客户端、4KiB边界和读写故障；系统源/扫描2074112像素，渲染1059470cycles、deadline0。这是行为DDR仿真，不替代板上带宽测量。见`full_verification.json`、`full_fifo8.log`。
- 视频算法与UI套件32项通过，AI三输入自检及损坏权重FAIL路径通过；模型、Canny和A6算法没有修改。根仓库适配器71项通过、1项Windows符号链接权限跳过；适配器未编辑。

### 真实板上，非采集卡/HDMI目视

1. `board_history/runtime_checks.json`通过。F2/I0连续60次采样、12.721秒保持源8388；按相同事件FIFO逐张选择I0–I5得到8388/8387/8386/8385/8384/8383，六帧不同。I6在4.933秒访问全部六帧；KEY3短按回I5后3.672秒保持8383。F3继续交替8388/8387。八模式、阈值、中值、实时/F1与Canny持续发布通过。
2. `board_keys/result.json`：17项控制/ROI场景通过，冻结源11204在缩放、平移、输出尺寸/位置变化后保持；验证的是实体按键同一事件队列及真实CPU/DDR路径，非人工电气按压。过渡中ROI deadline计数2，未写成全计数0。
3. `static_pixels/result.json`：F2/I3、CAMERA、MED1，第540行两次真实显示行RAM读取，源13865/config0均一致；间隔10.235秒，1920×RGB=5760字节，差异0。原始行`row0.bin`/`row1.bin`和复现脚本`read_static_line.py`保留。不是屏幕拍摄，也不是软件重画。
4. `stream_60s.json`：59.641秒源29.9794fps、每帧2073600像素；RAW overflow、采集discard与scan_bad均无增长。X3仍17cycles，语义25.8–126.5µs，整机显示延迟探针保持关闭。
5. `roi_fifo8/board.verification.json`：满幅/2×ROI分别58.016/59.515秒，采集1741/1784帧，源discard/scan_bad增量0；冻结源25213四次重渲染保持。**ROI性能不是全部通过**：满幅渲染约51–56ms，2×约21ms；两段live的deadline分别增长870/1784，仍存在既有实时ROI截止不足。相机约30fps与渲染刷新率分别记录。本次未作旧FIFO16对照，不归因这些数字为改善或退化。

## Flash部署

用户明确批准“验证通过后固化到Flash”，已完成：

- 写入前保存完整8MiB旧Flash：`F:/Project/fpga/vision_base/results/f2_static_20261011/flash_app/flash_before.bin`。这是原配置和原应用的完整备份，保留本机，未上传GitHub。
- 原有`program_vision_boot_flash.ps1`将新版应用/权重包23200B写入0x700000，只擦除对应24KiB区域，实际读回全部字节一致。见`flash_app/result.json`、`write.log`、`read_after.log`。
- 官方JTAG bridge将新版配置写入0地址，只擦除对应1060KiB，官方Flash验证成功、写保护恢复。见`flash_config/result.json`、`write.log`。应用及配置写入首轮官方验证均出现mismatch，官方工具按既有流程使用max clk重试后成功；完整日志保留，没有删掉失败记录或把首轮算通过。
- 完成后用同版位流通过JTAG重新配置SRAM，未用USER1下载应用。ROM自主从SPI Flash将18768B应用和4400B权重复制到DDR，BOOT7、JEDEC EF6017、CPU1；`verify_vision_boot.py`实际读取全部程序/权重字节，与当前ELF和模型一致。见`autoboot/result.json`、`read.log`；USER1只halt/read/resume。

**上述自主加载证明的是CPU应用/权重从Flash启动**；配置Flash写入已验证，但FPGA自身经主SPI加载配置、真实拔电/拔JTAG启动尚未实测。没有把JTAG SRAM重新配置当成物理断电验收。

### 固化后启动异常与KEY1实测

首轮`post_flash`复测在live检查报`Live counters stalled`：源4969→5014在增长、历史6帧，但显示0、source checksum0；CPU已经执行新版Flash应用。保存`post_flash/live.json`、`post_flash_failure_roi.json`，没有把自主程序加载通过记为显示启动通过。同版再次JTAG重新配置、未执行USER1读回时，CSI仍收到3458帧/正常几何，但统一RAW帧池capture/display为0；保存`post_flash_reconfigure_*`及`post_reconfigure_page13.json`。因此没有证据将首轮异常只归因于USER1暂停，也未归因于I6逻辑或模型。

用户按要求真实短按KEY1后，ROI显示帧592、frame_ok1、scan_bad0，随后的采集/显示648→691且始终相等，六帧历史有效；没有重下载程序或替换位流。见`after_key1_roi.json`、`after_key1_live.json`。KEY1恢复是已实测结果，JTAG热重新配置的启动异常根因仍未归属，保持独立待办，不将复位恢复称为永久修复。复位后的F2与实时复测结果在`post_key1/`保存。

`post_key1/runtime_checks.json`最终通过全部八模式、实时/F1、F2静态/六帧/I6启动及停止/F3与Canny持续发布。复位后F2/I0源1452在60次、12.686秒采样中不变；六张分别1452到1447，I6在4.948秒访问全部六帧，停止后3.659秒保持1447。此时实际运行的是Flash自主加载的新版应用，而非USER1临时程序。最终恢复M0/CAMERA、MED1、F0、正常菜单/I0、Sobel128/Canny80、SHAPE32、AI FIX、全幅ROI关闭，真实显示源3115、frame_ok1、scan_bad0；见`final_flash_restored.json`。

## 保存的失败候选

首版额外重置/门控计时器候选、seed9、CONGESTION_3和保留16-beat FIFO的门控候选出现路由不收敛或物理XLR超限（例如60959/60800），相关compile日志/JSON保留。本次没有安装失败候选，也没有通过降低时钟或删除图像回读/AI/历史功能使构建通过。

## 复现入口

在`F:/Project/fpga/vision_base`，使用PowerShell7、本机Efinity2026.1/官方Sapphire与RISC-V工具链。硬件操作按同一FTDI URL串行执行。应用Flash脚本需使用新的输出目录，以保留旧Flash备份。

```powershell
$py='C:/Users/Sregetic/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $py -E -X utf8 scripts/build_vision_firmware.py --boot-kb 8 --output-dir results/f2_static_20261011/boot_firmware
& $py -E -X utf8 scripts/generate_vision_soc.py --output-dir artifacts/vision_soc --custom --cache-kb 2 --boot-kb 8 --boot-hex results/f2_static_20261011/boot_firmware/vision.hex
& $py -E -X utf8 scripts/build_vision_firmware.py --load-method user1 --main firmware/vision/ai_main.c --mulhi-cfu
./scripts/verify_vision_features.ps1
./scripts/verify.ps1 -Suite full
./scripts/synthesize.ps1 -Top board -Flow compile -TimeoutSeconds 3600
./scripts/program_vision_sram.ps1 -Url 'ftdi://0x0403:0x6011:4:9/2' -BootOnly
```

`verify_hdmi_runtime.ps1`检查真实F2静态帧号/六帧/I6停止/F3/模式；`test_key_ui_board.py`检查固件按键事件与ROI。`program_vision_boot_flash.ps1`是现有0x700000应用包备份/写入/读回入口；配置位流仍使用官方JTAG bridge及`ftdi_program.py --jtag_bridge_mode all --verify_method onchipx1 --address 0`，不是整片擦除。自主程序加载用`verify_vision_boot.py`只读DDR实际字节核对，其USER1动作只halt/read/resume，没有程序下载或CPU reset。

## 验收边界

KEY1真实复位已由用户操作并由板上计数核对。F2的KEY2/KEY3电气按压、真实HDMI目视、实际拔电并拔JTAG的独立上电仍待现场确认。紫色闪烁、原图噪声、空心卡实物准确率、FOMO实时RGB闭环是不同问题，本次F2证据不替代其验收。JTAG热重新配置启动异常、ROI deadline不足及仅400XLR/4RAM余量保留为工程待办。
