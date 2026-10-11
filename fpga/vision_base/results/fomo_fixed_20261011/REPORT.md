# FOMO四组固定图：Ti60板上接入与实测

日期：2026-10-11。用户要求先在板上运行交接模型的四组固定图，核对输出及耗时，并控制片上资源。本轮已完成该范围；不把固定图验证写成真实相机识别或A6实物验收。

## 结论

现有Ti60/Sapphire100MHz RV32I运行官方TFLM软件算子，四张96×96 RGB int8输入全部推理成功；最终四份576B输出共2304B与交接参考逐字节一致，最大差0。不是电脑代算、QEMU或仅编译证明。

|固定输入|最终Invoke秒|最大LSB差|差异字节|阳性网格|
|---|---:|---:|---:|---:|
|blank|25.95942550|0|0|0|
|circle|25.96086187|0|0|2|
|rectangle|25.97728564|0|0|1|
|triangle|25.97116464|0|0|4|

阳性数量是12×12输出中的网格数，不是物体数。circle两个网格分数0.74609375/0.71484375，rectangle为0.90234375，triangle为0.77734375/0.8203125/0.91796875/0.71875，均与交接记录一致。当前没有区域合并/边界框后处理。

`board_final/result.json`、outputs.bin、results.bin、layers.bin、status.bin及read.log为最终CPU/DDR回读证据。runtime.log为空、错误码/mcause/mepc为0、完成数4、每图25层。主机独立比较实际输出，未只信任CPU写出的PASS。`host_reference.json`另记录TensorFlow2.21.0 BUILTIN_REF对包内TF2.14参考的重新核对，也全部一致。

## 资源和内存

|资源|既有硬件基线|本轮增量|剩余|
|---|---:|---:|---:|
|XLR|60082/60800|0|718|
|片上RAM块|252/256|0|4|
|DSP|59/160|0|101|

本轮没有改RTL/IP/时钟/片上缓存，没有重新生成或烧录FPGA配置，沿用ai_board_ui_20261010资源报告；该表不是本轮新增P&R结果。没有增加Conv硬件、MulDiv/FPU或BRAM神经缓存，因此本次无需以删除视频功能腾容量。

模型54640B、四组输入110592B、参考输出2304B及软件在DDR。最终ELF载入291328B，其中BSS18712B；arena预留262144B，实际使用149388B（约145.9KiB），初始化140.64566ms。APP使用0x07000000起4MiB、arena0x07700000，沿用128KiB栈；没有碰帧池/权重共享区。固定模型/输入通过.incbin加载，不重复生成大的文本数组。

## 计时和下一瓶颈

使用硬件64bit CLINT、100MHz；Invoke期间没有halt CPU，USER2只读APB状态。时间包含层间原控制服务，不含JTAG加载、图片拷贝、输出核对和回读。每图约25.97秒，仅约0.0385次/秒；视频刷新/采集帧率与这个分析速度不同。

25层逐层周期已保存。blank第3层Conv2D约5.260秒，第0层Conv2D约4.062秒，第1层Depthwise约1.632秒；模型约5877504MAC。当前使用通用参考循环和RV32I软件乘法，是数值参考版而非实时推理版。后续先在DDR固件中优化卷积地址循环、复用已有dot4/MulHi并逐值对照，再按剩余718XLR/4RAM决定硬件；本轮没有实现或宣称该加速。

## 两次板上运行与状态修复

首轮25kHz291408B程序load/实际回读一致，四组输出全部一致、Invoke约26.879–26.897秒，保存在board_reference。APB firmware_state在vision_flyhash_mailbox.sv实际只有2bit；首版写32bit状态码被截断，自动等待完成未退出，未影响DDR中的模型结果或64bit计时。已停止该agent自建轮询进程，导出完整首轮结果，而不是把等待超时当推理失败。

修正软件发送方为运行1/完成2/错误3，完整样本/层号保留DDR，不拓宽硬件。最终新程序291328B、RV32I ISA检查通过；500kHz静态下载后整段实际回读严格一致，才resume。自动观察1→2、导出/独立核对/恢复完整旧AI固件全部完成，进程exit0。首/末两轮时延变化不是受控加速对照，不归因于状态修复。

50/100/500kHz的静态1024B读与已有已核对ELF一致；最终整段500kHz核对也通过。默认USER1仍25kHz、动态张量/结果仍5kHz，只有本次固定图下载显式500kHz。32bit读benchmark记录保留；探测中发现本地JimTcl缺binary命令，该方案未用于正式加载或字节验收。

## 恢复及独立问题

board_final/restore/result.json证明18740B原AI应用和4400B原权重已实际回读相等并resume；restored_cpu.json实读firmware_state1。原video/UI参数恢复M3/MED0/F0、Sobel128/Canny128、菜单0，符合本轮开始的实读状态。原MLP/FlyHash/连接组和控制系统保留；FOMO固定测试不永久替换它们。Flash内容及FPGA SRAM配置保持。

本轮开始、模型下载前，CPU已停在ROM0xf90001a4；boot_status为VBO1/错误3/JEDEC0xFFFFFF。此故障在模型接入之前存在，保留preflight.log；本轮以USER1联调，未改Flash或宣称自主启动已修复。

当前相机/帧池rgb_capture_count及source frame仍0，开始/结束均如此；不得宣称与正常实时相机同时运行的验收。真实相机96×96 RGB ROI、后处理/OSD、实物准确率、现场无需上位机演示及Flash独立启动尚未由本次固定图测试覆盖。

## 代码与重跑

- firmware/vision/fomo_main.cc：四算子软件推理、DDR输出/错误与64bit逐层计时、保留原控制服务。
- scripts/build_fomo_firmware.py：固定官方依赖版本、仅三处精确移除硬件driver调用、复用现有DDR布局、RV32I指令检查。
- scripts/test_fomo_board.py：完整静态字节核对、两位握手、实际输出独立比较、finally恢复原完整应用/权重。
- scripts/load_vision_ddr.py：只增加大程序deadline参数，默认300秒/25kHz不变。
- scripts/test_fomo_reference.py、test_fomo_protocol.py及原test_ddr_loader.py通过；协议检查覆盖64bit计时、正负int8、严格/1LSB/2LSB、截断/错误记录及软件头文件。

重跑命令与依赖路径见docs/SHAPE_FOMO_INTEGRATION_20261011.md。交接历史说明保留但不覆盖当前已有SoC/DDR/DMA状态。完整B/A/X/I/F/V范围不变。
