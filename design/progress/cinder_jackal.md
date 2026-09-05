# cinder_jackal — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/cinder_jackal.py`.** Views:
`design/renders/cinder_jackal_pass1_*.png`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 5 | 7 | 8 | 7 | **32** |

## What is actually there

A lean canid: four slender dark legs, a narrow rust-orange ribby torso, a
black wedge-snout head with pointed ears and amber eyes, a raised orange
bar sitting along the spine, a gold swirl sigil on the flank, and a flat
solid wedge tail sticking straight out behind. The legs, ears and snout
land the "lean chase predator" intent well; the spine ridge and tail don't
match their own module doc.

- **Silhouette** (`_sil.png`): the ears and general quadruped shape read,
  but the spine bar and torso merge into one clump at the top, and the
  tail wedge continues the body's line as a straight spike rather than
  dropping away like a tail.
- **Proportion**: legs, snout and ears read correctly lean and jackal-like.
  The module doc calls the spine ridge "low... a smouldering mane," but
  what's built is a stiff rectangular bar standing proud above the back —
  it reads as a mounted rail or handle, not fur.
- **Build hygiene**: 1180/2600 tris (lightest of this batch), one mesh,
  legs and ridge both appear to join the torso cleanly in the side view.
- **Colour & read**: CHARCOAL head against RUST/TANGERINE body, AMBER eyes,
  and the GOLD sigil all separate cleanly even at small size — this is the
  best colour read of the four beasts scored this pass.
- **Style consistency**: leg and torso construction match the cast's other
  quadrupeds (yoke_ox, flicker_stag).

## Diagnosis — two lowest

1. **Proportion (5).** The "low ember ridge... smouldering mane" described
   in the module doc is built as a rectangular bar standing clear above the
   spine, reading as a rigid attachment rather than fur. Concrete fix: drop
   the ridge bar's base ~0.08–0.10 in Z so it sits flush against the
   torso's own top surface, and taper its ends rather than leaving them
   square, so it reads as raised fur instead of a machined part.
2. **Silhouette (5).** The tail is a flat wedge held level with the torso,
   reading as a horizontal spike continuing the body line rather than a
   tail. Concrete fix: angle the tail down by dropping its far end ~0.15 in
   Z, so in silhouette it visibly breaks away from the body instead of
   extending it.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the ridge bar's stiff look is actually a budget/style constraint
(this beast is 1180/2600 tris, well under budget, so there's real room to
add a softer, multi-segment ridge instead of one box) or a deliberate
"cinder ember" read I'm misjudging — flagging as a proportion issue rather
than guessing at intent. Also unsure whether the flat tail wedge reads
differently once the beast is mid-attack-animation in the real fight camera
versus this static capture.

---

## Pass 2 — fixer lane, 2026-09-05

Applied by the **fixer** lane (`tools/fixer/BRIEF.md`), which repairs what the
cloud reports. Views: `design/renders/cinder_jackal_pass2_*.png`, captured
with `look.cmd cinder_jackal 2`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 5 | 7 | 8 | 7 | **32** |
| 2 | 6 | 7 | 7 | 8 | 7 | **35** |

### Both diagnosed fixes applied

- **Proportion (5 → 7).** The spine ridge (`b.limb(...)`, `tools/blender/cinder_jackal.py`)
  dropped 0.09 in Z at every control point (1.53/1.60/1.58/1.49 →
  1.44/1.51/1.49/1.40) so it sits against the torso's own top surface instead
  of standing clear of it, and its end radii pulled from 0.03/0.02 down to
  0.01/0.01 so the tube tapers to a near-point instead of ending in the flat
  hex cap `limb()`'s `cap=True` draws at a non-zero radius — that cap was the
  "machined part" edge the diagnosis named. `cinder_jackal_pass2_34.png` and
  `_top.png` now show the ridge as a low tangerine stripe following the
  torso's curve; compare `cinder_jackal_pass1_34.png`, where it stands up off
  the back as a distinct raised bar.
- **Silhouette (5 → 6).** The tail's (`b.limb(...)`) far end dropped 0.15 in Z
  (0.42 → 0.27). `cinder_jackal_pass2_side.png` now shows the tail angling
  down and away from the torso; the flat wedge no longer continues the
  body's own horizontal line. The `_sil.png` change is real but
  smaller — pixel-diffed against `cinder_jackal_pass1_sil.png`, about 1.6% of
  the 64px silhouette changed, concentrated where the tail sits — the tail
  drops far enough to blend toward the leg cluster rather than reading as a
  clean horizontal spike, but does not fully separate into its own shape at
  64px. Not "shippable" (8) on this line yet.

`build.cmd cinder_jackal`: 1180/2600 tris, 1 mesh, no floating-part warning,
every climb Height and the sigil hold still `ok`. `run_tests.gd`: **ALL TESTS
PASSED**.

**+3 total (32 → 35), not a plateau — kept.** Build hygiene, colour and style
were not touched, per the brief; their scores are unchanged from pass 1.

## Unsure about, still

Same open questions as pass 1: whether the ridge's stiffness was a budget
constraint or a deliberate "ember" read (moot now that it sits flush — worth
revisiting only if a future pass wants a softer, multi-segment ridge), and
whether the tail reads differently mid-attack-animation in the real fight
camera than in this static capture. New from this pass: whether the tail
needs a further Z drop, or a sideways pull off the torso's Y-axis the way
`clot_toad`'s ridge-mounds fix widened its stance, to fully separate at 64px
— a further measurement a future pass could try, not a design call.
