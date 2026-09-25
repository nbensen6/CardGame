---
tags:
  - agent-status
agent: director
updated: 2026-09-24T21:58
working_on: Relayed Nick's Dev/Player camera switch to the fixer; chasing #14, which has not moved since 20:08.
---

# director

## This run — 2026-09-24 21:58 EDT

- **Did:** looked at all three shots again; the stones have bulk now, nothing else you asked for has moved.
- **Worked?** Partly: the stones are solid but read as clay pots, and the hunters are still specks at the paws.
- **Next:** your camera-switch ask is with the fixer; #14 (gap, then stones) is claimed and being worked now.
- **Need from you:** one word on the re-cut jackal (keep or revert); nothing else.

## Now

**What a player sees, before I read anyone's note.** Resting shot: a tall
black dog with orange panels, whole, on a dark disc under a purple sky; two
green specks at its paws; two pale **pots** floating at its right flank.
Sigil close-up: mostly empty cave wall, the beast a black lump under the
cards, "Attack 7" hanging in air — unchanged. Grip shot: the Frog mid-leap
onto a pale pot with a lid, "3" landing; jackal's head off the top; Goblin
behind the party panel (`VIS FAIL hunter1`, accepted by design).

![[frames/director/2026-09-24-2154-director-resting-shot.png]]
![[frames/director/2026-09-24-2154-director-grip.png]]

**Against the drawing**, same table as last run:

| his drawing | the frame now | verdict |
|---|---|---|
| whole beast, upper-middle | whole beast, head to foot | yes |
| cool sky, dark ground, pale stones | yes | yes |
| hunters far back, wide gap | still between the paws, ~15-20px | **no — #14, no movement** |
| stones a diagonal staircase up the front | two pots at the flank | **no — #14** |
| stones are chunky irregular rocks | a sphere with a lid | **half — #16 gave mass, shape wrong** |
| side-on / three-quarter | straight on | no — after #14 |
| beast black | black | settled (#17) |

![[frames/director/2026-09-24-2154-director-stone-vs-reference.png]]

**Did the fight get better for Nick, or did three scores go up?** Two
scores went up and one thing got visibly better. Better: #16 — the stones
have mass, which is a real step toward the drawing even though the shape
overshot into "pot". Scores: the artist cut the jackal to 2,639 tris (a
budget line, invisible at play size — its before/after is judged at half
scale, not 1:1) and the playtester added a facing check that fires on
nothing. Both are honest, careful work on things nobody asked for, done
because #14 has given them nothing to react to. **The thing Nick asked for
first and longest — space between the hunters and the beast — has had no
pushed work since he asked at 11:52.** The fixer's 20:19 run pushed nothing
(no commit, no note, lease went stale); its 21:20 run claimed #14 at 21:33
and is live now. That is the single thing standing in the way.

**My miss, at the top as the brief says:** Nick answered #18 at 19:48 EDT
(Dev / Player camera switch) and it sat unrelayed for two hours — the mirror
landed it after my 20:08 run. Relayed now, high, to the fixer, sequenced
after the #14 pass in flight.

**Audit of what closed since 20:08.** #16 (stones as boulders): closed by
the artist on a measured Done-when (height = width, 0 `hunter-off-marker`);
that was the ticket I wrote, so the closing was fine and the scoping was
mine — I asked for bulk and got a sphere. Reopening would be unfair; the
shape is a new request instead. Nothing else closed. #13 correctly left open
by the artist. #3 (Nick's 09-23 ticket) was `taken` for 31 hours with its
stones half never started; closed it as superseded into #14/#18 under #18's
authority so his board shows one row per outcome.

**Filed (three, the limit):**

1. `to: fixer`, high — Nick's Dev / Player camera switch in the Menu. Next
   run, after the #14 pass in flight; NOT the third-person camera itself.
2. `to: artist` — the footholds read as clay pots; build a faceted boulder
   as a model asset, do NOT touch `combat_3d.gd` (fixer is in it on #14).
3. `to: nick` — keep or revert the re-cut jackal; the artist asked in its
   status note where he cannot see it. Recommend keep.

**Held back (not filed, watch next run):**

- The artist's jackal before/after frame is half scale, not 1:1, against
  COMMON §4. It happens not to matter for this change; it will matter for
  the next one.
- Hunters are ~15-20px at rest and were before; that is #14's gap, not a
  model problem, and the artist's 20:13 read of that is right.
- The playtester has done three runs of "baseline unchanged, add a check".
  Fine while #14 is dark; the moment #14 lands, the run that matters is a
  route-reads-as-a-path look, not a new check.
- Sigil close-up still mostly wall; judge after #14 moves the camera.
- #13's `eta: next run` is stale (it is blocked on #14); the artist owns
  that line.

**What is working, so nobody optimises it away:** #16's one-line fix with a
before/after; the artist refusing to tick bar lines that are Nick's call;
the playtester proving a check fires by breaking the code on purpose; the
artist declining to touch camera code that another agent owns. Keep all of
it. The palette and the beast's silhouette are right.

## Old: 2026-09-24 20:09 EDT

- **Did:** took #18 and reorganised the tickets: one live stones ticket (#14), five closed or answered ones off your column.
- **Worked?** Yes; your Waiting-on-Nick column is now empty and #5 no longer asks a question you answered at 11:47.
- **Next:** chase the fixer on #14 (gap first, then stones) and the artist on #13; file the camera ticket after #14.
- **Need from you:** nothing until #14's after-frame reaches you on #18.

### Now, as of 20:09 EDT

**What a player sees, before I read anyone's note.** Resting shot: a tall
black dog with orange cracks, whole, on a dark disc under a purple sky. Two
green specks at its paws. Two pale saucers floating at its right flank. Sigil
close-up: mostly empty cave wall; the jackal is a black lump under the cards
and the "Attack 7" tag hangs in empty air. Grip shot: the best of the three,
the Frog mid-leap at a leg with a "3" landing, but the jackal's head is off
the top and the Goblin is behind the party panel (harness prints
`VIS FAIL hunter1`; the bar accepts that by design).

![[frames/director/2026-09-24-director-at-the-sigil.png]]
![[frames/director/2026-09-24-director-grip.png]]

**Against Nick's drawing** (`art/references/2026-09-24-nick-target-composition.webp`),
bullet by bullet of #11:

| his drawing | the frame now | verdict |
|---|---|---|
| whole beast, upper-middle | whole beast, head to foot | **yes** (fixer, #11) |
| cool sky, dark ground, pale stones | purple sky, dark disc, pale stones | **yes** (artist, #12) |
| hunters far back, wide gap | between the paws — the 10-unit gap is end-on | **no** |
| stones a diagonal staircase up the front | two 30x10px saucers at the flank | **no** |
| side-on / three-quarter | straight on | **no** |
| hot orange beast | black beast with ember cracks | **not decided** — asked above |

**Did the fight get better for Nick, or did three scores go up?** Better,
genuinely: today's #11 and #12 are the two biggest visible moves this fight
has had, and both were verified honestly. But the half of #11 that would
make the improvement *read* (bullets 1, 2, 4) was scoped out, and the thing
Nick asked for most (#4, "stones in front", 11:52) has had no work since he
asked, while #6 and #11 shipped past it. He asked on #5 at 17:40 "do you
need any guidance on how to proceed" — that is a man waiting.

**Filed (three, the limit):**

1. `to: fixer`, high — #4's visible half, stones in FRONT, now; Nick is
   waiting; no fifth investigation note.
2. `to: fixer` — turn the resting camera three-quarter; Nick already asked
   (#11 bullet 4); it is the one change that makes the gap and the path
   visible without moving anything.
3. `to: artist` — the footholds are saucers; give them boulder bulk, keep the
   colour, do not touch placement. After #13.

**Held back (not filed, watch next run):**

- The playtester's new `camera-not-over-shoulder` check enshrines an
  over-the-shoulder RESTING shot (Nick, 09-23), thirty minutes before the
  fixer removed it for #11 (Nick, 09-24). It passes today only because it is
  gated on `_focused`, which the fixer's fix leaves false on the ground. If
  either agent "fixes" the other, the camera will flip back. Playtester: the
  resting-shot target is now #11's drawing, not OTS; OTS mid-climb still
  stands.
- The sigil close-up shows wall, not beast. The front route (#4) will change
  that camera anyway; judge it after.
- The arena floor is a hard-edged oval disc over a void; it reads as a
  stage, not ground. Pre-existing; below the three above.
- #13 (hunters at 40px) is Nick's own, taken by the artist this hour; no
  request from me until I see what ships.

**What is working, so nobody optimises it away:** the root-cause instinct
(the tight-lock camera, the stale-frame intent tag) and the habit of
rendering before claiming are exactly right. The palette is right. The
beast's silhouette reads at play size. Keep all of it.

**Rule from Nick, 19:15 ET:** anything I need him to answer goes in a `to: nick`
request with `ask:` filled, so it lands in the board's Waiting on Nick column.
A question in this note's `Need from you` line is invisible to him. Every
future director run: never ask Nick here without a matching request.

**Reorganisation, 2026-09-24 20:09 EDT.** What went wrong on #5: Nick's real answer was
typed under `## Result` as a second dated `## Nick's answer` heading, the
GitHub mirror then put his later comment under the first heading, and nobody
set `to:` back off him — so the board showed an answered ticket as waiting on
him with an `ask:` he had already settled. Same shape on #11 (answered via
#18) and #17 (answered on GitHub). Fixed by hand this run; the rule that
stops it is COMMON.md 1a (take the ticket back the moment he answers).

**Live tickets under #18 now:** #14 (fixer: gap, then stones, top hold
standing), #13 (artist: characters, hand back to Nick with a 1:1 frame).
Closed: #4, #5, #11, #15, #17. The camera ticket (#18 step 3) is filed only
once #14 lands, so the fixer has exactly one thing in front of it.

## Log
- 2026-09-24 21:58 EDT — no movement on #14; relayed Nick's camera-switch ask to the fixer, closed #3 into #14/#18, filed stones-shape (artist) and jackal keep/revert (nick).
- 2026-09-24 20:09 EDT — took #18; reorganised #4/#5/#11/#14/#15/#17 (one live stones ticket, Nick's column cleared).
- 2026-09-24 19:20 EDT — Nick could not see my question; refiled it as a `to: nick` request (black jackal vs hot orange). Rule recorded above.

- 2026-09-24 18:40 EDT — first run. Rendered 3d/3dclimb/3dgrip, compared with Nick's drawing, filed 3 requests (2 fixer, 1 artist).
