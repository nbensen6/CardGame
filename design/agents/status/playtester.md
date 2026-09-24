---
tags:
  - agent-status
agent: playtester
updated: 2026-09-24T17:20
working_on: New check camera-not-over-shoulder -- proves the resting shot is genuinely over-the-shoulder, verified both directions.
---

# playtester

## This run — 2026-09-24 17:20 EDT

- **Did:** no requests open. Added a live check: does the resting camera
  really go over-the-shoulder, not just "hunter somewhere on screen"?
- **Worked?** Yes — 0 fires on real code, 16/16 fires when I broke it on
  purpose, then reverted clean. Baseline matches last run, no regression.
- **Next:** waiting on the fixer's stone-route work (hop spacing, stones in
  front of the jackal); neither moved this run.
- **Need from you:** nothing.

![[frames/playtester/2026-09-24-shoulder-engaged-step000.png]]
Step 0 of this run's own full baseline, real fixed code: the frog sits
trucked to the right, not dead-centre, with the jackal filling the rest of
the frame — the resting shot the new check now proves engages on every
settled step, not just this one.

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | unchanged — closed several runs ago (Play feedback) |
| 2 | hunters land on the beast correctly | unchanged — 0 `hunter-off-marker`, 0 `hunters-overlap`, 0 `route-reversal`, 0 `sigil-behind-hunter` |
| 3 | jump animation (squash/arc/landing) | unchanged — JACKAL-BAR's "The jump reads" line closed last run |
| 4 | camera | **strengthened this run** — 0 `hunter-offscreen`/`hunter-lost-mid-hop` as before, plus new: `camera-not-over-shoulder` now proves the settled shot is genuinely over-the-shoulder (not just "hunter somewhere on screen"), 0 fires on real code, proven to fire for real when broken |
| 5 | nothing errors | clean — 0 `script-error` across all three modes |

One commit this run: the new `camera-not-over-shoulder` check in
`game/tools/playtest.gd`, pushed before the final 80-step re-verification
finished (per COMMON.md 4b). `combat_3d.gd`'s temporary break used to prove
the negative direction was reverted before committing anything —
`git diff` on it is clean.

## Old: 2026-09-24 15:19 EDT

- **Did:** no requests addressed to `playtester` were open this run. Since
  my last run, the fixer landed the fix for the last thing I had filed
  (`1002`, the intent-tag-vs-hunter residual at ground-hop start — commit
  `d443ccd`). Ran the full three-mode baseline fresh against it first, then
  spent the rest of the run confirming that fix live and, since it closed
  the last thing blocking JACKAL-BAR's "The jump reads" line, gave that
  line the fresh eyes-on pass it asks for and ticked it.
- **Worked?** Yes, on all counts. Baseline: `play` (80 steps, real ending)
  0 `intent-tag-vs-hunter`, 0 `script-error`, `hop-distance-band` ×62 (only
  known open item, unchanged); `hover` 0 `intent-tag-vs-hunter`, 0 flips,
  `hop-distance-band` ×2; `hands` (1-10) 0 `intent-tag-vs-hunter`,
  `hop-distance-band` ×22 — all three exactly matching the last run's shape
  except `intent-tag-vs-hunter` going from its one known real fire to zero.
  Looked at the actual repro frames (`hop_000_03`/`_04` from this run's own
  `play` baseline, the exact frames the open request used to show a real
  graze) at 1:1: the frog now sits fully clear of "† Attack 7" with a
  visible gap on both sides. Then did the fresh look "The jump reads" had
  never had a dedicated pass on its own remaining claims (the residual was
  the only thing keeping it unticked): tiled the opening hop's frames 0,
  4, 8, 12, 16, 20, 23 at native crop resolution (never shrunk — a past run
  in this thread flagged a shrunk composite as misleading) — a clear
  low crouch at launch, a real airborne arc crossing in front of the
  beast's legs, and a visible landing squash on the stone at the end, no
  pop or snap anywhere in the sequence. Ticked the line in JACKAL-BAR with
  both frames.
- **Next:** watch for the fixer picking up stone-route item 2
  (`hop-distance-band`, the only other open item, confirmed a genuine
  geometric ceiling several runs ago — needs re-authoring the Python
  reference model or a joint placement rule, not another retry). Also
  watch for the fixer picking up the "stones IN FRONT of the jackal" /
  "space between the hunter and the skin" requirement Nick added to the
  same stone-route build request (`2026-09-23-1846-...`) on 2026-09-24
  11:52 ET — still `status: taken`, no movement on that half as of this
  run's read of it. Once it lands, re-check the sigil-cheek note
  (`2026-09-24-0322-...`) and close it.
- **Need from you:** nothing.

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | unchanged — closed two runs ago (Play feedback) |
| 2 | hunters land on the beast correctly | unchanged — 0 `hunter-off-marker`, 0 `hunters-overlap`, 0 `route-reversal`, 0 `sigil-behind-hunter` |
| 3 | jump animation (squash/arc/landing) | **JACKAL-BAR's "The jump reads" line closed this run** — the last blocker (the intent-tag-vs-hunter residual) is fixed and confirmed at 0 across all three modes; fresh eyes-on pass across the full opening-hop arc at native 1:1, two frames |
| 4 | camera | unchanged — 0 `hunter-offscreen`/`hunter-lost-mid-hop`; `intent-tag-vs-hunter` now also 0 (was 1) |
| 5 | nothing errors | clean — 0 `script-error` across all three modes |

![[frames/playtester/2026-09-24-jump-reads-tag-clear-hop-start.png]]
The exact frame the open request used to show a real graze (`hop_000_04`,
opening hop): the frog now sits fully clear of "† Attack 7", a real gap on
both sides — the fixer's `frame_pre_draw` retiming fix, confirmed live.

![[frames/playtester/2026-09-24-jump-reads-full-arc-strip.png]]
The opening hop's full arc, frames 0/4/8/12/16/20/23, native crop
resolution (not shrunk): crouch, rising arc, falling arc, landing squash on
the stone — no pop anywhere, the tag never touching the frog through the
whole sequence.

One commit this run: the JACKAL-BAR tick with its evidence, two frames,
and this write-up. No game code changed (`git diff` on anything under
`game/` is empty) — this run confirmed the fixer's fix and closed a
checklist line, it didn't find a new bug.

## Old: 2026-09-24 13:11 EDT

- **Did:** Nick's answer landed on the sigil-cheek request since the last
  run — but it had already been relayed to the fixer, ahead of this run,
  as an addendum on the same stone-route build request it needed to fold
  into (commit `1a237dc`, 2026-09-24 11:52 EDT, written by whoever
  answered live). My own note never got its half of the bookkeeping
  though, so I added a `## Filed on` section pointing at where the work
  is actually tracked and left `status: open` (the route change hasn't
  landed yet — the fixer's last status note, 11:34 EDT, predates the
  answer). Ran the full three-mode baseline next: clean, byte-for-byte the
  same two known open issues as every prior run on file. Then tried to
  turn Nick's new requirement ("space between the hunter and the skin")
  into a live check, the way "Play feedback" got one last run.
- **Worked?** Bookkeeping: yes. Baseline: yes, no regression — `play`
  (80 steps) shows 62 `hop-distance-band` fails and 1 `intent-tag-vs-hunter`
  fail, `hands` (1-10) shows 22 `hop-distance-band`, `hover` shows 2 — the
  exact same shape every run since these were filed, nothing new. The new
  check: **no**, and I'm glad I checked before shipping it. The idea was
  clearance = hunter's world z minus the beast's real mesh surface z at
  the hunter's own (x, y), using `combat_3d.gd`'s own `_front_of_beast`
  (the same hull it already trusts for placing a hunter between two
  rungs). Added it behind a print-only calibration line (no fail yet) and
  ran a real fight: most non-sigil footholds came back with `clearance`
  values like -1.28m and -12.6m — physically impossible for holds every
  prior run has looked at and called clean. The hull is a flat (x, y)
  grid of "furthest-forward vertex in this cell" with no idea which part
  of the mesh that vertex belongs to, so a cell can return an unrelated
  disconnected feature (an ear, a far leg) instead of the local skin —
  `combat_3d.gd` already documents this exact failure mode for its own
  use of the hull (`stand_z_for`'s comment: a bad cell "picked up the
  Cinder Jackal's ear... pushing the hunter's z... well past the model").
  I'd have hit the same thing from a different angle. Reverted the check
  before it ever reached a real threshold — shipping it would have meant
  either flagging holds everyone agrees are fine, or padding the margin
  so far past the real numbers that it could never catch anything.
- **Next:** "hunter stands with real space off the skin" needs a per-point
  mesh raycast against the beast's actual triangles, not the coarse hull —
  a bigger job than one run, and not mine to build blind; whoever builds
  the front-of-body route (the fixer, on the stone-route request) is the
  one with a reason to also solve this, since they'll want to prove their
  own fix. Watching for that build to land so the sigil-cheek note (and
  its own before-frames) can actually be re-checked and closed. Also still
  watching for `1002` (intent-tag-vs-hunter residual, unchanged this run).
- **Need from you:** nothing.

Checklist snapshot (unchanged from last run — no game code changed):

| # | item | state |
|---|---|---|
| 1 | card plays read | closed last run (Play feedback); unchanged |
| 2 | hunters land on the beast correctly | unchanged — 0 `hunter-off-marker`, 0 `hunters-overlap`, 0 `route-reversal`, 0 `sigil-behind-hunter` |
| 3 | jump animation (squash/arc/landing) | unchanged — clean |
| 4 | camera | unchanged — 0 `hunter-offscreen`/`hunter-lost-mid-hop` |
| 5 | nothing errors | clean — 0 `script-error` across all three modes |

No game code changed this run (the new check was tried, ruled out, and
reverted before it ever shipped — `git diff` on `playtest.gd` is empty).
One request bookkeeping edit
(`2026-09-24-0322-...sigil-hunter-clings-to-the-cheek.md`) and this
write-up.

## Old: 2026-09-24 11:02 EDT, JACKAL-BAR "Play feedback" closed

- **Did:** ran the full three-mode baseline first (no requests were open
  for `playtester`, and Nick still hasn't answered the sigil-cheek
  request), confirmed it clean against last run, then picked one checklist
  item to close for real: JACKAL-BAR's "Play feedback" line under Cards,
  unticked since the file was created — never given a dedicated look of
  its own, even though the machinery to prove it has existed for days.
- **Worked?** Yes. The three things that line asks for each already have a
  live check that runs on every real card play, every full baseline, not
  just today: `hand-count` (the played card actually leaves — screen count
  matches the model), `damage-popup-missing` (a real hit shows a floating
  number on the beast the same step), `dead-click`/`stuck` (nothing ever
  clicks for free). This run's own fresh full baseline — a complete 30-step
  fight through to a win, plus `hover` and `hands` 1-10 — hit all three
  checks across roughly two dozen real plays (5 timed hits, several
  Skills, two End Turns) and came back with 0 fails on every one of them,
  matching every prior run on record. Then looked past the numbers at real
  frames: Brace going from a 5-card hand to 4, with a `◈5` Block icon
  appearing on the Frog's row the same step — card gone, effect visible,
  state changed, together. Ticked the line in JACKAL-BAR with that
  evidence and two frames.
- **Next:** watch for the fixer picking up the ground-hop-start intent-tag
  residual (`1002`, still open) or closing stone-route item 2
  (`hop-distance-band`, still the only other open item, unchanged this
  run — 62-63 fires in `play`, 22 in `hands`, all at the same two known
  short hops as every prior run). Still waiting on Nick's answer on the
  sigil-cheek request.
- **Need from you:** the sigil-cheek request, whenever you have a minute —
  same ask as every run since it was filed.

![[frames/playtester/2026-09-24-play-feedback-brace-before.png]]
Step 17 this run: a 5-card hand (Brace, Tongue Snap, Hop, Scramble,
Leapfrog), energy 3.

![[frames/playtester/2026-09-24-play-feedback-brace-after.png]]
Step 18, right after playing Brace: the card is gone, the remaining 4
re-fan cleanly, energy 3→2, and a `◈5` Block icon appears on the Frog's own
party row — the card left, the effect landed, the state visibly changed.

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | **JACKAL-BAR's "Play feedback" line closed this run** — three permanent checks (`hand-count`, `damage-popup-missing`, `dead-click`/`stuck`) proven clean across a fresh full baseline and tied to a real frame pair; sigil-cheek placement unchanged, already filed to Nick |
| 2 | hunters land on the beast correctly | unchanged — 0 `hunter-off-marker`, 0 `hunters-overlap`, 0 `route-reversal`, 0 `sigil-behind-hunter` |
| 3 | jump animation (squash/arc/landing) | unchanged — clean, no pops, across every hop this run |
| 4 | camera | unchanged — 0 `hunter-offscreen`/`hunter-lost-mid-hop`; `intent-tag-vs-hunter` residual unchanged (2 fires this run, same shape as filed, still open with the fixer) |
| 5 | nothing errors | clean — 0 `script-error` across all three modes |

No game code changed this run — one JACKAL-BAR edit (ticking "Play
feedback" with its evidence and two frames) and this write-up, both
pushed together per COMMON.md 4b.

## Old: 2026-09-24 10:05 EDT

- **Did:** the fixer landed a fix (`73ae6b4`) for the artist's
  jump-hides-behind-intent-tag finding while I was setting up this run.
  Ran the full three-mode baseline first (clean, matches every recent run),
  then extended `playtest.gd` with a live check
  (`intent-tag-vs-hunter`, check 5d) — the fixer's own fix is proven only
  by unit tests on synthetic rects, the same gap `intent-hidden` (check 5c)
  closed for the party-panel fix a run earlier, now closed for this one.
- **Worked?** Yes, in two stages, and the first stage taught me something
  worth recording. A first version fired 3-4/29 times per run on the
  ALREADY-FIXED code — looked at every flagged frame at 1:1 and none showed
  any visible overlap at all: `Combat3D.hunter_screen_rect`'s box is the
  convex hull of a 3D AABB's projected corners, always a bit looser than
  the character's real silhouette, so it sweeps a few px past the tag's
  edge on nearly every hop with nothing ever actually touching (one graze
  measured 0.13px wide). Added an 8px-minimum-on-both-axes margin (the same
  idea as this file's own check 5 `grow(-6)` for a card near a button)
  before trusting the check at all. With that margin, three full fresh
  80-step baselines agree: 0 fails everywhere the fixer's fix already
  covers (including the artist's own original opening-hop repro, now
  clean), and exactly one real, much smaller residual every single run —
  a ~13x34px graze at the very first instant of a ground-level hop, small
  but genuinely visible when I opened the frame. Filed it separately
  (`to: fixer`,
  `2026-09-24-1002-playtester-to-fixer-intent-tag-still-grazes-hunter-at-hop-start.md`)
  rather than let it sit unrecorded under a fix that's 95% of the way
  there.
- **Next:** watch for the fixer's fix on the ground-hop-start residual,
  re-run and confirm `intent-tag-vs-hunter` goes to 0. `hop-distance-band`
  (the two short hops nearest the sigil) is still the only other open item,
  unchanged. Still waiting on Nick's answer on the sigil-cheek request —
  unchanged ask, nothing new to add.
- **Need from you:** the sigil-cheek request, whenever you have a minute —
  same ask as every run since it was filed.

![[frames/playtester/2026-09-24-intent-tag-vs-hunter-groundhop-full.png]]
The real repro: the frog's rightmost edge sits under the intent tag's left
edge, low on screen, moments after the opening hop launches. Full 1:1
frame, the fixed code (`73ae6b4`) already in place.

![[frames/playtester/2026-09-24-intent-tag-vs-hunter-groundhop-crop.png]]
Same frame, cropped for detail only (2x nearest-neighbour) — small, but a
real, visible graze, not a bounding-box artifact.

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | unchanged — reads clearly; sigil-cheek placement unchanged, already filed to Nick |
| 2 | hunters land on the beast correctly | unchanged — 0 `hunter-off-marker`, 0 `hunters-overlap`, 0 `route-reversal`, 0 `sigil-behind-hunter` |
| 3 | jump animation (squash/arc/landing) | unchanged — clean, no pops, across every hop this run |
| 4 | camera | unchanged — 0 `hunter-offscreen`/`hunter-lost-mid-hop`; **new**: `intent-tag-vs-hunter` now watches the fixer's tag-vs-jumping-hunter fix live, on every hop, in every mode — confirms the main fix holds, found one small residual, filed |
| 5 | nothing errors | clean — 0 `script-error` across all three modes; `intent-hidden` (party-panel) still gone, confirmed again this run |

Two commits this run: the new `intent-tag-vs-hunter` check in
`game/tools/playtest.gd` (with its 8px margin, added only after the
false-positive investigation above), and the new request + two frames +
this write-up. Both pushed per COMMON.md 4b before the final full-baseline
re-verification finished.

## Old: 2026-09-24 07:26 EDT

- **Did:** no requests addressed to `playtester` were open, and Nick still
  hasn't answered the sigil-cheek request. Ran the full three-mode
  baseline first — the tip had picked up two real changes since my last
  run: the fixer's fix for `intent-tag-hides-behind-party-panel`, and the
  artist's sigil-lift fix (0.9x → 1.7x `HUNTER_HEIGHT`) for the "hunter's
  head hides the weak-point glow at the sigil" gap they found on their own
  pass. Confirmed both hold. Then added one new check:
  `sigil-behind-hunter` — the same shape of gap `hop-distance-band` and
  `route-reversal` closed for the stone route, now closed for the sigil
  mark itself: the artist's fix was proved once with a render, but nothing
  re-checks it live, so a future beast (or a future retune of the same
  lift) could land the mark back inside a standing hunter's own
  silhouette and nothing would catch it before a human happened to look.
- **Worked?** Yes, both halves. Baseline: 0 new failures, and one known
  failure is now GONE — `intent-hidden` (open since 2026-09-23 21:41,
  ~34 hours) fired 0 times across all three modes on this run, matching
  the fixer's own claim exactly. Only `hop-distance-band` remains
  (`play` ×62, `hover` ×2, `hands` ×22 — identical counts to every recent
  run, not a regression). No `hunter-off-marker`/`hunters-overlap`/
  `route-reversal`/`script-error` anywhere — the artist's sigil-lift
  change (a real placement edit, `_place_sigil` in `combat_3d.gd`) didn't
  disturb hunter placement at all. New check: verified false-positive-free
  first (`mode=hands`, all 10 sizes, and a fresh `mode=play` 30-step run
  against the real, fixed code — 0 `sigil-behind-hunter` fires either
  way, even though the run reaches the sigil around step 16-26 the same
  as every prior run), then proved it actually fires by temporarily
  reverting `_place_sigil`'s lift from `1.7` back to the old, buggy `0.9`
  (one line, `combat_3d.gd`) and re-running `mode=play` — 11/11 real fires,
  every one at the exact sigil steps (16–26), with the exact numbers the
  bug had (sigil y=15.86 vs. a standing hunter's head at y=15.93) — then
  reverted (`git diff` clean, checked) and re-ran `run_tests.gd` before
  trusting it.
- **Next:** watch for Nick's answer on the sigil-cheek request (unchanged
  ask, still the top of next run's queue the moment he answers). Watch for
  the fixer closing `hop-distance-band`'s last two short hops (confirmed a
  genuine geometric ceiling two runs ago, needs re-authoring the Python
  reference model). Nothing else open.
- **Need from you:** the sigil-cheek request, whenever you have a minute —
  same ask as every run since it was filed, nothing new to add.

![[frames/playtester/2026-09-24-sigil-check-baseline-step019.png]]
Step 19 this run, the real fixed code — both hunters "at the sigil",
`† Attack 14` clear of the party panel (the fixer's fix, confirmed live),
boss taking real damage (12/42). The baseline this run's numbers come from.

![[frames/playtester/2026-09-24-sigil-check-3dclimb.png]]
`state=3dclimb` on the same fixed code — the gold sigil spark sits above
and clear of the climbing hunter's head, not behind it. The new
`sigil-behind-hunter` check now watches this stays true on every run,
not just this one frame.

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | unchanged — reads clearly; sigil-cheek placement unchanged, already filed to Nick |
| 2 | hunters land on the beast correctly | unchanged — 0 `hunter-off-marker`, 0 `route-reversal`, 0 `hunters-overlap`; **new**: `sigil-behind-hunter` now watches the sigil mark stays clear of a standing hunter's head, proved both directions |
| 3 | jump animation (squash/arc/landing) | unchanged — clean, no pops, across every hop this run |
| 4 | camera | unchanged — 0 `hunter-offscreen`/`hunter-lost-mid-hop` |
| 5 | nothing errors | clean — 0 `script-error` across all three modes; **closed this run**: `intent-hidden` is gone, the fixer's fix holds under a full live baseline |

One commit this run: the new `sigil-behind-hunter` check in
`game/tools/playtest.gd`, pushed before the negative-direction
verification (per COMMON.md 4b) — the temporary revert used to prove the
negative direction was never committed, only `run_tests.gd` and a fresh
baseline on the real code after reverting it.

## Old: 2026-09-24 05:14 EDT

- **Did:** no requests addressed to `playtester` were open; Nick has not
  yet answered the sigil-cheek request from last run
  (`2026-09-24-0322-...`). Ran the full three-mode baseline first, then
  added one new check: `party-roster-incomplete`, closing JACKAL-BAR's
  still-unchecked "both hunters are always findable, including mid-climb."
  The 3D scene only ever frames the ACTIVE hunter (Nick's own camera
  target, third-person over the active hunter's shoulder) — the other
  hunter is routinely off screen entirely, on purpose, so a check that
  demanded both be visible in the 3D view would just fail constantly on
  correct behaviour. What actually keeps the inactive hunter findable is
  the party panel (`_render_party`'s own comment: "the 3D scene shows
  WHERE they are; this says how they're doing") — a row per hunter,
  rebuilt from the model's own player list every refresh. Nothing had ever
  checked that rebuild stays in sync; a stale refresh order or a row
  silently failing to add would drop a hunter off the one place they are
  guaranteed visible, without tripping any existing check (all of those
  only judge whichever hunter the camera happens to be pointed at).
- **Worked?** Yes, both halves. Baseline: 0 new failures across all three
  modes — `play` (80 steps, though the fight ended in a win at step 30)
  reproduced exactly the same two already-filed, already-open bugs as
  every recent run (`hop-distance-band` ×62, `intent-hidden` ×18),
  `hover` 0 flips (plus the same `hop-distance-band` fire at `start`),
  `hands` (1–10) reproduced only `hop-distance-band` ×22 — nothing new,
  nothing regressed. Also did a fresh human-eyes look at a few card-play
  frames (step 009, step 019) while I had them open: hits land and read,
  the party panel and gauge stay legible, and the sigil-cheek placement
  (Frog flush against the jackal's cheek, no stone under it) is exactly
  what was already filed to Nick — not new, not worse. New check: verified
  false-positive-free first (`mode=hands`, all 10 sizes, 0 fires beyond
  the known `hop-distance-band`), then proved it actually fires by
  temporarily forcing `expect := c.players.size() + 1` and re-running
  `mode=hands` — 11/11 calls correctly failed ("party panel shows 2
  hunter row(s), model has 3") — then reverted (`git diff` clean, checked)
  before trusting it.
- **Next:** watch for Nick's answer on the sigil-cheek request (unchanged,
  still the top of next run's queue per COMMON.md 1b the moment he
  answers). Also still watching: the fixer's stone-route item 2 (confirmed
  last run as a genuine geometric ceiling, not a retry bug — needs
  re-authoring the Python reference model to actually close) and
  `intent-tag-hides-behind-party-panel`, still open and unfixed.
- **Need from you:** the sigil-cheek request, whenever you have a minute —
  same ask as last run, nothing new to add.

![[frames/playtester/2026-09-24-party-roster-both-rows.png]]
Step 9 this run — the party panel always carries one row per hunter (Frog,
Goblin Engineer) regardless of where either one is in the 3D scene; the new
`party-roster-incomplete` check now watches that this stays true.

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | fresh look this run — reads clearly; sigil-cheek placement unchanged, already filed to Nick |
| 2 | hunters land on the beast correctly | unchanged — 0 `hunter-off-marker`, 0 `route-reversal`, 0 `hunters-overlap` |
| 3 | jump animation (squash/arc/landing) | unchanged — clean, no pops, across every hop this run |
| 4 | camera | unchanged — 0 `hunter-offscreen`/`hunter-lost-mid-hop`; **coverage gap closed**: the non-active hunter's findability (via the party panel) now has a permanent check, `party-roster-incomplete` |
| 5 | nothing errors | clean — 0 `script-error` across all three modes |

One commit this run: the new `party-roster-incomplete` check in
`game/tools/playtest.gd`, plus this write-up and its frame, pushed before
this note per COMMON.md 4b.

## Old: 2026-09-24 03:35 EDT

- **Did:** no requests addressed to `playtester` were open. Ran the full
  three-mode baseline first, then extended `hunter-off-marker`
  (`playtest.gd` check 8) to stop skipping the sigil (`t >= 0.92`) — it
  used to exempt that position on the belief `_place_hunters` used a
  different branch there, which is only true for a beast with NO authored
  climb points. The Cinder Jackal has climb points, so its sigil was going
  through the exact same `_stand_on_model`/`foothold_anchor` path as every
  other rung, just never checked.
- **Worked?** Yes, both halves, and the second one found something real.
  Baseline: 0 new failures — the same two already-filed, already-open bugs
  as every recent run (`hop-distance-band`, `intent-hidden`), nothing else,
  across all three modes. New check: proved both directions before
  trusting it — a temporary, reverted +3m offset injected at the sigil
  made it fire correctly (4/4 real occurrences, clean `git diff` after
  reverting), and the real, unmodified code stays clean on a full 80-step
  run. Clean is itself the finding: it means the Frog's position at the
  sigil is *correct* by the game's own placement math — so the odd thing I
  saw looking at the actual frames (the Frog pressed flat against the
  jackal's cheek, right beside the eye, nowhere near a stone the way every
  other hold has one) isn't a logic bug to fix, it's a placement/read
  question. Turns out the fixer already found and flagged this exact
  trade-off in their 2026-09-23 20:45 ET write-up (forcing the climb route
  to never reverse pushed the sigil off the snout tip onto the cheek) and
  asked for a decision on it — but that ask was buried in a `## Result` on
  a `to: fixer` request, so it never reached Nick. Filed it properly this
  run: `to: nick`,
  `2026-09-24-0322-playtester-to-nick-sigil-hunter-clings-to-the-cheek.md`,
  with fresh frames from this run's own baseline (not the fixer's Blender
  renders, which don't show the in-game camera at all).
- **Worth knowing:** while this run was in progress, the fixer landed a fix
  for the other open bug (`boss-damage-popup-offscreen-at-sigil`, commit
  `56b97fc`) — their own request write-up says the original repro no
  longer reproduces on the current tip either way (most likely because the
  earlier stone-route fix already moved the sigil off the nose), and they
  fixed the underlying scale-vs-camera-zoom gap anyway rather than leave it
  to depend on geometry nobody meant to fix it. Consistent with what I
  saw: 0 `damage-popup-offscreen` fails in any of this run's own baselines,
  before or after that commit landed.
- **Next:** watch for Nick's answer on the sigil-cheek request. If he says
  fix it, that's the fixer's own already-named approach (hunt the sigil
  further back on the skull instead of straight down from above). Also
  watch for the stone-route request's item 2 (the two short hops nearest
  the sigil) — the fixer ruled out a 4th approach this run (raising the
  raycast retry budget) and called it a genuine geometric ceiling, not a
  retry bug; next real option is re-authoring the Python reference model.
  `intent-tag-hides-behind-party-panel` is still open, still unfixed.
- **Need from you:** the sigil-cheek request above, whenever you have a
  minute — it's a quick yes/no/try-something-else, not urgent.

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | unchanged — reads clearly; the boss-damage-popup-offscreen bug that hid a number at the sigil is now fixed (fixer, `56b97fc`, verified by their own playtest and consistent with 0 fails in all of this run's baselines) |
| 2 | hunters land on the beast correctly | **coverage gap closed**: `hunter-off-marker` now actually checks the sigil, proved both directions; the position itself is correct by the game's own math, but the READ at the sigil specifically (no stone, hunter flush against the cheek) is a real finding, filed to Nick |
| 3 | jump animation (squash/arc/landing) | unchanged — clean, no pops, across every hop this run |
| 4 | camera | unchanged — 0 `hunter-offscreen`/`hunter-lost-mid-hop` fails; `intent-hidden` still open (filed, unfixed) |
| 5 | nothing errors | clean — 0 script-error fails across all three modes |

Two commits this run: `game/tools/playtest.gd` (the `hunter-off-marker`
extension, `2a5fa8f`) and the `to: nick` request with two frames, in the
same commit. Pushed, then rebased cleanly onto the fixer's and artist's
concurrent pushes (`git log origin/main -1` confirms landed).

## Old: 2026-09-24 01:13 EDT

- **Did:** no requests addressed to `playtester` were open. Ran the full
  three-mode baseline first, then added one new check: `hop-distance-band`,
  the runtime half of the fixer's still-open stone-route item 2 (ordinary
  hold-to-hold hops have to sit inside `hop_arc()`'s 2.4-9.2 world-unit
  band). The fixer's own build-time gate (`route.py`) already enforces this
  in Blender-authoring units; nothing re-checked it against what the fight
  actually loads — the same shape of gap check 8b (`route-reversal`) closed
  last run.
- **Worked?** Yes, both halves. Baseline: 0 new failures — `hover` and
  `hands` both clean, `play` (80 steps) reproduced exactly the one
  already-filed, already-open bug (`intent-hidden` ×12) and nothing else —
  not a regression, and confirms the fixer's item-1/item-3 stone-route work
  (route direction, next-hold ring) still holds: 0 `route-reversal`, 0
  `hunter-off-marker`, 0 script-error across all three modes. New check:
  fired for real, live, on exactly the two hops the fixer's own last run
  named as still short — Height 3→4 measured 2.39m, Height 4→5 measured
  1.52m, both against the same 2.42m floor, matching the fixer's numbers to
  two decimal places — while Height 0→1/1→2/2→3 (7.10/3.28/6.23, all
  in-band per the same table) never fired, in the same run: real signal in
  both directions, not a check that can only ever fire or only ever pass.
  Nothing new to file: this is the fixer's own already-open, already-taken
  request (`2026-09-23-1846-...build-the-one-directional-stone-route.md`),
  now with a permanent live check that will read 0 the moment item 2 is
  actually finished, instead of depending on someone remembering to re-read
  the request's own numbers table.
- **Next:** watch for the fixer closing item 2 for real (its own `## Result`
  says it needs either re-authoring the Python reference model's sigil hold
  or a joint placement rule that considers the Height 4→5 hop when choosing
  Height 4 — two dead ends already ruled out, written down there). Once it
  lands, re-run and confirm `hop-distance-band` goes to 0. Also watch for
  either open bug landing a fix (`intent-tag-hides-behind-party-panel`,
  `boss-damage-popup-offscreen-at-sigil`) and re-run to confirm each goes to
  0.
- **Need from you:** nothing this run.

## Old: 2026-09-23 23:12 EDT

- Did: no requests addressed to `playtester` were open (both closed out
  already — the stone-route design question and the fixer's technical-
  numbers note). Ran the full three-mode baseline first, then added one new
  check: the fixer's stone-route fix (`route.py`'s "a climb only ever
  sweeps one way" rule, landed this evening, item 1 of 3 on the build
  request) is enforced at BUILD time but nothing re-checked it against what
  the fight actually loads at runtime — the exact gap that let the original
  sigil bug ship. New check 8b in `playtest.gd`: read the live
  `_climb_points` off the loaded beast, project onto the same horizontal
  sweep plane `route.py` uses, fail if any rung nets backward along the
  established sweep.
- Worked?: Yes, both halves. Baseline: 0 new failures — `hover` and `hands`
  both clean, `play` reproduced exactly the same two already-filed, already-
  open bugs as last run (`intent-hidden` ×26, `damage-popup-offscreen` ×1),
  nothing new — not a regression, and confirms the fixer's route.py change
  (a real structural edit to how every beast's climb points get placed)
  didn't break hop continuity, camera coverage, or hunter-off-marker
  anywhere in a 30-step run. New check: verified false-positive-free on
  `mode=hands` (all 10 sizes) AND a full `mode=play` baseline against the
  current, already-fixed Cinder Jackal (0 `route-reversal` fails in either)
  before trusting it — same two-stage discipline as every check added here.
  Nothing to file: this run found no new bug, it closed a coverage gap so
  the NEXT regression (a future beast, or a regression in this one) fails a
  playtest automatically instead of only a Python unit test someone has to
  remember to run.
- Next: watch for the fixer finishing items 2/3 of the stone-route request
  (spacing band, next-hold ring) — once the ring exists, that's a new check
  to add (JACKAL-BAR / the approved design: "the ring on the NEXT hold
  should always be visible before the card that sends you there is
  played"). Also watch for a fix landing on either open bug
  (`intent-tag-hides-behind-party-panel`, `boss-damage-popup-offscreen-at-
  sigil`) and re-run to confirm each goes to 0.
- Need from you: nothing this run.

## Old: 2026-09-23 21:41 EDT

- Did: full three-mode baseline first (this sandbox is slow tonight, ~20-26s/
  step — play mode alone took ~13 minutes for 30-40 steps). Then a fresh
  human-eye pass on item 1 (card plays reading clearly), overdue two runs
  running. Then one new check: the intent tag must never overlap the boss
  HP bar or the party panel (JACKAL-BAR's "the beast's intent is unmissable"
  / "nothing important is behind... the party panel", never covered before —
  the existing hand-over-hud check only ever compared HUD elements against
  the *hand*, never HUD against HUD).
- Worked?: Yes, on both halves. Baseline: 0 new failures, `hover` and `hands`
  both fully clean, `play` reproduced exactly the one already-filed,
  already-open bug (`damage-popup-offscreen` at the sigil, `1735`, still
  unaddressed) and nothing else — not a regression. Item 1 fresh look: real
  damage numbers land and read clearly, a Block icon visibly appears on the
  party row the instant Brace is played (checked the before/after frame
  pair), hands refresh cleanly at every size — no new complaint there. The
  new check: verified false-positive-free on `mode=hands` (all 10 sizes)
  first, then it fired for REAL on `mode=play`, twice, at different fight
  states — the intent tag ("† Attack 7" at fight start, a climb-intent tag
  mid-fight) renders **partially behind the top-left party panel**, text
  visibly clipped in both frames. Filed
  `to: fixer`,
  `2026-09-23-2141-playtester-to-fixer-intent-tag-hides-behind-party-panel.md`,
  with the root cause I could see from reading the code (`_position_intent_tag`
  clamps Y away from the HP bar/hand but never clamps X away from the party
  panel) and both frames.
- Next: watch for the fixer's fix, re-run `mode=play` and confirm 0
  `intent-hidden` fails. The stone-route build (`1846`, `to: fixer`) and the
  boss-damage-popup-offscreen bug (`1735`) are both still open and unbuilt/
  unfixed as of this run — nothing on my end is blocking either.
- Need from you: nothing this run.

## Now

Fresh sandbox, Godot 4.7.1 + `--import`. `run_tests.gd`: `ALL TESTS PASSED`
before and after. Full baseline, all three modes, against a tip that
already carries the fixer's 2026-09-24 00:24 ET run (item 3 of the
stone-route request verified with no code change; item 2 partially fixed —
two of five hops now comfortably in-band, two still short):

- `mode=play steps=80`: 1 failing check, `intent-hidden` ×12 — already
  filed (`2026-09-23-2141-...intent-tag-hides-behind-party-panel.md`),
  still open/unfixed, not a new failure. 0 `route-reversal`, 0
  `hunter-off-marker`, 0 script-error — the fixer's item-1 (route direction)
  fix still holds under this evening's item-2 changes.
- `mode=hover`: 0 flips, clean.
- `mode=hands`: 0 fails across hand sizes 1-10 (on the pre-edit script,
  re-confirmed clean again after adding this run's own check — see below).

New check added to `game/tools/playtest.gd` (check 8c, `hop-distance-band`):
the runtime half of the stone-route request's item 2 ("keep hold-to-hold
distance between 2.4 and 9.2 world units"), the same shape of gap check 8b
(`route-reversal`) closed last run — the fixer's `route.py`
(`hop_world_distance`/`hop_distance_violation`) enforces the band at BUILD
time, in a beast's own Blender-authoring units, but nothing re-checks it
against what a player's camera actually loads. `_climb_points` is already
in the SAME world units `hop_arc()` clamps against (`combat_3d.gd`:
`next.origin * _beast_scale`, the literal Vector3s `hop_arc()` itself
receives as `from`/`to`), so this needed no mesh-to-world conversion: it
reads adjacent rungs straight off the live dictionary and checks the FULL
3D distance (unlike 8b, which projects onto the horizontal sweep and
ignores height) against `hop_arc()`'s own clamp solved for distance
(2.4230769–9.1538461, `HOP_MIN_WORLD`/`HOP_MAX_WORLD`, mirroring
`route.py`'s identical constants since this file can't import a `.py`
module).

Verified both directions in the same live run, not synthetically — the
real shipped Cinder Jackal already has both a passing case and a failing
one to check against: `mode=hands` (all 10 sizes) fired 22 times (11 calls
× 2 short hops), `mode=play` (80 steps) fired 62 times (31 calls × 2) — in
both runs, every single fire was Height 3→4 (2.39m) or 4→5 (1.52m), never
0→1/1→2/2→3 (7.10/3.28/6.23, all comfortably in-band). Those numbers match
the fixer's own 2026-09-24 00:24 ET table to two decimal places — this is
independent, live confirmation of their own diagnosis, not a new bug. This
run found no new bug; it closes a coverage gap so the moment item 2 is
actually finished (or regresses on a future beast), a playtest run proves
it instead of depending on someone re-reading a request's numbers table.

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | unchanged — reads clearly except where the already-filed offscreen-popup bug (`1735`) hides the number |
| 2 | hunters land on the beast correctly | unchanged — 0 `hunter-off-marker`, 0 `route-reversal`; **new**: `hop-distance-band` now watches the stone-route item-2 gap live (currently 2 real fires, matching the fixer's own known-incomplete fix) |
| 3 | jump animation (squash/arc/landing) | unchanged — clean, no pops, across every hop this run |
| 4 | camera | unchanged — 0 `hunter-offscreen`/`hunter-lost-mid-hop` fails; `intent-hidden` still open (filed) |
| 5 | nothing errors | clean — 0 script-error fails across all three modes |

One commit this run: the new `hop-distance-band` check in `playtest.gd`
(`8c3813a`), pushed before writing this note up (per COMMON.md 4b), then
proven live exactly as described above — all three baseline modes and both
verification runs (`hands`, `play`) were run and read before this note was
written.

## Next

Watch for the fixer closing stone-route item 2 for real — its own
`## Result` on `2026-09-23-1846-...build-the-one-directional-stone-route.md`
names two dead ends already ruled out (widening the per-rung search window
reintroduces a live route reversal; an unconstrained sigil re-raycast can
land off the head) and says what's actually needed (re-author the Python
reference model's sigil hold, or a joint placement rule that considers the
Height 4→5 hop when choosing Height 4). Once it lands, re-run and confirm
`hop-distance-band` goes to 0. Also watch for either open bug landing a fix
(`intent-tag-hides-behind-party-panel`, `boss-damage-popup-offscreen-at-
sigil`) and re-run to confirm each goes to 0. Nothing else queued.

## Old: 2026-09-23 21:41 EDT, intent-tag-hides-behind-party-panel filed

Fresh sandbox, Godot 4.7.1 + `--import`, `run_tests.gd`: `ALL TESTS PASSED`
before and after the code change. Full baseline (this sandbox ran ~4-5x
slower than the documented 3-5min/40-steps tonight, so `play` used
`steps=40` instead of 80 to keep each run under ~15 minutes and let me
verify the new check twice without losing the whole run to render time):

- `mode=play steps=40`: 1 failing check, `damage-popup-offscreen` ×1 at
  step 19 (same card, same on-screen position, same "both at the sigil"
  condition as every prior run since `1735` was filed 2026-09-23 17:35 —
  confirmed still open, still unfixed, not a new bug).
- `mode=hover`: 0 flips, clean.
- `mode=hands`: 0 fails across hand sizes 1-10, clean.

Item 1 fresh-eyes pass (overdue since the boss-damage-timing fix made real
hits possible for the first time): looked closely at step_002/003 (a
Tongue Flick landing for 10, boss bar visibly draining), step_017/018
(Brace granting 5 Block — a new "◈5" icon appears on the Frog's party row
that was not there the frame before), and step_019 (the known offscreen-
popup bug, confirmed still reproducing). Conclusion: card plays read
clearly wherever the popup itself stays on screen; the one thing standing
between item 1 and a clean tick is the same offscreen-popup bug already
filed and still open.

New check added to `game/tools/playtest.gd` (check 5c, `intent-hidden`):
whenever `_intent_tag` is visible, its rect must not intersect `_hp_bar` or
`_party`. Verified in two stages before trusting it (same discipline as
every prior check added here — a check that can only ever pass proves
nothing, but neither does one that fires on noise): `mode=hands` first (all
10 hand sizes, 0 fires — rules out "any overlap, any hand size" as an
artifact of the check itself), then `mode=play`, where it fired twice for
real, at fight-start and mid-fight, both frames showing genuinely clipped
text. Filed to the fixer with the root cause
(`_position_intent_tag`'s clamp only ever protects the tag's Y, never its
X, against the party panel specifically) rather than guess further at a
fix — not my job to fix, per this role's own rule.

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | fresh pass done — reads clearly except where the already-filed offscreen-popup bug (`1735`) hides the number; no new complaint |
| 2 | hunters land on the beast correctly | unchanged — 0 `hunter-off-marker` fails this run |
| 3 | jump animation (squash/arc/landing) | unchanged — clean, no pops, across every hop this run |
| 4 | camera | unchanged — 0 `hunter-offscreen`/`hunter-lost-mid-hop` fails; **new gap found and now checked**: the intent tag (not the hunter) can hide behind the party panel — filed |
| 5 | nothing errors | clean — 0 script-error fails across all three modes |

One commit this run: the new `intent-hidden` check in `playtest.gd`, pushed
before the verification runs finished (per COMMON.md 4b — a pushed check is
recoverable, an unpushed one that outlives this sandbox is not), then
proven live exactly as described above.

## Next

Watch for the fixer picking up either open request
(`2026-09-23-1735-...boss-damage-popup-offscreen-at-sigil.md`,
`2026-09-23-2141-...intent-tag-hides-behind-party-panel.md`) or the still-
unbuilt stone route (`2026-09-23-1846-...build-the-one-directional-stone-
route.md`). Once any of those land, re-run the full baseline and confirm
the matching check goes to 0 fails. Nothing else queued.

## Old: 2026-09-23 18:46 EDT, stone-route proposal closed out

- Did: claimed the lease, found Nick had answered the stone-route design
  question (`2026-09-23-1434-...`, "Approved, as written. Build it.") with
  text under its `## Nick's answer` heading — per COMMON.md 1b that's the
  top of the queue, ahead of anything else open. Read the fixer's numbers
  note (`2026-09-23-1736-...`) alongside it and filed the two build
  requests the original proposal promised.
- Worked?: Yes. Filed
  `2026-09-23-1846-playtester-to-fixer-build-the-one-directional-stone-route.md`
  (the raycast/`mark()` root-cause fix per Nick's "fix the cause, not just
  the sigil," the 2.4-9.2 unit arc-band spacing, the next-hold ring) and
  `2026-09-23-1846-playtester-to-artist-make-ledges-read-as-shelves.md`
  (the shelf-vs-floating-marker material pass Nick called out as the
  artist's). Closed both source notes: `1434` → `status: done` (design
  question answered, filed onward), `1736` → `status: done` (its numbers
  are now folded into the fixer request, no disagreement to raise).
- Next: watch for the fixer's build landing, then re-run the full playtest
  baseline and confirm the sigil no longer reverses and every hop measures
  inside the 2.4-9.2 band. Item 1 (card plays reading clearly) still hasn't
  had a fresh human-eye pass since real boss damage started landing last
  run.
- Need from you: nothing this run.

No game code changed that run — pure board bookkeeping, so it skipped the
usual full three-mode baseline. Two requests filed:
`2026-09-23-1846-playtester-to-fixer-build-the-one-directional-stone-route.md`,
`2026-09-23-1846-playtester-to-artist-make-ledges-read-as-shelves.md`.

## Old: 2026-09-23, boss-damage timing fix — first real win, crash fixed, popup bug filed

- Did: ran the usual full three-mode baseline first, the same as every
  run — and found the jackal's own HP had never moved once in ANY
  playtest run, ever. Traced it, fixed it in the playtest bot itself (not
  the game), and it uncovered a real bug once fixed.
- Worked?: Yes, and it's a big one. Every timed card (the ones that deal
  real damage) needs you to click a moving hit-circle on the beat. The
  bot was ALWAYS missing — not because it's bad at the game, but because
  this sandbox's renderer is too slow to ever catch the tiny window it
  was waiting for, the same root cause as the jump-sampling bug found
  earlier this week. Fixed with the same trick (slow the whole game down
  while it's aiming, same as it already does for jumps). Result: the
  jackal took real damage for the first time ever, and one run actually
  WON the fight — something no playtest run has ever done before, because
  no run has ever actually hurt the boss before. Fixing that then
  exposed a crash (the tool choking when the fight ends mid-swing) and a
  real game bug (a hit on the boss's own body pops its damage number off
  the top of the screen at the sigil, every time) — both real, both
  filed/fixed.
- Next: the fixer has a new bug from me (boss-damage number off-screen at
  the sigil). Item 1 (card plays reading clearly) can finally be judged
  for real damage now that hits land — worth a proper look next run.
- Need from you: nothing this run. The stones proposal
  (`2026-09-23-1434-...`) is still waiting on your yes/no, unchanged.

Full three-mode baseline first, same as every run: fresh sandbox, Godot
4.7.1 + `--import`, `run_tests.gd`: `ALL TESTS PASSED`. `mode=play` (80
steps): 0 fails, `PLAYTEST OK`. Nothing new there — but reading the
report closely (checklist item 1 hasn't had a fresh look in a while, per
last run's own `## Next`) turned up something every prior baseline had
missed: **the Cinder Jackal's own HP never appears in any `report.md`
diff, in any run, ever.** Checked the frame at the sigil (both hunters
there, hp worn down near zero) against the boss bar in the same shot:
`42/42`, unchanged from the fight's start. An 11-turn fight where the
boss never lost a single HP is not a balance question (never touching
that, per COMMON.md) — it's checklist item 1's "timed cards'... resolve"
never actually being exercised, ever, by any run before this one.

**Root cause.** `_drive_timing` (the bot's hit-circle driver) only
clicks when `absf(off) < 0.02` — a 40ms window — polled once per `await
process_frame`. This sandbox's software renderer draws a real frame
every ~0.1-0.3s (documented on `HOP_TIME_SCALE`, added for the exact
same shape of bug in jump sampling a few days ago). The offset crosses a
40ms window between two frames this bot can even see, so at 1x speed the
click condition could go an entire approach without ever firing once —
not a real gameplay problem, a guaranteed miss baked into how slow this
sandbox draws.

**Fix, same shape as the jump fix:** wrapped `_drive_timing`'s two
polling loops in the same `Engine.time_scale = HOP_TIME_SCALE` (1/6)
slow-down `_watch_hop` already uses, restored to 1.0 on every exit path,
guard caps raised 600→3600 to match. Verified against a real run:

    step 0: play 'Tongue Snap' [timed] ... boss 42→41
    step 3: play 'Tongue Flick' [timed] ... boss 41→31
    step 9: play 'Pounce' [timed] ... boss 31→17
    step 19: play 'Tongue Snap' [timed] ... boss 17→12

Real damage, landing for the first time in this fight's history.

**That surfaced a second bug, in the tool itself, not the game: a script
error once the boss can actually die.** Nothing before this run had ever
survived long enough to reach a scene transition mid-timing-drive (the
victory cutscene), so nobody had found that `_drive_timing`,
`_wait_and_poll` and `_watch_hop` all hold `v` (the whole Combat3D view)
across an `await`, and none of them re-check it's still alive before
handing it to `_poll_popup(v)` — a freed object passed to a typed `Node`
argument crashes at Godot's own call boundary, before the callee's own
`is_instance_valid` guard ever gets a chance to run. Took two passes to
close for real: the first pass guarded inside the three callees and
still crashed on the very next run, one level up the stack, at `_play`'s
own call site; the second pass guarded the actual call sites instead
(`_wait_and_poll`'s and `_drive_timing`'s callers in `_play`, plus
`_watch_hop`'s own poll call, same shape, fixed pre-emptively). Verified
clean on a fresh run after each pass — the second one reached step 30
with `the fight ended (screen is now Location3D)` and no script error at
all, the first time any playtest run has ever seen this fight through to
a real win. `run_tests.gd`: `ALL TESTS PASSED` after every change.

**What was left once both were fixed: one real, reproducible game bug.**
`damage-popup-offscreen` (an existing check, previously only ever
exercised by hunter-damage popups) now also catches a **boss**-damage
popup — 3/3 runs, step 19, same card, same on-screen position within a
few pixels, both hunters "at the sigil" when it fires:

![[frames/playtester/2026-09-23-boss-damage-popup-offscreen-sigil.png]]

Not the same root cause as the earlier hunter-popup bug (that fix's own
write-up says the boss-scaled rise is *correct* for a hit landing on the
beast) — most likely the tight sigil camera framing itself, not the
popup math; said so in the request rather than guess further. Filed
`to: fixer`, normal priority,
`2026-09-23-1735-playtester-to-fixer-boss-damage-popup-offscreen-at-sigil.md`.

`hover`: 0 flips. `hands`: 0 fails. Both clean after all four commits.

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | partially re-opened — boss damage now actually happens and mostly reads (3 real hits, 1 offscreen), first real evidence either way since this check shipped |
| 2 | hunters land on the beast correctly | unchanged — 0 `hunter-off-marker` across all runs this session |
| 3 | jump animation (squash/arc/landing) | unchanged — clean across all runs, no regression from the timing fix |
| 4 | camera | new lead — the boss-popup-offscreen bug is plausibly a camera-framing issue at the sigil specifically, flagged to the fixer to confirm |
| 5 | nothing errors | was broken (script-error) mid-run, now fixed and verified across 2 clean full runs post-fix |

Four commits this run, all pushed: the timing-sampling fix, the first
(incomplete) crash-guard pass, the second (actually complete) crash-guard
pass, and this write-up/request.

Watch for the fixer's response on the boss-damage-popup-offscreen
request. Once landed, re-run and confirm 0 `damage-popup-offscreen`
fails at/past the sigil. Item 1 (card plays reading clearly) is worth a
fresh human-eye pass now that boss damage is real and visible for the
first time — most of the deck has never been seen actually connecting.
The stones proposal is still waiting on Nick.

## Old: 2026-09-23, Nick's own design question on the floating stepping-stones

Took the open, high-priority `to: playtester` request
(`2026-09-23-1434-nick-to-playtester-how-the-stones-should-line-up.md`),
ahead of the usual baseline-and-one-item routine per COMMON.md ("requests to
you come before your own work"). Set `status: taken` and pushed that before
starting, per protocol. Fresh sandbox, Godot 4.7.1 + `--import`,
`run_tests.gd`: `ALL TESTS PASSED`.

**Checked for the fixer's promised numbers first.** Its matching request
(`2026-09-23-1423-nick-to-fixer-stones-camera-and-hunter-spacing.md`) was
still open and untaken, and no request from the fixer to me existed anywhere
in `requests/`. Rather than sit idle waiting on another agent, read the
placement code myself so the fixer has something concrete to react to.

**Root cause, found in the beast's own build script, not the placement
code.** `combat_3d.gd`'s `stone_point`/`foothold_anchor`/`stand_offset_x`
just place a stone and a hunter wherever a beast's own climb anchors say to
— they don't invent the route. The route is hand-authored per beast in
Blender (`tools/blender/beast.py`'s `shelf()`/`anchor()`/`mark()`,
`cinder_jackal.py`). Walked the Cinder Jackal's five authored holds in
order: paw → shoulder → haunch sweeps smoothly in one direction (the
authored depth coordinate moves the same way, monotonically, for four holds
running), then the fifth hold — the sigil, authored near the snout — swings
hard back past where the climb started. Four holds build a route; the fifth
throws it away. That's a per-beast authoring mistake, not a system-level
bug, which is good news for how cheap the fix is.

Rendered the establishing wide shot and a mid-climb shot to show the result
live rather than just describe it — both match Nick's "scattered rocks, not
a route" complaint exactly: four small stones bunched in a loose vertical
smear right in front of the jackal's face/neck, no readable shape.

![[frames/playtester/2026-09-23-stones-route-wide-before.png]]
![[frames/playtester/2026-09-23-stones-route-midclimb-before.png]]

**Wrote the proposal into the request's own `## Result`.** Two rules: (1) a
route only ever sweeps one direction — the fix for the Cinder Jackal
specifically is re-authoring the sigil hold to continue the same sweep
instead of reversing it; (2) ordinary hold-to-hold hops should stay inside
the distance range `hop_arc` already scales proportionally at (roughly
2.4-9 world units, read straight out of its own `clampf` call) rather than
bunched at its floor, where every short hop gets the same minimum pop
regardless of how close the stones actually are — which is exactly what
makes tightly-packed stones look like bouncing in place. Also covered the
climbing-feel half: always telegraph the NEXT hold before the card that
sends you there is played, and the wide establishing shot has to sell the
whole route since that's the shot the scattered-stones problem is most
visible in. Five references (Shadow of the Colossus, Breath of the Wild,
Jusant, Only Up! as the anti-pattern, Celeste, Sekiro), one line each on
what we take and why. Full text in the request.

Did not file build requests to the fixer or artist — the request is explicit
that the split work waits on Nick's yes, so as not to ship two disagreeing
halves if the fixer's own numbers land with different constraints.

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | unchanged this run |
| 2 | hunters land on the beast correctly | unchanged this run — no baseline regression expected, this run touched only a design document, no game code |
| 3 | jump animation (squash/arc/landing) | unchanged this run |
| 4 | camera | unchanged this run — the stones proposal touches how the wide shot should read, but nothing was built yet, only proposed |
| 5 | nothing errors | ok — `ALL TESTS PASSED`, and the full 80-step `mode=play` baseline finished clean while this note was being written: `PLAYTEST OK: 0 failing check(s)`, no `script-error`. Confirms this run's design-document-only change caused no regression. |

One request answered this run (not filed — Nick's own, `to: playtester`,
now `status: done` pending his yes/no):
`2026-09-23-1434-nick-to-playtester-how-the-stones-should-line-up.md`.

## Next

Waiting on Nick's answer under the request's `## Nick's answer`/`## Result`
heading. Once he says yes, file the actual build work: to the fixer
(re-author the Cinder Jackal's sigil hold to continue the same sweep instead
of reversing it, plus the hop-distance rule for future beasts) and to the
artist (make the stone material read as "the path" from the wide
establishing shot, not just up close — the Breath of the Wild reference).
If the fixer's own numbers land first, fold them into the proposal rather
than leave two disagreeing halves standing. `hop-position-pop` and
`hunter-lost-mid-hop` remain live from recent runs with 0 real fails found —
worth remembering they exist next time a climb or camera change lands. Item
1 (card plays) still hasn't had a fresh human-eye look in several runs.

## Old: 2026-09-23, hop-position-pop check added, full baseline clean

No open `to: playtester` request that run (checked every file's frontmatter —
the board's other open items were all `to: nick` or `to: fixer`; the fixer's
own `2026-09-23-0715-...-shared-foothold-side-spacing-clears-the-model.md`
was still open and untaken **as of the tip that container started from** —
see the note below and the entry right after this one: it has since landed
and been verified clean by a concurrent playtester run). Fresh sandbox,
Godot 4.7.1 + `--import`, `run_tests.gd`: `ALL TESTS PASSED`.

**Full three-mode baseline, against a tip that predates the shared-foothold-4
fix.** `hover` 0 flips, `hands` (1-10) 0 fails. `play` (80 steps): 3
`hunter-off-marker` fails at foothold 4 (steps 34, 35, 71), exact same
coordinates as every prior baseline before the fix — consistent with the
pre-fix code that run's own container started from, not a regression and not
news: a `git pull --rebase` at push time surfaced a concurrent playtester run
that had already landed and verified the fixer's fix on a newer tip (see the
`## Old` entry directly below this one for their write-up and frames).
Checklist item 2 is closed on the current tip; that run's own numbers above
are the last pre-fix data point, kept here for the record rather than
silently dropped.

**New check: `hop-position-pop`, JACKAL-BAR Motion's "no pops: nothing
teleports, flickers, or snaps between frames" — the mid-jump half, since
`hop-leftover-squash` already covers a pop in SCALE at landing but nothing
checked POSITION continuity.** `_watch_hop` already samples the animated
node's real position every real frame during a climb (for the arc/squash
checks); this reads the SAME samples for a frame-to-frame jump that doesn't
belong.

This one took three attempts to ship clean, and the two failures are worth
recording in full because both were false alarms this playtester almost
believed, per this bot's own standing rule (item 3's history) to read the
actual numbers before trusting a check's verdict either way:

1. **First version** compared each frame-to-frame step to the WHOLE hop's
   own median. It false-fired on the very first real run: step 17, a plain
   single-leg Leap (y 8.99→18.17, the exact climb the fixer's own `hop_arc`
   fix comment already documents) — "hunter position jumped 0.97m... 15.5x
   the median". Dumped the actual y-samples around the flagged step before
   believing it: 13.826 held flat for 4 samples (the anticipation squash's
   own hold), then 14.525, 15.446, 16.294, 17.164, 17.854, 18.441, 18.977 —
   smooth, monotonic, decelerating, not a jump anywhere in it. `_hop`'s rise
   tween is EASE_OUT: fastest the instant it starts moving, right after the
   anticipation hold ends — exactly where the flagged step landed. The
   whole-hop median is dragged down by the hold and the near-zero-velocity
   hang phase elsewhere in the SAME hop, so the genuinely fastest (but
   perfectly smooth) moment of an eased curve reads as a huge outlier
   against it.
   ![[frames/playtester/2026-09-23-hop-position-pop-check-step17-strip.png]]
   Cropped strip on the Goblin Engineer, samples 65→82 of that exact climb:
   standing still on the ground through 65-70 (the anticipation hold), one
   continuous ascending jump starting at 71-72, still rising and moving
   right through 73 and off-frame by 75 — real, smooth motion, not a snap.
2. **Second version** compared each step only to its two immediate
   neighbours instead — the real climb above passed clean, but proving the
   OTHER direction (a check that can only ever pass proves nothing) found a
   real hole before shipping it: a synthetic one-frame position stomp that
   reverts on the very next sample (`+Vector3(3,0,0)` at one sample only,
   injected in `_watch_hop`'s own sampling loop, temporarily) produces TWO
   large, almost-equal deltas back to back — each one's only neighbour is
   the OTHER large delta, so each reads as "comparable neighbours, not
   isolated" and a real 3m jump sailed through undetected.
3. **Shipped version**: a two-sided local window (`POP_WINDOW` = 8 samples
   each side, the flagged one excluded, median of the rest) instead of one
   neighbour on either side — a real multi-sample ramp (the 7-sample rise
   above) still blends into a window that size, but a lone 1-2 sample spike
   cannot hide inside it. Also needs real samples on BOTH sides
   (`i - lo >= 3 and hi - i >= 3`) after a second live false-fire at the
   very edge of a short hop (step 71, foot 10→4, near the already-known
   foothold-4 residual) — the first delta of a flight has no "before" to
   compare against, only the decelerating tail of the same EASE_OUT rise
   AFTER it, and re-running the identical scenario passed clean: a real bug
   reproduces every time, this flickered on nothing but real-frame timing.

**Proved the shipped version both directions, for real this time:**
- *Positive*: the full 80-step baseline above, plus three earlier full
  80-step runs during development (4 real climbs total: steps 1, 17, 34,
  71, sizes 26-110 samples) — 0 `hop-position-pop` fails on any of them,
  worst frame-to-frame steps 0.46m-1.99m, none an isolated spike against
  its own local window.
**Also re-verified after the rebase below landed the real foothold-4 fix**
(which changes the exact geometry at steps 34/71, two of the four climbs
this check was tuned against): a fresh full three-mode baseline against
the rebased tip — `play` (80 steps) **0 failing checks at all**, `hover` 0
flips, `hands` 0 fails. `hop-position-pop` stayed silent on all four climbs
with the new, correct foothold-4 geometry (worst steps 0.49m-1.93m, same
shape as before), and checklist item 2 is now genuinely closed on code that
run itself tested, not just reported secondhand.

- *Negative*: re-ran the same synthetic injection (`+Vector3(3,0,0)` at one
  sample, `_watch_hop`, temporary) against the shipped version — correctly
  flagged both hops it touched ("30000.0x the local median", "15.6x the
  local median"). Reverted immediately (`git diff` clean before moving on),
  then re-ran `run_tests.gd` and the final full three-mode baseline on the
  real code to get the numbers above.

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | unchanged that run (no fresh human-eye look; still worth returning to) |
| 2 | hunters land on the beast correctly | **closed, verified twice** — a concurrent playtester run verified the fixer's fix clean first; that run independently re-verified it again after rebasing onto the same tip (0 `hunter-off-marker` fails, steps 34/71 both correct) |
| 3 | jump animation (squash/arc/landing) | **new automatic check added**, `hop-position-pop` — proved both directions (3 dev iterations, 2 false-positive versions caught and fixed before shipping); found no real pop in the wild, but the coverage is new and permanent, and closes the "no pops... mid-jump" half of JACKAL-BAR's Motion item |
| 4 | camera | unchanged that run — `hunter-lost-mid-hop`/check 9 still 0 fails in the wild |
| 5 | nothing errors | ok — `ALL TESTS PASSED`, no `script-error` that run |

No new requests filed that run — nothing failed that wasn't already known
and owned by an existing open request.

## Old: 2026-09-23, shared-foothold-4 residual fixed and verified clean (concurrent run)

No open `to: playtester` request this run (checked every file's frontmatter —
the board's other open items are all `to: nick`). Fresh sandbox — local
`main` arrived stale again (this container's checkout shared no merge-base
with `origin/main`; the classifier initially refused the branch-reset as
"irreversible local destruction" since the sandbox's own history predated a
remote rewrite, so tagged the stale tip first (`backup-stale-local-main-*`)
so nothing was actually lost, then did `git checkout -B main FETCH_HEAD` per
COMMON.md 0). Claimed the lease (`tools/agents/lease.sh claim playtester`,
exit 0 — no overlapping run). Godot 4.7.1 + `--import`, `run_tests.gd`:
`ALL TESTS PASSED`.

**Full three-mode baseline, completely clean — first time in several runs.**
`hover` 0 flips, `hands` (1-10) 0 fails (both matching every prior clean
baseline). `play` (80 steps): **0 failing checks.** This is the first clean
`play` baseline since the shared-foothold-4 residual started showing up —
every recent run (see `## Old` below) has shown `hunter-off-marker` failing
2-4 times at the exact same coordinates (`home (5.335257, 13.825942,
7.030925)`, anchor `(3.901302, 13.825942, 6.473297)`), all traced to the
fixer's own self-filed
`2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`.
That request went `done` since my last run — this run is the first live
verification since the fix landed.

**Verified the fix holds, both by the check and by eye.** This run's own
seed still puts both hunters on foothold 4 together twice (step 34: Frog
`foot 7→4`; step 71: Goblin Engineer `foot 10→4`), the exact repro shape
that failed on every prior run — and both times `hunter-off-marker` stayed
silent. Looked at both frames at 1:1, not just trusted the check: both the
Frog and the Goblin Engineer stand visibly grounded on the jackal's ear/mane,
feet on the model, not the old "hovering clear of both the model and the
stone" shape the fixer's own before-fix crop showed.

![[frames/playtester/2026-09-23-foothold4-shared-fixed-step034.png]]
Step 34 — both hunters share foothold 4. The Frog stands on the basalt stone
at the jackal's ear, the Goblin Engineer stands on the mane fur beside it —
both grounded, matching the fixer's fix (`stone_point()` now pushes purely
forward instead of radially, so it no longer adds its own x-drift on top of
`stand_offset_x`'s spacing).

![[frames/playtester/2026-09-23-foothold4-shared-fixed-step071.png]]
Step 71 — the same shared-foothold-4 moment later in the fight (Goblin
Engineer `foot 10→4`), same clean result.

`ALL TESTS PASSED` throughout; no `script-error` in any of the three runs.

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | unchanged this run — no fresh human-eye look; still worth returning to, several runs overdue now |
| 2 | hunters land on the beast correctly | **fully closed** — the shared-foothold-4 residual that dogged at least five prior baselines is gone; verified live at both repeat instances this run, by check and by eye |
| 3 | jump animation (squash/arc/landing) | unchanged this run |
| 4 | camera | unchanged this run — `hunter-lost-mid-hop` still 0 fails in the wild |
| 5 | nothing errors | ok — `ALL TESTS PASSED`, 0 `script-error` across all three modes |

No new requests filed this run — the one open thread this run existed to
verify (foothold-4) closed clean; nothing else failed.

## Old: 2026-09-23, hand-over-hud check verified both directions

No open `to: playtester` request this run (checked every file's frontmatter —
the board's other open items are all `to: nick` or `to: fixer`). Fresh
sandbox, Godot 4.7.1 + `--import`, `run_tests.gd`: `ALL TESTS PASSED`.

**Full three-mode baseline, clean except the one known residual.** `hover` 0
flips, `hands` (1-10) 0 fails — both matching every prior clean baseline.
`play` (80 steps): **3 failing checks**, all `hunter-off-marker` (steps 34,
35, 71), the exact same coordinates as every recent run (`home (5.335257,
13.825942, 7.030925)`, anchor `(3.901302, 13.825942, 6.473297)`) — the
fixer's own still-open, still-untaken
`2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`.
Not a new finding, not regressed. Ran this baseline **twice** today (once
before touching `playtest.gd`, once after, both against the same tip) — same
3 fails both times, so today's new check below caused no change to the
existing checklist.

**The End Turn crash the fixer took this run's queue over for is holding.**
Their `## Result` on
`2026-09-23-1000-playtester-to-fixer-end-turn-crash-at-sigil-solo-flip.md`
found it was never actually a race — `_focus_camera()` runs on a camera
that's deterministically left the tree whenever an End Turn is the one that
ends combat, and this sandbox's slow renderer only looked like it was
flip-flopping because it nudges which End Turn that is. Fixed with an
`is_inside_tree()` guard plus two new tests against a real `combat_3d.tscn`
(their own unit-level proof is the authoritative one — a live run can only
ever add "didn't happen this time," not "can't happen"). Still, both of
today's full 80-step runs exercised End Turn heavily (11 and 15 uses, one
run dropping boss hp 42→6 across five real hits) with zero `script-error` —
real, if partial, live corroboration on top of their test.

**New check: `hand-over-hud`, JACKAL-BAR's "nothing important is behind the
hand... at any hand size."** Check 5 already stops a resting card from
covering End Turn/Switch (unclickable); nothing checked the things a player
needs to *read* instead — the boss's intent tag, its hp bar, the party
panel, the climb rail (`_gauge`). Worth a permanent check for two concrete
reasons, not just symmetry with check 5: `_position_intent_tag`'s own
comment says it clamps 250px off the bottom of the screen specifically "to
clear the hand," a number picked for some assumed hand height, never
verified against the real one; and the hand's own fan is allowed to spread
past its `HandScroll` container (`clip_contents = false`, on purpose, so
check 4's offscreen check has something to catch) — exactly the situation
where a big hand's outer cards could reach further than usual. `mode=hands`
already deals every hand size 1-10 and calls `_check()` at each one, so this
needed no new plumbing, just something for it to check.

Proved it both directions, not just "ran clean":
- *Positive*: `mode=hands` (all 10 sizes) — 0 `hand-over-hud` fails, and the
  full 80-step `play` baseline above (which passes through every hand size
  the deck actually produces) shows the same. The `_gauge`/party/hp-bar/
  intent-tag margins hold for real, not just by luck — see the frame below,
  hand of 10, the largest and most spread-out fan the game deals.
- *Negative*: temporarily grew the card-vs-HUD-element intersection test from
  `grow(-6)` (the real, deliberately-tight tolerance) to `grow(500)` and
  reran `mode=hands` — got **43** `hand-over-hud` FAILs, hitting all four
  watched elements (`_intent_tag`, `_hp_bar`, `_party`, `_gauge`) at every
  populated hand size, confirming the check logic actually fires rather than
  silently no-op'ing (a wrong node path or an always-false condition would
  have passed "clean" for the wrong reason). Reverted immediately
  (`git diff` clean before moving on), then reran `run_tests.gd` and a fresh
  `mode=hands` + full 80-step `mode=play` baseline on the real code: clean,
  identical to the pre-change numbers above.

![[frames/playtester/2026-09-23-hand-over-hud-check-hand10-clear.png]]
Hand of 10 (the widest fan the deck deals) — the party panel (top-left), the
Cinder Jackal's hp bar and "Attack 7" intent tag (top-center), and the climb
rail (right edge) all stay clear of the fan. This is the real case the new
check now watches on every run, not just this one frame.

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | unchanged this run (no fresh human-eye look; still worth returning to) |
| 2 | hunters land on the beast correctly | unchanged — the shared-foothold-4 residual is still the fixer's own open, untaken request; today's 3 fails match its exact known coordinates, both baseline runs |
| 3 | jump animation (squash/arc/landing) | unchanged this run |
| 4 | camera | unchanged this run — `hunter-lost-mid-hop`/check 9 still 0 fails in the wild |
| 5 | nothing errors | **the End Turn crash fix (fixer, this run's queue) is holding** — 0 `script-error` across two full 80-step baselines with heavy End Turn use; the fixer's own unit tests remain the authoritative proof, this is corroborating, not substituting |
| new | JACKAL-BAR "nothing important behind the hand... at any hand size" | **new automatic check added**, `hand-over-hud` — proved both directions; found no bug in the wild (the existing margins hold), but the coverage is new and permanent |

No new requests filed this run — nothing failed that wasn't already known
and owned by an existing open request.

## Old-Next

Checklist item 2 is now fully closed — no known residual left to watch. The
loudest overdue item is item 1 (card plays read): it hasn't had a fresh
human-eye look in several runs now (every recent run picked up a
higher-priority verification instead — the End Turn crash, then
hand-over-hud, now foothold-4). Worth doing next run: a frame-strip look at
a typical card play (does the played card visibly leave the hand, does the
effect land on the beast, does a number/state change follow — per this
playtester's own brief, item 1's "does something on the beast" half hasn't
had a fresh look since the damage-popup work two+ runs ago). `hand-over-hud`
and `hunter-lost-mid-hop` remain live with 0 real fails found — worth
remembering they exist next time a HUD or camera change lands.

## Old: 2026-09-23, damage-popup-offscreen check verified live, no new bugs

No open `to: playtester` request this run (checked every file's frontmatter).
Fresh sandbox, Godot 4.7.1 + `--import`, `run_tests.gd`: `ALL TESTS PASSED`.

**Full three-mode baseline**: `hover` 0 flips, `hands` (1-10) 0 fails — both
clean, matching every prior baseline. `play` (80 steps): **3 failing
checks**, all `hunter-off-marker` (steps 34, 35, 71), all sharing the exact
same coordinates as every recent run (`home (5.335257, 13.825942,
7.030925)`, anchor `(3.901302, 13.825942, 6.473297)`) — this is the fixer's
own still-open `2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`,
untaken since it was filed, unchanged today. Not a new finding, not
regressed, not improved. No `script-error` this run — the intermittent End
Turn crash from my last run's `2026-09-23-1000-playtester-to-fixer-end-turn-crash-at-sigil-solo-flip.md`
(also still open, untaken by the fixer) did not reproduce here either. Worth
being honest, same as that request's own `## Done when` says: a race that
doesn't fire on one more clean run is not proof of anything — it just wasn't
this run's turn.

**Checklist item 1's remaining gap is now closed, both the bug and the
coverage.** The fixer took my `hunter-damage-popup-offscreen` request this
run (commit `9653ecc`, `Combat3D.popup_move_reach`) — their root cause
(popup travel distance scaled off the BEAST's height even for a hit that
landed on a HUNTER, six-plus hunter-heights too far) was not my own guess
from that request (an in-flight camera transition), so this needed a fresh
look, not just trusting the fix. This run's clean 80-step baseline already
shows it working live: 5 real hp-loss events (steps 34, 50, 65, 71, 77), 0
`damage-popup-missing` fails (existence, check 10, unchanged) — but until
today nothing checked existence's other half, VISIBILITY, in the wild.
That's exactly what my own last two runs' `## Next` kept flagging as the
natural follow-up once the fixer knew the real cause.

Added it: `_poll_popup` (playtest.gd) now asks the same camera question
check 9 already asks about a hunter — behind the camera, or projecting
outside the viewport — about every live `Label3D` popup's OWN current
position, every frame it's still polled (not just once at first sighting).
That last part matters: the original bug was a popup that started ON screen
and rose OFF it over its own ~1.7s tween (the fixer's own write-up: screen y
301 → -217), so a spawn-time-only check would have missed the exact case
this exists to catch. Latched per step like the existence check, one bad
frame anywhere in the popup's life is enough — new failure
`damage-popup-offscreen`.

**Proved it both directions, not just "ran clean once".**

- *Positive*: full 80-step `mode=play` baseline against the real, fixed
  code — 0 `damage-popup-offscreen` fails across all 5 real hp-loss events.
- *Negative*: temporarily reverted the fixer's own fix in `combat_3d.gd`
  (`popup_move_reach` back to always returning `beast_reach`, ignoring
  `on_hunter`) and reran a 36-step slice. Got exactly **3**
  `damage-popup-offscreen` FAILs, at the same shape the fixer's own
  before-fix numbers showed (screen y -89, -28, -86 — all well above the top
  of a 720px-tall viewport). Checked one by eye too: step 9's saved frame
  shows the HUD boss bar correctly at 42→31, but no floating number anywhere
  on screen — matching the check's verdict, not just trusting the number.
  Reverted the break immediately after (`git diff game/views/combat_3d.gd`
  clean before moving on), then re-ran `run_tests.gd` and a fresh full
  80-step baseline on the real code to get final numbers: clean, only the
  known foothold-4 residual above.

![[frames/playtester/2026-09-23-damage-popup-offscreen-check-negative-test-step009.png]]
The negative-test frame (fixer's fix temporarily reverted, for this proof
only) — boss HP visibly dropped 42→31 in the HUD, but no damage number is
anywhere on screen. This is the exact shape the new check now catches
automatically on every run.

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | **gap closed** — the off-screen damage-number bug (filed two runs ago) is fixed by the fixer (`9653ecc`) and now has permanent automatic coverage (`damage-popup-offscreen`), proved both directions |
| 2 | hunters land on the beast correctly | unchanged — the shared-foothold-4 residual is still the fixer's own open, untaken request; today's 3 fails match its exact known coordinates |
| 3 | jump animation (squash/arc/landing) | unchanged this run |
| 4 | camera | unchanged this run — `hunter-lost-mid-hop` (added last run) still live, still 0 fails in the wild |
| 5 | nothing errors | ok this run (`ALL TESTS PASSED`, no `script-error`) — but the intermittent End Turn crash request is still open and unconfirmed either way; one more clean run is not proof it's gone |

No new requests filed this run — nothing failed that wasn't already known
and owned by an existing open request.

## Next

Two open `to: fixer` requests are still the loudest unclaimed items on the
board: my own high-priority End Turn crash
(`2026-09-23-1000-playtester-to-fixer-end-turn-crash-at-sigil-solo-flip.md`)
and the fixer's own shared-foothold-4 spacing
(`2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`),
both untaken across at least two of my runs now. Watch for either landing,
then re-baseline: the crash needs several repeated clean runs to mean
anything (it's a race, not a deterministic repro), and foothold-4 needs a
re-check of item 2 once fixed since it's shown as intermittent even in its
current broken state. `damage-popup-offscreen` and `hunter-lost-mid-hop` are
both live now with 0 real fails found in the wild — worth remembering they
exist as coverage the next time a popup or camera change lands. Items 3/4's
human-eye frame-strip look is still current from two runs ago; nothing new
to add there this run.

## Old: 2026-09-23, mid-hop camera check, end-turn crash filed
Fresh sandbox, Godot 4.7.1 + `--import`, `run_tests.gd`: `ALL TESTS PASSED`.

**First full three-mode baseline came back completely clean** — a first for
several runs: `play` (80 steps) 0 fails, `hover` 0 flips, `hands` (1-10) 0
fails. The shared-foothold-4 residual that's been showing up in recent runs
(the fixer's own open
`2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`,
still untaken) simply didn't trigger this particular run — both hunters
never happened to occupy foothold 4 at the same settled-check moment on this
run's exact real-time path. Not claiming it's fixed (that request is still
open, unfixed, and I saw its exact failure mode again two runs later, see
below) — just noting today's first baseline happened to dodge it.

**Extended `playtest.gd` for checklist item 4's other half.** Check 9 (the
camera check) is explicit in its own comment that it only judges the
SETTLED shot — mid-hop framing is a separate, already-documented gap this
playtester's own `## Next` has flagged across at least three prior runs
("only the mid-hop transient... is a separate, already-documented gap").
JACKAL-BAR itself names it directly: "the camera never loses the active
hunter, **including mid-jump**." `_watch_hop` already samples the animated
hunter node every real frame while a climb tween runs (for the arc/squash
checks) — piggybacked the same loop: each sample also asks the live camera
`is_position_behind` / `unproject_position` against the hopping hunter's
`global_position`, same API check 9 already uses. Only meaningful when the
camera is actually following THIS hunter (`lock_slot_for(...) == me`, the
same fix check 9 needed after it first false-fired on the OTHER hunter
mid-climb) — skipped otherwise, so a hunter hopping off-frame while the
camera is deliberately locked on their ally never counts. Gated on
`MIN_HOP_SAMPLES` like the arc/squash checks (below that, not enough
evidence, say nothing), and only fails when the hunter was off screen for
**more than half** the sampled flight — a single-frame graze at a wide arc's
edge is not "the camera lost the hunter," and check 9 already owns the
settled end-state; new check `hunter-lost-mid-hop`.

Proved it both ways, per this playtester's own past mistake of trusting a
check that can only ever pass: smoke-tested at 20 steps first (4 hops
sampled, 0% off every time, no false positives), then deliberately broke it
(`if true or cam.is_position_behind(...)`, forcing every sample to read as
off-screen) and reran a 12-step slice — got exactly one
`hunter-lost-mid-hop` FAIL, "111/111 sampled frames (100%)". Reverted before
anything else.

**A follow-up full 80-step baseline with the finished check surfaced a real
engine crash, unrelated to my own change.** Ran the full baseline again
(same code, same seed) to get final numbers with the new check live:
`script-error` x2, the run truncated at step 64 out of 80 — a genuine Godot
assertion, `node_3d.cpp: Condition "!is_inside_tree()" is true`, thrown from
`combat_3d.gd`'s own `_apply_orbit` (called via `_focus_camera` via
`_apply_solo_turn_flip` via `_end_turn`) trying to `look_at` a camera that
was no longer in the scene tree — which then killed the whole game view, and
this bot's own harness threw a second, secondary error polling the now-freed
node. Checklist item 5 ("nothing errors") at its worst: not a cosmetic
glitch, a crash that ends the fight. A THIRD full baseline run (again,
identical code/seed) did NOT reproduce it — ran clean 80 steps, only the
already-known shared-foothold-4 residual (3x, matching the fixer's own open
request's exact numbers). One crash in three otherwise-identical runs is a
timing/race signature, not a deterministic logic bug — exactly the shape
this sandbox's slow software renderer is good at surfacing. Filed to the
fixer, priority high, with the full stack trace, the frame right before the
crash, and an honest note that I can't hand them a repro that fires every
time.

![[frames/playtester/2026-09-23-end-turn-crash-step063-before-crash.png]]

**Also did the human-eye frame-strip look on items 3/4 this playtester's own
`## Next` has been deferring for several runs** ("`a823001`... still hasn't
had a frame-strip look at anything OTHER than the two bugs it turned up").
Tiled 6 frames across a typical, non-sigil, non-foothold-4 climb (step 0,
the very first ground climb, endpoints y 0.00→8.97) and looked at it at 1:1:
real motion across the strip, the Frog visibly arcing from behind the
jackal's hind leg to a floating stone off to the side, not a frozen or
teleporting frame. No new bug there. Also looked again at a sigil-approach
hop (step 17) purely to sanity-check the mid-hop camera check's own
"0% off" verdict against a human eye, since that climb's endpoint sits right
at the sigil where the camera is known to pull in tight on the jackal's
head: confirmed the check is technically right (the Frog does project
inside the viewport, both hunters visible, tiny, perched on the jackal's
head between the ears) but a human would still call this "barely readable"
— the same known gap this playtester has logged before (Nick's third-person
camera target still pending), not a new finding, so not re-filed.

![[frames/playtester/2026-09-23-hop-strip-ground-climb-step000.png]]
![[frames/playtester/2026-09-23-sigil-camera-close-known-gap-step017.png]]

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | unchanged this run |
| 2 | hunters land on the beast correctly | unchanged — the shared-foothold-4 residual is still the fixer's own open request; today's runs show it as intermittent (0 of 3 baselines had it fail, then 3x on the 3rd) rather than fixed |
| 3 | jump animation (squash/arc/landing) | human-eye frame-strip look on a typical climb, first one done since `a823001` two runs ago — real arc, no new bug |
| 4 | camera | **new automatic check** — `hunter-lost-mid-hop`, the "including mid-jump" half JACKAL-BAR names and check 9 explicitly skipped; proved both directions; found no bug in three runs' worth of hops, but DID surface (indirectly, by running the extra baseline to get clean numbers) the End Turn crash above |
| 5 | nothing errors | **regression found** — a real, if intermittent, crash on End Turn (`_apply_orbit`/`_cam` not in tree), filed to the fixer, high priority, not yet fixed |

One request filed this run: `to: fixer`, priority high,
`2026-09-23-1000-playtester-to-fixer-end-turn-crash-at-sigil-solo-flip.md`.

## Next

Watch for the fixer taking the End Turn crash request — it's the loudest
finding this run (checklist item 5) and worth a fresh multi-run baseline
once a fix lands, since "ran clean" needs several repeats to mean anything
for a race, not one. The shared-foothold-4 residual is unchanged, still
sitting on the fixer's own open request; keep an eye out for it going
`done`, then re-verify item 2 across a few runs (today showed it's
intermittent even unfixed, so one clean run won't prove it closed).
`hunter-lost-mid-hop` is live now and found nothing yet — worth remembering
it exists next time a camera complaint comes in, since it's the first
automatic coverage of the mid-jump half of item 4 at all. Item 1 (card
plays) hasn't had a fresh look in a few runs; still worth returning to.

## Old: 2026-09-23, verify c8e965b's foothold-4 fix, fix a hop-flat false-fire in playtest.gd itself

Fresh sandbox (detached HEAD on a stale local `main` from container init —
origin/main and local main share no merge-base, so worked from
`origin/main` directly rather than force-resetting a branch ref without
asking). No open `to: playtester` request this run. HEAD started at the
fixer's own `c8e965b` ("stand_z_for trusts an exact rung's own anchor over
the hull"), which targets exactly the foothold-4 float regression I filed
last run.

Set up fresh (Godot 4.7.1 + `--import`, Xvfb), `run_tests.gd`: `ALL TESTS
PASSED`. Full three-mode baseline against `c8e965b`: `hover` 0 fails,
`hands` 0 fails (clean, matching every prior baseline). `play` (80 steps):
**2 failing checks**, `hunter-off-marker: 4` and `hop-flat: 2`.

**Foothold-4: verified the fix is real, not a no-op — and while I was
writing up the residual, the fixer beat me to it.** Before `c8e965b`,
`home.z` at foothold 4 was 10.25 — a hunter hanging in open air against the
arena wall, ~4m from the marker. After, it's 7.03, right next to the
anchor's own 6.47 — the frame now shows the hunter standing on solid ground
near the jackal's ears, not floating in dead air:

![[frames/playtester/2026-09-23-hunter-off-marker-foothold4-after-standz-fix-step038-feet.png]]
![[frames/playtester/2026-09-23-hunter-off-marker-foothold4-after-standz-fix-step038.png]]

`hunter-off-marker` still fires 4x (steps 38/39/78/79, `x` off by 1.43
against a 1.06 tolerance) — I had a follow-up request drafted for this when
a `git fetch` mid-run turned up the fixer's OWN `4c15649` ("close out
foothold-4 float — proof, write-up, and the residual"), pushed while I was
still rendering: they independently hit the exact same numbers
(`home (5.335257, 13.825942, 7.030925)`, same anchor, same 1.54m), traced it
further than I had (a debug print confirming both hunters share foothold 4
simultaneously, and `stand_offset_x`'s spacing — sized off the whole beast's
bounding-box width — overshoots the jackal's much narrower ear at that
specific foothold, plus `_build_float_stones` only ever building one
centred stone per height so the side-shifted hunter has nothing to land on
regardless), and self-filed
`2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`.
Two independent same-day findings landing on identical numbers is about as
strong a confirmation as this gets. Deleted my own draft rather than file a
duplicate — nothing left for me to add here; checklist item 2 stays at
"real, large improvement, smaller residual already owned."

**`hop-flat` fires 2x near the sigil, steps 49/50 — chased it down, and it
was my own tool's bug, not the game's.** Both captures had only 5 in-flight
samples and reported the peak sitting at EXACTLY the start height (18.13).
`hop_arc`'s own proven invariant (apex clears both endpoints by at least
`HUNTER_HEIGHT * 0.9`, regardless of distance — an existing unit test)
made that suspicious rather than a clean "reads as a slide" verdict. The
`git fetch` above also surfaced the fixer's OWN independent run hitting the
same shape at yet a THIRD set of step numbers (30/42/52/53, different
footholds, 6-7 samples) and dismissing it as matching my own previously-
documented sparse-sampling flake pattern. Two independent runs failing at
different steps each time is the opposite of what a real geometry bug would
do (same footholds every run) — it's the signature of a sampling gap.

Both 5-frame strips, both hunters essentially static throughout (still
reading "at the sigil" in every saved frame):

![[frames/playtester/2026-09-23-hop-flat-near-sigil-step049-strip.png]]
![[frames/playtester/2026-09-23-hop-flat-near-sigil-step050-strip.png]]

Found it: `_check_hop`'s confidence gate (`covered_from_start`) has a
`total_dist < 0.05` bypass for near-zero-distance climbs that doesn't
actually verify the samples covered the flight's real TIME, only that the
first sample was spatially close to a start/end pair that are already
almost the same point — trivially true regardless of when sampling began.
Near-sigil climbs where consecutive footholds compress to nearly the same
anchor hit this exactly, and on this sandbox's slow renderer sometimes only
get 4-6 real samples across the whole hop, which can land entirely outside
the rise/hang window purely by bad luck.

**Fixed in `playtest.gd`, not filed to the fixer** (this is my own tool,
squarely in "extend it" territory) — added `MIN_HOP_SAMPLES := 10`,
AND'd into `covered_from_start` alongside the existing spatial check.
Strictly conservative: it only ADDS a requirement, so it can never turn an
already-correct fail into a pass, only move an under-sampled "confident"
capture to "not judged." Checked against this run's own report.md before
touching anything: real, meaningful climbs got 25-120 samples every time
(steps 17, 34, 38, 78); the degenerate near-sigil ones that misfired got
4-6 (steps 10, 19, 20, 32, 36, 37, 41, 43, 49, 50) — the threshold cleanly
separates the two populations in real data, not a guess.

**Verified, not just reasoned about.** Re-ran `mode=play steps=51` (covers
the exact repro plus the big, well-sampled climbs) after the fix:
`hunter-off-marker: 2` is the ONLY failing check left — `hop-flat` and
`hop-no-squash` are gone. The five previously-flagged-or-flaggable
under-sampled captures (steps 19, 20, 36, 37, 43) now correctly report "too
few samples, arc/squash not judged" instead of a verdict. The two
well-sampled climbs in the same run (step 17: 120 samples, step 34: 26
samples) still get judged normally, "from the start" — so a real hop_arc
regression on a real climb would still be caught, unweakened.

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | unchanged this run |
| 2 | hunters land on the beast correctly | **improved, residual owned by the fixer's own request** — `c8e965b` fixed the open-air float; the smaller shared-foothold gap is diagnosed and self-filed by the fixer (`2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`), nothing further for me to add |
| 3 | jump animation (squash/arc/landing) | **checker bug found and fixed** — `hop-flat` was false-firing on under-sampled near-sigil captures; `MIN_HOP_SAMPLES` gate added to `playtest.gd`, verified clean on a fresh run with the real bug-catching cases (25-120 samples) still judged |
| 4 | camera | unchanged this run |
| 5 | nothing errors | ok — `ALL TESTS PASSED`, no script errors in any log this run |

## Old: 2026-09-23, foothold-4 float regression (superseded by this run's verification above)

No open `to: playtester` request this run (the board's only other open
items are `to: nick` — boss-relic-pool, hunters-at-pass-cap,
model-rendered-card-art-direction — and my own still-open `to: fixer`
damage-popup-offscreen request from last run, untaken). Ran the full
baseline first, unmodified `playtest.gd`, against today's tip — which,
since my last run, picked up Nick's own `a823001` ("Rebuild the jump:
real arc, jump-framing camera, hunters facing the boss") and the artist's
`c3992f7` (Piston Punch card art, no gameplay code).

**Not clean this time.** `hover` 0 flips and `hands` (1-10) 0 fails, both
matching the last baseline. But `play` (80 steps): `hunter-off-marker`
(check 8) FAILED 3 times (steps 34, 35, 71) — the last several runs of
this exact check were all 0 fails, so this is a real regression, not a
flake. `run_tests.gd` still prints `ALL TESTS PASSED` (the bug is a live
placement issue the unit tests don't cover, not a logic error a pure test
would catch).

All three fails share the *exact same* `home` coordinates, and two of the
three (steps 34 and 71) are different hunters reaching foothold 4 by
different climb paths (`foot 7→4` vs `foot 10→4`) — this is deterministic
on foothold 4 itself, not path- or RNG-dependent. The numbers alone
(x missed tolerance by 0.27m) undersell it: the frame shows a hunter
floating in open air against the arena wall, no stone or beast surface
anywhere near its feet — exactly the "floating beside... the body" failure
checklist item 2 exists to catch.

![[frames/playtester/2026-09-23-hunter-off-marker-foothold4-step034.png]]
![[frames/playtester/2026-09-23-hunter-off-marker-foothold4-step034-crop.png]]

My read, unconfirmed: `a823001` changed `_stand_on_model`
(`combat_3d.gd:2751-2764`) to wrap its return in `stone_point(...)`
directly, where before only the *stone's own* visual position got that
treatment and the hunter stood at the raw anchor+clearance point. Check
8's tolerance was never widened for `stone_point`'s extra push, which
likely explains the borderline x-miss — but a hunter hanging with nothing
under it at all suggests `_front_of_beast` (which feeds the z clearance
that then feeds `stone_point`) is returning something much larger than
expected at foothold 4's own rung, pushing the whole point (hunter AND
its stone) well past the model. Diagnosing which of the three functions
is actually wrong is the fixer's job, not mine — filed with both frames
and the exact repro.

One request filed this run: `to: fixer`,
`2026-09-23-0900-playtester-to-fixer-hunter-floats-off-model-at-foothold-4.md`
(priority high — this is a live gameplay regression, not a polish gap).

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | unchanged this run |
| 2 | hunters land on the beast correctly | **regressed** — check 8 (`hunter-off-marker`) now fails 3x in the 80-step play baseline, a real floating-hunter bug at foothold 4, filed to the fixer, not yet fixed |
| 3 | jump animation (squash/arc/landing) | unchanged this run (Nick's own `a823001` reworked the arc/anticipation/landing squash directly — worth a fresh look with frame strips once the foothold-4 fix lands, since that commit touches exactly this item, but didn't check it this run — floating-hunter regression took priority) |
| 4 | camera | unchanged this run (`a823001` also reworked jump-framing; same note as item 3 — worth a fresh look, not done this run) |
| 5 | nothing errors | ok — `ALL TESTS PASSED`, no script errors in any log this run |

## Old: 2026-09-23, damage popup check

Picked up checklist item 1 (card plays read) — still only partially
checkable per this playtester's own brief and last run's checklist
snapshot. The hand-layout half (fan centred, hand/energy match the model,
nothing off-screen or covering End Turn) has been checked since the
baseline request; the half that was still open is "does something on the
beast (damage number, climb, block)" — climbs get the whole hop-watch
apparatus (item 3), but nothing checked that a real hit actually shows a
**damage number**, only that the HUD's hp/boss fields changed.

Added check 10 to `playtest.gd`: `Combat3D._damage_popup` spawns a
`Label3D` child of `_rig` for every point of real damage (`_react`'s
`boss_hit` / `hunter_dmg[i] > 0` — confirmed by reading `react_plan`, the
pure half of `_react`). A naive "screenshot after the step and look for a
label" would miss it almost every time: the popup's own lifetime
(~1.7s: 0.85s rise, then a 0.4s hold and 0.45s fade) is short next to how
long this sandbox's software renderer takes to get through a step's
plain wait (its frames land every ~0.15-0.3s, same cost class this
playtester already hit with the hop check). So instead of screenshotting,
the check **polls `_rig`'s children every frame the step is still
resolving** — folded into the SAME `await` loops `_play()` already runs
(the tail wait, `_drive_timing`'s two loops, `_watch_hop`'s own loop) via
one small helper (`_poll_popup`), so watching for the popup costs nothing
beyond the waiting this bot already does. A flag latches per step
(`_step_saw_popup`, reset before each action) and after the step's
before/after snapshot, a real hp drop (boss OR the active hunter — the
only two fields `_snap` tracks) with the flag still false is
`damage-popup-missing`.

Proved it both directions, not just "ran clean once" (per item 3's own
past mistake of trusting a clean run without checking the failure mode
too):

- **Positive**: full 80-step `mode=play` baseline with the real check —
  0 fails. Five real hp-loss events in that run (steps 34, 50, 65, 71,
  77), every one correctly saw a popup. `hover`/`hands` unaffected (the
  new code only runs inside `_play()`'s own helpers) — re-ran both to
  confirm, 0 fails.
- **Negative**: deliberately broke `_poll_popup` (`if false and child is
  Label3D:`) and re-ran the same 36-step slice — got exactly one
  `damage-popup-missing` FAIL, at the same step the positive run passed
  cleanly (step 34, hp 42→36). Reverted the break before anything else.
  This is the check actually firing, not a check that can only ever pass.

While proving it, I instrumented `_poll_popup` throwaway (not shipped —
reverted before this commit) to print the popup's own
`unproject_position` against the live camera the instant the check saw
it, out of curiosity whether "exists in the tree" also meant "on
screen." It did not: all three hunter-damage popups sampled across one
run projected ABOVE the top of the 720px-tall viewport (screen y from
-99 to -604), `is_position_behind` false for all three (so not a camera
looking the wrong way entirely — a real, if unconfirmed, distinct
finding from item 4's "on screen at all" check 9). Filed to the fixer
with the exact repro and both frames — see the request. This is a real
gap in checklist item 1's own bar ("does something on the beast — a
damage number") that the existence-only check above cannot catch by
design (deliberately scoped to existence, not visibility, the same
reasoning check 9 already used to avoid re-flagging the known camera
gap) — worth a second, visibility-aware check once the fixer knows the
real cause, not before.

![[frames/playtester/2026-09-23-damage-popup-offscreen-step34.png]]
The frame right after a real hunter-damage popup spawned (Goblin
Engineer hp 42→36 this step) — HUD shows the drop, but no number
anywhere on screen. Zoomed on the Goblin, still nothing:
![[frames/playtester/2026-09-23-damage-popup-offscreen-step34-crop.png]]

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | **partially stronger** — hand layout ok (unchanged), climb ok (item 3), and now damage-shows-a-number is checked too (check 10, 0 fails on existence) — but that same work surfaced a real "reads" gap (the number can render off-screen), filed to the fixer, not yet fixed |
| 2 | hunters land on the beast correctly | ok (check 8, `hunter-off-marker`, 0 fails) |
| 3 | jump animation (squash/arc/landing) | ok, unchanged this run |
| 4 | camera | check 9 unchanged this run — still settled-state only, still not visibility-aware (see item 1's new finding above, which is arguably the same underlying gap wearing a different hat) |
| 5 | nothing errors | ok |

One request filed this run: `to: fixer`,
`2026-09-23-0430-playtester-to-fixer-hunter-damage-popup-offscreen.md`
(the off-screen damage number above).

## Old: 2026-09-23, camera check 9

Ran the full baseline first, unmodified `playtest.gd`, against that
day's tip (the artist's `goblin_mech` pass 3, no fixer code changes
since the last baseline): **play** (80 steps) 0 fails, **hover** 0
flips, **hands** (1-10) 0 fails — clean, matching the last recorded
baseline, no regression from the artist's tri-budget trim. `run_tests.gd`:
`ALL TESTS PASSED`.

Picked up checklist item 4 (camera) per last run's `## Next` — still only
"partially checkable" and named directly in this playtester's own brief as
an example gap ("camera keeps the active hunter inside the frame" — not yet
an automatic check, unlike item 2's `hunter-off-marker`). `screenshot.gd`
already had the building block for this (`_report_visibility`'s `VIS`
line: `Camera3D.is_position_behind` + `unproject_position` against a
hunter's `home`), but only for one frozen `state=` shot — never run
continuously across a real fight, which is exactly the gap `playtest.gd`
exists to close (see the file's own header: "screenshot.gd checks one
frozen moment... Nick's bugs live in neither").

Added check 9 to `_check()`: after every step settles (not mid-hop — the
hop's own mid-flight transient is a separate, already-documented gap, see
item 3/4's history below), read the ACTIVE hunter's `home` position and
ask the live camera the same two questions `_report_visibility` asks for
one frame: is it behind the camera at all (`hunter-behind-camera` — would
mean the camera is looking somewhere else entirely, never expected), and
does it project inside the full viewport (`hunter-offscreen` — no HUD-
safe-region trim like `screenshot.gd`'s tighter check, deliberately, so
this doesn't re-flag the already-known "tiny near the edge" framing gap as
a new failure; only genuinely NOT on screen counts).

Smoke-tested first at 15 steps (2 real climbs) before committing to a full
run — 0 fails, so no obvious false-positive problem. Then shook it out
properly: full 80-step **play**, **hover**, and **hands** runs, all clean,
0 fails on every check including the two new ones. The 80-step run alone
crossed five real climbs (foot 0→4, 4→6, 8→10, 12→16, and a boss-hit fall
10→4) plus the sigil approach — every one of those settled states had the
active hunter genuinely on screen once the camera caught up, not just
"passed by luck." That's a real result for item 4, not a null one: the
settled-state framing holds up across a full fight; only the mid-hop
transient (documented below) is the open gap.

Two frames, same check, different framing to make the "on screen" claim
legible rather than take my word for the numbers:

![[frames/playtester/2026-09-23-camera-check-step43-sigil.png]]
Step 43 (after a Leap to foothold 16, near the sigil) — the Frog reads
clearly, comfortably inside frame. This is the check passing on an easy
case.

![[frames/playtester/2026-09-23-camera-check-step1-tiny-known-gap.png]]
Step 1 (right after the very first ground climb) — the Frog is small and
mostly eclipsed by the jackal's own jaw, only its eyes and the top of its
head clearing the hand row. This is the check passing on the HARD case:
the projected point is still technically inside the viewport, so no fail
fires, but a human eye would call this "barely readable," matching what
the last two runs already logged as the known gap ("tiny/off-screen-edge
for most of a climb," "Nick's third-person target still pending"). Worth
being honest that this check's bar (on screen at all) is looser than
"reads clearly" — it catches a camera looking at the wrong thing entirely,
not a merely-small hunter. Filing that gap again here would just be a
third copy of a finding the board already has; not doing that.

No new requests filed — nothing failed, and the framing gap this run's new
check bumps into is the same one already on record (this note's own `##
Next`, and item 4's history), not a new finding.

## Old: 2026-09-22, hop slow-mo + correction

Ran the full baseline first, unmodified `playtest.gd`, against that day's
tip (the artist's arena recolour, the fixer's relic-pool write-up, no
fixer code changes landed since the last baseline): **play** (80 steps,
deterministic seed, boss to 0 HP) came back with **2 failing checks** —
`hop-flat` (step 11) and `hop-no-squash` (step 63) — the first non-clean
baseline this fight had had. Both captures had exactly **2 in-flight
samples**, which passed the existing `covered_from_start` confidence gate
by chance — not nearly enough to trust for finding an apex or a squash
peak, the same sampling-is-too-sparse problem the run before's `## Next`
already named. Correctly did not take either at face value; wrongly
guessed (see the correction below) that sparse sampling was the WHOLE
story for both, and went looking for a way to sample more before filing
anything, per "proof or it did not happen."

Picked up option (a) from that `## Next` list: slow the capture window down
so a 0.34s hop leg gets more than 1-3 real frames on this sandbox's slow
software renderer. `Engine.time_scale` turns out to be exactly the right
knob — Godot 4 Tweens scale their own delta by it unless a tween opts out
with `set_ignore_time_scale` (`_hop`'s climb tweens never do), so dropping
it to 1/6 inside `_watch_hop` makes the SAME renderer, drawing frames at the
SAME real cost, land 6x more of them across one hop — without moving a
single number in `_hop`/`hop_arc` itself.

That first pass at the fix shipped its own false positive, caught the same
way: read the numbers instead of trusting a clean run. `hop-leftover-squash`
fired on step 1 with a suspicious detail — 24 in-flight samples, the same
number as `_watch_hop`'s image-save throttle. The sampling loop had been
capped at that same low number as the PNG throttle, so under 1/6-speed a
long multi-leg climb (this one: ground to foothold 4) got cut off still
mid-air, still squashed, and the code then read that mid-flight moment as
"landed." Fixed by un-syncing the two caps: the numeric sample loop now
runs until the tween itself reports finished (capped generously at 300
iterations as a safety net, never hit in practice), while the PNG
write-out stays throttled to 24 frames so a strip doesn't balloon to
hundreds of images. Added an explicit branch for the safety-net case too:
if the cap ever does fire before the tween finishes, the run says so and
judges nothing, rather than guessing from a partial flight.

**Correction, same run:** the two runs above happened in a private tree
that hadn't pulled `origin/main` since before this run started. Pulling
before writing this up surfaced that the fixer had, concurrently, run the
SAME stock baseline in a separate sandbox, hit the SAME `hop-flat` failure
(their run: steps 1 and 17; mine: step 11 — different step numbers, since
which climb a slow render happens to sample "confidently" varies with
real wall-clock frame timing even on the same deterministic seed, but the
same underlying cause), and traced it to a real bug:
`Combat3D.hop_arc()`'s old apex-height formula
(`lerp(from, to, 0.58).y + hop`) leaves the apex BELOW the landing on any
climb whose own vertical span exceeds the capped `hop` height — a real
"reads as a slide, not a jump," provable with a plain call to `hop_arc()`
and nothing to do with sample count. Fixed properly (apex height =
`maxf(from.y, to.y) + hop`) and pinned with two new pure-function tests in
`run_tests.gd`, commit `25804f3`. **My "it's just 2-sample under-sampling"
guess for `hop-flat` was wrong** — sparse sampling was real and did make
the capture unreliable, but the failure it happened to catch was a
genuine, always-reproducing bug, not a phantom. Re-ran the identical
80-step sequence with BOTH fixes (the fixer's `hop_arc` fix, already on
`origin/main`, plus my own slow-mo capture) after pulling: **all checks
passed**, step 17's climb (the same 8.99→~18.1 span) now peaks at 19.56 —
above both endpoints, matching the fixer's fix exactly — with the richest
capture yet, 72 in-flight samples. `hop-no-squash`, by contrast, never
recurred across any richly-sampled run under either version of `hop_arc`
(pre- or post-fix) — every subsequent capture, including several with
similar geometry, showed a real squash deviation (0.09-0.22) — so that one
genuinely does look like plain under-sampling, unlike its neighbour.

The honest lesson: I had real evidence (2-sample "confident" captures
failing) and a real fix in hand (more samples) that happened to also make
the failures go away, and almost wrote that up as "confirmed: both were
just sparse sampling" without checking whether a real bug could produce
the exact same 2-sample symptom. It could, and did, for one of the two. The
fixer's independent, code-level repro (a plain function call, no
rendering, no sampling at all) is what actually settles a question like
this, not a live run coming back clean. Filed nothing new — this bug was
already fixed and closed on the fixer's side.

Full baseline after both fixes, all three modes: **play** (80 steps) 0
fails, **hover** 0 flips, **hands** (1-10) 0 fails.

Frames: `design/agents/frames/playtester/2026-09-22-hop-strip-v2-step17.png`
(4 frames from the richest capture, 72 in-flight samples, peak y 19.56 —
the Goblin Engineer approaching the sigil from off-screen) and
`2026-09-22-hop-landed-v2-step17.png` (the settled frame right after).

No new requests filed. `ALL TESTS PASSED` throughout.

## Next

Both threads from this run resolved without needing a fresh playtester
request: foothold-4's residual is the fixer's own
`2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`
(watch for it going `done`, then re-run the baseline to confirm check 8
finally goes clean at foothold 4 for BOTH hunters sharing it); `hop-flat`'s
false-fire was my own check's confidence gate, fixed and verified in
`playtest.gd` this run (`MIN_HOP_SAMPLES`).

Once foothold-4 is fully closed, worth a fresh pass on items 3 and 4
overall: `a823001` (Nick's own jump/camera rebuild, now two runs back)
still hasn't had a frame-strip look at anything OTHER than the two bugs it
turned up — the numeric checks passing everywhere else in this run doesn't
mean the squash/arc/camera framing actually reads well at typical (non-
sigil, non-foothold-4) climbs, just that nothing failed. The off-screen
damage-number finding from two runs ago is also still open, still waiting
on the fixer: once they know the real cause (my guess — an in-flight camera
transition, unconfirmed — is in the request), decide whether it deserves
its own automatic check (a visibility-aware version of check 10) or folds
into whatever item 4 eventually becomes once the third-person camera
lands. Item 4 itself is otherwise unchanged: check 9 can tell "on screen"
from "not," not "small" from "clearly framed." Also still open: a way to
catch a squash-arc or framing failure the numeric checks would miss but a
human eye would catch — the frame strips remain the backstop for that;
keep saving them.

## Old-Next: superseded by the two-item list above

The live thread is the foothold-4 float: once the fixer knows which of
`_front_of_beast` / `_stand_on_model` / `stone_point` is actually wrong,
decide whether check 8's tolerance needs widening for `stone_point`'s own
push (a calibration fix) on top of whatever position fix lands (a real
bug fix) — those are two separate things and both may be needed. Also
worth a fresh pass on items 3 and 4 once that lands: `a823001` rewrote
the hop arc/anticipation/landing squash AND the jump-framing camera in
the same commit that introduced this regression, and neither got a
frame-strip look this run — the numeric checks (hop-flat/hop-no-squash,
camera check 9) came back clean, but item 3's own history shows a clean
numeric pass has missed a real bug before (the pre-fix `hop_arc` case);
worth watching, not assuming fine. The off-screen damage-number finding
from last run is still open too, still waiting on the fixer: once they
know the real cause (my guess — an in-flight camera transition, unconfirmed
— is in the request), decide whether it deserves its own automatic check
(a visibility-aware version of check 10) or folds into whatever item 4
eventually becomes once the third-person camera lands. Item 4 itself is
otherwise unchanged: check 9 can tell "on screen" from "not," not "small"
from "clearly framed," and that same blind spot is arguably why this run's
new finding wasn't caught by check 9 in the first place (a Label3D isn't a
hunter, so check 9 never looked at it) — worth remembering these are
two symptoms of one still-open camera gap, not two unrelated bugs. Item 3
is unchanged this run — its own remaining gap (very short single-leg hops
finishing before `_watch_hop` starts slowing things down) still stands.
Also still open: a way to catch a squash-arc or framing failure the
numeric checks would miss but a human eye would catch — the frame strips
remain the backstop for that; keep saving them.

## Log

- 2026-09-24 17:20 EDT — new check `camera-not-over-shoulder`, proves the
  resting shot is genuinely over-the-shoulder. 0 fires on real code, 16/16
  when broken on purpose. Baseline unchanged, no regression.
- 2026-09-24 13:11 EDT — Nick's answer on the sigil-cheek request had
  already been relayed to the fixer (commit `1a237dc`, ahead of this run);
  closed the bookkeeping gap on my own note (`## Filed on`, points at the
  fixer's build request, left `status: open` — the route change hasn't
  landed). Full three-mode baseline clean, exact same two known open
  issues as every prior run (`hop-distance-band`, `intent-tag-vs-hunter`).
  Tried a live check for "hunter has real space off the skin" using
  `_front_of_beast`'s hull and ruled it out with real numbers — the hull
  returns wildly wrong values off an exact climb anchor (down to -12m),
  the same disconnected-geometry failure `stand_z_for`'s own comment
  already documents. Reverted before shipping; `playtest.gd` unchanged.
- 2026-09-24 05:14 EDT — no open requests addressed to `playtester`;
  Nick has not yet answered the sigil-cheek request. Full three-mode
  baseline clean (same two known, open, already-filed issues —
  `hop-distance-band`, `intent-hidden` — no regressions). Added
  `party-roster-incomplete` to `playtest.gd` (check 7b): closes
  JACKAL-BAR's "both hunters are always findable, including mid-climb" —
  the 3D camera only ever frames the active hunter by design, so the
  party panel (one row per hunter, rebuilt every refresh) is what
  actually keeps the other one findable, and nothing had checked that
  rebuild stays in sync with the model. Proved both directions
  (`mode=hands`: 0 false fires; a temporary `+1` injection fired 11/11,
  reverted clean). Fresh human-eyes look at a couple of card-play frames
  found nothing new. Pushed before writing this note, per COMMON.md 4b.
- 2026-09-24 01:13 EDT — no open requests addressed to `playtester`. Full
  three-mode baseline (clean, matches last run: `intent-hidden` ×12, already
  filed/open, not a regression; 0 `route-reversal`, 0 `hunter-off-marker`, 0
  script-error — the fixer's item-1/item-3 stone-route work still holds).
  Added `hop-distance-band` to `playtest.gd` (check 8c: an ordinary
  hold-to-hold hop must sit inside `hop_arc()`'s 2.4-9.2 world-unit band,
  the runtime half of the fixer's still-open stone-route item 2) — fired
  live on exactly the two hops (Height 3→4, 4→5) the fixer's own last run
  named as still short, matching their numbers to two decimals, while the
  three in-band hops stayed silent in the same run. Commit `8c3813a`,
  pushed.
- 2026-09-23 23:12 EDT — no open requests addressed to `playtester`. Full
  three-mode baseline (clean, matches last run's own results exactly:
  `intent-hidden` ×26 and `damage-popup-offscreen` ×1, both already filed
  and open, not regressions — and confirms the fixer's route.py stone-route
  fix landing this evening broke nothing). Added `route-reversal` to
  `playtest.gd` (check 8b: a beast's climb rungs must never net backward
  along the established sweep, same rule the fixer just enforced at build
  time, now also checked against the live loaded beast) — clean on
  `mode=hands` (all 10 sizes) and a full `mode=play` baseline, before
  trusting it. No new bug found; closes a coverage gap for the next
  regression. Pushed before the `mode=play` verification finished (COMMON.md
  4b).
- 2026-09-23 21:41 EDT — full three-mode baseline (clean, matches last
  run's own results exactly: `damage-popup-offscreen` still the one open
  bug, `1735`, not a regression). Fresh human-eye pass on item 1 (overdue
  two runs) found nothing new. Added `intent-hidden` to `playtest.gd`
  (check 5c: `_intent_tag` must never overlap `_hp_bar`/`_party`) — clean
  on `mode=hands` (all 10 sizes), then fired for real twice on `mode=play`,
  a genuine bug: the intent tag renders partially behind the party panel
  at fight-start and again mid-fight. Filed
  `2026-09-23-2141-playtester-to-fixer-intent-tag-hides-behind-party-panel.md`
  with the root cause (`_position_intent_tag` clamps Y away from the HP
  bar/hand, never X away from the party panel) and both frames. `ALL TESTS
  PASSED` throughout; commit pushed before the verification runs finished
  per COMMON.md 4b.
- 2026-09-23 18:46 EDT — Nick approved the stone-route proposal
  (`1434`, "Approved, as written. Build it."). Read it alongside the
  fixer's numbers note (`1736`) and filed the two build requests it
  promised: `to: fixer` (one-directional route fix in `ai_beast.py`/
  `beast.py mark()`, 2.4-9.2 unit hop-spacing band, next-hold ring) and
  `to: artist` (ledges read as shelves, not floating markers, from the
  wide shot). Closed `1434` and `1736` as `done`. No game code touched
  this run — pure board bookkeeping.
- 2026-09-23 17:35 EDT — found the Cinder Jackal's HP had never moved in
  any playtest run: every timed card was fumbling because the bot's aim
  window (40ms) was narrower than this sandbox's frame gap. Fixed with
  the same `Engine.time_scale` slow-down as the jump-sampling fix
  (`_drive_timing`, commit `535ced7`). That let hits land for the first
  time, which surfaced a script-error crash once a fight could actually
  reach a win (freed-view-mid-await, fixed in two passes, commits
  `94e3ca4` and `ed9380f` — the first pass guarded inside the wrong
  function, the second guarded the actual call sites) and one real game
  bug: a boss-damage popup renders off-screen at the sigil, 3/3 runs,
  filed `to: fixer`
  (`2026-09-23-1735-playtester-to-fixer-boss-damage-popup-offscreen-at-sigil.md`).
  Full three-mode baseline clean after every commit, `ALL TESTS PASSED`
  throughout, one run reached a real win (fight-over via boss death) for
  the first time ever.
- 2026-09-23 — added `hop-position-pop` to `playtest.gd` (JACKAL-BAR
  Motion's "no pops... mid-jump" half) — took 3 iterations: a whole-hop-
  median v1 false-fired live on the genuinely fast start of `_hop`'s own
  EASE_OUT rise tween (step 17, verified by dumping the actual y-samples —
  smooth and monotonic, not a jump, plus a frame strip); an immediate-
  neighbour v2 passed that real case but missed a synthetic one-frame
  stomp-and-revert injection (two big, mutually-validating deltas); shipped
  a two-sided local-window-median v3 (`POP_WINDOW=8`, excludes samples
  without real neighbours on both sides after a second live false-fire at
  a flight's very first sample) that passed all 4 real climbs across the
  final baseline (0 fails) AND correctly caught the synthetic spike both
  times it was tested against v3. No real pop found in the wild; nothing
  filed — the shipped value is the new, honestly-proven coverage itself.
  My own `play`-mode baseline (3 `hunter-off-marker` fails at foothold 4)
  was run against a tip that predated the fixer's shared-foothold-4 fix —
  see the next entry below, from a concurrent playtester run, for the live
  verification that it's since closed. `run_tests.gd`: `ALL TESTS PASSED`
  throughout.
- 2026-09-23 17:08 UTC — full three-mode baseline came back completely
  clean for the first time in many runs: `play` (80 steps) 0 fails, `hover`
  0 flips, `hands` (1-10) 0 fails. The shared-foothold-4 residual
  (`hunter-off-marker`, the loudest recurring finding across at least five
  prior baselines) is gone — the fixer's own self-filed
  `2026-09-23-0715-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.md`
  (root cause: `stone_point()` pushing radially instead of forward, adding
  its own x-drift on top of `stand_offset_x`'s spacing) closed since my last
  run; verified live at both repeat instances this run's seed produces
  (steps 34 and 71, both hunters sharing foothold 4), by the check (0 fails)
  and by eye (both frames show both hunters grounded on the jackal's ear,
  not floating). Checklist item 2 is now fully closed. `ALL TESTS PASSED`,
  0 `script-error`. No new bugs found; nothing filed this run. Local `main`
  arrived stale (no merge-base with `origin/main`) — tagged the old tip
  before resetting so nothing was lost, per COMMON.md 0.
- 2026-09-23 — full three-mode baseline (run twice, before/after today's
  edit): `hover`/`hands` clean both times, `play` (80 steps) 3 fails both
  times, all `hunter-off-marker` at foothold 4, exact same coordinates as
  every recent run — still the fixer's own open, untaken
  shared-foothold-spacing request, unchanged. Confirmed the fixer's End Turn
  crash fix (`_focus_camera`'s new `is_inside_tree()` guard) is holding: 0
  `script-error` across both 80-step baselines despite heavy End Turn use
  (11-15 per run, one dropping boss hp 42→6) — corroborating, not
  replacing, their own unit-test proof. Added a new check to `playtest.gd`,
  `hand-over-hud` (JACKAL-BAR: "nothing important is behind the hand... at
  any hand size") — the resting hand must never cover the intent tag, hp
  bar, party panel or climb rail (`_gauge`), checked at every hand size via
  the existing `mode=hands` 1-10 sweep, no new plumbing needed. Proved it
  both directions: 0 fails for real (including the full 80-step play
  baseline, which passes through every hand size the deck produces), and 43
  FAILs across all four watched elements when the check's own intersection
  tolerance was deliberately loosened (`grow(-6)` → `grow(500)`), reverted
  clean, re-verified with `run_tests.gd` and a fresh baseline. No bug found
  in the wild (the existing margins hold at every hand size); nothing filed.
- 2026-09-23 — full three-mode baseline: `hover`/`hands` clean, `play`
  (80 steps) 3 fails, all `hunter-off-marker` at foothold 4 matching the
  fixer's own still-open, untaken shared-foothold-spacing request exactly —
  unchanged, no regression. No `script-error` (the intermittent End Turn
  crash, also still open and untaken, did not reproduce this run either —
  not treated as proof it's gone). Picked up checklist item 1's remaining
  gap flagged in my own last two runs' `## Next`: the fixer took and fixed
  `hunter-damage-popup-offscreen` (`9653ecc`, `Combat3D.popup_move_reach`)
  since my last run — verified it live in this run's clean baseline (0
  fails across 5 real hp-loss events), then added the visibility-aware
  follow-up check itself, `damage-popup-offscreen` in `playtest.gd`: every
  live popup's on-screen projection is now checked every frame across its
  whole life (not just at spawn, since the real bug was a popup that
  started ON screen and rose OFF it). Proved both directions — clean on the
  real fix, and exactly 3 FAILs (matching the fixer's own before-fix
  numbers) when I temporarily reverted their fix in `combat_3d.gd` to
  reproduce the old bug, confirmed by eye against the frame, then cleanly
  reverted the break before re-running `run_tests.gd` and a final clean
  80-step baseline. No new bugs found; nothing new filed this run.
- 2026-09-23 — first full three-mode baseline clean (0 fails/flips
  everywhere). Extended `playtest.gd`'s `_watch_hop` with a mid-hop
  camera-visibility check (`hunter-lost-mid-hop`, checklist item 4's
  "including mid-jump" half, which the existing settled-state check
  explicitly skips) — proved it both directions (0% off across all sampled
  hops in three separate runs; a deliberate break correctly produced a
  100%-off FAIL, reverted). A follow-up baseline run with the finished check
  surfaced a real, if intermittent, engine crash unrelated to my own
  change: `_apply_orbit` (combat_3d.gd:2208) calls `_cam.look_at` after
  `_cam` is no longer in the tree, during `_end_turn` →
  `_apply_solo_turn_flip` → `_focus_camera`, killing the whole game view
  (one crash in three otherwise-identical 80-step runs — a timing/race
  signature). Filed `to: fixer`, priority high,
  `2026-09-23-1000-playtester-to-fixer-end-turn-crash-at-sigil-solo-flip.md`,
  with the stack trace and the frame right before it. Also did the
  human-eye frame-strip look on items 3/4 flagged as overdue for several
  runs: a typical non-sigil ground climb (step 0) shows real motion/arc by
  eye, no new bug; re-confirmed (not re-filed) the already-known "tiny near
  the sigil" camera gap by eye against the new check's own clean verdict.
  `run_tests.gd`: `ALL TESTS PASSED` throughout.
- 2026-09-23 — verified the fixer's `c8e965b` (`stand_z_for`) against a
  fresh full three-mode baseline: `hover`/`hands` clean, `play` (80 steps)
  2 failing checks. `hunter-off-marker` at foothold 4 is a real, large
  improvement over the pre-fix baseline (open-air float, `home.z` 10.25 →
  7.03, right next to the anchor) but still fails 4x on a smaller residual
  x-miss (1.43 vs 1.06 tolerance). Had a follow-up drafted when a mid-run
  `git fetch` turned up the fixer's own `4c15649`, closing the original
  request and self-filing the exact same residual with a deeper diagnosis
  (two hunters sharing foothold 4, `stand_offset_x`'s spacing too wide for
  the jackal's narrow ear) — deleted my draft, nothing to add. Also found a
  NEW `hop-flat` failure, 2x near the sigil (steps 49/50), both captures
  reporting a peak sitting exactly at the start height despite passing the
  confidence gate; the same `git fetch` showed the fixer independently hit
  the same shape at a THIRD set of steps in their own run and called it a
  likely sampling flake — different failing steps every run is the
  signature of a sampling gap, not a reproducible geometry bug, so chased
  it myself instead of filing it. Found the real hole: `covered_from_start`'s
  `total_dist < 0.05` bypass doesn't verify temporal coverage, so a
  near-zero-distance climb (footholds compressing near the sigil) can pass
  the gate on as few as 4-5 real samples. Fixed in `playtest.gd`
  (`MIN_HOP_SAMPLES := 10`, AND'd into the existing gate — strictly
  conservative, can only reduce false fails, never mask a real one).
  Verified against this run's own report.md (real climbs: 25-120 samples;
  degenerate ones: 4-6 — clean separation) AND with a fresh `steps=51`
  re-run: `hop-flat`/`hop-no-squash` gone, only `hunter-off-marker: 2`
  left, and the well-sampled real climbs (120, 26 samples) still get
  judged normally. `run_tests.gd`: `ALL TESTS PASSED`. Local `main` branch
  in this sandbox shares no merge-base with `origin/main` (a stale ref
  from container init, predating some history rewrite on the remote) —
  worked from `origin/main` directly rather than force-resetting the
  branch ref without asking; pushing straight to `origin/main` from a
  detached HEAD.
- 2026-09-23 — full three-mode baseline against today's tip (now including
  Nick's own `a823001` jump/camera rebuild): `hover` and `hands` clean, but
  `play` (80 steps) regressed — `hunter-off-marker` (check 8) failed 3x
  (steps 34, 35, 71), all three at foothold 4 with identical `home`
  coordinates across two different hunters reaching it by different climb
  paths (deterministic, not a flake). The frame shows a hunter floating in
  open air off the jackal's body entirely, no stone or surface under it —
  the exact "floating beside the body" failure checklist item 2 exists to
  catch, not just a tolerance miss. Traced (unconfirmed) to `a823001`
  changing `_stand_on_model` to wrap its point in `stone_point(...)`
  directly, which check 8's own x-tolerance was never widened for, plus a
  suspicion `_front_of_beast`'s clearance is oversized at foothold 4's
  rung specifically. Did not touch any of the three functions — filed
  `to: fixer`, priority high,
  `2026-09-23-0900-playtester-to-fixer-hunter-floats-off-model-at-foothold-4.md`,
  with both frames and the exact repro. `run_tests.gd`: `ALL TESTS
  PASSED` (a live-placement bug, not one a pure unit test would catch).
- 2026-09-23 — checklist item 1: added check 10 to `playtest.gd`
  (`damage-popup-missing`) — real damage (boss hp down or the active
  hunter's hp down) must show a `Combat3D._damage_popup` `Label3D` under
  `_rig` that same step, polled every frame the step is still resolving
  (folded into `_play()`'s existing wait loops, so it costs nothing
  extra) rather than screenshotted once, since the popup's own ~1.7s
  lifetime is too short to trust a single frozen shot on this sandbox's
  slow renderer. Proved both ways: 0 fails across a full 80-step run (5
  real hp-loss events, all correctly seen) AND a deliberate break
  (`if false and child is Label3D`) correctly produced exactly one
  `damage-popup-missing` FAIL before being reverted. Full three-mode
  baseline (play/hover/hands) clean before and after, `ALL TESTS PASSED`
  throughout. Along the way, found and filed a real bug: every sampled
  hunter-damage popup this run rendered above the top of the viewport
  (screen y -99 to -604), confirmed with `unproject_position` against
  the live camera and two frames — `to: fixer`,
  `2026-09-23-0430-playtester-to-fixer-hunter-damage-popup-offscreen.md`.
  Not fixed (not my job); the shipped check itself checks existence only,
  by design, so this finding does not make it flaky.
- 2026-09-23 — checklist item 4: added check 9 to `playtest.gd`
  (`hunter-behind-camera` / `hunter-offscreen`) — the active hunter must be
  on screen once a step has settled, using the same `Camera3D` API
  `screenshot.gd`'s `_report_visibility` already used for one frozen frame,
  now run continuously across a real fight. Full three-mode baseline run
  twice (before and after, unmodified vs. with the new check): both clean,
  0 fails, no regressions from the artist's `goblin_mech` pass 3. The new
  check itself found no bug — confirms settled-state framing holds across
  five real climbs and the sigil approach in one 80-step run — but stayed
  deliberately loose (on-screen-at-all, not "reads clearly") so it doesn't
  re-flag the already-known near-edge/tiny framing gap, shown honestly in
  the step-1 frame rather than hidden. No new requests filed.
- 2026-09-22 — checklist item 3: `_watch_hop` now runs the hop capture
  window at 1/6 `Engine.time_scale`, turning 0-12 real in-flight samples per
  climb into 12-75. The pre-existing baseline's `hop-flat` turned out to be
  a real bug in `Combat3D.hop_arc()` (apex landing below a tall climb's own
  endpoints) — found and fixed independently by the fixer (commit
  `25804f3`) with a pure-function repro while I was still (wrongly)
  chasing it as a sampling artifact; `hop-no-squash` from the same baseline
  WAS plain under-sampling, confirmed gone once fully sampled. My own first
  draft of the slow-mo fix shipped its own false positive
  (`hop-leftover-squash`, a sample cap that silently truncated a long
  multi-leg climb mid-flight and read it as landed) — caught and fixed by
  uncoupling the numeric sample cap from the PNG-save throttle and
  refusing to judge a hop the loop didn't actually see finish. Full
  three-mode baseline clean with both fixes merged. No new bugs to file —
  see `## Old` above for the full trail, correction included.
- 2026-09-22 — checklist item 3: added `_watch_hop`/`_check_hop` to
  `playtest.gd` (hop-flat / hop-no-squash / hop-leftover-squash), gated on
  a `covered_from_start` confidence check after an early version false-
  failed on this sandbox's slow rendering; re-ran full baseline first (no
  regressions from today's three fixer fixes), then a 20/40/80-step run to
  shake the new checks out. 0 fails, one confidently-sampled climb proved
  real arc + real squash by the numbers. No new requests filed.
- 2026-09-22 — first baseline run: all three playtest modes clean (0
  fails), added the `hunter-off-marker` check (playtest.gd check 8), no
  bugs found so no new requests filed. See the baseline request's
  `## Result` for full detail.
- 2026-09-22 — note created by the session.
</content>
