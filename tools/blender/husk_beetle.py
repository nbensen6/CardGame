"""The Husk Beetle - the fight-pool beast that does not want to be finished off.

Ledges at Height 2 and 3, sigil at 5. Its bent rule is `regen`: leave it alone
and its cracked shell knits itself back together, so the fight rewards a burst
of pressure over a slow grind - the opposite lesson every other fight-tier
beast (Crag Pup, Bounder, ...) teaches by just standing there and taking hits.

A stout ground beetle, low and armoured, climbing up its own back: two
segmented shell-plates stepping up from the thorax to a raised tail plate the
sigil sits on, mandibles up front, four stubby legs planted wide for a low
centre of mass - nothing here needs to be fast, it needs to be hard to end.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import out_path, mirror, point, UMBER, BROWN, CLAY, TAN, WHEAT, \
                   CHARCOAL, GRAPHITE, AMBER, RUST, STEEL, SLATE

b = Beast("husk_beetle", height=3.0, span=(-0.01, 2.52))

# ------------------------------------------------------------------- the legs
for sx in (-1, 1):
    for sy, ly in ((-1, -0.70), (1, 0.42)):
        b.limb([(0.60 * sx, ly, 0.86), (0.92 * sx, ly * 0.94, 0.46),
               (0.84 * sx, ly * 0.88, 0.14)], [0.15, 0.115, 0.075],
               GRAPHITE, seg=6)
        b.taper((0.84 * sx, ly * 0.88, 0.10), 0.075, 0.015, 0.22, CHARCOAL,
                seg=4, rot=point((0.35 * sx, 0.10 * sy, -1.0)))

# ------------------------------------------------------------------ the mass
b.ball((0.0, 0.10, 1.02), (0.96, 1.35, 0.80), UMBER, 12, 7)          # thorax/shell
b.ball((0.0, -0.86, 0.86), (0.60, 0.56, 0.56), BROWN, 10, 6)         # head
b.ball((0.0, -1.32, 0.78), (0.34, 0.30, 0.30), CLAY, 9, 5)           # jaw mass

# Mandibles: big enough to read as jaws rather than whiskers, curved out and
# forward so they cross the head's own silhouette instead of hiding against it.
mirror(lambda s: b.taper((0.22 * s, -1.40, 0.68), 0.15, 0.02, 0.58, RUST,
                         seg=5, rot=point((0.80 * s, -0.55, -0.30))))
mirror(lambda s: b.taper((0.34 * s, -1.56, 0.56), 0.09, 0.015, 0.30, CLAY,
                         seg=4, rot=point((0.60 * s, -0.80, -0.55))))
# Antennae: thicker and swept out well past the head's own width, so they
# show against the empty background rather than getting lost against the body.
mirror(lambda s: b.limb([(0.20 * s, -1.05, 1.20), (0.46 * s, -0.80, 1.48),
                         (0.66 * s, -0.48, 1.68)], [0.046, 0.032, 0.016],
                        CHARCOAL, seg=5, cap=False))
mirror(lambda s: b.ball((0.30 * s, -1.08, 0.98), (0.115, 0.10, 0.11),
                        CHARCOAL, 8, 5))                                # eye

# --------------------------------------------------------------- the shell steps
# Two plates stepping UP the beetle's own back, each doubling as its hold - the
# climb reads as scaling a segmented shell rather than a shelf bolted onto one.
# Steel-grey against the warm brown husk so the plates read as its own armour
# rather than blending into the body they step up out of.
b.shelf(2, (0.0, 0.30), (0.70, 0.44), STEEL, thickness=0.16, bevel=0.05)
b.shelf(3, (0.0, 0.66), (0.56, 0.38), SLATE, thickness=0.15, bevel=0.05,
        drop=0.02)
# A seam down the spine, the classic beetle elytra split, and one running
# between each pair of shell steps - breaks up the smooth dome into plates.
b.box((0.0, -0.30, 1.78), (0.020, 1.15, 0.030), CHARCOAL, bevel=0.0)
b.box((-0.46, 0.30, 1.36), (0.30, 0.020, 0.020), CHARCOAL, bevel=0.0,
      rot=(0.0, 0.0, 0.35))
b.box((0.46, 0.30, 1.36), (0.30, 0.020, 0.020), CHARCOAL, bevel=0.0,
      rot=(0.0, 0.0, -0.35))

# A raised tail-plate just behind the second step, high but pulled forward of
# the tail tip - the camera looks down -Y (a beetle's own -Y is its face), so
# anything left at the rearmost point of the body sits behind everything else
# in front of it and never reads. Keeping the plate's mass near the second
# shelf and putting the mark on its FRONT slope keeps the sigil in the clear.
b.ball((0.0, 0.35, 2.02), (0.44, 0.36, 0.42), BROWN, 10, 6)
b.ball((0.0, 0.50, 2.24), (0.27, 0.22, 0.24), UMBER, 9, 5)

b.foot((0.84, -0.66, 0.30))                                   # onto a foreleg

# The sigil, cracked and gold, on the front face of the tail-plate - facing
# -Y, toward the camera, the same direction every other beast's mark faces.
b.mark(at=(0.0, -0.20, b.z_for(5)), size=0.16, facing=(0.0, -0.94, 0.30))

b.done(out_path(), name="HuskBeetle")
