"""Load a DDR-linked ELF and optional weights via the existing USER1 CPU debug.

No FPGA programming, CPU reset or Flash access. OpenOCD owns cache maintenance
using the generated cpu0.yaml. A failed/partial load leaves the CPU halted.
"""
import argparse,json,struct,subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
IDE=Path('F:/Efinity/efinity-riscv-ide-2026.1')
# Active ROI scan exposed 0xa107a107 words at100kHz; the same halted
# application bytes read exactly at25kHz, without rewriting memory.
USER1_KHZ=25
# Cached ROI tensors produced repeated0x67756b75 at25kHz;5kHz word/dump reads
# matched the CPU sum. Halted program loading retains its verified25kHz setting.
USER1_READ_KHZ=5

def elf_segments(data):
    if len(data)<52 or data[:7]!=b'\x7fELF\x01\x01\x01':
        raise ValueError('Expected a complete little-endian ELF32 image')
    kind,machine,version,entry,phoff,shoff,flags,ehsize,phsize,phcount=struct.unpack_from('<HHIIIIIHHH',data,16)
    if (kind,machine,version,flags,ehsize,phsize)!=(2,243,1,0,52,32):
        raise ValueError('Expected RV32I executable ELF with no compressed/float ABI')
    if phoff+phsize*phcount>len(data):raise ValueError('Truncated ELF program headers')
    segments=[]
    for i in range(phcount):
        typ,offset,address,physical,size,memory,perm,align=struct.unpack_from('<8I',data,phoff+i*phsize)
        if typ!=1:continue
        if address!=physical or size>memory or offset+size>len(data):
            raise ValueError('ELF load segment is truncated or has a ROM load address')
        segments.append(dict(address=address,offset=offset,size=size,memory=memory,executable=bool(perm&1)))
    if not any(s['executable'] and s['address']<=entry<s['address']+s['size'] for s in segments):
        raise ValueError('ELF entry is outside its loaded executable segments')
    return entry,segments

def symbols(elf):
    result=subprocess.check_output([str(IDE/'toolchain/bin/riscv-none-elf-nm.exe'),'-P',str(elf)],text=True)
    return {v[0]:int(v[2],16) for line in result.splitlines() if len(v:=line.split())>=3}

def validate_image(elf,weights):
    entry,segments=elf_segments(elf.read_bytes());sym=symbols(elf)
    if sym['__app_start']!=0x07000000 or not 0x07000000<sym['__app_limit']<=sym['__weights_start']<sym['__weights_limit']<=sym['__debug_work_start']<sym['__debug_work_limit']<=0x08000000:
        raise ValueError('ELF memory map overlaps the frame pool or DDR regions')
    if entry!=sym['_start'] or any(not sym['__app_start']<=s['address']<=s['address']+s['memory']<=sym['__app_limit'] for s in segments):
        raise ValueError('ELF segments exceed the DDR application region')
    if weights and weights.stat().st_size>sym['__weights_limit']-sym['__weights_start']:
        raise ValueError('Weights exceed their DDR region')
    return entry,segments,sym

def tcl_path(path):
    value=path.resolve().as_posix()
    if any(c in value for c in '{}\n\r'):raise ValueError('Path contains Tcl delimiters')
    return '{'+value+'}'

def board_location(url):
    from efx_pgm.ftdi_program import acquire_jtag_engine
    from efx_pgm.device_utils import DeviceUtils
    with acquire_jtag_engine(1e6,url) as e:
        e.reset();e.write_ir(DeviceUtils.EFX_TI_INSTR['IDCODE']);identity=int(e.read_dr(32));e.go_idle()
        if identity!=0x10660a79:raise ValueError(f'Unexpected board ID {identity:#x}')
        device=e._engine_provider._ctrl._ftdi.usb_dev
        # USB address changes after replug; port path comes from this exact URL.
        return str(device.bus)+'-'+'.'.join(map(str,device.port_numbers))

def configuration(location,yaml,sym,jtag_khz=USER1_READ_KHZ):
    return f'''adapter driver ftdi
adapter usb location {location}
ftdi vid_pid 0x0403 0x6011
ftdi channel 1
ftdi layout_init 0x08 0x0b
adapter speed {jtag_khz}
jtag newtap ti60 bridge -expected-id 0x10660a79 -irlen 5 -ircapture 0x5 -irmask 0xf
target create sapphire.cpu0 vexriscv -endian little -chain-position ti60.bridge -coreid 0 -dbgbase 0x10b80000 -work-area-phys {sym['__debug_work_start']:#x} -work-area-size {sym['__debug_work_limit']-sym['__debug_work_start']}
vexriscv readWaitCycles 40
vexriscv cpuConfigFile {tcl_path(yaml)}
vexriscv jtagMapping 8 8 0 1 2 2 0 0
gdb_port disabled
tcl_port disabled
telnet_port disabled
init
'''

def main():
    p=argparse.ArgumentParser();p.add_argument('--url',required=True)
    p.add_argument('--elf',type=Path,required=True);p.add_argument('--weights',type=Path)
    p.add_argument('--cpu-config',type=Path,default=ROOT/'artifacts/vision_soc/cpu0.yaml')
    p.add_argument('--jtag-khz',type=int,default=USER1_KHZ,help='25kHz verified for USER1 reads while ROI scan remains active')
    p.add_argument('--chunk-bytes',type=int,default=0,help='0: original ELF transfer; 1024 with 1000kHz: verified short USER1 load/readback transactions')
    p.add_argument('--timeout-seconds',type=int,default=300,help='Load/readback deadline; large TFLM programs need longer than the original small application')
    p.add_argument('--output-dir',type=Path,required=True);a=p.parse_args()
    if a.jtag_khz<=0:p.error('--jtag-khz must be positive')
    if a.chunk_bytes<0 or a.chunk_bytes%4:p.error('--chunk-bytes must be zero or a positive multiple of4')
    if a.timeout_seconds<=0:p.error('--timeout-seconds must be positive')
    entry,segments,sym=validate_image(a.elf,a.weights)
    location=board_location(a.url);a.output_dir.mkdir(parents=True,exist_ok=True)
    commands=['halt','wait_halt 5000']
    if not a.chunk_bytes:commands.append(f'load_image {tcl_path(a.elf)}')
    readbacks=[]
    image=a.elf.read_bytes()
    for i,s in enumerate(segments):
        if not s['size']:continue
        for offset in range(0,s['size'],a.chunk_bytes or s['size']):
            size=min(a.chunk_bytes or s['size'],s['size']-offset)
            payload=image[s['offset']+offset:s['offset']+offset+size]
            path=a.output_dir/(f'segment{i}_{offset:06x}.bin' if a.chunk_bytes else f'segment{i}.bin')
            if a.chunk_bytes:
                write=path.with_suffix('.write.bin');write.write_bytes(payload)
                commands.append(f'load_image {tcl_path(write)} {s["address"]+offset:#x} bin')
            commands.append(f'dump_image {tcl_path(path)} {s["address"]+offset:#x} {size}')
            readbacks.append((path,payload))
    if a.weights:
        path=a.output_dir/'weights.bin';payload=a.weights.read_bytes()
        commands.extend([f'load_image {tcl_path(a.weights)} {sym["__weights_start"]:#x} bin',f'dump_image {tcl_path(path)} {sym["__weights_start"]:#x} {len(payload)}'])
        readbacks.append((path,payload))
    def run(name,commands,marker):
        cfg=configuration(location,a.cpu_config,sym,a.jtag_khz)+'if {[catch {\n'+'\n'.join([*commands,'echo '+marker])+'\n} failure]} {\n echo "VISION_DDR_ERROR: $failure"\n shutdown error\n}\nshutdown\n'
        path=a.output_dir/(name+'.cfg');path.write_text(cfg,encoding='utf-8')
        result=subprocess.run([str(IDE/'openocd/bin/openocd.exe'),'-f',str(path.resolve())],capture_output=True,text=True,timeout=a.timeout_seconds)
        log=result.stdout+result.stderr;(a.output_dir/(name+'.log')).write_text(log,encoding='utf-8')
        result.check_returncode()
        if marker not in log:raise RuntimeError('OpenOCD phase did not complete: '+name)
    # This installed VexRiscv target has no checksum_memory implementation.
    # Read actual CPU memory bytes and compare before permitting execution.
    run('load',commands,'VISION_DDR_READBACK')
    for path,expected in readbacks:
        if path.read_bytes()!=expected:raise RuntimeError('CPU memory readback mismatch: '+path.name)
    run('resume',['halt','wait_halt 5000',f'resume {entry:#x}'],'VISION_DDR_RESUMED')
    record=dict(passed=True,method='USER1 debug halt/load/verify/resume; no CPU reset',elf=str(a.elf.resolve()),entry=entry,segments=segments,
                payload_bytes=sum(s['size'] for s in segments),weights_bytes=a.weights.stat().st_size if a.weights else 0,weights_address=sym['__weights_start'],usb_location=location,jtag_khz=a.jtag_khz,chunk_bytes=a.chunk_bytes,byte_readback_verified=True,fpga_reprogrammed=False,flash_written=False)
    (a.output_dir/'result.json').write_text(json.dumps(record,indent=2),encoding='utf-8');print(json.dumps(record,indent=2))

if __name__=='__main__':main()
