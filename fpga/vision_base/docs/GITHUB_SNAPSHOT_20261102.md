# 2026-11-02：当前SDI/M7源码与可读性整理

本快照已通过[PR #6](https://github.com/Sregetic/efinity-mcp/pull/6)于2026-11-03合入`main`。2026-11-05另行移出根目录的旧MCP适配器服务、示例和专属CI；视觉源码与Runner门控保持，不操作板子。

## 从这里开始

- 使用：[项目README](../README.md)、[轨迹与跟随](M7_FOLLOW_TRAJECTORY.md)。
- 源码：[状态/协议/测试数据流](CODE_STRUCTURE.md)。
- 构建：[HQ12工程](../board/ti60_hdmi/README.md)。原生构建需要本机第三方接收参考文件与官方生成的Sapphire网表，目录已明确；这些不重新分发。
- 已验证状态：[总状态](PROJECT_MASTER_STATUS.md)、[本轮整理报告](../results/code_readability_20261102/REPORT.md)、[提速实测](../results/m7_speed_20261102/REPORT.md)。

包括HD-SDI→HQ12→HDMI整机、KEY1返回、即时视图、无BASE生产入口、M7印刷字母/四目标、可选单目标持续跟随、各目标三秒连续线与框内方向。人脸保持停用，独立FOMO与M0–M6边缘算法保持。

本轮整理用具名阶段/协议常量和清晰控制流替代裸数字/密集语句；169帧判定输出完全一致，速度关键模块RV32指令保持，完整固件339000B/BSS612112B。板上提速记录仍为上一轮339016B应用，同输入后端耗时减少23%–34%；没有把整理版写入SRAM/Flash。

## 仓库保留什么

保留生产源码、约束、模型/固定测试输入、正式报告和小型验收记录。移出723项临时解压、构建/仿真产物、旧源码备份、重复压缩包及已退休检测器；本机文件和旧提交保留。原始资料压缩包的LFS历史对象不清理。

不要把`backups/`、`build/`、`outflow/`、模拟器工作目录或完整`results/`树再整体加入Git。按本轮报告选择需要保留的证据，板上照片与原Flash转储留在本机。已有Runner/编程门控和原生文件的`.gitattributes`保护继续使用。
