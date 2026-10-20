# 2026-10-18 当前优化版 SRAM 部署与板上图像验收

## 结论与当前状态

用户授权后，已将色调配置优化版写入 Ti60 SRAM，设备 ID 为 `0x10660A79`，官方工具返回完成。制品与 `results/tone_config_xlr_20261018/release/` 绑定，保留此前中值流水和 Canny 弱瓦片缓存优化。**Flash 全程未写，未替换固件或权重。** CPU 从既有 Flash 自主启动，随后完成实际控制和相机 AI 任务。

当前已恢复 **M5 / MED1 / F0 / I0 / menu0、Sobel128 / Canny80 / SHAPE32、ROI关闭、AI关闭、Tone3、颜色顺序2、物理WB336/256/504、自动曝光开启**。原图/各模式 RGB888 及 Canny 位图回读均保留。`final_roi.json` 与烧录前设置逐项一致；源帧更新、source_frozen=0、source_held=0、CPU state=1。

当前 SRAM 位流资源：**56997/60800 XLR（93.75%）、237/256 RAM、62/160 DSP**，余3803 XLR/19 RAM/98 DSP；原生最终 WNS+0.254ns、WHS+0.026ns。此处是本次实际下载位流的构建资源，非另一个裁减版本。

## 实际回读的九幅图像

全部为 FPGA 真实 RGB888 回读，**1920×1080**，不是仿真图、采集卡截图或重绘图；统一源帧 **12655**、渲染配置 **10**，9720 行逐行核对完成标志、模式/参数、帧号、配置号、序列号及传输头。导出过程中保持同一原帧，图片中的 F1 是该步骤的冻结标志；目前已回到 F0。

|图像|文件|
|---|---|
|Gamma 前源图|[source.png](F:/Project/fpga/vision_base/results/optimized_sram_20261018/all_modes/source.png)|
|M0 原图显示|[mode_0.png](F:/Project/fpga/vision_base/results/optimized_sram_20261018/all_modes/mode_0.png)|
|M1 灰度|[mode_1.png](F:/Project/fpga/vision_base/results/optimized_sram_20261018/all_modes/mode_1.png)|
|M2 Sobel|[mode_2.png](F:/Project/fpga/vision_base/results/optimized_sram_20261018/all_modes/mode_2.png)|
|M3 灰度/Sobel 分屏|[mode_3.png](F:/Project/fpga/vision_base/results/optimized_sram_20261018/all_modes/mode_3.png)|
|M4 Sobel 彩色叠加|[mode_4.png](F:/Project/fpga/vision_base/results/optimized_sram_20261018/all_modes/mode_4.png)|
|M5 Canny|[mode_5.png](F:/Project/fpga/vision_base/results/optimized_sram_20261018/all_modes/mode_5.png)|
|M6 Canny 彩色叠加|[mode_6.png](F:/Project/fpga/vision_base/results/optimized_sram_20261018/all_modes/mode_6.png)|
|M7 识别模式|[mode_7.png](F:/Project/fpga/vision_base/results/optimized_sram_20261018/all_modes/mode_7.png)|

九图已逐幅查看，当前场景为天花板及线槽：原图和灰度保持原有纹理/黑位，Sobel 正常稀疏显示而非全白；Canny 主轮廓与平滑重建保持；两种叠加、分屏及识别参考区显示正常。M7 在该场景显示 NONE，没有借此计作圆/矩形实物准确率验收。

烧录前另外保存了同场景 M0：`before_camera/mode_0.png`。前后 RGB 均值最大差约1.07/255，1%分位黑位均为11/15/15；没有观察到新增偏紫、灰雾或条纹。它们是不同采集时刻的帧，用于目视/统计对照，而非同原帧 A/B 等价证明。

## 逐像素与数据保持核对

- 图像导出前后各回读4050个 Canny 位图字，**4277 个边缘点及全部位图内容一致**。两次计数 epoch 与图片冻结 epoch 分开记录，未把它们冒充同一次发布；验证的是同一冻结源的完整位图内容保持。
- Canny 显示与既有覆盖 ROM、九/五点拟合、双采样及原2像素中心对齐参考核对；Sobel叠加、灰度/Sobel分屏和Canny叠加也分别按真实相邻模式构造参考。
- **四项各2056320像素，所有RGB通道差异0、最大误差0**。只排除原OSD矩形x0..431/y0..39，没有排除四边或有色像素。
- 四周32像素条带中，Canny 可见像素左302、右376、上216、下229，均参与上述比对。

详见 `image_verification.json`、`edge_before.json`、`edge_after.json`、`expected_canny.npy` 和 `all_modes/images.json`。

## 现有功能的板上检查

**控制与 ROI：**既有脚本通过真实CPU事件队列注入按键事件，完成17项检查：Sobel上下调及16下限、Canny独立阈值上下调、中值开关、冻结、同原帧2倍缩放、X/Y平移、半幅输出、显示位置、视口边界约束、恢复实时。另检查SHAPE阈值/菜单及F2/F3状态切换。记录在 `key_ui/result.json`；这是板上事件策略验证，不是人工按键按压验收。

**六帧历史：**I0..I5各9次采样均保持静态帧，分别为11314、11313、11312、11311、11310、11309，六槽不同；I6才自动切换。详见 `history_static.json`。

**实时视频：**恢复F0后采样113条实时M0第500行，历时29.875秒；采集、显示内容及Canny计数均约29.992次/秒，内部HDMI扫描计数约59.983次/秒。所有样本的RAW溢出、FOV overrun、采集discard、scan_bad、配置/渲染/扫描错误、Canny fault、AE fault均0，CPU state1且probe hold0。采样行之间存在真实像素变化，不是残留冻结帧；本场景采样的显著洋红像素计数为0。

随后在F0/M5、不持有源帧或Canny平面的条件下再采样60条实时轮廓行，历时14.75秒；三个独立横向区域均未出现轮廓消失，最少可见像素为5/4/5，源帧和Canny epoch各前进442。详见 `live_rgb.json`、`live_canny.json`。这是短时指定行采样，不是移动摄像头或外部HDMI电气测量。

**CPU/AI：**在图像同一冻结源12655/配置10上完成一次真实相机DMA/FOMO任务，sequence1、完成状态3、错误0，当前天花板场景输出0目标。100MHz计时：预处理40.059ms、推理2666.945ms、后处理0.308ms、合计2707.312ms。完整融合记录确认冷启动三输入INT8/FlyHash/80神经元算术自检状态2。只做USER1只读摘要并恢复CPU，没有下载程序；最后恢复网络菜单原值、AI OFF。详见 `ai_board.json` 与 `fomo_summary/`。AI耗时与视频刷新/回读传输耗时分别统计。

## 截止期计数与验收边界

`render_deadline_misses`在启动/按键检查后为0，第一次全幅ROI冻结渲染后为1，九图导出结束仍为1；AI与恢复实时的控制转换后为5，随后实时检查及最终读数均为5。全过程配置/渲染/扫描错误和scan_bad为0。全幅渲染记录约4524164个100MHz时钟，即45.24ms；本轮没有把全幅ROI渲染宣称为60/30fps通过，也没有隐藏该截止期计数。F0关闭ROI后的内容更新约30次/秒正常。

本轮保留原图纹理与既有滤波，没有将资源优化包装为新的原图降噪。静止场景回读未复现紫闪；移动摄像头/接触诱发条件、实物卡片准确率、长时及实际断电验收仍单列。Flash保持10-17版本，断电/CONFIG后会回到该版本。

程序下载收据、精确构建manifest、资源与全部检查已归档：`program.json`、`program.log`、`build_manifest.json`、`resources.json`、`acceptance.json`。本轮没有修改RTL、固件或Flash。
