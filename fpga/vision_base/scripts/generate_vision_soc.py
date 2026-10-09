"""Generate the vision SoC with the installed official Sapphire CLI."""
import argparse,json,subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser()
p.add_argument('--output-dir',type=Path,required=True)
p.add_argument('--cache-kb',type=int,choices=[2,4],default=2)
p.add_argument('--custom',action='store_true')
p.add_argument('--boot-hex',type=Path,required=True)
p.add_argument('--boot-kb',type=int,choices=[1,4,8],default=8)
a=p.parse_args();out=a.output_dir.resolve();out.relative_to(ROOT)
out.mkdir(parents=True,exist_ok=True)
java='C:/Program Files (x86)/Common Files/Oracle/Java/java8path/java.exe'
jar='F:/Efinity/2026.1/ipm/ip/efx_soc/efx_soc/generator/EfxSapphireSoc.jar'
args=['--toplevelName','VisionSapphire','--systemFrequency','100000000',
 '--PeripheralClock','false','--cpuCount','1','--softTap','false',
 '--L1I','true','--L1D','true','--iCacheWays','1','--dCacheWays','1',
 '--iCacheSize',str(a.cache_kb*1024),'--dCacheSize',str(a.cache_kb*1024),
 '--lowArea','5','--reducedCsr','--noMulDiv','--noBarrelShifter',
 '--Fpu','false','--FpuDouble','false','--Linux','false','--Atomic','false',
 '--customInstruction',str(a.custom).lower(),'--titanium',
 '--ddrAEnable','true','--ddrAAxi4','--ddrADataWidth','128','--ddrAIdWidth','4',
 '--ddrAAddress','0x0','--ddrASize','0x08000000','--noDdrAClock','--axiAEnable','false',
 '--onChipRamAddress','0xf9000000','--onChipRamSize',hex(a.boot_kb*1024),
 '--ramHex',a.boot_hex.resolve().as_posix(),
 '--uart','name=system_uart_0_io,address=0x010000,interruptId=1,fifoDepth=16',
 '--gpio','name=system_gpio_0_io,address=0x015000,width=4,interrupts=0->12;1->13',
 '--apbSlave','name=vision_apb,address=0x100000,size=65536']
cmd=[java,'-cp',jar,'saxon.board.efinix.EfxSapphireSoc',*args]
(out/'config.json').write_text(json.dumps(dict(cache_kb=a.cache_kb,custom=a.custom,
 boot_kb=a.boot_kb,muldiv=False,ddr_base=0,firmware_base=0x07000000,command=cmd),indent=2),encoding='utf-8')
with (out/'generate.log').open('w',encoding='utf-8') as log:
 subprocess.run(cmd,cwd=out,stdout=log,stderr=subprocess.STDOUT,check=True)
net=out/'hardware/netlist/VisionSapphire.v';s=net.read_text(encoding='utf-8')
# The generator writes lane initialization files next to its netlist. Resolve
# them explicitly because the board project's readmemb cwd is the board folder.
for f in (out/'hardware/netlist').glob('*.bin'):
 s=s.replace('"'+f.name+'"','"'+f.as_posix()+'"')
# Match soc_gen.py: the CLI emits references to the vendor ALU blocks.
for name in ['EfxCPUSp1.v','EfxCPUSp2.v']:
 s+='\n'+Path(jar).parents[1].joinpath('source_efinity',name).read_text()
net.write_text(s,encoding='utf-8')
print('GENERATED',net)
