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
        # TARGET.png shows the jackal from the hips up, rising out of the
        # ground at the lava line, twice the size a whole figure could be in
        # the same frame (checker iter 01, 2026-10-07: framing/scale MAJOR).
        # The drawing is cut at concept row `cut`; `sink` px of it sit below
        # the floor so the cut edge is hidden. The route now starts at the
        # hips and climbs the flank, chest and neck to the face.
        # Checker iter 08 (2026-10-07): at 640 the hips, crotch and thighs
        # stood above the lava, where TARGET cuts the jackal at the waist;
        # now just under the belt.
        "cut": 590,
        "sink": 18,
        "holds": {
            0: (598, 568), 1: (600, 535), 2: (590, 500),
            3: (560, 430), 4: (535, 330), 5: (512, 225),
        },
        "ledges": [0, 2, 3, 4],
        # Concept-pixel boxes round each eye (checker iter 07, 2026-10-07:
        # TARGET's eyes are the hottest point on the head; ours read dim).
        "eyes": [(462, 192, 498, 222), (527, 192, 561, 222)],
        # Concept pixel of the sternum junction and the radius its heat
        # reaches (checker iter 11: TARGET's chest burns yellow-white where
        # the seams meet; ours was the same orange as every other crack).
        "hot": ((512, 355), 70),
        # No "repose" and no "flame" (Nick, 2026-10-06: "The jackal should
        # be able to move. So the direction doesnt matter. Its the quality
        # that im looking for."): the cut-and-rotate arm tore the figure, and
        # the fire belonged to that raised fist. Both stay available above.
    },
}

# TARGET.png, sampled across the rim (2026-10-07): the line is amber-gold,
# (252, 201, 122), not cream. The fight's post chain caps red at ~243 and
# lifts blue a little (the old 255,214,140 reached the screen as a pale
# 243,217,149), so the line is drawn deeper to land on TARGET's gold. Its
# innermost pixel is a hot orange edge, and outside it a warm glow.
LINE = np.array([255, 206, 112], float)
LINE_IN = np.array([250, 140, 45], float)
HALO = np.array([255, 172, 66], float)

# The cracks, widened and heated (see build).
CRACK_GROW = 1
CRACK_EDGE = np.array([222, 72, 24], float)
CRACK_CORE = np.array([255, 214, 96], float)
CRACK_CORE_MIX = 0.4

# The eyes: a near-white core, a hot orange ring and a short glow over the
# rock, so they survive the mipmap as TARGET's two bright points.
EYE_CORE = np.array([255, 244, 190], float)
EYE_RIM = np.array([255, 150, 40], float)
EYE_GLOW = 7
EYE_GLOW_A = 0.55

# The sternum: cracks near it heat toward white-yellow, and the rock right
# round the junction takes a warm orange wash.
HOT_CORE = np.array([255, 240, 170], float)
HOT_WASH = np.array([255, 120, 30], float)
HOT_WASH_A = 0.35

# Draw at the concept's own size. Upscaling it 2x with Lanczos added no
# detail and softened every facet edge into a two-pixel ramp; the game
# mipmaps the texture down to ~330 px anyway (sprite_match "detail", 2026-10-07).
SCALE = 1
# px at 1x. TARGET's line is thin: about 4 px on a 600 px figure, so ~5 px
# on the concept's 930 px one. The old 26 px cream stroke and 10 px ink ring
# ate the ears, the muzzle and the eyes (Nick, 2026-10-06).
# Grader, 2026-10-07: at 5 px the line was a wire inside a halo. TARGET's
# 4-5 px on a 600 px figure is ~7 px on this 930 px one, and sprite_match's
# outline still lands inside its tolerance.
# Checker iter 06 (2026-10-07): beside TARGET the line still read thin and
# the halo wide and diffuse; 9 px line, 20 px halo.
# Checker iter 13: measured on the pair at matched height, our line is 9 px
# to TARGET's 6, and the critic read it as a thick sticker border. 6 px
# measured 5 on screen; 7 measures 6.
LINE_W = 7
# TARGET's glow outside the line: the sky beside it is warmed about a
# quarter of the way to orange, fading over ~12 px of a 600 px figure; the
# game mipmaps the sprite to ~330 px, so it is drawn wider and stronger here
# to survive (grader, 2026-10-07: 0.30 over 22 px read as no glow). At 0.45 and a steep falloff ours read as a second, orange outline;
# at 0.15 it vanished at play size (checker, 2026-10-07).
# Checker iter 10: still a glow bleeding off the line rather than TARGET's
# crisp cel stroke with a slight warmth outside it; 14 px at 0.32.
# Checker iter 13: still a wide hazy halo; 10 px.
HALO_W = 10
HALO_A = 0.32
# The fight sizes the beast by its texture's box, and its camera was framed
# on the old box: 39 px of clear room round the line. Keep it, so the ears
# stay on screen at the same size as before.
MARGIN = 39


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
    body = ndi.binary_opening(body, disk(1))
    body = ndi.binary_fill_holes(body)
    keep, n = ndi.label(body)
    if n > 1:
        sizes = ndi.sum(body, keep, range(1, n + 1))
        body = keep == (int(np.argmax(sizes)) + 1)
    # Smooth the edge so the stroke is a clean line, not the concept's AA.
    body = ndi.gaussian_filter(body.astype(float), 0.75 * SCALE) > 0.5
    cut = spec.get("cut")

    # The figure is the concept's own pixels (Nick, 2026-10-06: "Its the
    # quality that im looking for"): its facet planes, snout, eyes and cracks
    # already are the drawing. Posterising them melted all four, so nothing
    # here repaints the body; it only cuts it off the card and inks the edge.
    # Pull the edge in a pixel so no grey card fringe survives under the line.
    inside = ndi.binary_erosion(body, disk(1))
    out = np.zeros(a.shape[:2] + (4,), float)
    out[..., :3] = a
    # TARGET's cracks are wider than the concept's and burn yellower at the
    # core: on screen its chest seams cover ~25 % with cores reaching
    # (255,205,60), ours 20 % and (255,180,57) (checker iter 05, 2026-10-07).
    # Grow each crack a pixel into the rock in its own red edge colour, then
    # pull the crack's interior toward TARGET's yellow core.
    crack = inside & (r > 150) & (r - b > 90)
    grown = ndi.binary_dilation(crack, disk(CRACK_GROW * SCALE)) & inside & ~crack
    out[grown, :3] = CRACK_EDGE
    core = ndi.binary_erosion(crack, disk(1))
    out[core, :3] += (CRACK_CORE - out[core, :3]) * CRACK_CORE_MIX
    if spec.get("hot"):
        (hx, hy), hr = spec["hot"]
        yy, xx = np.ogrid[:out.shape[0], :out.shape[1]]
        heat = np.clip(1 - np.hypot(xx - hx * SCALE, yy - hy * SCALE) / (hr * SCALE), 0, 1)
        # Near the junction the seams themselves swell into a molten pool.
        swell = ndi.binary_dilation(crack, disk(3 * SCALE)) & inside & (heat > 0.35)
        hc = (crack | grown | swell) & (heat > 0)
        out[hc, :3] += (HOT_CORE - out[hc, :3]) * (heat[hc, None] ** 0.8)
        hw = inside & ~hc & (heat > 0.45)
        t = ((heat[hw] - 0.45) / 0.55)[:, None] ** 1.5 * HOT_WASH_A
        out[hw, :3] += (HOT_WASH - out[hw, :3]) * t
    for ex0, ey0, ex1, ey1 in spec.get("eyes", []):
        box = np.zeros_like(inside)
        box[ey0 * SCALE:ey1 * SCALE, ex0 * SCALE:ex1 * SCALE] = True
        eye = box & inside & (r > 200) & (g > 110)
        d = ndi.distance_transform_edt(~eye)
        glow = inside & ~eye & (d < EYE_GLOW * SCALE)
        t = (np.clip(1 - d / (EYE_GLOW * SCALE), 0, 1) ** 1.5 * EYE_GLOW_A)[glow, None]
        out[glow, :3] += (EYE_RIM - out[glow, :3]) * t
        out[eye, :3] = EYE_RIM
        out[ndi.binary_erosion(eye, disk(1)), :3] = EYE_CORE
    out[inside, 3] = 255

    # TARGET.png's edge: a thin warm line hugging the figure, and outside it
    # a faint orange glow. The body stays dark; only the cracks burn.
    ring = ndi.binary_dilation(inside, disk(LINE_W)) & ~inside
    out[ring, :3] = LINE
    out[ring, 3] = 255
    inner = ring & ndi.binary_dilation(inside, disk(1))
    out[inner, :3] = LINE_IN
    dist = ndi.distance_transform_edt(~(inside | ring))
    halo = ~(inside | ring) & (dist < HALO_W)
    fall = np.clip(1 - dist / HALO_W, 0, 1) ** 1.5 * HALO_A
    out[halo, :3] = HALO
    out[halo, 3] = 255 * fall[halo]

    if cut:
        # Below the cut nothing is drawn: no body, no line, no halo. The line
        # is NOT closed along the cut -- that edge is under the floor.
        out[cut * SCALE:, 3] = 0
        inside[cut * SCALE:] = False
        ring[cut * SCALE:] = False
        body = body.copy()
        body[cut * SCALE:] = False
    # Crop to the drawing plus margin; keep the concept's feet as the origin.
    ys, xs = np.nonzero(inside | ring)
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
    if cut:
        feet_px -= spec.get("sink", 0) * SCALE   # the floor line, inside the cut
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
        f'[gd_scene load_steps={7 if flame else 4} format=3]',
        '',
        f'[ext_resource type="Texture2D" path="res://assets/3d/cast/{png.name}" id="1"]',
        '',
        # The drawing shows its own pixels: the scene's tonemap and fog are
        # undone for it (see the shader and tools/drawn_lut.py).
        '[ext_resource type="Shader" path="res://assets/3d/drawn_sprite.gdshader" id="3"]',
        '',
        '[sub_resource type="ShaderMaterial" id="ShaderMaterial_drawn"]',
        'shader = ExtResource("3")',
        'shader_parameter/tex = ExtResource("1")',
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
        'material_override = SubResource("ShaderMaterial_drawn")',
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
