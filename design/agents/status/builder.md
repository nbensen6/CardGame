---
tags:
  - agent-status
agent: builder
updated: 2026-09-29T16:37
working_on: "Playtest presses Switch."
---

# builder

The one lane that builds. Queue: [[../../plan/BUILDER-QUEUE]]. Brief:
`tools/builder/BRIEF.md`. Run it: `tools\builder\run.cmd`.

## This run

2026-09-29 16:37 EDT

- **Did:** The scripted playtest now presses Switch mid-turn and checks the other hunter's grip holds meanwhile.
- **Worked?** Yes: one Switch, grip 0.271 -> 0.271 while the Frog played; VERDICT: PASS.
- **Look at:** ![[frames/builder/2026-09-29-playtest-switch-before.md]] then ![[frames/builder/2026-09-29-playtest-switch-after.md]]
- **Ask:** nothing

## Notes

- **Found:** the grip-while-away check caught only one hanging step in 40; a scripted hang would pin it.
- **Found:** beast-behind-stone is still the playtest's one red check (20 hits this run).

## Log

- 2026-09-29 16:37 EDT — builder: playtest presses Switch once a round mid-turn (first press unconditional, later only while the held hunter hangs); checks grip-drained-away, switch-dead, switch-never-pressed; run: 1 press, grip 0.271 held; grader PASS; tests green, pushed.

- 2026-09-29 16:04 EDT — builder: jackal death: `death` clip (beast_clips.py, added via new ai_beast_clip.py from the saved .blend; ai_beast.py makes it too), router holds the fight for slow last hit 0.6 s + fall + 0.8 s rest, camera pulls wide if climbing; harness deathat=; grader FAIL x3 (slow-mo not visible in stills); tests green, pushed.

- 2026-09-29 15:30 EDT — builder: played cards fly (0.25 s, grow then shrink) to the beast for attacks, the hunter otherwise, effect on landing; Block landing plays `block` + ring; harness fly=/flyt=; grader FAIL x2 then PASS; tests green, pushed.

- 2026-09-29 15:02 EDT — builder: rigless hunters get tween beats (attack lunge + lift + scale punch toward the beast, hit white flash + knock-back + lean), only the hunter who spent energy lunges (strike_slots); harness 3dstrike beat=/actor=; grader FAIL then PASS; tests green, pushed.
- 2026-09-29 14:41 EDT — builder: timing notes open beside the active hunter (notes_anchor, side facing the card; note_pattern lift=false), card fallback; test pins the first note within a hunter-height; grader PASS; tests green, pushed.
- 2026-09-29 14:27 EDT — builder: grip clock pauses unless the hanging hunter is held, and during hops, timing windows and the beast's turn (grip_paused + test); harness 3dgrip hangs both hunters and shoots a before|after strip; grader FAIL x2 (hop/timing pauses not visible in stills), escalated; tests green, pushed.
- 2026-09-29 14:18 EDT — builder: beast turn staged (0.4 s hold + badge pulse, attack clip, damage on frame 16/40, hand 0.5 s later); harness enemyat=; playtest waits the turn out; grader FAIL x3 (bite unreadable in stills), escalated; tests green, pushed.
- 2026-09-29 13:19 EDT — builder: jackal round 4 attack_all 6 -> claw_sweep 6 (Height 4+, throws to 2); harness thenend=; grader FAIL then PASS; tests green, pushed.
- 2026-09-29 12:53 EDT — builder: Let the Frog hang? reworded for Nick (safe stones 2/4, hanging at 1/3, Frog +1 always lands safe); grip frame embedded; nothing built; tests green, pushed.
- 2026-09-29 12:39 EDT — builder: cinder_jackal max_hp 42 -> 70 (hurt switch at 28), test pins it; burn rework proposed, not built; grader PASS; tested, pushed.
- 2026-09-29 12:30 EDT — builder: a missed timed card resolves at plain value and discards (no Rhythm, counts as played); harness miss=1/nail=1; grader FAIL x2 then PASS; tested, pushed.
- 2026-09-29 12:19 EDT — builder: timing_plan (cost -> taps, drag at cost 2+ or climb 2+), HitCircle taps-then-drag with pointer-follow, notes pinned in screen space around the card (note_pattern, reach 230, rise 150); grader FAIL (notes over the hunter) then PASS; tested, pushed.
- 2026-09-29 11:58 EDT — builder: TOP_STONE_PULLBACK 6 in top_hold_z_for (whole route follows), stones shallower toward the beast (stone_depth_ratio 2.0 -> 0.9); grader FAIL x2 (12: chest hidden; 12+taper: jackal too small) then PASS at 6; tested, pushed.
- 2026-09-29 11:10 EDT — builder: menu scroll confirmed by Nick (10:50); marked 👀 for his tick, nothing built.
- 2026-09-29 00:39 EDT — builder: settings column wrapped in a ScrollContainer capped at the window (settings_scroll_height); wheel on the backdrop no longer closes the menu; grader PASS.
- 2026-09-29 00:21 EDT — builder: stones-back tried (whole route +20, then top stone only +20); both push beast-behind-stone 3 -> 31 and the chest stays hidden behind the hunter's own stone; grader FAIL; reverted, asked.

- 2026-09-28 21:41 EDT — builder: playtest hunter-lost-mid-hop replay holds Combat3D's _process so the posed hunter survives to the render (1 -> 0 fails); grader FAIL x2 on the zero-checks done-when; tested, pushed.
- 2026-09-28 20:21 EDT — builder: playtest hop-leftover-squash measured from the fit scale (10 -> 0 fails), hop-no-squash un-silenced; grader FAIL x2 on the zero-checks done-when; tested, pushed.
- 2026-09-28 19:40 EDT — builder: Dev camera is per-launch (never saved), DEV CAMERA corner tag; grader PASS; tested, pushed.
- 2026-09-28 19:30 EDT — builder: climbing camera keeps the rest pitch (0.08) and lens lift; CLIMB_FOCUS_PITCH_MAX deleted; grader FAIL x2 (midair phases, then misread facing), escalated; tested, pushed.
- 2026-09-28 19:05 EDT — builder: harness play mode (Test this now) no longer arms the 10 s shot failsafe that quit the window; grader FAIL (wanted Goblin view) then PASS; tested, pushed.
- 2026-09-28 18:55 EDT — builder: hop squash restores the hunter's fit scale, not 1 (Frog was 1.64x after any hop); rock top under the cap, hunters ride their stone's drift; grader FAIL x2 then PASS; tested, pushed.
- 2026-09-28 18:25 EDT — builder: resting hunters stand in front of their own line's first stone (rest_pos_for); grader FAIL (other hunter off-screen), escalated; tested, pushed.
- 2026-09-28 18:14 EDT — builder: follow aim at RoR2's pivot (1.25 hunter heights, above the head), researched from RoR2's survivor template; grader FAIL x2 (wanted further back); tested, pushed.
- 2026-09-28 17:09 EDT — builder: playtest hop-distance-band ceiling deleted with reason, floor kept (124 -> 0 fails); grader FAIL x2 on the multi-run done-when; tested, pushed.
- 2026-09-28 16:45 EDT — builder: FOLLOW_DIST 3.4 -> 5.2 (Nick: zoom out more); grader FAIL, PASS; tested, pushed.
- 2026-09-28 16:24 EDT — builder: top stones split around the snout (_head_x) and level at one face depth (_top_pair_front); grader FAIL, FAIL, PASS; tested, pushed.
- 2026-09-28 16:03 EDT — builder: FOLLOW_DIST 2.3 to 3.4 (Nick: too close); frame-share test band moved; grader FAIL x2; tested, pushed.
- 2026-09-28 15:36 EDT — builder: follow distance 3.2 to 2.3, ground pitch 0.20 to 0.08, camera floor 0.8 to 0.5; hunter_frame_share rule + test; grader FAIL x3; tested, pushed.
- 2026-09-28 15:09 EDT — builder: ground hunters aim at the beast (hunter_facing_y from position); grader PASS; tested, pushed.
- 2026-09-28 14:57 EDT — builder: stone lines fan out into a V (route_sweep_for); grader FAIL on Goblin stone under the gauge; tested, pushed.
- 2026-09-28 14:37 EDT — builder: F8 confirmed by Nick, marked 👀 for his tick; no code change.
- 2026-09-28 14:24 EDT — builder: follow camera rides the hopping hunter (live body, not landing stone), eased yaw; harness midair=S; grader FAIL x2; tested, pushed.
- 2026-09-28 13:55 EDT — builder: one hop per stone (climb_landings), no mid-air sub-landings; harness land=K; grader FAIL then PASS; tested, pushed.

- 2026-09-28 13:11 EDT — builder: stone lines split one each side of the jackal (route_offset_x, 4 hunters each side); grader FAIL then PASS; tested, pushed.
- 2026-09-28 12:51 EDT — builder: F8 cuts to a wide Dev view and back, note moved clear of the intent chip; grader FAIL on side-on Player shot; tested, pushed.
- 2026-09-28 12:24 EDT — builder: one fixed follow distance (3.2) behind the held hunter, centred, yaw on the beast-to-hunter line; grader FAIL on side-on Frog; tested, pushed.
- 2026-09-27 18:39 EDT — builder: the first climb engages the locked follow camera; hunter-offscreen 4 fails to 0; built, tested, pushed.
- 2026-09-27 18:24 EDT — builder: camera-not-over-shoulder waits for the truck's ease instead of 45 frames; 9 fails to 0; built, tested, pushed.

- 2026-09-25 20:55 EDT — session: 65-degree lens, stairs visible, beast whole; pushed.

- 2026-09-25 18:27 EDT — builder: playtest.cmd green -- fixed hunter-off-marker's stale side + a guard-cap bail that read `home` mid-tween; 7 failing categories down to 6; built, tested, pushed.
- 2026-09-25 18:02 EDT — builder: investigated weak-point-shot Switch behaviour, already correct in every path tried, no change shipped, item left open.
- 2026-09-25 17:52 EDT — builder: playtest's own top-hold z now hull-corrected like the real route, not the raw anchor; tested, pushed.
- 2026-09-25 17:41 EDT — builder: goblin trim (boots/shorts/strap/ear) recoloured to one muted rust, baked into goblin_mech_ai.glb's embedded texture; built, tested, pushed.
- 2026-09-25 17:26 EDT — builder: ground hunters face the beast, backs to camera, not the camera itself; built, tested, pushed.
- 2026-09-25 17:15 EDT — builder: hull built before the decorative stones, so mid-route hunters land on their own stone; built, tested, pushed.
- 2026-09-25 16:43 EDT — builder: sigil top hold uses each hunter's own route side, not the shared-foothold nudge; built, tested, pushed.
- 2026-09-25 16:31 EDT — session: top hold in front of the face, sigil shot lands; pushed.

- 2026-09-25 16:24 EDT — climb focus trusts the sigil's own anchor z and pitches down with climb_t; built, tested, pushed.
- 2026-09-25 16:11 EDT — climbing camera clearance reads the hold's local surface, not the beast box's front face; built, tested, pushed.
- 2026-09-25 15:55 EDT — one fixed camera stand-off, resting and climbing, built, tested, pushed.
- 2026-09-25 15:31 EDT — stones near-hunter fix built, tested, pushed.
- 2026-09-25 13:30 EDT — lane created; the four cloud agents and the board sync are off.
- 2026-09-25 13:27 EDT — F8 camera-toggle hotkey built, tested, pushed.
