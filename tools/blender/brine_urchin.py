"""The Brine Urchin - the elite-pool beast whose bent rule punishes reaching
the sigil ALONE rather than rewarding it.

Ledges at Height 2 and 4, sigil at 6. Every prior `at_sigil` gate (Crag Pup)
turns the sigil into a bigger single-target hit - camp it and only the
camper pays. This one pairs `at_sigil` with `attack_all` instead: the moment
EITHER hunter is at Height 6, the whole board flinches and BOTH hunters take
the sweep. Reaching the true weak point is not free reconnaissance anymore -
it is an alarm the other hunter eats too, so the co-op question becomes
"is my ally braced (or already swinging) before I commit to the climb,"
not "can I solo the sigil safely." No other beast pairs `at_sigil` with
`attack_all`; Boulder Ram and Frost Sentinel gate `attack_all` on height
thresholds instead, which is a board-position check rather than a
weak-point one.

A squat, radial thing clamped to a rock rather than a quadruped: a spined
ball body ringed with tapered spines at odd angles (an urchin's own
silhouette, not a creature with a front and back), four short clinging
tendrils gripping the base rock, and a single glowing eye/mouth at the
crown where the sigil sits - the thing that flares when you reach it.
Cool marine palette (CORAL/BRICK body, VIOLET/IRIS spine tips) against a
STONE anchor, distinct from every other elite: Mire Snapper's swamp clay,
Frost Sentinel's ice white, Grove Bear's forest green, Shifting Idol's
grey stone, Gloom Moth's slate purple, Bog Leech's pond murk, Silk Widow's
charcoal web.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import out_path, mirror, point, CORAL, BRICK, VIOLET, IRIS, \
                   STONE, GRAPHITE, GOLD

b = Beast("brine_urchin", height=2.9, span=(-0.02, 2.17))

# ------------------------------------------------------------------ the base
# A rock anchor with four short clinging tendrils - it is CLAMPED to
# something, not standing on legs, so the climb starts at the rock rather
# than at a foot.
b.ball((0.0, 0.0, 0.30), (0.62, 0.62, 0.32), STONE, 10, 6)
for ang in (40, 140, 220, 320):
    dx, dy = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    b.limb([(dx * 0.30, dy * 0.30, 0.42), (dx * 0.56, dy * 0.56, 0.30),
           (dx * 0.66, dy * 0.66, 0.10)], [0.12, 0.10, 0.06], GRAPHITE, seg=6)

# ------------------------------------------------------------------ the mass
# One big radial body - no front/back the way a quadruped has, which is the
# point: an urchin reads the same from every side, unlike every other elite.
b.ball((0.0, 0.0, 1.35), (0.88, 0.88, 0.82), CORAL, 14, 8)
b.ball((0.0, 0.0, 0.66), (0.66, 0.66, 0.42), BRICK, 12, 7)   # darker underside collar

# Spines radiating outward and slightly up, at even 36-degree spacing so
# there is a full spine's-width of clear gap straight ahead (270 degrees,
# -Y) for the sigil to sit in unobstructed - length and pitch still vary
# per index so the silhouette reads as uneven spikes, not a gear, without
# any spine actually crossing the forward column the sigil mounts on.
#
# taper() centres the cone ON `loc` (Blender's own cone origin convention),
# not at its base - a spine authored with `loc` at the body surface and the
# tip computed from the FULL length floats its tip a half-length past the
# real cone, which is exactly why the first build's nine tip-marker balls
# came back detached. Centring the cone on `base + d*len/2` instead puts its
# true ends at `base` (embedded in the body) and `base + d*len` (the tip).
for i in range(10):
    ang = i * 36.0
    rad = math.radians(ang)
    dz = 0.34 if i % 2 else 0.12
    dx, dy = math.cos(rad), math.sin(rad)
    norm = math.sqrt(dx * dx + dy * dy + dz * dz)
    dx, dy, dz = dx / norm, dy / norm, dz / norm
    ln = 0.60 if i % 3 else 0.74
    base = (dx * 0.66, dy * 0.66, 1.32 + dz * 0.66)
    center = (base[0] + dx * ln * 0.5, base[1] + dy * ln * 0.5,
              base[2] + dz * ln * 0.5)
    b.taper(center, 0.095, 0.015, ln, CORAL if i % 2 else BRICK, seg=6,
            rot=point((dx, dy, dz)))
    tip = (base[0] + dx * ln, base[1] + dy * ln, base[2] + dz * ln)
    b.ball(tip, (0.045, 0.045, 0.045), VIOLET if i % 2 else IRIS, 6, 4)

# --------------------------------------------------------------- the ledges
# Two ring-step shelves stepping up the flank, each anchored off-centreline
# (not on the beast's own symmetric vertical axis) - a centred anchor on a
# radially symmetric body gives beast.py's auto-placement no single
# "outward" direction to push along, which is the failure every earlier
# radially-ish body (Bog Leech, Thrasher) hit on their own long axis.
_h2 = b.z_for(2)
b.ball((0.55, -0.30, _h2), (0.20, 0.20, 0.15), BRICK, 9, 5)
b.shelf(2, (0.52, -0.28), (0.20, 0.17), STONE, thickness=0.10, bevel=0.04)

_h4 = b.z_for(4)
b.ball((0.45, 0.42, _h4), (0.19, 0.19, 0.14), BRICK, 8, 5)
b.shelf(4, (0.42, 0.40), (0.17, 0.15), STONE, thickness=0.09, bevel=0.04,
        drop=0.02)

b.foot((0.60, 0.0, 0.16))                                     # onto the rock base

# A thin flush plate mount for the sigil, set directly on the main ball's
# own front surface at the sigil's Height (computed from the ball's own
# ellipsoid, not guessed) rather than a rounded hump - Boulder Ram's and
# Cinder Jackal's own lesson: a ball crest wraps forward past its own
# centre and can occlude the mark it is meant to be showing off no matter
# how far the mark itself is nudged. Sitting due forward (x=0, the 18-
# degree gap between the two nearest spines) keeps every spine's own reach
# clear of this column, which a first build (spines phase-jittered, sigil
# tucked in at y=-0.40) did not guarantee and came back 100% buried.
_sigil_z = b.z_for(6)
_frac = (_sigil_z - 1.35) / 0.82
_r_xy = math.sqrt(max(0.0, 1.0 - _frac * _frac)) * 0.88
_sigil_y = -(_r_xy + 0.06)
b.box((0.0, _sigil_y, _sigil_z - 0.02), (0.16, 0.06, 0.16), BRICK, bevel=0.03)
b.mark(at=(0.0, _sigil_y - 0.10, _sigil_z), size=0.16, facing=(0.0, -1.0, 0.0))

b.done(out_path(), name="BrineUrchin")
