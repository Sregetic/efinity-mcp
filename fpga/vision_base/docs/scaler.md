# ROI 最近邻缩放核心

`rtl/roi_scaler.sv` 是单时钟、RGB565、2 pixels/clock (2PPC) 的可综合 ROI 最近邻缩放核心。它负责按源行读取、两行乒乓缓存和输出流；不负责帧所有权、AXI 写回、MIPI CSI、DDR PHY/controller、HDMI/LCD 时序或跨时钟域。

当前目录的硬件证据分层为：Icarus 行为仿真、Efinity `map` 资源/内存推断和主线集成仿真。它们分别证明协议/像素功能、可映射结构和系统级连接；均不等同于真实摄像头、DDR 板卡、显示器或物理吞吐验收。

## 端口

所有端口同步于 `clk`，复位为低有效 `rst_n`。job 端口名称保持原契约不变。

| 方向 | 端口 | 说明 |
| --- | --- | --- |
| in/out | `job_valid`, `job_ready` | 单个 job 的 ready/valid；只在 `job_valid && job_ready` 时锁存。 |
| in | `base_addr[31:0]` | 源帧首字节地址，RGB565 为 2 byte/pixel；必须偶地址。 |
| in | `src_width/src_height[15:0]` | 源帧宽高，单位 pixel/line。 |
| in | `stride_bytes[31:0]` | 源帧行跨度，单位 byte，可含 padding；独立于 ROI 宽度，必须偶数且至少 `src_width*2`。 |
| in | `roi_x/roi_y/roi_w/roi_h[15:0]` | 源帧内 ROI，左上原点，单位 pixel；ROI 必须落在源帧内，`roi_w <= MAX_LINE_PIXELS`。 |
| in | `dst_width/dst_height[15:0]` | 输出宽高，单位 pixel/line。 |
| in | `frame_id/config_id[31:0]` | job 握手时锁存；在该 job 的所有输出 beat 上保持。 |
| out/in | `pixel_valid`, `pixel_ready` | 输出 beat ready/valid；只有 `pixel_valid && pixel_ready` 才推进。背压时 data/keep/flags/ID 全部稳定。 |
| out | `pixel_data[31:0]` | 低 16 bit 为左（先）像素，高 16 bit 为右（后）像素；`pixel_keep=01` 时高 16 bit 置零。 |
| out | `pixel_keep[1:0]` | `2'b11` 表示两个有效像素，`2'b01` 表示一个有效像素。奇数 `dst_width` 的每一行最后一个 beat 为 `01`。 |
| out | `pixel_sof/pixel_eol/pixel_eof` | 与 beat 同拍：SOF 仅首 beat，EOL 为每行最后 beat，EOF 为最后行最后 beat。 |
| out | `pixel_frame_id/pixel_config_id[31:0]` | 对应锁存 job 的 metadata。 |
| out | `done` | 单周期完成脉冲；有效 job 只在 EOF beat 被接受的时钟沿产生。非法 job 为便于上层收敛，在 job 握手沿给 `done=1,error=1`，且不访存。 |
| out | `error` | sticky job 状态；复位/新合法 job 清零，非法 job、reader 错误或非法 `rd_keep` 置 1。 |
| out | `rd_cmd_valid`, `rd_cmd_ready` | 源行命令 ready/valid。命令握手后，reader 返回该行的 32-bit beat。 |
| out | `rd_addr[31:0]` | `base_addr + (roi_y + load_row)*stride_bytes + roi_x*2`，byte address；源 ROI 可从任意偶地址开始。 |
| out | `rd_pixels[15:0]` | 当前行像素数，固定为 `roi_w`。 |
| in/out | `rd_data_valid`, `rd_data_ready` | 行 beat ready/valid。 |
| in | `rd_data[31:0]` | 低 16 bit 为先像素，高 16 bit 为后像素。 |
| in | `rd_keep[1:0]` | 与 `rd_data` 同拍的有效像素数：`11` 或 `01`。 |
| in | `rd_error` | 行 reader 的 sticky 错误输入。 |

### 行返回协议

- 一条命令只描述一行，命令 payload 在 `rd_cmd_valid && !rd_cmd_ready` 时保持稳定。
- 命令接受后，核心以 `rd_data_ready=1` 接收整行；slave 可插入任意返回间隙，但必须保持 valid/data/keep 稳定直到握手。
- `rd_keep=11` 写入两个连续像素，`rd_keep=01` 写入一个尾像素；核心按 keep 计数，不按 beat 数量假设行长。
- 收齐 `roi_w` 个像素后，该 bank 才标记 ready。下一需要的源行可在当前输出行期间写入另一 bank。

## 实现策略

### 2PPC 输出与坐标

- 每个输出 beat 最多推进两个目标 x 坐标；两个坐标即使同地址、同奇偶也分别读出，不依赖像素 parity 交织。
- 每个 line bank 由 `roi_line_ram_2r2w` 实现，具有两个独立同步读端口和两个独立写端口。两个读地址可相同；行装载的 `rd_keep=11` 可在一个时钟写两个地址。
- RAM 读寄存器无复位。为适配 Efinity 原语，读端每周期读取其保持地址，写入时使用 `addr = we ? waddr : raddr`；scaler 在每个读请求时更新地址保持寄存器。这样既保持同步读时序，也避免把 2560×16 的数组展开为逻辑。
- 输出有一个 beat slot 和一个已发出的 RAM read slot。读请求与前一个 beat 的捕获可同拍发生；首 beat 有固定 warm-up，连续无背压时 steady state 为每时钟一个 beat（2 pixels/clock）。
- `pixel_data`、`pixel_keep`、SOF/EOL/EOF 和两个 ID 全部在输出寄存器中锁存；`pixel_ready=0` 时不会更新。

### 水平/垂直最近邻

job 配置阶段保留两条并行的 16-round restoring divider，得到：

```text
x_step_int = roi_w / dst_width       x_step_rem = roi_w % dst_width
y_step_int = roi_h / dst_height     y_step_rem = roi_h % dst_height
```

输出热路径不使用可变 `/` 或 `%`。水平每发出一个或两个 x 坐标，使用 add/compare/subtract DDA：

```text
sum       = err + step_rem
carry     = (sum >= dst)
err_next  = carry ? sum - dst : sum
src_next  = src + step_int + carry
```

因此第 `n` 个目标坐标严格对应 `floor(n*roi/dst)`。垂直 DDA 在每个已接受的 EOL beat 后只推进一次，不在发读请求时推进；目标行映射保持正确，即使输出发生背压。

### 两行乒乓与重复/跳行

- 初始源行装入 bank0。当前输出使用 `cur_bank`，下一发生变化的源行预取到另一个 bank。
- 垂直放大时，若下一目标行仍映射同一源行，则直接复用当前 bank，不发重复命令。
- 垂直缩小时，DDA 直接跳到下一需要的源行，只读目标 row，不逐行扫描中间源行。
- 如果预取尚未完成，当前行 EOF/EOL handshake 后进入等待；目标 bank ready 后切换，保证不会在背压或行边界覆盖当前数据。

## 非法 job 与地址边界

job 握手时检查：零尺寸、ROI 越界、`roi_w > MAX_LINE_PIXELS`、奇数 `base_addr`、奇数 `stride_bytes`、`stride_bytes < src_width*2`，以及源帧最后像素地址是否超出 32-bit 地址空间。非法配置不会发 `rd_cmd`，也不会接受 `rd_data`。握手后修改输入字段不会影响 active job；frame/config ID 和全部尺寸、地址、步进参数均已锁存。

## 吞吐边界与周期口径

固定 1080p60 的预算为每帧 `100 MHz / 60 = 1,666,667` 个时钟周期（取整上界）。理想 2PPC 输出 beat 数为：

```text
ceil(dst_width / 2) * dst_height
```

因此 1920×1080 为 `960*1080 = 1,036,800` 个 output beats，尚未加入 divider、首行读延迟、AXI 返回间隙、行切换等待和输出背压。`tb_roi_scaler.sv` 与主线集成 testbench 的周期记录均会明确说明背压/内存模型，不应把无背压理想值当成实物 DDR FPS。

当前版本的核心输出段达到 1 beat/clock；真实 job 是否落入 1,666,667 周期预算取决于行预取是否能被内存延迟覆盖。固定 1080p 输入/输出时每行需要 1920 个源像素，reader 必须持续提供相应 AXI beat；AXI/DDR 仲裁、写回和显示扫描不在本模块预算内。

## 仿真

现有测试文件保持原框架并改为 32-bit/keep：

- `sim/tb_roi_scaler.sv`：小尺寸 2PPC、NN/DDA、偶地址 ROI、奇数尾、垂直重复/跳行、命令/数据等待、输出背压、job 字段 mutate、非法配置；`+FULL=1` 额外逐像素检查：1920×1080→1920×1080、1280×720→1920×1080、中心 960×540→1920×1080。
- `sim/tb_axi_line_reader.sv`：128-bit AXI、offset/4-KiB/32-bit 末地址、INCR/burst cap、AR 背压 payload 稳定、R 背压稳定、奇数尾和 RRESP 错误。
- `sim/tb_roi_axi_scaler.sv`：真实 reader+scaler 串接、非 16-byte 对齐 ROI、4-KiB burst split、2PPC keep、NN 坐标、metadata、背压和 RRESP 错误传播。

默认 quick 入口：

```powershell
C:/Program` Files/PowerShell/7/pwsh.exe -NoProfile -File scripts/verify.ps1 `
  -Suite quick -Iverilog C:/iverilog/bin/iverilog.exe -Vvp C:/iverilog/bin/vvp.exe
```

默认回归的验收标志为 `PASS tb_axi_line_reader`、`PASS tb_roi_scaler`、`PASS tb_roi_axi_scaler`，并与项目其他 testbench 一起由脚本汇总为 `PASS vision_base suite=quick`。

当前 direct scaler full 日志（Icarus 12.0，10 ns 时钟，内存模型插入命令/返回间隙，输出按固定 pattern 背压）记录如下；每个 case 均逐像素比对并输出 `PASS`：

| case | 输入/ROI -> 输出 | source lines | output beats | frame cycles | `1,666,667` 预算 |
| --- | --- | ---: | ---: | ---: | --- |
| 90 | 1920×1080 full -> 1920×1080 | 1080 | 1,036,800 | 3,461,340 | 背压/返回间隙模型下未达 |
| 91 | 1280×720 full -> 1920×1080 | 720 | 1,036,800 | 1,944,505 | 背压/返回间隙模型下未达 |
| 92 | 中心 960×540 -> 1920×1080 | 540 | 1,036,800 | 1,474,264 | 该模型下达标 |

这些数值是当前 testbench 的受控压力记录，不是实物 DDR 的 FPS。理想无背压 2PPC 下，核心需要 `ceil(1920/2)*1080 = 1,036,800` 个输出 beat，低于 1,666,667 周期预算；上表中前两项未达是因为该压力模型的行数据供给和输出 ready 速率低于实时要求，不应用它们掩盖内存服务能力问题。主线统一 `scripts/verify.ps1 -Suite full` 于 2026-09-08 02:03:11 通过。其 `tb_frame_render_engine` 写回/帧池 full 三项记录为 case190 `1,039,655`、case191 `1,046,902`、case192 `1,039,496` cycles，均低于 1,666,667；该记录包含主线 engine 的 AXI 读写压力，和本表的 scaler-only 受控行返回模型分开解释。

## Efinity map

该独立核心的 map 命令为：

```powershell
C:/Program` Files/PowerShell/7/pwsh.exe -NoProfile -File scripts/synthesize.ps1 `
  -Top roi_axi_scaler -Flow map
```

目标是 Titanium `Ti60F225`，仅做 synthesis/map，不含板级 P&R、DDR 校准、摄像头配置或编程。最终对应当前冻结 RTL 的 map run（2026-09-08 09:58:09）为 `PASS`，status 中 scaler hash 为 `8d9b7e3869a749a38cd25e44115a8ab76ff048a2eeca82c2f36f5e8fe6180de4`，reader hash 为 `31fe42ee19198a87105a67c66b493319c4900125822669f2562655dbca3a6090`。资源为 `EFX_ADD=579`、`EFX_LUT4=1806`、`EFX_DSP48=4`、`EFX_FF=1104`、`EFX_RAM10=7`、`EFX_DPRAM10=16`。最新 warning 段只有 EFX-0200 移除未使用的 `re0/re1`；没有 `EFX-0657/0655/0680/0103` 当前-run logic-memory/control/address 错误。RAM 端口推断包含两行 bank 的双口 RAM；这是 map 结构证据，不替代 P&R 时序或板上 DDR 验证。
