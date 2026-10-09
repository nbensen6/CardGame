"""Cut the jackal out of TARGET.png into rig layers, and write the scene that
animates them.

    python3 tools/beast_rig.py

Nick, 2026-10-07: "the rest pose and design must match his drawing" and "the
jackal must be animated". So the art is not a new drawing: every layer is
TARGET.png's own pixels, cut along the joints, and the rest frame is TARGET's
jackal 1:1. Only what TARGET hides is repainted: the lower torso behind the
stones (inpainted from the rock round it), and the overlap at each joint (the
parent keeps a band of the child's pixels under the cut, so a part that
rotates shows rock under it, never a hole). The fist's fire is its own layer.

Writes, into game/assets/3d/cast/:
  cinder_jackal_2d.png         the rest frame (every layer composited); the
                               Sprite3D's texture until the rig's viewport
                               takes over, and what sprite_match.py measures
  cinder_jackal_2d_<part>.png  one per layer, cropped to its pixels
  cinder_jackal_2d.tscn        Sprite3D billboard + SubViewport rig +
                               AnimationPlayer (idle, attack, hit, death) +
                               climb_/ledge_ markers

Needs Pillow, numpy, scipy and opencv (cv2.inpaint). Deterministic.
"""
import json
import math
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage as ndi
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import crack_synth

ROOT = Path(__file__).resolve().parent.parent
TARGET = ROOT / "design/art/targets/TARGET.png"
OUT = ROOT / "game/assets/3d/cast"
ID = "cinder_jackal"

# Everything below is in TARGET.png pixels (1024 square).
CUT = 534          # the lava line: TARGET cuts the jackal here
SINK = 14          # rows repeated under the cut, hidden by the floor
# Canvas: the ears top out at y 55; the fire reaches x 157 at rest and the
# swung fist ~90 px further left, which the canvas must hold or it clips.
BOX = (50, 40, 830, CUT + SINK)
# The columns the fight frames: the figure and its fire at rest.
FIGURE_X = (140, 830)
# Where TARGET's stones cross the body.
STONE_BOX = [(330, 355), (648, 355), (648, 530), (330, 530)]
INPAINT_STONES = True
# 2026-10-08 (queue "Cracks: wide hot cores and a long sternum seam"): the
# fight now draws the jackal at TARGET's size and place and TARGET's own
# slabs exactly over TARGET's stones, so the body only has to be filled
# where a stone's own pixels are. The wide fills (borrowed blocks and the
# inpainted STONES rects) wiped out TARGET's sternum seam between the
# stones and read as a dark smudge round them. TIGHT keeps every TARGET
# pixel that is not stone and inpaints only the stones, grown a little.
TIGHT = True
TIGHT_GROW = 3
# 2026-10-09: the holes are rebuilt by tools/crack_synth.py, not inpainted.
CRACK_SYNTH = True
# TARGET's own dark rock in a stone's grown ring is kept, not rebuilt (max channel below this).
KEEP_DARK = 70
# 0 since 2026-10-08: the fight draws the jackal at TARGET's place, its cut
# on TARGET's lava line, so TARGET's own glow rows show and the ramp only
# hazed the hips orange (grader, "Cracks: wide hot cores").
UPLIGHT = 0.0
UPLIGHT_SPAN = 110
UPLIGHT_COLOR = (255, 105, 25)
ROCK_DARK = (52, 26, 22)
# Each of TARGET's slabs over the body, (x0, y0, x1, y1), read off a 3x crop
# of TARGET.png. The grey test alone missed their orange-lit undersides and
# left a slab's ghost on the belly, with a hard edge where the patch met it
# (checker r2 iter 11: both critics' top MAJOR). Every pixel in these, a few
# px grown, is stone whatever its colour.
STONES = [(495, 364, 560, 388), (552, 382, 636, 415), (520, 414, 593, 443),
          (440, 437, 538, 473), (335, 464, 485, 513)]
SCALE = 2          # layers are drawn at 2x for a clean line in the fight
HEIGHT = 1.90      # world height floor-to-ear-tip before _fit_height

# The gold line is TARGET's own outline; where a stone hides it, or the lava
# fades it, these walls close the silhouette (picked on a 1:1 grid).
WALLS = [
    [(470, 428), (455, 470), (425, 505), (418, 536)],   # left flank, behind stones
    [(806, 500), (808, 536)],                          # right fist into the lava
    [(628, 372), (605, 416)],                          # right flank, behind a stone
    [(626, 495), (641, 536)],                          # torso / right-arm gap
    [(683, 500), (686, 536)],
]
# How near TARGET's own line a wall may run before it draws no line of its own.
WALL_DOUBLE = 12
SEED = (513, 380)  # the chest

# Parts: (name, parent, pivot, region polygon). A part owns the figure's
# pixels inside its polygon and outside every later part's; the torso owns
# the rest. Pivots sit at the joint the part turns on.
PARTS = [
    ("head", "torso", (512, 288),
     [(425, 45), (600, 45), (592, 200), (580, 250), (560, 282), (512, 300), (465, 285), (447, 250), (438, 200)]),
    ("arm_r", "torso", (652, 268),
     [(612, 212), (640, 150), (870, 150), (870, 560), (684, 560), (640, 350), (625, 300)]),
    ("fore_r", "arm_r", (735, 378),
     [(690, 345), (835, 405), (835, 560), (684, 560), (655, 400)]),
    ("arm_l", "torso", (408, 298),
     [(140, 60), (380, 60), (390, 236), (442, 300), (430, 356), (330, 445), (140, 445)]),
    ("fore_l", "arm_l", (315, 372),
     [(140, 60), (360, 60), (352, 300), (300, 445), (140, 445)]),
]
# How far a parent keeps its child's pixels under the cut, TARGET px.
UNDERLAY = 26
# TARGET's rim, px: the gold line plus its hot inner edge.
RIM = 8
INK_UNDERLAY = True   # off only to debug a joint
# Draw order, back to front. The fire sits behind the fist it wraps.
# The fire goes under the raised arm too: where the figure hid it, it is
# grown in (fire_layer), and only shows once the fist swings away.
ORDER = ["torso", "arm_r", "fore_r", "head", "fire", "arm_l", "fore_l"]
FIRE_BOX = [(140, 80), (380, 80), (380, 330), (140, 330)]   # TARGET px, round the fist
# The fire licks: FIRE_FRAMES frames of TARGET's flame, each warped by a wave
# that climbs the flame once a loop, so its tongues sway and stretch upward
# off the fist instead of the whole ball pulsing (Nick's queue, 2026-10-08:
# "flame tongues, not a sun disc"). FIRE_BASE is the row (TARGET px) the
# tongues rise from: below it nothing moves, the fist's own glow stays put.
FIRE_FRAMES = 8
FIRE_FPS = 10.0
FIRE_BASE = 250
FIRE_SWAY = 2.5       # TARGET px, sideways at the very tip
FIRE_LIFT = 3.5       # TARGET px, how far a tip stretches up
# TARGET's flame is a plume trailing up and back off the fist. The canvas
# top is the flame's top (a taller canvas would shrink the whole beast,
# _fit_height reads it), so above FIRE_BASE the plume leans back instead:
# FIRE_LEAN px left per px of height. Below the base only a FIRE_HUG px skirt
# hugs the fist (the round bowl under it read as a sun disc, grader
# 2026-10-08), and fire within FIRE_CORE px of the fist burns yellow-white.
FIRE_LEAN = 0.32
# 2026-10-08 (queue "Fist fire: compact curling blaze wrapped on the fist"):
# TARGET's own flame, unwarped. The lean, the cream core and the orange
# edge pushed it into a tall pale plume off the fist; TARGET's is a compact
# orange-yellow blaze curling round the top and back of the fist.
FIRE_RAW = True
# Edge-keeping smooth of the flame's colours (see build()).
FIRE_SMOOTH = True
# "nlm": non-local means instead of the bilateral (builder 2026-10-09 run
# 13): the bilateral at 11/40 took the grain out but blurred the curl
# strokes (Laplacian in the flame 11.8 against TARGET's 15.1); NL-means
# averages like patches along each tongue, so the grain goes and the strokes
# stay.
FIRE_DENOISE = "nlm"
FIRE_NLM_H = 6
FIRE_MEDIAN = 5          # canvas px; "median": a median takes the grain and keeps the strokes' edges
# The colour path loses ~10-20 green in the flame's lemon core where red
# clips (registered: TARGET (255,237,52) drew (255,224,56)); green above
# FIRE_LIFT_FROM is lifted by up to FIRE_LIFT_G before it.
FIRE_LIFT_FROM = 170.0
FIRE_LIFT_G = 0.0   # 16 tried: no change on screen, the core is at the scene's gamut edge
FIRE_EDGE_PX = 1.5
FIRE_UNDER_FIST = 12.0   # canvas px
FIRE_TONE_FIX = False
# The colour path steepens the flame's yellows ~4x, so a smooth 8-bit
# gradient shows its 1-level steps as bands; a +-FIRE_DITHER level
# deterministic dither after the smooth breaks them up.
FIRE_DITHER = 1.0
FIRE_SMOOTH_D = 11
FIRE_SMOOTH_SC = 40.0
FIRE_SMOOTH_SS = 5.0
# Unsharp on the smoothed flame (canvas px sigma, gain): TARGET's curl
# strokes read inked; after the resample the game's read soft (grader R3).
FIRE_INK_SIG = 2.5
FIRE_INK = 0.0   # 0.7 on the NL-means output (run 13) drew contour striations round the fist; 0.8 on the bilateral (run 9) brought the grain back
FIRE_SHELL_PX = 0.0       # canvas px (2x TARGET) of the flame's outer shell
FIRE_SHELL_R = (110.0, 165.0)   # red: fully faded .. fully kept
FIRE_HAZE = 0.92        # 0.92 until the backdrop (tools/backdrop_cut.py) carried TARGET's glow itself
FIRE_HAZE_PX = 55.0    # TARGET px it fades over
FIRE_MAX_A = 1.0       # 0.95 (under halo_from, no halo) tried 2026-10-09: no visible change, error up
FIRE_HUG = 22
FIRE_CORE = 24
FIRE_HOT = np.array([255, 244, 196], float)
FIRE_EDGE = np.array([236, 84, 24], float)

# Climb holds: where TARGET's six slabs sit on screen, the centre of each top
# face, from the foreground left of the Frog up and right across the body to
# the top one just under the sternum, where the cracks meet (Nick,
# 2026-10-07: "stone design and placement"). The fight hangs slab k on the
# rest camera's sight line through hold k (combat_3d.stair_slab), so the rest
# shot draws each slab where TARGET does. 5 is the sigil, under the sternum.
HOLDS = {0: (360, 560), 1: (410, 485), 2: (489, 450), 3: (556, 425), 4: (594, 397), 5: (526, 375)}
LEDGES = [0, 2, 3, 4]

LINE = np.array([252, 201, 122], float)   # TARGET's rim, sampled
# TARGET's soft glow outside the rim: about 9 TARGET px, drawn by the shader
# from the moving figure's alpha (drawn_sprite.gdshader `halo`).
HALO = 0.6
HALO_PX = 9 * SCALE


def poly_mask(pts, shape):
    im = Image.new("L", (shape[1], shape[0]), 0)
    ImageDraw.Draw(im).polygon(pts, fill=255)
    return np.asarray(im) > 0


def fill_small(x, most=3000):
    h, n = ndi.label(~x)
    if n == 0:
        return x
    sizes = ndi.sum(np.ones_like(h), h, range(1, n + 1))
    return x | np.isin(h, [i + 1 for i, v in enumerate(sizes) if v < most])


def silhouette(T):
    r, g, b = T[..., 0], T[..., 1], T[..., 2]
    line = (r > 215) & (g > 150) & (b > 70) & (b < 190) & (r - b > 60)
    H, W = line.shape
    walls = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(walls)
    for w in WALLS:
        d.line(w, fill=255, width=3)
    walls = np.asarray(walls) > 0
    block = ndi.binary_dilation(line, iterations=2) | walls
    block[CUT:] = True
    lab, _ = ndi.label(~block)
    reg = lab == lab[SEED[1], SEED[0]]
    m = fill_small(reg | (ndi.binary_dilation(reg, iterations=9) & ndi.binary_dilation(line)))
    m[CUT:] = False
    return fill_small(m), line, walls


# Where to borrow rock for each hole a stone leaves: the same body, this far
# away (TARGET px), so the fill keeps TARGET's facets and cracks instead of
# a blur. The first offset whose source is clean body wins, per hole.
BORROW = [(0, 75), (0, -75), (-70, 0), (70, 0), (0, 120), (0, -120), (-60, 60), (60, 60),
          (0, 45), (0, -45), (-40, 0), (40, 0), (-35, 35), (35, 35), (-35, -35), (35, -35)]


def paint_hidden(T, m, line, walls):
    """Lift the stones off the body and close the line they hid."""
    mx, mn = T.max(2), T.min(2)
    # Only where TARGET's stones are: elsewhere a grey-ish pixel is rock lit
    # by the cliff behind it, and patching it wrecked the far arm.
    stone = m & (mx - mn < 45) & (mx > 60) & poly_mask(STONE_BOX, m.shape)
    stone = ndi.binary_opening(stone, iterations=1)
    rects = np.zeros_like(m)
    for x0, y0, x1, y1 in STONES:
        rects[y0:y1, x0:x1] = True
    if TIGHT:
        raw_stone = stone
        stone = ndi.binary_dilation(stone, iterations=TIGHT_GROW) & m
        rim = m & ~ndi.binary_erosion(m, iterations=RIM + 3)
        src = np.clip(T, 0, 255).astype(np.uint8).copy()
        hole = stone & ~rim
        # A stone's pale lit edge and its grey fringe reach past the grown
        # mask; inpainted from, they smear a cream blob under the sternum
        # seam where the fight's slab sits a few px off TARGET's. Any pale,
        # unsaturated pixel just round a hole goes into the hole too.
        sat = (mx - mn) / np.maximum(mx, 1)
        pale = (sat < 0.45) & (mx > 110) & ndi.binary_dilation(hole, iterations=6) & m & ~rim
        hole = hole | ndi.binary_dilation(pale, iterations=1) & m & ~rim
        # Where a stone crosses the outline its grey ends sat in the rim,
        # outside the hole, and showed as pale smudges beside the fight's
        # slabs. They are filled too, from rock only (the line and the sky
        # masked dark so neither smears in); _finish_body redraws the line.
        band = m & ~ndi.binary_erosion(m, iterations=5)
        hole = hole | (stone & rim & ~band)
        src[~m | band] = ROCK_DARK
        src[band & line & ~stone] = ROCK_DARK
        out = cv2.inpaint(src, hole.astype(np.uint8) * 255, 5, cv2.INPAINT_TELEA).astype(float)
        keep = ~hole
        out[keep] = T[keep]
        if CRACK_SYNTH:
            # Rock without crack smears, and every crack that runs under a
            # stone carried on through it (tools/crack_synth.py): where the
            # fight's slab sits a few px off TARGET's, the body round it
            # reads as TARGET's cracked rock, the sternum seam included.
            inner = hole & ~rim
            inp = out.copy()
            syn, *_ = crack_synth.fill(T, inner, m, ~rim)
            out[inner] = syn[inner]
            if KEEP_DARK:
                # The grown rings of two neighbouring stones also covered
                # TARGET's own dark rock in the narrow gap between them; where
                # the fight's slab sits a px off TARGET's, the synth crack
                # drawn there showed as an orange fleck and a red smear
                # (grader, run 11). In such a gap no crack is drawn and
                # TARGET's own dark pixels stay.
                # Each stone pixel belongs to the nearest STONES rect, by
                # distance to the rect (two slabs' pixels touch where their
                # gap narrows, so a label would merge them).
                ys, xs = np.nonzero(raw_stone)
                R = np.array(STONES, float)
                dx = np.maximum(np.maximum(R[None, :, 0] - xs[:, None], xs[:, None] - R[None, :, 2]), 0)
                dy = np.maximum(np.maximum(R[None, :, 1] - ys[:, None], ys[:, None] - R[None, :, 3]), 0)
                own = np.argmin(np.hypot(dx, dy), 1)
                cover = np.zeros(m.shape, np.int32)
                for k in range(len(STONES)):
                    sk = np.zeros(m.shape, bool)
                    sk[ys[own == k], xs[own == k]] = True
                    cover += ndi.binary_dilation(sk, iterations=TIGHT_GROW + 3)
                gap = inner & ~raw_stone & (cover >= 2)
                gap = ndi.binary_dilation(gap, iterations=1) & inner & ~raw_stone
                out[gap] = inp[gap]
                dark = gap & (mx < KEEP_DARK)
                out[dark] = T[dark]
        else:
            out = carry_seam(out, hole)
        # The band's stone pixels: the line goes back over them below.
        # Only the stone's own pixels: the grown ring poked out under a
        # slab's edge as a cream speck beside TARGET's line (queue, "Inner
        # arm outlines beside the stones"); there TARGET's own dark rock stays.
        out[raw_stone & band] = LINE
        return _finish_body(out, T, m, line, walls, stone)
    stone = (ndi.binary_dilation(stone, iterations=6) | ndi.binary_dilation(rects, iterations=3)) & m
    edge = m & ~ndi.binary_erosion(m, iterations=6)
    clean = m & ~stone & ~edge
    clean[CUT - 20:] = False
    out = T.copy()
    holes, n = ndi.label(stone)
    H, W = m.shape
    sat = (mx - mn) / np.maximum(mx, 1)
    hot = (mx > 150) & (sat > 0.45)
    for i in range(1, n + 1):
        ys, xs = np.nonzero(holes == i)
        hole = holes == i
        ring_y, ring_x = np.nonzero(ndi.binary_dilation(hole, iterations=4) & ~hole & clean)
        best, score = None, -1e9
        for dx, dy in BORROW:
            sy, sx = ys + dy, xs + dx
            ok = (sy >= 0) & (sy < H) & (sx >= 0) & (sx < W)
            ok[ok] = clean[sy[ok], sx[ok]]
            # Prefer plain rock to a hot seam: a borrowed crack doubles one
            # TARGET already shows (sprite_match's "crack cover").
            heat = hot[np.clip(sy, 0, H - 1), np.clip(sx, 0, W - 1)].mean()
            # ...and a source whose border matches the hole's, so the patch
            # does not read as a pasted rectangle (grader, 2026-10-07).
            ry, rx = ring_y + dy, ring_x + dx
            inb = (ry >= 0) & (ry < H) & (rx >= 0) & (rx < W)
            miss = np.abs(T[ry[inb], rx[inb]] - T[ring_y[inb], ring_x[inb]]).mean() if inb.any() else 255
            sc = ok.mean() - 3.0 * heat - miss / 40.0
            if sc > score:
                best, score = (dx, dy), sc
        dx, dy = best
        sy, sx = np.clip(ys + dy, 0, H - 1), np.clip(xs + dx, 0, W - 1)
        out[ys, xs] = T[sy, sx]
    # Whatever no offset reached cleanly, and the seam round each hole.
    patch = np.clip(out, 0, 255).astype(np.uint8)
    seam = ndi.binary_dilation(stone, iterations=2) & ~ndi.binary_erosion(stone, iterations=2) & m
    patch = cv2.inpaint(patch, seam.astype(np.uint8) * 255, 3, cv2.INPAINT_TELEA)
    # The hand-picked slabs (STONES) are filled from the rock round them, not
    # borrowed: a borrowed block brought its own seams and cracks and read as
    # a pasted rectangle with a second sternum seam (r2 iter 11).
    if INPAINT_STONES:
        # The silhouette's gold line is kept out of the fill: masked to the
        # rock's own dark tone while inpainting, so it cannot smear inward,
        # then put back.
        rim = m & ~ndi.binary_erosion(m, iterations=RIM + 3)
        hard = ndi.binary_dilation(rects, iterations=5) & m & ~rim
        src = patch.copy()
        src[rim | ~m] = ROCK_DARK
        filled = cv2.inpaint(src, hard.astype(np.uint8) * 255, 9, cv2.INPAINT_TELEA).astype(float)
        # The inpaint alone is a dark smudge (r2 iter 12: "a smoky column over
        # the belly", both critics). So each hole takes TARGET's own cracked
        # rock from the cleanest nearby offset, laid over the smudge with a
        # feathered edge: cracks and facets, no pasted rectangle.
        okay = m & ~rim & ~ndi.binary_dilation(rects | stone, iterations=4)
        okay[CUT - 20:] = False
        H2, W2 = m.shape
        holes2, n2 = ndi.label(hard)
        yellow = (T[..., 0] > 225) & (T[..., 1] > 170)
        feather = np.clip(ndi.distance_transform_edt(hard) / 7.0, 0, 1)
        for i in range(1, n2 + 1):
            ys, xs = np.nonzero(holes2 == i)
            best, score = None, -1e9
            # Never straight up: from the belly's centre line that lands on the
            # sternum seam and paints a second one.
            for dx, dy in [(-90, -40), (90, -40), (-110, 0), (110, 0), (-70, -70), (70, -70),
                           (-140, -30), (140, -30), (-60, 30), (60, 30)]:
                sy, sx = ys + dy, xs + dx
                inb = (sy >= 0) & (sy < H2) & (sx >= 0) & (sx < W2)
                good = np.zeros_like(inb)
                good[inb] = okay[sy[inb], sx[inb]]
                # No borrowed sternum: a second bright Y down the belly is
                # worse than plain rock.
                heat2 = yellow[np.clip(sy, 0, H2 - 1), np.clip(sx, 0, W2 - 1)].mean()
                sc = good.mean() - 6.0 * heat2
                if sc > score:
                    best, score = (dx, dy), sc
            dx, dy = best
            sy, sx = np.clip(ys + dy, 0, H2 - 1), np.clip(xs + dx, 0, W2 - 1)
            src_px = T[sy, sx].astype(float)
            use = okay[sy, sx][:, None]
            a = feather[ys, xs][:, None]
            filled[ys, xs] = np.where(use, filled[ys, xs] * (1 - a) + src_px * a, filled[ys, xs])
        patch[hard] = np.clip(filled[hard], 0, 255).astype(np.uint8)
    out = patch.astype(float)
    return _finish_body(out, T, m, line, walls, stone)


# TARGET's sternum seam runs as one yellow line from the Y to the top stone
# (x 504-513, down to y 363) and the stone hides where it goes next; below
# the stone the channel is orange again (y 387+). The inpaint smeared it
# into an orange haze wherever the fight's slab sits a few px off TARGET's
# (grader, run 5: "a diffuse orange smear behind the top stone"). Under the
# stone, and only there, the seam carries on: yellow into orange.
SEAM_TOP, SEAM_BOT = (508.5, 356), (508.5, 392)
SEAM_W = 8.0
SEAM_HOT = np.array([252, 196, 40], float)
SEAM_END = np.array([236, 96, 14], float)


def carry_seam(out, hole):
    H, W = hole.shape
    yy, xx = np.mgrid[0:H, 0:W].astype(float)
    (x0, y0), (_, y1) = SEAM_TOP, SEAM_BOT
    t = np.clip((yy - y0) / (y1 - y0), 0, 1)
    d = np.abs(xx - x0)
    a = np.clip((SEAM_W / 2 + 0.5 - d), 0, 1) * (yy >= y0) * (yy <= y1)
    a = ndi.gaussian_filter(a, 0.6) * hole
    col = SEAM_HOT[None, None] * (1 - t[..., None] ** 1.5) + SEAM_END[None, None] * t[..., None] ** 1.5
    return out * (1 - a[..., None]) + col * a[..., None]


def _finish_body(out, T, m, line, walls, stone):
    # TARGET's lava up-light: the bottom of the torso glows orange into the
    # cut. In the fight the floor's lava strip hides the sprite's last rows,
    # where TARGET's own glow lives, so the lower body read as an unlit dark
    # blob (r2 iter 13, both critics). Screen a warm ramp over the lower body
    # so the glow starts above what the floor hides.
    if UPLIGHT:
        yy = np.arange(m.shape[0], dtype=float)[:, None]
        ramp = np.clip((yy - (CUT - UPLIGHT_SPAN)) / UPLIGHT_SPAN, 0, 1) ** 1.6 * UPLIGHT
        ramp = np.where(m, ramp, 0.0)[..., None]
        warm = np.array(UPLIGHT_COLOR, float)
        out = 255.0 - (255.0 - out) * (1.0 - ramp * warm / 255.0)
    # The silhouette's own line, wherever the cut-out has none (behind the
    # stones, where the walls run): a band as wide as TARGET's rim.
    band = m & ~ndi.binary_erosion(m, iterations=5)
    near = ndi.binary_dilation(walls | stone, iterations=4)
    need = band & near & ~line
    # Where a wall runs a few px inside TARGET's own line (the left flank
    # under the bottom stone, the torso / right-arm gap), the painted band
    # drew a second, jagged line beside TARGET's (queue, "Inner arm outlines
    # beside the stones"). TARGET's line there is lit orange-cream, dimmer
    # than `line` takes; any such pixel (saturated, so not a grey stone)
    # within WALL_DOUBLE px and near the silhouette's edge, means the wall needs no line of its own.
    if WALL_DOUBLE:
        rim_zone = ~ndi.binary_erosion(m, iterations=12)
        tline = (T[..., 0] > 170) & (T[..., 1] > 95) & (T[..., 0] - T[..., 2] > 80) & rim_zone
        own = ndi.binary_dilation(tline, iterations=WALL_DOUBLE) & ndi.binary_dilation(walls, iterations=7)
        need &= ~own
    need[CUT - 3:] = False
    out[need] = LINE
    return out


def fire_layer(T, m):
    inside = poly_mask(FIRE_BOX, m.shape)
    box = inside & ~m
    r, g, b = T[..., 0], T[..., 1], T[..., 2]
    if FIRE_RAW:
        # Against TARGET's dark slate, so the dark red tips of the tongues
        # stay flame (a bright-only key cut them and left round puffs).
        # Solid down into the dark red glow between the tongues: a half-keyed
        # glow took the shader's orange halo (it fills every pixel under
        # alpha 1) and the gaps read as one orange disc.
        # A hard key on the drawn tongues: the dark glow round them read as
        # a smoky halo over the game's lighter cliffs, and half-keyed glow
        # took the shader's halo and filled the gaps orange.
        a = ((r > 125) & (r - b > 75)).astype(float)
    else:
        a = np.clip((np.maximum(r, g) - 150) / 70, 0, 1) * np.clip((r - b - 70) / 50, 0, 1)
    a = a * box
    # A drawn flame has a crisp edge. The soft ramp kept TARGET's glow round
    # the fire as a faint rim that, with the shader's halo on top, rounded
    # the tongues off into a ball.
    if not FIRE_RAW:
        a = np.clip((a - 0.35) / 0.3, 0, 1)
    a = ndi.gaussian_filter(a, 0.5 if FIRE_RAW else 0.6) * box
    bg = np.array([28, 24, 40], float)
    if FIRE_RAW:
        # TARGET's own colours: un-blending the half-keyed dark glow between
        # the tongues off the slate blew it up to solid orange, a disc.
        col = T.astype(float)
    else:
        col = (T - (1 - a[..., None]) * bg) / np.maximum(a[..., None], 0.05)
    # Behind the arm TARGET shows no fire, but the fist swings away from
    # there: grow it in from the nearest flame, solid 60 px in, fading out by 120, so the
    # swing never opens a fist-shaped hole in it.
    H, W = a.shape
    yy, xx = np.mgrid[0:H, 0:W].astype(float)
    lit = a > 0.5
    dist, (iy, ix) = ndi.distance_transform_edt(~lit, return_indices=True)
    hid = inside & m
    a = np.where(hid, a[iy, ix] * np.clip(2.0 - dist / 60.0, 0, 1), a)
    grown = col[iy, ix] * 0.25 + np.array([250, 120, 30], float) * 0.75   # TARGET's flame orange
    col = np.where(hid[..., None], grown, col)
    if FIRE_RAW:
        # Where TARGET itself shows flame inside the figure's mask (the
        # yellow core hugging the back of the fist), keep TARGET's pixel.
        flame = hid & (r > 170) & (r - b > 90) & (g > 60)
        col = np.where(flame[..., None], T, col)
        a = np.where(flame, 1.0, a)
    if FIRE_RAW and FIRE_HAZE > 0:
        # TARGET's flame lights the dark cliff round it: a dark red glow
        # between and beyond the tongues. Keyed out, the fight's slate showed
        # there and the shader's cream halo ringed the tongues. Carry TARGET's
        # own glow pixels, fading out FIRE_HAZE_PX from the flame, below the
        # halo's alpha so it casts none.
        flame_a = a > 0.5
        dd = ndi.distance_transform_edt(~flame_a)
        warm = np.clip((r - b - 8) / 60.0, 0, 1)
        fall = np.clip(1.0 - dd / FIRE_HAZE_PX, 0, 1) ** 1.2
        haze = FIRE_HAZE * warm * fall * (inside & ~m) * (~flame_a)
        haze = ndi.gaussian_filter(haze, 1.0) * (~flame_a) * box
        a = np.maximum(a, haze)
    if FIRE_RAW:
        # Just under the shader's halo_from: TARGET's flame casts no cream
        # halo (its own dark red glow is the haze above); at alpha 1 the
        # tongues threw the body line's soft orange halo round themselves.
        return np.clip(col, 0, 255), np.minimum(a, FIRE_MAX_A)
    # Lean the plume back off the fist: above the base, column x samples the
    # column FIRE_LEAN px per row further right.
    sx = xx + FIRE_LEAN * np.clip(FIRE_BASE - yy, 0, None)
    a = ndi.map_coordinates(a, [yy, sx], order=1) * inside
    col = np.dstack([ndi.map_coordinates(col[..., k], [yy, sx], order=1) for k in range(3)])
    # Fist distance: the skirt below the base, and the hot core.
    fist = m & inside
    d = ndi.distance_transform_edt(~fist)
    skirt = np.clip(1.0 - (d - FIRE_HUG) / 10.0, 0, 1)
    a = np.where(yy > FIRE_BASE, a * skirt, a)
    # Next to the fist the flame is solid: half-lit cream there read grey.
    a = np.where((d < FIRE_CORE) & (a > 0.15), 1.0, a)
    hot = 0.85 * np.clip(1.0 - d / FIRE_CORE, 0, 1)[..., None] ** 0.8
    # Tongue edges deep orange: how far inside the flame a pixel sits.
    din = ndi.distance_transform_edt(a > 0.5)
    edge = np.clip(1.0 - din / 7.0, 0, 1)[..., None] * (1 - hot)
    col = col * (1 - hot) + FIRE_HOT * hot
    col = col * (1 - 0.6 * edge) + FIRE_EDGE * 0.6 * edge
    return np.clip(col, 0, 255), a


def fire_frames(L):
    """FIRE_FRAMES copies of the fire layer L (canvas px, RGBA), each warped
    by a wave climbing the flame. Tips move most, the base not at all."""
    H, W = L.shape[:2]
    yy, xx = np.mgrid[0:H, 0:W].astype(float)
    base = (FIRE_BASE - BOX[1]) * SCALE
    span = (FIRE_BASE - FIRE_BOX[0][1]) * SCALE
    up = np.clip((base - yy) / span, 0, 1) ** 1.3
    lam = 70.0 * SCALE
    out = []
    for f in range(FIRE_FRAMES):
        ph = 2.0 * math.pi * f / FIRE_FRAMES
        # sin(k*y + ph) with ph growing travels toward -y: the wave climbs.
        # Each wave less its own value at ph 0, so frame 0 (the one the rest
        # pose shows) is TARGET's flame unmoved (builder 2026-10-09 run 13:
        # the old frame 0 stood ~1.75 screen px right of and 1 px below
        # TARGET's, its tongues bilinear-resampled soft).
        ax = 2 * math.pi * yy / lam + xx / (90.0 * SCALE)
        ay = 2 * math.pi * xx / (55.0 * SCALE)
        dx = FIRE_SWAY * SCALE * up * (np.sin(ax + ph) - np.sin(ax))
        dy = FIRE_LIFT * SCALE * up * 0.5 * (np.sin(ay - ph) - np.sin(ay))
        coords = [yy + dy, xx + dx]
        pre = [ndi.map_coordinates(L[..., k] * L[..., 3] / 255.0, coords, order=1, mode="constant")
               for k in range(3)]
        a = ndi.map_coordinates(L[..., 3], coords, order=1, mode="constant")
        A = np.clip(a / 255.0, 0, 1)
        rgb = np.dstack([pre[k] / np.maximum(A, 1e-3) for k in range(3)])
        out.append(np.dstack([np.clip(rgb, 0, 255), A * 255]))
    return out


GAP_MIN = 200     # TARGET px; smaller enclosed specks are line noise


def enclosed_gaps(m):
    """Background pixels the silhouette closes all round (the lava cut
    counts as a side): the gaps between limbs."""
    outside = ~ndi.binary_dilation(m, iterations=1)
    outside[CUT:] = False
    lab, n = ndi.label(outside)
    H, W = m.shape
    gap = np.zeros_like(m)
    for i, sl in enumerate(ndi.find_objects(lab), start=1):
        r = lab[sl] == i
        if r.sum() < GAP_MIN:
            continue
        if sl[0].start == 0 or sl[1].start == 0 or sl[1].stop == W:
            continue
        gap[sl] |= r
    # Up to the line, so no sliver of sky between gap and outline.
    return ndi.binary_dilation(gap, iterations=2) & ~m | gap


# The open pocket under the raised arm shows TARGET's near-black rock and its
# lava glow; the fight showed purple sky and the heat band's red bars there. The torso layer carries TARGET's own
# pixels in them, stones lifted out, faded on their open side. They sit at
# POCKET_ALPHA, just under 1, so the shader's halo (which reads the alpha)
# does not ring their open edge (drawn_sprite.gdshader `halo_from`).
POCKETS = [
    [(222, 300), (480, 300), (480, CUT), (222, CUT)],                # under the fist arm
]
POCKET_ALPHA = 0.94
POCKET_FEATHER = 9.0   # TARGET px, on the open side
HALO_FROM = 0.97
POCKET_STONE_TOP = 455   # TARGET row; its stones in the pocket all lie below


def pockets(T, m):
    """Soft alpha and TARGET's pixels (stones inpainted) for the pockets."""
    poly = np.zeros(m.shape, bool)
    for pts in POCKETS:
        poly |= poly_mask(pts, m.shape)
    poly[CUT:] = False
    soft = np.clip(ndi.gaussian_filter(poly.astype(float), POCKET_FEATHER) * 2.0 - 1.0, 0, 1)
    # Full strength against the body, where the body hides the edge.
    soft = np.where(ndi.binary_dilation(m, iterations=14) & poly, 1.0, soft)
    a = soft * POCKET_ALPHA * ~m
    mx, mn = T.max(2), T.min(2)
    stone = poly & ~m & (mx - mn < 50) & (mx > 70)
    stone[:POCKET_STONE_TOP] = False   # above: the outline's warm glow, not stone
    stone = ndi.binary_opening(stone, iterations=1)
    stone = ndi.binary_dilation(stone, iterations=4) & ~m
    # The rock and glow here change with height, not across, so each row of
    # a stone's hole is the line between the rock either side of it (or the
    # one side the body leaves).
    rgb = T.copy()
    ok = ~stone & ~m
    for y in np.nonzero(stone.any(1))[0]:
        xs = np.nonzero(stone[y])[0]
        runs = np.split(xs, np.nonzero(np.diff(xs) > 1)[0] + 1)
        for r in runs:
            x0, x1 = r[0] - 1, r[-1] + 1
            while x0 >= 0 and not ok[y, x0]:
                x0 -= 1
            while x1 < m.shape[1] and not ok[y, x1]:
                x1 += 1
            L = T[y, x0] if x0 >= 0 else None
            R = T[y, x1] if x1 < m.shape[1] and not m[y, x1] else None
            if L is None and R is None:
                continue
            L = R if L is None else L
            R = L if R is None else R
            w = (r - x0) / float(x1 - x0)
            rgb[y, r] = L[None, :] * (1 - w[:, None]) + R[None, :] * w[:, None]
    return rgb, a


def labels(m):
    lab = np.zeros(m.shape, object)
    lab[:] = "torso"
    for name, _, _, pts in PARTS:
        lab[poly_mask(pts, m.shape) & m] = name
    lab[~m] = ""
    return lab


def layer_alpha(lab, m):
    """Each part's pixels, plus the band of each child it lies under.

    The band stops short of the silhouette by TARGET's rim width: kept
    there, the child's outline lay twice, once on each layer, and the
    smallest idle sway split it into two lines (grader, 2026-10-07)."""
    own = {n: lab == n for n in ["torso"] + [p[0] for p in PARTS]}
    alpha = {n: own[n].copy() for n in own}
    deep = ndi.distance_transform_edt(m) > RIM
    for name, parent, _, _ in PARTS:
        near = ndi.distance_transform_edt(~own[parent]) <= UNDERLAY
        alpha[parent] |= own[name] & near & deep
    return alpha, own


def underlay_line(rgb, a, own_px, m):
    """The band's own edge, inked: hidden under the child at rest, it is the
    joint's outline once the child swings off it."""
    edge = a & ~ndi.binary_erosion(a, iterations=4) & ~own_px
    edge &= ndi.distance_transform_edt(m) > RIM - 2
    out = rgb.copy()
    out[edge] = LINE if INK_UNDERLAY else out[edge]
    return out


PRESHARPEN = 0.0   # 0.6 until run 6: its dark rim narrowed each crack; registered error 8.4 -> 8.0 off
PRESHARPEN_SIGMA = 1.5   # canvas px (2x TARGET)


def upscale(rgb, a):
    """2x, premultiplied and in float: in 8 bits the faint edge of a cut
    divided back out to a pale hairline along every joint."""
    h, w = a.shape
    pre = [rgb[..., k] * a for k in range(3)] + [a]
    big = [np.asarray(Image.fromarray(ch.astype(np.float32), "F").resize((w * SCALE, h * SCALE), Image.LANCZOS))
           for ch in pre]
    A = np.clip(big[3], 0, 1)
    A[A < 0.03] = 0.0     # no faint specks past the edge
    rgb2 = np.dstack([big[k] / np.maximum(A, 1e-3) for k in range(3)])
    if PRESHARPEN:
        # The fight draws the parts through a viewport and a footprint
        # filter, which soften TARGET's crisp crack edges by about half
        # (Laplacian inside the chest 4.7 against TARGET's 8.4). An unsharp
        # mask here, inside the solid rock only, puts the edge back before
        # the downsample, where it cannot ring on screen.
        solid = ndi.binary_erosion(A > 0.99, iterations=int(PRESHARPEN_SIGMA * 3) + 1)
        for k in range(3):
            ch = rgb2[..., k]
            ch2 = ch + (ch - ndi.gaussian_filter(ch, PRESHARPEN_SIGMA)) * PRESHARPEN
            rgb2[..., k] = np.where(solid, ch2, ch)
    return np.dstack([np.clip(rgb2, 0, 255), A * 255])


def crop_box(T2):
    x0, y0, x1, y1 = BOX
    return T2[y0:y1, x0:x1]


def to_canvas(p):
    return ((p[0] - BOX[0]) * SCALE, (p[1] - BOX[1]) * SCALE)


# Under the cut TARGET shows its lava line: a bright yellow-orange edge
# with blobs of lava, then the dark floor. The repeated last row drew a band
# of vertical streaks there instead ("hard red bars" at the feet), now that
# the fight's lava line sits at TARGET's height and no longer hides it. So
# the sink rows are TARGET's own rows under the body, faded out sideways
# where the body ends.
SINK_TARGET = True
SINK_FEATHER = 5.0     # TARGET px


def sink_target(rgb, a, T2):
    k = CUT - BOX[1]
    rgb, a = rgb.copy(), a.copy()
    row = ndi.gaussian_filter1d((a[k - 1] > 0.5).astype(float), SINK_FEATHER)
    row = np.minimum(row * 2.0, 1.0) * (a[k - 1] > 0.0)
    rgb[k:] = T2[k:k + rgb.shape[0] - k]
    a[k:] = np.minimum(a[k - 1], row)[None, :]
    return rgb, a


def sink(arr):
    """Repeat the row above the lava under it, so the floor hides the cut."""
    k = CUT - BOX[1]
    arr[k:] = arr[k - 1]
    return arr


# TARGET's cracks read as glowing channels: at a glance the light spills a
# little onto the plates beside them, and the sternum's yellow lights the
# chest round it. Through the fight's resamples that spill reads thinner than
# TARGET's (graders, 2026-10-08 runs 1-3 and 10-09). A soft glow of each
# crack's own colour, screened onto the dark rock next to it, puts it back
# without the shader's per-pixel taps (which stippled the channels).
CRACK_GLOW = 0.0           # strength of the narrow spill
CRACK_GLOW_SIGMA = 1.6     # TARGET px
HOT_GLOW = 0.0             # the yellow cores' wider glow
HOT_GLOW_SIGMA = 4.0
GLOW_TOP = 335   # TARGET row; above it (head, chin) no glow is added



def crack_glow(img, m):
    rim = m & ~ndi.binary_erosion(m, iterations=RIM + 3)
    inner = m & ~rim
    inner[:GLOW_TOP] = False   # the head and chin stay as drawn
    mx, mn = img.max(2), img.min(2)
    sat = (mx - mn) / np.maximum(mx, 1)
    crack = inner & (img[..., 0] > 150) & (sat > 0.6) & (img[..., 2] < 110)
    hot = inner & (img[..., 0] > 225) & (img[..., 1] > 150) & (img[..., 2] < 140)
    def blur(mask, sig):
        w = mask.astype(float)
        col = np.dstack([ndi.gaussian_filter(img[..., k] * w, sig) for k in range(3)])
        a = ndi.gaussian_filter(w, sig)
        return col / np.maximum(a[..., None], 1e-4), np.clip(a * 2.0, 0, 1)
    out = img.copy()
    for mask, sig, k in ((crack, CRACK_GLOW_SIGMA, CRACK_GLOW), (hot, HOT_GLOW_SIGMA, HOT_GLOW)):
        col, a = blur(mask, sig)
        a = a * k * inner
        # Screen: only ever brightens, never past the glow's own colour.
        scr = 255 - (255 - out) * (255 - col) / 255
        out = out * (1 - a[..., None]) + scr * a[..., None]
    return out


# The fight's resample spreads each thin yellow core into the dark rock
# beside it, so its peak lands dimmer and oranger than TARGET's (registered,
# hot cores: TARGET green 207, game 193). The cores are lifted toward
# yellow by that much before the resample, so they land on TARGET's colour.
HOT_LIFT = 0.0


# TARGET's sternum Y has a wide yellow-white core; after the resample the
# game's read a px narrower and more orange where it meets the abdomen seam
# (grader, 2026-10-09 run 9). Its yellow pixels grow by Y_GROW px, inside
# this box only, blended at Y_GROW_A.
Y_BOX = (478, 318, 548, 392)
Y_GROW = 0
Y_GROW_A = 0.6


def y_core(img, m):
    if not Y_GROW:
        return img
    x0, y0, x1, y1 = Y_BOX
    sub = img[y0:y1, x0:x1]
    r, g = sub[..., 0], sub[..., 1]
    hot = (r > 225) & (g > 165)
    grown = ndi.binary_dilation(hot, iterations=Y_GROW) & ~hot & m[y0:y1, x0:x1]
    num = np.dstack([ndi.maximum_filter(sub[..., k] * hot, size=2 * Y_GROW + 1) for k in range(3)])
    lum = sub @ np.array([0.3, 0.59, 0.11])
    put = grown & (num @ np.array([0.3, 0.59, 0.11]) > lum)
    out = img.copy()
    o = out[y0:y1, x0:x1]
    o[put] = o[put] * (1 - Y_GROW_A) + num[put] * Y_GROW_A
    return out


def hot_lift(img, m):
    if not HOT_LIFT:
        return img
    r, g = img[..., 0], img[..., 1]
    w = np.clip((r - 215) / 25.0, 0, 1) * np.clip((g - 140) / 40.0, 0, 1) * m
    out = img.copy()
    out[..., 1] = np.minimum(g + HOT_LIFT * w, 255)
    out[..., 0] = np.minimum(r + 0.5 * HOT_LIFT * w, 255)
    return out


# Graders across six runs read TARGET's limb and chest cracks as wider and
# more orange than the game's, though the registered pixels agree. Knobs for
# a widening (each channel's edge takes part of its crack's colour) and a lift
# of the channel middles toward orange, inside the body only (never the
# outline, the head's lines or the fire). Off: at 0.85/0.7 (run 6, 2026-10-09)
# graders saw no change and the registered error rose 8.0 -> 9.5.
WIDEN = 0.0          # blend of the 1-px grown crack onto the rock beside it
ORANGE = 0.0         # channel middles toward g = 0.42 r
WIDEN_HEAD_Y = 300   # TARGET row; above it is the head, left as drawn
WIDEN_SIZE = 3


def crack_widen(img, m):
    if not (WIDEN or ORANGE):
        return img
    inner = ndi.distance_transform_edt(m) > RIM + 3
    inner[:WIDEN_HEAD_Y] = False
    r, g, b = img[..., 0], img[..., 1], img[..., 2]
    mx, mn = img.max(2), img.min(2)
    sat = (mx - mn) / np.maximum(mx, 1)
    crack = inner & (r > 150) & (sat > 0.6) & (b < 110)
    out = img.copy()
    if WIDEN:
        w = crack.astype(float)
        num = np.dstack([ndi.maximum_filter(img[..., k] * w, size=WIDEN_SIZE) for k in range(3)])
        near = ndi.maximum_filter(w, size=WIDEN_SIZE) > 0
        lum = img @ np.array([0.3, 0.59, 0.11])
        nl = num @ np.array([0.3, 0.59, 0.11])
        put = inner & near & ~crack & (nl > lum + 20)
        out[put] = out[put] * (1 - WIDEN) + num[put] * WIDEN
    if ORANGE:
        mid = crack & (r > 190)
        out[..., 1] = np.where(mid, np.maximum(out[..., 1], out[..., 1] + ORANGE * np.maximum(0.42 * r - out[..., 1], 0)), out[..., 1])
    return out


# The fight's colour path (3D LUT through ACES) crushes the darkest greens
# and blues to 0: TARGET's plate (44,11,8) drew (40,0,0), so the rock read
# redder and darker round every crack. tools/jackal_tone_fix.json holds a
# per-channel pre-map measured off the rest frame (tools/jackal_tone.py, the
# registered body, TARGET over game), applied to every layer.
TONE_FIX = ROOT / "tools/jackal_tone_fix.json"


def tone_fix(L):
    if not TONE_FIX.exists():
        return L
    lut = np.array(json.loads(TONE_FIX.read_text())["lut"], float)
    out = L.copy()
    for k in range(3):
        out[..., k] = np.interp(L[..., k], np.arange(256), lut[k])
    return out


def build():
    T = np.asarray(Image.open(TARGET).convert("RGB")).astype(float)
    m, line, walls = silhouette(T)
    body = paint_hidden(T, m, line, walls)
    body = crack_glow(body, m)
    body = y_core(body, m)
    body = hot_lift(body, m)
    body = crack_widen(body, m)
    fire_rgb, fire_a = fire_layer(T, m)
    lab = labels(m)
    alpha, own = layer_alpha(lab, m)
    # TARGET's enclosed gaps (between the torso and the right arm) show
    # near-black cliff; the fight's purple sky showed through them instead
    # (critics, "Gaps between the jackal's limbs"). The torso layer carries
    # TARGET's own pixels there, opaque, behind the limbs that frame them.
    gap = enclosed_gaps(m)
    alpha["torso"] = alpha["torso"] | gap
    pocket_rgb, pocket_a = pockets(T, m)

    layers = {}
    for name in ORDER:
        if name == "fire":
            rgb, a = fire_rgb, fire_a
        else:
            rgb, a = underlay_line(body, alpha[name], own[name], m), alpha[name].astype(float)
            if name == "torso":
                put = (pocket_a > 0) & (a < 1)
                rgb = rgb.copy()
                rgb[put] = pocket_rgb[put]
                a = np.maximum(a, pocket_a)
        rgb, a = crop_box(rgb).copy(), crop_box(a).copy()
        if name in ("torso", "fore_r"):
            if SINK_TARGET:
                rgb, a = sink_target(rgb, a, crop_box(T))
            else:
                rgb, a = sink(rgb), sink(a)
        # The fire skips the tone fix (builder 2026-10-09 run 13): its blue
        # curve (measured on the rock) steps 2x then flattens between 49 and
        # 70, which is the flame's yellow, and drew contour lines round the
        # fist through the yellow core.
        layers[name] = upscale(rgb, a) if (name == "fire" and not FIRE_TONE_FIX) else tone_fix(upscale(rgb, a))
        if name == "fire" and FIRE_SMOOTH:
            # TARGET's flame carries a fine grain that the fight's colour
            # path (the LUT inverting ACES's shoulder) blows up ~4x in the
            # bright yellows: the game's flame read as sparkly noise
            # (builder, 2026-10-09 run 9). An edge-keeping smooth inside the
            # flame takes the grain out and keeps the tongues' edges.
            L = layers[name]
            if FIRE_DENOISE == "median":
                u8 = np.clip(L[..., :3], 0, 255).astype(np.uint8)
                sm = cv2.medianBlur(u8, FIRE_MEDIAN).astype(float)
            elif FIRE_DENOISE == "nlm":
                u8 = np.clip(L[..., :3], 0, 255).astype(np.uint8)
                sm = cv2.fastNlMeansDenoisingColored(u8, None, FIRE_NLM_H, FIRE_NLM_H, 7, 21).astype(float)
            else:
                sm = cv2.bilateralFilter(L[..., :3].astype(np.float32), FIRE_SMOOTH_D,
                                         FIRE_SMOOTH_SC, FIRE_SMOOTH_SS).astype(float)
            L = L.copy()
            if FIRE_INK:
                bl = np.dstack([ndi.gaussian_filter(sm[..., k], FIRE_INK_SIG) for k in range(3)])
                sm = np.clip(sm + (sm - bl) * FIRE_INK, 0, 255)
            L[..., :3] = np.where((L[..., 3:4] > 250), sm, np.where(L[..., 3:4] > 0, L[..., :3] * 0 + sm, L[..., :3]))
            # The flame's soft edge carried TARGET's dark glow colour, a dark
            # rim round every tongue over the fight's backdrop: each edge
            # pixel takes the colour of the nearest solid flame pixel.
            solid = L[..., 3] >= 250
            dd, (iy, ix) = ndi.distance_transform_edt(~solid, return_indices=True)
            edge = (L[..., 3] > 0) & ~solid & (dd <= FIRE_EDGE_PX) & (L[..., 3] > 128)
            L[edge, :3] = L[iy[edge], ix[edge], :3]
            if FIRE_DITHER:
                rng = np.random.default_rng(7)
                L[..., :3] = np.clip(L[..., :3] + rng.uniform(-FIRE_DITHER, FIRE_DITHER, L[..., :3].shape), 0, 255)
            if FIRE_LIFT_G:
                g = L[..., 1]
                L[..., 1] = np.clip(g + FIRE_LIFT_G * np.clip((g - FIRE_LIFT_FROM) / (240.0 - FIRE_LIFT_FROM), 0, 1), 0, 255)
            # The key kept TARGET's dark red glow as an outer shell with a
            # hard edge; over the backdrop it drew a contour line a few px
            # out from the tongues. In that shell, the darker the red, the
            # more it fades into the backdrop (which carries TARGET's glow).
            out_d = ndi.distance_transform_edt(L[..., 3] > 0)
            if not FIRE_SHELL_PX:
                out_d = out_d + 1e9
            shell = (L[..., 3] > 0) & (out_d < FIRE_SHELL_PX)
            red = L[..., 0]
            fade = np.clip((red - FIRE_SHELL_R[0]) / (FIRE_SHELL_R[1] - FIRE_SHELL_R[0]), 0, 1) ** 1.5
            fade = np.maximum(fade, np.clip(out_d / max(FIRE_SHELL_PX, 1e-3), 0, 1) ** 2)
            L[..., 3] = np.where(shell, L[..., 3] * fade, L[..., 3])
            layers[name] = L

    # Under the fist's soft outer line the flame's key dropped to a hole
    # (the cream line fails it) and both layers there were part-transparent:
    # the composite's alpha dipped to ~0.87 along the fist's edge and the
    # billboard's halo drew pale cream striations into the yellow core
    # (builder 2026-10-09 run 13). The flame is solid wherever the fist
    # covers it, so fill it there with the nearest solid flame colour.
    if "fire" in layers and FIRE_UNDER_FIST:
        L = layers["fire"].copy()
        cover = np.zeros(L.shape[:2], bool)
        for part in ("fore_l", "arm_l"):
            if part in layers:
                cover |= layers[part][..., 3] > 0
        solid = L[..., 3] >= 250
        dd, (iy, ix) = ndi.distance_transform_edt(~solid, return_indices=True)
        # and pinholes inside the flame, where the key failed on its grain
        holes = ndi.binary_fill_holes(ndi.binary_closing(solid, iterations=2)) & ~solid
        fill = (cover & ~solid & (dd <= FIRE_UNDER_FIST)) | holes
        L[fill, :3] = L[iy[fill], ix[fill], :3]
        L[fill, 3] = 255
        layers["fire"] = L

    # The rest frame: every layer over the last, as the rig draws it.
    H, W = layers["torso"].shape[:2]
    comp = np.zeros((H, W, 4), float)
    for name in ORDER:
        L = layers[name]
        a = L[..., 3:4] / 255.0
        ca = comp[..., 3:4] / 255.0
        oa = a + ca * (1 - a)
        comp[..., :3] = (L[..., :3] * a + comp[..., :3] * ca * (1 - a)) / np.maximum(oa, 1e-4)
        comp[..., 3:4] = oa * 255
    Image.fromarray(np.clip(comp, 0, 255).astype(np.uint8), "RGBA").save(OUT / f"{ID}_2d.png", optimize=True)

    # Crop each layer to its pixels; remember where it sits on the canvas.
    # The fire is a strip of FIRE_FRAMES frames, all cropped to one box.
    placed = {}
    for name, L in layers.items():
        frames = fire_frames(L) if name == "fire" else [L]
        ys, xs = np.nonzero(np.max([F[..., 3] for F in frames], axis=0) > 0)
        x0, x1, y0, y1 = xs.min(), xs.max() + 1, ys.min(), ys.max() + 1
        strip = np.concatenate([F[y0:y1, x0:x1] for F in frames], axis=1)
        Image.fromarray(np.clip(strip, 0, 255).astype(np.uint8), "RGBA").save(
            OUT / f"{ID}_2d_{name}.png", optimize=True)
        placed[name] = (int(x0), int(y0))

    # World units per canvas pixel: floor (the cut) to ear tip is HEIGHT.
    ys, xs = np.nonzero(m[:CUT])
    floor_px = (CUT - BOX[1]) * SCALE
    top_px = (ys.min() - BOX[1]) * SCALE
    mid_px = ((xs.min() + xs.max()) / 2.0 - BOX[0]) * SCALE
    px = HEIGHT / float(floor_px - top_px)
    write_scene(W, H, placed, px, floor_px, mid_px, lab)
    print(f"{ID}_2d: canvas {W}x{H}, px {px:.6f}, layers " + ", ".join(ORDER))


# --- the scene ---------------------------------------------------------------

PIVOT = {"torso": (512, CUT)}
PARENT = {"torso": None}
for _n, _p, _pv, _ in PARTS:
    PIVOT[_n], PARENT[_n] = _pv, _p
PIVOT["fire"], PARENT["fire"] = PIVOT["fore_l"], "fore_l"


def bone_path(name):
    chain = []
    while name is not None:
        chain.append(name)
        name = PARENT[name]
    return "/".join(reversed(chain))


# Clips: per bone, per property, (time, value) keys. Rotations in degrees
# (Godot 2D: + turns clockwise on screen). The attack's blow lands at 0.4 of
# the clip, where the fight puts the damage (ENEMY_BITE_FRAC).
def clips():
    idle = {
        "torso": {"position:y": [(0, 0), (1.2, 4), (2.4, 0)], "rotation": [(0, 0), (1.2, -0.6), (2.4, 0)]},
        "head": {"rotation": [(0, 0), (0.6, 1.2), (1.8, -1.2), (2.4, 0)]},
        "arm_l": {"rotation": [(0, 0), (1.2, 2.5), (2.4, 0)]},
        "fore_l": {"rotation": [(0, 0), (1.2, -2.0), (2.4, 0)]},
        "arm_r": {"rotation": [(0, 0), (1.2, -0.6), (2.4, 0)]},
        # The flame licks frame by frame; it never scales about the elbow at
        # rest, which slid the ball off the fist and showed its round rim.
        "fire": {"Art:frame": [(i / FIRE_FPS, i % FIRE_FRAMES) for i in range(int(2.4 * FIRE_FPS))],
                 "modulate": [(0, (1, 1, 1, 1)), (0.45, (1.04, 1.02, 1, 1)), (0.9, (1, 1, 1, 1)),
                              (1.5, (1.05, 1.02, 1, 1)), (2.4, (1, 1, 1, 1))]},
    }
    L = 1.2
    imp = 0.4 * L
    attack = {
        "torso": {"rotation": [(0, 0), (0.3, -3), (imp, 5), (0.8, 4), (L, 0)],
                  "position:y": [(0, 0), (0.3, -6), (imp, 10), (0.8, 8), (L, 0)]},
        "head": {"rotation": [(0, 0), (0.3, -4), (imp, 5), (0.8, 4), (L, 0)]},
        "arm_l": {"rotation": [(0, 0), (0.3, 16), (imp, -56), (0.8, -50), (L, 0)],
                  "scale": [(0, (1, 1)), (0.3, (0.97, 0.97)), (imp, (1.12, 1.12)), (0.8, (1.08, 1.08)), (L, (1, 1))]},
        "fore_l": {"rotation": [(0, 0), (0.3, 10), (imp, -22), (0.8, -18), (L, 0)]},
        "arm_r": {"rotation": [(0, 0), (0.3, 3), (imp, -4), (L, 0)]},
        "fire": {"scale": [(0, (1, 1)), (0.3, (1.15, 1.2)), (imp, (1.35, 1.25)), (L, (1, 1))]},
    }
    hit = {
        "torso": {"rotation": [(0, 0), (0.1, 3.5), (0.45, 0)], "position:x": [(0, 0), (0.1, 10), (0.45, 0)]},
        "head": {"rotation": [(0, 0), (0.1, -6), (0.45, 0)]},
        "arm_l": {"rotation": [(0, 0), (0.1, 7), (0.45, 0)]},
        "arm_r": {"rotation": [(0, 0), (0.1, 3), (0.45, 0)]},
    }
    death = {
        "torso": {"rotation": [(0, 0), (0.4, -3), (1.6, 8)], "position:y": [(0, 0), (0.4, -6), (1.6, 260)]},
        "head": {"rotation": [(0, 0), (0.4, -6), (1.6, 16)]},
        "arm_l": {"rotation": [(0, 0), (0.4, 10), (1.6, -75)]},
        "fore_l": {"rotation": [(0, 0), (1.6, -30)]},
        "arm_r": {"rotation": [(0, 0), (1.6, 10)]},
        "fire": {"scale": [(0, (1, 1)), (0.4, (1.2, 1.2)), (1.2, (0.0, 0.0)), (1.6, (0.0, 0.0))]},
    }
    return {"idle": (2.4, True, idle), "attack": (L, False, attack), "hit": (0.45, False, hit), "death": (1.6, False, death)}


def gd(v):
    if isinstance(v, tuple) and len(v) == 2:
        return f"Vector2({v[0]:g}, {v[1]:g})"
    if isinstance(v, tuple) and len(v) == 4:
        return f"Color({v[0]:g}, {v[1]:g}, {v[2]:g}, {v[3]:g})"
    return f"{v:g}"


def anim_resource(rid, name, length, loop, tracks):
    out = [f'[sub_resource type="Animation" id="{rid}"]', f'resource_name = "{name}"',
           f'length = {length:g}', f'loop_mode = {1 if loop else 0}']
    t = 0
    rest = {"rotation": 0.0, "position:x": None, "position:y": None, "scale": (1, 1), "modulate": (1, 1, 1, 1)}
    for bone, props in tracks.items():
        for prop, keys in props.items():
            path = f"Rig/Root/{bone_path(bone)}{'/' if '/' in prop or prop.startswith('Art:') else ':'}{prop}"
            discrete = prop.endswith(":frame")
            vals = []
            for _, v in keys:
                if prop == "rotation":
                    v = math.radians(v)
                vals.append(v)
            if prop.startswith("position:"):
                axis = 0 if prop.endswith("x") else 1
                base = REST_POS[bone][axis]
                vals = [base + v for v in vals]
            out += [f'tracks/{t}/type = "value"', f'tracks/{t}/imported = false', f'tracks/{t}/enabled = true',
                    f'tracks/{t}/path = NodePath("{path}")', f'tracks/{t}/interp = {0 if discrete else 2}',
                    f'tracks/{t}/loop_wrap = true', f'tracks/{t}/keys = {{',
                    f'"times": PackedFloat32Array({", ".join(f"{k[0]:g}" for k in keys)}),',
                    f'"transitions": PackedFloat32Array({", ".join("1" for _ in keys)}),',
                    f'"update": {1 if discrete else 0},',
                    f'"values": [{", ".join(gd(v) for v in vals)}]', '}']
            t += 1
    return out + [""]


REST_POS = {}


def write_scene(W, H, placed, px, floor_px, mid_px, lab):
    # Bone positions, relative to the parent bone, on the 2x canvas.
    for name in ORDER:
        c = to_canvas(PIVOT[name])
        par = PARENT[name]
        pc = to_canvas(PIVOT[par]) if par else (0.0, 0.0)
        REST_POS[name] = (c[0] - pc[0], c[1] - pc[1])

    def world(cx, cy):
        return ((cx - mid_px) * px, (floor_px - cy) * px)

    # The Sprite3D centres its texture on itself: shift it so the floor is y 0.
    bx, by = world(W / 2.0, H / 2.0)
    res = [f'[ext_resource type="Texture2D" path="res://assets/3d/cast/{ID}_2d.png" id="rest"]',
           '[ext_resource type="Shader" path="res://assets/3d/drawn_sprite.gdshader" id="shader"]',
           '[ext_resource type="Script" path="res://views/drawn_rig.gd" id="script"]']
    for name in ORDER:
        res.append(f'[ext_resource type="Texture2D" path="res://assets/3d/cast/{ID}_2d_{name}.png" id="{name}"]')
    subs = ['[sub_resource type="ShaderMaterial" id="drawn"]', 'resource_local_to_scene = true',
            'shader = ExtResource("shader")', 'shader_parameter/tex = ExtResource("rest")',
            f'shader_parameter/halo = {HALO:g}', f'shader_parameter/halo_px = {HALO_PX:g}',
            f'shader_parameter/halo_from = {HALO_FROM:g}', '']
    lib = []
    for i, (cname, (length, loop, tracks)) in enumerate(clips().items()):
        rid = f"anim_{cname}"
        subs += anim_resource(rid, cname, length, loop, tracks)
        lib.append(f'&"{cname}": SubResource("{rid}")')
    subs += ['[sub_resource type="AnimationLibrary" id="lib"]', '_data = {', ",\n".join(lib), '}', '']

    nodes = [f'[node name="{ID}_2d" type="Node3D"]', 'script = ExtResource("script")',
             f'pixel_size = {px:.6f}', f'floor_px = {floor_px:.1f}', f'mid_px = {mid_px:.1f}',
             f'figure_x0 = {(FIGURE_X[0] - BOX[0]) * SCALE:g}', f'figure_x1 = {(FIGURE_X[1] - BOX[0]) * SCALE:g}', '',
             '[node name="Body" type="Sprite3D" parent="."]',
             f'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {bx:.4f}, {by:.4f}, 0)',
             f'pixel_size = {px:.6f}', 'billboard = 2', 'shaded = false', 'double_sided = false',
             'alpha_cut = 2', 'texture_filter = 3', 'texture = ExtResource("rest")',
             'material_override = SubResource("drawn")', '',
             '[node name="Rig" type="SubViewport" parent="."]', 'disable_3d = true', 'transparent_bg = true',
             f'size = Vector2i({W}, {H})', 'render_target_update_mode = 4', '',
             '[node name="Root" type="Node2D" parent="Rig"]', '']
    # A parent before its children (a .tscn needs that); z_index draws ORDER.
    for name in sorted(ORDER, key=lambda n: bone_path(n).count("/")):
        par = PARENT[name]
        ppath = "Rig/Root" + ("/" + bone_path(par) if par else "")
        rx, ry = REST_POS[name]
        c = to_canvas(PIVOT[name])
        ox, oy = placed[name][0] - c[0], placed[name][1] - c[1]
        nodes += [f'[node name="{name}" type="Node2D" parent="{ppath}"]', f'position = Vector2({rx:g}, {ry:g})', '']
        # Draw order is tree order among siblings; the fire goes behind the fist.
        nodes += [f'[node name="Art" type="Sprite2D" parent="{ppath}/{name}"]',
                  f'z_index = {ORDER.index(name)}', 'z_as_relative = false',
                  f'texture = ExtResource("{name}")', 'centered = false', f'position = Vector2({ox:g}, {oy:g})']
        if name == "fire":
            nodes.append(f'hframes = {FIRE_FRAMES}')
        nodes.append('')
    # Holds: a Marker2D on the part each sits on, and the 3D marker the fight
    # reads, which drawn_rig.gd keeps on that Marker2D as the rig moves.
    for h, p in sorted(HOLDS.items()):
        part = lab[p[1], p[0]] or "torso"
        if part not in PIVOT:
            part = "torso"
        c, pc = to_canvas(p), to_canvas(PIVOT[part])
        nodes += [f'[node name="hold_{h}" type="Marker2D" parent="Rig/Root/{bone_path(part)}"]',
                  f'position = Vector2({c[0] - pc[0]:g}, {c[1] - pc[1]:g})', '']
    for kind, ids in (("climb", sorted(HOLDS)), ("ledge", LEDGES)):
        for h in ids:
            x, y = world(*to_canvas(HOLDS[h]))
            nodes += [f'[node name="{kind}_{h}" type="Node3D" parent="."]',
                      f'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {x:.3f}, {y:.3f}, 0.25)', '']
    nodes += ['[node name="AnimationPlayer" type="AnimationPlayer" parent="."]',
              'libraries = {', '&"": SubResource("lib")', '}', 'autoplay = &"idle"', '']
    text = "\n".join(['[gd_scene format=3]', ''] + res + [''] + subs + nodes)
    (OUT / f"{ID}_2d.tscn").write_text(text)


if __name__ == "__main__":
    build()
