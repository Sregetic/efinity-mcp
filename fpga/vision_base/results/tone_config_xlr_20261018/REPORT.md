# 2026-10-18 色调配置算术等价优化

## 实际结果

本轮在上一版 Canny 弱瓦片缓存基础上优化色调配置计算，完成仿真、完整原生构建和制品门禁。**整机再释放 383 XLR，RAM/DSP 保持。** 本轮未访问硬件、未写 SRAM/Flash。

|项目|上一候选：弱瓦片缓存|本轮色调候选|本轮变化|
|---|---:|---:|---:|
|XLR|57380 / 60800|56997 / 60800|净释放 383|
|XLR 占用|94.38%|93.75%|下降|
|空余 XLR|3420|3803|增加 383|
|RAM|237 / 256|237 / 256|保持，余 19|
|DSP|62 / 160|62 / 160|保持，余 98|
|最终 WNS|+0.211ns|+0.254ns|通过|
|最终 WHS|+0.026ns|+0.026ns|通过|
|未分配核心引脚|0|0|保持|

色调模块本身由 1823 降到 1443 XLR，省 380；其他层级重综合/打包净省 3，整机净省 383。色调模块仍为 1 RAM、6 DSP；所有层级节点的 RAM/DSP 自占用均与上一候选一致。

相对 10-17 固化版 60050 XLR / 235 RAM / 62 DSP，累计释放 3053 XLR、增加 2 RAM；这两块 RAM 来自上一轮弱瓦片缓存，本轮没有增加。当前板上固化仍为 10-17 sample_pass，本轮为未部署候选。

## 最小实现与数学依据

172 项原生输入仅变化 `board/ti60f225_v4/rtl/vision/rgb_chroma_tone.sv`，差异只在 `thresholds()`。保留每路每拍更新 8 个 clip 和 8 个 light 阈值的接口，不增加跨拍调度或等待。

1. 共用 `3g/5g/7g/9g/11g/13g` 移位加法项。clip 系数仍为 223、225、…、237，light 系数仍为 144、152、…、200。
2. 原饱和条件 `C*g > 65280` 等价为 `g > floor(65280/C)`。系数为展开时常量；用增益常量比较代替每个乘积的宽位饱和检查。
3. 未饱和时乘积至多 65280，结果只取 `[15:8]`；饱和时仍返回 9bit 哨兵 256。因此中间乘积可以保留低 16bit，溢出部分始终被原有饱和语义排除。`gain==0` 及 `gain>453` 的完整 16bit 行为保持。

原来的像素流水、阈值寄存时刻、舍入/饱和结果、黑色/高光去偏色、正常/弱光增益 ROM、shadow 同步和冻结保持逻辑均未变化。白平衡默认值及相机帧边界提交、传感器配置和自动曝光也保持。

上一轮 Canny 缓存、检测/平滑重建和全部 CPU/固件/AI、ROI、帧池/DDR/CDC、历史/冻结、识别、按键、原图/模式回读源码保持；`image_debug.image_snapshot` 仍占 5 RAM。没有借用关闭功能获得面积收益，时钟和 SDC 保持。

## 验证

- `chroma_thresholds`：逐路穷举完整 65536 个 16bit 增益，对照独立原始整数公式，**3145728 个阈值检查，差异 0**；每拍变化仍一拍更新。
- 新增 `tone_equivalence`：真实旧 RTL 与新 RTL **181768 个时钟、172369 个有效输出像素，差异 0**。包括每通道 116224 组有效区增益/像素输入、65536 步全范围增益、20 个复位时钟、连续参数变化、两种曲线、冻结/恢复和 HS/VS/DE/流水对齐；同时核对所有阈值寄存器及 alpha 阶段。
- `chroma_tone` 和 `chroma_shadow`：各 800 个独立公式参考样本，高光去偏色、饱和蓝色、黑色、正常/弱光曲线及同步时序通过。
- `chroma_singleclip`：实测单通道裁切高光去偏色，饱和蓝/绿物体、中间调及黑色保持。
- `tone_freeze`：20 个冻结帧维持既有 shadow 曲线，恢复实时后在 VS 更新。
- 既有 Gamma/色调集成：3 种曲线 × 8/10bit 共 6 项，160326 次比较通过；其中 8bit 检查覆盖四种色调菜单和既有 legacy 延迟路径。

旧 RTL 保存为仅仿真 `sim/vision/rgb_chroma_tone_reference.sv`，内容与优化前备份相同，仅模块名和说明行不同；不在原生输入中。新增逐周期夹具已注册到既有 `scripts/verify_vision_features.ps1`。详见 `verification.json` 和各项日志；Gamma 子目录保留相应独立参考结果。

## 原生构建与交付

使用现有 SC431HAI 中心 1080p30 四 lane profile；map/interface/P&R/位流生成四阶段全部通过。最终制品源/时序门禁通过，172 项输入只有色调 RTL 变化。构建命令：

```powershell
Set-Location F:/Project/fpga/vision_base
./scripts/synthesize.ps1 -Top board -Flow compile -VideoMode camera -Sensor sc431hai -SensorProfile F:/Project/fpga/vision_base/board/ti60f225_v4/sensors/sc431hai_1080p30_center_4lane.json -TimeoutSeconds 2400
./scripts/program_vision_sram.ps1 -ValidateOnly -VideoMode camera -Sensor sc431hai
```

交付位流：`F:/Project/fpga/vision_base/results/tone_config_xlr_20261018/release/ti60f225_oob.bit`。默认 `artifacts/camera/` 已同步此候选，上一候选的独立交付保留。

`resources.json` 为整机/局部资源与基线对比；`acceptance.json` 区分仿真、原生实现和物理验收；`compile.json`、原生报告、输入差异、前后源码/manifest、`rtl.diff` 及日志均已归档。临时 `.vvp` 已清理。

本轮未写 SRAM/Flash、未新导出板上图像；当前显示和固化保持。新候选现场画面、长时稳定和实际断电验收尚未复验。
