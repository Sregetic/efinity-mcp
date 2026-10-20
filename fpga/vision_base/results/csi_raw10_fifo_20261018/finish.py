from pathlib import Path
import json
P=Path(__file__).resolve().parent
def read(name):return json.loads((P/name).read_text(encoding='utf-8-sig'))
r=read('resources.json');video=read('live_video.json');restored=read('restored_video.json');keys=read('key_ui/result.json');ai=read('ai_board/result.json');numeric=read('ai_board/frozen/verification.json');images=read('image_verification.json');concurrent=read('concurrent_video.json');program=read('program.json');reload=read('firmware_reload/result.json');final=read('final_status.json');caps=read('final_page_28.json')[0];probe=read('final_page_16.json')[0]
assert all(x['passed'] for x in [video,restored,keys,ai,numeric,images,concurrent,reload])
assert program['programmer_completed'] and not program['flash_written'] and not reload['flash_written']
assert len(keys['cases'])==17 and len(keys['history'])==7 and len(ai['cases'])==5
assert (final['mode'],final['median'],final['memory'],final['roi_enabled'],final['source_held'],final['source_frozen'],final['menu'])==(5,1,0,0,0,0,0)
assert not any(final[k] for k in ['config_error','render_error','scan_error','canny_fault','capture_discarded','scan_bad_frames'])
assert (caps['snapshot_width'],caps['snapshot_height'],caps['snapshot_rgb_bits'])==(1920,1080,24) and not probe['probe_hold']
assert not read('final_ai.json')['ai_enabled'] and read('final_page_30.json')[0]['flyhash_firmware_state']==1
assert images['images']==9 and all(not x['different_channels'] for x in images['comparisons'].values())
result=dict(passed=True,scope='Native route and actual SC431HAI board/CPU/image-readback acceptance; not physical panel, motion-contact or recognition accuracy acceptance',resources=r,sram_programmed=True,flash_written=False,ddr_application_preserved=reload['elf'],program_bytes_verified=reload['payload_bytes'],weights_bytes_verified=reload['weights_bytes'],video_seconds=video['seconds'],video_rates=video['rates'],key_cases=17,history_slots=6,history_autoplay_separate=True,camera_ai_cases=5,ai_numeric=numeric,full_images=9,transferred_pixels=9*1920*1080,image_verification=images,concurrent_roi={k:v for k,v in concurrent.items() if k!='rows'},restored_video={k:v for k,v in restored.items() if k!='rows'},final=final,receiver_standalone_pixel_simulation_passed=False,receiver_structure_synthesis_passed=read('receiver_map_verification.json')['passed'])
(P/'acceptance.json').write_text(json.dumps(result,indent=2))
rate=video['rates'];a=r['after'];img=images
report=f'''# RAW10专用接收与512深FIFO：整机资源及SRAM验收

日期：2026-10-18。当前SRAM已更新，Flash保持10-17版。完整现有系统、原图/模式RGB24回读保留；DDR应用重新加载为原有果蝇读出版本，并完成实际程序178896B、权重4400B字节回读后运行。

## 实际资源

|资源|原ROI优化版|当前SRAM|本轮释放|当前余量|
|---|---:|---:|---:|---:|
|XLR|57356|56916|440|3884/60800|
|RAM|244|241|3|15/256|
|DSP|62|62|0|98/160|

最终WNS+{a['wns_ns']}ns、WHS+{a['whs_ns']}ns，未分配核心引脚0。原生map/interface/P&R/pgm四阶段及制品/源码/时序门禁通过。原生输入比较只有board/ti60f225_v4/rtl/csi_rx_controller.sv一个文件变化；PACK_TYPE15→1，仅保留RAW10所需Pack40；PIXEL_FIFO_DEPTH1024→512。相机166条初始化、PLL/HTS/VTS、4lane/RAW10、1920×1080中心窗口、Bayer/曝光/增益/色调、全部后端算法与内存/CPU逻辑保持。

CSI层级RAM11→8：四lane对齐FIFO仍4块，像素FIFO7→4块；CSI原始LUT2543→2083、FF1461→1304。整机XLR净释放440，不把局部LUT/FF数量相加当作物理XLR。image_snapshot仍5块RAM、1920×1080 RGB24。

## 已执行的检查

- 三份传感器profile启动序列、原生1080流、旧FOV流/RAW去马赛克逐像素、复位分支、错误时钟/Bayer相位拒绝通过；当前512深度同时高于保留2560宽RAW10分支的行容量下限400。SC2210和完整1440p分支没有本轮实物/P&R验收。
- 原图色调/高光/单通道裁切、AE冻结/手动/故障、曝光写入与I2C回读六项现有仿真通过。
- 实际IP5.15新旧独立map通过，检查Pack40保留、Pack48/56/64消除；这是结构综合证据，不是接收核像素仿真。
- 60秒实测{video['samples']}次采样、{video['seconds']:.3f}s：采集{rate['capture']:.3f}、显示内容{rate['display']:.3f}、Canny{rate['canny']:.3f}次/s。几何持续480字/行×1080行、4PPC、RAW10、518400字/帧；CSI硬错误掩码0x7ffd为0，采集丢弃/扫描欠载增量0。状态0x8002中的FIFO-empty不按错误处理。
- 实际CPU事件FIFO按键策略17项通过；六历史槽分别静止，I6独立自动播放；冻结、缩放、平移、视口和恢复实时通过。这不是人工电气按压验收。
- 相机FOMO+果蝇读出5种发布/同源重渲染/自检保持/实时场景通过。源43417/render10的FOMO576输出、旧INT8/FlyHash、80个连接组状态及4个读出分数均与实际同源图主机参考逐值一致；FOMO Invoke1159.574ms，读出0.171ms。未进行新训练或实物精度验收。
- 并发FOMO/读出+满幅ROI {concurrent['seconds']:.3f}s/{concurrent['samples']}采样：渲染均值{concurrent['mean_ms']:.3f}ms，观察发布{concurrent['observed_publications_hz']:.3f}次/s，扫描欠载/采集丢弃增量0。原16.667ms截止预算保持，截止计数增{concurrent['deadline_delta']}，不计满幅60fps通过。

## 实际九图

源帧{img['source_frame']}、渲染配置{img['render_config']}：Gamma前源图及M0..M7九幅完整1920×1080，9720行头/参数/帧/配置检查通过，共18662400像素。实际查看九图拼图、完整原图与Canny，未见整幅偏紫或坏行；相机原有细颗粒和高光饱和没有作为本轮画质改善。

Canny、Canny叠加、分屏、Sobel叠加各2056320个非OSD像素与既有参考逐值一致，最大误差0；没有排除四边。前后4050字Canny位图完全相同，共{img['canny_edges']}个边缘点。Sobel保持原有连续强度显示，不是0/255二值图：本轮检查器最初误写二值断言，核对vision_display及优化前条带后修正检查器，重新检查通过，没有修改生产Sobel或重复导出。

旧/新位流相机帧取图时刻不同，未做跨位流同一原帧A/B。第500–523行M0条带RGB均值由97.10/131.80/129.38到86.32/116.70/114.15，记录为不同时刻的亮度差，不称逐像素不变；本轮未调整AE/增益/曲线。当前曝光808、AE无故障。画面算法保持的证据为生产输入只改上述两项、同源多模式参考0差异及实际回读，不把时间间隔内亮度或噪声当作已证明相等。

九图：all_modes.png；原尺寸：images/source.png、images/mode_0.png至mode_7.png。image_verification.json保留各项结果。

## 当前状态与边界

已恢复M5/MED1/F0/I0/menu0、Sobel128/Canny80/SHAPE32、ROI关闭且全幅参数、AI OFF/NN BASE；Tone3/WB336/256/504、AE开启保持。源持有/冻结和位图hold均0，CPU状态1。恢复后另{restored['seconds']:.3f}s/{restored['samples']}采样确认实时帧继续更新、CSI硬错误和丢弃/欠载仍0。没有遗留OpenOCD或仿真运行。

Flash未写；断电/CONFIG后仍由旧Flash版本启动。本轮未做物理显示器现场观看、移动相机诱发紫闪、长时或实物卡精度验收。独立接收核像素仿真未计通过：映射网表的加密单元未在本机ModelSim环境编译通过；另搭IP5.17并行接口驱动对原15/1024基准也无像素输出，因此该驱动未建立有效基准。尝试保留在attempts/及相应工作目录，未把它们计入通过项；实际IP5.15结构综合、实际板上几何/CSI/图像证据分别记录。

详细入口：resources.json、compile.json、program.json、firmware_reload/result.json、live_video.json、key_ui/result.json、ai_board/result.json、ai_board/frozen/verification.json、concurrent_video.json、images/images.json、image_verification.json、restored_video.json和acceptance.json。位流与绑定报告在release/。
'''
(P/'REPORT.md').write_text(report,encoding='utf-8')
print('PASS complete SRAM/readback acceptance:',r['released'],'frame',img['source_frame'])
