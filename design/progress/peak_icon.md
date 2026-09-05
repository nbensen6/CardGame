# peak — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83,
batch 16 (see `design/progress/climb_icon.md` for the full rubric and batch
setup — same rules apply here, not repeated). Asset:
`game/assets/icons/peak.png` (256x256). Third of the "six are about going
up" family this batch scores.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 9 | 6 | 8 | 8 | **39** |

## What is actually there

Two overlapping mountain peaks — a tall SLATE/PEWTER pyramid in front, a
smaller one behind and to the right — both with white snow caps, and a
small red flag planted at the tall peak's summit. Alpha bbox
`(4, 0, 256, 238)`: touches the top edge (the flag is cropped there) and
the right edge (the smaller peak's right slope runs off-canvas), comfortable
margin at bottom and near-full width on the left.

- **Silhouette @ 42px (8):** the twin-peak shape survives the downsample
  clearly and reads unmistakably as a mountain; the flag compresses to a
  small red smear at the summit but doesn't hurt the read of the mountain
  itself.
- **Family distinction (9):** completely unlike `climb`/`ascend`'s
  arrow-on-post, and unlike `rope`'s vertical coil — the strongest
  silhouette separation scored in this batch, confirmed side by side at
  42px.
- **Mechanic match (6):** the card text is "a strike that scales with
  Height" — an attack — but the icon shows a place (a mountain), not an
  action. It supports the Height theme strongly but doesn't itself signal
  "strike" the way, say, `sword`'s blade does; a player would need the
  keyword to connect "mountain" to "damage."
- **Colour & contrast (8):** the slate/pewter blue-grey body reads clearly
  against the brown card standin, the white snow caps add a bright accent,
  and the red flag is the only warm colour in the family, which helps it
  stand out.
- **Style consistency (8):** consistent bevelled-block construction with
  the rest of the set.

## Diagnosis — two lowest

1. **Mechanic match (6).** Concrete fix: since the card is a strike, not
   terrain, add a motion cue to the mountain — a jagged crack or an impact
   burst at the peak — so the icon reads as "a hit that comes from height"
   rather than only "a mountain."
2. **Top/right edge clipping (contributes to Silhouette).** Concrete fix:
   pull the flag and the smaller peak's right slope fully inside the
   256x256 canvas so nothing is cropped at full size, before it's cropped
   again by the 42px downsample.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the flag is meant to be read as part of the mechanic ("Height" —
reaching the top) or is pure flavour left over from a "victory flag" idea;
nothing in the build comment says which, and it's the one element of this
icon that doesn't obviously serve "a strike."

## Pass 2 — #86 duty 1

Applied both named fixes in `tools/blender/icons.py`'s `peak()`, in-lane
(icons only — no beast or portrait geometry touched).

1. **Top/right edge clipping.** Measured the actual world-unit overflow
   before touching anything: `FRAME = 1.15` puts the frame's own half-extent
   at 0.575 in both X and Z (confirmed against `render()`'s
   `ortho_scale = FRAME` on a square 256x256 sensor). The flagpole's old
   `loc=(-0.06, 0.52)`/`length=0.30` spanned z 0.37–0.67, and the flag
   itself (`slabf(0.10, 0.60, ...)`, half-height 0.075) spanned z
   0.525–0.675 — both past 0.575. The back peak's old `spike(0.34, -0.24,
   0.30, ...)` put its own base radius's rightmost reach at x = 0.34+0.30 =
   0.64 — also past 0.575. Shortened and lowered the pole (length 0.30→0.18,
   loc z 0.52→0.46, base still meets the front peak's own apex at z≈0.37)
   and lowered the flag to match (z 0.60→0.48), and pulled the back peak
   and its snow cap left by 0.09 (x 0.34→0.25, cap 0.30→0.21) rather than
   shrinking its radius, so the "two overlapping peaks" silhouette is
   unchanged, just shifted clear of the edge.
2. **Mechanic match (6).** Concrete fix: added a small crack-burst at the
   summit — three short spikes fanning from the peak apex, thin base to
   wider tip, the same radiating-taper vocabulary `expose()` already uses
   for its own fracture cue, in `BRICK` (a colour already proven to
   separate from the card standin in `expose_icon.md`) rather than a new
   swatch — so the peak reads as a point of impact, not just a place.

Built with apt's Blender 4.0.2, headless (`libegl1`/`libegl-mesa0`/
`libgles2`, `numpy`+`pillow` via `python3 -m pip install
--break-system-packages`). Ran the full `icons.py` batch (no single-icon
build path exists) and diffed all 36 PNGs against the committed renders
pixel-by-pixel (not byte-by-byte — Blender's PNG writer embeds something
that changes the raw bytes on every run even for an unchanged scene, seen
here as every icon "differing" under `cmp` while most decoded to
byte-identical pixel arrays under Pillow). Twelve of the other 35 icons
(`sword`, `bow`, `skull`, `flask`, `bomb`, `support`, `relic`, `guard`,
`timer`, `thorns`, `light`, `strength`) showed real but small pixel drift
(mean per-channel diff 0.3–4.4, up to 25% of pixels touched) — WORKBENCH's
own AO/cavity sampling non-determinism, the same effect prior passes in
this file's siblings have flagged, not a `peak()`-only build. Kept only
`peak.png` (mean diff 19.3, 44% of pixels — a real, large, intentional
change) and reverted the rest with `git checkout --`.

Verified both fixes against the actual render, not just the arithmetic:

- **Clipping.** Alpha bbox (>10 alpha threshold) moved from `(4, 0, 256,
  238)` — touching the top and right edges — to `(4, 4, 247, 238)`, a real
  margin on every side now.
- **Burst.** Looked at a 4x crop of the summit
  (`design/renders/peak_icon_pass2_summit_zoom.png`): three jagged `BRICK`
  shards fan out from the pole's base where it meets the snow cap, reading
  clearly as a fracture/impact at full size. At a real 42px downsample
  (`design/renders/peak_icon_pass2_42px_big.png`, the same downsample this
  loop scores everything else at) the burst compresses to a small warm
  accent under the flag rather than a distinctly countable crack shape — a
  real but more modest effect than the full-size crop shows, which is why
  Mechanic match moves one point rather than several.

## Score, pass 2

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 9 | 9 | 7 | 8 | 8 | **41** |

- **Silhouette@42px (8 → 9):** the twin-peak shape was already reading
  fine at 42px before this pass; the bump is for the full-size margin now
  matching the comfortable-on-all-sides bar the rest of this batch clears,
  confirmed by the bbox numbers above, not a 42px-only effect.
- **Family distinction (9, unchanged):** neither fix touched the
  two-overlapping-peaks composition that made this line distinctive.
- **Mechanic match (6 → 7):** a real cue was added and confirmed in the
  full-size render; not higher because the same cue reads as a soft warm
  blob rather than a countable crack once downsampled to 42px, per the
  honesty rule — claiming more than what the small-size render actually
  shows would repeat the mistake this loop exists to catch.
- **Colour & contrast (8, unchanged):** `BRICK` is an existing swatch
  already proven to separate from the standin (`expose_icon.md`); it sits
  close in hue to the flag's `RED` by design (both mark the same point of
  contact) without touching the mountain body's own already-clean
  separation.
- **Style consistency (8, unchanged):** the burst reuses `expose()`'s own
  crack vocabulary rather than inventing a new primitive, which is a
  reason it could arguably move up, but nothing else in this icon changed
  to justify a bump on this line specifically, so left as scored.

**+2 total (39 → 41) — stop condition met (≥40).** Not applying a third
pass.

## Unsure about (pass 2)

Whether the crack-burst is legible enough at 42px to actually shift a
player's read from "a mountain" toward "a strike," or whether it mostly
helps at the larger sizes the deck view and campfire panel use — the
zoomed crop confirms the shape exists and is not a rendering artifact, but
this pass can't measure how it lands at a glance the way the bbox numbers
measure the clipping fix.
