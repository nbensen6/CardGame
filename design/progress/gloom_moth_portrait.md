# gloom_moth — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/gloom_moth.png`
(512x512). Batch 12 of #83; rubric defined in full in `frog_portrait.md`.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 7 | 7 | 6 | 7 | 8 | **35** |

Pass 2: 8 | 7 | 6 | 7 | 8 | **36** — see below.

Best of this batch, and the best-scoring beast portrait so far (ahead of
`eyrie_hawk_portrait`'s 35 by rubric-line spread, not just total).

## What is actually there

Head-and-shoulders crop, three-quarter angle: a large purple wing-hump
over a black-blue thorax, a rounded black head with one blue eye-dot and
an orange curled proboscis, two thin antennae, and a small gold sigil disc
riding one antenna near the head. Alpha bounding box `(50, 44, 429, 512)`
— comparable margins to `frog_portrait`'s (59, 50, 506, 512), the
best-framed portrait scored under this item.

- **Framing (7):** headroom above the wing-hump, sigil and both antennae
  fully inside frame, body cut at the bottom edge in line with the
  cast-wide crop convention. Not an 8+: the wing-hump sits slightly
  off-centre toward the left, leaving a touch more dead space on the
  right than the tightest-framed portraits.
- **Identity (7):** the purple hump plus black head with orange proboscis
  reads as insectoid and distinct from the cast's other bug beasts
  (husk_beetle, brine_urchin) by colour alone, though the wing-hump shape
  itself doesn't add a moth-specific cue beyond colour.
- **Readability @ 34px (6):** confirmed via a real 34px downsample. The
  purple hump and black head stay separated as two shapes, and the eye-dot
  survives as a small blue fleck; the gold sigil on the antenna and the
  orange proboscis both blur into indistinct smears at this size — the
  same "small sigil against a dark antenna could wash out at 34px" risk
  `gloom_moth.md`'s 3D pass flagged is confirmed here.
- **Colour & separation (7):** purple against black/blue thorax separates
  clearly; the blue eye-dot pops against the black head. No dark-on-dark
  failure, though purple and the near-black thorax sit closer in value
  than the cast's brighter colour pairs.
- **Style consistency (8):** matches the shared three-quarter
  head-and-shoulders convention on a transparent background cleanly.

## Diagnosis — two lowest

1. **Readability @ 34px (6).** Concrete fix: this is the same sigil-on-
   antenna placement `gloom_moth.md`'s 3D pass already flagged (Build
   hygiene 6/10) proposing to slide the disc toward the head — doing so
   would also move it into a higher-contrast area of the portrait crop,
   which should help the 34px read as a side effect.
2. **Framing (7).** Concrete fix: nudge `portraits.py`'s `FOCUS` centre
   slightly right (the wing-hump currently sits left-of-centre) to balance
   the dead space on the right edge.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the orange proboscis is meant to read as a distinct feature at
party-panel size — at 34px it all but disappears into the black head, so
if it's meant to be an identity cue (the way the eyespot marking is
called out as one in `gloom_moth.md`) this crop and size don't carry it.

## Pass 2 — cloud, backlog #86 duty 1

Only the **Framing (7)** line had a fix that stays in `portraits.py`
without touching the model: nudge the focus centre right, per this file's
own diagnosis. **Readability @ 34px (6)** needs the sigil moved on the
antenna, which is `gloom_moth.py` model geometry — out of this lane's
scope (`design/asset-loop.md`'s file-ownership split), so left untouched
here, same as `eyrie_hawk_portrait.md`'s sigil finding and every prior
pass under this item that hit a model-only fix.

Measured first rather than guessed: the mesh itself is X-symmetric
(`bbox` centre x = 0.022, checked directly with a bbox dump against the
`.glb`), so the "off-centre" read isn't a lopsided model — it's the fixed
three-quarter `EYE` angle in `portraits.py` projecting the moth's Y/Z
spread (antennae swept up-forward, wings drooping back) onto screen X
asymmetrically even though nothing in world X itself is uneven. Confirmed
by rendering the default framing and measuring the alpha bbox (Pillow,
threshold >10): centre at screen x=239.5 against the 512px canvas's own
256, i.e. 16.5px left of centre.

Added a `FOCUS_XY["gloom_moth"]` entry (`(-0.10, 0.0)`) — `portraits.py`
already has this override mechanism for exactly this class of problem
(`riptide_eel`, `cinder_jackal`). Swept the world-X offset in ~0.05
steps first (+0.05 made it worse, moving centre to -22.5px; the
correcting direction is negative) then narrowed to -0.10..-0.13; -0.10
lands the alpha bbox centre at 255.5 (-0.5px off the true centre, next
best of the values tried).

Built via apt's Blender 4.0.2, headless (same route prior duty-1 passes
used: `apt-get install blender python3-numpy libegl1 libgl1-mesa-dri
libglx-mesa0`, `python3.12 -m pip install --break-system-packages
Pillow` — numpy was already present under `/usr/lib/python3/dist-
packages`). Ran the full `portraits.py` batch (all 32) twice — once
before the `FOCUS_XY` edit, once after — and diffed pass-2 against
pass-1 (both from this session) rather than against the committed set
directly, matching `taunt_icon.md` pass 2's method: only `gloom_moth.png`
moved (mean per-pixel diff 22.7); nothing else changed. Copied only the
changed `gloom_moth.png` into `game/assets/portraits/`.

Verified by looking, not just by the numbers:

- **Full 512px composite** (grey background, before vs after): the
  before render crowds the wing-hump and head toward the left third of
  the frame with a wide empty margin on the right; the after render
  centres the same silhouette, with visibly more of the right side of
  the wing-hump and body now inside the frame and the left/right margins
  close to even.
- **A real 34px downsample** (Pillow `LANCZOS`, nearest-neighbour
  upscaled for viewing, brown-standin `RGB(139,105,74)` composite, same
  method every prior portrait pass under this item used): the before
  crop clips more of the body's right edge than the after one; the
  antennae, eye and sigil positions are unchanged (this fix only pans
  the frame, it doesn't move anything on the model), matching the
  intent of a framing-only fix.

- **Framing (7 → 8):** the wing-hump is no longer left-of-centre; the
  dead space this file's pass-1 diagnosis named is gone, confirmed in
  the full-size composite above. Not a 9+: the framing convention crops
  the body at the bottom edge regardless, which is shared across the
  whole cast and not something this pass touches.
- **Identity (7, unchanged):** framing-only change, no geometry moved.
- **Readability @ 34px (6, unchanged):** the sigil-on-antenna wash-out
  this line's diagnosis named is a model issue, untouched by this pass;
  the 34px comparison above shows the same sigil legibility either way.
- **Colour & separation (7, unchanged):** no colour or geometry changed.
- **Style consistency (8, unchanged):** unaffected by a camera-frame
  nudge.

**+1 total (35 → 36).** Below the loop's 40/50 stop line, but the
in-scope half of this pass's two-fix budget is spent — the other named
fix is model geometry for the fixer lane, per `asset-loop.md`'s
ownership split. Kept; no line regressed.

`run_tests.gd`: **ALL TESTS PASSED** (fresh import, headless). No new
tests — a portrait-framing-only pass adds none, matching every prior
portrait/icon-only pass under this item.

## Unsure about (pass 2)

Whether the sigil-on-antenna fix (this file's other named fix, and
`gloom_moth.md`'s own Build hygiene 6/10 finding) is worth a fixer pass
on its own, or whether it's better bundled with any other Gloom Moth
model work — not this lane's call; left in `gloom_moth.md` /
`gloom_moth_portrait.md` for the fixer to pick up.
