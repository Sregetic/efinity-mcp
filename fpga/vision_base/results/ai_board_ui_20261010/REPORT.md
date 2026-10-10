# AI实体菜单、自检与结果HUD：实施与实测

用户指定第1、2项已实现、原生构建、更新配置Flash/SRAM并完成CPU/DMA/DDR和内部显示像素联调。真实训练数据另一路采集，本文不作实物识别准确率结论。

## 1. 已完成的功能

- KEY0长按扩展至10页；保留模式切换、独立阈值、ROI、冻结与六帧历史。AI页KEY2循环OFF/FIX/AUTO，KEY3请求一次；实体FIX无请求不运行，恢复实时仍保持单次。开发工具view仍连续，未改变其现有契约。
- FIX使用已提交源ROI，ROI关闭时使用[640,300,640,480]；请求确切显示源，不让此前开发工具latest标志覆盖实体单次帧绑定。等待ROI提交结束，再申请compute lease/DMA。
- 启动和SELFTEST页KEY2运行三组固定灰度输入，检查128特征、32隐藏值、4输出、8字FlyHash、80个Q14状态及dot4/MulHi。更新权重时构建工具重新生成参考数据；错误权重FAIL用例通过。
- 最后完成相机任务独立保存，自检只更新ST，不覆盖相机张量、源帧/render/context、分数、ROI、框或完成序号。
- OSD显示执行、自检、N完成序号低16位、A年龄、F源帧/R渲染配置/M模型、I/H/N三种计算耗时。时间单位为十六进制微秒，65535饱和，完整周期保留在DDR。

## 2. 收尾修正与资源

顶部HUD在ROI窗口y240之前读取到scan frame_ok=0，曾将完全匹配的结果误显示OLD。vision_ai_bridge现在共享身份比较，分别输出identity_match和identity_match&&frame_ok；HUD用前者，画框继续使用后者。不是放宽坏帧画框条件。

字体改为1块同步位ROM，字符/nibble选择范围收窄；十进制用11位BCD移位，保持全部2048输入值。拥塞候选暴露AE统计到请求的长路径，原模块中增加帧统计/比较/更新两级寄存，只延后2个时钟，阈值、步进、8帧等待不变。300帧混合输入、fresh/fault/manual等价，默认及SC2210参数用例通过；本轮实际烧录的是SC431HAI。

|整机|本轮开始|最终|净变化|剩余|
|---|---:|---:|---:|---:|
|XLR|59952|60082|+130|718/60800|
|RAM块|251|252|+1|4/256|
|DSP|59|59|0|101/160|

完整Efinity2026.1.132.3.9，Ti60F225，TIMING_3/seed5，map/interface/P&R/pgm全部通过；最终WNS+0.077ns/WHS+0.026ns，未分配核心引脚0。没有放宽时钟/引脚约束，HDMI1080p60、SC431HAI完整1440p约30fps、CPU100MHz保持。新增AI部分主要在DDR固件，不新增神经硬件核；图像回读、Canny双缓冲、原视频模式、统一帧池和DMA均保留。

`resources.json`、`native_compile.json`及`release/*.rpt`是最终证据。初始大OSD候选拥塞、compact候选60855XLR越界、identity两次路由失败、CONGESTION_1旧AE候选WNS−0.978ns、AE的CONGESTION_1/3路由失败均保留本地记录，未作为最终发布。前期decimal版本60233XLR曾上板用于联调，最终release已经换成上述60082版本。

## 3. 最终板上证据

`board_release/result.json`通过：冻结源3831，完成序号1→2；无请求不重复、重复请求同源、返回实时不自动运行、自检保留全部相机融合字段。再次单次请求得到实时新源9816、序号3，OFF/FIX/AUTO切换通过。测试注入的是实体键同一个事件FIFO，不是人工电气按压。

`final_view_validation.json`通过：冻结源16833、源ROI[736,302,960,540]→[768,302,960,540]，render3→4、sequence5→6、processing context14保持。纯几何变化不假造处理配置变化。两次ROI和随后自检的1024灰度像素、128特征、32隐藏值、4输出、256位FlyHash、80个Q14状态全部与主机整数参考一致。

示例新ROI：DMA3.46370ms，INT8两层3.15846ms，连接组10.17245ms，CPU总17.18773ms；这些是该次输入计时，不作为受控加速比。连接组仍没有训练读出；INT8权重仍synthetic bring-up，背景输出triangle不当作实物三角卡成功。

`osd_release/mode_0.png`是实际FPGA内部显示链的顶部100行，USER2行RAM导出，不是绘制的示意图，也不是采集卡/物理HDMI证明。图中AI DONE、ST PASS、N0006、A0000、F000041C1/R00000004/M0001正确，旧OLD问题已在该窗口条件下核对。

导出后已恢复M0/MED1/F0、源ROI[736,302,960,540]、输出960×540、位置[320,240]、Sobel128/Canny80/SHAPE32、AI页AUTO。`live_release.json`最后源21258；3秒前后源继续推进，config/render/scan error、capture_discarded、scan_bad_frames、render_deadline_misses均为0。此短检查不替代整机长时验收。

## 4. 启动、检查与复现

配置Flash地址0已写后官方onchipx1验证，原0x700000应用区保留。18740B应用和4400B权重配置重启后由SPI复制到DDR，`autoboot_release/result.json`实际字节相等、CPU state1、未下载USER1程序。完整8MiB旧Flash备份留在flash/flash_before.bin及flash_final/flash_before.bin；真实断电、拔掉JTAG启动仍待实测。

控制策略RV32I、自检三向量及坏权重FAIL、融合记录、32视频项、quick帧池/DDR回归通过。OSD全部2048十进制值、880000可见像素及HUD外别名等价；桥接VS发布/背压/失效扫描分离；AE300帧等价。最终板上CPU执行证明真实CFU，QEMU的INT8_TEST只用算术参考，两者分别记录。

本轮导出脚本首次主机核对因vendor Python缺PIL退出，finally仍恢复实时；host_environment_failure.log保留。主机模型核对随后使用已安装的通用Python，硬件访问继续用独立vendor Python，无新增依赖；最终全部通过。

PowerShell7，F:/Project/fpga/vision_base：

```powershell
$hostPy='C:/Users/Sregetic/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $hostPy -E -X utf8 scripts/build_vision_firmware.py --main firmware/vision/ai_main.c --load-method user1 --mulhi-cfu --output-dir artifacts/vision_soc/ddr_firmware
& $hostPy -E -X utf8 scripts/test_ai_selftest.py
& $hostPy -E -X utf8 scripts/test_control_firmware.py
& $hostPy -E -X utf8 scripts/build_vision_firmware.py --boot-kb 8 --output-dir results/ai_board_ui_20261010/boot_firmware
& $hostPy -E -X utf8 scripts/generate_vision_soc.py --output-dir artifacts/vision_soc --custom --cache-kb 2 --boot-kb 8 --boot-hex results/ai_board_ui_20261010/boot_firmware/vision.hex
./scripts/synthesize.ps1 -Top board -Flow compile -TimeoutSeconds 3600
# SRAM/Flash操作使用现有源/制品/时序门禁；实际URL以设备枚举为准。
. ./scripts/efinity_env.ps1
& "$env:PYTHONHOME/bin/python.exe" scripts/test_ai_board_ui.py --url 'ftdi://0x0403:0x6011:4:9/2' --elf artifacts/vision_soc/ddr_firmware/vision.elf --output-dir results/ai_board_ui_20261010/recheck
```

源码/报告/少量真实回读上传，vendor生成SoC、bit/hex/ELF、Flash备份只保留本机。根adapter未修改，其真实MCP SDK测试71passed/1Windows权限skip、compileall通过。

## 5. 现场操作与未验收

KEY0每次长按约1秒选菜单，短按约0.2秒；AI页KEY2选FIX，KEY3短按一次，N增加。长按KEY2冻结后再分析，F保持、A0；ZOOM/PAN后回AI页请求，F保持而R/N改变。SELFTEST页KEY2短按，ST PASS且N/F/R保持。AUTO无完整几何候选时不提交任务，验证输入链优先FIX。

人工实体按压、实际断电/JTAG拔掉、物理HDMI长期/紫闪和A6实物识别仍待现场验收；真实训练集/未知门槛/连接组读出不在本轮完成项。完整B/A/X/I/F/V范围保持。
