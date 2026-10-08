# 原图普通亮度区域去噪：2026-10-08

## 结论与当前部署
- 新SRAM：F:\Project\fpga\vision_base\results\raw_rgb_denoise_20261008\release_compact\ti60f225_oob.bit；Flash保持原状。
- 最终原生资源59967/60800 XLR、247/256 RAM、59/160 DSP，相对I1/I3部署新增178 XLR、0 RAM、0 DSP，余833 XLR/9 RAM。
- 最终路由WNS+0.040ns、WHS+0.026ns、未分配核心引脚0。第一版release的最终WNS-0.005ns，未烧录；紧凑范围比较版release_compact/seed2通过后才烧录。placement阶段负slack不当作最终结果。
- 相机/显示工作点、原图回读、Canny/识别/帧池、Sapphire/AI/DMA均保留。DDR重新加载同一个8456字节应用及4400字节合成权重，25kHz实际读回一致。

## 根因与修复范围
原rgb_shadow_denoise只在Y<=48的暗部处理色度，不处理普通亮度区域的亮度/色噪。MED0下M0又跳过完整RGB中值，所以该区域噪声直接被tone放大。两版照片的光照/曝光也不同，未把全部差异归成版本回归。

改动仅位于现有rgb_shadow_denoise：保留暗部原算法；Y>48且左右Y差<=8、各RGB通道差<=16时，使用横向[1,2,1]/4舍入平均。強亮度/色彩边缘、每行首尾像素保持原值。无新增行RAM，无额外周期；M0/MED0也生效，完整3×3中值开关仍独立保留。near16的9位模差比较避免六组abs/mux，65536对8位输入与原距离条件等价。

这是横向轻量滤波，不冒充二维/时域去噪。较大纹理、斑点仍有残留；冻结时暗部提亮状态漂移的独立问题尚未在此修改。

## 实际同帧检查
- 旧位流同一源635884完成M0中值off/on/off；off重复行350..649逐像素完全相同，排除了这次开关对照期间的提亮漂移。打开中值细粒度下降，但色块仍明显，故未简单把MED1当修复。
- 新位流实际回读源21489/render2，源RGB与M0共两张1920×1080。目录：F:\Project\fpga\vision_base\results\roi_live_20261004\mode_frames_1791463195698。
- 回读期间曝光1233、shadow_boost0前后相同；不是改曝光、Gamma或压暗来掩盖颗粒。
- 新回读ROI[900,450,200,200]的40000个RGB像素与新RTL等价参考逐像素一致。
- 同一个源21489，通过已验证的旧管道参考作对照：细粒度高通标准差1.21012→0.771807，降低36.2207%；平均灰度136.8462→136.9364，仅增加0.0902级。旧管道是数值参考，不是另一张烧录前实拍；参考在旧板源635884的40000像素上已逐像素验证一致。
- 上述数值不是纯传感器时域噪声测量，包含实际背景细纹理，也不表示所有位置都降低36%。白色灯块及大斑点未据此宣称处理完成。

## 系统回归与恢复
- 29项视频特性回归通过；新增普通亮度RGB、黑/白、亮度边界/色彩边界及65536范围比较检查通过。
- 同源21489的分析DMA1024像素、128特征、32隐藏输出、4分数、256-bit FlyHash与主机逐值一致，DMA错误0；融合包源21489/render2/context4/model1、框[702,362,1181,681]、分数[23,-40,-53,-3]匹配CPU。依旧TEST，不宣称实物准确率。
- 已恢复用户当时使用的实时M0/MED0、ROI关闭、F0、Sobel128/Canny80、几何自动策略2；没有留下冻结源。额外15秒检查源帧推进、错误/扫描坏帧无新增，deadline计数不再增长（冻结/启停增量另见记录）。
- 面板最新图库更新为本次原图/M0两图；旧九图目录仍保留，读取九图功能未改变。

## 复现

```powershell
& 'C:/Users/Sregetic/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' -E F:\Project\fpga\vision_base\results\raw_rgb_denoise_20261008\check_readback.py F:\Project\fpga\vision_base\results\roi_live_20261004\mode_frames_1791463195698 --shadow 0 --revision new
```

![当前实际原图回读](F:\Project\fpga\vision_base\results\roi_live_20261004\mode_frames_1791463195698\mode_0.png)
