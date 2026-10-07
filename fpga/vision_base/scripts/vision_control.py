import argparse,json,time
from pathlib import Path
from efx_pgm.ftdi_program import acquire_jtag_engine
from efx_pgm.device_utils import DeviceUtils
from pyftdi.bits import BitSequence
from capture_mode_images import decode_snapshot,decode_caps
from flyhash_board import decode_status as decode_flyhash_status
def decode_roi(v):
 tag=(v>>128)&0xffffffff;u=(v>>64)&0xffffffff;t=(v>>32)&0xffffffff;l=v&0xffffffff
 if tag==0x26100412:
  names=['roi_enabled','roi_frame_ok','source_held','source_frozen','render_busy','render_pending','capture_active','config_busy','config_error','render_error','scan_error','commit_rejected']
  return dict(roi_frame_id=u,applied_config_id=t,**{name:(l>>(31-i))&1 for i,name in enumerate(names)})
 if tag==0x26100413:return dict(roi=[u>>16,u&65535,t>>16,t&65535],output_size=[l>>16,l&65535])
 if tag==0x26100414:return dict(capture_discarded=u,scan_bad_frames=t,render_cycles=l)
 if tag==0x26100415:return dict(requested_config_id=u,accepted_config_id=t,rejected_config_id=l)
 if tag==0x26100416:return dict(held_source_frame_id=u,held_raw_id_sample=t,rgb_capture_count=l)
 if tag==0x26100417:return dict(position=[u>>16,u&65535],display_size=[t>>16,t&65535],render_deadline_misses=l)
 return None

def validate_roi(roi,size,pos):
 x,y,w,h=roi;dw,dh=size;dx,dy=pos
 if min(x,y,dx,dy)<0 or min(w,h,dw,dh)<1:raise ValueError('ROI/size must be positive, origins nonnegative')
 if x+w>1920 or y+h>1080:raise ValueError('ROI exceeds1920x1080 original frame')
 if dw%8 or dx+dw>1920 or dy+dh>1080:raise ValueError('Output width must be a multiple of8; viewport must fit1920x1080 canvas')
p=argparse.ArgumentParser();p.add_argument('--sensor',choices=['sc431hai','sc2210'],default='sc431hai');p.add_argument('--url',default='ftdi://0x0403:0x6011:4:3/2');p.add_argument('--mode',type=int);p.add_argument('--threshold',type=int);p.add_argument('--sobel-threshold',type=int);p.add_argument('--canny-threshold',type=int);p.add_argument('--median',type=int,choices=[0,1]);p.add_argument('--memory',type=int,choices=range(4));p.add_argument('--index',type=int,choices=range(6));p.add_argument('--page',type=int,default=0,choices=range(32));p.add_argument('--color-order',type=int,choices=range(6));p.add_argument('--gamma','--tone',dest='gamma',type=int,choices=[0,1,2,3]);p.add_argument('--gain-r',type=int);p.add_argument('--gain-g',type=int);p.add_argument('--gain-b',type=int);p.add_argument('--samples',type=int,default=5);p.add_argument('--ae',type=int,choices=[0,1]);p.add_argument('--exposure',type=int);p.add_argument('--lcd-test',type=int,choices=[0,1]);p.add_argument('--lcd-bist',type=int,choices=[0,1]);p.add_argument('--lcd-backlight',type=int,choices=[0,1]);p.add_argument('--shape',type=int,choices=[0,1]);p.add_argument('--shape-threshold',type=int,choices=range(1,256))
p.add_argument('--roi',type=int,nargs=4,metavar=('X','Y','W','H'));p.add_argument('--output-size',type=int,nargs=2,metavar=('W','H'));p.add_argument('--position',type=int,nargs=2,metavar=('X','Y'));p.add_argument('--roi-enable',type=int,choices=[0,1]);p.add_argument('--rerender',action='store_true');p.add_argument('--roi-status',action='store_true');a=p.parse_args()
exposure_min,exposure_max=112,2950
if a.sensor=='sc2210':
 manifest=json.loads((Path(__file__).resolve().parents[1]/'artifacts/camera_sc2210/manifest.json').read_text(encoding='utf-8-sig'))
 if manifest['sensor']!='sc2210':raise ValueError('Selected artifact sensor mismatch')
 profile=manifest['sensor_profile'];exposure_min,exposure_max=profile['exposure_min'],profile['exposure_max']
if a.exposure is not None and not exposure_min<=a.exposure<=exposure_max:raise ValueError(f'exposure range{exposure_min}..{exposure_max}')
with acquire_jtag_engine(1e6,a.url) as e:
 e.reset()
 def command(op,value):
  e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);e.write_dr(BitSequence((0x56495331<<32)|(op<<24)|value,length=192));e.go_idle();time.sleep(.02)
 def roi_page(page):
  command(126,page)
  for _ in range(2):e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);v=int(e.read_dr(192));e.go_idle()
  if v>>160!=0x56495331 or (v>>128)&0xffffffff!=0x26100400+page:raise RuntimeError(f'ROI firmware/page mismatch: {v:048x}')
  s=(v>>96)&0xffffffff;rec=decode_roi(v)
  rec.update(mode=(s>>21)&7,median=(s>>20)&1,memory=(s>>18)&3,threshold=(s>>4)&2047,canny_ready=(s>>29)&1,canny_fault=(s>>31)&1)
  return rec
 def roi_status():
  status={}
  for page in range(18,24):status.update(roi_page(page))
  command(126,8)
  for _ in range(2):e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);v=int(e.read_dr(192));e.go_idle()
  if (v>>128)&0xffffffff!=0x26091785:raise RuntimeError('Threshold/color page mismatch')
  status.update(sobel_threshold=(v>>24)&2047,canny_threshold=(v>>13)&2047,canny_effective_threshold=(v>>2)&2047)
  return status
 commands=[(126,a.page),(1,a.mode),(2,a.threshold),(0x28,a.sobel_threshold),(0x29,a.canny_threshold),(3,a.median),(4,a.memory),(5,a.index),(6,a.color_order),(7,a.gamma),(8,a.gain_r),(9,a.gain_g),(10,a.gain_b),(11,a.ae),(12,a.exposure),(13,a.lcd_test),(14,a.lcd_bist),(15,a.lcd_backlight),(22,a.shape),(23,a.shape_threshold)]
 for op,value in commands:
  if value is None:continue
  if op in [8,9,10] and not 0<=value<=1024:raise ValueError('gain Q8.8 range0..1024')
  if op==1 and not 0<=value<=7:raise ValueError('mode0..7')
  if op in [2,0x28,0x29] and not 16<=value<=2047:raise ValueError('threshold16..2047')
 change_roi=a.roi is not None or a.output_size is not None or a.position is not None or a.roi_enable is not None or a.rerender
 if change_roi:
  deadline=time.monotonic()+10
  while roi_page(18)['config_busy']:
   if time.monotonic()>deadline:raise TimeoutError('Previous ROI commit is pending')
  current=roi_status();roi=current['roi'] if a.roi is None else a.roi;size=current['output_size'] if a.output_size is None else a.output_size;pos=current['position'] if a.position is None else a.position
  validate_roi(roi,size,pos);enabled=1 if a.roi_enable is None else a.roi_enable
 for op,value in commands:
  if value is not None:command(op,value)
 if change_roi:
  for op,values in [(0x30,roi[:2]),(0x31,roi[2:]),(0x32,size),(0x33,pos)]:command(op,(values[0]<<12)|values[1])
  command(0x34,enabled);command(0x35,0);expected=(current['requested_config_id']+1)&0xffffffff;deadline=time.monotonic()+10
  while True:
   ids=roi_page(21);state=roi_page(18)
   if ids['rejected_config_id']==expected:raise RuntimeError(f'ROI config{expected} rejected: {state}')
   if enabled and state['roi_enabled'] and state['applied_config_id']==expected and state['roi_frame_ok']:break
   if not enabled and ids['accepted_config_id']==expected and not state['roi_enabled']:break
   if time.monotonic()>deadline:raise TimeoutError(f'ROI config{expected} not applied: {ids}, {state}')
  command(126,a.page)
 if a.roi_status:
  status=roi_status();command(126,a.page);print(json.dumps(status,indent=2));raise SystemExit(0)
 out=[]
 for i in range(a.samples+1):
  e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);v=int(e.read_dr(192));e.go_idle();s=(v>>96)&0xffffffff
  rec=dict(magic=f'{v>>160:08x}',build=f'{(v>>128)&0xffffffff:08x}',mode=(s>>21)&7,median=(s>>20)&1,memory=(s>>18)&3,index=(s>>15)&7,threshold=(s>>4)&2047,edges=(v>>64)&0xffffffff,frames=(v>>32)&0xffffffff,status=f'{v&0xffffffff:08x}',raw=f'{v:048x}')
  if ((v>>128)&0xffffffff)>=0x26091604:
   rec.update(capture_id=(v>>64)&0xffffffff,display_id=(v>>32)&0xffffffff,canny_completed=v&0xffffffff,canny_fault=(s>>31)&1,canny_busy=(s>>30)&1,canny_ready=(s>>29)&1,history_count=(s>>26)&7)
   rec.pop('edges');rec.pop('frames');rec.pop('status')
  actual_build=(v>>128)&0xffffffff
  decode_build=(0x2609160e+(((actual_build>>4)&15)<<4)) if (actual_build&0xffffff00)==0x26091700 else actual_build
  rec['keys_n']=s&7;rec['sample_time_s']=time.time()
  if decode_build in [0x26091615,0x26091616,0x26091617,0x26091618,0x26091619,0x2609161a,0x2609161b,0x2609161c,0x2609161d,0x2609161e]:
   for key in ['capture_id','display_id','canny_completed']:rec.pop(key,None)
   rec.update(write_errors=(v>>64)&0xffffffff,edges=(v>>32)&0xffffffff,frames=v&0xffffffff)
  elif decode_build in [0x26091625,0x26091626,0x26091627,0x26091628,0x26091629,0x2609162a,0x2609162b,0x2609162c,0x2609162d,0x2609162e]:
   rec.pop('canny_completed',None);rec.update(checksum=(v>>64)&0xffffffff,display_id=(v>>32)&0xffffffff,capture_id=v&0xffffffff)
  build=decode_build
  if build in [0x2609164a,0x2609165a,0x2609166a,0x2609167a,0x2609164b,0x2609165b,0x2609166b,0x2609167b,0x2609164c,0x2609165c,0x2609166c,0x2609167c,0x2609164d,0x2609165d,0x2609166d,0x2609167d,0x2609164e,0x2609165e,0x2609166e,0x2609167e]:
   for key in ['capture_id','display_id','canny_completed']:rec.pop(key,None)
   channels=[(v>>64)&0xffffffff,(v>>32)&0xffffffff,v&0xffffffff]
   rec['rgb_sums_or_clips']=channels
   if build not in [0x2609167a,0x2609167b,0x2609167c,0x2609167d,0x2609167e]:rec['rgb_mean']=[n/65536 for n in channels]
  if build in [0x2609168b,0x2609168c,0x2609168d,0x2609168e]:
   for key in ['capture_id','display_id','canny_completed']:rec.pop(key,None)
   rec['physical_gains_rgb']=[(v>>80)&65535,(v>>64)&65535,(v>>48)&65535]
   if build in [0x2609168c,0x2609168d,0x2609168e]:
    rec['tone_mode']=v&3
    rec.update(sobel_threshold=(v>>24)&2047,canny_threshold=(v>>13)&2047,canny_effective_threshold=(v>>2)&2047)
  if build in [0x260916ad,0x260916ae]:
   for key in ['capture_id','display_id','canny_completed']:rec.pop(key,None)
   rec['highlight_pixels']=(v>>64)&0xffffffff
  if actual_build in [0x260917b0,0x260917c0,0x260917b1,0x260917c1,0x260917b2,0x260917c2,0x260917b3,0x260917c3,0x260917b4,0x260917c4,0x260917b5,0x260917c5]:
   for key in ['capture_id','display_id','canny_completed']:rec.pop(key,None)
   if actual_build in [0x260917b0,0x260917b1,0x260917b2,0x260917b3,0x260917b4,0x260917b5]:rec.update(exposure_applied=(v>>80)&65535,exposure_request=(v>>64)&65535,exposure_updates=(v>>48)&65535,exposure_readback=f'{(v>>24)&0xffffff:06x}',ae_fault=v&1,ae_busy=(v>>1)&1,ae_enabled=(v>>2)&1,shadow_boost=(v>>3)&1)
   else:
    n=(v>>48)&65535;total=(v>>32)&65535;clips=(v>>16)&65535
    rec.update(center_mean_raw=((v>>64)&0xffffffff)/n if n else None,center_count=n,total_count=total,clip_count=clips,clip_fraction=clips/total if total else None,ae_decision=v&3)
  if actual_build in [0x260917d1,0x260917d2,0x260917d3,0x260917d4,0x260917d5] or (actual_build==0x260917f5 and a.page==13):
   for key in ['capture_id','display_id','canny_completed']:rec.pop(key,None)
   rec.update(lcd_frames=(v>>64)&0xffffffff,lcd_line_pairs=(v>>48)&65535,lcd_config_state=(v>>4)&15,lcd_pack_fault=(v>>3)&1,lcd_test=(v>>2)&1,lcd_video_ready=(v>>1)&1,lcd_config_done=v&1)
  if actual_build in [0x260917e4,0x260917e5] or (actual_build==0x260917f5 and a.page==14):
   for key in ['capture_id','display_id','canny_completed']:rec.pop(key,None)
   rec.update(lcd_phy_seen=f'{(v>>8)&255:02x}',lcd_reset_pin=(v>>3)&1,lcd_backlight_pin=(v>>2)&1,lcd_bist=(v>>1)&1,lcd_backlight_enabled=v&1)
  if actual_build==0x260919a6:
   for key in ['capture_id','display_id','canny_completed']:rec.pop(key,None)
   rec.update(highlight_pixels=(v>>64)&0xffffffff,shape_enabled=(v>>63)&1,shape_valid=(v>>62)&1,shape_class=(v>>60)&3,shape_background=(v>>52)&255,shape_reject_flags=(v>>48)&15,shape_box=[(v>>36)&4095,(v>>24)&4095,(v>>12)&4095,v&4095])
  if actual_build==0x26100410:
   rec.pop('capture_id');rec.pop('display_id')
   meta=(v>>64)&0xffffffff
   rec.update(probe_busy=(meta>>31)&1,probe_hold=(meta>>30)&1,probe_request=(meta>>29)&1,probe_ack=(meta>>28)&1,probe_address=meta&4095,probe_data=f'{(v>>32)&0xffffffff:08x}')
  if actual_build==0x26100411:
   rec.pop('capture_id');rec.pop('display_id')
   stats=(v>>32)&0xffffffff
   rec.update(canny_completed=(v>>64)&0xffffffff,noise_mean_bound=(stats>>24)&255,noise_valid=(stats>>23)&1,median_applied=(stats>>22)&1,effective_threshold=stats&2047,display_id=v&0xffffffff)
  if actual_build in [0x26100418,0x26100419]:
   for key in ['capture_id','display_id','canny_completed']:rec.pop(key)
   if actual_build==0x26100418:rec.update(canny_analysis_size=[(v>>80)&65535,(v>>64)&65535],canny_coarse_edges=(v>>32)&0xffffffff,canny_display_edges=v&0xffffffff,canny_render='1px connected contour')
   else:rec.update(canny_analysis_cycles=(v>>64)&0xffffffff,canny_sweep_passes=(v>>32)&0xffffffff,canny_weak_visits=v&0xffffffff)
  if actual_build in [0x2610051a,0x2610051b]:
   rec=dict(magic=f'{v>>160:08x}',build=f'{actual_build:08x}',raw=f'{v:048x}',sample_time_s=time.time(),
            **{'snapshot_'+k:value for k,value in decode_snapshot(v).items()})
  if actual_build==0x2610051c:
   for key in ['capture_id','display_id','canny_completed']:rec.pop(key)
   width,height,bits=decode_caps(v)
   rec.update(snapshot_width=width,snapshot_height=height,snapshot_rgb_bits=bits)
  if actual_build in [0x26100603,0x26100604,0x26100605,0x26100606,0x26100607,0x2610061a,0x2610061b]:
   for key in ['capture_id','display_id','canny_completed']:rec.pop(key)
   rec.update(diagnostic_disabled=True,diagnostic_page=actual_build&255)
  if actual_build in (0x2610051d,0x2610071d,0x2610081d):
   rec=dict(magic=f'{v>>160:08x}',build=f'{actual_build:08x}',raw=f'{v:048x}',sample_time_s=time.time(),
            **{'flyhash_'+k:value for k,value in decode_flyhash_status(v).items()})
  if actual_build in [0x2610051e,0x2610051f]:
   rec=dict(magic=f'{v>>160:08x}',build=f'{actual_build:08x}',raw=f'{v:048x}',sample_time_s=time.time(),
            flyhash_half='low' if actual_build==0x2610051e else 'high',flyhash_bits=f'{v&((1<<128)-1):032x}')
  if actual_build==0x2610081e:
   rec=dict(magic=f'{v>>160:08x}',build=f'{actual_build:08x}',raw=f'{v:048x}',sample_time_s=time.time(),
            flyhash_result_address=(v>>96)&0xffffffff,flyhash_input_address=(v>>64)&0xffffffff,
            flyhash_firmware_state=(v>>32)&0xffffffff,flyhash_cycles=v&0xffffffff)
  roi_rec=decode_roi(v)
  if roi_rec is not None:
   for key in ['capture_id','display_id','canny_completed']:rec.pop(key)
   rec.update(roi_rec)
  if i:out.append(rec)
  time.sleep(.2)
 print(json.dumps(out,indent=2))
