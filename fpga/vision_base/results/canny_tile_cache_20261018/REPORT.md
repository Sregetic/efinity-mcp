# 2026-10-18 Canny 弱瓦片状态缓存等价优化

## 实际结果

已完成弱瓦片状态缓存、逐周期等价回归、整机原生 map/interface/P&R/pgm，以及制品源文件/最终时序门禁。**相对上一候选净释放 888 XLR，RAM 增加 2 块，没有释放 RAM。** 完整功能和原图/各模式回读保留；本轮未访问板卡、未写 SRAM/Flash。

|项目|上一候选：中值第二轮|本轮候选|变化|
|---|---:|---:|---:|
|XLR|58268 / 60800|57380 / 60800|净释放 888|
|XLR 占用|95.84%|94.38%|已低于 95%|
|空余 XLR|2532|3420|增加 888|
|RAM|235 / 256|237 / 256|增加 2；余 19|
|DSP|62 / 160|62 / 160|保持；余 98|
|最终 WNS|+0.152ns|+0.211ns|通过|
|最终 WHS|+0.026ns|+0.026ns|通过|
|未分配核心引脚|0|0|保持|

相对 10-17 已固化的 60050 XLR / 235 RAM / 62 DSP，累计释放 2670 XLR、增加 2 RAM。当前部署仍记为固化版，本轮候选尚未上板。

层级报告中 `canny/hyst` 从 4376.5 降到 3585.5 XLR，局部净省 791；剩余 97 是其他层级重综合/打包的净差。整机净省按 888 记，不用局部数字替代整机结果。RAM 自占用唯一变化的层级是 `canny/hyst`：0→2，两个边缘平面仍各 16、分类图仍 32；`image_debug.image_snapshot` 仍为 5 RAM。

## 实现范围

172 项原生输入只变化 `board/ti60f225_v4/rtl/vision/vision_hysteresis_sweep.sv`，新增仿真文件不在原生输入内。原来的 30×17=510bit 弱瓦片图及组合读选择器改为同步块 RAM；Efinity 实际映射为 2 块 RAM。

- 用 17bit 行有效图在原清空时刻整体失效，首写忽略旧 RAM 内容；没有增加全表清零等待。
- 单拍待写缓存及读写冲突转发，保持每拍一个分类输入，覆盖同一行连续写、跨行连续写、输入空隙及最后一个弱像素。
- 与原分类图扫描预取同时读取下一中心所在瓦片行；扫描和采集均不增加时钟，正反扫描及发布时刻保持。
- 保留弱图的保守语义：像素被晋升后不清瓦片标志，和原实现一致。没有调整阈值、减少扫描轮次或删掉小分量过滤。

相机/profile、色调和自动曝光、公共中值、Sobel/Canny 阈值、噪声规则、480×270 检测、斜线/转角/四边重建、双采样和 M6 混合均保持。CPU/固件/AI、ROI、帧池/DDR/CDC、六帧历史/冻结、识别、按键、帧边界提交和图像回读源码保持。时钟与 SDC 未变。

永久回归新增 `sim/vision/tb_weak_tiles.sv`，保存优化前 RTL 为仅仿真 reference，并注册到既有 `scripts/verify_vision_features.ps1`；fixture 与保存的优化前源码逐字比对，只有模块名和说明行不同。

## 等价与调用链验证

四种尺寸 8×4、48×32、37×19、480×270 的新旧 RTL 同步驱动，共检查 **3049668 个时钟、851299 次瓦片决策、2031116 个有效显示像素、896bit 回读，差异 0**。逐周期比较状态、坐标、邻居、方向、前后平面、capture/ready/busy、帧数、故障、处理周期/轮次/弱访问计数、显示/历史像素和 probe 握手/数据；不只比较最后图像。

每种尺寸四帧覆盖：连续分类写入、瓦片边界、末样本弱像素、下一帧全空、列优先跨行乱序写、带空隙输入、discard 不发布、前平面回读与历史读口。单瓦片行检查最终写入与首扫描预取冲突；37×19 检查不完整瓦片；生产尺寸检查全部 30×17 瓦片。

生产尺寸有弱像素的三帧均为 553084 个处理时钟、2 轮、16855 次弱访问；空帧 137702 时钟。新旧值及发布时刻逐周期一致，没有以降低处理率换面积。

独立参考和整链回归也通过：

- `hysteresis_random`：100 张随机图、19200 像素，独立 flood 参考。
- `hysteresis_sweep`：非复用模式、长链/斜链、孤立弱点、下一帧清空。
- `edge_components`：54 张图、41472 像素，MIN31 删除/MIN32 保留、细线/斜线/尾部及随机连通分量。
- `edge_probe`：1536bit 回读、2304 个有效显示像素和历史口检查，后台写不破坏前平面。
- `canny_noise`：完整 RGB/面积归约/中值/自适应/NMS/滞后/小分量链路 36864 像素；平坦噪声、细线及噪声突增保持/重试。
- `hysteresis_scene`：现有实拍分类输入与独立边缘参考，259200 像素；实拍帧 1900641 时钟、34 轮，下一空帧 137702 时钟。

详细计数与各项日志见 `verification.json`。以上为 RTL 仿真及实拍文件回归，不是新导出的板上图像。

## 原生构建与交付

构建使用现有 SC431HAI 中心 1080p30 四 lane profile，完整工程和图像回读开启。四阶段全部通过，最终 WNS/WHS 非负、未分配核心引脚为 0，`program_vision_sram.ps1 -ValidateOnly` 通过且没有硬件编程。`build_input_diff.json` 确认只有上述一个原生 RTL 输入变化。

```powershell
Set-Location F:/Project/fpga/vision_base
./scripts/synthesize.ps1 -Top board -Flow compile -VideoMode camera -Sensor sc431hai -SensorProfile F:/Project/fpga/vision_base/board/ti60f225_v4/sensors/sc431hai_1080p30_center_4lane.json -TimeoutSeconds 2400
./scripts/program_vision_sram.ps1 -ValidateOnly -VideoMode camera -Sensor sc431hai
```

候选交付：`F:/Project/fpga/vision_base/results/canny_tile_cache_20261018/release/ti60f225_oob.bit`。默认 `artifacts/camera/` 同步发布此候选；上一候选和固化版的独立交付均保留。

证据包括 `resources.json`、`acceptance.json`、`compile.json`、`compile.log`、`board.hier_util.rpt`、路由/时序报告、前后 RTL/manifest、`rtl.diff` 和仿真日志。临时 `.vvp` 已清理。

本轮未写 SRAM/Flash、未重新导出板上图片；当前固化仍为 10-17 sample_pass。候选现场画面、长期紫闪稳定性和实际断电验收仍待上板，不计作本轮已通过。
