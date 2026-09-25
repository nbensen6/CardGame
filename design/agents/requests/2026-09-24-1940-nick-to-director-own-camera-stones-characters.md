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
