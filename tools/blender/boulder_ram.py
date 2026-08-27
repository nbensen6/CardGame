"""The Boulder Ram - the fight-pool beast that punishes staying down.

Ledges at Height 2 and 4, sigil at 5. Its bent rule is the first beast to use
the `max_height` `when` condition (backlog #40 named it, nothing had spent
it): a heavy `attack_all` only lands if a hunter is still at Height 1 or
below when it comes up, dropping to a single mild `attack` if everyone has
climbed clear. Crag Pup punishes camping the SIGIL, Thrasher punishes
camping EITHER height by alternating swipes; this is the first beast that
punishes camping the GROUND - the opposite read of the same climb, and the
one board state none of the other seven new-content beasts ask about.

A low, block-shouldered quadruped built for a charge rather than a bite: four
thick stubby legs, a wide barrel chest, a raised stony hump over the front
shoulders carrying curled ram horns and a lowered head. Boxy stone-plate
colours (STONE, CLAY, UMBER, TAN) rather than the smooth organic palette the
elite-pool beasts wear, so the silhouette reads as "boulder" before it reads
as "animal".
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import out_path, mirror, point, STONE, CLAY, UMBER, TAN, BROWN, \
                   CHARCOAL

b = Beast("boulder_ram", height=3.0, span=(0.03, 1.87))

# ------------------------------------------------------------------- legs
# Four short, thick legs, wide for a low centre of mass - a body built to
# plant and charge rather than run. Front pair sits slightly wider than the
# rear, the same "braced for impact" stance a battering animal takes.
for sx in (-1, 1):
    for ly in (-0.58, 0.55):
        b.limb([(0.44 * sx, ly, 0.85), (0.56 * sx, ly * 1.02, 0.42),
               (0.50 * sx, ly * 0.98, 0.04)], [0.19, 0.15, 0.09],
               CHARCOAL, seg=6)

# ------------------------------------------------------------------ the mass
b.box((0.0, 0.0, 0.95), (0.60, 0.95, 0.40), CLAY, bevel=0.06)          # barrel chest
b.ball((0.0, -0.15, 1.45), (0.46, 0.55, 0.42), UMBER, 12, 7)           # shoulder hump

# Head: a wedge lowered forward for a charge, rather than a ball, so it reads
# as a battering face instead of another lump. wedge()'s narrow end already
# points -Y (forward), which is exactly where a lowered head should point.
b.wedge((0.0, -1.30, 0.55), (0.30, 0.40, 0.26), BROWN, narrow=(0.42, 0.55))
mirror(lambda s: b.ball((0.15 * s, -1.52, 0.66), (0.06, 0.05, 0.05),
                        CHARCOAL, 6, 4))                                # eye

# Curled ram horns - up and back over the head, the shape that reads
# "ram" rather than "dog" or "boar". limb() carries a non-twisting frame
# through the curl so it doesn't come out looking like a drill bit.
mirror(lambda s: b.limb([(0.18 * s, -1.15, 0.78), (0.40 * s, -1.05, 1.08),
                         (0.54 * s, -0.82, 1.20), (0.48 * s, -0.60, 1.10)],
                        [0.09, 0.07, 0.05, 0.02], TAN, seg=6))

# --------------------------------------------------------------- the ledges
# Two flank plates stepping up the shoulder, each anchored off the body's own
# centreline (x=0.26-0.30) rather than on it. A centred anchor on this body's
# own symmetric, elongated torso reads to beast.py's auto-placement as
# "outward along the whole torso's length" instead of "outward off this one
# plate" - the failure Bog Leech's, Thrasher's and Silk Widow's holds all hit
# and all fixed the same way.
b.ball((0.30, 0.05, 1.10), (0.26, 0.28, 0.22), STONE, 9, 5)
b.shelf(2, (0.28, 0.00), (0.20, 0.18), STONE, thickness=0.12, bevel=0.05)

b.ball((0.28, -0.30, 1.62), (0.22, 0.24, 0.20), CLAY, 8, 5)
b.shelf(4, (0.26, -0.35), (0.17, 0.15), CLAY, thickness=0.11, bevel=0.05,
        drop=0.02)

# ----------------------------------------------------------------- the tail
# A short stub, not raised over the spine - this beast's whole silhouette
# stays low and forward-weighted (a charge posture), unlike Thrasher's tail
# curling up to make the sigil height.
b.taper((0.0, 0.92, 0.62), 0.14, 0.03, 0.30, CHARCOAL, seg=6,
        rot=point((0.0, 0.75, -0.55)))

b.foot((0.59, -0.57, 0.04))                                    # onto a foreleg, at its surface

# A dedicated crest for the sigil, touching the HUMP directly rather than
# either flank plate - the lesson Silk Widow's write-up names: anchoring near
# a ridge that sits well behind the body's own front hemisphere inherits that
# ridge's depth no matter how far the crest is nudged forward off centreline.
# The hump spans y -0.70..0.40 here, so a crest at y=-0.60 touches it at the
# hump's own front face rather than its side.
#
# Two things learned building this one that neither Bog Leech's nor Silk
# Widow's write-ups say outright, because assetcheck's occlusion test only
# compares geometry within a narrow HEIGHT BAND around the sigil (+/-5.5% of
# the model's own height), not the whole silhouette: pushing the mark further
# forward along the SAME straight line as a crest/bridge behind it does
# nothing, since an orthographic check keeps whatever is directly behind it
# on that ray behind it no matter the distance - the fix has to break the
# straight line, not lengthen it. And a bridge whose FAR TIP lands inside
# that same height band, even by a hair, reads as "other" geometry sitting
# in front of the gold disc's own trailing edge and gets counted against it.
# So the crest and its bridge are kept entirely BELOW the sigil's own height
# band here - close enough (within the sigil-lands reach) that the mark still
# reads as touching a real surface, but out of the band the occlusion test
# actually samples.
_sigil_z = b.z_for(5)
# A first attempt hung the mark off a ball-and-stalk crest well clear of the
# hump - it passed every contract check (45% occluded) but the rendered
# preview showed exactly the failure this file's own README warns about: a
# grey ball on a stick reading as a periscope bolted to the shoulder, not
# part of the creature. Looking at the render (not just the contract) is
# what caught it. This mounts the mark almost flush instead: a small plate
# recessed into the hump's own front face, the mark sitting just proud of
# it - a shoulder-mounted sigil rather than an antenna.
b.box((0.32, -0.68, _sigil_z), (0.14, 0.06, 0.14), STONE, bevel=0.03)
b.mark(at=(0.32, -0.80, _sigil_z), size=0.12, facing=(0.0, -0.94, 0.30))

b.done(out_path(), name="BoulderRam")
