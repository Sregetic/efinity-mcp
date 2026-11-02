# M7 单目标持续跟随、三秒轨迹与 ROI 集成

## 最新跟随卡死修复已同步Flash

Flash菜单确认后用户报告卡住，强制读PC定位精确帧停机。无脸cache_step漏报跟随共享RAW租约占用，已最小修复；旧代码新增RV32回归失败，新版无脸/可选人脸均通过。337080B应用先临时DDR验证实时ROI恢复，再写Flash应用区0x700000；实际Flash与ROM自主启动DDR完整字节均匹配，无USER1补载。配置/中文菜单Flash未重烧，59582XLR/244RAM/63DSP、BSS611324B不变。当前M7自动/跟随开启、F0实时列表0目标，等用户重选原目标后验连续性/速率。当前固化回执flash_dma_fix/REPORT.md，根因和回归runtime_check/stall_after_flash/REPORT.md。下文为此前阶段。

## 当前固化状态

用户随后明确要求烧录Flash；无脸/HOLD修复配套已写入配置0地址和应用包0x700000，实际Flash/自主启动DDR字节验证通过。用户CONFIG或断电重载后BOOT7、CPU1/自检2与新ABI正确。初报没有菜单后，软件事件和实际HDMI取样正常、实体KEY1返回已记录，用户确认“现在能看到菜单”“能收起”。首次未弹出原因尚未复现。没有在该排查中补载应用或重配FPGA。当前跟随/轨迹为冷启动默认关闭，不能沿用下文临时阶段的开启/列表状态。最新回执、8MiB备份/恢复脚本和待验项以 flash_20261031/REPORT.md 为准。下文保留固化前的证据和状态。

## 现场反馈后的新发现（当前）

用户报告“目标没有持续跟随，只有运动提示”。实际读取旧UI0x26103043，确认跟随候选尚未部署。随后成套SRAM/DDR临时加载新位流/369672B应用，实际字节读回、control/M7新ABI、CPU1/自检2通过，但源帧池持续为0。传感器原生1080p、RAW10接收和ISP2073600像素完整；暂停CPU、重启传感器流无效，故该位流未通过实际视频链验收，暂不固化。

用户明确要求先恢复原画面并继续修复。旧KEY1位流与356240B字母修复应用已恢复，源/显示帧3318→3325、历史6、roi_frame_ok1；Flash未改。正在加入采集FIFO/写入握手的只读诊断并重新构建。证据和恢复脚本见runtime_check/，本报告下文保留此前离线/CPU回放结果，不据此宣称新版本已上板可用。

## 交付结果

实现和自动验证完成，新硬件/应用候选尚未部署，Flash 未改。当前板仍运行上一版 M7 字母修复应用及 KEY1 位流；本轮 CPU 回放完成后已恢复应用、菜单、推理策略和视图。当前用户不在板旁，没有新版本移动实物证据。

新功能使用现有 M7 四候选列表、按键和一键居中入口。“目标→持续跟随 / 目标轨迹”默认关，KEY0 直接切换；开启后 KEY2/3 选目标、KEY0 确认，保留初次居中的倍率并平移 ROI。再次进入一键居中返回全景、重新选择并清轨迹；关闭跟随恢复原一次性用法。操作见 `docs/M7_FOLLOW_TRAJECTORY.md`。

圆、矩形、A–Z/a–z、人脸的原 M7 类别数值算法未改；独立 AI、模型权重、M0–M6 Canny/Sobel 算法、阈值和连续显示未改。仅新增选中目标的局部边缘位置关联、轨迹与现有控制/显示连接。

## 位置、身份和显示

- 确认时复制所选结果的边缘参照和源身份，后续不查列表行号。完整类别继续较慢运行；选中位置从原始全景源的64×64局部灰度/Sobel更新，32×32参照完整搜索25×25平移。现有运动区域/方向只影响搜索顺序和同峰排序，全部625候选仍由实测边缘评分。
- 目标位置采用全景源坐标。DMA复用原帧池lease，复制局部后释放，遵守既有CPU缓存失效契约；没有读当前裁剪画面的背景位移，也没有复制视频链。ROI变化重置运动提示历史。
- 初始目标框大小与缩放固定。小死区、一次观测最多一次半步平移，通过原控制/缩放/帧边界发布。手动ROI先关闭自动写者。慢类别私有任务可跨自身ROI提交继续；旧视图框不投到新视图。
- 短暂匹配失败保持窗口，500ms无可靠观测失锁；分离的近分双峰立即显示目标丢失。丢失锁存、不自动重捕获、不跳强运动物体；停下仍靠轮廓保持。目标交叉无法判清时要求重选。
- 48点保存实际RAW源帧ID、取帧时硬件毫秒和测得中心，67ms最小采样间隔。重复源帧不追加，无预测/插值/漏检连线。按当前已生效ROI变换，三档淡出，满3秒删除；无CPU发布时也不会在16位显示时间回绕后复活旧点。
- 跟随与轨迹独立。全幅关闭跟随而保留轨迹；关闭两开关释放锁定。新选择清旧点。Sobel/Canny边缘及叠加共用同一最终M7框/标签/轨迹覆盖入口，未改各显示模式底图算法。
- F1进入列表暂转F0；只做一次居中仍恢复原状态。启用跟随/轨迹且成功选择保持F0，手动冻结/历史会失锁。关菜单也显示目标丢失。

## 整机资源与外部存储

最终整机原生Efinity compile（map/interface/pnr/pgm全部PASS）在 `candidate/hardware/`，不是局部估计：

| 项目 | 本轮前 | 最终 | 变化 / 剩余 |
|---|---:|---:|---:|
| XLR | 57462 | **59179 / 60800** | **+1717**；余1621 |
| RAM | 243 | **244 / 256** | **+1**；余12 |
| DSP | 63 | **63 / 160** | **0**；余97 |
| 完整应用 load | 356240B | **369672B** | **+13432B** |
| 应用 BSS（外部DDR） | 2318548B | **2360652B** | **+42104B** |
| 固定DDR控制记录 | 296B | **408B** | **+112B**，原前缀保持 |

WNS **+0.227ns**、WHS **+0.026ns**，未分配核心引脚0。报告另有供应商未用接口 `Missing Interface Pins=14`，不是核心引脚未分配。最终XLR约97.33%、RAM95.31%；资源仍紧，不宜据此继续叠大型模块。

显示复用原M7结果RAM闲置半区，新增64×13同步行FIFO。首版因多写地址展开为逻辑，60122XLR；改为一个明确同步写口后，最终节省943XLR、增加1RAM。两轮报告分别保存在 `hardware_initial/` 与 `candidate/hardware/`，只交付最终位流。

42104B新增BSS含：选中跟踪状态/48点/625分数及约16050B的精确行移位/密度缓存、4096B局部灰度、512B局部边缘、536B待发布行，另有M7两路及列表参照、16200B同源人脸接受边缘快照等。缓存是一次局部观测的重复计算复用，不是视频帧或新模型。控制记录另增112B，不在BSS差值中，新增外部DDR常驻总量 **42216B**。原FOMO arena **262144B** 不变，4MiB APP区剩 **1463980B**；既有相机/ROI帧池不变，无三秒视频缓存。

`candidate/build.json` 的 `software_only` / `xlr_delta=0` 仅表示该ELF构建没有跑RTL，不能当本轮整体资源变化；整机以本表/最终route报告为准。

## 速度和延迟：三种证据分开

### 实际板上CPU输入回放

在已知100MHz RV32/CFU硬件上临时执行诊断，保存实拍Canny A的类别判定，与由保存轮廓重建笔画、平移/转向/停止的packed输入位置任务并行。实际指令执行计时，非主机速度。没有向相机结果注入场景，也未提交跟随ROI。证据 `cpu_bench/result.json`：

| 指标 | 8.00059455秒回放结果 |
|---|---:|
| 完整普通类别完成 | 6次，**0.74994Hz** |
| 位置完成 | 101次，**12.62406Hz** |
| 类别CPU / 次 | 平均349.410ms，最大349.605ms |
| 位置CPU / 次 | 平均**54.769ms**，最大55.004ms |
| 观测到位置结果 | 平均**76.901ms**，最大**116.981ms** |
| 最大观测间隔 | 124ms |
| 窗口内位置 / 类别CPU占用 | 约69.14% / 29.64%（含进行中工作） |

该回放不含人脸细化、真实相机帧龄、RAW lease/CPU缓存同步等待和显示，回放frame不是实际摄像头frame。生产服务记录实际源帧/取帧时间；**12.62Hz不能写成摄像头跟踪fps或已现场流畅**。CPU在本繁忙回放中接近占满；位置优先会让完整类别更新较慢。

原完整搜索未缓存时，同回放位置6.87Hz，平均CPU77.54ms；精确行缓存后55.17ms，仍受慢任务抢占。最终按实耗时给位置约3:1预算，得到上述12.62Hz，代价是普通类别由约1.62Hz降到0.75Hz。保存 `before_cache/`、`before_priority/` 原始证据，未删差结果。

### 生产ROI链路受控RTL延迟

`latency/result.json` 将实际CPU最慢位置延迟116.98117ms，接到生产 `roi_axi_scaler + frame_render_control + frame_pool`，原生AXI/背压夹具、最终写回响应16周期、30Hz VBlank。六个实际C提交描述符验证源帧/config正确、仅VBlank发布：

- 观测→ROI实际显示config发布：**133.33296–133.33329ms**。
- 提交→ROI发布：**16.35179–16.35212ms**。

这是有明确相位/总线夹具条件的自动时序回放，不包含现场DDR竞争、相机曝光/传输或显示器延迟。生产 `geometry_m7_track_record` 已记录观测、ROI请求及实际view_config生效时间，现场可直接测同一指标。

### 现场状态

新配套未上板，未做移动实物、人脸/字母随动或复杂场景持续跟随验收。CPU回放均在finally恢复上一已知完整应用，实际字节读回通过；恢复回执 `board/restored_previous_priority/result.json`、板状态 `board/final_state.json`，菜单恢复 `board/menu_restore.json`。未写Flash、未重配FPGA、未重载权重。

## 自动验证与查看的实际渲染

| 验证 | 结果 / 证据 |
|---|---|
| 核心边缘位置 | ASan/UBSan移动/转向/55步停走、每帧625缓存评分逐一对照直接公式、运动提示方向、ROI四边、重复帧/三秒过期、短漏检恢复、长期丢失、相同双峰/交叉后不重锁、重选清表；`track_test.stdout` |
| 实拍边缘关联 | 保存A的边界对重建印刷笔画，20帧平移/转向通过，固定+7/+8源像素量级量化偏差，无累积漂移；`field_track.stdout`。不是原始相机RGB或实物运动 |
| RV32旧M7服务 | 共享lease/cache、AI所有权、错源/失效/取消、源身份、VS及原UI；`service_baseline/service.log` |
| RV32新跟随服务 | packed源/Sobel、lease释放、固定倍率、实际frame/ms去重、轨迹独立/全景、短漏检/丢失锁存、重新选择/列表重排、慢类别/人脸私有任务跨自有ROI、手工ROI夺回；`service_follow/run.log` |
| 原控制与新开关 | **4920断言 / 636组构图**，保留一次性、F1恢复、选中后钩子/失败不启动、连续F0、手工ROI和旧CLI解码；`control_final/result.json` |
| 真实生产ROI像素 | 6份C描述符，**12441600像素**逐一对照独立整数坐标公式，固定4倍/中心/实际轨迹变换；`follow_render/result.json` |
| C→实际轨迹RTL | **2073600像素 / 2302覆盖像素**，每个框/标签/真实点/色值逐一对照独立参考；`follow_render/overlay_result.json` |
| 轨迹RTL专项 | **2073600像素 / 1437标记**，VS原子、render变换门、三档淡出、重复X、3秒消失/时间wrap不复活；`rtl/track.log` |
| 中文字库/菜单 | 57344字体像素、19项/新开关/丢失/旧ASCII；新菜单 **8294400像素**，`rtl/osd.log`、`rtl/menu.log` |
| 原侧栏视频链 | 五幅原根菜单/显示模式/模型/选择栏，**9637725个面板外RGB像素与同步精确保持**、原模式bypass保持；仅更新目标组六项的夹具范围，`rtl/sidebar_video.log` |

已打开查看 `follow_render/render/follow_overlay.png`、`rtl/track_overlay.png` 和 `rtl/menus_preview.png`：所选框/矩形标签、ROI内正确平移的历史点、三档亮度、六项目标菜单和关菜单丢失提示均可见，无文字重叠。这些图是实际RTL输出的合成源回放，不是板上照片。

## 成套候选和复现

- 位流/hex/最终报告/manifest/status：`candidate/hardware/`。
- 完整应用/反汇编/map/build：`candidate/vision.elf` 等；原权重沿用，不打包或修改。
- 新control ABI **0x26103106**、M7 ABI **0x26103173**、TRK1能力 `0xa4=0x54524b31`、UI tag **0x26103144**；原M7L1保持。新应用与旧硬件会被启动身份检查拒绝，必须成套使用。
- 生产改动和必要测试/doc快照：`source/`；逐文件本轮变化 `changes.patch`、`source_scope.json`；原当前改动保存在 `before/`，不是拿旧提交覆盖工程。无Git仓库，没有初始化Git或改Runner。

在项目根使用既有Python/工具链：

```powershell
C:/ProgramData/anaconda3/python.exe -X utf8 -E scripts/test_geometry_m7_firmware.py --service-only --output-dir results/m7_follow_20261031/service_baseline
C:/ProgramData/anaconda3/python.exe -X utf8 -E scripts/test_target_follow.py
C:/ProgramData/anaconda3/python.exe -X utf8 -E scripts/test_sidebar_center.py --output-dir results/m7_follow_20261031/control_final
C:/ProgramData/anaconda3/python.exe -X utf8 -E scripts/test_target_follow_render.py
C:/ProgramData/anaconda3/python.exe -X utf8 -E scripts/test_target_follow_latency.py
C:/ProgramData/anaconda3/python.exe -X utf8 -E scripts/build_fomo_firmware.py --camera --cfu-kernels --output-dir results/m7_follow_20261031/candidate
```

渲染脚本消费已保存的真实RTL输出，生成它们的命令/依赖和核心检查见 `verify.ps1`；该入口默认离线，不重跑板上CPU回放或P&R。各组成检查已逐项执行，组合入口只做PowerShell语法检查，没有再次整链重复执行。整机原始构建命令/日志见 `fpga_final.log`；本轮额外Verilator副本的标准库解析失败后改用已有 `/usr/bin/verilator`，未修改全局工具。首次CPU采集读取过大超时，finally恢复成功；缩小采集后得到上述有效数据，失败记录在 `cpu_bench/initial_attempt/`。

下一步是成套临时加载新位流/应用后，现场移动、转向、停住、遮挡和交叉实物，读取真实CPU/源帧/ROI生效记录；本轮不以自动回放代替该验收，也未请求或执行Flash固化。
