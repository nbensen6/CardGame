# Why it feels awkward to play — a reflection

**2026-08-15.** Prompted by Nick: *"the game still feels awkward to play"*, naming
damage numbers, condensed information, parentheses, right-click explanations, and
keywords. All four are real and none of them exist today. This is what's underneath
them.

---

## 0. The root cause: the game has no vocabulary

Slay the Spire's cards do not explain their own rules. They name them.

> **StS:** "Deal 8 damage. Apply 2 **Vulnerable**."
> The card says *what*. "Vulnerable" is gold text — a signal that a rule exists.
> The tooltip says *how*: takes 50% more attack damage.
> **You learn it once. Every card that uses it is then three words long.**

Ours try to be their own rulebook:

> "Expose: its next 2 hits taken deal +4."
> "Time it! 3 dmg (+4), +3 per EACH hunter's Height."
> "Deal 5 damage, +3 for each Exposed stack on the Titan."

Every card re-teaches the mechanic, forever, in the smallest space in the game. The
first card above is literally a card explaining its own keyword.

**This is why the text-length pass earlier today was treating a symptom.** The text is
long because there is nowhere else for the rules to live. Shortening it just makes the
same explanation terser. The fix is a **keyword layer** — name the mechanic, explain it
once somewhere reachable, and let the card say the name.

The good news: **most of the mechanics are already named.** Poison, Expose, Rhythm,
Strength, Block, Height, Taunt, Grip. The naming work is largely done. What's missing
is the tooltip that makes the names mean something, so the card can stop explaining.

The one unnamed mechanic is the most-used: **the timed bonus.** `(+N nailed)` appears on
39 cards and is pure inline tooltip. That is exactly the parenthesis problem.

---

## 1. The thing not on the list, which may be the biggest

**The player is doing arithmetic on every card, every turn.**

> "Time it! 3 dmg (+4), +3 per EACH hunter's Height."

To know what that does, you must find your Height, find your ally's Height, multiply,
add, then branch on whether you'll nail the timing. Every turn, for every card in hand,
while a real-time grip bar drains.

**Slay the Spire never asks you to compute anything.** Strike reads "Deal 6 damage" —
but with 3 Strength against a Vulnerable enemy the card face itself shows the real
number. The template is static; the number is live.

We already do this for one field. The snapshot sends `"cost": _run.combat.effective_cost(pi, c)`
— the *computed* cost, not the printed one, so Burn Coal's discount shows on the card.
**The pattern exists; it just stops at cost.** Extending it to damage, block, and climb
is the same move, and it would delete most of our card text as a side effect: a card
that shows the real number doesn't need to explain its formula on the face.

That, more than shorter wording, is what "condensed information" actually means.

---

## 2. The four things, mapped

### Damage numbers on screen
**Missing entirely.** Today a hit produces a light flash (`_flash`), camera judder, a
sound, and **a line of text in the log**. The number — the thing you actually care
about — lives in prose, four lines down, in the corner.

So the loop is: play card → something flashes → *read* to find out what happened. That
is the awkwardness. Numeric feedback should be at the point of impact, not in a
transcript.

Worth being clear: this game is **not** short on juice. It has impact flashes, dust,
arena shake, HP danger colours, per-beast bodies, emotes, sound. It is short on
*numeric* feedback specifically. That's a narrow, cheap gap.

### Condensed information
Downstream of §0 and §1. With keywords and live numbers, "Time it! 3 dmg (+4), +3 per
EACH hunter's Height." becomes **"Time it! Deal 24."** — with 24 highlighted because
it's scaled, and the *why* one tap away.

### Parentheses
`(+N nailed)` is a tooltip pasted inline on 39 cards. Options, in order of preference:

1. **Name it.** Make "Nailed" a keyword with a tooltip. Card shows both numbers with
   the bonus in gold: **`3 → 7`**.
2. **Symbol it.** A timing glyph carries the meaning; the card shows only the nailed
   value in the timing colour.
3. Keep parentheses only where the two outcomes are genuinely different *effects*
   rather than different numbers.

### Right-click to explain
**Doesn't exist.** And note `CLAUDE.md` §5 forbids hover-only information because of the
eventual mobile target — so the mobile-safe equivalent is **tap-to-inspect** or
**tap-and-hold**, which §5 already anticipated and nobody built. This is the single
missing UI affordance that most of the above depends on: you cannot move rules off the
card until there is somewhere for them to go.

---

## 3. Other things StS has that we don't

- **Incoming-damage preview.** StS shows the enemy's intent *and* you can see whether
  your Block covers it. We show intent icons (good) but no "you will take 7 through 4
  Block" reckoning.
- **Pile counts.** Draw/discard/exhaust counts are always visible in StS. Ours are not
  surfaced, which matters a lot for the Goblin, whose whole kit now scales off the
  exhaust pile — `damage_per_exhausted` is invisible to the player.
- **Card highlighting when unplayable.** We send a `playable` flag; StS dims and greys
  hard so the hand reads at a glance.
- **A stable place to look.** StS's board never moves. Our camera orbits and the beast
  is enormous, which is great for spectacle and bad for reading numbers off.

---

## 4. What to build, ranked by impact per unit of work

| # | Change | Why it's first | Cost |
|---|---|---|---|
| 1 | **Floating damage numbers** at the point of impact | Closes the read-the-log loop. Pure feel, no rules change, no data change. | Small |
| 2 | **Live card values** — extend the `effective_cost` pattern to damage/block/climb | Deletes the arithmetic homework and shortens most card text automatically | Medium |
| 3 | **Tap-to-inspect card detail** | The container everything else needs; already mandated by §5 | Medium |
| 4 | **Keyword tooltips** (Poison, Expose, Rhythm, Nailed, Armoured, Grip) in the inspector, gold in card text | Lets cards stop re-teaching; makes 39 cards shorter at once | Medium |
| 5 | **Exhaust/draw/discard counts** on screen | The Goblin's new scaling is currently invisible | Small |
| 6 | **Incoming damage vs Block** readout | Turn decisions stop being guesswork | Small |

**1 and 5 are small and independent** — they can ship first and would be felt
immediately. **2, 3 and 4 are one project**, and doing 3 before 4 is mandatory since the
tooltip needs a home.

---

## 5. What we should not change

- **The juice we already have.** Flashes, shake, dust, sound and per-beast bodies are
  working. The problem is legibility, not spectacle.
- **The double timing.** The grip bar plus timed cards is the thing that makes this game
  not-Slay-the-Spire. Awkwardness here is a *readability* problem — the player can't
  tell what a card will do fast enough to act under time pressure. Fix the reading, not
  the clock.
- **Card text style.** The house style from earlier today still holds; it just gets much
  easier to obey once keywords and live numbers carry the load.
