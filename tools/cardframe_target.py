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
ART_BOTTOM = 0.63        # of H: where the art ends and the rules box starts
OUTER = 5                # cream line, px
GREEN_W = 11             # green band, px
INNER = 3                # dark line inside it, px


def rounded(draw, inset, fill):
    draw.rounded_rectangle((inset, inset, W - 1 - inset, H - 1 - inset),
                           radius=max(2, RADIUS - inset), fill=fill)


# TARGET's edge, outside in, measured across its Scramble card's left side
# (1 TARGET px = 5 source px): a dark rim, a cream line, a gold line, then
# green, dark green, green.
EDGE = [((14, 8, 4), 4), ((226, 230, 162), 5), ((126, 132, 62), 4),
        ((60, 80, 50), 6)]
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
    bb = int(BAND_BOTTOM * H)
    a[top:bb, top:W - top, :3] = BAND
    a[bb - 3:bb, top:W - top, :3] = (34, 32, 40)
    # The art window, behind the art: an icon's clear ground shows black.
    ab = int(ART_BOTTOM * H)
    a[bb:ab, top:W - top, :3] = ART_BG
    Image.fromarray(a, "RGBA").save(OUT / "card_frame_t_base.png")
    Image.new("RGBA", (W, H), (0, 0, 0, 0)).save(OUT / "card_frame_t_glow.png")
    print("wrote card_frame_t_base.png, card_frame_t_glow.png", W, "x", H, "edge", inset)


if __name__ == "__main__":
    build()
