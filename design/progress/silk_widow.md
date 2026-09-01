# silk_widow — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/silk_widow.py`.** Views: `design/renders/silk_widow_pass1_*.png`.
Captured after "Darken the rock, warm the organics" (palette + UV fix) and the
three-point lighting rig landed underneath this pass via merge — re-rendered
against both before scoring; this asset's colours and findings below are
unchanged from the pre-fix render.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 7 | 6 | 5 | 6 | 7 | **31** |
| 2 | 7 | 7 | 8 | 6 | 7 | **35** |

## What is actually there

A black spider: a small forward cephalothorax with a pair of fangs and a tiny
eye-huddle, a big swollen two-lobed abdomen behind it, six long bent-kneed
legs splayed wide, and a red taper-mark hourglass on the underside that
genuinely reads as a widow's marking. A thin grey crest reaches forward from
the abdomen past the head, carrying the gold sigil disc on its tip.

- **Silhouette** (`_sil.png`): reads as a spider at 64px — bulbous body, legs
  fanning out to the lower-right, a smaller head lobe. The forward crest is
  thin enough it barely registers in solid black, which is fine for
  silhouette but means the sigil-bearing part of the body isn't doing any
  silhouette work either.
- **Proportion**: the two-lobe cephalothorax/abdomen split and the bent-knee
  legs read as spider rather than the four-legged beasts already in the
  cast, exactly what the module doc calls for. The forward crest reads as an
  extra, disconnected element rather than part of the same creature — it's
  the one piece proportion doesn't sell.
- **Build hygiene**: the crest is anchored to touch the abdomen
  (`beast.py`'s `_sigil_lands` bounding-box check would have flagged it
  otherwise), but at 0.10→0.04 taper thickness against a 0.72-radius
  abdomen, it reads in every lit view as a thin rod poking out in front of
  the head with the sigil disc floating at the far end of it — the same
  "orbiting part" pattern named in `ART-REVIEW.md` for the Eyrie Hawk and
  Clot Toad, here on a part that is technically attached but visually is
  not.
- **Colour & read**: the red hourglass mark is the strongest single element
  in the model — it pops cleanly off the black abdomen and is legible small.
  The rest of the body (GRAPHITE cephalothorax, CHARCOAL abdomen/legs) sits
  close in value; the module doc's "eyes, barely eyes, enough to read as a
  face" are CHARCOAL on GRAPHITE and did not resolve as visible dots in any
  of the six views at this render size.
- **Style consistency**: low-poly primitives and the black-plus-accent
  palette sit fine beside the rest of the elite-pool beasts.

## Diagnosis — two lowest

1. **Build hygiene (5).** The sigil crest reads as a floating stick with a
   disc on the end rather than a crest growing out of the body. Concrete
   fix: thicken the taper's base radius from 0.10 to roughly 0.18 and
   shorten its length by about a third, so it reads as a stubby horn fused
   to the abdomen rather than a wire with a washer on it.
2. **Colour & read (6).** The eye-huddle (CHARCOAL on GRAPHITE) does not
   read as eyes in any view. Concrete fix: swap the eye balls to a lighter
   or contrasting swatch (e.g. the same RED as the hourglass, or STEEL) so
   the "barely eyes" the doc asks for actually show up as two dots rather
   than disappearing into the head.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the eyes are present but simply too small to resolve at this render
resolution rather than genuinely invisible from a colour clash — a tighter
head-only crop would settle it, same open question as boulder_ram's horn.

## Pass 2 — fixer

Applied both fixes named above, in `tools/blender/silk_widow.py`.

1. **Build hygiene.** The sigil crest's taper widened from base radius
   `0.10` to `0.18` and shortened from length `0.75` to `0.50`.
2. **Colour & read.** Both eye-huddle balls swapped from `CHARCOAL` to
   `STEEL`.

Rebuilt with `build.cmd silk_widow`, captured a fresh six-view set with
`look.cmd silk_widow 2`, and viewed every view directly.

- **Silhouette (7):** unchanged — `_sil.png` reads the same as pass 1, the
  crest was never large enough to register in silhouette either before or
  after.
- **Proportion (7):** the crest now reads as a stubby horn growing out of
  the abdomen in the `_front.png` and `_34.png` views, not a thin rod with
  the sigil disc floating at the far end — the "extra, disconnected
  element" pass 1 named is fixed.
- **Build hygiene (8):** confirmed directly in the lit views — the crest
  now visibly touches and reads as fused to the abdomen's front hemisphere.
  Not a 9+: it is still a distinct, separately-coloured lump rather than a
  seamless part of the same mass, which is a shaping question rather than a
  hygiene one.
- **Colour & read (6):** re-checked the eye-huddle directly in `_front.png`,
  `_side.png`, `_top.png` and 2x crops of each — the STEEL balls did not
  resolve as two visible dots in any of the six views. The eyes sit on the
  cephalothorax's forward (-Y) face, which stays turned away from or
  occluded by neighbouring geometry in every one of `look.py`'s six fixed
  camera angles, so the colour swap never gets a chance to show. Held at
  the pass-1 score rather than the plateau this would otherwise be, because
  the red hourglass mark (unrelated to this fix) is unchanged and still the
  strongest single colour element.
- **Style consistency (7):** unchanged — still sits fine beside the rest of
  the elite-pool beasts.

**+4 total (31 -> 35).** Build hygiene and Proportion both improved from the
crest fix; Colour & read did not move, honestly, because the eye fix never
becomes visible from any of the six standard camera angles, not because the
fix was wrong. `run_tests.gd` passes.

## Unsure about (pass 2)

Same open question as pass 1, now sharpened: the eyes are confirmed present
and correctly coloured, but no standard camera angle looks squarely enough
at the cephalothorax's front face to show them. Fixing this would mean
either repositioning the eyes toward a face that better angles are more
likely to catch, or accepting they are a detail this creature keeps mostly
implicit — an art-direction call, not a mechanical one, so flagging rather
than guessing.
