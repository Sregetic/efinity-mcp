# 全屏几何、Sobel可见性与Canny硬件偏置修复

## 当前板上结果

完整Ti60相机项目已写SRAM，配套186016B DDR应用和4400B原权重逐字节回读一致后启动。Flash保持，断电/CONFIG仍回原Flash。原八模式、实时菜单、中值直接切换、ROI/统一帧池、AI/CFU/FlyHash/连接组与RGB24回读保持。

当前恢复实时M7/MED1/F0，Sobel/Canny96、形状阈值32，全幅/ROI关闭，源/Canny持有0；保留用户进入前的八模式第三列编辑状态。最终错误、render_deadline_misses为0。约19.766秒健康检查源29.9504fps，RAW溢出/采集丢弃/扫描坏帧均0。X3探针完整读数保存在live_stream.json；本轮不据此重新验收既有低延迟目标。

## 几何识别真正扩大到全屏

生产vision_display给shape0显式范围(4,4)-(1920,1080)，不再使用中央640×480默认区域；原前端左/上4px无效黑边保持。原中央虚线提示删除，目标框、融合和一键居中沿既有全屏坐标/逆映射使用。分类器默认值和旧显式ROI工具/测试保持，不改变旧调用契约；FOMO FIX仍用已提交ROI或原固定分析区。

21bit面积可覆盖全屏有效像素，坐标、逐行跨度、包围面积、四角背景计数宽度足够，未扩大RAM。新sim/vision/tb_shape_fullscreen.sv沿真实display→classifier调用验证：旧版第一个旧中心外对象失败，新版12例通过，含四角实心/空心矩形、两侧圆、贴近四边、大于1.6M包围面积及原中央对象。日志geometry_fullscreen/candidate/simulation.log。当前整机M7与同源M0在HUD外0像素不同，中央框确已消失。

识别方法仍要求单个完整实心/闭合目标、均匀背景；四角16×16区域继续估计背景，目标须避开这些采样角区并与画面边界留距。实物四角摆放及误判记录另验。

## Canny虚线的硬件根因

诊断源1679/epoch1068：85点各采两类数据，共170记录。邻域tile85/85、斜率85/85正确，81个长窗和4个短窗center全部比应有值小64（即4显示像素）。宽偏置合并进DSP后，原生映射采用ABC级联。长窗应加260、实际等效-252；短窗应加130、实际等效-126，均对应center偏移-64。

用同一接受二值图，仅将数学模型center的+32改成-32，其余规则不变，按既定(+2,+2)显示流水位置，右侧去HUD1497600像素与实际**0差异**。这排除了阈值、二值图、斜率和邻域取样作为该重复虚线的来源。见trace_board/analysis.json、trace_board/bias_reproduction.json、trace_board/images/mode_5.png。

修复仅保留DSP舍入偏置2/4，移位后显式+32，避开宽ABC级联；原采样半径、追踪/邻接规则、阈值和二值识别图不改。最终原生line_fit由3个DSP变为2个直接(A*B)+C，无该ABC旁路。所有临时probe端口、寄存器与page4替换已删除；仅在trace_release/probe_sources保存诊断版本。

最终完整应用锁定源36282/epoch88：原图2050边缘点、8分量，前后4050字相同。按诊断前已确定的(+2,+2)位置比较，排除原无效边界和HUD后2046208像素与正确参考**0差异**；参考/实际均8分量。完整实际RGB已查看，本次复现的长边虚线消除。见board_final/comparison.json、board_final/images/mode_5.png和board_final/reference_correct.png。

历史canny_locked和board_after尖角位图在当前数学模型中仍为11/14个分量，原图均9；本轮没有改变曲线模型，不能将当前场景通过写成所有极尖角连续性完成。

## Sobel不再把弱边缘压得过暗

已被阈值接受的亮度改为min(255,128+floor(mag/2))，未接受仍黑；M2和M3共用，原M4叠加与二值识别掩码保持。T96最终实机非黑亮度最小/P10/中位/P90/最大为[176.0, 186.0, 238.0, 255.0, 255.0]。上方线条已在实际mode_2.png查看；没有通过降低阈值增加噪声。

## 针对性检查与资源

- tb_canny_fit新增256个signed center组合；原90112追踪选择、8256覆盖率、138240栅格像素（6528拟合）通过，见canny_center_fit.log。
- tb_edge_strength覆盖弱边缘、饱和、分屏及原Canny/叠加路径，见edge_strength.log。
- 为解决诊断构建实际22层帧池选择长路径，latest选择去除串行年龄计数依赖，并采用原pool_late_bypass后置元数据旁路。原compute/frame_pool/unified_history（130048像素）和5组BANKS/HISTORY各20004周期公开端口A/B一致，总100020周期；完整身份、同拍完成+获取、六帧历史和租约不变。未采用其他审计候选。
- 最终原生map/interface/P&R/pgm通过，59766/60800XLR、239/256RAM、65/160DSP；比上一板收回561XLR/1DSP，RAM保持。WNS+0.137ns/WHS+0.026ns、核心未分配引脚0，既有14项接口标记保持。
- 未重复整套未变化的固件/AI和38视频回归；原菜单30个板上状态属于配套同一ELF的既有证据，本轮实际恢复并确认第三列编辑状态。

## 部署与启动恢复

SRAM回执program.json绑定URL ftdi://0x0403:0x6011:4:b/2、IDCODE0x10660A79。第一次配置后USER2可用，但RGB采集计数0、25kHz USER1无法halt，5kHz也未恢复。CPU复位依赖DDR校准完成。重配同一通过门禁的位流以重新初始化启动链后，RGB计数383、25kHz halt正常，再加载并核对完整应用成功。原失败和恢复日志在firmware_load/，没有回退旧位流或写Flash。冷启动可靠性未计通过。

制品位于release/：ti60f225_oob.bit/hex、原生报告/manifest/build_status、配套vision.elf及shape_cards_weights.bin。完整加载回执firmware_load/result.json；复用现有scripts/program_vision_sram.ps1和scripts/load_vision_ddr.py，USER1为25kHz、超时2400秒。源码差异source.diff；改动前原文件before/。本轮未上传GitHub。

实体按键电气按压、物理HDMI、实物四角/空心卡、长时和冷启动仍待验；历史尖角数学重建分裂仍是算法待办。scope内数字/图像和恢复证据保存在acceptance.json及上述文件。
