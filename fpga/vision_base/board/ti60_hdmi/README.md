# HQ12 HD-SDI → HDMI 完整视觉工程

最新配置、菜单与完整应用已固化，回执见 `../../results/hdmi_finalize_20261101/flash/`。物理CONFIG/断电后的现场确认仍按项目总状态记录。

本工程用 HQ12 的 HDMI 输入代替原 SC431HAI/CSI 前端，复用原 DDR 帧池、ROI、菜单、M0–M6、M7、跟随与独立 FOMO。当前只接收已实测的 **1920×1080、约30Hz、YCbCr444、BT.709 limited**；输出仍使用独立1080p60时钟，显示刷新率不是识别速度。HQ12发送的AVI VIC=4与实测尺寸不符，不用于决定画幅。

原摄像头工程完整备份：`../../backups/camera_before_hq12_20261101/camera_source_and_releases.zip`。当前SDI工程的源表已剔除CSI、Bayer、FOV、sensor I2C和AE共32条前端源；从 `../ti60f225_v4` 引用的是共享后级，不是把原摄像头链保留在当前设计中。不要删除共享后级目录。

## 构建和临时加载

从项目根目录执行：

```powershell
& ./board/ti60_hdmi/build.ps1
```

脚本调用原生 interface → map → P&R → bitstream，并检查最终setup/hold与核心引脚分配。接收器复用 `../hdmi_input_test/vendor` 的供应商明文源；不是另做一套HDMI解码器。RX占PLL_TR0，DDR移至空出的BR0，其他后级时钟保持。源时钟中断只中止当前采集，不复位CPU或显示。

GitHub 源码不附第三方接收器源码或厂商生成的 Sapphire 网表。干净检出先准备 `../hdmi_input_test/vendor/source/hdmi_src/dvi_rx/` 的14个工程引用文件，并用已安装官方工具运行 `scripts/generate_vision_soc.py` 生成 `artifacts/vision_soc/hardware/netlist/VisionSapphire.v`。前者沿用本机参考目录，文件清单见工程 XML 的 `design_file`；本机现有这两个依赖不因仓库清理而删除。CPU/菜单/跟随离线测试不需要这些接收器文件。

成套的 `vision_hdmi.bit`、原生 `vision_hdmi.route.rpt.xml`、`vision.elf` 放在同一release目录后：

```powershell
& ./board/ti60_hdmi/load_sram.ps1 `
  -Url 'ftdi://0x0403:0x6011:4:b/2' `
  -ReleaseDir ./results/hdmi_finalize_20261101/release `
  -OutputDir ./results/hdmi_finalize_20261101/deploy_example
```

USB地址重插后需用厂商 `ftdi_program.py --list_usb` 重新枚举。此入口仅写FPGA SRAM和应用DDR；等待旧Flash应用自主启动后，用已验证的1MHz/1KiB USER1事务加载当前无BASE应用，实际字节读回一致才执行。此入口不写Flash；CONFIG/断电加载当时Flash中的版本。

## 成套Flash固化与恢复

基础运行、完整P&R和时序通过后，用已验证release目录：

```powershell
& ./board/ti60_hdmi/program_flash.ps1 `
  -Url 'ftdi://0x0403:0x6011:4:b/2' `
  -ReleaseDir ./results/hdmi_finalize_20261101/release `
  -OutputDir ./results/hdmi_finalize_20261101/flash
```

先备份整片8MiB Flash，再写0x700000应用包和0地址配置/菜单，执行厂商实际读回；然后只重载配置，验证ROM自主加载的完整DDR应用字节，没有USER1补载程序。新应用不需要BASE外部权重。实际断电重启或CONFIG仍需现场确认。

若确实需要恢复此次固化前的完整Flash，使用同目录的`restore_flash.ps1 -Url ... -BackupDir <上述OutputDir>`，完成后按CONFIG启动备份。每次固化使用新的OutputDir，不要覆盖`flash_before.bin`。

## 使用

接线：摄像头SDI → HQ12 → HDMI IN；Ti60 HDMI OUT → 显示器。

- KEY1打开/返回/关闭菜单；KEY2/KEY3上下，KEY0进入/确认。
- 图像→显示模式切原图、灰度、Sobel/Canny及叠加。
- 视图中的六个数值进入编辑后，KEY2/3调到哪画面立即变到哪；KEY0完成或KEY1返回都保留结果。
- 智能→模型→M7几何，推理模式→自动；人脸仍关闭，圆/矩形/印刷字母算法未改。独立FOMO保持。
- 目标→一键居中选目标；持续跟随和三秒轨迹沿用原开关，默认关闭。
- HQ12画面已由外部相机成像，默认增益unity、tone0、RGB顺序0。相机曝光和白平衡在外部相机设置，不通过HDMI或原sensor I2C调节；CLI明确拒绝这些无效写入。

诊断：`scripts/vision_control.py --sensor hq12 --page 34` 返回输入锁定、格式、源帧、溢出；原page33采集握手保留。RGB24源码/显示回读入口保持。

## 自动验证

`tb_frontend.sv` 覆盖整行FIFO绕回、像素顺序、短行中止、输入时钟消失/重锁、格式失效/恢复；1920宽运行76800像素通过。`scripts/test_hdmi_control.py` 覆盖输入状态解码、HDMI不支持的相机控制拒绝、原相机曝光调用仍可用，以及诊断地址不重复。CSC复用原已过20000定点向量的供应商实现。

整机最终资源、运行证据和现场待验项见 `../../results/hdmi_finalize_20261101/REPORT.md`；接收小测试的1929XLR不是整机资源。
