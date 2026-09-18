# AXI 行读取与缩放连接

`rtl/axi_line_reader.sv` 是 RGB565 行 reader：输入 `req_addr[31:0]`（byte address）和 `req_pixels`，从 AXI4 只读 INCR 128-bit 数据总线读取一段连续像素，并输出 32-bit/keep 行流。`rtl/roi_axi_scaler.sv` 将它与双 bank 2PPC `roi_scaler` 连接。

## Reader 契约

| 端口 | 说明 |
| --- | --- |
| `req_valid/req_ready` | 一条行请求的 ready/valid；只在握手时采样 `req_addr/req_pixels`。 |
| `req_addr` | 任何偶数 byte address；不要求 16-byte 对齐。 |
| `req_pixels` | 1..65535 个连续 RGB565 像素。 |
| `pixel_valid/pixel_ready` | 输出 32-bit beat ready/valid。背压时 data/keep 稳定。 |
| `pixel_data[31:0]` | 低 16 bit 是先像素，高 16 bit 是后像素；keep01 时高半拍清零。 |
| `pixel_keep[1:0]` | `11` 两像素，`01` 一个像素；奇数请求的最后 beat 为 `01`。 |
| `done` | 最后 output beat handshake 后单周期脉冲。非法请求为便于上层收敛，在请求握手沿给 done+error。 |
| `error` | sticky；RRESP 非 OKAY、RLAST 位置错误、零长度、奇数地址或 32-bit 范围错误均置位。 |

AXI 命令属性固定为：`ARID=0`、`ARSIZE=4`（16 bytes）、`ARBURST=INCR`；`ARLEN` 按 `MAX_BURST_BEATS`、剩余 beat 数和当前 4 KiB 页剩余 beat 数裁剪。`ARADDR` 始终 16-byte 对齐。一次只保留一个在途 burst，默认最大 16 beats；reader 内部 `FIFO_BEATS=16` 的 beat FIFO 吸收 R 返回间隙与本地解析延迟。

## 非对齐起点与边界

请求起点通过 `req_addr[3:1]` 选择首个 AXI beat 内的 16-bit lane，前置 lane 被丢弃；末尾只产生 `req_pixels` 个像素。若一对本地像素横跨两个 AXI beat，reader 使用 current + one-beat look-ahead 组出正常的 keep11 beat，不把中间跨界误报为 keep01。keep01 只表示请求的单像素首/尾半拍（在本实现的正常行请求中表现为奇数长度的末 beat）。

每次 burst 的起始地址按 16 bytes 对齐，`ARLEN` 严格在 `ARVALID && !ARREADY` 期间保持；AXI R 通道用 FIFO 满反压，不用改变尚未握手的 ARLEN。4 KiB 计算在对齐后的 `ARADDR` 上完成，因此 `0x...0ff0` 后不会跨到下一页。33-bit 请求末地址检查允许 `0xffff_fffe + 1 pixel`，拒绝超出 32-bit 地址空间的范围。

## Reader 流水

- AXI R beat 首先进入 FIFO，FIFO 有空间时 `RREADY=1`；下游停顿只会把反压传到 FIFO 满点。
- current word 和 one-beat look-ahead 让两个 16-bit lane 可以在一个本地 beat 中组合；跨 AXI beat 的 pair 也不需要额外输出气泡。
- output slot 在旧 beat handshake 的同一沿可替换新 beat，steady state 为每时钟一个 32-bit beat。
- reader 不负责行 stride、帧池、AXI 写回或超时；上层每次对一个 ROI 行发独立 `req_addr`。

## Scaler 连接

`roi_axi_scaler` 不更改 job 参数名称，新增输出 `pixel_keep[1:0]` 并透传 32-bit/keep 行流。scaler 的 `rd_cmd` 给出 ROI 行首地址；reader 输出的两个像素由 scaler 按 keep 写入 inactive bank。scaler 在 active bank 输出时预取另一源行，垂直重复不重读、缩小跳行；最终 EOF handshake 才产生 job done。任一 reader RRESP/RLAST 错误会通过 `rd_error` 锁存到 job `error`，上层据此决定是否发布写回帧。

当前包装器只提供 AXI read。它不包含 AXI write、帧缓存、DDR PHY/controller、显示扫描或总线仲裁；接 vendor DDR 时需把 AXI read 连接到合法的 interconnect/master 端口，不应把多组 AR/R 信号直接并联。

## 测试证据

`sim/tb_axi_line_reader.sv` 检查 aligned/offset/跨 4 KiB/合法最高地址、burst cap、AR 背压稳定、R 背压稳定、keep11/keep01、非法请求和 RRESP 错误。`sim/tb_roi_axi_scaler.sv` 检查真实 reader+scaler 串接的 NN 坐标、ROI offset、stride、4 KiB split、奇数尾、metadata、背压和错误传播。完整执行由 `scripts/verify.ps1` 统一编译现有 testbench；full 周期应结合 `results/verification.full.json` 和实际日志读取，不应从无背压模型外推板级 FPS。
