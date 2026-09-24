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

from route import route_direction, route_progress, keep_route_going, route_violation

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

if FAILS:
    print("FAILED:")
    for f in FAILS:
        print("  " + f)
    sys.exit(1)
print("ALL TESTS PASSED (%d assertions)" % COUNT)
