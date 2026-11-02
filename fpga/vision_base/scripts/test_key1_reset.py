"""Exercise the actual top-level PLL/CSI reset expressions, not a copied policy."""
from pathlib import Path
import argparse,json,re,subprocess

ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--output-dir',type=Path,required=True);a=p.parse_args();out=a.output_dir.resolve();out.mkdir(parents=True,exist_ok=True)
source=(ROOT/'board/ti60f225_v4/rtl/ti60f225_oob_top.v').read_text()
names=['w_arstn','pll_inst1_RSTN','USER_PLL_RSTN','mipi_dsi_tx_pll_RSTN','DDR3_PLL_RSTN']
assigns=[]
for name in names:
 matches=re.findall(r'^assign\s+'+name+r'\s*=\s*([^;]+);',source,re.M);assert len(matches)==1,(name,matches)
 assigns.append('assign '+name+' = '+matches[0]+';')
rx=source.split('csi_rx_controller inst_efx_csi2_rx',1)[1]
for port in ['reset_n','reset_byte_HS_n','axi_reset_n']:
 matches=re.findall(r'\.'+port+r'\s*\(([^)]+)\)',rx);assert len(matches)==1,(port,matches)
 names.append('rx_'+port);assigns.append('assign rx_'+port+' = '+matches[0]+';')
decl=re.findall(r'^wire\s+peripheral_reset_n\s*=\s*[^;]+;',source,re.M)
test='''`timescale 1ns/1ps
module tb;
reg i_arstn=1,i_pll_locked=1,pll_locked=1,user_pll_locked=1;
wire NAMES;
DECL
ASSIGNS
task check;begin
 if(!w_arstn||!pll_inst1_RSTN||!USER_PLL_RSTN||!mipi_dsi_tx_pll_RSTN||!DDR3_PLL_RSTN||!rx_reset_n||!rx_reset_byte_HS_n||!rx_axi_reset_n)$fatal(1,"KEY1 reached a functional reset path");
end endtask
initial begin
 #1;check;i_arstn=0;#1;check;#20000000;check;#3000000000;check;i_arstn=1;#1;check;
 pll_locked=0;#1;if(w_arstn)$fatal(1,"PLL-lock loss no longer resets system");
 pll_locked=1;#1;check;
 $display("PASS KEY1 pulse/20ms/3s hold isolated from all7 PLL/CSI reset pins; PLL-lock reset retained");$finish;
end
endmodule
'''.replace('NAMES',','.join(names)).replace('DECL','\n'.join(decl)).replace('ASSIGNS','\n'.join(assigns))
(out/'reset_root.sv').write_text(test)
r=subprocess.run(['C:/iverilog/bin/iverilog.exe','-g2012','-s','tb','-o',str(out/'reset.vvp'),str(out/'reset_root.sv')],capture_output=True);(out/'compile.log').write_bytes(r.stdout+r.stderr);r.check_returncode()
r=subprocess.run(['C:/iverilog/bin/vvp.exe',str(out/'reset.vvp')],capture_output=True);(out/'test.log').write_bytes(r.stdout+r.stderr)
assert r.returncode==0 and b'PASS KEY1' in r.stdout,(r.returncode,r.stdout,r.stderr)
(out/'result.json').write_text(json.dumps(dict(passed=True,source='board/ti60f225_v4/rtl/ti60f225_oob_top.v',functional_reset_pins_checked=7,raw_key1_pulse_and_hold_tested=True,pll_lock_loss_resets=True,scope='Actual reset expressions and connections; not ESD immunity or physical switch measurement'),indent=2));print(r.stdout.decode().strip())
