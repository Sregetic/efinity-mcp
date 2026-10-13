# 资源、满幅 ROI 与相机 FOMO 联调

开始于2026-10-12，继续于2026-10-13。最终部署、资源、性能与验收读取下方最终结果；失败候选保留为诊断证据，不算合格性能。

## 范围与实现

保留摄像头1440p约30fps/HDMI1080p60、八种图像模式、完整Canny、六帧历史/F1冻结/F2静态浏览/F3比较、动态ROI/缩放/平移/同源重渲染、图像回读、现有Sapphire/dot4/MulHi、MLP/FlyHash/真实连接组及SHAPE几何识别。没有增加片上张量/图像缓存或删减功能。

写FIFO和突发减为8拍，扫描读64拍、ROI读32拍。普通轮排除已经享有优先轮的客户端；优先传输结束保持普通轮游标，避免每次扫描抢占后普通轮重新从同一客户端开始。扫描FIFO低水位时给两个优先读轮，再服务一个普通读轮；RD/W通道各自保持唯一响应所有者。扫描与渲染仍使用8拍局部FIFO及RREADY背压，原始1666667-cycle截止计数保持。

相机FOMO复用compute源帧持有：START bit3只申请受保护源，CSR0x38发布基址，ACK后释放；旧灰度分析DMA保留。CPU仅从确切源ROI采样96×96 RGB，而不是搬整幅视频。packed16亮/暗量程解码、floor采样、INT8量化、25层推理、同类八邻域格点合并及结果映射均在DDR固件中执行。源码固定模型54640B，tensor arena实用149388B，保留原4400B MLP权重。

最终相机应用`camera_cooperative/vision.elf`的load177728B、BSS66048B，模型和样本数组均在现有DDR区内；arena预留256KiB，既有2KB缓存和100MHz核心保持。NN BASE/FOMO页面复用控制结构ai_manual bit1，bit0仍是FIX单次请求；不新增硬件命令或更改CON4结构大小。提交时锁存源/显示变换，完成后绑定FRAME/SOURCE_CONFIG/RENDER/CONTEXT/MODEL，不把下一次UI设置映射到旧任务上。FOMO保存全部合并目标，OSD显示最高分目标；格点框不是精确物体轮廓。

长卷积内复用现有control_service_step：Conv普通分支、1×1快分支和DW均在每个输出行开始调用。1×1使用倒计数，不在逐像素热循环增加除法；固定图构建关闭VISION_FOMO，保持原算子路径。行间调度只改变任务/按键服务频率，不修改模型算术、量化、片上缓存或硬件资源。

## 最终结果

原生完整构建、SRAM、DDR实际字节与相机数值验证通过。硬件制品为`priority2_release/`，最终WNS+0.026ns/WHS+0.027ns、未分配核心引脚0；固件为`camera_cooperative/vision.elf`。用户授权后，新配置及应用包已固化Flash，SPI自主加载实际字节核对通过，详见下方固化记录。

|资源|F2基线|本轮最终|净释放/余量|
|---|---:|---:|---|
|XLR|60400/60800|59635/60800|释放765，余1165|
|RAM|252/256|252/256|释放0，余4|
|DSP|59/160|59/160|释放0，余101|

|ROI|基线单次中位|最终单次中位|FOMO并发实际显示更新率：层间→行间|
|---|---:|---:|---:|
|1920×1080满幅|57.046ms|45.061ms|6.25→18.25Hz，2.92倍|
|960×540源放大至1080p|21.013ms|16.881ms|7.65→29.5Hz，3.86倍|

单次耗时相对基线分别降低约21.0%/19.7%。真实更新率来自62.5Hz USER2读取有效显示帧号、各20秒；不是用单次耗时取倒数。满幅仍未达到相机30fps或显示60fps；1666667-cycle截止计数保留。`performance_comparison.json`、`update_rate_comparison.json`及`row_poll_updates/result.json`保存明细。

最终连续FOMO+满幅/2×ROI各59.609/59.563秒，采集29.995/29.985fps、scan_bad/采集discard增量均0；源121462的四次冻结重渲染保持。FOMO完成源117359→121462，停止后恢复正常原图通过。见`cooperative_parallel/`。只有场景近黑的数字联调，不宣称真实卡片或紫闪验收。

`cooperative_load/verification.json`核对最终程序177728B与权重4400B实际字节；`cooperative_camera/result.json`通过FIX不重复、同源修改ROI后重新请求、自检不覆盖相机结果及恢复实时单次请求。冻结源122614、render55/context53、sequence73，修改ROI后render56/sequence74；实时新源128933/sequence75。

最终独立源图与576个INT8输出最大差0、差异字节0；同源灰度、原MLP、FlyHash、80个连接组状态全部相等。最终Invoke2668.156ms、预处理40.044ms、后处理0.303ms，FOMO合计2708.503ms。源图max2/255、41个非零通道值，输出背景/无目标，实物准确率未验收。见`cooperative_camera/frozen/verification.json`和`source_stats.json`。

## 层间候选的首次相机数值（历史）

`camera_final_load/verification.json`：实际USER1程序177760B与权重4400B逐字节读回一致后才resume。快写500kHz/静态读25kHz；动态图像记录使用已核对的5kHz。

`camera_board_roi/result.json`：实体按键事件FIFO策略通过。冻结源42353、render10、context14，FIX首次sequence1；稳定不重复。修改ROI后源保持、render11、sequence2；定点自检不覆盖相机结果。恢复实时后新源48665，单次请求sequence3。这里注入的是和实体按键同一路径的事件，不是人工电气按压。

`camera_board_roi/frozen/verification.json`：独立bulk USER2读取同一冻结源pre-Gamma RGB，再采样96×96；板上576个INT8输出与桌面scalar reference最大差0、差异字节0。32×32灰度、原MLP特征/隐藏层/logits、FlyHash256bit和80个连接组状态也逐值一致；身份号一致，FOMO MODEL2无旧MLP TEST标志。该次Invoke2645.713ms、预处理39.861ms、后处理0.315ms、FOMO合计2685.890ms。四张固定图片既有0.949s结果是在未运行视频的条件下，相机并行速度另测。

实际独立源图1920×1080读回53.672s，min0/max2，35个非零通道值；本次场景近黑，输出背景/无目标。灯光和镜头状态尚未获现场确认。这个结果验证同帧输入、数值与发布链路，**不验证真实形状卡准确率**。后处理非空、多目标、边界和并列分数另由48组RV32I夹具验证。

## 失败候选与根因

- 128拍读且按burst次数均分：ROI数字约17ms，但扫描欠载112→1910，拒绝作为性能收益。
- 动态按拍数分配信用：XLR60579，仍欠载；删除该候选逻辑，不增加复杂调度框架。
- scan32/render32：满幅约26ms但仍欠载；不是可用的30fpsROI。
- scan64/render32、一轮低水位优先：AI关闭时满幅45.775ms、2×16.943ms，零错误；连续FOMO加满幅时约60秒scan_bad5→57。数字变快伴随丢扫描，不作为通过。最终继续修低水位份额。
- 两轮优先的层间固件虽零欠载，实际ROI更新仅6.25/7.65Hz。层间控制调用隔着长算子，渲染完成后等CPU下次调度；修在共享Conv/DW行循环，不用减少NN算子或放宽帧身份规则来提高数字。行间版为18.25/29.5Hz，模型输出仍完全一致。
- 初次并发测试误把PAGE31低14位flags当成DDR完成sequence；核对真实ABI后改用完成状态及源帧推进，另读取完整DDR序号。后续恢复请求暴露CLI2秒等待短于相机推理，改为20秒等当前受保护任务结束；原传播错误保持，未加重试或假成功。
- 两轮优先seed6：XLR59635、RAM252、DSP59，但最终WNS−0.018ns，未安装；留存`priority2_seed6_failed/`。最终结果必须使用时序通过的候选。
- 初版相机C编译缺少本工程`-ffreestanding -fno-builtin`，自制memset被O2转换成递归自调用。实板DDR控制区出现重复SP/返回PC，菜单/阈值被栈覆盖。构建器在自有C源处恢复原选项并检查真实自调用；最终应用及RV32I生产memset核对通过。不把这次程序覆盖归因于读回噪声。
- Efinity允许XML语义不变的格式规范化，但原manifest仍绑定规范化前字节，部署门禁随后拒绝。修producer在接受语义一致时绑定实际保存字节，部署的身份/时序门禁保持。

## 回归与复现

核心19项、视频32项及RV32I控制/变换/packed65536值/四种ROI采样/48格点目标、旧DMA与RGB持有、OSD页面/单位、加载器/SPI/图像codec均通过。当前优先2扫描/普通轮/响应所有权测试通过；1080p完整共享总线2074112像素、CPU全部128bit存储通道、读写错误禁止发布通过，仿真render1739810cycle/截止1仍如实报告，不放宽截止。最终行间版368组算子/112420组算术和逐输出行调度检查通过。

最终9种模式（源图+八种显示）的1920×32诊断条回读同源131508通过，见`mode_readback_release/images.json`；是接口/身份验证，不是全幅画质验收。最终BASE菜单/灰度DMA/MLP/FlyHash/连接组的FIX单次、重复请求、自检不覆盖、恢复实时单次均通过，见`legacy_ai_release/result.json`；此前17项阈值/按键/六历史/冻结ROI事件通过，见`priority2_keys/result.json`。最终恢复M0/MED1/F0、正常菜单、Sobel128/Canny80、AI OFF、全幅ROI关闭，显示有效、scan_bad/discard0；人工电气按压未计。

实际操作与重跑命令见 `F:/Project/fpga/vision_base/docs/CAMERA_FOMO_AND_ROI_20261013.md`。TensorFlow主机对照使用`F:/efinity-ci/tinyml-env/Scripts/python.exe`。本地`reload_camera.py`记录本轮快写/慢读验证步骤，`test_parallel.py`复用现有ROI测试并在结束恢复实时原图。

最终SPI应用包为182160B、保留旧权重；`standalone/`记录最初准备阶段，`flash_20261013/app/`记录本次实际写入。配置Flash、应用Flash读回、自主SPI加载、KEY1恢复和实际拔电启动分别记录。当前配置和SPI应用来源均已更新到本轮版本，物理断电验收另列。

## 2026-10-13 Flash固化与SPI自主加载

用户确认不在现场，并授权数字验证通过后固化配置Flash和控制程序。沿用现有脚本与官方JTAG bridge，写前保存完整8MiB旧Flash；保留原权重，未改视频/模型算法或增加硬件资源。

- 应用包182160B在0x700000写入，仅擦除180KiB；实际Flash读回全部字节一致。见`flash_20261013/app/result.json`。
- 配置1072572B在0地址写入，仅擦除1048KiB，未触及应用区；官方onchipx1最终验证成功，写保护状态恢复。见`flash_20261013/config/result.json`。
- 两次写入各有首次官方验证失配及programmer内置max-clock重写，日志原样保留；最终均成功。没有自行增加重试或以退出码掩盖失配。
- JTAG重新配置同版SRAM、BootOnly无主机视频配置后，采集/显示373帧、capture379、frame_ok1、丢弃/欠载/错误0。新程序自主SPI加载：BOOT7/JEDEC EF6017/CPU1、177728B程序和4400B权重实际DDR全部字节一致。USER1仅halt/read/resume，无程序下载。见`flash_20261013/autoload_video.json`及`autoboot/result.json`。
- `verify_vision_boot.py`原300秒期限短于178KB应用已测12.4分钟回读；改成2400秒上限，25kHz静态读回和实际字节判据保持。当前自主加载验证实际通过，而非只延长等待后假定成功。

完整8MiB备份、位流、ELF、原始DDR/Flash二进制保持本地，不上传Git；上传源码和小型JSON/日志证据。配置内容验证、程序SPI自主加载、人工KEY1和拔电独立启动分别记录。

自主加载后的板上复测通过：

- `flash_20261013/keys/result.json`：17项独立阈值、下限、菜单、冻结同源ROI/缩放/平移/视口及历史事件通过，属于注入实体键事件队列，不是人工电气按压。
- `history/runtime_checks.json`：八模式、实时推进/F1冻结、F2/I0静止且六帧可选、I6主动播放及停止、F3与Canny持续发布通过；I0静态源28055保持。
- `post_flash_result.json`：NN BASE→FOMO、FIX冻结源29875、sequence1/MODEL2完成、启动自检PASS；预处理32.658ms、Invoke2667.750ms、后处理0.380ms。此次合并1个候选目标，用户不在现场，不认定类别准确率或有效实物卡。
- `final_live.json`：恢复M0/MED1/F0/菜单0、Sobel128/Canny80、AI OFF/NN BASE、全幅ROI关闭；显示30492→30597、采集30498→30602，丢弃/欠载/配置/渲染/扫描/Canny错误0。复位默认仍为M3/MED0/F0/128/128，最后主机设置未新增掉电参数保存。

只读实际DDR核对后按上述实体控制链测试，未使用USER1程序下载或补写张量。CPU启动、Flash验证和人工光照/实物/拔电验收继续分开。

## 验收边界

实物卡准确率/泛化、人工按键、HDMI目视/紫闪、真正拔电且JTAG断开的启动均另行验收。当前不添加官方AI硬件核，不降低Canny检测尺寸或减少图像回读；余量以最终联合原生报告为准。原完整项目范围保持。
