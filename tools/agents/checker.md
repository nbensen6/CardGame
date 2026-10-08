# checker: the critic prompt, the checklist, and the matching loop

The standard is **TARGET 1:1** (Nick, 2026-10-08: "build the concept 1:1").
`design/art/targets/TARGET.png` is the scene, `TARGET-UI.png` the cards and
HUD. The game's centred 720x720 square must hold TARGET's picture with every
element the same shape, proportion, colour, shading, line, size and place.
Nothing older than 2026-10-07 is a target or a rule. Never ask Nick how
anything should look; TARGET answers.

The builder uses the critic prompt and checklist below to queue its own work
(`tools/builder/BRIEF.md`, step 2). The loop at the bottom is for this
checker routine when a `## Round N` heading is open in
`design/match-log/log.md`.

## The pairs

    bash tools/shot.sh out=/tmp/now.png state=3d beast=cinder_jackal
    python3 tools/vs_target.py /tmp/now.png <out>-square.png --square
    python3 tools/vs_target.py /tmp/now.png <out>-beast.png  --beast
    python3 tools/vs_target.py /tmp/now.png <out>-stones.png --stones
    python3 tools/vs_target.py /tmp/now.png <out>-hand.png   --hand

TARGET is always left, the game right, at the same scale. `--square` is
TARGET against the centred square of the game frame: placement is judged
there.

## The critic prompt

Spawn each critic fresh (Agent tool) with only the pair images and this text,
the checklist included. No history, no notes, no account of what changed.

> Left is the target art. Right is the game. The goal is that the game is
> indistinguishable from the target. In the `--square` pair, everything must
> sit in the same place; in the close-ups, compare shapes and surfaces. Go
> through every box of the checklist below and list every visible
> difference: shape, proportion, thickness, angle, colour, shading, line,
> size, position, missing or extra elements. Rate each MAJOR (anyone would
> notice), MODERATE (noticeable side by side) or MINOR (only when flipping
> between them). Rank biggest first. Say "no differences" for a box only
> after checking it.

## The checklist

1. **Jackal:** pose (hunched, three-quarter turn, left fist raised and on
   fire), proportions and silhouette, outline, cracks and the sternum hot
   seam, eyes, facets and shading, rim and lava up-light, the fist's flame.
2. **Stones:** six slabs: shape (thin, flat, irregular, chipped, wide), top
   and side tones, edges, tilt, size of each, and the staircase's exact path
   and spacing from beside the frog's rock up to the sternum.
3. **Frog and its rock:** the frog's size and place, the pedestal's size,
   shape, faces and tone, the green marker, the HP bar.
4. **Ground and lava:** the hex floor and its seams, the lava band's height,
   thickness and glow.
5. **Background:** the slate cliffs on both sides, their shapes and edge
   light, the purple sky, embers.
6. **HUD:** boss name plate and segmented HP bar, intent chip, Log and Menu,
   climb gauge, energy box, draw/discard/burn, the hand's fan, card frames and
   cost coins, End Turn and Switch. Look, size and place. `TARGET-UI.png` is
   the close-up.
7. **Framing:** where the jackal's ears, the lava line and the frog sit in
   the square; how much of the square the jackal fills.

## The loop (only while a `## Round N` heading is open)

Each iteration: make the pairs into `design/match-log/iter-NN-*.png` (NN
continues from the highest there); spawn TWO critics, blind to each other;
fix the single biggest difference BOTH name at MAJOR or MODERATE, by any
means (art cut from TARGET, repaint, shaders, models, Meshy, camera,
layout); append the iteration, both critics' top three and what changed to
`design/match-log/log.md`; tests green; commit and push. Stop when two
iterations in a row have both critics report no MAJOR and no MODERATE, or
after 25 iterations since the `## Round` heading, and write a `## DONE`
block with what remains. Never write a question for Nick: make the call
against TARGET and carry on.

Take the `builder` lease (`LEASE_STALE=10800 tools/agents/lease.sh claim
builder`; exit 3 means stop), release it at the end, never force-push, never
end with a background command running. `tools/sprite_match.py` measures
against the old concept render; it is never the verdict.
