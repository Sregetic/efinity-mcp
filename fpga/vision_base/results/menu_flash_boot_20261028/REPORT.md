# 菜单随Flash自主启动修复（2026-10-28）

## 根因与改动

菜单已包含在完整应用里，但主动SPI配置完成后Flash进入深度休眠，ROM紧接着读9F芯片ID得到FFFFFF，停在BOOT phase3。CPU状态0，CON4菜单状态未初始化，因此长按KEY0无法打开侧栏。

实测对照：原状态phase3/FFFFFF；延迟数分钟只重启原ROM仍phase3/FFFFFF；仅发AB释放Flash休眠，再执行原ROM，转为BOOT7/EF6017/447344B程序/4400B权重、CPU1。没有下载或改写DDR应用，问题位于配置与启动交接，不是菜单绘制或按键定义。

只改工程bitstream_generation中的 `spi_low_power_mode: on → off`，使配置完成后Flash保持可读。菜单、默认收起状态、AI、RTL、DDR应用、引脚与时钟均不改。Efinix明确说明“Power down flash after programming”在配置完成后让Flash休眠，选项写入位流：[AN033 v3.1，第77页](https://www.efinixinc.com/docs/an033-configuring-titanium-fpgas-v3.1.pdf)。

## 制品与门禁

通过现有完整compile发布门禁，58458XLR/243RAM/64DSP、WNS+0.109ns/WHS+0.026ns、未分配核心引脚0，均与前版相同。`native_compile.log`显示spi_low_power_mode=off；原XML逐字替换该单项后与最终XML相同。

新配置与原生报告在 `release/`，并同步到原交付入口 `results/geometry_m7_20261028/release/`；配套447344B ELF及4400B权重原样保留。旧故障配置在 `before/`，不得作为独立启动交付。

## 实际验收

配置区已通过厂商hostx1完整回读校验；原0x700000应用区未重写。用户实际断电重上电、等待并长按KEY0后，明确确认“菜单已出现”。板子已离开本机，自动BOOT/菜单状态回读因USB未连接而未完成；现场结果为用户确认，不冒充自动抓图或读回。见acceptance.json。

诊断记录：`diagnosis.json`；原始三步记录在 `results/geometry_m7_20261028/menu_flash_check/read.json`、`restart_rom.log`、`wake_rom.log`。原8MiB Flash备份和0x700000应用包仍保留，本次只改配置区。

## 烧写过程与恢复

首次烧写在解锁状态轮询超时；1ms USB延迟试验虽然通过解锁，但后续发生桥接CRC模式和USB超时，未采用。完整读回显示首个不一致在256B页边界。最终恢复厂商默认USB设置，使用标准all/hostx1流程；工具检测首次数据不一致后按最大页等待时间重写，最终完整回读校验通过并恢复写保护状态。失败日志保留，未将失败轮次计作成功。

完成回执为flash/result.json、flash/write.log；program_config.ps1沿用标准厂商流程与已有制品门禁。试验性低延迟入口已删除，避免误用。最终配置固化后才通知用户断电，用户随后反馈菜单出现。
