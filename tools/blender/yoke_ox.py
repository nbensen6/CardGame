"""The Yoke Ox - the fight-pool beast that punishes climbing apart.

Ledges at Height 2 and 4, sigil at 5. Its bent rule is `height_split`
(design/BACKLOG.md #55's own limiter field, spent before only by Stone Warden,
a Titan): a hunter more than 3 Height above their ally takes chip damage each
of the Ox's turns, previewing for a hunter the exact rule language a real
Titan will use later, gentler (value 3) than Stone Warden's harsher 4. Every
other new-content fight beast bends a MOVE; this is the first fight-pool beast
whose whole twist is the limiter field instead - Riptide Eel (backlog #55's
thirteenth beast) already proved the pattern works at elite tier with
sigil_fatigue, this is the same idea one tier down with the co-op-specific
limiter instead.

A low, broad-shouldered bovine built around a real wooden yoke slung across
its withers - the shape carries the mechanic: a yoke is built for two to
pull together, and a hunter who climbs it alone is standing on the half of
the beast that was never meant to take weight by itself. Four thick legs, a
wide barrel chest, lowered head with wide sweeping ox horns (not the curled
ram horns Boulder Ram wears - these sweep OUT to the sides before curving
forward, the shape that reads "ox" rather than "ram"). Warm hide colours
(BROWN, UMBER, TAN) with the yoke itself in a paler wood tone (SAND) so it
reads as a separate, carried object rather than another part of the animal.
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import out_path, mirror, point, BROWN, UMBER, TAN, SAND, CREAM, \
                   CHARCOAL

b = Beast("yoke_ox", height=3.0, span=(0.03, 1.87))

# ------------------------------------------------------------------- legs
# Four thick legs, wide stance for a low centre of mass - a body built to
# brace against a shared load, not to run.
for sx in (-1, 1):
    for ly in (-0.60, 0.58):
        b.limb([(0.42 * sx, ly, 0.90), (0.53 * sx, ly * 1.02, 0.45),
               (0.48 * sx, ly * 0.98, 0.04)], [0.20, 0.16, 0.10],
               CHARCOAL, seg=6)

# ------------------------------------------------------------------ the mass
b.box((0.0, 0.0, 1.05), (0.62, 1.00, 0.38), BROWN, bevel=0.06)         # barrel chest
b.ball((0.0, -0.20, 1.48), (0.48, 0.56, 0.42), UMBER, 12, 7)           # withers hump

# Head: lowered forward, grazing/braced posture rather than raised - a body
# built to lean into a load.
b.wedge((0.0, -1.32, 0.62), (0.29, 0.42, 0.27), UMBER, narrow=(0.42, 0.55))
mirror(lambda s: b.ball((0.16 * s, -1.54, 0.72), (0.06, 0.05, 0.05),
                        CHARCOAL, 6, 4))                                # eye
b.ball((0.0, -1.62, 0.52), (0.11, 0.10, 0.08), TAN, 8, 5)               # muzzle

# Wide ox horns - out to the sides then sweeping well up, the shape that
# reads "ox" rather than Boulder Ram's curled-back "ram" horns. Built tall
# and thick enough to clear the withers hump's own silhouette (top z 1.90) -
# a first pass kept them low (tip z 0.90, well under the hump) and they
# vanished into the body in every render, including the 64px silhouette
# check this file's own README calls the real rubric. limb() carries a
# non-twisting frame through the curve so it doesn't come out looking like a
# drill bit.
mirror(lambda s: b.limb([(0.16 * s, -1.05, 0.95), (0.58 * s, -0.90, 1.28),
                         (0.98 * s, -0.62, 1.58), (1.08 * s, -0.32, 1.74)],
                        [0.15, 0.12, 0.08, 0.03], TAN, seg=6))

# ---------------------------------------------------------------- the yoke
# A full-width wooden beam at the base of the neck, in front of the withers
# hump rather than resting on it - a first pass put it AT the hump (y=-0.22,
# z=1.62, inside the hump's own z-range) and it read as invisible clutter
# swallowed into the hump's silhouette in every rendered angle, the 64px
# check included. Moved forward past the hump's own front face (hump half-
# depth 0.56 from its y=-0.20 centre, so anything past y=-0.76 clears it
# entirely) and raised near the hump's own crest height so it breaks the
# silhouette instead of hiding inside it - the position a real yoke actually
# sits, at the neck/shoulder junction, not draped over the back.
b.box((0.0, -0.85, 1.58), (0.80, 0.09, 0.09), SAND, bevel=0.03)
mirror(lambda s: b.taper((0.72 * s, -0.80, 1.44), 0.05, 0.05, 0.16,
                         CHARCOAL, seg=6, rot=point((0.0, 0.15, -1.0))))  # strap loop

# --------------------------------------------------------------- the ledges
# Height 2: a chest/shoulder ledge, anchored off the body's own centreline
# (x=0.28) rather than on it - a centred anchor on this body's symmetric,
# elongated torso reads to beast.py's auto-placement as "outward along the
# whole torso's length" instead of "outward off this one plate", the
# failure Bog Leech's, Thrasher's and Boulder Ram's holds all hit.
b.ball((0.30, 0.05, 1.05), (0.24, 0.26, 0.20), BROWN, 9, 5)
b.shelf(2, (0.28, 0.00), (0.20, 0.18), BROWN, thickness=0.12, bevel=0.05)

# Height 4: the step up onto the yoke itself, near one end rather than the
# centre - literally standing on the half of the beam built for a second
# puller, which is the whole point of the fight.
b.ball((0.62, -0.78, 1.42), (0.16, 0.14, 0.10), SAND, 8, 5)
b.shelf(4, (0.60, -0.80), (0.18, 0.15), SAND, thickness=0.10, bevel=0.04,
        drop=0.02)

# ----------------------------------------------------------------- the tail
b.taper((0.0, 0.92, 0.68), 0.13, 0.03, 0.28, CHARCOAL, seg=6,
        rot=point((0.0, 0.75, -0.55)))

b.foot((0.60, -0.58, 0.04))                                    # onto a foreleg, at its surface

# A plate flush-mounted on the yoke's own front face (off-centreline, the
# same lesson every hold above already used) carries the sigil - a medallion
# hanging from the yoke rather than an antenna standing clear of it, the
# "shoulder-mounted plate, not a periscope" fix Boulder Ram's and Glyph
# Tortoise's write-ups both landed on. A first attempt mounted it on the
# withers hump instead (x=0.20, y=-0.28) - deep INSIDE the hump's own
# ellipsoid at that x/z rather than on its surface, so assetcheck's front
# camera test found it 100% buried behind the hump's own bulk. Moving it to
# the yoke's own front face, well forward of the hump entirely, fixed it.
_sigil_z = b.z_for(5)
b.box((0.20, -1.00, _sigil_z), (0.12, 0.06, 0.10), SAND, bevel=0.03)
b.mark(at=(0.20, -1.12, _sigil_z), size=0.11, facing=(0.0, -0.94, 0.30))

b.done(out_path(), name="YokeOx")
