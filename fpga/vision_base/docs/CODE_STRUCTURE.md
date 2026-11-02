# 从目标列表读懂 M7 数据流

用户在“智能→模型”选择 M7，在“目标”打开轨迹或选择一个目标持续跟随。显示模式只影响观看方式；识别仍使用接受边缘与轮廓几何。人脸当前停用，独立 FOMO 保持自己的入口。

## 完整类别与选中位置是两条任务

- `geometry_m7.c`：扫描接受位图、沿 Moore 邻域追踪轮廓、找直径、简化多边形，判断圆/矩形。`m7_context.phase` 使用 `M7_SCAN_SEEDS`、`M7_TRACE_CONTOUR` 等名称。
- `geometry_letters.c`：标记连通组件、构造完整笔画候选、按姿态粗匹配/细复核、结合同行基线解决大小写，最后保留最多四框。`LETTERS_*` 名称直接指出每个有预算步骤正在做什么；数值保留，便于读取旧诊断记录。
- `geometry_m7_service.c`：请求不可变边缘快照，复制后释放硬件，再逐步运行轮廓和字母任务。原始帧、捕获时间、配置和坐标映射与任务一起保存。
- `target_follow_service.h`：与上面的服务共享 RAW DMA 租约；依次等待源帧、复制局部灰度、算局部边缘、关联选中目标。`FOLLOW_*` 不等待完整字母分类。
- `target_track.c`：单目标边缘关联、HOLD/LOST、固定倍率 ROI 平移。
- `target_motion.h`：最多四个全景身份的真实中心历史与方向。它不分配四套局部跟踪器。
- `control_service.h` / `fusion_service.h`：按键、菜单、列表选择、一次居中与帧边界 ROI 提交。

`geometry_m7_service.c` 是快照/跟随共享租约的唯一所有者，不能只改主循环或某个提前返回处来“解决占用”。现有无脸 `cache_step()` 仍报告跟随租约，防止独立 AI 误消费同一 DMA 完成事件。

## 协议名称保留原来的线值

`firmware/vision/vision_protocol.h` 集中 CPU 使用的控制/M7/RAW DMA 寄存器偏移、USER2 命令、按键位和能力标识。`CONTROL_OP_ROI_COMMIT` 仍为 `0x35`，`M7_REG_SOURCE_MS` 仍为 `0xa8`；没有改 RTL、外部命令或 408B 控制记录布局。

阅读坐标时先区分三种打包：

- 控制 ROI：每个字的高 12 位是 X/W，低 12 位是 Y/H。
- RAW DMA：低 16 位是 X/W，高 16 位是 Y/H。
- M7 结果 RAM：38 位记录拆成两个 19 位 APB 写入；使用 `M7_RECORD_HALF_BITS` 和 `M7_RECORD_HALF_MASK`。

目标历史始终存裁剪前全景坐标，按当前已生效 ROI 转换显示。硬件观察时间与完整分类完成时间不能混用。

## 测试按行为选择，不重复运行别人的准备步骤

在项目根目录执行，输出写到本地 `build/tests/`：

```powershell
python scripts/test_control_firmware.py --output-dir build/tests/control
python scripts/test_sidebar_center.py --output-dir build/tests/sidebar
python scripts/test_geometry_m7_firmware.py --service-only --output-dir build/tests/service
python scripts/test_target_follow.py --no-face --output-dir build/tests/follow
python scripts/test_target_motion.py --output-dir build/tests/motion
python scripts/test_geometry_letters_native.py --output-dir build/tests/letters
python scripts/test_ddr_loader.py --elf build/firmware/vision.elf --output-dir build/tests/ddr
python scripts/test_spi_boot.py --elf build/firmware/vision.elf --output-dir build/tests/boot
```

这些入口分别检查控制事务、列表/居中、共享租约、选中跟随、四目标身份/轨迹/实际线像素和印刷字母。跟随测试直接生成自己的启动/链接文件，不依赖上次运行缓存，也不自动先跑另一套服务测试。显式 `--output-dir` 的向量在该目录 `control/`；不传时保留原渲染脚本使用的路径。

DDR/启动测试使用指定的当前 ELF，不再暗中读取历史构建或 BASE 权重。启动协议的有权重兼容用例在输出目录生成 32B 固定数据，同时检查生产无权重包；保留原有十种启动/损坏情形。

C/C++ 使用项目 `.clang-format`：4 空格、100 列、同一行不挤多个控制语句。不要给这些规则写字符串匹配测试；用原有功能回归检查类别、位置、协议和恢复路径。

共享租约、快照失效、源帧身份、ROI 边界、过时配置和 ABI 检查都有实际契约或已复现故障依据，应保留。四目标歧义分支必定新建零历史身份，原来额外屏蔽方向的标志已删除；它不是关联安全条件。
