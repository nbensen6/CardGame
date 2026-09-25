# Builder queue

One ordered list. The builder (`tools/builder/BRIEF.md`) does the **top
unticked item** and nothing else. Nick reorders, adds, deletes, and ticks.

- `[ ]` open · `[?]` built, waiting for Nick to look · `[x]` Nick says done

Every item names the shot that must change. If the shot does not change, the
run failed.

## Now — the Cinder Jackal fight

- [ ] **Camera toggle Nick can find.** The Player/Dev button exists in the
      fight menu's keybind panel, and Nick still sees the free camera through
      `dev.cmd`. Find out why (suspect: `screenshot.gd` sets Dev on the real
      config slot and it sticks). Make Player the state he lands in, and bind
      one key (F8) that flips Player/Dev live with a one-second HUD label
      saying which. Shot: `state=3d` — locked third-person, hunter's back at
      bottom-centre.
- [ ] **Nick judges the 2026-09-25 camera and stones** — *waiting on Nick.*
      Run `tools\dev.cmd`, fight the jackal, compare against the drawing.
      Answer: is the gap right, is the staircase right, is the lens right.
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

