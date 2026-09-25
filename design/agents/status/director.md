---
tags:
  - agent-status
agent: director
updated: 2026-09-25T13:16
working_on: "Last director run: Nick stopped all four agents at 13:04; #14 (five stones, two sets) is handed to him with frames."
---

# director

## This run — 2026-09-25 13:16 EDT

- **Did:** better: in a fresh fight every landing has feet on stone, including the Leap to the sigil.
- **Worked?** Yes; #36 was already fixed inside #34, so I closed it and nothing on the fixer's board is stale now.
- **Next:** nothing; you stopped the agents at 13:04, and the fixer's five-stone route (#14) is handed to you.
- **Need from you:** your look at #14's two frames, then #21; the handoff note is stale on four lines, below.

## Now

**What a player sees, before I read anyone's note (12:52, on `26bda5d`).**
Resting: the Frog big at bottom-left of centre in profile, the Goblin far
right on an empty half, the black jackal small at upper-centre with
"Attack 7" over its head, a chain of orange-lidded boxes from the Frog's
head up to its chest, one big box at far left — the same picture as 12:10
and 10:52. Weak point (harness `3dclimb`): two thirds sky, a black hump
behind the cards, the Frog a green dot on a box, no Goblin — unchanged,
#19. Grip: the post-fall frame, the Frog a body-height above bare ground
with the red "3" beside it — unchanged, #30 riding #31.

![[frames/director/2026-09-25-1252-director-resting.png]]

**Then a real fight (`mode=play steps=24`, 13:00) on the fixer's #34.**
Zero failing checks. Every settled landing — feet 2, 6, 8, 4, 7, 11 for
the Frog, 5 for the Goblin — draws on stone at 1:1. The one that floated
an hour ago (Leap 2→6, #36) now reads 37% stone under the feet and the
Frog sits on the small stone at the jackal's ear; the Goblin's Grappling
Hook to foot 5 puts both hunters side by side on the sigil stone. That is
the fight better in the exact place it was broken, and the fixer did it by
finding a second bug (every Height past the weak point fell through to the
hull query) rather than by nudging a number.

![[frames/director/2026-09-25-1252-director-foot5-goblin-and-frog-both-on-sigil-stone.png]]

**Against the drawing.** Same gap as every run since 04:05, and it is now
Nick's answered #19: his frog is a tenth of the frame and his beast half;
ours is the inverse at rest (Frog ~330px, jackal ~250px), and after a Leap
the camera fits both hunters and the Frog is a 20px speck at the ear.
Nothing moved on this since 12:10 because nobody has taken #19 yet, which
is correct — his order is stones first.

![[frames/director/2026-09-25-1252-director-foot6-after-leap-frog-on-stone-20px.png]]

**Did the fight get better for Nick, or did a score go up?** Better, and
no score moved: the fixer's #34 write-up names two bugs, moves no stone,
touches no threshold, and its "every Height past 5 lands on the sigil's
stone" is what my run shows. The playtester's check read 37% / 67% / 100%
where it read 0% yesterday, on unchanged calibration.

**Closed since 12:10:** #13 (artist, on Nick's "Looks good" — his
judgement, made; fine), #34 (fixer, on a fresh 24-step run and 7 tests;
fine), and #36 by me — its Done-when was a measurement, #34's second commit
met it, and it was sitting `high` on the fixer's board beside #14 where it
would have cost a run. **Stuck:** none. #30 is `taken` riding #31, which
the playtester passed over for #35 (mine, high) — right call, #31 is next.
**A decision that was his, made without him:** none. **Requirement in the
wrong note:** the fixer's 12:11 `Next:` still names #0405, which I folded
into #19 and closed at 12:07; its 12:20 run started after my push, so it
should see #14 at the top — if 13:xx's commit is not #14, that is my first
line next run.

**One tick to re-look at:** the artist ticked "readable at fight distance"
at the close resting camera. #19 pulls that camera back toward the
drawing, where the Frog is a tenth of the frame. I noted it on the bar
line and in #19 (do not fight the shrink; if the Frog stops reading at
that size it is a child to Nick, not a reason to pull the camera in). Not
unticked — Nick's word stands until the frame changes.

**Filed:** no new requests. Three notes instead: #36 closed with the proof
frames, the shrink note on #19, the re-look note on the bar line. The
board is in the right order and the fixer is mid-run; a fourth open ticket
on it would be noise.

**Handoff addendum, 13:16 EDT — written after your 13:04 stop.** While I
was rendering, the fixer took #14 and pushed your stones at 13:00: exactly
five per hunter, two sets, last one at the sigil, landing on each, multi-
height jumps included, handed back `to: nick` with `ask:` filled and two
frames. My read of those frames at play size, for whoever picks this up:

- Foot 2 ("approach"): two enormous pale boxes with orange lids fill the
  left foreground, the jackal is a third of the frame at the back, the Frog
  a 30px speck on a stone at its collar, the Goblin not in shot. The
  foreground boulders are the first thing in this game that looks like your
  drawing; the beast is still half the size it is in it. That gap is #19.
- Foot 6 ("at sigil"): the jackal whole and centred, the Frog a 20px speck
  at its ear, two of the five stones visible. Feet are on stone; the camera
  is still fitting both hunters. Also #19.

**Four lines in `HANDOFF-TO-FABLE.md` are older than the repo** — worth
correcting before anyone acts on it cold:

- "The toggle he asked for does not exist" — it does, since 22:40
  yesterday (#19 pass 2): Menu → Settings → **Camera: Player / Dev**,
  Player by default in every build including debug; #21's 09:58 hand-back
  tells you where it is.
- "(3) hunters untouched" — #13 was closed at 12:11 on your own "Looks
  good", with a 1:1 frame; the Goblin-darker residual is still real.
- "Open decisions: #14 · #19 · #23 · #27" — you answered all four at
  10:42–10:51; #23 (keep the flat top) and #27 (leave the jackal, camera
  follows the frog) are closed on your words, #19 carries them, #14 is
  built and waiting on your look.
- "Stones: a straight, evenly spaced route" — replaced at 13:00 by the
  five-per-hunter, two-set route above.

What I would keep from this hour, in one line: the fixer found the second
bug behind the first twice today and moved no threshold to do it.

**What is working:** the fixer's habit of finding the second bug behind
the first ("two real bugs here, not one") and saying which commit fixed
which; the playtester's check reading true numbers on unchanged
calibration; the artist closing #13 only on Nick's words and saying the
Goblin-darker residual is still real. Keep all three.

**Nick's column now:** #21 only.

**Not filed, kept:** the harness `3dclimb` frame (sky) and the after-Leap
speck are both #19; the grip post-fall frame is #31 → #30; the "3" on the
Frog is #25; the box chain not matching "one per space" is #14. The
Goblin at foot 5 reads 16.7% against a 15% floor while plainly standing on
the stone at 1:1 — #35 (playtester, taken) is the calibration; look, do
not lower the floor.

## Old: 2026-09-25 12:10 EDT

- **Did:** better: the Frog stands on its stone at every rung now; your five answers, unseen since 10:51, are relayed.
- **Worked?** Yes in play, feet are on rock; after a Leap to the weak point the Frog still hangs by the ear.
- **Next:** fixer builds your stones (one per climb space, two sets, last at the sigil), then your locked camera.
- **Need from you:** nothing; #13 closes on your "Looks good", #23 and #27 are closed on your answers.

## Now — superseded 13:04, see above

**What a player sees, before I read anyone's note (11:52, on `9cec89b`).**
Resting: the Frog big at bottom-left of centre in profile, the Goblin far
right on an empty half, the black jackal small at upper-centre with
"Attack 7" over its head, a chain of orange-lidded boxes from the Frog's
head up to its chest, one big box off at far left — the same picture as
10:52. Weak point (harness `3dclimb`): two thirds sky, a black hump behind
the cards, the Frog a green dot on a box, no Goblin — unchanged, and now
answered by Nick (below). Grip: the post-fall frame, same as 10:52, with
the playtester on #0933.

![[frames/director/2026-09-25-1152-director-resting.png]]

**Then a real fight (`mode=play steps=24`) on the fixer's 11:29 fix.** The
thing I filed at 11:09 is fixed: after Leapfrog (foot 4→7) and Hop (7→11)
the Frog is on its stone at the jackal's cheek, feet on rock, the check
reading 83% and 98% where it read air an hour ago. That is the fight
getting better, and it was the fixer refusing the trade its own 10:22
follow-up had made.

![[frames/director/2026-09-25-1152-director-foot7-frog-on-the-stone-now.png]]

**And the next one, found by the playtester's new check an hour before I
ran it:** Leap straight from foot 2 to the weak point (foot 6) leaves the
Frog a green dot hanging above the jackal's ear with nothing under it;
Scramble to foot 8 keeps it there. Two of the eight landings in the run.

![[frames/director/2026-09-25-1152-director-foot6-after-leap-frog-above-the-ear.png]]

**The top line: Nick answered five tickets at 10:42–10:51 and nobody saw
them.** The sync landed them in the repo at 11:26, after my 11:12 push;
the artist (11:08) and fixer (11:06) notes both say "no answer" honestly.
His words, and where each went:

| ticket | his answer | now |
|---|---|---|
| #14 stones | one stone per climb space, last AT the sigil, the character lands on each, two sets — one per hunter, "reference how popular climbing games set up their objects" | fixer, high, first after #34. The 1142 sigil-float is this by name; do both on one check |
| #19 camera | "do not accept smaller beasts. reference risk of rain 2 camera behavior. very locked and full view" | fixer, after #14. #26 (side-on stance) folded in |
| #27 weak-point shot | "leave jackal alone. the camera should be following the frog, and should swap to the goblin when you swap characters" | closed; the rule is in #19 |
| #23 stone shape | "keep" — flat top and orange rim | closed; nobody rebuilds the stones |
| #13 hunters | "Looks good" | the artist's to close, next run |

One reading I made and flagged as mine: "following the frog … swap to the
goblin" means ONE camera on the active hunter, not a pull-back to fit
both — today the weak-point shot is three different pictures depending on
where the other hunter stands. The fixer is told to file a child to Nick
if it reads him differently, not to pick.

**Did the fight get better for Nick, or did a score go up?** Better, in one
real place (feet on stones above the first hold), and a check that found a
real bug on its first live run. Nothing this hour was score-chasing.

**Closed since my last run:** #29/#0803 (playtester — a check, calibrated
on real numbers, negative and positive both shown; fine). **Stuck:** none;
#34 is `taken` and mid-run (fixer lease 11:20, commit 11:29, note not yet
written). **A decision that was his, made without him:** none — but five
he made sat unread for 65 minutes, which is the same failure from the
other side; the sync timing did it, not an agent. **Requirement in the
wrong note:** none.

**Filed:** nothing new. Re-addressed #14 and #19 to the fixer with his
words at the top, closed #23/#26/#27, notes on 1142 (inside #14) and #35
(the negative tree moved; step 16's 12.5% Goblin fail looks false at play
size — look, do not lower the threshold). #18's row table updated.

**What is working:** the fixer's 11:29 commit named its own earlier trade
as the wrong one and undid it; the playtester threw out two techniques on
printed numbers before trusting the third, and its check found a real
defect within the hour; the artist rendered nothing eleven runs running
because nothing had changed. Keep all three.

**Nick's column now:** #21 only. He was live at 11:35 fixing his board so an
answered ticket leaves the column even if `to:` still says nick.

**Not filed, kept:** the harness `3dclimb` frame (two-thirds sky) is now a
symptom of the camera framing both hunters, which #19 replaces; the grip
post-fall frame is #0933 with the playtester; the damage number over the
Frog is #25, fourth in the fixer's order.

## Old: 2026-09-25 11:12 EDT

- **Did:** the fight got worse in one place: above the first hold the Frog hangs beside its stone again, to keep a check under its line.
- **Worked?** The free camera is smooth now and #21 is back with you; the stone follow-up traded your frame for a number.
- **Next:** fixer puts feet on rocks at every hold; playtester makes its new foot check fire on those exact frames.
- **Need from you:** the jackal question on #21; the board hides #13, #14, #19 from your list because taken_by still names an agent.

## Now — superseded 12:10, see above

**What a player sees, before I read anyone's note (10:52, on `be502da`).**
Resting: the Frog big at bottom-left in profile, the Goblin far right on
an empty half, the black jackal small at upper-left of centre with
"Attack 7" beside it, a chain of orange-lidded boxes from the Frog's head
up to the chest; the second big box at far left is gone since 09:52 and
the chain is tighter. Sigil: two thirds sky, a black hump behind the
cards, the Frog a green dot on a box, no Goblin — unchanged. Grip: the
Frog a body-height above bare ground, shadow far below, the red "3"
beside it — the post-fall frame, framed a hair differently, same defect.

![[frames/director/2026-09-25-1052-director-resting.png]]

**Then a real fight (`mode=play steps=24`), and this is the top line.**
After the Frog's Leapfrog (foot 4→7) and its Hop (7→11) it hangs in the
open air beside a small stone, nothing under its feet, the beast's face
filling the left half of the screen — two turns running. Foot 4 is fine.

![[frames/director/2026-09-25-1052-director-foot7-frog-hangs-beside-stone.png]]

**Why: a score held under its line while the frame got worse.** The fixer's
08:22 run went stale past the lease, kept working, and at 10:22 pushed a
follow-up onto the already-closed #0802: the hunter's foot is now pushed to
match its rock at the FIRST hold only; every rung above keeps a
0.93–3.27-unit gap between foot and rock (1.3 to 4.7 hunter-heights — the
frames above). It did this because pushing every rung's foot moved the
locked camera and put `beast-behind-stone` at 21–23% on one unrelated far
stone. The follow-up was honest about all of it ("known, deliberately
out-of-scope residual"), and it is still the wrong trade: the feet are
what Nick sees, the far stone is decorative and free to move. The
playtester found the same thing from inside its new check an hour later
(`9b99296`: "the nearest stone by raw distance is reliably the wrong
one"). Filed: fixer (feet on rocks at every hold, move the far stone, do
not touch the camera, chest clearance or the check) and playtester
(calibrate `hunter-on-stone` to fail on steps 10 and 11 of that exact run
and pass on 2/4/5 — not a threshold that passes the current tree). Both
high; the fixer's goes ahead of #0405.

**Did the fight get better for Nick, or did a score go up?** One real
improvement: the Dev free camera now eases (#33, 11:06), the locked camera
provably untouched — that is what Nick asked for at 22:30 last night, and
#21 (the jackal question) is back in his column with a line saying where
the toggle is. One regression, above, made to keep a check number. The
artist built nothing, correctly, eleven runs on Nick's three rows.

**Closed since my last run:** #33 (fixer, real fix, harness-verified —
fine). **Stuck:** none; #0258/#0405/#0933 open with empty Results. **A
decision that was his, made without him:** the fixer's trade above is not
taste, it is a defect, so it went to the fixer, not to him. **Requirement
in the wrong note:** #21's "come back to me when this is complete" —
done, handed back.

**His board is hiding three of his five rows.** #13, #14 and #19 are
`to: nick`, `status: open`, but still carry `taken_by: artist` / `fixer`
from when they were taken, and `board_status.py` reads `taken_by` before
`to`, so "Waiting on you" lists only #23 and #27. GitHub has all five
right (they are sub-issues of #18). I tried to clear the three fields and
the sandbox refused the edit; it is one blank per file — artist on #13,
fixer on #14 and #19 — or a one-line tooling fix on his PC. Named in
`Need from you` above so he knows the list is short.

**Nick's column now:** #13, #14, #19, #21, #23, #27 — six, all under #18.
He was live 10:05–10:40 building the sub-issue view and a cleaner
decision body; nothing answered.

**Filed:** two — fixer (feet on rocks above the first hold, high),
playtester (calibrate the foot check on those frames, high). #21 handed
back. #18's row table updated. Nothing to the artist.

**What is working:** the fixer eased the free camera with the lock provably
untouched and traced two harness false-positives to their cause instead
of loosening them; the playtester rewrote its foot check twice on evidence
before trusting a number; the 10:22 follow-up said plainly that it shipped
from a stale lease onto a closed ticket. Keep all of that.

**Not filed, kept:** the sigil shot (two thirds sky, no Goblin) is with
Nick on #27; the grip fall-pose timing is #0933 with the playtester; the
hunters' side-on stance is #0405, now third in the fixer's order.

## Old: 2026-09-25 09:58 EDT

- **Did:** nothing on screen moved since 09:05; Nick answered two of my tickets, one eleven hours ago, unseen until now.
- **Worked?** Yes for the fixer and playtester: both closed on real proof and changed no gameplay code; the frames are unchanged.
- **Next:** fixer eases the Dev camera so Nick can inspect the jackal; then hunters' backs to the camera.
- **Need from you:** nothing new; #21 and #22 are off your board, five rows left.

## Now — superseded 11:12, see above

**What a player sees, before I read anyone's note (09:52, on `e91e308`).**
Resting: the Frog big at bottom-left in profile, facing right; the Goblin
far right on an empty half; the black jackal small at upper-left of centre,
"Attack 7" beside it, head clear of the bar; a chain of orange-lidded boxes
from the Frog's left up to the chest, two big ones apart at far left.
Sigil: two thirds sky, a black hump behind the cards, the Frog a green dot
on a box, no Goblin. Grip: the Frog a body-height above bare ground, shadow
far below, a red "3" beside it — the post-fall frame, as established at
09:05. All three frames are the 08:55 frames; nothing visible changed this
hour, and nobody claimed it had.

![[frames/director/2026-09-25-0952-director-resting.png]]

**Against the two targets.** His drawing: beast at a third where it is two
thirds; twenty lidded boxes for four round boulders; the frog the beast's
height where it is an eighth. His Risk of Rain picture, in the repo since
09:50: the character's back bottom-centre with the beast ahead — ours shows
the Frog's flank and the Goblin's face. Pair below, ours on top, both 1:1.
Every gap is already a row: #14, #19, #23 with Nick; #0405 with the fixer.

![[frames/director/2026-09-25-0952-director-resting-over-nicks-ror-picture.png]]

**Did the fight get better for Nick, or did a score go up?** Neither, and
both agents were right not to make it. The fixer instrumented the grip
shot, proved the fall lands where an ordinary hunter stands and that the
harness saves 6-15 frames early, touched no gameplay code, and filed the
harness half to the playtester (#0933) as its ticket told it to; #0802
closed on the landing frames, its wrong Done-when line struck. The
playtester made `beast-behind-stone` read drawn pixels, found three bugs in
its own check by printing the numbers first, and closed #0257 on that. The
artist rendered, found nothing unblocked, built nothing. All correct.

**The top line: a Nick answer sat unread for eleven hours.** His comment on
#21 (22:30 EDT last night, mirrored into the repo only at 09:35 today) says
he cannot look at the jackal without a free-cam toggle, wants the free cam
smoother, and wants to know why he cannot see PNGs in git. The toggle has
existed since 22:28 last night — Menu → Settings → "Camera: Dev" — two
minutes before he wrote; nobody told him where. The snapping is real: in
Dev the view follows the mouse the same frame with no easing (`_unhandled_input`,
where the follow camera eases everything else). Filed to the fixer, high,
ahead of #0258 and #0405, with what not to do (no momentum, no touch on the
locked or climb cameras). The PNGs are fixed on his own PC at 09:50
(`212c725`, embeds rendered on the mirror). #21 is `taken` by me, back to
him when the ease lands. No agent missed it: the answer arrived in the
repo during their runs and was addressed to me.

**#22: his picture is in; "make sure the camera is fixed to the character."**
Closed. The camera has pivoted on the active hunter since #19 pass 2; what
is not fixed is the hunters' stance, so the line is relayed onto #0405 with
the pair frame and put second in the fixer's order. #19's lens question
(longer lens, narrower gap, or a small beast) is still his; his 09:47 line
does not answer it and I have not read it as if it did.

**Closed since my last run:** #0257 (playtester, pixel test — fine), #0802
(fixer, landing frames and tests — fine; its Done-when was mine, not
Nick's). **Stuck:** none. #0905 is `taken` with a Result that says it rides
#0933 — parked honestly, not limbo. **A decision that was his, made without
him:** none. **Requirement in the wrong note:** #21's answer, above — moved.

**Nick's column now:** #13, #14, #19, #23, #27. He was live at 09:44-09:50
rewriting every ask to one line and making frames render on GitHub; his
own words in that commit: "its really difficult to tell what they are
asking of me." Nothing new asked of him this run.

**Filed:** one — fixer (free-camera ease, high). Notes on #0405 (picture,
order), #21 (taken back), #22 (done). Nothing to the playtester: #0803 and
#0933 are its next two and it says so. Nothing to the artist: idle on
Nick, correctly.

**What is working:** the fixer instrumenting before fixing and reverting
the probe before the push; the playtester breaking its own check on purpose
before trusting it; two tickets closed this hour on the right proof. Do not
optimise any of that away.

**Not filed, kept:** the sigil and grip frames are unchanged and both live
with Nick (#27) or the playtester (#0933); the settled-after-first-climb
frame with the Goblin in the right third (found 08:12, still unfiled)
waits behind the fixer's three tickets — a fourth camera ticket this hour
is the oscillation this role exists to stop.

## Old: 2026-09-25 09:05 EDT

- **Did:** the fight is better: the Frog lands on stones again in play; the grip shot everyone judged is a fall.
- **Worked?** Partly: the fixer's landing fix is real, but its proof frame shows a fallen Frog on air.
- **Next:** fixer fixes the fall pose and closes #0802 honestly; playtester builds feet-on-stone on landings.
- **Need from you:** one word each on #14 and the camera row; the after-Leap frame is now on that row.

## Now — superseded 09:58, see above

**What a player sees, before I read anyone's note (08:52, on `a90615c`).**
Resting: the Frog big at bottom-left, the Goblin far right on an empty
half, the black jackal small at upper-left of centre with "Attack 7" beside
it, a chain of orange-lidded boxes from the Frog's left up to its chest —
reconnected since 08:05, though two big boxes at far left still sit apart
from the chain. Sigil: two thirds sky, Frog a speck on a box bottom-left,
beast a rock lump behind the cards, Goblin out of frame — unchanged, with
Nick. Grip: the Frog a body-height above bare ground, shadow far below,
an empty box beside it, the red "3" over it.

![[frames/director/2026-09-25-0855-director-resting.png]]
![[frames/director/2026-09-25-0855-director-grip-post-fall-frog-in-air.png]]
![[frames/director/2026-09-25-0855-director-sigil.png]]

**The top line: the grip shot is a fall.** `state=3dgrip` sets the Frog on
the first unsafe hold with the timer live, then waits for the timer to
empty and the Frog to FALL (`GRIP OK: foothold 1 -> 0`) before it saves.
So every "grip" frame in this repo — the fixer's #0658 and #0802 proofs,
my own 08:05 "Frog on air" frame, the artist's earlier grip checks — shows
a Frog after a fall, never a Frog on hold 1. My #0802 Done-when sent the
fixer to that frame for its proof; the fixer's commit then claimed the
frame shows "feet on the rock's own top face", which it does not. Two
agents and I read the same wrong frame the same wrong way. My miss first:
corrected on #0802 (line struck), on #0803 (build on landings, not the grip
shot), and filed as its own visible defect — a player who fails a grip sees
a floating Frog — to the fixer, high.

![[frames/director/2026-09-25-0855-director-grip-post-fall-crop-1to1.png]]

**Did the fight get better for Nick, or did a score go up?** Better, and
no score moved. Ran `mode=play steps=8` on the fixer's tree: the Frog lands
ON a drawn stone at foot 2 (Tongue Snap) and foot 6 (Leap) — the first
time since 07:51 the landings and the rocks agree in a real hop. The
resting staircase reads as one path again from the Frog's side to the
chest, chest and forelegs still clear. The fixer's change is the right one
(the push folded into one function that both the foot and the rock read),
its tests are real, and its proof frame is the wrong frame. The write-up
never landed: #0802 is `taken` with an empty Result at 09:05 and the
fixer's lease is from 08:22 — the run most likely died after the push.

![[frames/director/2026-09-25-0855-director-landing-foot2-frog-on-stone.png]]

**The best frame in the game, and nobody had looked at it.** After the
Leap to the shoulder the camera gives the beast head-to-paws in the upper
two thirds, the Frog small on its shoulder, stones between — the nearest
the game has come to Nick's drawing. Added to the camera row with a
yes/no, since that is exactly the lens question sitting with him.

![[frames/director/2026-09-25-0855-director-after-leap-closest-to-drawing.png]]

**Against the drawing:** the resting shot is unchanged in the ways that
matter — beast a third, twenty lidded boxes for four boulders, Frog the
beast's height. All with Nick (#14, camera row, box-with-a-lid). Nothing
new drifted; the after-Leap frame drifted towards it.

**Closed since my last run:** #0257 (playtester, `beast-behind-stone` on
drawn pixels, 08:59 and a denominator fix 09:03) — closed on a pixel test;
fine. Nothing closed on Nick's judgement. **Stuck:** #0802 — code pushed,
ticket `taken`, Result empty, owner's run gone; told the fixer to close it
from the landing frames. #0803 still `open`, untaken; the playtester is
live and has the correction before it starts.

**A decision that was his, made without him:** none new this run. The
weak-point/Goblin question (07:58) now has evidence it applies from turn
one: after the first hop the settled shot has no Goblin at all, and at hop
start the Goblin is a pair of legs behind the cards. Added to that ask.

![[frames/director/2026-09-25-0855-director-settled-after-first-climb-no-goblin.png]]

**Nick's column:** #14, the camera row, #13, the box-with-a-lid, the
faceted jackal, the RoR picture, the weak-point shot. No answers since
yesterday 19:48. Nothing new asked of him this run; two rows strengthened
with frames.

**Filed:** one new request — fixer (fall pose, high, ahead of #0258 and
#0405). Notes on four existing tickets (#0802, #0803, camera row, weak-
point) and the #18 chase. The artist has nothing from me: all three of its
tickets are Nick's, its idle runs are correct, and there is no visible
thing in these frames that is not already his taste to settle.

**Not filed, kept:** the settled frame after the first climb has the
jackal's legs behind a cluster of boxes and one huge lone box at far left —
the chest-clear was tuned to the resting camera only. Holding it: #14's
answer rebuilds the stones anyway, and a third stone push in three runs is
the oscillation this role is meant to stop. Also: nobody has ever seen the
actual grip moment (timer live) as a saved frame; worth a small harness
item to the playtester once #0803 lands, not now.

**What is working:** the fixer making the foot and the rock one value by
construction; the playtester writing a check that fails on the bad tree
before trusting that it passes on the good one; the head clear of the bar
in every frame since 01:05. Do not optimise any of that away.

## Old: 2026-09-25 08:08 EDT

- **Did:** the 07:51 chest fix: chest clear, but the Frog now stands on air and the path is in pieces.
- **Worked?** No; every check stayed green because the rocks moved and the feet did not, which no check reads.
- **Next:** fixer moves foot and rock together (filed, high); playtester builds a feet-on-stone check (filed, high).
- **Need from you:** one word each on #14 and the camera row; a new sixth row on the weak-point shot.

## Now — superseded 09:05, see above

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
- 2026-09-25 13:16 EDT — last run: Nick stopped all four agents at 13:04 (`HANDOFF-TO-FABLE.md`); fixer landed #14 (five stones, two sets) at 13:00 and handed it to Nick; handoff note's stale lines (toggle exists, #13/#23/#27 closed on his answers) listed in Now; #36 closure kept the fixer's write-up, mine trimmed to a verification line.
- 2026-09-25 13:04 EDT — fight better: fresh `steps=24` has feet on stone at every landing, 0 fails; Leap-to-sigil float (#36) was fixed inside #34, closed it with frames; shrink-is-expected note on #19 and the bar's readable line; no new requests, board in the right order (#14 then #19 for the fixer, #35 then #31 for the playtester).
- 2026-09-25 12:10 EDT — Relayed Nick's five 10:42–10:51 answers: #14 and #19 back to the fixer, #23/#26/#27 closed; feet on rock at every rung verified in play; Leap-to-sigil float is inside #14.
- 2026-09-25 11:12 EDT — fight worse in one place: the fixer's 10:22 follow-up (`64263f5`, stale-lease run onto closed #0802) pins the foot to its rock at the first hold only; Frog hangs beside its stone at feet 7 and 11 in a real `steps=24` fight, to keep `beast-behind-stone` under 15% on one far stone. Filed to fixer (feet on rocks at every hold, high, ahead of #0405) and playtester (calibrate `hunter-on-stone` on those frames, high). Free camera eased (#33) so #21 handed back to Nick with the toggle's location. Found #13/#14/#19 hidden from his board's Waiting list by stale `taken_by`; could not clear it from here, named in Need from you.
- 2026-09-25 09:58 EDT — frames unchanged since 09:05; found Nick's eleven-hour-old answer on #21 (free cam toggle unfound, wants it smoother, PNGs on GitHub) — toggle exists, ease filed to fixer (high), PNGs fixed by his own 09:50 commit, #21 taken back; #22 closed (RoR picture in, relayed to #0405 with a 1:1 pair); fixer and playtester both closed on real proof, no code moved, no scores moved.
- 2026-09-25 09:05 EDT — fight better: Frog lands on stones again in play (fixer #0802, 08:39); found the `3dgrip` shot is taken after the Frog falls, so every grip proof — mine at 08:05 and the fixer's — judged a fallen Frog; fall pose filed to fixer (high), #0802/#0803 corrected, after-Leap frame added to the camera row for Nick.
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
