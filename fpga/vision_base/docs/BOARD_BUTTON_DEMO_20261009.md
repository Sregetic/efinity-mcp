# 实体按键演示与本轮 A 项验证

当前制品、是否已写入 SRAM 和资源/时序，以 `docs/PROJECT_MASTER_STATUS.md` 最新摘要及 `results/a_controls_quality_20261009/REPORT.md` 为准。本指南描述本轮控制实现；实物卡片识别、人工按键和断电启动的验收分别记录。

## 2026-10-10启动更新

配置Flash和SPI程序/权重已安装，原按键菜单保持。完整AI和连接组描述子无需主机下载即可由ROM启动；连接组未训练读出，实物识别准确率和实际断电验收仍单列。资源、复现与数据来源见[启动与连接组记录](AI_AUTOBOOT_AND_CONNECTOME_20261010.md)。

## 三个操作键

KEY0=C4、KEY2=N14、KEY3=A3。KEY1=P14 是复位键，不参与菜单。

短按约0.2秒并松开；长按约1秒后松开。硬件保留同步、20ms消抖和长按检测；固件处理事件，显示参数在 VS 边界整包生效。

|按键|动作|
|---|---|
|KEY0 短按|切换八种显示模式，任何菜单页均可切换|
|KEY0 长按|选择下一菜单页，最后一页回到正常页；这替代旧版“长按直接切中值”|
|KEY2 短按|当前参数增加；中值页为开启|
|KEY3 短按|当前参数减少；中值页为关闭|
|KEY2 长按|实时 F0 与冻结 F1 切换；在 F2/F3 时返回实时|
|KEY3 长按|F0/F3→F1，F1→F2，F2→F3，历史索引复位为0|

## 菜单页

KEY0 长按依次选择：正常→MEDIAN→ZOOM→PAN X→PAN Y→SIZE→POS X→POS Y→正常。

|页|KEY2 / KEY3 短按|OSD 的 V 数值|
|---|---|---|
|正常|F0/F1 调该模式阈值；F2/F3 调六帧历史索引|显示模式名和 T 阈值，不显示 V|
|MEDIAN|开 / 关中值|0或1|
|ZOOM|缩小 / 放大源 ROI，相当于放大 / 缩小物体|源 ROI 宽度；全幅依次1920→960→480→240|
|PAN X|源 ROI 横向右移 / 左移32像素|源 ROI 的 x|
|PAN Y|源 ROI 向下 / 向上移16像素|源 ROI 的 y|
|SIZE|输出窗口放大 / 缩小|输出宽度；默认1920→960→480→240，宽度按8对齐|
|POS X|输出窗口右移 / 左移32像素|显示位置 x|
|POS Y|输出窗口下移 / 上移16像素|显示位置 y|

坐标在原帧和显示画布边界饱和，不回绕。恢复全幅源和全幅输出后自动关闭 ROI。移动全幅窗口时位置保持0，这是边界约束；先把 SIZE 减到960再平移。

正常页的 Sobel 和 Canny 各自保存阈值，范围16…2047、步进16；Canny 同时显示实际 T 与请求 R，噪声下限可能使二者不同。SHAPE 模式另有差值阈值，范围1…255、步进16、默认32，OSD 的 T 显示这个实际值。切换模式不覆盖其他阈值。

V 是当前菜单请求值，几何提交结束后生效；快速连续操作合并为最新几何，不覆盖已经在渲染的配置。退出菜单后恢复显示模式名。

## 不用上位机的验证顺序

1. 切到 CAMERA，观察实时画面；再依次切 GRAY、SOBEL、SPLIT、SOBEL OV、CANNY、CANNY OV、SHAPE。
2. 正常页下，在 SOBEL 按 KEY2/KEY3，确认每次±16且下限16；切到 CANNY，确认保留自己的阈值。SHAPE 按键改的是形状差值阈值，而非 Sobel。
3. 长按 KEY0 到 MEDIAN，用 KEY2/KEY3 开关，观察 MED1/MED0。
4. 长按 KEY2 冻结原图。选择 ZOOM 用 KEY2 放大，PAN X/PAN Y 移动源窗口；SIZE 缩小输出，POS X/POS Y 移动显示位置。场景保持同一原帧，变化的是渲染参数。
5. 恢复全幅源/全幅输出，回正常页。KEY3 长按进入 F2 回放，再长按到 F3 对比；短按 KEY2/KEY3 选择历史索引。最后 KEY2 长按回 F0。
6. SHAPE 模式下，将单个高对比空心圆或空心矩形放在640×480中央虚线区域内，四角留均匀背景。圆显示 CIRCLE/绿框，矩形显示 RECT/蓝框；无目标应显示 NONE。实心、反色、断线和背景负例分别记录。

当前几何模块是单目标、均匀背景、轴对齐矩形的规则识别，不将其写成通用物体分类器；AI TEST 分数也不作为实物正确率。

## 启动与复现

内嵌控制/FlyHash 程序从8KB ROM自动复制到DDR；按键、ROI、A6不需要 USER1 程序加载。完整 INT8 应用和权重仍走现有大程序加载器。这一轮仅写 SRAM，Flash 保持原内容，断电会丢失本轮 SRAM 位流。

PowerShell7，工作目录 `F:/Project/fpga/vision_base`：

```powershell
$py='C:/Users/Sregetic/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $py -E -X utf8 scripts/build_vision_firmware.py --boot-kb 8 --output-dir results/a_controls_quality_20261009/firmware
& $py -E -X utf8 scripts/generate_vision_soc.py --output-dir artifacts/vision_soc --custom --cache-kb 2 --boot-kb 8 --boot-hex results/a_controls_quality_20261009/firmware/vision.hex
./scripts/verify_vision_features.ps1
& $py -E -X utf8 scripts/test_control_firmware.py
./scripts/synthesize.ps1 -Top board -Flow compile -TimeoutSeconds 3600
./scripts/program_vision_sram.ps1 -Url 'ftdi://0x0403:0x6011:4:9/2'
```

FTDI URL 以实际枚举为准。自动测试 `scripts/test_key_ui_board.py` 注入同一个按键事件队列，验证固件/DDR/显示；实体电气按压与消抖由 RTL 回归和人工操作分别证明。报告中不混用两者。

## 第四项：独立启动包与无主机配置测试

`results/a_controls_quality_20261009/standalone`是已准备的控制/A6启动包，实际配置重启验证通过；不是已写入Flash的独立断电验收结果。ROM初始值M3/MED0/F0、Sobel/Canny128、SHAPE32、menu0、ROI关闭。只靠实体按键即可切CAMERA/SHAPE、调阈值、冻结/历史和ROI；完整AI应用自主加载另外实施。

```powershell
./scripts/prepare_standalone_release.ps1
./scripts/program_vision_sram.ps1 -Url 'ftdi://0x0403:0x6011:4:9/2' -BootOnly
```

BootOnly仅省略烧录后主机下发的初始视频参数，不省略制品/源码/时序校验，也不写Flash。现场先完成实物/实体键验收，再按原分工安排Flash固化和真实断电启动测试。
