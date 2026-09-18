# 硬件到货前交付报告 — 2026-09-08

## 结论与范围

本轮 RGB565 帧处理底座、主机闭环验证、板级诊断制品及真实 P&R 检查完成。统一 full suite 的 **9/9 testbench 通过**，三种全高清结果任务均逐像素核对 **2,073,600 pixels**；三个模式的 bit/hex 和报告文件摘要已核对，当前 RTL 与验收记录相符。

已生成的三份板级制品均通过 map/interface/pnr/pgm、最终 setup/hold 时序和未分配核心引脚检查。没有执行硬件编程。该结论不包含尚未接入的真实 DDR 多客户端仲裁、RAW→RGB565 采集适配、结果扫描 DMA、基础/高阶算法、RISC-V 或 AI。

## 交付内容

- `rtl/frame_render_engine.sv`：帧池、任务调度、AXI ROI 读取/2PPC 最近邻缩放与结果写回串接。
- `rtl/frame_render_control.sv`：冻结/实时取最新源帧、独立分析 lease、结果双缓冲、场消隐原子发布、周期统计和 deadline 计数。
- `rtl/axi_frame_writer.sv`：2PPC RGB565 → AXI128，行 stride/4 KiB/背压，最后一个 B 响应后才完成。
- `rtl/video_test_pattern.sv`：固定 1080p60 色条、白边和移动标记；配套板级 LED 活动指示。
- `rtl/frame_engine_timing_probe.sv`：用于物理时序验证的片内 AXI 数据发生/校验服务，不替代实际 DDR。
- `scripts/verify.ps1`、`scripts/synthesize.ps1`：统一仿真和编译；输入稳定性与产物摘要记录；最终时序失败直接判为失败。

默认帧内存规划为四个 4 MiB 源 bank + 两个 4 MiB 结果 bank，共 24 MiB。源帧实际格式和 DDR 地址容量仍需与真实采集适配器一致。结果宽度要求 8 pixels 对齐，源 ROI 可奇数；显示描述符包含 base、frame/config ID、width/height/stride。

## 全高清闭环周期

时钟预算为 100 MHz 下 1,666,667 cycles/frame（16.667 ms）。本表来自 `tb_frame_render_engine` 的受控 AXI 服务模型：AR/AW/W 有确定背压，R 带间隙，B 延迟 9 周期；不是上板 FPS 测量。

| 源/ROI → 结果 | 完整任务周期 | 按 100 MHz 换算 | 模型帧预算 |
|---|---:|---:|---|
| 1280×720 → 1920×1080 | 1,039,655 | 10.397 ms | 通过 |
| 1920×1080 → 1920×1080 | 1,046,902 | 10.469 ms | 通过 |
| 960×540 ROI → 1920×1080 | 1,039,496 | 10.395 ms | 通过 |

每个周期数覆盖 ROI 读取、缩放、写入及最后 B 响应，而非只统计输出 valid。源 lease、错误不发布与 vblank 描述符发布另有定向测试。

直接行流压力模型 `tb_roi_scaler` 的三个案例分别为 3,461,340 / 1,944,505 / 1,474,264 cycles；前两项超过帧预算。这组测试刻意限制输入供给并对输出施加背压，用于正确性检查，与上表不是同一内存服务模型。实际 DDR 也必须提供足够的持续服务；2PPC 本身不保证任意背压下的 60 fps。

## 最终实际 P&R

工具 Efinity 2026.1.132.3.9，器件 Ti60F225/I3，保持原时钟目标与 SDC；没有降低 100 MHz 处理时钟或用新增 false path 隐藏新逻辑。

| 模式 | XLR | Memory blocks | DSP | 最终 WNS | 最终 WHS |
|---|---:|---:|---:|---:|---:|
| camera | 28424 / 60800 | 89 / 256 | 4 / 160 | +0.461 ns | +0.027 ns |
| pattern | 16080 / 60800 | 84 / 256 | 0 / 160 | +0.497 ns | +0.026 ns |
| timing_probe | 20074 / 60800 | 114 / 256 | 6 / 160 | +0.409 ns | +0.026 ns |

三份报告的 Unassigned Core Pins 均为 0；Missing Interface Pins 均保留在各自原始报告中核查，非自动忽略必要板级接口。

`timing_probe` 用 1920×1080 结果画布、4096-byte 源 stride 和可变源/ROI 配置族做物理实现，core_clk 分析上限为 126.215 MHz，实际约束仍为 100 MHz。该模式会优化未使用的相机显示分支，其资源数不是“相机 + 新 DDR 帧引擎 + 全部算法”的整机资源承诺。

完整动态参数 `frame_render_engine` 独立 map 通过：LUT4=3,947、FF=2,539、DSP48=22、RAM10=14、DPRAM10=16。独立 map 与板级 P&R 的配置、优化边界不同，不直接相加推算最终资源。

## 本轮发现并修复的具体问题

1. 双口行缓存地址/使能结构不匹配 Efinity 提取模板，导致 RAM 展开；改为每物理端口共享地址与无复位同步读，最终推断为 DPRAM。
2. AXI ARLEN 依赖 FIFO 可用量，背压时会变化；改为只由请求游标、最大 burst 和 4 KiB 边界决定，RREADY 负责 FIFO 反压。
3. look-ahead word 提升时错误弹出 FIFO；修正 pop 的真实消费条件。
4. 行末判断了当前 bank 而非已预取的对侧 bank，导致重复加载正在读取的缓存；修正判断并添加读写 bank 排他断言。
5. writer 非最终 burst 的 B 响应后停留在等待状态；修正为继续规划后续 burst。
6. 帧池串行 32-bit 最值比较造成实际 P&R WNS −0.352 ns；改为并行比较与 one-hot 选择，保留原握手和排序语义，最终时序如上表。

失败样本、关键时序反例及回退源码保留在 `backups/prehardware_20260908/`。可重生成的本轮仿真可执行临时文件已清理；交付物和必要验收日志保留。

## 制品与复现

- 先用于 HDMI 连接/颜色/边框检查：`artifacts/pattern/ti60f225_oob.bit`。
- 再用于相机/DDR 直通基线：`artifacts/camera/ti60f225_oob.bit`。
- 新引擎时序检查：`artifacts/timing_probe/ti60f225_oob.bit`。
- 每个目录的 `manifest.json` 记录实际制品 SHA-256、编译输入摘要和模式。
- 功能验收：`results/verification.full.json`；汇总：`results/prehardware_acceptance.json`。

```powershell
& ./scripts/verify.ps1 -Suite full
& ./scripts/synthesize.ps1 -Top board -Flow compile -VideoMode pattern
& ./scripts/synthesize.ps1 -Top board -Flow compile -VideoMode camera
& ./scripts/synthesize.ps1 -Top board -Flow compile -VideoMode timing_probe
```

## 到货后继续的具体工作

1. 核对 PCB、相机、FPC/转接板及引脚；先用 pattern，再验证 camera 的 DDR 校准、颜色、真实采集尺寸/帧率和稳定性。
2. 确认真实外设工作点后，将采集格式适配、DDR 仲裁与显示扫描接入 RGB565 帧引擎，实测 ROI、冻结、无撕裂及 DDR 带宽。
3. 再按 `PROJECT.md` 接基础/高阶算法、RISC-V 和 AI；本轮不将这些后续项计入完成。

上板记录模板为 `results/hardware_acceptance.template.json`，所有未测物理指标保留 null。
