"""Proof for route.py -- no bpy, no Blender, no Godot. Run with plain:

    python3 tools/blender/test_route.py

Prints ALL TESTS PASSED, same convention run_tests.gd uses for the game's own
GDScript rules, so a failure here is exactly as loud.

Test numbers stick to values exact in binary floating point (0.5, 0.25, 1.0,
2.0, ...) wherever the assertion itself does arithmetic, so a mismatch always
means the rule is wrong, never that two roundings didn't happen to line up --
the two exceptions (crag_pup.py's and mire_snapper.py's own real numbers,
lifted straight from those scripts) are checked with a tolerance instead.
"""
import sys

from route import (route_direction, route_progress, keep_route_going, route_violation,
                    hop_world_distance, hop_distance_violation, enforce_hop_floor,
                    HOP_MIN_WORLD, HOP_MAX_WORLD)

FAILS = []
COUNT = 0


def check(name, got, want):
    global COUNT
    COUNT += 1
    if got != want:
        FAILS.append("%s: got %r, want %r" % (name, got, want))


def close(name, got, want, tol=1e-6):
    global COUNT
    COUNT += 1
    if abs(got - want) > tol:
        FAILS.append("%s: got %r, want %r" % (name, got, want))


def close_tuple(name, got, want, tol=1e-6):
    global COUNT
    COUNT += 1
    if abs(got[0] - want[0]) > tol or abs(got[1] - want[1]) > tol:
        FAILS.append("%s: got %r, want %r" % (name, got, want))


# ---------------------------------------------------------------- direction

check("no direction with nothing placed", route_direction(None, None), (0.0, 0.0))
check("no direction with only one rung placed", route_direction(None, (1.0, 2.0)), (0.0, 0.0))
check("direction is the plain displacement", route_direction((0.0, -1.0), (0.0, -0.5)), (0.0, 0.5))

# ---------------------------------------------------------------- progress

close("no direction: everything progresses", route_progress((0.0, 0.0), (5.0, -5.0), (0.0, 0.0)), 1.0)
close("progress is the forward dot product", route_progress((0.0, 0.0), (0.0, 1.0), (0.0, 1.0)), 1.0)
close("progress is negative when it reverses", route_progress((0.0, 0.0), (0.0, -1.0), (0.0, 1.0)), -1.0)

# ---------------------------------- keep_route_going: the raycast-side fix

# Fewer than two rungs placed: whatever the search found is used untouched --
# a route's first hold cannot break a sweep that does not exist yet.
check("first rung ever passes through", keep_route_going(None, None, (3.0, -9.0), 0.5), (3.0, -9.0))
check("second rung (only one placed) passes through",
      keep_route_going(None, (0.0, -1.0), (3.0, -9.0), 0.5), (3.0, -9.0))

# A candidate that keeps moving the established way is trusted as-is.
check("continuing candidate passes through",
      keep_route_going((0.0, 0.0), (0.0, -1.0), (0.0, -2.0), 0.5), (0.0, -2.0))

# The Cinder Jackal shape: paw (0, -1) -> shoulder (0, 0) -> haunch (0, 1) is
# one smooth sweep toward +y; the sigil (the reported bug) then jumps BACK to
# (0, -2), reversing past every rung already used. keep_route_going must
# refuse that and push the sigil forward instead, by exactly min_step past
# the haunch, along the same +y the climb already established.
sigil = keep_route_going((0.0, 0.0), (0.0, 1.0), (0.0, -2.0), 0.5)
close_tuple("reversed sigil is corrected, not passed through", sigil, (0.0, 1.5))

# A stalled pick (near-zero progress, not a full reversal) is pushed forward
# by exactly min_step too, not left to barely creep along.
stalled = keep_route_going((0.0, 0.0), (0.0, 1.0), (0.25, 1.0), 0.5)
close_tuple("stalled pick still gets the full min_step", stalled, (0.0, 1.5))

# Correcting only ever re-derives the point from last_anchor + direction; a
# purely-vertical established direction produces a corrected point with the
# SAME x as last_anchor, regardless of the candidate's own x.
corrected = keep_route_going((0.0, 0.0), (0.0, 1.0), (9.0, 0.5), 0.5)
close_tuple("correction follows the established axis", corrected, (0.0, 1.5))

# Degenerate (zero-length) direction -- the last two rungs sit on top of each
# other -- must not divide by zero, and passes the candidate through.
check("degenerate direction never crashes, passes through",
      keep_route_going((2.0, 2.0), (2.0, 2.0), (9.0, 9.0), 0.5), (9.0, 9.0))

# --------------------------------- route_violation: the hand-authored gate

check("no direction: nothing to violate", route_violation(None, None, (5.0, -5.0), 0.5), False)
check("continuing candidate: no violation",
      route_violation((0.0, 0.0), (0.0, -1.0), (0.0, -2.0), 0.5), False)
# crag_pup.py's own real numbers: foot (0.66, -0.66) establishes the
# direction with anchor(2, y=-0.30) (a real climb, toward +y), then mark()
# places the sigil at y=-0.50 -- less far along +y than the hold below it
# already sits at. A real reversal, on the actual shipped beast.
check("crag_pup's own sigil reversal is caught",
      route_violation((0.66, -0.66), (0.0, -0.30), (0.0, -0.50), 0.03 * 3.0), True)
# mire_snapper.py's own real numbers never reverse: foot y=-1.85, shelf(3)
# y=-0.72, sigil y=+0.86 -- one continuous sweep toward +y throughout.
check("mire_snapper's own route never violates",
      route_violation((0.0, -1.85), (0.0, -0.72), (0.0, 0.86), 0.03 * 3.0), False)

# ------------------------------------------ hop distance: the arc's own band

close("the band's own floor is 2.4 world units (hop_arc's clampf floor, "
      "solved for distance)", HOP_MIN_WORLD, 2.4230769230769229, tol=1e-6)
close("the band's own ceiling is 9.2 world units (hop_arc's clampf ceiling, "
      "solved for distance)", HOP_MAX_WORLD, 9.1538461538461533, tol=1e-6)

# The Cinder Jackal AI rebuild's own real numbers, 2026-09-23: H=3.06,
# top_i=5 -> hunter_size=0.10716... mesh units. Height 3->4 measured
# mesh_dist=0.3628 (world 2.370, just under the 2.4 floor); Height 4->5
# measured mesh_dist=0.2326 (world 1.519, well under it) -- both real,
# reproducible failures on the shipped asset before this fix (see
# enforce_hop_floor's own live numbers below for the corrected values).
HS = 0.10716217631910693
close("hop_world_distance matches the live Height 3->4 measurement",
      hop_world_distance(0.3628, HS), 2.3697, tol=1e-3)
check("a hunter_size of zero (never a real beast) never divides by zero",
      hop_world_distance(1.0, 0.0), 0.0)

check("Height 3->4's real pre-fix gap reads short",
      hop_distance_violation(0.3628, HS), "short")
check("Height 4->5's real pre-fix gap reads short, more severely",
      hop_distance_violation(0.2326, HS), "short")
# The Python reference model's own real Height 4->5 (the sigil, never
# rebuilt after the route-direction fix): mesh_dist=2.1548, world=14.075 --
# past the ceiling, not the floor.
check("the Python reference model's own Height 4->5 reads long",
      hop_distance_violation(2.1548, HS), "long")
check("a hop squarely inside the band is neither",
      hop_distance_violation(0.5, HS), None)
# The floor and ceiling themselves are inside the band (clampf's own edges
# are not violations) -- convert back from world units at HS's own ratio.
close("the exact floor, converted back to this beast's mesh units, still "
      "reads ok (not short)", HOP_MIN_WORLD * HS / 0.7, 0.3709, tol=1e-3)
check("the exact floor passes", hop_distance_violation(HOP_MIN_WORLD * HS / 0.7, HS), None)

# --------------------------------------- enforce_hop_floor: the fix itself

MIN_MESH = HOP_MIN_WORLD * HS / 0.7   # this beast's own hop floor, in mesh units

# Already far enough apart: passed through completely unchanged.
check("a hop already past the floor is left exactly where the raycast put it",
      enforce_hop_floor((0.0, 0.0), 0.5, (0.9, 0.0), MIN_MESH), (0.9, 0.0))

# The real Cinder Jackal Height 3->4 shape: dz=0.351 (the fixed climb step),
# candidate only 0.0918 away in (x, y) -- the exact MIN_ROUTE_STEP push that
# was landing this hop short. Corrected (x, y) must make the FULL 3D gap
# (against dz) reach MIN_MESH exactly, not just move by MIN_MESH itself.
moved = enforce_hop_floor((0.0, 0.0), 0.351, (0.0918, 0.0), MIN_MESH)
import math as _m
full_gap = _m.sqrt(moved[0] ** 2 + moved[1] ** 2 + 0.351 ** 2)
close("the corrected Height 3->4 pick clears the floor by the full 3D gap, "
      "not just its own (x, y) half", full_gap, MIN_MESH, tol=1e-6)
close("the correction keeps the candidate's own direction (moved straight "
      "out along it, not sideways)", moved[1], 0.0, tol=1e-9)

# dz alone already clears the floor (a tall climb step): no (x, y) push
# needed at all, even though the candidate sits right on top of last_anchor.
check("a dz that alone clears the floor needs no push",
      enforce_hop_floor((1.0, 1.0), MIN_MESH + 1.0, (1.0, 1.0), MIN_MESH), (1.0, 1.0))

# Degenerate (x, y): candidate exactly on top of last_anchor, dz alone not
# enough -- falls back to the route's own established sweep direction.
fell_back = enforce_hop_floor((0.0, 0.0), 0.0, (0.0, 0.0), MIN_MESH, (0.0, 1.0))
close_tuple("a degenerate (x, y) with no dz falls back to the route direction",
            fell_back, (0.0, MIN_MESH))

# Degenerate (x, y) AND no fallback direction (a route's very first hold):
# nothing to extend along, so the point is left exactly where it was found
# rather than invented from nothing.
check("no direction anywhere to extend along leaves the point untouched",
      enforce_hop_floor((0.0, 0.0), 0.0, (0.0, 0.0), MIN_MESH), (0.0, 0.0))

if FAILS:
    print("FAILED:")
    for f in FAILS:
        print("  " + f)
    sys.exit(1)
print("ALL TESTS PASSED (%d assertions)" % COUNT)
