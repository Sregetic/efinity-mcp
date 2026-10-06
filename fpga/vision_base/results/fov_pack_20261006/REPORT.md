# FOV 行缓存重排与图像回读开发版 — 2026-10-06

结论：`bayer_fov_reduce`由36RAM降到25RAM，额外净释放11块。比赛版整机233→222RAM、53951→53367XLR；完整调试版243→232RAM、55402→55368XLR。只保留RGB行快照的开发版实际为227RAM/53639XLR，快照实例占5RAM。三个配置都完成原生map/interface/P&R/位流生成，未烧录本轮候选；当前板上仍是上一轮243RAM的调试512版，SRAM/Flash保持原状态。

收尾只读面板状态为M0/T96/MED1/F0/ROIoff，配置/渲染/扫描/Canny故障位0；读回保存在active_board_readonly.json。未执行本轮候选烧录。

## 实施

源码：[bayer_fov_reduce.sv](F:/Project/fpga/vision_base/board/ti60f225_v4/rtl/bayer_fov_reduce.sv)。横向/纵向blend、输入2560×1440、输出1920×1080、完整视场、输出节拍、双缓冲、帧边界和overrun策略保持。

先实际实现了六行单数组3840×48。RTL等价通过，但Efinity把它按4096深度、2bit宽度映射成24个RAM，加上两份前行缓存共30RAM，只省6块，而非总位数推算的10块。`{row,addr}`还会引入1024行跨度，并不等于row×640。

最终把六行分为两个三行紧凑存储，每组1920×48、占10RAM；地址为row×640+addr，用shift/add表达。奇偶前行合为640×48，保留原行索引和同步读/写语义，占5RAM。合计20+5=25RAM；215040bit/10240bit的21块只是位容量下界，合法宽深组合和端口组织还有损耗。

FOV层级资源：比赛版1215.5→913.5XLR、36→25RAM；完整调试版1215.5→915.5XLR、36→25RAM。整机逻辑变化受跨模块打包影响，分别实测，不直接累加层级差值。

## 完整布局布线结果

器件Ti60F225 I3，Efinity2026.1.132.3.9；RAW FIFO512、相机SC431HAI、HDMI1080p60、算法与其他功能保持。DSP均43，Unassigned Core Pins均0，Missing Interface Pins均13，与原设计一致。

|配置|IMAGE_DEBUG|RAM|XLR|WNS ns|WHS ns|板上状态|
|---|---:|---:|---:|---:|---:|---|
|上一轮完整调试512|1|243|55402|+0.345|+0.026|当前已部署|
|本轮完整调试512|1|232|55368|+0.170|+0.024|候选未部署|
|上一轮比赛512|0|233|53951|+0.233|+0.026|未部署|
|本轮比赛512|0|222|53367|+0.157|+0.027|候选未部署|
|本轮仅行快照开发版|2|227|53639|+0.416|+0.026|候选未部署|

相对优化前255RAM，同功能完整调试构建累计释放23块；比赛构建累计释放33块；仅行快照构建累计释放28块。当前板上仍只享有上一轮12块的净释放，候选构建资源与当前烧录资源分别列账。

原生文件、层级报告与时序：[build_results.json](F:/Project/fpga/vision_base/results/fov_pack_20261006/build_results.json)、`debug_native`/`competition_native`/`snapshot_native`三个目录中的bit与报告。前两配置在扩展快照级别前完成构建；IMAGE_DEBUG0/1的生成模块、禁用头和有效数据行为保持。IMAGE_DEBUG2随后独立构建。

## 只保留image_snapshot

顶层`IMAGE_DEBUG`现在支持0=比赛、1=全部图像探针（默认）、2=仅RGB行快照。2保留`image_debug.image_snapshot`，关闭RAW snapshot及三个RGB color probe；功能状态、AE自己的统计、ROI/统一帧池/历史、Canny位图和FlyHash仍保留，不只剩图像处理主链。

RAW诊断页3返回明确disabled tag，但保留真实color_order的bit78:76，供原图导出使用。若把这一控制元数据也清零，现有RGB源导出会丢失通道顺序。页26/27的像素头与行数据、页28的1920×1080/24bit能力保持；RAW探针读取仍明确报disabled，不把控制元数据当RAW图片。主机错误文字改为this build，适用比赛版和仅快照版。

已有caps/行头/源绑定/PNG检查通过，并补充禁用RAW头仍保留源RGB/BGR顺序的检查。此配置本轮只验证构建与主机格式契约，实际USER2图像回读与板上长期验收尚未执行。

## 验证

用本轮修改前的六行版本生成独立`bayer_fov_reduce_reference`，复用已有`FOV_COMPARE_REFERENCE`逐周期对照，同时对数学参考逐像素检查。两帧共4147200像素通过；每拍比较VS/HS/valid/overrun，valid时比较全部32bit像素。覆盖两个完整帧、ping-pong切换、valid气泡、帧边界和复位，输出每行480字/1080行，无overrun。不是仅与更早八行版本比较，也不是只比最终checksum。

证据：[equivalence.json](F:/Project/fpga/vision_base/results/fov_pack_20261006/equivalence.json)、`equiv.run.log`、`capture_header_test.log`和[changes.diff](F:/Project/fpga/vision_base/results/fov_pack_20261006/changes.diff)。原始文件保存在before；直接3840×48的实测中间方案保留candidate_flat.sv/flat.map.rpt/flat.equiv.log。

构建时遇到的两个工具入口问题已定位修正：独立项目XML的design_file需放在正确的schema位置；整机readmemh使用板级相对路径，原生构建的cwd须为板级项目目录。最终三个配置构建退出码均0；早期失败不是算法或新存储布局错误。

## SoC预算修订

沿用上一轮独立测量的Sapphire24RAM/5134XLR，未重新生成或运行SoC：

- 本轮比赛版加SoC：222+24=246RAM、53367+5134=58501XLR，尚未加入连接逻辑。
- 仅行快照开发版加SoC：227+24=251RAM、53639+5134=58773XLR，剩5RAM/2027XLR，仍是独立结果的算术相加，非联合布局通过。
- 此开发版FlyHash完整cone实测5177XLR/2RAM。若之后实际改为固件，加SoC后的算术基数为249RAM/53596XLR；再按用户估计的连接逻辑0–2RAM/800XLR计算，为249–251RAM/54396XLR，约89.5%XLR，剩5–7RAM/6404XLR。

后两项仍待固件迁移、地址保留区/DDR客户端接入、cache一致性与联合P&R确认，没有提前记为已释放。ROI/feature控制的CDC、帧边界提交和状态承载继续保留；不把整块1100XLR当成已确定可删除的收益。2KB cache本轮未生成测量。SC2210分支已是native_1080，不实例化此FOV模块，未切换传感器或中心裁剪；旧SC2210资源数字不套用到本轮源码。

RISC-V/X4/X5、AI及全部B/A/X/I/V/F1目标保持，范围未删减。FlyHash硬件当前保持，固件迁移尚未实施。

## 复现命令

逐周期/像素复验，cwd=`F:/Project/fpga/vision_base`：

```powershell
& C:/iverilog/bin/iverilog.exe -g2012 -s tb -DFOV_COMPARE_REFERENCE -o F:/Project/fpga/vision_base/results/fov_pack_20261006/fov_equiv.vvp F:/Project/fpga/vision_base/sim/vision/tb_bayer_fov_reduce.sv F:/Project/fpga/vision_base/board/ti60f225_v4/rtl/bayer_fov_reduce.sv F:/Project/fpga/vision_base/results/fov_pack_20261006/bayer_fov_reduce_reference.sv
& C:/iverilog/bin/vvp.exe F:/Project/fpga/vision_base/results/fov_pack_20261006/fov_equiv.vvp
```

原生构建，cwd=`F:/Project/fpga/vision_base/board/ti60f225_v4`，OUT/WORK替换成各配置独立绝对目录：

```powershell
. F:/Project/fpga/vision_base/scripts/efinity_env.ps1
& "$env:PYTHONHOME/bin/python.exe" "$env:EFINITY_HOME/scripts/efx_run.py" ti60f225_oob.xml --flow compile --timeout 1500 --output_dir OUT --work_dir WORK --map_opts top-params=IMAGE_DEBUG top-params=2 top-params=RAW_FIFO_DEPTH top-params=512
# IMAGE_DEBUG=0/1/2分别为比赛/全部图像探针/仅RGB行快照。
```

保留源码、位流、报告与必要日志；本轮无例行hash校验。测试临时vvp在完成后清理。
