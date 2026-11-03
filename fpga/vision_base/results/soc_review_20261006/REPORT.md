# SoC / FlyHash / INT8 资源评审与实施 — 2026-10-06

最终候选是final_snapshot/final_competition，包含已复现的取消任务延迟写回修复。optimized_*仅保留为中间资源对照，已被替代。

结论：前三项与2KB cache已落实到联合构建。Sapphire不再只是独立面积试验：128bit AXI已经作为现有统一内存仲裁器的第5客户端接入，FlyHash占据率/投影/WTA改为DDR固件，INT8 dot4使用自定义指令，MulDiv保持关闭。比赛版实际55866 XLR / 241 RAM；保留真实图像行快照的开发版56398 XLR / 246 RAM。两版map/interface/P&R/位流生成均PASS，时序均正，尚未烧录本轮位流。板上CPU启动和固件任务执行仍待验证。

## 评审与取舍

|项目|实施结果|收益与边界|
|---|---|---|
|FlyHash改固件|已完成源码、RV32I参考核对和整机P&R|原计算锥5177 XLR / 2 RAM被移除；新任务邮箱2181.5 XLR / 0 RAM。替换后的层级净减约2995.5 XLR / 2 RAM，不按删除计算锥的毛值5200记账|
|INT8自定义指令、关闭MulDiv|已完成|4路有符号INT8 dot、18bit求和、32bit返回、响应背压；整机CFU37.5 XLR / 4 DSP。上一轮最小SoC的MulDiv已经关闭，额外“省800”不重复记入|
|FOV行缓存合并|采用上一轮已验证的物理排布|36→25 RAM，实际省11。两个1920×48三行组和一个640×48前行组；直接3840×48只省6块，`{row,addr}`也不是row×640|
|RAW checker0并入帧池|本轮保留两套路径|最终联合版均低于93%，用户设定的触发条件未达到；历史/冻结与原跨时钟路径保持|
|Canny单缓冲|本轮保留双缓冲|开发版仍余10 RAM，比赛版余15；未达到“RAM再次不足”的触发条件。前台平面lease、去噪访问状态和完整图像读回保持|
|I/D cache 4KB→2KB|已完成|独立原生SoC测得24→22 RAM，实际省2而非4。指令数据RAM缩小；D-cache字节写掩码的4个独立lane仍各占1块|
|roi_control / feature_controls整体移入固件|本轮未迁移|现有两锥分别578.5/509 XLR；包含实体键消抖、短长按、帧边界生效、CDC、冻结lease和渲染发布，不是仅低速计算。保留这些硬件职责，软件参数/事件控制仍是X4/X5后续工作；未计入“省800”|

当前空间已经满足最小SoC、FlyHash固件和图像行回读共存，先保留历史/冻结/Canny发布机制，而不是为未触发的空间压力改动整条帧链。正式B/A/X/I/V/F1范围保持；SC431HAI、完整视场、HDMI1080p60和所有模式保持。SC2210原生1080分支继续旁路FOV，本轮未新增SC2210实物验收。

## 完整原生构建

器件Ti60F225 I3，Efinity2026.1.132.3.9，RAW FIFO512，SAPPHIRE_ENABLE=1，I/D cache各2KB，4KB启动ROM，无MulDiv/FPU/MMU，AXI128bit/ID4，与板上DDR接口宽度一致。

|配置|IMAGE_DEBUG|XLR / 60800|RAM / 256|余XLR / RAM|DSP|WNS ns|WHS ns|
|---|---:|---:|---:|---:|---:|---:|---:|
|首版联合快照（邮箱重复存储）|2|57137 (93.98%)|246|3663 / 10|47|+0.109|+0.026|
|合并特征存储开发版（修复前）|2|55960 (92.04%)|246|4840 / 10|47|+0.198|+0.026|
|合并特征存储比赛版（修复前）|0|55999 (92.10%)|241|4801 / 15|47|+0.405|+0.026|
|最终联合快照开发版|2|56398 (92.76%)|246|4402 / 10|47|+0.236|+0.026|
|最终联合比赛版|0|55866 (91.88%)|241|4934 / 15|47|+0.132|+0.026|

合并特征存储阶段相对首版联合构建减1177 XLR；加入取消任务写回隔离后最终开发版仍减739 XLR：去掉重复64字节特征存储，host byte与firmware word共用CPU域的一份特征bank，使用逐bank/byte enable；loaded在CPU写入应答后推进，保留原JTAG逐字节核对契约。整机数字受跨模块打包影响，实际P&R为准，不直接累加各锥估值。

最终开发版SoC锥5002 XLR / 21 RAM，FlyHash邮箱2181.5 / 0，CFU37.5 / 0 / 4DSP。独立带完整外部端口的2KB CFU SoC为5257 / 22；整机未连接物理UART收发引脚，闲置部分被剪裁，独立与整机资源分别列账，UART硬件控制不算完成。

与已有同配置、不带SoC的候选比较：快照53639/227→56398/246，净增加2759 XLR/19 RAM；比赛53367/222→55866/241，净增加2499/19。迁移删掉的硬件计算面积和整机净释放分别列账。相对最早255RAM基线，加入SoC之后比赛版仍净少14块；本轮未部署，当前板上243RAM制品不按候选更新。

Unassigned Core Pins均0。未消费的Interface Pins为14，上一轮13；相对基线，USER1 DRCK/RESET不再消费，TCK开始使用，净增加1个未消费项；USER2读图tap保持。原DDR addr14/15等未消费端口与基线一致。两版CDC报告均无Synchronizer warnings。

## 已实现的运行路径

1. 启动ROM包含bootstrap和1780字节完整镜像；bootstrap复制应用到独占DDR `0x07000000`，执行fence/fence.i后跳转。栈顶`0x07010000`，与RAW槽位、`0x02000000`源帧池、`0x03000000`结果池分离。程序/栈在DDR，片上仅ROM/cache/总线队列。
2. 自定义指令opcode0x0b、function0，signed INT8×4求和；启动固件先测试极值65536，成功才发布boot_state=1。2表示CI自检失败，3表示应用trap，0表示尚未就绪。不是固定写“启动成功”。
3. USER2 0x50/51 host向量和0x54本板Canny位图都经同一固件编码。0x52取消。帧/config/epoch/stream error绑定仍由视频域持有；token变化、CPU reset或上下文变化使旧任务失效，旧完成结果不发布。回归实际复现了旧固件任务在新host任务开始后的延迟APB写回会覆盖新特征；现以APB0x2c登记工作token，对feature/hash/cycles和完成写回统一按当前任务token接受，迟到旧写回丢弃，测试通过。
4. Canny保持前台位图lease；固件通过APB索引/应答读4050个32bit字，提取64个占据率特征，生成256个稀疏投影，稳定选top13。主机仍可逐特征、逐hash bit核对；没有新增训练标签。
5. 固件页29使用tag2610071d；原RTL页29保持2610051d。0x58选择页30的完整32bit周期/boot_state/100MHz时钟，0x57回到hash；低13bit不冒充固件总耗时。自动位图任务的周期包括占据率与编码，host向量任务不包括host传输。
6. SoC debug使用已有USER1，图像/控制使用USER2。IMAGE_DEBUG=2保留真实RGB行快照；0关闭纯图像探针。默认SAPPHIRE_ENABLE=0保持已有硬件计算构建入口，以上两个已测候选明确启用1。

DBusCachedPlugin采用write-through，启动不把0x500F误当writeback；本轮CPU只操作独占代码/栈和APB位图，不直接读外部DMA改写的缓存帧。参考：[VexRiscv官方README](https://github.com/SpinalHDL/VexRiscv)。板上cache/DDR启动仍待运行验收。

## 验证

- `firmware_test/test.log`：实际RV32I QEMU，M/A/C/F/D关闭，生产FlyHash C对32向量与4幅完整480×270位图通过；含全空、全满、随机和既有板上读回位图。64项特征逐值、256bit hash逐bit核对。不是板上CPU执行证明。
- `int8.log`：1024随机向量、signed极值、结果保持/背压、复位、未定义function不接收，PASS。
- `mailbox.log`：148.5/100MHz异步clock，boot gating、host逐字节应答、bitmap背压、32bit周期、旧token/变epoch取消、取消中读口应答、CPU reset、取消旧任务延迟写回对新特征的隔离，PASS；`mailbox_cancel_write_before.log`保留修复前复现。
- `memory_full.log`：5客户端并发带背压，2074112扫描像素、1080p/ROI/冻结/读写错误不发布；RAW R108920/B72591，CPU R108919/B72591，render1059470周期/deadline0，PASS。是RTL模型，不是板上DDR吞吐。
- `memory.log`：相同5客户端短链增加CPU按32bit lane写掩码检查，PASS；非选中字节保持。
- `roi_no_cpu.log`：CPU_ENABLED=0的原4客户端路径，24帧/73728像素、ROI缩放/平移/冻结同源重渲染、原子提交、非法配置与扫描恢复，PASS。
- `ram.log`：生产Sapphire RAM绑定的字节写掩码、22bit tag、同步读/读使能保持，PASS。
- `boot_image.log`：针对具体ROM LMA/字节lane错位故障核对1780初始化字节，PASS；生产反汇编无M指令。未计算哈希。
- host `test_flyhash_board.py`：新旧tag、固件完整周期/boot state、源帧绑定检查，PASS。
- FOV沿用上一轮4147200像素逐周期等价与数学参考证据；本轮未重复修改或运行FOV算法。

`build_results.json`给出5次联合构建的资源、时序、原生各阶段PASS与位流路径；`changes.diff`记录已有文件变动；`before`保存本轮修改前文件。

## 复建入口

在 `F:/Project/fpga/vision_base`：
```powershell
$py='C:/Users/Sregetic/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $py -E scripts/build_vision_firmware.py
& $py -E scripts/generate_vision_soc.py --output-dir artifacts/vision_soc --custom --boot-kb 4 --boot-hex artifacts/vision_soc/firmware/vision.hex
& $py -E scripts/test_vision_firmware.py
& $py -E scripts/test_flyhash_board.py
```
原生联合编译从 `F:/Project/fpga/vision_base/board/ti60f225_v4` 运行，保留现有mem文件相对cwd语义：
```powershell
. F:/Project/fpga/vision_base/scripts/efinity_env.ps1
& "$env:PYTHONHOME/bin/python.exe" "$env:EFINITY_HOME/scripts/efx_run.py" ti60f225_oob.xml --flow compile --timeout 1500 --output_dir F:/Project/fpga/vision_base/results/soc_review_20261006/final_snapshot --work_dir F:/Project/fpga/vision_base/results/soc_review_20261006/final_snapshot/work --map_opts top-params=IMAGE_DEBUG top-params=2 top-params=SAPPHIRE_ENABLE top-params=1 top-params=RAW_FIFO_DEPTH top-params=512
```
比赛配置的IMAGE_DEBUG为0，输出/work另选独立目录。没有调用烧录工具或修改Flash。

## 后续验收

两个新位流已生成，但本轮没有写SRAM/Flash。下一阶段是板上确认boot_state=1、USER1 CPU debug、同一冻结原帧的固件64特征/hash核对、图像读回与共享DDR持续运行。固件实际耗时、cache2KB运行代价、复杂场景吞吐、实体键/UI回归尚待板测。软件参数/事件控制、物理UART和训练模型继续保留为正式X4/X5/X6工作，不标为完成。

当前ROM携带小型固件，DDR应用上限3840字节由linker明确约束；后续更大控制程序/模型从SPI或USER1装载，而不是扩大片上程序存储。本轮1780字节包含bootstrap，仍在该上限内。

整机CPU热复位的共享AXI事务清理仍未实现。官方SoC debug reset会复位其BMB/DDR桥，而外部共享仲裁器按全板vid_rst_n复位，存在进行中事务撤销路径；本轮CPU reset测试只覆盖任务邮箱，不覆盖这一整机路径。候选下一阶段先验证全板配置后的冷启动，整机热复位闭环继续属于X4错误/复位处理工作，不算已完成。
