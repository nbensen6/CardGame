---
tags:
  - agent-status
agent: director
updated: 2026-09-25T05:12
working_on: The hop split shipped correct-but-invisible; the Frog vanishes for the whole Leap and lands on air — camera lock first, stones under the landings second.
---

# director

## This run — 2026-09-25 05:12 EDT

- **Did:** the fight is not better; the Frog now vanishes for its whole leap and lands on air twice.
- **Worked?** The hop check went to zero honestly, but the flight it fixed cannot be seen by a player.
- **Next:** fixer makes the camera follow the Frog, then puts a stone under every landing; playtester counts drawn pixels.
- **Need from you:** nothing new; your five open rows stand, the lens one has one more picture.

## Now

**What a player sees, before I read anyone's note (04:52, on `9d24792`, the
04:20 tree).** The three still frames are pixel-for-pixel the ones I judged
at 04:08 — nothing in the resting, sigil or grip shot moved this hour.
Resting: the whole black jackal upper-middle, a third of the frame tall,
"Attack 7" beside the head; the Frog in full profile facing screen-right,
the Goblin facing the camera; the pale box with the orange lid on the left,
a small cone on the beast's chest. Sigil: four-fifths purple sky, "Attack 7"
over nothing, the beast a black lump behind the cards, the Frog a speck on
a plate, the Goblin out of frame. Grip: the Frog behind a red "3", only the
beast's legs in frame.

![[frames/director/2026-09-25-0500-director-resting-shot.png]]
![[frames/director/2026-09-25-0500-director-at-the-sigil.png]]
![[frames/director/2026-09-25-0500-director-grip.png]]

**What moved was motion, so I ran the 24-step play and looked at the Leap
(step 1, foot 2→6).** The Frog leaves the near stone and the next thing on
screen is the Frog at the sigil. In between, the camera swings to the
beast's face and the Frog is drawn in **0 of 24 captured frames** — I
counted its pixels; the same count finds ten thousand in the resting shot.
The check that guards this (`hunter-lost-mid-hop`) says 73 % on screen and
passes, because it projects a point into the rectangle and the Frog is
behind the body.

![[frames/director/2026-09-25-0500-director-leap-sheet.png]]

**Did the fight get better for Nick, or did a score go up?** A score went
up. The fixer's hop split (`f0808f0`) is a real, tested, honestly-reported
fix: `hop-distance-band` 124 → 0, four unit tests, a disclosed 42 → 52 %
regression on the camera check and a reverted pop rather than a shipped
one. It is also the pattern this note exists to catch, **correct but
invisible**: the ticket was about a 20 m hop nobody could see, and the
fix is three 6.8 m hops nobody can see, two of which land on air, because
the crossing still has one stone at each end and nothing between. The
fixer's own #14 note named both halves ("the hop animation itself, not just
`route_pos` placing more decorative stones") and shipped one. Nick's words
were "stones in a pattern from left to right"; two stones is not a pattern.

**Filed (three things, two of them requests):**
- Raised the fixer's own camera-lock ticket (`0420`) to `high` with a
  director note: this before the side-on hunters and the damage number;
  judge it by a strip with the Frog in every frame, not the check at 0; do
  not revert or retime the split.
- `to: fixer` (`0505`, high): a stone under every sub-hop landing between
  the near box and the chest, receding, the artist's rock; after `0420`;
  placement only — no new Heights, no gap change, no raycast, no revert.
- `to: playtester` (`0506`, high): make `hunter-lost-mid-hop` count drawn
  pixels, the way `beast-behind-stone` does; after the on-body-stone ticket
  it is on now; do not touch the threshold.

**The one frame worth Nick's eye this hour** is the mid-Leap one: whole
beast, face clear, tag above the head, ears in the sky — exactly his #18
"upper two thirds" line, and it only exists because the Frog is not in it.
Added to the lens/gap ticket in his column as the trade in one picture; the
`ask:` is unchanged.

![[frames/director/2026-09-25-0500-director-mid-leap-no-frog.png]]

**Audit of what closed since 04:08.** Two. The 20 m-hops ticket (`2344`),
closed by the fixer on a measurement with tests — correct close, and the
visible half is now its own ticket. The near-stone ticket (`0200`), closed
per my own 02:58 call — fine. **Stuck:** #14 was `taken` with an eta still
reading "item 3 not started" an hour after item 3 landed; corrected the eta
and added the handback condition, left it with the fixer because the
crossing is not yet something to show him. The face-behind-tag ticket
(`2356`) is `taken` by design, riding #14's handback — fine. Nick's five
open rows are unchanged and none has an answer yet; nothing of his was
decided without him this hour that I can find.

**Artist:** correctly built nothing again; both of its items are with Nick.
**Playtester:** live now (claimed 04:46) on the on-body-stone ticket; its
new request queues behind that.

**Not filed (kept to three):** the sigil shot is still four-fifths sky and
the Goblin is out of frame there — that is the camera, #18 step 3, mine,
after the gap and the stones per Nick's own order. The Frog leaving the top
of the frame on Tongue Snap (foot 0→2, 26 % off) is the same camera-lock
bug as `0420` from the other end and should fall with it.

## Log

- 2026-09-25 05:12 EDT — fight not better; hop split landed correct-but-invisible (Frog drawn in 0/24 Leap frames, lands on air twice). Raised fixer's camera-lock to high, filed stones-under-landings (fixer) and drawn-pixels check (playtester); #14 eta un-staled.
- 2026-09-25 04:08 EDT — nothing reached the game this hour; camera ask to Nick rewritten to name the gap-vs-two-thirds collision; hunters-face-the-beast filed to fixer after the hops; fixer told stone 2/5 are on-body; playtester pointed at the on-body split.
- 2026-09-25 02:58 EDT — fight better (whole beast back, fixer 02:49; red horizon line gone, artist 02:35), no scores moved; the near stone's box-with-a-lid shape is two of Nick's own inputs in conflict — filed to him with options; playtester told the tree moved under it and a stone on the body is not a failure; fixer told Height 2 stays, close the ticket, hops next; popup-on-the-Frog filed to fixer for after the hops.
- 2026-09-25 02:05 EDT — Goblin reads beside the Frog (artist, #13 handed back right); the fixer's stone sweep landed mid-run and the near rock now hides the beast chest-to-paws — filed the placement fix to the fixer, the occlusion check to the playtester, unblocked #19 for the artist. My miss: #14's visible half ("beast stays visible") was never stated.
- 2026-09-25 01:00 EDT — fight better again (Frog reads and matches the drawing; beast's head clear of the HUD, fixer 00:52); no scores moved; named the style-C vs smooth contradiction for Nick on #13 with options; artist sequenced (Goblin next, do not touch the Frog, do not decimate); #14 now the only blocker.
- 2026-09-25 00:03 EDT — fight visibly better (close shot landed: Frog quarter-frame, diagonal); beast head behind the HUD filed to fixer; #13 told it is unblocked; #19 re-routed to artist with the artist's correct cause; #14 sequenced (head → stones → 20 m hop).
- 2026-09-24 22:58 EDT — nothing visible moved; camera lock (fixer) and boulder mesh (artist) both landed correct-but-invisible by my own scoping. Advised the fixer on the over-the-shoulder framing, filed the horizon line to the artist, asked Nick for the RoR picture as a ticket.
- 2026-09-24 22:35 EDT — Nick live: three asks by morning. Camera ticket rewritten (locked by default, RoR shot), #14 re-aimed on his route_pos, #13 re-aimed smooth, playtester told its checks read the old route.
- 2026-09-24 21:58 EDT — no movement on #14; relayed Nick's camera-switch ask to the fixer, closed #3 into #14/#18, filed stones-shape (artist) and jackal keep/revert (nick).
- 2026-09-24 20:09 EDT — took #18; reorganised #4/#5/#11/#14/#15/#17 (one live stones ticket, Nick's column cleared).
- 2026-09-24 19:20 EDT — Nick could not see my question; refiled it as a `to: nick` request (black jackal vs hot orange). Rule recorded above.

- 2026-09-24 18:40 EDT — first run. Rendered 3d/3dclimb/3dgrip, compared with Nick's drawing, filed 3 requests (2 fixer, 1 artist).
