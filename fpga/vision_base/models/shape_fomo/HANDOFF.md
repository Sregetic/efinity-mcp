# Ti60F225 形状检测模型接入资料

目标：在实际 Ti60F225 板卡上运行 Edge Impulse FOMO int8 模型。先用固定图片验证板端推理，再接入摄像头。

## 随包文件

- `models/shape_fomo_int8.tflite`：原始模型，54,640 字节；模型部署的核心文件。
- `src/main.cc`：基于 Efinix TinyML / Sapphire BSP 的固定图片测试程序。
- `src/model/shape_fomo_model_data.cc`、`.h`：同一模型的 C++ 数组，可嵌入支持 TensorFlow Lite Micro 的软件工程。
- `src/model/fomo_test_images.h`：四张固定图片的量化输入和 PC 参考输出。
- `test_vectors/`：四张 PNG、输入和输出二进制数据，用于对照板端结果。
- `model_info.json`、`model_validation.json`：模型参数和已完成的 PC 推理记录。

上述源码需要 Efinix TinyML 的 TensorFlow Lite Micro、Sapphire BSP 和 RISC-V 构建环境；本包是接入资料，不是可独立编译的完整 FPGA 工程。

## 模型接口

- 输入 NHWC `[1,96,96,3]`，RGB，int8；scale = 0.003921568859368563，zero point = -128。
- uint8 RGB 像素对应 int8 输入值为像素值减去 128；本次固定图采用居中裁剪和最近邻缩放到 96×96。
- 输出 `[1,12,12,4]`，int8；scale = 0.00390625，zero point = -128。
- 四个输出通道依次为 `background`、`circle`、`rectangle`、`triangle`。
- 概率按 `(输出整数 + 128) / 256` 解量化，当前检测阈值为 0.5。
- 算子：Conv2D、DepthwiseConv2D、Add、Softmax。
- 测试程序使用 256 KB tensor arena；整个软件工程的内存需求还包括代码、测试数据和运行库，应以实际链接与运行结果为准。
- 当前程序统计阳性网格单元，未实现目标区域合并；接入实时检测时还需 FOMO 后处理。

## 还需要向板卡持有人索取

1. 原来的完整 Efinity 工程目录：包括 `.xml`、`.peri.xml`、全部 RTL、IP 配置和工程引用的初始化文件，不能只给单个 XML。
2. 实际 PCB 型号/版本、原理图或引脚表，以及 DDR/HyperRAM 型号。
3. 如果已有软核系统，还需要对应 BSP、存储器地址映射、时钟配置和下载/调试配置。

现有工程位于 `efinity-mcp-main/fpga/vision_base/board/ti60f225_v4/ti60f225_oob.xml`，引用了 DDR 控制器，目前未找到已接入的 Sapphire / TensorFlow Lite Micro 推理系统。应以实际板卡和完整工程为准。

## 验证状态和接入路线

电脑上的四张固定图已完成推理：空白图 0 个阳性格，circle 2 个，rectangle 1 个，triangle 4 个。此结果仅验证 PC 模型流程，尚未在 FPGA 上运行，也不是摄像头准确率评估。

建议先在匹配实际板卡的软核/内存系统中加入 TFLite Micro，集成 `src/`，通过串口核对四张固定图片的输出。之后再加入摄像头 RGB 预处理、推理和 FOMO 区域合并。

原始 `.tflite` 不能直接当作 FPGA 位流烧录。最终下载文件应是按实际板卡生成的 FPGA `.bit`，以及软核使用的 `.elf` / `.bin`（具体加载方式由系统决定）。

已准备的官方 Ti60 TinyML 示例采用 HyperRAM，现有 V4 视觉工程采用 DDR。此前编译出的参考固件依赖该参考系统，因此本包不包含其 `.bit`、`.elf`、`.bin`；接入工程师需按实际板卡重新匹配硬件系统并编译软件。

参考仓库：https://github.com/Efinix-Inc/tinyml

参考版本：`efinity-v2026.1.132`，commit `96886fa0c73e25e6218db7d0863f84677cf65138`；本机软件编译使用 Efinity 2026.1 和 Sapphire IP 3.4.1。
