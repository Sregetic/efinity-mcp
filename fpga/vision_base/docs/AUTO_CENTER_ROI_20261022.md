# 一键自动居中 ROI：当前操作与离线验证

2026-10-22当前候选为对称留边版。用户明确要求的是黑边对称，而非取消黑边或让目标偏离中心铺满屏幕。保留两层中文侧栏和前轮长时间FOMO推理期间取消/重发修复，仅调整共享构图函数。硬件不在现场，本轮未连接板卡、未写SRAM或Flash。

## 怎么使用

1. 在F0实时或F1冻结下，先取得有效目标。AI关闭或基础模型时使用既有几何结果；选中FOMO且开启AI时，居中动作请求一次新的FOMO任务。
2. 长按KEY0打开中文菜单，KEY2/KEY3选“目标”，短按KEY0展开二级。
3. 需要限制放大程度时，先选择“放大倍率”，进入编辑，设置“自动 / 1倍 / 2倍 / 4倍 / 8倍”，再次KEY0确认。倍率是上限，较大目标会自动降低倍率以保留整体。
4. 选择“一键居中”，KEY0进入确认页，再按KEY0确认。RISC-V会自行计算源ROI、缩放尺寸和输出位置，无需手动调平移或输出坐标。
5. 状态从“等待”转为“完成”表示现有ROI提交握手已确认，渲染结果随后按原帧边界切换。长按KEY0逐级返回并关闭菜单。
6. 选择“恢复全幅”并确认，可退出ROI、恢复原全幅，同时取消尚未完成的居中请求。

这是**一次识别后的一次自动构图**，不是连续跟踪。F0后续画面继续在这组ROI中实时更新；F1重渲染持有的同一原帧。目标移动后，可再次请求居中。F2/F3历史状态下显示“正忙”，先回到F0/F1再执行。

几何路径仍沿用当前检测区域；FOMO固定单帧仍使用已提交源ROI，ROI关闭时为原固定分析区[640,300,640,480]，自动模式仍为几何引导。本轮没有增加全图搜索或训练新的模型。无目标显示“无目标”，旧变换/身份显示“已过期”；当前构图保持。识别精度与分析更新率保持原状态，不以本轮构图测试代替实物识别验收。

## 构图规则

- 将显示目标框逆映射到原始源坐标，不把已经放大的显示坐标再次当成源坐标。
- 按1/2/4/8整数倍率等比放大，为目标保留余量；水平输出满足现有8像素对齐契约。
- 靠近源图四边时，以目标中心为基准同时收缩源窗口两侧，再将输出区域放在屏幕正中；左右黑边等宽、上下黑边等高，目标完整、等比缩放。
- 对称留边会减少贴边目标周围可见的背景；保留原倍率上限。处理奇数尺寸时兼顾完整目标与8像素输出宽度，目标真实中心误差上限4个显示像素，黑边本身逐像素对称。
- 沿用现有FRAME_ID、渲染配置、处理context、任务nonce和提交握手；不新增帧池或图像缓存。

## 保留的前轮回调修复

FOMO的长卷积会轮询按键并更新控制状态，但完成回调先于主循环下一次control_center_step。旧代码可能在关闭AI、切换基础模型或重新发起居中后，仍接受前一任务的结果并提交ROI。

修复位于共享的control_center_fomo入口：先执行已有control_center_step，处理取消、过期和新请求，再检查完成任务nonce并接受结果。没有在每个调用方复制检查，也没有新增状态字段或硬件寄存器。

新增回归先在旧代码上复现失败，再通过新代码；覆盖关闭AI、切模型、重新请求及恢复全幅。原F0/F1、独立阈值、菜单确认/取消、无目标、旧坐标变换、已有ROI逆映射、历史忙状态和FOMO身份测试继续通过。

## 离线证据与范围

当前证据目录：F:/Project/fpga/vision_base/results/center_symmetric_20261022/。前轮单边留黑/回调修复的原始证据保留在results/auto_center_roi_20261022/，本轮另存，没有覆盖。

- RV32I QEMU实际运行生产控制/融合头文件：4655个断言，636组几何参数、8组诊断UI向量；新增225组奇数/极小尺寸的四角、四边与中心位置测试，覆盖全部倍率。F0新增捕获后提交、F1持有帧和前轮取消/重发路径继续通过。
- 六份实际固件提交描述符回放到生产axi_line_reader/roi_scaler/roi_axi_scaler，使用原生2560行宽上限、32拍突发/FIFO及总线/像素背压。
- 9465856个真实RTL输出像素与独立整型最近邻参考一致；六例左右/上下边距分别相等，目标中心误差为0。636组参数检查整体保留≤4显示像素的真实中心误差上限，同时逐组检查完整目标、等比缩放与严格对称留边。
- 两份描述符来自几何路径与已有视图逆映射，另四份是框计算的贴边、长目标和手动倍率边界用例。输入目标框是联调夹具，不是本轮相机或新模型识别结果。
- 预览左图是与RTL内存响应一致的合成源场景，橙框是固件ROI；右图为真实RTL缩放像素按固件输出位置放入画布。画布拼接在主机完成，不作为完整HDMI扫描或板上显示验收。
- 本轮异步ROI live链路73728像素/24完整帧通过，包含左右12、上下11像素的对称画布、X=4 mod8和奇数Y位置、同源重渲染及故障恢复。前轮19核心保持为既有证据，本轮未重复计为新执行。

本轮未修改生产RTL，没有重跑整机P&R。沿用中文位流原生实测57745/60800XLR、246/256RAM、62/160DSP，WNS+0.108ns/WHS+0.027ns，余3055XLR/10RAM/98DSP。片上资源增量为0；原RGB24图像回读和5RAM快照保持，中文菜单/图像算法/相机设置保持。

## 当前配套制品

- 位流继续用F:/Project/fpga/vision_base/results/sidebar_chinese_20261022/release/ti60f225_oob.bit。
- 完整DDR应用更新为F:/Project/fpga/vision_base/results/center_symmetric_20261022/firmware/vision.elf，185728B，比前轮增加160B；BSS66104B保持。
- 原权重F:/Project/fpga/vision_base/models/shape_cards_bringup/shape_cards_weights.bin保持。
- 新190160B离线启动包为F:/Project/fpga/vision_base/results/center_symmetric_20261022/release/vision_boot.bin，按既有VBO1格式和CRC契约检查；仅生成文件，没有写Flash。紧凑救援程序6784B仍在8KiB内，基础DDR应用9064B也已编译。

新应用仍保留FOMO、原INT8、FlyHash、80节点连接组及伴随读出。旧Flash程序和旧DDR应用都保留；后续加载这份新DDR应用才能使用对称留边规则以及保留的取消/重发修复。

## 复现关键检查

```powershell
python -E -X utf8 scripts/test_sidebar_center.py --output-dir results/center_symmetric_20261022/control
C:/iverilog/bin/iverilog.exe -g2012 -s tb_roi_axi_scaler '-Ptb_roi_axi_scaler.CENTER_REPLAY=1' -o results/center_symmetric_20261022/render/center.vvp sim/tb_roi_axi_scaler.sv rtl/axi_line_reader.sv rtl/roi_scaler.sv rtl/roi_axi_scaler.sv
C:/iverilog/bin/vvp.exe results/center_symmetric_20261022/render/center.vvp +vectors=results/center_symmetric_20261022/control/center_vectors.mem +output=results/center_symmetric_20261022/render
python -E -X utf8 scripts/test_center_render.py --output-dir results/center_symmetric_20261022
```

运行目录为F:/Project/fpga/vision_base，Python使用本项目既有运行时。硬件返回后先做SRAM及DDR加载验证，再验收实物识别、实体按键、F0/F1居中、对称留边、恢复全幅和原图/各模式回读；Flash继续保持现状，后续按明确指令处理。
