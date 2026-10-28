# 2026-10-28 FPGA快照：M7边缘几何、人脸、多目标与Flash固化

本次更新沿用隔离worktree `F:/efinity-ci/upload-current-20261007`、分支 `sync/fpga-20261007` 和已有 [PR #6](https://github.com/Sregetic/efinity-mcp/pull/6)，不自动合并main。实时工程仍在 `F:/Project/fpga/vision_base`。

## 本次内容

M7使用生产Canny轮廓判圆/矩形，并将Pico人脸纳入同一模式，最多四目标。独立AI模型/推理与M0–M6语义保持。最终原生58458XLR/243RAM/64DSP，WNS+.109ns/WHS+.026ns、未分配核心引脚0；release及编译报告一同归档。

配置Flash 0地址与451776B应用包0x700000均已写入并校验；ROM SPI自加载447344B应用和4400B原权重后，实际DDR字节全部一致，无USER1程序下载。固化后背景M7约2.874s，视频29.875fps、溢出/采集丢弃/扫描坏帧0。配置Flash重载和物理断电尚未测。

17例主机/ASan/RV32I、服务租约/取消、队列及逐拍光栅等效、22项板上UI事件、实际RGB24及2046208像素0差异证据随快照保存。实物人脸/多目标、实体按键、物理HDMI和长时仍待现场。

结果入口：`results/geometry_m7_20261028/REPORT.md` 与 `flash_20261028/REPORT.md`；本机最终配置、ELF、权重在 `release/`，SPI包与写后回执在 `flash_20261028/app/`。GitHub按仓库既有约定只提交源码、可再分发模型/夹具和验收证据；位流、ELF、VBO1包及原Flash备份留本机，远端release目录保存构建报告和元数据。

## 仓库边界

仅同步工程源码、必要模型/夹具与决定验收的证据；原8MiB Flash备份、DDR实际读写分块、厂商生成IP、EDA缓存及中间失败位流不新增上传。保留仓库已有 `scripts/synthesize.ps1` 与Runner门禁，未用本机较弱版本覆盖它们。

仓库软件CI只验适配器/软件，不冒充原生P&R或实板。具体提交及CI结果由PR记录；Flash物理冷启动与实物准确率仍需现场验收。
