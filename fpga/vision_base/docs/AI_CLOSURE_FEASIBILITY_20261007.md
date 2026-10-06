# AI闭环可行性与实施顺序

2026-10-07。依据当前RTL、固件、2026-10-06原生资源报告和板上FlyHash运行记录；这是实施评审，尚未训练或部署分类模型。

## 结论

保留TinyML/INT8局部学习模型目标。先用已有Sapphire和signed INT8 dot4指令跑小型软件模型，厂商TinyML硬件加速器按实测热点接入。A6几何轮廓识别独立完成，不由神经网络替代。FlyHash目前是编码器，不是已训练的分类器。

TinyML是受资源约束的边缘学习应用；TensorFlow Lite Micro是软件运行时；Efinix TinyML Accelerator是可配置硬件。三者分别选择，不将导入整个参考SoC作为闭环前提。

## 已核对的边界

- 阈值改动前最近snapshot构建53539/60800XLR、235/256RAM、45/160DSP，余7261XLR、21RAM；competition53108/230/45，余7692XLR、26RAM。这些数字不包含2026-10-07新增阈值/OSD改动。
- RV32I、100MHz、2KB I/D cache、无MulDiv；CPU有独立DDR AXI客户端和dot4 CFU。已有板上Canny占据率/FlyHash任务的计算时间64.21987ms，单编码2.07811ms。该记录不代表训练模型的推理时间。
- 3840字节是4KB ROM扣除256字节bootstrap后的嵌入应用载荷限制，见firmware/vision/link.ld。DDR地址窗口配置128MiB，应用执行地址0x07000000。现有BSS/栈约束也须随更大应用重排；单删3840 ASSERT会让ROM装载越界。
- 当前FlyHash邮箱context要求ROI启用、源帧冻结、Canny结果hold，属于冻结任务闭环。连续分析须改成独立源帧lease，显示持续运行。
- DIRECT_SCAN占用了frame_pool的analysis lease用于直接扫描。现有analysis外部端口在该配置下被内部acquire/release替代。分析DMA接入前须为它增加独立所有权，保留扫描/冻结/历史的保护。
- CPU热复位下共享AXI在途事务清理尚待完成；USER1下载优先采用debug halt/load/resume路线，验证cache可见性和在途事务，避免把CPU reset当成已验证的下载步骤。

## 按用户顺序执行

1. A1/A2：Sobel/Canny独立阈值；实体键下限16、步进16、饱和上限2047；帧边界生效。OSD给出模式名和十进制实际阈值，Canny显示自适应噪声下限后的有效值。先仿真，再原生构建和实体键/回读验收。
2. A6：先在真实回读灰度/边缘图上找闭合轮廓，核对填充面积、矩形度、圆度、边界框和开放轮廓拒收。按采集批次保留独立实物样本。主机通过后移植已验证算子到RTL，实物识别另验。
3. 加载器：开发期复用USER1 CPU debug下载DDR ELF/程序与权重；ROM只保留小启动入口。统一应用、模型、输入、arena、栈的地址，处理I/D cache。先验超过3840字节程序，再验模型。SPI用于最终独立上电部署，核对实际Flash布局后实施。
4. 分析输入：独立lease取得几何结果对应的源bank/frame_id，不默认读取最新帧；源帧已退出历史则丢弃该分析请求。复用现有AXI reader和ROI缩放，生成小灰度/边缘张量并发布到DDR输入双缓冲。CPU先读稳定输入逐值核对，再连续调度。DMA写CPU读取的内存需有明确D-cache无缓存映射或维护操作，完成中断本身不证明缓存可见。
5. 学习模型：第一版在同一ROI上提取8×8灰度和8×8边缘占据率，训练128→32→4的INT8 MLP；4224个权重字节、4224 MAC，不含偏置、量化参数和代码。圆、矩形、其他、空白四类为拟定初始任务，以实物样本验证后固定。FlyHash同输入做原型/Hamming对照，保留其独立贡献。
6. 若特征MLP缺失局部细节，再试32×32灰度小CNN。候选valid3×3Conv8→2×2Pool→valid3×3Conv16→GAP→FC4，卷积/FC约259552 MAC、1288个INT8权重，最大单层输出7200bytes。数字只描述该候选结构，不是精度或板上速度保证。
7. INT8导出与固件：代表性相机样本校准，输入/权重/偏置/每层重定标/舍入/饱和契约固定；PC定点参考与RV32I逐层一致，再用现有dot4替换热点。固定小MLP可用静态C算子；需要更复杂模型图时接TFLM并只注册实际算子，实测tensor arena。标准.tflite模型、类别/预处理/量化参数保留。
8. I1：按几何定位裁出局部ROI，与整图缩小对照漏检和精度；不是仅把现有整图特征改名ROI。
9. I3：发布frame_id/config_id/model_id/ROI/几何量/AI分数/耗时，同帧融合；几何与AI冲突、低分或过期结果明确标记待复核。在对应源帧的边缘图叠加识别，冻结后复算同一源。
10. X3：最后增加保留行缓存的旁路链，并分别测像素算法、整机输入至输出延迟和持续吞吐。相机约30fps、HDMI60Hz当前不同步，纯FIFO替换DDR会产生供数缺口；直通工作点需要单独匹配帧率/消隐。用行数和时钟周期报告有限延迟，字面零延迟不作为测量结论。

## 验收门槛

训练/验证/测试按实物或采集批次隔离，避免相邻视频帧泄漏；覆盖空白、纹理、阴影、旋转、断口、细线和不同尺度。记录几何、MLP/FlyHash、融合三者的混淆矩阵及unknown/漏检；相同输入逐层定点输出一致。连续板测报告采集Hz、显示Hz、分析Hz、P95/最大延迟、结果年龄、DDR/丢弃计数和最终原生资源。初期分析5–10Hz只是工程目标，以板测确定。

## 官方资料

- [Efinix TinyML Generator](https://github.com/Efinix-Inc/tinyml/blob/main/tools/tinyml_generator/README.md)：全整数量化模型分析、按实际层选择Lite/Standard加速及资源估计。
- [TFLM memory management](https://github.com/tensorflow/tflite-micro/blob/main/tensorflow/lite/micro/docs/memory_management.md)：tensor arena和实际分配统计；模型文件大小不等于运行空间。
- [Full integer quantization](https://developers.google.com/edge/litert/conversion/tensorflow/quantization/post_training_integer_quant)：代表性样本、整数算子限制和整数输入/输出。
