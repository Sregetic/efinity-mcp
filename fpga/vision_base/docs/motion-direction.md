# Ti60F225 普通运动方向识别

这是接入真实 Flyvis 之前、2026-10-19 完成上板的普通运动算法版本。没有 Flyvis 神经网络、神经元动态或果蝇大脑连接组模型参数。功能为左右上下、静止和未知的运动状态判断，以及 HDMI 活动区域与方向显示。

## 算法和显示

灰度像素流按 12×12 网格，每格取 8×8 个采样求均值。相邻观测形成正负亮度变化（ON/OFF），用相邻格点的时延相关差求水平、垂直响应。变化阈值为 8 灰度级，方向响应下限为 256，主轴至少满足次轴的 3:2。这些是固定规则，不需要下载或训练模型。

M7 显示区域中 RAW 是实际单次观测结果；SHOW 是显示读出。显示读出累积 4 次有效新观测，再以两个同向窗口确认方向。短暂缺少证据时最多保持 700 ms，换向最短间隔 250 ms；HOLD 会明确标出保持状态。SHOW/HOLD 不能作为当前新识别结果，也不能用来计算原始方向准确率。

当前板级集成是观察模式，`source_verified=0` 时调度保持 FULL 回退。没有因此宣称 Canny 工作量、DDR 访问或功耗得到降低。活动网格表示亮度变化，镜头晃动和光照变化同样会触发。

## 源码入口

- `board/ti60f225_v4/rtl/vision/vision_local_motion_core.sv`：整数 ON/OFF 时延相关核心。
- `board/ti60f225_v4/rtl/vision/vision_local_motion_tap.sv`：完整光栅检查、网格采样与活动区域。
- `board/ti60f225_v4/rtl/vision/vision_motion_readout.sv`：仅用于显示的时序读出。
- `board/ti60f225_v4/rtl/vision/vision_motion_osd.sv`：RAW、SHOW、SUM/HOLD 字幕。
- `board/ti60f225_v4/rtl/vision/vision_motion_snapshot_cdc.sv`：跨时钟诊断快照。
- `board/ti60f225_v4/ti60f225_oob.xml`：整板 Efinity 工程入口。

此分支沿用历史已编译版本的 HDMI 设置、Gamma 优化和 V4 按键/复位映射，与旧 main 的 LCD 配置不同。没有重新选择引脚或时钟参数。历史 `.peri.xml` 和 SDC 随工程保留，适用于当时的 Ti60F225 V4、SC431HAI 摄像头配置；其他板型应使用自己的约束。

## 运行 RTL 验证

需要 Python 3 标准库和 Icarus Verilog。全部夹具由脚本生成，仅使用合成图形，不需要用户视频、训练数据或 NumPy：

```text
python fpga/vision_base/scripts/verify_motion_direction.py
```

Windows 的独立 Icarus 运行时可显式指定：

```text
python fpga/vision_base/scripts/verify_motion_direction.py --iverilog C:/iverilog/bin/iverilog.exe --vvp C:/iverilog/bin/vvp.exe --ivl-lib C:/iverilog/lib/ivl --output D:/motion-test-results
```

覆盖整数核心与参考逐值对照、四方向/静止/亮度跳变/全范围噪声、输入断包及背压、网格采样、策略回退、跨时钟快照、读出噪声/保持到期/反转/溢出，以及显示光栅和像素回归。输出日志在独立目录；脚本不访问开发板。

## 整板编译与观察

在 Efinity 2026.1 中打开 `fpga/vision_base/board/ti60f225_v4/ti60f225_oob.xml`，运行 Interface、Map、PnR，检查报告后再生成下载文件。使用既有本地下载流程及明确设备选择；本次上传未烧录或修改任何开发板，仓库不添加真实位流。

实际使用时固定摄像头，让一个清楚的物体向左、右、上、下各移动，再停止；分别观察 RAW、SHOW 和 HOLD，而不是只看大箭头。

历史归档版本的整板报告为 XLR 35,562/60,800、RAM 251/256、DSP 68/160、WNS +0.357 ns、WHS +0.026 ns，曾完成 SRAM 下载与实时计数检查。RAM 已接近上限。这些是历史归档结果，不是对本次 GitHub 分支新做的整板编译或现场效果承诺。

来源、原始哈希、换行归一化说明和历史证据边界见 [motion-direction-source.json](motion-direction-source.json)。本次分支保留与 main 只有换行差异的旧文件；新增/变更的功能源码来自归档快照。未上传个人视频、模型权重、位流、许可证或新的厂商 IP。
