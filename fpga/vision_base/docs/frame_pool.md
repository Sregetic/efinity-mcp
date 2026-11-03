# `frame_pool` 帧所有权核心

`rtl/frame_pool.sv` 是单时钟、单写者、双读者的帧元数据与所有权仲裁器。默认
`BANKS=4`，也可以用参数 3 做小容量验证。模块只管理 bank 的发布状态、租约和
元数据，不包含帧数据 RAM；实际像素写入/读取地址由上层把返回的 bank id 映射到
DDR 或其他存储器。

## 目标与边界

- writer 是相机采集路径，reader 0 是 `display`，reader 1 是 `analysis`。
- `display` 和 `analysis` 可以同时持有同一个已完成 bank。只要 reader 持有，
  writer 就不会覆盖该 bank；持续持有就是显示冻结或 AI 固定帧租约。
- 采集申请没有可写 bank 时 `cap_req_ready=0`。核心不回压相机，也不偷偷覆盖
  reader 仍在使用的帧；将来的 camera adapter 应在 SOF 处丢帧并自行计数。
- 这是同步的帧元数据核心，不是 AXI/DDR 控制器，也不实现摄像头驱动、像素搬运
  或跨时钟域。

## 接口

所有接口均在 `clk` 上同步，`rst_n` 为同步低有效复位。`valid && ready` 在一个
上升沿成立时才算接受事件。

| 信号 | 方向 | 说明 |
| --- | --- | --- |
| `cap_req_valid`, `cap_req_ready` | in/out | writer 申请一个可写 bank。接受时 `cap_req_bank` 是返回的 bank id，`cap_req_config_id` 同时被锁存。 |
| `cap_req_bank` | out | 组合选择结果；`cap_req_ready=0` 时置 0。 |
| `cap_done_valid`, `cap_done_ready` | in/out | writer 完成当前采集。`cap_done_bank` 必须等于当前返回的 bank；`cap_done_ok=1` 才发布帧，坏帧只释放写租约而不设置 ready。 |
| `display_acquire_valid`, `display_acquire_ready` | in/out | display 申请最新已发布帧。接受时锁存 `display_acquire_bank` 及其元数据。已有 display 租约时 ready 为 0；同拍给 `display_release` 时允许再次申请。 |
| `display_acquire_bank` | out | display acquire 的选择结果；未 ready 时置 0。 |
| `display_release` | in | display 租约释放脉冲；无租约时该脉冲没有状态效果。 |
| `display_hold_valid`, `display_hold_bank`, `display_hold_frame_id`, `display_hold_config_id` | out | display 当前租约及其元数据。hold valid 持续为 1 即保持冻结帧。 |
| `analysis_acquire_valid`, `analysis_acquire_ready` | in/out | 与 display 同义，但属于 analysis reader。 |
| `analysis_acquire_bank` | out | analysis acquire 的选择结果。 |
| `analysis_release` | in | analysis 租约释放脉冲。 |
| `analysis_hold_valid`, `analysis_hold_bank`, `analysis_hold_frame_id`, `analysis_hold_config_id` | out | analysis 当前租约及其元数据。 |
| `ready_bitmap` | out | 每个 bank 的已发布 ready 位；仅 `cap_done_ok` 才置位，重新申请写入时清零。 |
| `display_held_bitmap` / `analysis_held_bitmap` | out | 两个 reader 的逐 bank 占用位，便于调试和上层状态观测。 |
| `cap_active_valid`, `cap_active_bank`, `cap_active_frame_id`, `cap_active_config_id` | out | 当前 writer 租约及申请时锁存的 frame/config id。 |

`BANK_ID_WIDTH` 是由 `BANKS` 推导的 bank id 宽度（`BANKS=1` 时仍为 1）。输入
bank id 越界时 completion 不握手；正常路径永远只产生小于 `BANKS` 的 bank id。

## 选择策略

1. writer 只有一个活动租约；活动期间不能再次申请，除非本周期完成事件被接受。
2. writer 候选必须满足：最终不被任一 reader 持有、不是仍在写的 bank。释放与
   acquire 同周期的 reader 按“先释放、后重新获取”处理，因此该 bank 可以被
   重新选择，但若 acquire 也成功则 writer 候选会排除它。
3. 优先选择 `ready=0` 的 bank。若所有候选都已 ready，选择 `frame_id` 最小的
   旧帧（同号时选择较小 bank id），从而尽量不覆盖最新帧。32-bit frame id 在
   每次**接受采集申请**时递增；实现按常规无符号大小比较，工程运行不应跨越
   2^32 次申请后再依赖新旧排序。
4. reader 候选只从已发布帧中选择，选择 `frame_id` 最大者（同号时较小 bank
   id）。本周期被接受的 `cap_done` 且 `cap_done_ok=1` 也被视为本周期末发布，
   所以可以与 acquire 同拍；坏帧不会成为 acquire 候选。
5. 两个 reader 独立选择，因此可以得到同一个 bank；一个 reader 的租约不会阻止
   另一个 reader 获取该帧。

writer 正在写某一个 bank 时，其他已发布 bank 仍可被 reader 获取；写入整帧的持续
时间不会把整个 pool 变成 reader 的等待状态。

## 同周期事件与状态更新顺序

组合 `ready` 先依据当前状态、同周期释放以及已接受的 completion 计算候选；然后
在上升沿按以下顺序提交状态（非阻塞赋值保证同一 bank 的结果一致）：

1. **完成**：关闭旧 writer 租约；成功帧写入该 bank 的 `frame_id/config_id` 并
   设置 ready，坏帧保持未发布。
2. **释放**：清除对应 reader 的 held 位；释放不清除 ready 或元数据。
3. **获取**：将选择的最新帧设置为对应 reader 的 held 位并锁存元数据；release
   与 acquire 同拍时新租约覆盖旧租约。
4. **采集申请**：清除返回 bank 的 ready 位并打开新的 writer 租约，锁存申请时的
   `config_id` 与递增前的 `frame_id`。若 completion 与新申请同拍，completion
   先发布/释放旧租约，申请再打开新租约；成功 completion bank 本拍不会再次被
   选作新 writer bank，避免发布帧与重写发生歧义。

候选计算已排除同周期 acquire 目标，因此不会出现 writer 与 reader 在同一拍争用
同一 bank。每个握手只由 `valid && ready` 触发；ready 为 0 的请求不会生成内部
ACK，也不会被静默消费。

复位上升沿后，所有 `ready`、reader held 位和 writer 租约清零，frame/config 元
数据寄存器也归零；模块没有帧内存，因此不会清除外部帧数据。

## 上层连接约定

采集端在 `cap_req` 握手后只向返回 bank 写入一帧，并在帧边界用相同 bank 发出
`cap_done`。display/analysis 在 acquire 握手后可任意持续多个周期读取该 bank，
读取结束再给 release。相机不支持 backpressure 时，adapter 应把
`cap_req_valid && !cap_req_ready` 统计为待丢弃 SOF；这属于 adapter 的丢帧计数，
不是本核心的覆盖策略。

## 选择逻辑与时序
最新帧/最旧帧采用并行比较矩阵和 one-hot 选择，避免多个 32-bit 比较器串联后再进入采集 bank 排他判定。相同 frame_id 时仍选较小 bank 编号；空 bank 优先与同拍完成/读者获取的语义保持不变。该修改由板级真实 P&R 的 captured_bank 到 ready_q 临界路径驱动，功能回归使用原 tb_frame_pool 与帧控制回归。



## 统一历史池（RAW_TO_POOL）

`KEEP_HISTORY=0` 保留原来的最新帧策略；板级合并构建使用 `BANKS=8, KEEP_HISTORY=1`。
历史顺序由单写者完成时更新的 bank 排列表维护，索引 0 是最新已完成帧，最多公开六帧。
`pin_history=1` 保护这六帧；额外 bank 接收实时相机的 scratch 写入，由上层将其完成标为未发布。
读者 lease 和同拍 acquire 仍排除 writer 候选，正在写入或失败的帧不进入历史序列。
`display_age/analysis_age` 选择历史序号；`display_use_analysis` 使冻结的直扫源与后续 ROI 共用同一帧。
冻结、六帧回放、相邻帧比较、失败不发布和 CPU DDR 客户端验证见 `sim/tb_unified_history.sv`。
