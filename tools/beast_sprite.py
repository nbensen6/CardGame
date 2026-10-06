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
import math
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw
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
        # TARGET.png's pose out of the concept's arms-down turnaround (Nick,
        # 2026-10-06: "use the reference again ... design"): the arm on the
        # viewer's left is cut into upper arm and forearm+fist, the upper arm
        # swung out to the side about the shoulder and the forearm swung up
        # about the elbow, so the fist is raised beside the head. Concept
        # pixels; degrees clockwise on screen. `nudge` slides the forearm onto
        # the upper arm so the elbow stays one piece.
        "repose": [
            {"poly": [(300, 335), (400, 335), (405, 430), (360, 470), (285, 470)],
             "pivot": (365, 345), "deg": 70},
            {"poly": [(170, 370), (250, 360), (345, 440), (340, 520), (300, 560),
                      (320, 670), (160, 680), (150, 520)],
             "pivot": (300, 460), "deg": 150, "nudge": (30, 0)},
        ],
        # The raised fist burns at rest (TARGET.png): flame centre and size
        # on the REPOSED concept, in concept pixels.
        "flame": {"at": (205, 148), "size": (300, 230)},
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
CREAM_W = 52       # px at 2x: bold enough to read at play size (grader, 2026-10-06)
INK_W = 20
HALO_W = 40
MARGIN = 2


def disk(r):
    y, x = np.ogrid[-r:r + 1, -r:r + 1]
    return x * x + y * y <= r * r


def _rot(p, c, deg):
    t = math.radians(deg)
    x, y = p[0] - c[0], p[1] - c[1]
    return (c[0] + x * math.cos(t) - y * math.sin(t),
            c[1] + x * math.sin(t) + y * math.cos(t))


def repose(src, pieces):
    """Cut limbs out of the concept and swing them about their joints.

    Each piece is the figure inside `poly`, rotated `deg` about `pivot`. A
    piece after the first rides on the one before it: its pivot follows
    where the previous rotation carried it (plus `nudge`), like a forearm on
    an upper arm. What a piece leaves behind becomes the grey card.
    """
    a = np.asarray(src).astype(float)
    mn, mx = a.min(-1), a.max(-1)
    fg = ~((mn > 170) & (mx - mn < 26))
    card = np.median(a[~fg], 0)
    masks = []
    for pc in pieces:
        m = Image.new("L", src.size, 0)
        ImageDraw.Draw(m).polygon(pc["poly"], fill=255)
        masks.append((np.asarray(m) > 0) & fg)
    base = a.copy()
    for m in masks:
        base[m | (ndi.binary_dilation(m, iterations=4) & ~fg)] = card
    out = Image.fromarray(base.astype(np.uint8))
    prev = None
    for pc, m in zip(pieces, masks):
        piv = pc["pivot"]
        dst = piv
        if prev is not None:
            moved = _rot(piv, prev["pivot"], prev["deg"])
            dst = (moved[0] + pc.get("nudge", (0, 0))[0], moved[1] + pc.get("nudge", (0, 0))[1])
        t = math.radians(pc["deg"])
        c, s_ = math.cos(t), math.sin(t)
        inv = (c, s_, piv[0] - c * dst[0] - s_ * dst[1],
               -s_, c, piv[1] + s_ * dst[0] - c * dst[1])
        layer = Image.fromarray(np.dstack([a, m * 255.0]).astype(np.uint8), "RGBA")
        layer = layer.transform(src.size, Image.AFFINE, inv, resample=Image.BICUBIC)
        out.paste(layer, (0, 0), layer)
        prev = pc
    return out


FLAME_FRAMES = 8
# TARGET.png's fist fire: a cream-yellow core inside orange inside a deep
# red-orange skin, hard-edged bands like the cracks, no outline.
FLAME_BANDS = [(0.0, (238, 92, 26)), (0.32, (255, 150, 40)),
               (0.58, (255, 210, 90)), (0.8, (255, 244, 196))]


def flame_frames(w, h):
    """FLAME_FRAMES looping frames of a flat drawn flame, side by side.

    Time enters only as whole turns of a sine, so the last frame runs
    seamlessly back into the first. Deterministic.
    """
    v = np.linspace(1.0, -0.16, h)[:, None]        # 0 at the base, 1 at the tip
    u = np.linspace(-1.0, 1.0, w)[None, :]
    strip = np.zeros((h, w * FLAME_FRAMES, 4), np.uint8)
    for f in range(FLAME_FRAMES):
        ph = 2.0 * math.pi * f / FLAME_FRAMES
        # Tongues lick upward: the noise scrolls up the flame once per loop.
        n = (0.55 * np.sin(5.0 * u + 9.0 * v - ph + 0.7)
             + 0.35 * np.sin(-8.0 * u + 14.0 * v - 2.0 * ph + 2.1)
             + 0.25 * np.sin(13.0 * u + 21.0 * v - 3.0 * ph + 4.0))
        sway = 0.10 * np.sin(ph + 3.0 * v) * v
        # A teardrop: widest a third of the way up, a point at the tip.
        width = 0.92 * np.clip(np.sin(np.pi * np.clip(0.3 + v * 0.75, 0, 1)), 0, 1) ** 0.8
        width = width * (1.0 - 0.55 * v ** 2)
        heat = 1.0 - np.abs(u - sway) / np.maximum(width, 1e-3)
        heat = heat - 0.45 * v + 0.2 * n * (0.3 + v)
        # A rounded foot under the fist, not a cut-off base.
        heat = heat - 6.0 * np.clip(-v, 0, None) - 2.0 * np.abs(u) * np.clip(-v, 0, None) * 6.0
        heat = ndi.gaussian_filter(heat, 1.2)
        frame = np.zeros((h, w, 4), np.uint8)
        for lo, col in FLAME_BANDS:
            m = heat > lo
            frame[m, :3] = col
            frame[m, 3] = 255
        strip[:, f * w:(f + 1) * w] = frame
    return Image.fromarray(strip, "RGBA")


def build(beast_id):
    spec = BEASTS[beast_id]
    src = Image.open(ROOT / spec["concept"]).convert("RGB")
    if spec.get("repose"):
        src = repose(src, spec["repose"])
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
    # TARGET's cracks are hot enough to light the rock a hand's width out.
    glow = ndi.gaussian_filter(crack.astype(float), 16) * 3.0
    glow = np.clip(glow, 0, 1)[..., None] * (body & ~crack)[..., None]
    out[..., :3] = out[..., :3] * (1 - 0.75 * glow) + HALO * 0.75 * glow

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
    flame = spec.get("flame")
    if flame:
        # The flame is its own sprite, but the body's texture is widened to
        # cover it, so the fight's _fit_height (which reads the merged box)
        # measures the same beast with or without the fire.
        fw, fh = flame["size"][0] * SCALE, flame["size"][1] * SCALE
        fx, fy = flame["at"][0] * SCALE, flame["at"][1] * SCALE
        x0 = min(x0, int(fx - fw / 2))
        x1 = max(x1, int(fx + fw / 2) + 1)
        assert fy - fh / 2 >= y0, "the flame must not raise the beast's top"
        assert x0 >= 0, "the flame runs off the concept"
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
        f'[gd_scene load_steps={5 if flame else 2} format=3]',
        '',
        f'[ext_resource type="Texture2D" path="res://assets/3d/cast/{png.name}" id="1"]',
        '',
    ]
    if flame:
        fpng = OUT_DIR / f"{beast_id}_2d_flame.png"
        flame_frames(fw, fh).save(fpng, optimize=True)
        step = 0.1
        times = ", ".join(f"{i * step:g}" for i in range(FLAME_FRAMES))
        lines += [
            f'[ext_resource type="Texture2D" path="res://assets/3d/cast/{fpng.name}" id="2"]',
            '',
            '[sub_resource type="Animation" id="Animation_idle"]',
            'resource_name = "idle"',
            f'length = {FLAME_FRAMES * step:g}',
            'loop_mode = 1',
            f'step = {step:g}',
            'tracks/0/type = "value"',
            'tracks/0/imported = false',
            'tracks/0/enabled = true',
            'tracks/0/path = NodePath("Fire:frame")',
            'tracks/0/interp = 0',
            'tracks/0/loop_wrap = true',
            'tracks/0/keys = {',
            f'"times": PackedFloat32Array({times}),',
            f'"transitions": PackedFloat32Array({", ".join(["1"] * FLAME_FRAMES)}),',
            '"update": 1,',
            f'"values": [{", ".join(str(i) for i in range(FLAME_FRAMES))}]',
            '}',
            '',
            '[sub_resource type="AnimationLibrary" id="AnimationLibrary_1"]',
            '_data = {',
            '&"idle": SubResource("Animation_idle")',
            '}',
            '',
        ]
    lines += [
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
    if flame:
        x, y = world(flame["at"])
        # Just behind the drawing: the fist and its outline sit in the fire.
        lines += [
            '[node name="Fire" type="Sprite3D" parent="."]',
            f'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {x:.4f}, {y:.4f}, -0.01)',
            f'pixel_size = {px:.6f}',
            'billboard = 2',
            'shaded = false',
            'double_sided = false',
            'alpha_cut = 1',
            'texture_filter = 3',
            'texture = ExtResource("2")',
            f'hframes = {FLAME_FRAMES}',
            '',
            '[node name="AnimationPlayer" type="AnimationPlayer" parent="."]',
            'libraries = {',
            '&"": SubResource("AnimationLibrary_1")',
            '}',
            'autoplay = &"idle"',
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
