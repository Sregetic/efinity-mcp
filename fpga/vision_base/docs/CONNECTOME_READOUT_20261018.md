# 果蝇固定连接组的可训练分类读出

## 本轮范围

保留原视频、SHAPE、BASE/FOMO、FlyHash、80 个 Q14 神经状态和全部图像回读。新增软件伴随读出：同一份相机 ROI 的特征驱动固定连接组，再用 `80→4` INT8 线性层输出 blank/circle/rectangle/triangle 分数。只训练最后 320 个权重与 4 个偏置，不训练或重排 MaleCNS 连接。

该读出复用已有 dot4/MulHi 与 DDR，不新增 FPGA RTL、片上 RAM 或 DSP。NN 菜单仍是原来的 BASE/FOMO，SHAPE 仍是独立几何识别；本轮没有把联调分类器换成主显示判断。原 BASE/FOMO 执行时同时计算并保存读出，AI OFF 时不执行。

当前 `models/connectome_readout_bringup/` 是**生成图联调模型**，不是实物模型。独立生成测试集 160 张，INT8 判对 158 张；另外交付 FOMO 包的四张固定图片仅判对 2 张。这说明整数链路可用，但当前生成数据的泛化较差。四张固定图片没有参加训练或量化校准，保留错误结果，不用它们反复调参冒充独立测试。完整结果见 `results/connectome_readout_20261018/host_test/result.json`。

## 模型与同帧契约

- 固定回路仍是 80 节点、1296 条边、三次更新、每个独立 ROI 先清空状态；原神经元/连接 ID 与来源保持。
- 状态 Q14 转 INT8 为 `clip((state + 64) >> 7, -128, 127)`，输入零点 0、scale=1/128。复用原 `shape_dense` 的单次舍入，不使用 FOMO 的双舍入路径。
- CRD1 包固定 364 字节：magic/version/graph_version/training_kind，output_zero/multiplier/shift，4 个 int32 偏置，320 个 int8 权重。kind=1 为生成联调，kind=2 为独立采集数据训练。版本非零，图版本必须匹配 0x00010001。
- 分数是有符号定点 logits，不是概率，不因 argmax 就宣称目标可靠；实物未知/拒识门槛尚需校准。
- `connectome_readout_result[14]` 与原结果使用相同完成序号，busy 完成后才发布；保留 SOURCE_FRAME、SOURCE_CONFIG、RENDER、CONTEXT、图版本、读出版本和训练性质。

|word|内容|
|---:|---|
|0|0x43524431（CRD1）|
|1|完成序号，与 analysis_result/connectome_result 相同|
|2–5|源帧、源配置、渲染配置、处理 context|
|6–8|连接图版本、读出模型版本、训练性质|
|9–10|四个 INT8 分数的小端打包值、argmax 类别|
|11–12|读出层周期数、固定回路周期数；100MHz|
|13|busy；1 时不使用该记录|

`analysis_connectome_scores[4]` 单独保留四个 INT8 值。旧结果结构、帧持有、几何融合、OSD 与控制状态布局保持。

## 训练与构建

使用既有相机采集 manifest，不再建立第二套数据格式。`card_id` 和 `session_id` 跨 train/test 重复会被拒绝，两组都需包含四类。训练只用 train；test 不参与权重求解或量化范围选择。

```powershell
$py='C:/Users/Sregetic/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
$root='F:/Project/fpga/vision_base'
# DATASET/manifest.jsonl 换成实际采集文件；模型版本随数据更新。
& $py -E -X utf8 "$root/scripts/train_connectome_readout.py" `
  --manifest DATASET/manifest.jsonl --model-version 0x00020001 `
  --output-dir "$root/models/connectome_readout_real"
& $py -E -X utf8 "$root/scripts/test_connectome_readout.py" `
  --model-dir "$root/models/connectome_readout_real" `
  --output-dir "$root/results/connectome_readout_real_test"
& $py -E -X utf8 "$root/scripts/build_fomo_firmware.py" --camera --cfu-kernels `
  --connectome-readout "$root/models/connectome_readout_real/connectome_readout.bin" `
  --output-dir "$root/results/connectome_readout_real_firmware"
```

只有明确传 `--synthetic-bringup` 才生成联调数据；默认要求真实 manifest。真实训练的主机结果也不自动计入板端实物验收。

构建器不开 `--connectome-readout` 时保留原应用路径；开启时模型嵌入 DDR 应用 rodata，不占片上存储，不改变原 4400 字节 MLP 权重或 FOMO tflite。加载仍复用 `scripts/load_vision_ddr.py`，Flash 不随 USER1 加载改变。178KB 程序的完整 25kHz 静态回读实测需要十余分钟，使用已有 `--timeout-seconds 2400`，完成字节核对后才运行。

## 板上验证与下一步

当前板上结果以 `results/connectome_readout_20261018/REPORT.md` 为准。回读命令使用实际在线 FTDI URL 和本轮 ELF：

```powershell
. F:/Project/fpga/vision_base/scripts/efinity_env.ps1
& "$env:PYTHONHOME/bin/python.exe" F:/Project/fpga/vision_base/scripts/test_camera_fomo_board.py `
  --url TARGET --elf F:/Project/fpga/vision_base/results/connectome_readout_20261018/firmware/vision.elf `
  --connectome-readout --output-dir F:/Project/fpga/vision_base/results/connectome_readout_check
```

独立主机核对使用已安装 TensorFlow 环境 `F:/efinity-ci/tinyml-env/Scripts/python.exe` 运行 `scripts/verify_fomo_camera.py --directory 导出目录/frozen --connectome-readout 模型.bin`。它从同帧 pre-Gamma 原图核对 FOMO、灰度、MLP、FlyHash、80 状态和四个读出分数，不只检查完成标志。

后续顺序：真实卡片 manifest → 同一数据重训读出/对照 → 独立实物误识别与未知门槛 → 主显示和板上选择；FOMO 则按实测逐层耗时选择热点加速。可更新关联记忆、跨帧同目标状态和连接拓扑消融仍单列，当前快照分类读出不代替这些目标。保留原有全部系统范围。
