# 2026-10-17 当前Canny版本与启动设置固化

## 已完成的写入

用户明确授权把当前验收版本固化到Flash，保留功能和图像回读。配置采用已验收的`results/canny_smooth_20261017/sample_pass/release/`同一位流，不重编FPGA、不改RTL/SDC、不删探针。既有源/制品/时序门禁通过，当前USB重新枚举为FTDI4232接口2。

- 配置区地址0：1082168字节，官方写后校验成功，另实际读回全部配置字节与选定位流逐字节一致。见`config_flash/result.json`、`write.log`、`read.log`。
- 应用区0x700000：182160字节VBO1包，包含177728字节完整相机应用（内含54640字节FOMO模型）及原4400字节MLP权重；写后校验和实际字节读回均通过。保留原TinyML/INT8、FlyHash、连接组、FOMO、DMA/控制与自检，不换成简化控制程序。
- 写前完整8MiB旧Flash备份：`app_flash/flash_before.bin`。配置写入范围没有覆盖0x700000应用区。
- 资源保持60050/60800XLR、235/256RAM、62/160DSP，余750XLR/21RAM/98DSP；沿用原生WNS+0.071ns/WHS+0.029ns和未分配核心引脚0的验收结果。新增变化只在DDR固件，不增加片上资源。

## 启动设置的根因与修订

只写配置位流并不保存此前USER2临时下发的参数。旧`control_init()`初始化M3/MED0、Sobel/Canny128、AI策略2，且未主动提交默认设置；这与固化前读取的当前设置不同。

现由同一个`control_init()`初始化M5/MED1/F0、Sobel128/Canny80、SHAPE32、ROI关闭、正常菜单、AI策略0，并设置已有feature_dirty，启动后通过原帧边界提交握手自动生效。不增加运行时自动写Flash。颜色顺序2、Tone3、WB336/256/504、自动曝光开启已经是所选硬件位流默认值，保持原配置。

冷启动默认值新增回归先在旧固件失败，修订后RV32I控制回归通过，覆盖独立阈值、下限/步进、历史、11页菜单、AI单次/自检/FOMO选择、缩放/平移/冻结和原子提交。构建沿用既有`build_fomo_firmware.py --camera --cfu-kernels`、同一官方TFLM revision、RV32I和dot4/MulHi，不开启MulDiv或硬件加速器。

当前完整固件也同步发布到`artifacts/vision_soc/ddr_firmware/`，与Flash应用一致，避免默认打包/读取工具继续使用旧的简化应用；旧默认制品保存在`previous_default_firmware/`。独立交付模板的启动默认值同步更新。固化前设置实测快照见`before*.json`与`startup_settings.json`。

## 已完成的自主加载检查

应用写入后，当前验收位流重新配置SRAM；ROM从SPI自主加载程序/权重，没有USER1程序下载。随后只读诊断、不下发模式或阈值设置，实际已进入M5/MED1/F0、Sobel128/Canny80、ROI关闭、菜单0、AI关闭，采集继续更新且Canny ready1/fault0。见`autoload_defaults.json`、`autoload_ai.json`及`after_config_defaults.json`。

## 断电与功能验收

配置/程序Flash均已写完并核对，已请求用户实际断电5秒、上电等待20秒；用户随后回复目前不在现场，物理断电验收保持待完成，SRAM重配置仍单列。收到实际断电反馈后，先只读核对启动设置、帧计数和SPI启动状态，再验证原图/Canny/叠加回读与关键控制路径。

本次保存的是这一组上电默认设置；后续临时按键调整不自动写入Flash。曝光数值仍按现场光照自动收敛，不固定为写入前808。相机仍是SC431HAI原生1920×1080中心窗口约30fps，HDMI扫描60Hz；Canny检测480×270、1080p重建。紫闪长时、SC2210和实物识别精度不计作本轮通过。

最终写入记录见`deployment.json`。完整旧Flash备份、选定位流、完整应用/权重包、实际写后读回、编译产物及日志均保留。
