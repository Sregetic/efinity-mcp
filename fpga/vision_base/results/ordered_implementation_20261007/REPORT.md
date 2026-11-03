# 非AI任务实施与验收

2026-10-07。范围：A1/A2阈值交互、A6空心轮廓主机/RTL验证、X3行缓存处理与延迟测量。AI加载器、分析DMA、训练、推理没有在本轮实施；已有Sapphire/FlyHash保留。

## A1/A2

Sobel/Canny分别保存，M5/M6修改Canny，其余模式修改Sobel。实体键下限16、步进16、上限2047饱和，帧边界生效；KEY0模式/中值、KEY2加/KEY3减和历史索引优先级保持。USER2 opcode0x28/0x29显式设置两个阈值，原opcode2设置当前算法；CLI外部边界16..2047，直接协议写0在共享控制器限到16。

OSD显示模式名和四位十进制；Canny T为噪声下限后的有效阈值、R为设置值。板上已复现设置16而实际24，因此同时显示两值，避免把噪声下限保持误认为按键失效。网页切换模式先读对应算法阈值，避免把Sobel数值写到Canny。保存图像组按各模式读取阈值头，不再假设九种模式共用一个数值。

控制器160次短按等回归及独立设置/饱和/消抖/帧提交、OSD16/96/2047、边缘叠加和host图像codec通过。threshold_native原生54395XLR/235RAM/45DSP、最终WNS+0.028ns/WHS+0.026ns、未分配IO0，已写SRAM。实际USER2八项设置/切换/零下限核对通过；hud_images两张1920×48回读显示SOBEL T0096、CANNY T0128。实体按键本轮没有人工按压，用户明确不在硬件前，不将JTAG写入当物理按键动作。

## A6

新增models/shape_outline.py主机参考，沿用生产RTL的四角背景、绝对灰度差、行跨度填充、8连通单轮廓拓扑、面积/长宽比判别。对实际保存的顶棚和暗场回读，host与生产RTL各三帧640×480输入的类别/拒收标志/背景一致：顶棚NONE/flags6，暗场NONE/flags1。

主机14项空白/实心/空心/明暗反转/断口和噪声正例通过；生产RTL27项和复位通过。另用明确标为synthetic的1920×1080空心圆/矩形夹具验证生产默认ROI与参数，host/RTL分别CIRCLE、RECT，flags0、背景220。临时mem和vvp已由验证脚本清理。

这不是空心圆/矩形实物正例验收；现有真实图是非目标顶棚或暗场。用户明确不在硬件前，实物验收保留待现场操作，不重复要求照片，不用人工夹具计识别率。生产算法本轮没有凭空增加形态学或分类特例。

## X3

新增2PPC灰度窗口、3×3中值、Sobel直通支路，在ISP输出后、DDR之前逐对处理，四行灰度缓存，无整帧存储或DDR访问。默认1080p60显示、历史/冻结/ROI/Canny仍走原统一帧池；该算法支路没有被冒充为整个HDMI链已绕过DDR。

46080像素、30656内部像素与生产1PPC参考逐灰度/梯度/边缘对齐，中值开/关、1920宽和六行突发间隔通过。最初lane1用了上一对的错误字节，新回归在x4/y4失败；修正后通过，保留line_direct_before.log。测量比较的是中心(x-2,y-2)的原始到达时间，另测VS控制流水和ISP帧头到HDMI编码器输入首像素。

初次stream_native的直通支路计数每帧2073600像素、17周期，但显示延迟计数为0：Efinity报告generate作用域内line_direct.video_de无驱动，显示计数被常量优化。已将HDMI信号声明移到generate之前，重建stream_final_native；该中间版没有算显示延迟验收通过。初次比赛构建因此终止，改用修复后的源码构建。记录stream_before_samples.json保留失败数据，采样工具现在先写原始数据再验收。

显示测量按roi_frame_ok限定真实源帧，启动占位画面不参与计时；有效坏标签仍计display_unmatched。单元用例覆盖占位跳过、正常匹配、错误标签；比赛版关闭纯显示延迟探针，保留X3算法与行级测量。

qualified release_snapshot板上60秒通过：每帧2073600像素、源30.00384fps、pipeline17cycles=0.11448µs，中心像素25.79798–126.54545µs，ISP帧头至HDMI编码器输入首有效像素38.06865–54.75549ms；RAW overflow/capture discard/scan bad/display unmatched均0。这里没有计传感器曝光、MIPI入口或显示器内部延迟。

新增R设置值的最终构建与板上结果完成后补齐；此前release_snapshot资源58686XLR/243RAM/50DSP，release_competition57062/238/50，最终WNS+0.124/+0.188ns，WHS均+0.026ns。新增四行2PPC灰度缓存实际8RAM；资源相对上一轮235/230RAM增加8，不把功能增量算作释放资源。Flash始终保持。


## 最终制品与当前部署

final_snapshot：58759/60800XLR、243/256RAM、50/160DSP，WNS+0.128ns、WHS+0.026ns；final_competition：56669/60800、238/256、50/160，WNS+0.130ns、WHS+0.026ns。全部原生map/interface/P&R/bit生成通过，未分配IO0。比赛版关闭5RAM图像行快照和纯显示延迟探针，X3四行算法与行级统计保留；有明确disabled探针头，不返回假测量。

final_snapshot已实际写入SRAM，final_program.log设备0x10660A79并报告完成，Flash保持。最终60秒每帧2073600像素、源约30.0125fps；pipeline17cycles，中心像素25.79798–126.54545µs；ISP灰度支路帧头到HDMI编码器输入首有效像素38.06893–54.75703ms。RAW overflow、capture discarded、scan bad和有效显示标签未匹配计数均0。见final_board.json，不是传感器曝光或显示器光学延迟。

最终板上独立阈值/直接零写限16八项通过；final_floor_hud的真实像素逐glyph解码为CANNY T0024 MED1 F1 I2 C1 R0016，设置16、实际24可同时辨认。读取完恢复M1/F0、Sobel96/Canny128、median1、ROI关闭，无源帧锁定。图像导出仍会暂时冻帧，但本次仅48行条带，未替换网页完整九图。隐藏测试浏览器实际切Canny输入128、Sobel输入96、min16/step16通过；测试标签关闭，用户标签和服务保留。

当前A6暗场板上NONE/flags1，无实物正例；人工矩形/圆夹具只作为仿真数据。Sapphire已有固件保持，最终冷启动state1/100MHz核对通过，未实施新的AI训练/DMA/加载器。

X3当前完成的是DDR前算法支路。1080p60主显示仍使用DDR，整机HDMI旁路尚未实施；独立1080p30直通版或保持60Hz算法支路的选择已询问用户，未收到选择。A6实物和本轮人工按键动作也仍待现场操作。没有把这些项登记为全部完成。
