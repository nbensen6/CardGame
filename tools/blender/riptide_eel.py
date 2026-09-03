"""The Riptide Eel - the elite whose bent rule is a limiter, not a move.

Ledges at Height 2 and 4, sigil at 6. Its bent rule is `sigil_fatigue`
(backlog #55's limiter field, spent so far only by two of the four true
Titans - Gale Serpent and Sunken Warden - and never yet by any fight/elite
pool beast): camping the weak point burns a hunter's grip, same as it does
against those two Titans, just gentler (value 2, matching Gale Serpent's
own, rather than Sunken Warden's harsher 1). Every elite before this one
bends its rule through its OWN MOVES - a gate, a status, an escalation. This
is the first whose whole twist lives in the field every move-based beast
before it left at {} : an elite that previews the exact rule language a
hunter will meet again at a real Titan, so the lesson isn't dropped on them
cold at the boss. Its own moves are left plain (attack / block / attack_all,
no gates, no hurt-phase, no leech) on purpose, the same restraint Glyph
Tortoise's write-up already named for its own single-twist beast, so the
fatigue reads as the one thing this beast does differently rather than
competing with a second mechanic for the player's attention.

A moray-shaped eel that rears up out of a low crouch to strike: it lies
along the ground tail-first, then curves up through the body into a raised,
cobra-like neck and head - the SAME "you climb around this, not up it"
lesson Gale Serpent's coil already teaches, just as a rearing S-curve
instead of a spiral, so a hunter meets the shape of the idea before they
meet its most literal form. Two dorsal fin-ridges step up the rearing curve
for the holds. Deep-water NAVY/MIDNIGHT (spent before only by the two
aquatic Titans and Riftling/Sky Snapper/Stone Warden - never yet by any
new-content beast), with paler STEEL/SLATE ridge plates, distinct from Gale
Serpent's own SKY/ICE/INDIGO storm palette and Bog Leech's brown bog one.
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import out_path, mirror, point, NAVY, MIDNIGHT, STEEL, SLATE, \
                   CHARCOAL, AMBER

b = Beast("riptide_eel", height=3.0, span=(-0.02, 2.87))

# ------------------------------------------------------------------ the spine
# One backbone from the tail tip to the base of the skull: low and thin at
# the back, thickest at the belly, then rearing up and narrowing again into
# the neck - a cobra/moray posture, not a snake lying flat. limb() is what
# makes this ONE surface rather than a string of beads; a body this long
# built from balls alone is exactly what read as a caterpillar before this
# vocabulary existed (kenney.py's own account of the old toolkit).
SPINE = [
    (0.0,  1.62, 0.09),
    (0.0,  1.16, 0.16),
    (0.0,  0.66, 0.28),
    (0.0,  0.14, 0.44),
    (0.0, -0.36, 0.78),
    (0.0, -0.74, 1.24),
    (0.0, -0.97, 1.74),
    (0.02, -1.07, 2.18),
    (0.02, -1.02, 2.48),
]
RADII = [0.045, 0.16, 0.32, 0.43, 0.40, 0.34, 0.27, 0.215, 0.18]
b.limb(SPINE, RADII, NAVY, seg=9, cap=False)

# A paler belly band along the underside, following the same path a little
# inside it and stopping short of the reared neck - a moray's throat, not
# its whole length, keeps pale.
BELLY = SPINE[:7]
b.limb([(x, y, z - 0.05) for x, y, z in BELLY],
       [r * 0.62 for r in RADII[:7]], SLATE, seg=7, cap=False)

# Tail cap and skull-base cap, since cap=False left both ends open.
b.ball(SPINE[0], (0.05, 0.05, 0.05), NAVY, 6, 4)
b.ball(SPINE[-1], (0.18, 0.16, 0.16), NAVY, 8, 5)

# ------------------------------------------------------------------- the head
# Raised, jaws parted, eyes set high on the skull the way a real moray's are
# - built as its own shapes rather than more limb(), the same split Gale
# Serpent's neck-then-head uses.
b.ball((0.02, -1.30, 2.66), (0.22, 0.30, 0.20), NAVY, 10, 6)          # skull
b.wedge((0.02, -1.62, 2.56), (0.15, 0.28, 0.12), MIDNIGHT,
        narrow=(0.45, 0.60), bevel=0.03)                              # lower jaw
b.wedge((0.02, -1.58, 2.68), (0.16, 0.30, 0.10), NAVY,
        narrow=(0.40, 0.55), bevel=0.03)                              # upper jaw
# Eyes were floating clear of the skull - centre (0.16*s, -1.44, 2.82) sits
# outside the skull ball's own ellipsoid ((0.02,-1.30,2.66), radii 0.22/0.30/
# 0.20: normalized distance 1.26-1.53, >1 means outside), so a visible gap of
# background showed between each eye and the head in every render, caught by
# `riptide_eel_portrait.md`'s scoring pass, not by any check. Pulled both
# balls 22% of the way back toward the skull centre (normalized distance now
# 0.74-0.96, matching Eyrie Hawk's own working eye-on-skull placement at
# ~0.91) so they sit set into the surface instead of hovering above it.
mirror(lambda s: b.ball((0.13 * s, -1.41, 2.78), (0.055, 0.05, 0.05),
                        AMBER, 7, 4))                                  # eye
mirror(lambda s: b.ball((0.13 * s, -1.45, 2.78), (0.028, 0.026, 0.026),
                        CHARCOAL, 6, 4))                               # pupil

# Two short barbels off the jaw - the cheapest read for "eel", the same way
# Frog's nostrils were the cheapest read for "frog".
mirror(lambda s: b.taper((0.09 * s, -1.74, 2.50), 0.020, 0.006, 0.16,
                         MIDNIGHT, seg=4, rot=point((0.20 * s, -0.85, -0.35))))

# A dorsal fin membrane was tried here as narrow wedge segments along the
# spine - the eel read Gale Serpent's scaled coil does not attempt - and cut
# after looking at the rendered previews rather than the contract, which
# passed it: from above and from the side it read as a scatter of loose
# steel chips flagged onto the neck, not a membrane, the same "parts read as
# debris rather than one surface" failure Eyrie Hawk's first folded wing hit
# for the same reason (thin wide plates thrown off the body one at a time
# rather than a single grown surface). Left out rather than shipped wrong;
# a fin worth having needs its own single swept surface, not a row of
# wedges, and that is more than this pass's scope.

# --------------------------------------------------------------- the ledges
# Two dorsal ridge-humps stepping up the rearing curve, each anchored off
# the spine's own centreline AND past the spine's own local radius at that
# Height (0.35 at Height 2's z, 0.27 at Height 4's z) - a first attempt put
# both anchors at 0.22-0.26, which is INSIDE the main spine tube at those
# points, not past it, so beast.py's auto-push found the real surface a
# long way further out than the anchor and grew a synthetic step to reach
# it at every one of them. Same failure Thrasher's, Bog Leech's, Cinder
# Jackal's and Boulder Ram's holds all hit from a centred anchor; this is
# the version of it a THICK tube hits from an anchor merely offset, not
# centred, when the offset is not offset far enough.
_h2 = b.z_for(2)
b.ball((0.46, 0.05, _h2), (0.20, 0.22, 0.17), SLATE, 9, 5)
b.shelf(2, (0.44, 0.02), (0.18, 0.16), STEEL, thickness=0.12, bevel=0.05)

_h4 = b.z_for(4)
b.ball((0.38, -0.70, _h4), (0.17, 0.18, 0.14), SLATE, 8, 5)
b.shelf(4, (0.36, -0.66), (0.15, 0.13), STEEL, thickness=0.11, bevel=0.05,
        drop=0.02)

# Mirror plates on the far side, matching the two holds above so the top-down
# view reads as a dorsal ridge with two sides rather than holds strung along
# one flank. Built as plain box()/ball() rather than a second shelf() call,
# since shelf() re-registers the climb anchor for that Height - a second call
# at the same Height would silently move where a hunter actually stands.
b.ball((-0.46, 0.05, _h2), (0.20, 0.22, 0.17), SLATE, 9, 5)
b.box((-0.44, 0.02, _h2 - 0.12), (0.18, 0.16, 0.12), STEEL, bevel=0.05)

b.ball((-0.38, -0.70, _h4), (0.17, 0.18, 0.14), SLATE, 8, 5)
b.box((-0.36, -0.66, _h4 - 0.02 - 0.11), (0.15, 0.13, 0.11), STEEL,
      bevel=0.05)

b.foot((0.0, 1.30, 0.10))                                      # onto the low tail

# A small dedicated crest for the sigil, off the spine's own centreline (and
# past its local radius of ~0.20 there, same reason as the ledges above).
# assetcheck's own occlusion check caught what looking at the render alone
# did not: a first attempt at this crest put the taper's CENTRE closer to
# the body than the ball's own front edge (y=-0.68 against the ball's edge
# at y=-0.96) — bridging BACKWARD instead of forward — so the mark sat
# behind the crest's own bulk and came back 97% buried. Bog Leech's own
# crest (the working reference this is modelled on) puts the taper's centre
# PAST the ball's front edge, overlapping it by a small margin so finish()
# doesn't flag a gap, and the mark past the taper's own tip in turn — that
# ordering, not the taper's length, is what actually clears a low-poly
# ball's own widest cross-section.
_sigil_z = b.z_for(6)
b.ball((0.30, -0.86, _sigil_z), (0.15, 0.10, 0.15), SLATE, 8, 5)
b.taper((0.30, -1.06, _sigil_z - 0.02), 0.075, 0.03, 0.24, SLATE, seg=6,
        rot=point((0.0, -1.0, 0.0)))

# A matching crest on the far side, undecorated (no mark - the sigil itself
# stays singular, per every other beast in the cast), so the sigil's own
# crest doesn't read as the one asymmetric growth left on the body.
b.ball((-0.30, -0.86, _sigil_z), (0.15, 0.10, 0.15), SLATE, 8, 5)
b.taper((-0.30, -1.06, _sigil_z - 0.02), 0.075, 0.03, 0.24, SLATE, seg=6,
        rot=point((0.0, -1.0, 0.0)))

b.mark(at=(0.30, -1.22, _sigil_z), size=0.15, facing=(0.0, -0.94, 0.28))

b.done(out_path(), name="RiptideEel")
