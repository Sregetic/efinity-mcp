# HDMI 黑屏：板级资料核对（2026-09-15）

用户确认摄像头排线接 J4。以下为文档/工程核对，不代表已经定位物理黑屏根因。

| 信号 | 手册 PDF 第34页 | 原理图 PDF 第8页 | 当前 peri.xml |
|---|---|---|---|
| LED0 | GPIOR_27 / P13 | GPIOR_21 / N14 | led[0] -> GPIOR_21 |
| LED1 | GPIOR_24 / N13 | GPIOR_22 / P14 | led[1] -> GPIOR_22 |
| KEY1 | GPIOR_22 / P14 | GPIOR_27 / P13 | i_arstn -> GPIOR_27 |
| UART_RX | 手册本表未列 | GPIOR_28 / R14 | led[2] -> GPIOR_28（与原理图用途冲突） |

- 因此手册表格与同包原理图存在版本/标注差异；不得直接按手册表批量换脚。
- 当前 reset、LED0、LED1 跟原理图相符，并非这些引脚已证实配错。
- 25MHz = GPIOL_P_08、27MHz = GPIOL_P_10，与手册时钟表一致。
- HDMI TX 采用 GPIOR_PN_10/13/11/12，分别是 CLK/D0/D1/D2，与手册HDMI表的差分对一致；手册注明 P/N 对调，当前 top 对 TMDS 取反。
- 当前 CSI clock = GPIOT_PN_09，D2 = GPIOT_PN_06，与手册 J4 sensor 映射一致。
- Ti60F225 与 Ti60F225I3 的字符串差异本身不足以推断 PCB 不同；当前工程 device=Ti60F225，timing_model=I3。
- 独立参考 03_hdmi_tx_demo/hdmi_tx_demo_v2 仅使用25MHz参考时钟；当前 pattern 依赖相机工程的三个PLL组合锁定。可作为后续隔离测试候选，尚未编译/下载该参考工程。

当前上板证据：JTAG USER_MODE，CDONE=1，NSTATUS=1；UGREEN25854 MJPEG 抓图仍为均匀 RGB(7,7,7)。未证明 HDMI 输入已锁定。

本轮只读核对与保存报告：未修改 RTL/peri/SDC，未重新烧录。下一步先确认实际PCB版本/LED电路对应，再用最小HDMI链路区分时钟复位依赖与物理输出问题。
