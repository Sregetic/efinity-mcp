"""Check the actual DDR ELF and reject damaged/ROM images before touching USB."""
import struct
from pathlib import Path
from load_vision_ddr import elf_segments,validate_image,tcl_path,configuration

root=Path(__file__).resolve().parents[1]
out=root/'results/ai_closed_loop_20261007'
elf=out/'loader_test_build/vision.elf';data=elf.read_bytes()
entry,segments,sym=validate_image(elf,None)
assert entry==0x07000000 and sum(s['size'] for s in segments)>3840
assert sym['__stack_bottom']<sym['__stack_top']<sym['__debug_work_start']
assert 'adapter speed 25\n' in configuration('4-1.2.1',root/'artifacts/vision_soc/cpu0.yaml',sym)
assert 'adapter speed 50\n' in configuration('4-1.2.1',root/'artifacts/vision_soc/cpu0.yaml',sym,50)
assert sym['__input0']<sym['__input1']<sym['__input_limit']<=sym['__arena_start']<sym['__arena_limit']<sym['__stack_bottom']
bad=[data[:40],data[:52],b'NOTELF'+data[6:]]
for offset,fmt,value in [(18,'<H',62),(36,'<I',1),(24,'<I',0xf9000000)]:
    corrupt=bytearray(data);struct.pack_into(fmt,corrupt,offset,value);bad.append(corrupt)
phoff=struct.unpack_from('<I',data,28)[0]
for i in range(struct.unpack_from('<H',data,44)[0]):
    pos=phoff+32*i
    if struct.unpack_from('<I',data,pos)[0]!=1:continue
    for offset,value in [(12,0xf9000100),(16,len(data)+1),(20,1)]:
        corrupt=bytearray(data);struct.pack_into('<I',corrupt,pos+offset,value);bad.append(corrupt)
for corrupt in bad:
    try:elf_segments(corrupt)
    except (ValueError,struct.error):pass
    else:raise AssertionError('Malformed or ROM-mapped image accepted')
try:tcl_path(Path('bad{path}.elf'))
except ValueError:pass
else:raise AssertionError('Tcl delimiter accepted')
weights=out/'loader_weights.bin';weights.write_bytes(bytes((i*13+7)&255 for i in range(8192)))
validate_image(elf,weights)
print('PASS DDR ELF >3840 bytes, reserved regions, malformed/ROM images, Tcl path and weights')
