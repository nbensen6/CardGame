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

## Playtest presses Switch.

2026-09-29 16:37 EDT, builder.

- `_play` in `game/tools/playtest.gd` clicks the real Switch button mid-turn, at most once a round: the held hunter has played a card this round and still has a playable one. The first press is unconditional; later presses only while the held hunter is hanging, so the grip check has a clock to watch.
- Check `grip-drained-away`: the unheld hunter's `_climb[slot].g` is read before each step's click and again after the step (and at the Switch press itself, before the newly held hunter's clock runs). Any drop fails. `switch-dead` fails if the press did not change `_me()`; `switch-never-pressed` fails a play run with no press. `_finish` logs `switch: pressed N time(s); grip-while-away checked on M step(s)`.
- Run (40 steps): `Switch (hunter 0 -> 1)` at step 1; `grip-held OK, hunter 1 grip 0.271 -> 0.271 while hunter 0 played` at step 15 (Pounce); summary 1 press, 1 checked step. Only failure: `beast-behind-stone` (red before this change too, 14 -> 20 because the card order after the switch differs).
- Evidence: `design/agents/frames/builder/2026-09-29-playtest-switch-before.md` / `-after.md` (the reports). Grader: PASS.

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

**Builder, 2026-09-29 17:19 EDT:** one red check left, `beast-behind-stone`, now 21 fails
(was 3-12). All 21 are in the Goblin's view: since the playtest presses
Switch (16:37 run) the Goblin's camera is checked for the first time. From
behind the Goblin, its own first three stones (stones 5, 6, 7; the Goblin's
line is 5-9) cover 19-33%, 40-47% and 13-24% of the jackal's drawn pixels.
From behind the Frog, the Frog's own line (0-4) covers at most 11%, and
steps 5-8 and 13+ pass. The two lines are exact mirror images about the
jackal's box centre (x -1.07, which is also `_head_x`): Frog x -5.27 to
-3.87, Goblin 3.13 to 1.73, same y and z (81 to 23). So the geometry is
Nick's V layout working as drawn; the difference is in the jackal's own
silhouette, which fills more of the Goblin's line of sight. Nothing to fix
in the check (the pixel diff is real) and nothing in the layout without
changing what Nick approved, so no code changed and this is escalated as the
taste call the Session 14:35 line allows. Levers if Nick wants less cover:
a wider `ROUTE_FAN_WIDTH` (both lines open further out), or raise
`BEAST_STONE_COVER_MAX`, which was calibrated from the Frog's view only.
No grader run: nothing shipped, so before and after are the same frame
(`2026-09-29-goblin-stairs-cover-jackal.png`, `state=3d slot=1`).
`run_tests.gd`: ALL TESTS PASSED.

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

2026-09-29 11:10 EDT, builder. Nick answered 10:50: "Yes the scroll bar works now". Nothing
left to build; re-marked 👀 so he can tick it (the builder never writes `[x]`).

## Move the stones and the hunters back from the jackal.

2026-09-29 11:58 EDT, builder. Nick 10:44: "move the stones back. they don't
have to be so close to the head."

- `top_hold_z_for` now adds `TOP_STONE_PULLBACK` (6 units) after its face
  clearance. Every stone follows, because `route_pos` lerps from the ground
  spot to the top hold; the ground spot, the camera, the jackal are unchanged.
  playtest.gd calls the same function, so its expectations moved with it.
- The float stones flatten toward the beast: `stone_depth_ratio(recede)`,
  2.0x radius near the hunters to 0.9x at the top, and the rock mesh's y scale
  now follows `rock_height` (it was uniform, so `rock_height` only placed it).
  Why: the climb camera looks level from just behind the hunter, so the chest,
  under the hunter's feet, was hidden by the top stone's own body at any
  pullback (00:21 run's finding).
- Tried: pullback 8/12/16/20 without the taper (12: chest a thin strip; 16+:
  Frog over the face), 12 with the taper (grader: jackal too small). 6 with
  the taper passed.
- Playtest, 40 steps, same run: main `beast-behind-stone` 2 (max 15.6%),
  this change 6 (max 17.6%); route-reversal 64 and damage-popup-offscreen 2-3
  on both.
- Tests: the two `top_hold_z_for` tests include the pullback;
  `_test_top_stone_stands_back_from_the_head`,
  `_test_stone_depth_tapers_toward_the_beast`. ALL TESTS PASSED.
- Grader: FAIL (12, chest hidden), FAIL (12 + taper, jackal too small), then
  `VERDICT: PASS`.
- Note: in `tools/shot.sh`, `console=climb+5` runs nothing ('+' is decoded in
  play mode only); the frames used `"console=climb 5"`.

## One tap for ordinary timed cards?

2026-09-29 21:36 EDT, builder. Worked from Nick's 21:14: "drag no longer touch card tops, but some drag goes over the next click in the timing event. need to make sure they are spaced and lead well".

- **Road clear of every tap** (`Combat3D.road_clearance`, `ROAD_CLEAR` 75 px = a ring + half the road's dark band + 14): no tap's centre is that close to any leg of the drag's road. Checked on every candidate step of the walk, so a tap cannot land on the road and a leg cannot be laid across an earlier tap.
- **Leads on** (`drag_leads`, `DRAG_LEAD_TURN` 0.7 rad): the tap after the drag's tail turns at most ~40 degrees off the road's last leg, so the road points at it instead of doubling back under it.
- **Rings never touch** (`note_spacing`, `NOTE_GAP` = two rings + `NOTE_AIR` 12): was 69 px centre to centre (rings overlapped); tap steps are now 1.0-1.2 x NOTE_STEP, not 0.95-1.2.
- **Off the hunter by NOTE_AIR too**: keep-off rect grown by a ring + 12; `NOTE_BESIDE` is a ring + 12 (was 1.15 rings); the road may not cross the hunter (`road_crosses`).
- **Whole-walk retry** (`NOTE_WALKS` 32): a walk that boxed itself in is walked again; the first that meets every rule ships, else the roomiest. Test over 480 patterns (2 and 3 taps, every drag slot, three hunter rects): 0 taps on a road, 0 doubling back, 0 touching rings, 0 on the hunter.
- Harness: `3dosu` now waits 1 s after moving the hunters to their footholds before tapping. It tapped mid-hop, so the notes were laid round a hunter rect ~50 px from where the hunter stood in the frame (ring 2 and its road on the Goblin's legs).
- Grader: round 1 FAIL (rings 3 and 4 touched; a ring pressed on the hunter; wanted full-window shots with the card in frame). Round 2 `VERDICT: PASS`.
- Frames: 2x2 labelled sheets of full windows, `state=3dosu beast=cinder_jackal hold=on hand=<card>`, two plays each of piston_punch (cost 2) and overload_engine (cost 3). The pattern is random per play; 9 after plays were shot and all met the rules. The Test line stays the four-card deal so Nick taps them himself.


2026-09-29 17:04 EDT, builder. Worked from Nick's 12:44 ("yes and randomize the order for drag. sometimes on one sometimes others") and 12:59 ("some of the time events are going behind the cards").

- **Drag anywhere in the chain** (`Combat3D.drag_order`): on a card with a drag, the number of taps before it is rolled fresh every play, 0 to all of them, so the drag opens, sits inside or closes the chain. `note_pattern(..., drag_at)` keeps the drag's road in one piece wherever it falls.
- **HitCircle** now takes `begin_flat(bonus, points, drag_from, drag_len)`: taps, the drag, then taps again. Riding the drag to its end (or letting go past the rescue mark, which caps the chain at GOOD) moves on to the tap after it instead of closing the window. Numbers skip the road points (tap, drag, tap reads 1, 2, 3). The 3D `begin(..., slider)` path is unchanged.
- **Notes above the cards**: the circle's `z_index` was 0 and a raised card's is 10, so any note over the hand band drew under the cards. Now `CIRCLE_Z` 100 (under the dragged card at 200). Play A in the after grid shows note 3 drawn over the Overload Engine card.
- Grader-driven, same item: `NOTE_RISE` 150 -> 100 (notes were reaching the jackal's head and intent badge), queued notes fade by steps not indices with a floor (`LOOKAHEAD_FLOOR` 0.24), and a queued note's dark disc never fades below 0.7 (a faded disc vanished on the pale stone and the grader counted a step as missing).
- Tests: drag slot rolled across all four places over 60 seeds, road stays whole; tap-drag-tap resolves in order and a rescued drag carries on; circle z above a raised card and below a dragged one; lookahead floor.
- Grader: FAIL (cost 0/1 not shown; notes up at the head), FAIL (a cost-3 step unreadable on the stone), FAIL (drag ends touch the card tops; wants every note kept out of the card band). Three rounds, so escalated. The z fix means a note in the band now draws over the card, not behind it; keeping notes out of the band entirely is proposed.
- After frame: 3x2 grid, each `state=3dosu beast=cinder_jackal hold=on hand=<card>`: flick, lash_out, piston_punch (drag 1st), overload_engine x3 (drag 2nd, 3rd, last). The drag slot is random per play, so the shots were retaken until the slots differed. The Test line stays the four-card deal so Nick taps them himself (`hold=on` freezes the circle).

2026-09-29 12:19 EDT, builder.

Worked from Nick's 11:59 answer: "make it more complex dependent on how much the card cost. add a mechanic of click and drag. also add variety of where the clicks are, but don't have them far from the card."

What changed:

- **Taps by cost** (`Combat3D.timing_plan`): cost 0 = 1 tap, cost 1 = 2 taps, cost 2 = 2 taps then a drag, cost 3+ = 3 taps then a drag. A card that prints more windows keeps them (Satchel Charge 3 taps + drag, Bomb 2 taps at cost 0). A climb of 2+ is a drag at any cost (Winch = 1 tap + drag). Replaces the old floor of 3 notes on every card (`NOTE_MIN`) and `card_is_slider`; the melded-card case that guarded is now a test on `timing_plan` (taps never collapse into one hold). The sweep-bar face uses the same tap count.
- **Click and drag** (`HitCircle`): a chain can now be taps followed by a drag. Press the drag's head on the beat, then keep the pointer on the ball as it runs the road; wander more than `DRAG_RADIUS` (87 px) off it, or lift, and it counts as letting go (same rescue rule as the old hold). The road ahead is drawn dim with a DRAG label while you are still tapping.
- **Where the notes go** (`Combat3D.note_pattern`): a random walk around the card's middle, one step (92-110 px) at a time, turning every note, never on top of an earlier note, never more than 230 px from the card, never more than 150 px above its middle, never below the frame's bottom margin. Notes are pinned in screen space (`HitCircle.begin_flat`), so the camera easing no longer drags them off the card: in the before frame the three notes had drifted up under the grip banner.
- Harness: `hold=` now parks the circle one frame after the tap and freezes it. Under the software renderer, 26 frames had already closed the window before the shot.

Grader: round 1 FAIL. The notes rose over the hunter, and the on-screen shove lifted the whole pattern when a drag ran off the bottom. Fix: the rise cap and the floor inside the walk. Round 2: `VERDICT: PASS`.

The after frame is a 2x2 grid of four shots, each `state=3dosu beast=cinder_jackal hold=on hand=<card>` with flick (0), lash_out (1), piston_punch (2) and overload_engine (3). The Test line deals those four cards into a normal fight instead, so you can tap each one yourself. `hold=on` would freeze the circle in play mode.

## A missed timed card: keep the card?

2026-09-29 12:30 EDT, builder. Worked from Nick's 12:14 answer: "a miss play can do a plain value of the card, but hitting the timed can have a small bonus".

- `Combat.play_card`: the early return that made a missed timed card vanish is gone. A miss logs "misses the timing on X — plain value", previews un-nailed (timed bonus 0) and resolves every printed effect; the card discards (or exhausts / stays as a power) like any other card. Energy is spent either way, as before.
- The hit bonus is the existing `timed_*` fields, graded GOOD (half) / PERFECT (full). No card numbers changed.
- A miss does NOT build Rhythm (Rhythm is "+1 per timed card you LAND"); `landed` rides on the card_played moment for that.
- A miss now counts as a card played (nth_card, cards_played_total), since it resolved.
- "Sure" (auto_nail) unchanged: a miss still lands as a perfect hit.
- Harness: `miss=1` / `nail=1` tap the first timed card and resolve its circle as a miss / perfect, log panel open. Measured on Lash Out at the sigil: miss 8 damage, perfect 12; below the sigil the armoured hide chips both to 1, which is why the Test line climbs first.
- Tests: six old "fumble slips away" tests rewritten to the new rule (plain damage, printed block, printed climb, discard +1, counts toward nth_card, no Rhythm).
- Grader: FAIL (shot did not show the miss), FAIL (no hit to compare), PASS with the before frame and a miss | hit strip.

## Jackal HP 42 to 70?

2026-09-29 12:39 EDT. Nick 11:59: "yes, but we need to adjust how the jackal deals damage ...
special abilities ... potentially bring in a burn mechanic."

- Built: `bosses.json` cinder_jackal `max_hp` 42 -> 70. Nothing else changed
  (moves, hurt_moves, hurt_pct 0.4, weak point). Hurt switch now at 28 HP.
- Test: `_test_cinder_jackal_has_70_hp_so_its_hurt_moves_happen` pins 70 HP and
  the hurt switch between 29 and 27.
- Not built: the damage rework / burn. Nick said "start thinking", which is a
  design call, so it went to BUILDER-PROPOSED.md as a proposal (Burn bite) for
  him to move up or change.
- Grader: VERDICT: PASS (bar 42/42 -> 70/70, nothing else changed).

## Let the Frog hang?

Reworded 2026-09-29 for Nick, who asked what the question meant. Nothing in the game changed.

In plain words: on the jackal the stones at height 2 and 4 are safe, and the sigil is 5. If a climb stops you at 1 or 3 you are hanging: the big red countdown in the picture starts, and when it hits zero you slip down. The Frog adds +1 to every climb, and its starter climbs are all odd numbers, so every Frog climb ends on 2 or 4 and the Frog never hangs. Only the Goblin ever sees the countdown.

The proposal: keep the +1 on the Frog's Climb cards (Leap, Scramble), but not on its attacks that also climb (Tongue Snap, Pounce). Then, for example, a Tongue Snap from stone 2 lands on 3 and the Frog has to hang. Yes = make that change. No = leave the Frog as it is.

Picture: `state=3dgrip`, a hunter hanging with the countdown at 3.

### Built 2026-09-29 17:26 EDT: grip off

Nick, 17:14: "lets get rid of the grip mechanic for now" (and on the grip clock item: "remove grip timer for now"). So the Frog's +1 question is dropped; nothing about the Frog's climbs changed.

- One switch, `Coach.GRIP_TIMER_ON := false` (combat_3d.gd reads it as its own `GRIP_TIMER_ON`; the view has no class_name, Coach does). Flip it to true to bring grip back; the timer code, `grip_paused`, `grip_after_tick` are untouched.
- With it off, `climb_state_after_secure_update` always returns null, so no hunter ever gets a timer: the HOLD ON bar never shows, nothing drains, no `fall` is reported to the host.
- The party row's "hanging!" tag and the coach's "Your grip is draining" tip go quiet off the same switch (grader round 1 failed the frame for the leftover "hanging!").
- Core is unchanged: `secure`/`next_safe` still exist in the snapshot, and ledges still matter for anything else that reads them.
- Harness `state=3dgrip` now waits 1 s and prints `GRIP-OFF OK: foothold 1 -> 1 after 1 s, bar shown=false` (before: the Frog fell 1 -> 0 and took 3 damage).
- Tests: existing timer tests pass `timer_on=true` explicitly; new test `_test_grip_timer_off_means_a_hanging_hunter_just_hangs`.

## Give the jackal a swipe that cares where you are?

2026-09-29 13:19 EDT, builder.

- Worked from Nick 11:59: "a claw sweep attack and knocks players back that are close", on the session default (round 4, Height 4+).
- New beast move `claw_sweep` in bosses.json: `{"type": "claw_sweep", "value": 6, "min_height": 4}` replaces the jackal's round-4 `attack_all 6`. Damage 6 unchanged. Hurt pattern (the `attack_all 9` there) untouched.
- It hits only hunters at or above `min_height` and throws each one to the safe hold below that reach (jackal: Height 4 or 5 goes to Height 2). Same Sweep-anchor relic (`shake_resist`) still holds you in place. Hunters below 4 take nothing.
- One rule (`Boss.claw_catches`) drives the hit, the incoming-damage number and the red party-card border; the badge reads "Claw Sweep 6 — throws Height 4+". Keyword entry added for tap-to-inspect.
- Harness: `endturn=N` could not reach round 4 on the cloud's software renderer (10 s failsafe), so the failsafe now grows 15 s per end-turn; new `thenend=N` presses End Turn after `console=`, log open, to shoot a resolution.
- Frames: before (Sweep 6, both hunters red), after (Claw Sweep badge, only the Frog at 5 red), thrown (`... console=climb+5 thenend=2`: Frog 26 to 20 HP, Height 5 to 2, log line). The strip is after + thrown.
- Grader: round 1 FAIL (throw not shown, badge silent on it); round 2 PASS.

## The jackal's turn plays out on screen.

Built 2026-09-29 14:18 EDT.

- When a snapshot arrives with `round` advanced in the same fight (`Combat3D.enemy_turn_starts`), the view keeps the OLD board up and plays the turn out (`_enemy_stage`: windup -> attack -> landed -> ""):
  - 0.0-0.4 s: hold; the intent badge pulses twice (scale 1.25); the hand band is hidden and End Turn disabled.
  - 0.4 s: the existing `attack` clip starts. No new clips.
  - bite = 0.4 + 16/40 of the clip (jackal clip 1.333 s, bite at 0.933 s): the new snapshot renders: HP, damage popups, hunter hops/falls (so a sweep's shake and hops land here too), next intent. `_react` no longer restarts the attack clip while a staged turn owns it.
  - bite + 0.5 s: the new hand deals, End Turn comes back.
- `enemy_turn_beats(clip_len)` and `enemy_turn_starts(...)` are static and pinned by `_test_enemy_turn_beats_land_in_order`.
- The item's Test line was `endturn=1`, which only hands the turn to the Goblin; the beast acts on the second End Turn. The shots use `endturn=2`; Nick's Test link stays `endturn=1` so he presses the second End Turn himself and watches.
- Harness: `enemyat=S` shoots S seconds into the beast's turn on the view's own clock, then freezes the scene so the capture is that beat. Strip = enemyat 0.1, 0.65, 0.94, 1.6. Before strip used wall clock 0.3, 0.8, 1.2, 2.2 (no staging existed).
- Playtest waits for `_enemy_stage == ""` after End Turn (polling popups meanwhile) so it judges the settled board. Same three red checks as main; beast-behind-stone varied 3 (main, one run) vs 5-8 (this branch, four runs), all borderline 15.4-17.8% with drifting stones.
- Grader: FAIL x3. Met: the hold, the number after the hold, the hand last. Not met: the pulse and the clip do not read in stills (the jackal is small and front-on; its head drops ~0.65 s but subtly); the sweep was not shot; the Frog's damage "7" covers the Frog (existing popup placement).

Builder, 2026-09-29 18:09 EDT, on Nick's "re word this question it doesnt make sense" (17:14).

- The old Ask named the grader's complaint, not what to look at. New Ask: press End Turn once (the Test link already ends the Frog's turn, so the next End Turn is the jackal's) and say whether the jackal lunges at the Frog before the damage shows.
- The complaint itself was real: from behind the hunter the jackal stands 85 units away (20 tall) and its clip alone does not read as a bite. The whole body now carries the beat (`beast_lunge`, `beast_lunge_pitch`, both static and tested): it rears back 8% of the gap through the hold, drives 35% of the gap toward the hunter it bites in the 0.2 s before the bite, holds there 0.15 s while the number lands, and is home when the new hand deals. It pitches about its feet (0.2 rad back, 0.15 forward) and drifts toward the bitten hunter's x. `_step_enemy_turn` now runs before the beast is placed, so the lunge is the frame's own beat.
- A hunter's damage number opens above the hunter and out to its own side (`hunter_popup_at`), not on its head; the grader flagged the "7" covering the Frog twice.
- Shots: `state=3d beast=cinder_jackal endturn=2 enemyat=0.1|0.65|0.94|1.6`, composed 2x2. The Test line stays `endturn=1`: enemyat= freezes the view and quits, so it cannot go in Nick's link.
- Grader: FAIL (bite reads as rearing), FAIL (front-on lunge only grows; "7" on the Frog), FAIL ("wind-up cannot be told apart from the hold"; the bite now MET with a caveat, "7" off the Frog, no penalties). Escalated.
- Tests green; pitch at 0.35 rad foreshortened the jackal so it looked smaller on the bite, cut to 0.15.

## The grip clock only runs on your own time.

2026-09-29 14:27 EDT, builder.

- Rule: `Combat3D.grip_paused(slot, held_slot, hop_live, timing_open, enemy_turn)`. A hanging hunter's clock ticks only when they are the one held (`_me()`), their own hop tween (`_climb_tw[slot]`) is done, no sweep-bar/HitCircle window is open (`switch_blocked_by_timing`), and `_enemy_stage` is empty. `GRIP_SECONDS` stays 5.0. Test: `_test_grip_clock_runs_only_on_the_held_hunters_own_time`.
- Networked play only tracks your own slot, so there only the hop/timing/beast-turn pauses apply.
- Harness: `state=3dgrip` now hangs the Goblin too (between holds, above the Frog), shows the Goblin's bar, runs the Frog's clock out, shows the Goblin's bar again, and saves a 1280x360 before|after strip. It prints `GRIP-PAUSE OK/FAIL`. Old code: 0.58 -> fell. New: 0.98 -> 0.98.
- Grader round 1 FAIL (pair could not show a before/after value); round 2 FAIL only on hop/timing pauses and the 5 s, which a still cannot show; the done-when read as MET.

Builder, 2026-09-29 18:23 EDT, on Nick's "remove grip timer for now" (17:14).

- Already done: the 17:26 run ("Let the Frog hang?") set `Coach.GRIP_TIMER_ON := false`, which removes the timer for both items. No code changed this run.
- Verified on current main: `state=3dgrip` prints `GRIP-OFF OK: foothold 1 -> 1 after 1 s, bar shown=false`; no HOLD ON banner, no "hanging!" tag. Tests green.
- Before = the 14:27 pause-rule frame (banner + bar + "hanging!"); after = the same scenario now.
- The pause rule (`grip_paused`) and its test stay in the code, dormant, for when grip comes back.
- Grader: PASS on the first round.

## Timing notes open at the hold on the beast.

2026-09-29 14:41 EDT, builder.

- Frame: the item's own Test line (3dclimb slot=1) opens no timed card, so it cannot show a note. Shot `state=3dosu beast=cinder_jackal hold=on` instead: the harness taps the Goblin's Satchel Charge mid-climb and parks note 1 at its beat.
- Before: note 1 at about (247,540), on the tapped card, ~400 px from the hunter.
- Change: `notes_anchor(hunter_rect, card, view)` in combat_3d.gd. The pattern now opens beside the active hunter's projected AABB, on the side facing the tapped card, at 35% down the rect, NOTE_BESIDE (0.9 target radii) past the edge. `note_pattern(..., lift=false)` keeps the first note on that spot (±8 px) instead of lifting it 75-150 px. It falls back to the card when the hunter has no rect or is off the frame. The reach, rise and floor rules are unchanged, now measured from the hunter.
- After: note 1 at about (581,308), ~70 px from the Goblin's head. Test `_test_notes_open_beside_the_climbing_hunter` pins it over 40 seeds: the note is within one hunter-height, never on the hunter, on the side facing the card, and falls back to the card with no hunter or an off-frame hunter.
- Tension: Nick's 11:59 answer on the timing item said "don't have them far from the card". This item moves them to the hunter. The Ask puts that to him.
- Grader: PASS on the first round.

2026-09-29 18:44 EDT, builder (Nick 17:14: "i do see timing over the cards still").

- Root cause: the pattern's floor was the screen bottom less 96 px (y 624 at 720p), which is inside the hand band (card tops at y 512). A walk from a hunter standing low fanned notes down onto the cards; the whole-pattern shove used the same bottom bound.
- Measured with a new harness line (`TIMING lowest note bottom=... hand top=...`), six rolls each: old code at rest 4/6 over the hand (worst 101 px deep), mid-climb 1/6; new code 0/10 at rest, 0/4 mid-climb. Harness `rest=1` opens the timed card with both hunters on the ground.
- Change: `notes_floor(view_h, pad, hand_top)` = the old floor or the hand top less a note radius less 24 px (the DRAG caption clears too), whichever is higher on screen; `_hand_top()` reads the highest card; `pattern_shove(..., floor_y)` uses it as its bottom bound.
- Grader round 1 FAIL: frame was at rest, not mid-climb (fair; reshot mid-climb), grip bar not beside the notes (moot, grip is off per Nick), and note 2 drawn over the Goblin. Fixed the last: `note_pattern(..., avoid)` rejects any step whose ring would touch the hunter's rect; NOTE_BESIDE 0.9 -> 1.15 radii, the first note's jitter pushed back out if it lands on them.
- Test `_test_timing_notes_stay_off_the_hand`: 3 hunter spots x 40 seeds, no note bottom over the hand after the shove, no ring on the hunter; no-hand fallback unchanged.
- Covers two proposed lines at the bottom of the queue ("notes can still open over the hunter's body", "notes may dip into the card band"); Nick can delete them.
- Grader round 2: PASS.

## Hunters lunge when they attack and flinch when hit.

Builder, 2026-09-29 15:02 EDT.

- `_hunter_play` still plays a rig clip when one exists; with no clip (every hunter today) it falls back to `_hunter_tween_act`, a tween on the BODY (never the holder, so the climb hop and the pip are untouched).
- Numbers live in static `hunter_act_beat(anim)`: attack = 0.15 s out, 0.2 s back, 1.6 m toward the beast plus 0.55 m lift, scale punch 1.3, lean 0.4 rad into the beast. Hit = 0.2 s out, 0.25 s back, 1.0 m away, scale 0.9, lean -0.5 rad, white overlay at alpha 0.85 fading on the way home.
- The first try (0.9 m, no lift, punch 1.22) failed the grader: from the rest camera the beast sits straight behind the Frog, so "toward the beast" is into the screen and barely moves it (12 px). The lift is what makes it read (67 px at the new numbers).
- Only the hunter who played the card lunges: `strike_slots(prev_energy, energy, fallback)` picks whoever spent energy in the snapshot diff; a 0-cost card falls back to the hunter this client drives. The old code made every hunter take the attack beat together.
- The flash fade is part of the same tween, and killing a beat mid-flight clears its overlay, so a second hit never leaves a hunter stuck white.
- Harness: `3dstrike beat=rest|attack|hit actor=N` seeks the beat to its extreme with `custom_step` and zeroes camera shake, so the three frames share one camera. The after frame is a 2x2 sheet of full frames at half size.
- Test: `_test_hunters_lunge_on_attack_and_flinch_on_hit` pins both beats and the attribution rule.
- Grader: FAIL (lunge not visible, hit direction unclear, Goblin unjudgeable), then PASS.

Builder, 2026-09-29 18:59 EDT, on Nick's "the scenario doesn't show this properly also frog is stuck" (17:14).

- Cause: the `3dstrike` harness seeked the lunge to its peak and PAUSED the tween so a still could catch it. In `play` (Test this now) nothing ever unpaused it, so the Frog hung in its lunge against the jackal's face for good. It also snapped both hunters up to the sigil first, so the one pose Nick saw was a close-up of the Frog clipping the head. The game's own lunge was never stuck.
- Fix: `strike_holds_beat(play, beat)`: only an unattended shot holds a beat; test pins it. New `beat=loop`: hunters stay on the ground (no sigil snap), the Frog lunges (the beast takes a strike), comes home, flinches white, comes home. In `play` it runs three rounds on the real clock and then the fight is his, live. Unattended it seeks each beat with `custom_step` (a software-rendered frame is longer than the whole 0.35 s lunge; a real-clock shutter caught nothing) and writes a labelled 2x2: rest, strike peak, home again, hit peak.
- The shot widens the lens 1.6x (the view never writes fov) so the Goblin's stone is in frame: LOOP log shows the Goblin at (1163, 397) +-2 px in all four frames; Frog body 0 -> (0, 0.55, -1.6) scale 0.61 -> 0.79 -> home 0 -> (0, 0, 1.0) scale 0.55 -> home.
- Test link and Test line now carry `beat=loop`.
- Grader: FAIL (panels unlabelled, no rest-then-strike order, Goblin out of frame), then PASS.

Builder, 2026-09-29 22:12 EDT, on Nick's "in the lunge can you add a tongue coming out like its attacking with its tongue at the beast?" (20:59).

- `HUNTER_TONGUE` (combat_3d.gd) names the hunters whose attack lunge shoots a tongue; only `frog`, value is its colour (pink 0.93, 0.36, 0.5). The hunter dict now carries its `cid`.
- The tongue rides the lunge's own tween: `tween_method(_aim_tongue)` 0 -> 1 in parallel with the 0.15 s out, 1 -> 0 with the 0.2 s return, hidden at 0. Killing a beat mid-flight hides it, like the flash. Hit beats and the Goblin never show it.
- Shape: 14 unshaded cylinder segments plus a round tip pad, parented to the rig, built on first use. Runs from the mouth (55% hunter height above the body) to the beast box centre, stopping `TONGUE_SHORT` 0.15 short.
- The first straight tongue was 84 world units long but only 30 px on screen: from the rest camera the jackal stands straight behind the Frog, so a straight line points into the screen. It now arcs up by `TONGUE_ARC` 0.05 of its length (0.18 and 0.12 looped up behind the Attack badge) and thickens toward the tip (radius 0.14 x hunter height at the mouth, 7x that at the far end, pad up to 11x), so the far end still reads.
- Static `tongue_point(mouth, target, u)` holds the arc; `_test_hunters_lunge_on_attack_and_flinch_on_hit` pins Frog-only, starts in the mouth, lands 0.15 short of the aim, arcs above the straight line.
- Before and after frames both `state=3dstrike beast=cinder_jackal beat=loop`; only panel 2 (strike peak) changes.
- Grader: VERDICT: PASS.

Builder, 2026-09-29 22:41 EDT, on Nick's "slow down the animation by about 25 %" (22:29).

- `hunter_act_beat` durations x1.25: attack out 0.15 -> 0.1875 s, back 0.2 -> 0.25 s (round trip 0.35 -> 0.4375 s); hit out 0.2 -> 0.25 s, back 0.25 -> 0.3125 s. Distances, punch, lean and flash unchanged. The tongue rides the same tween, so it slows with it. The `beat=loop` harness reads the durations from the dict, so its live rounds slow too.
- Test pins the new out and back for both beats.
- Harness: new `beatat=T1,T2,..` with `beat=loop` (unattended only; ignored in play): shoots the lunge that many seconds after it starts, each panel a native-size 640x360 crop of the frame centre, so a speed change shows in stills. The peak-seeking strip could never show it.
- LOOP log, body z at 0.20/0.28/0.36/0.44 s: before -1.40/-0.39/0/0, after -1.59/-1.16/-0.31/0.
- Grader: FAIL (first strip at half size and 0.1-0.4 s, difference unreadable), then PASS on the cropped strip at 0.2-0.44 s.

## Played cards fly to their target.

Builder, 2026-09-29 15:30 EDT.

- A tapped card (plain tap, the circle timing, the sweep timing) is copied into a CardView on the HUD and flies from its hand slot to its target in `CARD_FLY_S` = 0.25 s: up to 1.2x in the first quarter, then shrinking to 0.3x and fading as it arrives, so it never parks over the hunter. The play command is sent only when it lands.
- Target: the beast's weak point for an attack or any card with printed damage, the commanding hunter for everything else (`card_fly_target`). A card with Block or ally Block plays the `block` sound and pops a pale-blue ring on the hunter as it lands (`card_fly_blocks`, `_block_ring`).
- Taps are ignored while a card is in the air (its hand index is not settled until it lands); End Turn lands a flying card first. The hunter slot is captured at tap time, so Switch mid-flight cannot redirect it.
- Harness: `fly=N` taps card N and freezes the flight; `flyt=F` sets how far (default 0.7; 1 lands it).
- Grader: FAIL (card at 55% still overlapped the fan and covered the Frog; the shrink was chained after the move, so the flight ran 0.44 s — fixed with delays), FAIL (no scale-up visible, no climb card shown), then PASS on a six-panel sheet.
- Playtest FAIL lines: 74 before and after the change.
- Not covered: cards played through a pick (exhaust/cheapen/meld) still resolve instantly.

Builder, 2026-09-29 17:39 EDT, on Nick's "the card is stuck" (17:29).

- Cause: the Test link carried `fly=0`, and the harness froze that flight on purpose (tween paused, then the whole view set to PROCESS_MODE_DISABLED) so a still could catch it mid-air. In `play` Nick holds that window, so Slash hung over the Frog forever and nothing else moved. The game's own flight was never stuck.
- Fix: `fly_holds_midair(play, flyt)` in the harness: only an unattended shot with `flyt` < 1 holds the card; in `play` the view is never disabled. A landing (`flyt=1`) now flies on the real clock and waits for `_card_flying` to clear instead of stepping the tween, so the after frame proves a real tap lands. Test pins the rule.
- `fly=N,M` taps each card in turn. With `flyt=1` each is caught once at half flight, then released to finish and land on the real clock; the frame is a strip, mid-flight | landed per card. In `play` the same taps just fly and land.
- After frame (`fly=0,0,0 flyt=1`, 852x720): each card caught a quarter into its flight (its 1.2x peak, bigger than the fan) | landed. Slash toward the jackal, 70 -> 69; Brace toward the Frog, lands with the pale ring and Block 5; Rope Up toward the Frog, lands and he climbs. Energy 9 -> 6.
- Grader round 2 FAIL: caught at half flight the card had already shrunk below hand size; no climb card. Round 3: caught at the peak, Rope Up added, failsafe gets 5 s per flown card.
- Grader round 3 FAIL: "none of the panels shows a card in flight" (at the quarter mark the card is still over its slot and reads as raised). Round 2 (half flight) showed the flight but not the scale-up. Escalated: the real game was never stuck; the frames can prove the flight or the scale-up, not both in one still.
- Grader round 1 FAIL: the landed-only frame showed no card in the air and no ring.

Builder, 2026-09-30, on Nick's "the played cards flying feel really bad please revert" (20:59).

- Reverted by hand (a `git revert` of 9283b8e and 14354b2 conflicted with later work): the flying CardView copy, `CARD_FLY_S`, `_fly_card_then`, `_land_card_now`, `_card_goal`, `card_fly_target`, `card_fly_blocks` and the block ring are gone. Every play path (plain tap, the one-card pick fallback, the card-face timing, the hit circle) calls `play_card` on the tap again, exactly as before 9283b8e. End Turn no longer lands a card first; taps are no longer ignored while one is in the air.
- The `block` sound went with it; it is again never played. Not re-added on its own: Nick asked for a revert.
- Harness: `fly=N,M` now just taps those cards in turn; `flyt=` is accepted and ignored so old Test links still open. `fly_holds_midair` and its test removed; the flight test now pins that the flight code is gone.
- Before (old code, `fly=0 flyt=0.5`): Slash frozen mid-air over the Frog. After (same args): Slash resolved on the tap, jackal 70 -> 69, energy 9 -> 8, discard 1, fan closed to three cards.
- Grader: VERDICT: PASS.

## The jackal dies on screen.

Run 2026-09-29 16:04 EDT.

- **Clip.** `death` (46 frames at 30 fps, rotation only): recoil (f5), front legs buckle and head drops (f14), root rolls +Y 80° so the body tips to -X, away from the climb side (f32), a small bounce (f37), still (f46). Keyframes live in `tools/blender/beast_clips.py`; `ai_beast.py` makes it on a fresh build. The Meshy source is not kept, so the new `tools/blender/ai_beast_clip.py cinder_jackal death` opens `tools/blender/ai/cinder_jackal_ai.blend`, keys the clip the same way and re-exports the glb with ai_beast.py's export settings (the stray Icosphere in the .blend is left out). Ran with pip `bpy` 4.2 on Linux; the glb gained an inert `KHR_materials_clearcoat` (factor 0), nothing else changed (same 33 nodes, 7917 verts, jpeg texture).
- **Game.** `game_3d.gd` (the router) no longer swaps straight to the reward: when the phase leaves combat for `reward`/`won` it asks the fight view `play_death()` and holds it that many real seconds (`holds_for_death`). `combat_3d.play_death()` plays the strike + damage popup for the HP that was left, sets `Engine.time_scale` 0.3 for 0.6 real s, then plays `death` and holds; total = 0.6 + clip + 0.8 s rest (`death_hold_secs`). If a hunter is off the ground the camera eases out to the establishing wide (a close climb shot cropped the fall); from the ground the rest shot is kept. Tried centring the camera on the beast: it put the camera inside the fall; reverted.
- **Harness.** `deathat=0.3,1.6,2.6,3.6` on `3dreward`: leaves the beast at 6 HP, loads the router, runs `console=`, then kills it through the real path and grabs one frame per time (real seconds after the blow) into a 2x2 grid. Software rendering makes the times land ~0.2 s late; the mid-fall panel is narrow, 1.6 catches it.
- **Grader.** Round 1 FAIL (strip cropped, no reward frame): fixed to whole frames and a 4th panel after the cut. Round 2 FAIL (middle panel still standing): slowed the fall 14→32 frames and reshot. Round 3 FAIL only on the 0.6 s slow-motion, which stills cannot show; hit, fall, body down and the cut all MET.
- Tests: `_test_router_holds_the_fight_for_the_beasts_death_only`, `_test_death_hold_covers_the_slow_hit_the_fall_and_the_rest` (also checks the glb carries `death`). Playtest unchanged: 3 failing checks before and after (route-reversal, beast-behind-stone, damage-popup-offscreen).

## Make the Jackal be less glossy and more matte.

2026-09-29 19:11 EDT, builder.

- Nick's screenshot: pale peach triangles across the jackal's brow and snout, the Frog at the sigil.
- Cause, isolated by shooting 3dclimb three ways: toon.gdshader's hard specular band (`step(spec_cut, N.H)`, strength 0.12) lights a whole flat facet at once on the low-poly head. Spec off removed the patches; rim off only dimmed the ear edges a little.
- Fix: `SURFACE_FINISH` in combat_3d.gd, `{"cinder_jackal": {"spec_strength": 0.0}}`, applied by `toon_material` to the painted body only (not the outline, not footholds). The felled jackal on the reward screen (`toon_all`) gets the same finish. Frog and Goblin untouched.
- Test: `_test_jackal_toon_body_is_matte`.
- Shot: before and after both `state=3dclimb beast=cinder_jackal` (Nick's own view; at rest the jackal is too far to see the gloss).
- Grader: VERDICT: PASS.

Builder, 2026-09-29 21:52 EDT, on Nick's "it is matte enough" (2026-09-29 21:14).

- Nick's answer approves the 2026-09-29 matte pass; nothing left to build. No code changed, no new frame, no grader run (before and after would be the same frame).
- Marked 👀 so Nick can tick it; the builder never writes `[x]`.

## Change the fog so it's behind the exterior.

- Cause: the Cinder Jackal's biome (`quarry_ember`) used exponential fog at density 0.014, which washed the whole Meshy rock wall and its lava seams into flat purple. With fog at 0 the mountains render crisp.
- Fix: new optional biome keys `fog_behind` ([begin, end] in arena radii) and `fog_behind_density` switch that biome to Godot depth fog. `fog_behind_range()` never lets the fog start nearer than `FOG_BEHIND_MIN_R` = 5.5 radii: the wall ring sits near 2.9 radii and the camera may stand up to 2.4 radii out on the other side. Jackal uses [6, 10] at peak opacity 0.6, so only the sky past the wall is hazed. Every other biome is explicitly reset to exponential fog with its own density, unchanged.
- A first try at [2.2, 4.0] still put a lilac wash on the mountains; that was the wall inside the fog ramp.
- Tests: `_test_fog_behind_range_never_starts_inside_the_wall`, `_test_fog_behind_range_scales_with_the_arena_and_ends_past_its_begin`.
- Shot: before and after both `state=3d beast=cinder_jackal`.
- Grader: VERDICT: PASS.

## More free unrestriced camera movement at higher speed.

Builder, 2026-09-29 22:32 EDT. Dev camera only; the Player camera and the rest shot are untouched.

- Wheel zoom: floor was 4.0 units from the pivot (the held hunter), so at the sigil the lens stopped a hunter-length short of the jackal. Now `DEV_ZOOM_MIN` 0.5 in steps of 0.2 (was 0.12), and past the floor each notch walks the pivot 0.6 along the lens (`dev_dolly`), so zooming in never stops.
- WASD: `dev_fly_speed` = 1.0 x max(dist, 6) u/s (was 0.34 x max(dist, 4)); Shift x3. Measured: W held 2 s from the rest shot moved the pivot 3.32 before, 12.06 after.
- Pivot clamp (`dev_pan_clamp`): up to the wall (`cam_reach_for`) and 1.5 arena radii up (was 0.8 and 0.9). The lens itself is still held inside the wall.
- Harness: `devzoom=N` (Dev on, N wheel-ups), `devorbit=deg`, `devfly=secs` (hold W in real time); all show the DEV CAMERA tag.
- Grader: round 1 FAIL (no dev tag in frame, before not at old max); round 2 zoom MET, speed/freedom "not visible in stills"; round 3 (strip: zoom + 2 s fly) FAIL, wants an off-axis position the old camera could not reach and read the zoom as no tighter than Nick's picture. Frames: `2026-09-30-devcam-free-{before,after}.png` and `-strip-{before,after}.png`.
- Tests: `_test_dev_camera_is_freer_and_faster` (six checks).


## The climb zigzags side to side.

2026-09-29 23:14 EDT, builder.

- `route_pos` keeps both end rungs on the straight line (ground gap and
  sigil) and steps every inner rung sideways by `ZIGZAG_WIDTH`, alternating,
  in the horizontal perpendicular of the line. The first inner rung steps
  OUTWARD (away from the other hunter's line); stepping inward first piled
  both lines' second stones together over the jackal's chest.
- Even hops: `zigzag_along` re-spaces the rungs along the line so every hop
  is the same 3D length (a hop that crosses twice as far sideways moves less
  far along it; bisection on the hop length). Tests pin alternation, even
  hops for n=3,5,6, and the no-offset case.
- The hunter turns to the stone it hops to during the crouch (`_turn_toward`,
  0.09 s, shortest way round). After a climb it keeps facing its last hop.
- Width tried: 1.0, 1.5, 2.0, 3.0 hunter heights. 1.0 barely moved the
  frame; 3.0 made the two lines cross. Shipped 2.0 with outward-first.
- Shot: the item's named `state=3dclimb` starts at the sigil and only the top
  stone shows, so it could not change. Graded on `state=3d` (the resting
  camera the done-when names) instead.
- Grader: FAIL twice. Round 1 (1.5, inward-first): "reads as a slightly
  reshuffled cluster". Round 2 (2.0, outward-first): "two mirrored rows, a V,
  not one alternating path"; the far rungs shrink with depth. The rest camera
  looks down the route, so any sideways step foreshortens; a clearer zigzag
  needs a wider step (which crowds the beast) or a camera off the line.

## The camera swings with each hop.

2026-09-29 23:38 EDT, builder.

- The follow camera already rode the body's x/z mid-hop (air_follow_pivot), so the pan was there; what was missing was the settle. At each hop's touchdown `_hop` now fires `_hop_landed`, which (for the followed hunter only) sets `_swing_vec`: the hop's travel along the camera's right vector x `HOP_SWING_SHARE` 0.2, capped at `HOP_SWING_MAX` 0.5 units. `hop_swing(t)` is a sin bump over `HOP_SWING_TIME` 0.15 s; `_swing_off` is added to the pivot in `_apply_orbit` only, so the eased pivot is never disturbed. A snap zeroes it. Test: `_test_camera_swings_past_a_sideways_hop`.
- Harness: `touch=K,S` runs live until the K-th touchdown, then S s of game time, and shoots without snapping.
- Overshoot proof (same command, old code vs new, `state=3d beast=cinder_jackal console=climb+3 touch=1,0.075`): Frog at screen x 640 before, 588 after; at +0.25 s the new code is back at 640.
  ![[agents/frames/builder/2026-09-30-hop-swing-before.png|420]] ![[agents/frames/builder/2026-09-30-hop-swing-after.png|420]]
- Done-when strip (graded PASS): `state=3d beast=cinder_jackal` then `console=climb+1 touch=1,0.3`; Frog centred at 640 both, camera x differs.
- Grader round 1 FAIL graded the overshoot pair as the done-when strip; round 2 PASS on the strip.

- 2026-09-30 09:56 EDT, builder: **reverted on Nick's word (09:44, "no i dont like this change").** `_swing_vec`/`_swing_t`/`_swing_off`, `HOP_SWING_*`, `hop_swing`, `hop_swing_vec`, `_hop_landed` and its tween callback are gone from combat_3d; `_apply_orbit` uses `_pivot` again; `_test_camera_swings_past_a_sideways_hop` removed. The harness `touch=K,S` stays (it is how the revert was shot).
- Proof, `state=3d beast=cinder_jackal "console=climb 3" touch=1,0.075`: Frog at screen x 588 with the old code, 640 now. Frames are two-panel strips: rest | 0.075 s after the first landing.
  ![[agents/frames/builder/2026-09-30-hop-swing-revert-before.png|420]] ![[agents/frames/builder/2026-09-30-hop-swing-revert-after.png|420]]
- Grader round 1 FAIL (single frames did not bracket a hop); round 2 PASS on the strips.

## Hits stop time.

Builder, 2026-09-30 00:21 EDT.

What changed (views/combat_3d.gd):
- `_strike(weak, dmg)` now takes the damage. Shake is `hit_shake(dmg, weak)`: 0.2 + 0.05 per point, clamped 0.25..1.0; the weak point keeps its old floor of 0.85.
- Hit-stop: `_hit_stop(slowmo)` sets `Engine.time_scale` to 0.01 for 0.08 real seconds (`HIT_STOP`), then for a weak point 0.25 for 0.15 s (`HIT_SLOWMO`). Each restore only undoes its own scale, so the death's slow motion (0.3) and harness freezes (0 / 0.02 / 0.1) are never clobbered. The timers are not process_always, so a pause holds the stop.
- Embers: a lazily built CPUParticles3D (`_ember_burst`) at `impact_point(box, cam)`, the beast box's face toward the camera (the weak point uses the sigil). Sized by `ember_reach(distance to camera)`, so the burst covers the same slice of frame near or far. `disable_fog` (the arena fog ate them at 85 m), `preprocess` 0.09 (so they are already flying on the frozen frame). `scale_amount` did not reach the screen on billboarded quads, so the quad size carries the scale.
- Shake now always throws the lens the full amplitude (`shake_offset`) and also tilts it (`shake_tilt`, 2.5 deg at full energy). A slide alone moved the far wall 2-3 px, which the grader read as no shake at all.
- The bite: `_react`'s per-hunter damage path is now `_hunter_struck(i, dmg)`: popup, flinch, `hit_shake`, `_hit_stop(false)`.

Harness: `state=3dstrike beat=impact` (unattended) shoots six frames on a 3x2 sheet: rest; a 6-damage blow landing (clock x0.01) and +0.10 s (clock x1.00, cam 0.19 m 1.1 deg); a 14-damage weak point landing and +0.10 s (clock x0.25, cam 0.36 m 2.1 deg); the 7 bite +0.10 s (cam 0.21 m 1.2 deg). Seeded (seed 2) so the shake's dice are the same every run. In play it falls through to the ordinary beat loop.

Grader: three rounds. Round 1 FAIL: offset invisible (positional only) -> added tilt. Round 2 FAIL: slow motion and damage scaling not shown -> six-panel sheet with clock and damage in the labels. Round 3 FAIL: "panel 3's framing matches panel 1 within about 2-3 px"; the bite has no landing frame. In the full-size run the other hunter moves 30 px at +0.10 s and 33 px on the bite, but at a third of the size it reads small.

Tests: `_test_hits_stop_time` pins hit_shake, shake_offset, shake_tilt, impact_point, ember_reach and the distinct clock scales. ALL TESTS PASSED. Playtest (30 steps) shows `beast-behind-stone` failing 7 times; it was 6 on main before this change, so it is not from this change.


Builder, 2026-09-30 10:11 EDT — removed on Nick's word (09:44, "no remove this for now").

- Reverse of 991b33c's combat code and test: `_strike(weak)` is back to its old fixed kick (0.3, weak point 0.85, positional only, no tilt); no `_hit_stop`, no clock freeze or weak-point slow motion, no impact ember burst, no `_hunter_struck` (the bite is popup + flinch, no shake, as before). `hit_shake`, `shake_offset`, `shake_tilt`, `impact_point`, `ember_reach`, `HIT_*` consts, `_cam_basis_home` and `_test_hits_stop_time` are gone. The arena's ambient embers (`_add_embers`) are a different item and untouched.
- Harness `state=3dstrike beat=impact` kept, rewritten to shoot the same six moments with the plain strike; tilt is now measured against the rest frame's aim.
- After: clock x1.00 in every panel; cam offset 0.02 m (blow +0.10 s), 0.18 m (weak point +0.10 s), 0.00 m (bite); 0.0° tilt throughout. Before: x0.01 / x0.25 clocks, 0.19 / 0.36 / 0.21 m and 1-2° tilt, ember bursts.
- Grader: FAIL, "Camera shake removed: NOT MET" on the 0.18 m weak-point offset. That shake predates this item (the original strike kick), so it stays until Nick says otherwise; hence the Ask.
- ALL TESTS PASSED.

## The jackal threatens between turns.

Built 2026-09-30 00:48 EDT.

- Threat = hunters ended / (hunters - 1), clamped 0..1: 0 at rest, 1 once only the last hunter acts (`beast_threat`). Eased in `_step_threat` (rate 4).
- Head: new `HeadTrack` SkeletonModifier3D on the jackal rig turns `neck` (40 %) and `head` (60 %) about world up after the idle clip. Target is the only hunter still acting (`threat_focus`), or the bitten hunter during the beast's turn. True angle to the Goblin is 0.061 rad (he stands nearly dead ahead), so `HEAD_TURN_GAIN` 8 overshoots it to ~0.49 rad, clamped at 0.7.
- Cracks: `glow_gain` x (1 + 3.0 x threat) plus a new `heat` uniform in toon.gdshader (a wider red-orange mask, 0 by default so every other model is unchanged) at 2.5 x threat. Before `heat`, only the ears brightened: the chest and leg markings are outside the strict glow mask.
- Badge: scale 1 + 0.18 x threat, with a 1.4 Hz heartbeat of 0.07 x threat; the cracks beat on the same clock (3x the amplitude). The wind-up tween still owns the badge during the beast's turn.
- Growl: new `growl` Sfx event plus `audio/growl.ogg` (synthesised low saw + filtered noise, 0.7 s), played once when threat reaches 1 in the same encounter (`growl_now`).
- Grader rounds: 1 FAIL (head, cracks unseen; only badge), 2 FAIL (cracks and badge MET, head unreadable: a ~20 px silhouette behind stones), 3 FAIL after trying a whole-body turn (0.5 x head yaw): it turned the glowing chest behind a stone, so it was reverted. The shipped frame is the round-2 state.

Reverted 2026-09-30 10:25 EDT (Nick, 09:44: "no revert this as the game is co op and we cannot make this work in multiplayer").

- Removed: `beast_threat`, `threat_focus`, `head_yaw_to`, `threat_pulse`, `intent_badge_scale`, `growl_now`, `_update_threat`, `_step_threat`, the THREAT_* and HEAD_TURN_* constants, `HeadTrack` (views/head_track.gd), the toon `heat` uniform, the `growl` Sfx event and audio/growl.ogg, and their test.
- Kept for low health (built on top of this): the beast glow-material list, now collected by `_rig_glow` (glow_gain and ember_gain only) and multiplied by `beast_low_glow` in `_step_low_health`. Its test's "breathes faster than THREAT_BEAT_HZ" check became "faster than 1 Hz".
- Frames: before ![[agents/frames/builder/2026-09-30-threat-revert-before.png|420]] after ![[agents/frames/builder/2026-09-30-threat-revert-after.png|420]]. After one End Turn the badge is back to its rest size and the cracks are no hotter.
- Grader: VERDICT: PASS (head-turn evidence weak at this distance; growl is audio).

## Low health shows on screen.

2026-09-30 00:56 EDT, builder.

- Console: `hp 10` sets the active hunter's HP (clamped 1..max), `hp beast 15` the beast's. Both push state.
- Rule: `Combat3D.is_low_hp(hp, max)` is under 30 % (LOW_HP_FRAC) and alive. Read from the shared snapshot each refresh, for the hunter you are watching (`_me()`) and for the beast.
- Hunter: a full-screen ColorRect with a canvas shader, first child of the HUD root so it tints the world and never the cards. Edge alpha `vignette_alpha` = 0.8 x (0.55 + 0.45 x heartbeat), a lub-dub at 1.2 beats/s; it never fades out between beats.
- Beast: a continuous CPUParticles3D stream (160 soft round sparks, 2 s life, additive) filling the beast's box and rising; the crack glow is multiplied by `beast_low_glow` = 1 + 1.5 hotter + a 0.35 breath at 2.4 Hz (faster than the 1.4 Hz threat beat).
- First pass was too faint (vignette 0.55, square 3.5 % sparks); raised to 0.8 and 7 % round sparks.
- Frames: before (console had no `hp`, Frog 42/42), after Frog 10/42 with the red edge, after jackal 15/70 with embers: ![[agents/frames/builder/2026-09-30-low-health-beast-after.png|420]]
- Grader: VERDICT: PASS (heartbeat and breath rate not judgeable from stills).
- Tests: `_test_low_health_shows_on_screen`.

2026-09-30 10:39 EDT, builder. Nick (09:44): "no remove the heartbeat".

- Read as: the red heartbeat edge is rejected outright, as with his other "no, remove" answers on this item list. Removed the hunter vignette (the full-screen ColorRect, its shader, `heartbeat`, `vignette_alpha`, `LOW_HEART_HZ`, `LOW_VIGNETTE`, `_low_me*`). Kept: the jackal's low-HP ember stream and hotter, faster crack breath, and the `hp` console command.
- Frames: Frog at 10/42, before (red wash on every edge) and after (none): ![[agents/frames/builder/2026-09-30-heartbeat-remove-before.png|420]] ![[agents/frames/builder/2026-09-30-heartbeat-remove-after.png|420]]
- Grader: VERDICT: FAIL. It read "remove the heartbeat" as "remove the pulse, keep a steady red edge". Not reworked: a steady edge contradicts the reading above and would leave the frame almost unchanged. Shipped as 👀 so Nick decides; a steady tint is a one-constant change if he wants it.
- Tests: `_test_low_health_shows_on_screen` now asserts no vignette rule or constant remains.

## One HUD style: carved obsidian.

2026-09-30 01:13 EDT, builder.

- One material, `Combat3D.obsidian_style(rim, rim_w, radius)`: fill (0.05, 0.043, 0.05, 0.92), ember rim (0.96, 0.47, 0.16), `border_blend` on, bottom lip rim_w+2, shadow 6 px offset 3 px.
- StyleBoxFlat has one border colour, so no bevel. `ui/obsidian_box.gd` wraps it (`Combat3D.carved`) and draws a glassy sheen over the top 46 % of the fill, a lit 1 px line inside the top edge and a 2 px shade inside the bottom lip.
- Applied to: TopBar (in `_apply_obsidian_hud`, called from `_ready`), party cards, intent badge, energy orb, End Turn and Switch (normal/hover/pressed/disabled/focus).
- Signalling rims kept: the hunter the beast is aiming at stays red, an empty energy orb stays grey, a non-hostile intent stays green. The hunters' identity colours moved from their card rims to their names.
- Display font: KenneyFutureNarrow as a FontVariation with the body font as fallback (it has no †, ⇥, ⛨). Used on the beast name, hunter names, intent badge and both buttons.
- Grader: FAIL (badge unchanged, no bevel) → added the bevel wrapper and an ember badge rim; FAIL (badge still looked the same) → badge label into the display font; PASS.
- Test: `_test_obsidian_hud_style_is_one_material`.

## The beast's health bar reacts.

2026-09-30 01:25 EDT. Built as an overlay (`game/ui/beast_bar.gd`) drawn over the
existing `HpBar` ProgressBar, so the bar's size, place and obsidian style are
unchanged.

- **Notches.** "Weak-point threshold" in the data is sigil damage per visit
  before the beast bucks you off (16 on the jackal), not an HP line. Read it as:
  a notch every 16 HP down from full (54, 38, 22, 6), i.e. one full sigil
  visit's worth each. Plus a taller ember notch at `hurt_pct` (28 HP), where
  the jackal switches to its hurt pattern. `hurt_pct` is now forwarded in the
  boss snapshot (`game_host.gd`).
- **Ghost.** A drop leaves a pale cream segment from the old value to the new;
  it holds 0.4 s then eases down over 0.35 s. A second blow inside the ghost
  keeps the ghost's current top. A heal or new fight clears it.
- **Crack.** A drop that crosses a notch flashes a white jagged crack at the
  highest crossed notch, fading over 0.5 s.
- **Harness.** `beat=loop` (unattended) now lands a real 18-damage blow via the
  console's `hp beast`, so 70 to 52 crosses the 54 notch; the bar's clock is
  frozen and set by hand per frame (0.1 s, 0.6 s, 2.0 s) so slow software
  frames cannot drain the ghost before the shutter.
- **Tests.** `_test_beast_bar_reacts`: notch placement, major notch, crossing,
  ghost hold/drain curve, bar state on blow and heal.
- **Grader:** VERDICT: PASS.

## Cards fan and glow.

2026-09-30 01:40 EDT. The fan, the per-card tilt, the lift, the straighten and
the 1.34 grow were already in `_layout_hand`; the before frame showed them. What
was missing was the glow and the pulse.

- **Rim.** `foil.gdshader` gained a rim mode (`rim` > 0): a gaussian on the
  distance to the card's true edge, ember-gold with 18 % of the foil's
  travelling rainbow, bright on the frame line, gone ~5 px inside (name and
  cost stay clean) and haloing ~10 px outward. First try was 35 % rainbow and
  read garish against the ember HUD.
- **Where.** `CardView.set_raised(on)` builds the rim on first use (a ColorRect
  10 px bigger than the card on every side, mouse-ignored) and only hides it
  afterwards. `_layout_hand` calls it with the same `card_is_raised` answer
  that lifts the card, so a timed card on touch glows too, not only hover.
- **Pulse.** The cost gem breathes 1.00 to 1.10 at 0.9 Hz (`pip_pulse`) while
  the card is not disabled; `_end_timing` no longer stops the tick on a card
  that still pulses.
- **Tests.** `_test_cards_fan_raised_card_wears_a_rim_that_hides_when_lowered`,
  `_test_cards_fan_cost_pip_pulse_stays_in_a_gentle_range`.
- **Grader:** VERDICT: PASS (it noted the pulse cannot show in a still).

## The intent badge reads like a warning.

2026-09-30 01:59 EDT, builder.

- **Before.** A 17 pt label with a 1 px ember rim. At the climb camera it sat on
  the jackal's ear tips: the crown was the projection of the box's top-centre
  point, and at a low camera the box's near top edge projects well above that.
- **Did.** Label 24 pt; 3 px red rim (`INTENT_RIM`) on every move; the leading
  move glyph (†, ◆, ▲, ✚, ✦, ▼, ☠) drawn at 34 pt, red on hostile moves and
  gold on calm ones (`intent_badge_bbcode`). The crown is now the top-centre of
  the beast's whole projected box (`intent_crown_screen`), so the badge clears
  the ears at every camera. `intent_tag_pos` takes the other hunters' rects too
  (`other_hunters`), two passes, so the badge is never over either hunter.
- **Round 1 grader FAIL:** only Attack in frame, icon-per-type unseen. Added a
  Defend frame (`state=3dclimb endturn=3`). **Round 2 FAIL:** Defend had a green
  rim, item says red-rimmed; every move now gets the red rim. **Round 3 PASS.**
- **Frames.** 2x2 strip: rest, climb, rest after `endturn=1` (Goblin's turn),
  climb after `endturn=3` (Defend 5).
- **Tests.** `_test_intent_badge_clears_the_other_hunter_too`,
  `_test_intent_badge_icon_is_big_and_red_on_hostile_moves`.

## The climb gauge stands beside the beast.

2026-09-30 02:10 EDT, builder.

- Before: a 3 px brown rail in a flat brown panel, 6 px coloured dots, a gold tick for the sigil.
- Panel now uses `carved(obsidian_style(EMBER_RIM, 1, 8))`, 84 x 372 (was 62 x 330), same right-centre anchor.
- Rail: 7 px black groove with a 2 px ember seam. Ledge rungs: three stacked lines (9 px at 28 % ember, 5 px at 55 %, 2 px hot core). Plain Heights: 10 px dim ticks.
- Sigil: five ember rings out to r31 plus a hot core, so a hunter standing on it sits inside the fire (first try at r22 was hidden by the Frog's pip). Label in the HUD display font.
- Pips: r13 obsidian disc, the hunter's portrait (snapshot `portrait`) at 1.5 r, a 2.5 px ring in their slot tint; side-step on a shared rung is `gauge_dot_dx` x 1.8.
- New static `gauge_y(h, top, y_top, y_bot)` places rungs and pips; `_test_climb_gauge_y_puts_ground_at_bottom_and_sigil_at_top` pins ground, top, clamp and a zero sigil.
- Grader: PASS first round. It noted the panel is still on the screen edge, not next to the beast, and covers the Goblin's stone.

## Obsidian floor.

2026-09-30 02:29 EDT. Before: flat matte grey-brown floor (the env's `Floor` mesh under the creature shader). After: `game/assets/3d/obsidian.gdshader`, on the env `Floor` mesh and the plain `Ground` disc, only for a biome with `"floor": "obsidian"` (quarry_ember). `Combat3D.floor_style()` + `_dress_floor()` (runs after `_show_env`; restores the scene's own Ground material for every other biome). Test `_test_floor_style_obsidian_only_in_the_jackal_biome`.

- Base albedo ~(0.035, 0.03, 0.045), one hard lit/shadow step.
- Specular band: a real sun highlight never lands in frame (key light is behind the camera), and a light-driven spec gave a big blue ellipse off the Fill. Tried a world-elevation band (a red ring around the camera) and a view-anchored spot (read as a spotlight decal). Kept: reflected view ray's VIEW-space y in [0.20, 0.235], hard edges, soft ends past |x| 0.9, colour (1.0, 0.74, 0.62) x0.8.
- Cracks: world-XZ Voronoi edges, 4 m cells, width min(0.018 cell, 1.2 px) so they stay hairlines near the camera; gain 0.35 orange.
- Grader round 1 FAIL (foreground cracks were solid red bars), round 2 PASS.

## Lava rock under the hunters.

Built 2026-09-30 02:40 EDT.

- New `game/assets/3d/lava_rock.gdshader`: base (0.11, 0.095, 0.10) multiplied by
  ROCK_DETAIL, toon diffuse, no specular. Emission (1.0, 0.32, 0.06) on faces whose
  world normal points down (smoothstep -0.55..-0.95, gain 0.7) plus a fresnel edge
  (power 7, gain 1.2).
- `BIOME["quarry_ember"]["stone"] = "lava_rock"`; `Combat3D.stone_style(biome)`
  reads it. `_add_float_stone` puts the shader on the rock body and the cap when the
  current beast's biome asks for it; every other biome keeps its pale stones. The
  existing ember rim torus stays and now reads as the glowing lip.
- Test `_test_stone_style_lava_rock_only_in_the_jackal_biome`.
- First pass (under gain 2.4, edge power 3) blew the whole stone out to orange/yellow;
  grader FAIL. Tightened to the values above; the stone reads dark with orange rim and
  edges. Second grader FAIL only because the Goblin's stone is cut off at the right edge
  in `state=3dclimb` (and `state=3d`), so "under both hunters" cannot be seen. Moving
  the camera is outside this item; left for Nick.

## Lava flows around the arena.

Builder, 2026-09-30 03:04 EDT. Brief: the Session line on the queue item (plan item 13 in
[[2026-09-29-intense-fight-plan]]).

- **What landed.** `combat_3d.BIOME["quarry_ember"]["lava"] = [1.0, 2.5]`
  (arena radii); static `lava_ring(biome)` clamps it to [LAVA_MIN_R 1.0,
  LAVA_MAX_R 2.55]; `_add_lava` builds, under `_rig`:
  - a flat annulus (`lava_ring_mesh`, 96 segments) at -0.003 R, level with the
    floor's brim so the floor's own edge walls it in; `lava.gdshader`, unshaded,
    two 3-octave value-noise layers in polar coords, the body flowing round at
    `flow` 0.018 rad/s and a darker crust at half that;
  - 8 OmniLight3D at 1.2 R, 0.05 R up, range 0.6 R, energy 6, with
    `light_cull_mask = LAVA_LIT_LAYER` (bit 19); only the env's meshes join that
    layer, so the lights warm floor and wall but not the Frog (at first they
    turned it yellow);
  - a heat shimmer band (open CylinderMesh at SHIMMER_R 2.46 R > CAMERA_MAX_R,
    0.3 R tall): `heat_shimmer.gdshader` wobbles the screen texture and adds an
    orange glow that is strongest at the lava. Its height is measured off
    VERTEX.y: a CylinderMesh's side UVs do not span 0..1 with caps off, which
    is why the first two tries drew nothing.
  - obsidian floor rim heat: new `rim_*` uniforms on `obsidian.gdshader`, set by
    `_add_lava`; emission rises over LAVA_RIM_HEAT 0.8 R toward the lava and
    fades out within 0.5-1.2 rim radii of the lens, so the ground in front of
    the hunter stays dark.
- **Tests:** `lava_ring` only in quarry_ember; ring starts past 0.86 R and ends
  inside the wall; shimmer beyond CAMERA_MAX_R and inside the wall;
  `lava_ring_mesh` spans inner..outer, 6 vertices per segment.
- **Grader:** FAIL x3, each time on the same point: the floor just in front of
  the lava does not read orange. At the rest camera the far rim, 0.2-1 R behind
  the beast, is about 20 screen rows (y 318-340), so neither the omni lights
  (obsidian albedo 0.035) nor the emissive rim heat shows much there. Floor
  lights at energy 10 turned the whole foreground maroon, which goes against
  "dark ground". The wide shot (`wide`) shows the whole ring and the glow.

## Embers in the air.

Builder, 2026-09-30 03:15 EDT. Brief: the Session line on the queue item (from
[[2026-09-29-intense-fight-plan]]).

- **What landed.** `combat_3d.BIOME["quarry_ember"]["embers"] = true`; static
  `ember_field(biome)` and `seam_points(n)`; `_add_embers` (after `_add_lava`)
  builds an `EmberField` under `_rig`:
  - a rising field: CPUParticles3D, 500 soft round sparks (radial
    GradientTexture2D, quad 0.022 R), box out to LAVA_MAX_R, 7 s life,
    preprocessed so a still frame is already full, fog off;
  - SEAMS 8 seam points at SEAM_R 3.4 R, heights stepping 0.5 / 1.0 / 1.5 R.
    Each has an OmniLight3D (energy 150, range 1.4 R) and a 60-spark drip
    falling off the rock toward the arena.
- **Why the light numbers are that big.** The env's `Wall` mesh starts at
  2.6 R, but its median vertex is 4.4 R out and it stands 4.5 R tall
  (measured). Lights at the wall's "inner face" (2.5 R) lit nothing the camera
  sees. Energy 30 at 3.4 R was still invisible on the rock; 200 read clearly.
- **Light budget.** The Compatibility renderer gives a mesh 8 omni lights. The
  Wall sat on LAVA_LIT_LAYER, so the lava's 8 lights used its whole budget
  (and they never reach it: 1.2 R + 0.6 R range). `_add_embers` moves the Wall
  from LAVA_LIT_LAYER to its own SEAM_LIT_LAYER (bit 18). The seam lights
  shine only there, so the floor in front of the hunters stays dark (an
  unmasked try turned the whole floor red).
- **Tests:** embers only in quarry_ember; seam points past LAVA_MAX_R and
  CAMERA_MAX_R, above the floor, at more than one height, evenly round the
  ring.
- **Grader:** FAIL (no orange on the rock, sparks unreadable), then PASS.


## A sky with ash.

Builder, 2026-09-30 03:29 EDT. Brief: the Session line on the queue item (from
[[2026-09-29-intense-fight-plan]]).

- **What landed.** `combat_3d.BIOME["quarry_ember"]["ash_sky"] = true`; static
  `ash_sky(biome)`; `_light_for` swaps the Sky's ProceduralSkyMaterial for a
  ShaderMaterial on the new `assets/3d/ash_sky.gdshader` (keeping the plain
  one in `_plain_sky` so the next beast gets it back). The shader: the biome's
  horizon-to-top gradient spread over the lower sky; two-octave-set fbm ash
  projected on a flat ceiling, drifting at `wind`; dark ash bodies with a
  bright red rim on each cloud's lower edge (cloud here, none 0.03 lower in
  EYEDIR.y), stronger low in the sky; a glow swell for 1/4 of every 9 s on
  one side. The cubemap pass gets the gradient only. Fog untouched.
- **Measured.** The rest camera sees sky only between elevation ~0.18 and
  ~0.4 (0 = horizon, 1 = zenith), in a notch ~250x100 px between the cliffs,
  mostly under the boss bar and the intent badge. "Low" is measured over
  that band.
- **Grader.** Three rounds, all FAIL: round 1, clouds too low-contrast;
  round 2 (red wash, bigger cells), "a purple-to-red gradient"; round 3
  (dark bodies, red lower rims), "a magenta-to-orange wash, no cloud shapes".
  Cloud shapes do show at 1:1 in the notch, but it is too small to read as
  a cloud layer.
- **Test.** `_test_ash_sky_only_in_the_jackal_biome`.

