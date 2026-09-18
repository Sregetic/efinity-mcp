# RGB565 帧处理闭环

`frame_render_engine.sv` 将 `frame_pool`、`frame_render_control`、`roi_axi_scaler` 和 `axi_frame_writer` 连接成同一时钟域的帧任务引擎。它不是相机协议接收器、物理 DDR 控制器或显示扫描器。

## 内存和像素契约

- 源数据是低地址优先的 RGB565，每像素 2 bytes；RAW8/RAW10 数据应先经过独立的去马赛克与格式适配。
- 默认源帧 4 banks，起始 `0x00000000`；结果帧 2 banks，起始 `0x01000000`；每 bank 4 MiB。共使用 24 MiB 地址范围。映射由参数指定，静态检查范围和重叠。
- `cap_req` 仅申请源 bank；外部采集 DMA 完成全部写响应之后，才提交 `cap_done_ok=1`。测试中的采集事件代表此契约，没有替代实际采集 DMA。
- 所有已发布源帧必须符合当前任务的 `src_width/src_height/src_stride_bytes`。源布局变更时先排空任务并重置帧池，再开始新布局；当前没有每 bank 的动态布局描述表。
- ROI 的 x/y/w/h 独立于源尺寸；缩放采用精确 `floor(dst_index * roi_size / dst_size)` 最近邻规则。
- 输出接口 2 pixels/beat。底层 scaler 支持奇数尾像素，但本写回引擎要求结果宽度为 8 的倍数，结果 stride 为 16 bytes 的倍数。1920、1280、640、224、96、64 等满足这个要求。
- `dst_width/height/stride` 描述结果图像，不等于外部 HDMI 扫描时序。低分辨率分析结果由后续消费者使用；送入固定 1080p 显示前仍需定义缩放或画布布局。

## 任务与所有权

1. `job_valid && job_ready` 接受并锁存整份配置。非法尺寸、ROI、stride、bank 越界当次报错，不发送 AXI。
2. 实时模式申请最新已完成源帧。`freeze_source=1` 时保留源 lease；后续冻结任务继续处理同一源帧。后续接受实时任务时才释放并重新申请最新帧。
3. scaler 和 writer 在同一周期启动。两者通过 valid/ready 流连接，背压沿链路传播。
4. 源帧至少保持到 scaler 完成和 writer 最后一个 B 响应完成。任何读写错误使该结果不进入显示待发布队列。
5. 结果写入非当前显示 bank。成功完成后 `pending=1`；此时暂不接收下一帧任务，避免覆盖待发布结果。
6. 只有 `pending && vblank` 才更新显示描述符。`vblank` 必须已经在 `clk` 域形成单周期脉冲，并代表扫描端已排空上一帧读取；不得直接接异步 VS 引脚。
7. `display_base/frame_id/config_id/width/height/stride_bytes` 在发布边界一起更新，之后保持稳定。`display_valid=0` 时描述符尚未生效。

`done` 表示计算与写回结束，不表示外部显示器已经看到画面。`last_cycles` 从双任务启动到写回完成计数；默认预算 1,666,667 cycles（100 MHz / 60 Hz），超预算增加 `deadline_misses`。AXI 对端无限等待时引擎保持 busy，没有伪造完成或释放被使用的 bank。

## 当前边界

可复验的闭环为：行为存储服务 → AXI 读取 → ROI/缩放 → AXI 写回 → 帧描述符发布。采集 RAW 转 RGB565、真实 DDR 多客户端仲裁、结果扫描 DMA 和异步 FIFO 尚不属于板上直通路径。板上摄像头版本仍使用原 RAW8 DDR → debayer → HDMI 链路；不会将 RAW8 当 RGB565 接入新引擎。

`frame_engine_timing_probe.sv` 是可综合的地址数据发生器和写校验接收器，将新引擎放到真实 `core_clk=100 MHz` 下进行布局布线。该版本的数据不经过物理 DDR，不构成带宽或摄像头联调证据。它使用 1920x1080 结果画布、4096-byte 源 stride、由调试输入决定的源/ROI 尺寸；时序结果只覆盖该配置族。

## 验证

`scripts/verify.ps1 -Suite full` 包含帧 lease/冻结/实时/场消隐、RGB565 写回逐像素比对、stride padding、4 KiB、读写响应错误和三种全高清结果任务。

`scripts/synthesize.ps1 -Top board -Flow compile -VideoMode timing_probe` 生成独立的时序探针制品。`camera` 和 `pattern` 是上板准备使用的两个独立模式。具体通过状态、周期与资源以 `results` 和 `artifacts/*/manifest.json` 的当前证据为准。
