# Ti60F225I3 / SC431HAI 视觉工程

固定 1080p60 视频主链，ROI、内部工作图尺寸和后续分析任务独立配置。基础/高阶算法、RISC-V 与局部 AI 按 `PROJECT.md` 分阶段接入。

## 工程入口

在 Efinity 打开：

`F:/Project/fpga/vision_base/board/ti60f225_v4/ti60f225_oob.xml`

目标器件为 **Titanium / Ti60F225 / I3**，当前工具为 **Efinity 2026.1.132.3.9**。引脚和 PLL 来自 V4 供应商工程，尚待与到货 PCB、相机和转接板核对。

## 当前实现

| 部分 | 已实现内容 | 验证边界 |
|---|---|---|
| 摄像头板级基线 | CSI/RAW8 DDR 三帧缓存、去 Bayer、HDMI | Efinity 编译、接口、P&R、位流；尚未上板 |
| 彩条诊断 | 1920×1080 有效区、2200×1125 总时序、八色条、白边框、移动标记、帧活动 LED | 完整帧仿真及独立板级制品 |
| RGB565 帧引擎 | 四源 bank、多读者 lease、冻结/实时切换、ROI、2PPC 最近邻缩放、AXI128 读写、结果双缓冲与场消隐发布 | 行为存储逐像素回归；独立物理时序探针 |

新引擎已形成“取帧 → ROI/缩放 → 写回 → 结果描述符发布”的闭环，但摄像头位流仍走供应商 RAW 缓存路径。真实 RAW→RGB565 采集适配、DDR 多客户端仲裁和结果扫描 DMA 尚未接入；不会将片内 AXI 测试服务当作真实 DDR 带宽证据。

## 编译与制品

在 PowerShell 7 中执行：

```powershell
# 上板前准备的两个独立版本
& 'F:/Project/fpga/vision_base/scripts/synthesize.ps1' -Top board -Flow compile -VideoMode pattern
& 'F:/Project/fpga/vision_base/scripts/synthesize.ps1' -Top board -Flow compile -VideoMode camera

# 新帧引擎的物理时序检查，不连接真实DDR数据路径
& 'F:/Project/fpga/vision_base/scripts/synthesize.ps1' -Top board -Flow compile -VideoMode timing_probe
```

制品分别保存于 `artifacts/pattern/`、`artifacts/camera/` 和 `artifacts/timing_probe/`。每份 `manifest.json` 记录 bit/hex 摘要、源文件摘要、模式和最终时序；编译中源代码发生变化或最终 WNS/WHS 为负时，脚本判定失败。XML 的纯格式规范化不视为 RTL 变化。

编译运行综合、接口生成、布局布线和位流生成，不调用下载器。默认 `vision_board_config.vh` 为 camera；脚本正常结束时恢复进入前的配置。若外部强制终止导致配置遗留，应先检查该头文件，再启动下一次编译。`board/.../outflow` 为最近一次编译工作区，交付版本以模式目录为准。

## 仿真与独立综合

```powershell
& 'F:/Project/fpga/vision_base/scripts/verify.ps1' -Suite full
& 'F:/Project/fpga/vision_base/scripts/synthesize.ps1' -Top frame_render_engine -Flow map
```

统一入口包含 9 个 testbench：板级三帧切换、帧池、任务控制、完整彩条时序、AXI 写入器、AXI 行读取、缩放器、读缩放串接及完整帧引擎。覆盖奇数 ROI/尾像素、stride、4 KiB、背压、配置锁存、错误不发布、冻结/实时和场消隐边界。

完整帧引擎长案例逐像素验证三种 1920×1080 结果：1080p 1:1、1280×720 放大、960×540 ROI 放大。每个案例均检查 2,073,600 个实际写回像素。结果宽度须为 8 的倍数；底层 scaler 的奇数输出能力另行测试。

`results/verification.full.json` 与逐项日志记录当前结果及源代码摘要。直接行流测试中的随机延迟与 AXI 集成测试采用不同服务模型，其周期不应混用。帧率验收还需要实际内存服务与上板计数。

## 报告与下一步

- 本轮结果与精确周期/资源：`results/PREHARDWARE_REPORT.md`。
- 所有权、发布和内存布局：`docs/frame_engine.md`。
- 读取/缩放/写入接口：`docs/axi_memory.md`、`docs/scaler.md`、`docs/frame_writer.md`。
- 硬件到货后的步骤与 LED 定义：`docs/BOARD_BRINGUP.md`。
- 上板测量记录模板：`results/hardware_acceptance.template.json`。

先核对实物并验证彩条、DDR 校准与相机直通，再做真实 DDR 适配和 ROI/冻结联调；之后接入算法、RISC-V 与 AI。原始压缩包、回退备份与必要验收报告保留。
