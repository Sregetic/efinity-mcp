# 2026-10-20 GitHub 更新入口

本次继续上传到私有仓库 Sregetic/efinity-mcp 的 sync/fpga-20261007 分支及 PR #6，不自动合并 main。工程来源为 F:/Project/fpga/vision_base；独立上传副本位于 F:/efinity-ci/upload-current-20261007。源工程和实际 SRAM/Flash 未因本次上传改变。

## 当前版本

- 最新已验收 SRAM：56916/60800 XLR、241/256 RAM、62/160 DSP；WNS +0.285ns、WHS +0.026ns。RAW10 专用接收及 FIFO 1024→512 本轮净省 440 XLR、3 RAM。
- SC431HAI 中心 1920×1080、RAW10、4 lane、约30fps；HDMI 扫描1080p60。Canny、色调/中值等价优化、全部控制/历史/冻结/ROI/AI与 RGB24 图像回读保留。
- 满幅 ROI 45.318→17.279ms，实际发布20.031→29.991Hz；仍超过16.667ms预算，不计满幅60fps。
- 当前伴随应用加入80节点/1296边固定连接组之后的80→4 INT8读出，和 FOMO/旧INT8/FlyHash共存；读出约0.17ms。合成联调不是实物准确率验收。
- Flash仍是10-17固化版；断电/CONFIG会回该版。本次上传没有执行配置或程序烧录。

## 文件入口

| 内容 | 仓库路径（相对此工程） |
|---|---|
| 最新状态/完整范围 | docs/PROJECT_MASTER_STATUS.md、docs/SYSTEM_SCOPE_AND_ROADMAP.md |
| 最新整机位流与绑定清单/报告 | artifacts/camera/ti60f225_oob.bit、manifest.json及同目录报告 |
| 当前DDR伴随应用 | results/connectome_readout_20261018/firmware/vision.elf |
| 原模型/原权重与新增读出包 | models/shape_fomo/、models/shape_cards_bringup/、models/connectome_readout_bringup/ |
| 最新SRAM与九图验收 | results/csi_raw10_fifo_20261018/REPORT.md、acceptance.json、image_verification.json |
| 完整1080p原图/八模式 | results/csi_raw10_fifo_20261018/images/；总览all_modes.png |
| ROI性能 | results/roi_render_perf_20261018/REPORT.md、performance.json |
| 连接组读出 | docs/CONNECTOME_READOUT_20261018.md、results/connectome_readout_20261018/REPORT.md |
| 尚未合入的RAM候选 | results/ram_audit_20261018/REPORT.md（不是已释放资源） |

同步当前 RTL、传感器表、固件、模型、主机工具、仿真及10-17/18精选记录。旧仓库历史证据保留；工具链、Sapphire厂商生成硬件、编译/仿真缓存、Flash备份、重复旧位流和无关工程留在本机。新增位流/ELF是既有验收制品，本次未重新综合。artifacts/pattern、timing_probe等既有目录仍为历史版本，不作为当前相机版本。

## 构建与Runner边界

Sapphire配置和boot ROM输入在artifacts/vision_soc；netlist/BSP由已安装的Efinix官方生成器生成。普通Python和RISC-V工具链用于固件，Efinity 2026.1用于整机。当前传感器profile为board/ti60f225_v4/sensors/sc431hai_1080p30_center_4lane.json；实际构建顶层参数SAPPHIRE_ENABLE=1、RAW_TO_POOL=1、IMAGE_DEBUG=2，P&R seed1。初始化表/位流等不作Git换行转换，保留制品清单绑定的字节。

上传副本的synthesize.ps1只合入本机已实现的传感器profile/目标支持，同时保留Runner的vendor_exit_code、source_changes、失败状态、最新报告/非空位流门禁及服务账户profile；efinity_env.ps1和program_vision_sram.ps1沿用仓库版本。全部工作流保持，真实Efinity和硬件工作流仍只手动触发。不要把本次软件检查当成新硬件验收。

实物卡准确率、移动相机诱发的间歇紫闪、长时稳定和实际拔电启动仍待验；接收核独立像素仿真未建立有效旧版基准，未计通过。已有板上/图像/原生P&R证据分别保留，详见最新REPORT。

本次上传检查：results/github_upload_20261020/verification.json，传感器三profile/流/复位回归与Runner九项负例通过；81份主机Python语法检查通过。178项原生输入/制品的Git暂存字节与源工程直接比较一致，保留原生生成报告的原始空白。本次未重新运行整机P&R或访问板卡。
