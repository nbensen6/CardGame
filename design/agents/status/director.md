---
tags:
  - agent-status
agent: director
updated: 2026-09-25T08:13
working_on: The 07:51 chest fix moved the rocks and not the feet — Frog on air, path in pieces, every check green; filed to fixer (high) and a feet-on-stone check to playtester.
---

# director

## This run — 2026-09-25 08:08 EDT

- **Did:** the 07:51 chest fix: chest clear, but the Frog now stands on air and the path is in pieces.
- **Worked?** No; every check stayed green because the rocks moved and the feet did not, which no check reads.
- **Next:** fixer moves foot and rock together (filed, high); playtester builds a feet-on-stone check (filed, high).
- **Need from you:** one word each on #14 and the camera row; a new sixth row on the weak-point shot.

## Now

**The top line, found after my first pass (08:05, on `8328d9f`).** The
fixer's #0658 landed at 07:51, one minute before my first render. It clears
the chest and both forelegs — that half is right and I said so. But it
clears them by shoving each low rock sideways by up to 5.6 units (eight
Frog-heights) and leaving the landing the Frog hops to exactly where it
was; the shipped comment says the rock "stays well within the hunter's own
footing radius", which is not true at that size. On screen: at the first
hold the Frog stands on air with the orange-rimmed stone behind its right
shoulder and its shadow on bare ground, and from the resting camera the
staircase of 06:55 has come apart into four groups — a box at far left, a
box in the middle, a cluster at the head, a low cluster at the Frog's
feet. `beast-behind-stone` 0, `hunter-off-marker` 0, `hop-distance-band` 0,
`hunter-lost-mid-hop` 0: the rock checks read rocks, the foot checks read
foot targets, nothing reads whether they coincide. **Score up, frame
worse — the exact pattern this role exists for, and #0505's "lands on air"
reintroduced from the other side.** Filed to the fixer, high (foot and
rock move together; keep the clear chest; do not touch count, shape,
camera, gap, thresholds) and to the playtester, high (a `hunter-on-stone`
check on drawn pixels, verified to fire on this tree and go quiet one
commit back). #0658 left `done` — it met its own Done-when — with a note
pointing at the new ticket. My share: #0658 said "keep #0505: a stone under
every landing stays" and the fixer read that as the stone *object*
staying; I should have written "under the hunter's feet, on screen".

![[frames/director/2026-09-25-0805-director-grip-frog-on-air.png]]
![[frames/director/2026-09-25-0805-director-resting-after-chest-clear.png]]

**What a player sees, before I read anyone's note (07:53, on `ebdf221`).**
Resting: the same frame as 06:55 to the pixel that matters — black jackal
upper-left of centre, head clear of the bar, "Attack 7" beside it, twenty
pale orange-lidded stones climbing from the Frog's left to its chest, the
two nearest still standing in front of its lower chest and near foreleg;
the Frog big, bottom-left, facing away; the Goblin far right, alone on an
empty half of the frame. Grip: the red "3" on the Frog, twelve stones in a
line, the beast a pair of legs behind the tag. Sigil: four-fifths sky, the
beast a lump behind the cards, the Frog a speck, the Goblin out of frame,
the intent tag floating alone.

![[frames/director/2026-09-25-0753-director-resting.png]]
![[frames/director/2026-09-25-0753-director-grip.png]]
![[frames/director/2026-09-25-0753-director-sigil.png]]

**Against the drawing:** unchanged since last run — beast at a third where
the drawing has two thirds, twenty lidded boxes where it has four round
boulders, the frog an eighth of the beast there and the same height here.
Every one of those gaps is already a row on Nick's board or a ticket in
the fixer's queue. Nothing new drifted.

**Did the fight get better for Nick, or did a score go up?** Neither, and
that is fine this hour. The playtester's #0506 landed: the mid-hop check
now judges real drawn pixels, and it proved the check bites by reverting
the fixer's fix and watching the number jump to 44%, then put the fix
back. That is exactly the discipline I asked for, it closed on a test, and
it changed nothing on screen by design. The artist rendered, found nothing
unblocked, built nothing — correct; card art is parked by Nick himself, so
its idle hours are not a miss. The fixer claimed #0658 at 07:22 and is
live; no push yet at 07:58.

**A decision that was his, made without him — the top line.** The sigil
frame above has no Goblin in it. The screenshot harness prints "out of
frame by design" for that (playtester, 03:22 today), and the bar's "both
hunters are always findable, including mid-climb" is ticked (artist,
yesterday) on the argument that the party panel is what keeps the partner
findable — on a frame taken before Nick opened the gap, when the Goblin
stood beside the Frog. I cannot find Nick saying the partner may leave the
frame at the payoff moment, and his camera words assume it is in view.
Filed `to: nick` with the frame, two options and a recommendation
(reframe on the beast's head and back, Goblin small below), sequenced
after his resting-camera row. Left the bar tick in place with a one-line
"disputed" note under it — his to untick, not mine. Told nobody to build.

**Closed since my last run:** #0506 (playtester, done — closed on a real
pixel test plus a negative test; fine). Nothing closed on his judgement.

**Stuck:** #0257 (playtester) is `open` while the playtester works it as
its own — low risk, it is addressed to nobody else; not worth a ticket.
#0258 and #0405 still open to the fixer, correctly behind #0658. #18
(mine) has no visible movement; chase entry added, every lever is Nick's.

**Nick's column:** #14, the camera row, #13, the box-with-a-lid, the
faceted jackal, the RoR picture, and now the weak-point shot. No answers
since yesterday 19:48. The two that unblock the fixer's next runs are #14
and the camera row.

**Filed:** three — nick (weak-point shot, 07:58), fixer (Frog on air, high,
08:02), playtester (feet-on-stone check, high, 08:03). One note on the bar,
one on #0658, one chase entry on #18. The fixer's ticket goes ahead of
#0258 and #0405; the playtester's sits beside its #0257 half.

**What is working:** the playtester proving a check can fail before
trusting that it passes; the fixer writing failing numbers down; the head
clear of the bar in every frame since 01:05. Do not optimise any of that
away.

**Harness note for the other three:** the first `state=3d` render after
`--import` on this cold sandbox came out empty — a sand disc, a yellow
blob, blank HUD — and the second was real. If your first frame of a run
looks like nothing, render it again before you file anything.

![[frames/director/2026-09-25-0752-director-cold-render-empty.png]]

**Not filed — first thing next run, fixer, after the Frog-on-air:** the
settled frame after the Frog's first climb has the Goblin filling the right
third of the screen, legs and belt over the climb gauge and the Menu — the
post-hop camera pivots to the Frog with the partner three and a half units
from the lens. Found in step 0 of my own 14-step playtest on `8328d9f`
(`PLAYTEST OK: 0 failing check(s)` — no check reads the other hunter
against the camera either). Not yet proven whether it predates 07:51; the
mid-hop frames and the playtester's 07:45 launch frame use the climb camera
and do not show it, so nobody has looked at this exact frame at 1:1 before.
Three requests were already filed when I found it; it is the top of the
next run.

![[frames/director/2026-09-25-0812-director-after-first-climb-goblin-fills-right-third.png]]

**Not filed (kept for later):** the intent tag floating in the sky at the
sigil (moves with the sigil camera; do not tune it for a pose that is
about to change); the Goblin alone on an empty right half of the resting
frame (the lens row decides it); the grip shot's beast reduced to legs
(same camera step).

## Log
- 2026-09-25 08:08 EDT — the 07:51 chest fix (#0658) cleared the chest by moving rocks and not feet: Frog on air at the first hold, path in four pieces, every check green — filed to fixer (high) and a hunter-on-stone check to playtester (high); before that: frames matched 06:55, playtester closed #0506 on a real test, artist correctly idle on Nick; found the "partner off-screen at the sigil is by design" call made by two agents, not Nick — filed it to him with a frame, marked the bar tick disputed; harness note: the first render on a cold sandbox came out empty.

- 2026-09-25 07:02 EDT — path better, beast worse: #0505 put twenty stones across the gap and two hide the chest; the check fired 7-13 times and the fixer called it the playtester's; filed placement-only fix to the fixer (high), rewrote Nick's #14 ask to the count with options, folded stale #2356 into #14, flagged #0258/#0405 open while the fixer said nothing of mine.
- 2026-09-25 06:05 EDT — addendum: fixer's camera lock landed 05:56; verified by my own pixel count, Frog drawn in 24/24 opening Leap frames (was 0/24) and the mid-Leap shot is the best frame yet; found the 24 shots are the first 24 frames only, added to 0506.
- 2026-09-25 05:57 EDT — nothing visible moved (frames identical to 05:00 bar idle); fixer live on camera lock; answered the playtester's chest-stone handback (pixel metric via 0506, no exemption, no route bend) — the chest stone is a floating waypoint that only lines up from one camera, recorded on #18; nothing closed, nothing stuck, Nick's five rows unchanged.
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
