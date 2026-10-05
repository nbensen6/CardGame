"""Cut a HUD panel out of the A1 card frame, as the same tintable pair.

Nick, 2026-10-05 ("A HUD that matches the chosen card frame"): every HUD
element and the cards have to read as one set, with "the same two-layer rule
as the cards: neutral stone plus a glow layer that takes the seat colour".

The cheapest way to be the same material is to BE the same pixels. The card's
bottom-right quarter is a carved corner, two edges of the frame and a slab of
cracked interior stone; mirrored into four it is a panel with no socket, no
title bar and no art window. It is cut from both halves of the card pair, so
in game the HUD stacks exactly like card_view.gd's A1 frame does:

    game/assets/ui/hud_panel_a1_base.png   neutral stone
    game/assets/ui/hud_panel_a1_glow.png   white glow on transparent

    python tools/hudpanel_a1.py      # re-run after tools/cardframe_a1.py

Margins for the nine-patch are HUD_PANEL_PATCH in combat_3d.gd.
"""

import os

from PIL import Image, ImageOps

ASSETS = os.path.join("game", "assets", "ui")
# The quarter: from the card's middle to its outer right edge, and from inside
# the rules panel down to the outer bottom edge (below that is backdrop).
QUARTER = (345, 660, 688, 946)


def mirror4(q):
    """A quarter that owns the bottom-right corner, made into a whole panel."""
    w, h = q.size
    out = Image.new(q.mode, (w * 2, h * 2))
    out.paste(q, (w, h))
    out.paste(ImageOps.mirror(q), (0, h))
    out.paste(ImageOps.flip(q), (w, 0))
    out.paste(ImageOps.flip(ImageOps.mirror(q)), (0, 0))
    return out


def main():
    os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
    for name in ("base", "glow"):
        src = Image.open(os.path.join(ASSETS, "card_frame_a1_%s.png" % name))
        p = os.path.join(ASSETS, "hud_panel_a1_%s.png" % name)
        mirror4(src.crop(QUARTER)).save(p)
        print("wrote", p)


if __name__ == "__main__":
    main()
