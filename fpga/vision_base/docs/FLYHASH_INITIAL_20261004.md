# 果蝇神经网络初步实施

先采用 FlyHash-inspired 稀疏投影/WTA 原型，不把模型路线锁定为用户最终选型。依据 [Dasgupta、Stevens、Navlakha的2017年论文](https://courses.csail.mit.edu/6.852/brains/papers/DasguptaStevensNavlakha.pdf) 的果蝇嗅觉回路策略，而不是FlyVis视觉连接组复现。

已交付 `models/flyhash.py` 标准库参考、固定投影ROM `models/flyhash_projection.mem`、可综合 `rtl/flyhash_encoder.sv`：64个uint8特征→256个Kenyon单元，每单元6条不同连接求和→保留最高13个响应。相同fan-in使共同均值/尺度归一化不改变WTA排名，编码核没有乘法器或除法器。相等分数取较小单元编号，输出256bit稀疏hash以及锁存的frame/config ID。

参考提供8×8边缘占据率特征和Hamming原型匹配。输入JSON必须含64个features、uint32 frame_id/config_id，可用 `python -E models/flyhash.py --input REQUEST.json` 运行。256×6投影可直接用uint8连接索引存放，约1.5KiB；uint8输入64bytes。

32组零、全亮、梯度和随机输入与参考逐bit一致，包含同分、输入气泡、帧号锁存和复位。含10个输入气泡的完整任务4950周期；按100MHz假设约49.5µs。Ti60F225映射FF1002、LUT1343、RAM3、DSP0；只有map证据，尚无板上推理计时。

复验纳入 `scripts/verify.ps1`，参考先生成fixture，再运行 `tb_flyhash_encoder`；单独映射 `scripts/synthesize.ps1 -Top flyhash_encoder -Flow map`。证据在 `results/flyhash_20261004/` 和 `results/flyhash_encoder.map.rpt`。

这是相似性编码器和原型匹配基础，不是已训练的圆/矩形或通用物体识别模型。真实ROI特征接入、独立采样训练/测试、未知阈值校准、几何融合和RISC-V控制尚待实施；本原型不替代原项目INT8/TinyML目标。

2026-10-05追加：编码核已集成真实Ti60主链并写SRAM。冻结ROI的FPGA Canny位图经主机提取64个占据率特征，再由板上编码，frame/config/epoch与实际冻结任务核对；真实当前空边缘平面以及32组人工向量全部逐bit通过。计算计数现在排除LOAD阶段的输入等待，固定4877周期；板上148.5MHz约32.84µs，完整实际边缘读图4.375s、特征传输/编码核对0.109s。新USER2控制与错误取消、完整P&R/板测见`results/project_advance_20261005/REPORT.md`。当前空输入不作为实物分类验收，特征提取仍在主机，实时片上特征、标签/未知阈值/几何融合继续实施；上述初期map-only状态是历史记录。

本日光照恢复后的后续版本：占据率提取已移入`vision_edge_features.sv`，复用Canny消隐读口、64个计数器及串行整数归一化，直接馈入编码器。源1/配置1/epoch39的2960像素非黑边缘输入，全部64项向量与独立参考逐值一致，256bit结果与同源host输入一致，另32组人工向量通过；提取加编码完成状态约62ms，编码仍4877周期。0x54是默认片上任务，0x50/51用于参考；0x56/57支持实际特征读回并恢复hash页。当前仍是冻结任务及主机启动，不是自动连续分类，类别/未知阈值/几何融合与RISC-V/INT8范围未完成。资源和证据见`results/project_light_20261005/REPORT.md`；前面的host提取状态属于历史制品。
