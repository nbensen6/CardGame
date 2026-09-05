# brine_urchin — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/brine_urchin.py`.** Views:
`design/renders/brine_urchin_pass1_*.png`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 4 | 6 | 8 | 8 | 7 | **33** |

## What is actually there

A spined red ball clamped to a grey rock base by four short tendrils, with
tapered spines at odd radial angles tipped in violet/iris balls, and a gold
sigil disc mounted in a socket on one flank. The top-down view reads
clearly as a sea-mine/urchin silhouette with all eight spines visible and
evenly spread; the 3/4 and side views read much weaker.

- **Silhouette** (`_sil.png`): only two or three of the eight spines show
  up as black silhouette spikes at 64px — the rest point close enough
  toward or away from this camera angle that they foreshorten to almost
  nothing, so the body reads as a plain round blob rather than a spined
  urchin.
- **Proportion**: the body itself is a near-perfect sphere with no clear
  front, face, or asymmetry beyond the sigil socket — from the fight's
  default angle it reads closer to a spiked mine than a creature with a
  face, even though the module doc calls out "a single glowing eye/mouth at
  the crown."
- **Build hygiene**: 1768/2600 tris, one mesh, spines and tendrils both
  join the body cleanly in `_form.png` with no floating islands or gaps.
- **Colour & read**: CORAL/BRICK body against VIOLET/IRIS spine tips and a
  STONE base gives three clearly separated zones even at small size; the
  gold sigil pops cleanly against the red body.
- **Style consistency**: round-plus-taper construction fits the rest of the
  cast; the mine-like read is more a proportion/silhouette issue than a
  style mismatch.

## Diagnosis — two lowest

1. **Silhouette (4).** Most spines foreshorten to points from the
   game's actual viewing angle instead of projecting sideways into the
   outline. Concrete fix: rotate a few of the spines (particularly the pair
   nearest the front-facing axis) by roughly 20–30° around Z so more of
   them read as visible spikes crossing the silhouette rather than dots.
2. **Proportion (6).** The body reads as a generic spiked sphere with no
   face cue at fight distance, despite the module doc's intent of a
   glowing eye/mouth at the crown. Concrete fix: enlarge the socket the
   gold sigil sits in by roughly 30%, or darken its rim, so it reads as an
   eye/mouth from the default fight camera rather than only up close.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the "sea mine" read is actually a problem — the boss's `at_sigil`
+ `attack_all` mechanic (punish reaching the sigil alone) has real
menace-as-a-device logic behind it, and a mine-like silhouette might
support that better than a face would. Flagging it as a proportion finding
rather than assuming the fix; a design call, not a measurement. Also unsure
whether the tendrils gripping the base read as "clinging" at fight
distance or just as short stubby legs — could not tell from these six
views alone.

---

## Pass 2 — fixer lane, 2026-09-05

Applied by the **fixer** lane (`tools/fixer/BRIEF.md`), which repairs what the
cloud reports. Views: `design/renders/brine_urchin_pass2_*.png`, captured with
`look.cmd brine_urchin 2`, compared against the existing
`brine_urchin_pass1_34.png` / `_sil.png`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 4 | 6 | 8 | 8 | 7 | **33** |
| 2 | 6 | 7 | 8 | 8 | 7 | **36** |

### Both diagnosed fixes applied

- **Silhouette (4 → 6).** Spines 4 and 9 (`ang = i * 36.0`, at 144° and 324°)
  sit almost exactly on the 3/4 fight camera's own viewing axis — one nearly
  facing it, one nearly facing away — so they foreshortened to near-dots
  instead of visible spikes. Rotated both 20° around Z
  (`ang = i * 36.0 + (20.0 if i in (4, 9) else 0.0)`), off that axis, without
  touching the other eight or the 18° gap the sigil column already depends on
  at 252°/288°. `brine_urchin_pass2_34.png` shows the spine that used to sit
  as a small violet dot right of the sigil now reading as a full spike with
  its tip clear of the body, next to `brine_urchin_pass1_34.png`'s dot. Still
  not shippable — most of the ring still foreshortens from this angle — but a
  real, visible gain, and the top view (`brine_urchin_pass2_top.png`) confirms
  no new overlap between the rotated spines and their neighbours.
- **Proportion (6 → 7).** The BRICK backing plate the gold sigil mounts on
  (`b.box(..., (0.16, 0.06, 0.16), BRICK, ...)`) enlarged ~30% to
  `(0.21, 0.08, 0.21)`, per the diagnosis's own two options — size over rim
  colour, since the palette is off-limits for a one-model fix. `_34.png` and
  `_side.png` now show a distinctly wider dark plate behind the gold disc,
  reading closer to a socketed eye than a small medallion; compare
  `brine_urchin_pass1_34.png`'s thin rim.

+3 total, not a plateau — kept. Colour and style were not touched, per the
brief, and their scores are unchanged from pass 1.

`run_tests.gd` passed (all green) before commit. Build log: 1768/2600 tris, 1
mesh, every climb Height and the sigil hold still `ok` — the socket enlarge
only grew the backing plate, not the sigil's own `mark()` size, so the sigil
hold contract was untouched.

## Unsure about, still

Same open question named in pass 1: whether the "sea mine" read is a bug or
the correct read for this boss's own punish-camping mechanic — a design call,
not something this pass's two measurement fixes could resolve either way.
