---
tags:
  - request
from: nick
to: director
status: taken
priority: high
beast: cinder_jackal
eta: gap+stones 3-4 fixer runs, camera after, characters with the artist
created: 2026-09-24T19:40
taken_by: director
issue: 18
synced_comment: 5824190956
---

# Own these three to completion. Chase them every run until I say they are right.

**#18**

## What I want

Three things I keep asking for and keep not getting. **They are yours now** —
not to build (you still build nothing) but to OWN: decide who does what, in
what order, and chase it run after run until I confirm it, not until an agent
says it is done.

1. **The camera.** I want third person, close, hovering near the character.
   Right now it is still free cam. Two reasons, both real:
   - `free_camera_allowed()` returns `is_debug_build`, and I play through
     `tools/dev.cmd`, which IS a debug build. The lock the fixer shipped has
     never once applied to me.
   - The resting shot was then widened to show the whole beast (#11), which
     moved it further from what I asked for on 09-23, not closer. The answer
   is not a wider camera — it is more distance between us and the beast; see
   below.
2. **The stones in front of the boss.** Asked 09-24 11:52. Still beside the
   flank. #4 and #14 both cover it and neither has moved.
3. **The characters.** "#13 done" then I looked at them and they look really
   bad. Reopened.

## The real diagnosis — read the reference again

**Correction, 2026-09-24 19:55 EDT.** An earlier draft of this ticket claimed
Nick's two asks contradicted each other — close third-person on the hunter
versus the whole beast in frame. **That was wrong, and he said so.** Do not
carry it forward.

Look at `art/references/2026-09-24-nick-target-composition.webp` again:

- The frog is **in the foreground, close to the camera, and fairly large**.
  The camera is near him — this IS a close third-person shot.
- The beast is **far away**, small in the frame, whole, looming in the
  background over a wide gap of dark ground.
- The stones **recede into depth** between the two: big and near the frog,
  smaller as they climb away toward the beast. A path in perspective, not a
  vertical line beside a body.

So both asks are satisfied at once, and the reason we cannot do it is neither
the camera nor a conflict:

> **There is not enough space between the hunters and the beast.**

They stand between its paws, about ten units out. At that range any camera
close enough to be third-person on a hunter has the beast filling and
overflowing the frame — so the fixer widened the shot to fit the beast and
lost the close hunter. Move the hunters properly back, and a close
over-the-shoulder camera frames the whole beast on its own, with the stones
climbing away into the gap. The distance is the fix; the camera follows it.

**So the order of work is:**

1. Open the gap — hunters well back from the beast, a real stretch of ground
   between them.
2. Lay the stones across that gap, receding toward the beast.
3. Then bring the camera back in close behind the active hunter, which now
   works because there is somewhere for it to stand.

Do not "resolve a contradiction" — there isn't one. Do not widen the camera
further to compensate for the gap being too small.

## Authority

- You may set `priority:` on anyone's ticket and say the order they are done in.
- You may tell an agent to stop what it is doing and take something else.
- You may close a ticket as `wontfix` if it is superseded — say where it went.
- You still build nothing, and you still never decide my taste for me.

## Done when

I look at the fight and say the camera, the stones and the characters are
right. Not before.

## Nick's answer

**From GitHub #18 (nbensen6, 2026-09-24 23:48 UTC):**

Director, have an agent create a dev mode vs player mode option so i can see the camera angle the player will see. I would like to be able to toggle this in the setting so i can see how the camera looks when playing in a non dev environment.


## Result — director, 2026-09-24 20:08 EDT (in progress)

**Taken.** Reorganised the tickets first so there is one live ticket per
outcome and nothing sits under Nick that he has already answered:

| outcome | live ticket | who | state |
|---|---|---|---|
| 1. the gap, 2. the stones | **#14** (rewritten: gap first, then stones across it, top hold standing) | fixer | open, high |
| 3. the camera | filed by the director after #14 lands — not before, per your order | fixer | not yet |
| the characters | **#13** (reopened by you) | artist | open, high; goes back to you with a 1:1 frame |

Closed into the above: #4 (stone-route saga, into #14), #5 (answered 11:47,
into #14's Done-when), #11 (wide camera, superseded by this ticket), #15
(my yaw request, withdrawn), #17 (answered: keep the jackal black).

Nothing is required of Nick until #14's after-frame is posted here.

## Result — director, 2026-09-24 21:58 EDT (in progress)

**Your 19:48 answer (Dev / Player camera switch) is relayed** to the fixer as
`2026-09-24-2155-director-to-fixer-player-camera-toggle-so-nick-can-see-what-a-player-sees.md`,
high, sequenced right after the #14 pass the fixer is on now. It exists so
you can judge step 3 (the close camera) when it lands; nobody builds step 3
before it.

Movement since 20:08: **none on the gap or the stones.** The fixer's 20:19
run pushed nothing at all (no commit, no note); its 21:20 run claimed #14 at
21:33 and is live as I write. #3 (your 09-23 ticket, same three things)
closed into here so there is one row per outcome. #13 unchanged, blocked on
#14 by the artist's own correct call.

## Result — director, 2026-09-24 22:33 EDT (in progress)

**Nick, live at 22:25, and his own commit at 22:12.** He opened the gap,
laid a straight route and put the ground camera 9 units behind the hunter
himself; then said, in chat: smooth character models with clean outlines,
stones in a pattern left to right to the head, camera locked third person
(and "I still cannot find the toggle" — it was never built). At 22:30 he
sent a Risk of Rain 2 frame as the camera target. All three are due before
he wakes.

| ask | ticket | who | order tonight |
|---|---|---|---|
| camera locked third-person, Risk of Rain shot, free cam opt-in | 21:55 ticket, rewritten | fixer | first, 1 run |
| stones left → right → head, on his `route_pos()` | #14 | fixer | second, 2-3 runs |
| smooth hunters, clean outline | #13 | artist | now, 1-2 runs |
| checks read the old route / old camera | 22:33 ticket | playtester | now, so the fixer's playtests are honest |

The toggle he asked for at 19:48 is folded into the camera ticket with the
default flipped: locked is what everyone gets; Dev is the opt-in.

## Result — director, 2026-09-24 22:58 EDT (in progress)

**Your 19:48 answer is built.** The fixer shipped the Camera: Player / Dev
button in the Menu at 22:30, and — per your 22:25 word — Player is the
default in every build, your debug build included. Open the fight through
`tools/dev.cmd` and do nothing: the camera is locked behind the Frog. Menu →
Camera: Dev gives the free camera back, and it remembers.

Movement on the three since 22:33:

| ask | state at 22:58 |
|---|---|
| camera locked third-person | **done** (the lock); the Risk of Rain framing is the fixer's next run — tonight's shot is your own 22:12 one, stacked on the centre line |
| stones left → right → head | no movement; #14 is the fixer's run after the framing |
| smooth hunters, clean outline | artist is on #13 now, after building the boulder mesh you will see once the fixer wires it |

What you see tonight beside your drawing, 1:1 — the order is right, the
diagonal is not yet:

![[frames/director/2026-09-24-2250-director-resting-vs-reference.png]]

Nothing needed from you except the small file drop asked separately (your
Risk of Rain 2 picture into the references folder).

## Result — director, 2026-09-25 00:04 EDT (in progress)

Movement on the three since 22:58 — the first visible step tonight:

| ask | state at 00:04 |
|---|---|
| camera locked third-person, Risk of Rain shot | **shot landed 23:46** — Frog a quarter of the frame, bottom-left, path diagonal; with you on the camera ticket to say if it is the one. One new fault it caused (the beast's face sits behind the Attack tag) is filed to the fixer and rides the stones run. |
| stones left → right → head | no movement; the fixer's next run, sequenced on #14 (head clearance → stones using the artist's rock → the 20 m-hop teleport clears with it) |
| smooth hunters, clean outline | artist told #13 is unblocked now the Frog renders big; Frog first, back to you with a frame |

Beside your drawing at 1:1 tonight:

![[frames/director/2026-09-24-2355-director-resting-vs-reference.png]]

## Result — director, 2026-09-25 02:58 EDT (in progress)

Movement on the three since 02:05 — the resting shot now has the whole beast:

| ask | state at 02:58 |
|---|---|
| camera locked third-person, Risk of Rain shot | landed 23:46; still with you on the camera ticket to say if it is the one |
| stones left → right → head | **near stone off the beast, 02:49** — whole beast in frame for the first time tonight; the 20 m hops (the last item) are the fixer's next run; one question to you on the stone's shape, filed separately |
| smooth hunters, clean outline | both hunters done by the artist at 01:36; #13 is with you to say yes or no |

Beside your drawing at 1:1 tonight:

![[frames/director/2026-09-25-0253-director-resting-vs-reference.png]]

## Result — director, 2026-09-25 05:57 EDT (in progress)

Movement on the three since 02:58 — nothing you can see yet; the resting,
sigil and grip shots are the 05:00 ones to the pixel:

| ask | state at 05:57 |
|---|---|
| camera locked third-person, Risk of Rain shot | landed 23:46; the lens-vs-gap question is with you on the camera ticket. The fixer is now on the camera losing the Frog for a whole Leap (its own finding, filed 04:20, raised to high) |
| stones left → right → head | the long hops are split into short ones (fixer, 04:20) but the Frog lands on air between the near box and the chest — stones under those landings are the next fixer item after the camera. The small "stone on the chest" is not on the body at all: it floats most of the way across the gap and only lines up from the resting camera (playtester's measurement, 05:31). From the front it reads as a bag the beast carries. Your stones-on-the-limbs placement needs the gap answer first |
| smooth hunters, clean outline | both hunters done 01:36; #13 is with you to say yes or no |

Beside your drawing at 1:1 (unchanged since 02:53):

![[frames/director/2026-09-25-0253-director-resting-vs-reference.png]]

## Result — director, 2026-09-25 07:58 EDT (in progress)

**One visible move on the three since 07:02, and it went backwards.** The
chest-stone fix (#0658) landed 07:51: chest clear, Frog on air, path in
pieces — re-filed to the fixer, high;
the artist built nothing because all three of its tickets sit with you; the
playtester rebuilt a check (honest, test-backed, invisible on screen by
nature).

| ask | state at 07:58 |
|---|---|
| camera locked third-person, Risk of Rain shot | with you: gap vs lens (the camera row). New this run: the weak-point shot asked separately — mostly sky, Goblin gone |
| stones left → right → head | landed 06:16; with you on #14 (twenty stones or four). 07:51: the chest was cleared by moving rocks, not feet — the Frog now stands on air at the first hold and the path is in pieces; fixer re-filed, high, 08:02 |
| smooth hunters, clean outline | with you on #13 since 17:20 yesterday |

Beside your drawing this morning, 1:1 — unchanged from 06:55:

![[frames/director/2026-09-25-0753-director-resting.png]]

Nothing is required of you beyond the rows already on your board; one word
on #14 and one on the camera row unblocks the fixer's next two runs.

## Result — director, 2026-09-25 09:05 EDT (in progress)

**One visible move on the three since 07:58, and it went forwards.** The
fixer's 08:39 push (#0802) puts the Frog back on a drawn stone at every play
landing and reconnects the staircase from the resting camera. The frame
everyone had been using to judge it — the "grip" shot — turns out to be
taken after the Frog falls off its hold, so it still shows a Frog on air;
that fall pose is filed to the fixer (high) and the wrong proof corrected on
#0802 and #0803. Nothing else reached the game; the artist is idle on your
three rows, the playtester landed two check rebuilds (invisible by nature).

| ask | state at 09:05 |
|---|---|
| camera locked third-person, Risk of Rain shot | with you: gap vs lens (the camera row). New this run: the after-Leap frame is the closest the game has come to your drawing — added to that row with a yes/no |
| stones left → right → head | landed 06:16; with you on #14 (twenty stones or four). 08:39: the Frog lands on the stones again in play; the fall pose is the one thing still on air |
| smooth hunters, clean outline | with you on #13 since 17:20 yesterday |

Beside your drawing this morning — the after-Leap shot, the nearest yet:

![[frames/director/2026-09-25-0855-director-after-leap-closest-to-drawing.png]]

One word on #14 and one on the camera row still unblocks the fixer's next
two runs; nothing else is needed from you.

