"""Check page-dispatch equivalence; payload expressions must remain identical."""
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / 'results/a_controls_quality_20261009/diag_priority_before.txt'
SOURCE = ROOT / 'board/ti60f225_v4/rtl/ti60f225_oob_top.v'


def main():
    old = REFERENCE.read_text(encoding='utf-8')
    top = SOURCE.read_text(encoding='utf-8')
    start = top.index('  // Page addresses are disjoint;')
    new = top[start:top.index('\n end\n else if(jtag_diag_SHIFT)', start)]
    payloads = re.findall(r'diag_shift<=(.*?);', old)
    assert set(payloads) == set(re.findall(r'diag_shift<=(.*?);', new))
    ids = {payload: index for index, payload in enumerate(dict.fromkeys(payloads))}

    def dispatch(text, output):
        return re.sub(r'diag_shift<=(.*?);',
                      lambda m: f'{output}=6\'d{ids[m[1]]};', text)

    bench = '''module tb;
reg [5:0] feature_diag_page;
reg fly_profile_view,fly_feature_view,x3_profile_view,probe_csi_view;
integer IMAGE_DEBUG,SAPPHIRE_ENABLE,DISPLAY_LATENCY_PROBE;
reg [5:0] a,b;
integer i,j,k,f,p,n=0;
always @* begin
''' + dispatch(old, 'a') + '\nend\nalways @* begin\n' + dispatch(new, 'b') + '''
end
initial begin
 for(i=0;i<3;i=i+1) for(j=0;j<2;j=j+1) for(k=0;k<2;k=k+1)
 for(f=0;f<16;f=f+1) for(p=0;p<64;p=p+1) begin
  IMAGE_DEBUG=i;SAPPHIRE_ENABLE=j;DISPLAY_LATENCY_PROBE=k;
  {fly_profile_view,fly_feature_view,x3_profile_view,probe_csi_view}=f;
  feature_diag_page=p;#1;
  if(a!==b) $fatal(1,"page=%0d image=%0d soc=%0d latency=%0d flags=%0d",p,i,j,k,f);
  n=n+1;
 end
 $display("PASS diagnostic dispatch: %0d legal states; payloads unchanged",n);
end
endmodule
'''
    with tempfile.TemporaryDirectory(prefix='vision_diag_') as directory:
        sv = Path(directory) / 'tb.sv'
        vvp = Path(directory) / 'tb.vvp'
        sv.write_text(bench, encoding='utf-8')
        subprocess.run(['iverilog', '-g2012', '-o', str(vvp), str(sv)], check=True)
        subprocess.run(['vvp', str(vvp)], check=True)


if __name__ == '__main__':
    main()
