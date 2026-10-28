# 生产边缘几何参考

`reference_edges.json` 保存468个参考字形的实际Canny接受边缘：Arial、Times New Roman、Noto Sans SC Medium，字号256、384、512px，A–Z/a–z各52类。

来源是本机已安装字体渲染的1920×1080图案，经过项目原有 `vision_canny` RTL（MED1、STABLE_NMS1、阈值96、3帧）后抓取的位图。字体文件本身不包含在本目录。每条记录含紧边界、字高/基线比例及原始接受边缘，生成器再提取32×32行列外侧极值。

`scripts/generate_geometry_letters.py` 从这些数据生成CPU只读几何参考。验证数据在 `sim/fixtures/geometry_letters`，字号400/480px，与参考字号不同。小字号输入的过滤现象和早期代理试验保留在本机任务记录，不作为最终312样例的验收数据。

重新采集使用 `scripts/capture_geometry_letter_references.py`：默认参考192/256/320px，`--kind large` 为384/512px，`--kind validation` 为400/480px。最终参考选择256/384/512px。该脚本调用 `sim/vision/tb_geometry_letters_native.sv` 的Verilator可执行文件；原始PNG、接受位图与日志保存在对应任务目录。

本机先在Ubuntu-24.04构建探针（只仿真，不访问板卡）：

```bash
cd /mnt/f/Project/fpga/vision_base
r=board/ti60f225_v4/rtl/vision
verilator --binary --timing --top-module tb -Wno-fatal -j 4 \
  --Mdir results/geometry_letters_20261028/native/obj \
  sim/vision/tb_geometry_letters_native.sv \
  "$r"/vision_{canny,canny_denoise,median9,hysteresis_sweep,hysteresis,sparse_window,sobel,canny_raster}.sv
```

然后从Windows项目目录执行上述采集脚本。默认参考批次与large批次中仅选字号256/384/512写入reference_edges.json，再运行generate_geometry_letters.py生成头文件；validation批次用于独立检查，不进入参考。
