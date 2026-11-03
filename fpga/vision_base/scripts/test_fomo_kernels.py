"""Compare optimized C++ kernels/Q31 to the original math on RV32I QEMU.

INT8_TEST emulates the existing CFU; only real-board tests measure its speed.
"""
import argparse
import json
import subprocess
from pathlib import Path
from build_fomo_firmware import ROOT, IDE, EXAMPLE, software_headers

p = argparse.ArgumentParser()
p.add_argument('--output-dir', type=Path, default=ROOT/'results/fomo_speed_20261011/unit')
out = p.parse_args().output_dir
out.mkdir(parents=True, exist_ok=True)
src = Path('F:/efinity-ci/deps/tinyml') / EXAMPLE
software_headers(src, out / 'reference_headers')
source = r'''
#include <stdint.h>
#include "fomo_fixedpoint.h"
#define ConvPerChannel RefConvPerChannel
#include "tensorflow/lite/kernels/internal/reference/integer_ops/conv.h"
#undef ConvPerChannel
#define DepthwiseConvPerChannel RefDepthwiseConvPerChannel
#include "tensorflow/lite/kernels/internal/reference/integer_ops/depthwise_conv.h"
#undef DepthwiseConvPerChannel
#include "fomo_kernels.h"
[[noreturn]] static void finish(unsigned ok) { *(volatile unsigned*)0x100000=ok?0x5555:0x3333; for(;;); }
extern "C" void fomo_kernel_fail() { finish(0); }
extern "C" void trap() { finish(0); }
extern "C" void DebugLog(const char*) { finish(0); }
static unsigned control_polls=0;
extern "C" void fomo_control_poll() { ++control_polls; }
static uint32_t random_state=2210;
static uint32_t next() { uint32_t x=random_state; x^=x<<13; x^=x>>17; x^=x<<5; return random_state=x; }
static int32_t ref_high(int32_t a,int32_t b) {
    if(a==INT32_MIN&&b==INT32_MIN) return INT32_MAX;
    int64_t value=(int64_t)a*b;
    return (value+(value>=0?(1ll<<30):(1-(1ll<<30))))/(1ll<<31);
}
alignas(16) static int8_t input[4096],weights[10000],reference[4096],actual[4096];
static int32_t bias[96],multipliers[96],shifts[96];
static void vectors() {
    for(auto& v:input) v=next(); for(auto& v:weights) v=next();
    for(int i=0;i<96;i++) {
        bias[i]=(int)(next()%20001)-10000;
        multipliers[i]=0x40000000+(next()&0x3fffffff); shifts[i]=(int)(next()%11)-8;
    }
}
static void compare(int bytes) { for(int i=0;i<bytes;i++) if(reference[i]!=actual[i]) finish(0); }
static void conv(int channels,int outputs,int fh,int fw,int stride,int pad,int dilation,int offset,bool biased,bool unaligned) {
    vectors();
    int ih=5,iw=6,oh=(ih+2*pad-dilation*(fh-1)-1)/stride+1,ow=(iw+2*pad-dilation*(fw-1)-1)/stride+1;
    int32_t di[4]={1,ih,iw,channels},df[4]={outputs,fh,fw,channels},dout[4]={1,oh,ow,outputs},db[1]={outputs};
    tflite::RuntimeShape in(4,di),filter(4,df),outshape(4,dout),bs(1,db);
    tflite::ConvParams p{};p.stride_width=p.stride_height=stride;
    p.padding_values.width=p.padding_values.height=pad;
    p.dilation_width_factor=p.dilation_height_factor=dilation;p.input_offset=offset;p.output_offset=-57;
    p.quantized_activation_min=-91;p.quantized_activation_max=104;
    const int8_t* x=input+(unaligned?1:0);
    tflite::reference_integer_ops::RefConvPerChannel(p,multipliers,shifts,in,x,filter,weights,bs,biased?bias:nullptr,outshape,reference);
    unsigned before=control_polls;
    vision_fomo::Conv(p,multipliers,shifts,in,x,filter,weights,biased?bias:nullptr,outshape,actual);
    if(control_polls-before!=(unsigned)oh)finish(0);
    compare(oh*ow*outputs);
}
static void depthwise(int channels,int stride,int pad,int dilation,int offset,bool biased) {
    vectors();
    int ih=5,iw=6,fh=3,fw=3,oh=(ih+2*pad-dilation*2-1)/stride+1,ow=(iw+2*pad-dilation*2-1)/stride+1;
    int32_t di[4]={1,ih,iw,channels},df[4]={1,fh,fw,channels},dout[4]={1,oh,ow,channels},db[1]={channels};
    tflite::RuntimeShape in(4,di),filter(4,df),outshape(4,dout),bs(1,db);
    tflite::DepthwiseParams p{};p.depth_multiplier=1;p.stride_width=p.stride_height=stride;
    p.padding_values.width=p.padding_values.height=pad;
    p.dilation_width_factor=p.dilation_height_factor=dilation;p.input_offset=offset;p.output_offset=-128;
    p.quantized_activation_min=-128;p.quantized_activation_max=127;
    tflite::reference_integer_ops::RefDepthwiseConvPerChannel(p,multipliers,shifts,in,input,filter,weights,bs,biased?bias:nullptr,outshape,reference);
    unsigned before=control_polls;
    vision_fomo::Depthwise(p,multipliers,shifts,in,input,filter,weights,biased?bias:nullptr,outshape,actual);
    if(control_polls-before!=(unsigned)oh)finish(0);
    compare(oh*ow*channels);
}
extern "C" int main() {
    const int32_t corners[]={INT32_MIN,INT32_MIN+1,-1073741824,-2,-1,0,1,2,1073741824,INT32_MAX};
    for(int32_t a:corners)for(int32_t b:corners) if(fomo_round_high(a,b)!=ref_high(a,b))finish(0);
    for(int i=0;i<50000;i++) {int32_t a=next(),b=next(); if(fomo_round_high(a,b)!=ref_high(a,b))finish(0);}
    for(int i=0;i<10000;i++) {int32_t a=(int16_t)next(),b=(int16_t)next(); if(fomo_mul16(a,b)!=a*b)finish(0);}
    for(int e=0;e<32;e++) {
        for(int32_t x:corners) if(fomo_round_divide(x,e)!=gemmlowp::RoundingDivideByPOT(x,e))finish(0);
        for(int i=0;i<1000;i++) {int32_t x=next(); if(fomo_round_divide(x,e)!=gemmlowp::RoundingDivideByPOT(x,e))finish(0);}
    }
    for(int i=0;i<10000;i++) {
        int32_t x=(int)(next()%2000001)-1000000,m=next()&INT32_MAX,s=(int)(next()%19)-15;
        int32_t expected=tflite::MultiplyByQuantizedMultiplier(x,m,s);
        if(vision_fomo::emit(x,vision_fomo::prepare(m,s),0,INT32_MIN,INT32_MAX)!=expected)finish(0);
    }
    for(int i=0;i<1000;i++) {
        int32_t m=next()&INT32_MAX,s=-(int)(next()%32),offset=(int)(next()%256)-128;
        int32_t low=-128+(next()%64),high=64+(next()%64);
        auto q=vision_fomo::prepare(m,s);
        for(int j=0;j<10;j++) {
            int32_t v=(int)(next()%2000001)-1000000;
            int64_t r=(int64_t)tflite::MultiplyByQuantizedMultiplier(v,m,s)+offset;
            int32_t expected=r<low?low:r>high?high:r;
            if(vision_fomo::emit(v,q,offset,low,high)!=expected)finish(0);
        }
    }
    int convs=0,dws=0;
    for(int repeat=0;repeat<4;repeat++) {
        for(int channels:{3,8,16,48,96})for(int outputs:{4,16,96}) {
            conv(channels,outputs,1,1,1,0,1,128,true,false);convs++;
            conv(channels,outputs,1,1,1,0,1,-127,false,true);convs++;
        }
        for(int stride:{1,2})for(int pad:{0,1})for(int offset:{-127,0,128}) {
            conv(3,16,3,3,stride,pad,1,offset,true,false);convs++;
        }
        conv(3,16,3,3,1,2,2,128,false,true);convs++;
        for(int channels:{3,16,48,96})for(int stride:{1,2})for(int pad:{0,1})for(int offset:{-127,0,128}) {
            depthwise(channels,stride,pad,1,offset,true);dws++;
        }
        depthwise(16,1,2,2,128,false);dws++;
    }
    const char* p="PASS RV32I Q31 50100, signed16 10000, divide32320, requant10000, activation10000, Conv172/DW196 exact cases\n";
    while(*p)*(volatile unsigned char*)0x10000000=*p++;
    if(convs!=172||dws!=196)finish(0);finish(1);
}
'''
(out/'test.cc').write_text(source)
(out/'start.S').write_text('.section .text.start,"ax"\n.global _start\n_start:\n la sp,__stack_top\n la t0,trap\n csrw mtvec,t0\n call main\n j trap\n')
(out/'link.ld').write_text('OUTPUT_ARCH(riscv)\nENTRY(_start)\nSECTIONS{. = 0x80000000; .text : {*(.text.start) *(.text*)} .rodata : {*(.rodata*)} .data : {*(.data*) *(.sdata*)} .bss : {*(.bss*) *(.sbss*)} __stack_top = 0x80100000;}')
includes=[out/'reference_headers',src,src/'tensorflow/third_party/gemmlowp',ROOT/'firmware/vision']
cmd=[str(IDE/'toolchain/bin/riscv-none-elf-g++.exe'),'-march=rv32i_zicsr_zifencei','-mabi=ilp32','-O2','-std=c++17',
     '-DINT8_TEST','-DVISION_FOMO','-DNDEBUG','-DTF_LITE_STATIC_MEMORY','-DTF_LITE_DISABLE_X86_NEON','-ffunction-sections','-fdata-sections',
     '-fno-exceptions','-fno-rtti','-fno-pic','-mno-relax','-msmall-data-limit=0','-nostartfiles','-specs=nosys.specs',
     *['-I'+str(p) for p in includes],'-Wl,--gc-sections','-T',str(out/'link.ld'),str(out/'start.S'),str(out/'test.cc'),
     '-lc','-lgcc','-o',str(out/'test.elf')]
r=subprocess.run(cmd,capture_output=True,text=True)
(out/'compile.log').write_text(r.stdout+r.stderr)
r.check_returncode()
r=subprocess.run([str(IDE/'qemu/qemu-system-riscv32.exe'),'-M','virt','-cpu','rv32,m=false,a=false,c=false,f=false,d=false',
                  '-nographic','-bios','none','-kernel',str(out/'test.elf')],capture_output=True,text=True,timeout=180)
(out/'test.log').write_text(r.stdout+r.stderr)
if r.returncode or 'PASS RV32I Q31' not in r.stdout: raise AssertionError((r.returncode,r.stdout,r.stderr))
(out/'result.json').write_text(json.dumps(dict(passed=True,rounding_pairs=50100,mul16_pairs=10000,conv_cases=172,
                                             divide_pairs=32320,requant_pairs=10000,
                                             activation_cases=10000,
                                             depthwise_cases=196,cooperative_poll_per_output_row=True,cfu_emulated=True,physical_timing_verified=False),indent=2))
print(r.stdout.strip())
