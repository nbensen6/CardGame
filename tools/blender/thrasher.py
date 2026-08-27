"""The Thrasher - the fight-pool beast that never lets you pick a height.

Ledges at Height 2 and 4, sigil at 5. Its bent rule is pure repositioning
pressure: `swipe_low` (hits anyone ON the ground) and `swipe_high` (hits
anyone OFF it) alternate as its whole pattern, so no height is ever safe two
turns running. Root Lurker punishes staying low, Sky Snapper punishes staying
high; this is the fight-pool beast that punishes staying ANYWHERE - reading
the telegraph and climbing or descending before it lands is the whole fight.

A low, crouched newt: four splayed legs, a long flat body, bright warning
colour down the throat and belly, and a tail that curls up and back over its
own spine like it is about to lash - the same up/down motion the fight makes
you dodge, worn as its own silhouette.
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import out_path, mirror, point, CHARCOAL, GRAPHITE, SLATE, STEEL, \
                   ORANGE, TANGERINE, RUST

b = Beast("thrasher", height=3.2, span=(-0.02, 2.36))

# ------------------------------------------------------------------- the legs
# Four short, splayed legs, wide for a low centre of mass - a body built to
# crouch and lash rather than run.
for sx in (-1, 1):
    for sy, ly in ((-1, -0.62), (1, 0.58)):
        b.limb([(0.56 * sx, ly, 0.68), (0.86 * sx, ly * 0.92, 0.32),
               (0.80 * sx, ly * 0.86, 0.08)], [0.14, 0.10, 0.06],
               CHARCOAL, seg=6)
        b.taper((0.80 * sx, ly * 0.86, 0.06), 0.06, 0.012, 0.16, GRAPHITE,
                seg=4, rot=point((0.30 * sx, 0.08 * sy, -1.0)))

# ------------------------------------------------------------------ the mass
b.ball((0.0, 0.05, 0.90), (0.62, 1.28, 0.52), CHARCOAL, 12, 7)       # torso
# Bright warning belly, low and flat under the torso - a newt's own toxic
# throat-flash, not a shell, so the palette reads differently from Husk
# Beetle even though both step up the spine the same way.
b.box((0.0, 0.05, 0.46), (0.50, 1.05, 0.10), ORANGE, bevel=0.04)

# Head: a wedge rather than a ball, so it reads as a flat snout instead of
# another lump. wedge()'s narrow end already points -Y (forward, toward the
# camera), which is exactly a snout's own direction - no rotation needed.
b.wedge((0.0, -1.20, 0.62), (0.34, 0.46, 0.22), GRAPHITE,
        narrow=(0.35, 0.55))
mirror(lambda s: b.ball((0.16 * s, -1.44, 0.78), (0.075, 0.06, 0.065),
                        RUST, 7, 4))                                  # eye
b.box((0.0, -1.52, 0.54), (0.24, 0.10, 0.05), TANGERINE, bevel=0.02)  # throat flash

# --------------------------------------------------------------- the ledges
# Two ridge-humps stepping up the spine, offset from the centreline - a
# centred anchor on this body's own symmetric, elongated spine comes back
# with an unbounded "outward" push: beast.py's auto-placement reads the
# whole torso's LENGTH as "outward" when the anchor sits on the axis that
# length runs along, dragging the climb point (and the steps grown to reach
# it) out toward the tail. The same failure Bog Leech's holds hit, fixed the
# same way - anchor off to ONE side, never on the centreline, so "outward"
# resolves sideways across the torso's short axis instead of along its long
# one.
b.ball((0.30, 0.15, 1.15), (0.30, 0.34, 0.26), CHARCOAL, 9, 5)       # first ridge
b.shelf(2, (0.28, 0.10), (0.22, 0.20), STEEL, thickness=0.13, bevel=0.05)

b.ball((0.26, 0.55, 1.85), (0.24, 0.26, 0.22), GRAPHITE, 8, 5)       # second ridge
b.shelf(4, (0.24, 0.50), (0.18, 0.16), SLATE, thickness=0.12, bevel=0.05,
        drop=0.02)

# ---------------------------------------------------------------- the tail
# Curls up and forward over the spine - the same up/down lash the fight makes
# you dodge, worn as the beast's own silhouette. Kept well short of the sigil
# height so it doesn't drag the measured span (and every hold fraction with
# it) upward the way an unrelated tall flourish would, and started behind
# both ridges so it doesn't share their climb points' z-band.
b.limb([(0.0, 0.95, 1.10), (0.0, 1.32, 1.68), (0.0, 1.10, 2.14),
       (0.0, 0.72, 2.34)], [0.20, 0.15, 0.09, 0.02], CHARCOAL, seg=7)

# A small dedicated crest for the sigil, off the spine's own centreline - the
# same reason the ridge shelves above are. Its centre sits at the sigil's own
# Height, which is exactly the trap Bog Leech's first attempt hit: a low-poly
# ball's widest cross-section is at its own centre, so a mark merely nudged
# off its surface at the SAME height is still buried under that bulge no
# matter how far it is pushed sideways. The fix that actually worked there
# was real forward clearance - the mark sits a full radius-and-a-half in
# front of the crest's own edge, not a hand-measured "just clears it" - with
# a thin stalk bridging the gap so finish() doesn't flag it as floating.
b.ball((0.34, 0.30, b.z_for(5)), (0.16, 0.09, 0.16), GRAPHITE, 8, 5)
b.taper((0.34, -0.02, b.z_for(5) - 0.02), 0.07, 0.02, 0.46, GRAPHITE, seg=6,
        rot=point((0.0, -1.0, 0.0)))

b.foot((0.80, -0.62, 0.08))                                    # onto a foreleg

# The sigil, pulled well forward of the crest's own surface rather than
# sitting at its edge - see the comment above.
b.mark(at=(0.34, -0.24, b.z_for(5)), size=0.16, facing=(0.0, -0.94, 0.30))

b.done(out_path(), name="Thrasher")
