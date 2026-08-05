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
2. **3D combat feel** — camera framing, hunters positioned on the beast, idle/attack
   animations, the strike/shake juice moved into 3D.
3. **The overworld** — render `RunMap` as physical locations with walkable paths;
   moving your character onto a node is how you choose the route. Node types keep
   their meaning (fight / elite / rest / event / shop / treasure / Titan).
4. **Traversal co-op** — how two players move together.
5. **Retire or keep the 2D client?** Keeping both costs double maintenance on every
   view change. Recommendation: keep `combat_view.gd` until the 3D one has feature
   parity, then delete it — the tests don't depend on it.

## Open questions for Nick

- **Camera in combat:** fixed cinematic angle (FF-style), or free orbit?
- **Traversal scale:** small diorama-ish areas per node, or one continuous walkable
  region per act?
- **Does the grip timer stay real-time** in 3D, or become a turn-based resource
  now that the fight is more deliberate?
