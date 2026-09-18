# 板级工作工程来源与变更

输入资料：`F:/Project/fpga/参考资料/Ti60F225_DemoBoard_v4完整资料包..zip`，其中 `10_Ti60f225_sc431hai2hdmi_demo/Ti60f225_sc431hai2hdmi_v6.rar`。

只导入所需RTL、存储器初始化、主工程、接口配置、SDC及调试描述；没有用旧bit/hex或旧构建报告代替本次编译。当前outflow由本机Efinity重新生成。原压缩包保持原样。

## 固定工作点

- Efinity 2026.1.132.3.9；Titanium Ti60F225，I3。
- 活动CSI源为 `rtl/csi_rx_controller.sv`，标注IP 5.15；未把目录中未被工程引用的5.16配置直接替代它。
- 摄像头ROM有效图像配置1920×1080；实际60fps采集需硬件测量。
- HDMI时序为H=1920+88+44+148=2200，V=1080+4+5+36=1125，像素时钟148.5MHz，对应1080p60输出目标。
- CSI数据四个RAW10样本取高8位，32bit/拍写入DDR；显示侧16bit/拍读取RAW8，再去Bayer得到两像素RGB。
- 保留厂商DDR控制器、校准、时钟及HDMI编码逻辑，不移植其他厂商板的引脚。

## 修改清单

| 文件 | 修改 |
|---|---|
| `rtl/frame_buffer_V3/bank_switch.v` | 三帧分支统一计算next-state，先处理读释放，再处理写发布，同拍事件均处理；原有单/双帧分支保持 |
| `rtl/frame_buffer_V3/frame_buffer.v` | 将FB_NUM、MAX_VID_WIDTH、MAX_VID_HIGHT传给ddr_buffer |
| `rtl/ti60f225_oob_top.v` | 最大输入拍数按MAX_HRES/4；移除未连接的旧PLL声明 |
| `ti60f225_oob.sdc` | CLK_25M指定40ns |
| `ti60f225_oob.xml` | 关闭未提供work_dbg生成源码的自动LA注入，保留手工debug_top源 |

三帧分支的ACK表示处理了边界事件；当没有新完成帧可读时维持当前显示帧。当写端没有空闲bank时保持当前写bank，当前设计仍是单采集/单显示的基础轮换，不是完整多读者管理。新的`rtl/frame_pool.sv`是独立通用核心，后续接入时再替换这一层。

原`bank_switch`的局部反例在本工程的`sim/tb_board_bank_switch.sv`中变为正常/并发切换回归；帧跨度验证值为480×1080×4+512=2,074,112字节。

## 报告解释

脚本会检查流程退出状态、“Unassigned Core Pins”、最终 WNS/WHS 和源文件编译期间稳定性，而不是只看CLI打印PASS。`Missing Interface Pins`中被逻辑优化掉的未使用接口仍可能列出，需逐项区分实际未连接的必要信号与供应商预留接口。时序报告结论仅适用于当前SDC；对输入/输出真实板级时序和跨域行为的验证仍在硬件阶段完成。

camera 模式的数据链路尚未接入新 ROI 引擎、完整 Canny、SoC 或 AI。timing_probe 模式将 RGB565 帧引擎接到可综合的地址数据发生器/写校验服务，保留像素数据路以进行实际 P&R；它未接真实 DDR 数据口。pattern 模式提供相机独立的彩条与活动状态。模式制品分别保存到根目录 artifacts/，源码入口共享，避免多份工作树漂移。

新增源码：根目录 rtl/video_test_pattern.sv、frame_render_engine.sv 及依赖；板级 rtl/vision_board_config.vh 由编译脚本临时选择模式。LED定义和上板顺序见 docs/BOARD_BRINGUP.md。本轮帧池并行选择的时序修改没有放宽 SDC、降低时钟或增加 false path。
