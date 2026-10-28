# M7：印刷字母与框上标注

烧录配套候选后，在菜单选择 **几何识别（M7）**。圆形、矩形、人脸和 A–Z、a–z 都在这个模式中显示，不需要进入智能识别菜单。

把正向、清晰的印刷体字母以相同字号成行摆放，字母之间留出空隙。每个框上直接显示识别到的字母或“圆形 / 矩形 / 人脸”。字母框为青色，顶部摘要为 `LETTER`，`L` 表示当前显示的字母数量。仍最多显示4个目标；更多目标时显示 `N4+`。

建议单字在1920×1080画面中高约200像素以上。本次完整输入链验证的实际边缘框高度为180–496像素。很小的字母可能丢点、丢内孔，甚至整条短笔画被现有 Canny 小连通域过滤规则去掉；可使用已有视图放大功能改善输入。Canny 检测、阈值规则与连续显示没有修改。

同形字符需要上下文：例如 `C/c`、`O/o` 使用同行字高和基线辅助判定；某些无衬线字体的 `I` 与 `l` 仅靠边缘无法可靠区分，框上显示 `I/l`。缺少可靠大小写参照时可以显示 `C/c` 这类候选，而不是强行猜测。

## 判定与资源路径

输入仍是现有480×270 Canny接受位图。圆/矩形、人脸、字母共用边缘和轮廓来源；字母比较轮廓的行列极值、比例、字高及基线，参考形状同样经过生产 RTL Canny 提取，没有引入灰度人脸模型或新的 AI 推理模块。

字母匹配在现有 RISC-V 上分段执行，与圆/矩形组成几何任务；人脸维持自己的快照和独立完成路径，不要求几何任务等待人脸。字母新增CPU工作量，实际摄像头识别刷新率和运动滞后需上板测量。

框上字体由CPU生成32×16位图，放入原有两块结果RAM的空闲地址。没有增加整帧缓存或片上字体RAM。参考轮廓和工作区使用外部CPU DDR；菜单与独立AI的入口不变。

## 自动验证

- 三种字体：Arial、Times New Roman、Noto Sans SC Medium。生产RTL参考字号256/384/512px；验证使用未参与参考生成的400/480px。
- 79个完整1920×1080输入场景，使用默认MED1/阈值96经原RTL Canny获得312个字母样例：306个明确识别，6个保留 `I/l` 歧义。52类均有明确识别样例。
- 同时检查框坐标、最多4框、溢出提示；ASan/UBSan无错误。RV32I执行得到全部候选身份及显示框，与主机结果一致。
- 原26组圆/矩形/人脸和私有快照回归、服务取消/源帧/慢人脸/按键路径通过。
- 实际RGB标签、摘要、原I3主框及源帧元数据经过2073600像素仿真；原菜单字库及侧栏RGB/同步回归通过。

关键文件：

```text
firmware/vision/geometry_letters.c
models/geometry_letters/reference_edges.json
sim/fixtures/geometry_letters/
scripts/test_geometry_letters_native.py
results/geometry_letters_20261028/REPORT.md
```

主机和RV32I回归命令（项目根目录）：

```powershell
C:/ProgramData/anaconda3/python.exe -E scripts/test_geometry_letters_native.py
C:/ProgramData/anaconda3/python.exe -E scripts/test_geometry_m7.py --native-dir results/geometry_m7_20261028 --output-dir results/geometry_letters_20261028/host_final
C:/ProgramData/anaconda3/python.exe -E scripts/test_geometry_m7_firmware.py --cases-dir results/geometry_letters_20261028/host_final --letters-cases-dir results/geometry_letters_20261028/native_host --output-dir results/geometry_letters_20261028/rv32_final
```

## 接口与交付边界

基础M7 ABI仍为 `0x26102871`，配套固件额外要求 `0x3c` 返回标签能力 `0x4d374c31`（M7L1）。原无标签记录继续按边框显示。

- 原4框与4元数据记录地址不变；新标签行索引在 `0x38`，低/高19位写入 `0x80/0x84`，写高位后索引自增。
- 元数据第4字保留原N/C/R/F字段；bit13开启标签，bit16:14为L，bit23:17为主框字符提示。
- 字母在两位硬件框类别中编码为0，在旧I3分类中映射到通用OTHER；完整字符类别由 `geometry_m7_classes[4]` 提供，与GEO3发布序号同时提交。旧ELF读回路径不变。
- 类别1/2/3为圆/矩形/人脸，4–29为A–Z，30–55为a–z，56–81为大小写候选对，82为I/l。

当前交付是离线候选。CPU应用、菜单、权重、配套位流及VBO1固化包都在本机 `results/geometry_letters_20261028/candidate/`；位流/ELF/固化包不随Git源码上传。当前Flash仍是此前用户确认“菜单出现、画面正常”的版本。
