"""Build four-op TFLM against the existing RV32I DDR map, without hardware IP."""
import argparse
import json
import re
import subprocess
from pathlib import Path
from load_vision_ddr import ROOT, IDE, validate_image

REVISION = '96886fa0c73e25e6218db7d0863f84677cf65138'
EXAMPLE = 'tinyml_hello_world/Ti60F225_tinyml_hello_world/embedded_sw/SapphireSoc/software/standalone/tinyml_pdti8/src'
LABELS = ['blank', 'circle', 'rectangle', 'triangle']


def software_headers(src, overlay, cfu=False):
    # The vendor reference kernels call optional accelerator drivers first.
    # Remove only those calls for the existing SoC with no TinyML accelerator.
    for name, driver in [('conv', 'conv'), ('depthwise_conv', 'depthwise'), ('add', 'add')]:
        rel = Path('tensorflow/lite/kernels/internal/reference/integer_ops') / (name + '.h')
        text = (src / rel).read_text()
        text, includes = re.subn(r'^#include "platform/tinyml/ops/[^\"]+"\n', '', text, flags=re.M)
        text, calls = re.subn(r'(?:auto|OP_STATUS_T) res = ' + driver + r'_drv\(.*?\);\s*if\(res == OP_OK \|\| res == OP_BYPASS\) \{\s*return;\s*\}',
                              '// Existing SoC: execute the reference software kernel.', text, flags=re.S)
        assert (includes, calls) == (1, 1), (rel, includes, calls)
        if cfu and name != 'add':
            start = text.index('int8_t* output_data) {') + len('int8_t* output_data) {')
            end, depth = start, 1
            while depth:
                depth += (text[end] == '{') - (text[end] == '}')
                end += 1
            function = 'Conv' if name == 'conv' else 'Depthwise'
            text = text[:start] + '\n vision_fomo::' + function + '(params, output_multiplier, output_shift, input_shape, input_data, filter_shape, filter_data, bias_data, output_shape, output_data);\n' + text[end-1:]
            text = text.replace('#include "tensorflow/lite/kernels/internal/common.h"',
                                '#include "tensorflow/lite/kernels/internal/common.h"\n#include "fomo_kernels.h"', 1)
        path = overlay / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)
    if cfu:
        rel = Path('fixedpoint/fixedpoint.h')
        text = (src / 'tensorflow/third_party/gemmlowp' / rel).read_text()
        text = text.replace('#include <', '#include "fomo_fixedpoint.h"\n#include <', 1)
        text, count = re.subn(r'(inline std::int32_t SaturatingRoundingDoublingHighMul\(std::int32_t a,\s*std::int32_t b\) \{).*?\n\}',
                             r'\1\n  return fomo_round_high(a, b);\n}', text, count=1, flags=re.S)
        assert count == 1
        text, count = re.subn(r'(inline IntegerType RoundingDivideByPOT\(IntegerType x, int exponent\) \{.*?\n\})',
                             r'\1\n\ntemplate <>\ninline std::int32_t RoundingDivideByPOT(std::int32_t x, int exponent) {\n  return fomo_round_divide(x, exponent);\n}',
                             text, count=1, flags=re.S)
        assert count == 1
        path = overlay / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--tinyml-dir', type=Path, default=Path('F:/efinity-ci/deps/tinyml'))
    p.add_argument('--model-dir', type=Path, default=ROOT / 'models/shape_fomo')
    p.add_argument('--output-dir', type=Path, required=True)
    p.add_argument('--cfu-kernels', action='store_true', help='Requires the installed dot4/MulHi FPGA build; baseline software kernels remain available')
    p.add_argument('--camera', action='store_true', help='Complete control/legacy AI application with camera RGB FOMO; no embedded test images')
    p.add_argument('--connectome-readout', type=Path, help='CRD1 trained 80->4 companion readout; preserves the existing NN/SHAPE selection')
    a = p.parse_args()
    if a.camera and not a.cfu_kernels:
        p.error('The installed camera application requires dot4/MulHi kernels')
    readout = None
    if a.connectome_readout:
        if not a.camera:
            p.error('--connectome-readout requires --camera')
        import sys
        sys.path.insert(0, str(ROOT/'models'))
        from connectome_readout import load
        readout = load(a.connectome_readout)
    if a.camera:
        from build_ai_selftest import generate
        generate(ROOT/'models/shape_cards_bringup/shape_cards_weights.bin', ROOT/'firmware/vision/ai_selftest_data.h')
    revision = subprocess.check_output(['git', '-C', str(a.tinyml_dir), 'rev-parse', 'HEAD'], text=True).strip()
    if revision != REVISION:
        raise ValueError('Build uses the audited Efinity 2026.1 TFLM revision')
    src = a.tinyml_dir / EXAMPLE
    out = a.output_dir.resolve()
    out.mkdir(parents=True, exist_ok=True)
    overlay = out / 'software_headers'
    software_headers(src, overlay, a.cfu_kernels)
    data = '.section .rodata.fomo,"a"\n'
    data_files = [('fomo_model', [a.model_dir / 'shape_fomo_int8.tflite'])]
    if readout:
        data_files += [('connectome_readout_weights', [a.connectome_readout])]
    if not a.camera:
        data_files += [('fomo_inputs', [a.model_dir / 'test_vectors' / (s + '_input.bin') for s in LABELS]),
                       ('fomo_expected', [a.model_dir / 'test_vectors' / (s + '_expected_output.bin') for s in LABELS])]
    for symbol, files in data_files:
        data += '.balign 16\n.global ' + symbol + '\n' + symbol + ':\n'
        for path in files:
            if symbol in ('fomo_inputs', 'fomo_expected') and path.stat().st_size != (27648 if symbol == 'fomo_inputs' else 576):
                raise ValueError('Fixed-vector tensor length mismatch: ' + str(path))
            data += '.incbin "' + path.resolve().as_posix() + '"\n'
    (out / 'data.S').write_text(data)
    groups = {
        'core/api': ['error_reporter', 'flatbuffer_conversions', 'op_resolver'],
        'kernels': ['kernel_util'],
        'kernels/internal': ['quantization_util'],
        'micro': ['memory_helpers', 'micro_allocator', 'micro_error_reporter', 'micro_graph',
                  'micro_interpreter', 'micro_profiler', 'micro_string', 'micro_utils', 'simple_memory_allocator'],
        'micro/kernels': ['conv', 'conv_common', 'depthwise_conv', 'depthwise_conv_common',
                          'add', 'softmax', 'softmax_common', 'kernel_util'],
        'micro/memory_planner': ['greedy_memory_planner', 'linear_memory_planner'],
        'schema': ['schema_utils'],
    }
    sources = [src / 'tensorflow/lite/c/common.c']
    sources += [src / 'tensorflow/lite' / group / (name + '.cc') for group, names in groups.items() for name in names]
    application = ['ai_main.c', 'flyhash.c', 'fomo_camera.cc'] if a.camera else ['fomo_main.cc']
    sources += [ROOT / 'firmware/vision' / s for s in application]
    sources += [ROOT / 'firmware/vision/start.S', out / 'data.S']
    includes = [overlay, src, src / 'tensorflow/third_party/flatbuffers/include',
                src / 'tensorflow/third_party/gemmlowp', src / 'tensorflow/third_party/ruy', ROOT / 'firmware/vision']
    flags = ['-march=rv32i_zicsr_zifencei', '-mabi=ilp32', '-O2', '-ffunction-sections', '-fdata-sections',
             '-fno-pic', '-msmall-data-limit=0', '-mno-relax', '-DNDEBUG', '-DTF_LITE_STATIC_MEMORY',
             '-DTF_LITE_DISABLE_X86_NEON', '-DTF_LITE_USE_GLOBAL_CMATH_FUNCTIONS',
             '-DTF_LITE_USE_GLOBAL_MIN', '-DTF_LITE_USE_GLOBAL_MAX', *['-I' + str(i) for i in includes]]
    if a.camera:
        flags += ['-DVISION_FOMO', '-DVISION_MULHI_CFU']
    if readout:
        flags += ['-DVISION_CONNECTOME_READOUT']
    tools = IDE / 'toolchain/bin'
    objects = []
    log = []
    for i, source in enumerate(sources):
        obj = out / ('obj/' + str(i) + '.o')
        obj.parent.mkdir(exist_ok=True)
        cpp = source.suffix == '.cc'
        command = [str(tools / ('riscv-none-elf-g++.exe' if cpp else 'riscv-none-elf-gcc.exe')), *flags]
        if cpp:
            command += ['-std=c++17', '-fno-exceptions', '-fno-rtti', '-fno-threadsafe-statics', '-fno-use-cxa-atexit']
        elif source.parent == ROOT/'firmware/vision' and source.suffix == '.c':
            command += ['-ffreestanding', '-fno-builtin']
        command += ['-c', str(source), '-o', str(obj)]
        r = subprocess.run(command, capture_output=True, text=True)
        log.append(' '.join(command) + '\n' + r.stdout + r.stderr)
        (out / 'build.log').write_text('\n'.join(log))
        r.check_returncode()
        objects.append(str(obj))
    elf = out / 'vision.elf'
    command = [str(tools / 'riscv-none-elf-g++.exe'), *flags, '-nostartfiles', '-specs=nosys.specs',
               '-Wl,--gc-sections', '-Wl,-Map=' + str(out / 'vision.map'),
               '-T', str(ROOT / 'firmware/vision/link_ddr.ld'), *objects, '-lm', '-lc', '-lgcc', '-o', str(elf)]
    r = subprocess.run(command, capture_output=True, text=True)
    log.append(' '.join(command) + '\n' + r.stdout + r.stderr)
    (out / 'build.log').write_text('\n'.join(log))
    r.check_returncode()
    entry, segments, symbols = validate_image(elf, None)
    dis = subprocess.check_output([str(tools / 'riscv-none-elf-objdump.exe'), '-d', str(elf)], text=True)
    (out / 'vision.dis').write_text(dis)
    if re.search(r'\t(?:mul\w*|div\w*|rem\w*|f[a-z]+\.[sd]|c\.[a-z]+)\s', dis):
        raise ValueError('Generated code uses an instruction absent from the installed RV32I core')
    if a.camera and '<memset>' in dis.split('<memset>:\n',1)[1].split('\n\n',1)[0]:
        raise ValueError('The freestanding memset was optimized into a recursive call')
    size = subprocess.check_output([str(tools / 'riscv-none-elf-size.exe'), str(elf)], text=True)
    record = dict(tinyml_revision=revision, isa='RV32I_Zicsr_Zifencei', software_only=True, cfu_kernels=a.cfu_kernels, camera=a.camera,
                  model_bytes=(a.model_dir / 'shape_fomo_int8.tflite').stat().st_size,
                  load_bytes=sum(s['size'] for s in segments), bss_bytes=symbols['__bss_end']-symbols['__bss_start'],
                  arena_address=symbols['__arena_start'], arena_reserved_bytes=262144,
                  xlr_delta=0, block_ram_delta=0, dsp_delta=0, hardware_rebuild=False,
                  elf=str(elf), size_report=size, source_files=[str(s) for s in sources])
    if readout:
        record['connectome_readout'] = dict(path=str(a.connectome_readout.resolve()), bytes=364,
                                           version=readout['version'], graph_version=readout['graph'],
                                           training_kind=readout['kind'], companion_only=True)
    (out / 'build.json').write_text(json.dumps(record, indent=2))
    print(size)
    print(json.dumps(record, indent=2))


if __name__ == '__main__':
    main()
