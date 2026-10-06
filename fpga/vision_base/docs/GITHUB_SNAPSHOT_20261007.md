# 2026-10-07 当前源码上传

这是 `F:/Project/fpga/vision_base` 的源码与精选验收记录快照。上传在独立 Git worktree 中进行；本地工程、网页服务和当前 SRAM 配置保持。

## 当前验证范围

- A1/A2：独立 Sobel/Canny 阈值、16 下限与步进、模式名和十进制 OSD；控制器仿真、板上协议写入、真实 OSD 像素和网页模式切换已核对。本轮人工实体按键动作待现场验证。
- A6：主机参考与生产 RTL 的空心圆/矩形合成正例、真实非目标回读一致性通过；空心轮廓实物正例待现场验证。
- X3：DDR 前四行灰度缓存的中值/Sobel支路、逐像素参考和板上 60 秒计数通过。1080p60 主 HDMI 仍走统一 DDR 帧池；整机直通待实施。
- AI：保留既有 Sapphire/FlyHash 固件。新分析 DMA、模型训练和 INT8 推理未在本轮实施。

最终原生构建：调试版 58759 XLR / 243 RAM / 50 DSP，WNS +0.128 ns；比赛候选 56669 / 238 / 50，WNS +0.130 ns，WHS 均 +0.026 ns，未分配 IO 0。调试版已有独立 SRAM 烧录记录；比赛候选尚未烧录。资料见 [实施报告](../results/ordered_implementation_20261007/REPORT.md)、[构建结果](../results/ordered_implementation_20261007/build_results.json)、[当前状态](../results/program_capture_20261003/current_state.json)。

板上测量：源约 30.0125 fps，控制流水 17 周期；中心像素支路延迟 25.798–126.545 μs，ISP 帧头至 HDMI 编码器输入首有效像素 38.069–54.757 ms。这不是传感器曝光或显示器光学延迟，也不是整机零延迟。

## 上传范围与构建依赖

上传 RTL、仿真、固件 C/汇编、主机工具、SoC 配置和精选报告。新增位流、ELF、厂商生成的 Sapphire netlist/CPU 块、工具链、工作目录、缓存、备份和整套图像画廊留在本机。仓库既有历史资料保持；上传没有新增厂商二进制或授权 IP 文件。

Sapphire 使用本机 Efinity 2026.1 官方生成器，netlist 在构建机器生成：

```powershell
# 在当前 checkout 的 fpga/vision_base 下；使用本机已有的普通 Python。
python scripts/build_vision_firmware.py
python scripts/generate_vision_soc.py --output-dir artifacts/vision_soc --cache-kb 2 --custom --boot-kb 4 --boot-hex artifacts/vision_soc/firmware/vision.hex
```

完整构建需要本机已安装的 Efinity 2026.1、RISC-V IDE/toolchain、Java 和供应商板级依赖。实际构建日志记录的顶层参数：`SAPPHIRE_ENABLE=1 RAW_TO_POOL=1 IMAGE_DEBUG=2`（调试），比赛版 `IMAGE_DEBUG=0`，P&R seed 1。源码默认参数保留原入口，默认构建不等于这两份已验证候选。

仓库 `synthesize.ps1`、`efinity_env.ps1`、`program_vision_sram.ps1` 保留已合入 main 的 Runner 版本；没有用本机较旧的控制脚本覆盖。上传不触发真实 Efinity 或硬件工作流，不自动合并 main。日志中的绝对路径是本机历史运行位置，不代表远程附件或自动下载入口。
