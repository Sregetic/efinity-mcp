# Shape FOMO：固定图片接入

本阶段只验证随包四组固定输入在现有Ti60/Sapphire上的数值与推理耗时，不将固定图检测结果当作真实相机准确率。模型保存在`models/shape_fomo`；`HANDOFF.md`是外部交接时的历史说明，当前项目已有RISC-V、DDR加载器与分析DMA，以本文件及PROJECT_MASTER_STATUS.md为准。

## 路线与资源

- 复用现有100MHz RV32I、2KB I/D cache、DDR和USER1；不添加TinyML Accelerator、不启用MulDiv/FPU、不更改RTL/时钟/片上缓存。
- 运行官方Efinity2026.1 TinyML仓库固定版本`96886fa0c73e25e6218db7d0863f84677cf65138`中TFLM的Conv2D、DepthwiseConv2D、Add、Softmax软件算子。
- vendor参考头文件先尝试硬件driver。构建工具在输出目录生成三个保留原版权的头文件，精确移除driver调用，保留软件算法；不修改依赖仓库，不链接加速器driver或HyperRAM示例硬件。
- ELF使用现有`firmware/vision/link_ddr.ld`：代码/常量/BSS在0x07000000起的4MiB应用区，arena在0x07700000，预留256KiB。片上XLR/RAM/DSP增量均为0，硬件制品保持60082XLR/252RAM/59DSP。
- 四张PNG对应96×96×3 RGB int8输入；每张27648B。输出12×12×4、576B，background/circle/rectangle/triangle。阈值0.5对应int8值>=0。
- 四组固定输入直接使用交接包预处理数据；不将现有32×32灰度分析DMA输出伪装为本模型RGB输入。

## 编译与本机核对

官方依赖工作树位于F:/efinity-ci/deps/tinyml；所需源目录由git sparse-checkout取出，不复制整份第三方源码到视觉项目。

```powershell
Set-Location F:/Project/fpga/vision_base
$hostPy='C:/Users/Sregetic/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $hostPy -E -X utf8 scripts/build_fomo_firmware.py --output-dir results/fomo_fixed_20261011/firmware_final
& F:/efinity-ci/tinyml-env/Scripts/python.exe scripts/test_fomo_reference.py
& $hostPy -E -X utf8 scripts/test_fomo_protocol.py
```

## 板端执行与回读

实际FTDI URL以当前枚举为准。测试程序临时替换DDR应用，结束后恢复原完整AI程序和权重；配置Flash及应用Flash保持现状。

```powershell
. ./scripts/efinity_env.ps1
& "$env:PYTHONHOME/bin/python.exe" scripts/test_fomo_board.py `
  --url 'ftdi://0x0403:0x6011:4:9/2' `
  --elf results/fomo_fixed_20261011/firmware_final/vision.elf `
  --restore-elf artifacts/vision_soc/ddr_firmware/vision.elf `
  --restore-weights models/shape_cards_bringup/shape_cards_weights.bin `
  --load-jtag-khz 500 `
  --output-dir results/fomo_fixed_20261011/recheck
```

先halt/load/实际DDR字节回读/核对后resume。首轮25kHz完整加载与核对通过，但291KB程序传输很慢；50/100/500kHz的静态1024B对照均一致，最终500kHz整段291328B实际回读也严格一致。上面的500kHz只用于halt下的固定图ELF下载，默认加载器与原固件恢复仍25kHz；相机张量/结果回读保持5kHz，不把静态下载成功外推到动态ROI。较大程序的deadline显式设为1800秒，原加载器默认300秒保持。运行中通过USER2读取APB状态，不halt CPU；完成后5kHz USER1导出四组完整输出、64位CLINT周期、25层耗时、内存用量与错误日志。

APB的firmware_state实际仅2bit（vision_flyhash_mailbox.sv）：测试应用写1表示运行、2表示固定图完成、3表示错误。样本/层号与完整状态保存在DDR；不再向此字段写入32bit magic。首轮只影响自动完成检测，数值/64bit计时仍完整；首轮真实回读单独保存在board_reference。

`fomo_status`含FOM1 magic、执行阶段、错误码、当前样本、完成数、arena实用字节、初始化周期、输入/输出字节数、算子数、当前层、日志长度、mcause/mepc和100MHz计时频率。`fomo_results`逐样本保留64位Invoke周期、最大LSB差、差异字节数、阳性网格数与执行层数。CPU端比较后，主机再对实际DDR输出独立逐字节比较；严格一致与最大1LSB分别报告，超过1LSB视为失败。

Invoke计时包括层间原控制服务，逐层计时单独记录算子区间；均不包括JTAG加载、图片拷贝、回读和输出比较。当前是软件参考实现，后续按实测热点决定是否复用已有dot4/MulHi。

## 尚未包括

真实相机RGB ROI预处理、FOMO相邻网格合并与OSD、实物独立测试、生产固件中的长期调度和自主Flash启动。完整原系统功能保持，现有MLP/FlyHash/连接组支路继续保留。

最终板上四组均576/576字节一致、最大差0；Invoke分别25.9594255/25.96086187/25.97728564/25.97116464秒，arena实用149388B。两位完成握手和自动恢复原18740B程序/4400B权重通过，恢复CPU状态1；未重配FPGA、未写Flash。完整记录见F:/Project/fpga/vision_base/results/fomo_fixed_20261011/REPORT.md。
