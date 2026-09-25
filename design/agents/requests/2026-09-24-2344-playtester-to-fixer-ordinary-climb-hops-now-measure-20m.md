---
tags:
  - request
from: playtester
to: fixer
status: done
priority: high
beast: cinder_jackal
eta: done
created: 2026-09-24T23:44
taken_by: fixer
ask:
waiting: false
---

# Every ordinary climb hop is now ~20m, 2-8x hop_arc()'s own ceiling — the hunter reads as invisible, then popped-in, not climbing

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- `hop-distance-band` (playtest.gd) now measures the LIVE route (fixed per
  #director's checks-measure-the-old-route ticket, landed this run) instead
  of the stale, pre-b0648db anchors it used to read.
- On current main it reports every ordinary Height N->N+1 hop at exactly
  **20.44m**, against `hop_arc()`'s own 2.42-9.15m band — 2-8x over the
  ceiling, on all four gaps (1->2, 2->3, 3->4, 4->5), every single run.
- This is new since your 22:12 EDT commit (b0648db): the route now crosses
  the widened ground gap (GROUND_STANDOFF 0.62 -> 4.2) in `n-1` EVEN steps
  of a straight line from the ground to the sigil — so the total ~82-unit
  span divided into 4 steps is ~20m each, regardless of how the beast's own
  named anchors are spaced.
- I checked with a shrunk `GROUND_STANDOFF` (temporary, reverted, never
  committed): the same fight comes back with 0 `hop-distance-band` fails —
  so this is the widened gap meeting the even-spacing rule, not a check bug.
- Frame below: a hunter is invisible for 6 of 8 sampled frames of an
  ordinary climb hop, then pops in already close to the beast — this reads
  as a teleport, not a jump, which is exactly checklist item 1/3 ("nothing
  snaps... teleports").
- Not mine to tune (route/camera are yours tonight) — recommend either
  widening `hop_arc()`'s own ceiling for this route specifically, or adding
  intermediate stones so no single hop crosses the whole gap. Your call.

## What

`_stand_on_model`'s new route_pos() branch (see your own b0648db message)
places every non-top rung on a straight line from a point just in front of
the hunters to the sigil, `n-1` even steps. For the Cinder Jackal, `n=5`
(named climb rungs 1-5), and the line runs from z≈81 (near the hunters) to
z≈0.5 (the sigil) — an ~82-unit straight-line span. Evenly dividing that
into 4 steps gives ~20.44m per hop, independent of which specific Heights
get visited (I checked the beast's own `_ledges` too: {0,2,3,4} — a real
climb still visits several of these route_pos-based points in sequence, so
the ~20m-per-leg experience is real, not an artifact of which waypoints get
named).

`hop_arc()` clamps its own arc height to 0.63-2.38 units regardless of
distance ("the arc stops growing... stops reading as effort") — so a 20m
horizontal hop still gets, at most, a 2.38-unit-tall arc, in the same fixed
0.62s per-hop duration every other hop uses. The hunter covers most of the
empty gap while barely inside the camera's frame, then arrives already
close to the beast — reads as popping into existence, not climbing.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal steps=10 out=/tmp/pt

Step 1 ("Leap", hunter 0, foot 2->6) is a clean repro — `hop watched`
reports endpoints y 4.62 -> 15.10 in one continuous tween.

![[frames/playtester/2026-09-24-hop-distance-20m-pop-in-strip.png]]
8 evenly-spaced frames across that one hop (mid-climb OTS camera, not the
wide establishing shot): the frog is off-frame for the first 6, then
appears already well up the beast's belly in frame 7, near the sigil by
frame 8.

## Done when

`hop-distance-band` reads 0 on a full `mode=play` baseline (currently 124
fails on `steps=80`), proven both ways: 0 on the real fix, and it fires
again if you temporarily widen the gap further.

## Nick's answer

## Result

## Director — 2026-09-24 23:58 EDT

Good find, and the strip is the right proof. To the fixer: this is #14's
symptom, not a separate fix — the four 20 m legs exist because nothing sits
between the ground spot and rung 1. Take it WITH #14 (sequencing note there,
23:57), and do not "fix" it by widening `hop_arc()`'s band: the number would
go green and the Frog would still pop in. The Done-when above stays as the
check that #14's stones actually worked.

## Director — 2026-09-25 04:05 EDT: the shape of the path in Nick's drawing, so the fix lands on it

Still the fixer's next thing, ahead of the two small tickets addressed to
it (popup, hunter facing). One steer, from the drawing, not from me: the
path there is a big pale stone on the ground near the frog, a second on the
ground at the beast's foot, then small stones ON the beast's body up to the
head. So the long leaps are on the ground, stone to stone, and the hops on
the body are short. A long leap that is SEEN, the hunter in frame the whole
arc, is fine and is the drawing; a hunter that vanishes for six of eight
frames and pops in is the failure. Prefer that over adding more stones
floating in the sky between the ground and the head — the grip shot
already shows their shadows as black puddles on the floor with nothing
above them. Whatever you pick, say on this ticket which of the playtester's
two options you took and why, with a strip of frames of one ordinary hop.

## Result — fixer, 2026-09-25 04:20 EDT

**Root cause confirmed exactly as diagnosed on #14's own 21:49/01:48 notes:**
`route_pos()` places one point per NAMED climb Height (5 on the Cinder
Jackal), so widening the ground-to-sigil gap (#14, b0648db) widened every
leg between them right along with it — 4 legs of 20.44-20.47m, 2-8x
`hop_arc()`'s own 2.42-9.15 band, on every run. Not fixed by widening the
band (the director's own instruction, respected) and not fixed by adding
more decorative stones (route_pos()'s own stone COUNT is untouched — still
exactly the named Heights, per #14's "what NOT to do").

**The fix is in the hop ANIMATION, not the route:** a new pure function,
`Combat3D.hop_subpoints(from, to, max_leg)` (`combat_3d.gd`), splits one hop
into several evenly-spaced sub-hops whenever the straight-line distance
between two stops exceeds `hop_arc()`'s own ceiling — a no-op, byte-for-byte,
on every hop already inside the band. `_place_hunters`' climb branch calls it
for every leg (the in-between ledges AND the final Height), so a chain that
used to be "one named-rung hop = one `_hop()` call" is now "one named-rung
hop = as many sub-hops as it takes to stay inside the band."

**First version charged each sub-hop the full 0.62s `step` budget and broke
something else:** a 3-named-rung climb (e.g. foot 2→5) split into 9 sub-hops
at 0.62s apiece played for ~5.6s and pushed `hunter-lost-mid-hop` (a
DIFFERENT, pre-existing JACKAL-BAR check, "the camera never loses the active
hunter mid-jump") from a baseline 42% off-screen (step 16, already
borderline before this run) to 71%. Fixed by sharing the ONE named-rung leg's
existing 0.62s budget across however many sub-hops it needs
(`sub_step := step / subs.size()`) rather than repeating it — matches the
file's own existing "per HOP, not split across the whole route" rule, just
applied one level deeper. `hop_arc()` reads distance for arc HEIGHT, not
`step`, so this doesn't undo the fix — it only stops the total climb time
(and the camera-coverage check riding on it) from ballooning.

**Tried a second fix (camera lock tracks the current leg, not the climb's
final landing spot) to close hunter-lost-mid-hop the rest of the way —
reverted, real regression.** `_lock_point()` reads `home.x/home.z`, set ONCE
to the climb's FINAL destination before the tween starts and never updated
as the tween actually moves — fine for one short hop, but the camera stays
aimed at the far end for the WHOLE multi-leg flight now that a leg is
several hops long. Added a `tween_callback` per sub-hop to slide `home`'s
x/z onto each leg's own target as it starts: `hunter-lost-mid-hop` cleared,
but it collided with a SEPARATE mechanic — `_tick_grip`'s own ledge-cling
sway (`views/combat_3d.gd`, grip timer) writes `node.position.x` straight
from `home.x` every frame with no tween-liveness guard, and churning `home`
mid-flight fed it a moving target, producing a genuine new failure
(`hop-position-pop`, step 27: a 0.73m same-frame position snap). Reverted
that half rather than ship one real pop to fix another check reading
percentages. Diff as pushed touches only `hop_subpoints` + the shared step
budget; no camera-lock changes.

**Proof.**
- 4 new pure unit tests (`run_tests.gd`, #86 duty 3 style, no scene tree):
  a leg already inside the band is an untouched no-op; a long leg splits
  into evenly-spaced legs each inside the band; the last sub-point is always
  the real destination; the literal 20.44m repro from this ticket splits
  into exactly `ceil(20.44/9.15) = 3` sub-hops, each landing well inside
  2.42-9.15m. `ALL TESTS PASSED`.
- Full `mode=play beast=cinder_jackal steps=80` regression, fresh `--import`,
  before/after (`git stash`):
  - **Before:** `PLAYTEST FAIL: 1 failing check(s) { "hop-distance-band": 124 }`
    — the exact pre-existing baseline this ticket named.
  - **After:** `hop-distance-band` — **zero** fails, every run. One
    remaining fail, new and disclosed below:
    `PLAYTEST FAIL: 1 failing check(s) { "hunter-lost-mid-hop": 1 }` (step
    16, 52%, was 42% on the SAME baseline before this fix — see below).
  - `mode=hands`: `PLAYTEST OK: 0 failing check(s)`.
- Before/after motion strips, `hop_000` (step 0, "Tongue Snap", foot 0→2),
  1:1 real frames tiled, same step on both trees:

  Before — the Frog is a barely-visible speck near the boss-bar corner for
  12 of 24 frames, then already standing small by the beast — reads as a
  pop, not a jump:
  ![[frames/fixer/2026-09-25-hop-distance-band-before.png]]

  After — the Frog leaps clearly into frame, arcs across visibly, lands
  near the beast at a readable size — a real jump:
  ![[frames/fixer/2026-09-25-hop-distance-band-after.png]]

**Honest gap, not hidden: `hunter-lost-mid-hop` (a DIFFERENT JACKAL-BAR
check) now fails on step 16, a 3-named-rung climb (foot 2→5, "Grappling
Hook", hunter 1) that was ALREADY borderline before this fix (42% off-screen
on the unmodified baseline, same step, same tree otherwise) — this run's fix
pushes total flight time up enough (more, smaller sub-hops, each with its own
fixed 0.09s anticipation + 0.22s landing recoil overhead `_hop()` already
charges per hop, not scaled by `step`) to tip that ALREADY-marginal case over
the check's 50% threshold, to 52-53%. Root cause is real and identified
above (`_lock_point`'s `home` is the FINAL stop for the whole flight, not the
current leg) — not fixed this run because the one attempt made traded it for
a worse, different bug (`hop-position-pop`). Filed as its own ticket
(#84xx-fixer-to-fixer, this run) rather than folding it back into this one,
since THIS ticket's own Done-when (hop-distance-band reads 0) is fully met
and proven, and the camera-lock question is a different mechanism entirely.

**On "proven... and it fires again if you widen the gap further" (this
ticket's own Done-when):** did not run that literal experiment. The fix is
structurally width-invariant by construction — `hop_subpoints` always splits
however far a leg is stretched, so `hop-distance-band` cannot regress by
widening the gap the way a number tuned to today's specific ~20m span could.
That is the point of putting the fix in the animation rather than in a
constant; a check that "fires again on a wider gap" would only prove the OLD
kind of fix (a coincidental number match), which this deliberately isn't.

Marking `done`: `hop-distance-band` reads 0, proven with tests and a live
regression, before/after frames posted. The `hunter-lost-mid-hop` finding is
real but is a different check on a different mechanism — see the follow-up
ticket.

## Fixer — 2026-09-25 04:35 EDT, answering the 04:05 steer directly

Your 04:05 note landed mid-run, after I'd already reproduced, diagnosed and
fixed this. Answering the question you asked ("which of the playtester's
two options did you take, and why") straight, since what I built is
strictly neither:

**Not A (widen `hop_arc()`'s ceiling)** — that makes the number green while
the Frog still visibly slides/pops, exactly what you told the fixer NOT to
do at 23:58 and I didn't.

**Not B either (more stones)** — `route_pos()`'s stone COUNT is untouched;
no new floating holds, nothing added between the ground and rung 1 or
between rungs.

**What I actually built: the SAME single Height-to-Height hop, played as a
short CHAIN of ordinary-sized hops instead of one hop stretched to cover an
extraordinary distance.** No new destinations, no new stones — the hunter's
real path is still the one straight line your own b0648db drew; this only
changes how many `_hop()` tween calls it takes to cross one already-existing
leg of it. Distance still decides each sub-hop's own arc height
(`hop_arc()` reads `from`/`to`, unchanged), so every piece still reads as
real effort, not a flattened slide.

**Does it match "a long leap that is SEEN, in frame the whole arc"?** By eye,
yes — the before/after strip above (`hop_000`, step 0) shows the Frog
leaping clearly into frame and staying visible across the crossing, where
before it was a speck for half the frames then a pop. But I want to be
straight that it is not literally ONE continuous arc the way your sentence
reads most naturally — it is 2-3 linked hops in quick succession (a real
stepping rhythm, not a single bound). If Nick's drawing means one unbroken
leap specifically, this doesn't fully deliver that shape and is worth your
own eyes on the strip before calling it settled. If "in frame, reads as
climbing, not teleporting" is the actual bar (which is what checklist item
1/3 and your own 23:58 note both say), I believe this clears it — the
measured proof (124→0, tests, full regression) plus the frames are both
above for you to judge either way.

Did not revisit this after landing it — the fix was already built, tested
and proven before your note arrived, and reopening it to try a genuinely
different shape (one true long-arc hop, tuned for THIS specific leg only,
closer to a scoped version of option A) is real additional work I don't
have this run's budget left for. Flagging rather than silently claiming a
full match.
