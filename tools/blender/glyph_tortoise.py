"""The Glyph Tortoise - the fight-pool beast whose bent rule is a shrug, not a hit.

Ledges at Height 2 and 4, sigil at 5. Its bent rule is `artifact`
(backlog #36, spent so far only by Frost Sentinel, an ELITE, and never yet
by any of the twelve new-content beasts before this one): it wards off the
first `artifact` Frail/Poison/Expose a hunter tries to land on it before
any of them actually apply. Every beast before this one that bends a rule
does it through its OWN moves - a pattern, a gate, a static outgoing
Thorns. This is the first new-content beast whose whole twist is what it
does to the CARDS a hunter plays at it: a debuff-heavy opening hand spends
its first couple of applications for nothing, so the puzzle is patience
(chip it down first, debuff it once the ward is spent) or accept the
opening cost and debuff through it anyway. Its own moves are left plain
(attack / block / attack_all, no gates or phases) on purpose, so the
artifact ward reads as the one thing this beast does differently rather
than getting lost next to a second twist.

A low, broad tortoise: four stubby legs, a wide domed shell carved with
rune-glyphs (the ward made literal rather than left as a pure number), a
small retracted head. The shell doubles as both climb ledges - two plates
stepping up its own ridge - the same "the ledges ARE the shape" trick
Husk Beetle and Boulder Ram already use for a shelled/armoured body. Cool
stone/slate tones (SLATE, STONE, PEWTER) for the shell against a warm
CLAY/BROWN hide, with the glyphs picked out in AMBER so they read as
carved marks rather than a texture - distinct from Boulder Ram's flatter
grey rock read and Husk Beetle's warm beetle-shell one.
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from beast import Beast
from kenney import out_path, mirror, point, SLATE, STONE, PEWTER, CLAY, \
                   BROWN, UMBER, AMBER, TAN

b = Beast("glyph_tortoise", height=2.6, span=(0.02, 1.80))

# ------------------------------------------------------------------- the legs
# Four short, stubby legs, wide stance - a body built to plant and endure,
# not to run.
for sx in (-1, 1):
    for ly in (-0.62, 0.56):
        b.limb([(0.62 * sx, ly, 0.70), (0.72 * sx, ly * 0.98, 0.34),
               (0.66 * sx, ly * 0.94, 0.05)], [0.17, 0.15, 0.12],
               CLAY, seg=6)

# ------------------------------------------------------------------ the mass
b.ball((0.0, 0.02, 0.78), (0.66, 1.00, 0.42), BROWN, 12, 7)          # underbody
b.ball((0.0, 0.05, 1.28), (0.72, 0.85, 0.52), SLATE, 12, 7)          # the domed shell

# Head, low and drawn slightly INTO the shell, not thrust out - a retracted
# posture, distinct from every fight-pool beast that leads with a snout.
b.ball((0.0, -1.06, 0.72), (0.19, 0.24, 0.17), CLAY, 9, 5)
mirror(lambda s: b.ball((0.11 * s, -1.24, 0.78), (0.045, 0.04, 0.045),
                        UMBER, 7, 4))                                  # eye
b.wedge((0.0, -1.24, 0.66), (0.10, 0.14, 0.08), TAN, narrow=(0.4, 0.5),
        bevel=0.02)                                                    # blunt beak

# ------------------------------------------------------------- the glyph carvings
# Small carved marks across the shell's crown - the ward made literal.
# Kept off the shell's own centreline the same way every recent beast's
# HOLDS and marks have to be, and away from the two ledge plates below so
# they never compete with a climb point for the same surface.
for gx, gy, gz in ((-0.30, -0.30, 1.62), (0.28, -0.10, 1.68),
                   (-0.18, 0.50, 1.58), (0.34, 0.42, 1.50)):
    b.box((gx, gy, gz), (0.06, 0.06, 0.015), AMBER, bevel=0.006)

# --------------------------------------------------------------- the ledges
# Two shell plates stepping up the dome's own ridge, each anchored off the
# shell's centreline (x=0.26-0.30) rather than on it - a centred anchor on a
# body this symmetric reads to beast.py's auto-placement as "outward along
# the whole shell" rather than "outward off this one plate", the same
# failure Bog Leech's, Thrasher's, Cinder Jackal's and Boulder Ram's holds
# all hit and all fixed the same way.
_h2 = b.z_for(2)
b.ball((0.30, -0.15, _h2), (0.20, 0.22, 0.15), STONE, 9, 5)
b.shelf(2, (0.28, -0.15), (0.19, 0.17), PEWTER, thickness=0.11, bevel=0.05)

_h4 = b.z_for(4)
b.ball((0.26, 0.42, _h4), (0.18, 0.20, 0.14), STONE, 8, 5)
b.shelf(4, (0.24, 0.38), (0.16, 0.14), PEWTER, thickness=0.10, bevel=0.05,
        drop=0.02)

b.foot((0.66, -0.62, 0.10))                                    # onto a foreleg

# A stubby stone prow, pushed clear of the dome's own front bulge - a domed
# shell this round reaches forward (-Y) nearly as far as it does outward, so
# a mark merely set on its crown at the sigil's own Height sits well BEHIND
# the shell's own front surface at that z-band and is buried no matter how
# far sideways it is nudged (the "ball crest wraps past its own centre"
# lesson Cinder Jackal's and Boulder Ram's write-ups both already named,
# just larger here because the shell is a much bigger dome). A first attempt
# used a thin taper for the bridge and read as a flagpole with a coin on it
# in the rendered preview - looking at the render, not the contract, caught
# it. Rebuilt as a stubby wedge() (a shape this file's own vocabulary calls
# out for "a slab at one end and an edge at the other") so the prow reads as
# a grown shell ridge rather than an antenna.
_sigil_z = b.z_for(5)
b.ball((0.20, -0.35, _sigil_z - 0.02), (0.14, 0.12, 0.13), STONE, 8, 5)
b.taper((0.20, -0.65, _sigil_z), 0.10, 0.04, 0.55, STONE, seg=7,
        rot=point((0.0, -1.0, 0.15)))
b.mark(at=(0.20, -0.91, _sigil_z), size=0.08, facing=(0.0, -1.0, 0.0))

b.done(out_path(), name="GlyphTortoise")
