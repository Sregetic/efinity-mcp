# ROI 最近邻缩放核心

`rtl/roi_scaler.sv` 是一个单时钟、16-bit RGB565 的可综合 ROI 最近邻缩放核心。它只负责“DDR 按行抽象读 -> 一行片上缓存 -> 输出流”，不包含帧所有权、MIPI CSI、DDR PHY/controller、HDMI/LCD 时序或跨时钟域逻辑。

当前验收环境没有 Ti60F225I3/SC431HAI 实物；本目录的证据是 Icarus 仿真核心证据，不代表 MIPI/DDR/HDMI/LCD 已完成。

## 端口

所有端口同步于 `clk`，复位为同步低有效 `rst_n`。

| 方向 | 端口 | 说明 |
| --- | --- | --- |
| in/out | `job_valid`, `job_ready` | 单个 job 的 ready/valid。只在 `job_valid && job_ready` 时锁存。核心空闲时 `job_ready=1`。 |
| in | `base_addr[31:0]` | 源帧首字节地址；RGB565 按 2 byte/pixel 解释。必须偶地址。 |
| in | `src_width/src_height[15:0]` | 源帧尺寸（pixel/line）。 |
| in | `stride_bytes[31:0]` | 源帧行跨度，单位是 byte，可包含 padding；它独立于 ROI 宽度和目标宽度。必须为偶数且至少 `src_width*2`。 |
| in | `roi_x/roi_y/roi_w/roi_h[15:0]` | 源帧内 ROI，左上原点，宽高为 pixel。ROI 必须完全落在源帧内，`roi_w <= MAX_LINE_PIXELS`。 |
| in | `dst_width/dst_height[15:0]` | 输出尺寸（pixel/line）。 |
| in | `frame_id/config_id[31:0]` | 随 job 锁存，在该 job 的每个输出像素上保持不变。 |
| out/in | `pixel_valid`, `pixel_ready` | 输出像素 ready/valid。`pixel_valid=1 && pixel_ready=1` 才算接受。背压期间 data/flags/ID 全部保持。 |
| out | `pixel_data[15:0]` | RGB565 数据。 |
| out | `pixel_sof/pixel_eol/pixel_eof` | 当前输出像素的首帧、行尾、帧尾标志；标志与 `pixel_data` 同拍。SOF 仅在 `(x,y)=(0,0)`，EOL 在每行最后像素，EOF 在最后行最后像素。 |
| out | `pixel_frame_id/pixel_config_id[31:0]` | 输出像素对应的锁存 ID。 |
| out | `done` | 单周期 job 完成脉冲。有效 job 只在 EOF 像素被 `pixel_ready` 接受后的时钟沿产生；非法 job 在 job 被接受的时钟沿产生。 |
| out | `error` | sticky job 状态。复位清零；新合法 job 清零；非法 job 置 1 并与 `done` 一起报告，保持到下一次 job 或复位。 |
| out/in | `rd_cmd_valid`, `rd_cmd_ready` | DDR 行命令 ready/valid。 |
| out | `rd_addr[31:0]` | 当前行首像素的 byte address：`base_addr + (roi_y + src_y_rel)*stride_bytes + roi_x*2`。 |
| out | `rd_pixels[15:0]` | 当前行需要返回的像素数，固定为 `roi_w`。 |
| in/out | `rd_data_valid`, `rd_data_ready` | DDR 行返回数据 ready/valid。命令握手后，slave 依次返回恰好 `rd_pixels` 个 16-bit 数据。 |
| in | `rd_data[15:0]` | 当前行 RGB565 数据。 |

### 行读协议

- 一次只允许一个在途行命令；`rd_cmd_valid` 拉高后，在 `rd_cmd_ready=0` 时 `rd_addr/rd_pixels` 不变。
- 命令握手后核心进入接收状态；`rd_data_ready` 在收齐整行前保持高，允许 slave 插入任意空闲周期。
- 收到恰好 `rd_pixels` 个数据后才开始该行输出；不会发出第二条命令，也不会在行响应未收齐时覆盖缓存。
- slave 应在命令握手之后才驱动该命令的数据返回；核心不依赖固定返回延迟。

## 实现策略

- 只有 `logic [15:0] line_buf [0:MAX_LINE_PIXELS-1]` 一行缓存，不分配整帧 BRAM。数据接收按 `line_wr_index` 顺序写入。
- 输出读取在时序块中把 `line_buf[src_x_rel]` 注册到 `pixel_data`，避免用一个异步整行大 mux。综合工具可将这段单端口时序访问映射为同步块 RAM；具体 RAM 推断仍需在目标 Efinity 版本做综合报告确认。
- 横向和纵向都在 job 锁存后各运行 16 轮 restoring divider，得到 `step_int = roi/dst` 与 `step_rem = roi%dst`；两条 divider 并行工作，完成后才发第一条行命令。输出阶段用整数坐标 advance/Bresenham 残差更新：
  `src_next = src + step_int + (err + step_rem >= dst)`，`err_next = (err + step_rem) mod dst`。
  因此每个像素热路径没有可变除法，映射严格等于 `floor(x*roi_w/dst_width)` 和 `floor(y*roi_h/dst_height)`，包括非整数倍率。配置阶段固定增加 16 个时钟（两条 16-bit divider 并行），不引入单拍可变除法器；divider 完成后才发第一条行命令。
- 同一源行可被多个目标行复用（放大时不重复发读命令）；纵向坐标发生变化时才重新请求下一行。缩小时按精确坐标跳行。
- 输出数据寄存器只有在无有效数据或当前像素被接受时才更新；`pixel_ready=0` 时所有输出字段保持，支持任意输出背压。

## 非法 job 与地址边界

在锁存时检查：零尺寸、ROI 越界、`roi_w > MAX_LINE_PIXELS`、奇数 `base_addr`、奇数 `stride_bytes`、`stride_bytes < src_width*2`，以及源帧最后一个像素地址超出 32-bit 地址空间。非法配置不发任何 `rd_cmd`，不接受任何 `rd_data`，并在 job 握手后给出 `done=1,error=1`。输入 job 字段在握手后修改不会影响 active job；所有工作字段已经锁存。

## 吞吐与边界

- 连续输出时，首个像素有一个缓存读取注册延迟；同一行后续像素可达到每时钟接受 1 pixel。每个 job 先固定消耗 16 个 divider 时钟；每个新源行需等待一条命令和该行返回，行切换存在控制气泡。
- 输入 DDR 抽象目前是单行、单在途、16-bit 返回；没有 DDR burst、bank scheduling、FIFO、帧 ping-pong 或 CDC。它不是 1080p60 带宽/时序承诺。
- 仿真中打印的 cycle 数包含 testbench 人为插入的命令延迟、返回间隙和输出背压，仅用于功能/协议回归，不能换算为实物板卡 FPS。
- `MAX_LINE_PIXELS` 默认 2560；测试可用较小参数综合/仿真，但实际目标行宽超过参数时该 job 会报错。

## 仿真

`sim/tb_roi_scaler.sv` 是自检 testbench，覆盖 2x 放大、整数/非整数缩小、移动 ROI + padding stride、命令/数据延迟、输出背压、job 输入在 active 期间变化、非法配置，以及可选的 1280x720 -> 1920x1080 长案例。主代理的快速验证入口可编译顶层 `tb_roi_scaler`；设置 `+FULL=1` 才运行长案例。编译输出应放在 `vision_base/build/scaler/`，不要把生成物提交到 RTL/docs 目录。

本轮本地证据（Icarus 12.0，2026-09-08）：默认回归输出 `PASS case=1..4`、`PASS invalid case=5..8`、`PASS tb_roi_scaler`；`+FULL=1` 额外输出 `PASS case=90 pixels=2073600 commands=720 cycles=5552713` 与 `PASS tb_roi_scaler`。这些 cycle 数来自 10 ns 仿真时钟以及 testbench 注入的命令等待、返回间隙和输出背压，不是 Ti60F225I3 实物 FPS 或 DDR 带宽结论。
