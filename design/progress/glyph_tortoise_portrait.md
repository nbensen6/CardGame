# glyph_tortoise — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/glyph_tortoise.png`
(512x512). Batch 12 of #83; rubric defined in full in `frog_portrait.md`.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 3 | 6 | 6 | 8 | 6 | **29** |
| 7 | 8 | 8 | 8 | 7 | **38** |
| 9 | 8 | 6 | 7 | 8 | **38** |

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

## Pass 3 — the two lines pass 2 tied at 7

**Tooling note.** `download.blender.org` is unreachable from this run's
network policy (a fresh `connect_rejected`, not the stale-checkout issue).
Rendered instead with the `bpy` PyPI wheel (4.2.0) driving the exact same
`tools/blender/portraits.py` code — no second copy of the render logic.
Checked this is trustworthy for *this* asset specifically, not assumed: the
unmodified script (dx=0, i.e. pass 2's own committed state) reproduced pass
2's recorded alpha bbox `(27, 40, 509, 493)` exactly, pixel for pixel. That
check does not generalize — a same-session spot check on `frog` rendered a
badly-wrong extreme close-up under `bpy` that does not match the shipped
`frog.png` at all, same script, same FOCUS entry, no fix applied here or
elsewhere. Left `frog` and everything else untouched; this pass touches only
the one named `FOCUS_XY` entry below, verified the way pass 2 always has
(alpha bbox measured directly, real 34px downsample, both looked at with the
Read tool).

Two lowest, tied at 7: **Framing** and **Style consistency**.

1. **Framing.** Pass 2 named the cause and didn't chase it: right margin 3px
   against 27/40/19 on the other three edges, i.e. the crop is shifted left
   of the model's own centre. Added `FOCUS_XY["glyph_tortoise"]`, +0.09 off
   the bbox-centre X (0.0554 → 0.145) — measured by trying 0.05 (21/9,
   better but not centred), then 0.09 (15/15, centred within 1px), rather
   than guessed.
2. **Style consistency.** Same root cause pass 2 named for its own fix: an
   off-centre crop reads as an accident rather than a deliberate framing
   choice. No separate change — the same `FOCUS_XY` fix is the whole
   attempt; there's no second lever available in `portraits.py` for this
   creature's own wide-body idiom without re-opening Framing.

Rebuilt via `python3 tools/blender/portraits.py -- <scratch dir>` (all 30,
same non-determinism pass 2 already documented), kept only
`glyph_tortoise.png`, reverted the rest.

Measured: alpha bbox now `(15, 39, 497, 491)` → margins **15, 39, 15, 21**.
Downsample: `design/renders/glyph_tortoise_portrait_pass3_34px_big.png`
(Pillow `LANCZOS` to 34px, then nearest-neighbour back up to view it).

- **Framing (7 → 9):** left and right now match within 1px; top (39) still
  taller than bottom (21), but that reads as ordinary headroom-above-the-
  subject, the same convention `frog_portrait.md`'s Framing-8 already scored
  as a positive, not an asymmetry to fix.
- **Identity (8, unchanged):** shell, head and all four legs still read as
  this creature regardless of crop-centring; not one of the two fixed lines
  and nothing else here touched the model.
- **Readability @ 34px (8 → 6):** confirmed via the real downsample above.
  Shell, body and legs still separate cleanly, but the gold sigil mark —
  credited in pass 2's own 8 — is not a rendering artifact of this pass's
  fix; it is `374389e`'s already-committed model change reaching this
  portrait for the first time. That fixer commit moved the sigil off its
  raised stalk onto the shell's flat front slope specifically to fix a
  *3D* Build-hygiene complaint (`glyph_tortoise.md` pass 2, "reads as a
  flagpole with a coin on it"), and nobody re-rendered this portrait
  against the new model until now to see the 2D consequence: a flush gold
  mark that read fine on a stalk is a thin faint crescent at 512px and
  invisible at 34px. Real, but not this pass's regression, and not
  fixable from `portraits.py` — noted for the fixer lane below.
- **Colour & separation (8 → 7):** same cause as above — the shell/body/leg
  separation this line always scored is intact; docked because the sigil
  accent that used to read as a distinct gold dot no longer separates at
  either size.
- **Style consistency (7 → 8):** the balanced crop reads as a deliberate
  three-quarter full-body composition now, matching `bog_leech` / `thrasher`
  / `husk_beetle`'s shared idiom rather than an off-centre accident.

**+0 total (38 → 38) — kept anyway.** Both of this pass's own named fixes
(Framing, Style) genuinely improved and neither regressed; the flat total is
the Readability/Colour drop from a model change this pass didn't make and
would have shown up in the very next render regardless of any crop work.
Reverting the `FOCUS_XY` entry would restore the off-centre crop while doing
nothing for the sigil, so keeping it is the strictly-better state on every
line this pass actually controls. This is a plateau (gain < 2) by the loop's
own stop condition — stopping here rather than spending pass 4 on lines this
lane can't move.

`run_tests.gd`: **ALL TESTS PASSED** (fresh `--import`, headless, Godot
4.7.1 — this pass touches only `tools/blender/portraits.py` and the
regenerated `glyph_tortoise.png`, no `game/**` GDScript).

## Unsure about (pass 3)

Whether the flush gold sigil is worth a model-side fix at all — it may read
fine at in-fight camera distance and only be a 2D-crop casualty, the same
open question pass 1 already had about the pre-fix stalk mount. Flagging the
concrete finding for whoever picks up beast work next: the sigil mark on the
current `glyph_tortoise.glb` (post-`374389e`) is not readable at 34px in the
portrait crop, and that is a MODEL question (mark size/contrast), not a
`portraits.py` framing question — this lane's tools have nothing left to
try on it. Also unsure whether the `bpy`-vs-real-Blender discrepancy seen on
`frog` affects other assets in the cast; not investigated further since it's
outside this pass's two named lines and `download.blender.org` being
unreachable is this run's problem, not a standing one.
