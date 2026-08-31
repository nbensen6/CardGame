# husk_beetle — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/husk_beetle.py`.** Views: `design/renders/husk_beetle_pass1_*.png`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 5 | 5 | 6 | 8 | **29** |

## What is actually there

A rounded brown grub-like beetle: one big domed shell mass with a smaller
head-bump riding on top of it, four black spiked legs, a small head at the
front with two orange mandible points, two thin antennae, and a yellow-ringed
sigil disc mounted on a thin grey rod standing straight up out of the shell's
centre. A single dark line and a short diagonal notch are the only marks
suggesting a shell seam.

- **Silhouette** (`_sil.png`): reads as a legged blob with a small head notch
  at 64px — "bug with legs," not specifically "armoured beetle with two
  shell plates." Nothing in the black shape says "segmented" or "two
  ledges"; ART-REVIEW's own build note already called this a "pill-bug"
  read and the silhouette confirms it.
- **Proportion**: the two-hump body (head-bump riding the main shell) and
  four legs read as an insect at this size, matching intent.
- **Build hygiene**: 1384/2600 tris, 1 mesh, 1 material, nothing floating on
  the legs or mandibles. The sigil disc is the exception — it sits on a bare
  rod that visibly clears the shell surface by a wide gap in the side and
  top views, reading as a flag planted in the beetle rather than a marking
  on it. Same "orbiting part" failure named for Eyrie Hawk, Clot Toad and
  Silk Widow in earlier batches.
- **Colour & read**: brown shell, black legs, orange mandibles, yellow sigil
  — the sigil separates cleanly from the shell colour, but the shell's two
  humps are close enough in value that the "two segments" the intent
  describes do not read as two segments, only as one lumpy mass. Matches
  the existing ART-REVIEW note almost exactly.
- **Style consistency**: rounded primitives, dark spiked legs — sits fine
  beside the rest of the cast.

## Diagnosis — two lowest

1. **Silhouette / Proportion (5/5, tied).** The shell is one smooth mass;
   nothing breaks the outline into the "two-segment shell forming the two
   ledges" the build intent describes. Concrete fix: cut a visible notch
   or step in the shell profile between the head-bump and the main dome
   (drop the seam ~0.05 in Z where the existing dark line sits) so the
   silhouette shows two stacked lumps with a waist between them, not one
   continuous curve.
2. **Build hygiene (5).** The sigil rod holds it clear of the shell surface
   by roughly the rod's full length. Concrete fix: shorten the rod so the
   disc sits within ~0.03 of the shell surface, or delete the rod and mount
   the disc flush against the shell like the sigil placement on beasts that
   scored well on this line (e.g. Yoke Ox's sigil, which sits set into its
   yoke bar rather than floating above it).

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the antennae crossing visually in the three-quarter view (noted
already in ART-REVIEW as a perspective artefact, not a real mesh collision)
still reads as odd enough to dock Style — left out of the score here since
front and side views read clean, matching the existing note.
