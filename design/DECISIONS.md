# Decisions

Why things are the way they are. Code shows what changed, never why. Newest
first. A decision here outranks any older instruction in a brief or a note.

## 2026-10-12 — the goal is the fight playing well, not the picture

TARGET.png is reached. It stops being the thing we build toward. The new
target is [[PLAYABLE-MINUTE]] — ten checks you watch happen, judged by playing,
not by a side-by-side. Five of the ten are Nick's to judge; no agent marks
those passed, for the same reason an item's words never outranked the drawing.

Consequence: the game is 16:9 again. Matching a square reference 1:1 had pushed
the whole HUD into a 720-wide band with the scene showing either side.

## 2026-10-12 — the vault holds pictures; the repo holds state

276 notes, 75,553 lines and nine tools syncing a board between markdown, GitHub
Issues and a Projects board, for a team of one. Cut to `TASKS.md`,
`DECISIONS.md`, `LEARNINGS.md` in the repo root, with `design/` keeping what
Obsidian is genuinely good for: reference art, shots, match-log pairs, frames,
renders. Everything else is under `design/files/archive/2026-10-cut`.

A hosted tracker earns its keep when other people need comments and
assignments. We are one person.

## 2026-10-12 — routines off; interactive for feel, background agents for testable work

The builder and checker routines are paused, not deleted. The builder's grader
only ever received still frames, so it could never see the fight — which is why
weeks of runs improved pixels and not play. Background agents come back for
work a test can verify; feel work happens with Nick in the loop.

## 2026-10-06 — the jackal moves, so direction does not matter

> "The jackal should be able to move. So the direction doesnt matter. Its the
> quality that im looking for."

Pose-matching and the cut-and-rotate repose are off the table. Quality of the
drawing is the thing.

## 2026-10-06 — the builder may spend Meshy credits on art quality

Up to **60 credits per run**, reported in its run note. More than that, or any
3D generation, still comes to Nick.

## 2026-10-06 — the drawing outranks the words

An item said "bold outlines"; TARGET.png has a thin warm line; the outline got
thicker. Prose about a reference drifts. Where a word in a brief and the
reference disagree, the reference wins.

## 2026-10-05 — card frame A1, carved obsidian, tinted per seat

Picked from four mockups. The ember colour is not baked: a neutral stone layer
plus a glow layer that takes the seat colour, so each character's cards light up
in their own colour. `CardView.SEAT_TINT` is the one table; `combat_3d.gd`'s
`SLOT_TINT` reads from it so the cards match the floor markers.

The cost number shrinks to fit its socket, never the socket to the number.

## Standing rules

- **No bought asset packs.** No other game's images in this repo — describe
  them in words.
- **Not balancing yet.** Gameplay is not ready; build feel and content, not
  win-rate numbers.
- **Never open the game or Blender on Nick's main screen.** `shot.cmd` already
  launches off-screen; keep it that way.
- **Music off while testing.**
- **Don't teach Blender in text** — build the asset and let Nick react.

## 2026-08-05 — three calls that still hold

Learn Blender rather than commission the models; orbital camera; real-time grip
(the timed-card + grip-bar "double timing" is the feel that lands — lean into
timed cards).
