# checker0 并入统一帧池：实测与验收

## 当前结论

联合原生 Efinity 构建已完成，Sapphire/FlyHash 固件保留，XLR 已低于 90%。完整1080p模型（20736000像素、10个完整显示帧）和最后SRAM版本的板上帧池验收均通过。固件计时修复后任务也已验收。

| 构建 | 合并前 XLR / RAM | 最终 XLR / RAM | 净释放 XLR / RAM | 最终 WNS / WHS |
| --- | --- | --- | --- | --- |
| final_timer_snapshot | 56398 / 246 | 53395 / 235 | 3003 / 11 | +0.015 / +0.023 ns |
| final_timer_competition | 55866 / 241 | 53108 / 230 | 2758 / 11 | +0.216 / +0.026 ns |

两版均为 SC431HAI、1080p60 HDMI、SAPPHIRE_ENABLE=1、RAW_TO_POOL=1；snapshot 为 IMAGE_DEBUG=2，比赛版为 0。map/interface/P&R/位流生成全部通过，未分配 core IO 为 0。vendor pgm 步骤只生成位流，实际 SRAM 写入另记。

## 净收益而非删除量

旧 checker0 独立锥为 3924 XLR、16 RAM、2 DSP。它从合并候选的层次资源报告中消失。新 RAW CDC 占 2 RAM，RGB 采集 FIFO 为吸收六行 2PPC 突发从 1024 增到 2048（4→7 RAM）。因此 RAM 净省 16−2−3=11，逻辑也须扣掉八 bank 历史管理、前端与接口开销；最终净收益以上表为准。

## 改动范围

源池使用 8×4MiB，地址 0x00000000..0x01ffffff；结果双缓冲为 0x02000000..0x027fffff，CPU 从 0x07000000 开始。六个历史帧和 reader lease 被保护，额外 bank 接收不发布的 scratch 相机帧。AXI 客户端从五个减到四个，删除旧 RAW DDR client。

去 Bayer/WB 移到 DDR 前，148.5MHz 2PPC ISP 通过 512-word RAW CDC 和 2048-word RGB CDC 接入同一源池；全画幅直扫 source lease，ROI 仍写 result 后场边界发布。RAW 前端行间四个空周期满足旧 ISP 行缓存延迟复位；1920 宽比较捕获并验证了这个修复。

历史内容现在是拍摄曝光、去 Bayer、WB 后的 packed16 RGB；这些拍摄参数被保留，不作为历史 Bayer 重算。Gamma、边缘模式和 ROI 在同一 RGB 源上重渲染。实时路径也经过相同 packed16 格式，亮部是 RGB555、暗部两计数步长。RAW 探针仅 IMAGE_DEBUG=1 启用且只读实时输入；当前烧录的 IMAGE_DEBUG=2 只保留5块RAM的RGB图像回读。HDMI 协议、光栅、SC431HAI 配置和实体按键逻辑保持原设计。

## 离线验收

- history.log：66304 像素；六个历史索引、回放整圈、相邻比较、scratch 不发布、冻结转 ROI 同源重渲染、恢复实时；CPU 字节掩码与共享 DDR 同时覆盖。
- pooled_live.log：89088 像素、29 个完整显示帧；独立相机/显示时钟，缩放、平移、画布位置、冻结、原子配置、非法配置拒绝、采集溢出与扫描饥饿恢复。
- raw_full.log：46080 RAW 像素，1920 宽、六行突发和 3/4 valid；4PPC→2PPC 字节次序、连续行、帧号、实际 ISP 对参考逐像素一致。
- packed_rgb.log：262656 色值无错误。原 pool、render_control、render_engine、5-client memory、CDC 回归通过。
- pooled_full.log：20736000像素、10个完整显示帧逐像素核对；148.5/100MHz、独立相机/光栅、DDR/CDC、冻结缩放和平移通过。

## 板上验收

用户已批准仅 SRAM 编程；Flash 保留。编程、CPU 冷启动、60秒实时错误计数、六帧历史、冻结/回放/比较及同源 ROI 重渲染将在 board_accept.log 和独立 JSON 中记录。最后在板制品为 final_timer_snapshot，SRAM写入见 program_final.log，Flash保持现状。CPU USER1 热复位的共享 AXI 在途清理仍是既有待办，本次不将其列为已验收。

## 复现构建

在 board/ti60f225_v4 工作目录，先 dot-source F:/Project/fpga/vision_base/scripts/efinity_env.ps1，再执行 vendor efx_run.py：

```powershell
& "$env:PYTHONHOME/bin/python.exe" "$env:EFINITY_HOME/scripts/efx_run.py" ti60f225_oob.xml --flow compile --timeout 1500 --output_dir OUTPUT --work_dir WORK --map_opts top-params=IMAGE_DEBUG top-params=2 top-params=SAPPHIRE_ENABLE top-params=1 top-params=RAW_TO_POOL top-params=1
```

比赛版把 IMAGE_DEBUG 改为 0，使用独立 OUTPUT/WORK。完整模型：Icarus top=tb_pooled_live，参数必须作为完整 PowerShell 字符串传入：'-Ptb_pooled_live.W=1920'、'-Ptb_pooled_live.H=1080'。测试源为各 RTL core、stream_cdc、vision_rgb_capture、vision_rgb_scanout、vision_roi_control 和 sim/vision/tb_pooled_live.sv。

source_changes.diff 保存实现前后比较，before/ 保留实现前文件；first_snapshot、final_snapshot、release_*、accepted_* 是调试试验，最终使用 final_timer_*。


## 固件运行时修复

首次 CPU 冷启动自检通过，但首个 FlyHash 任务进入 trap（firmware_state=3）。实测与生成网表交叉核对发现：Lite/reducedCSR 配置虽然内部有计数寄存器，却没有 mcycle 的 CSR 读映射；原 main.c 首次计时读取触发异常。QEMU 的算法测试没有覆盖这项板级 CSR 契约。

计时改为 mailbox APB0x30 的 CPU 域 32-bit free-running counter，频率仍为100MHz。算法、任务 nonce 和 CFU 均保留；mailbox 回归校验间隔14个 CPU 周期的读值差为14，固件构建检查阻止重新引入该未映射 CSR。更新位流及运行任务验收以 final_timer_* 为准。


## 最终板上验收

board_final.log通过。60秒采样207组，采集帧438→2234，显示帧437→2233；RAW溢出、采集丢弃、扫描坏帧全程0。相机采集约30.00fps；HDMI光栅维持1080p60，这是两个不同速率。
六个历史显示ID为[2242, 2241, 2240, 2239, 2238, 2237]，冻结/回放/相邻比较/恢复实时通过；全画幅、2x缩放、平移、恢复全画幅四个ROI版本都保持源ID2567。完整ROI重渲染最后为28.329ms，超过16.67ms的一帧预算会记录deadline miss，但发布的整帧保持完整；本次没有宣称ROI重算达60fps。

首轮历史索引脚本未等待memory=1在场边界生效，回放计数仍在前进；修正为观察已生效memory=1再进入memory=2后通过。只修正验收脚本，历史RTL保持原实现。

snapshot最后使用PnR seed=1：seed=0的Canny py→mapRAM RE路径为−0.060ns，未用于编程，报告保留在timer_snapshot_seed0.*；seed=1为+0.015ns。比赛版seed=0为+0.216ns。复现snapshot时传--pnr_opts seed=1。

FlyHash最后实测见flyhash_final/result.json：CPU状态1，冻结Canny源帧6217 / 配置7 / epoch 62，3422个分析边缘像素，64个占用特征与主机逐项一致，256bit编码与主机一致，另32组特征向量通过。bitmap提取+编码为64.220ms；纯编码为2.078ms。软件提取全480x270位图的实测不是几百微秒，需更高识别更新率时再优化这一项。它不代表训练分类器已完成。

后续待办仍为CPU USER1热复位的共享AXI在途清理；本次没有把冷启动和任务运行等同于热复位验收。RAW历史源现在是post-ISP packed16 RGB，WB/曝光保留拍摄值，Gamma/边缘/ROI可在同一源帧重算。


## 最后在板图像

定稿SRAM版本通过USER2直接回读两张完整1920×1080图像，无采集卡参与；两张均绑定源帧16893、配置9：

- [Camera color](F:/Project/fpga/vision_base/results/raw_pool_20261006/images_final/mode_0.png)
- [Canny](F:/Project/fpga/vision_base/results/raw_pool_20261006/images_final/mode_5.png)

images_final/images.json和restore.json记录成功及恢复状态；收尾回到M0、memory0、ROI关闭、阈值96、median1。浏览器原完整九图图库没有用这两图覆盖。
