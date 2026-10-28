# 菜单Flash启动修复

用户反馈固化后菜单不可用。实际板上BOOT magic有效/phase3/JEDEC FFFFFF，CPU0，M7 ABI26102871，CON4未初始化。延迟数分钟后只重启原ROM仍phase3/FFFFFF；仅发AB释放深度休眠再启动同一ROM后BOOT7/EF6017/447344/4400、CPU1，无程序下载。

根因：工程spi_low_power_mode=on，主动SPI配置完成后将Flash置休眠，与现有ROM直接9F识别并加载应用的契约冲突。Efinix AN033 v3.1第77页说明该选项写入位流，配置完成后让Flash休眠。修复只将该bitstream_generation参数改off；菜单代码、默认收起规则、完整DDR应用、AI、RTL、约束、时钟保持。

采用既有完整compile发布门禁，避免手工替换制品清单。通过后只更新Flash配置；0x700000应用/权重包不重写。原始配置/位流清单保存before/；完整旧Flash备份仍在geometry_m7_20261028/flash_20261028/app/flash_before.bin。

现场重新CONFIG/上电验收已向用户异步询问。以新启动BOOT7、CPU1、物理长按/菜单事件及实际菜单RGB为验收，不再把SRAM重配等同配置Flash启动。

完成：编译/时序/资源与前版相同，默认USB+官方all/hostx1固化通过；用户真实断电后长按KEY0菜单出现。板子不在本机，自动冷启动回读/图像未获得。后续识别滞后是独立性能修订，在本地继续，不再尝试硬件连接。
