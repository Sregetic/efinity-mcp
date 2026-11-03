# 交接的形状检测模型

来自用户提供的Ti60_给朋友_模型接入资料.zip；原始TFLite模型、接口JSON、验证JSON及四组PNG/int8输入/参考输出保持原样。交接中的C++数据数组不重复保存，构建时通过`.incbin`直接使用二进制，避免同一模型的多份文本副本。

部署入口：F:/Project/fpga/vision_base/docs/SHAPE_FOMO_INTEGRATION_20261011.md。

HANDOFF.md为原交接说明，里面“尚未找到Sapphire”等描述反映交接方当时看到的工程，不覆盖本项目当前状态。当前已接入Sapphire、DDR加载器与灰度分析DMA；FOMO需要的RGB96×96输入与完整后处理另行集成。

本包只有四组联调向量，不含训练脚本、完整训练集、独立准确率报告；四组输出和实物识别验收分开。

2026-10-11：固定图最终CFU提速已板测，约0.949秒/张、较软件参考27.36倍，四组2304B完整输出逐字节相等、片上资源增量0。构建选`--cfu-kernels`；正式结果见F:/Project/fpga/vision_base/results/fomo_speed_20261011/REPORT.md。相机RGB ROI、后处理/OSD、端到端延迟和实物准确率仍与固定图验收分开。
