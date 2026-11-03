# 2026-10-22 GitHub 快照：中文菜单、对称居中和运动提示

本次继续更新私有仓库Sregetic/efinity-mcp的sync/fpga-20261007分支及PR #6，保持草稿，不合并main。源工程F:/Project/fpga/vision_base，独立上传目录F:/efinity-ci/upload-current-20261007。远端codex/non-brain-motion-20261022和既有PR/分支保持。

## 当前交付

- 中文两层菜单：四分类、17项、64px行高，KEY0进入/确认/长按返回，KEY2/KEY3选择及草稿调节；全部八种显示模式和M7几何识别保持。
- 单目标一键居中/放大：几何或新FOMO目标绑定源帧/渲染配置；对称留边，保持完整目标、比例及倍率上限；保留FOMO取消/重发修复。不是持续追踪或全图搜索。
- “目标→运动提示”：固定ON/OFF时延相关，显示四方向/静止/待判及明确的保持标记；帧边界确认，冻结/历史暂停；不接管ROI、AI或DDR任务。移植来源为74cc8f2，未覆盖旧分支顶层、Gamma或引脚。
- 保留相机工作点、Canny显示与二值识别、Sobel独立阈值、历史/冻结/ROI重渲染、统一帧池/DMA、Sapphire、FOMO/INT8/FlyHash/真实连接组及RGB24图像回读。

最终整机59878/60800 XLR、249/256 RAM、63/160 DSP，WNS+0.237ns/WHS+0.027ns、未分配核心引脚0。新增运动模块首版60648 XLR，存储/累加器优化回收770 XLR，最终余922 XLR/7RAM/97DSP。图像快照仍5RAM，中文字库121字/4RAM，侧栏字体合计5RAM。完整DDR应用185888B、BSS66104B，原权重保持；8KiB救援程序6820B通过构建但没有更新CPU ROM。

## 配套文件（相对于fpga/vision_base）

| 内容 | 路径 |
|---|---|
| 操作说明 | docs/MOTION_SIDEBAR_20261022.md |
| 最新范围和状态 | docs/PROJECT_MASTER_STATUS.md、docs/SYSTEM_SCOPE_AND_ROADMAP.md |
| 当前位流 | results/motion_sidebar_20261022/release/ti60f225_oob.bit |
| 当前相机DDR程序 | results/motion_sidebar_20261022/firmware/vision.elf |
| 原权重 | models/shape_cards_bringup/shape_cards_weights.bin |
| 仅生成、未写入的启动包 | results/motion_sidebar_20261022/release/vision_boot.bin |
| 当前相机位流及绑定清单 | artifacts/camera/ |
| 最终报告与资源 | results/motion_sidebar_20261022/REPORT.md、resources.json、acceptance.json |
| 菜单和提示预览 | results/motion_sidebar_20261022/motion_ui_detail.png、motion_menu.png、motion_hold.png |
| 对称居中前后预览 | results/center_symmetric_20261022/symmetry_comparison.png |

新菜单要求本轮位流和DDR程序配套。最新可下载制品是离线候选，不是当前板卡状态。

## 验证与边界

本地已有原生map/interface/P&R/位流生成，以及RV32I4664断言/636居中参数/12诊断向量、62核心参考/864网格/57读出、24光栅八模式视频同步对照、中文字符/提示及原侧栏外像素、融合/边缘/前端/RGB24行快照验证。报告中分别标明完整前端与对齐输出注入测试。预览是RTL生成的合成场景，不是新相机照片。

本次上传复用既有整机和RTL证据，不重复构建或上板。SRAM仍按10-18、Flash按10-17最近现场记录；实际按键、相机运动精度/扰动、长时和真实断电待硬件返回。软件CI不代表新的原生FPGA或物理验收。

## 上传范围

上传当前源代码、传感器表、固件、仿真、工具、说明和精选10-22证据，以及当前配套位流/ELF/启动包。历史报告和预览保留，重复旧位流/应用、before备份、原始packed16像素、仿真可执行缓存、反汇编、工具链、厂商生成IP及Flash备份留在本机。已有模型和九幅真实模式图沿用10-20快照。

根目录适配器、全部工作流、Runner门禁及synthesize.ps1/efinity_env.ps1/program_vision_sram.ps1保持远端既有版本；没有扩展硬件任务、编程权限或信任边界。Git属性保留原生输入/初始化表/位流/启动包字节，避免换行转换破坏制品绑定。Sapphire生成硬件仍由本机已安装官方生成器提供。
