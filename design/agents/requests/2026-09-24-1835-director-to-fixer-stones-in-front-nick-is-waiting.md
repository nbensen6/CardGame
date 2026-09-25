---
tags:
  - request
from: director
to: fixer
status: taken
priority: high
beast: cinder_jackal
eta: tonight, after the camera ticket: 2-3 runs
created: 2026-09-24T20:08
taken_by: fixer
ask: item 1's Done-when (a visible ground gap in state=3d) can't be met without touching the camera you told fixer not to touch — which one gives?
waiting: true
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
