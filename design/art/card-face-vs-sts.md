# The card face vs Slay the Spire — element by element

**2026-08-15.** Prompted by Nick: *"BLK? is that supposed to be block? just have
block.... then it says gain 5 block below. that doesn't make sense."*

He was right, and the diagnosis matters more than the fix.

---

## 0. What I got wrong

The first pass at "live card values" **added a readout line above the authored text**
instead of replacing it. So Brace read:

```
5 blk                  <- invented abbreviation
Gain 5 Block.          <- the authored text, saying the same thing
```

Two lines, one fact, one of them in an abbreviation nobody asked for. That is worse
than the original, because now the card contradicts itself in tone and wastes the
scarcest space in the game restating itself.

**Slay the Spire never does this.** A StS card has exactly one description. Strike
says "Deal 6 damage." With 3 Strength it says "Deal 9 damage." — the *number inside
the sentence changes*, highlighted (lawngreen, bold). There is no second line, ever.

Fixed: the face now writes **one sentence from what the card will actually do**, in
full words, with live numbers. The authored text — which explains a card's *shape*,
like "+3 per Rhythm" — moved into the inspector where there is room for it.

```
Before:  5 blk / Gain 5 Block.
After:   Gain 5 Block.

Before:  2→5 dmg  +2 climb / Time it! 2 dmg (+3 nailed), +3 per Rhythm, hop +1.
After:   Time it! Deal 2→5 damage. Climb +2.
```

---

## 1. Element-by-element

| Element | Slay the Spire | Ours | Status |
|---|---|---|---|
| **Cost** | Orb, top-left | Gold pip, left | ✅ equivalent |
| **Name** | Banner across the top | Plain label | ✅ fine |
| **Art** | Large illustration, ~40% of the card | A 42px shared icon | ❌ **11 icons for 136 cards** |
| **Type** | Frame *shape* — attacks pentagonal, skills rectangular, powers circular | `type` is data-only; nothing on screen | ❌ **invisible** |
| **Rarity** | Banner colour | Only in the inspector | ❌ **invisible on the face** |
| **Description** | ONE line, dynamic numbers inline | ONE generated sentence, live numbers | ✅ **fixed today** |
| **Modified numbers** | Highlighted green when a buff changed them | Green when live ≠ printed | ✅ **fixed** |
| **Keywords** | Gold inline in the description + tooltip | Gold inline + inspector tooltip | ✅ **fixed** |
| **Inspect** | Right-click / hold | `?` button per card | ✅ equivalent, and touch-safe |
| **Unplayable** | Dimmed and greyed hard | `playable` flag exists, styling is soft | ⚠️ weak |

---

## 2. What's still missing, in the order I'd fix it

### ~~2.1 Modified numbers~~ ✅ done

The face body is a `RichTextLabel` now, so single tokens can be coloured:

- **Green** when the live value differs from what the card printed. Leap reads
  "Climb **+4**" with the 4 green for the Frog, because the class passive adds 1 —
  which is how a player discovers a passive is doing anything at all.
- **Amber** for the half of a timed card you only get by landing it: "Deal 2**→5**".

Colours are `CardView.LIVE_COLOR` / `NAILED_COLOR` / `KEYWORD_COLOR`.

### ~~2.2 Keywords inline~~ ✅ done

Every keyword in the generated sentence is **gold**, and only when the card genuinely
touches it — so the colour always means "there is a tooltip behind this word", never
decoration. The inspector's headline renders the identical BBCode, so the face and the
detail panel cannot drift.

### 2.3 Type is invisible ❌

An attack and a skill look identical. StS encodes it in the frame *shape*, which is
readable at a glance and in peripheral vision. We already ship a per-type tint in
`CardView.TINT` for the icon — extending that to the frame border is cheap. And note
the design doc still flags `type` as mechanically inert: either make it matter or
drop the field.

### 2.4 Rarity is invisible on the face ❌

It's in the inspector but not on the card, so a rare drafted mid-run doesn't *feel*
rare. StS uses banner colour; a border tint would do the same job here.

### 2.5 Art ❌

11 icons across 136 draftable cards, and 32 cards have no icon at all. This is the
biggest remaining visual gap and the least code — it's an art problem, and the icon
audit is still outstanding.

---

## 3. Where the text now lives

| Layer | Holds | Example |
|---|---|---|
| **Card face** | What it does, right now, live | *"Time it! Deal 2→5 damage. Climb +2."* |
| **Inspector — top** | The same sentence, larger | same |
| **Inspector — authored** | The card's *shape*: how it scales | *"Time it! 2 dmg (+3 nailed), +3 per Rhythm, hop +1."* |
| **Inspector — keywords** | The rules, explained once | *Timed · Rhythm · Height · Armoured* |

The authored `text` in `cards.json` is no longer what a player reads in combat. It is
the scaling note. That means the house style from earlier today relaxes: it can be
precise about formulas rather than fighting for characters, because it isn't competing
with the numbers any more.
