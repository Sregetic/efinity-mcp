# RAW像素对顺序修复

## 根因与复现

checker0写侧ser2par_v1把较早的32bit FOV字放到128bit高位；读侧vid_par2ser从MSB输出16bit并左移。因此每个FOV字的高16bit像素对先输出，再输出低16bit。
上一轮新增vision_raw_frontend却取md[15:0]先输出、md[31:16]后输出，每四像素交换两对，造成高对比竖线的周期性锯齿/螺纹。板内source.png已显示此问题，和拍屏摩尔纹分开处理。

新回归使用旧链路的MSB-first顺序，输入{x0,x1,x2,x3}。修复前before.log在RAW order x0 y0失败；修复后after.log的1920宽/六行突发/3-of-4 valid、46080像素和实际ISP对参考一致通过。之前回归把测试向量及参考同时写成LSB-first，漏掉了接口契约错误。

## 修改

只交换RAW前端的取半字顺序：第一次md[31:16]，第二次md[15:0]；更新测试向量和参考。FIFO深度、RGB打包格式、统一帧池、SoC及HDMI光栅均保持。

## 导出冻结事件

网页九图导出mode_frames_1791298276936277400按用户要求完成，九图已通过并恢复memory0/M1。现场显示帧号65738→65764；未中断导出，未关闭网页服务。按钮和进度文字明确标识HDMI暂时冻帧。

## 构建与板上验收

两版原生综合、接口、P&R和位流生成完成，SAPPHIRE_ENABLE1/RAW_TO_POOL1、seed1。snapshot：53539XLR /235RAM /45DSP，最终WNS +0.220ns、WHS +0.027ns；competition：53108XLR /230RAM /45DSP，最终WNS +0.214ns、WHS +0.027ns。

snapshot已实际写入SRAM，program.log设备0x10660A79并报告JTAG完成；Flash保持。

修复后source与M1的完整1920×1080图像传输通过，但图像接近全黑：source RGB均值0.000065/0.00799/0.183，中心RAW均值16.24、接近黑电平16，曝光2950、三字节读回00b860、I2C无故障。该黑图不作为螺纹消除的视觉验收。继续核对现场照明/镜头与传感器。


60秒只读监测完成：185个样本、采集和显示帧号19273→21064，camera_fps 29.99849；RAW FIFO overflow、capture discarded、scan bad均0。RAW中心均值范围16.214–16.295，持续接近黑电平。实时链路运行通过，亮场视觉验收仍待现场状态确认。
