# husk_beetle — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/husk_beetle.png`
(512x512). Batch 12 of #83; rubric defined in full in `frog_portrait.md`.

Note: `husk_beetle.md`'s 3D pass (29/50, later fixer-repaired to 33 —
`design/progress/husk_beetle.md`'s own "Pass 2 — fixer" section) was scored
against the pre-fix model; this portrait was rendered after that fix landed
(`portraits.py` builds from the model), so any pre-fix-only findings below
should not be assumed to carry over unchanged.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 4 | 6 | 6 | 5 | 6 | **27** |

Second-lowest portrait scored so far under this item, one point above
`bog_leech_portrait`'s 26 and below `cinder_jackal_portrait`'s 28.

## What is actually there

A large brown shell mass fills the middle of the frame, a smaller
round hump with a gold-ringed sigil sits at the top, and a head with two
pale-orange mandible points and dark eye is visible at the bottom-left with
legs at the frame edges. Alpha bounding box `(37, 0, 457, 477)` — the top
hump touches the very top edge of the canvas (y=0) while the bottom has
35px of clearance, the opposite of the bottom-cropped convention every
other scored portrait in this batch uses.

- **Framing (4):** the top-hump-and-sigil touches the top edge with zero
  clearance, while unused space sits below the subject — a crop that is
  tight on the wrong side relative to the rest of the cast's
  headroom-above / cut-at-bottom convention.
- **Identity (6):** the two-mass shape (small sigil-bearing hump above a
  larger shell) plus mandibled head reads as "armoured bug," but the two
  masses are close enough in brown value that they read as one lumpy
  silhouette rather than the two distinct plates the build intent
  describes — the same finding `husk_beetle.md`'s 3D pass made about
  silhouette/proportion (5/10 each, pre-fix).
- **Readability @ 34px (6):** confirmed via a real 34px downsample. The
  gold sigil on the upper hump stays visible as a small bright dot against
  the brown, which helps orient the shape, but the two shell masses and
  the head all blur into one continuous brown blob with legs barely
  surviving at the edges.
- **Colour & separation (5):** shell, hump, and head are all close
  variants of the same reddish-brown; only the black legs, orange
  mandibles, and gold sigil break the palette. This is the weakest line
  and matches `husk_beetle.md`'s own pre-fix Colour & read finding (6/10)
  almost exactly.
- **Style consistency (6):** the head-and-shoulders convention is present
  in spirit, but the top-edge crop breaks the shared headroom convention
  the other portraits in this batch (`gloom_moth_portrait`) hold to.

## Diagnosis — two lowest

1. **Framing (4).** Concrete fix: pull `portraits.py`'s `FOCUS` centre up
   and/or widen the span slightly so the top hump clears the canvas edge
   with visible headroom, matching the convention every other scored
   portrait uses.
2. **Colour & separation (5).** Concrete fix: give the smaller top hump a
   distinct value or hue step from the main shell (a lighter tan, per
   `husk_beetle.md`'s own earlier fix proposal for the 3D silhouette
   problem) so the two segments separate by colour even where the
   silhouette does not fully break them apart.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the top-edge crop is a `FOCUS` table oversight (this asset never
having been re-tuned after the model's fixer pass changed its geometry) or
a deliberate choice — this scoring pass can see the clipped edge, not why
it's set that way.
