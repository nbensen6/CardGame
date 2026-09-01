# goblin_mech — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/goblin_mech.png`
(512x512). Batch 10 of #83; rubric defined in full in `frog_portrait.md`.
Rendered from the model as it stands after `goblin_mech.md`'s pass 2 fixer
pass (compressor box moved off the goblin's centerline, limb radii thickened)
— this portrait reflects that geometry, not the pass-1 render the earlier 3D
score describes.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 7 | 7 | 5 | 8 | 8 | **34** |

## What is actually there

Three-quarter crop of a green goblin's head and upper torso: pointed ears, a
gold goggle-strap across the eyes, a small dark mouth/tusk mark, a brown
chest satchel with a diamond stitch mark, one raised orange ordinary arm at
top-right, and a cluster of dark-grey mechanical shapes (shoulder block,
jointed limb segments, a claw) filling the frame's right side.

- **Framing (7):** decent headroom above the ears and a clean torso crop at
  the bottom, but the raised orange arm crowds the top-right corner close to
  the frame edge, and there's a little unused white space at top-left that a
  small reframe could reclaim.
- **Identity (7):** the goblin face (ears, goggles, tusk mark) reads
  immediately, and "grey machinery on one side" is legible at full size — the
  pass-2 fix (box off the centerline) means nothing mechanical crosses behind
  the head here, matching what `goblin_mech.md`'s pass 2 reports. Docked
  because the rig itself doesn't read as a single arm the character is
  wearing, only as "goblin plus grey machine," which is the same "several
  medium objects, not one enormous one" proportion gap the 3D scoring named
  and pass 2 did not fully close.
- **Readability @ 34px (5):** confirmed via a real 34px downsample. The green
  head, orange raised arm, and brown satchel still separate, but the grey rig
  collapses into one dark, undifferentiated mass with no visible joints or
  boxes — worse than the 3D pass's "scattered blocks" read, since at this size
  it isn't even scattered, just a blob.
- **Colour & separation (8):** green goblin, orange arm/exhaust accents, brown
  satchel, and grey rig all separate cleanly at full size; no dark-on-dark
  pairing anywhere in frame.
- **Style consistency (8):** matches the shared three-quarter convention; the
  machined-plate rig against the organic goblin reads consistent with the
  cast's established material contrast.

## Diagnosis — two lowest

1. **Readability @ 34px (5).** Concrete fix: none available without touching
   the model (out of scope here) — the rig's boxes are close enough in value
   and small enough on-screen that no crop or framing change fixes this; worth
   flagging to Nick as a portrait-specific case where a fix that helped the
   3D silhouette (pass 2's box repositioning) didn't carry through to a
   readable 34px icon.
2. **Framing (7).** Concrete fix: nudge the crop left/down slightly so the
   raised orange arm has clearance from the top-right corner, recovering the
   unused space at top-left in trade.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the grey-rig collapse at 34px is a portrait-crop problem (the rig
occupies less relative frame area than the goblin, so it gets less pixel
budget) or would also affect the party-panel read of any future "elite"
character with a similarly busy attachment — no other scored portrait so far
carries a comparably detailed side-attachment to compare against.
