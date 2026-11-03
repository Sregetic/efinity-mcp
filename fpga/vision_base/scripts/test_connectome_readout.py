"""Production RV32I readout vs exact host reference, with model-boundary failures."""
import argparse
import json
import struct
import subprocess
import sys
import tempfile
from pathlib import Path
import numpy as np
from train_shape_cards import ROOT, array

sys.path.insert(0, str(ROOT/'models'))
from connectome import fixed
from connectome_readout import inputs, load, predict
from shape_cards import CLASSES, gray_roi, features
from PIL import Image


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--model-dir', type=Path, required=True)
    p.add_argument('--output-dir', type=Path, required=True)
    a = p.parse_args()
    model_path = a.model_dir/'connectome_readout.bin'
    model = load(model_path)
    blob = model_path.read_bytes()
    # A wrong graph, illegal MulHi shift, overflowing bias and truncated blob are rejected before build.
    invalid = [blob[:-1]]
    for offset, value in [(8, 0x1234), (24, -1), (28, 0x7fffffff)]:
        data = bytearray(blob)
        struct.pack_into('<i', data, offset, value)
        invalid.append(bytes(data))
    with tempfile.TemporaryDirectory() as tmp:
        path = Path(tmp)/'invalid.bin'
        for data in invalid:
            path.write_bytes(data)
            try:
                load(path)
            except ValueError:
                pass
            else:
                raise AssertionError('Malformed readout was accepted')
    heldout = np.load(a.model_dir/'heldout.npz')
    states = np.vstack([heldout['states'], np.full((1, 80), -16384, np.int16),
                        np.full((1, 80), 16384, np.int16), np.zeros((1, 80), np.int16),
                        np.random.default_rng(2210).integers(-16384, 16385, (64, 80), dtype=np.int16)])
    expected = np.array([predict(s, model) for s in states])
    assert np.array_equal(expected[:len(heldout['scores'])], heldout['scores'])
    assert np.all(inputs(np.full(80, 16384, np.int16)) == 127)
    assert np.all(inputs(np.full(80, -16384, np.int16)) == -128)
    fixture_features = []
    for name in CLASSES:
        with Image.open(ROOT/'models/shape_fomo/test_vectors'/(name+'_96.png')) as image:
            fixture_features.append(features(gray_roi(image, (0, 0, image.width, image.height))))
    fixture_scores = [predict(fixed(f), model) for f in fixture_features]
    external = [dict(input_class=name, predicted_class=CLASSES[int(np.argmax(scores))],
                     scores=scores.tolist(), correct=int(np.argmax(scores)) == i)
                for i, (name, scores) in enumerate(zip(CLASSES, fixture_scores))]
    out = a.output_dir.resolve()
    out.mkdir(parents=True, exist_ok=True)
    source = '#define INT8_TEST\n#define VISION_MULHI_CFU\n#include "connectome.h"\n#include "connectome_readout.h"\n'
    source += 'static const uint8_t blob[] __attribute__((aligned(4)))={'+','.join(map(str, blob))+'};\n'
    source += array('states', 'int16_t', states)+array('expected', 'int8_t', expected)
    source += array('features', 'int8_t', fixture_features)+array('expected_fixture', 'int8_t', fixture_scores)
    source += '''
static void finish(unsigned ok){*(volatile unsigned *)0x100000=ok?0x5555:0x3333;for(;;);}
void main(void){
 const struct connectome_readout_model *m=(const struct connectome_readout_model*)blob;
 if(sizeof(*m)!=364||!connectome_readout_valid(m))finish(0);
 int8_t scores[4];int16_t neurons[80];
 for(unsigned i=0;i<sizeof(states)/sizeof(states[0]);i++){
  connectome_readout(m,states[i],scores);
  for(unsigned j=0;j<4;j++)if(scores[j]!=expected[i][j])finish(0);
 }
 for(unsigned i=0;i<4;i++){
  connectome_snapshot(features[i],neurons);connectome_readout(m,neurons,scores);
  for(unsigned j=0;j<4;j++)if(scores[j]!=expected_fixture[i][j])finish(0);
 }
 const char*p="PASS RV32I CRD1 quantization, signed dense and four independent fixed-image pipelines\\n";
 while(*p)*(volatile unsigned char*)0x10000000=*p++;finish(1);
}
void trap(void){finish(0);}
'''
    (out/'test.c').write_text(source)
    (out/'start.S').write_text('.section .text.start,"ax"\n.global _start\n_start:\n la sp,__stack_top\n la t0,trap\n csrw mtvec,t0\n call main\n j trap\n')
    (out/'link.ld').write_text('OUTPUT_ARCH(riscv)\nENTRY(_start)\nSECTIONS{. = 0x80000000; .text : {*(.text.start) *(.text*)} .rodata : {*(.rodata*)} .data : {*(.data*) *(.sdata*)} .bss : {*(.bss*) *(.sbss*)} __stack_top = 0x80100000;}')
    ide = Path('F:/Efinity/efinity-riscv-ide-2026.1')
    subprocess.run([str(ide/'toolchain/bin/riscv-none-elf-gcc.exe'), '-march=rv32i_zicsr_zifencei', '-mabi=ilp32',
                    '-Os', '-ffreestanding', '-fno-builtin', '-mno-relax', '-msmall-data-limit=0', '-nostdlib',
                    '-I'+str(ROOT/'firmware/vision'), '-T', str(out/'link.ld'), str(out/'start.S'),
                    str(out/'test.c'), '-lgcc', '-o', str(out/'test.elf')], check=True)
    r = subprocess.run([str(ide/'qemu/qemu-system-riscv32.exe'), '-M', 'virt', '-cpu',
                        'rv32,m=false,a=false,c=false,f=false,d=false', '-nographic', '-bios', 'none',
                        '-kernel', str(out/'test.elf')], capture_output=True, text=True, timeout=90)
    (out/'test.log').write_text(r.stdout+r.stderr)
    assert r.returncode == 0 and 'PASS RV32I CRD1' in r.stdout, (r.returncode, r.stdout, r.stderr)
    result = dict(passed=True, readout_vectors=len(states), compared_int8_outputs=len(states)*4,
                  independent_full_circuit_vectors=4, malformed_models_rejected=len(invalid),
                  max_integer_difference=0, model_bytes=len(blob), real_accuracy_verified=False,
                  external_fixed_images=external, external_fixed_correct=sum(r['correct'] for r in external),
                  scope='PASS means integer equivalence, not recognition acceptance; external images never train the model')
    (out/'result.json').write_text(json.dumps(result, indent=2))
    print(r.stdout.strip())
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
