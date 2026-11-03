# M7：印刷字母与框上标注

当前另已固化ROI连续显示修复：59441XLR位流配同一337080B固件，Canny算法与字母判定不改。用户确认画面/跟随正常，见[当前Flash报告](../results/m7_follow_20261031/flash_roi_continuous/REPORT.md)。下方为已有字母功能说明和前期记录。

短按 KEY1 打开菜单，选择 **智能→模型→M7几何**，再将 **推理模式设为自动**。圆形、矩形与 A–Z、a–z 共用 M7，不需要另开字母开关。显示可选原图、Sobel/Canny 边缘或叠加；选择固定单帧时，用“立即推理”运行一次。

**当前跟随卡死修复：**共享RAW DMA占用误报已修复，337080B应用已写Flash并验证自主启动；Canny和本页字母数值保持。见[当前修复报告](../results/m7_follow_20261031/runtime_check/stall_after_flash/REPORT.md)。

**此前Flash无脸修复版：**M7人脸暂时停用，只保留圆、矩形和字母；包含短暂停更HOLD修复、持续跟随和三秒轨迹。配置、中文菜单和完整固件已固化，Flash自主启动/实际字节验证通过；用户初报重载没有菜单，随后实际HDMI菜单取样/实体KEY1返回正常，用户确认菜单可见且KEY1能收起，见[Flash报告](../results/m7_follow_20261031/flash_20261031/REPORT.md)。下文旧人脸验证数字为此前阶段。

把清晰印刷体以相同字号成行、成组摆放，字母之间留出空隙。当前框上显示实际字母或“圆形 / 矩形”，字母框为青色，顶部 `L` 是显示的字母数量。仍最多显示4个目标，更多时显示 `N4+`。在“目标→一键居中”可以实时选择目标并居中，再进入即可重新全景选择，见[全景选目标说明](AUTO_CENTER_ROI_20261022.md)。KEY0 短按确认，KEY1 返回/取消。

[单目标持续跟随与三秒轨迹](M7_FOLLOW_TRAJECTORY.md)沿用本页的类别算法，选中后另用局部边缘更新位置，最多四项列表保持。当前Flash包含该功能，开关默认关闭；实际移动连续性仍待现场验证。

此前[实拍字母修复](../results/m7_letter_fix_20261030/REPORT.md)的自动验证与实际保存输入回放证据继续有效，原临时DDR应用已由当前Flash无脸跟随版替代。

## 字号、倾斜与大小写

建议单字在1920×1080画面中高约200像素以上。很小的字母可能丢点、丢内孔或整条短笔画；输入边缘不足时，几何后端不能补回未被接受的笔画，可使用已有视图放大功能改善输入。

本次自动验证覆盖三种字体 Arial、Times New Roman、Noto Sans SC Medium，包含未用于参考生成的400/480px字号。姿态验证将原始完整图像缩放至0.7、整体旋转 ±12°/±18°，再通过原生产 RTL Canny，而不是旋转二值轮廓冒充相机输入。

同形字符仍需要上下文：`C/c`、`O/o` 等用同行字高和投影基线判断大小写；无衬线 `I` 与 `l` 仅靠边缘可能相同，显示 `I/l`。缺少可靠大小写参照时可显示候选对。圆环与细杆必须有可靠文字同行，才会被改判为字母，避免把圆形、边框或数字0强行识成 `O/o`。同样，Canny 去掉 `i/j` 的点后，只在同行高度、基线和下伸部几何支持时接受对应笔画。

## 仍然只读边缘，未修改 Canny

圆、矩形、字母输入现有 **480×270 Canny 接受位图**。Sobel 显示只改变观看方式，不把 M7 切换成另一种识别算法。Canny 显示下“图像→边缘阈值”调节 M7 共享输入阈值，范围16–2047；Sobel 显示阈值独立。Canny 检测、连通域规则、连续显示和阈值没有因本次字母修复而改变。

本次把原来丢失内部笔画的行列极值比较，改为完整笔画/内孔轮廓：16×16粗匹配、32×32同类细复核，配合有限姿态校正、笔杆方向、同行字高和基线。参考仍是原468份生产 Canny 轮廓，粗参考取其中156份。按实际连通组件归属取点，避免倾斜字母包围框重叠时混入邻字；分离笔画只提出非破坏式组合候选，拟合成功才作为完整字母输出。没有引入 OCR 引擎、神经网络或灰度分类器。

单连通组件最多缓存16384个点；超限会拒绝不完整的字母判定并置复杂标记，原圆/矩形仍保留。密集纹理按参考轮廓密度上限排除。该上限已用实际超限组件验证，不将截断数据当完整字形。

人脸仍按既有头型、眼口边缘与比例判断。仅头部候选可从确切同源帧缓存补算192×240局部 Sobel/Canny，局部阈值为共享请求阈值 T/2；这是此前用户批准的 M7 局部细边缘路径，本次未修改。人脸维持私有快照、独立完成和发布，普通几何不等待人脸。独立 BASE/FOMO 模型、权重与推理算法不变。

## 已有验证与实际速度

| 输入 | 场景数 | 字母数 | 明确标签 | `I/l` | 失败 |
|---|---:|---:|---:|---:|---:|
| 原三字体完整 Canny 输入 | 79 | 312 | 306 | 6 | 0 |
| 原图缩放、±18°后经原 Canny | 18 | 104 | 100 | 4 | 0 |
| 原图缩放、±12°后经原 Canny | 18 | 104 | 100 | 4 | 0 |
| 本次保存的实际相机接受边缘 | 1 | 3 | 3 | 0 | 0 |
| 合计 | 116 | 523 | 509 | 14 | 0 |

52个大小写类别均有明确识别样例。主机 ASan/UBSan 与 RV32I 的116帧全部候选身份、最多4显示框一致；原26组圆/矩形/人脸、服务取消/源帧/租约与 UI 路径通过。50张清晰证件照和10张无脸对照的60帧中，人脸私有结果和最终显示脸框与原版本一致，新增字母误框为0；不据此扩大原人脸可用范围。

保存实拍帧的 A、B、a 从旧版0个输出变为3个正确框，实际 RV32 板上回放也一致。该帧下方 `b` 已缺失大部分边缘，未计入3个样例；用户照片与这份接受位图不是同一瞬间的 RGB/边缘配对。用户不在现场，因此没有完成重新摆放 AaBb 后的四目标实时验收。

以下为同一次板上、同一冻结输入的 CPU 计时，包含普通轮廓提取与字母判定，**不含人脸任务、相机帧龄和显示等待**：

| 输入 | 旧版 | 修复版 |
|---|---:|---:|
| 本次实拍 A/B/a | 351.7ms | 295.9ms |
| 未参与参考生成的印刷体场景 | 540.7ms | 484.0ms |
| 复杂人脸背景的普通几何任务 | 898.0ms | 1569.0ms |

清晰字母场景更快，但复杂背景候选增多时更慢。临时应用在当前无目标背景自由运行8.018秒，普通几何完成10次（约1.25次/秒）、人脸2次（约0.25次/秒）；最新任务完成耗时分别723ms、3322ms。源帧持续前进、CPU恢复运行。该数值是当前背景的结果更新频率，不是视频帧率或移动字母端到端延迟。

## 资源与配套

本轮仅修改 CPU 固件，不改 RTL，不重新运行整机 P&R。片上资源增量 **0 XLR / 0 RAM / 0 DSP**，沿用现有整机 **57462/60800 XLR、243/256 RAM、63/160 DSP**。

| 完整应用 | Flash 中旧版 | 临时 DDR 修复版 | 变化 |
|---|---:|---:|---:|
| 加载代码/常量 | 376784B | 356240B | −20544B |
| 外部 DDR BSS | 1929912B | 2318548B | +388636B |

4MiB APP 区按加载段+BSS计算还余1519516B。新增 DDR 工作区主要是480×270组件标签表、访问位图、组件成员集合与64KiB点缓存；没有新增 RGB 整帧缓冲或片上 RAM。原262144B FOMO arena另计且未变。

临时完整应用：`results/m7_letter_fix_20261030/candidate/vision.elf`。保留的 Flash 配套：`results/key1_back_flash_20261030/release/`。控制/M7 ABI 仍为 `0x26103005` / `0x26103072`，标签能力为 `0x4d374c31`（M7L1），外部记录地址和字段未改变。

- 原4框与4元数据记录地址不变；标签行索引为 `0x38`，低/高19位写入 `0x80/0x84`。
- 元数据第4字保留 N/C/R/F；bit13为标签，bit16:14为 L，bit23:17为主框字符提示。
- 字母在两位硬件类别中编码为0，旧 I3 分类映射为 OTHER；完整类别在 `geometry_m7_classes[4]`，随 GEO3发布序号提交。
- 类别1/2/3为圆/矩形/人脸，4–29为 A–Z，30–55为 a–z，56–81为大小写候选对，82为 `I/l`。

## 复现入口

在项目根目录执行；以下命令会编译/运行相应软件测试，不访问板子。姿态用例复用已保存的生产 Canny 接受位图。

```powershell
C:/ProgramData/anaconda3/python.exe -X utf8 -E scripts/test_geometry_letters_native.py --output-dir results/m7_letter_fix_20261030/upright_final
C:/ProgramData/anaconda3/python.exe -X utf8 -E scripts/test_geometry_letters_native.py --cases-dir sim/fixtures/geometry_letters_field --output-dir results/m7_letter_fix_20261030/field_final
C:/ProgramData/anaconda3/python.exe -X utf8 -E scripts/test_geometry_letters_pose.py --backend results/m7_letter_fix_20261030/upright_final/letters --output-dir results/m7_letter_fix_20261030/poses_native
C:/ProgramData/anaconda3/python.exe -X utf8 -E scripts/test_geometry_letters_pose.py --backend results/m7_letter_fix_20261030/upright_final/letters --angles -12 12 --output-dir results/m7_letter_fix_20261030/poses_native12
C:/ProgramData/anaconda3/python.exe -X utf8 -E scripts/test_geometry_m7_firmware.py --cases-dir results/m7_letter_fix_20261030/classic_final --letters-cases-dir results/m7_letter_fix_20261030/rv32_letters --output-dir results/m7_letter_fix_20261030/rv32_final
```

输入、完整评分、板上计时、DDR加载回执和恢复入口集中于 [本次修复报告](../results/m7_letter_fix_20261030/REPORT.md)。原框上字库/像素生成逻辑未改，沿用原标签 RTL 和菜单像素回归证据。

