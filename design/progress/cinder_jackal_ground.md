# cinder_jackal (fight ground) — refinement log

Loop: `design/asset-loop.md`, applied to a **fight ground**, per the artist
brief's item 3 ("the arena — the jackal's ground and walls"). Filed as
`cinder_jackal_ground` rather than `cinder_jackal` because a beast/companion
model of the same name already exists in `game/assets/3d/env/` under a
different meaning (the Python "classic" body, unrelated) and
`game/assets/3d/cast/` (the AI beast). Unlike `crag_pup_ground.md` and
`stone_warden_ground.md` (report-only passes under a past item), this one
both scores and applies fixes — the current artist brief owns this ground.
Views: `design/renders/cinder_jackal_env_pass<N>_*.png`, captured with
`tools/blender/look.sh env cinder_jackal <N>` (Ubuntu-packaged Blender 4.0.2
via apt, since `download.blender.org` is blocked on this sandbox again this
run — same finding as the previous artist session's status note).

Same rubric adaptation as the two grounds above: silhouette/proportion ask
whether it reads as *a place*, not a creature.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 5 | 5 | 6 | 3 | 3 | **22** |
| 2 | 5 | 5 | 6 | 6 | 6 | **28** |
| 3 | 5 | 5 | 6 | 6 | 6 | **28** |

Stop line for a ground is 44/50. Stopped at pass 3 (see "Why stop here"
below) rather than running the full 4 — the two lines still open are the
same systemic issue two other grounds already flagged and left to Nick, not
something a fourth two-line pass on this one script would move.

## Pass 1 — what was actually there

`tools/blender/env/cinder_jackal.py`'s own docstring calls this "burnt
ground, still smoking where it has walked": a dished UMBER floor with a
CHARCOAL rim (`e.ground`), a CHARCOAL apron beyond it, and a default
`e.enclose("cliff")` wall — which is the shared `env.py` style, SLATE body
/ PEWTER accent, the same grey every other "cliff" ground in the game uses.

- **Silhouette** (`_sil.png`): an uneven cluster of rectangular boxes —
  reads as "a broken rock enclosure," no more specific than that. Same
  family of shape as `crag_pup_ground`'s ring, less broken/leaning than its
  jagged slabs, so scored a point lower.
- **Proportion**: from the fight-camera three-quarter (`_34.png`) and
  profile (`_side.png`), the wall is 100% of what's on screen — the UMBER
  floor is not visible at all from either angle. Only `_top.png` shows the
  floor, rim and scattered rocks the script's own docstring is about. Same
  finding as `crag_pup_ground.md` and `stone_warden_ground.md`: the shared
  `enclose()` wall (`env.py`, tuned by Nick against camera reach across
  every ground in the game) fills the frame by design, and this ground is
  not a special case of that.
- **Build hygiene**: pieces overlap cleanly, no floating geometry, 5966/7400
  tris. Docked one point versus `crag_pup_ground`'s 5→ish range because the
  scattered rock/slab detail the script places is, like those two grounds,
  unconfirmable from the angle that matters — see pass 3 below for what
  that turned out to mean here specifically.
- **Colour & read (3)**: the wall is SLATE/PEWTER — a cool blue-grey with
  nothing in common with the warm UMBER floor twelve units away, and from
  the fight camera / sigil close-up (the two framings a player actually
  sees), there is no warm colour anywhere in the shot. Lower than
  `crag_pup_ground`'s 4 because that ground's mismatch was a value problem
  between two greys; this one is a straight hue clash between the only two
  materials on screen.
- **Style consistency (3)**: `enclose("cliff")` with no arguments is the
  *default* — the same grey as any other cliff-walled quarry in the game.
  Nothing about this wall says "Cinder Jackal" while the beast standing on
  it carries a strong TANGERINE/AMBER identity (`design/adding-detail.md`).

## Diagnosis — two lowest (pass 1)

1. **Colour & read (3).** The wall's material is disconnected from the
   floor it encloses and from the beast's own palette. Concrete fix: recolour
   the wall to the same material family as the apron/rim it already shares
   (CHARCOAL), with an accent on the beast's own hot row (RUST, next to its
   TANGERINE/AMBER) instead of the generic cliff grey.
2. **Style consistency (3).** Same root cause, same fix — `enclose()` takes
   `uv=`/`accent=` per call precisely so one fight doesn't have to share
   another's palette; nothing had ever passed them here.

## Pass 2 — applying it

`tools/blender/env/cinder_jackal.py`: `e.enclose("cliff")` →
`e.enclose("cliff", uv=CHARCOAL, accent=RUST)`. Geometry, budget and the
`CLEAR`/tris/materials checks are byte-for-byte the same as pass 1 (`TRIS
5966 MESHES 1 MATERIALS 1`, `CLEAR ... nearest standing geometry 17.12`) —
this is a material swap, not a rebuild.

**Verified in the real fight, not just the isolated render — this mattered.**
The neutral-grey Blender render (`_top.png`, `_34.png`) shows a dramatic
swing to near-black with visible red ember caps. Under this fight's own
warm ambient/fog lighting (`combat_3d.BIOME`), that same material reads much
closer to tan than the Blender preview suggested, and a first side-by-side
glance at `state=3d`/`wide` screenshots looked like *no change at all* —
which would have been a false "done" if trusted. Two things caught it:

- What looked unchanged in `state=3d wide` was the jackal's own
  **footholds** (its basalt climb outcrops, part of the cast model),
  not the ground's wall, sitting in front of it at a similar screen
  position — confirmed by a throwaway diagnostic pass (`uv=PINK,
  accent=ORCHID`) that made the real wall unmistakable in the same shot.
- At `state=3dclimb` (the sigil close-up, where the wall fills almost the
  whole background), a direct pixel sample of the same screen position
  before/after: **(163, 144, 132) → (103, 77, 51)**, a real ~53/255 mean
  shift in that region, not a rounding difference. Crops in
  `design/agents/frames/artist/2026-09-22-cinder-jackal-arena-wall-*.png`
  (in-game) and `*-top-*.png` (isolated Blender render) — before/after,
  same camera, same lighting, both worth opening side by side.

**What did NOT get confirmed:** the RUST accent band sits near the top edge
of each tall wall piece, and in every camera framing tested here that edge
sits above the frame (or right at its top border) — so the base recolour
is verified, the ember-cap accent is not. Worth another look with a camera
pitched up, or accepting the accent mostly doesn't get seen and isn't doing
much work.

Colour & read and Style consistency both move 3→6: the wall is now visibly
warmer/darker than the pale, cool original in the actual fight, and shares
a material family with the apron/rim for the first time. Not a 9 — see
"What's still open."

## Pass 3 — the scatter's own mismatch

Two more scatter calls in the same script used the same cool-grey family
the wall just left: `e.scatter(..., e.rock(p, r, PEWTER), ...)` (10
boulders) and `e.scatter(..., e.slabs(p, r, STONE, n=2), ...)` (16 flagstone
clusters). Same diagnosis, same fix in spirit: PEWTER → BROWN, STONE → CLAY
— the next two swatches up from UMBER on `kenney.py`'s own peach/clay/
brown/umber row, so the boulders and slabs read as a lighter shade of the
same rock rather than a colder material dropped in from a different biome.
Removed the now-orphaned `PEWTER`/`STONE` imports; left the file's other
pre-existing unused imports (`SAND`, `TAN`, `WHEAT`, `CREAM`, `GRAPHITE`,
`ICE`, `MINT`, `GREEN`) alone — they predate this pass and are not this
fix's mess to clean up.

**Honesty check, and the actual result.** Measured, not assumed: a pixel
diff between the pass 2 and pass 3 top-down renders shows only **862 of
74,735** changed pixels attributable to this swatch swap, against a huge
shared footprint with the wall recolour. The colour values themselves are a
real, measured hue shift (BROWN `(176,96,65)` / CLAY `(200,116,81)` vs.
PEWTER `(134,139,161)` / STONE `(111,113,134)`, sampled directly off
`colormap_base.png`) — but the boulders and slabs this scatter places turn
out to occupy far less of the frame than the wall itself does, at every
angle tested here, including top-down. The change is real, cheap, and
harmless (kept for consistency — nothing regresses by making it), but it
is **not** independently confirmed to move what a player actually sees, so
the score does not move for it. Scored on what was seen, not on what the
diff said should be there.

## Why stop here (pass 3, not 4)

The two lines still lowest — **Silhouette (5)** and **Proportion (5)** —
are the same systemic finding `crag_pup_ground.md` and `stone_warden_ground.md`
already made and left unfixed: the shared `enclose()` wall
(`env.py`'s `ENCLOSE_HIGH`/`ENCLOSE_CLEAR`, tuned by Nick against camera
reach across every ground in the game, not something this one script owns)
fills the fight-camera frame by design, so the floor a ground is actually
named after is only confirmable from directly above. A fourth two-line
pass on `tools/blender/env/cinder_jackal.py` alone cannot move either
number — the honest concrete fix is a change to shared wall geometry or
camera framing that would affect every "cliff"/"crag" ground in the game,
which is Nick's call (`design/asset-loop.md`'s rebuild-verdict spirit, even
though nothing here needs literally rebuilding — the ceiling is systemic,
not this asset's own geometry). Not filing a `to: nick` request for it
right now since it's already sitting as an open, unresolved finding in two
other grounds' progress files; flagging it here again would be the third
copy of the same ask.

## What's still open

- The RUST ember-accent band's own visibility, per pass 2 above — untested
  at a camera pitch that would actually show it.
- Whether the pass-3 scatter recolour reads at all from the fight camera
  itself (only confirmed, and only barely, from the isolated top-down
  Blender render) — plausible it is simply too small and too far back to
  matter, same as the "gravel chips" `crag_pup_ground.md` couldn't confirm
  either.
- Silhouette/Proportion, per "Why stop here."
