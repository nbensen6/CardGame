# The 3D pivot

> Nick, 2026-07-28: *"build this as a 3D game, combats turn-based like Final
> Fantasy but with cards, progress like Slay the Spire — but you physically move
> to the next area in 3D space."*

## The headline: almost nothing has to be thrown away

`CLAUDE.md` §2's layering rule — `/core` must never depend on `/views`, `/input`
or `/net` — was written for exactly this moment, and it pays off completely.

| Layer | Fate | What it is |
|---|---|---|
| `/core` | **survives untouched** | Combat, Card, Run, RunMap, Boss, PlayerState, Content, Progress — every rule, 56 cards, 26 relics, 14 beasts, 10 events, 8 ascension tiers, and a tuned balance |
| `/session` | **survives untouched** | The authoritative host and its snapshot split. It broadcasts plain Dictionaries; it has no idea whether the client is 2D or 3D |
| `/net` | **survives untouched** | Co-op still works the same way |
| `ui/` | **mostly survives** | `CardView`, `Sfx`, `Music`, `Coach` are Controls/helpers — a 3D game still has a card hand and a HUD, drawn on a `CanvasLayer` over the 3D viewport |
| `/views` | **replaced** | The 2D `combat_view` becomes a 3D scene. This is the actual work |

**Proven, not assumed:** `views/combat_3d.gd` already renders live combat in 3D —
same `Session.client`, same `shared`/`private` dicts, same `CardView` hand — with
zero changes to `/core` or `/session`. Screenshot-verified.

## What 3D changes for the design (mostly upgrades)

**The climb stops being an abstraction.** Height was a number and a ladder of
squares. In 3D it is literal vertical position on the beast's body — a hunter at
the weak point is *visibly up there*. Shadow of the Colossus was the reference
all along; 3D is where that reference actually lives. The prototype already does
this: `foothold` lerps a hunter's world Y between the ground and the sigil.

**The map becomes a place.** `RunMap` is already a DAG — rows of nodes with
edges. That is trivially a *physical* layout: each node becomes a location in the
world, each edge a path you can walk. `pick_node(col)` stops being a button press
and becomes "you walked there." **All run structure, node types, and balance
survive**; only the input method changes.

**The art problem may actually get easier.** The 2D look failed because it was
four clashing styles (board-game icons + cartoon animal faces + fantasy borders +
flat vector). Kenney's 3D kits are **one coherent low-poly style across ~4,900
models** — cast, environments and props all match by construction. That is a
better starting point than the 2D situation ever was.

## What it costs (the honest part)

3D is a genuine multiplier on the *presentation* half of the project:

- **Camera work** is now a craft: framing a huge beast and a tiny climber in one
  shot, and moving between traversal and combat, is real design effort.
- **Animation.** Static models read as toys. The Animated Characters Bundle has
  rigged bases + 17 animations (idle/walk/run/attack/jump/death), which covers the
  hunters. Beasts would need their own.
- **Traversal is a new system** — a controller, collision, a navigable world, and
  a co-op question: do both players walk, or does one lead?
- **Scope discipline matters more, not less.** The earlier warning stands: this is
  a solo commercial project, and 3D widens every art task. The Early-Access framing
  in `ROADMAP.md` becomes *more* important, not less.

## Proposed build order

1. ✅ **Prove the architecture** — 3D combat client on live snapshots. *Done.*
2. ✅ **3D combat feel** — *Done.* Cinematic low camera with a negative `v_offset`
   so the 3D frame clears the card hand; hunters placed off the beast's real AABB
   (flanking on the ground, clinging to the flank mid-climb, standing on the sigil
   at the top) with tweened hops between holds; fully **procedural** animation
   since the Cube Pets models are static props — breathing, out-of-phase idle sway,
   recoil on hit; and the strike juice rebuilt in 3D as a burst OmniLight + dust
   particles at the sigil + camera shake. Intent shown in the top bar.
3. ✅ **The overworld** — *Done.* `views/overworld_3d.gd` renders the act you're
   in as a hex island (Kenney Hexagon Kit). Each node is one landmark tile that
   says what it is — watchtower = fight, castle = elite, cabin = rest, market =
   shop, wizard tower = event, mine = treasure, mountain = Titan — with the DAG's
   edges drawn as roads between them (bright = walkable now, faint = read ahead).
   Clicking a reachable landmark walks your hunter there, and **arriving** is what
   calls `pick_node()`. Verified end to end by the harness: a landmark is projected
   back to a screen point, that point is fed through the same raycast a click uses,
   the walk runs, and the run advances a row into combat.

   Node rows sit on even hex rows so the odd rows between stay clear; roads are
   drawn ribbons rather than laid tiles, because a hex is far too coarse to say
   *which* edges exist (the first attempt paved nearly every row).
4. ✅ **One 3D loop** — *Done.* `views/game_3d.gd` routes on the authoritative
   `phase`: map -> the overworld, combat -> the 3D fight, everything else -> the
   2D client, which still owns event / campfire / shop / reward / won / lost.
   The menu now boots this instead of the 2D view, so the 3D path is the game.
   The fallback is deliberate: those phases have no 3D staging yet, and a 2D
   screen beats blocking the loop on art that doesn't exist. Verified by driving
   a whole lap — map -> combat -> reward -> map — and asserting which client is
   mounted at each phase, not just that it didn't crash.

5. **Traversal co-op** — how two players move together.
6. **2D-client parity** — what the 3D fight still owes the 2D one. Making the
   router the default turned every gap into a live regression, so these were
   closed straight away: the real-time **grip timer** (3D had timed cards but no
   climb clock, so leaving a hold cost nothing), the **multi-pick cards** (Burn
   Coal / Catapult / Meld were literally unplayable — the hand only ever sent
   `play_card(index, hit, slot)`), the **party panel** (a co-op game showing
   nothing about your ally), and the **coach**.

   The **combat log** is now ported too, so the 3D fight owes nothing it can't
   argue for: the only 2D feature not carried across is the climb's ladder
   readout, and that's deliberate — Height IS the hunter's position on the beast
   now, so a row of rungs would restate what the scene already shows. "How far to
   the next ledge" still appears on the grip bar, which is when it matters.

   **Parity reached.** Retiring `combat_view.gd` is now only blocked by the
   phases it still owns (event / campfire / shop / reward / won / lost).

7. **Retire or keep the 2D client?** Keeping both costs double maintenance on every
   view change. Recommendation: keep `combat_view.gd` until the 3D one has feature
   parity, then delete it — the tests don't depend on it.

## Open questions for Nick

- **Camera in combat:** fixed cinematic angle (FF-style), or free orbit?
- **Traversal scale:** small diorama-ish areas per node, or one continuous walkable
  region per act?
- **Does the grip timer stay real-time** in 3D, or become a turn-based resource
  now that the fight is more deliberate?
