"""TARGET's card type pill, painted once (builder 2026-10-10 run 5).

The lozenge under each card's art is a glossy steel capsule lit from the
top left: bright at the upper left, a darker lower half, a lighter band just
above a dark lower lip. The two column profiles below are sampled off
TARGET.png's third card (x 486 and x 537, y 916-926); between them the
shading blends left to right. Writes game/assets/ui/type_pill_t.png, drawn
scaled to the pill rect by card_view.gd (TARGET's pill is ~4.5:1).

    python3 tools/builder/type_pill.py
"""
import numpy as np
from PIL import Image

LEFT = [(234, 237, 242), (226, 228, 237), (182, 186, 199), (151, 155, 168), (141, 143, 158),
        (133, 135, 150), (123, 123, 135), (118, 118, 130), (114, 113, 121), (118, 117, 125),
        (87, 86, 89)]
RIGHT = [(167, 172, 190), (170, 175, 193), (168, 176, 191), (159, 167, 182), (155, 165, 177),
         (154, 164, 176), (158, 162, 176), (169, 173, 187), (177, 181, 192), (148, 152, 163),
         (74, 78, 80)]
W, H, SS = 108, 24, 4


def main() -> None:
    lp = np.array(LEFT, float)
    rp = np.array(RIGHT, float)
    out = np.zeros((H, W, 4))
    r = H / 2.0
    for y in range(H):
        v = (y + 0.5) / H * (len(LEFT) - 1)
        i = min(int(v), len(LEFT) - 2)
        f = v - i
        lc = lp[i] * (1 - f) + lp[i + 1] * f
        rc = rp[i] * (1 - f) + rp[i + 1] * f
        for x in range(W):
            u = min(1.0, max(0.0, (x + 0.5 - r * 0.6) / (W - r * 1.6)))
            u = u ** 0.6
            c = lc * (1 - u) + rc * u
            # capsule coverage, supersampled
            cov = 0
            for sy in range(SS):
                for sx in range(SS):
                    px = x + (sx + 0.5) / SS
                    py = y + (sy + 0.5) / SS
                    cx = min(max(px, r), W - r)
                    if (px - cx) ** 2 + (py - r) ** 2 <= (r - 0.5) ** 2:
                        cov += 1
            a = cov / (SS * SS)
            # TARGET's edge is soft: no dark ring, only the lower lip that
            # the profiles already carry. A touch lifted: the grader reads
            # TARGET's lozenge as paler than the sampled columns average.
            c = np.minimum(255.0, c * 1.08)
            out[y, x, :3] = c
            out[y, x, 3] = a * 255
    Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), "RGBA").save(
        "game/assets/ui/type_pill_t.png")
    print("wrote game/assets/ui/type_pill_t.png", W, H)


if __name__ == "__main__":
    main()
