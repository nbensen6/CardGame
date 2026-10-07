"""TARGET.png's HUD panel: a thin, flat, dark plate with a hairline edge.

Checker round 2, iter 07 (2026-10-07): both critics' top MAJOR was the HUD's
"heavy glowing borders everywhere" -- the A1 carved stone and its glow
(tools/hudpanel_a1.py). TARGET.png draws the boss strip, the intent chip and
the climb gauge as quiet dark glass with a hairline rim. Same two layers and
the same nine-patch geometry as A1 (686x572, 72 px patch), so add_a1_panel
draws these with no other change: `base` is the dark face and its grey
hairline, `glow` a thin white ring the HUD tints additively (seat colour,
the beast's ember, the intent's red) -- a coloured hairline, not a halo.

    python3 tools/hudpanel_flat.py
"""
import os
from PIL import Image, ImageDraw

W, H = 686, 572
R = 44            # corner radius, source px (~14 px drawn at 0.32)
OUT = os.path.join(os.path.dirname(__file__), "..", "game", "assets", "ui")


def rr(draw, inset, fill=None, outline=None, width=0):
    draw.rounded_rectangle((inset, inset, W - 1 - inset, H - 1 - inset),
                           radius=max(1, R - inset), fill=fill, outline=outline, width=width)


def main():
    s = 4  # supersample for clean edges
    base = Image.new("RGB", (W * s, H * s), (0, 0, 0))
    big = ImageDraw.Draw(base)
    big.rounded_rectangle((0, 0, W * s - 1, H * s - 1), radius=R * s, fill=(70, 66, 64))
    big.rounded_rectangle((5 * s, 5 * s, W * s - 1 - 5 * s, H * s - 1 - 5 * s),
                          radius=(R - 5) * s, fill=(15, 15, 19))
    base = base.resize((W, H), Image.LANCZOS)
    # outside the rounded corners stays black: the nine-patch is drawn opaque
    # under an RGB texture, so make the corners transparent instead
    mask = Image.new("L", (W * s, H * s), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, W * s - 1, H * s - 1), radius=R * s, fill=235)
    mask = mask.resize((W, H), Image.LANCZOS)
    base = base.convert("RGBA")
    base.putalpha(mask)
    base.save(os.path.join(OUT, "hud_panel_flat_base.png"))

    glow = Image.new("RGBA", (W * s, H * s), (0, 0, 0, 0))
    g = ImageDraw.Draw(glow)
    g.rounded_rectangle((0, 0, W * s - 1, H * s - 1), radius=R * s,
                        outline=(255, 255, 255, 150), width=6 * s)
    glow.resize((W, H), Image.LANCZOS).save(os.path.join(OUT, "hud_panel_flat_glow.png"))
    print("wrote hud_panel_flat_base.png, hud_panel_flat_glow.png")


if __name__ == "__main__":
    main()
