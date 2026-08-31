# thrasher — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/thrasher.py`.** Views: `design/renders/thrasher_pass1_*.png`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 8 | 6 | 5 | 6 | 7 | **32** |

## What is actually there

A low, splayed-leg newt: a long flat black body, an orange warning-colour
belly stripe carried down onto the legs, a pointed snout with two small red
eye dots, and a tail that curls sharply up and back over the spine like a
raised scorpion stinger. A thin grey crest juts out sideways near the tail's
base, carrying the gold sigil disc.

- **Silhouette** (`_sil.png`): the strongest of this batch — the raised
  curling tail against the low flat body reads as a distinct, recognizable
  shape at 64px, and reads *different* from the other quadrupeds in the
  cast rather than another generic hump-and-legs silhouette. This is
  exactly the "lash" pose the module doc is going for.
- **Proportion**: the flat crouched body and splayed legs read as newt, and
  the tail's curl is proportioned well against the body — big enough to
  read, not so big it overwhelms. The sigil crest is the one part that
  reads as added-on rather than grown from the body.
- **Build hygiene**: the sigil crest is a thin rod jutting sideways off the
  tail base with the gold disc riding its tip, visible clearly in side and
  top views as a separate stick-with-a-washer rather than a part of the
  creature — the same "orbiting part" pattern already named in
  `ART-REVIEW.md` for the Eyrie Hawk and Clot Toad, and scored the same way
  this batch in Silk Widow.
- **Colour & read**: the orange belly stripe against the black body is the
  strongest colour choice in the batch — it separates cleanly and would
  likely still read at 34px. The red eye dots pop against the black snout.
  The two dark tail-curl segments sit close in value against the black
  body and don't add much separation, but they're small enough not to hurt
  overall legibility.
- **Style consistency**: low-poly primitives, consistent bevel and palette
  with the rest of the fight-pool beasts.

## Diagnosis — two lowest

1. **Build hygiene (5).** The sigil crest reads as a floating rod-and-disc
   rather than a part of the tail. Concrete fix: same as Silk Widow this
   batch — thicken the crest's base and shorten it by roughly a third so it
   reads as a stub growing off the tail rather than a wire poking out to
   the side.
2. **Proportion (6).** The crest also pulls the eye away from the tail-curl
   silhouette that is this asset's best feature. Concrete fix: once
   thickened per above, consider moving the sigil mark onto the tail curl's
   own surface instead of a separate crest, so the sigil sits on a shape
   that's already reading well rather than adding a new one.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Nothing beyond the crest fix — this is the cleanest read of the batch, and
the open question is purely whether the sigil needs its own crest geometry
at all, which is a design call rather than a measurement.
