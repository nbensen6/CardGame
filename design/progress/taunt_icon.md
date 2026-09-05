# taunt — icon scoring log

Loop: `design/asset-loop.md`, adapted for 2D card icons per backlog #83,
batch 20 — continuing the icon rubric batches 14-19 established. **Scoring
pass only — report, not repair; no edits to `tools/blender/icons.py`.**
Asset: `game/assets/icons/taunt.png` (256x256, rendered by `icons.py`,
orthographic head-on per `design/ART-REVIEW.md`'s own build note). Second
of batch 20's four (see `expose_icon.md` for the batch's scope and shared
rubric).

## The adapted rubric (1–10 each, out of 50)

Same five lines batches 14-19 established (`design/progress/intangible_icon.md`
has the full rationale) — Silhouette@42px / Family distinction / Mechanic
match / Colour & contrast / Style consistency.

## Score

| Silhouette@42px | Family | Mechanic | Colour | Style | Total |
|---|---|---|---|---|---|
| 7 | 9 | 6 | 8 | 8 | **38** |

Pass 2: 9 | 9 | 6 | 8 | 8 | **40** — see below.

## What is actually there

A dark UMBER flagpole topped with a small GOLD ball, carrying three
horizontal ORANGE/TANGERINE banners of decreasing width stacked down the
pole — a signal flag or notice-board, read as one continuous shape.

- **Silhouette @ 42px (7):** the pole-and-flags block survives the
  downsample as one clean, solid silhouette; the top ball shrinks to a
  small dot but the three-flag stack it sits on stays legible as three
  distinct bands rather than fusing into a single rectangle.
- **Family distinction (9):** checked against every other icon scored
  under this item — nothing else uses a pole-with-banners shape; this is
  one of the more unambiguous silhouettes scored so far.
- **Mechanic match (6):** a flag on a pole reads as "planting a marker" or
  "a signal/rally point," which is a reasonable metaphor for pulling
  attention, but nothing about the shape specifically ties it to *the
  beast's* attention rather than a generic notice-board or waypoint icon
  — no eye, no aggressive posture, no line pointing at a target the way
  `expose`'s crosshair points at one. A player who hasn't read the
  keyword text would plausibly guess "a marker/checkpoint" before
  guessing "taunt."
- **Colour & contrast (8):** pixel-sampled directly: the UMBER pole runs
  roughly RGB(72-78, 39-43, 27-30), darker and redder than the brown
  standin RGB(139,105,74) — a real, unambiguous separation on the dark
  side; the ORANGE/TANGERINE flags are visibly lighter and more saturated
  than the standin in every rendered view.
- **Style consistency (8):** the flat bevelled banner slabs match the
  slab-stack construction used elsewhere in the set (`wall`'s bricks,
  batch 19's `gadget`); the ball-topped pole matches the spike-plus-ball
  vocabulary `support` and `relic` (this batch) also use.

## Diagnosis — two lowest

1. **Mechanic match (6).** Concrete fix: none proposed that stays within
   "one concrete fix, not redesign the whole icon" — the flag reads fine
   as *a* signal, just not distinctly as *aggro-pulling* versus any other
   marker; a small directional cue (an arrow or eye motif worked into the
   topmost flag) would be the more targeted change if Nick wants one.
2. **Silhouette @ 42px (7).** Concrete fix: the top ball is the icon's
   only rounded element and is nearly lost at 42px; enlarging it slightly
   relative to the pole width would keep it legible as a deliberate cap
   rather than a stray dot.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether "signal flag" reads as *taunt* specifically to a player with no
tooltip open, or whether it needs the keyword text to land — the same
kind of open question `intangible_icon.md` already named for "afterimage,"
and not settleable from a static render alone.

## Pass 2 — cloud, backlog #86 duty 1

Only the **Silhouette @ 42px (7)** line had a fix that stays in `icons.py`
without touching design. **Mechanic match (6)** was diagnosed as needing a
new motif (an arrow or eye worked into the topmost flag) that the pass-1
scorer explicitly left to Nick ("if Nick wants one") — that is a design
call, not a technical one, so left untouched here, the same split every
prior pass under this item has made for its own two-fix budget.

Applied the **Silhouette** fix: `icons.py`'s `taunt()` ball moved from
`((-0.30, 0.0, 0.44), (0.075, 0.06, 0.075), GOLD, 7, 4)` to
`((-0.30, 0.0, 0.46), (0.095, 0.075, 0.095), GOLD, 7, 4)` — radius up ~27%
in x/z (+25% in y-depth) and the centre raised 0.02 to keep clearance from
the topmost flag (flag top edge at world z 0.385; new ball bottom at
0.46-0.095=0.365, still 0.02 clear, versus the old ball's 0.365-clearance-
by-coincidence at 0.44-0.075=0.365 — the same gap, just carried by a bigger
ball instead of a smaller one).

Built via apt's Blender 4.0.2, headless (`apt-get install blender libegl1
libegl-mesa0 libgles2`; `numpy`/`Pillow` via `python3.12 -m pip install
--break-system-packages` — blender's bundled interpreter reads
`/usr/lib/python3.12`'s site-packages, not `python3`'s default 3.11, the
same 3.12-vs-3.11 split worth naming for the next pass that hits it fresh).
No single-icon build path exists, so ran the full `icons.py` batch (all 36)
twice — once before the edit, once after — and diffed pass-2 against
pass-1 (both from this session, isolating the code change from cross-run
WORKBENCH render noise) rather than against the committed set directly:
only `taunt.png` moved (mean per-pixel diff 0.79); every other icon's
diff against the *committed* set (2-9 mean) was already present in the
pre-edit pass-1 render too, matching the ordinary render-noise range prior
passes (`flicker_stag_portrait.md` pass 2, `yoke_ox_portrait.md`) already
named. Copied only the changed `taunt.png` into `game/assets/icons/`.

Verified by looking, not just by the numbers:

- **Alpha bbox** (Pillow `getbbox()`, >10 alpha threshold) moved from
  `(44, 13, 169, 251)` to `(40, 4, 169, 251)` — the ball's growth pushed the
  top margin from 13px to 4px, still clear of the canvas edge, not clipped.
- **Full 256px render**
  (`design/renders/taunt_icon_pass2_before_full.png` vs `..._after_full.png`):
  the ball is visibly larger and rounder against the pole top; nothing else
  in the icon moved.
- **A real 42px downsample** (Pillow `LANCZOS`, nearest-neighbour upscaled
  for viewing, brown-standin `RGB(139,105,74)` composite, same method every
  prior icon pass under this item used):
  `design/renders/taunt_icon_pass2_before_42px.png` vs `..._after_42px.png`
  — the old ball is a barely-there smear at the pole top; the new one is an
  unambiguous round gold cap, clearly a deliberate element rather than a
  stray dot, with the three flag bands still reading as three distinct
  bars underneath it exactly as before.

- **Silhouette @ 42px (7 → 9):** the cap now reads as a deliberate rounded
  element rather than a shrinking dot, and the flag stack below it is
  unaffected — confirmed in the 42px comparison above. Not 10: the pole's
  own thin line still softens slightly at this size, unrelated to this fix.
- **Family distinction (9, unchanged):** no other icon in the set gained or
  lost a pole-with-banners silhouette; this pass didn't touch the flags.
- **Mechanic match (6, unchanged):** untouched by design — still reads as
  "a signal/marker" rather than specifically "taunt," the same finding pass
  1 left as Nick's call.
- **Colour & contrast (8, unchanged):** the ball is still GOLD, same hue,
  just larger; no new colour introduced.
- **Style consistency (8, unchanged):** a bigger ball-cap doesn't change
  the shared "spike-plus-ball" vocabulary `support`/`relic` already use in
  this same batch — if anything it now matches their proportions more
  closely (`support`'s cap ball is `(0.12, 0.08, 0.12)`, `relic`'s inner
  ball `(0.09, 0.055, 0.09)` — this pass's `(0.095, 0.075, 0.095)` sits
  between the two rather than being the smallest of the three as before).

**+2 total (38 → 40), meets the loop's 40/50 stop line — kept.** No line
regressed.
`run_tests.gd`: **ALL TESTS PASSED** (fresh import, headless). No new
tests — an icon-geometry-only pass adds none, matching every prior
portrait/icon-only pass under this item.

## Unsure about (pass 2)

Whether `Mechanic match` is worth a future pass at all, or whether "signal
flag reads as a marker, not specifically aggro" is a permanent ceiling for
this shape family without the redesign pass 1 flagged (an arrow/eye motif)
— that's Nick's call, not this lane's, and 40/50 already meets the loop's
stop condition, so no pass 3 is planned for this asset.
