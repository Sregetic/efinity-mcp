# 2026-10-28 M7完整项目Flash固化

## 配置、应用和权重已写入

最终58458XLR/243RAM/64DSP、WNS+0.109ns/WHS+0.026ns的配置已写Flash 0地址并通过厂商onchipx1校验。完整447344B相机应用及4400B原权重以451776B VBO1包写0x700000，实际逐字节读回一致。人脸属于M7，独立AI模型/推理不变。

原Flash完整8MiB备份保存在本机 `app/flash_before.bin`，连同原始hex不上传GitHub。恢复时使用官方同设备JTAG桥，按备份重写；桥接之后用已验收SRAM位流恢复运行。旧验收位流/应用亦保留在 `results/edge_visibility_20261027_144437/release/`。

配置首次校验报告不一致，厂商工具内置“retry program using max clk”重写后校验成功；未修改厂商代码。日志为 `config/write.log`，最终回执 `config/result.json`。写入仅擦除配置所需1052KiB，应用区0x700000不在该范围。

## ROM从Flash加载的应用已实际核对

写配置后用同一最终位流重启SRAM，让片上ROM从SPI加载应用。USER1只halt/read/resume，**没有下载程序或权重**；读取启动记录为 `[0x56424f31,7,0xef6017,447344,4400]`，CPU状态1。

通过已测的1MHz/1KiB静态读口，将全部447344B应用和4400B权重与最终制品逐字节比较，一致后恢复CPU；约48.672s。记录与实际读回字节在 `autoboot/`，核对入口为 `verify_autoload.py`。Boot ROM原CRC格式与加载入口保持。

**配置Flash写入和校验已通过；本轮未触发从配置Flash重载，也未进行物理断电。** 这里的自主加载证据针对ROM从Flash读入配套DDR程序，不将SRAM重配冒充配置Flash冷启动。

## 自加载后的M7与视频通过

完整M7结果已完成且源/render/context匹配，native有效、DMA owner0、DMA失败/故障0，见 `m7_completed.json`。固定背景一轮联合判定2873.865ms；源视频8秒约29.8750fps，RAW溢出/采集丢弃/扫描坏帧累计0，见 `health.json`。

已恢复实时M7/MED1/F0、Sobel96/Canny96、几何开启、ROI关闭、一级图像菜单打开，无测试冻结/源租约。`post_flash.py` 的finally释放外部Canny持有；`final_state.json`与`acceptance.json`留存。前轮17组算法、22项UI事件、实际RGB24及2046208像素零差异证据仍适用于此同一候选，未重复计为新测试。

实物人脸、多目标、实体按键、物理HDMI和长时测试仍待现场。

## 文件与复现

- 最终位流/ELF/权重：上级 `release/`；配套VBO1包：`app/vision_boot.bin`、`app/vision_boot.hex`。
- 应用Flash写入：项目已有 `scripts/program_vision_boot_flash.ps1`，显式传最终ELF、权重、新输出目录。
- 本次配置Flash写入脚本：`program_config.ps1`，要求完整旧Flash备份和已通过应用回读；采用同封装官方桥及厂商all/onchipx1。
- `verify_autoload.py` 只读已启动应用；`post_flash.py` 检查M7并恢复实时菜单。不要重放旧地址专用断点或再次向已验证的运行应用下载程序。

本轮 `configuration_flash_written=true`、`application_flash_written=true`、`physical_power_cycle_verified=false`、`config_flash_reload_verified=false`。

GitHub沿用源码/精选证据发布规则：位流、ELF、VBO1包、实际DDR二进制及旧Flash备份留本机；远端release目录为构建报告与元数据。完整固化制品仍在本机上述路径。
