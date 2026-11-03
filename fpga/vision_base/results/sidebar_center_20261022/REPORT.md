# 侧栏菜单与单目标居中：离线实施记录

日期：2026-10-22。结论：已实现板端侧栏、选择/草稿调节/确认取消、单目标一次性居中和等比放大，复用现有 RISC-V、帧池与 ROI 渲染。**本轮只做离线验证，未访问板卡、未写 SRAM 或 Flash。** 实际部署仍按总状态中 10-18 SRAM / 10-17 Flash 的最近记录，未在本轮刷新现场状态。

## 实现与保留范围

- KEY0 长按打开侧栏 / 返回，短按进入和确认；KEY2/KEY3 短按上下选择或增减草稿。原八模式、独立 Sobel/Canny/SHAPE 阈值、中值、ROI/缩放/平移/显示位置、AI/SELFTEST/BASE/FOMO 均有入口，原长按冻结/历史规则保持。
- 新草稿只在确认后提交；取消不改实际参数。沿用原参数 VS 边界生效、ROI 配置序号、渲染完成与显示切换握手，没有 CPU 逐像素搬整帧。
- CENTER 等待新几何或一项新 FOMO 任务；先检查源/渲染/处理身份，再将检测坐标逆映射回原帧，使用现有 ROI 通路构图。自动倍率 1/2/4/8，手动上限可设；目标靠边时留黑边，保持纵横比，数学水平中心误差至多 4 个显示像素。
- F0/F1 支持居中；F2/F3 或正在提交时报告 BUSY。无有效目标报告 NO OBJ，处理/变换变化报告 STALE，不用旧框改新画面。FULLVIEW 恢复全幅并取消待执行的居中。它不是连续跟踪，实时 F0 不会因为居中自动冻结相机。
- AI OFF 时几何快照继续更新；AI 结果启用、身份匹配、坏扫描抑制仍保留。FOMO 沿用 FIX / AUTO 分析范围，AUTO 无几何候选会结束为无目标，不悬留 WAIT。推理错误继续走原错误路径，侧栏居中状态也结束为 ERROR。
- 新侧栏在最终视频模式/旁路选择之后叠加，不参与识别或 AI 输入，也不改变原图 ISP 旁路选择。侧栏外像素保持；RGB/DE/HS/VS 一致多 1 个 148.5MHz 时钟，约 6.73ns，无整帧 UI 缓存。
- SELFTEST 与 AI 菜单直接显示 ST NONE/WAIT/PASS/FAIL、AI IDLE/RUN/DONE/ERR；AI 关闭时也能查看自检结果。现有正常画面的 AI 身份/年龄判断和回读保留，运行 DONE 本身不等于实物识别通过。
- RGB24 原图/模式/最终显示回读继续存在，image_snapshot 仍为 5 RAM；CPU、cache、CFU、Canny 检测与抗锯齿、传感器初始化、帧池/历史/冻结保持。原 166 写 SC431 中心1080p RAW10四lane约30fps profile 不变。

CON4 魔数和原控制共享结构前 120B 保持，新增状态只追加。完整 DDR 应用进入时清除新增区，保留已有模式、阈值及 ROI。APB UI 字的低 23bit 保持，高 9bit 承载侧栏开关/编辑/条目/状态；诊断解码同步更新。原 `0x61` 旧菜单诊断和 `0x62` 按键注入接口保留。新增 UI 字库补齐 J，NO OBJ 状态不会缺字。

## 资源与程序容量

以整机原生最终布线报告为准，不把局部估算当整机结果：

| 项目 | 10-18 基线 | 本轮候选 | 增加 | 余量 |
|---|---:|---:|---:|---:|
| XLR | 56916 | 57821 | 905 | 2979 / 60800 |
| RAM | 241 | 242 | 1 | 14 / 256 |
| DSP | 62 | 62 | 0 | 98 / 160 |

最终 WNS +0.275ns、WHS +0.026ns，未分配核心引脚 0。Missing Interface Pins 与原板接口一样为 14，未将其写成全部接口引脚均使用。SDC、频率和 P&R seed 保持。

首版 57617 XLR /245 RAM；将两次菜单文字查表合并成一次后，侧栏只新增一份字库 RAM，没有删减既有回读。`first_pass/release/` 留存首版报告；最终值见 `resources.json` 与 `release/ti60f225_oob.route.rpt.xml`。

完整相机 FOMO + MLP/FlyHash + 80节点连接组及80→4伴随读出应用：184768B，较原178896B增加5872B；BSS仍66104B，原模型/权重保持。8KiB片上启动程序保持容量，紧凑构建为6656B；完整基础控制DDR应用8708B。四固定图FOMO调用方也完成构建，270528B，此处只计构建，不计板上四图重跑。

曾尝试把整个新菜单直接编进8KiB救援程序，实际链接超限；最终以 `VISION_BOOTSTRAP` 明确区分紧凑启动/救援与完整DDR应用，救援仍用原紧凑菜单，没有扩大片上ROM/cache。候选位流沿用原SoC/ROM配置，使用配套完整DDR应用获得新功能。SPI程序包189200B，含184768B应用、4400B原权重和32B既有VBO1头，已按原加载器契约离线打包；未写Flash。

## 已完成验证

| 检查 | 结果与证据 |
|---|---|
| 原生整机 | map / interface / P&R / pgm 四阶段通过；pgm 是生成位流，不是板卡烧录。最终日志 `native_release.log`，报告 `release/` |
| RV32I 控制 | `scripts/test_sidebar_center.py`：实际生产控制头文件、无M/A/C/F/D的QEMU执行，2525断言、407组几何；`control/result.json` |
| 交互/身份 | 选择循环、进入/确认/取消、独立阈值上下限、草稿ROI、VS等待、提交确认、全幅恢复、F0/F1/历史忙、旧结果及FOMO请求nonce；另含已有平移缩放窗口的逆映射、6组诊断解码 |
| 核心回归 | 19项全部通过，含实体引脚消抖/长短按事件RTL、控制CDC、AI OFF几何、帧持有、共享总线、分析DMA、ROI渲染及故障路径；`core_quick.json` |
| 视频回归 | 38项全部通过，含旧OSD、形状、Canny连通/噪声/重建、色调/中值/曝光、历史、RGB888图像回读、原FOV及完整Canny；`video_full.json` |
| 最终UI定向复测 | 完整两幅1920×1080场景、65536随机输入拍、3577692个侧栏外有效像素RGB/同步一致，字库A–Z覆盖；`sidebar_final.log`。旧HUD及AI关闭下侧栏自检/运行状态字符复测：`osd_final.log` |
| 文字表共享 | 同字库和页脚下，共享与重复查表262144拍逐周期一致；`osd_share.log` |
| 旧控制/融合 | 原RV32I控制和源/显示逆映射、发布身份回归通过，日志副本 `legacy_control.log` / `legacy_fusion.log` |
| 固件调用方 | 完整相机/连接组应用、基础DDR控制、紧凑嵌入启动、四固定图FOMO分别构建通过，保留各ELF/构建记录 |

宽度/边界测试验证的是构图数学和固件握手，RTL回归验证的是相应视频/帧通路；未把这些写成实物目标准确率或真实DDR/HDMI长时性能。FOMO推理速度本轮未重测，仍由既有模型决定。

## 交付

- 操作与后续实测：`F:/Project/fpga/vision_base/docs/SIDEBAR_CENTER_20261022.md`。
- 配套位流：`F:/Project/fpga/vision_base/results/sidebar_center_20261022/release/ti60f225_oob.bit`。
- 完整DDR程序：`F:/Project/fpga/vision_base/results/sidebar_center_20261022/firmware/vision.elf`。
- 原权重：`F:/Project/fpga/vision_base/models/shape_cards_bringup/shape_cards_weights.bin`。
- 后续自主启动用的离线包：`release/vision_boot.bin`；本轮不执行安装。
- `sidebar_menu.png` / `sidebar_edit.png`：实际RTL输出的合成场景UI预览，不是相机实拍，也不是板上居中效果证据。
- 源文件备份/差异：`before/`、`changes.diff`、`native_input_changes.json`；接收IP、Canny/色调/帧池等原生输入保持。

下一次板上操作需同时加载新位流与完整DDR应用，仅运行旧Flash应用仍是旧菜单。先仅写SRAM并用原USER1加载DDR，依次验菜单草稿/确认/取消、独立阈值、F0/F1居中及无目标/边缘目标、FULLVIEW、F2六静态历史与I6播放、AI、自检、原图及各模式回读。Flash待用户后续指令。
