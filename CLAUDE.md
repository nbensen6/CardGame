# CLAUDE.md — Project Brief & Working Context

> This file is written for an AI coding assistant (Claude Code) and for the developer.
> Place it in the repository root. Claude Code reads `CLAUDE.md` automatically on open.
> Keep it updated as decisions are made — it is the single source of truth for *what* we're
> building and *why*, and the guardrails for *how*.

---

## 1. One-line pitch

A cooperative, roguelike **deckbuilder** where **two players team up against a boss**. Each
player has their own private hand; the boss and the battlefield are shared. Ships **premium on
PC first**, and is **architected from day one so a mobile version (and a "phones-as-hands,
TV-as-the-boss" casting mode) is a later rendering target, not a rewrite.**

## 2. The core architectural idea (read this first — it drives everything)

Design the game around a clean split between two kinds of view:

- **Private view (a player's hand):** the cards, energy, and choices only that one player sees.
- **Shared view (the board):** the boss, the battlefield, both players' health/status, the log.

Whether a player's *private view* is rendered in their own PC window today, or on their own
**phone** tomorrow, the networking and game logic are **identical**. Whether the *shared view*
is a PC screen today or a **cast TV screen** tomorrow, it's the same shared state.

**Consequence:** if we build this client/server split now, the flashy "phone is your hand, TV
is the boss" mode later is *just pointing existing clients at new displays.* We are NOT building
casting now. We are building the split that makes casting cheap later. **Do not couple game
logic to any specific display, input device, or screen layout.**

## 3. Platform & release strategy

- **Phase 1 target: PC (Steam), premium (buy-once).** This is where the paying deckbuilder
  audience already is (Balatro, Slay the Spire).
- **Mobile is deferred, not designed-out.** We make a small set of cheap decisions now (below)
  so the eventual iOS/Android port is input polish + store setup, not a rewrite.
- **Casting / second-screen mode is a Phase 3+ feature.** Architect for it; don't build it yet.

## 4. Open decisions (confirm with the human before locking in)

These are assumptions this document currently makes. Flag them; don't silently change them.

1. **Engine: Godot 4.x (GDScript)** is the assumed default — free/open-source (no engine
   revenue fee, which matters for a small budget), text-based scenes/scripts that are easy for
   an AI agent and version control, strong built-in high-level multiplayer, exports to
   Win/Mac/Linux + iOS/Android, 2D-first (ideal for a card game). **Alternative:** Unity (C#)
   if a larger asset store and hiring pool matter more. *Pick one before writing gameplay code.*
2. **Monetization: premium on both PC and mobile.** A free-to-play mobile economy would reshape
   progression/pacing and should be decided *before* building, not bolted on later.
3. **Theme/setting/art style:** undecided. Use neutral placeholder art and a generic
   fantasy-ish theme until the human decides. Do not invest in final art during prototyping.
4. **Netcode hosting model:** start with a Godot **authoritative host/server** (one player hosts,
   or a headless server build). Confirm whether launch is online co-op, LAN, or both.

## 5. Design constraints for "mobile-ready" (cheap now, painful to retrofit)

Honor these from the first line of UI/gameplay code:

- **Single-pointer input only.** A mouse click == a finger tap. No action may *require*
  right-click, hover, or a keyboard shortcut as its only path. Keyboard/mouse extras are fine as
  optional accelerators.
- **No hover-only information.** There is no hover on touch. Card details, tooltips, and
  keywords must be reachable by tap/click (e.g. tap-to-inspect), not hover-only.
- **Flexible, anchor-based, scalable UI.** Support widely different aspect ratios (tall/narrow
  phone vs wide monitor). Anchor and scale UI; never hard-code pixel positions for one
  resolution. Size interactive targets for a thumb.
- **Mobile-class performance budget.** Keep art and effects light enough to plausibly run on a
  mid-range phone. Card games are naturally light — just stay disciplined; avoid effects that
  would need redoing for mobile.
- **Cloud-save-friendly progression.** Design save/progression so it could follow a player
  across devices later.
- **Transport-agnostic networking.** Keep the netcode transport behind an interface so a phone
  client or a web/cast client can attach later without touching game logic.

## 6. Game design (the actual game)

Core loop (co-op roguelike deckbuilder vs boss):

- Each player controls a character with a **starting deck**; players progress through a run of
  encounters, earning/buying **cards**, relics/upgrades, and building **complementary decks**.
- **Combat is turn-based** against a boss/enemies on a **shared battlefield**. The design goal
  that separates good co-op deckbuilders from bad ones: players should **combo with each other**,
  not just play two solo games side by side. Build in shared resources, hand-offs, buffs that
  target the ally, or shared threat — mechanics that reward coordination.
- **Roguelike structure:** runs are the unit of play; permadeath/restart with meta-progression
  between runs. Reference points: Slay the Spire (combat/deck feel), Across the Obelisk and
  HELLCARD (co-op-vs-boss structure).

Design non-goals for the MVP: no PvP, no real-time combat, no procedural art, no live-ops
economy.

## 7. Build order (do these in sequence — validate fun before scaling tech)

1. **Single-player core loop first.** One character, a starter deck, one boss, turn-based combat,
   win/lose. **Prove it's fun with one player before adding networking.** If it isn't fun solo,
   co-op won't save it.
2. **The client/server split (the private-hand / shared-board architecture).** Refactor the
   single-player game so state is authoritative on a host and views are clients. Still testable
   on one machine (e.g. two windows).
3. **Two-player online co-op on PC.** Two clients, each with a private hand, sharing one board.
   Focus on co-op *combo* mechanics here.
4. **Content & balance pass.** More cards, more bosses, meta-progression. This is where the game
   lives or dies; budget the most iteration time here.
5. **Steam page + demo early** (can start in parallel with 3–4) to collect wishlists.
6. **Mobile port** — only once PC validates the loop. Input polish, UI reflow, store setup.
7. **Casting / second-screen mode** — private view on phone, shared view cast to TV. This is
   "attach existing clients to new displays," enabled by step 2.

## 8. Suggested repo structure (adjust to engine)

```
/                   # CLAUDE.md, README, license, .gitignore
/game               # engine project (Godot project.godot lives here)
  /core             # game rules & state — NO rendering, NO input, NO networking deps
  /net              # transport-agnostic networking layer (interfaces + impl)
  /views            # private (hand) view and shared (board) view — presentation only
  /input            # input abstraction (pointer-first)
  /data             # cards, bosses, relics as data files (JSON/resources), not hard-coded
  /ui               # anchor-based, scalable UI components
/design             # game design docs, card lists, balance spreadsheets
/tools              # build scripts, content pipeline
```

Key rule: **`/core` must not depend on `/views`, `/input`, or `/net`.** Game rules take inputs
and produce state; views render state; the network moves state. This separation is what makes
the display/input/platform swaps cheap.

## 9. Costs & fees (for planning)

- **Apple Developer Program:** $99/year (recurring; needed for iOS).
- **Google Play:** $25 one-time (lifetime).
- **Steam (Steamworks):** ~$100 one-time per app (Steam Direct fee, recoupable).
- **Store commission:** 15% while under $1M/yr (Apple Small Business Program / Google's first-$1M
  tier; Steam is 30% up to $10M). Rises to 30% above thresholds.
- **Engine:** Godot is free with no revenue share. (Unity has a free tier with revenue caps.)
- So the literal cost to *release* is roughly **$200–225 in year one** before commissions.

## 10. Market context (why this is worth building)

The deckbuilder genre is currently one of the strongest in games: Balatro sold 5M+ copies and
won Best Mobile at The Game Awards; Slay the Spire 2 made ~$92M in its first two weeks; Pokémon
TCG Pocket passed 150M downloads. Co-op is a proven way to *expand* that audience. The gap: the
best co-op-vs-boss deckbuilders (Across the Obelisk, HELLCARD, Aeon's End) are almost all
PC/Steam — nobody owns this on mobile, and no one combines it with a Jackbox-style
phone-as-hand / shared-screen format. That gap is the opportunity (and the reason to validate on
PC first, where the audience is proven).

## 11. Working agreement for the AI assistant

- Prefer the simplest thing that proves the current phase's goal. Don't build Phase 3 tech in
  Phase 1.
- Never violate the constraints in §5 (single-pointer input, no hover-only info, scalable UI,
  `/core` isolation) without flagging it to the human first.
- When adding cards/bosses/relics, add them as **data** in `/data`, not hard-coded logic.
- Keep game rules deterministic and testable; write unit tests for `/core` combat resolution.
- If a decision from §4 is still open and blocks progress, ask rather than guess.

## 12. 3D assets

Every 3D asset goes through the scored refinement loop in
**`design/asset-loop.md`** — build, capture, look, score, fix the two worst
things, repeat, max four passes. Do not generate an asset in one pass and call
it done.

The step that matters is *look*: render it and open the images. Eleven assets in
this repo passed every automated check and were still wrong, because a check can
prove a model meets its contract and cannot tell you it reads as a lamp.

- `tools\blender\look.cmd <asset> <pass>` — capture six views to `design/renders/`
- `design/progress/<asset>.md` — the score history for one asset
- `design/ART-REVIEW.md` — assets still waiting on a human eye
- `tools\blender\palette.py` — the shared colour atlas. Derives from
  `colormap_base.png`, so it is safe to re-run and the numbers in it always mean
  what they say. **Every model embeds the atlas**, so changing it means
  `build.cmd all` — cast, grounds, tiles, portraits and icons — or the game keeps
  drawing the old colours.
- Light lives in `combat_3d.BIOME`, not in the models. It is the cheapest
  identity this project can buy: a biome's key colour, ambient, fog and sky cost
  no rebuild and change every screenshot. Reach for it before reaching for
  geometry.
