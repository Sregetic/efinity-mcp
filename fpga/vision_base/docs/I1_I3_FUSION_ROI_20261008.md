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

## 用户操作与验收方法（2026-10-08）

入口：http://127.0.0.1:63438/。先刷新网页并点“读取状态”。当前图像区域是已保存快照，不是实时视频；实时切换看HDMI显示器，远程检查用新的回读数据。只点“显示已保存图像”不会采新图。

### 先验证不依赖形状卡的功能

1. 展开“图像参数”，用“整帧1×”，显示选择M6“彩色+边缘”（或M7“识别/综合”）；分析方式选“当前原帧上的指定ROI”，点“应用分析方式”。当前手动分析区域是独立的analysis_control配置，不会由网页显示ROI字段自动重设；用下面命令可明确指定源ROI。
2. 勾选“冻结同一原帧”，勾选“启用ROI”，点“应用/重新渲染”。点“读取状态”两次，确认source_held=1、source_frozen=1、held_source_frame_id/roi_frame_id相同且不变。摄像头可以继续采集，但显示被持有的源帧保持不变。
3. 等分析完成：屏幕显示AI TEST、F源帧、R渲染配置、M模型版本和Q四分数；匹配时显示青色分析框，冻结年龄A应为0。当前TEST只验联调，不以圆/矩形分类正确率作为模型验收。
4. 保持冻结，依次点“中心2×”、左右平移64、缩小0.5×。源帧号应不变，applied_config_id应更新，画面按参数变化。框应跟随同一个原帧区域变换，而非粘在固定屏幕坐标；超出显示裁剪只画交集。手动原帧分析ROI保持时，同一源图输入/分数应一致，F不变、R更新。
5. 取消冻结，恢复“整帧1×”、ROI关闭、M6、分析方式“几何自动ROI”。确认held/frozen=0，源帧号持续增加，画面恢复运动；scan_bad_frames、scan_error、render_error不得新增。

### 明确指定手动AI区域并逐值核对

这组命令在上面已冻结的整帧视图上运行；会把分析方式设为手动并设置源ROI，不烧录。运行期间别点其他JTAG回读按钮。PowerShell工作目录为F:/Project/fpga/vision_base。

```powershell
. F:/Project/fpga/vision_base/scripts/efinity_env.ps1
$py='F:/Efinity/2026.1/python311/bin/python.exe'
$url='ftdi://0x0403:0x6011:4:9/2'
$elf='F:/Project/fpga/vision_base/results/fusion_roi_20261008/firmware/vision.elf'
$out='F:/Project/fpga/vision_base/results/manual_feature_acceptance'
& $py F:/Project/fpga/vision_base/scripts/read_ai_result.py --url $url --elf $elf --policy view --roi 700 360 480 320 --output-dir "$out/tensor"
& 'C:/Users/Sregetic/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' -E F:/Project/fpga/vision_base/scripts/validate_ai_result.py --directory "$out/tensor" --weights F:/Project/fpga/vision_base/models/shape_cards_bringup/shape_cards_weights.bin
& $py F:/Project/fpga/vision_base/scripts/read_fusion_result.py --url $url --elf $elf --output-dir "$out/fusion"
```

合格结果：validation.json的passed=true；1024灰度输入、128特征、32隐藏输出、4分数、256-bit FlyHash逐值一致；融合frame_id与冻结源相同，render_config_id与当前视图配置相同，model_id=1，state=test。融合包display_box与青色框对应。设备URL只对应本次已连接的这块板，重新插拔后先按设备枚举确认。

### 再验证自动ROI及A6实物

- 显示M7，分析选择“几何自动ROI”并应用。浅色背景上放完整深色圆/矩形（包含空心与实心），位于显示中央识别区域：x640..1279/y300..779，目标与区域边界留间距。
- 稳定后SHAPE应对应实物；自动分析记录automatic_roi=true、geometry_valid=true，roi应围住原帧里的该目标，DMA采样/CPU结果及青色框应绑定同一源帧/配置。TEST标签继续保留，AI类别与几何类别一致不是当前模型保证。
- 移走目标/换空白背景，预期SHAPE NONE、AI NONE，无残留框；移动目标，框跟随；目标出区域或被裁掉时不分析不完整候选。分别记录空心圆、空心矩形、实心形状、空白和纹理背景的误检漏检，失败即保持待验收。

### 旧结果防错帧

底层方法：只暂停analysis_control的run位而保留融合HUD，换成新的源帧；预期OLD、A>0、旧青色框消失。再恢复run位应产生新匹配结果。网页“关闭AI叠加”会关HUD，不是暂停推理；观察OLD使用run位暂停。本轮既有证据在results/fusion_roi_20261008/stale，年龄49439、match0、旧框位置无青色像素；再次板上重测由JTAG工具完成。

### 图像回读及尚未达标项

- “读取九图”读取同一源的原图/M0–M7，约8分钟，期间HDMI静止；完成后恢复开始前状态。当前缩放视图的严格回读使用capture_mode_images.py --current-view，默认九图会临时回到全幅冻结视图。
- 原图颗粒、Canny阶梯、实物A6精度、实时紫闪分别验收，不因TEST框出现就通过。
- 本次发现暗部提亮状态在冻结期间仍变化，导致M7回读亮度分界；source_frame保持只证明源帧持有，而非像素/处理状态完全一致。该项修复并重测前保持失败。
- 全幅实时ROI有render_deadline_misses增长记录；功能显示通过与吞吐/长时稳定验收分开。


2026-10-08后续：普通亮度区原图去噪已写SRAM，当前制品与验收以PROJECT_MASTER_STATUS.md最新摘要及results/raw_rgb_denoise_20261008/REPORT.md为准。较大斑点与冻结提亮漂移继续单列。
