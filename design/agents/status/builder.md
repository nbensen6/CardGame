---
tags:
  - agent-status
agent: builder
updated: 2026-10-05T00:33
working_on: "Overnight: keep closing the gap to picture A until 8 AM."
---

# builder

The one lane that builds. Queue: [[../../plan/BUILDER-QUEUE]]. Brief:
`tools/builder/BRIEF.md`. Run it: `tools\builder\run.cmd`.

## This run

2026-10-05 00:33 EDT

- **Did:** Overnight pass 10: the jackal's cliffs are now A's charcoal, not navy blue.
- **Worked?** Yes, grader said CLOSER: VERDICT: PASS.
- **Look at:** ![[frames/builder/2026-10-05-overnight-p10-before.png]] then ![[frames/builder/2026-10-05-overnight-p10-after.png]]
- **Ask:** nothing

## Notes

- **Found:** A's sky is a wide mauve notch; ours is a small disc between cliffs.

## Log

- 2026-10-05 00:33 EDT — builder: overnight pass 10: cliff_flat lit/side/shade tones blue slate -> neutral charcoal (0.23,0.235,0.26)/(0.145,0.148,0.165)/(0.075,0.075,0.085); grader PASS (CLOSER); tests green, pushed.
- 2026-10-05 00:10 EDT — builder: overnight pass 9: quarry_ember sky top/horizon navy+red -> violet (0.26,0.12,0.28)/(0.66,0.26,0.44), ash_params (pink-violet under, cover 0.3, pulse 0.3) via ash_params() + test; grader PASS (CLOSER); tests green, pushed.
- 2026-10-04 23:58 EDT — builder: overnight pass 8: slab cap matches the 6-sided block (segments, radius, spin), SLAB_SIDE_TONE (0.46,0.50,0.55) -> (0.36,0.39,0.43); grader PASS (CLOSER); tests green, pushed.
- 2026-10-04 23:40 EDT — builder: overnight pass 7: slab stones neutral grey+cobble texture -> flat cooled SLAB_SIDE_TONE/SLAB_TOP_TONE + test; grader PASS (CLOSER); tests green, pushed.
- 2026-10-04 23:24 EDT — builder: overnight pass 6: rest rock albedo 0.36 + ROCK_DETAIL -> flat REST_ROCK_TONE (0.12,0.115,0.135) + test; grader PASS (CLOSER); tests green, pushed.
- 2026-10-04 23:11 EDT — builder: overnight pass 5: jackal tint (0.7,0.8,0.85) -> (0.66,0.78,0.95), body_floor (0.27,0.24,0.23) -> (0.26,0.24,0.29) so the grade keeps blue in the rock + test; grader PASS (CLOSER); tests green, pushed.
- 2026-10-04 22:56 EDT — builder: overnight pass 4: jackal outline 0.010/energy 2.2 -> 0.007/1.4, colour (1,.55,.18), body_floor 0.22 -> (0.27,0.24,0.23); test now asks line > Frog's; grader PASS (CLOSER); tests green, pushed.
- 2026-10-04 22:42 EDT — builder: overnight pass 3: BIOME lava_glow 0.45 scales lava pool gain, lava lights, floor rim heat, heat-haze glow band (gain + height) and cliff foot band; floor crack_gain 0.7 -> 0.3 + test; grader PASS (CLOSER); tests green, pushed.
- 2026-10-04 22:31 EDT — builder: overnight pass 2: jackal body_floor (0.20,0.11,0.07) -> (0.22,0.20,0.19) so the grade keeps it brown + test; grader PASS (CLOSER); tests green, pushed.
- 2026-10-04 22:13 EDT — builder: overnight pass 1: outline hull welded normals in NORMAL for facet-lit (skinned) bodies, depth push along the view ray + tests; grader PASS (CLOSER); tests green, pushed.
- 2026-10-04 21:56 EDT — builder: cliffs and floor flat: cliff_flat.gdshader (3 flat slate tones by face normal, warm foot band) on the jackal wall via wall_style "flat"; obsidian slab_var + wider/hotter seams via floor_params, floor_tone 0.25 + test; grader PASS; tests green, pushed.

- 2026-10-05 01:50 EDT — builder: stone staircase: jackal biome route_top 0.42 (route ends at chest), one_line (held hunter's line only, no zigzag), REST_ASIDE so the first block shows beside the Frog, slab blocks 1.4x wide with straight sides 1.05 tall + tests; grader FAIL then PASS; tests green, pushed.
- 2026-10-04 21:26 EDT — builder: jackal rigged: v2 wrapper -> rigged glb, Idle/Punch_Combo grafted (BEAST_CLIPS, 0.3 s blend), hit at f39/60, mesh_xform for skinned measure (fixed 100x fit), idle hips/spine yaw held front, lunge share 0.3 + test; grader FAIL x2 then PASS; tests green, pushed.
- 2026-10-04 21:01 EDT — builder: jackal-fills-frame investigated: 45% shoulder width impossible with head, Frog and whole model in frame (body ~1050 px tall at that width); standoff/tilt sweep peaks ~21%; sunk-legs option frame ~30%; no code change, marked 👀 for Nick's call; pushed notes only.
- 2026-10-04 20:50 EDT — builder: clean shapes: outline hull along welded normals (TANGENT) + depth push, MSAA 4x, Frog thin dark line, scene glow + hotter cracks and line, toon tex_soften/facet/facet_shade, eye mask + tests; grader FAIL x3 (eyes at 1:1), shipped 👀; tests green, pushed.
- 2026-10-04 19:46 EDT — builder: Cinder Jackal fights as cinder_jackal_v2 (AI_ART "_v2", .tscn wrapper with climb/ledge markers, beast_variant_path), GROUND_GAP_PER_HEIGHT 1.5 height floor on the standoff, outline 0.010, cool tint + low body floor + test; grader FAIL x2 (beast fills height, not A's width), shipped 👀; tests green, pushed.
- 2026-10-04 19:30 EDT — builder: scene pass 2 toward picture A: jackal stones -> pale flat slabs (BIOME stone "slab"), raised rest rock under waiting hunters (rest_rock_lift), thick warm outline on jackal (0.018) and Frog + tests; grader FAIL x2 (stones ring the head: route geometry, Nick's call), shipped 👀; tests green, pushed.
- 2026-10-04 16:02 EDT — builder: scene pass 1 toward picture A: GROUND_STANDOFF 4.2 -> 1.75 + rest_beast_share, toon body_floor/shadow lift and warm outline on the jackal, obsidian floor slate tone + test; grader FAIL x2 (a climb stone over the face), shipped 👀; tests green, pushed.
- 2026-09-30 17:25 EDT — builder: sky "crash" answered (Nick 16:59): same play-mode quit as the HUD item, fixed at 17:12; proved with pre-fix vs main play runs sampled to +20 s; no code change; grader PASS; tests green, pushed.
- 2026-09-30 17:12 EDT — builder: HUD "crash" answered (Nick 16:59): play mode quit after idleat/deathat/enemyat shots via _save_and_quit; now returns PLAY READY when quits_after_shot is false + test; grader FAIL (one still) then PASS on 8 s grid; tests green, pushed.
- 2026-09-30 12:55 EDT — builder: sky clouds move on Nick's word (09:44): ash wind 0.018 -> (0.3, 0.1) cells/s via BIOME ash_wind + static ash_wind() + test; grader FAIL on half-size grid then PASS on 4x sky strips; tests green, pushed.
- 2026-09-30 12:43 EDT — builder: Embers answered (Nick 09:44): rising field emits from the lava ring only (ember_band = lava_ring, RING emission), glow down (alpha 0.75, seam lights 95) + test; grader FAIL x2 (origin unjudgeable from a still), shipped 👀; tests green, pushed.
- 2026-09-30 12:24 EDT — builder: Obsidian floor answered (Nick 09:44 "remove the band"): specular band deleted from obsidian.gdshader, test asserts no band uniform; grader PASS; tests green, pushed.
- 2026-09-30 12:13 EDT — builder: HUD trimmed on Nick's 11:44 word: beast plate pinned top-left on glass, party panel hidden, intent chip small beside the bar, hunter idle sway gone and ridden stones still; harness idleat= grid; grader FAIL x2 then PASS; tests green, pushed.
- 2026-09-30 11:57 EDT — builder: Remove cost answered (Nick 11:44): SHOW_COST back on, new card_border.gdshader (obsidian, brass hairline and fillet, hunter line, corner studs), name ribbon darkened; grader PASS; tests green, pushed.

- 2026-09-30 11:48 EDT — builder: intent badge moved to the HUD on Nick's word (09:44): intent_hud_pos pins it top centre in a hud_style panel (red edge on hostile), INTENT_ON_HUD skips the crown tracking + test; grader FAIL (one frame) then PASS on 2x2 strips; tests green, pushed.
- 2026-09-30 11:24 EDT — builder: cards fan and glow removed on Nick's word (09:44): reverse of 3aec5e3 (set_raised rim, foil.gdshader rim mode, pip_pulse) kept with remove-cost; fan/tilt/lift kept (predate the item, lift carries touch timing) + test; grader FAIL (wanted the fan gone too), shipped 👀 to ask; tests green, pushed.
- 2026-09-30 11:10 EDT — builder: remove cost on Nick's word (10:59): CardView.SHOW_COST/shows_cost gate the framed gem, borderless gem and rail number; energy rule untouched + test; grader PASS; tests green, pushed.
- 2026-09-30 11:02 EDT — builder: HUD redesigned after Slay the Spire on Nick's word (09:44): unit_bar.gd under each hunter and in party rows, beast plate under its feet, frameless intent, pile_badge.gd stacks, amber End Turn pill, obsidian_box.gd deleted + test; grader FAIL x2 then PASS; tests green, pushed.
- 2026-09-30 10:39 EDT — builder: low-health heartbeat vignette removed on Nick's word (09:44); jackal ember stream and `hp` command kept; grader FAIL (wanted a steady edge), shipped 👀 for Nick; tests green, pushed.
- 2026-09-30 10:25 EDT — builder: jackal threat reverted on Nick's word (09:44): c5c33bd undone by hand (threat statics, _update/_step_threat, HeadTrack, toon heat, growl sfx+ogg, test); low health keeps the glow list via _rig_glow/_step_low_health; grader PASS; tests green, pushed.
- 2026-09-30 10:11 EDT — builder: hits stop time removed on Nick's word (09:44): reverse of 991b33c in combat_3d.gd and run_tests.gd (hit-stop, slow motion, ember burst, hit_shake/tilt, _hunter_struck); beat=impact harness rewritten for the plain strike; grader FAIL on the pre-existing strike shake, shipped 👀; tests green, pushed.
- 2026-09-30 09:56 EDT — builder: hop swing reverted on Nick's word (09:44): swing state, HOP_SWING_*, hop_swing/hop_swing_vec/_hop_landed and its test removed, _apply_orbit back on _pivot; harness touch= kept; grader FAIL then PASS; tests green, pushed.
- 2026-09-30 03:29 EDT — builder: a sky with ash (quarry_ember `ash_sky`; ash_sky.gdshader sky shader: fbm ash on a flat ceiling, red lower rims, 9 s glow swell, gradient-only cubemap pass; _light_for swaps it in and restores the plain sky; 1 test); grader FAIL x3 (sky notch too small to read clouds), shipped 👀; tests green, pushed.
- 2026-09-30 03:15 EDT — builder: embers in the air (quarry_ember `embers`; ember_field/seam_points; EmberField: 500 rising soft sparks, 8 seam omni lights at 3.4 R on a new SEAM_LIT_LAYER that takes the Wall off LAVA_LIT_LAYER (Compatibility 8-light cap), a spark drip per seam + 2 tests); grader FAIL then PASS; tests green, pushed.
- 2026-09-30 03:04 EDT — builder: lava ring (quarry_ember `lava` [1.0, 2.5] R; lava_ring/lava_ring_mesh + lava.gdshader polar flow; 8 omni lights on LAVA_LIT_LAYER so the cast stays unlit; heat_shimmer.gdshader band past CAMERA_MAX_R; obsidian rim heat faded near the lens + 3 tests); grader FAIL x3 (rim floor not orange), escalated 👀; tests green, pushed.
- 2026-09-30 02:40 EDT — builder: lava rock stones (lava_rock.gdshader: dark basalt x ROCK_DETAIL, emission on world-down faces + fresnel edge; stone_style/`"stone": "lava_rock"` on quarry_ember only, body+cap take it, ember rim kept + test); grader FAIL x2 (too orange, then Goblin off-frame), escalated 👀; tests green, pushed.
- 2026-09-30 02:29 EDT — builder: obsidian floor (obsidian.gdshader: near-black base, view-space reflected sheen band, px-clamped Voronoi crack hairlines; floor_style/_dress_floor on env Floor + Ground for quarry_ember only + test); grader FAIL then PASS; tests green, pushed.
- 2026-09-30 02:10 EDT — builder: climb gauge in obsidian (carved panel 84x372, groove rail, ember-halo ledge notches, 5-ring burning sigil wider than a pip, portrait pips r13 in slot-tint rings via snapshot `portrait`, static gauge_y + test); grader PASS; tests green, pushed.
- 2026-09-30 01:59 EDT — builder: intent badge reads like a warning (24 pt, 3 px red rim, 34 pt move icon via intent_badge_bbcode, crown from projected box top, clears both hunters + 2 tests); grader PASS on round 3; tests green, pushed.
- 2026-09-30 01:40 EDT — builder: cards fan and glow (fan/tilt/lift already there; foil.gdshader rim mode, CardView.set_raised builds an ember-gold rim 10 px past the card, called from _layout_hand; cost gem breathes 1.0-1.1 via pip_pulse while playable + 2 tests); grader PASS; tests green, pushed.
- 2026-09-30 01:25 EDT — builder: beast HP bar reacts (beast_bar.gd overlay: notches per weak_point_threshold + hurt_pct line, 0.4 s ghost + drain, crack on crossing; hurt_pct in snapshot; beat=loop lands an 18 blow; tests); grader PASS; tests green, pushed.
- 2026-09-30 01:13 EDT — builder: carved-obsidian HUD (obsidian_style + ObsidianBox bevel wrapper `carved`, hud_font FontVariation w/ fallback; top bar, party cards, intent badge, energy orb, End Turn/Switch + test); grader FAIL x2 then PASS; tests green, pushed.
- 2026-09-30 00:56 EDT — builder: low health (console `hp N` / `hp beast N`; is_low_hp <30 %, vignette_alpha heartbeat ColorRect under the HUD, beast_low_glow hotter+2.4 Hz breath in _step_threat, LowHpEmbers CPUParticles3D stream over the beast box + test); grader PASS; tests green, pushed.
- 2026-09-30 00:48 EDT — builder: jackal threat between turns (beast_threat/threat_focus/head_yaw_to/intent_badge_scale/growl_now + test; HeadTrack neck/head modifier, gain 8; toon `heat` uniform + glow_gain x(1+3t); badge 1+0.18t heartbeat; growl.ogg); grader FAIL x3 (head unseen behind stones; body-turn try reverted), escalated 👀; tests green, pushed.
- 2026-09-29 23:38 EDT — builder: hop swing: _hop_landed callback at each touchdown sets _swing_vec (hop's screen-sideways travel x0.2, cap 0.5) and a 0.15 s sin bump offsets the orbit pivot (hop_swing, hop_swing_vec + test); harness touch=K,S freezes S s after the K-th touchdown without snapping; grader FAIL (graded the overshoot pair, wanted the done-when strip) then PASS; tests green, pushed.
- 2026-09-29 23:14 EDT — builder: climb zigzag (route_pos inner rungs +-ZIGZAG_WIDTH 2.0 H, outward first; zigzag_along keeps hops even; _turn_toward faces the next stone); graded on state=3d; grader FAIL x2, escalated 👀; tests green, pushed.
- 2026-09-29 22:51 EDT — builder: top item (lunge 25% slower) was already pushed in a460aed but left without 👀; marked 👀, no rebuild so it is not slowed twice.
- 2026-09-29 22:41 EDT — builder: lunge/flinch 25% slower (hunter_act_beat x1.25, test pinned); harness beatat= fixed-clock cropped strip; grader FAIL then PASS; tests green, pushed.
- 2026-09-29 22:32 EDT — builder: dev camera freed: wheel floor 4.0 to 0.5 then dolly past it (dev_zoom, dev_dolly), WASD 1.0 x max(dist,6) + Shift x3 (dev_fly_speed), pivot clamp to the wall and 1.5R up (dev_pan_clamp); harness devzoom=/devorbit=/devfly=; grader FAIL x3 (speed unseen in stills), escalated; tests green, pushed.
- 2026-09-29 22:12 EDT — builder: Frog tongue on the attack lunge (HUNTER_TONGUE, _aim_tongue riding the lunge tween, arced 0.05 so it reads from behind the Frog, tongue_point static + test); grader PASS; tests green, pushed.
- 2026-09-29 21:52 EDT — builder: jackal matte item, Nick said matte enough; no code change, marked 👀 for his tick.
- 2026-09-29 21:36 EDT — builder: drag road clear of every tap (road_clearance, ROAD_CLEAR 75), tap after the drag leads on (drag_leads), rings never touch (NOTE_GAP 92), 12 px air off the hunter and road off them too, whole-walk retry (NOTE_WALKS 32); 3dosu waits 1 s for hops before the tap; grader FAIL then PASS; tests green, pushed.

- 2026-09-29 21:11 EDT — builder: card flight reverted on Nick's word (20:59): flying copy, CARD_FLY_S, _fly_card_then/_land_card_now/_card_goal/_block_ring gone, every play path calls play_card on the tap; harness fly= just taps, flyt= ignored; grader PASS; tests green, pushed.
- 2026-09-29 19:24 EDT — builder: fog behind the exterior: quarry_ember switched to depth fog via fog_behind [6,10] radii (fog_behind_range, min 5.5 R past the far wall), peak 0.6; other biomes reset to exponential; grader PASS; tests green, pushed.
- 2026-09-29 19:11 EDT — builder: jackal matte: SURFACE_FINISH spec_strength 0 on the jackal's toon body (the hard spec band lit whole head facets pale); rim left; grader PASS; tests green, pushed.
- 2026-09-29 18:59 EDT — builder: 3dstrike no longer pauses the beat in play (strike_holds_beat); new beat=loop runs lunge/flinch from the ground, labelled 2x2 shot with widened lens; grader FAIL then PASS; tests green, pushed.
- 2026-09-29 18:44 EDT — builder: timing notes floored at the hand top (notes_floor, _hand_top, pattern_shove floor) and kept off the hunter (note_pattern avoid, NOTE_BESIDE 1.15); harness rest=1 + lowest-note line; old 5/12 rolls over the hand, new 0/14; grader FAIL then PASS; tests green, pushed.
- 2026-09-29 18:23 EDT — builder: grip clock item: grip timer already off since 17:26 (GRIP_TIMER_ON=false); verified 3dgrip GRIP-OFF OK, no bar, no slip; no code change; grader PASS; tests green, pushed.

- 2026-09-29 18:09 EDT — builder: jackal's turn: body lunge (rear back in hold, 35% of gap toward bitten hunter on the bite, home by the hand, pitch + x drift), hunter damage number up and aside; Ask reworded for Nick; grader FAIL x3 (wind-up unreadable), escalated; tests green, pushed.

- 2026-09-29 17:42 EDT — builder: "the card is stuck" was the harness: fly= froze the flight and disabled the view in `play` too; fly_holds_midair(play, flyt) + test; fly=N,M with flyt=1 shoots a mid-flight | landed strip on the real clock; failsafe +5 s per flown card; grader FAIL x3 (flight vs scale-up in stills), escalated; tests green, pushed.

- 2026-09-29 17:26 EDT — builder: grip mechanic off (Nick 17:14): Coach.GRIP_TIMER_ON=false read by combat_3d; no timer starts, bar hidden, no fall, "hanging!" and coach grip tip gated; timer code kept; harness 3dgrip prints GRIP-OFF; grader FAIL (hanging! tag) then PASS; tests green, pushed.
- 2026-09-29 17:19 EDT — builder: playtest.cmd green: 1 red check left, beast-behind-stone 21, all in the Goblin's view (new since the playtest presses Switch); stones 5-7 = Goblin's own first three, 19-47% pixel; Frog's own line <= 11%; routes mirror-symmetric (x -5.27..-3.87 vs 3.13..1.73 about box centre -1.07); no code change, escalated as a taste call; tests green, pushed.
- 2026-09-29 17:04 EDT — builder: drag slot rolled per play (drag_order, note_pattern drag_at), HitCircle tap-drag-tap, circle z 100 over the hand, NOTE_RISE 100, lookahead floor + dark disc; grader FAIL x3 (drag ends touch card tops), escalated; tests green, pushed.
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
