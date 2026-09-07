# vine_weaver — refinement log

Loop: `design/asset-loop.md`. **Scoring pass only — item #83 is report, not repair;
no edits made to `tools/blender/vine_weaver.py`.** Views: `design/renders/vine_weaver_pass1_*.png`.
Hunter (1400 tri budget).

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 8 | 7 | 4 | 7 | 8 | **34** |

## What is actually there

A humanoid ent: a wide green foliage canopy on top of a brown trunk-torso,
two arms that fork into leaf-clump "hands," root feet with several toes at
uneven lengths, vines with leaves wound around the waist, amber eye-dots set
into the trunk, and a small purple gem sitting off to one side near the
vines.

- **Silhouette** (`_sil.png`): distinctive — wide canopy top, forked-arm
  bumps at the shoulders, a ragged root-foot base. This is exactly the
  "canopy wider than the trunk, top of the silhouette is a mass and not a
  point" the redesign intent asked for, and it clears the old lamp-shape
  problem the previous design had.
- **Proportion**: canopy, trunk, forked arms and root feet all read as
  "walking tree" and hold up beside the cast; canopy width doesn't
  overwhelm the trunk.
- **Build hygiene**: **1704/1400 tris — 304 over budget**, which the build
  note already flags as a deliberate call rather than an oversight. Scored
  on the rubric line as written ("within budget") this is a real fail
  regardless of the reasoning. Separately, the purple gem sits visibly
  clear of the vine mass in the side view — the same "orbiting part"
  failure named for several beasts (Eyrie Hawk, Clot Toad, Silk Widow,
  Husk Beetle) — it reads as a bead resting near the vines, not set into
  them.
- **Colour & read**: brown trunk, green canopy and hand-leaves, purple gem,
  amber eyes — separates well, nothing dark-on-dark.
- **Style consistency**: rounded low-poly, sits fine beside the cast.

## Diagnosis — two lowest

1. **Build hygiene (4).** Two separate issues, both concrete: (a) the
   304-tri overage is a named trade-off already on record — the fix, if
   Nick wants one, is to say which of canopy/forked-arms/six root-toes/two
   vines gives up tris, not something to guess at here; (b) the purple gem
   is spaced away from the vine surface — concrete fix: move it inward
   along its current offset by roughly its own radius so it nests into the
   vine coil rather than sitting beside it.
2. **Proportion (7).** Solid already; the only soft spot is the canopy's
   size relative to the trunk, which the build note itself flags as
   unjudged. Left as a genuine open question rather than a manufactured
   fix — it reads fine in this render, so no change proposed.

Not applying either — this item scores and proposes; a fix is Nick's call.

## Unsure about

Whether the 304-tri budget overage should be accepted as this hunter's
permanent cost of the Ent redesign, or trimmed — that's the trade-off the
build note already named and left for Nick, and nothing in this render
changes the terms of that call.

---

## Pass 2 — fixer lane, 2026-09-07

Applied by the **fixer** lane (`tools/fixer/BRIEF.md`), which repairs what the
cloud reports. Picked under the brief's screen-size-tier rule: every top-level
beast and all fourteen fight grounds were checked first and had no actionable
work left — the beasts are all sitting on an applied fixer pass awaiting the
cloud's next diagnosis, and every ground's item #83 pass explicitly proposed
no fix (budget overages, or claims that need the beast in-scene to check).
Vine-Weaver is a **hunter** (tier 3), tied for lowest actionable hunter score
with `mountain_climbers` (34 each); picked because its one diagnosed fix (move
the purple gem) is a plain measurement, where `mountain_climbers`' hygiene fix
asks for a choice between two different attachment designs for the cheek
shard — closer to a judgement call than a measurement. Views:
`design/renders/vine_weaver_pass2_*.png`, captured with `look.cmd vine_weaver 2`.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 8 | 7 | 4 | 7 | 8 | **34** |
| 2 | 8 | 7 | 6 | 7 | 8 | **36** |

### Only the applicable half of the diagnosed fix applied

**Build hygiene (4 → 6).** The diagnosis named two issues on this line: the
304-tri budget overage (explicitly left to Nick — "the fix, if Nick wants one,
is to say which... gives up tris, not something to guess at here") and the
purple gem sitting clear of the vine mass. Only the gem is a measurement;
the budget call is a design call and untouched, per the brief's hard rule
against moving a shared budget to make a fix pass.

The gem (`b.ball(path[-1], ...)` in `tools/blender/vine_weaver.py`) sat
exactly on the vine's own centreline (`trunk_r(z) + 0.030`), so it wasn't
spaced away from the vine radially — the problem was its own radius (~0.05)
being bigger than the tapered vine tip it sat on (~0.027), reading as a bead
resting on a thread rather than a gem grown from the coil.

First attempt: pulled it inward along its radial offset by its full own
radius (0.05), matching the diagnosis's literal wording. Rendered and
compared against pass 1 (`vine_weaver_pass2_34.png` at that point) and it was
a regression, not an improvement — the pull put the ball's centre inside the
trunk's own surface (offset 0.030, pulled 0.05), and it vanished behind the
trunk mesh entirely in the 3/4, front and side views. Caught by rendering
before writing anything down, same as the flicker_stag belly-ball case this
brief's example points at.

Reverted to a smaller pull, 0.025 (half the gem's radius), which keeps the
ball's centre just outside the trunk surface while its far half still
overlaps the vine coil's own volume. Confirmed in
`vine_weaver_pass2_34.png`, `_front.png` and `_side.png` against the
original `vine_weaver_pass1_34.png`: the gem now reads as sitting into the
trunk/vine mass at the mouth's base rather than as a separate bead beside it,
in every view checked, and is still visible in all three (not swallowed).
`_sil.png` unchanged — the gem was always too small to register there, in
either pass.

`run_tests.gd`: fresh headless run, Godot 4.7.1.1: **ALL TESTS PASSED**.

**+2 total (34 → 36), not a plateau — kept.** No line regressed.

### Not applied

**Proportion (7, unchanged).** The pass-1 diagnosis's own second line says
outright "no change proposed" — the canopy-to-trunk ratio "reads fine in this
render." Nothing to apply.
