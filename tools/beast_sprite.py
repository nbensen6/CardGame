"""Turn a beast concept into the flat inked sprite the fight draws.

    python3 tools/beast_sprite.py cinder_jackal

Nick, 2026-10-05: "have the builder do the 2.5D like in the reference."
TARGET.png's jackal is a drawing, not lit geometry: a thick cream outline
with a thin dark ink line inside it and a soft orange halo outside, a few
flat dark-brown tones per facet, and hard-edged glowing cracks. This makes
that drawing out of the concept (a clean figure on a plain grey card) and
writes, beside the PNG, the .tscn the fight loads as `<id>_2d`: a billboard
Sprite3D plus the climb_/ledge_ markers, which are authored here as pixel
points on the image (`HOLDS`) rather than raycast off a mesh.

Needs Pillow, numpy and scipy. Re-runnable; the output is deterministic.
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage as ndi

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "game" / "assets" / "3d" / "cast"

BEASTS = {
    "cinder_jackal": {
        "concept": "design/art/targets/2026-10-04-jackal-concept.png",
        # World height of the sprite before the fight's own _fit_height,
        # the same 1.90 the v2 model had so every constant tuned on it holds.
        "height": 1.90,
        # Height -> pixel (x, y) on the CONCEPT image (1024 square). The
        # route climbs the right leg, the right flank, the chest, the neck,
        # and ends on the face, which stays clear at rest.
        "holds": {
            0: (600, 960), 1: (612, 760), 2: (590, 600),
            3: (560, 430), 4: (535, 330), 5: (512, 225),
        },
        "ledges": [0, 2, 3, 4],
    },
}

# TARGET.png, sampled.
CREAM = np.array([255, 226, 160], float)
INK = np.array([28, 16, 16], float)
HALO = np.array([255, 168, 60], float)
TONES = [np.array(c, float) for c in
         ([66, 42, 37], [84, 55, 46], [96, 63, 51], [110, 73, 58])]
CRACK = np.array([242, 82, 24], float)
CRACK_HOT = np.array([255, 196, 72], float)

SCALE = 2          # draw at 2x the concept so the strokes stay crisp
CREAM_W = 28       # px at 2x: TARGET's outline is ~1.1 % of the beast's height
INK_W = 12
HALO_W = 28
MARGIN = 2


def disk(r):
    y, x = np.ogrid[-r:r + 1, -r:r + 1]
    return x * x + y * y <= r * r


def build(beast_id):
    spec = BEASTS[beast_id]
    src = Image.open(ROOT / spec["concept"]).convert("RGB")
    w0, h0 = src.size
    src = src.resize((w0 * SCALE, h0 * SCALE), Image.LANCZOS)
    a = np.asarray(src).astype(float)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    mx, mn = a.max(-1), a.min(-1)

    # Silhouette: the plain grey card is light and colourless; every
    # sizeable region of it is background, enclosed or not.
    bgish = (mn > 170) & (mx - mn < 26)
    lab, n = ndi.label(bgish)
    sizes = ndi.sum(bgish, lab, range(1, n + 1))
    bg = np.isin(lab, [i + 1 for i, s in enumerate(sizes) if s > 400 * SCALE * SCALE])
    body = ~bg
    body = ndi.binary_opening(body, disk(2))
    body = ndi.binary_fill_holes(body)
    keep, n = ndi.label(body)
    if n > 1:
        sizes = ndi.sum(body, keep, range(1, n + 1))
        body = keep == (int(np.argmax(sizes)) + 1)
    # Smooth the edge so the stroke is a clean line, not the concept's AA.
    body = ndi.gaussian_filter(body.astype(float), 1.5) > 0.5

    # Cracks: the saturated orange. Hard edged, no gradient.
    crack = body & (r > 150) & (r - b > 95) & (r - g > 35)
    # Only the seams thick enough to read at play size survive, drawn
    # thicker, with a yellow core like TARGET's: a few bold cracks, not a mesh.
    crack = ndi.binary_opening(crack, disk(4))
    crack = ndi.binary_dilation(crack, disk(3)) & body
    hot = ndi.binary_erosion(crack, disk(6)) | (crack & (g > 150) & (r > 225))

    # Flat fills: the concept's per-facet shading, smoothed and cut to four
    # tones, so a facet reads as one colour like the drawing.
    lum = 0.3 * r + 0.59 * g + 0.11 * b
    lum = lum.copy()
    lum[crack] = np.median(lum[body & ~crack])
    lum = ndi.median_filter(lum, size=9)
    cuts = np.percentile(lum[body & ~crack], [30, 60, 85])
    tone = np.digitize(lum, cuts)
    # A facet is one colour: vote out the speckle the concept's texture leaves.
    tone = ndi.median_filter(tone, size=25)
    out = np.zeros(a.shape[:2] + (4,), float)
    for i, c in enumerate(TONES):
        m = body & (tone == i)
        out[m, :3] = c
    out[crack, :3] = CRACK
    out[hot, :3] = CRACK_HOT
    out[body, 3] = 255

    # The cracks glow onto the rock beside them.
    glow = ndi.gaussian_filter(crack.astype(float), 5) * 1.6
    glow = np.clip(glow, 0, 1)[..., None] * (body & ~crack)[..., None]
    out[..., :3] = out[..., :3] * (1 - 0.55 * glow) + HALO * 0.55 * glow

    # Ink just inside the edge, the cream stroke outside it, then the halo.
    inner = body & ~ndi.binary_erosion(body, disk(INK_W))
    out[inner, :3] = INK
    ring = ndi.binary_dilation(body, disk(CREAM_W)) & ~body
    out[ring, :3] = CREAM
    out[ring, 3] = 255
    stroke = body | ring
    dist = ndi.distance_transform_edt(~stroke)
    halo = (~stroke) & (dist < HALO_W)
    fall = np.clip(1 - dist / HALO_W, 0, 1) ** 2.0 * 0.55
    out[halo, :3] = HALO
    out[halo, 3] = 255 * fall[halo]

    # Crop to the drawing plus margin; keep the concept's feet as the origin.
    ys, xs = np.nonzero(out[..., 3] > 4)
    x0, x1 = max(xs.min() - MARGIN, 0), min(xs.max() + MARGIN, out.shape[1])
    y0, y1 = max(ys.min() - MARGIN, 0), min(ys.max() + MARGIN, out.shape[0])
    by = np.nonzero(body.any(1))[0]
    bx = np.nonzero(body.any(0))[0]
    feet_px = by.max()                      # bottom of the body, 2x space
    head_px = by.min()
    mid_px = (bx.min() + bx.max()) / 2.0
    img = Image.fromarray(np.clip(out[y0:y1, x0:x1], 0, 255).astype(np.uint8), "RGBA")
    png = OUT_DIR / f"{beast_id}_2d.png"
    img.save(png, optimize=True)

    # World units per 2x pixel: the BODY (not the halo) is spec height tall.
    px = spec["height"] / float(feet_px - head_px)
    # Sprite3D centres the texture on its node: offset so the feet sit at
    # y 0 and the body is centred on x 0.
    cx = (x0 + x1) / 2.0
    cy = (y0 + y1) / 2.0
    sx = (cx - mid_px) * px
    sy = (feet_px - cy) * px

    def world(p):
        x, y = p[0] * SCALE, p[1] * SCALE
        return ((x - mid_px) * px, (feet_px - y) * px)

    holds = {int(k): world(v) for k, v in spec["holds"].items()}
    lines = [
        '[gd_scene load_steps=2 format=3]',
        '',
        f'[ext_resource type="Texture2D" path="res://assets/3d/cast/{png.name}" id="1"]',
        '',
        f'[node name="{beast_id}_2d" type="Node3D"]',
        '',
        '[node name="Body" type="Sprite3D" parent="."]',
        f'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {sx:.4f}, {sy:.4f}, 0)',
        f'pixel_size = {px:.6f}',
        'billboard = 2',
        'shaded = false',
        'double_sided = false',
        'alpha_cut = 2',
        'texture_filter = 3',
        'texture = ExtResource("1")',
        '',
    ]
    # z 0.25: a hunter on a hold stands just in front of the drawing.
    for h, (x, y) in sorted(holds.items()):
        lines += [f'[node name="climb_{h}" type="Node3D" parent="."]',
                  f'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {x:.3f}, {y:.3f}, 0.25)', '']
    for h in spec["ledges"]:
        x, y = holds[h]
        lines += [f'[node name="ledge_{h}" type="Node3D" parent="."]',
                  f'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {x:.3f}, {y:.3f}, 0.25)', '']
    tscn = OUT_DIR / f"{beast_id}_2d.tscn"
    tscn.write_text("\n".join(lines))
    print(f"{png.relative_to(ROOT)} {img.size[0]}x{img.size[1]}  "
          f"body {spec['height']:.2f} tall, {(bx.max() - bx.min()) * px:.2f} wide")
    print(f"{tscn.relative_to(ROOT)} holds " + json.dumps({h: [round(x, 2), round(y, 2)] for h, (x, y) in holds.items()}))


if __name__ == "__main__":
    for bid in sys.argv[1:] or list(BEASTS):
        build(bid)
