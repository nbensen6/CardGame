# Task Queue

Nick's continuous task list for Claude. **How it works:**
- Add tasks under **Inbox** — one `- [ ]` line each, any order, any device
  (easiest from your phone: GitHub app / github.com → edit this file → commit).
- Tell Claude "work the task list" (or run `/loop 10m work the next task in TASKS.md`
  to have it poll and work continuously). Claude pulls, takes the TOP unchecked
  task, does it, checks it off with the commit hash, pushes, and takes the next.
- Vague is fine ("the reward screen feels bad") — Claude will interpret, and ask
  in **Questions** below if truly stuck rather than stalling.

## Inbox
- [ ] **depth plan** (see `design/depth-plan.md`) — ~~(1) the MAP~~ ✅ `f301e06` (branching routes, fight/elite/rest/treasure/boss nodes, 6 lesser beasts). ~~(2) deck transformation~~ ✅ `18656c7` (campfires: rest/thin/sharpen; upgrades; skippable rewards). ~~(4) rule-changing relics~~ ✅ `c10a366` (26). Map follow-ups: ~~edges~~ ✅, ~~events~~ ✅ `a7ae962`; still open: shop nodes (needs gold). ~~(3) fight variety~~ ✅ `d31c629`, ~~(5) archetype pools~~ ✅ `358bf5d`, ~~(6) ascension ladder~~ ✅. **Depth plan complete.** Balance pass done `692a453` (sim now models human timing/falls; naive 7% / coord 78% / A8 20%). Onboarding done `f30052c`. Shops + gold done `f1786d6` (and caught a real relic-pool bug, `0d5f8ec`).
- [ ] **art direction** — the last M1 gap and yours to call: commission, learn Inkscape, or style-lock. See `design/depth-plan.md`.
- [ ] playtest: does the difficulty *feel* fair now? The sim says balance, not fun. Next: (2) deck transformation: card removal + upgrades + skip-reward; (3) fight variety: quick non-titan fights that twist the climb; (4) rule-changing relics (~30); (5) per-class archetype reward pools; (6) ascension ladder
- [ ] **3D pivot** (see `design/3d-pivot.md`) — ~~prove the architecture~~ ✅, ~~3D combat feel~~ ✅ `167fb10`, ~~the overworld (walk a hex island to choose your route)~~ ✅ `5bf3550`, ~~one 3D loop via a phase router~~ ✅ `728027d`. Parity closed since 3D became the default: ~~grip timer~~ ✅ `475ebe1`, ~~multi-pick cards~~ ✅ `3132928`, ~~party/relics/gold HUD~~ ✅ `3b5530f`, ~~coach~~ ✅. Still open: the combat log in 3D; traversal co-op; whether to retire the 2D client.
- [ ] *(standing)* continually look through assets to use — finds so far: menu reskin `c4140ba`, strike/shake juice `5d9d09f` (burst flash + dust + arena judder); ambient music `e5fb47e` (menu=Flowing Rocks, combat=Retro Mystic — swap assets/music/*.ogg to change); emotes `e4285f7`; HUD fantasy-frame skin `da743f8`. Queue empty — next finds will be my own proposals (noted here before building)
## Questions from Claude
- **Art direction** is still the open call (see the `art direction` task): commission,
  learn a tool, or style-lock on Kenney. The 3D pivot narrows this a lot — the
  Hexagon Kit + Cube Pets already look like one game, which the 2D mix never did.
- **Combat camera**: fixed cinematic angle (Final Fantasy style, what it does now),
  or free orbit?
- **Does the real-time grip timer stay real-time in 3D**, or become a turn-based
  resource now the fight is more deliberate? It's ported and working either way.

## Done
- [x] composition overhaul — beast is the play space — `8e519df` (hunters climb ON the beast, glowing weak point, route line; abstract ladder removed)
- [x] Grappling Arm only playable when it can pull — `caf4be9` (requires an ally below you within reach; greys out otherwise)
- [x] hand header as character symbol — `8b2703b` (portrait above the hand; text only for turn-ended/selection states)
- [x] switch characters while the climb timer runs — `9181605` (per-hunter grip timers; Switch enabled mid-climb, both timers drain at once, grip bar names whichever hunter it shows)
- [x] boss attack intent as icons — `984cd87` ([beast] [sword] [value] → [target portrait]; sweeps show both hunters)
- [x] max time on timed cards + faster sweeps — `373b544` (2.5s window, expire = fizzle; sweep 1.25→1.9; strip reddens as time runs out)
- [x] find sharper assets for cards — `06500f5` (icons swapped to crisp 128px PNGs; portraits baked at 3x so everything downscales)
- [x] get rid of the "helps your ally" tag + shrink the card icon — `8db43fe` (tag removed; art is a fixed 42px accent, text centered in the freed space)
- [x] all the height boxes (ladder rungs) same size — `41aed4b` (uniform 22px; the sigil is marked by gold, not size)
- [x] add more climb per boss — `5cca9b8` (weak points 3/5/7/8, were 2/4/6/6; final titan uses the full ladder; ledges retuned so ascents take more grip-timer hops)
- [x] lock-in character sound — `ce8f3b4` (new "lock" event: Kenney metalLatch; reward lock keeps the power-up)
- [x] run another game and test the cards for sizing; make the cards look better — `c453b75` (ornate fantasy-border card frames; screenshot-verified)
- [x] make log collapsible — `c453b75` (Log ▸/▾ toggle: 4-line ticker ↔ 16-line history)
- [x] character icon disappeared at the weak point — `c453b75` (Height can overshoot the sigil; markers now clamp to the top rung)
