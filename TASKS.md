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
- [ ] continually look through assets to use *(standing task — I'll fold asset upgrades into every visual pass and note finds here)*

## Questions from Claude
(none)

## Done
- [x] run another game and test the cards for sizing; make the cards look better — `c453b75` (ornate Kenney fantasy-border card frames w/ hover/selected states; sizing screenshot-verified on the wordiest deck)
- [x] make log collapsible — `c453b75` (Log ▸/▾ toggle: 4-line ticker ↔ 16-line history)
- [x] character icon disappeared at the weak point — `c453b75` (bug: Height can overshoot the sigil, marker had no rung; now clamps to the top rung)
