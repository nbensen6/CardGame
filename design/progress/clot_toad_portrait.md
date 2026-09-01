# clot_toad — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/clot_toad.png`
(512x512). Batch 11 of #83; rubric defined in full in `frog_portrait.md`.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 3 | 4 | 5 | 6 | 6 | **24** |
| 7 | 7 | 7 | 6 | 6 | **33** |

Lowest portrait scored so far, below `bog_leech_portrait`'s 26 from batch 10.

## What is actually there

A wide tan-brown blob body with two cream/yellow gland lumps and a pale
lump on its back fills the bottom-left three-quarters of the frame. The
stepped ridge/gland stack that carries the beast's whole "climb route"
identity, plus the gold sigil disc, sit at the top-right — and are cropped
by the frame edge, cutting off mid-shape.

- **Framing (3):** the ridge/gland stack and the sigil disc — the two
  elements `clot_toad.md`'s own 3D pass already named as this beast's
  identity-carrying parts — are cropped by the top-right frame edge rather
  than fully in view; the sigil disc is cut roughly in half. Weakest
  framing score of any portrait scored under this item so far.
- **Identity (4):** the tan blob body reads as "toad-like" from shape alone,
  but with the ridge stack cropped, nothing signals "climb route" or
  "gland" — the crop removes the one feature the module doc names as this
  beast's defining trait.
- **Readability @ 34px (5):** confirmed via a real 34px downsample. The
  body blob stays a recognisable rounded shape and the two cream gland
  lumps on its near side stay visible as lighter dots, but the cropped
  ridge stack at the edge shrinks to an indistinct brown smear and the
  sigil is entirely gone.
- **Colour & separation (6):** the cream gland lumps separate cleanly
  against the tan body, and the visible slice of the ridge stack's rust and
  orange tones reads distinctly from the tan — no dark-on-dark problem,
  the crop is the failure here, not the palette.
- **Style consistency (6):** the head-and-shoulders-style crop convention
  is present in intent, but cutting the beast's own identity feature at the
  edge is a framing miss the other scored portraits in this batch don't
  share.

## Diagnosis — two lowest

1. **Framing (3).** Concrete fix: widen or re-centre `portraits.py`'s
   `FOCUS` entry for this asset so the ridge/gland stack and sigil sit
   fully inside the frame rather than clipped at the top-right corner —
   the crop is cutting off the exact feature the build script's own
   docstring calls the point of the beast.
2. **Identity (4).** Same root cause as framing: once the ridge stack is
   back in frame, identity should recover substantially without any model
   change, since the 3D scoring pass (`clot_toad.md`) already found the
   geometry itself under-reads that feature too (28/50, its own lowest
   line was Silhouette at 4 for the same stack).

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether this is a `portraits.py` `FOCUS` crop bug specific to this asset, or
whether the underlying model's ridge stack sits high/far enough back that no
crop choice would fit it and the sigil both in frame without a wider shot —
this scoring pass can see the cut, not its cause.

## Pass 2 — fixer

Applied the one fix named above: `portraits.py`'s `FOCUS["clot_toad"]` moved
from `(0.42, 1.15)` to `(0.48, 1.35)` — a higher centre and a wider span, so
the frame's top edge clears the scab-crest ball at the very top of the ridge
stack (the model's actual highest point) with room to spare instead of
landing almost exactly on it. `(0.42, 1.15)` turned out to be `husk_beetle`'s
own tuned value, unchanged from a copy default rather than tuned for this
asset's taller stack. Rebuilt with `build.cmd portraits`; every other
portrait in `FOCUS` re-rendered byte-identical in content but not in file
bytes (Blender's WORKBENCH output isn't bit-reproducible run to run), so
those were reverted with `git checkout --` and only `clot_toad.png` was kept.

Re-viewed `game/assets/portraits/clot_toad.png` directly (portraits are not
part of `look.cmd`'s six-view flow — that renders `.glb` cast/env models, and
a portrait is already the flattened 2D asset) and a fresh 34px downsample
built the same way batch 11's pass 1 did.

- **Framing (7):** the ridge/gland stack, the gold sigil disc, and the small
  scab-crest ball above it are now fully inside the frame with visible
  margin on the right and top edges — no cropping anywhere the diagnosis
  named. Not a full 8+: the composition is now slightly more zoomed-out
  than the other portraits in this batch, so it is not yet as tight a crop
  as the convention the other scored portraits share.
- **Identity (7):** with the stack and sigil visible, the beast now reads as
  the specific "climb route" toad the module doc describes, not a generic
  tan blob — the recovery the pass-1 diagnosis predicted.
- **Read@34px (7):** confirmed via a fresh 34px downsample (compared frame
  by frame against a downsample of the pre-fix PNG pulled from `HEAD`). The
  stack now survives as a distinct rust-coloured zigzag with a hint of gold
  at its tip, where pass 1 showed it vanish into an indistinct smear with no
  sigil at all. The body blob and cream gland lumps read exactly as before —
  the wider span cost no visible detail there.
- **Colour & separation (6):** untouched by this fix — same read as pass 1,
  not one of the two lines named.
- **Style consistency (6):** untouched by this fix — same read as pass 1,
  not one of the two lines named.

**+9 total (24 → 33), not a plateau — kept.** Both named lines (Framing,
Identity) improved, Read@34px improved as a direct consequence of the same
fix, and neither untouched line (Colour, Style) moved. `game/tools/run_tests.gd`
passes (headless Godot run, all green) — the change is confined to
`tools/blender/portraits.py`'s data table and the regenerated PNG, nothing
in `/core` or `/game` code.
