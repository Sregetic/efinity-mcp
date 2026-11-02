# BASE 已从当前工程和候选固件移除

## 用法与交付

“智能→模型”现在只保留 **FOMO** 和 **M7几何**，KEY2/KEY3在这两项间切换，KEY0确认。默认M7，推理/持续跟随/目标轨迹仍关闭。M7原一次性居中、四目标列表、所选单目标持续跟随和最近3秒轨迹保留；人脸仍停用。

候选：`F:/Project/fpga/vision_base/results/remove_base_20261031/candidate/vision.elf`；无外置权重启动包：同目录 `vision_boot.bin`。源码快照 `source/`，修改前文件 `before/`，差异 `changes.patch`。

**本轮没有访问板子、改SRAM/DDR或写Flash。当前板上仍是上一份已验收的黑屏修复版，仍含旧BASE入口；本报告的删除结果是工程源码和候选固件。** 新菜单RTL尚未重新全机P&R，不能把本候选直接称作已上板。

## 删除了什么

- 控制菜单、紧凑键菜单、CLI和本地网页不再提供BASE；保持FOMO=1、M7=2的已有线协议编号，0号槽退役并拒绝外部选择。临时替换DDR应用遇到旧0号选择时迁到M7，保持原推理开关与ROI。
- 删除相机主循环的128→32→4两层BASE MLP、hidden/logit数组和BASE权重校验。此前即使选FOMO也先额外跑BASE，现在直接执行FOMO，并用FOMO类别/分数发布结果。
- 自检仍验证dot4/MulHi、共享灰度特征、FlyHash和固定连接组，不再生成或运行BASE的隐藏层/分类分数自检。该自检通过不表示另做了一遍完整FOMO推理测试。
- 启动包和Flash/读回工具支持原VBO1格式的零长度外置权重段，不需要4400B BASE权重；老格式显式传权重的路径保留。打包/烧录辅助脚本要求显式提供ELF，避免默认指向旧BASE应用。
- FOMO算子、模型与后处理、共享FlyHash/连接组及可选训练读出、M7数值判定/局部边缘跟随、帧池/DDR/ROI和M0–M6算法均未改变。只删除OSD的BASE文字和专用字形，没有改Canny/Sobel。

`models/shape_cards_bringup/`内旧训练文件/权重以及历史部署包、恢复备份保留用于复现历史结果，不进入当前相机构建；该目录已标记RETIRED。共用的`shape_model.h`数学/特征函数仍供固定连接组读出及历史离线训练使用，当前候选没有链接BASE的`shape_dense`。

## 成本变化

| 项目 | 已固化旧应用 | 当前候选 | 变化 |
|---|---:|---:|---:|
| 应用加载字节 | 337080 B | 333912 B | −3168 B |
| 应用BSS | 611324 B | 611284 B | −40 B |
| 外置BASE权重有效载荷 | 4400 B | 0 B | −4400 B |
| VBO1启动包（含32B头） | 341512 B | 333944 B | −7568 B |
| FOMO内嵌模型 | 54640 B | 54640 B | 不变 |
| 外部DDR FOMO arena预留 | 262144 B | 262144 B | 不变 |
| 外部DDR固定控制记录 | 408 B | 408 B | 不变 |

4MiB APP区剩余3249108B。既有0x07400000起的2MiB权重地址区仍保留原ABI地址，不把停止装载4400B说成整个2MiB区域已回收。无新视频缓存或外部DDR工作区。

当前已部署整机为59441/60800 XLR、244/256 RAM、63/160 DSP；这是上一菜单位流的最终P&R值。新OSD删了文字/字形，本轮未跑新整机P&R，因此新候选XLR/RAM/DSP留空，不声称硬件节省。CPU删除了FOMO每次请求额外两层4224次MAC及对应BASE启动自检，未新测耗时；M7原来就不执行BASE，不把本次删除当作跟随提速。

## 自动验证

- 完整RV32I相机固件编译通过，ISA/DDR布局检查通过。
- 链接ELF没有`shape_dense`、BASE hidden/logit及其自检数组，保留FOMO、M7、实际跟踪器及共享诊断符号；反汇编没有对旧权重区域的加载。见`elf_check.json`。
- 生产控制策略QEMU：4883断言、636构图；覆盖两模型双向循环、退役0号拒绝、旧选择迁移、推理关闭、FOMO新结果居中/取消与坐标变换、M7四目标选择及跟随开关。见`control/`。
- M7服务与无脸跟随服务QEMU通过；共享RAW租约占用、实际源帧/时间、重排、局部Sobel位置关联、漏检/丢失/重选及手工ROI控制权保持。见`service/`、`follow/`。这不是重新取得的现场运动证据。
- 无权重共享特征/FlyHash/连接组自检通过，紧凑菜单控制通过。见`selftest/`、`control_compact/`。
- 网页/服务实际HTTP路由仅允许FOMO/M7，拒绝BASE=0，图集/并发串行化/来源检查通过。见`panel.log`。
- 生产SPI ROM在RV32I上10个用例通过，包括原加权包、损坏拒绝、非整字长度及零权重段；本候选零权重包通过原VBO1解析。见`boot_test/`及`candidate/vision_boot.json`。
- 生产侧栏RTL的模型值、七显示模式、四目标列表、RGB/同步通过：6幅完整1080p画面共12441600像素，11575133次面板外RGB检查；M7和FOMO实际渲染均已查看，文字/高亮正常。记录见`rtl/test.log`；菜单图见`rtl/model_menu.png`、`rtl/fomo_menu.png`。

首轮侧栏仿真新增第6幅FOMO画面后超过旧125ms仿真watchdog，前5幅像素检查通过；测试时间上限按6幅画面改为150ms后通过，实耗125.20277ms仿真时间；未改像素断言或生产RTL。首次超时原日志保留在`rtl/test_timeout.log`。

## 复现主要检查

```powershell
Set-Location F:/Project/fpga/vision_base
$py='C:/ProgramData/anaconda3/python.exe'
& $py -X utf8 -E scripts/build_fomo_firmware.py --camera --cfu-kernels --output-dir results/remove_base_20261031/recheck
& $py -X utf8 -E scripts/test_sidebar_center.py --output-dir results/remove_base_20261031/recheck_control
& $py -X utf8 -E scripts/test_ai_selftest.py --output-dir results/remove_base_20261031/recheck_selftest
& $py -X utf8 -E scripts/test_spi_boot.py --elf results/remove_base_20261031/recheck/vision.elf --output-dir results/remove_base_20261031/recheck_boot
& $py -X utf8 -E scripts/test_roi_panel.py
& $py -X utf8 -E scripts/pack_vision_boot.py --elf results/remove_base_20261031/recheck/vision.elf --output results/remove_base_20261031/recheck/vision_boot.bin
```

以上命令离线执行，不访问或烧录板子。新菜单的全机P&R、板上功能与Flash安装留在实际部署步骤完成，不覆盖当前已验收的Flash。
