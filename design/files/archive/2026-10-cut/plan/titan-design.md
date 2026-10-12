# Design direction — Titan-slayers (Shadow of the Colossus inspired)

> Captures the creative north star. Not code. Mechanics here map onto systems we
> already have in `/core` (Combat, Boss, Card, Run) so most of this is data +
> small extensions, not rewrites.

## Why SotC fits our game (the key insight)

Shadow of the Colossus is: **find the weak point → reveal it (sword light) →
climb/hold on → drive the blade in.** That is *already* our co-op combo loop:
**Expose (reveal a sigil) → focus-fire (strike the exposed point).** So SotC
isn't a new system to bolt on — it's the theme that explains the systems we built.

The co-op twist on SotC's famous loneliness: **two wanderers, not one.** One
reveals and holds the beast's attention; the other strikes. The partnership *is*
the reinterpretation — and it's what no SotC-like has done.

## Pillars to honor

- **Every Titan is a puzzle, not a stat block.** Each colossus needs a distinct
  gimmick (a flyer you must ground, a guardian whose shield-arm you disable
  first, a burrower). Variety comes from *mechanics*, not just bigger numbers.
- **Scale & awe.** The Titan dominates the shared screen. Minimal, somber tone.
- **The weak-point loop.** Reveal → strike is the heartbeat of every fight.
- **Holding on.** Titans try to throw you off (our `attack_all` "shake"); block/
  grip cards are you clinging on.

## Cards (theme reframing + new ideas)

Existing mechanics, reflavored to SotC:
| Card | Mechanic (already built) | SotC framing |
|------|--------------------------|--------------|
| Expose | +vulnerable stacks | "Reflect Light" — the sword reveals a sigil |
| Slash / Cleave | damage | "Drive the Blade" — strike the weak point |
| Draw Aggro | taunt/redirect | "Hold On" — cling to the beast, draw its fury |
| Cover | ally block | "Steady" — brace your partner as it bucks |
| Rally | ally energy | "Whistle" — call your partner to the weak point |

New cards worth adding (small `/core` extensions):
- **Grip / Climb** — a shared "foothold" the team builds up; some sigils are
  "high" and only strikable once foothold ≥ N. Turns focus-fire into a two-step
  co-op setup (one climbs, one strikes).
- **Sunlight Blade** — bonus damage that scales with the Titan's current Exposed
  stacks (pure focus-fire payoff).
- **Bowshot** — cheap ranged chip that also reveals (light `Expose`); the "Agro
  + bow" ranged option.

## Titans (enemies)

Model each colossus as **multiple weak points (sigils)** plus a signature gimmick.
Our `Boss` already supports HP, block, `vulnerable`, `strength`, telegraphed
move patterns, `attack_all`, `enrage`. Add per-Titan gimmicks as data + a couple
of new move types.

Concept roster (original names — avoid SotC's IP):
1. **The Stone Warden** (have it) — the tutorial colossus. Slow, heavy, single
   sigil. Reskin flavor: a walking fortress of moss and stone.
2. **The Gale Serpent** (have it) — sky/wind. Gimmick: **airborne** — deals
   `attack_all` sweeps and can't be struck for full damage until "grounded"
   (a foothold/reveal check). Enrages as it circles.
3. **The Sunder-Ox** (new) — a charging bull-titan with a **shield-plate** you
   must break (high block) before its sigil can be exposed.
4. **The Drowned Colossus** (new) — submerges (gains block / untargetable) on a
   telegraph; the team must Expose during the window it surfaces.

New move types to support these (data-driven, small Combat additions):
- **submerge / guard-up** — become hard to damage for a round (reward timing).
- **shake** — an `attack_all` that also strips block (throws you off).
- **phase** — at HP thresholds, reveal a new sigil / change pattern.

## Tone & naming

Somber, awestruck, a little guilty. Titans get weighty names (Warden, Serpent,
Ox, Colossus). Card text is terse and evocative. Meta-progression hook for later:
felling a Titan **costs** something (SotC's price) — a run-level "corruption"
meter that escalates difficulty or unlocks, echoing the moral ambiguity.

## Build order for this direction

1. Reflavor existing cards to SotC names (data only). *(cheap, do anytime)*
2. Add the **Grip/Climb → high-sigil** system (foothold resource) — the core
   SotC co-op loop, extends Expose/focus-fire.
3. Add 1–2 new Titans with real gimmicks (submerge, shield-plate, phases).
4. Art pass once the loop is validated (see README / assets plan).
