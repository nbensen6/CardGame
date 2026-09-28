---
tags:
  - request
from: fixer
to: fixer
status: done
priority: normal
created: 2026-09-22
taken_by: fixer
---

# A tall single-leg climb's jump animation reads as a slide, not a jump

## What

Caught live by the playtester's own `hop-flat` check (`playtest.gd`'s
`_check_hop`), not filed by anyone — no open `to: fixer` request this run,
so per the fixer brief this is "a failure the current playtest shows that
nobody has filed yet": ran `mode=play beast=cinder_jackal steps=80` fresh
against the tip and it failed twice.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=80 out=/tmp/pt

Before the fix, step 1 and step 17 both failed:

    FAIL [step 1] hop-flat: step 1: hop peak y=18.13 never rose above its endpoints (8.99 -> 18.18) -- reads as a slide, not a jump
    FAIL [step 17] hop-flat: step 17: hop peak y=18.13 never rose above its endpoints (8.99 -> 18.17) -- reads as a slide, not a jump
    PLAYTEST FAIL: 1 failing check(s) { "hop-flat": 2 }

Both were `Leap`/`Hop`-style big single-leg climbs with no intermediate
ledge to split the hop into shorter legs (`_route_between`) — Leap alone
can climb 3+ Height in one hop, and the jackal's rungs are not evenly
spaced in world Y, so one hop can cover several hunter-heights of vertical
span.

## Cause

`Combat3D.hop_arc(from, to, step)` built the jump's apex as
`from.lerp(to, 0.58) + Vector3.UP * hop`, where `hop` is deliberately
clamped to at most `2.5 * HUNTER_HEIGHT` (documented: "an unclamped hop
over a long haul would arc absurdly high"). For a short hop the remaining
42% of the climb's own vertical span (the part not yet covered by the 0.58
lerp) is small enough that the capped `hop` bonus covers it and the apex
still clears both endpoints. For a climb whose own vertical span already
exceeds a couple of hunter heights, 42% of that span dwarfs the capped
`hop`, so the apex lands BELOW the landing height — the "rise" tween never
actually rises past where the hunter is going, and the whole parabola reads
as a rising slide with a wobble at the end, exactly what the check caught.

Reproduced directly, outside any scene tree:

    hop_arc(Vector3(0, 8.99, 0), Vector3(0.3, 18.17, -0.4), 0.34)
    -- before: apex.y = 15.97 (BELOW to.y = 18.17)
    -- after:  apex.y = 19.82 (clears both endpoints)

Every existing `hop_arc` test moved flat (Y unchanged), which is exactly
why this slipped through every prior duty-3 pass on this same function —
none of them could have caught an apex landing below a real climb's own
endpoints.

## Fix

`game/views/combat_3d.gd`, `Combat3D.hop_arc()`: the apex's height now
comes from `maxf(from.y, to.y) + hop` — always clearing whichever endpoint
is higher by `hop` — instead of leaning the height along with x/z. The
lean toward the landing (0.58 lerp) still applies to x/z only, so the
"jump onto something, not a lob" read is unchanged for ordinary hops; only
the height guarantee changes, and only tall climbs were ever affected.

## Proof

- Two new unit tests in `game/tools/run_tests.gd`:
  `_test_backlog86_hop_arc_apex_clears_both_endpoints_on_a_tall_climb` pins
  the exact live numbers above; `_test_backlog86_hop_arc_apex_height_is_the_higher_endpoint_plus_hop`
  proves the general invariant (apex height is always the higher endpoint
  plus `hop`, climbing up or down), so the fix is a real rule and not a
  patch of one reported case. `$GODOT --headless --path game --script
  res://tools/run_tests.gd` → `ALL TESTS PASSED`.
- Re-ran the identical repro (`mode=play beast=cinder_jackal steps=80`) on
  the fixed code, same deterministic opening (step 17: the same
  8.99 → ~18.1 climb): peak y is now 19.56, clearing both endpoints.
  `PLAYTEST OK: 0 failing check(s) {  }` — `hop-flat` is gone and nothing
  else regressed.

Commit: `25804f3` (the fix + tests), this request's own commit records the
write-up.

## Result

Fixed and proven as above. Before: `PLAYTEST FAIL: 1 failing check(s) {
"hop-flat": 2 }`. After: `PLAYTEST OK: 0 failing check(s) {  }`. No frame
is attached — this is a trajectory bug (the sampled arc over several
frames, not any single frame's pixels), so the numeric before/after in the
playtest report is the real evidence, same as the report text above.
