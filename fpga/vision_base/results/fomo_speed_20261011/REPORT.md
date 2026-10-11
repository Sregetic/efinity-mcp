# FOMO 固定图提速：最终板上验收

日期：2026-10-11。物理 Ti60/Sapphire 100MHz，现有 RV32I、2KB I/D cache、dot4/MulHi CFU。最终固件为 `cfu_release/vision.elf`，完整测试与恢复见 `board_release`。本轮只调整 DDR 固件，FPGA 制品、时钟、缓存、Flash 和原视频功能保持原状。

## 最终结果

|固定输入|原软件参考 / 秒|最终加速 / 秒|提速|差异字节|
|---|---:|---:|---:|---:|
|blank|25.95942550|0.94905574|27.35x|0|
|circle|25.96086187|0.94912661|27.35x|0|
|rectangle|25.97728564|0.94912175|27.37x|0|
|triangle|25.97116464|0.94913686|27.36x|0|

平均 949.11024ms，平均提速 27.3595 倍。四组完整输出共2304B，主机实际DDR回读逐字节相等，最大LSB差0；CPU独立比较也全为0。25个算子均执行，模型、权重、96×96 RGB输入和12×12×4输出保持原样。阳性网格数0/2/1/4不是实物目标计数或准确率。

计时为64位CLINT、100MHz。Invoke期间CPU持续运行，包含层间原控制服务；排除JTAG加载、输入拷贝、回读、输出核对和一次性AllocateTensors。逐层周期见 `board_release/layers.bin` 与 `board_release/result.json`。固定图性能不是相机帧率或端到端识别延迟。

## 有效改动

1. 普通卷积复用dot4；权重预打包、零点补偿按通道一次计算，RGB patch复用于所有输出通道。
2. 深度卷积每个通道保持独立乘加，复用dot4低8位，3×3九项展开；临时权重按实际8bit保存，减少循环/读指针开销。
3. Q31使用现有MulHi精确恢复舍入位，维持TFLite两阶段舍入。右移掩码、乘数变换等按通道预计算，符号判断使用slt而非31位串行移位，输出保留32bit到字节存储点。
4. 行地址在每行计算，列地址逐像素递增；像素循环中的重复软件乘法已移出。量化修正用移位0/1和掩码，系数布局24B/通道。

已尝试但未保留：提前激活截断和8通道分块，两者数值正确但整机Invoke更慢。最终使用连续像素/通道输出次序，保留实际有效的地址、量化和DW优化。

|实际候选记录|平均Invoke / ms|最终采用|
|---|---:|---|
|board_cfu|2435.69980|否|
|board_quant|1265.43134|否|
|board_final|1273.73307|否|
|board_tiled|1440.56976|否|
|board_address|949.11024|否|
|board_release|949.11024|是|

`cfu_address`已达0.949秒；为清除诊断函数noreturn警告，声明永久错误服务的真实控制流。加载段字节比较显示制品发生变化（`release_identity.json`），因此最终`cfu_release`完整重跑四组，结果和耗时重新取得，不复用旧版本计时。

## 资源与恢复

沿用硬件60082/60800XLR、252/256块RAM、59/160DSP，余718XLR/4RAM/101DSP；本轮三项增量均0，未进行新的P&R或FPGA编程。DDR arena实用149388B、预留262144B，和原软件参考相同。ELF加载段285200B，比原291328B少6128B；临时打包/量化系数使用现有DDR栈，不占新的片上RAM。

脚本finally恢复原18740B完整AI应用与4400B权重，实际DDR字节核对通过、resume和原UI配置恢复完成；`board_release/restore/result.json`通过，`restored_page30.json`的firmware_state=1。Flash保持原状。静态下载500kHz、动态张量回读5kHz、原应用恢复25kHz，原默认值保持。

## 验证

- RV32I QEMU：50100组Q31、10000组signed16、32320组除幂舍入、10000组重定标、10000组激活检查，172组Conv/196组DW，全部与原算法一致。CFU在QEMU中仿真，仅用于数值，不用于性能。
- 构建审计：RV32I_Zicsr_Zifencei，无M/F/C指令；使用现有CFU指令。vendor依赖固定commit96886fa0c73e25e6218db7d0863f84677cf65138，构建目录生成头文件覆盖，依赖源码保持原样。
- 物理板：静态完整ELF字节回读后执行，APB1→2，完整四组张量、64位周期、25层、arena回读通过；原应用恢复通过。
- GitHub上传工程的适配器本机检查71 passed/1 Windows symlink privilege skipped，compileall通过；这些软件检查不替代板上验收。

## 复现与范围

构建、板测命令见 F:/Project/fpga/vision_base/docs/SHAPE_FOMO_INTEGRATION_20261011.md。新构建使用 `--cfu-kernels`；未选该参数时仍生成原软件参考，便于对照。

真实相机RGB96×96 ROI、FOMO后处理/OSD、视频并行时DDR竞争及端到端延迟尚未验收。四张固定图不代表实物准确率、A6或完整AI闭环。开始加载模型之前已有source/capture count=0与ROM SPI JEDEC错误3/FFFFFF，时间线见原接入报告；这些状态保留独立排查，本轮没有重配相机或改写Flash。
