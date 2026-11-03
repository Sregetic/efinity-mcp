# 相机 FOMO 接入与 ROI 优化

当前部署、实测结果和剩余验收以 PROJECT_MASTER_STATUS.md 最新摘要及 `results/roi_fomo_20261012/REPORT.md` 为准。该目录记录10月12日开始、13日继续的联调；未通过候选不算发布版。

## 板上操作

完整相机 FOMO 应用新增最后一页 **NN BASE / NN FOMO**。KEY0 长按依次经过正常、MEDIAN、ZOOM、PAN X/Y、SIZE、POS X/Y、AI、SELFTEST、NN，然后回正常页。NN 页 KEY2 或 KEY3 短按选择下一次请求的后端：V0 为原 MLP/FlyHash/连接组显示，V1 为交接的 Shape FOMO。FIX 下切换选择不会自动重跑；已有结果仍以其 M/model ID 标明来源，下一次短按请求完成后更新。现有两种按键长按的冻结/历史动作保持。

验证输入链时，先选 NN FOMO，再到 AI 页用 KEY2 选 FIX。摆好物体后，KEY2 长按冻结 F1，再在 AI 页短按 KEY3 提交一次。N 应增加一次，F 保持冻结源帧，M 为0002。没有新请求时 N 保持。修改 ZOOM/PAN/SIZE/POS 后回 AI 页重新请求：F 不变，R 随新渲染配置改变。返回 F0 后结果可能显示 OLD；这表示分析对应的原帧已过期，不把旧框画到新物体上。

FOMO 的 C0/C1/C2/C3 分别是背景/圆/矩形/三角形，阈值为量化概率0.5。同类八邻域格点合并，OSD显示得分最高的一个结果；全部合并结果保存在DDR。框表示12×12输出格点覆盖的区域，不是物体精确外轮廓；SHAPE原有几何轮廓识别单独保留。真实空心/实心卡、反色、光照和背景准确率另行验收。

AI/SELFTEST/NN 页最后一行仍用十六进制。BASE为US I/H/N（原INT8/FlyHash/连接组微秒）；M0002为MS I/H/N（RGB预处理/Invoke/后处理毫秒）。SELFTEST仍检查原模型、FlyHash、连接组与定点指令，不替代FOMO实物准确率。

## 数据与资源

帧池中的源数据是共享亮/暗量程的packed16 RGB，不是Bayer或RGB565。复用现有compute lease：START bit3只取得受保护源帧，CPU从其DDR基址采样96×96 RGB，在结束时ACK释放。旧32×32灰度DMA路径保留。FOMO任务还生成同源32×32灰度并运行原MLP、FlyHash和80状态连接组，保留原记录与回读接口。

真实相机应用使用已有100MHz RV32I、dot4/MulHi和2KB缓存。模型54640B，只注册Conv/Depthwise/Add/Softmax四种算子；代码、模型、tensor arena和诊断样本放DDR，没有新增神经RTL核或片上图像缓存。SOURCE_FRAME、SOURCE_CONFIG、RENDER_CONFIG、CONTEXT和MODEL分别绑定，变换在提交时锁存。

最终资源59635/60800XLR、252/256RAM、59/160DSP，余1165XLR/4RAM。写FIFO8、扫描读64拍、ROI读32拍；扫描低水位优先两轮后给普通轮，普通轮不重复授予优先端。128拍读与动态按拍数分配的候选在实板出现欠载，未作为合格性能结果；1666667-cycle截止计数保留，不为改善数字放宽预算。

最终Conv/DW复用现有控制服务，在输出行边界调度ROI/按键，修掉仅层间调度造成的低更新率。FOMO并发时满幅有效显示更新6.25→18.25Hz、2×7.65→29.5Hz；单次中位45.061/16.881ms，和采集约30fps、HDMI60Hz、模型推理约2.668秒分别统计。停止AI先完成当前受保护任务，CLI等待20秒；OFF不丢弃正在执行的源帧记录。

## 复现

PowerShell7，目录 `F:/Project/fpga/vision_base`。URL按实际设备枚举，下面为本轮目标。

```powershell
$py='C:/Users/Sregetic/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $py -E -X utf8 scripts/build_fomo_firmware.py --cfu-kernels --camera --output-dir results/roi_fomo_20261012/camera_cooperative
& $py -E -X utf8 scripts/test_fomo_pixels.py
& $py -E -X utf8 scripts/test_control_firmware.py
```

CLI使用现有菜单/按键事件FIFO，不新增网络选择硬件命令：先读NN页V值，再按需短按KEY2切换。

```powershell
. ./scripts/efinity_env.ps1
& "$env:PYTHONHOME/bin/python.exe" scripts/vision_control.py --url 'ftdi://0x0403:0x6011:4:9/2' --menu 10 --roi-status
# V与目标后端不同时才执行一次：
& "$env:PYTHONHOME/bin/python.exe" scripts/vision_control.py --url 'ftdi://0x0403:0x6011:4:9/2' --menu 10 --key-event 2 --roi-status
& "$env:PYTHONHOME/bin/python.exe" scripts/test_camera_fomo_board.py --url 'ftdi://0x0403:0x6011:4:9/2' --elf results/roi_fomo_20261012/camera_cooperative/vision.elf --output-dir results/roi_fomo_20261012/cooperative_camera
# 主机逐值对照需要已有 TensorFlow 环境，不使用无 TensorFlow 的工程 Python：
& F:/efinity-ci/tinyml-env/Scripts/python.exe scripts/verify_fomo_camera.py --directory results/roi_fomo_20261012/cooperative_camera/frozen
```

首次对照复用现有bulk USER2回读同一冻结源的pre-Gamma RGB，主机按同一ROI采样96×96，再逐值比对板上576个INT8输出、32×32灰度、原MLP/FlyHash/连接组和目标合并。USER1只读必要记录，避免慢速重复导出整幅输入；`read_fomo_camera.py --full-input`保留完整CPU RGB/packed样本导出用于细查。计时在CPU执行时完成，回读暂停不计入Invoke。

普通自制控制C文件保持原工程的`-ffreestanding -fno-builtin`；本轮已复现缺少这些选项导致自制memset递归及栈覆盖，构建会检查该实际故障。C++对象在显式初始化函数中局部静态构造，现有裸机入口不增加全局构造流程。

配置Flash、SPI自主加载、KEY1恢复和真实拔电启动分别记录。按用户授权，完整8MiB旧Flash备份后，新配置已写入0地址，182160B启动包写入0x700000，配置写后验证与应用实际字节读回均通过。包内为177728B应用（含54640B FOMO模型）及原4400B MLP权重；两种后端均在同一自主加载应用内。

同版FPGA经JTAG重新配置SRAM后，ROM自主从SPI加载新程序/权重，BOOT7、JEDEC EF6017、CPU1及实际DDR全部字节一致。此检查无USER1程序下载；不将其写成主SPI配置路径或实际拔电/JTAG断开启动的验收。证据在`results/roi_fomo_20261012/flash_20261013/`。自举验证脚本沿用25kHz静态读回，因178KB应用实测需12.4分钟，等待上限由300改2400秒，不改读回速度或一致性规则。

自主加载后17项按键/ROI事件、八种模式、冻结和F2静态浏览/I6播放停止、F3及Canny发布复测通过；NN FOMO的FIX请求源29875、MODEL2、Invoke2667.750ms，启动自检PASS。最后已恢复实时原图M0/MED1/F0、Sobel128/Canny80、AI OFF/NN BASE。复位初始值仍保持原固件M3/MED0/F0、Sobel/Canny128；现场可用正常页KEY0切到CAMERA，不把主机最后设置写成掉电保存的参数。
