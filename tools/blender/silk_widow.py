"""The Silk Widow - the elite-pool beast that punishes going shieldless.

Ledges at Height 2 and 4, sigil at 6. Its bent rule is `frail` paired with an
`undefended`-gated `attack`: two Frail applications a cycle chip away at the
Block hunters can gain, and the one move that spikes hard (18 vs a baseline
10-11) only spikes if a hunter has ZERO Block when it comes up. Stone Warden
already has one `undefended` move, but it is one move among four next to a
`height_split` limiter that is the actual centrepiece; this is the first
beast where staying defended against a beast actively working to strip your
Block IS the whole puzzle, rather than a strategy none of the others touch.
Mire Snapper drains, Frost Sentinel wards with Artifact, Grove Bear enrages,
Shifting Idol moves the sigil, Gloom Moth clogs the deck, Bog Leech escalates
- none of them ask "can you keep a shield up while something erodes it".

A spider built low and splayed: a small forward cephalothorax with fangs and
a huddle of eyes, a big swollen abdomen behind it carrying a red hourglass
mark on the underside, and six long bent-kneed legs.
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import out_path, mirror, point, CHARCOAL, GRAPHITE, SLATE, STEEL, \
                   RED, BRICK

b = Beast("silk_widow", height=3.2, span=(0.00, 2.42))

# ------------------------------------------------------------------- legs
# Three pairs, bent-kneed - hip near the cephalothorax/abdomen join, an
# elevated outward knee, then down to a foot on the ground. The elevated
# knee (higher than both the hip and the foot) is what reads as "spider"
# rather than "dog": a straight taper down would read as the four-legged
# beasts already in the cast.
for sx in (-1, 1):
    for ly in (-0.60, -0.05, 0.55):
        b.limb([(0.40 * sx, ly, 0.92), (0.98 * sx, ly * 1.05, 0.68),
               (0.78 * sx, ly * 0.95, 0.26), (0.62 * sx, ly * 0.90, 0.02)],
               [0.10, 0.075, 0.05, 0.028], CHARCOAL, seg=6)

# -------------------------------------------------------------- cephalothorax
b.ball((0.0, -0.95, 0.98), (0.42, 0.46, 0.36), GRAPHITE, 10, 6)
# Fangs, pointing down and forward.
mirror(lambda s: b.taper((0.14 * s, -1.28, 0.82), 0.05, 0.012, 0.22, CHARCOAL,
                         seg=5, rot=point((0.10 * s, -0.55, -1.0))))
# A huddle of small eyes, barely eyes, enough to read as a face. STEEL
# against the GRAPHITE head so they resolve as two dots instead of
# disappearing into it (CHARCOAL-on-GRAPHITE never read in any lit view).
mirror(lambda s: b.ball((0.16 * s, -1.22, 1.14), (0.055, 0.05, 0.05),
                        STEEL, 6, 4))
mirror(lambda s: b.ball((0.24 * s, -1.14, 1.08), (0.04, 0.035, 0.035),
                        STEEL, 6, 4))

# ------------------------------------------------------------------ abdomen
# The main mass - big, swollen, behind the cephalothorax rather than fused
# with it, so the silhouette reads as two lobes joined at a waist rather than
# one blob (the failure mode every ball-only earlier beast hit).
b.ball((0.0, 0.75, 1.35), (0.72, 0.98, 0.64), CHARCOAL, 12, 7)
# The waist pinch - generously sized and centred to overlap BOTH the
# cephalothorax and the abdomen's bounding boxes, since the two are too far
# apart along Y to touch directly. A first attempt left a 0.14-unit gap
# here and the whole front half (cephalothorax, fangs, eyes, front legs)
# came back as its own floating island - finish()'s touch test is a real
# bounding-box overlap, not "looks close in the viewport".
b.ball((0.0, -0.45, 1.05), (0.32, 0.40, 0.32), GRAPHITE, 8, 5)

# Red hourglass marking on the underside - two tapers meeting point to point,
# thin in Z so it reads as flat marking against the belly rather than a
# separate horn.
mirror(lambda s: b.taper((0.0, 0.55 + 0.34 * s, 0.66), 0.24, 0.02, 0.30, RED,
                         seg=4, rot=point((0.0, -s, 0.0))))

# --------------------------------------------------------------- the ledges
# Two ridged plates stepping up the abdomen's spine, each a hump the shelf
# grows out of. Anchored off the centreline (x=0.30ish) rather than on it -
# a centred anchor on this body's own symmetric, elongated abdomen reads to
# beast.py's auto-placement as "outward along the whole abdomen's length"
# instead of "outward off this one plate", the same failure Bog Leech's and
# Thrasher's holds both hit and fixed the same way.
b.ball((0.30, 0.45, 1.85), (0.30, 0.32, 0.26), GRAPHITE, 9, 5)
b.shelf(2, (0.28, 0.40), (0.22, 0.20), STEEL, thickness=0.13, bevel=0.05)

b.ball((0.26, 0.95, 2.20), (0.24, 0.24, 0.22), SLATE, 8, 5)
b.shelf(4, (0.24, 0.90), (0.18, 0.16), STEEL, thickness=0.12, bevel=0.05,
        drop=0.02)

b.foot((0.55, -0.75, 0.02))                                    # onto a foreleg

# A small dedicated crest for the sigil, touching the ABDOMEN directly rather
# than the ridge humps above it. A first attempt anchored the crest against
# ridge hump 2 and the mark still came back 86% occluded: assetcheck's front
# axis runs along the body's OWN build -Y (the ridges sit at y=0.45/0.95,
# solidly behind y=0), so anything anchored near them inherits their depth no
# matter how far the crest itself is nudged forward off centreline - the
# lesson bog_leech/thrasher's write-ups are about X/Z burial, not this DEPTH
# one. Anchoring against the abdomen's own front hemisphere (y near 0, well
# ahead of both ridges) fixes it at the source instead of fighting it with an
# ever-longer bridge.
_sigil_z = b.z_for(6)
b.ball((0.35, 0.15, _sigil_z + 0.08), (0.22, 0.16, 0.22), GRAPHITE, 8, 5)
# A longer bridge than Bog Leech's or Thrasher's needed - a first attempt at
# y=-0.22 still came back 51% occluded, so the mark is pulled a further 0.3
# forward here, well clear of both ridge humps' own measured forward reach
# (~y=0.19-0.30 at this column). Thickened base (0.10 -> 0.18) and shortened
# by a third (0.75 -> 0.50) so it reads as a stubby horn fused to the
# abdomen instead of a wire with the sigil disc floating at the far end.
b.taper((0.35, -0.35, _sigil_z), 0.18, 0.04, 0.50, GRAPHITE, seg=6,
        rot=point((0.0, -1.0, 0.0)))

# The sigil: a taut vein-mark on the crest, pulled well forward of the
# crest's own surface rather than sitting at its edge.
b.mark(at=(0.35, -0.55, _sigil_z), size=0.16, facing=(0.0, -0.94, 0.30))

b.done(out_path(), name="SilkWidow")
