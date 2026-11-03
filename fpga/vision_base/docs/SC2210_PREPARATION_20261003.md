# SC2210 → Ti60转接板 → MIPI：提前准备

2026-10-04追加：相同后端已接入Canny脉冲中值、噪声下限、32像素连通域抑点和JTAG整幅边缘读图。SC2210参考位流B9D7E28D…完整构建/源码门禁通过，WNS+0.337/WHS+0.026ns；仍保留2-lane/24MHz/1080p30参考profile。当前实板是SC431HAI的0550966A…消噪版，HDMI仍1080p60。以下首次准备记录中的F6BF板上身份属于历史，最新身份以current_state.json为准；见[追加实测](../results/noise_finish_20261004/REPORT.md)。

## 已接入的代码

- 以 `-Sensor sc431hai/sc2210` 构建；默认仍为SC431HAI。SC2210制品存到 `artifacts/camera_sc2210`，当前摄像头制品仍在 `artifacts/camera`，避免覆盖成另一种传感器版本。
- SC431HAI保留优化后的2560×1440→1920×1080 FOV滤波。SC2210使用原生1920×1080 RAW10输入，保持四像素打包与RAW8存储顺序，并把CSI帧开始脉冲归一成完整帧VS，不套用3/4缩小。
- MIPI接收lane数量与byte-clock参数来自所选profile，支持2/4-lane；未改变PHY引脚、HDMI协议/PLL、1080p60显示、DDR布局、去马赛克、Gamma/颜色处理、Sobel/Canny、A6、按键及冻结/历史功能。
- I²C使用现有单所有者控制器，增加外部初始化ROM输入；计数器能表示表末终值，覆盖256项整幂表而不回绕。SC431HAI原164项表保留。
- AE和曝光写入器共享所选profile的范围与初值，保留原算法、三字节写入/回读和诊断接口。主机控制按选定传感器制品读取曝光范围。
- 烧录工具增加 `-ValidateOnly`，可完整检查源码、制品、传感器选择、setup/hold和引脚而不连接JTAG编程。构建后临时传感器header恢复为当前默认。

## 参考配置与真实模组的区别

厂家[VS-SC2210产品页](https://www.szovs.com/en/cmos-camera/566119)列出的模组为4-lane、1920×1080@60，并提供Ti60方案；实际用户将购模组尚未确认，不将这个商品规格视为已经取得其初始化表。

已保存厂家公开的[SC2210 V0.8数据手册](https://www.szovs.com/Data/szovs2/upload/file/20240224/SC2210_%E6%95%B0%E6%8D%AE%E6%89%8B%E5%86%8C_V0.8.pdf)，核对ID2210、7-bit I²C地址30、RAW10 DT2B、lane/位深寄存器和曝光边界。源码参考为固定commit的[SC2210 T31驱动](https://github.com/themactep/ingenic-sdk/blob/0eb3addbb3cac7ee85a5cc021514830e4dde2a1e/common/sensor/t31/sc2210.c)中的2-lane/24MHz/1080p30数组，253项原值不改，仅转换为项目ROM字格式。此参考用于提前验证代码接入，未确认与未来4-lane模组匹配。

厂家HDK百度分享入口本轮浏览器加载两次超时，未取得该模组Ti60初始化工程；没有以修改lane寄存器或猜PLL值的方式把2-lane参考表伪装成厂家4-lane表。已询问具体模组型号/链接，匹配后替换profile和对应寄存器表。

## 构建与检查

```powershell
# 保留当前摄像头模式，HDMI仍为1080p60
& 'F:/Project/fpga/vision_base/scripts/synthesize.ps1' -Top board -Flow compile -VideoMode camera -Sensor sc431hai

# SDK参考模式：仅提前验证接入；不是未来模组的默认烧录命令
& 'F:/Project/fpga/vision_base/scripts/synthesize.ps1' -Top board -Flow compile -VideoMode camera -Sensor sc2210 -SensorProfile 'F:/Project/fpga/vision_base/board/ti60f225_v4/sensors/sc2210_1080p30_2lane_24mhz_reference.json'
& 'F:/Project/fpga/vision_base/scripts/program_vision_sram.ps1' -VideoMode camera -Sensor sc2210 -ValidateOnly
```

真实模组到位并取得匹配表后，先核对ID、lane、MCLK、RAW10/BGGR、1080行×480个32-bit字及连续帧；再核对DDR完整发布、错误计数、曝光回读、显示/冻结/历史/边缘/识别。原BLC16和白平衡系数未重新标定，换机后用实际暗场/中性目标复测；不把离线P&R作为新摄像头出图证明。

原始输入资料、测试、构建/校验及最终资源结果位于 `results/sc2210_preparation_20261003/REPORT.md`。本轮未烧录、未写Flash，当前板上F6BF…原60Hz版保留。

## 2026-10-04 ROI主链同步
相同动态ROI、缩放、平移、冻结重渲染及四客户端DDR代码已构建为CC4B91EA…，WNS+0.353/WHS+0.026ns，ValidateOnly通过，SC2210未烧录。当前SC431HAI板上为3D1B037A…ROI版；原F6BF/B9D7记录是历史。详见 `results/roi_live_20261004/REPORT.md`。
