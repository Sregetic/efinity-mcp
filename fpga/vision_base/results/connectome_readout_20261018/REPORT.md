# 果蝇连接组分类读出：软件接入与板上数值核对

日期：2026-10-18。本轮完成固定连接组之后的可训练 INT8 分类读出，**没有完成实物识别验收**。新模型暂为伴随诊断，原 BASE/FOMO、SHAPE 和显示菜单保持。

## 交付与资源

固定 MaleCNS 回路仍为80节点/1296边/三次Q14迭代，每个独立ROI清空状态；其后新增80→4线性读出，四类为空白、圆、矩形、三角形。只训练320个INT8权重、4个int32偏置；复用原dot4/MulHi与shape_dense单次舍入。模型364B，训练/量化/实际C参考/构建/同帧发布/回读已经接通。

- DDR运行固件：`F:/Project/fpga/vision_base/results/connectome_readout_20261018/firmware/vision.elf`。
- 当前模型：`F:/Project/fpga/vision_base/models/connectome_readout_bringup/connectome_readout.bin`，CRD1，图/模型版本均0x00010001，training_kind=1（生成图联调）。
- FPGA仍是上一轮ROI优化位流：`F:/Project/fpga/vision_base/results/roi_render_perf_20261018/release/ti60f225_oob.bit`。本轮没有重编译或重烧FPGA，也没有写Flash、原MLP权重或更改相机参数。

|资源|本轮前|本轮后|增量/余量|
|---|---:|---:|---|
|XLR|57356/60800|57356/60800|0；余3444|
|片上RAM|244/256|244/256|0；余12|
|DSP|62/160|62/160|0；余98|
|DDR应用load|177728B|178896B|+1168B，包含364B模型|
|DDR应用BSS|66048B|66104B|+56B|
|FOMO arena实用|149388B|149388B|0|

静态DDR占用净增1224B，不含执行栈；片上缓存和硬件保持。WNS+0.254ns/WHS+0.026ns沿用同一位流的已验收P&R结果，不称本轮新增综合。

## 数值、帧绑定与画面保持

1. `host_test/result.json`：227组合法Q14状态、908个INT8输出的生产C/RV32I与独立整数参考零差异；正负端点饱和、负值舍入和4组独立固定图完整回路通过。4种坏包（截断、图版本错误、非法移位、累加溢出）在构建输入边界被检出。PASS只表示计算链一致。
2. `ddr_load/result.json`：178896B实际DDR程序逐字节等于新ELF后才从入口运行，FPGA/Flash/旧权重均保持。初次600秒期限短于本次完整静态回读，停在69632B；核对该前缀后，以25kHz继续读完剩余109264B，全部相等，5kHz恢复CPU。没有执行未经核对的半包；复现命令采用已有2400秒期限。
3. `board/result.json`：FIX首次seq1/源137307/render27/context37，等待后seq保持；同原帧改ROI后seq2/render28；原自检保持seq2和相机结果；恢复F0后seq3/新源143829。五次CRD1记录均与FOMO/旧结果的序号、源、配置、render/context相同，busy为0。这里是实际事件FIFO策略测试，不是人工按压。
4. `board/frozen/verification.json`：从独立回读的同源1920×1080 pre-Gamma图重新计算；576个FOMO输出、1024灰度、原MLP、FlyHash256bit、80个状态与四个读出分数全部相等。FOMO为MODEL2，无旧MLP TEST混入。`head_board_comparison.json`另核对冻结、稳定、同源改ROI、自检四组读出数值；实时新源只核对记录身份，没有再导出该帧整图。
5. `image_comparison.json`：加载前后同源94587/render25的source、M0、M5各1920×24行条带，共138240像素，差异为0。这不是新的九模式整幅画质验收；本轮视频RTL没有变化。

完整源图已查看，是天花板和灯，没有现场摆放的形状卡。原图导出本身不改变显示色调或Gamma。

## 实测耗时与并发

|阶段|本次固定源任务实测|
|---|---:|
|连接组80状态|4.07571ms|
|新增读出层|0.17121ms|
|FOMO预处理|25.80642ms|
|FOMO Invoke|1159.49160ms|
|FOMO后处理|0.22806ms|
|FOMO三阶段合计|1185.52608ms|

另两次独立任务读出0.16933/0.17064ms、回路4.11081/4.09151ms。0.17ms只是新增读出层开销，不是整体相机识别延迟；FOMO选择下伴随读出也随完整任务发布，仍需约1.2秒。本轮没有改FOMO算术或进行严格相同输入提速A/B。

`concurrent_video.json`：连续FOMO+新增读出+满幅ROI，19.969秒/1554采样，观察发布29.846Hz，渲染均值17.599ms（16.002–18.502ms），坏扫描/采集丢弃增量0。原16.667ms预算保持，截止计数增532；不计满幅60fps通过。`concurrent_task/`完成seq21，推理错误0、帧绑定保持。

`fomo_hotspots.json`按实际25层读取：Conv合计602.179ms、Depthwise520.082ms，合计约96.8%的Invoke；ADD17.774ms、Softmax18.870ms。最慢单层为第3层1×1Conv163.282ms，第1层3×3DW139.631ms；这是下一轮加速的依据，不因DSP空闲就直接装整套大核。

## 识别质量：仍未通过

当前模型由既有生成器训练400张图，独立生成测试160张图，INT8判对158/160（98.75%）；该数值只适用于生成分布。原八空间桶直接线性浮点对照157/160，尚未证明真实生物拓扑优于基线。

另外四张交付FOMO固定图没有进入训练/量化：只判对空白、三角形，圆判成三角形、矩形判成圆，即2/4。当前满幅天花板源137307还被伴随读出判成圆；同源中心ROI和之后实时默认ROI判为空白。保留这些失败，**不以生成测试高分替代真实泛化，也不让它接管SHAPE/OSD判断**。原FOMO在该场景报告0目标，数值匹配主机。

真实数据、未知门槛、主显示选择、少样本示教/关联记忆、随机重连拓扑消融尚未验收。真实卡片数据应由既有manifest/card_id/session_id隔离后重训。只有数据证明旧编码不够时，再增加输入细节或评估小加速核。

## 收尾状态

`final_cpu.json` CPU1；`final_ai.json` AI OFF。`final_status.json`恢复M5/MED1/F0、Sobel128/Canny80/SHAPE32、NN BASE/menu0、ROI全幅参数但关闭，源持有/冻结均0，帧号继续增长，扫描/采集错误0。Flash继续为10-17固化版本，新增读出只在当前DDR应用运行，复位/断电后从原Flash应用启动。

训练、构建、模型格式与验证步骤：`F:/Project/fpga/vision_base/docs/CONNECTOME_READOUT_20261018.md`。本轮未动PCB、相机模式、图像算法或帧池/仲裁；未做人工按压、实物卡准确率、运动紫闪、长时或物理断电验收。
