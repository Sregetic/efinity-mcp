# AI加载器、分析DMA与INT8联调

2026-10-07。当前SRAM为`dma_final_snapshot`，DDR中运行`ai_firmware_single_gray/vision.elf`和合成联调权重。当前实时显示：M0、median1、Sobel96/Canny96、memory0、ROI关闭；后续Canny弱轮廓复核已单独128→96，见[阈值复核](CANNY_THRESHOLD_FIX_20261007.md)。Flash保持；断电后AI程序/权重需重新通过USER1加载。真实卡片训练/测试、I1几何引导与I3融合OSD仍待完成。

## 实际完成与证据

- USER1加载8496字节程序和8192字节权重，CPU内存逐字节回读一致，再resume入口；运行校验通过。最终静态模型测试载荷13256字节，超过原3840限制。保留原嵌入ROM限制，新增DDR linker，而不是删除4KB ROM的边界检查。
- 128→32→4 INT8模型导出标准TFLite和4400字节固件权重；192组主机逐层比较一致。板上32组输入的1024个隐藏值、128个输出值，另4幅灰度的特征和FlyHash全部匹配。仅使用合成联调数据，实物精度没有登记通过。
- 新增独立compute lease和第5个共享AXI客户端；显示/扫描的旧lease保持。精确frame请求找不到源时返回stale，保留历史/冻结保护。32×32 origin-floor采样输出DDR双缓冲uint16灰度，CPU完成后ACK；源lease在最后响应结束后释放。
- 实际冻结源4694，ROI=(13,7,37,45)：DMA的1024灰度像素与同帧JTAG原图逐值相等。128特征、32隐藏值、4 logits与256-bit FlyHash也分别匹配主机参考。source_config_id是采集配置，不等于显示ROI的render config_id；尚未将它们作为I3同帧融合的完整契约。
- 实时59.687秒：源29.9898fps，每帧2073600像素；RAW overflow、capture discard、scan bad的新增计数均0。历史scan bad=152保留，未清零伪装通过。X3的17cycles及中心像素25.798–126.545µs保持；按用户选择关闭整机显示延迟探针，读数明确为disabled/null。
- 自动分析目标10Hz；短窗实测112次/12.583秒=8.9007Hz，含USER1停核回读时间，不当成纯连续推理速度。当前一帧DMA1.530ms、网络2.797ms、CPU整体6.131ms；CPU整体包括灰度/特征/FlyHash，不含DMA和显示等待。

原始记录位于`results/ai_closed_loop_20261007`：`loader_board/result.json`、`loader_execution.json`、`inference_board.json`、`mulhi_execution.json`、`same_frame_pixels.json`、`camera_exact/validation.json`、`runtime_summary.json`、`live60_stream.json`、`native_builds.json`。位流、ELF、官方生成IP和工具保持本机，不上传GitHub。

## 资源：计入物理路由占用

|构建|XLR/60800|RAM/256|DSP/160|最终WNS/WHS ns|部署|
|---|---:|---:|---:|---|---|
|上一轮final_snapshot|58759|243|50|+0.128/+0.026|历史|
|新dma_final_snapshot|60015|243|58|+0.093/+0.026|当前SRAM|
|新dma_final_competition|59941|238|58|+0.063/+0.026|未烧录|

两份新制品均map/interface/P&R/pgm PASS、未分配核心引脚0。snapshot保留5RAM原图/各模式行回读，DISPLAY_LATENCY_PROBE=0；X3算法与行级统计保留。比赛版实际剩859 XLR、18 RAM，不再沿用DMA接入前4131 XLR的预算。新DMA使用0RAM，输入双缓冲位于DDR；RAM持平是新增功能没有占用片上RAM，并非本轮又释放了18块。

通用DMA首版完整调试超容量；关闭整机延迟探针后packed60468，但加1044 routing XLR仍达61512，仍失败。固定事务DMA替代通用行读取器/帧写入器后，DMA层级2131.5→844.5 XLR，净省1287；最终snapshot总量60015包含643 routing XLR。物理总量以含routing的报告为准。早期单字符串map_opts被厂商忽略、未启用SoC/DMA的构建也保留为无效候选记录，未部署。

## 实测回归和修复

1. 800kHz USER1批量回读出现277程序字节和354权重字节错误；100kHz回读一致。设置明确100kHz，不做自动重试降级。该厂商OpenOCD target没有checksum_memory，使用实际CPU字节比较，成功后才resume；失败留在halt状态。
2. TFLite负数tie揭示双重舍入差异；统一TFLITE_SINGLE_ROUNDING。signed32 MulHi CFU对应shift≤−2的导出契约，4097主机案例、1024 CFU极值/随机和板上模型通过。静态网络平均3.619→2.784ms，约快23.1%；不宣称整个视频链加速23.1%。MulDiv原已关闭，没有再虚计省800 XLR。
3. 识别固件开启时显示欠载增长；停分析及DMA-only各10秒均稳定。删除多余1024字节栈灰度副本，直接复用有发布标志保护的analysis_gray后，10秒、同帧导出和实时60秒均稳定。证据`frozen_steady_*`、`analysis_off_*`、`dma_only_*`、`single_gray_*`保留，数据支持重复灰度写入/工作集造成的共享访存压力；未补拍AXI波形来断言具体cache冲突位置。
4. 实物采样工具导出packed-frame native channels，与DMA一致；普通网页原图仍按显示颜色顺序导出。ROI shadow修改不影响任务标签，固件读取锁定的actual ROI寄存器0x130/0x134。

## 联调入口

执行目录`F:/Project/fpga/vision_base`，先加载`scripts/efinity_env.ps1`。编译模型自测：

```powershell
python scripts/build_vision_firmware.py --load-method user1 --mulhi-cfu --main models/shape_cards_bringup/model_selftest.c --output-dir artifacts/vision_soc/model_selftest
python scripts/build_vision_firmware.py --load-method user1 --mulhi-cfu --main firmware/vision/ai_main.c --output-dir artifacts/vision_soc/ddr_firmware
# 使用Efinity的Python，且位流必须已具备DMA与CFU function1。
python scripts/load_vision_ddr.py --url ftdi://0x0403:0x6011:4:9/2 --elf artifacts/vision_soc/ddr_firmware/vision.elf --weights models/shape_cards_bringup/shape_cards_weights.bin --output-dir results/ai_load
python scripts/read_ai_result.py --url ftdi://0x0403:0x6011:4:9/2 --elf artifacts/vision_soc/ddr_firmware/vision.elf --latest --roi 640 300 640 480 --output-dir results/ai_read
```

ROI参数使用四个独立整数。精确冻结源改用`--frame FRAME_ID`，与`--latest`互斥。读完resume，普通读图不改变显示。主机`validate_ai_result.py --directory results/ai_read --weights models/shape_cards_bringup/shape_cards_weights.bin`比较全部特征/层输出/hash。

原生构建参数必须作为独立CLI参数：

```powershell
python F:/Efinity/2026.1/scripts/efx_run.py ti60f225_oob.xml --flow compile --output_dir OUTPUT --work_dir WORK --map_opts top-params=IMAGE_DEBUG top-params=2 top-params=SAPPHIRE_ENABLE top-params=1 top-params=RAW_TO_POOL top-params=1 top-params=ANALYSIS_DMA_ENABLE top-params=1 top-params=DISPLAY_LATENCY_PROBE top-params=0 --pnr_opts seed=1
```

在`board/ti60f225_v4`执行，官方Sapphire生成IP由本机既有生成脚本准备。当前默认ANALYSIS_DMA_ENABLE=0保持旧入口；以上明确开启1。比赛版只将IMAGE_DEBUG改为0。

## 实物数据与后续

采样使用`collect_shape_sample.py --dataset DATASET --split train|test --label blank|circle|rectangle|triangle --session-id SESSION --card-id CARD --url URL`。工具回读真实原帧并恢复显示；训练测试同时隔离card_id和session_id。`train_shape_cards.py --manifest DATASET/manifest.jsonl --output-dir MODEL`；合成联调须显式`--synthetic-bringup`。训练环境本机Pythonvenv使用tensorflow2.21.0、numpy2.5.3、Pillow12.3.0；不导入未使用的算子。

官方[generator](https://github.com/Efinix-Inc/tinyml/blob/main/tools/tinyml_generator/README.md)固定版本96886fa0c73e25e6218db7d0863f84677cf65138，本模型只有FULLY_CONNECTED。Lite估算417LUT/506FF/305ADD、4RAM/8DSP；Standard6601/5081/1135、22RAM/16DSP。LUT/FF/ADD不是实测XLR；Lite的旧预算结论仅针对DMA接入前；当前859XLR尚无该加速器的原生联合构建结论。当前选择dot4+MulHi，固定两层C算子保持TFLite数值契约；TFLM留待实际模型出现更多算子时接入。

尚待：真实卡片数据与精度、I1几何定位ROI、I3同帧几何/AI融合OSD与未知/过期标记、FlyHash真实原型对照、邮箱缩减、SPI独立上电、完整控制面。现有Canny双缓冲、中值、历史、按键职责未为AI删除。软件测试71pass/1 Windows符号链接权限skip；真实MCP stdio用例通过，硬件Runner未触发。
