"""Offline RV32I sidebar transactions and source-bound one-shot ROI centering."""
import argparse,ast,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--output-dir',type=Path,default=ROOT/'results/motion_sidebar_20261022/control')
out=p.parse_args().output_dir;out.mkdir(parents=True,exist_ok=True)
source=r'''
#include <stdint.h>
#define CONTROL_TEST
#define FUSION_TEST
#define VISION_FOMO
static uint32_t c[32],f[64];
static uint32_t cr(unsigned o){return c[o/4];}
static void cw(unsigned o,uint32_t v){c[o/4]=v;if(o==8)c[3]|=1;if(o==0x30){c[4]=(c[4]&~32u)|((v&1)<<5);if(v&2)c[4]|=16;if(v&4)c[4]&=~(1u<<11);if(v&8)c[6]=c[0x34/4];}}
#define CTRL_R(o) cr(o)
#define CTRL_W(o,v) cw(o,v)
#define FUS_R(o) (f[(o)/4])
#define FUS_W(o,v) (f[(o)/4]=(v))
#define CONTROL_STATE (&state)
extern struct vision_control_state state;
#include "fusion_service.h"
struct vision_control_state state;volatile uint32_t fusion_result[16];
static unsigned checks=0,geometry_cases=0;
static void puts(const char*s){while(*s)*(volatile unsigned char*)0x10000000=*s++;}
static void hex(uint32_t v){const char*s="0123456789abcdef";for(int k=28;k>=0;k-=4)*(volatile unsigned char*)0x10000000=s[(v>>k)&15];}
static void finish(unsigned ok){*(volatile unsigned*)0x100000=ok?0x5555:0x3333;for(;;);}
static void check_line(unsigned ok,unsigned line){checks++;if(!ok){puts("FAIL ");hex(line);puts("\n");finish(0);}}
#define check(x) check_line((x),__LINE__)
static void key(unsigned bits){control_event(0xff000000u|bits);}
static void trace(const char*name){puts("UI ");puts(name);puts(" ");hex(control_ui(&state));puts(" ");hex(state.settings);puts("\n");}
static void reset(void){for(unsigned i=0;i<32;i++)c[i]=0;for(unsigned i=0;i<64;i++)f[i]=0;c[4]=(1<<8)|(1<<6);c[5]=100;f[0]=0x26101003;f[4]=10;f[5]=100;f[7]=5;control_init();state.settings=(state.settings&~48u)|16;}
static void apply(void){control_service_step();c[3]&=~1u;control_service_step();}
static void accept(void){c[4]&=~16u;c[4]|=1u<<7;c[6]=c[0x34/4];control_service_step();}
static void select(unsigned item){
 if(state.sidebar_edit)key(8);
 if(state.sidebar_open==2&&control_sidebar_group(state.sidebar_item)!=control_sidebar_group(item))key(8);
 if(!state.sidebar_open)key(8);
 if(state.sidebar_open==1){while(control_sidebar_group(state.sidebar_item)!=control_sidebar_group(item))key(4);key(1);}
 while(state.sidebar_item!=item)key(4);check(state.sidebar_open==2);
}
static void action(unsigned item){select(item);key(1);check(state.sidebar_edit);key(1);check(!state.sidebar_edit);}
static void geometry(unsigned x,unsigned y,unsigned w,unsigned h,unsigned render,unsigned valid){
 uint64_t box=(1ull<<63)|((uint64_t)valid<<62)|(2ull<<60)|((uint64_t)(x+2)<<36)|((uint64_t)(y+2)<<24)|((uint64_t)(x+w+1)<<12)|(y+h+1);
 f[4]++;f[6]=render;f[8]=box>>32;f[9]=box;
}
static void trace_crop(const char *name,unsigned x,unsigned y,unsigned w,unsigned h){
 const uint32_t words[12]={x,y,w,h,state.commit[0],state.commit[1],state.commit[2],state.commit[3],
  state.center_frame,state.center_render,state.center_context,state.serial};
 for(unsigned i=0;i<4;i++)check(state.commit[i]==state.roi[i]);
 puts("ROI ");puts(name);for(unsigned i=0;i<12;i++){puts(" ");hex(words[i]);}puts("\n");
}
static void verify_box(unsigned x,unsigned y,unsigned w,unsigned h,unsigned maxz){
 geometry_cases++;
 reset();state.center_zoom=maxz;state.center_serial=state.serial;state.center_settings=state.settings;state.center_shape=state.shape_threshold;
 check(control_center_box(x,y,w,h,100,0,5));
 unsigned sx=state.roi[0]>>12,sy=state.roi[0]&4095,sw=state.roi[1]>>12,sh=state.roi[1]&4095;
 unsigned dw=state.roi[2]>>12,dh=state.roi[2]&4095,dx=state.roi[3]>>12,dy=state.roi[3]&4095,z=dw/sw;
 check(sw&&sh&&dw&&dh&&sx+sw<=1920&&sy+sh<=1080&&dx+dw<=1920&&dy+dh<=1080&&!(dw&7));
 check(z>=1&&z<=8&&(!maxz||z<=maxz)&&dw==sw*z&&dh==sh*z);
 check(2*dx+dw==1920&&2*dy+dh==1080);
 int cx=2*(int)dx+(2*(int)x+(int)w-2*(int)sx)*(int)z-1920;
 int cy=2*(int)dy+(2*(int)y+(int)h-2*(int)sy)*(int)z-1080;
 check(cx>=-8&&cx<=8&&cy>=-8&&cy<=8);
 check(x>=sx&&x+w<=sx+sw&&y>=sy&&y+h<=sy+sh);
 check(state.center_frame==100&&state.center_context==5&&state.center_stage==2&&state.pending==1);
}
void main(void){
 uint32_t isa;__asm__ volatile("csrr %0,misa":"=r"(isa));check((isa&(1u<<8))&&!(isa&0x102du));
 reset();check(offsetof(struct vision_control_state,sidebar_open)==120);
 state.roi[0]=123;state.ai_policy=2;state.sidebar_open=1;state.center_stage=3;control_sidebar_reset();check(state.roi[0]==123&&state.ai_policy==2&&!state.sidebar_open&&!state.center_stage);reset();
 unsigned original=state.settings;key(8);check(state.sidebar_open==1&&!state.sidebar_edit);trace("root");
 key(2);check(state.sidebar_item==SIDE_AI&&state.sidebar_open==1);key(4);check(state.sidebar_item==SIDE_MODE);
 key(1);check(state.sidebar_open==2&&!state.sidebar_edit&&state.settings==original);trace("image");
 key(2);check(state.sidebar_item==SIDE_MEDIAN);key(4);check(state.sidebar_item==SIDE_MODE);
 key(1);check(state.sidebar_edit&&state.edit_mode==5);key(4);check(state.edit_value==6&&(state.settings&7)==6);trace("edit_mode");
 key(8);check(!state.sidebar_edit&&state.sidebar_open==2&&state.settings==original);trace("cancel");
 key(8);check(state.sidebar_open==1&&!state.sidebar_edit);key(8);check(!state.sidebar_open);
 for(unsigned group=0;group<4;group++){
  reset();unsigned saved=state.settings;key(8);for(unsigned j=0;j<group;j++)key(4);
  check(control_sidebar_group(state.sidebar_item)==group&&state.sidebar_open==1&&((control_ui(&state)>>23)&7)==7);
  key(1);check(state.sidebar_open==2&&!state.sidebar_edit&&state.settings==saved&&!state.pending);
  unsigned first=control_sidebar_first(group),count=control_sidebar_count(group);
  for(unsigned j=0;j<count;j++){check(state.sidebar_item==first+j&&!state.pending&&state.settings==saved);key(4);}
  check(state.sidebar_item==first);key(2);check(state.sidebar_item==first+count-1);
  key(8);check(state.sidebar_open==1&&!state.sidebar_edit);key(8);check(!state.sidebar_open);
 }
 reset();
 select(SIDE_MOTION);check(!state.pending&&state.sidebar_item==16&&state.settings==original);trace("motion_off");
 key(1);key(2);check(state.edit_value==1&&state.settings==original);trace("motion_edit");
 key(8);check(!state.sidebar_edit&&state.settings==original);
 key(1);key(2);key(1);check(state.settings==(original|0x80000000u)&&!state.pending);trace("motion_on");apply();check(c[2]==state.settings);
 key(1);key(4);key(1);check(state.settings==original&&!state.pending);trace("motion_disabled");
 state.menu=8;key(8);key(8);check(!state.sidebar_open&&((control_ui(&state)>>11)&15)==8);reset();
 select(SIDE_MODE);key(1);key(4);check(state.sidebar_edit&&(state.settings&7)==6);key(1);check(!state.sidebar_edit&&state.sidebar_open==2&&(state.settings&7)==6);
 key(1);for(unsigned i=0;i<8;i++){key(4);check(state.sidebar_edit&&state.edit_value==((7+i)&7)&&(state.settings&7)==state.edit_value);apply();check((c[2]&7)==state.edit_value&&!state.pending);}
 key(2);check((state.settings&7)==5);key(8);check(!state.sidebar_edit&&(state.settings&7)==6);
 select(SIDE_THRESHOLD);key(1);key(4);check(state.sidebar_edit&&state.edit_value==64&&((state.settings>>20)&2047)==64&&((state.settings>>9)&2047)==128);
 for(unsigned i=0;i<200;i++)key(4);check(state.edit_value==16&&((state.settings>>20)&2047)==16);key(1);check(!state.sidebar_edit&&((state.settings>>20)&2047)==16);
 key(1);for(unsigned i=0;i<200;i++)key(2);check(state.edit_value==2047&&((state.settings>>20)&2047)==2047);key(8);check(((state.settings>>20)&2047)==2047);
 control_event(0x01000002);key(1);key(2);check(state.edit_value==144&&((state.settings>>9)&2047)==144&&((state.settings>>20)&2047)==2047);key(8);
 control_event(0x01000007);key(1);for(unsigned i=0;i<32;i++)key(4);check(state.shape_threshold==1&&state.edit_value==1);for(unsigned i=0;i<32;i++)key(2);check(state.shape_threshold==255&&state.edit_value==255);key(1);check(!state.sidebar_edit);
 select(SIDE_MEDIAN);key(1);check(!(state.settings&8)&&!state.sidebar_edit&&state.sidebar_open==2);key(1);check((state.settings&8)&&!state.sidebar_edit);
 select(SIDE_ZOOM);trace("view");key(1);key(2);check(state.edit_value==960&&state.roi[1]==((1920u<<12)|1080)&&!state.pending);trace("edit_zoom");
 key(8);check(state.roi[1]==((1920u<<12)|1080));key(1);key(2);key(1);check(state.key_roi_dirty&&state.roi[1]==((960u<<12)|540));
 apply();check(state.pending==2);accept();check(state.good&&!state.pending);
 select(SIDE_PAN_X);key(1);key(2);check((state.edit_roi[0]>>12)==512&&(state.roi[0]>>12)==480);key(8);check((state.roi[0]>>12)==480);
 select(SIDE_AI);key(1);key(2);check(!state.ai_policy);key(1);check(state.ai_policy==1&&state.ai_manual==1);
 action(SIDE_RUN);check(state.ai_request==1);action(SIDE_SELFTEST);check(state.selftest_request==1);
 select(SIDE_MODEL);key(1);key(2);check(state.ai_manual==1);key(1);check(state.ai_manual==3);
 select(SIDE_TARGET_ZOOM);key(1);for(unsigned i=0;i<6;i++)key(2);check(state.edit_value==8&&!state.center_zoom);key(1);check(state.center_zoom==8);
 key(16);check(((state.settings>>4)&3)==0&&state.sidebar_open);key(32);check(((state.settings>>4)&3)==1&&state.sidebar_open);
 action(SIDE_FULL_VIEW);apply();check(!state.enabled&&!state.pending&&state.roi[0]==0&&state.roi[3]==0);
 // New geometry is required after confirmation, even when AI is OFF.
 reset();action(SIDE_CENTER);check(state.center_request==1);apply();control_center_step();check(state.center_stage==4&&!state.pending);
 control_center_step();check(!state.pending);geometry(700,400,160,120,0,1);control_center_step();check(state.center_stage==2&&state.pending==1&&state.center_frame==100);
 trace_crop("geometry",700,400,160,120);
 apply();check(state.pending==2);accept();control_center_step();check(state.center_status==CENTER_DONE&&!state.center_stage);trace("center_done");
 unsigned serial=state.serial;for(unsigned i=0;i<10;i++){geometry(710,410,160,120,state.serial,1);control_center_step();}check(state.serial==serial);
 // F0 uses the next capture for live rendering rather than waiting for a frozen lease.
 reset();state.settings&=~48u;c[4]&=~64u;action(SIDE_CENTER);apply();control_center_step();
 geometry(700,400,160,120,0,1);control_center_step();apply();check(state.pending==1&&state.warming);
 c[5]++;apply();check(state.pending==2&&!state.warming&&!state.freeze);
 accept();control_center_step();check(state.center_status==CENTER_DONE&&!state.center_stage&&!state.pending);
 // A target in an already panned/scaled viewport is mapped back to the source.
 reset();state.enabled=state.good=1;state.freeze=1;c[4]|=128;state.serial=7;
 state.commit[0]=(480u<<12)|270;state.commit[1]=state.commit[2]=(960u<<12)|540;state.commit[3]=(400u<<12)|200;
 action(SIDE_CENTER);apply();control_center_step();geometry(700,400,160,120,7,1);control_center_step();
 check(state.center_stage==2&&state.center_render==7&&state.center_frame==100);
 check(state.roi[0]==((620u<<12)|395)&&state.roi[1]==((480u<<12)|270)&&state.roi[2]==((1920u<<12)|1080)&&!state.roi[3]);
 trace_crop("inverse_view",780,470,160,120);
 // No target, stale transform, history mode and busy renderer do not alter the view.
 reset();action(SIDE_CENTER);apply();control_center_step();geometry(700,400,160,120,0,0);control_center_step();check(state.center_status==CENTER_NONE&&!state.pending);trace("no_target");
 reset();action(SIDE_CENTER);apply();control_center_step();geometry(700,400,160,120,99,1);control_center_step();check(state.center_status==CENTER_STALE&&!state.pending);
 reset();state.pending=1;action(SIDE_CENTER);control_center_step();check(state.center_status==CENTER_BUSY&&state.pending==1&&state.serial==0);
 reset();state.settings=(state.settings&~48u)|32;action(SIDE_CENTER);control_center_step();check(state.center_status==CENTER_BUSY&&!state.pending&&((state.settings>>4)&3)==2);
 reset();action(SIDE_CENTER);apply();control_center_step();state.shape_threshold++;geometry(700,400,160,120,0,1);control_center_step();check(state.center_status==CENTER_STALE&&!state.pending);
 // A FOMO selection requests a fresh job, not a previously published model result.
 reset();state.ai_manual=3;state.ai_policy=1;action(SIDE_CENTER);apply();control_center_step();check(state.center_stage==3&&state.ai_request==1);
 static struct fusion_job j;j.g.frame=100;j.g.context=5;
 control_center_fomo(0,&j,1,700,400,160,120);check(state.center_stage==3&&!state.pending);
 control_center_fomo(state.center_seen,&j,1,700,400,160,120);check(state.pending==1&&state.center_stage==2);
 reset();state.ai_manual=3;state.ai_policy=1;action(SIDE_CENTER);apply();control_center_step();control_center_fomo(state.center_seen,&j,0,0,0,0,0);check(state.center_status==CENTER_NONE);
 reset();state.ai_manual=3;state.ai_policy=1;action(SIDE_CENTER);apply();control_center_step();j.g.context=4;control_center_fomo(state.center_seen,&j,1,700,400,160,120);check(state.center_status==CENTER_STALE);
 reset();state.ai_manual=3;state.ai_policy=2;action(SIDE_CENTER);apply();control_center_step();state.ai_policy=0;control_center_step();check(state.center_status==CENTER_STALE&&!state.pending);
 // A long Invoke polls keys before its completion callback, not the main loop.
 j.g.frame=100;j.g.render=0;j.g.context=5;
 reset();state.ai_manual=3;state.ai_policy=1;action(SIDE_CENTER);apply();control_center_step();
 control_event(0x60000000);control_center_fomo(state.center_seen,&j,1,700,400,160,120);
 check(state.center_status==CENTER_STALE&&!state.pending&&!state.center_stage&&!state.roi_enable);
 reset();state.ai_manual=3;state.ai_policy=1;action(SIDE_CENTER);apply();control_center_step();
 select(SIDE_MODEL);key(1);key(4);key(1);control_center_fomo(state.center_seen,&j,1,700,400,160,120);
 check(state.center_status==CENTER_STALE&&!state.pending&&!state.center_stage&&!state.roi_enable);
 reset();state.ai_manual=3;state.ai_policy=1;action(SIDE_CENTER);apply();control_center_step();
 unsigned old_nonce=state.center_seen;action(SIDE_CENTER);apply();
 control_center_fomo(old_nonce,&j,1,700,400,160,120);
 check(state.center_seen==state.center_request&&state.center_stage==3&&!state.pending&&state.ai_request==2);
 control_center_fomo(state.center_seen,&j,1,700,400,160,120);check(state.pending==1&&state.center_stage==2);
 reset();state.ai_manual=3;state.ai_policy=1;action(SIDE_CENTER);apply();control_center_step();
 action(SIDE_FULL_VIEW);control_center_fomo(state.center_seen,&j,1,700,400,160,120);
 check(!state.center_stage&&!state.roi_enable&&!state.pending&&state.key_roi_dirty);
 static const unsigned zs[5]={0,1,2,4,8};
 for(unsigned iz=0;iz<5;iz++)for(unsigned iy=0;iy<9;iy++)for(unsigned ix=0;ix<9;ix++){
  unsigned w=40+ix*13,h=30+iy*9,x=(1920-w)*ix/8,y=(1080-h)*iy/8;verify_box(x,y,w,h,zs[iz]);
 }
 verify_box(0,0,1920,1080,0);verify_box(100,0,1600,1080,8);
 static const unsigned odd_w[5]={1,3,17,41,143},odd_h[5]={1,5,19,53,137};
 for(unsigned iz=0;iz<5;iz++)for(unsigned size=0;size<5;size++)for(unsigned iy=0;iy<3;iy++)for(unsigned ix=0;ix<3;ix++){
  unsigned w=odd_w[size],h=odd_h[size];verify_box((1920-w)*ix/2,(1080-h)*iy/2,w,h,zs[iz]);
 }
 verify_box(2,40,60,80,0);trace_crop("top_left",2,40,60,80);
 verify_box(1850,980,64,72,0);trace_crop("bottom_right",1850,980,64,72);
 verify_box(900,320,60,400,0);trace_crop("tall_target",900,320,60,400);
 verify_box(1300,700,120,80,2);trace_crop("manual_2x",1300,700,120,80);
 puts("PASS sidebar_center checks=");hex(checks);puts(" geometry_cases=");hex(geometry_cases);puts("\n");finish(1);
}
void trap(void){puts("TRAP\n");finish(0);}
'''
(out/'test.c').write_text(source)
(out/'start.S').write_text('.section .text.start,"ax"\n.global _start\n_start:\n la sp,__stack_top\n la t0,trap\n csrw mtvec,t0\n call main\n j trap\n')
(out/'link.ld').write_text('OUTPUT_ARCH(riscv)\nENTRY(_start)\nSECTIONS{. = 0x80000000; .text : {*(.text.start) *(.text*)} .rodata : {*(.rodata*)} .data : {*(.data*) *(.sdata*)} .bss : {*(.bss*) *(.sbss*)} __stack_top = 0x80100000;}')
bin=Path('F:/Efinity/efinity-riscv-ide-2026.1/toolchain/bin')
cmd=[str(bin/'riscv-none-elf-gcc.exe'),'-march=rv32i_zicsr_zifencei','-mabi=ilp32','-Os','-ffreestanding','-fno-builtin','-mno-relax','-msmall-data-limit=0','-nostdlib','-I'+str(ROOT/'firmware/vision'),'-T',str(out/'link.ld'),str(out/'start.S'),str(out/'test.c'),'-lgcc','-o',str(out/'test.elf')]
r=subprocess.run(cmd,capture_output=True,text=True);(out/'compile.log').write_text(r.stdout+r.stderr);r.check_returncode()
r=subprocess.run(['F:/Efinity/efinity-riscv-ide-2026.1/qemu/qemu-system-riscv32.exe','-M','virt','-cpu','rv32,g=false,m=false,a=false,c=false,f=false,d=false','-nographic','-bios','none','-kernel',str(out/'test.elf')],capture_output=True,text=True,timeout=60)
(out/'test.log').write_text(r.stdout+r.stderr)
assert r.returncode==0 and 'PASS sidebar_center' in r.stdout,(r.returncode,r.stdout,r.stderr)
ui=[]
for line in r.stdout.splitlines():
 if line.startswith('UI '):
  _,name,word,settings=line.split();ui.append(dict(name=name,word=int(word,16),ui=((int(word,16)>>23)<<15)|(int(word,16)&32767),settings=int(settings,16)))
by_name={v['name']:v['ui'] for v in ui}
assert by_name['root']==0x838005 and by_name['image']==0x800005 and by_name['edit_mode']==0xc00006 and by_name['edit_zoom']==0xcc03c0,ui
# Exercise the diagnostic decoder without importing its hardware-only CLI.
tree=ast.parse((ROOT/'scripts/vision_control.py').read_text())
decode=next(n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name=='decode_ui')
namespace={};exec(compile(ast.Module(body=[decode],type_ignores=[]),'decode_ui','exec'),namespace)
for v in ui:
 word=v['word'];record=namespace['decode_ui']((0x56495331<<160)|(0x26101040<<128)|(v['settings']<<96)|(word<<64))
 item=((word>>26)&15)|(((word>>14)&1)<<4 if word>>31 else 0);status=(word>>23)&7;level=0 if not word>>31 else 1 if status==7 else 3 if word>>30&1 and item==0 else 2
 group=item if level==1 else (0 if item<3 else 1 if item<9 else 3 if item<13 else 2)
 assert record==dict(menu=0 if level else (word>>11)&15,menu_value=word&2047,shape_threshold=(word>>15)&255,index=(v['settings']>>15)&7,
                     sidebar_open=(word>>31)&1,sidebar_edit=(word>>30)&1,sidebar_item=item,center_status=status,sidebar_level=level,sidebar_group=group),record
(out/'ui_vectors.json').write_text(json.dumps(ui,indent=2));(out/'ui_vectors.mem').write_text(''.join(f'{v["ui"]:06x}\n' for v in ui))
roi=[]
for line in r.stdout.splitlines():
 if line.startswith('ROI '):
  _,name,*words=line.split();values=[int(word,16) for word in words]
  assert len(values)==12
  roi.append(dict(name=name,target=values[:4],roi=values[4:8],frame=values[8],render=values[9],context=values[10],config=values[11]))
assert len(roi)==6
(out/'center_vectors.json').write_text(json.dumps(roi,indent=2))
(out/'center_vectors.mem').write_text(''.join(f'{word:08x}\n' for v in roi for word in [*v['target'],*v['roi'],v['frame'],v['render'],v['context'],v['config']]))
checks=int(r.stdout.split('checks=')[1].split()[0],16)
geometry_cases=int(r.stdout.split('geometry_cases=')[1].split()[0],16)
assert geometry_cases==636
(out/'result.json').write_text(json.dumps(dict(passed=True,isa='RV32I',checks=checks,geometry_cases=geometry_cases,symmetric_margins=True,render_vectors=len(roi),diagnostic_decode_vectors=len(ui),scope='Production control/MMIO/geometry/FOMO result logic on QEMU; no board timing or real recognition acceptance',ui_vectors=ui),indent=2))
print(r.stdout.strip())
