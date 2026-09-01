# eyrie_hawk — portrait scoring log

Loop: `design/asset-loop.md`, adapted for 2D per backlog #83. **Scoring pass
only — report, not repair.** Asset: `game/assets/portraits/eyrie_hawk.png`
(512x512). Batch 11 of #83; rubric defined in full in `frog_portrait.md`.

## Score

| Framing | Identity | Read@34px | Colour | Style | Total |
|---|---|---|---|---|---|
| 8 | 7 | 6 | 6 | 8 | **35** |

## What is actually there

A head-and-shoulders three-quarter crop: a brown feathered head with two
small ear-tuft points, black dot eyes, a curved beak, a blue-grey body/wing
mass, a cream belly patch at the bottom edge, and a gold sigil disc that
sits beside the neck with a visible gap to the body.

- **Framing (8):** generous headroom above the head, the beak and both eyes
  fully in frame, body and belly patch visible at the bottom edge for
  context — same convention as `frog_portrait.md`, working well here too.
- **Identity (7):** the hooked beak and feathered head read as a bird of
  prey clearly; docked because the ear-tuft points read slightly more
  mammalian than avian at a glance before the beak resolves it.
- **Readability @ 34px (6):** confirmed via a real 34px downsample. The
  head and beak stay legible as a bird shape, and the gold sigil disc still
  shows as a distinct warm dot against the blue-grey body; the gap between
  the sigil and the body — the "orbiting part" issue `eyrie_hawk.md`
  already named — is no longer visible at this size, which reads as a
  minor improvement specific to the 34px crop rather than a fix.
- **Colour & separation (6):** brown head against blue-grey body separates
  well, and the gold sigil pops against both; the cream belly patch sits
  close in value to the blue-grey wing at its edge, a soft rather than hard
  separation.
- **Style consistency (8):** matches the shared three-quarter head-and-
  shoulders convention on transparent background cleanly.

## Diagnosis — two lowest

1. **Readability @ 34px (6) / Colour & separation (6), tied.** Concrete fix
   for the sigil: same as `eyrie_hawk.md`'s own finding — move the disc
   flush against the shoulder plumage so the attachment reads correctly at
   full size too, not just relying on downsampling to hide the gap. Concrete
   fix for the belly/wing edge: shift the cream belly patch's value up
   slightly so its boundary against the blue-grey wing stays crisp at both
   sizes.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the sigil's "orbiting part" gap reading as fine at 34px but still
visibly disconnected at full size (512px, in the party panel's larger
displays such as a campfire or deck view) means the fix matters less than
`eyrie_hawk.md`'s 3D finding implied, or whether this is just one crop angle
getting lucky — not confirmed either way.
