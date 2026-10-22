# 两层窄菜单、模式名称与行距修订

日期：2026-10-22。已完成离线实现和原生整机验证。**本轮未连接板卡、未写SRAM或Flash。**

## 用户要求与落实

| 要求 | 实际结果 |
|---|---|
| 侧栏收窄 | 一级144px，确认分类后向右展开160px，合计304px；原为448px，两层总宽减少32.1% |
| 写清模式含义 | MODE直接显示8种名称；MEDIAN显示ON/OFF，AI显示OFF/FIXED/AUTO，MODEL显示BASE/FOMO，TARGET Z显示AUTO/1X/2X/4X/8X；坐标带PX，尺寸带W |
| 两层展开 | 一级IMAGE/VIEW/TARGET/AI；短按KEY0确认分类才展开二级，编辑在第二列内完成 |
| 每栏间距加大 | 行高32→64px，选中项分名称和数值两行显示 |

菜单从y=128开始，原顶部HUD完整保留；避免窄菜单遮住原状态栏左半部后留下不完整的右侧字段。一级高度448px，二级按项目数为384/576/384/448px。

分类：IMAGE含MODE/THRESH/MEDIAN，VIEW含SRC ZOOM/PAN X/PAN Y/OUT SIZE/POS X/POS Y，TARGET含CENTER/TARGET Z/FULLVIEW，AI含AI/RUN AI/SELFTEST/MODEL。原单目标居中、帧身份、ROI草稿/确认、冻结/历史、自检和完整相机AI保持。

MODE的0–7依次为CAMERA原图、GRAY灰度、SOBEL边缘、SPLIT分屏、SOBEL OV叠加、CANNY、CANNY OV叠加、SHAPE几何识别。模式不以005等数字显示。数字阈值与坐标仍为实际参数，保留原独立阈值规则。

KEY0长按：打开一级，或逐级取消编辑/返回/关闭。短按：一级进入二级，二级进入编辑，编辑后确认提交。KEY2/KEY3短按上下选择或增减草稿，原长按冻结/历史保持。

## 资源与时序

| 整机 | 上一版单层 | 本轮最终版 | 变化 | 剩余 |
|---|---:|---:|---:|---:|
| XLR | 57821 | 57906/60800 | +85 | 2894 |
| RAM | 242 | 242/256 | 0 | 14 |
| DSP | 62 | 62/160 | 0 | 98 |

最终WNS +0.188ns、WHS +0.026ns，未分配核心引脚0；原接口Missing Interface Pins仍14。map/interface/P&R/pgm四阶段通过，pgm仅生成位流，未进行板卡编程。时钟、SDC、seed、CPU/IP/ROM/cache参数保持。

菜单仍只用原增加的1块字库RAM，原图/模式RGB24回读仍5块RAM；没有新增UI帧缓存或扩大状态CDC总线。完整原生输入对照仅vision_osd.sv改变，摄像头/RAW10/FIFO、Canny/色调、帧池、DMA、缩放器和其余算法保持。

完整DDR应用185472B，较上一版184768B增加704B；BSS仍66104B。紧凑启动/救援构建6784B，仍在8KiB内；基础控制DDR调用方8968B。完整相机FOMO/原INT8/FlyHash/连接组及伴随读出保持，模型与4400B原权重保持。离线VBO1包189904B，未写Flash。

## 验证证据

- `control/result.json`：实际生产头文件在严格RV32I QEMU执行，misa检查M/A/C/F/D关闭；2591断言、407组居中几何、8个UI诊断向量通过。新增四分类、16子项循环、确认后展开、逐级返回和取消不提交验证。
- `osd.log`：原HUD、全部8种模式名称、符号值、AI关闭下自检、两层边界、64px行高及顶部HUD避让通过。
- `sidebar_video_final.log`：三幅完整1920×1080场景、65536拍随机闭合旁路检查，5936988个菜单外有效像素RGB及同步一致；无新增视频流水拍。
- `core_quick.json`：19项原核心回归通过，覆盖按键/CDC、帧池/持有、分析DMA、DDR共享、ROI与渲染等。
- `snapshot.log`：192个RGB888像素、两种tap、192bit行头/身份/顺序与坏行拒绝通过。
- `legacy_control.log`：原独立阈值、旧诊断菜单接口、冻结/历史、ROI提交及AI控制回归通过。
- `firmware/`、`base_firmware/`、`boot_firmware/`、`fixed_firmware/`：相关调用方构建记录。固定四图应用这里只记录编译，未在板上重跑。
- `native_final.log`、`release/`：最终原生报告和配套位流；`resources.json`记录实际整机余量。

预览生成时发现随机流尾部VS已为高会使测试缺少新帧上升沿，导致预览原点错一行。已在测试源提供完整低→高→低帧同步，与真实视频契约一致；未在生产模块增加补丁或重试。最终原点和菜单外像素检查通过。

本轮没有重跑上一轮38项完整视频回归：摄像头与图像算法源码保持，仅对修改的OSD/合成显示、控制及相关接口定向验证；旧38项不计作本轮新执行结果。无相机新照片、实物识别、实体按键或长时验收。

## 制品与复现

- 配套位流：`F:/Project/fpga/vision_base/results/sidebar_hierarchy_20261022/release/ti60f225_oob.bit`。
- 完整DDR应用：`F:/Project/fpga/vision_base/results/sidebar_hierarchy_20261022/firmware/vision.elf`。
- 预备自主启动包：`release/vision_boot.bin`，仅离线生成。
- 原权重：`F:/Project/fpga/vision_base/models/shape_cards_bringup/shape_cards_weights.bin`。
- 操作说明：`F:/Project/fpga/vision_base/docs/SIDEBAR_HIERARCHY_20261022.md`。
- `sidebar_menu.png`、`sidebar_submenu.png`、`sidebar_edit.png`来自实际RTL合成场景，非相机实拍。

主要命令：`scripts/test_sidebar_center.py`、`scripts/verify.ps1 -Suite quick`；OSD与侧栏测试分别为sim/vision/tb_osd.sv、tb_sidebar_video.sv，实例源为vision_osd.sv、vision_sidebar_overlay.sv；整机命令为scripts/synthesize.ps1 -Top board -Flow compile -Sensor sc431hai -SensorProfile board/ti60f225_v4/sensors/sc431hai_1080p30_center_4lane.json -TimeoutSeconds 3600。原传感器头在构建后恢复默认。

旧部署仍按总状态10-18 SRAM/10-17 Flash记录，未在本轮刷新现场。新菜单需本轮位流与DDR应用配套；硬件返回后再做SRAM试按和实际画面验收，Flash保持现状。
