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
- [ ] **Stones: first one in front of the hunter, last one in front of the
      beast's head.** Today the stones sit as a cluster beside the jackal's
      left flank, floating at chest height, and the ground between the Frog
      and the jackal is empty. Nick's arrows: the first stone lands just
      ahead of the active hunter, on the ground he is standing on; the
      staircase climbs the gap; the last stone is in front of the jackal's
      head. Project each stone to screen and check it: first stone's screen
      position is between the Frog and the beast, low; last stone overlaps
      the head. Do not move the beast, do not shrink it. Shot: `state=3d`,
      then the same shot beside his drawing.
- [ ] **Hops land on stones, not in the air.** Nick's frame
      `art/references/2026-09-25-nick-hopping-in-air.webp`: the Frog climbs
      to points in open air beside the jackal while the stones sit on the
      ground behind it. Every climb hop ends with the hunter's feet on a
      stone of the route, at every height, for both hunters. The playtester's
      `hunter-on-stone` check and the floating-Frog tickets (#34, #36, the
      2026-09-25 one) are the same bug seen from the tool side. Shot:
      `state=3dclimb` and `state=3dgrip`, feet on stone in both.
- [ ] **One locked camera, resting and climbing.** Two frames from Nick:
      at rest, "zoom out" (`art/references/2026-09-25-nick-stones-and-zoom.webp`);
      mid-climb, "camera closer, should be locked to character"
      (`art/references/2026-09-25-nick-climb-camera-closer.webp`, the Frog a
      speck on the chest with the camera parked wide on the beast). Same
      rule in both: the camera sits a fixed stand-off behind the ACTIVE
      hunter, wherever the hunter is, hunter's back bottom-centre, and it
      follows every hop. At rest that means further back than today; on
      the beast it means much closer than today. Do not shrink or move the
      beast. Shot: `state=3d` and `state=3dclimb` side by side; the hunter
      must be the same size on screen in both.
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
