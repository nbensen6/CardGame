"""Draw the card frame TARGET.png shows (Nick, 2026-10-08: "build the concept
1:1"), replacing the carved-stone A1 frame.

    python3 tools/cardframe_target.py

TARGET's card, measured on its Scramble card (TARGET px, ~138 x 205):
  - a thin cream-gold outer line (~(226,228,170)) and inside it a narrow
    green band with darker links (~(97,133,87)), the edge of every card;
  - a dark grey-violet name band across the top (~(55,52,62));
  - the art straight under it, edge to edge inside the border, down to about
    0.62 of the card, with no frame of its own;
  - the type pill on the art's lower edge, the rules below on dark olive
    (~(36,39,31)).

Writes game/assets/ui/card_frame_t_base.png (opaque frame + body, drawn under
the art) and card_frame_t_glow.png (fully clear: TARGET's card carries no
glow), both at the A1 source size so card_view.gd's nine-patch margins hold.
"""
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "game/assets/ui"
W, H = 690, 984
RADIUS = 26
CREAM = (226, 226, 168)
GREEN = (92, 128, 82)
LINK = (40, 64, 42)
DARK_LINE = (18, 20, 16)
BAND = (55, 52, 62)
BODY = (36, 39, 31)
BAND_BOTTOM = 0.132      # of H: where the name band ends and the art starts
ART_BOTTOM = 0.588        # of H: where the art ends and the rules box starts
OUTER = 5                # cream line, px
GREEN_W = 11             # green band, px
INNER = 3                # dark line inside it, px


def rounded(draw, inset, fill):
    draw.rounded_rectangle((inset, inset, W - 1 - inset, H - 1 - inset),
                           radius=max(2, RADIUS - inset), fill=fill)


# TARGET's edge, outside in, measured across its Leap and Tongue Snap cards'
# sides at 1024 (1 TARGET-1024 px = ~5.3 source px; builder 2026-10-09 run
# 14): a thin dark rim, a cream line, a dark slate band ~6 px wide, then a
# dull-gold line with a green-grey line inside it, then a dark keyline round
# the art window. The name band covers the band along the top, so the top
# edge reads as the cream line alone, as in TARGET.
EDGE = [((14, 10, 6), 3), ((240, 240, 188), 12), ((14, 16, 18), 31),
        ((156, 172, 96), 10), ((72, 132, 102), 5), ((16, 22, 18), 3)]
# The beads: TARGET's inner gold line is dotted, bright yellow beads with
# darker olive-gold gaps (the "trim" seen at 720 down every card's sides).
BEAD = (250, 238, 140)   # the beads: yellow-cream dots on TARGET's green inner line
BAND_DASH = (58, 92, 56)   # faint green dashes inside the dark band
BAND_DASH_W = 4
BAND_DASH_ON, BAND_DASH_PERIOD = 10, 18
BEAD_W = 10               # px across: the gold line's width
BEAD_ON, BEAD_PERIOD = 13, 22   # px along: ~3 screen px a bead, so the dots survive the hand's 0.13 scale (run 16)
CHEV_X = (120, 200)      # px: the bevel's back edge (under the gem) and its apex
CHEV_LIT = (68, 65, 80)
CHEV_DARK = (42, 39, 50)
BAND_FROM = 11           # the name band starts inside the cream line, px
ART_BG = (10, 11, 9)     # TARGET's art window behind an icon: near-black


def build():
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    inset = 0
    for col, w in EDGE:
        rounded(d, inset, col + (255,))
        inset += w
    rounded(d, inset, BODY + (255,))
    a = np.asarray(im).copy()
    top = inset
    # beads in the band: the band runs from b0 to b1 px in from the edge
    b0 = EDGE[0][1] + EDGE[1][1] + EDGE[2][1]
    lo, hi = b0, b0 + BEAD_W
    on = (np.arange(H) % BEAD_PERIOD) < BEAD_ON
    for x in list(range(lo, hi)) + list(range(W - hi, W - lo)):
        rows = np.nonzero(on)[0]
        rows = rows[(rows > RADIUS) & (rows < H - RADIUS)]
        a[rows, x, :3] = BEAD
    # and TARGET's fainter green dashes down the middle of the dark band
    m0 = EDGE[0][1] + EDGE[1][1] + EDGE[2][1] // 2 - BAND_DASH_W // 2
    dash = (np.arange(H) % BAND_DASH_PERIOD) < BAND_DASH_ON
    rows = np.nonzero(dash)[0]
    rows = rows[(rows > RADIUS) & (rows < H - RADIUS)]
    for x in list(range(m0, m0 + BAND_DASH_W)) + list(range(W - m0 - BAND_DASH_W, W - m0)):
        a[rows, x, :3] = BAND_DASH
    onx = (np.arange(W) % BEAD_PERIOD) < BEAD_ON
    for y in range(H - hi, H - lo):
        cols = np.nonzero(onx)[0]
        cols = cols[(cols > RADIUS) & (cols < W - RADIUS)]
        a[y, cols, :3] = BEAD
    bb = int(BAND_BOTTOM * H)
    a[BAND_FROM:bb, BAND_FROM:W - BAND_FROM, :3] = BAND
    a[bb - 3:bb, BAND_FROM:W - BAND_FROM, :3] = (34, 32, 40)
    # TARGET's name band is bevelled into a ">" just right of the cost gem:
    # a lit upper facet and a darker lower one, apex pointing at the name.
    mid = (BAND_FROM + bb) // 2
    x0, x1 = CHEV_X
    for y in range(BAND_FROM, bb - 3):
        k = abs(y - mid) / max(1, mid - BAND_FROM)
        xe = int(x1 - (x1 - x0) * k)
        if xe > x0:
            a[y, x0:xe, :3] = CHEV_LIT if y < mid else CHEV_DARK
    # The art window, behind the art: an icon's clear ground shows black.
    ab = int(ART_BOTTOM * H)
    a[bb:ab, top:W - top, :3] = ART_BG
    # The window is see-through: card_view.gd draws the art (on a black
    # ground) UNDER this frame, so the frame's filtered edge overlaps the
    # art's and a tilted card's window edge is smooth, not a staircase
    # (run 14).
    a[bb:ab, top:W - top, 3] = 0
    Image.fromarray(a, "RGBA").save(OUT / "card_frame_t_base.png")
    Image.new("RGBA", (W, H), (0, 0, 0, 0)).save(OUT / "card_frame_t_glow.png")
    print("wrote card_frame_t_base.png, card_frame_t_glow.png", W, "x", H, "edge", inset)


if __name__ == "__main__":
    build()
