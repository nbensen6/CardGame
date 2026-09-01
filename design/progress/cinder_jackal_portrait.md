# cinder_jackal — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/cinder_jackal.png`
(512x512). Batch 11 of #83; rubric defined in full in `frog_portrait.md`.

Unlike `frog`/`eyrie_hawk`/`flicker_stag`, this portrait is framed as a full
side-on standing shot rather than a head-and-shoulders crop — all four legs
and the whole body are in frame, the head is small relative to the canvas.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 6 | 6 | 4 | 6 | 6 | **28** |

## What is actually there

A full-body three-quarter-side view: black wedge head with two pointed ears
and a gold eye dot, a rust-red barrel body, a mustard sigil disc on the
flank, an orange rectangular bar standing proud along the spine (the
"smouldering mane"), and four thin black legs.

- **Framing (6):** the whole animal fits in frame with headroom above the
  ears and clearance below the feet, but the full-body side-on crop leaves
  the head small and off to one side rather than centred as the identity
  anchor the way the head-and-shoulders convention (frog, eyrie_hawk) does.
- **Identity (6):** the black wedge head with pointed ears and the overall
  quadruped stance read as "jackal/dog" at a glance, but nothing in the
  crop signals "ember/fire" beyond the warm body colour — the module doc's
  "smouldering mane" identity marker is present but doesn't read as fire.
- **Readability @ 34px (4):** confirmed via a real 34px downsample. The
  four thin black legs nearly disappear into faint vertical smudges, the
  mane bar and body merge into one rust-orange mass with no separation, and
  the sigil disc is barely a lighter blob within that mass. Weakest line
  of this batch — the full-body crop puts most of the frame's area on thin
  legs and background, leaving little pixel budget for the parts that
  actually carry identity.
- **Colour & separation (6):** the black head/legs separate cleanly against
  the rust body, but the mane bar's orange and the sigil's mustard sit close
  enough in hue to the surrounding red-brown body that neither pops as its
  own element, matching `cinder_jackal.md`'s own colour-adjacent finding
  about the mane reading as a rigid bar rather than fur.
- **Style consistency (6):** the full-body side crop breaks from the
  head-and-shoulders convention every other scored portrait in this batch
  (eyrie_hawk, flicker_stag) and batch 9 (frog, vine_weaver, lightbearer)
  use — worth flagging as a possible outlier rather than a deliberate
  per-beast choice.

## Diagnosis — two lowest

1. **Readability @ 34px (4).** Concrete fix: tighten `portraits.py`'s
   `FOCUS` crop for this asset toward a head/shoulder framing like the other
   scored portraits, so the party-panel size spends its pixels on the head
   and mane rather than four thin legs and empty background.
2. **Identity (6).** Concrete fix: same root cause `cinder_jackal.md`
   already names — drop the mane bar's base into the spine so it reads as
   fur rather than a bolted-on rectangle; that fix would also help this
   portrait's identity read directly.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the full-body side-on crop is this asset's own `FOCUS` entry in
`portraits.py` (a deliberate per-asset choice) or an oversight that should
match the head-and-shoulders convention most of the cast uses — this
scoring pass can see the difference but not its cause.
