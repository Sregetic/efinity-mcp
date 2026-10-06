# 资源优化实施与实测 — 2026-10-05

本轮实际完成诊断构建分离、RAW FIFO 512 深度试验和最小 Sapphire 独立资源测量。FlyHash 固件迁移、控制面迁移、Canny/fov 存储重排、RAW/ISP 体系合并仍未实施，不把潜在收益计入已释放资源。B/A/X/I/V/F1 全部目标保留。

## 整机同源码、同器件布局布线

Efinity 2026.1.132.3.9，Ti60F225 I3；四个配置均完成 map/interface/P&R/pgm，Unassigned Core Pins=0，Missing Interface Pins=13 与原设计一致，DSP 均43。

|配置|IMAGE_DEBUG|RAW_FIFO_DEPTH|XLR|RAM|WNS ns|WHS ns|
|---|---:|---:|---:|---:|---:|---:|
|同源码基线|1|1024|55675|255|+0.334|+0.026|
|比赛版、1024|0|1024|53675|245|+0.181|+0.026|
|调试版、512，当前SRAM|1|512|55402|243|+0.345|+0.026|
|比赛版、512|0|512|53951|233|+0.233|+0.026|

诊断裁剪单项释放10RAM/2000XLR；调试版缩FIFO释放12RAM/273XLR；组合实际释放22RAM/1724XLR。P&R打包并非线性叠加：比赛版缩FIFO反而增加276XLR。比赛版空余23RAM/6849XLR；调试版空余13RAM/5398XLR。

前一已运行的 KEY 修正版为55368XLR/255RAM；新参数化基线为55675XLR/255RAM。因此当前调试512版相对前一制品是RAM减12、XLR增34，而非逻辑大幅下降。全部比较分别列账。

五个纯诊断实例通过顶层 `IMAGE_DEBUG` 的 generate 分离：RAW snapshot、三个 RGB color probe、HDMI行图像 snapshot。关闭后页3–7/26–27返回明确disabled tag，页28的RGB位数返回0；主机工具在读取图像前报出该构建状态，不把零数据当图片。AE统计、ROI/帧池/历史、识别、Sobel/Canny、Canny位图读口、FlyHash及功能错误计数继续保留。图像调试版仍为默认。

`RAW_FIFO_DEPTH`实际传入checker0的WR/RD FIFO，默认已设512；1024配置仍可原生覆盖。每路主FIFO由13RAM变7RAM，checker0总RAM由28变16。HDMI1080p60/VIC16、相机配置、1px Canny和像素算法保持。

资源明细：[build_results.json](F:/Project/fpga/vision_base/results/resource_trials_20261005/build_results.json)。对应四个 `*_native` 目录保留位流、原生资源/时序/层级报告和构建日志。

## 板上A/B与验证边界

用相同M0/T96/MED1/F0、440/256/516白平衡、tone3、AE1，先512、再1024、最后512进行SRAM对照；Flash保留。测试整帧与中心2× ROI各设置60秒，同一冻结源依次整帧、放大、平移、居中缩小四次重新渲染。

|深度/场景|实际采样跨度s|RGB采集计数增量|扫描坏帧/采集丢弃增量|渲染周期中位数|deadline增量|
|---|---:|---:|---:|---:|---:|
|1024/整帧|58.016|3482|0/0|3867005|1160|
|512/整帧|57.719|3462|0/0|3867730|1154|
|1024/2×|59.078|3543|0/0|1792178|1771|
|512/2×|58.891|3534|0/0|1791008|1767|

ROI功能检查通过，两种深度均有deadline增长，渲染周期接近；这不是512特有的现象，也不是60fps渲染验收。RGB采集/已发布源帧ID的增量不是独立相机帧率或渲染完成次数。默认控制器的预算1666667周期，实际整帧/2×实时渲染均超预算；该性能问题保留，不通过调大预算掩盖。

512冻结源7754和1024冻结源7789各自四次重渲染保持源/RAW标签不变、配置更新；两个测试均无ROI配置、渲染、扫描或Canny故障。最终512版短时历史检查：F1显示ID255保持、采集继续；F2观察到250–253切换；F3在252/253间交替，history_count=6。完整六槽遍历另有既有仿真，不把此次短采样当长时历史验收。

两个版本都读取了同一冻结源内的source/M0/M2/M5四张1920×64条带，行号400–463、源/config/Canny epoch绑定通过。当前AE中心RAW均值为1024版16.135、512版16.126；RAW稀疏块为16–17，RGB源最大通道值4，边缘条带全黑。当前输入接近黑电平；这些结果仅支持传输/格式/绑定检查，不构成明亮场景画质或无条纹验收。旧的完整九图展示保留，未被本次条带覆盖。

FlyHash FPGA/主机64项特征和编码一致，但本轮为零边缘输入；编码4877周期、片上任务约62ms，不算非黑实物识别验证。

RAW `write_errors`累计1保留，恢复实时后追加62.27秒/290点监测，1→1、增量0；此前项目资料也记录1→1，首次产生的位置在本轮未重定位。它由帧写提交检查产生，不等同FIFO溢出计数。RAW FIFO高水位、最坏DDR服务间隔和硬件欠载计数尚无直接板上遥测；本轮零ROI错误、FIFO仿真和短时写提交观察分别列账，不宣称完整零溢出验收。

证据：[board_comparison.json](F:/Project/fpga/vision_base/results/resource_trials_20261005/board_comparison.json)、两个 `*_board/board.verification.json`、`*_strips/images.json`、[history_checks.json](F:/Project/fpga/vision_base/results/resource_trials_20261005/history_checks.json)、各次program日志。

## Sapphire：真实RAM与逻辑交换

使用本机官方SoC IP3.4.1生成RV32 Lite：4KB ICache+4KB DCache、1KB启动RAM、100MHz共享时钟、128bit/ID6 DDR AXI、UART16、GPIO4、APB0；关闭FPU/MMU/Atomic/MulDiv/barrel及多余外设。官方生成的同步/异步RAM ABI缺少绑定，复用现有Efinity simple_dual_port_ram实现同步口；实际UART4×8异步口使用寄存器阵列。读使能保持、单周期读取、字节写掩码及22bit标签测试通过。

所有CPU输入由移位寄存器保留，输出通过动态选择保留，避免独立综合把CPU/总线剪掉。此测试顶层仅用于面积与内部100MHz时序；移位寄存器/选择器的资源单独扣除，外部AXI时序未约束，也未执行DDR程序或烧录这个测试位流。

|RAM映射|CPU层级XLR估计|SoC RAM|测量包装XLR|包装总XLR|100MHz WNS ns|
|---|---:|---:|---:|---:|---:|
|常规blockRAM|5134|24|440|5574|+4.864|
|仅UART16×8/AXI元数据64×6用寄存器|7020|20|441|7461|+5.057|
|所有深度≤64的同步RAM用寄存器|14729|12|426|15155|+4.577|

三个配置均完成map/interface/P&R/pgm、无未分配引脚。数字来自物理打包后的层级报告，不是LUT+FF相加。达到12RAM的代价是CPU层级约14729XLR，所以“10–16RAM同时约4000–5000XLR”的预算本轮未成立。

官方生成源码还有可选MMU/fence及`IBusCachedPlugin_iBusRsp_output_payload_rsp_error`等未驱动网告警，未擅自修改厂商CPU网表；独立面积成功不代替指令执行、异常与外部DDR启动验证。

当前比赛512版233RAM+常规SoC24RAM=257，超容量1；选择性20RAM版的独立逻辑相加53951+7020=60971，比60800多171。仅作预算筛选，联合布局与总线接入增量另验。若未来实际迁移整个FlyHash，本版cone约5208XLR/2RAM，常规SoC的算术预算约53877XLR/255RAM；迁移尚未发生，新增接口、固件启动、cache一致性和DDR地址保留区仍需集成实测。

配置及报告：[sapphire_results.json](F:/Project/fpga/vision_base/results/resource_trials_20261005/sapphire_results.json)、[parameters.json](F:/Project/fpga/vision_base/results/resource_trials_20261005/sapphire_eval/parameters.json)。SoC的RAM绑定依据实际生成的调用接口及[SpinalHDL RAM ABI](https://spinalhdl.github.io/SpinalHDL/dev/spinal/core/Ram_1w_1rs.html)；生成、启动和外部DDR约束参考[Efinix官方Sapphire文档](https://www.efinixinc.com/support/docsdl.php?pn=SAPPHIREUG&s=ef)。

## 六项当前状态

|原提案|本轮状态|
|---|---|
|1. DDR程序、小cache、最小SoC|生成与独立P&R实测完成；尚未接入整机DDR/固件启动|
|2. FlyHash和控制转固件|保留当前硬件路径；待SoC接入后做同输入/周期/资源实测|
|3. 调试/比赛构建分离|实现，两种深度的比赛版完整构建通过；仅调试版上板|
|4. FIFO缩到512|实现、仿真、原生P&R、板上A/B完成；当前部署调试512版，完整画质/极限带宽验收仍开放|
|5. Canny/fov存储重排|本轮未实施，未计入收益|
|6. RAW/统一帧池体系合并|保持后备，本轮未实施，未计入收益|

## 复现

工作目录 `F:/Project/fpga/vision_base`，PowerShell7。原生构建使用显式顶层参数，保持四种配置可重复；OUT/WORK分别指定独立绝对目录。

```powershell
. ./scripts/efinity_env.ps1
$py="$env:PYTHONHOME/bin/python.exe"
& $py "$env:EFINITY_HOME/scripts/efx_run.py" board/ti60f225_v4/ti60f225_oob.xml --flow compile --timeout 1500 --output_dir OUT --work_dir WORK --map_opts top-params=IMAGE_DEBUG top-params=1 top-params=RAW_FIFO_DEPTH top-params=512
# IMAGE_DEBUG=0选择比赛版，RAW_FIFO_DEPTH=1024复现基线。
```

保留可运行检查：`sim/tb_raw_fifo_depth.sv`使用实际128bit DC_FIFO、两种异步时钟、8192字、满压/环绕/排空；深度512/1024各通过。`sim/tb_sapphire_ram.sv`三种映射通过。`scripts/test_capture_mode_images.py`检查caps0/24、非法caps拒收、disabled头拒收及RGB/PNG源绑定。编译/测试日志保留；无例行hash校验。
