# 2026-10-10：SPI自主加载与连接组软件原型

## 当前结果与资源

执行顺序为SPI自主加载，随后连接组定点原型。完整目标保持不变：连接组加入局部分析支路，不替代ROI、帧池、RISC-V、TinyML、FlyHash和加速路线。

当前FPGA为`results/ai_autoboot_20261010/release/ti60f225_oob.bit`。同设备原生映射、接口、布局布线和位流生成通过，最终59952/60800XLR、251/256RAM、59/160DSP；WNS+0.129ns/WHS+0.026ns，未分配核心引脚0。HDMI1080p60、SC431HAI完整1440p约30fps和原图/模式回读保留，未调整SDC时钟。

|比较|XLR|RAM|DSP|
|---|---:|---:|---:|
|本轮开始的A控制版|59738|251|59|
|最终SPI/CPU写边界版|59952|251|59|
|净变化|+214|0|0|
|最终余量|848|5|101|

中途CPU写边界候选因60802XLR超过容量而终止。收紧到Sapphire实际128MiB DDR地址范围后，最终59952，比该候选少850XLR；这包含布局布线缓冲变化，不当作净释放850。没有删减功能。连接组只改变DDR应用和数据，不增加FPGA模块、RAM或DSP。

## 1. 自主加载实现、故障与验证

8KB片上ROM中的`boot_spi.c`通过已有控制APB的0x48输出、0x4c输出使能、0x50同步输入读SPI，不另加控制器/FIFO。GPIO引脚按板卡资料和官方同封装桥接例程配置为1.8V；U14实物JEDEC经官方桥和CPU GPIO均读得EF6017（Winbond8MiB），与原理图的GD标注不同，固件按实物校验。

Flash配置映像从0开始；程序区保留0x700000..0x7fffff。VBO1头部32B描述DDR程序、权重、入口及各自CRC32；程序进入0x07000000，权重进入0x07400000。包复用现有ELF地址检查；帧池0..0x027fffff、输入/arena/stack/debug区域不重叠。空白程序头用于USER1开发启动内嵌控制程序；坏格式、地址、CRC或芯片ID记录明确故障并停止CPU，不执行半包。

首次官方快写遗漏了交替256B页。改用官方`all --verify_method onchipx1`流程，失败后使用最大页等待时间；写后CRC和实际字节比较都通过。没有修改厂商库。完整原Flash备份在`results/ai_autoboot_20261010/flash/flash_before.bin`，后续备份留在对应flash目录。

冷启动逐字节复制曾卡住；对齐32位复制诊断及正式ROM启动通过。进一步核对Sapphire生成桥可见它输出128位SIZE/data/strobe、保留原字节地址，现有DDR客户端统一要求对齐beat。在`frame_memory_system.sv` CPU边界对齐AW地址，保留WSTRB/数据/事务顺序；板级按实际128MiB映射去掉不可能的高地址位。旧边界在新增字节lane仿真报AW boundary，新边界通过所有字节/半字/字lane及掩码外不覆盖检查。

数值回读另有独立问题：25kHz ROI张量读入重复0x67756b75，5kHz独立word和dump读都匹配CPU灰度和。共享配置将数据回读默认设5kHz；已逐字节验证的静态程序加载/启动身份读取保留显式25kHz。5kHz核对原图1024灰度、128特征、32隐藏值、4输出及256bit FlyHash通过，不把回读错误当相机像素。

最终Flash已写入本轮正时序配置映像（官方写后验证成功）及当前应用包；SRAM配置重启后ROM读SPI，CPU状态1，15404B程序和4400B合成权重实际DDR字节完全一致，期间没有USER1程序下载。证据：`results/connectome_20261010/autoboot/result.json`。真实断电/拔掉JTAG线再上电尚未实测，配置重启与物理断电验收分开。

## 2. 真实连接组定点软件原型

数据为[Fly Dino发布的MaleCNS派生子图](https://github.com/cobanov/flyjump/tree/e34c6614e7d13a1018585f705cdeb59b9f38291d/public/data/connectome)，固定commit e34c6614e7d13a1018585f705cdeb59b9f38291d。80节点、1296有向聚合边、26029突触计数、32输入节点、16输出节点；全部body ID、端点、接触计数、类型、递质、位置和原声明保留。`models/connectome_malecns/provenance.json`、nodes.csv、edges.csv可追溯。数据CC BY4.0；原始全表没有在本机重新提取，来源真实性采用发布者的派生数据和清单，不声称独立复现原始抽取。

动力学沿用[公开协议](https://github.com/cobanov/flyjump/blob/e34c6614e7d13a1018585f705cdeb59b9f38291d/docs/experiment.md)的符号假设、入边绝对接触数归一化、gain1.4、0.3旧状态+0.7tanh、3次同步迭代。递质符号和动力学属于工程模型，不是生理测量。输入改为现有64个边缘密度特征的2x4空间汇聚，共8通道；这是工程映射，不声称LC型真实感受野。每个独立ROI重置状态，当前不跨对象保持记忆。

浮点用Float64；定点为Q14，整数累加、对称舍入、257项tanh插值表。CSR、索引、权重和LUT共4660B，放DDR应用只读区。C复用已有MulHi完成精确有符号16x16乘法，不开MulDiv/FPU，不添加硬件大核。仍保留现有INT8层和FlyHash，同一份128特征同时送三种方法。

主机33组输入含已经核对的相机ROI，2640个C/Q14状态逐值一致；最大浮点状态误差0.0001731665，4倍输出特征误差0.000692666。`results/connectome_20261010/host_validation.json`和RV32I QEMU日志留存。

板上源6726/render1/context6、ROI[640,300,640,480]：80状态逐值等于主机定点，浮点最大误差0.0001242063；连接组1539996周期=15.39996ms。包含特征、INT8、FlyHash、连接组的CPU总23.99159ms，DMA3.51022ms。本次先让任务完成，再只读，未把调试暂停时长当计算时延。`board/result.json`同时绑定两套结果的sequence/frame/source_config/render_config/context；原INT8/FlyHash也通过，DMA错误0。

当前输出是16个未训练读出特征，不是新的实物分类器。常规模型仍为synthetic TEST，真实卡数据/读出训练、独立测试、消融、拓扑优势和关联记忆待后续；不将Q14误差或数值一致性写成识别正确率。

## 复现与后续

1. `scripts/build_connectome.py`生成可审查节点/边CSV和固件表；`scripts/test_connectome.py`执行浮点/定点及RV32I核对。
2. `scripts/build_vision_firmware.py --load-method user1 --main firmware/vision/ai_main.c --mulhi-cfu --output-dir artifacts/vision_soc/ddr_firmware`生成DDR ELF；此字段代表链接格式，实际本轮运行由SPI启动。
3. `scripts/program_vision_boot_flash.ps1`备份、验证分区、更新应用和权重、重启SRAM；常规模型更新保留配置区。FPGA RTL变化仍经`synthesize.ps1`正时序门禁后单独安装配置映像。
4. `scripts/verify_vision_boot.py`只读核对自加载身份/实际字节；`read_ai_result.py`读取同任务张量和连接组状态；`validate_ai_result.py`、`validate_connectome.py`各自核对。让冻结任务完成后再读，避免调试暂停污染计时。
5. 实物数据到位后训练16输入读出，与直接特征、FlyHash、INT8和重连拓扑做同ROI对照。先测热点，再讨论加速，当前848XLR/5RAM不堆叠新的大核。

当前实时状态恢复M0/MED1/F0、ROI[736,302,960,540]、输出960x540、位置[320,240]、菜单PAN X、Sobel128/Canny80/SHAPE32/自动几何策略2。旧紫闪、原图残留颗粒、A6实物卡和人工按键验收仍单列；本轮不把它们写为修复或验收通过。

## 持续实时补测

显式view策略下连续运行60秒；记录文件间隔61.668秒，源采集推进1849帧，捕获丢弃/扫描坏帧/deadline增量0，故障位0。最后完成序列1867/源38333/render1/context7再次通过INT8、FlyHash和80个Q14状态核对，累计DMA错误0；单次连接组15.42689ms、CPU总23.83770ms、DMA3.56431ms。该测试没有同步观察物理HDMI，不作为光学长时验收。见results/connectome_20261010/live_validation.json和live_result/。
