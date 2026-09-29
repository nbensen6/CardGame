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

**Builder, 2026-09-28 15:36 EDT:** the 12:24 build was pushed but left without its eye, so
this run re-took it against the RoR2 screenshot. Before: Frog ~20% of the
frame tall, camera looking down, horizon at y~215. Changes:
- `FOLLOW_DIST` 3.2 → 2.3 (tried 2.4, 2.6, 2.1; 2.1 hid the jackal's face
  behind the Frog at the sigil). New static `hunter_frame_share(dist, fov)`
  and a test pinning FOLLOW_DIST to the RoR2 band (0.20-0.34; 3.2 gave 0.17).
- `GROUND_VIEW_PITCH` 0.20 → 0.08 and `CAMERA_FLOOR` 0.8 → 0.5, so the
  resting lens sits low and near level like RoR2 (horizon now y~290) and the
  jackal's head drops out from under the boss bar. The sigil pitch
  (`CLIMB_FOCUS_PITCH_MAX`) is unchanged.
- Tried raising the aim (`GROUND_VIEW_EYE` 0.8, 1.2): pushed the Frog behind
  the cards, reverted.
Measured camera-to-Frog distance: 2.49 at rest, 2.43 at the sigil, so the
distance IS static; the Frog still reads ~1.8x bigger at the top (it did
before too, 165 vs 290 px). Cause not found; proposed.
Grader: FAIL three times. Round 1: change too small. Round 2: jackal head
under the intent badge/boss bar at rest. Round 3: "Frog about 180 px tall
(25%) at rest and about 335 px (46%) at the sigil". `run_tests.gd`: ALL
TESTS PASSED.

**Builder, 2026-09-28 18:55 EDT:** worked from Nick's 18:10 note ("model of frog
got changed when i got knocked back"). Root cause: the hop's squash-and-stretch
tweened the hunter body's scale back to `Vector3.ONE`, and a cancelled hop
reset it to `Vector3.ONE` too. The Frog is fit to HUNTER_HEIGHT at scale 0.61,
so after ANY hop (a climb or a knockdown) it stood 1.64x its size. The Goblin
(fit 0.38) had never hopped in these shots. This is also the unexplained
"Frog reads ~1.8x bigger at the top" from the 15:36 run.
- `_spawn_hunter` stores the fit scale as `rest_scale` meta; `_hop` squashes
  relative to it and `_cancel_pending_tween` restores it
  (`hunter_rest_scale`, tested).
- With the Frog its real size, it stood half-sunk in its stone. Two causes,
  both fixed: the rock mesh's top sat half a cap ABOVE the cap
  (`cap_height * 0.5 - rock_height`, against its own comment), and the stone
  bobs ±0.08 on its own phase while the hunter on it swayed on another.
  Rock top now sits inside the cap; a hunter standing on a stone rides that
  stone's drift (`stone_bob`, `riding_stone`, tested).
- Repro: `state=3d beast=cinder_jackal console=climb+5;climb+2`. Measured body
  scale after: 0.609 (was 1.0).
- Not reproduced: Nick's screenshot also shows the Frog side-on. The harness
  knockdown shows it facing the beast; proposed at the bottom of the queue.
Grader: FAIL (round 1, pair did not show rest vs knockback), FAIL (round 2,
Frog sunk into stone), PASS (round 3). `run_tests.gd`: ALL TESTS PASSED.

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

**Builder, 2026-09-28 14:57 EDT:** Nick (13:34), with a front and top
drawing: two lines, big near the hunters, small near the beast, meeting at
the beast. Before, both lines swept LEFT by the same STONE_SWEEP_WIDTH, so
they ran parallel (the Goblin's near stone sat almost under the jackal). New
`route_sweep_for(side)` opens each line OUTWARD on its own side by
ROUTE_FAN_WIDTH (1.4); tops stay at route_offset_x's ±2.8. Near ends are
now ±4.2, tops ±2.8: a V in the top view. Stones and hunters' landings both
read it (`_build_float_stones`, `_stand_on_model`); playtest's two route
mirrors call it too, and its stale STONE_SWEEP_WIDTH copy (6.5, the real
one is 2.0) is gone. Test: `_test_route_sweep_for_opens_the_two_lines_into_a_v`.
Frames: `2026-09-28-stone-lines-wide-{before,after}.png` (establishing shot,
shows the V), `-before/-after.png` (Frog cam), `-goblin-after.png` (Goblin
cam: both big stones flank the jackal like his front view).
Grader round 1 FAIL: from the Frog cam the Goblin's big stone is under the
climb gauge, and the middle stones hide behind the Frog's big stone. Tried
top ±1.4 with fan 0.7 (near ends ±2.1): Goblin's stone still under the gauge
and the Frog's big stone moved in front of the jackal's legs. Reverted. The
Frog cam maps x=+1.4 at the near-stone depth to about screen x 1095, so a V
whose near end is wider than its top cannot keep the Goblin's stone on screen
while the hunters stand ±1.15 apart. Needs a call: spread the hunters, or
accept the Goblin's stone off-frame in the Frog's view.

**Builder, 2026-09-28 16:24 EDT** (Nick 15:44: "the last stone for the goblin
is not at the head"; also asked for the question reworded). Measured on
`cinder_jackal`: the Frog's top stone at (-0.80, 15.1, 17.41), the Goblin's
at (4.80, 15.1, 0.53). Two causes. (1) The pair split around the sigil's
anchor (x 2.0), which is painted on the head's right edge; the hull at that
height says the snout is x -2.3..0.1 (centre -1.07), so the Goblin's line
ended past the side of the head. (2) Each top stone read the face in its own
column, so the Frog's caught the snout (z 17.4) and the Goblin's missed it
and fell back to the neck (z 0.5). Change: `_head_x` (middle of the hull
columns within 0.5 of the furthest-forward one) is the pair's centre, and
`_top_pair_front` (furthest of the snout and both stones' columns) is both
stones' face. After: Frog top (-3.87, 15.1, 17.41), Goblin top (1.73, 15.1,
17.41): one each side of the snout, level. Playtest's three route mirrors
call the same two functions. Tests: `_test_head_x_of_is_the_middle_of_the_snout_columns`,
`_test_top_pair_front_of_takes_the_furthest_face`,
`_test_both_top_stones_stand_level_in_front_of_the_head`. Shots:
`state=3d slot=1 console="climb 5" land=4` (Goblin at the top) as
`2026-09-28-top-stones-level-{before,after}.png`; rest `slot=1` as
`-rest-{before,after}`; Frog at the top as `-frog-after`. playtest.sh ran
past 8 minutes here and was stopped, not judged.
Grader round 1 FAIL (stone level with the head but beside the neck: the
sigil-centred pair), round 2 FAIL (head MET, rest criteria not visible in a
sigil shot), round 3 PASS on four-panel strips
`2026-09-28-top-stones-strip-{before,after}.png` (rest, wide, Frog top,
Goblin top): "Last stone in front of the head: MET for both hunters."

**Builder, 2026-09-28 18:25 EDT** (Nick 18:10: "hunters are not starting in
front of the stones"). Before: at rest the hunters stood ±1.15 either side
of centre (`side * (size.x * 0.06 + 0.5)`), while the two stone lines open
out to head_x ±4.2 (x -5.27 and 3.13 on the jackal), so each big near stone
flanked the hunters rather than leading from them. Change: new static
`rest_pos_for(first_stone, rest_z)`; `_place_hunters`' ground branch puts
each hunter at its own line's first-stone x (same slot convention and same
`route_pos_cleared` call as `_build_float_stones`), at the old rest z, which
is 4.2 units camera-side of that stone. Test:
`_test_rest_pos_for_stands_each_hunter_in_front_of_its_first_stone`.
Frames (`state=3d beast=cinder_jackal`): `2026-09-28-hunters-front-of-stones-{before,after}.png`
(Frog cam), `-wide-{before,after}` (F8 Dev), `-goblin-after` (slot=1: Goblin
in front of its stone, Frog off the left edge).
Grader round 1 FAIL: the Frog is in front of its stone, but the Goblin is
off-screen in the Frog's camera (VIS FAIL hunter1 at x 1691), and its big
stone is cut by the right edge. Its fix, "pull the right line inward",
contradicts Nick's 13:34 V (near ends wider than the tops): the hunters are
now 8.4 apart, and the follow cam puts roughly 112 px per unit at their
depth, so both on screen needs a gap under ~4.5, narrower than the top
pair's own 5.6. Not iterated further; Nick's call: accept the other hunter
off-screen, or narrow the lines (losing the V).

**Builder, 2026-09-28 19:05 EDT** (Nick 18:44: "this is fine... side note the
game is crashing while testing"). Layout accepted as built; this run is the
crash. Cause: "Test this now" runs `tools/screenshot.gd -- play ...`, and the
harness still armed its unattended-shot failsafe (`_failsafe`: 10 s, then
`quit(1)`), so every test window closed itself ten seconds after
`PLAY READY`. Reproduced under Xvfb: `PLAY READY` then `SHOT TIMEOUT`, process
gone at 15 s. A full scripted fight (`playtest.sh mode=play steps=40`) ran to
the end with no script error, so there is no second crash in the fight itself
that the harness can find. Change: static `arms_failsafe(user_args)` is false
in `play`; plain shots still arm it (checked: `SHOT SAVED`). Test:
`_test_play_mode_never_arms_the_shot_failsafe`. Frames
`2026-09-28-test-window-strip-{before,after}.png`: the play window grabbed at
30 s, Frog (slot 0) and Goblin (slot=1) side by side; before is black (window
gone), after is the live fight.

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

**Builder, 2026-09-28 16:03 EDT** (Nick 15:44: "camera follows more smoothly, but the
placement is too close to the character"). The 15:36 Zoom-out run had pulled
FOLLOW_DIST in from 3.2 to 2.3; up the side that drew the Frog about 45% of
the frame tall (rest about 25%). FOLLOW_DIST 2.3 -> 3.4, one number, rest and
climb alike. Measured: `console="climb 5" land=2` Frog from x 430-860 to
505-775, its stone now whole under it; rest shot now shows the Goblin too.
`midair=` samples t 0.2..1.6: cam_dist 2.32-2.53 before, 3.42-3.55 after, Frog
on screen 6 of 6 both. The run_tests band for `hunter_frame_share` moved to
0.12-0.20 and now asserts FOLLOW_DIST is further back than 2.3. Frames:
`2026-09-28-follow-further-{before,after}.png` (land 2),
`-rest-{before,after}`, `-hop-{before,after}` (six midair samples).
Grader round 1 FAIL (stills can't show the hop), round 2 FAIL: distance MET,
follow MET as far as stills show; failed on the attack badge touching the
Frog's head in two mid-hop panels and on two mid-hop panels with no stone
under the Frog (those are airborne by design).

**Builder, 2026-09-28 16:45 EDT** (Nick 16:29: "zoom the camera out more"). FOLLOW_DIST
3.4 -> 5.2, the one stand-off used at rest, mid-climb and at the sigil.
`hunter_frame_share` at the 65-degree lens goes 0.162 -> 0.106; the run_tests
band moved to 0.08-0.13 and now asserts the distance is further back than 3.4.
Frames: `state=3d slot=0 beast=cinder_jackal console="climb 5"` with `land=1`,
`land=2`, `midair=0.45`, `midair=0.95`, tiled 2x2 into
`2026-09-28-zoom-out-more-strip-{before,after}.png` (rest shot:
`-rest-{before,after}`). Frog about 135 px wide -> 85 px on the strip; the
attack badge now clears the Frog mid-hop by ~30 px.
Grader: round 1 FAIL (single land=2 frame could not show hops), round 2 PASS.

**Builder, 2026-09-28 18:14 EDT** (Nick 18:02: "better but not perfect. do research on
camera positions and the position specifically from risk of rain 2"). Research: RoR2's
survivor template (ArcPh1r3/HenryTutorial `CharacterBase.cs`, the base every RoR2
survivor mod copies from Commando) sets `pivotVerticalOffset = 1.37` above a 1.82-unit
capsule whose origin is its centre, `idealLocalCameraPos = (0, 0, -10)` (level, 10 back
from the pivot; "-12 for large characters like Loader"), fov 60, pitch -70..70. So the
RoR2 pivot is 1.25 survivor heights up, ABOVE the head: the survivor stands below the
crosshair, horizontally centred, and the enemy owns the frame's centre. Ours aimed at the
hunter's middle (GROUND_VIEW_EYE 0.5), which put the Frog dead centre. Change:
GROUND_VIEW_EYE = (0.91 + 1.37) / 1.82 = 1.25, with the RoR2 numbers as named constants;
distance untouched. Measured: rest Frog screen y 358 -> 414, Goblin 361 -> 420 (feet
above the card fan); `midair=0.45/0.95` Frog still ON screen (636,396)/(639,330).
Distance note: RoR2 at fov 60 draws the survivor 1.82/(2*10*tan30) = 16% of frame
height; our FOLLOW_DIST 5.2 at fov 65 draws the 0.7 hunter 11%, i.e. we already sit
further back than RoR2 (RoR2-equivalent would be ~3.5). Left alone: Nick asked for
"zoom out" at 3.4 and said "better" at 5.2. Test `_test_follow_camera_aims_above_the_head_like_ror2`.
Frames: `2026-09-28-ror2-camera-{before,after}.png` (rest) and
`-strip-{before,after}` (rest + `console="climb 5" land=2`).
Grader: FAIL twice, both on "camera not further back" (it graded the previous run's Ask);
its fix (pull back to 2/3 size) runs against the RoR2 numbers, so it goes to Nick.

**Builder, 2026-09-28 19:30 EDT** (Nick 18:44: "the camera should be consistent. its
zooming when you start climbing ... closes in once you start climbing. also the camera
should be facing the same direction the character is facing"). Measured first: the
distance never changed (CAM dist=5.20 at rest and at every landing; MIDAIR cam_dist
5.3-5.6 through the climb), the Frog's scale stayed 1, and its yaw already matched the
body's facing (camera yaw -0.16, body forward (0.16, -0.99): the lens sits straight
behind it). What DID change the instant the first hop began: pitch 0.08 -> 0.20
(`climb_focus_for` lerped to CLIMB_FOCUS_PITCH_MAX by climb_t, and climb_t reads the
climb's FINAL height, so it hit 0.2 on hop one) and the lens lift (v_offset -0.36 -> 0,
faded by climb_t in `_apply_orbit`). The lens rose ~0.6 and looked down onto the stone,
which reads as a push-in at the same distance; the Frog drifted 414 -> 429 -> 441 -> 450
px down the screen over landings 1-3. Change: pitch is GROUND_VIEW_PITCH at every height
(CLIMB_FOCUS_PITCH_MAX deleted; the unfocused climbing branch too) and the lift is
`lens_lift_for(dist)`, no climb term. After: the Frog is at (640, 414) at rest and at
landings 1, 2 and 3, same size. Test `_test_climbing_camera_keeps_the_rest_pitch_and_lift`
replaces the old pitch-rises test. Frames: `2026-09-28-camera-consistent-strip-{before,after}.png`
(rest, `console="climb 5"` land=1/2/3).
Grader: round 1 FAIL (compared midair samples, which land at different hop phases run to
run), round 2 FAIL with the distance criterion MET ("frog fills about the same share ...
the jackal grows ... because the frog is nearer to it, not because the camera zooms") but
"the frog shows its face and pale belly to the camera". A 3x crop shows its spotted back
and folded hind legs; the facing numbers above agree. Left to Nick.

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

**Builder, 2026-09-28 15:09 EDT:** Nick, 2026-09-28: "the faces when at the bottom
should be at the beast". A render with yaw 0 showed both models already
face -Z (backs to camera), so the fixed `0.7 * side` was swinging each one
40 degrees outward, side-on. `hunter_facing_y` now takes the hunter's
position and the beast's, and on the ground returns `atan2(dx, dz)`: the
yaw that aims -Z at the beast. Climbing branch unchanged. New test
`_test_hunter_facing_y_ground_hunters_look_at_the_beast`. Grader: PASS.

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
**Builder, 2026-09-28 17:05 EDT:** `hop-distance-band` is now 0 fails
(was 124). Only its CEILING half was red: every jackal leg measures
16.30m against hop_arc's 9.15m cap, because the route is one straight
line with one stone per Height (Nick, 2026-09-25) and no mid-air
sub-landings (Nick, 2026-09-28), so leg length is set by the beast's own
size. No route Nick has asked for can pass that ceiling, so it is
deleted with its reason at `HOP_MIN_WORLD` in playtest.gd; the floor
half (2.42m, "same minimum bounce however close the holds are") stays
and still passes. Game untouched: whether a 16m hop should arc higher
than its 2.38m cap is a look question, asked on the item. Still red:
hunter-lost-mid-hop 1 (step 9, hunter drawn in 6/15 frames of its own
jump), beast-behind-stone 4 (stone 7, 18-27%; waits on the stairs
decision). `run_tests.gd`: ALL TESTS PASSED. No 3D shot for a
"Shot: none" item; the frames are the playtest summary, before/after.

**Builder, 2026-09-28 20:21 EDT:** `hop-leftover-squash` is now 0 fails (was 10), new
red since the 18:55 fit-scale fix. The game was right, the check was
stale: hunters rest at their fit scale (Frog 0.61, Goblin 0.38,
`Combat3D.hunter_rest_scale`), and the check still compared every landing
to Vector3.ONE, so each hop "landed 0.39 off". `_scale_dev` now measures
relative to the body's rest scale (tested in run_tests.gd). The same
change un-silences `hop-no-squash`: in-flight squash read 0.52 against 1
(always "squashing"), it now reads 0.21 of rest, a real squash that
passes. `beast-behind-stone` swings on unchanged code: two before-code
runs gave 10 and 12, two after-code runs 12 and 12 (stones 5-7 at
15-24%, straddling the 15% line). Still red: hunter-lost-mid-hop 1
(step 9, drawn in 5/16 frames; next), beast-behind-stone 12 (waits on
the stairs decision). `run_tests.gd`: ALL TESTS PASSED. Grader
`VERDICT: FAIL` twice, on the parent's "zero checks" done-when, which one
run cannot reach; it scored "one red check cleared this run" MET. Left
`[ ]` per the Session 14:35 line (one check per run, no escalation).

**Builder, 2026-09-28 21:41 EDT:** `hunter-lost-mid-hop` is now 0 fails (was 1, step 9).
The game was right, the check was wrong. Step 9 is a Pounce: the Frog
drops from y 17.5 to 11.6. The live hop frames show it on screen the
whole way down, but the replay said "drawn in 6/16". A debug dump showed
why: the replay set the hunter's recorded mid-air `pos`, then Combat3D's
own `_process` (the idle / stone-ride line, which runs whenever no hop
tween is live) rewrote `position.y` to the stone height before the
render. Every sample the replay drew had the hunter at y ~11.6 while the
replay camera aimed at y 16-17.5, so it fell below the frame (rect empty,
"NOT DRAWN"). Ascents hid this because their mid-air heights sit close
to the landing stone. Fix: `_check_hop_visibility` now stops the view's
`_process` for the length of the replay and hands it back
(`_hold_view`, tested). After: all 8 hops in the 40-step run are 100%
drawn, step 9 16/16. Still red: `beast-behind-stone` 12 (11 before;
it swings 10-12 on unchanged code, stones 5-7 at 15-37%). That is the
last red check and a taste call (how much stone may cover the jackal),
so it is asked on the item. `run_tests.gd`: ALL TESTS PASSED. Grader
`VERDICT: FAIL` twice, on the parent's "zero checks" done-when; it scored
"one red check cleared this run" MET.

**Builder, 2026-09-29 00:21 EDT:** Nick's 23:44 line: move the stones
and hunters back so the jackal's chest shows from the last stone. Tried
it and reverted it: nothing in the game changed this run.
Tried: a `ROUTE_PULLBACK` (a fraction of the beast's height) added to
`top_hold_z_for`, so every stone follows because `route_pos` lerps
to the top. Top-stone shots at 0.3/0.6/1.0/1.5 × height (6-30 units). The
chest does not come out. At 1.0 and up a thin strip of flank shows to the
right of the stone. The grader: "Only a thin strip of flank ... The chest
is not readable."
Why, from the frame math: the follow camera looks almost level (pitch
0.08) from RoR2's pivot, 0.875 above the hunter's feet, and yaws at the
beast's centre. So the Frog is always dead in line with the jackal's
middle. Anything lower than the Frog's feet sits behind the Frog's own
stone. The chest, ~8 units below the top stone, only clears the stone's
top edge when the route is ~50 units back. No stone position fixes that
without changing the camera (a higher pivot) or the stone's height
(a last stone at chest height puts the chest behind the Frog's body).
Two variants measured in the 40-step playtest:
(a) whole route AND ground spot back 20: jackal tiny at rest,
beast-behind-stone 3 -> 31 (Goblin's near stone 5 covers 23-30%);
(b) top stone only back 20, ground unchanged: mid stones now hang in front
of the jackal at rest, beast-behind-stone 3 -> 31, worst 35.0% pixel,
over Nick's "a third is ok". Baseline on main, same run: beast-behind-stone
3 (max 15.8%), route-reversal 64 and damage-popup-offscreen 3, neither of
them from this item (proposed at the bottom of the queue). Grader
`VERDICT: FAIL` on (a); (b) not shipped either. Frames:
`2026-09-29-stones-back-top-before/-tried` (tried = (b)),
`-rest-before/-rest-tried`. The Test link shows the game as it is
(nothing shipped), at the top stone.

## Dev camera never survives a launch.

Original item: F8 into Dev is for this launch only; every launch starts on the Player camera, whatever was saved. While Dev is on, a small "DEV CAMERA" tag stays in a corner so Nick knows. Why: Nick pressed F8 to test it, the flag was saved, and every game since opened in the wide Dev view (his 2026-09-28 14:20 screenshot: tiny hunters, no beast). Done-when: launch twice with `Test: state=3d press=F8`; the second launch's frame is the Player camera.

2026-09-28 19:40 EDT, builder:
- `Progress.dev_camera_enabled` is now a static var for this launch only; it never writes the config, and an old saved `dev_camera_enabled=true` is ignored.
- `Combat3D._sync_dev_camera_tag()` puts a standing "DEV CAMERA" label bottom-right (above End Turn) while Dev is on. F8 and the Menu's Camera button both call it.
- The screenshot harness no longer forces Player at start, so the second shot proves the fix on its own (its scratch config may still hold an old true).
- Tests: the F8 test checks the tag appears and disappears; a new test checks that a stale saved true is ignored and that Dev never reaches the config.
- After strip: left is the F8 launch (Dev, tag), right is the next plain launch (Player). Grader: PASS.

## Can't scroll on the menu.

2026-09-29 00:39 EDT, builder. The in-fight settings panel (Menu, top right) grew past a
720-tall window once the keybind rows landed: Reset keys sat on the edge and
Abandon the hunt / Back were off-screen, with no way to scroll. The column now
sits in a ScrollContainer whose height is `Combat3D.settings_scroll_height`
(whole column when it fits, else window minus 24 px each side and the panel's
padding), refitted when the column or the window changes size. A wheel turn on
the dimmed backdrop no longer counts as a tap that closes the menu. Touch drag
scrolls the same box. Tests: `_test_settings_scroll_height_caps_at_the_window`,
`_test_settings_wheel_on_backdrop_does_not_close`. Grader: PASS (asked for a
scrolled-to-bottom frame as extra proof; the shot harness has no scroll arg).
