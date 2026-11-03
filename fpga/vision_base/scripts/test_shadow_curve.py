"""Normal-light black toe and weak-light lift share the existing gain ROM."""
from pathlib import Path

root=Path(__file__).resolve().parents[1]
directory=root/'board/ti60f225_v4/rtl/gamma_conrrection'
shadow=[int(v,16) for v in (directory/'chroma_shadow_gain_q8.mem').read_text().split()]
normal=[int(v,16) for v in (directory/'chroma_tone_gain_q8.mem').read_text().split()]
assert len(shadow)==len(normal)==256
normal_peak=[min(255,(v*normal[v]+128)>>8) for v in range(256)]
assert normal_peak[0]==0 and normal_peak[255]==255 and max(normal)<=4*256
assert all(a<=b for a,b in zip(normal_peak,normal_peak[1:]))
def luma_tone(rgb):
    gain=normal[max(rgb)]
    return sum(w*((v*gain+128)>>8) for w,v in zip((.2126,.7152,.0722),rgb))
# Same frozen ceiling frame: a dark fixture should not turn into a gray patch.
light=luma_tone((49,62,60));dark=luma_tone((10,14,14))
assert 125<=light<=129 and (light-dark)/(light+dark)>.52, (light,dark)
peak=[min(255,(v*shadow[v]+128)>>8) for v in range(256)]
assert peak[0]==0 and peak[255]==255 and max(shadow)<=9*256
assert all(a<=b for a,b in zip(peak,peak[1:]))
assert all(peak[v]>=min(255,(v*normal[v]+128)>>8) for v in range(256))
assert peak[8]>=64 and peak[16]>=100
print('PASS tone: normal black-toe contrast, two monotonic256-entry curves, black0, white255, weak-light gain<=9x')
