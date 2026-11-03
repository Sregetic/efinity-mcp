# 统一帧与内存核心实施

`rtl/frame_memory_system.sv` 已复用原帧池、ROI缩放器与写回引擎，补齐真实 RGB565 采集写 DMA、结果扫描读 DMA和共享 AXI。输入是低地址像素在低16位的2PPC RGB565；原 RAW8 帧缓存保留为独立 AXI 客户端，两个格式不混用。

## 使用契约
1. 申请 capture lease 后锁存源尺寸/stride；采集全部像素，最后 B 响应成功才发布源帧。错误帧释放但不发布；越过 bank 的配置在写 DDR 前结束并报错。源布局固定，变更布局前排空并重置帧池。
2. job 握手锁存 ROI、缩放和配置号。实时使用最新完整源帧；冻结保留同一源 lease，可改变 ROI 后重渲染。分析客户端具有独立 acquire/release 和 frame/config ID。
3. 成功结果只写非当前显示 bank；等待下游排空后发单周期 vblank，原子切换描述符，并在下一周期启动扫描 DMA。`scan_pixel_*` 以 ready/valid 传输像素、SOF/EOL/EOF、frame/config ID，消费者保存完整帧后以 scan_error 判定有效性。
4. 四客户端共享一个128-bit AXI端口：0采集写、1渲染读写、2扫描读、3原RAW读写。写 round-robin，读在扫描FIFO低水位时插入最多一次优先突发，其余保持独立 round-robin 游标；AR握手后持有至RLAST，AW握手后持有至B，不交织W。每通道只保留一个在途 burst；该已知上限用 profiling 决定后续是否增加队列。
5. `stream_cdc.sv` 是可背压数据流的双时钟 FIFO，可将像素及标记/帧号作为一个整体跨域，共同复位丢弃在途数据。无背压采集和固定时序扫描分别由 `vision_rgb_capture.sv` 与 `vision_rgb_scanout.sv` 适配：采集溢出结束已广告的突发后丢弃整帧，扫描欠载计数并排空当前包。

默认地址：现有RAW历史区约0–16MiB；新增RGB源4×4MiB位于 `0x02000000`，结果2×4MiB位于 `0x03000000`。相机顶层已接入这些新区：debayer后原RGB经无背压采集适配、CDC和采集DMA写入源帧，ROI结果经扫描DMA与CDC回到Gamma/Canny前。原RAW客户端仍走同一个物理DDR端口。

## 资源优化与证据
同一Ti60F225/I3核心映射，源/结果extent的乘法缩至32×16→48bit，避免上下文扩宽成32×64；有效尺寸的地址语义不变。原映射RAM36/DSP40/FF3861/LUT5942，最终RAM8/DSP20/FF11508/LUT10933。宽浅FIFO使用Efinity原生 `syn_ramstyle="registers"`，以逻辑换取28块RAM；写FIFO从32降到单个16-beat burst，读FIFO仍能缓存完整burst。尝试 `syn_ramdecomp="area"` 没有减少RAM，已删除无效设置。

完整核心回归、DDR行为模型共享总线、并行采集/扫描、后台读写、冻结ROI变化、错误帧不发布及CDC通过。共享总线完整1920×1080采集→渲染→扫描逐像素核对共2,074,112扫描像素，渲染1,059,424周期，模型deadline_misses0；异步CDC核对2,048个含帧号的beat及背压稳定/满/回卷/复位。100MHz下对应模型渲染10.594ms，不是板上测得DDR FPS。

复验：`scripts/verify.ps1 -Suite full`；资源：`scripts/synthesize.ps1 -Top frame_memory_system -Flow map`。原始报告位于 `results/frame_memory_system_20261004/`，包括baseline、缩位、RAM/FF取舍和逐像素日志。

## X1/X2主链接入

相机主链已实现动态ROI、最近邻缩放、输入平移、输出窗口位置和冻结后重渲染。配置经完整CDC邮箱锁存，成功结果在vblank替换显示描述符；冻结源lease与源/配置号随每次任务保留。关闭ROI恢复原RGB路径，重新启用先采集新源，避免误冻旧缓存。

整机原生构建及SRAM候选已完成；实时整帧/2×各60秒及同源四配置回读均通过，零采集溢出与扫描欠载，具体已验收范围以 `results/roi_live_20261004/REPORT.md` 为准，扫描不欠载和源不溢出须同时通过。操作说明见 `docs/ROI_OPERATION.md`。独立核心模型周期与实际DDR渲染周期分别记录，HDMI60Hz不代表后台渲染60fps。
