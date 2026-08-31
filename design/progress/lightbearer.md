# lightbearer — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/lightbearer.py`.** Views: `design/renders/lightbearer_pass1_*.png`.
First scoring under item #83's rubric for a **hunter** (1400 tri budget, not
the 2600 beast budget) — the five-line rubric applies the same way.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 8 | 7 | 6 | 7 | 8 | **36** |

## What is actually there

A robed, hooded figure standing on a triangular-panelled cone skirt, holding
a tall staff topped with a lantern well above the head. A small dark
hood-face patch holds one gold eye-dot; a small separate orange orb floats
near the free hand at hip height.

- **Silhouette** (`_sil.png`): clean and distinctive — a narrow robed cone
  with the staff-lantern breaking the top of the outline well above the
  head. This is the tall-narrow-triangle shape the build intent names, and
  the only hunter whose highest point isn't part of its own body; it reads
  immediately as a spellcaster archetype.
- **Proportion**: robe, hood and staff read as a caster figure and hold up
  next to the other hunters. No visible legs or arms below the elbow, per
  the robe design — matches intent, and the existing note's worry about
  "unfinished" doesn't play out here; the cone skirt reads as a full
  garment, not a cut-off body.
- **Build hygiene**: 1312/1400 tris (96% of budget, no headroom left), 1
  mesh, 1 material. The small orange orb near the hand is not attached to
  anything — no visible arm, hand, or connecting geometry reaches it in any
  view — it reads as a stray floating ball rather than a carried light,
  which undercuts the "second light already caught" part of the class
  intent (the staff-lantern reads fine; the second light does not).
- **Colour & read**: tan robe, black hood-face, gold staff accents, orange
  orb — separates cleanly, nothing dark-on-dark. The face patch is very
  dark, which reads as "hidden under a hood" rather than a design flaw.
- **Style consistency**: fits the cast's rounded low-poly look; the staff
  reads as a weapon/prop the way other hunters' gear does.

## Diagnosis — two lowest

1. **Build hygiene (6).** The hand-orb has no connecting geometry to the
   body. Concrete fix: add a simple forearm/hand shape between the torso
   and the orb (even a short taper) so it reads as held rather than
   floating, or move the orb to sit directly against the robe's surface at
   the hip if a held pose isn't the goal.
2. **Proportion (7).** The face patch under the hood is small and mostly
   shadowed in the three-quarter and side views, so from most angles the
   figure reads as faceless. Concrete fix: not urgent, but if revisited,
   widening the gold eye-dot slightly or adding a second one would carry
   the "vessel with a face" read further without changing the silhouette.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the hood reads as a hood or a party hat, per the existing
ART-REVIEW note — this render doesn't resolve that either way; it's a
genuinely close call and worth a second, less flattering angle before
deciding.
