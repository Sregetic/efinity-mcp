"""Minimal MCS-51 (8051) disassembler + assembler used for D7 firmware work."""

SFR = {
    0x80: "P0", 0x81: "SP", 0x82: "DPL", 0x83: "DPH", 0x84: "DPL1", 0x85: "DPH1",
    0x86: "DPS", 0x87: "PCON", 0x88: "TCON", 0x89: "TMOD", 0x8A: "TL0", 0x8B: "TL1",
    0x8C: "TH0", 0x8D: "TH1", 0x8E: "CKCON", 0x90: "P1", 0x98: "SCON", 0x99: "SBUF",
    0xA0: "P2", 0xA8: "IE", 0xB0: "P3", 0xB8: "IP", 0xC0: "P4", 0xC8: "T2CON",
    0xCA: "RCAP2L", 0xCB: "RCAP2H", 0xCC: "TL2", 0xCD: "TH2", 0xD0: "PSW",
    0xE0: "ACC", 0xF0: "B",
}


def direct(a):
    if a in SFR:
        return SFR[a]
    if a < 0x80:
        return "0x%02X" % a
    return "0x%02X" % a


def bitname(b):
    base = (b & 0xF8) if b >= 0x80 else (0x20 + (b >> 3))
    off = b & 7
    if b >= 0x80 and base in SFR:
        return "%s.%d" % (SFR[base], off)
    return "0x%02X.%d" % (base, off)


# fmt placeholders (lowercase, never collide with literal operand text):
#   i=#imm8  d=direct  k=addr16  r=rel8  b=bit
_T = {
    0x00: ("NOP", ""), 0x02: ("LJMP", "k"), 0x03: ("RR", "A"), 0x04: ("INC", "A"),
    0x05: ("INC", "d"), 0x06: ("INC", "@R0"), 0x07: ("INC", "@R1"),
    0x10: ("JBC", "b,r"), 0x12: ("LCALL", "k"), 0x13: ("RRC", "A"), 0x14: ("DEC", "A"),
    0x15: ("DEC", "d"), 0x16: ("DEC", "@R0"), 0x17: ("DEC", "@R1"),
    0x20: ("JB", "b,r"), 0x22: ("RET", ""), 0x23: ("RL", "A"), 0x24: ("ADD", "A,#i"),
    0x25: ("ADD", "A,d"), 0x26: ("ADD", "A,@R0"), 0x27: ("ADD", "A,@R1"),
    0x30: ("JNB", "b,r"), 0x32: ("RETI", ""), 0x33: ("RLC", "A"), 0x34: ("ADDC", "A,#i"),
    0x35: ("ADDC", "A,d"), 0x36: ("ADDC", "A,@R0"), 0x37: ("ADDC", "A,@R1"),
    0x40: ("JC", "r"), 0x42: ("ORL", "d,A"), 0x43: ("ORL", "d,#i"), 0x44: ("ORL", "A,#i"),
    0x45: ("ORL", "A,d"), 0x46: ("ORL", "A,@R0"), 0x47: ("ORL", "A,@R1"),
    0x50: ("JNC", "r"), 0x52: ("ANL", "d,A"), 0x53: ("ANL", "d,#i"), 0x54: ("ANL", "A,#i"),
    0x55: ("ANL", "A,d"), 0x56: ("ANL", "A,@R0"), 0x57: ("ANL", "A,@R1"),
    0x60: ("JZ", "r"), 0x62: ("XRL", "d,A"), 0x63: ("XRL", "d,#i"), 0x64: ("XRL", "A,#i"),
    0x65: ("XRL", "A,d"), 0x66: ("XRL", "A,@R0"), 0x67: ("XRL", "A,@R1"),
    0x70: ("JNZ", "r"), 0x72: ("ORL", "C,b"), 0x73: ("JMP", "@A+DPTR"),
    0x74: ("MOV", "A,#i"), 0x75: ("MOV", "d,#i"), 0x76: ("MOV", "@R0,#i"), 0x77: ("MOV", "@R1,#i"),
    0x80: ("SJMP", "r"), 0x82: ("ANL", "C,b"), 0x83: ("MOVC", "A,@A+PC"), 0x84: ("DIV", "AB"),
    0x85: ("MOV", "DD"), 0x86: ("MOV", "d,@R0"), 0x87: ("MOV", "d,@R1"),
    0x90: ("MOV", "DPTR,#k"), 0x92: ("MOV", "b,C"), 0x93: ("MOVC", "A,@A+DPTR"),
    0x94: ("SUBB", "A,#i"), 0x95: ("SUBB", "A,d"), 0x96: ("SUBB", "A,@R0"), 0x97: ("SUBB", "A,@R1"),
    0xA0: ("ORL", "C,/b"), 0xA2: ("MOV", "C,b"), 0xA3: ("INC", "DPTR"), 0xA4: ("MUL", "AB"),
    0xA5: ("?A5", ""), 0xA6: ("MOV", "@R0,d"), 0xA7: ("MOV", "@R1,d"),
    0xB0: ("ANL", "C,/b"), 0xB2: ("CPL", "b"), 0xB3: ("CPL", "C"), 0xB4: ("CJNE", "A,#i,r"),
    0xB5: ("CJNE", "A,d,r"), 0xB6: ("CJNE", "@R0,#i,r"), 0xB7: ("CJNE", "@R1,#i,r"),
    0xC0: ("PUSH", "d"), 0xC2: ("CLR", "b"), 0xC3: ("CLR", "C"), 0xC4: ("SWAP", "A"),
    0xC5: ("XCH", "A,d"), 0xC6: ("XCH", "A,@R0"), 0xC7: ("XCH", "A,@R1"),
    0xD0: ("POP", "d"), 0xD2: ("SETB", "b"), 0xD3: ("SETB", "C"), 0xD4: ("DA", "A"),
    0xD5: ("DJNZ", "d,r"), 0xD6: ("XCHD", "A,@R0"), 0xD7: ("XCHD", "A,@R1"),
    0xE0: ("MOVX", "A,@DPTR"), 0xE2: ("MOVX", "A,@R0"), 0xE3: ("MOVX", "A,@R1"),
    0xE4: ("CLR", "A"), 0xE5: ("MOV", "A,d"), 0xE6: ("MOV", "A,@R0"), 0xE7: ("MOV", "A,@R1"),
    0xF0: ("MOVX", "@DPTR,A"), 0xF2: ("MOVX", "@R0,A"), 0xF3: ("MOVX", "@R1,A"),
    0xF4: ("CPL", "A"), 0xF5: ("MOV", "d,A"), 0xF6: ("MOV", "@R0,A"), 0xF7: ("MOV", "@R1,A"),
}

# register-form families: base opcode -> (mnemonic, "before Rn", "after Rn")
_REG = {
    0x08: ("INC", "", ""), 0x18: ("DEC", "", ""), 0x28: ("ADD", "A,", ""),
    0x38: ("ADDC", "A,", ""), 0x48: ("ORL", "A,", ""), 0x58: ("ANL", "A,", ""),
    0x68: ("XRL", "A,", ""), 0x78: ("MOV", "", ",#i"), 0x88: ("MOV", "d,", ""),
    0x98: ("SUBB", "A,", ""), 0xA8: ("MOV", "", ",d"), 0xB8: ("CJNE", "", ",#i,r"),
    0xC8: ("XCH", "A,", ""), 0xD8: ("DJNZ", "", ",r"), 0xE8: ("MOV", "A,", ""),
    0xF8: ("MOV", "", ",A"),
}


def _len(op):
    if (op & 0x1F) in (0x01, 0x11):
        return 2
    hi, lo = op & 0xF8, op & 0x07
    if hi in _REG:
        _m, pre, post = _REG[hi]
        return 1 + post.count("i") + post.count("r") + post.count("d") + pre.count("d")
    if op in _T:
        f = _T[op][1]
        if f == "DD":
            return 3
        return 1 + f.count("i") + f.count("r") + f.count("b") + f.count("d") + 2 * f.count("k")
    return 1


def disasm_one(mem, pc, base=0):
    """Return (text, length). mem is bytes, pc is index; base is the address of mem[0]."""
    op = mem[pc]
    addr = base + pc

    def b(i):
        return mem[pc + i]

    if (op & 0x1F) == 0x01 or (op & 0x1F) == 0x11:
        mn = "AJMP" if (op & 0x1F) == 0x01 else "ACALL"
        tgt = ((addr + 2) & 0xF800) | ((op & 0xE0) << 3) | b(1)
        return "%s 0x%04X" % (mn, tgt), 2

    hi, lo = op & 0xF8, op & 0x07
    if hi in _REG:
        mn, pre, post = _REG[hi]
        r = "R%d" % lo
        n = 1
        out = pre + r
        if post.startswith(",#i"):
            out += ",#0x%02X" % b(1)
            n = 2
            post = post[3:]
        elif post.startswith(",d"):
            out += "," + direct(b(1))
            n = 2
            post = post[2:]
        elif post == ",A":
            out += ",A"
        if pre == "d,":
            out = direct(b(1)) + "," + r
            n = 2
        if post.startswith(",r"):
            rel = b(n)
            n += 1
            out += ",0x%04X" % ((addr + n + (rel - 256 if rel > 127 else rel)) & 0xFFFF)
        return ("%-5s %s" % (mn, out)).rstrip(), n

    if op not in _T:
        return "DB   0x%02X" % op, 1

    mn, f = _T[op]
    if f == "":
        return mn, 1
    if f == "DD":
        return "%-5s %s,%s" % (mn, direct(b(2)), direct(b(1))), 3

    n = 1
    out = ""
    i = 0
    while i < len(f):
        c = f[i]
        if c == "i":
            out += "0x%02X" % b(n)
            n += 1
        elif c == "d":
            out += direct(b(n))
            n += 1
        elif c == "b":
            out += bitname(b(n))
            n += 1
        elif c == "k":
            out += "0x%04X" % ((b(n) << 8) | b(n + 1))
            n += 2
        elif c == "r":
            rel = b(n)
            n += 1
            out += "0x%04X" % ((addr + n + (rel - 256 if rel > 127 else rel)) & 0xFFFF)
        else:
            out += c
        i += 1
    return "%-5s %s" % (mn, out), n


def disasm(mem, start=0, end=None, base=0):
    end = len(mem) if end is None else end
    pc = start
    out = []
    while pc < end:
        try:
            txt, n = disasm_one(mem, pc, base)
        except IndexError:
            break
        raw = " ".join("%02x" % x for x in mem[pc:pc + n])
        out.append("%04X  %-11s %s" % (base + pc, raw, txt))
        pc += n
    return "\n".join(out)


# ---------------------------------------------------------------- assembler
def asm(src, org=0):
    """Two-pass assembler for the small subset used by the D7 hooks."""
    lines = []
    for raw in src.splitlines():
        line = raw.split(";")[0].strip()
        if line:
            lines.append(line)

    # Pre-seed every label so the first pass can size forward references.
    labels = {}
    for line in lines:
        if line.endswith(":"):
            labels[line[:-1]] = org
        elif ":" in line and not line.split(":")[0].strip().startswith("0x"):
            labels[line.split(":")[0].strip()] = org

    for _pass in range(4):
        # Labels start out pointing at org, so a branch can look wildly out of
        # range until they settle.  Only the last pass is allowed to complain.
        strict = _pass == 3
        out = bytearray()
        pc = org
        for line in lines:
            if line.endswith(":"):
                labels[line[:-1]] = pc
                continue
            if ":" in line and not line.split(":")[0].strip().startswith("0x"):
                lab, rest = line.split(":", 1)
                labels[lab.strip()] = pc
                line = rest.strip()
                if not line:
                    continue
            enc = _asm_one(line, pc, labels, strict)
            out += enc
            pc += len(enc)
    return bytes(out)


def _num(tok, labels):
    tok = tok.strip()
    if tok in labels:
        return labels[tok]
    if tok.lower().startswith("0x"):
        return int(tok, 16)
    if tok.endswith("h") or tok.endswith("H"):
        return int(tok[:-1], 16)
    return int(tok, 0)


_RN = {"R%d" % i: i for i in range(8)}


def _asm_one(line, pc, labels, strict=True):
    parts = line.replace("\t", " ").split(None, 1)
    mn = parts[0].upper()
    ops = [o.strip() for o in parts[1].split(",")] if len(parts) > 1 else []
    U = [o.upper() for o in ops]

    def imm(o):
        return _num(o.lstrip("#"), labels) & 0xFF

    def rel(o):
        t = _num(o, labels)
        d = t - (pc + _asm_len(mn, ops))
        assert not strict or -128 <= d <= 127, "rel out of range: %s" % line
        return d & 0xFF

    if mn == "NOP":
        return b"\x00"
    if mn == "RET":
        return b"\x22"
    if mn == "RETI":
        return b"\x32"
    if mn == "CLR" and U == ["A"]:
        return b"\xe4"
    if mn == "CLR" and U == ["C"]:
        return b"\xc3"
    if mn == "SETB" and U == ["C"]:
        return b"\xd3"
    if mn == "INC" and U == ["A"]:
        return b"\x04"
    if mn == "INC" and U == ["DPTR"]:
        return b"\xa3"
    if mn == "LJMP":
        a = _num(ops[0], labels)
        return bytes([0x02, a >> 8, a & 0xFF])
    if mn == "LCALL":
        a = _num(ops[0], labels)
        return bytes([0x12, a >> 8, a & 0xFF])
    if mn == "AJMP" or mn == "ACALL":
        a = _num(ops[0], labels)
        base = 0x01 if mn == "AJMP" else 0x11
        assert (a & 0xF800) == ((pc + 2) & 0xF800), "AJMP page: %s" % line
        return bytes([base | ((a >> 3) & 0xE0), a & 0xFF])
    if mn == "SJMP":
        return bytes([0x80, rel(ops[0])])
    if mn in ("JZ", "JNZ", "JC", "JNC"):
        op = {"JZ": 0x60, "JNZ": 0x70, "JC": 0x40, "JNC": 0x50}[mn]
        return bytes([op, rel(ops[0])])
    if mn == "MOV":
        d, s = U[0], U[1] if len(U) > 1 else ""
        if d == "DPTR":
            a = _num(ops[1].lstrip("#"), labels)
            return bytes([0x90, a >> 8, a & 0xFF])
        if d == "A" and s.startswith("#"):
            return bytes([0x74, imm(ops[1])])
        if d == "A" and s in _RN:
            return bytes([0xE8 | _RN[s]])
        if d in _RN and s.startswith("#"):
            return bytes([0x78 | _RN[d], imm(ops[1])])
        if d in _RN and s == "A":
            return bytes([0xF8 | _RN[d]])
        if d == "A" and s == "@R0":
            return b"\xe6"
        if d == "A" and s == "@R1":
            return b"\xe7"
        if d == "@R0" and s == "A":
            return b"\xf6"
        if d == "@R1" and s == "A":
            return b"\xf7"
        if d == "A":
            return bytes([0xE5, _num(ops[1], labels) & 0xFF])
        if s == "A":
            return bytes([0xF5, _num(ops[0], labels) & 0xFF])
        if s.startswith("#"):
            return bytes([0x75, _num(ops[0], labels) & 0xFF, imm(ops[1])])
        if d in _RN:
            return bytes([0xA8 | _RN[d], _num(ops[1], labels) & 0xFF])
    if mn == "MOVX":
        if U[0] == "A" and U[1] == "@DPTR":
            return b"\xe0"
        if U[0] == "@DPTR" and U[1] == "A":
            return b"\xf0"
        if U[0] == "A" and U[1] == "@R0":
            return b"\xe2"
        if U[0] == "A" and U[1] == "@R1":
            return b"\xe3"
        if U[0] == "@R0" and U[1] == "A":
            return b"\xf2"
        if U[0] == "@R1" and U[1] == "A":
            return b"\xf3"
    if mn == "MOVC":
        if U[1] == "@A+DPTR":
            return b"\x93"
        return b"\x83"
    if mn == "PUSH":
        return bytes([0xC0, _num(ops[0], labels) & 0xFF])
    if mn == "POP":
        return bytes([0xD0, _num(ops[0], labels) & 0xFF])
    if mn == "CJNE":
        if U[0] == "A" and ops[1].startswith("#"):
            return bytes([0xB4, imm(ops[1]), rel(ops[2])])
        if U[0] in _RN and ops[1].startswith("#"):
            return bytes([0xB8 | _RN[U[0]], imm(ops[1]), rel(ops[2])])
        if U[0] == "A":
            return bytes([0xB5, _num(ops[1], labels) & 0xFF, rel(ops[2])])
    if mn == "DJNZ":
        if U[0] in _RN:
            return bytes([0xD8 | _RN[U[0]], rel(ops[1])])
        return bytes([0xD5, _num(ops[0], labels) & 0xFF, rel(ops[1])])
    if mn == "ANL" and U[0] == "A" and ops[1].startswith("#"):
        return bytes([0x54, imm(ops[1])])
    if mn == "ORL" and U[0] == "A" and ops[1].startswith("#"):
        return bytes([0x44, imm(ops[1])])
    if mn == "XRL" and U[0] == "A" and ops[1].startswith("#"):
        return bytes([0x64, imm(ops[1])])
    if mn == "ADD" and U[0] == "A" and ops[1].startswith("#"):
        return bytes([0x24, imm(ops[1])])
    if mn == "DB":
        return bytes(_num(o, labels) & 0xFF for o in ops)
    raise ValueError("cannot assemble: %s" % line)


def _asm_len(mn, ops):
    one = {"NOP", "RET", "RETI"}
    if mn in one:
        return 1
    if mn in ("SJMP", "JZ", "JNZ", "JC", "JNC", "AJMP", "ACALL"):
        return 2
    if mn in ("LJMP", "LCALL", "CJNE"):
        return 3
    if mn == "DJNZ":
        return 2 if ops[0].upper() in _RN else 3
    return 3


if __name__ == "__main__":
    import sys

    data = open(sys.argv[1], "rb").read()
    base = int(sys.argv[2], 16) if len(sys.argv) > 2 else 0
    print(disasm(data, base=base))
