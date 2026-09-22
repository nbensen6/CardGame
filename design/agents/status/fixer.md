---
tags:
  - agent-status
agent: fixer
updated: 2026-09-22
working_on: in progress -- running the play/hover/hands playtest baseline, hunting a fixable bug in-scope
---

# fixer

## Now (mid-run)

No open `to: fixer` request this run (fresh sandbox). Followed my own prior
run's "Next" note and widened the "states around the fight" look to the
campfire/shop/event screens (`location_3d.gd`) that hadn't had one yet:
rendered `state=3dcampfire`, `state=3dshop`, `state=3devent` (desktop and a
forced-mobile/phone-aspect shot) — all read clean, no overlap, no clipped
buttons, no missing glyphs.

While probing `state=3dwon` (drives a full run through all four Titans) to
exercise the reward screen further, found a real bug, but it lives in
`Run`/`location_3d.gd` reward/relic code shared by every fight, not in the
Cinder Jackal's own arena/cards — outside this rotation's scope per the
board's "Work outside the Cinder Jackal fight unless a request asks you to".
Filed rather than fixed:
`requests/2026-09-22-2245-fixer-to-nick-boss-relic-pool-runs-dry-at-half-the-titans.md`
— with exactly 4 `tier: "boss"` relics for a 4-Titan ladder, and BOTH
hunters drawing independently from that same shared pool each boss kill,
2-player co-op exhausts it after just the 2nd Titan: the 3rd and 4th
Titans' reward screens show zero relic choices, "Lock In Reward" stays
permanently disabled, and the header prompt still says "Tap a relic to
select" with nothing to tap. Reproduced with
`state=3dwon beast=cinder_jackal` — the driver script itself got stuck
spinning 400 iterations at the empty 3rd-Titan reward, never reaching WON
(`RUN ended in phase 5`, i.e. still REWARD). Frame:
`design/agents/frames/fixer/2026-09-22-boss-reward-relic-pool-exhausted.png`.
Flagged both the possible content gap (pool sized for solo, not 2p co-op —
Nick's call) and the definite bug regardless (the prompt text has no
"nothing left, Skip" case).

Lost some time to my own harness mistake: backgrounded a playtest render
with a bare shell `&` instead of the Bash tool's `run_in_background`, which
got reaped when the tool call returned, then retried without noticing and
ended up with three overlapping `playtest.gd` processes fighting over the
same 4 cores and the same output directory. Killed all of them and started
one clean `mode=play beast=cinder_jackal steps=80` run
(`out=/tmp/pt_play_clean`) properly backgrounded; it's still in flight as
this note is being written mid-run so the untracked request/frame files
don't sit uncommitted. Picking back up once it reports: if it's clean,
`mode=hover`/`mode=hands`, then a fresh read of `combat_3d.gd`/
`card_view.gd`/`core/combat.gd` for an in-scope fix (order-of-work item 3),
or backlog #86 duty (item 4) if that neighbourhood really is exhausted.

## Next (placeholder until this run's real fix lands)

Finish the play/hover/hands baseline, fix whatever it turns up (or the next
thing found reading the jackal-fight files), prove it, and overwrite this
note with the real result before the run ends.

## Now (superseded below by the prior run's entry, kept for history)

No open `to: fixer` request this run (fresh sandbox). Ran all three
`playtest.gd` modes (play/hover/hands) fresh against the current tip —
all came back `0 failing check(s)`. Followed up on my own previous run's
"Next" note first: probed every other glyph the HUD, log toggle, deck view
and switch button use (☠ • ⇥ ▶ ▸ ▾ ◀ →) with the same throwaway
`ThemeDB.fallback_font` render technique that caught the "⚔" bug last time —
all render fine, so that bug class is now confirmed isolated to the one
codepoint already fixed. No new finding there.

Read through `hit_circle.gd`, `card_view.gd`'s timing minigame, and the
`ally_grip`/`sac_ally_grip`/`pull_ally`/`grip_per_rhythm` card-effect
plumbing in `core/combat.gd` (the Frog/Goblin's own cards) end to end —
this whole neighbourhood already carries extensive "backlog #86 duty 2"
comments from earlier rounds fixing exactly the raw-vs-clamped and
self-echo bug classes I was looking for; found nothing new to fix there
this run.

Found and fixed something outside that neighbourhood instead, while
looking at the states around the fight rather than just the fight itself:
the reward screen straight after felling the Cinder Jackal had its
"Tap a card to select" prompt line unreadable — physically painted over by
the reward row's own cards (added to the tree after it, so they draw on
top wherever they overlap) and fighting the felled beast's 3D corpse for
contrast on top of that. Filed it to myself
(`requests/2026-09-22-2200-fixer-to-fixer-reward-prompt-hidden.md`) and
fixed it: wrapped the prompt `Label` in a `PanelContainer` (same
`StyleBoxFlat` look every combat HUD text panel already uses — this one
was the one label in the whole Hud tree that never got it) and moved its
band up clear of the row's real top edge, found empirically from a
pixel-column scan of the rendered PNG rather than trusting the .tscn's
nominal offsets (the cost-orb's intentional overhang past the card's own
border isn't visible from the layout numbers alone). Also gated the new
panel's visibility on the prompt text being non-empty, so the three other
screens that reuse this Hud and clear the prompt (`_render_event`,
`_render_over`, `_clear_ui`) don't regress into showing a floating empty
bar — checked `state=3devent` and `state=3dwon` directly to confirm.
`ALL TESTS PASSED` (a scene-layout + visibility fix, proven with rendered
frames rather than a new pure-function test, same as the artist's
ear-glare fix). Before/after at `state=3dreward beast=cinder_jackal`:
"The Fro...ks... Tap a card to ...ct" (fragmented, cut by the cards) →
"The Frog picks:   Tap a card to select" (clean)
(`design/agents/frames/fixer/2026-09-22-reward-prompt-hidden-*.png`, crops
included).

## Next

Pick up the next open `to: fixer` request, or hunt a bug per the fixer
brief. The glyph-missing bug class and the sigil raw-vs-clamped bug class
both look exhausted for now in the files fixer.md names — next time,
worth widening the "look at the states around the fight, not just the
fight" approach that found the reward-prompt bug: the campfire/shop/sharpen
screens (also `location_3d.gd`) haven't had the same close look yet.

## Log

- 2026-09-22 — fixed the reward screen's prompt line ("Tap a card to
  select") being painted over by the reward row's own cards and fighting
  the felled beast's 3D corpse for contrast — wrapped it in a
  `PanelContainer` (the same backdrop pattern every combat HUD label
  already uses) and moved its band clear of the row, gated on non-empty
  text so other screens don't gain a stray empty bar; before/after frames.
  Self-filed and self-fixed — see the request's `## Result`.
- 2026-09-22 — fixed the attack icon ("⚔") rendering as a bare "×" on the
  boss's intent telegraph and the party card's incoming-damage readout —
  U+2694 CROSSED SWORDS has no glyph in this build's font-fallback chain.
  Replaced it with a new `Combat3D.ATTACK_GLYPH` constant (†), probe-verified
  to render; four unit tests (three updated, one new); before/after frames.
  Self-filed and self-fixed — see the request's `## Result`.
- 2026-09-22 — fixed the climb rail's gauge drawing one hunter's dot on top
  of the other's at the sigil (raw-foothold vs clamped-foothold comparison
  in the dot-offset logic, same bug class as the two fixes below but in a
  spot neither one touched); one new pure function
  (`Combat3D.gauge_dot_dx`), four new unit tests, before/after frames. Self-
  filed and self-fixed — see the request's `## Result`.
- 2026-09-22 — fixed the party panel showing a raw foothold past the sigil
  ("↑16 / 5"); clamped the numerator in `party_card_stats()`, one new unit
  test, before/after frames. See the request's `## Result`.
- 2026-09-22 — fixed hunters overlapping at the sigil (raw-foothold vs
  clamped-foothold comparison in `hunter_side_offset`); two new unit tests,
  a new playtest check, before/after frames. See the request's `## Result`.
- 2026-09-22 — note created by the session.
