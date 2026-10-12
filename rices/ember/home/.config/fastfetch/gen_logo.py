import math, os

COLS, ROWS = 40, 20
PW, PH = COLS, ROWS * 2
CX, CY = PW / 2, PH / 2
CORAL = (217, 119, 87)
CORE = (240, 156, 124)
LEN = [1.0, 0.58, 0.82, 0.5, 0.95, 0.62, 0.78, 0.48, 1.0, 0.6, 0.88, 0.54, 0.76, 0.6]
N = len(LEN)
R = 18.6
HALF = 2.3
RAYS = []
for i, ln in enumerate(LEN):
    a = -math.pi / 2 + 2 * math.pi * i / N + 0.15
    RAYS.append((math.cos(a), math.sin(a), R * ln))
SS = 4

def cover(px, py):
    core = ray = 0
    for sy in range(SS):
        for sx in range(SS):
            x = px + (sx + 0.5) / SS - CX
            y = py + (sy + 0.5) / SS - CY
            if x * x + y * y <= 3.4 ** 2:
                core += 1
                continue
            for ux, uy, L in RAYS:
                al = x * ux + y * uy
                if 0 <= al <= L and abs(-x * uy + y * ux) <= HALF * (1 - al / L):
                    ray += 1
                    break
    return core / SS ** 2, ray / SS ** 2

grid = [[None] * PW for _ in range(PH)]
for y in range(PH):
    for x in range(PW):
        c, h = cover(x, y)
        if c + h >= 0.5:
            grid[y][x] = CORE if c >= h else CORAL

out = []
for r in range(ROWS):
    line = []
    for c in range(PW):
        t, b = grid[2 * r][c], grid[2 * r + 1][c]
        if t is None and b is None:
            line.append(" ")
        elif b is None:
            line.append("\033[38;2;%d;%d;%dm\u2580\033[0m" % t)
        elif t is None:
            line.append("\033[38;2;%d;%d;%dm\u2584\033[0m" % b)
        else:
            line.append("\033[38;2;%d;%d;%dm\033[48;2;%d;%d;%dm\u2580\033[0m" % (t + b))
    out.append("".join(line))
open(os.path.expanduser("~/.config/fastfetch/logo.ansi"), "w").write("\n".join(out) + "\n")
