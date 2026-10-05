---
tags:
  - art
---

# Card frames: what real TCGs do, and what ours does

Research for the builder queue item "Research: card frames, against real TCGs"
(Nick, 2026-10-05: "the card template for the outer layer of the cards looks
low quality"). Done by the session so the builder can go straight to mocking.

Other games are **described**, never copied into this repo.

## What our card actually does, at hand size

Looked at `Tongue Snap` and `Leap` in `state=3d`, cropped at 3x:

1. **The border is a flat gradient strip**, yellow-olive, with a thin green
   line inside it. No bevel, no inner shadow, no thickness. It reads as a
   coloured outline around a rectangle rather than as a frame.
2. **The art is not in a window.** It fills the top of the card and stops at a
   hard horizontal edge where the text panel starts. Nothing contains it, so
   it runs straight into the border.
3. **The name ribbon overhangs the card** on both sides, and its ends are
   ragged.
4. **The cost orb floats outside the card entirely** — a green disc hanging
   off the top-left corner, overlapping the card beside it. No printed card
   has anything outside its own edge; this alone makes the hand read as UI
   widgets rather than cards.
5. **The type pill straddles the art/text boundary**, in a grey that appears
   nowhere else on the card.
6. **The text box has no fill of its own** — a slightly different dark, no
   rule, no inset.
7. **The edges alias badly**: stair-stepping and dotted artefacts along the
   border where the card is rotated in the fan.
8. **No rarity cue and no footer.** Nothing distinguishes a common from
   anything else.

## How real cards are built

The common structure, across every game below:

    outer edge (hard, usually black)
      └ frame plate (bevelled, has thickness)
          ├ title plate — name, and the cost set INTO it
          ├ art window — its own keyline; art never touches the frame
          ├ type bar — separates art from rules text
          └ text box — its own fill, inset, with a visible edge
      └ footer — rarity, set, artist

**Magic (M15 frame).** A black border at least ~2mm wide is a printing
requirement, and it does the visual work too: every card has a hard edge
against any background. Inside it, the frame is tinted by colour identity, and
the art sits behind the frame's inner edge so the frame overlaps the art
slightly rather than butting against it. Mana cost sits inside the title bar,
right-aligned. A tidy info line in the lower-left carries number, rarity, set
and artist. The whole frame is designed so art can slide behind the borders
while the text stays crisp.

**Pokémon.** A thick coloured border wrapping an inner frame; HP and type at
the top right, inside the frame; attacks in a boxed list with energy symbols
set in their own column. The border is treated as part of the illustration's
context, not as a cut line — it gives the art depth rather than merely ending
it. Rarity and set symbols sit in fixed positions, and the foil treatment is a
layer over the whole card, not a change of frame.

**Hearthstone.** The frame is a sculpted physical object, not a rectangle: an
irregular art window, ornament around the edges, and stats set into gems
embedded in the frame itself. The legendary gem and the gold premium border
are the rarity cue, applied consistently so the treatment is recognisable at a
glance. Because the frame is an object, the card reads as a card even at
thumbnail size.

**Runeterra / Marvel Snap.** Minimal by comparison, but they keep the same
three devices: a crisp outer stroke, an inset art area, and a strong cost disc
that sits **inside** the card's bounds.

## What makes a frame read as expensive

Six things, in the order they'd improve our card:

1. **A hard outer edge.** One dark stroke the whole way round. It is what
   separates a card from the scene behind it.
2. **Thickness.** A bevel — light on the top-left, dark on the bottom-right —
   so the frame reads as a raised plate rather than a painted line.
3. **The art is contained.** A keyline around the art window, and the frame
   overlapping the art slightly. Art touching the border always looks unfinished.
4. **Everything inside the card.** The cost belongs set into the frame or the
   title plate, never floating outside the silhouette.
5. **Distinct materials.** Title plate, type bar and text box are visibly
   different surfaces, not three shades of the same dark.
6. **A rarity cue in a fixed place.** One token that never moves.

## Three directions to mock

Each on our own cards — Tongue Snap, Leap, Scramble — at true hand size
(~160px tall), in a fan, over the fight, not on a white page.

**A — Carved obsidian.** The fight's own material. Near-black bevelled plate,
thin ember-orange keyline, cost set into a socket in the top-left of the
frame, name on a raised plate, type bar in the same stone, text box an inset
darker panel with a hairline rule. Rarity as the keyline's colour. Closest to
`TARGET-UI.png` and to the HUD item that follows this one.

**B — Printed card.** Magic's logic: hard black outer border, inner frame
tinted by card type (attack warm, skill cool), title plate with the cost
right-aligned inside it, art window with a keyline, a type line, a text box
with a light parchment fill so rules text is black-on-light and maximally
readable at hand size. The most legible of the three; the least like the rest
of our UI.

**C — Sculpted relic.** Hearthstone's logic: a thick ornate frame with an
irregular art window, the cost as a gem embedded in the top-left, the type as
a small ribbon across the base of the art, ornament at the corners. The most
expensive-looking and the most work; also the most likely to crowd the art at
160px.

**Fix in all three, regardless of which Nick picks:**

- the cost comes inside the card silhouette
- the art gets a keyline and stops touching the border
- the name ribbon stops overhanging the card's edge
- the aliasing on the rotated card edges is fixed
- a rarity cue exists, in a fixed position

## Sources

- [Card frame — mtg.wiki](https://mtg.wiki/page/Frame)
- [Card frame / border — mtg.wiki](https://mtg.wiki/page/Border)
- [How to Read a Magic: The Gathering Card — misprint.com](https://www.misprint.com/posts/how-to-read-a-magic-card)
- [Card Frames Part 2: Shadowverse and Hearthstone — write.as](https://write.as/itsphos4/card-frames-part-2-shadowverse-and-hearthstone)
