# Builder queue

One ordered list. The builder (`tools/builder/BRIEF.md`) does the **top
unticked item** and nothing else. Nick reorders, adds, deletes, and ticks.

- `[ ]` open · `[?]` built, waiting for Nick to look · `[x]` Nick says done

Every item names the shot that must change. If the shot does not change, the
run failed.

## Now — the Cinder Jackal fight

- [?] **Camera toggle Nick can find.** The Player/Dev button exists in the
      fight menu's keybind panel, and Nick still sees the free camera through
      `dev.cmd`. Find out why (suspect: `screenshot.gd` sets Dev on the real
      config slot and it sticks). Make Player the state he lands in, and bind
      one key (F8) that flips Player/Dev live with a one-second HUD label
      saying which. Shot: `state=3d` — locked third-person, hunter's back at
      bottom-centre.
- [x] **Nick judged the 2026-09-25 camera and stones** (2026-09-25 14:30 EDT).
      Verdict, drawn on the frame: `art/references/2026-09-25-nick-stones-and-zoom.webp`.
      Stones are wrong, camera is too close. The two items below are his answer.
- [?] **Stones: first one in front of the hunter, last one in front of the
      beast's head.** Today the stones sit as a cluster beside the jackal's
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
- [?] **One locked camera, resting and climbing.** Two frames from Nick:
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
- [?] **Climb shot at the sigil, second pass: trust the hold's anchor z.**
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
- [?] **Hops land on stones, not in the air — mid-route.** The builder's
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
- [?] **Hunters face the beast.** Nick, 2026-09-25 14:35 EDT: "want the
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
- [?] **Goblin reads at 40 px.** The Frog reads at fight size; the Goblin is
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
- [?] **Re-derive the two failing playtest checks.** `hop-distance-band` and
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
- [ ] **Weak-point shot.** Camera stays locked behind the active hunter at
      the top hold; swaps hunter on Switch. Shot: `state=3dclimb hold=top`
      (check the harness for the exact hold name).

## Waiting on Nick

The builder skips this section. Answer here or in Home; the item then moves
into Now.

- [ ] **DECISION, waiting on Nick: big Frog or visible stairs?** Measured
      2026-09-25 17:05 EDT with the stones printed to screen: the route IS an
      even staircase in the world (z 81, 65, 49, 33, 17; y 1 to 15), but from a
      camera 6 behind a hunter standing 85 units from the beast the whole
      staircase lands in 40 screen pixels, edge-on. A sweep of every camera
      distance, height and pitch found none that keeps the Frog above the
      cards, the beast in frame, AND the stones 25 px apart. Two frames:
      `agents/frames/builder/2026-09-25-stairs-a-beast-far.png` (as built: Frog
      big, beast whole and far, stairs edge-on) and
      `agents/frames/builder/2026-09-25-stairs-b-beast-near.png` (hunters 3
      beast-lengths away instead of 5: stairs read as stairs, beast's head off
      the top). Pick one, or say "stairs AND whole beast, Frog can be small"
      and the builder raises the camera. Nothing below moves the stones until
      this is answered.

## Open decisions, with the default the builder takes if Nick says nothing

- #14 stones: five per hunter, as built.
- #19 gap vs lens: keep the gap, narrow the lens until the beast fills the
  upper two-thirds.
- #23 boulder shape: plain rounded boulders, no flat top, no orange rim.
- #27 weak-point shot: locked behind the active hunter, beast untouched.

## Later — beast rollout (AI pipeline, see `tools/builder/BRIEF-art-rollout.md`)

Do not start until the jackal fight is ticked. One beast per run through
`design/guide/ai-beast-recipe.md` and `tools/blender/ai_beast.py`.

- [x] `cinder_jackal` — the template
- [ ] `crag_pup`
- [ ] `bramble_hog`
- [ ] `boulder_ram`
- [ ] `yoke_ox`
- [ ] `grove_bear` (elite)
- [ ] `flicker_stag` (elite)
- [ ] `glyph_tortoise` — check the sigil raycast lands on the head, not the shell

Non-quadrupeds need a new body plan in `ai_beast.py`; ask first.

## Proposed (found by the builder, not yet ordered by Nick)

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
- [ ] (proposed) `goblin_mech_ai_Image_0.png` (and the same pattern would hit
      any other `*_Image_*.png`) is gitignored as "derived, regenerable from
      the tracked `.jpg` beside it" (`8e5a27c`), but the live fight actually
      reads the PNG, not the JPG — confirmed by reverting only the PNG and
      watching the render revert. The tracked
      `goblin_mech_ai_Image_0.jpg` looks orphaned (unused by the current
      `.glb`, which embeds its own PNG). Worth deleting the stale jpg or
      correcting the gitignore comment so the next person doesn't edit the
      jpg expecting it to change anything.
