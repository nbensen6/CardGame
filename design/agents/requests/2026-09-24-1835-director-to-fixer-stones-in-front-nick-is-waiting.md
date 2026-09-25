---
tags:
  - request
from: director
to: nick
status: open
priority: high
beast: cinder_jackal
eta: all four items landed 06:16 EDT; waiting on your look
created: 2026-09-24T20:08
taken_by: fixer
ask: Does the stone path across the gap read like your drawing, or is the near stone still too big and wall-like against the beast?
waiting: false
issue: 14
---

# Open the gap between the hunters and the jackal, then lay the stones across it (#18, steps 1 and 2)

**#14**

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need — Nick, live, 2026-09-24 22:25 EDT (relayed by the director)

- **"The stones should be in a pattern from left to right to the head of the
  jackal."** Before he wakes up tomorrow.
- **His own commit at 22:12 (`b0648db`) is the base. Do not revert it.** It
  opened the gap, put the ground camera 9 units behind the hunter, and laid
  the route as one straight line ahead. Build on `route_pos()`.
- The line is straight AHEAD, so from behind the hunter the stones stack one
  over the other (frame below). Sweep it sideways: first stone low and to
  the LEFT of the hunter, each next one further RIGHT and higher, the last
  at the head. In his drawing the path is a diagonal across the picture.
- Keep the even spacing he measured (his commit: one line, even steps — five
  destinations gave five step lengths and broke the hop band). A lateral
  sweep with even arc length keeps that.
- Do NOT re-enter `route.py`'s raycast search (proven dead end, 21:49). Do
  NOT move the sigil. Do NOT widen the camera to show the path — the camera
  is the other ticket.
- While you are in the stone code: load the artist's new
  `game/assets/3d/env/foothold_rock.glb` for the hold body (it landed at
  22:28 but is not wired in; the frame still shows the pot).
- Then hand it back per COMMON §5: `to: nick`, `status: open`, `ask:`, a
  1:1 `state=3d` frame. Never `done`.

![[frames/director/2026-09-24-2232-director-after-nicks-camera-commit.png]]

## What I need (director, 20:08 EDT — still the shape of the work)

- **First, the gap.** Move both hunters' ground positions well back from the
  beast — a real stretch of empty dark ground between them and its paws.
  Nick's drawing: the gap is most of the picture.
- **Then the stones.** Lay an APPROACH across that gap: open-air holds from
  the hunter's ground spot up to the existing first rung on the body — big
  near the hunter, smaller as they recede. The on-body route (rungs, sigil)
  stays exactly where it is. (Reworded 21:59 EDT: "toward the head" meant
  the direction the path reads, never "move the body rungs".)
- **The last hold** leaves the hunter standing in front of the sigil with
  space between him and the skin (Nick on #5). The sigil itself stays.
- Do NOT touch the camera — not wider, not yawed. Step 3 of #18 is a close
  third-person camera behind the hunter, and it comes AFTER this.
- Do NOT restart the hop-band math from #4 first. Once the stones sit in open
  air across the gap they are no longer raycast onto the mesh, so #4's
  measured ceilings do not apply; place the path, then check the band.
- Do NOT restyle anything off the drawing — Nick (#17): placement only.

## What

Rewritten by the director, 2026-09-24 20:08 EDT, under Nick's #18. Before this the stones
work was spread over #4 (five investigation notes, closed into here), #5
(answered, closed into here), #11 (superseded) and the first version of this
ticket. This is now the ONE live ticket for the gap and the stones.

What a player sees today, at 1:1 on current main:

![[frames/director/2026-09-24-director-resting-shot.png]]

The hunters stand between the paws, about ten units out. Two pale saucers
float at the right flank. Nick's diagnosis on #18: *there is not enough space
between the hunters and the beast.* At that range no camera can be close on a
hunter and show the beast, which is why the wide shot happened. Open the gap
and everything else follows.

Nick's drawing, which is the target for **placement only**:

![[art/references/2026-09-24-nick-target-composition.webp]]

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3d beast=cinder_jackal size=1280x720

## Done when

- The gap is a NUMBER, not a look (reworded 21:59 EDT, see the director's
  call below): the hunters' ground standoff is the distance a camera 4 units
  behind and 2 above the active hunter, at the game's real FOV, needs to see
  the whole beast head-to-foot with headroom. Proven with a harness-only
  screenshot state at that camera position — the play camera untouched.
- In that harness frame at 1:1: hunter at the bottom, a clear stretch of
  ground, the approach stones receding to the first rung, the whole beast.
- At the top hold the hunter reads as standing in front of the sigil, not
  pasted on the cheek (the frame #5 asked for).
- 80-step playtest: 0 `route-reversal`, 0 `hunter-off-marker`.
- The after frame is posted here; the director hands it to Nick on #18.

## Director — 2026-09-25 05:08 EDT: still taken, and the eta was stale

Item 3 landed at 04:20 (`f0808f0`, `hop-distance-band` 124 → 0) but the eta
line still said "not started" — corrected. Not handing to Nick yet: the
crossing is now three hops with a stone under only the first and last, and
the Frog is invisible for the whole flight (fixer's own `0420`). Item 4 is
filed as `2026-09-25-0505` (stones under every landing). When `0420` and
`0505` are in, THIS ticket goes `to: nick` with the 1:1 `state=3d` frame and
an `ask:` — per its own instruction above, never `done`.

## Nick's answer

## Result — fixer, 2026-09-24 21:49 EDT (in progress, not done)

Two investigations this run, both real findings, neither shippable yet.
Nothing pushed to `combat_3d.gd`, `ai_beast.py` or `route.py` — every
experiment below was proven, then reverted rather than left half-working.
Leaving `status: taken`; the "no direction" and "the stones" pieces both
need more work than one run.

### 1. Moving the hunters back alone cannot open the gap — the resting camera cancels it

Tested directly: cranked `GROUND_STANDOFF` (the hunter's ground standoff,
`combat_3d.gd`) from its shipped `0.62` up to `32.0` — pushing the hunter's
own world Z from 26.7 to 544 (20x further from the beast) — and rendered
`state=3d` at every step, projecting both the hunter and the beast's own
front-paw point to screen pixels each time:

| GROUND_STANDOFF | hunter world Z | hunter screen (x,y) | paw screen (x,y) |
|---|---|---|---|
| 0.62 (shipped) | 26.7 | (640, 448) | (677, 443) |
| 2.5 | 57.7 | (640, 448) | (661, 436) |
| 8.0 | 179.7 | (640, 448) | (649, 431) |
| 32.0 | 575.5 | (640, 448) | (642, 428) |

The hunter's own screen position never moves — not by one pixel, at any
standoff — because the resting camera's pivot locks onto the ACTIVE
HUNTER's exact (x, z) (`_lock_point()`, unconditional, `CAMERA_LOCK = 1.0`)
and `dist_for_window_for`'s own "beast standoff" term is already `0`
once the hunter is this far out (`maxf(beast_front_z*0.85 - pivot_z, 0)` —
negative once `pivot_z` passes ~14, clamped to 0). So the camera doesn't
just follow the hunter, it moves BY EXACTLY the hunter's own displacement,
every time — a pure translation of the whole rig, which is why the hunter
is pixel-identical across a 20x change in real distance. The paw only
crawls from 443 to 428 (15px, converging — the last 4x of standoff only
moved it 3px more), because the beast's OWN world position never changes
and it's just receding from an ever-more-distant camera. **There is a hard
ceiling on how much "gap" this camera can ever show, and it is reached
almost immediately — no realistic hunter placement gets meaningfully past
what 0.62 already shows.**

This means item 1 of this ticket ("a clear stretch of ground... visible in
`state=3d`") cannot be satisfied by moving hunters, full stop, under the
current resting camera — regardless of how far back they stand. The
camera's own pivot-tracking is the blocker, not the world placement. #14
says "do not touch the camera," and I've respected that and reverted
everything (`combat_3d.gd` is byte-for-byte unchanged in this push) — but
that instruction and this Done-when item are in direct conflict as
written. Nick's own #18 sequencing (open the gap, THEN lay the stones,
THEN bring the camera in close) may already assume this is fine — the
dramatic "gap" reveal might only ever have been meant to arrive with
step 3's close third-person camera, not the current wide establishing
shot. If so, item 1's Done-when bullet needs rewording (drop "clear
stretch of ground visible in state=3d," since no non-camera change can
produce it) rather than staying an open bar nothing can clear. Flagging
back to you rather than guessing which reading is right.

### 2. The stones: tried moving the route toward the head, reverted — real, reproducible reasons

Rebuilt the shipped Cinder Jackal AI model (`ai_beast.py`, reusing its own
already-exported `.glb` as the source — no Meshy spend) with the middle
climb rungs biased toward the head instead of a fixed window near the
front leg. Two different versions, both reverted:

**Attempt A — blend the search window toward the head as climb height
rises** (`climb_lane_center`, new pure function in `route.py`, unit
tested). Landed inside a real anatomical trap: swept the model at every
climb height first (a standalone diagnostic, not part of the build) and
the body's own cross-section is NOT monotonic front-to-back as height
rises — at the first rung's own height (32% up, leg/shoulder level) there
is a big gap of open air between the front leg and the belly (nothing for
a raycast to hit between y=-0.96 and y=0.74 at all), and the leg itself
slants BACKWARD as it rises from paw to shoulder (confirmed: rung 1
naturally lands further toward the tail than the foot below it, just from
following the real leg surface). The body only opens up toward the head
much higher — by 69% up (climb height 2.10 of 3.06) a horizontal sweep
finds continuous surface almost to the nose. A per-rung target Y that
assumes steady, even progress toward the head either finds nothing to
raycast onto at the low rungs (hard `FAIL`, reproduced live) or, once
loosened, gets dragged straight back toward the tail anyway by the
existing one-directional enforcement (`route_progress`'s own "keep going
the same way" rule locks onto whatever direction the first two rungs
established — and the first middle rung's own real pick, forced by the
leg's backward slant, sets a tail-ward direction no later per-rung target
can undo without re-litigating the anti-reversal rule itself).

**Attempt B — keep the search exactly as it ships, only raise the
floating-off-the-skin standoff** (`OPEN_AIR_WORLD`, `route.py`). Smaller,
safer-looking change; still made things visibly worse. The standoff isn't
just a final cosmetic push — it's baked into the SAME distance math that
decides which candidate is "in the hop-distance band" (`_hop_ok`) and
which one "continues the route" (`route_progress` is called on `c[1] + r`,
not the raw candidate), so raising it changes which real surface point
gets picked, not just how far the final stone sits from whatever got
picked. Rendered before/after at 1:1 (`state=3d`, cropped on the stones):
before, 2 stones read as clearly separate from the flank; after, 4 stones
(now individually visible, which IS real progress) but stacked tight
against the leg, partly in its own shadow — closer-looking, not
further-looking, than before. Not shippable as a net improvement.

Frames from this run's own experiments (not committed as final assets,
kept here for the record):

![[frames/fixer/2026-09-24-open-air-standoff-before.png]]
![[frames/fixer/2026-09-24-open-air-standoff-after.png]]

**Recommendation for whoever (or whichever future run) picks this back
up:** the raycast-onto-the-mesh-surface approach is very likely the wrong
architecture for "open air" stones — you noted this yourself ("once the
stones sit in open air... they are no longer raycast onto the mesh").
Every attempt above still asks "where does the body's surface happen to
be" and then pushes off it, which means the route is still fundamentally
shaped by the body's own silhouette (why Attempt A hit a wall the body's
own anatomy set, not a bug). A parametric path instead — a curve (even a
straight line, or a simple 2-point Bezier) authored from a point near the
hunter's own ground position to a point near the sigil, sampled at N
evenly-spaced holds, each one only checked for CLEARANCE against the body
(nudged outward if it happens to clip, never anchored TO the surface) —
would let the path go wherever reads well in front of the beast,
independent of what the mesh silhouette does at any given height. That's
a bigger rewrite than either attempt above, which is why I'm not
starting it with the run mostly spent on ruling these two out.

**Verification of the revert:** `python3 tools/blender/test_route.py` and
`run_tests.gd` both `ALL TESTS PASSED` on the tree as pushed;
`git status` shows zero diff against `combat_3d.gd`, `ai_beast.py`,
`route.py`, `test_route.py`, or the shipped `cinder_jackal_ai.glb`/`.blend`
— this push changes nothing about the live game, only this write-up.

**eta:** the camera question (#1 above) needs your call before item 1 can
ever close. The stones (#2) are a real rewrite (parametric path, not a
raycast tweak) — 2-3 more runs once that direction is confirmed, not the
1 more I guessed when taking this.

## Director's call — 2026-09-24 21:59 EDT

**Read both investigations. The pixel-projection table is exactly the right
kind of proof, and reverting both stone attempts was right. Answer to your
question, so you are not waiting on me:**

1. **The camera does not give; the Done-when does.** Nick's #18 says the
   distance is the fix and the camera follows it, in that order. So the gap
   is a *measurement* this ticket lands, and its *visibility* arrives with
   step 3. Rewritten above. Size it from the real need: a camera 4 units
   behind and 2 above the active hunter, at the game's FOV, must see the
   whole beast head-to-foot with headroom — whatever standoff that takes is
   the gap. **Prove it with a harness-only screenshot state** (a new
   `state=` in `screenshot.gd` that parks the camera there) rather than the
   play camera. That frame is how you, the playtester, Nick and I see the
   gap, and it is the starting point for step 3 — so do NOT wire it into
   play, and do NOT touch `_lock_point` / `_aim_camera`.
2. **Stop going into the on-body route.** Attempts A and B tried to move the
   rungs on the jackal toward the head; that was my bullet's fault ("toward
   the front of the head") and it is reworded above. The rungs and the sigil
   stay where `route.py` puts them today. What #14 wants is the *approach*:
   open-air holds across the gap from the ground spot to rung 1, placed
   parametrically (a curve, N holds, size falling off with distance), no
   raycast at all. The hop-band check runs on that path afterwards, per the
   original bullet. Do NOT re-enter `route.py`'s search, `_hop_ok`, or
   `OPEN_AIR_WORLD` for this — you have proven that lane is a dead end.
3. **Order next run:** the camera switch Nick asked for (one run, filed
   21:55, high), then back here: gap number + harness frame first, approach
   stones second. Fill `eta:` with that.

## Director — 2026-09-24 22:32 EDT

Back to `to: fixer`, `status: taken`. The camera question you handed me at
21:49 is answered by Nick himself: his 22:12 commit stops the ground camera
fitting the beast and parks it 9 units behind the hunter. The 21:59 call
above (harness-only state, "camera does not give") is superseded by that;
the camera work is now the 21:55 ticket, rewritten tonight. Order tonight:
the camera ticket first (one run), then this.

## Director — 2026-09-24 23:57 EDT (sequencing, now the camera has landed)

The camera ticket is done and with Nick — the shot is real progress. This is
your next run and the order inside it, so nothing gets done twice:

1. **Head clearance first** (new ticket, 23:56): the close camera puts the
   beast's face behind the Attack tag; one or two numbers. Do it here because
   narrowing the gap makes the beast bigger and pushes the head further up.
2. **The stones across the gap**, on Nick's `route_pos()` line, left → right
   → head, using the ARTIST'S rock (its handoff, 22:26, is open to you) — the
   pale stones in tonight's frame still read as a pot with an orange lid and
   a pot with a gold ring. Wiring its mesh is part of this, not a separate run.
3. The playtester's 20 m-hop finding (23:44, high) is this ticket's symptom:
   the route crosses the gap in four even 20 m legs because there is nothing
   between the ground spot and rung 1. Once the stones are there the hops are
   stone-to-stone and the check clears. **Do not widen `hop_arc()`'s ceiling
   to make it pass** — that would make the number green while the Frog still
   teleports on screen.

What NOT to do is unchanged: no re-entry into `route.py`'s search, `_hop_ok`
or `OPEN_AIR_WORLD`; the on-body rungs and the sigil stay where they are.

## Fixer — 2026-09-25 01:05 EDT (item 1 of 3 done)

Did the sequencing's item 1 (head clearance, the 23:56 ticket) this run,
before touching the stones. Camera numbers (`GROUND_VIEW_EYE`/`_PITCH`)
can't clear the head without failing the Goblin's own on-screen position
(15px of slack, gone at the first step tried) or blowing up the Frog's
scale — measured both, numbers on the 23:56 ticket's own `## Result`. Used
the ticket's own fallback instead: the intent tag now hangs beside the head
when the crown has no room above it, rather than clamping onto it. Proven
with 2 new tests, `ALL TESTS PASSED`, `3dclimb`/`3dgrip` CAM lines
byte-for-byte unchanged, before/after frame on that ticket. Left it `taken`,
not closed — its own Done-when says it rides this ticket's handback.

**Items 2 and 3 (the stones, the hop-band symptom) are still not started.**
The 21:49 write-up's recommendation stands: a parametric path (a curve from
near the hunter to near rung 1, N holds, checked only for clearance against
the body) rather than another raycast-onto-surface attempt — a real rewrite,
not a numbers tweak, and not something to start with this run's budget
already spent on item 1 plus proving it properly. `eta:` updated below.

Note for whoever picks up item 2: narrowing the gap (this ticket's own item)
will make the beast bigger on screen again, which may reopen the head
clearance question — the near-top intent-tag fix should still hold (it
reacts to wherever the crown actually projects, not a fixed number), but
re-check `state=3d` once the stones land rather than assume it does.

## Fixer — 2026-09-25 01:48 EDT (item 2 done: sweep + rock; item 3 still open)

Took item 2 of the 23:57 sequencing note (item 1, head clearance, landed last
run). Nothing pushed to `route.py`/`ai_beast.py`/the beast's own `.glb` — this
is entirely inside `combat_3d.gd`/`playtest.gd`, no Blender rebuild needed.

### The sweep

`route_pos` (`combat_3d.gd`) took a new `half_width` argument. The near end's
`x` used to be `top.x * 0.2` — barely off the top hold's own x, so from behind
the hunter the approach stones stacked one over the other (Nick's own
complaint, relayed 22:25 EDT). Now `start.x = top.x - half_width`, so the
whole thing is still ONE straight line (start → top, lerped by `t` — Nick's
"one line, even steps" from b0648db is unchanged, since a straight line has
the same even spacing wherever it points), just angled sideways as well as in
depth/height: first stone left and low, each next one further right and
higher, last exactly on the sigil.

`half_width` is `STONE_SWEEP_WIDTH` (new const, `HUNTER_HEIGHT * 3.0`), sized
off the hunter rather than the beast's own width on purpose — first tried
`_beast_box.size.x * 0.5` (5.4 units on the Cinder Jackal) and rendered it:
because the near stone sits close to the camera, that offset put it almost at
the frustum's edge, stretched by the wide-angle-lens distortion objects get
near the edge that close in. `HUNTER_HEIGHT * 3.0` (2.1 units) keeps the sweep
visible without that.

5 new unit tests in `run_tests.gd`, pure/no scene tree (#86 duty 3 style):
n<=1 returns the top hold unchanged, the first rung sits left of it, each
rung sweeps monotonically right, the sweep still climbs and the last rung
still lands exactly on the top hold, every leg of the line is the same
length (the "even steps" requirement), and `half_width=0` collapses back to
a centred line (regression guard). `ALL TESTS PASSED`.

`playtest.gd` calls the same static function directly for its own checks 8/8c
(hunter-off-marker, hop-distance-band) — missed on the first pass, caught by
a full playtest run (`script-error: Invalid call... Expected 5 argument(s)`).
Added `STONE_SWEEP_WIDTH` there too (mirrored the same way
`SIGIL_HUNTER_HEIGHT` already mirrors `HUNTER_HEIGHT`, since this file can't
import a `.gd` script's private consts) and passed it at both call sites.

### The rock

Wired in the artist's `foothold_rock.glb` (#17's own handoff, 22:26) in place
of the `SphereMesh` BODY, using their own verified scaffolding math
(`design/progress/foothold_rock.md` pass 2 — they'd already proven this exact
wiring live and reverted it before their own push, per "do not touch
combat_3d.gd"). The mesh's single `MeshInstance3D` child gets the same
`material_override` (the #12 palette + `ROCK_DETAIL` multiply) the old sphere
had, found by `find_children` since the imported scene is a `Node3D` wrapper
around one mesh, not a `MeshInstance3D` directly. Dropped the old per-stone
tilt/squash (tuned for a sphere; the artist's own note says it would distort
this hull unpredictably) — a random Y spin only, per their handoff. CAP/RIM
and the palette code are untouched, per #17.

### Proof

- `ALL TESTS PASSED` (`run_tests.gd`, including the 5 new `route_pos` tests).
- Full `mode=play beast=cinder_jackal steps=80` regression, fresh `--import`:
  `PLAYTEST FAIL: 1 failing check(s) { "hop-distance-band": 124 }` — the
  SAME count as the pre-existing baseline (this run's own numbers below), and
  the SAME shape it's had every run since b0648db. Zero `route-reversal`,
  zero `hunter-off-marker`, zero `script-error` once the two `playtest.gd`
  call sites were fixed. `state=3dgrip`'s pre-existing `VIS FAIL hunter1`
  reproduces identically on `git stash` of this whole change (541,81) vs
  (546,81) after — pre-existing, not a regression.
- Rendered `state=3d` (below) and `state=3dgrip` (below) fresh.

![[frames/fixer/2026-09-25-stone-sweep-state3d-after.png]]
![[frames/fixer/2026-09-25-stone-sweep-3dgrip-after.png]]

The grip shot matches the artist's own verification
(`frames/artist/2026-09-24-foothold-clay-pot-vs-boulder.png`) — a clean
angular rock with a readable flat cap. **The wide `state=3d` shot is honest,
not a win yet**: the literal "stacked" complaint is gone (each rung now has
its own distinct x), but sweeping the near stone (Height 1) out from behind
the hunter reveals it was ALWAYS this close to the camera (its own z sits
~7 world units in front of the lens, against a resting camera 3 units behind
the hunter) — previously invisible because it sat almost exactly on the
hunter's own sightline. Now visible, it dominates the frame the way any
object that close does, while the stones after it (Heights 2-4) recede
into a ~20m-per-hop span (item 3's own number, unchanged by this fix — see
below) and read as small/lost near the beast rather than as a legible
staircase. I did not retune that near-point's own depth (the `ground_z -
HUNTER_HEIGHT * 6.0` term) — it's Nick's own b0648db number, not something
this ticket asked me to touch, and I don't have standing to call whether
"big and near" (his own words, 20:08 EDT) is working here or reads as too
big. Flagging rather than guessing.

### Item 3 (hop-distance-band, #`2026-09-24-2344-...`) — confirmed NOT solved by item 2

The director's 23:57 note expected this to clear once the stones landed. It
doesn't, and the reason is structural, not a tuning miss: `route_pos` still
only has as many points as the beast has named climb Heights (5 on the
Cinder Jackal), because `n`/`i` come from `_rung_count()`/`_rung_index()` —
the SAME indices `_stand_on_model` uses for the hunter's actual foot state.
The sweep changes WHERE those 5 points sit, not how many there are, so the
total ~82-unit ground-to-sigil span is still divided into 4 legs of ~20.44m
each (measured this run, identical to every prior baseline). Fixing this for
real needs MORE waypoints between the named Heights than gameplay has states
for — which means the hop animation itself (currently one `hop_arc` tween
per Height change, in `_place_hunters`) would need to walk several
waypoints for a single card-driven height change, not just `route_pos`
placing more decorative stones. That's the "2-3 more runs" this ticket
already carried, now narrowed to one clear target instead of two.

Leaving `status: taken` — Done-when isn't met (item 3 open, and the wide
shot still isn't what Nick's drawing shows). Not handing to `nick`: nothing
here is ready for his judgement yet, and the honest gap above is bigger than
a look-and-say-yes.

## Fixer — 2026-09-25 02:55 EDT

Landed the director's own `2026-09-25-0200-...near-stone-now-hides-the-beast-from-chest-to-paws.md`
follow-up: the near stone (Height 1) no longer hides the beast's chest/legs
in `state=3d` (`STONE_SWEEP_WIDTH` 2.1 -> 4.55 units). Full before/after and
the one open remainder (a second, smaller, PRE-EXISTING stone at Height 2,
previously hidden behind the big one, now visible on the chest) are on that
ticket's own `## Result`. `hop-distance-band` stayed at its 124 baseline, as
expected for an x-only move. Item 3 (the hop-animation rewrite) is still not
started.

## Note from playtester — 2026-09-25 03:21 EDT

Filed on a separate ticket (2026-09-25-0155-director-to-playtester, "the
beast is behind a stone and nothing fires") but it belongs in this ticket's
own baseline, so leaving it here too: `playtest.gd` now has a live check,
`beast-behind-stone`, that projects `_beast_box` and every `_float_stones`
entry the same way check 8d already projects the sigil, and fails when a
stone nearer the camera than the beast covers more than 15% of the beast's
own on-screen rect. On the tree as of this run's own item-2 sweep (the
artist's rock, landed 01:51): stone 1 (the near approach stone) covers
28-39% across a full three-mode baseline, stone 2 covers 16-23%, and stone 5
(the sigil hold, mid-climb) covers 45-48% — 13-22 fires depending on mode,
0 `script-error`. Verified it goes quiet (temporarily widened
`STONE_SWEEP_WIDTH` 10x, reverted, never committed) so it isn't just
noise. Not something for this ticket to fix now — the director's own
ticket to me says the placement is yours — just so it's in your baseline
next to `hop-distance-band`/`route-reversal` when you pick the stones back
up.

## Director — 2026-09-25 04:05 EDT: the playtester's stone-2 and stone-5 numbers are on-body stones — leave them

Read the note above before you act on it. `beast-behind-stone` fires on
stone 2 (23.9%) and stone 5 (45-48%). Looked at both at 1:1: stone 2 is
the small stone on the beast's chest, stone 5 is the hold on its head that
the Frog stands on at the sigil. Both sit ON the body. Nick's drawing has
its small stones on the beast's shoulder, arm and foot; a foothold on the
body is the picture, not a fault. The fault was the near stone BETWEEN the
camera and the beast, and that one is gone (your 02:49 fix). The check
cannot yet tell the two apart; that is the playtester's open ticket
(`2026-09-25-0257-...`), not yours.

So: do NOT move stone 2 or stone 5, do NOT widen the sweep again, do NOT
tune anything to make that number go to zero. Your next thing is still
item 3, the 20 m hops. The 0200 near-stone ticket's Done-when is met; close
it yourself.


## Note from fixer — 2026-09-25 06:16 EDT

Item 3 (the 20m hops) is done, by a different fixer run than the one that
picked this ticket up earlier tonight — `f0808f0` (`hop_subpoints`, splits
an over-long climb leg into several real hops without moving any stone or
rung) plus a follow-up camera fix `a6f97ed`/`#0420` (the camera used to aim
at a chained climb's FINAL stop for the whole flight; now advances leg by
leg). `hop-distance-band` 124 -> 0, `hunter-lost-mid-hop` cleared (0/24 ->
24/24 on the director's own repro), both full regressions clean.

Then #0505 (this run): the split hops were visible but landed on air
between the first and last stone. `_build_float_stones` now drops a stone
under every sub-hop landing `hop_subpoints` produces, not just the named
rungs, receding in size toward the beast. `state=3d` reads as one path now;
full numbers and frames on #0505's own `## Result`.

Both ride this ticket's own handback — set `status: done` on each rather
than closing myself, per #0505's own instruction. Worth your own eyes on
the resting shot before it goes to Nick: ![[frames/fixer/2026-09-25-0505-stones-under-every-landing-resting.png]]

## Fixer — 2026-09-25 06:29 EDT: all four items in, handing to Nick

All four items of this ticket (head clearance, sweep + rock, hop-band
split, stones under every sub-hop) are landed as of the last three runs.
Re-verified fresh this run before handing back, not just trusting the prior
notes: `--import` from a clean clone, `ALL TESTS PASSED`, a fresh
`state=3d` render byte-identical to the one already on record, and a full
`mode=play beast=cinder_jackal steps=80` regression.

**This ticket's own Done-when, checked against that regression:** 0
`route-reversal`, 0 `hunter-off-marker` — both clean, the only bar this
ticket's own text sets. `hop-distance-band` (item 3/4's own bar) is also 0.

**One honest number left in the log, not this ticket's to close.** The
same regression shows `beast-behind-stone: 13` — the approach stones (not
the on-body sigil hold, which the director already excused 04:05 EDT)
cover more than 15% of the beast's on-screen body at several points in
play, up to ~40% on one step. That check can't yet tell an approach stone
that's supposed to be in front of the beast from one that's actually
blocking it — the playtester owns sharpening it. Not chasing it here: this
ticket's own Done-when doesn't mention it, and after the director's 04:05
call I don't have standing to keep retuning stone placement against a
check that flags correct-by-design coverage too.

**My own eyes on the frame, so you're not deciding blind:** the resting
shot below is a real staircase now — five distinct stones, each smaller
than the last, sweeping left-to-right up to the sigil, and the "stacked
into one pale blob" complaint from your own 22:25 note is gone. Next to
your drawing, the difference that stands out to me: your reference has the
beast filling most of the frame with a few small stones scattered in front
of it; this frame has a near stone big enough to cover a good third of the
Frog-to-beast gap, and the approach reads more like a solid diagonal wall
than floating rocks with daylight between them and the body. That may be
right — "big near the hunter, smaller as they recede" is your own 20:08
instruction, and the near stone's own distance from the camera (fixed
since Nick's b0648db, never this ticket's to move) is what makes it read
big. Flagging rather than guessing which way you want it.

![[frames/fixer/2026-09-25-0505-stones-under-every-landing-resting.png]]
