"""The Clot Toad - the elite-pool beast whose bent rule punishes attrition
rather than board position.

Ledges at Height 2 and 4, sigil at 6. Its bent rule is `hurt_pct`/`hurt_moves`
(backlog #44), spent before this only by Crag Pup, Mire Snapper, Gale Serpent
and Cinder Jackal - and every one of those four gets MORE dangerous below the
threshold (bigger hits, `enrage`, a faster pattern). This is the first one
that goes the other way: below 40% HP its pattern swaps to `regen` + `block`
almost exclusively, so a slow chip-damage strategy that leaves it hovering
just under the line lets it scab back over and pop back above the threshold,
undoing the work. The puzzle is not "survive the enrage" like the other four,
it is "commit to a real burst once it's low, or it stalls the fight
indefinitely" - the opposite lesson from the same two data fields.

A squat warty toad sitting low and wide rather than a quadruped built to
move fast: four short bent legs, a flat wide head with eyes bulging on TOP
(a toad's own silhouette, not a snout-forward predator), and a stepped
glandular ridge up its spine ending in a swollen, scabbed-over gland at the
tail where the sigil sits - the same gland that visibly "clots" the fight
back together when the beast is low. Sandy warm palette (SAND/WHEAT skin,
CREAM throat) with dark clot-red BRICK patches, distinct from every other
elite: Mire Snapper's swamp clay, Frost Sentinel's ice white, Grove Bear's
forest green, Shifting Idol's grey stone, Gloom Moth's slate purple, Bog
Leech's pond murk, Silk Widow's charcoal web, Brine Urchin's marine coral.

The torso is deliberately kept SHORT along Y (front-to-back) rather than the
long, egg-shaped body a first attempt used: a torso whose own back edge
reaches nearly as far back as the tail ridge gives beast.py's own
axis-relative hold placement no clear "the ridge sticks out past the body"
signal to push a climb point toward, and it kept dragging every hold's
anchor out to the torso's OWN far edge instead of the small ridge actually
meant to carry it. The ridge mounds are also placed at fixed, hand-picked
heights rather than through `z_for()` - z_for() depends on `span`, and a
mound whose own position depends on span while span is itself measured FROM
that mound's position is a feedback loop, not a fixed point (the first
attempt's span estimate never converged and the model kept stretching taller
and thinner every pass). `z_for()` is used below only for the thin shelf/mark
surfaces sitting ON these fixed mounds, exactly like every other beast script.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import out_path, mirror, point, SAND, WHEAT, CREAM, CLAY, BRICK, \
                   GOLD, GRAPHITE

b = Beast("clot_toad", height=2.2, span=(0.02, 1.55))

# ------------------------------------------------------------------- the legs
# Short and bent, planted wide for a low centre of mass - a toad squats, it
# does not stand tall on its legs the way a quadruped predator would.
for sx in (-1, 1):
    for sy, ly, thigh, size in ((-1, -0.46, 0.24, 0.20), (1, 0.40, 0.27, 0.23)):
        b.ball((0.62 * sx, ly, thigh), (size, size * 0.9, size * 0.85), CLAY, 9, 5)
        b.ball((0.67 * sx, ly * 1.05, 0.09), (size * 0.9, size, size * 0.30),
               CLAY, 9, 5)

# ------------------------------------------------------------------- the mass
# Wide and flat, and short front-to-back - a toad's body reads as squashed
# and roughly as wide as it is long, not a long egg with a head on one end.
b.ball((0.0, 0.0, 0.50), (0.86, 0.62, 0.34), SAND, 14, 8)           # torso
b.ball((0.0, -0.04, 0.28), (0.70, 0.50, 0.18), CREAM, 12, 7)        # pale belly, lower

# Wide flat head, forward and low - a toad's face is most of its front, not a
# narrow snout on a long neck.
b.ball((0.0, -0.74, 0.46), (0.50, 0.38, 0.30), SAND, 12, 7)
b.ball((0.0, -0.96, 0.36), (0.26, 0.18, 0.16), WHEAT, 9, 5)         # jowl/mouth mass

# Eyes bulge on TOP of the head, not the sides - the single most toad-specific
# silhouette cue there is.
mirror(lambda s: b.ball((0.24 * s, -0.74, 0.66), (0.15, 0.14, 0.15), GOLD, 9, 5))
mirror(lambda s: b.ball((0.24 * s, -0.80, 0.69), (0.07, 0.065, 0.07), GRAPHITE, 7, 4))

# The mouth line - a wide downturned wedge, not a jaw that opens.
b.wedge((0.0, -1.02, 0.30), (0.30, 0.08, 0.05), GRAPHITE, narrow=(0.55, 0.6))

# Warts scattered across the back - small pale bumps that break up the smooth
# torso into skin rather than a boulder.
for wx, wy, wz, wr in ((-0.48, 0.16, 0.72, 0.10), (0.40, -0.14, 0.75, 0.09),
                       (-0.24, -0.30, 0.66, 0.08), (0.50, 0.20, 0.62, 0.10),
                       (-0.58, -0.06, 0.55, 0.085)):
    b.ball((wx, wy, wz), (wr, wr, wr * 0.75), WHEAT, 6, 4)

# --------------------------------------------------------------- the ledges
# A stepped glandular ridge running back along the spine - each mound clears
# the torso's own back edge (y=0.62) by a wide margin, so it reads clearly as
# the far point in that direction rather than getting lost against a torso
# that reaches almost as far itself. Off the body's own centreline (x != 0),
# not on it - the same fix Thrasher's own build needed, since even a SHORT
# body still gives a centred anchor no single "outward" side to prefer.
b.ball((0.28, 0.62, 0.74), (0.32, 0.28, 0.22), CLAY, 11, 6)
b.shelf(2, (0.28, 0.60), (0.26, 0.20), CLAY, thickness=0.11, bevel=0.04)

b.ball((0.24, 0.94, 1.04), (0.27, 0.24, 0.20), CLAY, 10, 6)
b.shelf(4, (0.24, 0.92), (0.21, 0.17), CLAY, thickness=0.10, bevel=0.04,
        drop=0.02)

b.foot((0.65, -0.42, 0.24))                                    # onto a foreleg

# The gland: a swollen, scabbed-over mound at the tail, the tallest point on
# the body and where the sigil sits - the same gland that visibly "clots"
# back together when the beast turtles below 40% HP. A flat scab-plate on its
# crown gives the hold check real upward-facing area to measure - a bare
# sphere's tip is a point, not a shelf, the same fix Brine Urchin's own sigil
# mount used.
# Reaches BACK into the rump. At r_y 0.24 it stopped 0.011 short of the
# body — invisible, and still three parts the exporter counts as a
# separate object. A gland grows out of a back; it does not hover.
b.ball((0.16, 1.13, 1.08), (0.27, 0.31, 0.21), BRICK, 10, 6)
b.box((0.16, 1.04, b.z_for(6) - 0.02), (0.17, 0.10, 0.05), BRICK, bevel=0.03)
b.mark(at=(0.16, 0.93, b.z_for(6)), size=0.10, facing=(0.20, -1.0, 0.20))
# A small scab-crest just behind and above the sigil itself - without SOME
# geometry reaching higher than the mark, the body's own true top sits right
# at the mark and the sigil measures as ~87% of the body's height instead of
# the contract's 80%, since the contract wants headroom above the weak point
# the same way every other beast's own crown detail (Crag Pup's moss cap,
# Husk Beetle's tail-plate rise) already provides.
# Sat 0.010 above the gland it is supposed to be growing out of.
b.ball((0.14, 1.10, 1.37), (0.14, 0.13, 0.14), WHEAT, 8, 5)

b.done(out_path(), name="ClotToad")
