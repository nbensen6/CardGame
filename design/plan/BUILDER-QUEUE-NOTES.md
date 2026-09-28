# Queue notes

The history behind each line of [[BUILDER-QUEUE]]: the original brief, what
the builder measured and tried, what the session decided. The builder appends
under the matching heading. Nick never has to read this page.

## Zoom out: stairs visible, beast whole.

Your direction, built by the session 2026-09-25 20:55 EDT, not a
decision: lens 48 → 65 degrees, first stone straight ahead of the
hunter (route sweep 4.5 → 1.4), rest camera 8 back and 2 up looking
slightly down, mid-climb camera 5 behind the hunter on its stone, sigil
shot unchanged at 14. Result: the staircase reads from the hunter to
the face, the jackal is whole and far, hunters clear of the cards. The
cost is the Frog: about 60 px at rest instead of 200. Before is the
"stairs-a" frame. If the Frog is too small, say how big and the camera
comes in; the lens stays.


**Builder, 2026-09-28 12:24 EDT:** worked from Nick's 2026-09-28 12:04 note and the Risk
of Rain 2 screenshot (`design/art/references/hKsXNZ9zAbYXR7QxaDZBoY-1920-80.jpg`,
survivor about a quarter of the frame tall, centred, camera behind looking at
the boss). Changes, all in the 3D combat view:
- One distance, `FOLLOW_DIST = 3.2`, at rest, mid-climb and at the sigil.
  The climb pad (2.0) and the sigil pull-back (14) now equal it, and the
  big-leap zoom-out is gone. At the 65-degree lens that puts the Frog about
  150 px tall on a 720 frame (was about 60).
- Aim at the hunter's own middle (`GROUND_VIEW_EYE` 0.5 hunter-heights,
  everywhere, no climb lift), and `SHOULDER_AIM` 0, so the hunter is centred.
  Measured: hunter0 at (640, 380) at rest, (640, 418) at the sigil.
- Yaw on the line from the beast through the held hunter
  (`follow_yaw_for`), so the lens is behind them, not on world +Z.
- Tried pitch 0.35 (the beast went off the top) and 0.08 (no visible
  change, the camera floor holds the lens height). Kept 0.20.
Grader: FAIL twice. Both times it said the Frog reads side-on, and that the
stones hide the beast at rest. The first is the model's facing (see "Hunters
face the beast"). The second is stone placement seen from hunter height. I
fixed neither: both are outside this item.

## F8 flips the camera Player/Dev.

The Player/Dev button exists in the
fight menu's keybind panel, and Nick still sees the free camera through
`dev.cmd`. Find out why (suspect: `screenshot.gd` sets Dev on the real
config slot and it sticks). Make Player the state he lands in, and bind
one key (F8) that flips Player/Dev live with a one-second HUD label
saying which. Shot: `state=3d` — locked third-person, hunter's back at
bottom-centre.

### Builder run, 2026-09-28 12:51 EDT

- Nick: "nothing happens when i press f8". Reproduced in the harness with
  `press=F8`: the flag did flip to Dev, but Dev only unlocks drag/wheel input,
  so the frame was identical, and the 1 s note at y=96 was drawn under the
  intent chip (canvas layer 0, below the HUD).
- The `screenshot.gd` suspect is ruled out: it uses the scratch slot
  `progress_screenshot`, never the real one. But that scratch slot DID keep a
  `press=F8` flip into the next shot, so the harness now resets to Player.
- Change: F8 to Dev takes the camera (`_take_manual_control`), pins the aim
  height with `_pan.y` (a user-framed camera otherwise aims at the
  beast-framing height and drops the hunters under the cards), and cuts to
  `dev_overview()` = 3.6x the locked distance, same tilt. F8 to Player calls
  `_focus_camera()` then a snapped `_aim_camera`, a cut back. The note is 28 px
  at y=150, clear of the chip.
- Harness: `press=F8,F8` now presses in turn; waits 4 frames (~0.8 s here).
- Tuning measured by the VIS lines: 1.35x put the hunters under the cards
  until the pan pin; 2.2x with +0.25 tilt cut the jackal's head off; 3.6x
  flat keeps both hunters (y 337) and the whole jackal.
- Grader: FAIL three rounds. What it still names is the Player shot itself
  (Frog side-on, not back to camera; jackal hidden behind the stones), which
  are the proposed Frog-facing and near-stones items, and the note's 1 s
  duration, which a still cannot show.

**Builder, 2026-09-28 14:37 EDT:** Nick's 14:14 answer ("f8 now works") reopened the item. Nothing left to build: no code changed, no frames shot, no grader run. Marked 👀 so Nick can tick it.

## Nick judged the 2026-09-25 camera and stones

(2026-09-25 14:30 EDT).
Verdict, drawn on the frame: `art/references/2026-09-25-nick-stones-and-zoom.webp`.
Stones are wrong, camera is too close. The two items below are his answer.

## Stones: first by the hunter, last in front of the head.

Today the stones sit as a cluster beside the jackal's
left flank, floating at chest height, and the ground between the Frog
and the jackal is empty. Nick's arrows: the first stone lands just
ahead of the active hunter, on the ground he is standing on; the
staircase climbs the gap; the last stone is in front of the jackal's
head. Project each stone to screen and check it: first stone's screen
position is between the Frog and the beast, low; last stone overlaps
the head. Do not move the beast, do not shrink it. Shot: `state=3d`,
then the same shot beside his drawing.
**Builder, 2026-09-25 15:31 EDT:** CHEST_CLEAR_PUSH zeroed — it was
throwing rung 0 to x=-545 on a 1280px frame, which is the actual cause
of the empty gap. First stone now sits big and low in front of the
Frog. Rungs 1-4 still bunch near the jackal (perspective, camera
almost on top of rung 0 while the route's far end is ~80 units away) —
may resolve once the queued zoom-out lands, may not.

**Builder, 2026-09-28 13:11 EDT:** Nick (12:29): "the pair of stones need more
distance between them... each character can land on a stone that is
slightly to the right or left of the beast." Before: the two lines were
offset by `stand_offset_x` (±0.89 on the 10.8-wide jackal, meant for two
hunters sharing a ledge on the body), so each rung's pair touched and hid
the jackal. New `route_offset_x` gives the ROUTES at least
`ROUTE_PAIR_HALF_GAP` = 4 hunter heights (2.8) each side; `_top_hold`
uses it, so the stones and the hunters' landings (`_stand_on_model`) move
together. The playtest's hunter-off-marker check now uses the same rule.
Tried 2.5: the Frog's stone covered the jackal's legs again. Grader round
1 FAIL (read "in front of" as closer to the camera; top stones at jaw, not
face), round 3 PASS on the same geometry. Test:
`_test_route_offset_x_splits_the_pair_wider_than_a_shared_ledge`.

## Rest camera pulled back to 6.

Two frames from Nick:
at rest, "zoom out" (`art/references/2026-09-25-nick-stones-and-zoom.webp`);
mid-climb, "camera closer, should be locked to character"
(`art/references/2026-09-25-nick-climb-camera-closer.webp`, the Frog a
speck on the chest with the camera parked wide on the beast). Same
rule in both: the camera sits a fixed stand-off behind the ACTIVE
hunter, wherever the hunter is, hunter's back bottom-centre, and it
follows every hop. At rest that means further back than today; on
the beast it means much closer than today. Do not shrink or move the
beast. Moved ahead of the hops item 2026-09-25 15:40 EDT: the stones
run found rungs 1-4 collapse to one screen point because the camera
(dist=3) sits on rung 0; the route cannot be judged until this lands. Shot: `state=3d` and `state=3dclimb` side by side; the hunter
must be the same size on screen in both.
**Builder, 2026-09-25 15:55 EDT:** GROUND_VIEW_DIST (3.0) renamed
ACTIVE_HUNTER_DIST and raised to 6.0; the climbing camera
(`_focus_camera`) now uses that same fixed number plus only the
beast-clearance a buried hold still needs (`climb_dist_for`,
tested), instead of `_dist_for_window(THIRD_WINDOW)` fitting a
window around the beast's own height. Rest shot (dist 3→6) matches
Nick's "zoom out." Climb shot (dist 22.4→19.4) is closer and no
longer clips through the mesh, but `state=3dclimb`'s own test
scenario puts both hunters at/near weak_point_height — the most
extreme, deepest-buried hold on the route — where the clearance term
still dominates, so the hunter is noticeably smaller there than at
rest; the "same size in both" bar is met at holds nearer the beast's
front and not yet at the very top. The dedicated weak-point-shot
queue item below covers that top hold specifically.

## Sigil shot: face and eyes in frame.

*Landed by the session, 2026-09-25 16:31 EDT, after the builder's two
passes: the top stone stands in front of the face, camera at 14. Frame
in status/builder. The anchor-trust advice below was wrong; the hull was right.*
Answer to the builder's 16:11 ask: yes, skip `_front_of_beast` for the
climbing camera's clearance and trust the hold's own authored z, the
same rule `stand_z_for` already uses and for the same reason (the hull
band picks up the head and neck). Clearance at the sigil should come
out near 0.53, not 13.6. If the camera then clips the mesh, the fix is
a small fixed pad (1 to 2 units), not a return to the hull query.
Clearance alone will not land it: in the 16:11 after frame the camera
sits behind the Frog level with the back and looks past the head into
sky, so the jackal is not in frame at all. At the sigil the camera
must also sit higher than the hunter and pitch DOWN so the head is in
the upper half. Pitch is part of this item, not the later weak-point
item.
Done-when is the frame, not the number: at the sigil the hunter is
fully above the card fan, back to camera, bottom-centre, and the
jackal's eyes are in the upper half. If that frame does not land this
run, stop and say why in one sentence; do not tune a third constant.
Shot: `state=3dclimb`. Previous passes:
`agents/frames/builder/2026-09-25-sigil-climb-after.png` (dist 17.0),
`2026-09-25-locked-camera-climb-after.png` (dist 19.4).
**Builder, 2026-09-25 16:24 EDT:** clearance now trusts the anchor z
(`climb_focus_for`, tested) instead of the hull — dist 17.0→8.0 (6.0
fixed stand-off + a 2.0 pad so the lens doesn't sit on the surface it
now trusts, both within the ranges the ticket itself allowed) — and
pitch rises with climb_t instead of freezing wherever it last was, so
the jackal is now visibly in frame (was empty sky). Done-when not met:
the hunter is still mostly behind the card fan and no eyes are visible
— the lens is looking at the side of the head/ear, not the face. That
reads like a yaw problem, out of this item's scope (clearance + pitch
only); stopped rather than tune a third constant. See the proposed
item below.

## Hops land on stones.

The builder's
16:43 pass fixed the top hold only. Measured 2026-09-25 17:05 EDT with
`state=3dclimb slot=1` (the harness now prints STONE/HUNTER/RUNGS lines):
hunter1 at foot 4 has home z 30.71, its stone (STONE8) is at z 33.33:
2.62 units in front of the stone, in the air. hunter0 at the top: home z
16.58 vs stone z 17.41, 0.83 off the same way. Hunters at rest are
correct (z 85.27). The offset grows with rung, so the hunter's route and
the stones' route are built from different numbers (suspect: the
hunters' stops are computed before `_beast_box`/the hull are final, or
`hop_subpoints`/`_advance_climb_home` leave `home` on a sub-point).
Done-when: HUNTER home == its STONE world position within 0.1 on every
rung, printed by the harness, and a `run_tests.gd` case on the shared
rule. Shot: `state=3dclimb slot=1`, Goblin's feet on a stone.
**Builder, 2026-09-25 17:15 EDT:** both suspects were wrong; the real
cause was `_show_beast`'s own call order. It ran `_build_float_stones()`
BEFORE `_build_hull()`, so the stone's `_top_hold()` -> `_front_of_beast()`
call always saw an empty `_hull` and fell back to the box's raw far
edge, while `_stand_on_model` (called later, from `_place_hunters`, once
the hull is real) got the true value — two different numbers for the
same rung, growing with how close the rung sat to the top (matches the
measured 0.84 vs 2.62). Swapped the two calls. Live on `cinder_jackal`,
`state=3dclimb slot=1`: HUNTER0 home z=16.577120, its stone z=17.412895
-> now 16.577118 (was 0.84 off, now 0.00); HUNTER1 home z=30.710747, its
stone z=33.326931 -> now 30.710747 (was 2.62 off, now 0.00). Frame
confirmed changed (Goblin now stands ON the boulder, not floating past
it) with an md5 check against HEAD, not just eyeballed — see the Found
line below on why that check mattered this run. New `run_tests.gd` case
builds a fake mesh, calls `_build_hull()`/`_build_float_stones()` in the
wrong order to confirm it fails (9.31 apart), then the right order to
confirm it passes (0.00 apart).

**Builder, 2026-09-28 13:55 EDT** (Nick: "the characters are still jumping in
mid air"). The 2026-09-25 fix made the END of every climb land on its stone,
but not the hops in between. `_place_hunters` split every stop-to-stop leg
with `hop_subpoints` whenever it was longer than `HOP_MAX_LEG` (9.15m), and on
the jackal every leg is 16-25m, so each leg played as 2-3 hops whose middle
landings had no stone (the stones went back to one per Height on 2026-09-25).
Measured with the new `land=K` harness option (freezes the followed hunter the
instant hop K touches down): before, `climb 5` from rest landed the Frog at
z 78.6, 71.9, 65.2, 57.2 and the Goblin at z 77.2, 69.0, 60.9, 54.2, of which
only z 65.2 / 60.9 are stones; after, the Frog lands at z 65.2, 49.2, 33.3,
17.4 and the Goblin at 60.9, 40.8, 20.7, 0.5, every one a stone's own z.
Change: one hop per named stop (`climb_landings`, shared with playtest's hop
check); `hop_subpoints` is no longer called by the game. New test
`_test_every_climb_landing_is_a_stone`. Shot:
`state=3d slot=N beast=cinder_jackal console="climb 5" land=1..4`, both
hunters, tiled into `2026-09-28-hops-land-strip-{before,after}.png`.
Grader: FAIL on one frame (could not see "every hop"), then PASS on the
strips: "all eight landings ... show the hunter standing on a stone".

**Builder, 2026-09-28 14:24 EDT** (Nick 13:59: "camera is not smoothly
following the character and is jumping around"). Cause: the follow camera
aimed at `home`, and `_advance_climb_home` moves `home` to each leg's landing
stone the instant the leg starts -- 16-25 units ahead on the jackal. The pivot
eased toward it at rate 9 and overtook the hunter; the yaw also cut to the new
bearing in one frame, and the first hop's `_focus_camera` snapped the aim to the
climb's FINAL height. Every harness shot snaps the camera, so none of it showed
in a frame: new harness option `midair=S` runs climb + camera live for S s of
game time, freezes time, shoots unsnapped and prints a MIDAIR line. Before,
`console="climb 5"` at t=0.2/0.45/0.7/0.95/1.2/1.6: Frog on screen in 1 of 6,
behind the lens in 4. Change: `_follow_pos` (live body while its hop tween
flies, else `home`) feeds the lock point, the yaw and the focus aim; mid-hop the
pivot rides the body (`air_follow_pivot`), dead zone 0.56 above the eye and
0.1 below so a landing stays above the card fan; yaw eased (`ease_yaw`); the
big-leap "frame the whole band" branch removed (it needed the zoom-out Nick
ruled out). After: on screen 6 of 6, x=640 every sample, lens 3.2-3.4 from the
eye. Test `_test_follow_camera_rides_the_body_not_the_landing`. Shot strip:
`2026-09-28-camera-follows-hop-{before,after}.png`.
Grader: FAIL, then FAIL after the landing fix (lopsided dead zone): "the
intent badge ... sits on the Frog's head" and panel 1 (mid-hop, by design)
read as a float. Camera fault itself not cited in round 2.

## Hunters face the beast.

Nick, 2026-09-25 14:35 EDT: "want the
characters to face the beast." In the frame the Frog and Goblin stand
side-on to the camera. At rest, after End Turn, after Switch, both
hunters face the jackal (backs to the camera, per the Risk of Rain 2
shot). Shot: `state=3d`, both hunters visible.
**Builder, 2026-09-25 17:26 EDT:** the ground-facing formula was
`PI + 0.7 * side` — with the camera behind the hunters at +Z looking
toward the beast at -Z, and rotation.y=0 already facing -Z, that PI
term turned them to face the camera instead. Dropped it (now
`0.7 * side`); the climbing branch was untouched. Lifted into a
tested static function, `hunter_facing_y`. Frame confirmed changed.

## Goblin: one muted trim colour.

The Frog reads at fight size; the Goblin is
noise. Same treatment that fixed the Frog: fewer, bigger colour regions,
one silhouette read (the pack? the goggles?). Shot: `state=goblin`,
crop both hunters at 1:1.
**Builder, 2026-09-25 17:41 EDT:** sampled the goblin at true in-fight
size and found four separate bright warm hues (boots ~h16, ~h36; strap
~h0; ear tuft ~h40, all near-full saturation) competing with the green
body and the blue tank — the Frog avoids this by being one hue (MINT)
plus two small accents. `tools/blender/ai/goblin_ai_trim_desaturate.py`
masks that whole warm band by hue and folds it into one muted rust
(sat x0.55, val x0.85), baked into `goblin_mech_ai.glb`'s own embedded
texture (not just the loose extracted PNG, which is gitignored and
regenerates from the glb on every `--import` — confirmed by reverting
it alone and watching the live fight revert too). Picked the pack as
the one anchor per the ticket's own suggestion; did not touch the tank
or skin. Frame confirmed changed (goblin-only crop: 47% of its own
pixels differ). Did not touch the goggles option, or shrink the pack
itself — only the competing trim.

## Playtest: two checks re-derived.

`hop-distance-band` and
`hunter-off-marker` measure the beast's authored anchors, not the stone
route. Measure the route, or delete them. Shot: none — this one is
`ALL TESTS PASSED` plus a green `playtest.cmd`.
**Builder, 2026-09-25 17:52 EDT:** both checks' own top-hold z was the
raw sigil anchor, never the hull-pushed z `_top_hold()` actually builds
the route from — exactly the "authored anchor, not the route" bug named
above, just left in the checks themselves after an earlier pass
(962e3f0) re-derived everything else about them. Now both call
`top_hold_z_for`/`_front_of_beast` the same way `_top_hold()` does.
hunter-off-marker's route-mismatch fails: 10 → 2 on a 25-step
`playtest.cmd mode=play beast=cinder_jackal steps=25` run;
hop-distance-band clean before and after. `playtest.cmd` is not fully
green: the 2 remaining hunter-off-marker fails are a different bug (see
the proposed item below), and beast-behind-stone/camera-not-over-
shoulder/hunter-offscreen/hunter-lost-mid-hop/damage-popup-offscreen/
intent-tag-vs-hunter were already red before this change, unrelated,
and already tracked by the open camera items above.

## Weak-point shot, same frame as the sigil.

*Session, 18:05 EDT: covered by the sigil item above; the builder's 18:02 investigation confirmed the shot holds on Switch. Judge it on the sigil frame. One tick covers both.*
**Original:** Camera stays locked behind the active hunter at
the top hold; swaps hunter on Switch. Shot: `state=3dclimb hold=top`
(check the harness for the exact hold name).
**Builder, 2026-09-25 18:02 EDT:** no `hold=` value named "top" exists
in `screenshot.gd` — `state=3dclimb` already puts hunter0 at
`weak_point_height` by default, so that alone is the named shot.
Checked three ways: unforced default, `slot=1`, and a real `press=Tab`
(the actual Switch key) — all three land the same correct frame (dist
14.00, pitch 0.200, both hunters in view, eyes in the upper half).
`_switch_to` → `_focus_camera` → `climb_focus_for` already retargets
per-hunter on a swap; no broken frame found to fix, so nothing shipped
and this stays open. See `status/builder.md` for the frames.

## playtest.cmd green.

*Session, 18:35 EDT, answering the 18:27 ask: yes, retune `camera-not-over-shoulder`'s threshold and ease pair to the camera as it is now; a check's calibration is measurement, not taste. Still open: 6 red categories. Take them one per run, top of this list, in the order the builder proposed at the bottom. `beast-behind-stone` waits on the stairs decision below.*
**Original:** Answer to the builder's 17:52 ask: split off,
this item. Every check that is red on today's camera and route is
either re-derived against the shot as it now is, or deleted with one
line saying why. Red as of 17:52: camera-not-over-shoulder,
hunter-offscreen, beast-behind-stone, hunter-lost-mid-hop,
damage-popup-offscreen, intent-tag-vs-hunter, and the 2 remaining
hunter-off-marker fails (a hunter that hops PAST the sigil lands
1.7-2.6 off the check's shared-foothold x; fix the check's top-branch
side, or the landing, whichever is wrong). A red check nobody trusts is
worse than no check. Done-when: `tools\playtest.cmd` prints no FAIL,
`run_tests.gd` green. Shot: none.
**Builder, 2026-09-25 18:27 EDT:** `hunter-off-marker` is now 0 fails,
the only category this run closed. Two real bugs, both in the check
itself (game logic already correct, already tested):
(1) the top branch (`i >= n-1`, a hunter at or past the sigil) computed
`side` with the OLD dynamic shared-foothold rule (0.0 whenever nobody
shares the foot, which is nearly always) instead of `route_side`, the
FIXED per-hunter offset `_stand_on_model`'s own doc comment says the
top branch actually uses (2026-09-25, "two sets of stones, one set for
each character") — fixed, distance dropped 2.60m→1.71m on the one case
this alone explained.
(2) `_watch_hop`'s 300-sample guard cap (at `HOP_TIME_SCALE`, 1/6
speed) is too short for a multi-rung Leap/Grappling Hook — the tween
was still running when the guard gave up, and the function returned
without waiting for it to land, so `home` (and every check downstream
of `_watch_hop`, not just this one) read a mid-flight sub-hop point.
Now awaits `tw.finished` (at real speed, after the guard bails) before
returning. Both remaining hunter-off-marker fails were exactly this:
1.71m off, byte-identical on both, matching a still-running tween's
stale `home` far better than a geometry bug. `run_tests.gd`:
ALL TESTS PASSED.
Done-when NOT met: 6 categories still red (`camera-not-over-shoulder`,
`hunter-offscreen`, `beast-behind-stone`, `hunter-lost-mid-hop`,
`damage-popup-offscreen`, `intent-tag-vs-hunter`) — each is its own
investigation, not a quick follow-on to this fix (see the proposed
items at the bottom of this file for what was learned about each).
Staying `[?]`, not `[x]`.
**Builder, 2026-09-27 18:24 EDT:** `camera-not-over-shoulder` is now 0
fails (was 9), with 21 printed passing samples, `_shoulder` 0.951-1.000.
The camera was never broken — the check's clock was. `_shoulder`'s ease
is written in SECONDS (2.2/s, behind 0.45s of `_air_settle` holding it
at zero after every landing: 1.81s to pass 0.95) and the harness judged
it after a FIXED 43-45 FRAMES (~0.72s). Measured before/after: every one
of the 9 fails was a partly-eased value in two clean clusters —
0.42-0.44 on the steps whose hop hit `_watch_hop`'s guard cap (the bare
frame tail) and 0.87-0.91 on the steps that got the extra frames of a
fully-watched hop — and not one was near 0.0, so the truck always
engaged. Threshold unchanged at 0.95; the wait is now derived from the
camera's own numbers (`Combat3D.shoulder_settle_seconds`, tested, with
`AIR_SETTLE_TIME`/`SHOULDER_EASE_RATE` lifted out of inline literals so
the check cannot drift from the shot again). The check also prints its
value when it PASSES now, so "0 fails" can't be mistaken for a silenced
check. Done-when NOT met: 4 categories still red (hunter-off-marker 8,
hunter-offscreen 4, beast-behind-stone 8, intent-tag-vs-hunter 1), per
Nick's own one-category-per-run note. `run_tests.gd`: ALL TESTS PASSED.
Grader `VERDICT: FAIL` — scored the parent's "prints no FAIL" done-when
(unreachable this run by that same note); scored the camera criterion
MET, "re-derived, not silenced." Left `[ ]`.
**Builder, 2026-09-27 18:39 EDT:** `hunter-offscreen` is now 0 fails
(was 4). The check was right and the game was wrong. All 4 fails were
steps 0-3, the Frog's first climb, projecting to (640, -47..-261) with
`focused=false establishing=false` (the check now prints those flags).
`_focus_camera` leaves `_focused` false while everyone is on the ground
(#11's resting shot), and nothing turned it back on when someone left
the ground. Only Switch or End Turn did, so until step 4 the camera held
the ground shot and the Frog climbed off the top of it. `_aim_camera`
now hands over to the locked follow the first time anyone leaves the
ground (`Combat3D.want_follow_engage`, tested); the rest shot is
untouched. Steps 0-3 now also pass `camera-not-over-shoulder` (21 → 25
passing samples). Frame: `state=3d beast=cinder_jackal
"console=climb 2"` (the harness now waits for a console climb's hop
to land): before, the Frog is out of frame at (640, -48); after, it
is on its stone at (640, 466), back to camera, with the jackal whole
behind it. Still red: hunter-off-marker 8, beast-behind-stone 8
(10 before; this category swings between runs), intent-tag-vs-hunter 1.
`run_tests.gd`: ALL TESTS PASSED. Grader `VERDICT: FAIL`: it
graded the parent's done-when, which can't be read off a frame for
a "Shot: none" item. Left `[ ]`.
