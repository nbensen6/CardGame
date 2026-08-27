"""The Bog Leech - the elite-pool beast that gets worse the longer you leave it.

Ledges at Height 2 and 4, sigil at 6. Its bent rule pairs `leech` with
`enrage`: every bite it lands both drains and heals it AND feeds its
strength, so the longer the fight runs the harder its NEXT bite hits - a
compounding threat rather than a flat one. None of the other elites make
that pairing their whole pattern: Mire Snapper spends leech as one move among
five generalist ones, Frost Sentinel wards with Artifact, Grove Bear enrages
but never heals off it, Shifting Idol moves the sigil, Gloom Moth clogs your
deck rather than your health bar. Husk Beetle (fight pool) also punishes slow
play, but passively - it just heals; nothing it does gets stronger by hurting
you.

A squat, swollen leech hunched low over its own puddle: a ringed, segmented
body with a wet sucker-mouth at the front-bottom, two fed-fat body-segments
stepping up its back, a raised tail-sac, and a small crest off to one side
where a taut, engorged vein-mark - the sigil - sits.
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import out_path, mirror, point, PEWTER, STONE, SLATE, CHARCOAL, \
                   GRAPHITE, BRICK

b = Beast("bog_leech", height=3.0, span=(0.08, 2.71))

# ---------------------------------------------------------------- underside
# No legs - a leech grips with its body, not limbs. Small sucker-pads along
# the underside give it contact points and a bit of character without
# reading as legs, which would say "insect" rather than "leech".
for ly in (-0.95, -0.30, 0.35, 1.00):
    mirror(lambda s, ly=ly: b.ball((0.34 * s, ly, 0.18), (0.16, 0.15, 0.10),
                                    CHARCOAL, 8, 5))

# ------------------------------------------------------------------ the mass
# One long swollen body, low and heavy - a creature built to squat and drain,
# not to move fast.
b.ball((0.0, -0.05, 1.05), (0.94, 1.38, 0.80), PEWTER, 12, 7)        # main sac

# Ring seams: thin belly stripes, blood-red so they read as veins under a
# stretched hide. A first attempt made these thin only in Y (full body width
# and height) and, viewed head-on down that same thin axis, each one
# rendered as a giant flat red wall covering the whole silhouette - the
# preview caught it, the automated checks did not. Thin in Y AND Z instead,
# low on the belly, so they read as stripes rather than a curtain.
for yy in (-0.85, -0.20, 0.45, 1.05):
    b.box((0.0, yy, 0.55), (0.86, 0.026, 0.07), BRICK, bevel=0.0)

# Front sucker-mouth: low, wet, dark, angled down and forward the way a
# leech's real mouth is on its underside rather than the front of its face.
b.ring((0.0, -1.42, 0.55), (0.30, 0.30, 0.20), GRAPHITE, 14, 5,
       rot=point((0.0, -1.0, 0.55)), thickness=0.10)
b.ball((0.0, -1.44, 0.52), (0.15, 0.11, 0.11), CHARCOAL, 8, 5)        # mouth well
# A pair of small dark eye-spots just above the mouth - barely eyes, enough
# to read as a face from the front.
mirror(lambda s: b.ball((0.20 * s, -1.36, 0.86), (0.08, 0.06, 0.07),
                        CHARCOAL, 7, 4))

# --------------------------------------------------------------- the ledges
# Two fed-fat segments stepping up the back, each a hump the shelf grows out
# of - the same "hump, then a flat step on its own front slope" trick
# crag_pup and gloom_moth use, rather than a slab standing free of the body.
b.ball((0.0, 0.15, 1.95), (0.62, 0.58, 0.44), STONE, 10, 6)          # first hump
b.shelf(2, (0.30, 0.14), (0.34, 0.32), SLATE, thickness=0.14, bevel=0.05)

b.ball((0.0, 0.62, 2.28), (0.44, 0.38, 0.32), PEWTER, 9, 5)          # second hump
b.shelf(4, (0.24, 0.60), (0.26, 0.24), SLATE, thickness=0.13, bevel=0.05,
        drop=0.02)

# --------------------------------------------------------------- the tail-sac
# A raised, engorged sac at the rear - the fattest, most fed-looking part of
# the body.
b.ball((0.0, -0.10, 2.30), (0.30, 0.24, 0.26), STONE, 9, 5)
b.ball((0.0, -0.20, 2.55), (0.18, 0.15, 0.16), PEWTER, 8, 5)

# A small dedicated crest for the sigil to sit on, off the spine's own
# centreline. Three earlier attempts kept it at x=0 and all three came back
# buried - the auto-push machinery in beast.py's _decorate() computes its
# outward direction from the offset between a climb point and the model's
# OWN bounding-box centre, and a point that sits almost exactly on that
# centre line (as every centred anchor on this spine does) turns that
# direction unstable: the same failure mode gloom_moth's wing-hold shelves
# hit and fixed the same way - anchor off to ONE side of the ridge, not on
# the seam between two. Reused here for the sigil itself, not just a hold.
# Flat on purpose - shallow in Y (depth) so its own front surface stays
# close to its centre, which is where the mark sits: a round ball here
# buries the mark under its own front hemisphere every time, round after
# round, since the ball's radius toward the camera is always bigger than
# the sliver of taper mark() lets poke out past "here". A shallow welt
# rather than a full knob gives the mark room to actually clear it.
b.ball((0.40, -0.30, 2.32), (0.20, 0.10, 0.20), STONE, 8, 5)
# A thin bridge out to where the mark sits - pulling the mark clear of the
# crest's own front surface (needed to pass the sigil-visibility check)
# opened a gap between it and the rest of the body; finish() flags any part
# that floats free, so this closes it without adding the crest's own bulk
# back at the sigil's height.
b.taper((0.40, -0.48, 2.30), 0.07, 0.025, 0.38, STONE, seg=6,
        rot=point((0.0, -1.0, 0.0)))

b.foot((0.34, -0.95, 0.20))                                    # onto a sucker-pad

# The sigil: a taut, engorged vein-mark, pulled well out in front of the
# crest's own surface rather than sitting at its centre. Placing the mark AT
# a ball's centre (the same shape gloom_moth's forehead crest uses) only
# clears the ball's own front hemisphere when the ball's centre HEIGHT
# doesn't coincide with the mark's own height - mine did, by construction
# (the ball was centred at the sigil's own z), so the ball's own widest,
# most-forward cross-section sat exactly where the mark needed to be. Pulled
# forward of that surface with real margin, not a hand-measured "just clears
# it" guess, since a low-poly ball bulges past its idealised surface anyway.
b.mark(at=(0.40, -0.70, b.z_for(6)), size=0.18, facing=(0.0, -0.94, 0.30))

b.done(out_path(), name="BogLeech")
