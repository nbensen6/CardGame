# Icon audit

**2026-08-15.** The last visual gap from `design/card-face-vs-sts.md`.

---

## 0. What was wrong

Slay the Spire gives every card its own illustration. We can't — 142 cards is a
commission, not a weekend. But the icon is doing the job art does in StS: telling you
what a card is *before you read it*. It wasn't doing that.

Measured before the audit, across the 136 draftable cards:

| icon | cards |
|---|---|
| climb | **27** |
| shield | **21** |
| sword | **20** |
| support | 16 |
| gadget | 11 |
| skull | 10 |
| …8 more | 1–7 each |

**14 icons for 136 cards.** A fifth of the catalog wore the same face. A hand read as a
column of near-identical tiles, so the icon carried no information and the name was
doing all the work — which is exactly the "hard to scan" feeling.

There was a second problem underneath: `GameHost._card_icon` *guessed* an icon from a
card's fields at snapshot time, so the choice lived in code and only knew 14 options.
Cards that did declare an `icon` had been authored against that same narrow set.

## 1. What changed

**Vocabulary: 14 → 25 icons.** Twelve more PNGs pulled from the Kenney Board Game
Icons set already in the bundle (258 available, so this cost nothing but curation).

| key | source | means |
|---|---|---|
| volley | dice_sword | multi-hit attack |
| guard | dice_shield | timed block |
| wall | structure_wall | block that scales as you replay it |
| ascend | character_lift | a big climb, or a primed one |
| rope | pawns | both hunters climb together |
| lift | hand_token_open | haul your ally up |
| target | card_target | strike that scales off Exposed |
| peak | structure_watchtower | strike that scales off Height |
| rhythm | spinner | the Frog's combo counter |
| timer | hourglass | timed, and nothing else to show |
| cog | puzzle | meld / fuse |
| burn | card_remove | exhaust a card |
| stack | cards_stack | draw |

**Choice moved from code into data.** `tools/cardlab/assign-icons.js` stamps an `icon`
onto every card in `cards.json`. The heuristic still exists as a fallback, but nothing
relies on it now, and any single card can be overridden by hand — the script never
overwrites an existing icon unless you pass `--all`.

**The ordering is the design.** The first attempt put class-signature fields first, and
produced 22 cards wearing `rhythm` and 19 wearing `skull` — the same problem moved down
a level, where a Frog's hand became one repeated badge. Shape now wins: *what does this
card do* (attack / climb / guard) before *what flavour is it*. A class reads from its
icon **mix**, not from every card carrying the class badge.

## 2. Result

| | before | after |
|---|---|---|
| Distinct icons | 14 | **25** |
| Most-shared icon | 27 cards (20%) | **16 cards (11%)** |
| Cards with no declared icon | 32 | **0** |

Per class, out of 41 pool cards each:

| Class | Icons shown | Its signature |
|---|---|---|
| The Frog | 16 | **rhythm** 10 · sword 6 · rope 3 |
| The Vine-Weaver | 16 | **fire** 7 · **skull** 6 · rope 4 |
| The Mountain Climbers | 14 | **peak** 9 · **lift** 7 · **rope** 6 |
| The Goblin Engineer | 18 | **burn** 8 · **gadget** 7 · **bomb** 5 |

That's the outcome worth having: each class's most common icons *are* its identity —
the Frog keeps a beat, the Vine-Weaver poisons, the Climbers work the rope and the
height, the Goblin burns and builds — while still showing 14–18 different faces, so no
two cards in hand blur together.

The Card Lab tracks both numbers now (Overview → Icons column, and a Health finding),
so this can't quietly rot as cards are added.

## 3. Still open

- **Tint is per-icon, not per-class.** Two classes using `rope` get the same hemp
  colour. Tinting by class would push identity further, at the risk of making the same
  mechanic look like two different things. Probably not worth it.
- **These are still shared symbols, not art.** A real illustration per card remains the
  StS-grade answer and is a commission, not a script. This makes the hand *scannable*;
  it doesn't make it *beautiful*.
- **`type` (attack/skill) is still invisible** and still mechanically inert — see
  `card-face-vs-sts.md` §2.3. Frame shape is where that belongs, not the icon.
