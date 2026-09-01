# glyph_tortoise — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/glyph_tortoise.png`
(512x512). Batch 12 of #83; rubric defined in full in `frog_portrait.md`.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 3 | 6 | 6 | 8 | 6 | **29** |
| 7 | 8 | 8 | 8 | 7 | **38** |

## What is actually there

A blue-grey domed shell fills most of the frame, a gold-ringed sigil set
into its front slope, brown head and stubby legs visible at the bottom-left
corner. Checked the alpha channel directly rather than eyeballing it: the
content's bounding box is `(0, 20, 512, 512)` — the shell and legs are cut
by the LEFT, RIGHT, and BOTTOM edges of the 512x512 canvas, with only 20px
of clearance at the top. Three of four edges are clipping content.

- **Framing (3):** the worst edge-clipping found under this item so far —
  `clot_toad_portrait` (24/50, fixed to 33) cropped one edge; this crops
  three. Not scored lower than 3 because, unlike `clot_toad`, the parts cut
  off (legs, chin) are peripheral rather than the beast's own identity
  feature — the sigil and shell dome, `glyph_tortoise.md`'s named strengths,
  are both fully inside the frame with room to spare.
- **Identity (6):** the shell dome plus visible sigil reads as this beast,
  but the crop removes most of the leg/chin detail that would otherwise
  support the read, so it leans on the shell and sigil alone.
- **Readability @ 34px (6):** confirmed via a real 34px downsample. The
  blue-grey dome and gold sigil disc stay separated as a blob-with-a-dot;
  the cropped legs are reduced to faint tan smudges at the frame edges,
  barely readable as legs at all.
- **Colour & separation (8):** blue-grey shell, brown head, and gold sigil
  all separate cleanly from each other and from the white/transparent
  ground — no dark-on-dark. Best-scoring line for this asset, consistent
  with `glyph_tortoise.md`'s own 3D pass (7/10 on the equivalent line).
- **Style consistency (6):** every other scored portrait crops
  head-and-shoulders with headroom above the subject; this one is
  effectively a top-down shell shot with the head shoved into a corner —
  a different framing idiom from the rest of the cast, not just a tight
  version of the same one.

## Diagnosis — two lowest

1. **Framing (3).** Concrete fix: pull `portraits.py`'s `FOCUS` entry back
   (widen the span and/or lower the centre) so the shell and legs sit fully
   inside the 512x512 canvas — right now the crop is effectively zoomed
   past the model's own extent on three sides.
2. **Style consistency (6).** Same root cause as framing: once the crop is
   pulled back to fit the model, it should also land closer to the
   head-and-shoulders framing the rest of the cast uses, since the shell
   dome would no longer need to fill the entire frame to appear large.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the 3D pass's own "sigil mount reads as a bolted-on handle"
finding (`glyph_tortoise.md`, Build hygiene 5/10) is visible from this
portrait's angle — the sigil reads flush and clean here, but this is a
single static crop, not the turntable the 3D pass used, so it can't
confirm or clear that finding.

## Pass 2 — fixer

Applied both fixes named above, in `tools/blender/portraits.py`.

1. **Framing.** `FOCUS["glyph_tortoise"]` moved from `(0.58, 1.00)` to
   `(0.50, 1.28)` — lowered the centre and nearly doubled the span so the
   whole model, not just the shell, fits inside the 512x512 canvas. Landed
   on `1.28` after a first try at `1.20` still touched the right edge
   (bbox `(12, 26, 512, 509)`); widened further and re-checked the alpha
   bbox numerically rather than eyeballing it, same method pass 1 used.
2. **Style consistency.** Same root cause, same fix — pulling the crop back
   to fit the model turned the top-down shell shot into a proper
   three-quarter full-body view, the same wide-body framing idiom already
   used for `bog_leech`, `thrasher` and `husk_beetle` rather than a shell-
   fills-the-frame outlier.

Rebuilt with `build.cmd portraits`. That command re-renders every portrait,
and Blender's WORKBENCH output is not byte-reproducible even for unchanged
FOCUS entries (same non-determinism `silk_widow_portrait.md`'s pass 2 hit),
so every portrait but `glyph_tortoise.png` was reverted with `git checkout --`
and only the changed one kept.

Checked the alpha bounding box directly: `(27, 40, 509, 493)` — margins of
27px left, 40px top, 3px right, 19px bottom. All four edges now clear,
against pass 1's three edges clipped and only 20px of top clearance.

- **Framing (3 → 7):** every edge now has real clearance. Not higher: the
  right margin (3px) is much thinner than the other three, so the crop is
  not evenly balanced.
- **Identity (6 → 8):** the legs and chin that pass 1's crop cut down to
  faint smudges are now fully in frame alongside the shell and sigil,
  confirmed directly in the full-res render — the read no longer leans on
  the shell and sigil alone.
- **Readability @ 34px (6 → 8):** confirmed via a real 34px downsample
  (`design/renders/glyph_tortoise_portrait_pass2_34px_big.png`, Pillow
  `LANCZOS`, same method pass 1 used). The blue-grey shell, gold sigil dot,
  brown body and all four legs stay distinct and separately readable —
  where pass 1's legs reduced to faint tan smudges, they now read clearly
  as legs.
- **Colour & separation (8, unchanged):** not one of the two fixed lines,
  and the swatches themselves didn't change — same clean separation as
  pass 1.
- **Style consistency (6 → 7):** now a three-quarter full-body crop
  matching the wide-low-body framing already used for other stout beasts,
  rather than the outlier top-down shell shot pass 1 scored. Not higher:
  it is still a different idiom from the head-and-shoulders crop most of
  the cast uses — appropriate to this creature's proportions, but still not
  the majority convention.

**+9 total (29 → 38), not a plateau — kept.** Both named lines improved and
neither held steady at the old value; Identity, Readability and Style all
moved as a consequence of the same framing fix; Colour is unchanged,
honestly, since neither fix touched the model's palette. `run_tests.gd`:
**ALL TESTS PASSED**.

## Unsure about (pass 2)

Whether an even-tighter span could close the 3px right margin without
reopening the clipping pass 1 had — not attempted, since two fixes per run
is the budget and both named lines already moved. Also unresolved: the
`glyph_tortoise.md` 3D pass's "sigil mount reads as a bolted-on handle"
question pass 1 raised — this portrait angle still shows the sigil flush
and clean, same as pass 1, and this fix didn't touch the model.
