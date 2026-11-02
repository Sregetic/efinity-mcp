# Ti60F225I3 实时视觉系统

当前输入为 **HD-SDI 摄像头 → HQ12 → HDMI IN**，HDMI OUT 接显示器。工程包含原图/灰度、Sobel/Canny、ROI/缩放、M7 边缘几何、目标列表、居中/跟随、最近三秒轨迹和独立 FOMO。

## 先用菜单选择功能

- **KEY1**：打开菜单、返回、关闭；**KEY2/KEY3**：上下；**KEY0**：进入/确认。CONFIG 保留为配置重载键。
- **图像→显示模式**：上下切换即时预览；边缘阈值直接调节，中值滤波按 KEY0 开关。
- **视图**：平移、缩放、输出大小/位置在调节时立即生效，不必每步确认。
- **智能→模型→M7几何，推理模式→自动**：识别圆、矩形及清晰印刷体 A–Z/a–z，最多四个目标。M7 与显示模式独立，Sobel/Canny 边缘及叠加模式都能看识别框/标签。
- **目标→目标轨迹 / 运动提示**：无需选择或居中，分别显示各已识别目标最近三秒真实轨迹和框内方向。
- **目标→一键居中**：实时全景列表中用 KEY2/KEY3 选择，KEY0 确认。先开启“持续跟随”则固定初始倍率、平移 ROI 跟随这一个目标；重新选择可换目标。

M7 继续使用接受边缘与轮廓几何，不是 OCR/新分类模型；人脸目前停用。完整字母判定比选中目标的局部位置更新慢，不能用视频刷新率表示识别或跟随速度。使用条件与失锁行为见[字母说明](docs/M7_PRINTED_LETTERS.md)、[轨迹与跟随](docs/M7_FOLLOW_TRAJECTORY.md)。

## 源码、已验证运行和 Flash 分开记录

最近已验证的临时配置为四目标连续线版：56540/60800 XLR、240/256 RAM、63/160 DSP；提速应用339016B、BSS612112B。同输入识别后端耗时降低23%–34%，当前背景完整类别约0.88Hz，不是目标跟踪帧率。[提速证据](results/m7_speed_20261102/REPORT.md)。

可读性整理后的源码候选为339000B、BSS612112B，保留上述提速；本轮仅构建/自动验证，不重配板子。部署与待验以[项目总状态](docs/PROJECT_MASTER_STATUS.md)为准。

**Flash 仍是上一 SDI 固化版**，配置/菜单及333704B完整应用在同一 Flash；CONFIG/断电会回该版本，不保留之后的临时连续线和提速。固化回执/恢复证据在本机 `results/hdmi_finalize_20261101/flash/`。原摄像头工程完整备份在本机 `backups/camera_before_hq12_20261101/`，不混入当前 SDI 构建。

## 开发入口

| 路径 | 用途 |
|---|---|
| `board/ti60_hdmi/` | 当前 HDMI 输入整机、约束和构建入口 |
| `rtl/`、`board/ti60f225_v4/rtl/vision/` | 共享帧池、DDR/ROI、边缘、菜单和显示逻辑 |
| `firmware/vision/` | 控制、M7、跟随和独立 AI 固件 |
| `firmware/vision/vision_protocol.h` | APB 寄存器、USER2 命令、按键位、能力标识 |
| `sim/fixtures/` | 自动验证所需的固定输入 |
| `scripts/` | 构建、功能验证和显式部署工具 |

先读[代码数据流与测试入口](docs/CODE_STRUCTURE.md)。C/C++ 使用项目 `.clang-format`，不把多条控制语句挤在一行；现有协议数值、控制记录布局和帧边界所有权保持。

### 构建与自动验证

在安装 Efinity 2026.1 / RISC-V 工具链的 Windows 主机，从项目根目录执行：

```powershell
python scripts/build_fomo_firmware.py --camera --cfu-kernels --output-dir build/firmware
python scripts/test_geometry_m7_firmware.py --service-only --output-dir build/tests/service
python scripts/test_target_follow.py --no-face --output-dir build/tests/follow
python scripts/test_target_motion.py --output-dir build/tests/motion
python scripts/test_geometry_letters_native.py --output-dir build/tests/letters
```

原生整机物理构建使用 `board/ti60_hdmi/build.ps1`；先生成共享 Sapphire 硬件/BSP，详见[SDI 构建说明](board/ti60_hdmi/README.md)。本机工具路径由脚本约定，厂商 Python 与普通 Python 分开。软件测试、原生 P&R、板上运行和现场移动效果分别验收。

GitHub 保留源码、必要固定输入和正式报告。编译目录、模拟器缓存、完整本机备份和原始资料压缩包不重复入库；它们在本机或旧提交中保留。当前提交是源码整理，不是新的 Flash 发行版。长期范围见[系统范围与路线](docs/SYSTEM_SCOPE_AND_ROADMAP.md)。
