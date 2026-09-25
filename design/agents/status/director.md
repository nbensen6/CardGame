---
tags:
  - agent-status
agent: director
updated: 2026-09-25T01:57
working_on: Both hunters read now; #14 (stones) is live with the fixer and is the only blocker; asked the playtester to measure the hidden beast.
---

# director

## This run — 2026-09-25 01:57 EDT

- **Did:** the fight is better again — the Goblin reads beside the Frog; only the stones stand in the way.
- **Worked?** Yes; both hunters now look like one family, and the fixer is rewriting the stones as I write.
- **Next:** fixer lands the stones (#14); artist clears the red horizon line; playtester measures how much beast is hidden.
- **Need from you:** answer #13 — one line settles both hunters; the Jackal is its own row.

## Now

**What a player sees, before I read anyone's note.** Resting shot: a big
smooth green Frog bottom-left, and now, on the right, a small smooth green
Goblin with a blue tank on its back, red shorts, goggles and a gold crown —
a character, not a blue-and-orange crystal. For the first time the two
hunters look like they came from the same game. Between them, still, the
pale pot with the orange lid sitting exactly over the beast's chest and
forelegs; the second pot with the gold ring at its throat; the black
faceted jackal's head, ears and eyes clear above, "Attack 7" hung beside
the crown. The hard red line still runs full width at the beast's ankles,
through the Frog's marker and the Goblin's shins. Climb shot: unchanged —
sky, a black lump bottom-left, the Frog tiny on a pot, "Attack 7" over
nothing. Grip shot: unchanged — the Frog half behind a "3", only the
beast's legs in frame.

![[frames/director/2026-09-25-0152-director-resting-shot.png]]
![[frames/director/2026-09-25-0152-director-at-the-sigil.png]]
![[frames/director/2026-09-25-0152-director-grip.png]]

**Against the drawing**, 1:1 beside it:

![[frames/director/2026-09-25-0152-director-resting-vs-reference.png]]

| his drawing | the frame now | verdict |
|---|---|---|
| whole beast, upper-middle, sky above its ears | head whole with sky above, torso behind the near pot | **half — torso is #14, live now** |
| frog large, bottom-left, camera near it | quarter of the frame, bottom-left | yes |
| the frog is a smooth cartoon frog | a smooth cartoon frog | yes (#13, 00:16) |
| (no goblin in the drawing) | a smooth cartoon goblin, same treatment | **yes — artist, #13, 01:36** |
| stones recede from frog to beast | big near, small far | order yes; still pots, rock waits on #14 |
| path runs diagonally, left to right | diagonal | yes |
| broad hot glow at the horizon | a 3 px red line | no — #19, artist, now unblocked |
| cool sky, dark ground, pale stones | yes | yes |
| beast black | black | settled (#17) |

**Did the fight get better for Nick, or did three scores go up?** Better.
One visible commit since 01:00 (the artist's Goblin) and it is the right
one: judged at the real fight camera beside the Frog, at 1:1, no rubric
score attached, no Meshy spend, handed back `to: nick` with `ask:` filled
instead of closed. The playtester's commit (a hit-circle check) is
invisible to a player and honest about it — it had no request and no
regression, and it did not invent one. The fixer claimed its lease at
01:20 and has pushed nothing yet, which on #14 is the right shape: its
own 01:05 note says the stones are "a real rewrite, not a numbers
tweak", and a rewrite that lands in one push beats three partial ones.
**The single thing standing in the way is still #14.** Torso behind the
pot, the climb shot, the "3" over the Frog, the 20 m hops — one cause.

**My miss, at the top as the brief says:** none found. My held-back item
from 01:00 (the 62-vs-124 `hop-distance-band` count) is not a discrepancy:
the 20 m ticket itself says 124 on `steps=80`; 62 was a shorter run.
Dropped.

**Audit of what closed since 01:00.** Nothing changed status. **Stuck
audit:** the 23:56 head ticket is `taken` with a finished Result — its
Done-when is a measurement, not Nick's taste, and it rides #14's handback
by its own wording; not limbo, but the fixer should close it when the
stones land. #14 `taken`, 300 lines of investigation, live. #19 `open` to
the artist, was queued behind #13 — #13 is now Nick's, so I have marked
#19 unblocked and raised it to high. The rock handoff and the 20 m ticket
`open` to the fixer, queued inside #14. **Nick's column:** four rows, every
one with `ask:` filled — #13 (now covers both hunters), the camera shot,
keep-or-revert the Jackal, the Risk of Rain picture. No new answers since
23:48; he is asleep. **Judgement calls sitting elsewhere:** none. The
artist's `Need from you` line ("does the Goblin also read as smooth") is a
restatement of #13's `ask:`, not a stray question.

**Filed (three):**

1. `to: playtester` (new) — the beast's torso is behind a stone in the
   resting shot and nothing in the baseline fires on it; build one check
   that measures how much of the beast is covered by footholds, fail on the
   current tree, report a percentage. NOT: move a stone, touch the camera,
   pick a threshold the current frame passes. Filed now so it exists
   before #14 lands, not after.
2. `to: artist`, on #19 — unblocked, next, priority high; do not wait for
   Nick's answer on #13. NOT: touch the Frog, the Goblin or the Jackal; do
   not restyle the stones.
3. Nothing to the fixer, on purpose: it is live on #14 and a ticket filed
   now reaches its next run, where #14's own sequencing note already says
   everything I would say. The one line I would add is below.

**Held back (watch next run):**

- Fixer: when the stones land, do not tilt or pull the camera to get the
  torso out from behind a stone — move the stone. And re-render `state=3d`
  for the head: a narrower gap makes the beast bigger and the tag fix has
  to hold at the new size (its own note already says this).
- Fixer: if #14 lands and the resting shot still has a pot on the chest,
  that is not done, whatever `hop-distance-band` reads.
- The Goblin's greens are a shade duller than the Frog's (the artist
  measured it: 0.61/0.45 against 0.67/0.70). At 1:1 it reads fine and the
  two look like a pair. Not a ticket; if Nick says "make them match" it is
  one number.
- The Frog is still the most saturated thing in the frame. Taste; Nick's.

**What is working, so nobody optimises it away:** the artist fetching a
result it had already paid for instead of generating again, measuring the
colour gap before deciding it needed a boost, judging beside the Frog in
the real fight, and handing #13 back with the `ask:` widened to both
hunters so Nick answers once. The playtester running the full baseline
before adding anything, and proving its new check fires when the code is
broken on purpose. The fixer not starting the rewrite with a spent budget.
Keep all of it.

## Old: 2026-09-25 01:00 EDT

- **Did:** the fight is better again — the Frog reads as a frog, and the beast's whole head is now clear of the HUD.
- **Worked?** Yes, but the frame now mixes two looks: smooth Frog beside faceted Goblin and Jackal; your call.
- **Next:** fixer lays the stones (#14, now the only blocker); artist does the Goblin; nothing else in the way.
- **Need from you:** answer #13 — one line settles the Frog, the Goblin and the cast's look together.

### Now, as of 01:00 EDT

**What a player sees, before I read anyone's note.** Resting shot: a big
smooth cartoon Frog bottom-left, a quarter of the frame, bright green,
facing right at the beast — the first time this fight has had a hunter you
would recognise from across a room. The Goblin small on the right, still a
faceted blue-and-orange crystal thing. Between them the pale pot with the
orange lid, the beast's torso hidden behind it; the second pot with the gold
ring at its chest. The black jackal at the top, its whole head — ears, eyes, muzzle —
clear under the boss bar with a strip of sky, the "Attack 7" tag hung
beside its crown (the fixer's 00:52 commit, which landed while I was
rendering; the first frame I judged still had the head behind the tag). The hard red line still runs full
width at the beast's ankles. Climb shot: unchanged — sky, a black lump
bottom-left, the Frog tiny on a pot, "Attack 7" over nothing. Grip shot:
unchanged — the Frog half behind a "3", only the beast's legs in frame.

![[frames/director/2026-09-25-0055-director-resting-shot.png]]
![[frames/director/2026-09-25-0055-director-at-the-sigil.png]]
![[frames/director/2026-09-25-0055-director-grip.png]]

**Against the drawing**, 1:1 beside it:

![[frames/director/2026-09-25-0055-director-resting-vs-reference.png]]

| his drawing | the frame now | verdict |
|---|---|---|
| whole beast, upper-middle, sky above its ears | head whole with sky above, torso behind the near pot | **half — head yes (fixer, 00:52); torso is #14** |
| frog large, bottom-left, camera near it | quarter of the frame, bottom-left | yes |
| the frog is a smooth cartoon frog | a smooth cartoon frog | **yes — artist, #13, 00:16** |
| stones recede from frog to beast | big near, small far | yes in order; still pots, rock waits on #14 |
| path runs diagonally, left to right | diagonal | yes |
| broad hot glow at the horizon | a 3 px red line | no — artist ticket open, queued after the Goblin |
| cool sky, dark ground, pale stones | yes | yes |
| beast black | black | settled (#17) |

**Did the fight get better for Nick, or did three scores go up?** Better,
and no score went up at all: two commits since 00:03 (the artist's Frog,
the fixer's head), two visible changes, both judged at 1:1 in the real
fight. The artist handed #13 back `to: nick` with `ask:` filled and left
the Goblin alone on purpose; the fixer tried the camera numbers first as
asked, proved with a table that they fail the Goblin's position, took the
fallback I named, and left the ticket riding #14 as told. That is the
process working exactly as written. The one new thing a player sees that
nobody has put in front of Nick: **the cast now has two looks in one
frame.** At 16:30 he picked style C (low-poly, flat facets) for the whole
cast; at 22:25 he asked for smooth characters. Both cannot hold. His own
drawing has a smooth frog and a faceted rock beast, so I have named the
contradiction on #13 with the frame above, three options, and a
recommendation (smooth hunters, faceted beast), so his one-line answer
settles the Frog, the Goblin and the bar's style line together. **The
single thing still standing in the way is #14** — the torso behind the pot,
the small beast, the unreadable climb shot and the 20 m hops are all the
same missing stones. The head step landed at 00:52; the fixer's own next line is "#14
itself, a real rewrite, not started this run". Every excuse for not
laying stones is now discharged: camera in, head clear, the artist's rock
asset waiting in a handoff ticket. If the next director run finds no stones
started, that is the first line of that note.

**My miss, at the top as the brief says:** none found this run. The first
frame I rendered had no beast in it at all (an empty sand disc) — a load
race straight after `--import`, gone on the re-render; noting it so the
next agent who sees a blank arena re-renders before filing anything.

**Audit of what closed since 00:03.** Nothing changed status. **Stuck
audit:** #14 `taken` (fixer) with 115 lines of Result — investigation notes,
not a finished claim, checked; the horizon ticket `open` to the artist with
my re-file in its Result — correctly queued; the artist's rock handoff and
the playtester's 20 m ticket `open` to the fixer with empty Results —
queued inside #14. Nothing in limbo. **Nick's column:** four rows, every one
with `ask:` filled — #13 (Frog, the one that matters tonight), the camera
shot, keep-or-revert the Jackal's geometry, the Risk of Rain picture. No
new answers from him since #17 (23:26); he is asleep. **Judgement calls
sitting elsewhere:** the style-C contradiction above was the only one, and
it was in nobody's note — it was in the frame.

**Filed (two, on one ticket — the third slot deliberately unused):**

1. `to: nick`, on #13 — the smooth-vs-faceted contradiction, the frame,
   three options, recommendation. Not a new ticket: his answer to the
   artist's `ask:` already decides it, he just needs to know that it does.
2. `to: artist`, on #13 — the Frog is right, do NOT touch it again; Goblin
   next, judged beside the Frog in one frame; re-state the tri-budget line
   in the bar honestly (5,200 tris, 37 KB → 2.1 MB) and do NOT decimate to
   get back under it; do not touch the Jackal.

Nothing to the fixer or the playtester: the fixer's head fix is right and
its next pick (#14) is already the right one, and the playtester was live
as I wrote. What I would have said is below.

**Held back (not filed, watch next run):**

- Fixer: with the head clear, the torso is still behind the near pot at
  1:1. That is the stones' job (#14), not another camera pass — do not tilt
  the camera to dodge a stone.
- Playtester: the artist's fresh baseline counted 124 `hop-distance-band`
  fails where your 23:44 note said 62. Same main, same route — if the
  re-pointed check now fires twice per hop, the count on the 20 m ticket is
  wrong by half. Invisible to a player; one line to check.
- The "3" over the Frog in the grip shot; the climb shot; the pot at the
  beast's chest — all #14.
- The Frog is now the most saturated thing in the frame, brighter than the
  beast's embers. Nick's drawing has a duller green. Taste; his to raise,
  not mine.

**What is working, so nobody optimises it away:** the artist reverting to a
file already in the tree instead of rebuilding (zero Meshy spend, one run),
judging at the real fight camera at 1:1 with the Goblin in the same frame,
and handing back `to: nick` with `ask:` filled instead of closing — the
first time #13 has been handed back correctly. The fixer measuring the camera
levers in a table before rejecting them, then fixing the tag and not the
camera, with the climb cameras proven byte-identical. Keep all of it.

## Old: 2026-09-25 00:03 EDT

- **Did:** the fight is better for the first time tonight, but the beast's face now hides behind the Attack tag.
- **Worked?** Yes — Frog big and bottom-left, path diagonal, like your drawing; the hidden head is the one new fault.
- **Next:** fixer clears the head then lays the stones; artist smooths the Frog now the camera shows it big.
- **Need from you:** look at the camera shot on your board and say whether it is the one you meant.

### Now, as of 00:03 EDT

**My miss, at the top as the brief says:** the horizon-line ticket I filed
at 22:57 named the wrong cause (the sky curve). The artist proved it is the
arena wall seen edge-on and handed it back; I have re-filed it with the
right levers, behind the Frog. Also: the fixer's own frame of the new shot
was posted at 23:44 with the face already behind the tag, and it measured
the beast's height without saying which part was missing — that is the
"score up, frame not checked" pattern, caught here rather than by the fixer.

**What a player sees, before I read anyone's note.** Resting shot: a big
low-poly Frog bottom-left, a quarter of the frame, in profile facing right;
the Goblin small on the right; a pale boulder with a flat orange lid mid
frame and a smaller one with a gold ring further back; the black jackal at
the top with its eyes just under the "Attack 7" tag and its skull behind
the boss bar. A hard red line still runs full width at the beast's ankles.
The path from Frog to beast is a real diagonal now. Climb shot: unchanged —
sky, a black lump bottom-left, the Frog tiny on a pot, "Attack 7" over
nothing, Goblin off frame. Grip shot: the Frog still hidden behind a "3"
four Frogs tall; only the beast's legs in frame.

![[frames/director/2026-09-24-2355-director-resting-shot.png]]
![[frames/director/2026-09-24-2355-director-at-the-sigil.png]]
![[frames/director/2026-09-24-2355-director-grip.png]]

**Against the drawing**, 1:1 beside it:

![[frames/director/2026-09-24-2355-director-resting-vs-reference.png]]

| his drawing | the frame now | verdict |
|---|---|---|
| whole beast, upper-middle, sky above its ears | top third, head behind tag and bar | **no — new ticket to fixer, rides #14** |
| frog large, bottom-left, camera near it | ~200 px, bottom-left, camera over its shoulder | **yes — fixer, 23:46** |
| stones recede from frog to beast | big near, small far | yes (still the pots; artist's rock waits on #14) |
| path runs diagonally, left to right | diagonal | **yes — fixer, 23:46** |
| broad hot glow at the horizon | a 3 px red line | no — re-filed to artist with the right cause |
| cool sky, dark ground, pale stones | yes | yes |
| beast black | black | settled (#17) |

**Did the fight get better for Nick, or did three scores go up?** Better,
for the first time tonight — two rows of the table flipped to yes on one
fixer commit, and they are the two Nick drew the picture for. The cost is
one new visible fault (the head) that the fixer's own measurements did not
see because they measured height, not which part of the beast was showing.
**The single thing standing in the way now is #14**: the stones across the
gap. It fixes the beast being small (the gap), the climb shot (the route
decides where that camera stands), and the playtester's new 20 m-hop
teleport (four even legs because nothing sits between the ground and rung
1) — three symptoms, one ticket, and it has sat `taken` since 20:08 with
nothing shipped. That was by Nick's own order (camera first) and the order
is now discharged, so the next fixer run with no stones is the first line
of my next note.

**Audit of what closed since 22:58.** Only the playtester's checks ticket
(22:33, mine): Done-when measurable (three checks re-pointed at the live
route, 0 false fires, fires again on a revert) — legitimate. It surfaced the
20 m-hop finding as a by-product, which is the discipline working. Nothing
closed that was Nick's to close. **Stuck audit:** the camera ticket is
correctly `to: nick`, `open`, `ask:` filled, frame at 1:1 — not stuck. The
artist's rock handoff (22:26) is open to the fixer with an empty Result —
queued, now sequenced inside #14. #13 is `taken` by the artist and marked
blocked on the camera; the camera is in, so I have told the artist it is
unblocked and what the Frog looks like at a quarter of the frame (thorny).
**Judgement calls sitting elsewhere:** the playtester's ticket offers the
fixer a choice (widen the hop band, or add stones) that Nick already made
at 22:25 — relayed on the ticket so the fixer does not pick the wrong one.
#18's 19:48 GitHub comment is the toggle ask, already built; nothing new
from Nick since #17.

**Filed (one new, three notes, one re-route — three things, three agents):**

1. `2026-09-24-2356-director-to-fixer-the-beasts-face-is-behind-the-attack-tag.md`
   (high): tilt/eye-height numbers first, tag placement second, done as the
   first step of the #14 run because the gap change moves the head again.
   Not: widen, move stones, touch the climb camera.
2. #13 note to the artist: unblocked, Frog first, judge in `state=3d` at
   1:1, hand back to Nick. Not: Meshy, rebuild, touch the jackal.
3. #19 re-routed to the artist after #13 with the door opened: Wall material
   filtering (scoped) or Wall base geometry. Not: the camera, the shared
   shader default.

Plus sequencing on my own #14 (head → stones with the artist's rock → the
20 m hop clears itself; do not widen `hop_arc()`), and the same one-liner
on the playtester's 20 m ticket.

**What is working, so nobody optimises it away:** the fixer's pixel-exact
before/after and "climb camera provably untouched"; the artist's
elimination proof on the horizon line (it was right and I was wrong); the
playtester finding a real teleport the moment its checks read the live
route. Keep all three.

**Leftovers I did not file (three is the limit):** the "3" in `3dgrip` is
still four Frogs tall and on top of the Frog; the climb shot stays
unreadable until #14; the pot with the gold ring at the beast's chest is
the second foothold and will go with the rock swap.

## Old: 2026-09-24 22:58 EDT

- **Did:** looked at all three shots; nothing visible moved since 22:35, and the camera lock you asked for is in.
- **Worked?** Partly: the lock is real but invisible in a frame; the shot is still your 22:12 one, stacked dead centre.
- **Next:** fixer tunes the over-the-shoulder shot, then the stones; artist smooths the hunters, then the horizon line.
- **Need from you:** nothing urgent; one small file drop asked as a ticket (your Risk of Rain picture).

**What a player sees, before I read anyone's note.** Resting shot: a black
jackal with ember panels, whole, centre-top, about a third of the frame; a
big pale stone with an orange cap in front of it, a smaller one above, both
on the same vertical line as the beast; the Frog and Goblin at the bottom
centre, under the intent tag, about a ninth of the frame tall; a hard red
line the full width of the frame at the beast's ankles. Sigil close-up:
mostly purple sky, a black lump bottom-left, the Frog on a stone at
centre-left, "Attack 7" hanging over nothing — unreadable, unchanged for
three runs. Grip shot: the Frog fully hidden behind a "3" the size of four
Frogs; only the beast's legs in frame, the same red line behind them.

![[frames/director/2026-09-24-2250-director-resting-shot.png]]
![[frames/director/2026-09-24-2250-director-at-the-sigil.png]]
![[frames/director/2026-09-24-2250-director-grip.png]]

**Against the drawing**, 1:1 beside it:

![[frames/director/2026-09-24-2250-director-resting-vs-reference.png]]

| his drawing | the frame now | verdict |
|---|---|---|
| whole beast, upper-middle, about half the frame | whole, 38% | yes |
| frog large, bottom-left, camera near it | ~85 px, bottom-centre | half — right size class, wrong place |
| stones recede from frog to beast | big near, small far, in order | **yes — Nick's 22:12 commit** |
| path runs diagonally, left to right | everything on one vertical line | **no** — the framing pass (camera ticket), then #14 |
| broad hot glow at the horizon | a 3 px red line | **no** — new ticket to artist |
| cool sky, dark ground, pale stones | yes | yes |
| beast black | black | settled (#17) |

**Did the fight get better for Nick, or did three scores go up?** Neither,
in fifteen minutes: nothing visible moved. Two correct-but-invisible pieces
landed, and both were scoped that way on purpose by me, so they are not the
failure pattern — the fixer's camera lock (a frame cannot show "drag does
nothing"; the proof is real synthesised drags, which is the right proof) and
the artist's boulder mesh (asset only, handoff to the fixer filed, because
two hands in `_build_float_stones` on the same night is how a run gets
spent on a merge). What Nick sees is still exactly his own 22:12 commit.
**The single thing standing in the way is the framing pass**: his commit
put the order right and the camera behind the hunter, and the next fixer
run has to move that camera over one shoulder so the depth he drew reads as
a diagonal instead of a stack. Advised on the camera ticket with the numbers
(Frog a ninth, beast 38%, both want "closer", and "do not widen").

**My miss, at the top as the brief says:** the red horizon line has been in
every frame I have posted since 21:54 and I named it tonight for the first
time. Filed to the artist, after #13.

**Audit of what closed since 22:35.** The stones-as-pots ticket, closed by
the artist at 22:26: its Done-when was mine and measurable (a mesh at
budget, rendered in the fight via a local swap, reads as rock, a handoff
request filed) — all four met, the before/after is 1:1 and honest, and it
reads as rock. Legitimate close; Nick sees pots until the fixer wires it,
and that is the open handoff, queued behind #14 by the artist's own correct
call. Nothing else closed. **Stuck audit:** the camera ticket's Result says
"handing it back" while the frontmatter still says `to: fixer`, `taken` —
but its `eta:` says the framing is next run and the ticket's last Done-when
is the shot, not the lock, so it is correctly still the fixer's; told it so.
#13 correctly held by the artist. Keep-or-revert jackal (mine, to Nick):
no answer yet, not urgent.

**Filed (three, the limit):**

1. `to: fixer` — a director section on the live camera ticket: over one
   shoulder, pivot on the active hunter, closer and lower; do NOT widen, do
   NOT move stones, do NOT touch the climb camera yet.
2. `to: artist`, after #13 — the 3 px red horizon; widen the sky band into
   the glow his drawing has; do NOT change the colours or add geometry.
3. `to: nick` — drop the Risk of Rain 2 picture into the references folder.
   (My 22:35 note asked this in `Need from you`, which COMMON 1a says he
   never sees. Corrected.)

**Held back (not filed, watch next run):**

- The sigil close-up is unreadable and has been for three runs. It is held
  on purpose: #14 moves the route, and the route decides where that camera
  stands. The run after #14 lands, it is the first thing I file.
- The "3" popup covers the Frog entirely in the grip shot. A harness moment
  (popup and leap at the same instant); in play it fades. Watch, do not file.
- The playtester is live on my checks ticket as I write; judge next run.
- The artist's 22:30 note says Nick asked live to redo the hunters' look.
  #13 is `taken` by the artist and hands back to Nick; nothing for me to
  move — but the artist must not pick the look for him. If a frame comes
  back with one style chosen, it goes to Nick with options.

**What is working, so nobody optimises it away:** Nick's own 22:12 commit
is the first frame in which the stones are in FRONT of the beast in the
order he drew; the fixer proving the camera lock with real drags rather than
the gate test; the artist verifying the boulder in the actual fight and
then reverting rather than committing into the fixer's function; the
playtester breaking code on purpose to prove a check fires. Keep all of it.
The palette is right, the beast's silhouette reads, the stone shape is now
right and only waits on wiring.

## Old: 2026-09-24 22:35 EDT (live, on your message)

- **Did:** re-aimed all three agents at your three asks for tonight; the camera toggle was never built, so you did not miss it.
- **Worked?** Your 22:12 commit is the biggest visible step yet: close camera, real-size hunters, a gap.
- **Next:** fixer locks the Risk of Rain camera then sweeps the stones left to right; artist smooths the hunters; playtester fixes stale checks.
- **Need from you:** drop the Risk of Rain frame into design/art/references so the fixer can render beside it.

## Old: 2026-09-24 21:58 EDT

- **Did:** looked at all three shots again; the stones have bulk now, nothing else you asked for has moved.
- **Worked?** Partly: the stones are solid but read as clay pots, and the hunters are still specks at the paws.
- **Next:** your camera-switch ask is with the fixer; then #14, re-aimed after two dead ends it proved tonight.
- **Need from you:** one word on the re-cut jackal (keep or revert); nothing else.

### Now, as of 22:35 EDT

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
and landed at 21:49 as I wrote this: two investigations, both reverted,
nothing shipped, and a question to me — its "do not touch the camera" bullet
and its "gap visible in state=3d" Done-when cannot both hold, because the
wide camera locks to the hunter and translates with it. **Answered on #14:**
the gap is a number, proven in a harness-only camera state, and its
visibility arrives with step 3; and my own "toward the head" bullet sent it
into the on-body route, so that is reworded — the approach across the gap is
open-air and parametric, the rungs stay. That misdirection is on me; the
fixer's proof was exactly right. **That stall is the single thing standing
in the way.**

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
- 2026-09-25 01:57 EDT — fight better again (Goblin reads, matches the Frog; artist handed #13 back to Nick correctly); no scores moved; fixer live on #14 with nothing pushed yet; filed the beast-occlusion check to the playtester, unblocked #19 for the artist; nothing to the fixer on purpose.
- 2026-09-25 01:00 EDT — fight better again (Frog reads and matches the drawing; beast's head clear of the HUD, fixer 00:52); no scores moved; named the style-C vs smooth contradiction for Nick on #13 with options; artist sequenced (Goblin next, do not touch the Frog, do not decimate); #14 now the only blocker.
- 2026-09-25 00:03 EDT — fight visibly better (close shot landed: Frog quarter-frame, diagonal); beast head behind the HUD filed to fixer; #13 told it is unblocked; #19 re-routed to artist with the artist's correct cause; #14 sequenced (head → stones → 20 m hop).
- 2026-09-24 22:58 EDT — nothing visible moved; camera lock (fixer) and boulder mesh (artist) both landed correct-but-invisible by my own scoping. Advised the fixer on the over-the-shoulder framing, filed the horizon line to the artist, asked Nick for the RoR picture as a ticket.
- 2026-09-24 22:35 EDT — Nick live: three asks by morning. Camera ticket rewritten (locked by default, RoR shot), #14 re-aimed on his route_pos, #13 re-aimed smooth, playtester told its checks read the old route.
- 2026-09-24 21:58 EDT — no movement on #14; relayed Nick's camera-switch ask to the fixer, closed #3 into #14/#18, filed stones-shape (artist) and jackal keep/revert (nick).
- 2026-09-24 20:09 EDT — took #18; reorganised #4/#5/#11/#14/#15/#17 (one live stones ticket, Nick's column cleared).
- 2026-09-24 19:20 EDT — Nick could not see my question; refiled it as a `to: nick` request (black jackal vs hot orange). Rule recorded above.

- 2026-09-24 18:40 EDT — first run. Rendered 3d/3dclimb/3dgrip, compared with Nick's drawing, filed 3 requests (2 fixer, 1 artist).
