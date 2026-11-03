# 两层侧栏中文显示（2026-10-22，离线候选）

## 结果

侧栏分类、16项名称、八种模式、开关/像素/倍率、居中/推理/自检状态和操作提示完成中文显示；SOBEL、CANNY和FOMO名称保留。原顶部调试HUD及技术编号保持。菜单仍是先选一级、确认后展开二级；一级144px、二级160px、合计304px，行高64px、起点y128。视频/同步没有新增流水拍。

中文字库是61条实际菜单文本使用的113字、16×16点阵，共28928bit；原ASCII字形/大小保持。原生map中字库独占4RAM，旧HUD没有重复实例化这份中文字库；侧栏总字体5RAM。没有UI帧缓存、运行时Unicode解码或CPU协议改变。字形数据和文本在vision_osd.sv中生成，脚本scripts/generate_sidebar_chinese.py可复现，字体文件不入工程。

## 整机资源与时序

| 项目 | 上一版 | 中文版 | 增量 | 剩余 |
|---|---:|---:|---:|---:|
| XLR | 57906 | 57745 / 60800 | -161 | 3055 |
| RAM | 242 | 246 / 256 | +4 | 10 |
| DSP | 62 | 62 / 160 | +0 | 98 |

最终WNS +0.108ns、WHS +0.027ns，未分配核心引脚0；既有Missing Interface Pins14保持。Map/interface/P&R/位流生成四阶段与源变化/最终时序门禁通过；pgm在此指生成位流，不是板卡写入。中间placement的WNS为负，最终route为正，未用中间值代替最终验收。

173项原生输入只有board/ti60f225_v4/rtl/vision/vision_osd.sv变化，另172项保持；根据已有原生manifest对比，没有为本轮额外重算哈希。相机配置、Canny/Sobel/重建/色调、ROI/DMA/帧池/历史、CPU/IP/cache/固件/AI/果蝇及RGB24回读未变。image_debug.image_snapshot仍5RAM。XLR净减161是本轮整机P&R差值，不把它泛化为汉字必然更省逻辑。

## 本轮验证

- 生成器--check：61条文本、113个非空且不重复的16×16字形，所有文本不超过8个字格。
- OSD：4分类、16项、8模式、开关/单位/倍率、居中7状态、推理/自检状态和确认取消；53504像素检查含全部中文字形及128个ASCII编码的原HUD像素。
- sidebar_video：65536随机关闭菜单周期和三幅完整1920×1080场景；5936988个菜单外像素RGB和DE/HS/VS一致，菜单墨点13189。三张PNG和2倍局部拼图已查看。
- fusion_display：同帧标签、几何、过期结果和无重新绑定通过。
- edge_strength / edge_overlay：Sobel阈值/饱和、Canny覆盖率、二值识别隔离、M2–M7叠加及原图/灰度保持通过。
- line_snapshot：192个RGB888像素、两种tap、行头/串行/元数据/错误行行为通过。

本轮是6项定向RTL回归加生成检查；原完整38视频套件、19核心和2591 RV32I断言不重复计本轮结果。固件/按键控制代码未改，仍复用上一轮通过的交互与407几何用例证据。

## 制品与后续使用

- 中文位流：release/ti60f225_oob.bit；artifacts/camera已更新为相同离线候选。
- 配套完整DDR应用保持：F:/Project/fpga/vision_base/results/sidebar_hierarchy_20261022/firmware/vision.elf（185472B，BSS66104B）。
- 原4400B权重保持；需要自主启动时的189904B离线启动包仍是results/sidebar_hierarchy_20261022/release/vision_boot.bin。本轮没有重打包相同固件。
- 中文菜单操作见F:/Project/fpga/vision_base/docs/SIDEBAR_HIERARCHY_20261022.md。

本轮未连接板卡、未写SRAM或Flash；最近已记录实机仍是10-18 SRAM/10-17 Flash。实机字体可读性、实体按键、实时相机/目标居中、长时和实际断电继续待硬件返回验收。预览是RTL合成场景，不是新相机照片。RAM剩10块，后续新增模块仍须核对整机预算；没有删除现有功能换空间。
