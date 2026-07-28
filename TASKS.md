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
- [ ] get rid of the "helps your ally" tag on cards (messes up text) + shrink the card icon size
- [ ] find sharper assets for cards — current ones look blurry
- [ ] all the height boxes (ladder rungs) should be the same size
- [ ] *(standing)* continually look through assets to use — finds so far: menu reskin `c4140ba`; queued: Emote Pack (reactions), Explosion/Smoke (strike & fall juice), UI Pack (grip/timing bars), Music Loops (ambient)

## Questions from Claude
(none)

## Done
- [x] lock-in character sound — `ce8f3b4` (new "lock" event: Kenney metalLatch, a latch clunking shut; reward lock keeps the power-up)
- [x] run another game and test the cards for sizing; make the cards look better — `c453b75` (ornate Kenney fantasy-border card frames w/ hover/selected states; sizing screenshot-verified)
- [x] make log collapsible — `c453b75` (Log ▸/▾ toggle: 4-line ticker ↔ 16-line history)
- [x] character icon disappeared at the weak point — `c453b75` (Height can overshoot the sigil; markers now clamp to the top rung)
