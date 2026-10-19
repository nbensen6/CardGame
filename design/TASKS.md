# Tasks

The live list. Top unchecked item is the next one. Short lines; the reasoning
lives in [[DECISIONS]], the traps in [[LEARNINGS]].

Nick adds items anywhere in **Now**; order is priority. Check an item off with
its commit hash.

## Now — make the fight fun

The art target is reached (2026-10-12). The goal is no longer a picture.

- [ ] **Write the playable minute.** 5–10 observable behaviours for the Cinder
      Jackal: what the player does each turn, what creates tension, what a loss
      feels like. One page. This replaces TARGET.png as the thing we build
      toward, and it is checkable by playing.
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
- [ ] **Close the scene seam** left by the square: the cliffs still stop at the
      old 720 boundary, so a 16:9 window shows the edge of the set.

## Later

- [ ] Traversal co-op (the one piece of the 3D pivot still open).
- [ ] Steam capsule art — marketing, worth commissioning rather than learning.

## Questions for Nick

Nothing open.
