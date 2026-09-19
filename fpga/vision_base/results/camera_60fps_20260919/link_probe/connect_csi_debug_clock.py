from pathlib import Path
p=Path('board/ti60f225_v4/rtl/ti60f225_oob_top.v');s=p.read_text(encoding='utf-8')
import re
s,n=re.subn(r'\.axi_clk\s*\(1\x27b0\)', '.axi_clk(core_clk)',s,count=1);assert n==1
s,n=re.subn(r'\.axi_reset_n\s*\(1\x27b0\)', '.axi_reset_n(i_arstn)',s,count=1);assert n==1
s,n=re.subn(r'\.u_dly_enable_D\s*\(\)', ".u_dly_enable_D(4'b0)",s,count=1);assert n==1
s,n=re.subn(r'\.u_dly_inc_D\s*\(\)', ".u_dly_inc_D(4'b0)",s,count=1);assert n==1
p.write_text(s,encoding='utf-8')
