"""Workflow test for requests/2026-09-23-0500-nick-to-artist-recreate-leap-style.md:
can the artist recreate Nick's Canva card-art style (game/assets/cardart/leap.png)
without Canva? This is a pure 2D layered-shape paint, not a 3D render -- leap.png
itself carries no 3D shading cue (no specular, no lens perspective, no AO), it is
flat filled shapes layered by depth, which a renderer fights against and a direct
2D paint reproduces on its own terms. Every colour below is sampled straight from
leap.png's own quantized pixel histogram, not invented.

    python3 tools/cardpaint.py <out.png>

Verdict (see the request's ## Result for the full writeup): this reproduces the
surface cues -- palette, flat-shape layering, tiny-subject-in-a-landscape framing
-- well enough to read as "the same family" at card size, but not Nick's hand:
the reference's confident, asymmetric brush shapes read as unmistakably pine
trees at a glance; these procedural ellipses need the surrounding context to
read as trees at all, and getting the centre 'recession' to read as a hazy
treeline rather than pillars or a flat wall took several rounds of visual
iteration even for this one, reused forest template. A genuinely different
card subject would need that same bespoke tuning from scratch, not a swap of
inputs into this script.
"""
import random
import sys

from PIL import Image, ImageDraw, ImageFilter

random.seed(3)

W, H = 620, 870

SKY = (104, 192, 248)
SKY_HAZE = (190, 224, 238)
PALEST = (208, 232, 208)
PALE2 = (208, 232, 192)
LIGHT = (176, 208, 128)
LIGHT2 = (152, 192, 152)
MID = (136, 176, 120)
MID2 = (128, 168, 112)
DARK = (80, 112, 80)
DARK2 = (64, 104, 64)
DEEP = (56, 88, 56)
TRUNK = (32, 32, 48)
PATH_LIGHT = (216, 184, 152)
PATH_MID = (192, 160, 136)
PATH_SHADOW = (120, 112, 96)
GRASS_HI = (184, 208, 96)
GRASS_MID = (152, 176, 104)
FROG_BODY = (143, 192, 53)
FROG_BELLY = (232, 216, 128)
FROG_DARK = (96, 150, 40)

GROUND_Y = 800  # nominal ground row most trees plant into


def spire(draw, cx, base_y, height, width, color, tiers=9, alpha=255):
    """A tall narrow cone of overlapping tapered lobes -- a distant tree seen
    as one soft silhouette, no visible trunk. Many of these, heavily
    overlapped, read as one ragged treeline once blurred."""
    for i in range(tiers):
        t = i / (tiers - 1)
        y = base_y - height * t
        w = width * (1 - 0.85 * t) * random.uniform(0.8, 1.05)
        h = height / tiers * random.uniform(1.6, 2.1)
        x = cx + random.uniform(-width * 0.08, width * 0.08)
        draw.ellipse([x - w / 2, y - h / 2, x + w / 2, y + h / 2], fill=color + (alpha,))


def layer_spires(color, xs, blur, base_range, h_range, alpha=255):
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ld = ImageDraw.Draw(layer)
    for cx in xs:
        h = random.uniform(*h_range)
        w = random.uniform(40, 70)
        base = random.uniform(*base_range)
        spire(ld, cx, base, h, w, color, alpha=alpha)
    if blur:
        layer = layer.filter(ImageFilter.GaussianBlur(blur))
    return layer


def lobed_tree(draw, cx, base_y, trunk_top_y, canopy_top_y, trunk_w, canopy_w,
                trunk_color, canopy_color, lobes=4, alpha=255):
    """A thin trunk from base_y up to trunk_top_y, with rounded canopy lobes
    clustered in the upper portion between canopy_top_y and a bit below
    trunk_top_y."""
    lean = random.uniform(-10, 10)
    draw.polygon([(cx - trunk_w / 2, base_y), (cx - trunk_w / 2 + lean, trunk_top_y),
                  (cx + trunk_w / 2 + lean, trunk_top_y), (cx + trunk_w / 2, base_y)],
                 fill=trunk_color + (alpha,))
    canopy_bottom = trunk_top_y + (base_y - trunk_top_y) * 0.35
    for i in range(lobes):
        t = i / max(1, lobes - 1)
        y = canopy_bottom - (canopy_bottom - canopy_top_y) * t
        w = canopy_w * (1 - 0.35 * t) * random.uniform(0.85, 1.15)
        h = canopy_w * 0.55 * random.uniform(0.8, 1.1)
        x = cx + lean * (1 - t) + random.uniform(-canopy_w * 0.15, canopy_w * 0.15)
        draw.ellipse([x - w / 2, y - h / 2, x + w / 2, y + h / 2], fill=canopy_color + (alpha,))


def layer_lobed(canopy_color, trunk_color, xs, blur, trunk_w=(4, 7), tip_range=(60, 220),
                 canopy_w=(90, 150), alpha=255):
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ld = ImageDraw.Draw(layer)
    for cx in xs:
        base = GROUND_Y + random.uniform(-10, 40)
        tip = random.uniform(*tip_range)
        cw = random.uniform(*canopy_w)
        ctop = tip + random.uniform(20, 60)
        lobed_tree(ld, cx, base, tip, ctop, random.uniform(*trunk_w), cw,
                   trunk_color, canopy_color, lobes=random.randint(4, 6), alpha=alpha)
    if blur:
        layer = layer.filter(ImageFilter.GaussianBlur(blur))
    return layer


def bare_trunk(draw, x, base_y, tip_y, w, color, alpha=255):
    lean = random.uniform(-14, 14)
    draw.polygon([(x - w / 2, base_y), (x - w / 2 + lean, tip_y),
                  (x + w / 2 + lean, tip_y), (x + w / 2, base_y)], fill=color + (alpha,))


def composite(img, layer):
    return Image.alpha_composite(img.convert("RGBA"), layer).convert("RGB")


def paint():
    img = Image.new("RGB", (W, H), SKY)
    for row in range(H):
        t = max(0.0, 1 - row / 380)
        r = int(SKY[0] + (SKY_HAZE[0] - SKY[0]) * t)
        g = int(SKY[1] + (SKY_HAZE[1] - SKY[1]) * t)
        b = int(SKY[2] + (SKY_HAZE[2] - SKY[2]) * t)
        ImageDraw.Draw(img).line([(0, row), (W, row)], fill=(r, g, b))

    cloud_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    cd = ImageDraw.Draw(cloud_layer)
    for _ in range(6):
        cx = random.uniform(160, W - 160)
        cy = random.uniform(15, 120)
        rw = random.uniform(55, 120)
        rh = random.uniform(12, 26)
        cd.ellipse([cx - rw, cy - rh, cx + rw, cy + rh], fill=(235, 248, 235, 90))
    img = composite(img, cloud_layer.filter(ImageFilter.GaussianBlur(12)))

    # side-margin distant spires: full opacity, tall, reach down near the ground
    img = composite(img, layer_spires(PALEST, [65, 90, 115, 140, 165, 190, 480, 505, 530, 555, 580, 605],
                                       7, (740, 800), (430, 580)))
    img = composite(img, layer_spires(PALE2, [55, 80, 105, 130, 470, 495, 520, 545, 570],
                                       5.5, (740, 800), (430, 580)))
    img = composite(img, layer_spires(LIGHT2, [45, 70, 95, 460, 485, 510, 535],
                                       4, (740, 800), (430, 580)))

    # centre-gap treeline: hazy and partly translucent, stopping well above
    # the clearing -- the gap stays open air down to the path, not a solid
    # green wall.
    gap16 = [205 + i * (415 - 205) / 15 for i in range(16)]
    gap10 = [220 + i * (400 - 220) / 9 for i in range(10)]
    gap6 = [240 + i * (380 - 240) / 5 for i in range(6)]
    img = composite(img, layer_spires(PALEST, gap16, 7, (520, 580), (330, 420), alpha=190))
    img = composite(img, layer_spires(PALE2, gap10, 5.5, (500, 560), (280, 360), alpha=170))
    img = composite(img, layer_spires(LIGHT2, gap6, 4, (480, 540), (220, 300), alpha=140))

    # lobed mid trees: trunk + rounded canopy, across the margins
    img = composite(img, layer_lobed(LIGHT, DARK2, [30, 70, 110, 150, 470, 510, 550, 590], 3.5,
                                      tip_range=(120, 260), canopy_w=(100, 150)))
    img = composite(img, layer_lobed(MID, DARK2, [15, 50, 90, 490, 530, 570, 605], 2,
                                      tip_range=(90, 220), canopy_w=(110, 165)))
    img = composite(img, layer_lobed(MID2, TRUNK, [5, 40, 500, 540, 580], 1,
                                      tip_range=(60, 180), canopy_w=(120, 175)))

    # near dark canopy trees, closest to camera, biggest, least blur
    img = composite(img, layer_lobed(DARK, TRUNK, [0, 35, 480, 560, 600], 0.6,
                                      trunk_w=(6, 10), tip_range=(40, 130), canopy_w=(150, 210)))
    img = composite(img, layer_lobed(DEEP, TRUNK, [-15, 610], 0,
                                      trunk_w=(7, 11), tip_range=(20, 90), canopy_w=(170, 230)))

    # bare near trunks: thin vertical lines full height, scattered through
    # the whole margin band, little to no canopy -- the "through the trees"
    # foreground read leap.png leans on hardest.
    trunk_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    td = ImageDraw.Draw(trunk_layer)
    for x in (10, 32, 55, 78, 100, 130, 165, 200, 420, 448, 478, 505, 530, 558, 585, 610):
        tip = random.uniform(40, 300)
        w = random.uniform(4, 7)
        base = GROUND_Y + random.uniform(-20, 60)
        bare_trunk(td, x, base, tip, w, TRUNK)
        for _ in range(random.randint(2, 5)):  # a sparse tuft of leaf flecks near the tip
            fx = x + random.uniform(-14, 14)
            fy = tip + random.uniform(5, 40)
            r = random.uniform(3, 7)
            td.ellipse([fx - r, fy - r * 0.6, fx + r, fy + r * 0.6], fill=DARK2 + (255,))
    img = composite(img, trunk_layer)

    # ground clearing
    ground = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    gd = ImageDraw.Draw(ground)
    gd.polygon([(0, 745), (W, 725), (W, H), (0, H)], fill=DEEP + (255,))
    gd.polygon([(0, 785), (W, 765), (W, H), (0, H)], fill=DARK2 + (255,))
    stones = [(120, 838, 50, 20), (215, 812, 52, 20), (300, 792, 46, 18), (355, 760, 40, 16)]
    for sx, sy, sw, sh in stones:
        gd.ellipse([sx - sw / 2, sy - sh / 2 + 5, sx + sw / 2, sy + sh / 2 + 5], fill=PATH_SHADOW + (255,))
        gd.ellipse([sx - sw / 2, sy - sh / 2, sx + sw / 2, sy + sh / 2], fill=PATH_MID + (255,))
        gd.ellipse([sx - sw / 2 + 6, sy - sh / 2 + 3, sx + sw / 2 - 10, sy + sh / 2 - 8], fill=PATH_LIGHT + (255,))
    for _ in range(70):
        gx, gy = random.uniform(0, W), random.uniform(800, H)
        gd.ellipse([gx - 3, gy - 8, gx + 3, gy], fill=GRASS_HI + (210,))
    for _ in range(45):
        gx, gy = random.uniform(0, W), random.uniform(750, 805)
        gd.ellipse([gx - 3, gy - 7, gx + 3, gy], fill=GRASS_MID + (210,))
    img = composite(img, ground)

    # foreground bush clumps at the corners
    bush = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    bd = ImageDraw.Draw(bush)
    for cx, cy in [(35, 800), (5, 835), (W - 25, 815), (W - 55, 845)]:
        for _ in range(3):
            r = random.uniform(40, 62)
            bd.ellipse([cx - r, cy - r * 0.7, cx + r, cy + r * 0.7], fill=DEEP + (255,))
        for _ in range(2):
            r = random.uniform(18, 32)
            bd.ellipse([cx - r + 15, cy - r * 0.7 - 8, cx + r + 15, cy + r * 0.7 - 8], fill=GRASS_MID + (255,))
    img = composite(img, bush)

    branch = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(branch).line([(280, 705), (400, 668), (455, 648)], fill=(93, 64, 46, 255),
                                 width=7, joint="curve")
    img = composite(img, branch)

    # the frog, caught mid-hop off a stepping stone -- small, off-centre, in
    # the clearing, echoing leap's small-subject-in-a-big-scene move
    frog_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    fd = ImageDraw.Draw(frog_layer)
    fx, fy = 460, 625
    fd.ellipse([fx - 32, fy + 4, fx - 10, fy + 16], fill=FROG_DARK + (160,))  # trailing hind legs
    fd.ellipse([fx - 30, fy - 4, fx - 12, fy + 6], fill=FROG_DARK + (160,))
    fd.ellipse([fx - 15, fy - 13, fx + 15, fy + 10], fill=FROG_BODY + (255,))
    fd.ellipse([fx - 9, fy - 2, fx + 9, fy + 9], fill=FROG_BELLY + (255,))
    fd.ellipse([fx - 4, fy + 2, fx + 14, fy + 12], fill=FROG_DARK + (255,))  # front legs reaching
    fd.ellipse([fx + 8, fy - 2, fx + 22, fy + 6], fill=FROG_DARK + (255,))
    for ex in (fx - 7, fx + 7):
        fd.ellipse([ex - 5, fy - 20, ex + 5, fy - 10], fill=FROG_BODY + (255,))
        fd.ellipse([ex - 3, fy - 18, ex + 3, fy - 12], fill=(20, 20, 20, 255))
        fd.ellipse([ex - 2, fy - 17, ex, fy - 15], fill=(255, 255, 255, 220))
    img = composite(img, frog_layer)

    return img


if __name__ == "__main__":
    out = sys.argv[1] if len(sys.argv) > 1 else "hop.png"
    paint().save(out)
    print("saved", out)
