# 2026-10-18 满幅 ROI 渲染提速（已写 SRAM，Flash 保持）

## 结果

当前 SC431HAI 中心1080p、完整CPU/AI/帧池/历史/冻结/识别及图像回读版本已经完成原生编译、SRAM写入和板上验收。满幅ROI平均 **45.318→17.279ms**，耗时降低 **61.87%**、速度 **2.623倍**；实际发布观测 **20.031→29.991Hz**。Flash、固件和模型均未写入。

|板上条件|持续时间|样本|最小/平均/最大渲染|观测发布更新|扫描欠载/采集丢弃增量|
|---|---:|---:|---:|---:|---:|
|原版满幅ROI，AI OFF|19.969s|1711|44.903/45.318/45.788ms|20.031Hz|0/0|
|优化版满幅ROI，AI OFF|59.984s|5021|17.191/17.279/17.381ms|29.991Hz|0/0|
|优化版满幅ROI，并发相机FOMO|29.985s|2321|16.293/17.545/18.425ms|29.682Hz|0/0|

计时来自100MHz硬件渲染计数，发布率通过快速USER2轮询真正不同的显示源帧计数，不用“源帧号差”冒充实际发布次数。基线/优化版轮询最大间隔31/32ms；并发AI为32ms。慢速USB默认延迟的早期采样仅保留作记录，不用于上述发布率比较。真实计数见 [performance.json](F:/Project/fpga/vision_base/results/roi_render_perf_20261018/performance.json)；采集约30fps、HDMI扫描刷新、渲染任务耗时、AI推理和JTAG导图时间是不同指标。

## 改动与根因

本轮172项原生输入仅有两个文件变化：

- [axi_line_reader.sv](F:/Project/fpga/vision_base/rtl/axi_line_reader.sv)：先预留整段读突发所需的FIFO空间，再发AR。已接受的突发不再因像素解包的背压而占住共享读通道；同步读槽与原有current/lookahead字缓存保留顺序和尾部语义。
- [roi_axi_scaler.sv](F:/Project/fpga/vision_base/rtl/roi_axi_scaler.sv)：ROI读队列由8字改为32字，与既有32拍突发匹配；扫描队列由共享reader默认值改为与既有64拍突发匹配。

原来两个8字FIFO分别接收32/64拍读突发，2PPC解包在FIFO填满后降低RREADY；仲裁器直到RLAST才释放所有权。现在等待发生在AR之前，等待期间其他DDR客户端可以继续服务。突发上限32/64、扫描低水位优先规则、单突发所有权、4KiB边界、地址/错误处理和帧发布边界保持。

缩放仍是原来的整数floor-DDA采样，没有改变算法或降低分辨率。相机寄存器/视场、时钟、色调/白平衡、中值/Canny重建、阈值/识别掩码、CDC、CPU/固件/权重与各模式RTL保持。没有通过关闭功能提速。

## 资源取舍

|项目|优化前|本轮实际位流|变化/余量|
|---|---:|---:|---:|
|XLR|56997/60800|**57356/60800（94.34%）**|增加359，余**3444**|
|RAM|237/256|**244/256**|增加7，余**12**|
|DSP|62/160|**62/160**|保持，余98|
|最终WNS/WHS|+0.254/+0.026ns|**+0.254/+0.026ns**|通过|
|image_snapshot|5 RAM|**5 RAM**|图像回读保留|

首轮“两路全RAM”也通过原生实现，但要251RAM，只余5。最终让32字ROI短队列用SRL、64字扫描队列用同步RAM：相对该候选省7RAM、多407XLR，并保持相同输出/周期；该候选没有上板。实际采用的是上述244RAM版，而非另一个裁减构建。详见 [resources.json](F:/Project/fpga/vision_base/results/roi_render_perf_20261018/resources.json)、[rtl.diff](F:/Project/fpga/vision_base/results/roi_render_perf_20261018/rtl.diff) 和 ram_trial 的原生证据。

## 仿真与现有功能

- 新增共享总线占用回归：旧reader在像素端暂停后保留已接受R突发，测试先失败；新8/32/64字队列均通过。对齐、非对齐、奇数尾部、4KiB边界、读响应错误和非法请求均核对；所有新测试已接受R突发的接收背压次数为0。
- 完整引擎的1280→1920、1920→1920及960→1920三组1080p输出，共 **6,220,800像素** 与独立地址/采样公式一致，含最终B响应后发布；另验证读/写错误不发布。
- 统一DDR/CPU各种字节写入、八银行六帧静态历史与I6播放、冻结/比较、同源重渲染、实时恢复、显示配置原子切换、非法配置、溢出中止和扫描饥饿恢复仿真通过。最终SRL/RAM混合版重新运行相关引擎/历史/实时链路，非只复用首轮结果。
- 板上既有 [ROI检查](F:/Project/fpga/vision_base/results/roi_render_perf_20261018/roi_board/board.verification.json) 验证满幅、2倍缩放、冻结、同源平移和半幅输出；扫描错误和丢弃增量均0。
- [按键策略板测](F:/Project/fpga/vision_base/results/roi_render_perf_20261018/key_ui/result.json) 17项通过：独立Sobel/Canny阈值与下限、中值、冻结/缩放/平移/位置、菜单、历史索引和恢复实时。通过真实CPU事件FIFO注入，并非人工按压验收。
- 原有Flash应用并发运行相机DMA/FOMO，完成序号27，累计分析DMA失败0，最后任务错误0，启动INT8/FlyHash/连接组三向量自检状态2（通过）。该任务预处理22.342ms、Invoke1246.523ms、后处理0.222ms、总1269.086ms。当前场景0目标；不计实物准确率，也不把不同任务输入作为严格AI性能A/B。

见 [verification.json](F:/Project/fpga/vision_base/results/roi_render_perf_20261018/verification.json)、[ai_result.json](F:/Project/fpga/vision_base/results/roi_render_perf_20261018/ai_result.json) 和原始日志。

## 实际图像

真实FPGA回读，源帧 **13010**、渲染配置 **20**。原图/Canny/Canny叠加三幅为1920×1080，另六幅取第500–523行（1920×24），涵盖Gamma前源图和其他全部模式。共3384个行头/帧/配置/模式检查，6,497,280像素传输。三幅整图和六幅条带均已查看。

|图像|尺寸|文件|
|---|---|---|
|M0原图|1920×1080|[mode_0.png](F:/Project/fpga/vision_base/results/roi_render_perf_20261018/images/mode_0.png)|
|M5 Canny|1920×1080|[mode_5.png](F:/Project/fpga/vision_base/results/roi_render_perf_20261018/images/mode_5.png)|
|M6 Canny叠加|1920×1080|[mode_6.png](F:/Project/fpga/vision_base/results/roi_render_perf_20261018/images/mode_6.png)|
|Gamma前源图|1920×24|[source.png](F:/Project/fpga/vision_base/results/roi_render_perf_20261018/mode_strips/source.png)|
|M1灰度|1920×24|[mode_1.png](F:/Project/fpga/vision_base/results/roi_render_perf_20261018/mode_strips/mode_1.png)|
|M2 Sobel|1920×24|[mode_2.png](F:/Project/fpga/vision_base/results/roi_render_perf_20261018/mode_strips/mode_2.png)|
|M3分屏|1920×24|[mode_3.png](F:/Project/fpga/vision_base/results/roi_render_perf_20261018/mode_strips/mode_3.png)|
|M4 Sobel叠加|1920×24|[mode_4.png](F:/Project/fpga/vision_base/results/roi_render_perf_20261018/mode_strips/mode_4.png)|
|M7识别|1920×24|[mode_7.png](F:/Project/fpga/vision_base/results/roi_render_perf_20261018/mode_strips/mode_7.png)|

回读前后4050个Canny位图字完全一致，共**4385边缘点**。满幅Canny与原有覆盖ROM/拟合/双采样/边界掩码/两像素中心对齐参考逐值核对，满幅Canny叠加与原图和原有32级混合公式核对：**各2,056,320像素，RGB差异0、最大误差0**，只排除OSD矩形，不排除四边或有色像素。分屏/Sobel叠加条带另各46,080像素差异0。

没有旧/新位流共用同一DDR原帧的实拍A/B，未用不同相机帧声称逐像素相等。最初对F1直通视图调用现有导图工具被其渲染lease检查拦住；随后按工具原契约取得ROI源帧lease导出，没有修改或放宽回读检查。图中F1仅用于同帧导出，当前已恢复F0。此轮不改变原图降噪，不将观察到的原有颗粒宣称为新优化。

详细结果：[image_verification.json](F:/Project/fpga/vision_base/results/roi_render_perf_20261018/image_verification.json)。

## 截止期与当前状态

原1666667-cycle（16.667ms）渲染预算保持，没有改阈值或清计数。AI OFF满幅平均17.279ms，仍略超过60Hz预算，60秒截止期累计增1800；这是渲染预算超时统计，不是扫描欠载。当前满幅30Hz源帧发布已经实测，**满幅60fps重渲染尚未达到**。并发AI 30秒截止期增824，扫描欠载/丢弃均0；详细值不隐藏。

最终已恢复**M5/MED1/F0/I0/menu0、Sobel128/Canny80/SHAPE32、ROI关闭且参数全幅、AI关闭/NN BASE**；Tone3、WB336/256/504、颜色顺序2保持。CPU state1、source_held/source_frozen/probe_hold均0，图像回读RGB24bit，六帧历史存在，错误/欠载/丢弃计数0。实际 [final_status.json](F:/Project/fpga/vision_base/results/roi_render_perf_20261018/final_status.json)、各final_page文件及 [acceptance.json](F:/Project/fpga/vision_base/results/roi_render_perf_20261018/acceptance.json) 已核对；没有遗留冻结或调试持有。

SRAM位流：[ti60f225_oob.bit](F:/Project/fpga/vision_base/results/roi_render_perf_20261018/release/ti60f225_oob.bit)，官方JTAG完成、IDCODE0x10660A79，收据 [program.json](F:/Project/fpga/vision_base/results/roi_render_perf_20261018/program.json)。Flash保持10-17版，程序/权重未下载替换；断电或CONFIG后回原Flash版本。移动相机诱发紫闪、实物识别、长时与物理断电不计本轮验收。
