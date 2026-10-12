# Builder proposals

Things the builder noticed and did not do. Nick moves a line into
[[BUILDER-QUEUE]] under Now to make it real, or deletes it. The builder
appends here, never to the queue.

- [ ] (proposed) The "screenshot.gd sets Dev on the real config slot and it
      sticks" suspicion from the camera-toggle item didn't hold up: it
      redirects to a scratch config before ever touching dev_camera_enabled,
      and the real user://progress.cfg on this machine has no such key. The
      Player-by-default fix already landed 2026-09-24 (fixer); nothing to do
      here unless it resurfaces.
- [ ] (proposed) F8's new HUD note (top-centre, shared with F9's) can overlap
      the boss intent badge when one is showing. Cosmetic; low priority.
- [ ] (proposed) The in-fight settings panel's own Camera button label goes
      stale if F8 is pressed while the panel is open (fixes itself on next
      open/close). Cosmetic; low priority.
- [ ] (proposed) Rungs 1-4 of the stone route still collapse to nearly one
      screen point near the jackal — the camera (dist=3) sits almost on top
      of rung 0 while the route's far end (the sigil) is ~80 world units
      away, so everything past the first rung reads as "far" in near-equal
      measure. Re-check once the queued zoom-out item lands; if it's still
      collapsed, the route's near end may need to stop anchoring to the
      hunter's real (very distant) ground stance.
- [ ] (proposed) CHEST_CLEAR_PUSH is zeroed (was throwing rung 0 off-screen
      under the locked cam). The beast-chest-overlap problem it was added to
      fix (#0658) was never re-measured under `state=3d` — worth checking
      once the camera work settles, rather than assuming it's still needed
      at its old value.
- [ ] (proposed) Re-check the stone route's rungs 1-4 (the "collapse to one
      screen point" item above) against the new dist=6 rest shot — the old
      note was measured at the pre-fix dist=3.
- [ ] (proposed) The climbing camera's beast-clearance term
      (`climb_dist_for`) still measures "how deep is this hold in the mesh"
      off the whole model's own AABB front face (`_beast_box.end.z * 0.85`),
      tuned for grounded-hunter framing, not for a hold already ON the
      body. At weak_point_height (state=3dclimb's own test scenario) that
      clearance is ~13 units on top of the fixed 6, so the hunter reads
      much smaller there than at rest, even though the general rule (one
      fixed stand-off, closer than the old window-fit) is working. The
      weak-point-shot queue item below should measure this directly rather
      than assume the general fix already covers the top hold.
      **Builder, 2026-09-25 16:11 EDT:** tried feeding `climb_dist_for` the
      hold's own local surface (`_front_of_beast` at the hunter's column)
      instead of the box's front face — only dropped the clearance from ~13
      to ~11 (dist 19.4→17.0), not the near-zero an exact-rung anchor should
      need. See the two items directly below.
- [ ] (proposed) `_front_of_beast`'s 5x3 hull neighbourhood, queried at the
      sigil's own (x, y), still reads ~13.6 even though the sigil's authored
      anchor z is 0.53 — almost certainly the jackal's head/neck passing
      through the same column, the same shape of contamination the
      "ear"/"muzzle" bugs hit (see `hull_front_at`'s own doc comment).
      `stand_z_for` already dodges exactly this for exact-rung footholds by
      trusting the anchor's own z and never asking the hull
      (`stand_needs_hull_clearance` returns false for them). The climbing
      camera's clearance term should probably do the same: for an exact
      rung, use the hold's own anchor z (clearance ~0) instead of
      `_front_of_beast`, and reserve the hull query for interpolated
      footholds only, if any of those ever reach `_focus_camera`.
- [ ] (proposed) Nick's own suggested read on the sigil shot ("the camera
      may sit above the hold looking down at the head") is a different
      aim/pitch at the weak point, not just less clearance distance —
      probably belongs in the "Weak-point shot" item below rather than this
      one; the two should be looked at together once that item is up.
- [ ] (proposed) With clearance and pitch fixed at the sigil (dist 17.0→8.0,
      pitch rising with climb_t), the after frame shows an ear/jaw silhouette
      against the sky, not a face — the eyes never come into frame at whatever
      yaw the camera already had. The Weak-point shot item should check
      whether `_yaw` needs its own rule at the top hold (facing the actual
      front of the head) rather than just carrying over whatever yaw the
      climb was already at.
- [ ] (proposed) `_stand_on_model`'s `side` parameter is now unused inside
      the function — the top-hold branch (its only reader) was switched to
      `route_side` this run (#26). Harmless (every call site still compiles,
      the two callers that pass a real `side` just no longer have it read),
      but a future cleanup could drop it from the signature and its three
      call sites, or fold it into a doc note explaining why it is still
      passed.
- [ ] (proposed) Mid-route footing on the "hops land on stones" item (#26):
      checked hunter1 (weak_point_height-1, not the top) with
      `state=3dclimb slot=1` — it stands near the jackal's front leg, not
      obviously centred on its own decorative stone. The lateral math for
      that branch (`route_pos_cleared` via `route_side`) was already correct
      before this run's fix, so this may be a real second bug or may just be
      a hard-to-read camera angle; worth a dedicated look with a render zoomed
      on that hunter before assuming either way.
      **Builder, 2026-09-25 17:15 EDT:** with the hull-order fix, hunter1 in
      `state=3dclimb slot=1` now stands visibly ON its own stone (the AFTER
      frame on this same run's item, above) — looked resolved, but not
      re-measured at THIS specific mid-route height, so leaving this open
      rather than closing it myself.
- [ ] (proposed) `tools/shot.cmd`, run with a RELATIVE `out=` path from a shell
      whose working directory isn't the repo root (confirmed with the Bash
      tool, which runs Git Bash under Windows), fails to save: Godot logs
      `ERROR: Can't save PNG at path: '<relative path>'` from `img.save_png()`
      at `screenshot.gd`'s `_capture()`, but the very next line unconditionally
      prints `SHOT SAVED: <path> (WxH)` regardless of whether the save actually
      happened — there is no check on `save_png`'s return value (`Error`, 0 on
      success). This run's first before/after pair silently reused an already-
      committed frame from an earlier commit (same path, save failed both
      times, old bytes never touched) and only an `md5sum` against `git show
      HEAD:<path>` caught it — eyeballing the "before"/"after" images looked
      convincing because they WERE real images, just not from this run. An
      absolute `out=` path (e.g. `G:/ts-builder/design/...`) saves correctly.
      Fix: `_capture()` should check `img.save_png(_out)`'s return value and
      print an actual error (or refuse to print "SHOT SAVED") on failure, so
      a future run can't ship a stale frame as proof without an extra hash
      check nobody is required to run.
- [ ] (proposed) Two `state=goblin` screenshots of the *identical* game
      state (no code or asset change between them) differ by roughly 43,000
      of 921,600 px, all in the background tent/box scenery to the left of
      the hunters — not the small idle-animation jitter (ember pulse, sway)
      this project's notes usually attribute frame-diff noise to. Worth a
      look before it's mistaken for a real change in some future before/after
      pair: isolate the diff to the subject's own bounding box, the way this
      run had to, rather than trust a full-frame pixel count.
- [ ] (proposed) `hunter-off-marker`'s TOP branch (a foothold AT or PAST the
      route's top rung — a hunter that hops past the sigil, e.g. Leap or
      Grappling Hook landing beyond weak_point_height) still measures the
      hunter ~1.7-2.6m off its own expected x, byte-identical before and
      after this run's route/top-z fix, so it's a separate bug in the check's
      dynamic shared-foothold `side` logic (line ~732 of playtest.gd), not
      the route-vs-anchor mismatch this item targeted. Worth a dedicated
      look with the harness's STONE/HUNTER/RUNGS print at a foothold past
      the top, the same way the "hops land on stones" item measured its bug.
- [ ] (proposed) Every other playtest check that judges "the settled frame"
      (`beast-behind-stone`, `hunter-offscreen`, the framing checks) was
      sampling the same too-early instant `camera-not-over-shoulder` was, and
      now sees a camera that has actually finished easing. Their counts may
      have shifted for that reason alone — worth re-baselining each before
      reading its number as a real bug.
- [ ] (proposed) `beast-behind-stone` read 8, then 6, then 8 across three
      runs of the identical command with no change in between. That category
      is not stable run-to-run, so a single run cannot tell a fix from noise
      — it needs either a tolerance or a repeat count before it is judged.
- [ ] (proposed) **Built 2026-09-27 — see the Now item above; kept only for
      the record of what was measured.** `camera-not-over-shoulder` (9 fails on the latest
      `playtest.cmd`, every one a `_shoulder` value between 0.02 and 0.88,
      none reaching the check's own 0.95 floor): the check's own doc comment
      claims `_shoulder`'s ease (`combat_3d.gd` `_aim_camera`, rate 2.2/s)
      "reaches this in well under a second" and that "every step gives it
      several real seconds to settle" before `_check` runs. The math says
      otherwise: `1 - exp(-2.2t) = 0.95` needs t≈1.36s, and the actual
      post-action wait (`_wait_and_poll(v, 43 or 45)`) is ~0.72-0.75s at
      normal speed — under half what the ease needs, not "several seconds."
      Either the check's wait needs to genuinely grow to match its own
      stated assumption, or `_shoulder`'s ease rate / SHOULDER_ENGAGED_MIN
      were tuned for a shot Nick approved and only the TEST's timing
      assumption is stale — didn't touch the gameplay-feel constants this
      run without asking, same caution every camera flip in this file has
      needed. Not yet tried: instrumenting one real step to confirm `delta`
      actually behaves as this arithmetic assumes (headless rendering may be
      slower than 1/60s/frame, which would change the numbers).
- [ ] (proposed) `beast-behind-stone` (5 fails, always "stone 7" at
      15.6-18.3% pixel coverage against a 15% cap): almost certainly the
      same trade-off the "CHEST_CLEAR_PUSH is zeroed" proposed item below
      already named — that push existed to keep a rung's stone off the
      beast's chest (#0658) and was zeroed this session to fix rung 0
      landing off-screen. Re-tuning it risks reopening the off-screen bug it
      was zeroed to fix; needs someone to check both frames together, not a
      number bumped blind.
- [ ] (proposed) **`hunter-offscreen` built 2026-09-27 18:39 EDT, see the Now
      item above: the cause was `_focused` staying false through the first
      climb, not the establishing shot.** `hunter-offscreen` (4 fails, all early-game non-climb
      actions — Tongue Snap/Scramble/Tongue Snap again — projecting to
      y=-217..-868, nowhere near the 0..720 screen), `hunter-lost-mid-hop`
      (1 fail, hunter off-screen 84% of its own jump), `damage-popup-
      offscreen` (1 fail) and `intent-tag-vs-hunter` (1 fail): not
      investigated this run past confirming they survive the
      `_watch_hop`-tween-completion fix above (counts shifted slightly
      run-to-run, likely just timing noise from that fix, not new bugs).
      `hunter-offscreen`'s extreme y values are the most suspicious of the
      four — worth checking whether the camera is still on its wide
      establishing shot (not yet locked onto the hunter) at the exact instant
      this check samples, the same "camera hasn't caught up yet" shape as the
      hunter-off-marker bug fixed this run, just on the CAMERA side instead
      of the route side.
- [ ] (proposed) `goblin_mech_ai_Image_0.png` (and the same pattern would hit
      any other `*_Image_*.png`) is gitignored as "derived, regenerable from
      the tracked `.jpg` beside it" (`8e5a27c`), but the live fight actually
      reads the PNG, not the JPG — confirmed by reverting only the PNG and
      watching the render revert. The tracked
      `goblin_mech_ai_Image_0.jpg` looks orphaned (unused by the current
      `.glb`, which embeds its own PNG). Worth deleting the stale jpg or
      correcting the gitignore comment so the next person doesn't edit the
      jpg expecting it to change anything.
- [ ] (proposed) The first hop now spends more of its flight off-screen:
      step 0's mid-hop coverage went from 0% to 18% off, because the follow
      cuts to the landing height at take-off. Step 1 improved from 22% to 4%
      off. No check fails on it; worth a look if the first take-off reads
      as a jump cut.
- [ ] (proposed) `hunter-off-marker`'s 8 current fails are mid-route
      (foothold 2 is 2.36m off in x, foothold 4 is 0.79m off), not the
      past-the-sigil top branch fixed 2026-09-25. Same symptom, different
      place; take it as a fresh bug.
- [ ] (proposed) **Frog turns its back to the camera.** With the lens now straight behind the held hunter, the Frog model still reads in profile. Its rest facing sits about 90 degrees off the beast line.
- [ ] (proposed) **Near stones hide the jackal at rest.** From hunter height at the new range, only the jackal's head clears the first two stones.
- [ ] (proposed) **Opening wide shot is still a zoom.** The fight opens on the whole beast and eases in to the follow distance. Ask Nick whether the camera should start at the follow distance.
- [ ] (proposed) **Other hunter behind the camera mid-climb.** At 3.2 units the second hunter falls behind the lens at the sigil (VIS FAIL hunter1).
- [ ] **Hunters stand wider apart on the ground.** At ±1.15 units the Goblin's own stone line falls under the climb gauge in the Frog's view.

- [ ] **Colour bible.** One note in `art/` listing every colour the game may use (sky, ground, stone, ember, each hunter, HUD), each with its light and dark version, and a rule: nothing enters the game in a colour that is not on it. From the "Stop Asking AI To Build The Whole Game At Once" video (notes/video-transcripts, 2026-09-28): their reference was daylight, the game was night, so every colour got translated once and the look stayed coherent. Ours: Nick's drawing and the RoR2 reference, translated to style C.
- [ ] **Lighting preset panel for Nick.** A dev-only panel (behind F8's Dev mode) with sliders for sun angle, sun colour, ambient, fog density and a row of presets (dusk, deep night, blizzard, sunrise, pale day). Same video: the scene's whole mood changed per preset with no art change, and the dev tuned it by eye. Cheapest atmosphere lever we have; Nick judges by eye anyway.
- [ ] **Simple shapes, let the light do the work.** Same video: "don't ask AI for realistic meshes; a house is boxes and a roof, the light does the rest." Our stones are crates today; a low-poly boulder from a Blender script (one line per piece, rerun on a fix) plus the lighting panel above may read better than any generated mesh.

- [ ] (proposed) **midair= samples drift run to run.** The same midair=0.95 lands mid-hop one run and on the stone the next, so before/after midair strips are not comparable.
- [ ] **Jackal Burn bite.** Nick 2026-09-29: rethink the jackal's damage, maybe burn. One idea: its round-3 bite (9) becomes a 5 bite that applies 3 Burn (lose 1 HP a turn per stack, stacks fall by 1 each turn), so damage lands over time and block alone does not answer it.
- [ ] (proposed) **Block sound unplayed again.** The `block` sound only rode on the reverted card flight; a Block card now plays no block sound.
- [ ] **Beast close-up for tells.** A short push-in on the jackal when the last hunter's turn begins, so head turns and glow read at all.
- [ ] **Display-font digits read oddly.** KenneyFutureNarrow draws "7" like a hook; the intent badge's number may want the body font.
- [ ] **Show more sky at rest.** Tilt or lower the rest camera so the ash clouds over the wall read.
- [ ] **Hunters move: idle, hop, attack, hit.** The Frog and Goblin are still statues; give each a rig and four short animations (after the target picture is picked).
- [ ] **Clear the climb stones off the jackal's face.** At the new closer rest camera the mid stones cover the head; route them beside it.
- [ ] **Jackal eyes too small at rest.** At 1:1 the eyes are 2-3 px; the glowing inner ears outshine them.
- [ ] **Jackal rock is red, not A's brown.** The softened texture plus the ember key still reads maroon.
- [ ] **Sigil above the climb's end.** In the jackal fight the top stone is now at the chest; the hunter strikes from ~7 units below the head's sigil.
- [ ] **Two sigil rings on the jackal's chest.** At rest two gold rings sit over the chest, under the staircase's top.
- [ ] **Float stone homes never cleared.** `_build_float_stones` clears the stones but not `_float_home`, so a rebuild indexes stale homes.

- [ ] **Flat stones and rest rocks.** The climb stones and the hunters' rest rocks keep a cobble texture beside the now-flat cliffs and floor.
- [ ] **Scene grade crushes dark colours.** Contrast 1.10 with saturation 1.18 zeroes dim channels, so every dark brown in the fight renders pure red.
- [ ] **Slab tops lighter than sides.** From the rest camera the climb slabs' tops render darker than their sides; picture A's tops are the lightest faces.
- [ ] **Matte floor.** The fight floor shows glossy grey-violet reflection patches; picture A's floor is matte charcoal.
- [ ] **Stones step across the beast.** The climb blocks rise up the jackal's left side; picture A's step across the front of its body to the chest.
- [ ] **Wide mauve sky between the cliffs.** Picture A opens a wide violet sky notch behind the beast with cliffs only at the edges; ours shows a small disc.
- [ ] **Slab shadows on a lighter ground.** A floor-plane contact shadow per slab, since a black blur is invisible on the near-black floor.
- [ ] **Brighter gold card edge.** The card frame's edge reads dull olive; TARGET's is a thin brighter gold line.
- [ ] **Card title ribbon.** TARGET's card names sit on a slanted dark ribbon; ours are flat labels.
- [ ] **Wider hand without covering the Frog's bar.** TARGET's fan spans ~70% of the frame; ours ~53%, limited by the Frog's HP bar.
- [ ] **Slab silhouettes from TARGET.** Trace TARGET's six slab outlines as fixed polygons instead of seeded random flagstones.
- [ ] **Steeper, bigger staircase.** Grader: TARGET's lowest slab is ~16% of frame width and the column climbs steeper; needs the Frog lowered first.
- [ ] **Seeded slab shapes.** Slab outlines use randi(), so every launch draws different stones; seed them per slab.
- [ ] **Bigger fist flame.** Grow the rig canvas upward for a TARGET-sized plume while keeping _fit_height on the figure, not the canvas.
- [ ] **`vs_target.py --beast` and `--hand` crops are fitted to the beast, not the square.** Map their shot boxes through the --square test (x 280+0.703t, y 0.703t) as `--stones` now is, so the close-ups agree with the 1:1 test.

- (2026-10-09 run 8) A red-edged slab stands on the floor at the 16:9 frame's right edge, outside the centred square.

- 2026-10-09 builder run 9: graders on Cracks, Fist fire and Cliffs name differences (softer, paler, hazier) that registered pixel measurements on the same pairs do not show (band colours within ~6 levels, sharpness equal or higher). A grader input that adds a registered difference map, or a 2x close-up pair for each item, may let these items close.

- 2026-10-09 builder: a control grade (TARGET.png pasted into the frame's centred square, graded with the Cracks item's text and pairs) passed, while the real frame, ~4 levels off TARGET in the chest, failed ten runs running as "half-width cracks". The item's critic sentence may prime the grader on near-identical pixels; consider giving the grader a registered difference map, or dropping the critics' words from what it reads.

- 2026-10-09 builder run 12: "Cracks: wide hot cores" failed again on the same asks; at the top of `## Now` it blocks every item under it, since the brief allows a next item only after a PASS. Retiring it, or letting the builder move on after a FAIL that measurements contradict, would unblock the queue.

- 2026-10-09 builder run 17: `tools/shot.sh` (and shot.cmd) shoot without re-importing. After `tools/beast_rig.py` rewrites the part PNGs, the shot draws the stale imported textures at the new .tscn offsets and the jackal's parts land 1-3 canvas px off; this confounds any rig experiment. Running `--import` inside shot.sh when an asset is newer than its .import would fix it. Also, run 17's "Scene lines soft" failed six grader rounds (one at size=1820x1024, TARGET's own pixels) with the same wording each time while registered measurements put the jackal at no added blur; it may need retiring or a difference-map grader input like the earlier proposals.
- 2026-10-09 (builder run 18): the rig's arm beside the fist stops ~5 TARGET px inside TARGET's outline (beast_rig.py, near the fire); the backdrop carries TARGET's outline there at rest, so a swing shows a ghost line. Extend the arm layer to TARGET's full outline.
