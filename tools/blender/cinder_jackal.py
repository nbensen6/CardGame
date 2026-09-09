"""The Cinder Jackal - the fight-pool beast that punishes a slow kill.

Ledges at Height 2 and 4, sigil at 5. Its bent rule is `hurt_pct`/`hurt_moves`
(backlog #44, named in boss.gd, spent so far only by two OLD beasts - Crag Pup
and Mire Snapper - and by neither of the six new-content beasts before this
one): below 40% of its max HP the whole pattern swaps to a harder one, for
the rest of the fight. Every other new-content beast punishes a BOARD choice
- a height, a defended/undefended state, the sigil itself. This is the first
one whose bent rule punishes a TIME choice: chip it down slowly and the back
half of the fight gets strictly worse (bigger attacks, a second attack_all,
and enrage stacking on top), so a lead you were happy to sit on becomes a
lead you have to press. Burst it past 40% and the fight stays exactly as
tame as it looked in the first three moves.

A lean, long-legged canid built for the chase rather than the charge: four
slender limbs (agile, not stubby the way Boulder Ram's are), a narrow ribby
torso, a wedge snout, erect pointed ears, and a low ember-coloured ridge down
the spine - a smouldering mane rather than a flame, so the palette hints at
"goes feral when hurt" without trying to depict the mechanic literally. Warm
fur colours (RUST, TANGERINE) against CHARCOAL/GRAPHITE, distinct from
Thrasher's cold newt palette and Boulder Ram's boxy stone one.
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import out_path, mirror, point, CHARCOAL, GRAPHITE, RUST, \
                   TANGERINE, AMBER, TAN

b = Beast("cinder_jackal", height=3.1, span=(0.05, 1.69))

# ------------------------------------------------------------------- the legs
# Four slender legs, narrower stance than a charging beast (Boulder Ram) or a
# crouching one (Thrasher) - a body built to stand tall and run, not brace.
for sx in (-1, 1):
    for ly in (-0.56, 0.52):
        b.limb([(0.30 * sx, ly, 1.02), (0.36 * sx, ly * 1.05, 0.54),
               (0.32 * sx, ly * 1.00, 0.05)], [0.12, 0.09, 0.07],
               CHARCOAL, seg=6)

# ------------------------------------------------------------------ the mass
b.ball((0.0, 0.05, 1.20), (0.42, 0.92, 0.38), RUST, 12, 7)             # ribby torso

# Shoulders and haunches. Nick, 2026-09-08: "limbs still don't seem like they
# are attached properly." They were not. A limb() tube simply ended INSIDE the
# torso ellipsoid, so where a shoulder should be there was a hard intersection
# curve and nothing else - and because the leg is CHARCOAL against a RUST body,
# that curve was also the strongest colour boundary on the model. Maximum
# contrast exactly where the eye looks for a joint reads as a part bolted on.
#
# Two things fix it and both are cheap: a mass in the BODY's colour that the leg
# emerges from, and moving the colour break off the joint and down the limb.
# These are the shoulders; the leg tops now sit inside them rather than inside
# the torso.
for _sx in (-1, 1):
    for _ly in (-0.56, 0.52):
        b.ball((0.29 * _sx, _ly, 1.00), (0.19, 0.25, 0.21), RUST, 9, 6)
b.box((0.0, 0.05, 0.90), (0.32, 0.66, 0.09), TAN, bevel=0.03)          # pale underbelly

# Head: a wedge lowered slightly forward for a hunting posture, not a ball,
# so it reads as a snout instead of another lump. wedge()'s narrow end
# already points -Y (forward), which is exactly a snout's own direction.
b.wedge((0.0, -1.18, 1.18), (0.24, 0.36, 0.20), GRAPHITE, narrow=(0.34, 0.52))
mirror(lambda s: b.ball((0.13 * s, -1.42, 1.30), (0.06, 0.05, 0.05),
                        AMBER, 7, 4))                                   # eye

# Erect pointed ears - a canid's own silhouette marker, distinct from every
# other fight-pool beast's head (none of them have ears at all).
mirror(lambda s: b.taper((0.15 * s, -0.98, 1.52), 0.11, 0.01, 0.30,
                         CHARCOAL, seg=5, rot=point((0.22 * s, -0.35, 1.0))))

# A low ember-coloured ridge down the spine - the "smouldering, not yet on
# fire" read that ties to the hurt_pct twist without depicting it literally.
# A limb() rather than a box: the old flat-topped box held one constant Z
# across the whole spine, so it floated clear of the torso's own curved top
# surface toward the front (a 0.16 gap at the shoulder) and read as a bolted-
# on rail rather than fur. Following the torso's curve and tapering the radii
# down at both ends (matching how the tail below is built) sits it flush and
# lets it thin out into the body instead of ending in a square edge.
b.limb([(0.0, -0.52, 1.44), (0.0, -0.05, 1.51), (0.0, 0.40, 1.49),
        (0.0, 0.72, 1.40)], [0.01, 0.09, 0.08, 0.01], TANGERINE, seg=6)

# --------------------------------------------------------------- the anchor
# Queue item 4. The ridge above is real but the fight camera views the
# spine's TOP edge nearly end-on (item 1a: only 2/44 of its faces clear the
# remeshed body from that angle), so more ridge does not turn into more
# screen area. The queue's own fix direction: something that breaks the
# silhouette to the SIDE instead, off the neck/shoulders. This is that -
# a mirrored pair of smouldering hackle spikes rooted at the base of the
# neck, swept up and back and out past the torso's own half-width (0.42),
# so they add to the SAME axis (screen-space left/right) this near-frontal
# fight camera actually reads, the way the mirrored ears already prove reads
# from here. Base radius 0.17 against unionremesh.py's 0.06 voxel is roughly
# 3x the voxel size, so it is meant to survive the remesh as a chunky bump
# on its own, unlike the thin ridge and the eyes - no union.txt hold-out
# added for it; see the queue write-up for whether that held up in the
# rebuilt, remeshed model.
mirror(lambda s: b.taper((0.15 * s, -0.55, 1.40), 0.17, 0.05, 1.2, TANGERINE,
                         seg=7, rot=point((0.9 * s, 0.15, 0.35))))

# --------------------------------------------------------------- the ledges
# Two haunch/shoulder humps stepping up the spine, each anchored off the
# body's own centreline (x=0.24-0.27) rather than on it. A centred anchor on
# this body's own symmetric, elongated torso reads to beast.py's
# auto-placement as "outward along the whole torso's length" instead of
# "outward off this one hump" - the failure Bog Leech's, Thrasher's and
# Boulder Ram's holds all hit and all fixed the same way.
_h2 = b.z_for(2)
b.ball((0.32, -0.03, _h2), (0.16, 0.18, 0.14), RUST, 9, 5)
b.shelf(2, (0.30, -0.03), (0.17, 0.15), TAN, thickness=0.10, bevel=0.05)

_h4 = b.z_for(4)
b.ball((0.30, 0.35, _h4), (0.16, 0.16, 0.13), RUST, 8, 5)
b.shelf(4, (0.28, 0.30), (0.14, 0.12), TAN, thickness=0.09, bevel=0.05,
        drop=0.02)

# ----------------------------------------------------------------- the tail
# Bushy, low and trailing behind rather than raised - a hunting stance, not a
# lashing one, unlike Thrasher's tail curling up over its spine.
b.limb([(0.0, 0.88, 0.98), (0.0, 1.28, 0.72), (0.0, 1.58, 0.27)],
       [0.15, 0.12, 0.03], RUST, seg=6)

b.foot((0.32, -0.56, 0.14))                                    # onto a foreleg,
# a little above the paw's own lowest point - the synthetic step grown to
# reach it (beast.py's _grow_steps) sits BELOW the anchor by design, and an
# anchor placed exactly at the true floor leaves that step nowhere to go but
# under it.

# A dedicated mount for the sigil, off centreline, flush against the torso's
# own upper-front shoulder rather than wrapped in a rounded hump - the lesson
# Boulder Ram's write-up names outright: a ball crest wraps FORWARD past its
# own centre, so its front surface can sit closer to the camera than a mark
# merely nudged off its top, burying it no matter how far sideways the mark
# moves. A thin flush plate (y half-extent 0.055, not a ball's full radius)
# avoids that by construction - its front face cannot reach past where it is
# put. Touches the torso by bounding-box overlap (it is well inside the
# torso's own x/y/z range), so it never reads as a floating flourish.
_sigil_z = b.z_for(5)
b.box((0.35, -0.50, _sigil_z - 0.03), (0.13, 0.06, 0.13), RUST, bevel=0.03)
b.mark(at=(0.35, -0.61, _sigil_z), size=0.12, facing=(0.0, -0.94, 0.30))

b.done(out_path(), name="CinderJackal")
