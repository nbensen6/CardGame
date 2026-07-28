# Titan-Slayers — Development Roadmap

> **Goal:** Commercial Steam release.
> **Vision:** Ambitious / sprawling (many creatures, beasts, biomes, modes).
> **Strategy to get there without dying of scope creep: Early Access.**
>
> This is a living document. It decides *what the game is* so that "production"
> can happen on rails. When something here is a proposal, it says **(proposed —
> confirm/adjust)**. The designer owns the creative/business calls; Claude builds on
> rails, keeps the test suite + balance sim green, and maintains this doc.

---

## 0. The core tension, and how we resolve it

**Commercial + sprawling + solo = the classic "never ships" recipe.** The fix is
not to shrink the *vision* — it's to shrink the *first release* and grow in public:

- **North Star (sprawling):** the long-term game — lots of creatures, a bestiary
  of titans, multiple biomes, difficulty ladders, daily/challenge modes, unlocks.
- **EA-launch box (tight & finishable):** the smallest release that is genuinely
  *complete and fun* — a focused slice we can polish to a shine and sell.
- **Growth (public):** post-EA content updates, funded and steered by players, on
  a published roadmap, until **1.0**. Then post-1.0 expansions.

Rule we hold ourselves to: **nothing new enters the EA-launch box once it's
locked.** New ideas go on the *post-launch* list, not into the launch build.

---

## 1. Design pillars *(proposed — confirm/adjust)*

Every feature must serve a pillar, or it's cut. These keep an ambitious game
*coherent* instead of just big.

1. **Two hands, one mountain.** The fantasy is two small climbers cooperating to
   fell a giant. Every system reinforces interdependence — you must *combo*, not
   play two solo games.
2. **Climb → reveal → strike.** A Shadow-of-the-Colossus positional puzzle over
   each titan (Height/foothold to the weak point), not an HP-bar race.
3. **Asymmetric creatures.** Characters are mechanically distinct and *depend* on
   each other (a climber hauls a striker up; a striker pays off the climb).
4. **Readable depth.** Easy to understand, hard to master. Single-pointer,
   mobile-ready readability, no hover-only info (per CLAUDE.md §5).
5. **Charming but weighty.** Whimsical little creatures vs. huge, heavy, deliberate
   beasts. Tone is the capsule-art hook that makes us stand out in a crowded genre.

---

## 2. Milestone ladder (with the marketing track interleaved)

Each stage has an **exit test** — how we *know* we can move on.

### M0 — Prototype ✅ (essentially done)
Find the fun with placeholders. Online + solo co-op, climb loop, 4 characters, 4
titans, timing minigame, procedural SFX, placeholder art.
**Exit:** the loop is fun for 15 min and you want "one more run." *(Reached.)*

### M1 — Vertical slice ⬅ **WE ARE HERE (closing the gaps)**
*One* complete run at near-shipping quality — the thing a stranger can play
start→finish with **zero explanation**. This build *is* your future demo.
Gaps to close (see §4 for the ordered plan):
- **Onboarding / tutorial** ⬅ *next focus* — teach climb→reveal→strike with no words.
- **Run structure** — a map with path choices + events (the roguelike replay engine).
- **One difficulty setting that feels fair**, validated by a real human, not just the sim.
- **First real art pass** on the core (one biome, the 4 creatures, the slice's titans).
**Exit:** a stranger plays a full run unaided and asks to play again.

### M2 — Steam page live *(marketing track begins — do this AT M1)*
Store page, capsule art, short trailer/GIFs, wishlist button. **Wishlists take
months to accumulate and are the #1 predictor of a deckbuilder's launch.** Start
a devlog/community (Reddit, TikTok/YouTube shorts, a Discord).
**Exit:** page is live and collecting wishlists; you're posting progress regularly.

### M3 — Design lock (the content bible)
Freeze the EA-launch content list with **numbers** (§3). Decide what's in EA vs.
1.0 vs. post-1.0. This is the moment "keep adding content" *stops* and
"build the locked list" *starts.*
**Exit:** §3 targets are confirmed and frozen for EA.

### M4 — Production → Alpha (feature-complete)
Build every EA system + content to target counts. Content can be rough/unbalanced.
**Exit:** all EA systems present; a full EA-scope run is playable end-to-end.

### M5 — Demo + Steam Next Fest
A polished, self-contained demo (a few titans / one biome). Next Fest is a huge
wishlist spike — time it deliberately. Gather demo feedback + telemetry.
**Exit:** demo is stable, onboards players, and converts wishlists.

### M6 — Beta (content-complete) → balance → RC
No new content — only balance, bug-fixing, polish/juice, and **repeated human
playtesting** (the sim measures balance, not fun). Add a difficulty ladder.
**Exit:** a release candidate survives clean playthroughs; new players "get it."

### M7 — Early Access launch 🚀
Ship the tight, complete core commercially with a **public post-launch roadmap.**
**Exit:** it's on sale and stable.

### M8 — Public growth → 1.0
Content updates on a published cadence (new creatures, beasts, biomes, modes),
steered by player data + community. Then a **1.0** marketing beat (big update +
price/marketing push).
**Exit:** the sprawling vision is realized; game exits EA at 1.0.

### M9 — Post-1.0
Expansions / DLC, sales events, ports (Steam Deck verification, maybe mobile —
the single-pointer constraint keeps that door open).

---

## 3. Content targets *(proposed — confirm at M3 design lock)*

The vision is sprawling; the **EA box is deliberately small**. "Have" = built today.

| Content | Have | **EA launch (tight)** | 1.0 | Post-1.0 |
|---|---|---|---|---|
| Characters | 4 | 4 (polished, distinct) | 6–8 | +packs |
| Titans (bosses) | 4 | 6–8 | 12–15 | +tiers |
| Biomes / acts | 1 | 2 | 3–4 | + |
| Cards | ~30 | ~90–110 | 150+ | + |
| Relics | ~6 | ~30 | 60+ | + |
| Map events | 0 | 12–15 | 30+ | + |
| Difficulty ladder | 0 | 1 base + ~5 ascension tiers | 15–20 tiers | + |
| Modes | Solo + co-op | + tutorial | + daily/challenge | + |

**Note:** EA launch is ~1/3 of the 1.0 vision by design. That's the point — it's
finishable, sellable, and it proves the game before we build the rest.

---

## 4. The immediate plan — closing the M1 gaps

Ordered by your pick (onboarding first), then the rest of the vertical slice.

### Epic A — Onboarding / tutorial *(next up)*
Make a first-time player understand **climb → reveal → strike** and **co-op
dependency** without reading anything. *(proposed approach)*
1. **Scripted first encounter** — a gentle "training titan" (low HP, telegraphed,
   won't kill you) with **contextual coach prompts** that appear at the moment
   they're relevant: "Climb to the glowing weak point," "Now strike!", "Your ally
   can't reach — carry them up." Prompts dismiss on the action, not a wall of text.
2. **Progressive reveal** — introduce one concept per beat (play a card → energy →
   climb → the armored/weak-point gate → shake/knock-off → co-op combo).
3. **Contextual hints in normal play** — a first-time-seen cue for each new
   mechanic (a new card type, first enrage, first relic), suppressible.
4. **Empty-state guidance** — the hand/board tells you what to do when idle
   ("End your turn," "Waiting for ally").
**Verify:** a person who has never seen the game finishes the training titan
unaided. (Needs a real human — that's you first, then someone else.)

### Epic B — Run structure & variety (roguelike replay engine)
A **map** between fights (branching paths: fight / elite / event / rest / shop),
**events** (risk/reward text choices), and inter-run randomness so no two runs
feel alike. This is what makes a roguelike replayable — currently the biggest
"skeleton" gap after onboarding.

### Epic C — Difficulty that feels fair (human-validated)
One solid baseline tuned with *people*, not just the sim. Then the ascension-style
ladder later (M6).

### Epic D — First real art pass
Art direction for one biome + the 4 creatures + the slice's titans. Commission or
style-lock now that the loop is proven (per assets guidance). This is a **you**
call (taste/budget); I can prep specs, placeholders, and integration.

---

## 5. Who does what

**Claude drives:** systems & content code, the balance sim + tooling, UX/onboarding
implementation, refactors, keeping tests/sim green, and maintaining this doc.

**The designer owns (I can't):** *is it fun*, art direction & budget, real-human
playtesting, all business/marketing calls (Steam page, pricing, trailer, Next Fest
timing), and — most important — **keeping the EA box closed.**

---

## 6. Risk register

| Risk | Why it matters | Mitigation |
|---|---|---|
| **Scope creep** | #1 killer; sprawling + solo | The EA box (§0); new ideas → post-launch list only |
| **No wishlists at launch** | Deckbuilders need them; they're slow | Steam page at M1; devlog/community early |
| **Genre is brutally crowded** | ~212 RLDBs shipped 2025 | Lean on the co-op + climb hook; distinct capsule/tone |
| **Co-op needs 2 players** | Finding a partner is friction | Solo mode (done); strong matchmaking/Steam invites later |
| **Netcode across real machines** | Only localhost tested | Real cross-machine playtests before EA |
| **Balancing co-op is hard** | Two-player power spikes | The sim + human playtests each content drop |
| **Solo-dev burnout** | Long ambitious project | EA ships revenue + validation early; published cadence, not crunch |

---

## 7. Definition of "done" for EA launch

We ship EA when: the §3 EA targets are met; a stranger can onboard and complete a
full run unaided; one difficulty feels fair to human testers; the core has a real
art pass; cross-machine co-op works; and the Steam page + demo have done their job
on wishlists. **Not before, not (much) after.**
