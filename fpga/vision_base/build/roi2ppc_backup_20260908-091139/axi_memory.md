# AXI 行读取与缩放连接

`rtl/axi_line_reader.sv`：32-bit byte address，128-bit AXI4只读INCR，固定ID=0，默认每burst至多16 beats，可设1-256。一次一个在途burst，按4 KiB边界拆分，读取地址按16字节对齐。ROI起点只需2字节对齐，首beat丢弃起点前的像素，末beat丢弃超出行长的像素。低地址16-bit像素位于RDATA低位。

请求：`req_valid/req_ready, req_addr[31:0], req_pixels[15:0]`。响应：`pixel_valid/pixel_ready, pixel_data[15:0]`。每请求恰好返回指定数量像素，`done`在最后像素被接受后脉冲。请求为0长度、奇数地址或32-bit地址越界时，done+error，不发AXI。

AXI侧为`m_axi_arid/araddr/arlen/arsize/arburst/arvalid/arready`和`rdata/rresp/rlast/rvalid/rready`；AR不回压时仍按握手接受。RRESP非OKAY或RLAST位置异常会锁存error。读取按原预期长度继续，已发出的像素并不回滚；上层以任务最终error决定是否发布结果帧。该模块依赖合规的AXI响应；不实现总线超时或处理slave永久不再返回的情况。复位时需要上层协调在途事务，避免旧响应混入新任务。

`rtl/roi_axi_scaler.sv`已将此reader和`roi_scaler`按行请求/数据接口连接起来，并为整个job锁存任一行的内存错误。job参数、SOF/EOL/EOF、frame_id/config_id原样沿用scaler契约。运行中的源帧必须由调用者一直持有，直到任务done；包装模块不隐式操作frame_pool。

这个包装器是AXI内存到缩放像素流的渲染引擎，不包含AXI写通道、帧写入、DDR PHY/controller、显示扫描或总线仲裁。要接当前vendor DDR，需要映射128-bit读接口并将其他固定AXI属性设为合法常量；如果仍保留vendor显示reader，必须先加入多主仲裁，不能把两组AR线直接并联。

吞吐：单beat寄存器按16-bit顺序送出，每beat8像素。为保持逻辑小且握手清晰，下一beat在寄存器空后才接受，存在气泡；scaler又在源行读取和输出之间切换。因此本版应通过结果帧缓存/显示缓冲接固定速率输出，不直接声称每个显示有效周期都有像素。BRAM/DSP推断和最大频率待Efinity综合后记录。

验证：`tb_axi_line_reader`检查非16字节对齐的ROI、4 KiB边界、burst上限、输入/输出停顿、合法最高地址、非法地址/长度及总线响应错误；`tb_roi_axi_scaler`检查真实串接后的坐标、颜色字、元数据、背压和任务错误传播。
