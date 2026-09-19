import argparse,json,time
from efx_pgm.ftdi_program import acquire_jtag_engine
from efx_pgm.device_utils import DeviceUtils
from pyftdi.bits import BitSequence
p=argparse.ArgumentParser();p.add_argument('--url',default='ftdi://0x0403:0x6011:4:3/2');p.add_argument('--mode',type=int);p.add_argument('--threshold',type=int);p.add_argument('--median',type=int,choices=[0,1]);p.add_argument('--memory',type=int,choices=range(4));p.add_argument('--index',type=int,choices=range(6));p.add_argument('--page',type=int,default=0,choices=range(16));p.add_argument('--color-order',type=int,choices=range(6));p.add_argument('--gamma','--tone',dest='gamma',type=int,choices=[0,1,2,3]);p.add_argument('--gain-r',type=int);p.add_argument('--gain-g',type=int);p.add_argument('--gain-b',type=int);p.add_argument('--samples',type=int,default=5);p.add_argument('--ae',type=int,choices=[0,1]);p.add_argument('--exposure',type=int);p.add_argument('--lcd-test',type=int,choices=[0,1]);p.add_argument('--lcd-bist',type=int,choices=[0,1]);p.add_argument('--lcd-backlight',type=int,choices=[0,1]);p.add_argument('--shape',type=int,choices=[0,1]);p.add_argument('--shape-threshold',type=int,choices=range(1,256));a=p.parse_args()
with acquire_jtag_engine(1e6,a.url) as e:
 e.reset()
 for op,value in [(126,a.page),(1,a.mode),(2,a.threshold),(3,a.median),(4,a.memory),(5,a.index),(6,a.color_order),(7,a.gamma),(8,a.gain_r),(9,a.gain_g),(10,a.gain_b),(11,a.ae),(12,a.exposure),(13,a.lcd_test),(14,a.lcd_bist),(15,a.lcd_backlight),(22,a.shape),(23,a.shape_threshold)]:
  if value is None:continue
  if op==12 and not 112<=value<=2950:raise ValueError("exposure range112..2950")
  if op in [8,9,10] and not 0<=value<=1024:raise ValueError('gain Q8.8 range0..1024')
  if op==1 and not 0<=value<=7:raise ValueError('mode0..7')
  if op==2 and not 0<=value<=2047:raise ValueError('threshold0..2047')
  e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);e.write_dr(BitSequence((0x56495331<<32)|(op<<24)|value,length=192));e.go_idle();time.sleep(.05)
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
   if build in [0x2609168c,0x2609168d,0x2609168e]:rec['tone_mode']=v&3
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
  if i:out.append(rec)
  time.sleep(.2)
 print(json.dumps(out,indent=2))
