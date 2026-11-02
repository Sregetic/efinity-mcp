# FPGA视觉项目入口

本目录是完整Ti60视觉系统，遵循全局C:/Users/Sregetic/.codex/AGENTS.md；这里补充项目范围与事实入口。

- 涉及项目目标、集成、资源或下一步时，先读docs/PROJECT_MASTER_STATUS.md最新摘要/正式目标表及docs/SYSTEM_SCOPE_AND_ROADMAP.md相关段落。
- 原技术方案、研究来源和当前制品路径由上述文档指定；数字以当前报告与实际运行状态核对，历史日期段落不当当前状态。
- 范围保持B1–B5、A1–A6、X1–X7、I1/I2/I3、F1/F2、V1/V2。真实连接组加入局部分析支路，不取代ROI、帧池、RISC-V、TinyML或协同加速。
- FlyHash编码、真实连接组网络、常规INT8/TinyML是不同方法，分别记实现与验收。公开作者成绩、合成联调、原生P&R、板上数值与实物效果分开。
- 保留既有帧持有/DDR仲裁/CDC、二值识别掩码、消抖与帧边界提交、原图/模式回读。源帧配置与ROI渲染配置先核对实际ABI，I3不混用。
- 摄像头60fps与MIPI LCD是用户明确暂缓；其他范围仅按用户明确调整。SC2210分支复用整套系统。
- 当前硬件制品、未验收项与资源余量读取状态表，不将计划/候选写成已上板。默认在实际缺口上推进，已验收链路无需重做。

- 当前输入接入任务在board/ti60_hdmi（HQ12 HDMI）；原摄像头备份见backups/camera_before_hq12_20261101。当前SRAM、Flash与未部署诊断候选必须按总状态表区分，用户基础验证期间不擅自重配或冻结画面。

- HQ12正式SDI固化制品在results/hdmi_finalize_20261101/release，回执与原Flash恢复备份在该目录flash/；视图六项为即时调节。当前验收边界与物理重新加载确认读取总状态最新摘要。

- 最新多目标连续轨迹/框内方向临时版本在results/multi_target_motion_20261102/lines/reset_release；Flash仍是上一SDI版。首帧启动修复、真实运行及验收边界见该任务REPORT.md/lines/acceptance.json，不把点版现场确认当成线版确认。
