# Tasks

The live list. Top unchecked item is the next one. Short lines; the reasoning
lives in [[DECISIONS]], the traps in [[LEARNINGS]].

Nick adds items anywhere in **Now**; order is priority. Check an item off with
its commit hash.

## Now — make the fight fun

The art target is reached (2026-10-12). The goal is no longer a picture.

- [x] **Write the playable minute** — [[PLAYABLE-MINUTE]]. Ten checks, each
      something you can watch happen. It replaces TARGET.png as the thing we
      build toward.
- [ ] **Play the minute and say which checks fail, in order.** Five of the ten
      are Nick's to judge; no agent marks those passed.
- [x] **Pull the fight's numbers into one config file** — `game/core/feel.gd`
      holds the grip bar and the sweep window as `static var`, so they can be
      changed in the RUNNING game (`godot_exec: Feel.SWEEP_SPEED = 1.4`) and
      felt without a relaunch. The digest reports them. Camera lag and the
      impact timings are still scattered; move them when one of them is
      actually in question.
- [ ] **Make `playtest.sh` the feedback, not a screenshot.** It already drives
      real turns. Have it record a trace — timing, hit-stop, what each turn did
      — so a change can be compared across runs by something other than a still
      frame.
- [ ] **Split `game/views/combat_3d.gd`** (~4000 lines) into camera, route and
      hand. It is past the size where an agent can hold the whole file.
- [x] **Two HP bars in the world** — in solo both hunters' bars floated at once.
      Only the hunter you hold carries one now; the other's health is in the
      party row. Same rule the stones already used.
- [x] **The cone over each hunter's head** — gone (`HUNTER_PIP`). It existed so
      a hunter stayed findable while the camera orbited behind the beast; the
      camera no longer goes there.
- [x] **The climb camera ends up inside the jackal.** At the sigil the beast
      fills the whole frame and nothing reads — see
      `design/shots/2026-10-20-climb-too-close.png`. Nick, 2026-10-20: "the
      camera positioning gets too close to the jackal when you climb. I think
      the stones should be farther away from the jackal."
- [x] **The jackal stands halfway into the arena.** It should sit on the EDGE
      of the ground, not in the middle of it.
- [x] **The ground is a mess.** Make it one consistent surface, and remove the
      wall/slab the jackal is standing on.
- [x] **Nick's 2026-10-21 list, the second time** — 7538e1b9. The clean
      jackal was never on screen: the fight draws the rig's seven part layers,
      not `cinder_jackal_2d.png`, and those were still cut from TARGET.png (the
      wall on its left, the stone outlines on its belly, the glow round the
      flame). `tools/beast_recut.py` cuts them from the clean sprite. The
      beast stands IN the lava, past the ground's edge and sunk to its feet
      (`DRAWN_LAVA_STAND` / `DRAWN_LAVA_SINK`; the first try's 0.9-height
      push-back left it on dark floor); both staircases draw. Then bigger
      (`DRAWN_LAVA_ZOOM` 1.6), the far wall fading to sky instead of black,
      the follow camera lined up on the drawing's real place, and the stones
      back to the low-poly hull (`STAIR_SLAB_GEOMETRY`). Shots:
      `design/shots/2026-10-21-big-rest.png`, `-climb.png`.

- [ ] **Decide what the arena IS** — [[LOOK-DEBT]]. Not re-matching: how wide,
      how deep, what is behind the beast, where the stones hang and what holds
      them. The seam at the square's edge (x=279, measured), the dead flanks
      and the lens-facing slabs are all the same root: a painting's
      compositional cheats copied into a camera-driven scene.

## Later

- [ ] Traversal co-op (the one piece of the 3D pivot still open).
- [ ] Steam capsule art — marketing, worth commissioning rather than learning.

## Questions for Nick

Nothing open.
