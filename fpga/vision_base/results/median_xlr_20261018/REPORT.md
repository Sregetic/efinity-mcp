# 2026-10-18 公共中值算子等价XLR优化

## 结果与部署状态

已完成RTL替换、逐周期等价回归、整机原生map/interface/P&R/pgm以及制品源文件/时序门禁。新候选为`F:/Project/fpga/vision_base/results/median_xlr_20261018/release/ti60f225_oob.bit`，默认构建制品`artifacts/camera/`也同步到该候选。

**整机净释放1614 XLR，RAM和DSP保持。当前只生成候选，本轮未写SRAM或Flash，也未操作JTAG/现场硬件。** 已固化版本仍是10月17日sample_pass，实际断电验收仍待现场完成。新候选的物理画面和长时运行没有计作通过。

|项目|优化前sample_pass|新候选|变化|
|---|---:|---:|---:|
|XLR|60050 / 60800（98.77%）|58436 / 60800（96.11%）|−1614|
|空余XLR|750|2364|+1614|
|RAM|235 / 256|235 / 256|0|
|DSP|62 / 160|62 / 160|0|
|最终WNS|+0.071ns|+0.249ns|均通过|
|最终WHS|+0.029ns|+0.026ns|均通过|
|未分配核心引脚|0|0|保持|

仍余21块RAM、98个DSP。到95% XLR还需释放676，当前不将下一项估算计入结果。

## 本次改动与效果约束

唯一变化的原生输入为`board/ti60f225_v4/rtl/vision/vision_median9.sv`：用十九比较的中值选择网络替代九级奇偶全排序，输出仍是九个无符号8bit数中的第5个。九级寄存、每拍一窗口、像素与meta对齐、零初始化保持，模块接口和所有调用方保持。

七份算子各自持续运行，覆盖RGB/灰度前端四份、Canny前处理一份、X3的2PPC两份；没有串行合并跨支路算子。下游Sobel/Canny的坐标、阈值、噪声地板与帧校准语义保持。最新九点/五点斜线拟合、转角/四边预取、像素内双采样、M6混合和480×270检测尺寸也保持。

原生输入共172项，与固化版逐项对照只有上述一个文件变化，见`build_input_diff.json`。相机profile/曝光/白平衡/色调、CPU/固件、ROI、帧池/DDR/CDC、SHAPE/AI、历史/冻结、按键/菜单和回读源码保持。回读实例仍占5块RAM，功能源与构建分支未裁剪。仿真夹具另在`sim/vision/tb_median9.sv`扩充，不进入原生位流。

## 为什么可维持数值效果

候选只由无符号min/max构成。对任意阈值t，先做min/max再映射为`x>=t`，与先阈值化再做min/max等价。因此穷举九输入的512种二值排列，可验证该选择网络对全部8bit有序值的中值性质；另外用真实RTL与旧RTL逐周期对照检查流水和初始化，避免只有主机算法正确。

旧RTL完整保留为测试夹具中的`median9_sort_reference`，已确认与修改前源码仅模块名不同；另有独立排序参考，避免两份RTL共同出错而互相通过。

`median9.run.log`中26912组窗口全部通过，包含：

- 2048组二值/阈值边界：四套取值对各穷举512个窗口；
- 256组全相等值；
- 4608组亮/暗单点脉冲，覆盖九个位置和全部8bit数值；
- 20000组固定种子随机窗口。

全部逐周期比较新旧median和64bit meta，另测META=1；独立参考确认九级延迟和每拍输入。差异0，连续输入及管线排空均覆盖。

## 调用链回归

|回归|结果|
|---|---|
|frontend|450处有效像素检查，0错误|
|color_denoise|450处RGB滤波/旁路/边缘对齐，0错误|
|canny_denoise|6144像素、噪声地板、校准与meta通过|
|line_direct|46080像素、30656处内区比较，MED关闭/开启、1920全宽、六行间隙和延迟统计通过|
|fusion_display|完成帧标签、源灰度几何、新旧ROI结果与绑定通过|
|canny_noise|36864像素；平坦噪声、几何/细线保留、突发噪声保持已接受轮廓并重试通过|

日志与`simulation.json`保存在本目录。已移除本轮测试产生的七个临时`.vvp`，保留日志、源码前后对照和交付制品。

## 实测面积归属

|实例|前XLR|后XLR|释放|
|---|---:|---:|---:|
|frontend灰度中值|738|549|189|
|frontend RGB三路|3×666|3×477|567|
|Canny filter|754|565|189|
|X3 med0|688|499|189|
|X3 med1|682|493|189|
|七份合计|4860|3537|1323|

其余291是整机重新综合/布局后的净差，未另改对应模块；整机净数1614以当前place和层级报告为准，不把父子模块重复加总。层级self XLR合计校验为58436。详见`resources.json`、`before.hier_util.rpt`和`board.hier_util.rpt`。

## 原生构建及制品

沿用SC431HAI中心1080p30四lane profile、相同工具/时钟/SDC及完整功能：

```powershell
& F:/Project/fpga/vision_base/scripts/synthesize.ps1 -Top board -Flow compile -VideoMode camera -Sensor sc431hai -SensorProfile F:/Project/fpga/vision_base/board/ti60f225_v4/sensors/sc431hai_1080p30_center_4lane.json -TimeoutSeconds 2400
```

`native_compile.log`记录厂商map、interface、pnr、pgm四阶段完成。首次外层Tee日志使用相对路径，在内部Push-Location期间触发归档路径错误；厂商完整编译已结束，原生报告与位流存在且最终时序通过。随后用原脚本pgm流重走源文件/时序门禁、重新生成制品，再以绝对路径完成归档。此处理未重新修改RTL或SDC，见`orchestration_note.txt`、`finalize.log/json`。

最终制品发布后执行既有`program_vision_sram.ps1 -ValidateOnly`，源文件/位流身份、选定传感器、最终时序和核心引脚检查通过。该参数仅检查制品，未执行烧录。详细记录见`candidate_gate.log`、`compile.json`、`acceptance.json`和`release/manifest.json`。

当前候选通过了逻辑等价及原生实现检查；当前Flash仍按`F:/Project/fpga/vision_base/results/canny_flash_20261017/deployment.json`记载。物理画面、紫闪长时、独立断电、SC2210/无profile全1440p路径的新P&R与实物识别精度未在本轮重验。
