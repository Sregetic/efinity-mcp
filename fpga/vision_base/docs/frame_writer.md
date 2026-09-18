# `axi_frame_writer`

`rtl/axi_frame_writer.sv` 是结果帧/采集帧共用的 RGB565 写入边界。它把
2PPC 像素流转换成 AXI4 128-bit INCR 写事务，不包含 DDR PHY、AXI 仲裁或
整帧 RAM。

## 数据与控制接口

### Job 接口

| 信号 | 方向 | 说明 |
|---|---|---|
| `job_valid/job_ready` | in/out | 单 job 握手；只在 `job_ready=1` 时采纳参数 |
| `base_addr[31:0]` | in | 第一行起始字节地址 |
| `dst_width[15:0]` | in | 目标宽度，单位为 pixel |
| `dst_height[15:0]` | in | 目标高度，单位为 line |
| `stride_bytes[31:0]` | in | 相邻行起始地址的字节步长 |
| `busy` | out | 有效 job 从接收至最终 `B` 握手期间为 1 |
| `done` | out | 一拍脉冲；只在最终像素已接收、所有 W beat 已接受且最终 `B` 已握手后产生 |
| `error` | out | sticky 到下一个 job 或复位；表示配置、输入标记或 AXI `B` 响应错误 |

### 2PPC 像素接口

一个 input beat 是两个 RGB565 pixel：

```text
pixel_data[15:0]  = lower-address / left pixel
pixel_data[31:16] = next pixel
pixel_keep[1:0]   = 2'b11 (合法固定宽度协议)
```

`pixel_sof` 只应在第一拍为 1，`pixel_eol` 在每行最后一拍为 1，
`pixel_eof` 只应在整帧最后一拍为 1。`pixel_valid/pixel_ready` 是标准
valid/ready：`pixel_valid=1 && pixel_ready=0` 时，`pixel_data`、keep 和
所有帧标记必须保持稳定。未处于 active job 时 `pixel_ready=0`，额外输入
不会被接受。

本版要求 `dst_width` 为 8 pixel 的倍数，因此每行恰好由
`dst_width/8` 个 AXI W beat 组成，四个 32-bit 输入 beat 正好组成一个
128-bit W beat。每个 W beat 都使用 `m_axi_wstrb=16'hffff`，不会写入
padding。

### AXI 写接口

接口信号为：

```text
m_axi_awid[3:0], m_axi_awaddr[31:0], m_axi_awlen[7:0]
m_axi_awsize[2:0], m_axi_awburst[1:0], m_axi_awvalid, m_axi_awready
m_axi_wdata[127:0], m_axi_wstrb[15:0], m_axi_wlast
m_axi_wvalid, m_axi_wready
m_axi_bresp[1:0], m_axi_bvalid, m_axi_bready
```

固定属性如下：

- `AWID=0`，`AWSIZE=3'd4`（16 bytes），`AWBURST=2'b01`（INCR）。
- `AWLEN` 是 burst beats 减一；`MAX_BURST_BEATS` 默认 16，可按集成配置为
  不超过 32 的值。
- burst 同时受 `MAX_BURST_BEATS`、当前行剩余 beat 和 4 KiB 页边界限制，
  因而既不跨行，也不跨 4 KiB。
- AW、W、B 分别按自己的 valid/ready 握手。模块只保持一个在途 burst，
  但不会等待整帧才开始写。
- AW 或 W 被 backpressure 时，地址/长度或 WDATA/WLAST/WSTRB 保持稳定。
  `B` 只在对应 burst 的 WLAST 之后接受；`BRESP != OKAY` 会置 sticky
  `error`，但仍按已知尺寸排空后续写事务。

## 配置边界

在 `job_valid && job_ready` 的边沿检查：

1. `dst_width != 0`、`dst_height != 0`，且 `dst_width[2:0] == 0`；
2. `base_addr[3:0] == 0`、`stride_bytes[3:0] == 0`；
3. `stride_bytes >= dst_width*2`；
4. 最后一行最后一个 byte 不超出 32-bit byte address 空间。

非法 job 在接受边沿直接给出 `done=1,error=1`，不进入 active 状态，也不
发出任何 AXI 通道。合法 job 的参数在握手时锁存，之后上游改变配置总线
不会改变当前帧。

输入 marker 或 `pixel_keep` 错误会锁存 `error`，但写入仍按锁存的
`dst_width*dst_height` 计数继续，以免错误标记把任务永久卡在半帧。尺寸已知
而输入永久缺失，或 AXI 从设备永久不回 `B`，模块不制造超时恢复；由上层按
系统协议协调复位。

## 存储和地址推进

内部只有组装寄存器和小型 assembled-word FIFO，默认深度为
`2*MAX_BURST_BEATS`（`MAX_BURST_BEATS<2` 时至少为 4），不保存整帧。
FIFO 满时 `pixel_ready` 下降；W 通道释放空间后可恢复接收。帧的第 `row`
行起始地址为：

```text
base_addr + row * stride_bytes
```

行内地址每个 W beat 加 16；行末跳过 `stride_bytes - dst_width*2` 的
padding 后进入下一行。由于合法 base/stride 都是 16-byte 对齐，所有 AW
地址天然对齐。

## 本地仿真

默认回归使用 Icarus Verilog（路径 `C:\iverilog\bin`）：

```powershell
& 'C:/iverilog/bin/iverilog.exe' -g2012 -Wall `
  -s tb_axi_frame_writer `
  -o build/tb_axi_frame_writer.vvp `
  rtl/axi_frame_writer.sv sim/tb_axi_frame_writer.sv
& 'C:/iverilog/bin/vvp.exe' build/tb_axi_frame_writer.vvp
```

测试顶层固定输出 `PASS tb_axi_frame_writer`。`sim/tb_axi_frame_writer.sv`
包含 byte-array memory scoreboard，覆盖：

- 16/32/64/96 pixel 小图、跨 4 KiB 的行、192/256 pixel 多 burst 行；
- `AW` 地址/长度/4 KiB/行边界、ID/size/burst 属性和 `W` 数据次序；
- full `WSTRB`、padding 保持、pixel/AW/W 背压下的稳定性；
- marker/keep 异常、AXI `BRESP` 错误、非法 job 无 AXI 事务；
- `done` 不早于最终 `B` 握手。

附加 `+FULL=1` 会运行 `1920x1080`、2PPC、`stride=4096` 的理想总线案例。
本次本地主机证据为 `cycles=1036821`，低于 100 MHz 下 60 fps 的
`1666667` cycle 帧预算；该数字是 RTL/behavioral-memory 仿真周期，不是
板上 FPS、DDR 实际带宽或 Efinity 时序结论。
