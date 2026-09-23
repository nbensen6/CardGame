"""Give a model-rendered card its backdrop.

    python3 tools/cardbg.py <raw_transparent.png> <card_id>

cardart.py renders the subject on transparency and stops there — background
colour is a game-identity decision (design/agents/status/artist.md's arena
pass made the same call for the ground: match the fight's own palette rather
than drop in whatever a generic render happens to produce), so it lives here
as a separate, cheap-to-re-run step instead of being baked into the Blender
script.

WHY A RADIAL GLOW, NOT A FLAT FILL
-----------------------------------
A flat colour behind a cutout character reads as "sticker on a swatch." A
glow anchored where the render's own alpha is brightest/highest (its own
upper region, where a raised arm or a head usually sits) gives the eye
somewhere to land before the card's front-layer furniture (banner, pips,
rules text) goes on top in CardView. Radiating OUT to the fight's dark
CHARCOAL keeps the corners calm so the frame moulding (drawn over this in
CardView, see ART_LAYER in card_view.gd) still reads as the edge of the art,
not a second border.

Colours are read straight out of tools/blender/colormap_base.png at the same
pixel cells tools/blender/kenney.py's CHARCOAL/RUST swatches name, so a card's
backdrop and the arena/hunter models it sits next to in the same fight always
agree, instead of a value typed in here drifting from the atlas over time.
"""
import math
import os
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))
COLORMAP = os.path.join(HERE, "blender", "colormap_base.png")
OUT_DIR = os.path.join(ROOT, "game", "assets", "cardart")


def _swatch(px, py):
    """The same cell tools/blender/kenney.py's swatch() names, sampled as a
    plain RGB pixel instead of a UV — px/py are the CENTRE-x, TOP-edge-y
    pixel coordinates kenney.py itself uses (its own +16 note explains the
    16px offset to the cell's vertical centre)."""
    im = Image.open(COLORMAP).convert("RGB")
    return im.getpixel((px, py + 16))


CHARCOAL = _swatch(336, 448)   # dark neutral, this fight's wall/floor base
RUST = _swatch(112, 192)       # this fight's one warm accent (the arena pass)


def _lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


## A first pass blended straight to RUST at the glow's centre and it read as
## a card-sized orange flare, not an ember behind a character — the arena
## pass hit the same trap ("a neutral Blender render showed a dramatic swing
## to near-black... far more muted [in the real fight] than the flat preview
## suggested," design/agents/status/artist.md) in the opposite direction.
## Fix the same way: darken the base well past the raw swatch, and only ever
## blend PART way to RUST, never all the way.
DARK = tuple(int(c * 0.45) for c in CHARCOAL)
GLOW_PEAK = _lerp(DARK, RUST, 0.40)


def make_background(w, h, glow_xy=(0.72, 0.30)):
    """DARK everywhere, a contained ember-GLOW_PEAK glow centred at glow_xy
    (fractional card coordinates) — a hint of warmth near the mech arm, not
    a flood across the whole card."""
    bg = Image.new("RGB", (w, h))
    px = bg.load()
    gx, gy = glow_xy[0] * w, glow_xy[1] * h
    radius = 0.42 * math.hypot(w, h)
    for y in range(h):
        for x in range(w):
            d = math.hypot(x - gx, y - gy) / radius
            t = min(1.0, d) ** 1.6   # eased falloff: contained core, quick fade
            px[x, y] = _lerp(GLOW_PEAK, DARK, t)
    return bg


def composite(raw_path, card_id):
    fg = Image.open(raw_path).convert("RGBA")
    w, h = fg.size
    bg = make_background(w, h).convert("RGBA")
    out = Image.alpha_composite(bg, fg).convert("RGB")
    dst = os.path.join(OUT_DIR, card_id + ".png")
    out.save(dst)
    print("wrote %s (%dx%d)" % (dst, w, h))


def main():
    if len(sys.argv) != 3:
        print(__doc__)
        return
    composite(sys.argv[1], sys.argv[2])


if __name__ == "__main__":
    main()
