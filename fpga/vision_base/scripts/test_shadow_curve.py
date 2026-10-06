"""Run directly: weak-light tone lift keeps black, white, monotonicity and gain ceiling."""
from pathlib import Path

root=Path(__file__).resolve().parents[1]
directory=root/'board/ti60f225_v4/rtl/gamma_conrrection'
shadow=[int(v,16) for v in (directory/'chroma_shadow_gain_q8.mem').read_text().split()]
normal=[int(v,16) for v in (directory/'chroma_tone_gain_q8.mem').read_text().split()]
assert len(shadow)==len(normal)==256
peak=[min(255,(v*shadow[v]+128)>>8) for v in range(256)]
assert peak[0]==0 and peak[255]==255 and max(shadow)<=9*256
assert all(a<=b for a,b in zip(peak,peak[1:]))
assert all(peak[v]>=min(255,(v*normal[v]+128)>>8) for v in range(256))
assert peak[8]>=64 and peak[16]>=100
print('PASS weak-light tone: 256 peaks monotonic, black0, white255, gain<=9x, normal-light curve retained')
