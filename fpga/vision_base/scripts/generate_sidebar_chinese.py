"""Generate only the Chinese glyphs and fixed texts used by the two-level menu."""
from pathlib import Path
import argparse
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "board/ti60f225_v4/rtl/vision/vision_osd.sv"
FONT = Path("C:/Windows/Fonts/Noto Sans SC Medium (TrueType).otf")
BEGIN = "// BEGIN GENERATED CHINESE SIDEBAR"
END = "// END GENERATED CHINESE SIDEBAR"
TEXTS = dict(
    MENU="菜单", IMAGE="图像", VIEW="视图", TARGET="目标", AI="智能",
    MODE="显示模式", THRESHOLD="边缘阈值", MEDIAN="中值滤波", ZOOM="图像缩放",
    PAN_X="水平平移", PAN_Y="垂直平移", SIZE="输出尺寸", POS_X="水平位置", POS_Y="垂直位置",
    AI_MODE="推理模式", RUN="立即推理", SELFTEST="自检", MODEL="模型",
    CENTER="一键居中", TARGET_ZOOM="放大倍率", FULLVIEW="恢复全幅",
    CAMERA="彩色原图", GRAY="灰度图", SOBEL="SOBEL边缘", SPLIT="左右分屏",
    SOBEL_OVERLAY="SOBEL叠加", CANNY="CANNY边缘", CANNY_OVERLAY="CANNY叠加",
    ON="开启", OFF="关闭", WIDTH="宽", PIXELS="像素", FIXED="固定单帧", AUTO="自动",
    M7="M7几何", TIMES="倍", CONFIRM="K0确认", FINISH="K0完成", ENTER="K0进入", UP="K2上选", DOWN="K3下选",
    CLOSE="K1关闭", BACK="K1返回", CANCEL="K1取消", EDIT="编辑",
    READY="就绪", WAIT="等待", DONE="完成", NO_TARGET="无目标", BUSY="正忙", STALE="已过期", ERROR="出错",
    TEST_NONE="待自检", TEST_WAIT="自检中", TEST_PASS="自检通过", TEST_FAIL="自检失败",
    AI_IDLE="推理空闲", AI_RUN="推理中", AI_DONE="推理完成", AI_ERROR="推理出错", AI_OLD="结果过期",
    MOTION="运动提示", LEFT="向左", RIGHT="向右", MOVE_UP="向上", MOVE_DOWN="向下",
    STILL="静止", UNKNOWN="待判", HOLD="保持",
    CHOOSE="选择目标", CIRCLE="圆形", RECTANGLE="矩形", FACE="人脸",
    FOLLOW="持续跟随", TRAIL="目标轨迹", LOST="目标丢失",
)


def generate(font_path):
    chars = "".join(dict.fromkeys(c for text in TEXTS.values() for c in text if ord(c) >= 128))
    assert len(chars) <= 128 and all(len(text) <= 8 for text in TEXTS.values())
    codes = {c: 128 + i for i, c in enumerate(chars)}
    font = ImageFont.truetype(str(font_path), 15)
    assert font.getname() == ("Noto Sans SC", "Medium"), "Use the documented font/weight"
    lines = [BEGIN, "// Noto Sans SC Medium, 15px in 16x16 cells; regenerate with scripts/generate_sidebar_chinese.py.",
             f"localparam integer CHINESE_GLYPHS={len(chars)};"]
    for name, text in TEXTS.items():
        data = bytes(codes[c] if ord(c) >= 128 else ord(c) for c in text.ljust(8))
        lines.append(f"localparam[63:0] ZH_{name}=64'h{data.hex()}; // {text}")
    lines += ["function automatic[255:0]chinese_glyph(input[6:0]code);", " begin case(code)"]
    patterns = []
    for i, ch in enumerate(chars):
        # Fixed baseline, not a per-glyph fit: radicals keep their relative alignment.
        box = font.getbbox(ch)
        assert box[0] >= 0 and box[2] <= 16 and box[1] >= 5 and box[3] <= 21, (ch, box)
        cell = Image.new("L", (16, 16))
        ImageDraw.Draw(cell).text((0, -5), ch, font=font, fill=255)
        bits = [int(value >= 96) for value in cell.tobytes()]
        assert not any(bits[15::16]), f'Packed font requires its existing blank last column: {ch}'
        pattern = int("".join(map(str, bits)), 2)
        assert pattern and pattern not in patterns, f"Empty or duplicate glyph: {ch}"
        patterns.append(pattern)
        lines.append(f" 7'd{i}:chinese_glyph=256'h{pattern:064x}; // {ch}")
    lines += [" default:chinese_glyph=0;endcase end", "endfunction", END]
    return "\n".join(lines), len(chars)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--font", type=Path, default=FONT)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    generated, count = generate(args.font)
    source = OUTPUT.read_text(encoding="utf-8")
    start = source.index(BEGIN)
    stop = source.index(END, start) + len(END)
    if args.check:
        assert source[start:stop] == generated, "Menu texts/font differ from generator"
    else:
        OUTPUT.write_text(source[:start] + generated + source[stop:], encoding="utf-8")
    print(f"PASS {len(TEXTS)} Chinese menu texts, {count} unique 16x16 glyphs, 8-slot bounds; ASCII font retained")


if __name__ == "__main__":
    main()
