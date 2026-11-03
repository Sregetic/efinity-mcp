"""Exercise the actual build profile gate and top-level reset logic, without a board."""
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import zipfile

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'results/sc2210_adapter_fix_20261014'
OUT.mkdir(exist_ok=True)
PS='C:/Program Files/PowerShell/7/pwsh.exe'
IVERILOG='C:/iverilog/bin/iverilog.exe'
VVP='C:/iverilog/bin/vvp.exe'
profiles=ROOT/'board/ti60f225_v4/sensors'
top=(ROOT/'board/ti60f225_v4/rtl/ti60f225_oob_top.v').read_text()
reset=re.search(r'localparam I2C_RESET_CYCLES.*?wire i2c_rst_n = .*?;',top,re.S)[0]
output=re.search(r'assign o_cam_rst_p = .*?;',top)[0]
gate=(ROOT/'scripts/synthesize.ps1').read_text().split('$started=',1)[0]
gate=gate.replace('$root=Split-Path -Parent $PSScriptRoot',"$root='"+str(ROOT)+"'")
header=ROOT/'board/ti60f225_v4/rtl/vision_sensor_config.vh'
assert 'VISION_SENSOR_DPHY_CLOCK_MODE' in (ROOT/'board/ti60f225_v4/rtl/csi_rx_controller.sv').read_text()
original=header.read_bytes()
report=[]

with tempfile.TemporaryDirectory() as tmp:
 tmp=Path(tmp)
 # Execute the production pre-build block; it emits no hardware command or source edits.
 runner=tmp/'gate.ps1'
 runner.write_text("param([string]$Profile)\n$PSScriptRoot='"+str(ROOT/'scripts')+"'\n$build=[scriptblock]::Create(@'\n"+
                   gate+"Write-Output $sensorHeader\n'@)\n& $build -Top board -Sensor sc2210 -SensorProfile $Profile\n")
 for name in ['sc2210_1080p30_2lane_24mhz_reference','sc2210_1080p30_2lane_27mhz_ovs']:
  p=profiles/(name+'.json');data=json.loads(p.read_text());table=profiles/data['init_file']
  r=subprocess.run([PS,'-NoProfile','-File',str(runner),'-Profile',str(p)],capture_output=True,text=True)
  assert r.returncode==0,r.stderr
  assert f'`define VISION_SENSOR_DPHY_CLOCK_MODE "{data["mipi_clock_mode"]}"' in r.stdout
  assert f'`define VISION_SENSOR_BYTECLK_MHZ {data["hs_byteclk_mhz"]}' in r.stdout
  (OUT/(name+'.vh')).write_text(r.stdout)
  if name.endswith('_ovs'):
   with zipfile.ZipFile(data['source_archive']) as z:source=z.read(data['source_archive_entry']).decode('utf-8-sig')
   body=re.split(r'^\s*\[',source.split('[paralist]',1)[1],maxsplit=1,flags=re.M)[0]
   writes=[tuple(int(x,16) for x in pair) for pair in re.findall(r'^\s*0x([0-9a-fA-F]{4}),\s*0x([0-9a-fA-F]{2}),\s*$',body,re.M)]
   assert [int(w,16) for w in table.read_text().splitlines()]==[(a<<9)|(v<<1) for a,v in writes]
   assert len(writes)==251 and data['mipi_clock_mode']=='Continuous' and data['hs_byteclk_mhz']==47.25
  shutil.copyfile(table,tmp/table.name)
  wrong=dict(data,mipi_clock_mode='Continuous' if data['mipi_clock_mode']=='Discontinuous' else 'Discontinuous')
  bad=tmp/(name+'.json');bad.write_text(json.dumps(wrong))
  rbad=subprocess.run([PS,'-NoProfile','-File',str(runner),'-Profile',str(bad)],capture_output=True,text=True)
  assert rbad.returncode!=0 and 'MIPI clock mode mismatch' in rbad.stderr,rbad.stderr
  rom=ROOT/'board/ti60f225_v4/rtl/cam_i2c_ctrl/i2c'
  exe=tmp/'boot.vvp'
  subprocess.run([IVERILOG,'-g2012','-s','tb','-Ptb.N='+str(data['init_length']),'-Ptb.INIT_FILE="'+str(table).replace('\\','/')+'"',
                  '-o',str(exe),str(ROOT/'sim/vision/tb_sensor_boot.sv'),str(rom/'i2c_master_reg_set.v'),str(rom/'i2c_master_reg_rom.v')],check=True,cwd=ROOT)
  result=subprocess.run([VVP,str(exe)],check=True,capture_output=True,text=True,cwd=ROOT)
  (OUT/(name+'.boot.log')).write_text(result.stdout)
  report.append(dict(profile=name,gate=True,wrong_clock_rejected=True,boot_entries=data['init_length'],boot_pass=True))
 for sc,cycles in [(0,4096),(1,25000)]:
  tb=f'''`timescale 1ns/1ps
`define VISION_SENSOR_SC2210 {sc}
module tb;
reg CLK_5M=0,w_arstn=0;wire o_cam_rst_p;
always #100 CLK_5M=~CLK_5M;
{reset}
{output}
integer i,j;
initial begin
 repeat(2) @(negedge CLK_5M);
 if(o_cam_rst_p!=={1-sc} || i2c_rst_n!==0) $fatal(1,"reset polarity");
 for(j=0;j<2;j=j+1) begin
  w_arstn=1;#1;if(o_cam_rst_p!=={sc}) $fatal(1,"run polarity");
  for(i=1;i<={cycles};i=i+1) begin
   @(posedge CLK_5M);#1;
   if(i2c_rst_n!==(i=={cycles})) $fatal(1,"release count %0d",i);
  end
  repeat(100) @(negedge CLK_5M);
  if(i2c_rst_cnt!={cycles} || !i2c_rst_n) $fatal(1,"saturation");
  #20;w_arstn=0;#1;if(i2c_rst_cnt!=0 || i2c_rst_n) $fatal(1,"asynchronous reset");
  @(negedge CLK_5M);
 end
 $display("PASS sensor {sc}: {cycles} cycles, polarity, saturation, repeated reset");$finish;
end
endmodule
'''
  file=tmp/'reset.sv';file.write_text(tb);exe=tmp/'reset.vvp'
  subprocess.run([IVERILOG,'-g2012','-s','tb','-o',str(exe),str(file)],check=True)
  result=subprocess.run([VVP,str(exe)],check=True,capture_output=True,text=True)
  (OUT/f'reset_sc{sc}.log').write_text(result.stdout)
assert header.read_bytes()==original,'default header changed by profile gate test'
(OUT/'verification.json').write_text(json.dumps(dict(passed=True,profiles=report,reset_sc431_cycles=4096,
                                                   reset_sc2210_cycles=25000,default_unchanged=True,hardware_tested=False),indent=2))
print('PASS both profile gates/boot tables and reset branches; wrong clock profiles rejected')
