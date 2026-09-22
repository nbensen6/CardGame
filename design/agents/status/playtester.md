---
tags:
  - agent-status
agent: playtester
updated: 2026-09-22
working_on: jump-animation checks added (checklist item 3) — no bugs found this run
---

# playtester

## Now

Re-ran the full baseline first (all three modes, unmodified `playtest.gd`,
against today's three fixer fixes) to check for regressions: **play** (80
steps, boss to 0 HP), **hover** (0 flips), **hands** (sizes 1-10) — all
**0 failing checks**, same as the first baseline. Not a regression, and
nothing new to file.

Then picked up my own `## Next` from last run: checklist item 3 (the jump
animation) was "not yet checkable" because `playtest.gd` only grabbed one
settled frame per step, after every hop had already finished. Extended
`_play()` to detect a real climb (a foothold change on the acting hunter —
the same "was != foot" rule `Combat3D.hunter_move_kind` uses) and, when one
happens, watch the hunter's own animated `Node3D` (`_hunters[i].node` /
`.body`, not the bookkeeping `home` dict — that gets written to the
*destination* the instant the climb is decided, before the tween even
starts, so it would never catch a hunter failing to actually arrive)
every real frame while its climb `Tween` is running: saves each sampled
frame (`hop_STEP_NN.png`) and checks the shape of the hop once it lands.

Three new checks (`_check_hop`): **hop-flat** (the hop's peak height never
rose above a straight line between its endpoints — a slide wearing a jump's
clothes), **hop-no-squash** (the body's scale never left `Vector3.ONE` —
no anticipation/impact squash), **hop-leftover-squash** (landed still
squashed — a pop at the end, checked against the *settled* state after the
tween conclusively stops running, so no race). All three ran clean on
every climb any of today's runs could sample.

Getting there took one real false positive, caught by re-running and
reading the numbers, not assumed away: an early cut at "no pop at the
*start*" (first sample already closer to the destination than to where the
hop began) fired once — turned out to be this bot's own sampling starting
late, not the game. This software renderer is slow enough (~0.1-0.3s/real
frame) relative to one hop leg (0.34s) that the first frame this bot can
catch sometimes already lands past the apex. Dropped the start-pop check
entirely, and gated hop-flat/hop-no-squash on a `covered_from_start` check
(first sample within 40% of the hop's own distance from where it started)
so a late, partial capture is logged and skipped rather than judged — confirmed
by re-running: two more late/partial captures later in the run (a 3-sample
descending hop that would have false-failed hop-flat under the old logic)
now correctly log "partial capture, arc/squash not judged" instead of
failing. One multi-leg climb (step 17, a Height-5 sigil climb, 12 samples)
had a full, confident capture: peak y 18.13 clearing both endpoints
(8.99 → 18.09) and a 0.201 scale deviation — a real arc and a real squash,
by the numbers, not just by eye. Frame strip: both hunters visibly climb
across the 12 tiles, smoothly, no snap.

Checklist snapshot:

| # | item | state |
|---|---|---|
| 1 | card plays read | ok |
| 2 | hunters land on the beast correctly | ok (check 8, `hunter-off-marker`, 0 fails) |
| 3 | jump animation (squash/arc/landing) | **partially checkable now** — 3 new automatic checks (`hop-flat`/`hop-no-squash`/`hop-leftover-squash`), 0 fails on every climb any run could confidently sample this run; still can't judge every climb — a fast single-leg hop on this sandbox's slow renderer is sometimes too quick to catch mid-flight (logged as "partial capture", never silently skipped) |
| 4 | camera | partially checkable, ok so far; over-the-shoulder target still pending (Nick's, not a bug) |
| 5 | nothing errors | ok |

Frames: `design/agents/frames/playtester/2026-09-22-hop-strip-goblin-step17.png`
(the 12-tile strip, the Goblin Engineer climbing the jackal's flank toward
the sigil) and `2026-09-22-hop-landed-step17.png` (the settled frame right
after) — read at 1:1, nothing flagged.

No new requests filed this run — nothing broke, and the one false positive
never left this machine (caught and fixed before it was reported as a bug).

## Next

Checklist item 3 is now "partially checkable," not "ok" — the honest gap
is that a fast single-leg hop is often too quick for this sandbox's
software renderer to sample mid-flight (0-3 partial samples, correctly not
judged rather than false-failed). Two ways to close it, either worth
trying next: (a) a way to slow down or single-step the engine's `Tween`
processing during just the capture window, if Godot exposes one, so even a
0.34s hop yields enough real frames to judge on THIS hardware; or (b) stop
gating on real frame timing and instead read `Tween`/`hop_arc`'s own
progress analytically (the tween's easing curves are known, `hop_arc` is
already pure and tested) rather than sampling the live node at all. Also
still open: checklist item 4 (camera) once the fixer/artist have more to
show there, and finding a way to catch a squash-arc failure the numeric
checks would miss but a human eye would catch (the frame strips are the
backstop for that — keep saving them).

## Log

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
