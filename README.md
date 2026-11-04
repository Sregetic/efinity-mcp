# 基于 FPGA 的实时图像边缘检测与智能识别系统

基于 **Efinix Ti60F225I3 + Sapphire RISC-V** 的实时视觉作品。当前输入为 **HD-SDI 摄像头 → HQ12 → HDMI IN**，经板上处理后从 HDMI OUT 输出。

## 作品功能

- **分级菜单与即时预览**：板上 KEY1 打开/返回菜单，KEY2/KEY3 上下选择，KEY0 进入/确认；显示模式与视图参数调节即时生效。
- **图像处理**：彩色原图、灰度、Sobel/Canny 边缘及叠加显示，可调边缘阈值、中值滤波、ROI、缩放与平移。
- **边缘几何识别**：M7 按边缘与轮廓判断圆、矩形和清晰印刷体 A–Z/a–z，最多四个候选，显示逐目标框与标签；人脸当前停用。独立 FOMO 保留。
- **一键居中与持续跟随**：从实时目标列表选择一个目标居中，可固定初始倍率持续平移 ROI 跟随，并支持重新选择。
- **运动方向与轨迹**：果蝇启发的局部运动支路辅助搜索；各已识别目标的方向与最近三秒轨迹来自实际中心位置和时间，不要求先居中。
- **帧缓存**：实时、冻结、历史浏览与对比模式通过板上长按快捷键操作，侧栏没有独立入口。

具体使用和已知条件见 [项目说明](fpga/vision_base/README.md)、[M7 字母](fpga/vision_base/docs/M7_PRINTED_LETTERS.md)、[轨迹与跟随](fpga/vision_base/docs/M7_FOLLOW_TRAJECTORY.md)。

## 代码与构建入口

| 目录 | 内容 |
|---|---|
| [`fpga/vision_base/`](fpga/vision_base/) | 视觉系统源码、固件、模型、约束与必要验证输入 |
| [`fpga/vision_base/board/ti60_hdmi/`](fpga/vision_base/board/ti60_hdmi/) | 当前 HDMI 输入整机及原生构建入口 |
| [`fpga/vision_base/docs/`](fpga/vision_base/docs/) | 数据流、协议、操作和系统状态 |
| [`fpga/vision_base/results/`](fpga/vision_base/results/) | 与本项目有关的分阶段报告和验收证据，日期不代表当前部署版本 |
| [`fpga/参考资料/`](fpga/参考资料/) | 赛题与器件、TinyML 技术资料 |
| [`fpga/output/`](fpga/output/) | 本项目技术方案和参考工程评估 |
| [`scripts/runner/`](scripts/runner/) | 既有隔离构建与受保护 SRAM 下载工具 |

原生构建需要 Efinity、RISC-V 工具链，以及构建说明列出的第三方接收器文件和官方生成的 Sapphire 网表；这些依赖不随本仓库重新分发。详见 [HDMI 构建说明](fpga/vision_base/board/ti60_hdmi/README.md)。

Runner 保留原相机工程的构建契约，不自动切换成 HDMI 整机；当前作品使用上面的 HDMI 构建入口。Runner 工作流仅手动触发，构建和烧录分开，原审批门控保留。[Runner 说明](docs/self-hosted-runner.md)。

## 源码、运行版本和 Flash

当前源码整理候选为 339000 B、BSS 612112 B。相关已验证临时硬件为 56540 XLR / 240 RAM / 63 DSP；Flash 仍是此前 SDI 固化版。源码上传不代表重新烧录或新增现场验收，具体以 [项目总状态](fpga/vision_base/docs/PROJECT_MASTER_STATUS.md) 和 [源码快照](fpga/vision_base/docs/GITHUB_SNAPSHOT_20261102.md) 为准。

## 仓库范围

本仓库当前目录只维护这套视觉作品及其构建、验证资料。原来的 Efinity MCP 适配器服务、客户端配置示例、包清单和专属测试已移出当前版本；仓库 URL 保持不变。旧提交仍可追溯，不在本次清理中重写历史。

自动 CI 检查 Windows 部署入口与构建拒绝门控，不访问板卡，也不替代 HDL 仿真、Efinity P&R 或现场验证。项目算法与视频验证入口见 [代码结构](fpga/vision_base/docs/CODE_STRUCTURE.md)。

## 许可

原创代码沿用仓库 [MIT License](LICENSE)。第三方代码、模型和厂商资料按各自许可使用，原有版权声明保留。
