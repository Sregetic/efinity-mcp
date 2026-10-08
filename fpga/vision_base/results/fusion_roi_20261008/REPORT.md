# I1 / I3 实施与上板记录

2026-10-08。对应长期路线第1、2项：I3同帧结果记录/显示/冻结复核，I1几何驱动ROI及A6样本准备。实现已写SRAM并在当前相机链验证；A6实物形状卡和真实模型准确率单列，未用背景暗斑或合成模型代替。

## 当前制品与资源

- SRAM：`F:/Project/fpga/vision_base/results/fusion_roi_20261008/release_pipeline/ti60f225_oob.bit`。Flash原样。
- DDR应用：`firmware/vision.elf`，RV32I、dot4/MulHi、无MulDiv，8456字节text/1392字节BSS；25kHz USER1加载和程序/权重逐字节回读通过，见`load_25khz/result.json`。当前仍使用4400字节合成联调权重，模型版本1。
- 原生Ti60F225/I3、seed1，map/interface/P&R/位流生成通过；**最终WNS +0.080ns、WHS +0.026ns、未分配核心引脚0**。Post-Placement −0.225ns不是最终结论。见`resources.json`、`release_pipeline/ti60f225_oob.route.rpt.xml`。

|资源|上一部署|本轮|实际增量|剩余|
|---|---:|---:|---:|---:|
|XLR|57838|59789/60800|+1951|1011|
|RAM|247|247/256|0|9|
|DSP|59|59/160|0|101|

新增结果CDC/控制和HUD没有增加像素RAM，没有删已有功能。逻辑利用率98.34%；后续新增硬件先继续回收逻辑，F2软件原型不需要另加大核。HDMI1080p60、SC431HAI2560×1440约30fps、Canny480×270检测保持，SC2210实物分支本轮没有编程。

## 实现

1. **I3**：分开记录源帧、源侧lease字段、render配置、model版本和处理context；原子VS发布、当前匹配与结果年龄；过期结果显示OLD并隐藏框；同源冻结重渲染后重新关联结果。当前RAW分支的源侧配置字段实为raw_id帧戳，不冒充传感器初始化版本。
2. **I1**：复用现有单个几何模块读取当前前端灰度；坐标减去两层窗口偏移，再按已提交ROI/缩放/屏幕平移反变换；留白后申请确切源帧compute lease，复用32×32 DMA和既有CPU推理。无完整候选不推理；可视边界/letterbox与旧配置候选拒收。
3. 面板/CLI共用固件事件0x60：0关闭、1配置ROI、2几何自动ROI。保留硬件消抖和帧边界提交。原图/模式回读加`--current-view`，可保持当前冻结配置读取。

完整ABI、命令和已知边界见`F:/Project/fpga/vision_base/docs/I1_I3_FUSION_ROI_20261008.md`。

## 实际板上证据

`verify_evidence.py`从保存的源图、CPU数组、融合包、page31和屏幕像素重新检查，`board_validation.json`通过。

- 原冻结源**1971/render2/context4**，配置原ROI `[700,360,480,320]`：1024灰度像素与Gamma前DDR原图采样完全相同；128特征、32隐藏输出、4分数、256-bit FlyHash与主机参考逐值一致。屏幕青色框 `[702,362,1181,681]`，TEST、年龄0；导出前后同一完整发布记录序号988不变。见`frozen_ai`、`frozen_fusion`、`frozen_images`。
- 25kHz重测冻结源**58008**：render **10→11**，源帧与原ROI不变；从全幅变为源裁剪 `[400,200,960,540]`、输出1600×900、位置160/90。两次1024像素与所有CPU输出一致，显示框反投影后为 `[662,358,1461,891]`，匹配1、年龄0；框顶整行像素为青色。见`verified_*`。
- **真实几何自动触发**：在同一源1971中，将已有相机背景暗斑移进几何区域（源裁剪 `[500,900,160,120]`，输出1280×960、位置320/60，既有形状差值阈值64）。几何圆形框 `[834,454,913,533]`，自动选择原帧ROI **`[562,947,14,14]`**，DMA/CPU/模型/融合全链运行，显示匹配1/年龄0。该ROI的1024采样像素、全部层输出与主机一致。几何类别1，联调模型类别3，明确显示TEST，不声称实物识别一致或融合准确率。
- **校准后重调度**：同一源1971/render6，阈值32时NONE；阈值64、背景标定完成后自动发布有效推理。旧实现只按帧/context去重会停在首个NONE；现在把几何内容纳入key。见`scheduler_none`、`scheduler_recovered`与`automatic_*`。
- **OLD实测**：暂停新分析后换到新冻结源51410/render8；保留发布源1971/render6。page31年龄49439、匹配0；OLD文字被回读，旧框位置行没有青色像素。见`stale`。随后恢复分析与实时画面，未留下持有源帧。
- **实际权重/版本切换**：冻结源93939/render16/context14，合成权重1→仅改变输出偏置的权重2→原权重1。三次输入1024字节完全相同，版本2分数`[25,-40,-50,0]`，恢复1分数`[12,-40,-50,0]`，每版与各自主机参考逐值一致；发布包、屏幕M字段和分数一致，匹配1/年龄0。见`model_versions/validation.json`、`verify_model_versions.py`和HUD。是配置/发布检查，不是第二个真实训练模型。
- 恢复后15.95s采样：源约**30.03fps**、Canny约**29.97fps**、Canny故障样本0、RAW写错误0、扫描坏帧/渲染/扫描错误0。见`progress_summary.json`、`raw_errors.json`及最终控制记录。它是本轮运行检查，不代替整机长时或物理HDMI紫闪验收。

最终恢复M6、Sobel128、Canny80、median0、形状差值阈值32、F0、全幅ROI配置且ROI关闭、自动几何策略2。完整功能与旧训练/数据工具保留。额外实时全幅ROI开/关期间，render_deadline_misses从7增至67；不是零新增deadline的报告。恢复ROI关闭后再查10秒保持67，记录在`steady_before/after.json`；扫描坏帧/显示错误仍0。全幅ROI渲染吞吐继续归X1/X3性能收尾，不把成功显示等同所有deadline达标。

面板在原端口63438重启并保留旧图库；新HTML包含分析策略按钮，实际HTTP policy0→2与状态读取通过，见`panel_board_check.json`。没有关闭用户浏览器或Codex；原标签刷新后加载新控制项。

## A6准备与验证

- `prepare_a6_fixtures.py`：9幅确定性合成图，空心/实心圆与矩形、反色空心、空白、条纹背景、裁剪矩形。主机与实际RTL逐像素输入、三次冻结帧分类一致，见`a6_synthetic/result.json`。
- 实际背景暗斑灰度回读：阈值64，host/RTL均CIRCLE、背景131、轮廓填充4992、比例0.78，见`a6_camera_candidate/result.json`。这是相机候选和I1连接检查，不是形状卡实物验收。
- 原全幅相机背景负例拒收记录保留；真实card_id/session_id隔离采集工具不变。现场空心卡片、反色卡片、复杂背景误检漏检和真实模型门槛继续待验收。

## 根因修正和排除的候选/数据

- 几何完成值与下一帧采集标签原先可能混用；现独立capture标签与completed标签，下一帧开始不重新给旧框贴新源帧号。
- 新HUD曾将x→字符选择→字模→RGB连成21级，最终WNS −0.575ns。该`release_final`没有烧录。拆分字符/字模并同步RGB/DE/HS/VS一拍后，本次最终+0.080ns；额外6.734ns，不改变刷新率。
- 100kHz USER1读回曾有坏字段/字节，包括0xa107a107。热加载比较失败后CPU保持halt；同一程序内存、不重写、只改25kHz读回，8456字节完全一致。随后25kHz完整程序/权重加载通过。共用配置与CLI统一25kHz，保留显式速度参数，没有自动重试。早期`zoom`、`pan`中的100kHz数据未通过完整核对，**排除在board_validation之外**；保存为故障记录，不补造字段。flags外部解码检查reserved bits，遇到错误直接报错。
- 旧`release`是完成标签修正前候选，`release_tagged`是被当前构建取代并主动停止的P&R，均未部署。本轮唯一新上板位流是`release_pipeline`。
- 热权重测试的首版助手把写入/原PC恢复分成两个OpenOCD连接，出现WAIT持续重发和读口失败。调试注入访存会借用CPU寄存器；退出后重连丢掉上一连接保存的应用上下文。现改为同一连接完成写入、二进制回读比较、版本/nonce更新与resume；重加载当前程序入口恢复正确寄存器后，1→2→1通过且原输入未改变。失败读日志保留在`model_versions/context_fault_read.log`，不当模型成功证据。正式冷加载器的两阶段方法始终从ELF入口启动，不做原PC热恢复；没有把此故障扩散到它或改动厂商OpenOCD。

## 检查与交付边界

29项视频特性回归、19项核心快速回归（含异步结果CDC/VS发布、compute lease/分析DMA/共享内存）、RV32I控制/融合函数、CPU结果解码、面板路径/类型/序列化检查通过。板上数据/像素检查独立记录。仓库71项软件测试通过，1项Windows缺符号链接权限跳过，实际MCP SDK要求启用；软件CI不是原生P&R或实物验收。

![同源I3融合回读](F:/Project/fpga/vision_base/results/fusion_roi_20261008/frozen_images/mode_6.png)

![几何自动ROI的相机候选链测试](F:/Project/fpga/vision_base/results/fusion_roi_20261008/automatic_images/mode_6.png)

![旧结果OLD回读](F:/Project/fpga/vision_base/results/fusion_roi_20261008/stale/hud/mode_6.png)
