# 相机 ROI 操作

2026-10-09新增实体 ROI 菜单和独立形状阈值；最新操作见[按键演示](BOARD_BUTTON_DEMO_20261009.md)。以下带旧日期的按键描述只对应当时位流，尤其 KEY0 长按已由直接开关中值改为切换菜单页。当前部署仍以总状态表最新摘要为准。

本机控制面板由 `scripts/roi_panel.py` 提供，地址保存在 `results/roi_live_20261004/panel_server.json`。界面有整帧、中心 2×/4×、缩小 0.5×、方向平移和重新渲染。操作在 FPGA 的16bit共享范围RGB源帧、ROI 渲染 DMA、双缓冲结果和 HDMI 扫描链执行，网页没有代替 FPGA 做裁剪。

先勾选“启用 ROI”和“冻结同一原帧”，点击“应用 / 重新渲染”。随后修改裁剪、输出尺寸、屏幕位置、显示模式或边缘阈值并再次应用。`held_source_frame_id` 与 `held_raw_id_sample` 保持不变，`applied_config_id` 更新。取消冻结恢复实时取最新完整帧；关闭 ROI 回到原相机路径。

源帧固定1920×1080、16bit共享范围线性RGB，位于 debayer/白平衡之后、Gamma/色调/Canny 之前。冻结后的几何、Gamma、色调和边缘参数可处理同一 RGB 源；改变前级曝光/白平衡需要重新取源帧。缩放为最近邻，不做双线性插值。输出宽度按 8 像素对齐；输出窗口外为黑色。完整 HDMI 画布始终为 1920×1080、60Hz，独立于 ROI 大小和实际渲染更新率。

2026-10-05画质修正：Gamma前固定RGB565的5/6bit通道台阶不同，产生紫绿量化斑块；最近舍入仅减小平均偏差，实际仍有色带。内部改为16bit共享范围编码：bit15=范围，bits14:10/9:5/4:0为R/G/B。三个通道均<=63时，各保存floor(v/2)、解码为2*q，误差最多1；任一通道>=64时，三个通道统一round(v*31/255)，解码为RGB888。此前0…31精确、32以上粗量化的候选在当前充分照明下仍放大32…63区间色斑，最终将精细范围扩到63。高范围仍为RGB555精度，16bit DMA、帧池、字节跨度、ROI复制与像素顺序保持。未来直接读取DDR的CPU需按此格式解码，而不是RGB565。PNG回读仍为RGB888，原图仍处于Gamma之前。

SC431HAI源码默认白平衡为物理R/G/B336/256/504（Q8.8）。本次光线变亮后，板上运行时调为440/256/516，平坦墙面块均值159.42/160.16/159.59；CLI仍可调，这是场景测量值，不是自动白平衡或完整色彩矩阵标定。重烧/复位采用源码默认值，恢复本次光线参数用`vision_control.py --gain-r 440 --gain-g 256 --gain-b 516`，再重新读取源帧。SC2210保留此前准备的默认增益。

暗部色调沿用既有RAW中心统计开关（低于48启用，高于60停用），公共RGB增益上限9x，保留0→0与255→255、峰值单调；普通曲线保留。RAW统计值来自曝光后的像素，不等于室内照度。它提高暗部显示亮度，不替代曝光和色彩标定，也不消除传感器的全部噪声。当前工作阈值96、median1；源19的完整九模式历史快照采样阈值128，快照参数与当前板上参数独立。

## 实体按键与阈值

2026-10-05实际板卡按键验证使用配套硬件手册260813第33页映射：KEY0=C4、KEY1=P14（复位）、KEY2=N14、KEY3=A3，LED0=P13、LED1=N13。配套2026-03原理图将BR区KEY/LED对调；旧工程采用原理图映射，KEY2短按未进入控制逻辑。现已校正并写SRAM，KEY2/KEY3实测96→112→96，按键输入分别为`keys_n=5/3`。

2026-10-07阈值版已写SRAM：F0实时/F1冻结时，KEY2短按加16、KEY3短按减16，范围16…2047，饱和而不回绕。M5/M6修改独立Canny阈值，其余模式修改Sobel阈值；切换模式保留两个设置。短按在松开后生效，约20ms消抖，统一在帧边界提交。长按约1秒切换存储模式，F2回放/F3对比时短按仍切换历史索引。KEY0短按切模式，长按开关中值。OSD显示模式名和四位十进制：`SOBEL T0096`表示96，`CANNY T0128 R0128`显示实际阈值和设置值；设置16而噪声下限24时显示`T0024 R0016`，按键仍按设置值步进。网页切模式先读取该算法的独立阈值，再由“应用”提交。实体操作后点击网页“读取状态”，保存的图像快照保持独立。原十六进制/零下限说明属于旧位流。

“消噪开启”现在同时控制灰度中值与 RGB 三通道 3×3中值。M0关闭消噪时保留直接ISP输出，开启时走现有窗口的处理结果；HDMI与板内图片回读使用同一输出选择。M4/M6/M7的彩色底图也按此开关处理。原图仍是Gamma前源帧，不替换成网页修饰图。

命令行等效操作（PowerShell 7，工作目录 `F:/Project/fpga/vision_base`）：

```powershell
. ./scripts/efinity_env.ps1
$py="$env:PYTHONHOME/bin/python.exe"
$jtag='ftdi://0x0403:0x6011:4:9/2' # 使用当前 FTDI 枚举结果
& $py scripts/vision_control.py --url $jtag --memory 1 --roi 480 270 960 540 --output-size 1920 1080 --position 0 0 --mode 5 --threshold 128 --median 1 --roi-status
& $py scripts/vision_control.py --url $jtag --roi 608 334 960 540 --rerender --roi-status
& $py scripts/vision_control.py --url $jtag --roi 0 0 1920 1080 --output-size 960 540 --position 480 270 --roi-status
& $py scripts/vision_control.py --url $jtag --memory 0 --roi-enable 0 --roi-status
```

网页“读取 FPGA 边缘快照”用 JTAG 回读完整 480×270 Canny 前台平面，不是 UGREEN 视频。显示选择 Canny 或彩色叠加后使用；一次读取约一分钟。禁止另一程序同时打开同一 JTAG 接口。离线复验入口为 `scripts/verify_roi.ps1`，完整 1080p 逐像素复验加 `-Full`。


## 无采集卡读取原图和各模式（2026-10-05）

面板顶部自动加载上一次完整读取的原图和 M0…M7，点击缩略图或“查看快照”切换，原尺寸链接打开完整 PNG。图像注明采集时间、源帧和配置，是独立于当前参数的静态快照；刷新页面、修改参数或重新采集时，上一组图仍保留。参数和详细状态折叠在图像下方。

面板按钮“重新读取原图与全部模式 · 1080p（约 8 分钟）”自动暂时启用整帧ROI、冻结一个RGB源，读取原图及M0…M7，再恢复读取前的模式、ROI和冻结状态。每次写入独立的 `results/roi_live_20261004/mode_frames_<timestamp>/`，全部成功并恢复板上状态后，原子更新 `mode_gallery.json`；中途写出的部分图不替换已完成图组。静态图片请求独立于板上任务，但 `/state`、`/apply`、`/preview`、`/modes`、`/flyhash` 共用一把板级锁，不会并行打开 JTAG。

每幅保存1920×1080 RGB888 PNG；原图来自DDR共享范围RGB源的解码像素，位于Gamma之前并按当前color_order转换通道。M0…M7来自最终送入HDMI编码器的像素，包含真实OSD、识别叠加和单像素Canny显示，不是主机重算边缘。

单行缓存1920×24bit，完整图按行从重复显示的同一冻结源拼接；逐行检查源帧、配置号、模式、阈值、median、tone与序号，检查Canny前台epoch保持及ROI扫描错误计数。它是静态快照，不是USB视频，也不证明TMDS链路的电气兼容性。原图不是未经ISP的RAW10。

CLI使用Efinity进程环境：

```powershell
. F:/Project/fpga/vision_base/scripts/efinity_env.ps1
& "$env:PYTHONHOME/bin/python.exe" F:/Project/fpga/vision_base/scripts/capture_mode_images.py --url ftdi://0x0403:0x6011:4:9/2 --output-dir F:/Project/fpga/vision_base/results/my_mode_images
```

指定单模式用`--modes source`、`--modes 2`或`--modes 5`；指定校验条带用`--rows 0 80`，其PNG只包含80行且元数据标明裁剪范围。默认输出9幅完整1080p图。目录中的`images.json`记录数据来源、实际模式、冻结源、配置、参数和读回时间；`restore.json`记录恢复后的状态。

JTAG页26为行状态，页27为192bit头加RGB888行数据，页28为尺寸/格式。命令0x40的bit11选Gamma前源，bit10…0选行。电脑端使用厂商已有分包`read()`而非受512字节FIFO限制的单包`read_dr()`；仅在当前导出连接将FTDI latency从16ms调至1ms，结束后恢复。PNG CRC属于文件格式，不计算例行源/位流hash。

## 冻结 ROI 的板上 FlyHash（2026-10-05）

面板“冻结当前 ROI · 验证板上 FlyHash”保留当前几何参数，临时持有原帧，等待同一冻结源的两个 Canny 发布，然后回读480×270前台位图。主机复用`models/flyhash.py`提取8×8占据率特征；64个uint8送入FPGA稀疏投影/WTA编码器，结果与主机逐bit核对，带源frame/config及Canny epoch。图中没有OSD像素混入特征。结束后恢复原显示/ROI/冻结状态；网页展示的结果明确是已完成任务，不是实时推理。

```powershell
. F:/Project/fpga/vision_base/scripts/efinity_env.ps1
& "$env:PYTHONHOME/bin/python.exe" F:/Project/fpga/vision_base/scripts/flyhash_board.py --url ftdi://0x0403:0x6011:4:9/2 --output-dir F:/Project/fpga/vision_base/results/my_flyhash --self-test
& "$env:PYTHONHOME/bin/python.exe" F:/Project/fpga/vision_base/scripts/verify_roi_board.py --url ftdi://0x0403:0x6011:4:9/2 --output-dir F:/Project/fpga/vision_base/results/my_roi_check --seconds 60 --snapshots
```

`--self-test`额外核对32组人工特征向量；不是32张实物识别样本。计算部分固定4877个148.5MHz时钟（约32.84µs），不含JTAG读图/特征传输。当前完整边缘图读回约4.4s，连接局部FTDI latency设1ms后恢复。特征提取仍在主机，编码器在FPGA；原型标签、未知阈值与实时片上特征提取还需后续实施。

USER2页29为valid/busy/feature_ready/fault、loaded、7bit任务序号、13bit计算周期及frame/config/epoch；页30/31为256bit编码的低/高128bit。命令0x50开始，0x51的[13:8]为0…63特征序号、[7:0]为值，0x52中止。乱序/重复特征、任务中源/config/epoch/扫描错误计数变化会终止当前任务，不发布错误编码。ROI的`frame_ok`每个VS都会清零，因此分析持有的是冻结lease，而不是把正常帧边界当错误。成功结果保持原标签，后续显示或参数变化不把旧编码伪装成新帧结果。

### 光照恢复后的片上特征版（本日后续，当前版本）

默认`flyhash_board.py`现在使用`--feature-source fpga`：0x54开始任务，FPGA借用既有Canny水平消隐读端口扫描4050个32bit位图字，64个小计数器统计8×8分区，再用整数串行除法精确计算`(count*255+area//2)//area`，自动送入编码器。没有新整帧缓存或DDR客户端。原图和Canny位图的主机读取用于观察及独立核对，不再由主机提供生产特征。`--feature-source host`只用于参考输入；`--compare-host`可在同一冻结源/配置/epoch上比较两条路径。

0x56选择特征向量的四个16byte区段；页30临时返回tag`26100520…26100523`及128bit数据，低byte对应该区段第一个特征。0x57恢复页30的hash格式。主机在读向量前后检查完成状态与任务序号，并核对全部64个值，不仅比较可能碰撞的hash。成功结果仍带旧任务标签，恢复实时显示后不把它当当前帧推理。

实际非黑边缘输入全部64项逐值一致，片上提取加编码约62ms，编码本身4877周期；图像导出另约4.4s。这仍是冻结任务的片上处理，不是逐帧自动分类，也没有已训练类别。面板把边缘图放到状态JSON之前，直接展示“特征和编码均在FPGA”。证据：`results/project_light_20261005/REPORT.md`。


## 资源优化构建（2026-10-05）

当前调试版默认`IMAGE_DEBUG=1, RAW_FIFO_DEPTH=512`，保留上述原图/模式快照、Canny位图和FlyHash。比赛版用原生`--map_opts top-params=IMAGE_DEBUG top-params=0`，只关闭RAW snapshot、三个RGB probe和行图像snapshot；页28返回RGB位数0，CLI明确报出该构建状态，不导出零图片。Canny位图、ROI/帧池/历史和功能状态仍保留。日常开发继续用调试版，旧完整九图与当前板上状态仍分别显示。

四种布局布线资源、1024/512实板对照、Sapphire独立测量和验证边界见[资源试验报告](F:/Project/fpga/vision_base/results/resource_trials_20261005/REPORT.md)。本轮条带为1920×64、行400–463，接近黑电平的输入不作为明亮画质验收；未替换面板的完整九图。


## 仅RGB行快照开发配置（2026-10-06候选）

IMAGE_DEBUG=2保留原图与M0–M7的RGB行快照，关闭RAW snapshot及三个RGB统计probe。ROI/历史/Canny位图/FlyHash/AE功能统计保持；页3虽然返回RAW禁用tag，bit78:76仍是真实color_order，RGB源导出继续正确排序。RAW工具明确报disabled，图像能力页28仍为1920×1080/24bit；全探针默认IMAGE_DEBUG=1，纯比赛为0。

本轮仅快照配置实际227RAM/53639XLR，snapshot实例5RAM；FOV缓存36→25RAM、算法与输出节拍等价。新三种位流已完成P&R，未上板；当前仍运行此前243RAM调试512版。完整结果与命令：[FOV/快照候选报告](F:/Project/fpga/vision_base/results/fov_pack_20261006/REPORT.md)。
