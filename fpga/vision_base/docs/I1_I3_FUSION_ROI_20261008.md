# I1 / I3：同帧融合与几何引导 ROI

本轮对应长期路线的第1、2项。当前部署、资源、实际回读见 `results/fusion_roi_20261008/REPORT.md`；此文件说明实现契约，不用软件仿真替代实物识别验收。

## 数据流与保持不变的部分

复用单个 `vision_shape_classifier`、独立 compute lease、既有分析 DMA、128→32→4 INT8 固件和已有帧边界控制。分析打开时，几何定位读当前源帧的前端灰度，不读滞后发布的 Canny 位图；分析关闭时保留原边缘模式识别路径。摄像头、HDMI、Canny 二值掩码、历史/冻结、原图/模式回读保持。

几何完成结果带完成帧号，而非下一帧开始时更新的采集标签。CPU 将显示坐标减去前端两层窗口的中心偏移，再按已提交的缩放/平移反变换到1920×1080源坐标。自动 ROI 加八分之一留白（每轴至少4显示像素）；接触可视区域边缘的候选不进入自动任务。DMA 持有确切源帧，写32×32灰度输入，完成后释放 compute lease；CPU 推理不阻塞视频。

## 三种分析策略

现有 USER2 控制事件 `0x60`，由固件统一处理，面板和CLI复用该入口：

|值|策略|
|---|---|
|0|关闭分析与融合 HUD；保留原几何识别路径|
|1|对配置的原帧 ROI 分析，默认跟随已显示源帧；调试工具可指定精确帧或 latest|
|2|由当前灰度几何结果选择 ROI，无完整候选时发布 NONE|

ROI/模型版本/显式请求nonce等变化触发重算；相同冻结帧、几何内容与参数只计算一次。背景标定后的新几何内容即使源帧/context未变，也触发重算；不按每个HDMI扫描序号无谓重复推理。配置提交中或几何结果的渲染配置过期时等待完整新记录。手动源 ROI 可在当前可视裁剪外，DMA仍分析原帧；屏幕只画交集，交集为空不画框。

## 完整发布与显示契约

新增 APB `0xf8100300`，ABI `0x26100803`。CPU九字 staging 包只在下一VS整包发布；忙期间背压阻止覆盖。geometry→CPU 为带序列的 held-data CDC；CPU读取前后序列一致才使用。

九字包依次为 flags、源帧号、源侧lease配置字段、渲染配置号、模型版本、处理context、框左上、框右下、四个signed INT8分数。源侧字段沿用DMA/帧池ABI；当前RAW合并分支的capture_config_id来自raw_id帧戳，不是传感器初始化版本。本轮保留这个真实值，绝不把ROI提交号写进它。阈值/模式/中值/色调/白平衡变化生成独立处理context。JTAG page31提供当前enabled/match/age、发布源帧与渲染配置、当前context。

只有源帧、渲染配置和处理context全部匹配，且扫描帧有效时，才画青色分析框。旧结果保持可查，显示 `OLD` 与年龄，不把旧框贴到新对象。冻结复核使用同一源帧；改变缩放/平移后，更新渲染配置并重新分析，采集配置不跟着冒充渲染配置。

HUD沿用原模式名、十进制阈值和SHAPE；新增AI状态、类别C/几何G、年龄A、源帧F、渲染R、模型M、采集S和四个Q分数字节。F/R/S/A为十六进制；Q为二补码INT8十六进制。字符选择与字模解码分两拍，RGB/DE/HS/VS一起延迟一拍（6.734ns），不改变视频刷新率。

当前模型版本1来自合成联调，明确显示 `TEST`，不输出实物可信判断。真实模型仅在校准后的分数间距、有效几何与类别一致时显示OK；矛盾DIFF，证据不足UNKN。真实门槛校准属于后续实物数据任务。

## 可复现检查

```powershell
# General Python; no vendor environment needed for these software checks.
$py='C:/Users/Sregetic/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $py -E F:/Project/fpga/vision_base/scripts/test_fusion_firmware.py
& $py -E F:/Project/fpga/vision_base/scripts/test_fusion_result.py
& $py -E F:/Project/fpga/vision_base/scripts/prepare_a6_fixtures.py --output-dir F:/Project/fpga/vision_base/results/fusion_roi_20261008/a6_samples
& F:/Project/fpga/vision_base/scripts/verify.ps1 -Suite quick
& F:/Project/fpga/vision_base/scripts/verify_vision_features.ps1
```

板上使用 Efinity Python环境后，`vision_control.py --ai-policy 1/2 --ai-status` 查看显示状态；`read_ai_result.py --policy view --frame FRAME --roi X Y W H` 读取确切任务和所有张量；`read_fusion_result.py` 读取完整融合记录，随后均恢复CPU执行。`validate_ai_result.py`逐值核对CPU特征、隐藏层、输出和FlyHash；原帧采样比较使用 `capture_mode_images.py --source-native-order` 的Gamma前RGB。`--current-view`只读取已冻结且持有的视图，不重新提交ROI配置，便于把同一发布包和屏幕像素绑定；默认导出行为保持。

## A6样本与证据边界

`prepare_a6_fixtures.py`产生空心/实心圆和矩形、反色空心图、空白、条纹背景和裁剪矩形，共9幅确定性离线样本；`verify_shape_readback.py --input-kind synthetic`将同一640×480输入送进真实RTL，与主机参考比较三次冻结帧。相机回读负例使用默认 `camera_readback`，分开记录。

这些样本是实现检查，既不是实物训练/测试集，也不替代现场空心卡片、复杂背景和ROI漏检验收。既有 `collect_shape_sample.py`按card_id/session_id隔离真实训练与测试继续保留。

板上另将既有相机背景暗斑放进几何区域，使用既有形状差值阈值64标定，得到圆形候选并自动反变换为源ROI `[562,947,14,14]`。这一案例用于验证自动调度/DMA/CPU/融合链，不算形状卡片识别精度；测试结束恢复阈值32和完整实时视场。实际灰度回读用 `verify_shape_readback.py --threshold 64` 对照真实RTL。

## USER1回读速率修正

本轮100kHz回读出现错误字段与程序字节，其中包含 `0xa107a107`；同一halt状态、同一内存不重写，改25kHz后8456程序字节全部与ELF一致。既有加载器在比较失败时留CPU于halt，没有执行未验证代码。现将 `load_vision_ddr.configuration` 和加载CLI共用的默认速率统一设25kHz，AI/FlyHash/融合读口一起使用；不增加自动重试。reserved flags在结果外部解码边界直接报错。依据是本板实测，尚未声称最高可靠频率；[上游实现](https://github.com/SpinalHDL/openocd_riscv/blob/riscv_spinal/src/target/vexriscv.c)显示其通过JTAG排队注入访存并等待响应，具体本机fork不视为与上游逐行相同。
