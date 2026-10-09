> Entries dated before 2026-10-07 are history and bind nothing; TARGET.png and `tools/builder/BRIEF.md` decide.

# Queue notes

The history behind each line of [[BUILDER-QUEUE]]: the original brief, what
the builder measured and tried, what the session decided. The builder appends
under the matching heading. Nick never has to read this page.


## Frog and its rock: TARGET's size and place.

2026-10-08 15:22 EDT. Grader PASS on round 4.

- Frog drawn at `HUNTER_DRAW_SCALE` 0.72 of HUNTER_HEIGHT (climb maths untouched); marker smaller and lowered onto the head.
- Pedestal: `PEDESTAL_TOP_POLY`, a chamfered pentagon with its corner at the lens a little right of the Frog, R 1.32, depth 1.6, 1.5 hunter-heights deep so the column shows down to the cards. Navy-black front faces (probe matches TARGET within ~4/channel), warm narrow side bands, an ember strip on the back-right top edge only.
- HP bar: 102x17, 13px bar, 1px edge, no plate (TARGET ~102x13).
- Hand: HAND_REST_SCALE 0.86 -> 0.70, HAND_REST_LIFT 14 -> 36, so card tops land on TARGET's line (~545 in the square pair) with all text on screen. Lowering alone (round 3) cut the text off: grader auto-FAIL.
- Grader rounds: 1 FAIL (pedestal flat/diamond), 2 FAIL (tone judged by eye; probe disproved it), 3 FAIL (cards cropped), 4 PASS.
- Meshy: none.

## Frog's rock and the floor: TARGET's pedestal and hex tiles.

Builder 2026-10-08 03:15 EDT. Before: the Frog stood on a dark rounded lump whose top was a sliver; the floor was a faint random crack web.
- Pedestal: `_put_rest_rock` now builds `pedestal_mesh()` (new `pedestal.gdshader`): a hex prism with a flat face to the rest camera, top stretched 1.35x toward the lens (the rest eye looks down only ~8 degrees, so a regular hex showed no top). Flat vertex-colour tones: top renders (53,45,58) vs TARGET (54,44,59); near-black navy front; dim ember rim on the back edges. Mostly emission so the lava lights do not turn it maroon.
- Floor: obsidian shader gains `hex_tiles`; the jackal biome sets it, crack_px 2.8, crack_gain 0.4 (old test caps gain at 0.4).
- Test: `_test_pedestal_is_a_deep_hex_with_a_plum_top`.
- Grader: PASS first round. Remaining gaps: sides hidden behind the card fan; near seams bolder and tiles bigger than TARGET's; Goblin's rock block at right edge.
- sprite_match: 3 of 5 off (beast untouched). Meshy: 0 credits.

## Fist fire: flame tongues, not a sun disc.

2026-10-08 builder run.

- **Before:** the fire layer (cut from TARGET by `tools/beast_rig.py`) had a soft alpha ramp that kept TARGET's glow as a faint rim, and idle scaled it up to 1.1 about the elbow, sliding the ball off the fist so its round underside showed. Read as a sun disc.
- **Built (all in `tools/beast_rig.py`, assets regenerated):** crisp flame alpha; the plume leans back up-left above `FIRE_BASE` (`FIRE_LEAN` 0.32: the canvas top is already the flame's top, and a taller canvas would shrink the beast through `_fit_height`); below the base only a `FIRE_HUG` 22 px skirt hugs the fist; flame within `FIRE_CORE` 24 px of the fist burns yellow-white, tongue edges deep orange. The fire is now an 8-frame strip (`fire_frames`: a wave climbs the flame once a loop, tips sway and stretch up, the base stays put), stepped by a discrete `Art:frame` track at 10 fps in `idle`; the idle scale flicker is gone (attack/death keep theirs). `anim_resource` learned discrete `Art:` tracks.
- sprite_match: `3 of 5 off` both before and after (crack cover, detail, outline): unchanged by this item; the body is TARGET's own pixels.
- Grader: round 1 FAIL (NOT CLOSER: still a ball), round 2 FAIL (CLOSER; flicker unprovable from a still), round 3 PASS with the idle grid. Meshy: 0 credits. Tests: ALL TESTS PASSED.
- Idle grid: ![[agents/frames/builder/2026-10-08-fistfire-idle.png|420]]

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


2026-09-30 11:02 EDT, builder. Nick (09:44): "no. we need to redesign the display
of information. reference how slay the spire ii displays information". The
obsidian material above is gone.

- **Health on the creature.** `ui/unit_bar.gd`: a red bar, number inside
  ("42/42", no "HP"), a blue shield with the Block number on its left end and
  the fill turning blue while Block stands. One under each hunter's feet on
  screen (`unit_bar_pos`, hidden while the hunter is off screen), and the same
  bar in the party rows.
- **The beast's plate.** The old top banner (TopBar) is now one frameless line,
  name then red bar with "70/70" inside, pinned under the beast's feet
  (`beast_plate_pos`); a hunter standing there wins and the plate lifts above
  their head. Round 1 had it over the head and the grader said it covered the
  ears. Notches, ghost and crack from the health-bar item still draw on it.
- **Party rows.** No frame: face, name, red bar, one status line (`party_card_stats`
  with `on_bar` drops HP and Block, the bar has them). Only the hunter being
  aimed at gets an edge, red.
- **Intent.** The box is gone; outlined glyph and words float over the head.
  Not moved: the next item (Nick: "remove damage badge and put it somewhere
  else") owns where it goes.
- **Energy.** Still a rounded square, lit gold from inside. Not a disc: Nick
  (2026-08-25) found a round orb read like the osu circles. No "3/3" because
  the snapshot has no max energy (proposed).
- **Piles.** `ui/pile_badge.gd`: draw, discard and burn as little card stacks
  with a count disc, under the orb. The row still opens the deck.
- **Buttons.** End Turn is the warm amber pill (150x46), Switch a slate pill.
- **Panels left** (climb gauge, log) are plain glass with a hairline edge
  (`hud_style`). `ui/obsidian_box.gd` deleted.
- **Grader:** FAIL (plate on the ears, piles as text, orb square, intent boxed)
  → plate under feet, pile stacks; FAIL (intent still a box) → frameless intent;
  VERDICT: PASS.
- **Test:** `_test_hud_reads_like_slay_the_spire`.

2026-09-30 12:13 EDT, builder, on Nick's 11:44 answer.

- Beast plate (`TopBar`) pinned top-left at `beast_plate_hud_pos()` (16,12) behind `BEAST_PLATE_ON_HUD`, on a `hud_style` glass panel. The under-the-feet rule `beast_plate_pos` stays for its test.
- Party panel hidden (`PARTY_PANEL_SHOWN = false`). Lost with it: the red "aimed at" edge and the Height line (proposed at the bottom of the queue).
- Intent: no "Next:", icon 34 -> 18 px, text 15 px, 1 px rim, `reset_size()` so the chip fits its words; `intent_hud_pos(sz, plate)` puts it 10 px right of the plate, centred on it.
- Idle bob: the hunters' `sin()` sway is gone (`hunter_idle_y`); a stone with a hunter on it no longer drifts, so feet stay on it.
- Harness: `idleat=0,0.4,...` shoots a grid of the settled rest frame over real time and prints each hunter's y (all 0.0000 over 1.2 s, both slots). The Frog-active grid is `2026-09-30-hud-trim-after-frog.png`.
- Grader: FAIL (bob not provable in one still; bare plate) -> idleat grid + glass plate; FAIL (Goblin not in frame) -> slot=1 grid; PASS.
- Test: `_test_intent_badge_sits_in_a_fixed_hud_slot` rewritten for the new layout.

2026-09-30 17:12 EDT, builder, on Nick's 16:59 answer ("game crashes a second after opening").

- Not a crash: the window quit. `Test:` carries `idleat=0,0.4,0.8,1.2`, and `_shoot_idle` (like `_shoot_death` and the enemyat path) ends in `_save_and_quit()` even in `play`, so the game saved `game/shot.png` and quit 1.4 s after the fight settled. The sky item's `idleat=0,3,6` quit at about 6 s: the same bug is Nick's "crashes after a few seconds" there.
- Fix at the root: `_save_and_quit()` returns early with "PLAY READY" when `quits_after_shot(args)` is false (`play` in the args). That covers every shot path at once. Same rule as `arms_failsafe` (2026-09-28).
- Proof: Xvfb framebuffer dumped at +2/+4/+6/+8 s after the last idleat frame, as a 2x2 grid. Before: exited, all black. After: alive, fight on screen in all four, hunter y 0.0000 throughout.
- Grader: FAIL (one still cannot show it stays open or that the hunters hold still) -> 2x2 grid over 8 s; VERDICT: PASS.
- Test: `_test_play_mode_never_arms_the_shot_failsafe` gains `quits_after_shot` checks.

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

2026-09-30 11:24 EDT. **Nick: "remove this".** Reverted what this item built: the ember-gold rim
on the lifted card (`CardView.set_raised`, `foil.gdshader`'s rim mode) and the
cost-gem pulse (`pip_pulse`, already invisible since Remove cost). The fan,
per-card tilt, lift, straighten and 1.34 grow predate the item (backlog #86 and
the Slay the Spire hand) and stay: the lift is what puts the timing strip on
screen on touch and what reveals the rules text under the deep tuck.

- **Grader:** VERDICT: FAIL. It read "remove this" as the whole item, so it
  wanted the arc, tilt and lift gone too. Not done: removing the lift breaks
  timed cards on touch. Its own FIX said to confirm with Nick first, so the
  Ask does that.
- **Test:** `_test_cards_fan_raised_card_has_no_glow`; the two rim/pulse tests went
  with the code.

## The intent badge reads like a warning.

2026-09-30 11:45 EDT, builder (Nick 09:44: "remove damage badge and put it somewhere else in the hud").

- **Before.** The badge floated in world space over the jackal's head (`_position_intent_tag` tracking the crown via `intent_tag_pos`).
- **Did.** `_position_intent_tag` now pins it to a fixed HUD slot, `intent_hud_pos`: top centre, y 12, between the party panel and Log/Menu. It wears the glass `hud_style` panel with a 2 px red edge on hostile moves (hairline edge on calm ones) and reads "Next: † Attack 7". `INTENT_ON_HUD` gates the old crown path; `intent_tag_pos` and its ten tests are left in place until Nick says the move is for good.
- **Frames.** 2x2 strips, before and after: rest, climb, rest after `endturn=1` (Goblin's turn), climb after `endturn=3` (Defend 5).
- **Test.** `_test_intent_badge_sits_in_a_fixed_hud_slot`.
- **Grader.** Round 1 FAIL: one frame only, the Goblin and a non-attack icon unseen. Round 2 on the strips: PASS.

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

2026-09-30 12:24 EDT, band removed (Nick, 09:44: "remove the band"). Deleted the reflected-view band (uniforms `band_*` and its EMISSION term) from `obsidian.gdshader`; base, cracks and rim heat unchanged. Floor test now also checks the shader has no `band_strength` uniform. Grader PASS. Frames: `2026-09-30-floor-band-before/after.png`.

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

Builder, 2026-09-30 12:43 EDT. Brief: Nick 09:44, "glow a little too strong and
should not be rising on the lava rock everyone is standing on. only from the
lava surrounding them."

- **Root cause.** The rising field emitted from a box LAVA_MAX_R wide, so it
  covered the whole floor, the hunters' rock included.
- **What changed.** Static `ember_band(biome)` = the biome's `lava_ring` (1.0 to
  2.5 R; hunters stand no further out than 0.86 R), ZERO without embers. The
  rising field is now `EMISSION_SHAPE_RING` over that band. Glow down:
  `EMBER_PEAK_ALPHA` 0.75 (was 1.0), spark 0.02 R (was 0.022), 420 sparks (was
  500), seam lights `EMBER_SEAM_ENERGY` 95 (was 150). A first try at alpha 0.6 /
  0.018 R / 360 left the frame nearly empty; nudged back up.
- **Frames.** Rest pair `2026-09-30-embers-lava-{before,after}.png`; wide dev pair
  (`devzoom=16 devorbit=-35`) `2026-09-30-embers-lava-wide-{before,after}.png`.
- **Test.** `_test_embers_rise_off_the_lava_not_the_hunters_rock`.
- **Grader.** FAIL on the rest pair (glow MET; origin "not visible in this shot",
  asked for a wider view), FAIL on the wide pair (glow MET; origin still
  unjudgeable, and no hunter in the dev frame). Stopped there: no harness view
  shows the rock and the ring together, so a third round would fail the same way.
  Final: `VERDICT: FAIL`.

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

- **2026-09-30 12:55 EDT, builder: "clouds need to move" (Nick, 09:44).** The
  shader already scrolled by `TIME * wind`, but `wind` was 0.018 noise cells
  a second: one cell per ~55 s, so three rest frames 3 s apart showed the
  same cloud shapes (the only change between them was the glow pulse). Wind
  is now `BIOME["quarry_ember"]["ash_wind"] = Vector2(0.3, 0.1)`, read by the
  static `ash_wind(biome)` and set on the ShaderMaterial in `_light_for`;
  the shader default matches. A cell now crosses in ~3 s; the second fbm
  octave still runs the other way at 0.6x, so the ash churns as it drifts
  rather than sliding as one sheet. Test: `ash_wind` length between 0.15 and
  1.0 cells/s. Proof: `idleat=0,3,6` grid, sky notch cropped 4x in the
  before/after frames (full grid: `2026-09-30-sky-drift-after-grid.png`).
  Grader: FAIL on the half-size grid ("clouds sit in the same place"), PASS
  on the 4x sky strips. Glow pulse and fog untouched.

- **2026-09-30 17:25 EDT, builder: "game crashes after a few seconds" (Nick, 16:59).**
  Not a crash, and already fixed on main by the HUD item's run (17:12): in
  `play`, `idleat=0,3,6` ended in `_save_and_quit()`, so the window saved
  `shot.png` and quit about 6 s after the fight settled. `test_scenario.cmd`
  pulls main before launching, so Nick's next click gets the fix. No code
  change this run; proof only. Same Xvfb play run, sampled at +3/+9/+15/+20 s
  after the fight is up: pre-fix `screenshot.gd` (3851fde^) is open at 3 s and
  gone by 9 s (log ends `SHOT SAVED`); main is open at all four (log ends
  `PLAY READY`), no script or shader errors, clouds visibly moved between
  tiles. Grader: VERDICT: PASS (it could not see the glow pulse or the
  other-biome rule in this grid; both unchanged since 03:29).

## Remove cost.

2026-09-30 11:10 EDT, builder. Nick (10:59): "remove cost". Read as the energy
cost printed on each card, the green gem top-left. Before frame: gems 1, 2, 1,
0, 0 on the five hand cards.

- `CardView.SHOW_COST := false` and static `CardView.shows_cost(data)` gate
  every place a face draws cost: framed card gem, borderless card gem, rail row
  number. No gem means no gem pulse (`_pulses()` is false).
- The rule is untouched: cards still cost energy (`Combat.can_play`), the
  energy orb still shows 3. Balance is Nick's, so the Ask is whether energy
  goes too.
- Not touched: the name ribbon's left inset that cleared the gem.
- Grader: VERDICT: PASS.
- Test: `_test_remove_cost_card_faces_draw_no_cost`.

2026-09-30 11:57 EDT, builder. Nick (11:44): "no we still need cost gems. a
redesign of the card borders in need." Before frame: no gems, the thick green
lofted 9-slice (`frame_frog.png`) and a light steel name ribbon.

- `SHOW_COST := true`: the gem is back on framed, borderless and rail cards.
- New border `ui/card_border.gdshader`, drawn per pixel in the card's own rect
  (no 9-slice smear): outer brass hairline, obsidian face with an engraved
  groove and top-left bevel light, a 2 px brass fillet, a 2.5 px line in the
  hunter's colour (frames.py's hues, `CardView.BORDER_HUES`), a soft inner
  shadow on the art, brass diamond studs at the four corners and the foot.
  Band 9 px (`BORDER_BAND`), radius 12.
- Name ribbon darkened to match (`BANNER_TINT` via self_modulate), name cream.
- First pass (band 8, no outer hairline) melted into the dark floor at hand
  size; second pass added the hairline, widened the brass and hue lines.
- Not touched: the deck list and the rail form still use the baked `FRAMES`.
  Only in cloud: Blender is not installed, so the shader route, not frames.py.
- Grader: VERDICT: PASS.
- Test: `_test_cost_gems_back_on_a_redesigned_border`.

## Scene pass 1 toward picture A: big lit jackal, readable floor.

2026-10-04 builder run.

- **Before:** hunters stood at 5.2x the jackal's front edge (z=85); the jackal
  was ~150 px tall, a black shape on the horizon; the obsidian floor was near-black.
- **Changes:**
  - `GROUND_STANDOFF` 4.2 -> 1.75 (shared constant, every beast). New static
    `rest_beast_share()` measures the rule: the jackal is now ~0.46 of frame height at
    its front edge (ears at y≈5, paws on the lava line). Tried 1.0 and 1.5 (head cut off)
    and 2.0 (~0.41, the round-1 frame).
  - `toon.gdshader` gains `body_floor` (default 0, a no-op): `ALBEDO = max(base, body_floor)`,
    applied after the glow mask so lifting the body never makes it "hot". A plain
    multiply (`tint`/`lift`) was tried first: it made the whole jackal glow yellow and
    left pure black untouched.
  - `SURFACE_FINISH["cinder_jackal"]`: body_floor (0.19, 0.105, 0.075), shadow_color
    (0.50, 0.46, 0.56), half_level 0.72, outline_color (1.0, 0.72, 0.30), outline_width
    0.006. `toon_material` routes `outline_*` keys to the outline pass.
  - `obsidian.gdshader` gains `tone`, an emissive slate floor colour; quarry_ember sets
    `floor_tone` (0.17, 0.17, 0.19). Lightening `base_color` was tried first: the
    lava omni lights multiply albedo, so the floor went orange (0.20) or red (0.075).
- **Grader:** round 1 FAIL (jackal narrow, faces unlit): brighter body shading and a
  closer standoff. Round 2 FAIL: "the head is a featureless black shape". The STONE dump
  puts STONE2 at screen (731, 81), right on the face: it is a lava-rock climb stone in
  front of the head, not the head. Moving the stone route is layout work outside this
  item, so it is shipped 👀 for Nick to decide.
- **Tests:** `_test_scene_pass1_picture_a`. ALL TESTS PASSED.

## Cards and HUD in the style of picture B.

Run 2026-10-04 16:13 EDT. Frames: `2026-10-04-card-hud-before.png`, `-after.png` (`state=3d beast=cinder_jackal`).

- Card border shader is now gold instead of obsidian: dark outer hairline, gold bevels, an engraved groove with a run of beads, dark fillet, the hunter's colour line kept. `BORDER_BAND` 9 -> 13 px; corner and foot studs scale with the band.
- Playable cards get a gold halo (ground panel shadow, 16 px, `CardView.playable_glow`); unplayable cards none.
- New `ui/plate_frame.gdshader` + `Combat3D.add_plate_frame()`: a framed ring laid over a Control (re-pinned after a Container sorts). Gold on the energy counter (dulls at 0 Energy) and End Turn; stone slab (grain, drawn behind the host) under the beast's name and bar.
- Grader round 1 FAIL: frames too thin, plate not stone. Thickened frames, stronger halo, stone slab. Round 2 FAIL: only the card art (pictograms/3D render not repainted) and the plate's name tab. No 2D painting tool is in reach here and Meshy regeneration is off-limits, so the art repaint is left for Nick.
- Final: VERDICT: FAIL (closer than before; card art not repainted).

## Scene pass 2 toward picture A: grey stone steps, frog on a lit rock.

Builder, 2026-10-04 19:30 EDT.

- **Stones:** the jackal's biome (`quarry_ember`) now asks for `"stone": "slab"` instead of `"lava_rock"`: pale cool grey body and cap, no ember rim, depth `SLAB_DEPTH` 0.32 of the radius at every rung (was 2.0 near, 0.9 at top). Reverting is one BIOME entry; the lava rock shader is untouched.
- **Frog's rock:** new biome flag `"rest_rock": true`. `rest_rock_lift()` returns `REST_ROCK_HEIGHT` (0.55 hunter heights); `rest_pos_for()` takes it as a lift, so a waiting hunter stands on top of a dark hex rock (`_put_rest_rock`, one per slot, built in `_place_hunters` where the rest spot is decided). It is not a float stone: it doesn't bob or spin. First tried building it in `_build_float_stones`; there `ground_standoff_for` gave z=10.3 while `_place_hunters` gave 45.1 (the beast box differs by then), so the rock was off-screen. Building it at placement fixed that.
- **Outlines:** jackal `outline_width` 0.006 -> 0.018, colour (1.0, 0.84, 0.50). The Frog gets a SURFACE_FINISH entry with only the line (0.013, same colour); its body keeps the toon defaults.
- **Tests:** stone-style test now pins "slab", the flat depth, the rest lift (jackal only), rest_pos_for's lift, the thick jackal line and the Frog's line; the matte test now checks the Frog's body keeps default specular and uses goblin_mech for "no entry".
- **Grader:** FAIL twice. Round 1: stones, face, Frog line and jackal line not met. Round 2 (thicker lines): lines and rock met; still NOT MET: stones ring the head instead of climbing one line to the chest, a slab over the muzzle, no contact shadow under the Frog.
- **Why I stopped there:** the stone positions are the climb route. The top stone is the sigil hold, and the zigzag and one line per hunter are Nick's own rulings (#14, 2026-09-25, 2026-09-29). Ending the line at the chest moves where the hunters land, so it is his call. That is the Ask; it matches the proposed item "Clear the climb stones off the jackal's face".


## Swap in the new upright jackal model.

2026-10-04 19:46 EDT. Before: old quadruped `_ai` jackal, small and pale-outlined. Picture A: upright rock brute, dark with orange cracks.

- `AI_ART["cinder_jackal"]` is `"_v2"`; `cinder_jackal_ai.glb` stays on disk (and in its death-clip test).
- `cinder_jackal_v2.glb` is a bare Meshy mesh: no nodes named, no rig, no markers, feet at y -0.95. No Blender in the cloud, and `ai_beast.py`'s four-foot gate refuses a biped anyway, so the markers live in a Godot wrapper, `cast/cinder_jackal_v2.tscn`: the glb lifted 0.9521 so the feet sit at 0, plus climb_0..5 and ledge_0/2/3/4 at the old route's height fractions (0, .32, .45, .575, .69, .76 of 1.90) up the camera-right side, z 0.25-0.3 (front is +Z). `beast_variant_path()` prefers `<id><variant>.tscn` over `.glb`. The stones and holds are derived from those plus the hull, as for every beast.
- Root cause of "camera at its knees": `ground_standoff_for` scaled only off the front edge (depth); the v2 is ~0.32 deep against the old jackal's 2.5. Added `GROUND_GAP_PER_HEIGHT` (1.5 beast-heights, min gap); 1.4 clipped the ears at the top edge, 1.7 left it small. Deep beasts keep GROUND_STANDOFF.
- Outline 0.018 -> 0.010: on the slimmer limbs 0.018 was a blobby pale halo. Body: the texture is reddish-brown (median sRGB 82,49,39) and the ember light painted it red all over; `tint` (0.7, 0.8, 0.85) and body_floor (0.08, 0.05, 0.045) bring it to dark rock with bright cracks.
- Grader round 1 FAIL: too small, too red, stones not a route. Round 2 (gap 1.7 -> 1.5, tint) FAIL: "fills height (y 15-335) but only ~18% of width; TARGET covers ~63%". At 1.38:1.90 a full-height figure in 16:9 cannot be 60% wide without cropping the legs below the frame: that is a layout choice, so it went to Nick.
- Final VERDICT: FAIL.



## Clean shapes: flat planes, a smooth glowing outline.

2026-10-04 20:50 EDT. Before: the jackal's hull is a pale, broken, stair-stepped band; the Frog wears a yellow halo; the rock is noisy dark red; nothing blooms. Picture A: thick smooth warm line, flat brown planes, cracks and eyes glowing into the air.

- Root cause, measured: the v2 jackal is half-faceted, 35,475 vertices on 14,822 positions, so the hull pushed along NORMAL tore open at every facet edge. `Combat3D.hull_mesh()` copies each toon mesh and writes, into TANGENT (unused by toon.gdshader, skinned with the mesh), the average normal of every vertex at the same position (`welded_normals`, cached per mesh). `outline.gdshader` pushes along TANGENT when `welded` is set. NORMAL is untouched, so the body keeps its facets.
- The welded hull at first painted pale lines over the cracks: in concave creases it pokes through the body. Fixed with `depth_push` (3 line widths back from the camera), so the line shows only past the silhouette.
- MSAA 4x for 3D in project.godot (`anti_aliasing/quality/msaa_3d=2`).
- Frog line: near-black, width 0.005 (was the jackal's warm 0.013).
- Bloom: glow on in the fight's Environment (threshold 1.0, levels 1-3, additive). It renders on gl_compatibility (checked with an extreme setting). Jackal line `outline_energy` 2.2 with colour (1.0, 0.62, 0.24); crack `glow_gain` 0.55 -> 3.0.
- Planes: toon.gdshader gained `tex_soften` (mip bias on the body colour only; the glow mask still reads the sharp texture), `facet` (face normal from screen derivatives), and `facet_shade` (a value shift per face direction). Jackal body_floor raised to (0.20, 0.11, 0.07) and shadow_color to (0.85, 0.74, 0.80), so the planes read instead of going black.
- Eyes: `eye_l`/`eye_r`/`eye_radius`/`eye_gain` in toon.gdshader, a model-space mask that boosts hot texels. The v2's bright eye texels sit at x ±0.03-0.05, y ~0.575, z ~0.22 (found by probing texels; the inner ears are higher, y 0.72-0.95). At 6x zoom they now show as two pale slants, but at 1:1 they are 2-3 px and lose to the ears.
- Grader: round 1 FAIL (planes, bloom). Round 2 FAIL (eyes only). Round 3 FAIL: outline, MSAA, Frog line, planes and crack bloom MET; eyes NOT MET at fight distance; rock still redder than A's brown.
- Final VERDICT: FAIL.

## The jackal fills the frame like picture A.

2026-10-04 21:01 EDT. Not built: the done-when cannot be met inside the item's own limits, so no code changed.

- **Before** (`2026-10-04-jackal-fills-before.png`, `state=3d beast=cinder_jackal`): the jackal spans x 600-830 of 1280 (~18% with arms), ears at y≈20, feet on the lava line at y≈335, the Frog at y 340-420 just in front of its feet. The sigil ring sits on the brow between the eyes: it is placed at climb_5 (y 1.44 of 1.90, chin) plus 1.7 hunter heights of lift, which lands at ~0.82 of the height, eye level on this model.
- **Why 45% can't fit:** the v2 body is 1.38 wide by 1.90 tall, shoulders about half its height. Shoulders across 45% of a 16:9 frame (576 px) make the whole body ~1050 px tall in a 720 px frame. With the head inside, the bottom third must leave the frame; and the Frog stands on the ground nearer the camera than the beast, so it always projects BELOW the beast's feet. Head in frame + Frog visible + whole model + 45% width cannot all hold. Scaling the beast changes nothing (angles only depend on size over distance).
- **Tried** (all reverted): `GROUND_GAP_PER_HEIGHT` 1.5 -> 1.2/1.1/1.0/0.9/0.8/0.7 with `GROUND_VIEW_PITCH` 0.08 -> 0/-0.10/-0.20/-0.25/-0.28 (and `ORBIT_PITCH_MIN` opened to -0.30). Negative pitch tilts up with the Frog pinned at y≈416, but `CAMERA_FLOOR` (0.5 + lens lift) holds the lens up from about -0.10, so more tilt buys nothing. Best with head and Frog both in frame: gap 1.1, pitch -0.10, ~21% width. Below gap ~1.2 the lava ring shows as an orange slab in the bottom-left under the energy counter.
- **Option frame** (`2026-10-04-jackal-fills-option-sunk.png`, a throwaway hack, not shipped): gap 0.55 and the jackal sunk 0.42 of its height into the floor, which is what picture A does (its waist sits on the lava line). Even then the shoulders reach ~30%: A's jackal is far broader in the chest than this model. Sinking also breaks the stone route (holds are on the legs) and needs the lava-ring fix above.
- **What would reach A:** hide the legs below a floor edge (Nick's call, the earlier "crop its legs" ask), and a broader-chested model or pose for the last ~15%.
- Grader not run: there is no after frame.

## The jackal idles and punches.

Built 2026-10-04 21:26 EDT (builder, cloud).

- `cinder_jackal_v2.tscn` now instances `cinder_jackal_v2_rigged.glb` (feet at 0, so the old 0.9521 lift is gone); the climb/ledge markers are unchanged. `cinder_jackal_v2.glb` stays on disk.
- `Combat3D.BEAST_CLIPS["cinder_jackal_v2"]` names the sources; `graft_beast_clips` copies `Idle` -> "idle" (loop) and `Punch_Combo` -> "attack" (once) onto the rigged AnimationPlayer. All three files share `Armature/Skeleton3D` track paths. Crossfade 0.3 s each way: Idle hangs the arms low, Punch_Combo starts in a high guard.
- Hit: sampled the hands through Punch_Combo. Jabs at f15 and f27, then the right haymaker reaches furthest forward (z 0.61) at f39 of 60. So `hit` = 39/60, and the bite lands at 0.4 + 2.5 x 0.65 = 2.025 s into the beast's turn.
- Root cause of a 100x jackal: the skinned mesh sits under a 0.01 Armature with centimetre bones. `_merged_aabb` and `_build_hull` used the mesh node's own transform (1.9 cm tall). New `mesh_xform` goes through the skeleton's bind instead (skeleton x bone rest x bind pose). For unskinned meshes it is the same as before.
- Idle is a look-around that twists hips and spine up to 90 degrees off camera, and the jackal read side-on. `face_front` removes the yaw from Hips/Spine02/Spine01/Spine and keeps pitch and roll. The head still glances left and right.
- Punch_Combo reads as a blow on its own. The old full body lunge (35% of the gap) pushed the fists and head off the frame, so the `lunge` share is 0.3 for this clip (`beast_lunge_scale`).
- Grader: FAIL (idle pair identical at half size; no hit frame), FAIL (no return-to-idle frame), then PASS on the grid: idle t=1/t=2 crops; mid-punch (`endturn=2 enemyat=1.95`); hit +0.3 s showing 35/42 (`enemyat=2.3`); return to idle (`enemyat=12`).
- Test: `_test_rigged_jackal_idles_and_punches`.


## Stones are one staircase of chunky blocks.

2026-10-05 01:37 ET, builder. Before: ten thin pale discs, two lines per jackal (one per hunter), zigzagging up to y 15 (head height) and pulled 6 units toward the camera, so on screen they ringed and topped the head.

What changed, all scoped to the jackal's biome (`quarry_ember`), other fights untouched:
- `route_top` 0.42 (`route_top_y`): the route's top hold sits at 0.42 of the beast's height (y 8.4 on the 20-unit jackal) instead of the sigil's y 15.2. Hunters and stones both read `_top_hold`, so they still agree. **This moves the end of the climb to the chest** (the Ask).
- `one_line` (`stone_line_shown`, `_one_line`): only the held hunter's line is drawn; the other line shows only the stone its hunter stands on. No zigzag on that line (`route_pos(..., zigzag=false)`), so the five rungs rise evenly on one straight line.
- `rest_aside_for` / `REST_ASIDE` (2.1): a waiting hunter stands inside its first stone, so from behind the Frog that block shows beside it instead of hidden by it. Side effect: the Goblin is now in frame at rest (VIS hunter1 OK; was FAIL at x 1565).
- Slabs are blocks: `SLAB_SIZE` 1.4x radius, straight-sided 6-sided body `SLAB_BLOCK_HEIGHT` (1.05, a Frog and a half) at every rung, replacing the tapered hull whose underside read as a thin wedge from the low camera.
- Screen positions after: stones at (538,323) (602,253) (634,214) (654,188) (667,174).

Grader: round 1 FAIL (upper stones thin, zigzag knot at the chest) -> fixed with fixed block height and no zigzag; round 2 VERDICT: PASS.
Tests: ALL TESTS PASSED; new `_test_stone_staircase_is_one_line_to_the_chest`.


## Cliffs and floor in picture A's flat style.

2026-10-04 21:56 EDT
- Before: cliffs were the env's painted rock texture (creature shader) lit orange by the eight seam lights; floor was obsidian with hairline cracks and a `floor_tone` of 0.17 that, being an sRGB `source_color`, rendered near black (sampled (32,12,24) vs the picture's ~(41,29,39)).
- Cliffs: new `game/assets/3d/cliff_flat.gdshader`, unshaded, face normal from screen derivatives picks one of three cool slate tones (lit / side / shade) by a fixed key direction; a warm band at the wall's foot (0.35 arena radii) stands in for the lava's glow. Applied by `_dress_wall()` when the biome names `"wall": "flat"` (quarry_ember only, `wall_style()`).
- Floor: obsidian shader gains `slab_var` (each Voronoi cell one of three flat tone steps); biome `floor_params` sets crack_cell 6, crack_px 2.2, crack_gain 0.7, slab_var 0.5; `floor_tone` 0.25/0.245/0.27. Floor now samples (58,35,45).
- Tried: tone 0.30/0.29/0.36 read violet (74,52,80); crack_px 2.6 / gain 0.9 seams too hot.
- Grader: round 1 VERDICT: PASS. It noted the stones and rest rocks keep their cobble texture (out of scope).
- Tests: ALL TESTS PASSED; new `_test_cliffs_and_floor_flat_style`.

## Overnight: keep closing the gap to picture A until 8 AM.

Brief: the standing item; one pass per run. First before frame: `frames/builder/2026-10-05-overnight-p1-before.png`.

- 2026-10-04 22:13 EDT — pass 1: the jackal's outline was missing on its top and left: skinning mangled the welded normals carried in TANGENT (hull slid sideways), and the -z depth push shrank the hull toward screen centre. Welded normals now ride in NORMAL for facet-lit bodies; depth push runs along the view ray. CLOSER (grader PASS). After: ![[agents/frames/builder/2026-10-05-overnight-p1-after.png|420]]
  - Grader's remaining gaps, biggest first: beast size (~17% of width vs ~2/3; needs Nick's call, see "The jackal fills the frame"), horizon lava band too wide and hot, stones beige drums off to the beast's left, frog's rock beige not charcoal, floor seams too loud, sky red-magenta not violet, cliffs too blue.
  - Needs new art (skipped): two upright ears, raised flaming fist, wide crouching stance.
- 2026-10-04 22:31 EDT — pass 2: the jackal's body was solid red glow because the scene grade (ACES, contrast 1.10, saturation 1.18) clamped its dim brown body floor's green and blue to zero; a near-grey floor (0.22, 0.20, 0.19) now renders A's dark brown plates with orange cracks on top. CLOSER (grader PASS). After: ![[agents/frames/builder/2026-10-05-overnight-p2-after.png|420]]
  - Grader's remaining gaps, biggest first: beast size (Nick's call), horizon lava band too wide and bright with an orange-lit floor, stones brown drums bunched at the left leg, frog's pedestal light not dark, outline still a thick halo.
- 2026-10-04 22:42 EDT — pass 3: the lava horizon was a ~50 px yellow-white band and the floor's seams glowed orange; the band was the heat-haze cylinder's added glow. A per-biome lava_glow (0.45) now scales the haze band's glow and height, the pool, its lights, the floor's rim heat and the cliffs' foot band; seam gain 0.7 -> 0.3. CLOSER (grader PASS). After: ![[agents/frames/builder/2026-10-05-overnight-p3-after.png|420]]
  - Grader's remaining gaps, biggest first: beast size (Nick's call), red-orange cloud band behind the beast and blue cliffs vs A's calm violet sky and charcoal cliffs, tan drum stones and pedestals vs pale flat slabs and a dark pedestal, floor still maroon-tinted, lava line now a little too red/dim vs A's yellow-orange.
- 2026-10-04 22:56 EDT — pass 4: the jackal's outline (0.010, energy 2.2) bloomed yellow-white and the body read as a black cut-out inside it; the line is now 0.007, energy 1.4, deeper orange, and the body floor (0.27, 0.24, 0.23) lets A's dark brown plates and orange cracks read. CLOSER (grader PASS). After: ![[agents/frames/builder/2026-10-05-overnight-p4-after.png|420]]
  - Grader's remaining gaps, biggest first: beast size (Nick's call), tan drum stones left of the beast vs flat grey slabs up the centre, tan cobbled pedestal vs dark basalt, saturated red-orange sky clouds vs calm violet, lava horizon thinner/redder than A's.
  - Needs new art (skipped): glowing eyes/inner ears at fight distance, flaming fist.
- 2026-10-04 23:11 EDT — pass 5: the jackal's body read as one orange-tan mass (~74,29,5; A's basalt ~80,38,28): the grade's saturation still stripped its blue. A cooler tint (0.66, 0.78, 0.95) and a blue-leaning floor (0.26, 0.24, 0.29) make it dark charcoal-brown, so the orange-red cracks stand out. CLOSER (grader PASS). After: ![[agents/frames/builder/2026-10-05-overnight-p5-after.png|420]]
  - Grader's remaining gaps, biggest first: beast size (Nick's call), cracks thin and sparse with no lit eyes vs A's thick glowing seams, cream/tan stones and pedestals vs cool grey slabs and a dark charcoal pedestal, pinkish-red sheen on the near floor vs dark charcoal tiles.
- 2026-10-04 23:24 EDT — pass 6: the hunters' waiting rocks were pale beige cobble (0.36 grey + rock texture under the warm key), the brightest thing in the scene; A's pedestal is a dark charcoal hex. They are now flat REST_ROCK_TONE (0.12, 0.115, 0.135), no texture. CLOSER (grader PASS). After: ![[agents/frames/builder/2026-10-05-overnight-p6-after.png|420]]
  - Grader's remaining gaps, biggest first: beast size (Nick's call), stones tan brick-textured drums in a column left of the beast vs pale grey flat slabs up the middle, orange-lit sky clouds and dense embers vs A's clean purple sky, cracks thin with no lit eyes.
- 2026-10-04 23:40 EDT — pass 7: the climb slabs rendered tan brick (~170,130,110): a neutral grey with the cobble texture under the warm key; A's are flat neutral grey (~156,149,141). They are now flat SLAB_SIDE_TONE/SLAB_TOP_TONE, cooled (0.46,0.50,0.55)/(0.58,0.62,0.68), no texture, rendering ~(137,128,125). CLOSER (grader PASS). After: ![[agents/frames/builder/2026-10-05-overnight-p7-after.png|420]]
  - Grader's remaining gaps, biggest first: beast size (Nick's call), slabs chunky blocks bunched at the beast's left hip vs thin wide slabs up the middle with tops lighter than sides, navy cliffs vs charcoal walls with lit edges and a warmer purple sky, outline thin/broken round the legs and lower torso.
  - Needs new art (skipped): glowing eyes, flaming fist.
- 2026-10-04 23:58 EDT — pass 8: the climb slabs' sides rendered near-white (~218) and an 8-sided cap, spun apart from the 6-sided block, cut dark notches round every rim, so the tops read darker than the sides. The cap is now the block's own top (six sides, same radius and spin) and SLAB_SIDE_TONE is (0.36, 0.39, 0.43): mid-grey sides (~110) under lighter tops (~190). CLOSER (grader PASS). After: ![[agents/frames/builder/2026-10-05-overnight-p8-after.png|420]]
  - Grader's remaining gaps, biggest first: the beast reads dark (thin cracks, no lit eyes, near-black plates vs A's warm lit plates and bright seams), stones thick drums in a short column at the hip vs thin slabs up to the chest, saturated orange-red cloud band and navy/near-black cliffs vs A's muted purple dusk and slate cliffs, glossy floor patches vs matte charcoal with even glowing seams.
  - Needs new art (skipped): glowing eyes, flaming fist, thin faceted slab shape.
- 2026-10-05 00:10 EDT — pass 9: the sky was a near-black navy top under orange-red rimmed ash cloud; A's is a calm violet dusk, plum (~41,20,37) into magenta (~127,53,90). Sky top/horizon are now violet (0.26, 0.12, 0.28) / (0.66, 0.26, 0.44) and the ash is sparse violet haze lit dusky pink (cover 0.48 -> 0.3, pulse 0.9 -> 0.3). CLOSER (grader PASS). After: ![[agents/frames/builder/2026-10-05-overnight-p9-after.png|420]]
  - Grader's remaining gaps, biggest first: beast size (Nick's call), stones climb up the beast's left side vs across the front of its body to the chest (thick blocks kept, per Nick's staircase item), no glowing eyes or readable muzzle.
  - Needs new art (skipped): glowing eyes, flaming fist.
- 2026-10-05 00:33 EDT — pass 10: the cliffs read navy (lit faces ~32,35,61) over most of the upper frame; A's walls are near-black charcoal with cool grey faces (~18,24,36 to ~49,49,63). cliff_flat's lit/side/shade tones are now neutral charcoal (0.23,0.235,0.26)/(0.145,0.148,0.165)/(0.075,0.075,0.085), rendering ~(28,30,41) over ~(0,2,7). CLOSER (grader PASS). After: ![[agents/frames/builder/2026-10-05-overnight-p10-after.png|420]]
  - Grader's remaining gaps, biggest first: beast size (Nick's call), thick drum stones stacked left of the beast vs thin pale slabs up the centre to the chest, small magenta sky disc vs A's wide mauve sky with cliffs only at the edges, lava band thinner than A's and not lighting the cliff bases, red-on-purple floor seams vs dark hex tiles with subtle orange seams.
  - Needs new art (skipped): flaming fist pose, readable muzzle with glowing eyes and orange inner ears.
- 2026-10-05 00:41 EDT — pass 11: the far-right floor slabs rendered pale lavender patches (~106,96,112; A's floor is even warm slate ~42,36,40): a cool floor_tone stepped up by slab_var 0.5. floor_tone (0.25,0.245,0.27) -> (0.25,0.235,0.24), slab_var 0.5 -> 0.2. CLOSER (grader PASS), but its evidence was the jackal's shading, which this pass did not touch (idle-pose variance between shots); it did not remark on the floor. After: ![[agents/frames/builder/2026-10-05-overnight-p11-after.png|420]]
  - Grader's remaining gaps, biggest first: stones thick drums up the beast's left vs thin slabs zig-zagging in front of the chest, no glowing eyes/ears on the head, busy black shard cliffs and dense embers vs calm cliffs and clean purple sky, thin hard lava line vs soft wide glow band, outline hard yellow line vs soft gold glow.
- 2026-10-05 00:55 EDT — pass 12: the floor tiles rendered maroon (~49,31,34; A's ~30,21,30 plum-charcoal) and the seams came out red, not A's orange. floor_tone (0.25,0.235,0.24) -> (0.205,0.2,0.22), rendering ~(33,19,27); crack_color (1.0,0.62,0.2) via floor_params turns the seams orange. CLOSER (grader PASS). After: ![[agents/frames/builder/2026-10-05-overnight-p12-after.png|420]]
  - Grader's remaining gaps, biggest first: beast size (Nick's call), thick pale drum stones vs thin broken slabs in front of the body (Nick's staircase item), flat dark cliffs vs cool grey rim-lit cliffs with a lava glow band behind the beast's base.
  - Needs new art (skipped): face with glowing eyes, flaming fist.
- 2026-10-05 01:10 EDT — pass 13: the cliffs rendered near-black (~26,27,40) with facets that barely separated, the top ~45% of the frame; A's walls are slate with clearly lit planes (~74,79,96 lit, ~42,44,56 shadow). cliff_flat lit/side/shade (0.23,0.235,0.26)/(0.145,0.148,0.165)/(0.075,0.075,0.085) -> (0.31,0.32,0.37)/(0.20,0.205,0.235)/(0.11,0.11,0.125), rendering ~(70,75,95) lit. A first try at (0.42,0.44,0.50) came out near-white lavender and was pulled back. CLOSER (grader PASS). After: ![[agents/frames/builder/2026-10-05-overnight-p13-after.png|420]]
  - Grader's remaining gaps, biggest first: beast size (Nick's call), beast emission (ears, eyes, cracks hotter and denser), thick pale drum stones beside the beast vs thin slabs across its front (Nick's staircase item), thin lava band vs A's warm tall glow with pools at the left edge, cliffs now ~15% too bright/blue vs A's charcoal, Frog overexposed neon lime with no dark outline.
  - Needs new art (skipped): raised flaming fist pose, eye glow if the eyes share the body material.
- 2026-10-05 01:27 EDT — pass 14: the jackal's cracks rendered dim red (~200,74,38) on a red-brown body; the body's cool tint (pass 5) also cooled the paint the glow mask reads, pushing most crack texels out of the orange window. New toon.gdshader `glow_color` (alpha = mix, default 0 = no-op): the jackal's cracks glow (1.0, 0.58, 0.16) at 0.85, and the mask reads the paint a quarter of the way back from the tint (half way lit the whole body). CLOSER (grader PASS). After: ![[agents/frames/builder/2026-10-05-overnight-p14-after.png|420]]
  - Grader's remaining gaps, biggest first: beast size (Nick's call), thick drum stones stepping up the beast's left vs thin slabs in front of the chest (Nick's staircase item), no eye/ear glow on the head, cliffs lighter/bluer and sky more magenta than A, thin red lava line vs A's wide orange glow band with pools.
  - Needs new art (skipped): flaming fist, readable face with glowing eyes.
- 2026-10-05 01:50 EDT — pass 15: the slate cliffs (pass 13) sampled median ~(59,63,84) vs A's ~(15,21,33); cliff_flat tones pulled half way back to (0.26,0.268,0.305)/(0.165,0.17,0.195)/(0.09,0.09,0.103), rendering median ~(40,42,57). NOT CLOSER (grader FAIL: it saw no change but particle noise); reverted, not pushed. 1 NOT CLOSER in a row. After: ![[agents/frames/builder/2026-10-05-overnight-p15-after.png|420]]
  - Grader's remaining gaps, biggest first: beast size (Nick's call), stones a diagonal of drums left of the beast vs thin slabs across its chest (Nick's staircase item), beast's face/eyes/flaming fist (new art).
- 2026-10-05 01:55 EDT — pass 16: the cliffs rendered lit slate blue (~106,110,136) over ~70% of the upper frame; A's walls are near-black silhouettes (~21,21,28 to ~42,42,53). cliff_flat lit/side/shade (0.31,0.32,0.37)/(0.20,0.205,0.235)/(0.11,0.11,0.125) -> (0.21,0.205,0.235)/(0.12,0.118,0.135)/(0.055,0.054,0.062): darker, less blue, lit kept well above shade so facets still separate. CLOSER (grader PASS). After: ![[agents/frames/builder/2026-10-05-overnight-p16-after.png|420]]
  - Grader's remaining gaps, biggest first: beast size (Nick's call), stones a vertical stack of unoutlined drums at the beast's left vs outlined slabs climbing diagonally to the chest (Nick's staircase item), cliffs lack lit ridges and a warm lava bounce at their base, floor seams thinner and sparser than A's hex grid, thin magenta streak at the far-left horizon (~60,300), lava band narrower than A's.
  - Needs new art (skipped): glowing eyes and inner ears, flaming fist.
- 2026-10-05 02:10 EDT — pass 17: the lava horizon was a thin red line (~#ff3010, y 305-330) with little glow above it; A's is a wide soft orange-yellow band rising behind the beast. A new per-biome haze_glow (0.85) and haze_color (1.0, 0.56, 0.14) drive only the heat haze's glow band, so it stands taller and warmer while lava_glow 0.45 still keeps the pool, the floor's rim and the cliffs' foot dim (pass 3). CLOSER (grader PASS, small margin). After: ![[agents/frames/builder/2026-10-05-overnight-p17-after.png|420]]
  - Grader's remaining gaps, biggest first: beast size (Nick's call), pale drum stones in a tight stair beside the beast vs flat slabs in front of the chest (Nick's staircase item), near-black cliffs vs lit cool blue-grey faces (pass 13 vs pass 16 flip-flopped; left alone), floor hex seams dimmer than A's.
  - Needs new art (skipped): flaming fist, face-on pose with glowing eyes.
- 2026-10-05 02:35 EDT — pass 18: dense orange embers covered the sky and cliffs (420 rising + 8x60 seam drips); A has a few faint sparks. Cut to 140 + 8x18 and peak alpha 0.75 -> 0.55. NOT CLOSER (grader FAIL: fewer embers read as particle scatter, none of the big gaps moved); reverted, not pushed. 1 NOT CLOSER in a row. After: ![[agents/frames/builder/2026-10-05-overnight-p18-after.png|420]]
  - Grader's remaining gaps, biggest first: beast size (~20% of width vs ~75%; Nick's call), thick drum stones left of the beast vs thin slabs up over the chest (Nick's staircase item), horizon ~45% vs ~53% high (camera, off-limits), Frog's pedestal low and wide vs a tall centred hex pillar.
  - Needs new art (skipped): flaming fist, glowing eyes.
- 2026-10-05 02:41 EDT — pass 19: the climb stones had no ink line and their grey sides melted into the lava haze; A's steps carry a thin dark outline. A closed dark hull (cull-front, unshaded, 0.045 Frog-heights wider) round each slab drew a crisp ~3 px charcoal line. NOT CLOSER (grader FAIL: at full frame it saw only ember scatter and 2-5 px stone shifts, not the line); reverted, not pushed. 2 NOT CLOSER in a row. After: ![[agents/frames/builder/2026-10-05-overnight-p19-after.png|420]]
  - Grader's remaining gaps, biggest first: beast size (~20% of width vs ~70%; Nick's call), stones chunky blocks off the beast's left hip vs thin slabs across its chest (Nick's staircase item), near-black cliffs and a narrow sky wedge vs readable grey-blue cliffs and a wide violet sky (passes 13/15/16 flip-flopped; left alone), floor hex seams cleaner/higher contrast, a single centred pedestal under the Frog.
  - Needs new art (skipped): glowing eyes, flaming fist.
- 2026-10-05 02:56 EDT — pass 20: the sky rendered a hot magenta wedge (~91,13,71): the grade's saturation crushed its green to ~11-31, where A's dusk keeps ~42-47. Sky top/horizon (0.26,0.12,0.28)/(0.66,0.26,0.44) -> (0.29,0.23,0.32)/(0.60,0.40,0.50), rendering ~(84,44,81) vs A's ~(87,42,87). The grader's top pick, lighter cliffs, was left alone (passes 13/15/16 flip-flopped). CLOSER (grader PASS, small, sky only). After: ![[agents/frames/builder/2026-10-05-overnight-p20-after.png|420]]
  - Grader's remaining gaps, biggest first: beast size (Nick's call), thick pale steps on the left vs thin warm slabs zig-zagging to the chest (Nick's staircase item), hard yellow outline and thin cracks vs a soft gold rim with orange crack glow, near-black cliffs, dense embers, floor too dark with a hard lava stripe and a glare streak at the left.
  - Needs new art (skipped): glowing eyes, flaming fist.
- 2026-10-05 03:07 EDT — pass 21: half the floor slabs rendered red-black (~21,6,11) beside ~(33,19,27) ones, where A's floor is one even plum-slate (~31,21,29): slab_var 0.2 stepped low slabs into the grade's crush. slab_var 0.2 -> 0.06 evened them to ~(30-33,15-19,22-27). NOT CLOSER (grader FAIL: it saw the frames as identical apart from idle-pose stone jitter); reverted, not pushed. 1 NOT CLOSER in a row. After: ![[agents/frames/builder/2026-10-05-overnight-p21-after.png|420]]
  - Grader's remaining gaps, biggest first: beast size (Nick's call), thick drum stones up the beast's left vs thin tilted slabs to the chest (Nick's staircase item), near-black cliffs vs blue-grey lit facets (passes 13/15/16 flip-flopped; left alone), hard full-width lava stripe vs a softer glow pooled behind the beast, floor seams barely visible vs a clearly cracked hex floor, Frog on a raised hex pillar.
  - Skipped: the eyes don't read because the idle pose bows the head (open question on "The jackal idles and punches"), not a material gap.
- 2026-10-05 03:34 EDT — pass 22: the grader's top fixable gap was the jackal's cracks reading as a yellow net (interior hot pixels ~242,183,82, 76% yellow) vs A's red-orange seams (~218,109,46, 30%). Not the outline (a blue test line sat on the silhouette only; depth push and a double-sided body changed nothing); glow_gain 3 -> 1.5/1.0 and a redder glow_color barely moved it; the lit crack albedo plus the scene bloom (glow_intensity 1.3, screen blend) clip it to yellow. glow_color (1.0,0.58,0.16) -> (0.55,0.16,0.03) got ~241,163,68, 61% yellow. NOT CLOSER (grader FAIL: it saw near-identical frames); also broke the test 'the jackal's cracks glow orange, not the cool tint's red'. Reverted, not pushed. 2 NOT CLOSER in a row. After: ![[agents/frames/builder/2026-10-05-overnight-p22-after.png|420]]
  - Grader's remaining gaps, biggest first: beast size (Nick's call), thick stones beside the beast vs thin slabs up to the chest (Nick's staircase item), Frog off-centre on a low plinth vs a tall centred hex pillar, weak rim and no glowing face, far wall without lava glow at its base.
- 2026-10-05 03:58 EDT — pass 23: the grader's code-fixable gaps were mostly tried (floor tone, cliffs, embers, cracks) or off-limits; the floor already samples A's ~(31,21,29). A's cliff feet glow orange at the lava (left wall ~115,31,18 at the 90th percentile) while ours stay black to the horizon, so a per-biome wall_heat (1.0) let the cliffs' warm band burn at full heat while lava_glow 0.45 kept the pool and floor dim; the band at y 280-300 went from ~(16,3,0) to ~(95,14,0). NOT CLOSER (grader FAIL: it saw only ember scatter and a 7 px stone shift); reverted, not pushed. 3 NOT CLOSER in a row: stop rule met, item marked 👀. After: ![[agents/frames/builder/2026-10-05-overnight-p23-after.png|420]]
  - Grader's remaining gaps, biggest first: beast size (~16% of width vs ~75%; Nick's call), thick near-white stones left of the beast vs thin outlined slabs in front of its chest (Nick's staircase item), black cliffs with no rim light or outline vs lit blue-grey walls, two ring markers on the beast's chest (ledge rings, gameplay info; left alone).
  - Needs new art (skipped): raised flaming fist, readable face with glowing eyes and orange inner ears.
  - Close-out: the first before frame is p1-before; the last after frame that shipped is p20-after (passes 21-23 were reverted, so the game today looks like p20-after).
  - Found: the cracks' yellow comes from the global bloom, not the jackal's material; toning it touches the lava and every glow, so it is a scene-wide pass, not a crack fix.

## Redraw the jackal to TARGET.png's pose, and light its fist.

2026-10-06 builder run (cloud).

- **Pose.** `tools/beast_sprite.py` now re-poses the concept before inking it (`repose`, spec `"repose"`): the viewer's-left arm is cut into upper arm and forearm+fist; the upper arm swings 70 degrees out about the shoulder and the forearm 150 degrees up about the elbow (nudged 30 px onto the upper arm so the elbow stays joined). The fist is raised beside the head, as in TARGET. No new illustration was needed. Lean, weight shift and head turn are NOT done.
- **Fist fire.** `flame_frames` draws 8 looping frames of a flat banded flame (deep orange, orange, yellow, cream core) into `cinder_jackal_2d_flame.png`. The scene gets a `Fire` Sprite3D (hframes 8) just behind the fist, plus an `AnimationPlayer` whose `idle` steps `Fire:frame`. The fight already plays a beast's `idle` on load, so no fight code changed. The body texture is widened to cover the flame's rect, so `_fit_height` (which reads the merged box) sizes the beast the same.
- **Outline/glow.** CREAM_W 28 to 52, INK_W 12 to 20, HALO_W 28 to 40. Crack glow is wider (sigma 5 to 16) and stronger (0.55 to 0.75).
- **Framing.** DRAWN_GAP_PER_HEIGHT 1.1 to 1.0: the ear tips now meet the top edge. At 0.75 the head left the frame entirely, because the locked camera does not tilt. A trial that sank the drawing 0.28 heights into the floor ("in the lava") moved the sigil to the chest and the stones over the fist, and gaps below 0.8 barely grew the beast. Both were reverted.
- **Not done: stones and climb camera.** The stone route (TARGET: in front of the torso, ending at the chest) and the stones missing from `3dclimb` both come from the camera and route rules. The climb shot is locked at GROUND_VIEW_PITCH with FOLLOW_DIST, per Nick 2026-09-28 ("the camera should be consistent"). At the top hold, every stone sits below the frame. Fixing that means tilting or lifting the climb camera, which goes against that rule, so it is asked, not done.
- Tests: `_test_jackal_is_a_drawing` adds checks for the flame strip, the flame up beside the head on the viewer's left, the flame staying inside the body's box, and a looping `idle` stepping `Fire:frame`. ALL TESTS PASSED.
- Grader: round 1 FAIL (CLOSER: the burning fist matches; outline thin, size, stones, climb). Round 2 FAIL (CLOSER: outline MET, fist MET; pose lean, framing size, snout/brow, stone shadows, 3dclimb stones NOT MET). Stopped after two rounds because the rest needs Nick's camera call. Final `VERDICT: FAIL`.
- Climb frame: ![[agents/frames/builder/2026-10-06-jackal-pose-3dclimb-after.png|420]]

## The jackal becomes a 2.5D sprite, like the reference.

2026-10-05 builder run.

- **Built:** `tools/beast_sprite.py` turns the concept (`design/art/targets/2026-10-04-jackal-concept.png`, a clean figure on a grey card) into `game/assets/3d/cast/cinder_jackal_2d.png`: background keyed out, the facet shading voted down to four flat browns, only the thick crack seams kept and drawn with yellow cores, a dark ink line inside the silhouette, a solid cream stroke outside it and a short warm halo. It also writes `cinder_jackal_2d.tscn`: a `Sprite3D` (billboard fixed-Y, unshaded, opaque prepass) plus `climb_0..5` / `ledge_0,2,3,4` markers. The markers are authored as pixel points on the concept image (`HOLDS` in the script): right leg, flank, chest, neck, face.
- `AI_ART["cinder_jackal"]` is now `"_2d"`. `_v2` and `_ai` stay on disk.
- `_build_hull` finds no mesh on a drawn beast, so it leaves the hull empty. `_front_of_beast` then reads the box front, which is the plane of the drawing, and `_head_x` uses the authored head x. This means the hull queries, `_front_of_beast`'s hull path and `stand_z_for`'s hull branch no longer run for the jackal. They are NOT deleted, because every other beast is still a mesh and still uses them.
- A drawn beast has no depth to keep clear, so the hunters stand closer: `DRAWN_GAP_PER_HEIGHT` is 1.1 against `GROUND_GAP_PER_HEIGHT` 1.5. All four `ground_standoff_for` callers go through `_ground_back()`. At 1.0 the ear tips touched the top of the frame.
- Climb: `state=3dclimb` puts the Frog on its top stone and the Goblin at Height 4 with the drawing behind them. ![[agents/frames/builder/2026-10-05-jackal-sprite-climb.png|420]]
- Tests: `_test_jackal_is_a_drawing` covers the sprite (billboard, unshaded, flat), the six holds (rising, on the image, ending at the face) and the drawn gap. The v2 test no longer asserts that v2 ships. ALL TESTS PASSED.
- **Grader, three rounds, all FAIL.** Round 1: thin rim, near-black fills, busy cracks, too small. Fixed with a thicker rim, mid-brown fills, bold cracks and the closer gap. Round 2: soft halo instead of an inked line, faceted fills. Fixed with a crisp cream stroke, a dark inner ink line, flatter tones and a smaller halo. Round 3: "CLOSER than the before frame... But the frame has not landed". The pose is the concept's (arms down, no flaming fist), the beast is about 25 % of the frame width against TARGET's ~65 %, the outline is too thin, and the face is too small to read. Final `VERDICT: FAIL`.
- **What is left is the drawing itself, not the pipeline.** The sprite can only be as close as its source, and the source is an arms-down turnaround. To reach TARGET it needs a new illustration in TARGET's pose (raised flaming fist, big head) on a plain background. `tools/beast_sprite.py` will ink it and re-author the holds in one run. Making the beast fill ~65 % of the width also means a wider shot or a bigger beast than the current camera allows with the ears in.

## Rebuild the stones to match the reference exactly.

**Builder, 2026-10-05 15:17 EDT.** Before: five Frog-and-a-half-tall six-sided
blocks with a lit cap, stacked tight up the jackal's left side. TARGET.png:
wide, thin, slightly irregular grey slabs seen from above, dark under-edge,
soft shadow, gaps between them.

What changed (`_add_float_stone`, slab branch only; other biomes untouched):
- `slab_outline()` / `slab_mesh()`: a 9-corner convex, jittered (0.26),
  wider-than-deep (0.62) prism; top at the stone origin so hunters still land
  on it. `SLAB_BLOCK_HEIGHT` 1.5 -> 0.4 Frog-heights. No cap, no rim.
- `slab_tilt()`: each slab leans its top toward the rest camera
  (elevation + 0.42 rad). The camera sits at Frog height, below the upper
  stones, so flat slabs showed only their undersides.
- Tops shaded per corner (+0.08 / -0.1) for soft planes; sides
  `SLAB_SIDE_TONE` darkening 0.2 to the under-edge; no specular.
  `SLAB_TOP_TONE` 0.58/0.62/0.68 -> 0.44/0.47/0.52 (rendered near-white before).
- Ink: an inverted hull 1.05x, back faces, near-black.
- Drop shadow: a billboard radial blur under each slab, alpha 0.9. It does
  not read: the floor and the jackal behind are both near-black.
- `SLAB_FAR_SCALE` 0.65: upper slabs shrink faster, so there is air between them.
- Jackal biome `route_top` 0.42 -> 0.36: the top slab (and the top hold) now
  sits at the chest ring, not the neck.

Grader: FAIL x3. Round 1: too regular, near-white, no ink, no shadow, top at
neck. Round 2: flat tops, near-black sides, no shadow. Round 3 (final):
shape and colour MET, spacing MET, chest MET; thickness (wants a grey side
about a third of the top's depth), drop shadow, and near slab vs the
Frog's plinth NOT MET. Not done here: moving the near slab out onto the
floor (route geometry and the rest-aside tests) and a zigzag (Nick asked
for one straight line on 2026-10-04).

## Research: card frames, against real TCGs.

2026-10-05, builder. Worked from `design/art/card-frame-research.md`, so nothing was re-researched. All three directions are built on the real card and switched by the harness flag `cardframe=A|B|C`. The shipping frame is unchanged until Nick picks.

**Look at:** ![[agents/frames/builder/2026-10-05-card-frames-after.png]] It shows the three strips, 1:1, from the real `state=3d` fight: Tongue Snap, Leap, Scramble and Tongue Flick in the hand. The full shots are `2026-10-05-card-frames-A.png`, `-B.png` and `-C.png`.

**What ours does instead.** It's a gold strip with a hairline of the hunter's colour. The cost orb hangs off the corner, the name ribbon overhangs both edges, and the art runs to the border with nothing to contain it. Nothing marks rarity. At 160px it reads as a widget, not a card.

**All three fix the same five things:**
- The cost sits inside the silhouette.
- The art sits in a cut window with a keyline and an inner shadow, and the frame overlaps it.
- The title plate stays inside the edge.
- The outer edge is anti-aliased in the shader, which fixes the stair-stepping on rotated cards.
- One rarity token sits in a fixed place.

**A, carved obsidian** (from Hearthstone's socketed stats and Runeterra's restraint):
- Near-black bevelled stone plate with a little grain, lit top-left.
- Cost in an inset socket at the left end of the title plate.
- Raised title plate, and a stone type bar in small caps.
- Inset dark text box with a hairline rule in the keyline colour.
- Rarity is the keyline round the art: ember for common, ice for uncommon, gold for rare. There is also a diamond in the footer.
- Expensive because it has thickness and the cuts read as cuts. Its weakness is that it is dark on a dark fight, so the hand loses some separation from the scene.

**B, printed card** (from Magic's M15 frame, plus Pokémon's fixed rarity/set marks):
- A hard 4.5px black border.
- The frame is tinted by type: attack is brick red, skill is slate blue, power is green.
- Light title plate with the name left-aligned and the cost right-aligned inside it.
- Parchment type line with a rarity diamond at its right end.
- Parchment rules box with black text. Keyword and live-number colours are darkened so they still read on parchment.
- Expensive because it reads as a printed object, and it has the best legibility. Its weakness is that it is furthest from TARGET-UI and from the rest of our dark/gold UI. Its cost is also the smallest of the three.

**C, sculpted relic** (from Hearthstone's frame-as-object):
- A thick gold plate with an engraved groove and domed bosses at the corners.
- The art window is arched at the top.
- The cost is a large gem set into the top-left corner, still inside the card.
- Dark wooden title plate.
- The type is a gold ribbon across the foot of the art.
- Dark inset text box, and a rarity diamond in the footer.
- Expensive because the frame is an object. It is closest to TARGET-UI: gold edge, big green cost gem, pill type, dark text panel.

**Pick: C.** It keeps TARGET-UI's two strongest cues, the gold frame and the large cost gem. It fixes every defect in the research. It also gives the HUD item one material to theme with. A is the fallback if Nick wants the frame to recede.

Grader round 1 FAILED because the frame itself didn't show the sources or the pick. The strips are now labelled. A's cost socket also went from 26 to 30px. Round 2: VERDICT: PASS. The grader noted that B is furthest from TARGET-UI and that C is CLOSER.

**Code:**
- `CardView.frame_mock` (static), `FRAME_MOCKS`, `frame_mock_spec()`, `frame_mock_layout()` and `_build_mock_frame()`.
- New shaders `card_frame_mock.gdshader` (the plate with the art window cut out) and `card_plate.gdshader` (bevelled raised/inset plates).
- Tests pin, at three card sizes, that every piece stays inside the card and the pieces don't overlap.
- When Nick picks, the follow-up is to make that spec the default and delete the other two.

## Ship the A1 card frame, tinted per seat.

2026-10-05, builder. The A1 pair from `tools/cardframe_a1.py` is now the shipping frame, behind `CardView.SHIP_A1` (false brings the carved-obsidian border back).

- **Layers:** ground (rounded, carries the playable halo) → A1 stone nine-patch → art in its window → A1 glow nine-patch (additive, `self_modulate` = seat tint) → name, type, rarity, rules, cost.
- **Nine-patch:** drawn at the source's 690x984 and scaled down by card width / 690, so the margins (130 left/top, 60 right/bottom, socket inside the top-left one) keep their shape and only the runs stretch. At 162x228 the centre squeezes 13 source px; nothing visible.
- **Tint:** `CardView.SEAT_TINT`, one colour per character. `combat_3d.gd`'s `SLOT_TINT` now reads its two entries from it, so the floor markers and the hand are one table. The playable halo takes the seat colour too (`seat_glow`), so a Frog hand has no gold left on it.
- **Boxes:** authored exactly as given (socket, title, art, type, text), normalised against the card. Icon-only cards put the icon inside the art window.
- **Cost:** font = 1.5 × socket radius, emboldened. At hand size the socket is 15px across and the digit 11px. The test checks two digits fit at 135, 162 and 191 wide.
- **Grader, pass 1:** FAIL. Costs inside but barely readable; cards run off the bottom of the window. Fixed the digit (bigger, bold). The bottom overhang is the hand's deliberate deep tuck (FAN_TUCK + 52, the Slay the Spire hand), and TARGET-UI's cards also run off the bottom, so I left it alone.
- The second seat (the Climbers, blue) is not in the rest shot. Switch to it to see the blue hand.
- **Grader, pass 2:** VERDICT: FAIL. Same reason: the resting hand runs off the bottom of the window. Stopped there and marked it for Nick; raising the hand changes the fan's tuck, which is a separate decision.

## A HUD that matches the chosen card frame.

Builder, 2026-10-05 16:18 EDT.

**What was built.** `tools/hudpanel_a1.py` cuts the A1 card pair's bottom-right
quarter (carved corner, two edges, cracked interior stone) and mirrors it into
a panel with no socket or art window: `hud_panel_a1_base.png` (neutral stone)
and `hud_panel_a1_glow.png` (white glow). `Combat3D.add_a1_panel()` stacks them
behind any control as nine-patches (margin 72 source px, drawn at 0.32, less on
a short panel so the bands never meet), glow additive and tinted. It sits in a
zero-min-size holder so it never grows the container it decorates.

Applied to: beast plate and intent (beast ember, intent red while hostile),
energy counter, climb gauge, End Turn (seat glow, re-tinted on Switch by
`_retint_seat_panels`), Switch (neutral glow), and a thin plate under each
hunter's health bar in that hunter's seat colour. Meshy not used, no credits spent.

**What I took from other card games.**
- Slay the Spire: one loud button. End Turn keeps a warm amber face (TARGET-UI's
  colour too) while everything else stays quiet stone; energy stays the one
  big un-shrunk number beside the hand.
- Hearthstone: every HUD piece is cut from the same physical material as the
  cards, so the board reads as one object. Here literally the same pixels.
- Runeterra: the player's colour lives in a rim light, not in the panel fill,
  so seat identity is a glow and the stone stays neutral.
- Marvel Snap: thin, flat plates for health under each unit, no boxes round
  the creature; the health bar keeps its red and the plate is just a sill.

**Grader.** Three rounds, FAIL each time. Round 1: carved band read as a
hairline, beast glow read pink. Round 2 (scale 0.2 -> 0.32, stone lifted 1.3x,
gold beast glow, panels padded outward): energy/gauge/End Turn now read as the
card's stone, but it judged the result further from TARGET-UI than the old
grey-riveted plate and gold End Turn. Round 3: End Turn face back to amber.
Still FAIL: it wants TARGET-UI's grey carved stone with bolts and gold energy,
which conflicts with the item's own "glow takes the seat colour" rule. Short
panels (beast plate 50px, intent, Switch, health plates) clamp the frame scale
and read as pale outlines. Final VERDICT: FAIL.

Test: `state=3d beast=cinder_jackal`.

## Stop the inking from destroying the jackal. Quality, not pose.

2026-10-06 19:27 EDT — builder.

- Before: thick cream stroke (52 px at 2x) + 20 px ink ring + halo, body posterised to four tones and median-filtered (size 25), cracks redrawn and glowed onto the rock. That is what melted the ears, flattened the muzzle and erased the facets. Measured on the old sprite: 33% of opaque pixels cream, median luminance 0.45.
- Now `tools/beast_sprite.py` only cuts the concept off its card and lines the edge: the body is the concept's own pixels (2x Lanczos), a 10 px (2x) warm line (255,214,140) and a 28 px orange glow at 45%. New sprite: 9% cream (line + hottest cracks), median luminance 0.19.
- `repose` and `flame` removed from the jackal's spec (the functions stay); `cinder_jackal_2d_flame.png` deleted. The torn arm was the worst artefact after the halo.
- The fight sizes the beast by its texture box, so the thinner edge made the beast grow and cut the ears off the top. MARGIN now keeps the old stroke's clear room, so framing is as before.
- Test: `_test_jackal_is_a_drawing` now checks no Fire node, cream share < 15%, median lum < 0.28 (fails on the old sprite, passes on the new).
- Head crop: ![[art/shots/2026-10-06-head-pair-after.png|520]]
- Grader: PASS. Meshy: 0 credits.
- The drawing vs the words: agree here; TARGET's line is thin and warm.

## Drive the jackal sprite to 1:1 with the concept. Numbers, not opinions.

2026-10-06 20:54 EDT, builder (rim colour and glow).

- **TARGET's rim, sampled across five edges:** line (252,201,122) amber-gold, ~5 px on a 600 px figure; a darker amber/orange step on its inner side; outside, the sky warmed about a quarter toward orange, fading over ~12 px.
- **Game before:** the line reached the screen as (243,217,149), pale cream: the post chain caps red at ~243 and lifts blue. The halo (0.15 alpha, squared falloff, 14 px) was invisible at play size.
- **Change:** LINE 255,214,140 -> 255,196,105 (lands on screen at 249,199,115); innermost px of the line LINE_IN 240,128,40; HALO 255,140,40 at 0.30 alpha over 22 px, falloff ^1.5. Width unchanged (LINE_W 5).
- **sprite_match:** figure is now alpha > 128 (was > 40), so the translucent glow is not counted as outline; TARGET's 0.005 was measured on the line, not the glow.
- **Grader R1 FAIL:** warmer, but no glow visible and no gold-over-orange split. R2: LINE 255,206,112, LINE_IN 250,140,45, halo 0.50 over 36 px -> FAIL: colour and glow MET, line reads as a wire inside a haze. R3: the drawing outranks "keep the width": TARGET's 4-5 px on a 600 px figure is ~7 px on the concept's 930, so LINE_W 5 -> 7 (outline 0.0074, inside tol 0.009); halo tightened to gold 255,172,66 over 28 px -> FAIL, CLOSER: colour and glow MET; the line still reads about half TARGET's weight in the pair, and the grader cannot see sprite_match output.
- Final sprite_match: `0 of 5 off` (outline 0.0074).
- Meshy: 0 credits.
- Pair: ![[agents/frames/builder/2026-10-07-rim-gold-pair.png|520]]

2026-10-06 20:21 EDT, builder.

- **sprite_match, before:** crack cover 0.273 OFF, detail 0.032 OFF, outline 0.0120 OFF (3 of 5 off). **After:** `0 of 5 off`.
- **crack cover was a measuring fault, not a drawing one.** The body inside the line already carried 0.124 hot (concept 0.123). The extra came from the cream line itself (255,214,140 has saturation 0.451, just over `hot()`'s 0.45) and the orange halo, both counted as "cracks". sprite_match now strips a band as wide as the measured rim off the silhouette before the body measures (symmetric: the concept's rim is ~1 px). Run on the OLD sprite, the new measure still calls detail and outline OFF, so those two were real.
- **detail:** beast_sprite.py upscaled the concept 2x with Lanczos, softening every facet edge into a 2 px ramp. Now drawn at 1x (755x1019, same framing: margin kept so the box and on-screen size are unchanged). 0.032 -> 0.063 (concept 0.068 under the new rim rule).
- **outline:** the halo at 0.45 peak alpha was counted as rim. TARGET's glow outside the line is a faint haze, absent along most edges, so peak alpha is now 0.15. 0.0120 -> 0.0053. The line itself is unchanged (5 px at 1x). Measured off TARGET.png: horizontal cream runs median 6 px on a ~600 px figure, ~4-5 px perpendicular, so 0.005 holds; the picture and the number agree.
- **The real fault at play size: the fight's post chain.** Grader round 1 (FAIL, NOT CLOSER) saw no change, because the PNG never reached the screen as drawn: ACES + exposure 0.82 + contrast/saturation drop everything under ~0.14 linear to black. Measured with a ramp: linear 0.05 -> 0, 0.2 -> 18, 0.5 -> 133, 1.0 -> 234. The plates (sRGB ~42) landed at ~13 and the facets merged. An analytic inverse of Godot's ACES (round 2) did not match 4.7's chain and made it darker.
- **Fix:** `drawn_sprite.gdshader` on the sprite (material_override, written by beast_sprite.py): fog off, every texel looked up in `drawn_sprite_lut.gdshaderinc`, the measured inverse curve (a shader constant, so no import setting can compress it). `tools/drawn_lut.py` re-measures it (shader `calibrate` mode paints a ramp, shoots the fight, fits). In-frame body luma 16 -> 38 (concept 42), body rgb (40,2,0) -> (57,29,28). run_tests pins the Environment numbers the LUT was measured against.
- **Grader:** R1 FAIL (no visible change), R2 FAIL (body near black, the analytic inverse), R3 FAIL but CLOSER: cracks now lines, facets read; it still wants the rim visibly thinner than before. The rim is unchanged on purpose: it measures TARGET's width.
- Meshy: 0 credits.
- Pair: ![[agents/frames/builder/2026-10-07-sprite-1to1-pair.png|520]]

## Rig the jackal as a 2D cut-out in TARGET's pose: drawn at rest, animated in the fight.

2026-10-07 15:43 EDT, builder.

- **How:** `tools/beast_rig.py` cuts the jackal out of TARGET.png itself: the gold rim is thresholded, the body flood-filled from the chest, and five short walls close the line where stones or lava hide it. Parts: torso, head, arm_l/fore_l (raised), arm_r/fore_r, and the fist's fire on its own layer (pulled out of TARGET by brightness and hue, then grown in behind the arm so a swing never opens a hole in it).
- **Repaint:** stone holes in the body are filled with TARGET's own rock borrowed from a nearby offset (picked for clean source, little heat, matching border), not blurred; the line they hid is redrawn. Every parent keeps a 26 px band of its child's pixels under the cut, stopping 8 px short of the silhouette so the outline never doubles, and the band's edge is inked so a swung joint shows an outlined shoulder.
- **Rig:** Node2D bones + Sprite2D parts in a `Rig` SubViewport (`views/drawn_rig.gd`) whose texture the existing `Body` billboard draws, premultiplied (`drawn_sprite.gdshader` gained `premul` and a `halo` grown from the moving alpha). The canvas is 90 TARGET px wider on the left for the swing; `trim_box` hands the fight the old figure box, so the camera and arena are unchanged (box pos/size identical to before).
- **Clips:** idle 2.4 s loop (breathing, small sway, fire flicker), attack 1.2 s (wind-up 0.3, fist lowest at 0.48 = ENEMY_BITE_FRAC, so damage lands on impact), hit 0.45 s, death 1.6 s (sinks into the lava, fire goes out). `_beast_anim` finds the AnimationPlayer as before; no new wiring needed.
- **Holds:** climb_/ledge_ markers ride a Marker2D on the torso/head every frame; the fight reads them once at load, so its stones and hunters do not follow (grader's main FAIL).
- **sprite_match:** `3 of 5 off` (crack 0.272, detail 0.022, outline 0.0142). TARGET's own raw jackal scores crack 0.182 / outline 0.0146 / detail 0.086 at 1x, so outline matches TARGET; crack is raised by the fire layer and the lava-lit rows; detail is a 2x-resolution effect. Per Nick's override TARGET wins over the concept targets.
- **Grader:** FAIL x3, CLOSER every round. Fixed between rounds: doubled outline on the far arm (underlay stopped at the rim), the pasted-rectangle patch (border-matched borrowing), stones wrongly detected on the far arm, pale hairlines at every joint (float premultiplied upscale). Left: stones/hunters don't ride the animation; small impact-frame shoulder notch; ears touch the frame top (camera, existed before).
- **Meshy:** 0 credits; TARGET's own pixels were closer than any regeneration.
- **Frames:** `2026-10-07-rig-before.png`, `-after.png`, `-pair-after.png`, `-strip.png` (idle, wind-up, impact, back to idle), `-hit-death.png`.

## Stones: TARGET's staircase, in TARGET's place.

Run 2026-10-07 16:46 EDT.

- **Before:** five small dark-edged slabs per line on a straight route from beside the Frog to the face (`route_pos`).
- **Placement rule:** the jackal's climb holds (`tools/beast_rig.py` HOLDS) are now TARGET's six slab centres, in TARGET px: (360,560) (410,485) (489,450) (556,425) (594,397) (526,375). Slab k hangs on the rest camera's sight line through climb point k (`stair_slab`), `near` 0.33 to `far` 0.92 of the way from the eye, so at rest it draws where TARGET draws it relative to the jackal. The eye is the rest camera rebuilt (`stair_eye_for`: follow yaw, shoulder truck, 0.93 up after the lens v_offset); STONE vs CLIMB screen positions agree to the pixel in x.
- **Frog conflict:** the shoulder truck always draws the Frog ~100 px left of the sternum, so on jackal sight lines alone slab 0 sat on its head. Low slabs get the sideways gap between TARGET's Frog and ours, fading to none at the top (`stair_shift`), plus `first_nudge` (-1.3, 0.25) hunter heights on slab 0. Grader round 1 FAIL (slab 0 butting the Frog, slab 5 hiding the top one, Goblin behind the gauge) — fixed: nudge, slab-5 width 0.157→0.125, Goblin rest 2→1.6 asides.
- **Design:** widths from TARGET (fraction of beast height), no ink hull, side thickness 0.3 × half-width (`stair_thickness`); tops render ~150-160, sides ~110-120 (TARGET 157-190 / 110-123).
- **Climb:** every slab is footing; leaving Height 0 goes via slab 0, so climb 5 lands six times (frozen with `land=1..6`, strip in the frames).
- **Top/sigil:** climb_5 is under the sternum, so the top hold and the sigil (climb_5 + lift) follow. The gauge is drawn by Height and needed no change.
- **Goblin:** same staircase mirrored about the top slab, eye at its own rest spot; hidden at rest (one_line).
- **Tests:** "climb ends at the face" → "under the sternum"; hold 0 may sit under the lava line; new `_test_staircase_slabs_sit_on_the_eyes_sight_line`. ALL TESTS PASSED.
- Grader round 2: PASS. sprite_match `3 of 5 off` (PNGs untouched; same as the rig run). Meshy 0.
- Harness: screenshot.gd now prints `CLIMB<h> screen=` beside each STONE.

## HUD and cards: TARGET's look, no glow.

2026-10-07 23:17 EDT. Brief: the queue item verbatim (remove seat glow everywhere; match TARGET piece by piece).
Before: every card wore a green seat halo, the boss plate and intent chip sat on the A1 stone with a gold/red glow, the climb gauge had a green glowing frame, unit bars a seat-coloured plate.
Done:
- HUD: new `Combat3D.flat_panel_style` / `add_flat_panel` (dark translucent face, 1 px plain edge, no shadow) replace `add_a1_panel` on the boss plate (padding trimmed so it is thin), intent chip (dark red-brown, thin red edge when hostile, grey when calm), climb gauge (radius 12), unit bars. Energy box: brown face, 3 px gold border and a faint warm 5 px halo, because TARGET draws that soft edge (picture over the words' "no glow"; grader agreed it matches). End Turn/Switch: pills only, nothing behind.
- Cards (A1): ground seat rim off; the A1 glow layer tinted one dull gold (`A1_RIM`) on every seat; stone darkened toward olive (`A1_STONE_SHADE`); a big green cost disc (`a1_cost_disc`, 0.30 of the width, centred on the top-left corner); type shown as a centred grey pill (`a1_type_pill`) instead of a caps strip.
- Fan: `HAND_REST_SCALE` 0.8→0.86, `FAN_OVERLAP` 0.84→0.80, `HAND_REST_LIFT` 22→14 (higher lifts covered the Frog's 42/42 bar).
Tests: seat-glow card test now pins the dull-gold rim; new tests for the flat panel (no glow, behind host, pad, tap-through) and the cost disc. Grader round 1 FAIL (fan narrow/low, caps type label, no hand pair); round 2 PASS.
Meshy: 0 credits.


## Stones: TARGET's thin pale slabs, spread as a staircase.

2026-10-08 00:16 EDT, builder. Brief: the queue item verbatim.
- **Before:** six nine-cornered pucks (convex hull of a jittered ellipse, read as hexagons), side 0.2 r, stacked at the belly: screen (540,392) (604,364) (656,338) (704,312) (732,283) (679,263).
- **Measured TARGET** against the jackal (sternum Y-junction anchor, 0.81 px scale TARGET→frame): wants ≈ (505,440) w130, (568,388) w114, (635,360) w73, (689,340) w53, (721,318) w63, (665,300) w49 — every slab ~25-60 px lower than ours, low two further left.
- **Shape:** new `stair_outline` (four jittered corners on a 2:1 rectangle, each chipped by its own amount or left sharp, one edge in two notched; star-shaped, fanned from the centre) and `stair_slab_mesh` (pale top inset by a lit bevel ring `STAIR_BEVEL` 0.05 r, then a darker wall). `STAIR_THICK` 0.2 → 0.35 (TARGET's side band ~1/6 of width). Only the staircase uses them; other slab biomes keep `slab_outline`/`slab_mesh`.
- **Places:** STAIRCASE `adjust` and `width` re-fit to the current camera. After: (460,431) (524,382) (602,358) (676,341) (719,323) (663,305). Tones sampled: top ~189 / side ~117 vs TARGET ~168 / ~107.
- **Frog conflict:** our Frog draws ~55 px higher against the jackal than TARGET's, so slab 0 cannot be both TARGET's place on the jackal and clear of the Frog; it sits left of the Frog, below the lava line.
- **Grader:** round 1 FAIL (regular polygons, slab 0 at Frog height), round 2 FAIL (all same rounded rectangle, upper four bunched), round 3 FAIL (straight-edged bricks, hard top edges, climb flatter/smaller than TARGET). CLOSER every round. Marked 👀 per brief.
- Outlines come from `randi()`, so the slab silhouettes change each launch.
- Tests: new `_test_staircase_slabs_are_chipped_flagstones_with_a_lit_bevel`. ALL TESTS PASSED. sprite_match not run (no drawn beast touched). Meshy: 0 credits.

2026-10-08 13:15 EDT, builder (second pass, from the `Next pass:` line).
- **Measured** on the `--beast` pair against the sternum Y-junction: the top four sat ~30-36 frame px too low, the low two 45-75 px too far left, so the climb was wide and flat.
- **Placement:** `adjust` re-fit (0.179,0.044) (0.061,0.07) (0.029,0.064) (0.003,0.039) (-0.021,0.041) (-0.008,0.033); slab 0 held to +50 px so it clears the Frog. Screen now (516,419) (575,357) (638,324) (691,308) (719,282) (663,269). Widths 0.30/0.26/0.165/0.125/0.144/0.105 (low two bigger, top one wider).
- **Shape:** `stair_outline` keeps 40% of corners sharp, cuts the rest by a long uneven bevel, and kinks up to three edges in or out (no notch); `STAIR_ASPECT` 0.5→0.55; staircase slabs spin ±0.55 rad (was ±0.25) so edges run at angles.
- **Sides:** new `stair_side_tone` gives each wall a flat tone by facing (left/front lit, right in shadow, darkened 0.04-0.34); the lit bevel drop 0.7→0.4 of the bevel so the wall reads. TARGET samples: top 188-202, side 108-160; ours top ~187, side ~96-140.
- **Ink:** TARGET's slabs carry a thin soft dark edge (looked at 1:1), so the staircase now gets the hull too (`STAIR_INK` 0.22/0.19/0.19, `STAIR_INK_GROW` 1.035, slab-deep). The old "no dark line" note is pre-reset.
- Grader round 1 FAIL (sides not dark, still boxes, no ink), round 2 PASS. Tests: side-tone checks added to the flagstone test; ALL TESTS PASSED. sprite_match not run (no drawn beast touched). Meshy: 0 credits.

## Left background: cliff and purple sky, not black.

2026-10-08 01:17 EDT. Before: the left third was the wall's thin spikes over grey-violet haze (the wall's far-fade), no lit planes, no lava glow at its foot; TARGET has a dark slate mass with cool lit edges, orange lava glow at its base, violet sky toward the centre.

- Added `flank_cliffs()` / `FLANK_CLIFF_SET` / `_add_flank_cliffs()` in combat_3d: nine tapered 4-6 sided prisms (seven columns, two boulders) on the screen-left flank (-x), quarry_ember only (`"flank_cliffs": [-1.0]`). Shaded with CLIFF_FLAT, far_mix 0 (never fades to sky), its own key (FLANK_KEY, from screen centre: the wall's key lights faces seen from the ring's inside and left every flank face in shade/black), lit_at 0.4, cooler lit tone 0.33/0.35/0.44, heat band 1.6x taller and 2x hotter so the foot glows orange.
- Round 1 (tall wide columns, lit_at 0.7): grader FAIL, NOT CLOSER: flat black slabs hid the sky. Round 2: shorter columns, taper top 0.12 of base, fewer sides, lower lit_at: PASS.
- Tones (left 0-15% x, 6-30% y): before mean (25,24,36), TARGET (13,10,16). Grader notes ours is still a little lighter/bluer and busier than TARGET's planar charcoal faces (proposed at bottom of queue).
- Test `_test_flank_cliffs_fill_the_jackal_left_only`. 3dclimb frame checked: masses out of the climb view, nothing clipping.
- Meshy: 0 credits. sprite_match not run (no drawn beast touched).



## Stones: thin soft slabs, lower and spread like TARGET.

2026-10-08 builder. Queued this run from two blind critics (both MAJOR on stones; also both MODERATE on cracks, fist fire, floor seams, cliffs, cards, queued below it).
- **Measured** on the `--beast` pair against the sternum Y: all six slabs ~30-45 crop px too high; walls ~2x TARGET's depth and dark.
- **Shape:** `STAIR_THICK` 0.35 -> 0.2, `STAIR_BEVEL` 0.05 -> 0.12, bevel drop 0.4 -> 0.6 of the bevel (rounded lit rim), `stair_side_tone` lightened (walls 0.1 lighter, shadow 0.22 -> 0.12), `STAIR_INK` 0.22 -> 0.36 grey (soft edge, not a hard dark line).
- **Places:** `adjust` (x right, y up, beast heights) now (0.13,0) (0.02,0.025) (0.015,0) (0.008,-0.012) (-0.01,-0.02) (-0.008,-0.03); widths 0.33/0.28/0.165/... Lowest slab now left of the Frog with a gap, a spaced diagonal up to the sternum.
- Grader round 1 FAIL (lower walls still thick and dark, slabs overlapping in a column, lowest touching the Frog), round 2 PASS.
- Test `staircase slabs` thickness bound changed to 0.15-0.25 of r. ALL TESTS PASSED. sprite_match not run (no drawn beast touched). Meshy: 0 credits.

## Stones: TARGET's slabs, shape and path 1:1.

2026-10-08 16:22 EDT, builder.
- **Approach:** the six slabs are now TARGET's own pixels. `tools/cut_slabs.py` segments TARGET.png's grey slabs (low saturation, bright), smooths the edge at 4x with a soft grey-share score, bleeds colour under the transparent rim, and writes `game/assets/3d/slabs/slab_0..5.png` (0 lowest) at native size. `stair_slab_sprite` draws slab k as an unshaded billboard Sprite3D (`STAIR_SLAB_TOP` 0.35 puts the top face at the stone's origin, so hunters still land on it); the procedural mesh stays as the hidden body. Goblin's line flips the picture.
- **Placement:** STAIRCASE widths 0.248/0.221/0.147/0.115/0.13/0.103 and `adjust` refit so each sprite's centre lands on TARGET's centre mapped into the square (x 280+0.703t, y 0.703t): measured (534,398) (568,343) (624,320) (671,301) (698,281) (650,264) vs wanted (534,397) (568,344) (624,320) (671,301) (698,281) (650,264). `adjust` moves ~480 px per beast height on screen.
- **vs_target `--stones`:** its shot box was fitted to the beast, not the square, so it showed the game ~1.2x larger and disagreed with `--square` (graders alternated between the two). The shot box is now the target box mapped through the square (0.3594,0.33,0.5891,0.60).
- **Grader:** R1 FAIL (placement vs lava/frog in --stones), R2 FAIL (beast-relative refit too big in --square), R3 FAIL (jagged edges, over-lava), R4 FAIL (square placement), R5 FAIL (--stones crop inconsistent with frame; soft edges), R6 PASS after the native-res recut and the square-mapped --stones crop.
- Root cause left: the game's jackal draws ~1.2x TARGET's and its lava horizon ~40-55 px lower; queued both.
- Tests: ALL TESTS PASSED. Meshy: 0 credits.



## Cracks: wide hot cores and a long sternum seam.

2026-10-08 17:56 EDT, builder. Not passed; item left open.

Found by measuring, not by eye: the jackal is TARGET's own pixels, so every crack difference came from how the game draws them.

- **Colour, a 3D LUT.** The fight's ACES + contrast 1.10 + saturation 1.18 mix the channels. The old per-channel LUT (tools/drawn_lut.py) turned TARGET's crack orange (247,161,23) red (255,117,44) and capped everything at grey 232. New `tools/drawn_lut3d.py` paints a 17^3 grid of emissions on the jackal's quad (`cal_grid` mode in drawn_sprite.gdshader, drawn over everything, a grey shot for covered cells and 180-degree turned repeats), reads it back through a homography fitted to the quad's green frame, and inverts it by Gauss-Newton into `drawn_sprite_lut3d.gdshaderinc`. It is measured with bloom off (a flat patch blooms into itself and made thin cracks ~10% dark), emission = 0.12 + 2.28 u^1.7. The shader caps the emitted colour at 1.6 by scaling the whole colour (clipping red alone turned the hot cores cream). Three calibrations, ~11 shots each.
- **Thin lines, rig resolution.** The rig SubViewport rendered at 2x TARGET (1560 px) and was sampled at ~0.4 on screen without mipmaps, which skipped texels in the thin cracks. DrawnRig now renders the viewport at screen size (`size_2d_override`, so canvas coordinates, poses and holds are unchanged), grows the billboard's pixel_size and halo_px to match, and mipmaps the parts at runtime (*.import is gitignored). Edge sharpness now 6.2 against TARGET's 6.3.
- **Seam, size and place.** The seam below the Y was hidden because the jackal drew 1.17x TARGET's, so TARGET's stones landed higher on its body. GROUND_VIEW_PITCH -0.06 -> 0.012 (the orbit rises round the Frog: the Frog stays, the lava line lifts from y 420 to 381, TARGET 381), DRAWN_GAP_PER_HEIGHT 0.9 -> 1.21 (rig canvas on screen 0.415 -> 0.350, TARGET 0.352), and new DRAWN_SHIFT_PX (-82, 43) with `DrawnRig.shift_view`, which moves the picture and its climb markers but not the box the camera aims at. The stones follow the climb points, so STAIRCASE `adjust` and `width` were re-solved from measured slab centroids: all six now sit within 1-4 px of TARGET's.
- **Seam, the cut-out.** beast_rig.py filled a wide region round TARGET's stones (borrowed blocks and inpainted STONES rects), which wiped the seam between the stones and left a dark smudge. `TIGHT` now inpaints only the stone pixels (grown 3 px), keeping TARGET's seam glow. UPLIGHT 0.75 -> 0: with the cut on TARGET's lava line, TARGET's own glow rows show and the ramp only hazed the hips.
- **vs_target.py.** Close-ups cropped TARGET from its 1024-px original but the game from 720 rows, so TARGET's half carried ~1.4x the detail and every game line read thinner. TARGET is now brought to the shot's square resolution first.
- **Measured, inside the jackal's outline (TARGET at 720 vs the game, registered):** mean abs error 41.8 before -> 12.3 after. Bands T/G: dark (57,16,13)/(60,15,10), brown (102,36,21)/(109,40,21), dim orange (156,51,21)/(161,56,20), orange (231,72,17)/(227,85,25), hot (251,203,69)/(247,190,91). Crack coverage on the --beast pair: TARGET 16.2%, game 15.6%.
- **Grader:** R1 FAIL (frame barely changed), R2 FAIL (seam hidden; after the resize), R3 FAIL, R4 FAIL, R5 FAIL, R6 FAIL. Each said the cracks part moved toward TARGET, no penalties. Every round asked for 2-3x wider cracks with painted yellow cores, which the registered pixels do not support. Final: VERDICT: FAIL.
- Frames: ![[agents/frames/builder/2026-10-08-cracks-before.png|420]] ![[agents/frames/builder/2026-10-08-cracks-after.png|420]]
- Meshy: 0 credits.

2026-10-08 18:32 EDT, builder (run 2). Not passed; item left open.

- **Sharpness.** The parts reach the screen through two linear resamples; the Laplacian inside the body was 5.0 against TARGET's 9.8. New `sharpen` (unsharp mask) in drawn_sprite.gdshader, `RIG_SHARPEN` 2.2 in drawn_rig.gd: now ~9.
- **Width and heat.** New shader knobs, all set from drawn_rig.gd: `crack_grow` (0.85, radius `crack_px` 2.6 texels) spreads each crack's colour over the plate pixel next to it, never over light pixels (outline, eye cores); `crack_heat` (0.9) lifts the hot pixels to `crack_core` gold; `hot_glow` (0.55, `hot_glow_px` 3.5) adds a short gold glow round the hot cores (the sternum Y); `crack_orange` (0) is there but off (0.35-0.8 turned limbs and ears pale). EMIT_CAP 1.3 was tried and reverted: it turned the yellow cores orange.
- **Grader:** R1 FAIL (unchanged at frame scale), R2 FAIL, R3 FAIL, R4 FAIL (glow 1.6@7: smear), R5 FAIL (0.7@4: still smear), R6 FAIL (0.35@3: too narrow), R7 FAIL (0.55@3.5, wider cracks: sternum closer, limbs still thin). No penalties in any round; each said the chest moved toward TARGET. Final: VERDICT: FAIL. Graders also repeatedly claim the game has more, smaller plates than TARGET, which cannot be (the jackal is TARGET's own pixels).
- has_open.py counted 0 open items (it split on the first `## Now` text, inside the intro line); fixed to match the heading.
- Frames: ![[agents/frames/builder/2026-10-08-cracks2-before.png|420]] ![[agents/frames/builder/2026-10-08-cracks2-after.png|420]]
- Meshy: 0 credits.

2026-10-08 19:34 EDT, builder (run 3). Not passed; item left open.

- **The hollow cracks were the shader.** Close up, run 2's cracks were an orange rim on both sides of a dark middle: the 2.2 unsharp mask rang, and `crack_grow` gated its fringe by `(1 - own)` so a crack's own soft edge stayed dark. `sharpen` is off; grow is now a max filter (two rings, the brightest crack pixel in reach, applied where it is brighter than the pixel).
- **Footprint filter.** New `footprint` in drawn_sprite.gdshader, `RIG_SUPERSAMPLE` 2 in drawn_rig.gd: the rig viewport renders 2x screen and the billboard box-filters each pixel's footprint (3x3 taps over dFdx/dFdy). One clean downsample instead of trilinear mips plus a bilinear tap. Crack radii now in screen px (`RIG_CRACK_PX` 1.5, `RIG_HOT_GLOW_PX` 5), scaled by the supersample.
- **EMIT_CAP 1.6 -> 2.2.** The cap was crushing the hot cores' green (-26 against TARGET); now -7. Above 2.2 nothing changes.
- **Channel middle to orange.** `crack_heat` 1.0 now also lifts the red-hot middle of each channel toward (1.0, 0.58, 0.16). The old heat test (r > 0.78, g > 0.38) almost never fired: the part PNGs' median crack is (0.82, 0.25, 0.05), i.e. TARGET's cracks are red-orange and only the sternum is yellow.
- **Measured (chest, registered, TARGET/game):** crack coverage 0.123/0.176, hot 0.049/0.040, crack mean (214,83,32)/(219,84,31). With every knob off and the footprint filter alone the pixels match TARGET almost exactly (0.123/0.129, 0.049/0.050), and graders still call the cracks thin, so they judge the look, not the pixels.
- **Grader:** R1 FAIL (footprint only), R2 FAIL (cap 2.2), R3 FAIL (max-filter grow + orange middle). No penalties; each said the sternum moved toward TARGET. Final: VERDICT: FAIL.
- Graders again claim more hairline cracks than TARGET, which the cut-out cannot have.
- Frames: ![[agents/frames/builder/2026-10-08-cracks3-before.png|420]] ![[agents/frames/builder/2026-10-08-cracks3-after.png|420]]
- Meshy: 0 credits.

2026-10-08 20:21 EDT, builder (run 4). Not passed; item left open.

- **The cream cores were the scene's glow.** The 3D LUT was calibrated with glow off (drawn_lut3d.py turns it off to measure), but the fight ran with it on. Registered on TARGET's hot pixels: TARGET (249,192,51), game with glow (251,204,102), glow off (249,182,51). glow_hdr_threshold 2.3, glow_levels/1 0, additive blend and intensity 0.5 all left it at ~(250,203,100); only glow off fixes it. combat_3d.tscn `glow_enabled = false`. It also takes the pink fringe off the jackal's cream line and gives the fist fire its tongues back (the fist item's Next pass asked for exactly this).
- **Shader crack knobs off** (RIG_CRACK_GROW 0): the 16-tap max filter stippled the channels (hatched orange, visible at 3x). With the knobs off and glow off, chest crack coverage is TARGET 18.4% / game 19.4%, crack colour (203,75,26)/(201,74,23).
- **Offline crack glow** in tools/beast_rig.py (`crack_glow`): each crack's own colour, gaussian-blurred (σ 1.6 TARGET px, 0.55) and the yellow cores' (σ 4, 0.45), screened onto the rock inside the line. Smooth, so no stipple. σ 6 at 0.8 overshot TARGET's Y at close range and was reverted.
- Tried and reverted: NS inpaint with TIGHT_GROW 5 for the stone holes (no better than TELEA; the game's stones cover the holes).
- drawn_lut3d.py no longer asserts glow is on.
- **Grader:** R1 FAIL (glow off, knobs off; "almost the same"), R2 FAIL (with crack glow; "a little brighter and wider"). No penalties. Final: VERDICT: FAIL. Both again claimed more fine cracks than TARGET, which TARGET's own pixels cannot have.
- Frames: ![[agents/frames/builder/2026-10-09-cracks4-before.png|420]] ![[agents/frames/builder/2026-10-09-cracks4-after.png|420]]
- Meshy: 0 credits.


2026-10-08 21:25 EDT, builder (run 5). Not passed; item left open.

- **Blur was the render path, not the art.** Laplacian inside the chest: TARGET 8.4, game 4.7. Three causes, fixed in order: the rig viewport drew the parts at 0.7 with trilinear mips (RIG_SUPERSAMPLE 2.0 -> 2.857 so the viewport renders the 2x canvas 1:1; 5.8), the cut-out's 2x upscale was bilinear (now Lanczos; 7.2), and the footprint downsample softens a little (new PRESHARPEN 0.6, sigma 1.5 canvas px, unsharp inside solid rock only, before the downsample so it cannot ring on screen; 8.5).
- **Baked crack glow off** (CRACK_GLOW 0, HOT_GLOW 0): it softened every crack into a halo; with the sharper path TARGET's own pixels match. Chest error 12.6 -> 9.5, hot cores 6.1%/6.1%, hot colour (251,204,44)/(252,198,51).
- **Stone smears.** Pale unsaturated pixels within 6 px of a stone hole now join the hole (they smeared cream under the seam), and a stone's grey ends inside the rim are filled from rock with the line and sky masked dark, the line redrawn over the band.
- **Tried and reverted:** `crack_boost` (each crack widened 1 TARGET px with its brightest colour, middles heated to (255,196,70), a painted seam from the Y to the top stone). Chest error 15.1 and it read as orange cartoon outlines, spreading onto the muzzle lines. Not TARGET.
- **Gap between torso and right arm:** the torso layer now carries TARGET's own dark cliff pixels in the gap the silhouette closes (`enclosed_gaps`), instead of the fight's purple sky.
- **Seam under the top stone:** `carry_seam` paints the Y's stem on down inside the top stone's hole only (yellow into orange, x 508, y 356-392), so where the fight's slab sits a few px low the seam meets it as a line, not an inpainted haze.
- **Feet:** the sink rows under the cut were the last row repeated, a band of vertical streaks now the lava line sits at TARGET's height. `sink_target` puts TARGET's own rows there (its lava edge), faded out sideways where the body ends. The scene's lava strip still shows red bars beside the body; hiding the heat-shimmer band did not remove them (the pool ring itself).
- **Grader:** R1 FAIL ("no visible change at frame scale"; 2-3x wider cracks with yellow-white cores), R2 FAIL (same, plus "seam a diffuse smear behind the top stone"), R3 FAIL (Y brighter; still thinner redder limb cracks), R4 FAIL (after the sink fix; same asks). A registered close-up of the right forearm shows the same cracks as TARGET; the visible differences there are sky, cliff and lava bars. Final: VERDICT: FAIL.
- Frames: ![[agents/frames/builder/2026-10-09-cracks5-before.png|420]] ![[agents/frames/builder/2026-10-09-cracks5d-after.png|420]]
- Meshy: 0 credits.


2026-10-08 22:45 EDT, builder (run 6). Not passed; item left open.

- **Pocket under the fist arm.** TARGET's open gap between the raised arm and the torso (down to the lava) is near-black rock with lava glow; the fight showed purple sky. beast_rig.py `POCKETS` puts TARGET's own pixels there on the torso layer, stones lifted out by row interpolation (the glow changes with height, not across), faded on the open left side, at `POCKET_ALPHA` 0.94 so the shader's new `halo_from` (0.97) keeps the halo off its open edge. Registered, the pocket now matches TARGET within a few levels.
- **Red bars over it were the heat band.** The shimmer cylinder is see-through and was drawn after the jackal, so wherever the jackal was under full alpha its glow lay on top. `heat.render_priority = -1` (combat_3d.gd). Putting the jackal at priority 1 instead hid the stones behind it; reverted.
- **Half a pixel off TARGET's columns.** Registered on the chest, the shot fit TARGET best shifted -0.5 px in x: every 2-px crack was resampled across three columns. DRAWN_SHIFT_PX -82 -> -83.2 (canvas px). Chest error 9.8 -> 8.4, crack-pixel error 13.8 -> 10.7.
- **Dark greens crushed.** The colour path took TARGET's darkest plate greens/blues to 0 ((44,11,8) drew (40,0,0)), so the rock read redder round every crack. New tools/jackal_tone.py measures the per-channel response on the body and writes tools/jackal_tone_fix.json, a pre-map faded to identity above 40; beast_rig.py `tone_fix` applies it to every layer.
- **PRESHARPEN 0.6 -> 0**: its dark rim narrowed each crack (pec crack profile now matches TARGET's to ~10 levels). Chest error 8.4 -> 8.0.
- **HOT_LIFT 18**: the yellow cores land ~14 green short after the resample; lifted before it (hot green 188 -> 199, TARGET 206).
- Tried and reverted: a screen-space unsharp after the footprint filter (0.4: error 9.6, 0.8: 10.7), PRESHARPEN 1.0 (8.7), hole growth 2/4 and 1/3 (no change), `crack_widen` WIDEN 0.85 / ORANGE 0.7 with HOT_GLOW 0.35 (error 9.5; the grader saw no change).
- Embers now draw before the jackal (render_priority -1): TARGET's sparks are in the sky.
- **Grader:** R1 FAIL (pocket only), R2 FAIL (shift), R3 FAIL (hot lift), R4 FAIL (widen 0.5/orange 0.5/glow 0.3), R5 FAIL (tone fix, widen off), R6 FAIL (presharpen off), R7 FAIL (strong bloom), R8 FAIL (narrow bloom below the chin). No penalties; every round said the cracks were unchanged and asked for wider, oranger, glowing cracks; R6 also claimed a different crack layout, which TARGET's own pixels cannot have. Final: VERDICT: FAIL.
- **Bloom rounds, reverted.** R7: CRACK_GLOW 0.6 σ2.5 + HOT_GLOW 0.6 σ5 (error 13.5): "slightly closer", but soft bloomed blur, yellow over the pecs, a chin patch and glowing face lines. New `GLOW_TOP` (335) keeps glow off the head. R8: CRACK_GLOW 0.25 σ1.2 + HOT_GLOW 0.5 σ2.5 below the chin (error 8.4): "hard to tell apart", asks 2-3x wider #FFD040 cracks again. R7 asked for crisp channels, R8 for wider ones; graders also disagree on the right forearm (matches / thin hairlines). Glow back to 0, the pushed state.
- Frames: ![[agents/frames/builder/2026-10-09-cracks6-before.png|420]] ![[agents/frames/builder/2026-10-09-cracks6-after.png|420]]
- Meshy: 0 credits.
2026-10-08 23:13 EDT, builder (run 7). Not passed; item left open.

- **Chest speck was the weak-point sigil.** Its glow mesh and light sat at the Height 5 climb point plus 1.7 hunter heights, right of the sternum. TARGET draws no mark; for a drawn beast the sigil's children are now hidden (the node stays as the strike anchor).
- **Stones re-registered.** The six slabs sat 2-4 px low/right of TARGET's, so the cut-out's inpainted stone holes showed round them and dimmed the seam under the top stone. STAIRCASE `adjust` re-solved; all six centroids now within 1.5 px of TARGET's.
- **Measured (TARGET/game, square at 720):** forearm R crack 24.6/25.4%, hot 7.6/8.4%; belly 26.8/28.9%; chest 20.8/20.4%, hot 6.3/6.3%, mean (107,45,24) both; stem column pixels within a few levels.
- **Grader:** R1 FAIL (seam "a little brighter, further down"; asks 2x wider cracks again). No penalties. VERDICT: FAIL. Not widened: the registered pixels already equal TARGET's.
- Frames: ![[agents/frames/builder/2026-10-09-cracks7-before.png|420]] ![[agents/frames/builder/2026-10-09-cracks7-after.png|420]]
- Meshy: 0 credits.
## Fist fire: compact curling blaze wrapped on the fist.

2026-10-08 18:51 EDT, builder. Not passed; item left open.

- **Built (tools/beast_rig.py, `FIRE_RAW`):** TARGET's own flame, unwarped: no lean, no cream core, no orange edge recolour, TARGET's colours (no un-blend off the slate), a hard key on the drawn tongues (r > 125, r-b > 75), TARGET's flame pixels kept where the figure's mask overlaps the fist. Flicker calmer: FIRE_SWAY 10 -> 2.5, FIRE_LIFT 14 -> 3.5, idle modulate peaks 1.15 -> 1.05. The rig's rest composite now equals TARGET pixel for pixel round the fist.
- **Shader:** crack_grow / heat / hot_glow now act only near dark plates and onto pixels darker than the fire's glow (`plate`, `rock`), so they never touch the flame.
- **Found:** with the scene's glow off, the flame shows TARGET's tongues and dark gaps; with it on they wash into one orange dome. Raising `glow_hdr_threshold` 1.0 -> 1.7 (above the jackal's 1.6 emission cap) changed nothing in the shot, so something else drives that bloom. Not changed: global glow also lights the lava.
- On-screen colour bands round the fist, TARGET/game: yellow (253,211,66)/(254,198,77), orange (247,136,31)/(250,149,50), dark red (134,47,22)/(141,47,22).
- **Grader:** R1 FAIL (round puffs, pale), R2 FAIL (blob, airbrushed), R3 FAIL (colour right; dark smoky halo), R4 FAIL (soft dome, no tongues). Every round: closer than before, no penalties. Final: VERDICT: FAIL.
- Frames: ![[agents/frames/builder/2026-10-08-fistfire2-before.png|420]] ![[agents/frames/builder/2026-10-08-fistfire2-after.png|420]]
- Meshy: 0 credits.

## Stray yellow speck on the jackal's chest.

2026-10-08 23:20 EDT, builder. Passed.

- The speck was the weak-point sigil (glow mesh plus an omni light) at the Height 5 climb point lifted 1.7 hunter heights. TARGET draws no mark, so a drawn beast hides the sigil's children; the node stays as the strike flash's anchor.
- Grader: VERDICT: PASS.
- Meshy: 0 credits.
