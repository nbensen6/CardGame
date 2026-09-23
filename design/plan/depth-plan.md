# Getting to Slay-the-Spire-level depth

> Written 2026-07-28 after Nick asked what separates this from StS.
> **The gap is not mechanics — it's decision density and run structure.**

## The diagnosis

The climb→strike→climb loop, the live grip timer, and four asymmetric classes are
genuinely distinctive — arguably more so than StS's core. What's missing is how
*often* the player makes a choice that compounds.

Strategic decisions in a Titan-Slayers run today:

| | count |
|---|---|
| Pick a character | 1 |
| Pick 1-of-3 cards after each fight | 4 |
| **Total** | **~5** |

A Slay the Spire run has **50–80**: which path, which node, fight the elite or
skip, which card, whether to *skip* the card, spend gold on a card / a removal /
a potion, every event choice, upgrade-or-heal at each fire.

StS is not deeper per fight. It's that every ~30 seconds you make a choice that
compounds. That's the whole difference.

## Current content (2026-07-28)
48 cards · 31 in the reward pool · 8 relics · 4 titans · 4 characters

## The ordered plan

### 1. The map — the single biggest lever ✅ SHIPPED `f301e06`
Branching paths between fights with node types: **fight / elite / rest / event /
shop / treasure**. Mostly run-structure + UI work, very little new combat code.
The moment it exists, every run has a different shape and the player is choosing
constantly instead of riding a fixed rail of four titans.

**Shipped:** `core/run_map.gd` generates 4 acts × 3 branching rows + a Titan row,
seeded and connectivity-guaranteed. Node types live: fight / elite / rest /
treasure / boss, with six lesser beasts backing the fight and elite nodes. The
route is a shared choice (either hunter may step).
**Edges drawn** (`ui/map_edges.gd`) — open steps bright, the rest faint, so a
route can be planned several rows ahead.
**Events shipped** (`a7ae962`) — 10 hand-written wayside choices; they bruise but
never kill, and their stakes are printed on the button.
**Still to do here:** **shop** nodes (needs a gold economy).

### 2. Deck *transformation*, not just addition ✅ SHIPPED `18656c7`
Cards currently only get added, so every deck converges on "my 10 starters plus
whatever showed up." The three missing pressures:
- **Card removal** (the most valuable purchase in StS)
- **Upgrades** (a `+` version of each card)
- **Skipping a reward** as a real strategy (keeping the deck lean)

Without these a deckbuilder can't *sharpen* — it only bloats.

**Shipped:** rest nodes became **campfires** — each hunter chooses Rest (heal),
Thin (remove a card, floors at 5), or Sharpen (upgrade). `Card.upgraded_copy()`
is one generic rule (bump the numbers a card uses; if it has none, cost -1) so
new cards get upgrades free. Rewards are **skippable**.

### 3. Fight variety — not every fight is a titan ✅ SHIPPED `d31c629`
Specific to our mechanic: the climb is slow and ceremonial, so it should feel
like an act boss. All four fights are currently the same shape, so the ritual
never varies. Add quick regular fights that *twist* the climb — a low-slung beast
with a ground-level weak point, a swarm that punishes being separated, an enemy
that rewards staying at the base.

**Shipped:** four move types that bend position — `swipe_low` (only hunters on
the ground), `swipe_high` (only hunters off it), `rift` (damage scales with the
Height GAP between hunters), `shift_sigil` (the weak point moves mid-fight) — and
four beasts built around them. The intent row computes conditional targeting, so
the twist telegraphs itself.

### 4. Relics that change rules, not numbers ✅ SHIPPED `c10a366`
8 relics today, mostly flat bonuses. They should hook our unique systems:
*"timed windows are 1s longer," "start each fight at Height 2," "Rhythm doesn't
reset between turns," "falling costs no HP."* ~30 of those and runs feel authored.

**Shipped: 26 relics**, most of them rule-changers hooked into the climb, the
grip timer, timing windows, Rhythm and the weak-point threshold. Two are
client-side (grip seconds, timing width) and travel in the snapshot.

### 5. Archetype-aware reward pools ✅ SHIPPED `358bf5d`
The 31-card pool is shared across all four characters, so you can't draft
*toward* anything. Each class needs its own pool containing 2–3 discoverable
archetypes (Frog: rhythm-chaining vs. hit-and-run; Goblin: gadget-spam vs.
one-huge-swing). "I'm building the poison deck this run" is the missing feeling.

**Shipped:** every character has its own `reward_pool` (archetype cards +
neutrals); each hunter drafts from theirs, so two players build different decks
off the same fight. Eight new cards seed the archetypes, plus a `rhythm` card
field so the Frog's combo has a starter.

### 6. Ascension ladder + unlocks ✅ SHIPPED
The long tail — last. Reason to play run #20.

**Shipped:** 8 cumulative tiers (`data/ascension.json`), unlocked by clearing the
one below and persisted in `user://progress.cfg`; chosen at the menu.

**All six items are now shipped.** Remaining known gaps: shop nodes (needs a gold
economy), and a real balance pass — the run is deliberately untuned while the
structure was moving (see the memory note on not balancing yet).

Content as of this pass: 56 cards · 26 relics · 14 beasts (6 fight / 4 elite /
4 Titan) · 10 events · 8 ascension tiers · 4 characters with their own pools.

---

## Art direction — why the current placeholders don't work

Three separate problems, and only one is about which assets were picked:

1. **Style collision.** Four incompatible visual languages at once: flat
   monochrome board-game icons, round cartoon animal faces, ornate fantasy UI
   borders, flat vector landscape. No shared line weight, palette, or detail level.
2. **Tonal mismatch with our own pillar.** "Tiny creatures vs. colossal beasts" —
   but a cute round animal *face* in a box is not colossal. The art fought the hook.
3. **Recognizability.** Kenney is the most-used free library in existence; players
   and curators clock it instantly as prototype art.

**Composition was the first fix — done (commit 8e519df).** The beast now fills the
arena and hunters climb *on* it toward a glowing weak point. This cost no new art
and it makes the eventual art brief concrete: *a tall, climbable body with a
marked weak point*, not a headshot.

### Sourcing options, honestly costed
- **Commission** (~$1–3k for 4 characters + 6 beasts + UI kit) — best result, but
  only after the loop is locked and the composition is settled, or you pay twice.
- **Learn it yourself** (Inkscape, flat vector) — very achievable if the style is
  built on *shape* rather than detail. High-contrast silhouettes with a tight
  palette hide a non-artist's weaknesses and read at any size.
- **Style-lock first, source second** — write the rules down ("black silhouettes,
  three colours, one accent, no gradients"), then everything made *or* bought gets
  filtered through them. This is what turns mixed sources into a coherent look.
