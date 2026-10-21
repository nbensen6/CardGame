# Decisions

Why things are the way they are. Code shows what changed, never why. Newest
first. A decision here outranks any older instruction in a brief or a note.

## 2026-10-21 — the drawn beast stands in the lava; the stones stay where the climb is

Nick: "pushed farther back into the lava ... the stones don't have to be right
next to the jackal", then, when it came back standing on dark ground: "put it
back into the lava. This is a visual change, not a mechanism change." So the
stones, the climb and the sigil are built from the rig's anchors where they
stand, and only then does the drawing step out past the ground's edge into the
ring (`DRAWN_LAVA_STAND`, 0.12 of the arena radius past the lava's inner edge)
and sink `DRAWN_LAVA_SINK` (0.05 of its height) so the pool covers its feet.
The figure reads as a far thing standing in the lava behind the staircase; a
hunter at the sigil stands on the top stone with lava between it and the
chest. That gap is wanted, not a bug to close. Standing out there cost it
size, so the drawing alone grows `DRAWN_LAVA_ZOOM` (1.6) about its own floor
row -- holds, stones and camera never see it. All three knobs are in
`combat_3d.gd`.

Same day, three more visual calls:
- **The wall does not fade at all.** It faded straight ahead of the camera
  (to violet, then near-black, then to nothing) so TARGET's open sky showed
  between two formations; measured along the view, the window swung with the
  lens ("this weird wall that kind of looks purple ... it follows the
  camera"). `cliff_flat.gdshader` has no far fade now; the wall is rock all
  round, lit with the flanks' tones so it reads as slate, not a silhouette.
- **Two paths that never meet.** The Goblin's line was the Frog's
  mirrored about the top stone, so both met at the chest and the top pair
  folded into one. Each line now stands `STAIR_SPLIT` (0.22 of the beast's
  width) off the shared route, Frog left, Goblin right -- 0.1 still read as
  one staircase meeting at the chest ("they shouldn't connect at any point")
  -- and `far` is 1.25 so each top stone stands out past the anchor plane
  toward the beast. The waiting hunters stand symmetric about the top
  column, 1.5 asides each way (`_stair_rest_x`), so the paths rise as mirror
  images. The hunter's feet use the same `_stair_slab`, so they land on
  their own stones.
- **The jackal draws at double.** `DRAWN_LAVA_ZOOM` 3.2 ("the jackal should
  feel really big. Try with double, and then we'll reel it in"). Its ears
  clip the top of the rest frame; the number comes down when Nick says.
- **The staircase stones are a Meshy asset.** `stair_stone.glb`: a low-poly
  basalt block with a pale worn top, generated from a concept image
  (meshy-t2.5 smart topology, 1500 tris), fitted in code to each rung's
  radius with its top at the hunter's feet (`_stair_stone`). Its own texture
  stays; the flat-colour slab path remains for biomes without it.
- **The follow camera lines up on the drawing where it stands.** `_yaw_point`
  adds `_drawn_back_z()` to the box centre, so the climb shot keeps the
  jackal behind the hunter ("the camera facing the jackal at all points").
- **The stones are geometry.** `STAIR_SLAB_GEOMETRY` on: the painted
  cut-outs were TARGET's pixels upscaled, soft at any size ("turn to low
  poly ... cleaned up and high resolution"). Their old "outline" was the
  beast's depth prepass, which the beast no longer reaches from the lava.

The sprite's art lives in the rig's seven layers (`cinder_jackal_2d_<part>.png`),
never in the composite. Any fix to the jackal's drawing goes through
`tools/beast_recut.py` (from a clean `cinder_jackal_2d.png`) or `beast_rig.py`
(from TARGET.png), or it will not reach the screen. See [[LEARNINGS]].

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
