> 早上验收后的图像质量修订正在记录于 [IMAGE_QUALITY_20260916.md](F:/Project/fpga/vision_base/docs/IMAGE_QUALITY_20260916.md)：Canny 升级为 480×270、4×4 区域平均；M0 使用真正的功能前直通，暂不显示 OSD；曝光初值降为原来的约四分之一。以下表格与实测数字是 26091606 的原始验收记录，最新编译和烧录状态以修订记录为准。
# 1–4 阶段：早上验收说明

日期：2026-09-16。硬件：Ti60F225I3 开发板、SC431HAI、HDMI 直连显示器。

## 本版范围

| 阶段 | 已接入的功能 | 实现范围 |
|---|---|---|
| 1 | 灰度、3×3 Sobel、灰度/边缘分屏 | 1920×1080 流水处理；幅值为 abs(Gx)+abs(Gy) |
| 2 | 3×3 中值、实时阈值、消抖按键、红色边缘叠加 | 对 9 个灰度像素排序取中值；可开关；参数在场消隐提交 |
| 3 | DDR 实时显示、冻结、回放、多帧对比 | 8 个物理槽位，保留最近 6 个完整帧；对比为两帧交替显示 |
| 4 | Canny 五个完整阶段 | 高斯、梯度/方向、非极大值抑制、双阈值、完整八连通滞后连接 |

**Canny 本版分析尺寸为 240×135，不是全分辨率 1080p Canny。** 每 8×8 源像素取一个分析样本，在分析网格上处理，再按 8 倍最近邻映射到 1080p 显示。细线呈小块、细小文字丢失属于本版分析分辨率限制；Sobel 和原图没有使用这个 240×135 通路。Canny 是帧级结果，存在更新延迟，移动物体上的叠加可能滞后。

HDMI 输出维持 **1920×1080、60 Hz**。该数值不等同于相机每秒产生 60 个独立新帧，独立采集速率另看板上计数。已有相机颜色、低照度噪声和固定暗斑仍有待收敛项。

没有加入形状识别、RISC-V 或 TinyML。固定暗斑仍为 ISSUE-CAM-001，等采集卡接入后继续调查。

## 开始验收

显示器切到开发板所在 HDMI 输入。摄像头对准照明充足的印字纸、棋盘格或有清楚轮廓的物体。先看原图，再看算法结果，避免把暗场本身的低对比当作算法没有工作。

本轮最后设置：**M3、T040、MED1、F0、I0**，即灰度/边缘对照、阈值 64、中值开启、实时显示。

这是 **JTAG SRAM 下载**。保持开发板供电即可继续验收；开发板断电或重新配置后，要重新下载本版。KEY1 为复位，复位后参数返回 M3/T080/MED0/F0/I0。原来的 Flash 内容保持原样。

## 按键

编号以开发板丝印 KEY0、KEY1、KEY2、KEY3 为准，不按摆放方向猜编号。

| 按键 | 短按后松开 | 长按约 1 秒 |
|---|---|---|
| KEY0 | 下一个显示模式 M0→M7→M0 | 开关 3×3 中值滤波 MED0/1 |
| KEY2 | F0/F1 时阈值 +16；F2/F3 时历史索引 +1 | 实时→冻结；其他状态→实时 |
| KEY3 | F0/F1 时阈值 −16；F2/F3 时历史索引 −1 | 实时→冻结→回放→对比→冻结 |
| KEY1 | 保留原有硬件复位 | — |

按键约 20 ms 消抖，长按只触发一次，短按在松开后触发。连续短按分别清零计时，历史索引在 I0–I5 间循环。

左上角：M 为显示模式；**T 为十六进制阈值**，T040=64、T080=128、步长010=16；MED 为中值开关；F 为存储模式；I 为历史偏移；C1 表示已有完整 Canny 结果。

## 显示模式

| 模式 | 画面 |
|---|---|
| M0 | 彩色原图，保留当前相机 ISP，不加边缘效果 |
| M1 | 灰度图；MED1 时为中值滤波后的灰度 |
| M2 | 黑白 Sobel 边缘 |
| M3 | 左侧灰度、右侧 Sobel，绿色分界线 |
| M4 | 原图叠加红色 Sobel 边缘 |
| M5 | Canny 边缘图 |
| M6 | 原图叠加红色 Canny 边缘 |
| M7 | 左侧彩色、右侧灰度 |

MED 开关作用于灰度/Sobel 分支；Canny 使用独立的高斯预滤波，并不随 MED 开关变化。

M3/M7 是同一画面左右区域的对照，不是将两幅完整场景分别缩到半屏。窗口处理在顶部和左侧约 4 像素处留黑边，屏蔽不完整邻域；采集视场保持原样。

## 存储模式

- **F0 实时**：持续采集，显示最新完整帧。
- **F1 冻结**：保持当前显示帧。移动物体或转动摄像头，冻结图像仍应不动。
- **F2 回放**：以约 0.5 秒一步循环播放最近 6 个完整帧；I 指定起始历史偏移。
- **F3 对比**：以约 0.5 秒间隔交替显示 I 和下一历史帧，I5 的下一帧为 I0。

先在镜头前缓慢移动手或纸，再进入冻结/回放，否则静止场景的相邻帧看起来很接近。六帧代表的原始拍摄时长取决于采集速率，这不是长时间录像功能。

冻结、回放、对比期间，相机继续向独立临时槽位采集，不覆盖已保留的显示帧和历史帧。返回 F0 后恢复发布新图像。

## 验收顺序

1. **M0→M1**：确认物体位置和视场一致、灰度无明显错行，观察显示是否稳定。
2. **M3→M2**：对准棋盘格或印字纸，检查边缘跟随轮廓；提高阈值应减少边缘，降低应增加边缘。
3. **中值开关与 M4**：比较孤立噪点，检查红色边缘与物体边界对应。中值也可能削弱极细小纹理。
4. **F1→F0**：冻结时移动物体，画面保持；恢复实时后看到新位置。
5. **F2/F3**：在运动场景采集后检查回放、两帧交替和 I0–I5 循环选择。
6. **M5/M6**：等待数帧，观察 Canny 连通边缘。控制值作用于 Canny 高阈值，低阈值取一半，高阈值最低为 16。按 240×135 分析范围验收，不把其小字效果当作 1080p Sobel 的结果。

物理按键和 HDMI 直连画面的最终效果由实际观察验收；板上寄存器、仿真和时序通过与这一步分别记录。

## 电脑控制与重新下载

PowerShell 7，可从任意工作目录运行：

```powershell
# 当前验收起点
& 'F:/Project/fpga/vision_base/scripts/control_vision.ps1' -Mode 3 -Threshold 64 -Median 1 -Memory 0 -Index 0

# 原图 / Sobel 红色叠加 / Canny
& 'F:/Project/fpga/vision_base/scripts/control_vision.ps1' -Mode 0
& 'F:/Project/fpga/vision_base/scripts/control_vision.ps1' -Mode 4
& 'F:/Project/fpga/vision_base/scripts/control_vision.ps1' -Mode 5

# 冻结、回放、对比、恢复实时
& 'F:/Project/fpga/vision_base/scripts/control_vision.ps1' -Memory 1
& 'F:/Project/fpga/vision_base/scripts/control_vision.ps1' -Memory 2 -Index 0
& 'F:/Project/fpga/vision_base/scripts/control_vision.ps1' -Memory 3 -Index 0
& 'F:/Project/fpga/vision_base/scripts/control_vision.ps1' -Memory 0

# 默认页：帧号/Canny；页1：写入错误/边缘计数；页2：源图像校验和
& 'F:/Project/fpga/vision_base/scripts/control_vision.ps1' -Page 1
& 'F:/Project/fpga/vision_base/scripts/control_vision.ps1' -Page 2

# 开发板断电后重新下载（JTAG SRAM）
& 'F:/Project/fpga/vision_base/scripts/program_vision_sram.ps1'
```

下载脚本先核对制品、源码 SHA-256 和非负时序，再按 1 MHz JTAG 下载，最后设置验收起点。USB 拓扑变化时先用 Efinity Programmer 枚举当前设备，通过 -Url 传入当前 JTAG URL；不要沿用失效的设备路径。

## 证据位置

- RTL：F:/Project/fpga/vision_base/board/ti60f225_v4/rtl/vision/
- 最新位流及身份：F:/Project/fpga/vision_base/artifacts/camera/
- 功能仿真：F:/Project/fpga/vision_base/results/vision_features/verification.json
- 板上记录及最终制品副本：F:/Project/fpga/vision_base/results/overnight_features_20260916/final/
- 改动前备份：F:/Project/fpga/vision_base/backups/overnight_features_20260916/

复现功能仿真：& 'F:/Project/fpga/vision_base/scripts/verify_vision_features.ps1' -Full。

## 本轮实测结果

构建 26091606 已下载；位流 SHA-256 为 4CD66647A91F4AAD08E9AC38F09126295569FEBE2D979BA47E5BE87A8C26CE96。

- Efinity 布局布线：WNS +0.333 ns、WHS +0.026 ns，未分配引脚 0。
- 功能仿真 7 项通过。Canny 32400 点逐点比较，1064 个输出边缘点，0 差异；覆盖连通弱边缘保留和孤立弱边缘剔除。
- 冻结时显示帧 782、源图像校验和 1651886080 连续十次一致，采集帧 785→810。
- 回放实际访问帧 777–782 共六个不同帧；对比 I4 交替 778/777，I5 跨环交替 777/782。
- 同一冻结帧阈值 16→32 时边缘计数 2723→277；64/128 时为 0。这个场景的边缘较弱，早上请用照明充足的目标验收；提高阈值到没有边缘不等于没有视频输出。
- 约 170 秒定间隔状态采样中，写帧错误计数保持 0，Canny fault 为 0，采集、显示、Canny 完成计数持续增长。
- 此时独立采集约 12.66 帧/秒，显示输出约 60 帧/秒，Canny 约 30 次/秒。Canny 会处理重复显示的源帧，这三个数值各自代表不同环节；不将它们合并成“相机 60fps”。

完整机器检查：F:/Project/fpga/vision_base/results/overnight_features_20260916/final/hardware_checks.json。

仍待人工验收：外接显示器画面、实际按键、运动场景下的撕裂/叠加延迟、演示视频。上述短时计数检查不代表全夜长时间无丢帧结论。