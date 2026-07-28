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
- [ ] *(standing)* continually look through assets to use — finds so far: menu reskin `c4140ba`, strike/shake juice `5d9d09f` (burst flash + dust + arena judder); queued: Emote Pack (reactions), UI Pack (grip/timing bars), Music Loops (ambient)

## Questions from Claude
(none)

## Done
- [x] find sharper assets for cards — `06500f5` (icons swapped to crisp 128px PNGs; portraits baked at 3x so everything downscales)
- [x] get rid of the "helps your ally" tag + shrink the card icon — `8db43fe` (tag removed; art is a fixed 42px accent, text centered in the freed space)
- [x] all the height boxes (ladder rungs) same size — `41aed4b` (uniform 22px; the sigil is marked by gold, not size)
- [x] add more climb per boss — `5cca9b8` (weak points 3/5/7/8, were 2/4/6/6; final titan uses the full ladder; ledges retuned so ascents take more grip-timer hops)
- [x] lock-in character sound — `ce8f3b4` (new "lock" event: Kenney metalLatch; reward lock keeps the power-up)
- [x] run another game and test the cards for sizing; make the cards look better — `c453b75` (ornate fantasy-border card frames; screenshot-verified)
- [x] make log collapsible — `c453b75` (Log ▸/▾ toggle: 4-line ticker ↔ 16-line history)
- [x] character icon disappeared at the weak point — `c453b75` (Height can overshoot the sigil; markers now clamp to the top rung)
