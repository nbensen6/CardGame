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
- [ ] **Hops land on stones, not in the air.** Nick's frame
      `art/references/2026-09-25-nick-hopping-in-air.webp`: the Frog climbs
      to points in open air beside the jackal while the stones sit on the
      ground behind it. Every climb hop ends with the hunter's feet on a
      stone of the route, at every height, for both hunters. The playtester's
      `hunter-on-stone` check and the floating-Frog tickets (#34, #36, the
      2026-09-25 one) are the same bug seen from the tool side. Shot:
      `state=3dclimb` and `state=3dgrip`, feet on stone in both.
- [ ] **Hunters face the beast.** Nick, 2026-09-25 14:35 EDT: "want the
      characters to face the beast." In the frame the Frog and Goblin stand
      side-on to the camera. At rest, after End Turn, after Switch, both
      hunters face the jackal (backs to the camera, per the Risk of Rain 2
      shot). Shot: `state=3d`, both hunters visible.
- [ ] **Goblin reads at 40 px.** The Frog reads at fight size; the Goblin is
      noise. Same treatment that fixed the Frog: fewer, bigger colour regions,
      one silhouette read (the pack? the goggles?). Shot: `state=goblin`,
      crop both hunters at 1:1.
- [ ] **Re-derive the two failing playtest checks.** `hop-distance-band` and
      `hunter-off-marker` measure the beast's authored anchors, not the stone
      route. Measure the route, or delete them. Shot: none — this one is
      `ALL TESTS PASSED` plus a green `playtest.cmd`.
- [ ] **Weak-point shot.** Camera stays locked behind the active hunter at
      the top hold; swaps hunter on Switch. Shot: `state=3dclimb hold=top`
      (check the harness for the exact hold name).

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
