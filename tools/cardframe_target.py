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
EDGE = [((14, 10, 6), 2), ((228, 230, 188), 9), ((38, 40, 31), 33),
        ((222, 210, 158), 7), ((48, 78, 56), 10), ((40, 66, 48), 0),
        ((10, 14, 12), 3)]
# Re-measured on TARGET's Tongue Snap left side and Tongue Flick right side at
# 1024 (Matched check 2026-10-10 run 4), outside in: a thin bright cream rule
# (~(228,230,188), ~1.5 px), a dark olive band (~(38,40,31), ~6 px) with no
# green in it, then the rule beside the art, ~4 px: a solid warm cream line
# (~(222,210,158)) and, on the window side, a dashed one, pale mint dashes on
# dark green gaps, ~3 px a period at 720 (the BEAD dashes draw over it). The old frame drew a broad cream outside and a saturated yellow-green
# rule inside, which read as a heavy double green/gold border.
# Run 7 (2026-10-10), measured at 720 on TARGET's Tongue Snap and Scramble
# sides: the outer rule is one screen px, not two; the band is darker
# (~(26,28,26)); a warm near-black keyline (~(22,13,6)) sits right before
# the inner rule; and the stitch beside the inner rule is yellow-olive
# (~(149,152,99)), not mint.
EDGE_TOP = [((14, 10, 6), 2), ((236, 236, 196), 6), ((26, 28, 26), 31), ((22, 13, 6), 5),
            ((222, 210, 158), 7), ((80, 104, 76), 10), ((40, 66, 48), 0),
            ((10, 14, 12), 3)]
# Run 8 (2026-10-10), with each card registered on TARGET's rails first
# (combat_3d HAND_CARD_NUDGE), profiled across the rails at 720 at quarter-px
# steps: TARGET's side outer rule peaks ~135-160 (ours ~100), and the band
# drops to ~10-20 right before the inner rule (ours ~35). Wider, brighter
# outer rule; darker, wider keyline; the inner rules keep their place. Above
# the name band's foot the frame keeps EDGE_TOP: TARGET's top edge is the thin
# line alone.
EDGE = [((14, 10, 6), 2), ((255, 248, 204), 7), ((20, 21, 18), 26), ((4, 2, 2), 9),
        ((255, 240, 168), 8), ((48, 100, 68), 9), ((40, 66, 48), 0),
        ((10, 14, 12), 3)]
BEAD = (228, 220, 136)   # the dashes: olive green beside the gold rule (run 8; was yellow-olive (176,180,116))
# ...but TARGET lights its cards from the left: on a card's RIGHT side the
# stitch is teal (~(126,157,132)) and the outer rule a dim warm brown
# (~(100,88,72)), measured at 720 on Tongue Flick's right edge (run 7).
BEAD_R = (150, 196, 170)
INNER_R = (232, 236, 196)
GAP_R = (24, 64, 56)
OUTER_R = (128, 112, 92)
BAND_DASH = (26, 28, 26)   # TARGET's band carries no green dashes: band colour
BAND_DASH_W = 4
BAND_DASH_ON, BAND_DASH_PERIOD = 10, 18
BEAD_W = 9               # px across: the dashed half of the inner rule
BEAD_SKIP = 8             # px: the solid cream half before it
BEAD_ON, BEAD_PERIOD = 12, 17   # px along: ~3 screen px a bead, so the dots survive the hand's 0.13 scale (run 16)
CHEV_X = (120, 200)      # px: the bevel's back edge (under the gem) and its apex
CHEV_R = 60              # px: the right-hand bevel's depth
CHEV_LIT = (68, 65, 80)
CHEV_DARK = (42, 39, 50)
BAND_FROM = 11           # the name band starts inside the cream line, px
ART_BG = (10, 11, 9)     # TARGET's art window behind an icon: near-black
# A clear margin round the frame, px. The Compatibility renderer has no 2D
# MSAA, so a fanned card's opaque quad edge drew a staircase down every side
# where TARGET's edges are smooth (Matched check 2026-10-10 run 4). With clear
# texels past the edge, the filtered alpha ramps the edge instead.
# card_view.gd's A1_PAD must match.
PAD = 10


def build(flat=False):
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    inset = 0
    for col, w in EDGE:
        rounded(d, inset, col + (255,))
        inset += w
    rounded(d, inset, BODY + (255,))
    a = np.asarray(im).copy()
    im_t = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d_t = ImageDraw.Draw(im_t)
    inset_t = 0
    for col, w in EDGE_TOP:
        rounded(d_t, inset_t, col + (255,))
        inset_t += w
    rounded(d_t, inset_t, BODY + (255,))
    assert inset_t == inset
    bb0 = int(BAND_BOTTOM * H)
    a[:bb0] = np.asarray(im_t)[:bb0]
    top = inset
    # beads in the band: the band runs from b0 to b1 px in from the edge
    b0 = EDGE[0][1] + EDGE[1][1] + EDGE[2][1] + EDGE[3][1]
    lo, hi = b0 + BEAD_SKIP, b0 + BEAD_SKIP + BEAD_W
    # run 9: TARGET's right-hand rail (the shadow side) is a pale cream rule
    # with teal beads on a dark teal ground, not the left side's gold.
    r0 = RADIUS
    a[r0:H - RADIUS, W - b0 - BEAD_SKIP:W - b0, :3] = INNER_R
    a[r0:H - RADIUS, W - hi:W - lo, :3] = GAP_R
    on = (np.arange(H) % BEAD_PERIOD) < BEAD_ON
    for x in ([] if flat else list(range(lo, hi))) + list(range(W - hi, W - lo)):
        rows = np.nonzero(on)[0]
        rows = rows[(rows > RADIUS) & (rows < H - RADIUS)]
        a[rows, x, :3] = BEAD if x < W // 2 else BEAD_R
    # the right side's outer rule, dim
    o0, o1 = EDGE[0][1], EDGE[0][1] + EDGE[1][1]
    # (bright gold round the top corner and beside the name band, as TARGET)
    a[int(BAND_BOTTOM * H):H - RADIUS, W - o1:W - o0, :3] = OUTER_R
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
    rails = a.copy()
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
    # And at the band's right end, against the border: TARGET carves the
    # same bevel there, mirrored, a dark notch whose apex points back at the
    # name (Matched check 2026-10-10 run 4). Kept inside the 80 px right
    # patch margin so the nine-patch never stretches it.
    # TARGET's band stops at the right-hand rail: the rail (outer rule, dark
    # band, inner rule and stitch) runs on up past the name and curls round
    # the top-right corner (Matched check 2026-10-10 run 7, Tongue Flick).
    # Kept inside the 80 px right patch margin.
    rail_w = sum(w for _, w in EDGE[:-2])
    a[:bb, W - rail_w:, :] = rails[:bb, W - rail_w:, :]
    rx0, rx1 = W - rail_w, W - rail_w - CHEV_R
    for y in range(BAND_FROM, bb - 3):
        k = abs(y - mid) / max(1, mid - BAND_FROM)
        xe = int(rx1 + (rx0 - rx1) * k)
        if xe < rx0:
            a[y, xe:rx0, :3] = CHEV_LIT if y < mid else CHEV_DARK
    # The art window, behind the art: an icon's clear ground shows black.
    ab = int(ART_BOTTOM * H)
    a[bb:ab, top:W - top, :3] = ART_BG
    # The window is see-through: card_view.gd draws the art (on a black
    # ground) UNDER this frame, so the frame's filtered edge overlaps the
    # art's and a tilted card's window edge is smooth, not a staircase
    # (run 14).
    a[bb:ab, top:W - top, 3] = 0
    out = Image.new("RGBA", (W + 2 * PAD, H + 2 * PAD), (0, 0, 0, 0))
    out.paste(Image.fromarray(a, "RGBA"), (PAD, PAD))
    if flat:
        # run 9: the hand's upright middle card. TARGET draws its left rail
        # (the seam under Leap) as a solid gold rule with a green fringe; the
        # beads only show on the fan's tilted cards.
        out.save(OUT / "card_frame_t_flat.png")
        return
    out.save(OUT / "card_frame_t_base.png")
    Image.new("RGBA", out.size, (0, 0, 0, 0)).save(OUT / "card_frame_t_glow.png")
    print("wrote card_frame_t_base.png, card_frame_t_glow.png", W, "x", H, "edge", inset)


if __name__ == "__main__":
    build(flat=True)
    build()
