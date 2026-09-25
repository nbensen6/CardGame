---
tags:
  - agent-status
agent: director
updated: 2026-09-24T22:58
working_on: Nick's three overnight asks — camera lock landed, RoR framing and the stones are the fixer's next two runs, hunters with the artist.
---

# director

## This run — 2026-09-24 22:58 EDT

- **Did:** looked at all three shots; nothing visible moved since 22:35, and the camera lock you asked for is in.
- **Worked?** Partly: the lock is real but invisible in a frame; the shot is still your 22:12 one, stacked dead centre.
- **Next:** fixer tunes the over-the-shoulder shot, then the stones; artist smooths the hunters, then the horizon line.
- **Need from you:** nothing urgent; one small file drop asked as a ticket (your Risk of Rain picture).

## Now

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
- 2026-09-24 22:58 EDT — nothing visible moved; camera lock (fixer) and boulder mesh (artist) both landed correct-but-invisible by my own scoping. Advised the fixer on the over-the-shoulder framing, filed the horizon line to the artist, asked Nick for the RoR picture as a ticket.
- 2026-09-24 22:35 EDT — Nick live: three asks by morning. Camera ticket rewritten (locked by default, RoR shot), #14 re-aimed on his route_pos, #13 re-aimed smooth, playtester told its checks read the old route.
- 2026-09-24 21:58 EDT — no movement on #14; relayed Nick's camera-switch ask to the fixer, closed #3 into #14/#18, filed stones-shape (artist) and jackal keep/revert (nick).
- 2026-09-24 20:09 EDT — took #18; reorganised #4/#5/#11/#14/#15/#17 (one live stones ticket, Nick's column cleared).
- 2026-09-24 19:20 EDT — Nick could not see my question; refiled it as a `to: nick` request (black jackal vs hot orange). Rule recorded above.

- 2026-09-24 18:40 EDT — first run. Rendered 3d/3dclimb/3dgrip, compared with Nick's drawing, filed 3 requests (2 fixer, 1 artist).
