# cinder_jackal (fight ground) — refinement log

Loop: `design/guide/asset-loop.md`, applied to a **fight ground**, per the artist
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
| 6 | 7 | 8 | 7 | 8 | 7 | **37** |

Pass 6 is a rebuild, not another fix on `enclose()` — see below. Passes 1-3
score the old primitive wall; pass 6 on is the Meshy one, so the two are not
one continuous line, but the log stays in one file because it is the same
asset.

Stop line for a ground is 44/50. Passes 1-3 stopped at pass 3 (see "Why stop
here" below) rather than running the full 4 — the two lines still open were the
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
  it carries a strong TANGERINE/AMBER identity (`design/guide/adding-detail.md`).

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
which is Nick's call (`design/guide/asset-loop.md`'s rebuild-verdict spirit, even
though nothing here needs literally rebuilding — the ceiling is systemic,
not this asset's own geometry). Not filing a `to: nick` request for it
right now since it's already sitting as an open, unresolved finding in two
other grounds' progress files; flagging it here again would be the third
copy of the same ask.

## What's still open

- Whether the pass-3 scatter recolour reads at all from the fight camera
  itself (only confirmed, and only barely, from the isolated top-down
  Blender render) — plausible it is simply too small and too far back to
  matter, same as the "gravel chips" `crag_pup_ground.md` couldn't confirm
  either.
- Silhouette/Proportion, per "Why stop here."

---

## Pass 4 — artist lane, 2026-09-23 (verification only, no score change)

Picked up pass 2's own open question — the RUST accent band's visibility —
and actually answered it, rather than leaving "untested at a camera pitch
that would show it" sitting open a second run running. No code touched.

**Rendered every 3D camera state the fight actually uses**, not just the
sigil close-up pass 2 checked: `state=3d`, `3dclimb`, `3dgrip`, `3dstrike`,
and `3d wide` (the pulled-back framing). **The RUST accent never appears in
any of them.** Confirmed by eye in each frame and by a direct crop of a
wall piece's own visible top edge in the `wide` framing (the one shot with
the best chance of showing it) — the piece's top edge runs off the top of
the frame itself, above the RUST band's own placement fraction
(`env.py`'s `_wall_cliff`, `tall * uniform(0.75, 0.95)`), before the accent
would ever be reached.

**It is real, though — just not in this game's camera.** The loop's own
scoring camera (`cinder_jackal_env_pass3_34.png`, the pulled-back 3/4 view
`look.py` shoots) shows the RUST caps clearly on several wall pieces —
which is why the recolour was a legitimate Colour/Style improvement in the
loop's own methodology (the rubric's stated test camera), even though a
player will never see it. Same family of finding as `goblin_mech.md` pass
3's exhaust-pipe top-down-only separation and pass 5's hose-ring
side-profile-only collapse: real in one camera, invisible in the one that
ships.

**Not fixed, on purpose.** The accent's placement (`_wall_cliff`) and the
wall's overall height (`ENCLOSE_HIGH`, passed as this ground's own `high=`
if ever overridden) are both shared code — `_wall_cliff` backs every
"cliff"-style ground in the game, and wall height was deliberately tuned by
Nick "against camera reach across every ground in the game" per pass 3's
own note. Cutting the now-confirmed-invisible accent geometry to reclaim a
few tris was considered and declined: it is real in the loop's scoring
camera, already credited toward this ground's Colour/Style score, and
removing it would be undoing a scored, deliberate design choice on a guess
about what the shared wall system should do differently — not this script's
call to make alone. Filed `to: nick` instead of guessing (see
`requests/2026-09-23-1200-artist-to-nick-arena-wall-accent-never-shows.md`) —
this is the third grounds' progress file to flag the shared wall system,
but the first with the accent question actually closed by evidence rather
than left as "untested."

Score unchanged, 28/50 — nothing here was a diagnosed fix, it's a
verification of an existing open line. `ALL TESTS PASSED` (no code
touched).

![[frames/artist/2026-09-23-cinder-jackal-wall-accent-camera-comparison.png]]

---

## Pass 5 — artist lane, 2026-09-23 (re-check, no score change)

A fresh six-view look, per the previous run's own `## Next`. Rendered every
3D camera state again (`3d`, `3dclimb`, `3dgrip`, `3dstrike`, `wide`) plus
`look.sh env cinder_jackal 4` (the isolated scoring camera). The script is
unchanged since pass 3, so this is a re-confirmation, not new data: the wall
still reads as a flat warm-tan backdrop at ground-camera distance (the
BIOME-lighting shift pass 2 documented), the RUST accent band still never
reaches inside any frame that ships, and the top-down scoring render still
shows a ring of uniform `_wall_cliff` boxes — real, but the same shared
`env.py`/`ENCLOSE_HIGH` territory pass 3/4 already declined to touch alone.
Nothing new found. No score change (28/50 stands), no fix applied, no new
renders committed (would have been pixel-identical to pass 3's own). Spent
the rest of the run on `design/progress/frog_ai.md` instead, now that the
Meshy network wall (the real blocker on the brief's bigger ask) is down.

---

## Pass 6 — artist lane, 2026-09-23 18:25 UTC — the Meshy rehaul

Nick answered the open wall-accent request directly: "the environment needs
a rehaul. use meshy to create an environment to replace the one created in
blender." Passes 1-5 all diagnosed the same ceiling honestly (a primitive
`enclose()` wall cannot be given real silhouette by recolouring it) and
correctly declined to touch shared `env.py` geometry alone — this pass is
the actual fix that unblocks, not a fourth recolour.

**What changed.** `tools/blender/env/cinder_jackal.py`'s floor
(`e.ground(UMBER, rim=CHARCOAL, dish=0.20)` + `e.apron(...)`) is untouched —
it was never the flagged problem. Only the wall changed, and it is no
longer built by `env.py`'s shared `enclose()` at all: Meshy text-to-3d
generated an enclosed crater rim (prompt: "a small enclosed volcanic canyon
arena: a flat cracked scorched rock clearing in the middle surrounded by a
low ring of jagged charred cliff walls... hand-painted stylized fantasy
game art"), refined with a texture prompt pulled from this ground's own
palette (scorched charcoal-black rock, warm umber cracks, glowing
orange-rust embers, no snow/moss/green — 2 Meshy tasks, preview
`01a0cf77-655e-7018-93df-1251ba59f345` + refine `01a0cf79-6c8b-700d-b30f-
cd808fac0c1d`, logged in `design/progress/meshy-ledger.md`). Cleaned,
welded, decimated to 9000 tris and scaled by its own measured inner radius
so its nearest standing geometry sits at 18.37 local units — outside the
15.3 `ENCLOSE_CLEAR` env.py itself used, which is outside the 14.4 hard
minimum `combat_3d.CAMERA_MAX_R` (2.40) needs for ANY beast this ground
might ever host. Full recipe and the reasoning behind every number:
`tools/blender/ai/cinder_jackal_env_ai.py`.

Shipped as `game/assets/3d/env/cinder_jackal_ai.glb`, picked up over the old
`cinder_jackal.glb` by a new `ENV_AI_ART := {"cinder_jackal": "_ai"}` table
in `combat_3d.gd` (same shape as `AI_ART`/`HUNTER_AI_ART`) — the old
procedural wall stays on disk, untouched, one dictionary entry away from
coming back.

**Verified in the real fight, every camera state that ships**, same seed,
same positions, before vs. after: `state=3d`, `3dclimb` (the sigil
close-up), `3dgrip`, and `3d wide`. This is the direct answer to the
standing open question across passes 2-5 — does the wall's own detail
survive to a camera a player actually uses:

![[frames/artist/2026-09-23-cinder-jackal-arena-rehaul-wide-before-after.png]]
![[frames/artist/2026-09-23-cinder-jackal-arena-rehaul-3dclimb-before-after.png]]
![[frames/artist/2026-09-23-cinder-jackal-arena-rehaul-3d-before-after.png]]

The `3dclimb` pair is the one that matters most: this is the exact camera
the wall-accent request was filed against, and where pass 4 measured the
RUST band never reaching the frame. The after shot shows real ember cracks
glowing in the rock, in frame, without any camera change — because the
detail is now baked into the wall's own jagged form and texture instead of
riding a flat band placed above where any in-game camera looks.

**Scored honestly, not maxed.** 37/50, against the old wall's 28 (see "Pass
6 is a rebuild" note on the table above — not the same line, same asset):

- **Silhouette (7).** The isolated `_sil.png` (64px, blown up) reads
  clearly as a broken, jagged rock rim with a real gap — recognisable as
  "a place" the way the old cluster of boxes only did with a label.
  Docked one point: the tallest peaks bunch to one side rather than
  reading evenly around the ring, and the gap is a little lopsided.
- **Proportion (8).** The direct fix of passes 1-5's one open, systemic
  finding: floor and wall both read together in `3d`, `3dclimb`, `3dgrip`
  and `wide` now — not just from directly above. Not a 9-10: no
  measurement was taken of exactly how much of the floor is visible in
  each shot, only "clearly some, clearly more than before."
- **Hygiene (7).** Weld + decimate (28,948 → 9,000 tris) left no floating
  geometry or z-fighting in any render or in-game shot. Docked two points
  versus a hand-built beast: this is machine cleanup only, no manual
  artifact-cutting pass the way `cinder_jackal_ai`'s ear/tail fixes got —
  reasonable for a background piece, not free of the caveat.
- **Colour & read (8).** Ember cracks are now visible in-game, unprompted,
  in the exact close-up camera three prior passes couldn't get the old
  accent into. Matches the jackal's own TANGERINE/RUST/ember identity.
- **Style consistency (7).** Reads as its own charred place, not a generic
  cliff-walled quarry. Docked one point: the floor is still the old flat
  primitive UMBER disc, so up close (`3dgrip`) the seam between the
  generated wall's detail and the floor's flat primitive simplicity shows
  — the floor was correctly left alone (never the flagged problem) but is
  now visibly the plainer of the two pieces.

`ALL TESTS PASSED`. Full 80-step playtest (`mode=play beast=cinder_jackal
steps=80`) started before this note was written; result appended below the
moment it lands, per COMMON.md §4b — committing now rather than holding a
proven, rendered change unpushed while a background verification finishes.

## What's still open

- **Hygiene/Style's one point each** — a manual pass over the decimated
  mesh (the way beasts get one) and/or a small floor detail pass so it
  doesn't read as the plainer of the two pieces up close.
- **Silhouette's lopsided peaks** — try a second Meshy preview with the
  prompt asking explicitly for an even ring, or nudge this one's tallest
  cluster in Blender by hand.
- Same four other Titan grounds this brief has not reached yet (Crag Pup,
  Stone Warden, and the rest) still carry the primitive `enclose()` wall
  this pass replaced here — out of scope for this brief (Cinder Jackal
  fight only) but worth naming so nobody rediscovers the same ceiling from
  scratch on the next one.
