---
tags:
  - agent-status
agent: artist
updated: 2026-09-23T21:12
working_on: fixed portraits.py's AI_ART table -- it only ever had cinder_jackal, so the party-rail/campfire portraits for both hunters were still rendered from the OLD Python-primitive frog.glb/goblin_mech.glb even though the fight itself moved to frog_ai/goblin_mech_ai weeks ago. Added frog and goblin_mech, re-rendered both portraits, verified in the real party rail. This was also the outstanding 34px Colour & read check both hunter notes had named as open: frog_ai now measures clean (8->9, total 41->42/50, AT the hunter stop line); goblin_mech_ai measures confirmed-still-duller (stays 8, 39/50) -- named the concrete next fix (tank-vs-body contrast). ALL TESTS PASSED. Lease released.
---

# artist

## This run — 2026-09-23 21:12 ET

- **Did:** the party rail's portraits for the Frog and the Goblin Engineer
  were still the OLD Python-primitive models — even though `combat_3d.gd`
  wired both hunters to their Meshy `_ai` rebuilds a while back,
  `portraits.py` (the separate tool that renders the 34px party-rail/
  campfire portrait) never got the same table update. A real fight
  screenshot showed the mismatch directly: the icon in the corner didn't
  match the hunter standing in the arena. Fixed the table, re-rendered both
  portraits.
- **Worked?** Yes — verified in the real party rail, before/after, same
  camera and state (frame below). This also happened to be the exact 34px
  Colour & read check both `frog_ai.md` and `goblin_mech_ai.md` had named
  as still-open (couldn't be measured until the portrait actually came from
  the right model): `frog_ai` measures clean and **crosses the 42 hunter
  stop line (41→42/50)**; `goblin_mech_ai` measures confirmed-still-duller,
  not worse, not better (stays 39/50) — named the concrete next fix (the
  tank reads too close to the body at that size).
- **Next:** `goblin_mech_ai`'s tank-vs-body contrast at 34px, or the
  193-island Hygiene question both hunter notes still list.
- **Need from you:** nothing.

![[frames/artist/2026-09-23-hunter-portraits-34px-old-vs-new.png]]
![[frames/artist/2026-09-23-hunter-portraits-party-rail-before-after.png]]

## Now

Checked for a fresh, unhandled answer under `## Nick's answer` on my own
`to: nick` notes first, per `COMMON.md` 1b — none. Checked open `to: artist`
requests — none this run. Worked the `JACKAL-BAR.md` queue: both hunter
notes (`frog_ai.md` pass 2, `goblin_mech_ai.md` pass 2/3) named the same
concrete open item — Colour & read "not verified at the 34px party-portrait
scale — `portraits.py`'s `AI_ART` table is beast-only" — so this run closed
that gap for both at once, one table edit.

**Confirmed the bug first, in the real game, not just in the code.**
Rendered `state=3d beast=cinder_jackal` and looked at the party rail next to
the hunters actually standing in the arena: the rail's frog was the flat
primitive green blob, the rail's goblin was the flat primitive green-and-
grey figure — neither matched the mottled, painted `_ai` models visibly
standing on the arena floor two inches away in the same screenshot.

**The cause**, in `tools/blender/portraits.py`: `AI_ART = {"cinder_jackal":
"_ai"}` — this table decides which `.glb` a portrait renders from, and it
only ever had the beast. `combat_3d.gd`'s own `HUNTER_AI_ART = {"frog":
"_ai", "goblin_mech": "_ai"}` has pointed the fight itself at the rebuilt
hunter models for a while; nothing kept the portrait tool's table in sync
with it.

**Fix:** merged the hunter entries into `portraits.py`'s own `AI_ART`
(`{"cinder_jackal": "_ai", "frog": "_ai", "goblin_mech": "_ai"}`),
`painted=True` for both — an AI model's texture already carries painted
light/shade, the same reason `look()` already drops the specular highlight
for `painted=True` models. Re-ran `portraits.py` for just these two; the
existing `FOCUS`/`FOCUS_XY` entries framed the `_ai` mesh correctly with no
retuning needed. Copied the two output PNGs over
`game/assets/portraits/{frog,goblin_mech}.png` — same 512×512 RGBA shape,
so nothing downstream (`characters.json`'s `portrait` paths, the party
rail's `_portrait_of(p, 34)`, the campfire hunter row) needed a code change.

**Verified in the real party rail**, same camera/state, before vs after:

![[frames/artist/2026-09-23-hunter-portraits-party-rail-before-after.png]]

**This closes the 34px Colour & read verification both hunter notes had
open**, now actually measured instead of assumed, because the portrait the
rail draws finally IS the shown model. Downsampled each render to the real
34px and measured mean saturation/value over the non-transparent pixels,
composited on the rail's own dark-brown background to judge legibility the
way the eye actually sees it:

    frog_ai         sat 0.69  val 0.44  — clean: eye/body/belly separate
    goblin_mech_ai  sat 0.27  val 0.40  — reads goblin-shaped, but the
                                          cool body and navy tank crowd
                                          together with little contrast

![[frames/artist/2026-09-23-hunter-portraits-34px-old-vs-new.png]]

`frog_ai`'s own Colour & read line was held at 8 explicitly pending this
check — now clean, bumped to 9, **total 41→42/50, at the hunter stop
line** (`design/progress/frog_ai.md` pass 3). `goblin_mech_ai`'s own line
was held at 8 the same way — verified, and the verification confirms pass
2's original "measurably duller than the Frog's own" finding rather than
improving on it, so it stays 8, **total unchanged, 39/50**
(`design/progress/goblin_mech_ai.md` pass 4). No texture touched this
pass — the scope was the tooling gap, not a colour fix; the concrete next
move for `goblin_mech_ai` is named with real numbers now: raise the tank's
value/saturation relative to the body, checked against the rail's own
`(58,42,30)` background specifically.

Updated `JACKAL-BAR.md`'s hunter-fidelity bullet with both new numbers and
this pass's write-up links.

`ALL TESTS PASSED` (`run_tests.gd`; no game code changed, a Blender tool
table and two portrait PNGs only). No playtest re-run — nothing moves or
renders differently in the 3D scene itself, only a 2D portrait texture the
party rail and campfire already knew how to draw (same reasoning past
texture-only passes here used).

## Old: 2026-09-23 20:11 ET, mesh-topology gap check

- **Did:** Blender's download wall (blocked 3 runs running, request filed
  `to: nick`) cleared on its own this run — no answer needed, the network
  policy fix just landed. Used it for the thing it was blocking:
  `goblin_mech_ai`'s Build hygiene score has been stuck since pass 1 on an
  unanswered question — "no floating islands, no part spaced away from the
  body," unverified since the original build. Wrote a proper check for it
  (`tools/blender/ai/mesh_gap_check.py`) and ran it on the real shipped
  model.
- **Worked?** Yes, a clean answer either way would have been useful, and
  this one came back clean: 489 raw mesh islands (unwelded topology,
  Meshy's normal remesh output), but a measured 3D distance check says
  **zero** of them are actually floating away from the body — the two
  closest-to-flagging are 2.5mm and 6.6mm gaps on a 1.85m-tall model,
  invisible even zoomed in. Build hygiene 6→7, total 37→38→**39/50** — real
  progress, still 3 points under the 42 hunter stop line.
- **Next:** no single line is the clear worst any more (Sil 8, Prop 8,
  Hygiene 7, Colour 8, Style 8) — closing the stop line needs the 34px
  party-portrait colour check pass 2 named as still open (`portraits.py`'s
  `AI_ART` table is beast-only), or a fresh six-view look for something
  this run didn't find. Also closed the Blender-wall request as done.
- **Need from you:** nothing.

## Now

Checked for a fresh, unhandled answer under `## Nick's answer` on my own
`to: nick` notes first, per `COMMON.md` 1b — none. Checked open `to: artist`
requests — none this run. Worked the `JACKAL-BAR.md` queue.

**Set up Blender and Godot fresh (per `status/README.md`), and both worked
without the network wall this time** — `curl` against
`download.blender.org` returned `200` (vs the clean `403` the last three
runs hit), so the request filed at 18:11
(`requests/2026-09-23-1811-artist-to-nick-blender-download-blocked.md`) is
resolved; marked it `status: done` with the proof in its own `## Result`
rather than leave it sitting open with nothing to answer. Meshy also
confirmed working (`balance` OK, 0/8 tasks spent today — the daily ledger
rolled over) but wasn't needed this run.

**Picked the loudest remaining hunter-fidelity gap that Blender specifically
unblocks.** `design/progress/goblin_mech_ai.md` (the shipped, wired-in
Meshy rebuild — not `goblin_mech.md`, the older primitive one, already past
its own stop line) named Build hygiene as its lowest line twice running (6,
pass 1 and pass 2), both times explicitly because the mesh-topology check
`frog_ai.md` pass 2 ran on the Frog had never been run on this model — "an
open question, not a confirmed clean bill."

**Ran a stronger version of that check, not just the same one.** `frog_ai`
pass 2's own check walked the mesh into 193 raw connected components and
confirmed them "silhouette-safe" — a 2D check, and its own "still open"
list admits it never verified in 3D whether any of them are real gaps.
Wrote `tools/blender/ai/mesh_gap_check.py` instead: same connected-component
walk, then (numpy) the minimum 3D distance from every island to the nearest
vertex in a DIFFERENT island. An island that's just unwelded from its
neighbours (harmless, the normal cost of a decimated Meshy remesh) sits at
~0 gap; a genuinely floating part — spaced away from the body, the actual
defect the rubric line names — would show a real fraction of the model's
own bounding-box diagonal as its gap.

    blender -b --python tools/blender/ai/mesh_gap_check.py -- game/assets/3d/cast/goblin_mech_ai.glb

    REPORT total_verts 5799
    REPORT total_islands 489
    REPORT body_diag 2.3296
    REPORT islands_with_real_gap_total 0 (of 489 islands, verts>=3, threshold=0.010)

**489 islands, zero real gaps at a 1%-of-body-diagonal threshold (~23mm).**
Didn't stop at the first clean number — re-ran at 10x tighter (0.1%,
~2.3mm) to find the honest floor: two 4-vert islands show up, at 2.5mm and
6.6mm gaps near the backpack/compressor-tank region. Looked at both
locations in the existing six-view renders at that spot: invisible even
zoomed in, sub-centimetre gaps between decimated micro-facets, not a seam
or a standoff part.

**No fix to apply — the finding itself is the result.** Build hygiene's
open question was "is this confirmed clean," not "here's a known defect to
fix." It's now confirmed clean, with a sharper test than the one `frog_ai`
itself still has outstanding (that asset's own "still open" item 1 is this
exact 3D-gap question, unresolved). Scored Build hygiene 6→7 — matched to
`frog_ai`'s own 7, on the same logic: real tri-budget overage (5199 vs the
1400 hunter budget) still costs a point at this tier, but the topology
uncertainty that was `goblin_mech_ai`'s own extra gap versus `frog_ai` is
now closed. **Total 38→39/50**, still under the 42 hunter stop line.
Nothing else touched — no geometry, texture or code changed, so `ALL TESTS
PASSED` needed no playtest re-run (ran it anyway: no game-visible change,
confirmed by `git status` showing only the new script and the two progress/
status notes).

Full write-up: `design/progress/goblin_mech_ai.md` ("Pass 3").

## Old: 2026-09-23 19:20, floating-stone shelves

- **Did:** took the playtester's request to make the climb stones read as
  shelves, not floating markers — added a flat, level cap and a thin warm
  rim-light edge on top of each stone's existing rock body.
- **Worked?** Yes — clearly better in the wide establishing shot, the exact
  frame the request complained about: before, four round pebbles; after,
  a visible stack of pale-topped ledges with a warm lip. Before/after below.
- **Next:** the playtester's own build request
  (`2026-09-23-1846-...-build-the-one-directional-stone-route.md`, fixer's)
  covers placement/spacing — that's someone else's half, not touched here.
  I left the stones' slow idle bob/spin alone (motion, not look) — flagged
  for the playtester in case a "fixed shelf" that still slowly spins reads
  oddly now that the shape says "stationary."
- **Need from you:** nothing.

![[frames/artist/2026-09-23-stones-shelf-wide-before-after.png]]
![[frames/artist/2026-09-23-stones-shelf-close-before-after.png]]

Took the one open `to: artist` request
(`2026-09-23-1846-playtester-to-artist-make-ledges-read-as-shelves.md`) —
top of the queue per `COMMON.md` 2, and the only one open this run (checked
my own `to: nick` notes for a fresh, unhandled answer too; the Blender-wall
one is still open with nothing written under its answer heading, so left
alone).

**The ask:** the playtester found that after Nick approved the stone-route
proposal, the climb holds themselves still read as "four scattered pebbles,"
not a path — specifically because a round boulder alone doesn't say
"footing" the way Breath of the Wild's climbable rock does (lighter
material/colour on the actual holds, visible from a distance). Material
pass only; placement is the fixer's half of the same approved proposal.

**What changed**, in `_build_float_stones` (`combat_3d.gd`): each stone went
from one boulder mesh to three parts —

- **Body** — the original boulder, shape/colour untouched, still random
  tilt+squash so a run of stones doesn't clone.
- **Cap** — new. A flat, perfectly level cylinder on top (no random tilt,
  unlike the body), pale worn-sandstone tone, deliberately lighter than the
  body AND the jackal's own near-black skin. This is the actual "footing"
  cue, and it stays level regardless of how the body under it is squashed.
- **Rim** — new. A thin unshaded warm-ember ring at the cap's edge. This is
  what carries the shelf's silhouette at wide-shot distance, where the
  cap/body colour difference alone gets small on screen.

**First pass had a visible gap** between cap and body — the boulder mesh is
very low-poly (`rings=3`, so its "top" is a faceted point, not a smooth
dome), and its own random tilt swings that point sideways by more than the
cap's thickness at this radius. Fixed by overlapping the body further up
into the cap rather than placing them flush; re-rendered and confirmed no
daylight gap in the wide shot, `3dgrip`, or a close crop.

**Checked the request's other bullet** — "ledges (real footing) and mid-air
pass-through points ... look distinguishably different": read
`_build_float_stones`/`_build_ledge_marks` closely. Every climb point
already gets one of these stones; there's no separate "no footing, mid-fall"
stone today. The existing safe-ledge ring (drawn only on `boss.ledges`
heights, a strict subset) already marks which ones are secure. Left that
system alone — it already satisfies this bullet.

Verified: `state=3d ... wide` (the request's own repro command), `3dgrip`
(hunter standing on a stone — feet still land flush on the new cap),
`3dstrike` (sigil close-up, no stones in frame, unaffected). `ALL TESTS
PASSED`. Pushing this now per COMMON.md 4b, then running the 80-step
playtest in the foreground (not backgrounded) as the last step of this run;
result appended to the Log below once it finishes.

Marked the request `status: done` with the before/after frames embedded in
its own `## Result`.

## Old: 2026-09-23 18:16, Goblin Engineer colour boost

- **Did:** made the Goblin Engineer's colours read better — boosted
  saturation and lifted the shadows on its texture directly (no Blender, no
  Meshy spend), since the palette was measurably flatter and darker than
  the Frog's own.
- **Worked?** Yes, a real if modest improvement — the backpack tank, goggles
  and strap all read more distinctly now, verified in the real fight and
  the campfire screen; frames in the write-up. Scored it: Colour & read
  7→8, total 37→38/50 — closer, but still under this fight's own 42 bar for
  a hunter.
- **Next:** the remaining gap needs Blender (a mesh-cleanliness check, the
  lowest-scoring line) — blocked again this run.
- **Need from you:** Blender downloads have failed three runs running now
  (roughly 16:24, 17:19, and this one) — same fix as the Meshy one earlier
  today would likely clear it. Filed a request with the details; not
  blocking anything urgent, but it's the reason today's hunter-fidelity
  work has been limited to texture tweaks instead of real geometry.

## Now

**No open `to: artist` request this run**, and none of my own `to: nick`
requests had a fresh, unhandled answer either — checked both per
`COMMON.md` 1b/2 before picking work. Worked the `JACKAL-BAR.md` queue.

**Both Meshy (8/8 daily tasks already spent, ledger-confirmed) and Blender
were unavailable again — third run in a row on the exact same Blender
wall**, so this is the one to file, per the last run's own threshold:
`requests/2026-09-23-1811-artist-to-nick-blender-download-blocked.md`
(`to: nick`, not blocking, but flags the recurring pattern).

**Picked the one thing that needed neither tool.** `goblin_mech_ai`'s pass-1
score (37/50, `design/progress/goblin_mech_ai.md`) named two lowest lines:
Build hygiene (needs Blender — still blocked) and Colour & read (texture
"measurably duller than the Frog's own"). The second one doesn't actually
need Blender or Meshy: the runtime texture is a plain PNG Godot's importer
already extracted to disk (`embedded_image_handling=1`), the same fact the
jackal ear-glare fix relied on to edit a texture directly with no
re-export needed.

**Re-measured the gap on the real files first**, rather than trust pass 1's
carried-over number (which turned out to be from Blender's own linear-space
pixel data, not the shipped sRGB asset): HSV saturation 0.284 vs the Frog's
0.671, value 0.535 vs 0.702 — real, reproducible, just smaller than the
original "80 vs 156 luminance" framing suggested. Fixed with a direct HSV
edit on `goblin_mech_ai_Image_0.png` — saturation ×1.55, value gamma 0.80 —
moving about 40% of the way to the Frog's own numbers, deliberately not all
the way (risk of reading oversaturated against this hunter's own palette).
Script kept at `tools/blender/ai/goblin_ai_colour_boost.py` (no `bpy`
despite the folder — it's the goblin-AI-texture family of scripts, this one
just doesn't need Blender).

Verified in the real fight and the campfire row, before/after at true
in-fight size:

![[../agents/frames/artist/2026-09-23-goblin-colour-boost-infight-crop.png]]
![[../agents/frames/artist/2026-09-23-goblin-colour-boost-campfire-crop.png]]

The backpack tank, goggles and strap all separate more clearly. Modest, not
dramatic — the toon shader's own shadow ramp compresses colour range on top
of whatever the texture carries, so part of the ceiling here is shader-side,
not texture-side.

**No regression** — only the one PNG changed (`git status` confirmed);
full-frame pixel diff against the immediately-prior render shows nothing
outside the goblin's own screen region beyond thin edge pixels on the
jackal's legs and the Frog, consistent with ordinary idle-animation jitter
between two independently-timed renders (same pattern the outline-width
pass documented). `ALL TESTS PASSED` (`run_tests.gd`) — texture-only change,
no logic touched, so no playtest needed.

**Score: Colour & read 7→8, total 37→38/50** — still under the 42 hunter
stop line. `design/progress/goblin_mech_ai.md` ("Pass 2") has the full
write-up including what's still open: the portrait-scale colour check, and
Build hygiene, still blocked on Blender.

## Old: 2026-09-23 17:19, outline-width fix / goblin_mech_ai shipped and scored

**Both Meshy and Blender were unavailable again.** `python3 tools/meshy.py
balance` succeeds (the credential still works), but the daily task ledger
(`design/progress/meshy-ledger.md`) already shows 8/8 spent for
2026-09-23, and the date hasn't rolled over — confirmed, not assumed, same
conclusion the last run reached. Tried Blender fresh this run rather than
trust the last run's note that it might have cleared:
`curl https://download.blender.org/...` → clean `403`, `connect_rejected` /
"organization policy" per `$HTTPS_PROXY/__agentproxy/status`, same wall,
still up. Not filing a fresh `to: nick` for this — two runs in a row on the
same wall starts to look like it's worth flagging, but nothing changed
since the last run's own note said not to yet; if a third run hits the
same wall, that's the one to file.

**Picked the loudest thing that needed neither.** With no model-building
budget, went looking at what a shader/material change could still fix — the
outline-width request I'd filed to the fixer
(`requests/2026-09-23-1540-artist-to-fixer-hunter-scale-outline-swallows-thin-hunters.md`)
was still `open`, untaken, hours after filing, and blocking the single
loudest line on `JACKAL-BAR.md` ("Frog and Goblin match the jackal's
fidelity") — the Goblin Engineer's Meshy rebuild was already built,
tested, and sitting on disk, unshippable purely because of this one shader
parameter. Decided to implement it myself rather than wait longer: it's a
material/shader change on an asset I own, the same kind of edit past runs
have already made directly in `combat_3d.gd` (the ear-glare fix, the
footholds texture, `HUNTER_AI_ART`/`ENV_AI_ART` itself), not a gameplay
bug fix outside my own scope.

**The fix.** `OUTLINE_WIDTH_SCALE` in `combat_3d.gd`: a dict of model id to
a multiplier on `outline.gdshader`'s own default line width (`0.0045`), not
the flat global override the original request explicitly said not to ask
for. Read at both places a toon-shaded model's outline material gets built
— `toon_material()` (called from `_shade_model` for the live fight, and
`toon_all` for the reward-screen felled beast and the campfire hunter row)
— so a tagged hunter reads the same everywhere it appears, not just in
combat. An id with no entry gets the implicit `1.0` and the code never
calls `set_shader_parameter` at all, so the jackal and the already-shipped
Frog draw through the exact same call they always did — nothing about
their outline changed, in code or in the render.

**`goblin_mech`: 0.33.** Matches the manual local test the original
diagnosis reported (width `0.0015` against the `0.0045` default) — but
re-verified fresh this run rather than carried over on trust: wired
`"goblin_mech": "_ai"` into `HUNTER_AI_ART`, rendered `state=3d
beast=cinder_jackal`, cropped the hunter at 3x.

![[../agents/frames/artist/2026-09-23-goblin-outline-width-fix-crop.png]]

Left: the primitive Goblin (unchanged, still the shipped fallback). Right:
the Meshy rebuild, outline scaled — mint skin, gold goggles, dark slate
tank rig and a raised clawed hand all legible, matching the Frog's own
level of read.

**Checked every place this model shows, not just the one screenshot that
started the diagnosis.** The campfire hunter row (`toon_all`'s other call
site, `_place_hunters` in `location_3d.gd`) reads just as clearly:

![[../agents/frames/artist/2026-09-23-goblin-outline-width-fix-campfire.png]]

**No regression on the jackal or the Frog** — full-frame `state=3d`
before/after, pixel-diffed. Outside the Goblin's own screen region, the
only pixels that moved are consistent with ordinary idle-animation timing
jitter between two independently-run screenshots (breath/ember-pulse/idle
sway, all time-driven); a tight crop of the jackal's legs and the Frog
confirms both are shape-for-shape identical, not just "diff is small":

![[../agents/frames/artist/2026-09-23-goblin-outline-width-fix-before-after.png]]

**Scored for real, for the first time.** The original build pass was
explicitly left unscored (not shown to players the way they'd see it yet);
now it is. Full rubric breakdown in
`design/progress/goblin_mech_ai.md` ("Shipped and scored") — short version:
Silhouette 8, Proportion 8, Build hygiene 6, Colour & read 7, Style
consistency 8. **Total 37/50**, under the 42 hunter stop line, an honest
number rather than a rounded-up one (`frog_ai` landed 41/50 on its own
first wired-in pass, for comparison). Lowest two lines for whoever picks
this up next: Build hygiene (needs Blender for a mesh-cleanliness check
this run couldn't do) and Colour & read (the texture is still measurably
duller than the Frog's own — 80.1 vs 156.5 mean luminance, unchanged by
this pass; needs either a Meshy budget reset or manual texture work).

**Ticked `JACKAL-BAR.md`'s "each hunter reads at fight distance, not a
green blob"** — true now for both hunters, with evidence. Left the bigger
"Frog and Goblin match the jackal's fidelity" line unticked — 37/50 is a
real hunter on screen, not yet at the tier's own bar.

**`ALL TESTS PASSED`.** An 80-step `mode=play beast=cinder_jackal steps=80`
playtest was kicked off against the wired-in model but ran past this
run's foreground window — per `COMMON.md` 4b, pushed the code, the frames
and every write-up first rather than let a background run hold up
everything else this session did. Result appended to
`design/progress/goblin_mech_ai.md` and the `## Log` below the moment it
lands.

Filed the result on the original request
(`requests/2026-09-23-1540-artist-to-fixer-hunter-scale-outline-swallows-thin-hunters.md`,
now `status: done`) rather than leave it open under the fixer's name for
work already finished.

## Old: 2026-09-23 16:24, floating-foothold rock-detail texture

- **Did:** gave the jackal's (and every beast's, shared code) floating
  climb footholds real surface detail — generated a faceted-rock texture
  and multiplied it onto the stones, which had only ever had one flat
  colour. Fixes `artist.md` item 1's own "footholds are plain basalt".
- **Worked?** Yes — before/after in the real fight (same camera, same
  state) shows the stone going from a flat orange blob to a visibly
  cracked, faceted rock, still the same warm palette. Frame below.
- **Next:** the hunter-fidelity item (Goblin Engineer) is still blocked on
  the fixer's outline-width fix, untouched since last run. If a future run
  gets Blender back, the stones could get real geometry too, not just a
  texture.
- **Need from you:** nothing.

**Both Meshy and Blender were unavailable this run.** Checked first, before
picking work: `design/agents/status/artist.md`'s own last entry already
recorded 8/8 daily Meshy tasks spent (confirmed no reset since — Meshy
budget is a hard daily cap, not per-run). Tried Blender next —
`curl https://download.blender.org/...` came back a clean `403 Forbidden`
through the proxy, twice, not a timeout or a flaky retry (`curl -sS
"$HTTPS_PROXY/__agentproxy/status"` confirmed `connect_rejected` /
"organization policy" on that host this session, distinct from the Meshy
network wall other runs have filed before). Prior runs built real beasts
under this exact wall with Blender working fine today, so this reads as a
this-session network policy quirk, not a standing block — not worth a
fresh `to: nick` request for a one-off that may not recur; noted here so
the next run knows to just try again rather than assume it's permanent.

**Picked the next thing that needed neither.** The hunter-fidelity item
(the loudest open line on `JACKAL-BAR.md`) is blocked on the fixer's
outline-width fix (`requests/2026-09-23-1540-...`, still open, untouched
since I filed it). Went looking for a real gap I could still close and
found one by rendering, the same way the ear-glare bug was found: the
`3dgrip` state (a hunter mid-climb, a real reachable state, not a
synthetic edge case) shows the floating stone under the Frog as one flat
solid-orange blob with a hard shadow — no surface variation at all. This
is exactly `artist.md` item 1's own named issue ("footholds are plain
basalt"), never actually fixed, only recoloured (2026-09-23, brown to
match the arena's own boulders — colour was right, surface detail never
was).

**Ruled out reusing the arena's own Meshy texture first.** The env
model's `cinder_jackal_ai_Image_0.jpg` (the crater wall's baked texture)
has real rock detail, but it's vertical striated wall rock, UV-unwrapped
for that specific wall mesh — slapping it onto a `SphereMesh`'s own
lat-long UV via its default mapping would stretch/misalign into an obvious
smear, not read as rock. Building a real from-scratch rock mesh is the
right fix but needs Blender, which wasn't available.

**Built a generated (not modelled) detail texture instead** — pure
numpy/PIL, no Blender, no Meshy: a toroidal Voronoi (seed points wrapped
9x so the pattern has no seam crossing the sphere's own UV wrap),
per-cell random brightness, and a distance-based darkening near each cell
edge for a crack line — the same low-poly **faceted** look every other
rock/beast asset in this fight already established, not an invented style.
512×512 grayscale, `game/assets/3d/rock_detail.png`.

**Wired into `_build_float_stones()`** (`combat_3d.gd`, shared by every
beast — verified specifically in the Cinder Jackal fight per this fight's
own scope rule): added `mat.albedo_texture = ROCK_DETAIL` next to the
existing per-stone `albedo_color` tint, which stays exactly as it was — the
texture multiplies it, so the already-tuned BROWN palette and its
"lighter than the beast's own CHARCOAL legs" contrast rule are untouched.
One texture shared by every stone; the existing per-stone random rotation
(unrelated code, already there) turns a different facet forward on each,
so neighbouring stones still don't clone.

**Verified.** `ALL TESTS PASSED` (`run_tests.gd`, material-only change, no
logic touched). Before/after at the exact same camera and state
(`state=3dgrip beast=cinder_jackal`, a real reachable mid-climb position):

![[../agents/frames/artist/2026-09-23-foothold-rock-detail-before-after-crop.png]]

Full frame, after:
![[../agents/frames/artist/2026-09-23-foothold-rock-detail-after-full.png]]

Full write-up, including why texture over geometry and what was ruled out:
`design/progress/foothold_rock_detail.md`.

**Playtest: clean.** Kicked off a full 80-step `mode=play` as the general-
regression check (this touches a shared code path used by every beast's
climb, even though the change itself is a pure `material_override` swap
with no position/index logic touched) — it ran past the 590s foreground
cap and moved to the background, so pushed everything first per COMMON.md
4b rather than let it run unwitnessed. Result, once it finished:
`PLAYTEST OK: 0 failing check(s) {  }`, full 80 steps, exit code 0 — Meld,
Catapult+Burn Coal, Leapfrog, Brace, Take Aim, Scramble, several real
climbs/hops with position-continuity checks, a real fall (foot 10→4, hp
20→14 at step 71) all clean. No regression.

**Also looked at, and deliberately did NOT file:** the `3dgrip` state also
shows the OTHER hunter (not the one the camera follows) going behind the
top HUD bar — flagged it as a possible bug at first, then found
`playtest.gd`'s own `check 9` comment (2026-09-23) explicitly documents
this as settled, not a gap: only the camera-followed hunter is required to
stay on screen, after an earlier version of this exact check "false-fired
on the OTHER hunter mid-climb" and was deliberately narrowed. Re-filing it
would be re-litigating already-closed work, so left alone.

## Old: 2026-09-23 15:40, Goblin Engineer Meshy rebuild — blocked on outline width

**Picked up the loudest remaining item on `JACKAL-BAR.md`**: "Frog and
Goblin match the jackal's fidelity." The Frog already has a shipped Meshy
rebuild (`frog_ai.md` pass 2, 41/50); the Goblin Engineer had no Meshy
attempt yet. Both blockers that note left open — Meshy fetch, the
hunter-display-path — were already `status: done`, so this was the natural
next move, not a new investigation.

**Budget was tight.** 6 of 8 daily Meshy tasks were already spent before
this run (frog previews/refine, arena preview/refine). That left exactly
one preview and one refine — no room to try three candidates the way
`frog_ai.md` pass 1 did. Wrote one careful prompt pulled straight from
`goblin_mech.py`'s own docstring (oversized mech arm, ordinary arm,
compressor tank, goggles, tusks) instead. What came back reinterprets that
as a mechanical tank-and-hose backpack rig rather than a second giant arm —
a different read of the brief, not what was literally asked for, but still
unmistakably "goblin with visible machinery," and Nick's 2026-09-23 brief
explicitly allows a style change, not just a literal rebuild. Accepted
rather than spend the last task on a reroll. Refined with a texture prompt
built from this hunter's own established palette, sampled from the shared
atlas, not guessed. **8 of 8 daily Meshy tasks now spent — none left
today.**

**Cleaned in Blender** (`tools/blender/ai/goblin_ai_clean.py`, the same
weld/centre/scale/decimate recipe `frog_ai_clean.py` proved): welded
doubles, scaled to the current `goblin_mech.glb`'s own measured height
(1.85, read off a real bounds probe), decimated 27,422 → 5,199 tris
(matches `frog_ai`'s own already-accepted overage). One mesh, one material.
Reads clearly as a goblin with visible machinery in isolation — mint skin,
gold goggles, dark slate tank rig, brown straps — under `look.py`'s neutral
lighting, six-view render below.

![[../renders/goblin_mech_ai_pass1_front.png]]

**Wired in to test, and found a real problem — not shipped.** Tagged
`goblin_mech` into `HUNTER_AI_ART` and compared the real fight, same camera
and state, before/after. The toon shading and ink outline apply correctly —
same code path the Frog already uses — but **at true in-fight size it
reads as a near-solid black blob**, worse than the primitive it would
replace:

![[../agents/frames/artist/2026-09-23-goblin-mech-ai-infight-before-after.png]]

Measured, not just eyeballed: the exported texture's mean luminance is 80.1
against `frog_ai`'s own shipped texture at 156.5. Tried the obvious fix —
a gamma lift on the baked texture, no new Meshy spend
(`tools/blender/ai/goblin_ai_brighten.py`) — and it barely moved the
in-fight read. Isolated the real cause instead: `toon.gdshader`'s shadow
colour is a cool blue-grey by design, not black, so the black is coming
from the second pass, `outline.gdshader`'s inverted-hull ink line. Its
`width` (0.0045, distance-scaled) is tuned for thick, rounded masses — the
jackal, the Frog. The Goblin's own design is deliberately the opposite
(many thin parts: straps, tank fittings, limb segments), and at hunter
scale those individual outline strokes start overlapping and eating the
model. Confirmed by a throwaway local test — dropped `width` to 0.0015,
reverted immediately, `git diff` clean before committing anything — and the
identical asset read clearly:

![[../agents/frames/artist/2026-09-23-goblin-mech-ai-crop-outline-width-diagnosis.png]]

**A hunter that renders worse than what it replaces is a regression, not a
win** — reverted `HUNTER_AI_ART` back to `{"frog": "_ai"}` (confirmed via
`git diff`, clean on both `combat_3d.gd` and `outline.gdshader`) before
committing. The built asset (`goblin_mech_ai.glb`, `.blend`, both scripts)
ships in this commit regardless, same as `frog_ai` pass 1's own spike did —
ready to wire in the moment the outline question is resolved. Not scored
against the asset-loop rubric, same reasoning `frog_ai.md` pass 1 gave:
scoring a model that isn't shown to players the way they'll see it would be
misleading. Full build log, prompts and measurements in
`design/progress/goblin_mech_ai.md`.

**Filed to the fixer**
(`requests/2026-09-23-1540-artist-to-fixer-hunter-scale-outline-swallows-thin-hunters.md`):
the outline width needs to vary by hunter scale/part-thickness — this will
block every future detailed hunter, not just this one.

`ALL TESTS PASSED`. 80-step playtest (`mode=play beast=cinder_jackal
steps=80`) re-run against the final, reverted state to confirm no
regression — nothing in the committed diff touches gameplay code or
hunter/beast positioning (`HUNTER_AI_ART` is byte-for-byte what was already
shipped), so a regression here would be a surprise, but the result is
appended the moment it lands rather than assumed.

**Playtest result: clean.** `PLAYTEST OK: 0 failing check(s) {  }` — all 80
steps (Meld, Catapult+Burn Coal, Leapfrog, Brace, Take Aim, Scramble, Build
Grapple, several climbs and hops with position-continuity checks passing),
exit code 0. Confirms the prediction above: the committed diff never
touched `HUNTER_AI_ART` or any gameplay/positioning code, only added new,
unreferenced asset files and docs.

## Next

**Hunter fidelity** (still the loudest `JACKAL-BAR.md` line): blocked on
the fixer's outline-width fix
(`requests/2026-09-23-1540-artist-to-fixer-hunter-scale-outline-swallows-thin-hunters.md`,
still open). Once it lands: re-wire `goblin_mech` into `HUNTER_AI_ART`,
re-verify, score it for real.

Blender's own network wall cleared this run (`download.blender.org` fetched
clean — the first artist run in three not to hit the 403). Worth
re-confirming next run before relying on it; if it holds, the footholds'
underlying geometry (still a smooth sphere under the new cap/rim, this run
only touched the visual dressing) is the obvious next real-geometry pass.

## Log

- 2026-09-23 21:12 EDT — fixed `portraits.py`'s `AI_ART` table (beast-only,
  `{"cinder_jackal": "_ai"}`) to also cover `frog`/`goblin_mech`, so the
  party-rail/campfire portraits finally render from the same `_ai` models
  the fight itself has used for a while, not the old Python-primitives.
  Verified in the real party rail before/after. This closed the 34px
  Colour & read check both hunter notes had left open: `frog_ai` 8→9,
  total 41→42/50 — **at the hunter stop line**
  (`design/progress/frog_ai.md` pass 3); `goblin_mech_ai` stays 8, 39/50,
  confirmed still duller than the Frog's own at that scale, next move named
  with real numbers (`design/progress/goblin_mech_ai.md` pass 4). Updated
  `JACKAL-BAR.md`. `ALL TESTS PASSED`; no playtest re-run (texture/tooling
  only, nothing moves differently). Lease released.
- 2026-09-23 20:11 EDT — Blender's download wall cleared on its own
  (`download.blender.org` now `200`); closed the `to: nick` request that
  flagged it. Wrote `tools/blender/ai/mesh_gap_check.py` (a measured 3D
  nearest-different-island-gap check, stronger than `frog_ai`'s own
  silhouette-only one) and ran it on `goblin_mech_ai.glb`: 489 raw topology
  islands, 0 with a real spatial gap (>1% of body diagonal); even at 10x
  tighter threshold only two 4-vert islands show up, both sub-centimetre
  and invisible in the renders. Closes the open Build hygiene question from
  pass 1/2. Build hygiene 6→7, total 38→39/50, still under the 42 hunter
  stop line. No asset/code change, so no playtest needed; `ALL TESTS
  PASSED`. See `design/progress/goblin_mech_ai.md` ("Pass 3"). Lease
  released.
- 2026-09-23 19:29 EDT — 80-step playtest for the stone-shelf change, run in
  the foreground this time (COMMON.md 4b), after pushing the code/frames
  first: `PLAYTEST FAIL: 1 failing check(s) { "damage-popup-offscreen": 1 }`
  at step 19. Checked before treating it as a regression: this is the exact,
  already-filed, still-open `to: fixer` issue
  (`requests/2026-09-23-1735-playtester-to-fixer-boss-damage-popup-offscreen-at-sigil.md`)
  — a damage number's screen projection, nothing to do with the stones'
  mesh/material. No hop/camera check failed; hop position continuity and
  mid-hop camera coverage were clean on every sampled jump, including onto
  the new shelf-capped stones. Not a regression from this change; not
  reopening or duplicating the fixer's own request. Commit `66d2f4f`.
- 2026-09-23 19:20 EDT — shipped the ledges-read-as-shelves request: added a
  flat cap + warm rim edge on top of each floating stone's existing rock
  body (`_build_float_stones`, `combat_3d.gd`); fixed a cap/body gap the
  first pass had. `ALL TESTS PASSED`. Before/after in the request's own
  `## Result` and above. Request marked `status: done`. Commit `66d2f4f`.
- 2026-09-23 18:16 EDT — boosted saturation (x1.55) and lifted value (gamma 0.80) directly on goblin_mech_ai's extracted PNG texture (tools/blender/ai/goblin_ai_colour_boost.py, no Blender needed) -- HSV sat 0.284->0.433, val 0.535->0.601, toward the Frog's own 0.671/0.702. Verified in the real fight and campfire row, backpack/goggles/strap read more distinctly. Colour & read 7->8, total 37->38/50, still under the 42 hunter stop line. ALL TESTS PASSED; pixel-diff confirms no regression outside the goblin's own region (idle-animation jitter only). Filed to:nick on the Blender wall (3rd run in a row hitting the same 403 on download.blender.org) per the prior run's own filing threshold. See design/progress/goblin_mech_ai.md ("Pass 2"). Lease released.
- 2026-09-23 17:34 EDT — the 80-step playtest for the outline-width/goblin_mech_ai change (below) finished clean: PLAYTEST OK, 0 failing check(s), full 80 steps, exit code 0. Ran slow this session (real CPU time, the same sandbox flakiness status/fixer.md has noted before, not a hang) but finished with no artificial cutoff. No regression. See design/progress/goblin_mech_ai.md. Lease released.
- 2026-09-23 17:19 EDT — gave outline.gdshader's shared ink-outline a per-model width scale (OUTLINE_WIDTH_SCALE in combat_3d.gd, threaded through toon_material/toon_all/_shade_model), took the still-open to:fixer request myself since it was blocking JACKAL-BAR's loudest line and neither Meshy (0/8 today) nor Blender (network wall, reconfirmed) had budget for anything else. Wired goblin_mech_ai into HUNTER_AI_ART at scale 0.33 -- went from a near-solid black blob to a clearly-readable hunter in the real fight and the campfire row, jackal/Frog confirmed unaffected (pixel-diff outside the goblin's own region matches ordinary idle-animation jitter). Scored for real for the first time: 37/50, under the 42 hunter stop line -- see design/progress/goblin_mech_ai.md ("Shipped and scored"). Ticked JACKAL-BAR's "reads at fight distance, not a green blob" line for both hunters. ALL TESTS PASSED. 80-step playtest kicked off, ran past the foreground window -- pushed code/frames/write-ups first per COMMON.md 4b, result to follow. Marked the request done.
- 2026-09-23 16:27 EDT — the background 80-step playtest for the foothold-texture change (below) finished clean: PLAYTEST OK, 0 failing check(s), full 80 steps, exit code 0. Confirms the change (a pure material_override/albedo_texture swap) touches no position/foothold-index logic. See design/progress/foothold_rock_detail.md.
- 2026-09-23 16:24 EDT — gave the shared floating footholds a generated (numpy/PIL toroidal-Voronoi) faceted-rock detail texture, mat.albedo_texture on _build_float_stones' SphereMesh, multiplied over the existing per-stone BROWN tint (unchanged). Both Meshy (0/8 left) and Blender (download.blender.org hard-403 this session) unavailable, so pure 2D texture, no geometry/logic touched. ALL TESTS PASSED. Before/after verified in the real fight at state=3dgrip (a real reachable mid-climb state) -- flat orange blob to visibly cracked/faceted rock. 80-step playtest pushed to background past the 590s cap; pushed code first per COMMON.md 4b, result to follow. See design/progress/foothold_rock_detail.md. Lease released.
- 2026-09-23 15:48 EDT — playtest for the above finished clean: PLAYTEST OK, 0 failing check(s), all 80 steps, exit code 0. Confirms the committed diff (goblin_mech_ai asset + docs, HUNTER_AI_ART reverted to shipped state) touches no gameplay code. Lease released.
- 2026-09-23 15:40 EDT — built the Goblin Engineer's Meshy rebuild (1 preview + 1 refine, 8/8 daily Meshy tasks now spent), cleaned/decimated in Blender to goblin_mech_ai.glb. Wired into HUNTER_AI_ART to test: reads as a near-solid black blob at true in-fight size, not a texture problem -- isolated the cause to outline.gdshader's fixed ink-outline width overlapping on this hunter's many thin parts (jackal/frog are thick rounded masses, this one isn't). Reverted HUNTER_AI_ART (git diff clean), kept the built asset committed unwired. Filed to:fixer with the diagnosis and a before/after frame. ALL TESTS PASSED; 80-step playtest re-run against the final reverted state. See design/progress/goblin_mech_ai.md.
- 2026-09-23 18:34 UTC — took the answered arena-wall-accent request: rebuilt the Cinder Jackal arena's enclosing wall with a Meshy-generated crater rim (2 Meshy tasks), left the floor untouched, shipped as cinder_jackal_ai.glb via a new ENV_AI_ART table in combat_3d.gd. Scored 37/50 (design/progress/cinder_jackal_ground.md pass 6), up from 28. ALL TESTS PASSED, 80-step playtest clean (PLAYTEST OK, 0 failing checks). Ticked both JACKAL-BAR.md arena lines. Request marked done.

- 2026-09-23 — Meshy network wall confirmed down (the to:nick request landed,
  re-verified independently: fetched all 3 logged Frog previews, no proxy
  403). Fresh six-view arena look found nothing new (systemic wall issue
  still open, still Nick's call). Built `frog_ai` pass 1: fetched Meshy
  candidate A, wrote `tools/blender/ai/frog_ai_spike.py` (hunter-specific,
  not `ai_beast.py`), welded/oriented/scaled-to-1.15/decimated to 5200 tris.
  Reads as a frog immediately, even at 64px silhouette. Deliberately not
  textured, not rigged, not wired into `cast/frog.glb`/`AI_ART` — the
  hunter-display-path request (to fixer) was still open when this pass
  started (the fixer took it mid-run, per a concurrent push). Committed and
  pushed (a prior run apparently spiked this and lost it by not pushing).
  ALL TESTS PASSED (no game code touched).
- 2026-09-23 — (a concurrent run, log entry not left by its own author —
  added here for the record) jackal footholds recoloured from a cool grey
  to BROWN (`combat_3d.gd` `_build_float_stones()`), matching the arena's
  own scattered-boulder swatch. See `## Old: jackal footholds` above.
- 2026-09-23 — `goblin_mech` pass 8: fresh six-view look at the last open
  Style candidate (goggle strap at oblique angles) found a real defect pass
  4 never saw — the strap's own Y-radius put its front edge ahead of the
  goggle barrel/lens it's mounted to (measured: -0.290 vs -0.262 vs -0.228),
  reading as a blade/beak at the fight-camera (3/4) and profile angles.
  Pulled Y-radius 0.180→0.105, verified tri budget/silhouette/portrait/
  in-fight, no tri cost. Style 8→9, 39→40/50. ALL TESTS PASSED; playtest
  re-run, one pre-existing `hunter-off-marker` FAIL (already filed, no code
  path from a decorative-ring radius to foothold placement).
- 2026-09-23 — Meshy hunter rebuild attempt hit a network-policy wall:
  `api.meshy.ai` works, `fetch`'s `assets.meshy.ai` is denied by the
  sandbox; 3 Frog previews generated, unretrievable. Filed to:nick (network)
  and to:fixer (hunters never get the beast toon/anim display path — a
  rigged Meshy hunter would render worse than today's primitives without
  it). Pivoted to `goblin_mech` pass 7: did the rig-scale-up experiment pass
  6 flagged, scaled every rig coordinate+size from one pivot in the
  generator (not a post-hoc mesh transform), verified every risk pass 6
  named, Proportion 7→8, 38→39/50. Matched-pair playtest (rebuilt vs stock,
  same seed) confirmed both playtest FAILs found are pre-existing. ALL
  TESTS PASSED.
- 2026-09-23 — pass 6 on `goblin_mech` (item 2, hunters, cap lifted): fresh
  six-view check found no new defect. Re-confirmed pass 4's crown-zigzag
  fix wasn't oversold (compared its own before/after renders directly),
  confirmed the whole silhouette including the ordinary arm is one
  connected component (`scipy.ndimage.label`), and measured the
  rig-vs-ordinary-arm size disparity as real but moderate — Prop/Hygiene's
  existing 7s hold up, not hidden defects. Considered and declined a
  rig-scale-up experiment for Proportion as too risky without a full
  iterate cycle. Score unchanged, 38/50. Separately: verified the arena's
  open "RUST wall accent visibility" question across all 5 real fight
  camera states plus a wide framing — confirmed it never shows in play
  (only in the loop's own scoring camera) — and filed
  `to: nick` (`requests/2026-09-23-1200-artist-to-nick-arena-wall-accent-never-shows.md`)
  since the fix lives in shared `env.py` code. No code changed;
  `ALL TESTS PASSED`. See `design/progress/goblin_mech.md` pass 6,
  `design/progress/cinder_jackal_ground.md` pass 4, and `## Now`/`## Next`
  above for the full write-up.
- 2026-09-23 — pass 5 on `goblin_mech` (item 2, hunters, cap lifted),
  37→38/50: checked pass 4's two open candidates (wrist-joint curvature,
  claw/piston distinctness) fresh and ruled both non-issues, not fixed.
  Found and fixed a real one instead — GRAPHITE and CHARCOAL, the rig's two
  largest single-colour masses (compressor box, hose ring), sample at
  near-identical luminance (59.4/56.4) against this same rig's own STONE/
  PEWTER (114.1/139.5), leaving little headroom for the toon-shaded bevel
  highlight the model's own docstring says is the rig's whole job. Moved
  both to STONE, no new hue, no geometry/tri change (`_sil.png`
  pixel-identical, 1378 tris both builds). **Got the first in-game
  verification wrong and corrected it on the record**: an initial
  mid-strike camouflage claim (13.8-luminance-gap sample) turned out to be
  a misidentified pixel — the sampled point was pixel-identical before and
  after the fix, and a diagnostic recolour confirmed it was the jackal's
  own wing membrane, not the rig, which is mostly self-occluded in that
  pose. Re-verified properly: isolated renders show a real (if
  shader-compressed, +6.9 mean luminance) lightening, and a genuinely
  unoccluded in-game pose (`state=3dgrip slot=1`) confirms it without
  repeating the earlier mistake. Colour 7→8. `ALL TESTS PASSED`; playtest
  re-run, the one failure (`hunter-off-marker`, foothold 4) matches the
  already-open fixer request by exact coordinates, pre-existing. See
  `design/progress/goblin_mech.md` and `## Now` above for the full
  write-up, including the misidentified-pixel correction in full.
- 2026-09-23 — pass 8 on `frog` (item 2, hunters), 41→43/50: fixed pass 7's
  own named candidate — the front legs never broke the silhouette the way
  the haunch does since pass 5. Three attempts, each looked at in a render
  before the next: a fatter limb radius (marginal, mostly the foot), a
  shoulder ball placed by a local surface calc (still barely visible — the
  scoring camera's compound silhouette hides more than one ellipsoid's own
  local surface implies), a much bigger ball placed away from the limb
  (broke the silhouette but read as a glued-on third lump in `_side.png`).
  Landed on a shoulder ball placed almost exactly where the limb starts —
  the same relationship pass 5's own knee ball has with the hindleg — which
  reads as an integrated shoulder in `_side`/`_form` and still gives a real,
  if modest, 670px `_sil` diff. Cost: +336 tris (4800→5136), a further
  increase on the model's already-deliberate overage. Sil 8→9, Prop 8→9 —
  **clears the 42 hunter stop line.** Verified in isolated renders (`_sil`,
  `_side`, `_front`, `_top`, unchanged footprint), the live fight camera
  (real, localised diff on the frog, not the goblin or the jackal's own
  idle pulse), and the 34px portrait (honestly does not show this fix,
  unlike some earlier passes — reported, not hidden). `ALL TESTS PASSED`;
  playtest re-run, the one failure (`hunter-off-marker` at foothold 4)
  matches the already-open fixer request by exact coordinates, pre-existing.
  `frog` is now past its stop line — next run moves to `goblin_mech` or the
  Meshy-rig fixer request unless something new is found. See
  `design/progress/frog.md` and `## Now` above for the full write-up.
- 2026-09-23 — pass 7 on `frog` (item 2, hunters) under Nick's wider "make
  the characters CLEAN, pull from AAA games" brief, 40→41/50: diagnosed
  Style (never had a dedicated pass) using a named greyscale/value-contrast
  technique — measured every colour boundary on the model off the atlas's
  own pixels and found the AMBER toes vs the MINT foot pad were the
  weakest on the whole model (18.8 luminance gap, against 38–100+
  everywhere else), on the one feature the model's own docstring calls
  its foot's main read. Fixed with a single colour swap, AMBER→RUST (a
  43-point gap, and this fight's own established warm accent), no geometry
  change. Verified in a greyscale render, a live-fight before/after
  (real, localised diff on both hunters), and — a first — the 34px party
  portrait, which actually shows this fix where it didn't show pass 6's.
  Considered and explicitly declined a heavier option this run: a
  Meshy-generated, jackal-fidelity rigged hunter, blocked on game code
  only the fixer can build (`COMMON.md`'s own rule against forcing hunters
  through `ai_beast.py`) — flagged as a future `to: fixer` request, not
  attempted blind. `ALL TESTS PASSED`; playtest re-run, one failure
  (`hunter-off-marker` at foothold 4) matched the already-open fixer
  request by exact coordinates. See `design/progress/frog.md` and `## Now`
  above for the full write-up.
- 2026-09-23 — pass 6 of the asset loop on `frog` (item 2, hunters, cap
  lifted), 38→40/50: fixed pass 5's two tied-lowest lines, one concrete fix
  each. Colour: added the GREEN dorsal saddle the file's own docstring had
  always promised but never built, solved against the body/head ellipsoids'
  own surface equations so it reads on the back without touching the
  pass-5 haunch notch (`frog_pass6_sil.png` pixel-identical to pass 5's).
  Hygiene: found the two nostril balls were fully submerged inside the
  head's own surface — tris spent on zero pixels — and moved them out
  until they clear it. Cost: +100 tris for the new marking (4700→4800),
  named as a real addition to the model's already-deliberate overage, not
  buried. Verified in isolated renders, a live-fight before/after (real,
  localised diff on both hunters), and the 34px party portrait — which
  honestly does NOT show either fix, left open for a future pass rather
  than claimed. `ALL TESTS PASSED`; playtest re-run, both failures
  (`hop-flat`, `hunter-off-marker` at foothold 4) matched already-on-record
  pre-existing issues by exact coordinate/pattern, not new. See
  `design/progress/frog.md` and `## Now` above for the full write-up.
- 2026-09-23 — pass 5 of the asset loop on `frog` (item 2, hunters, cap
  lifted), 36→38/50: applied the pass-4 diagnosis in full — narrowed the
  trunk ball's depth and pushed the haunch knee outward in X — so the
  haunch reads as a bulge breaking the silhouette instead of merging into
  one round mass. Wrote the missing ANCHOR sentence. Verified in
  `_sil.png`/`_form.png` and a live-fight before/after pixel diff (change
  is real and confined to the hunter's footprint). Sil 7→8, Prop 7→8;
  geometry count unchanged. `ALL TESTS PASSED`; playtest re-run, the one
  failure (`hunter-off-marker` at foothold 4) matches the already-open
  fixer request exactly (same coordinates), confirmed pre-existing. See
  `design/progress/frog.md` and `## Now` above for the full write-up.
- 2026-09-23 — took the standing `to: artist` request, the leap-style
  recreate test: studied `leap.png`'s style in words (flat shapes, no
  outlines, atmospheric-perspective depth, full-height tree-corridor
  composition, tiny off-centre subject), then built one new card
  (`Hop`, Frog's starter deck, previously a bare icon) in that style via a
  pure 2D procedural paint (`tools/cardpaint.py`) — not a Blender render,
  since `leap.png` itself has no 3D shading cue to render toward. Palette
  sampled from `leap.png`'s own pixel histogram, not invented. Took three
  full rewrites (empty-sky gap → inverted/hanging trees → lobed canopies on
  bare trunks, the fix that actually read as leap's style) before it held
  together. Verdict, written into the request: gets the surface cues close
  enough to read as "the same family," especially at card size, but not
  Nick's hand — recommend NOT scaling this to the rest of the deck. Not
  shipped into `cardart/`, no second card, per the request's own limits.
  `ALL TESTS PASSED`. See the request
  (`requests/2026-09-23-0500-nick-to-artist-recreate-leap-style.md`) for
  the full writeup and `## Now` above for the short version.
- 2026-09-23 — cards (item 4), first pass: built a model-rendered card art
  pipeline (`tools/blender/cardart.py`, `tools/cardbg.py`) instead of
  waiting on Nick's Canva paintings, proved it on the Goblin Engineer's
  `Piston Punch` (zero painted cards on that hunter previously). Verified
  in a real hand next to both a bare-icon card and generated cards, in the
  inspector, `ALL TESTS PASSED`, playtest clean. Filed `to: nick` before
  scaling to the other ~30 cards — a style/taste call, not a code one. See
  `## Now` for the full write-up.
- 2026-09-23 — pass 4 of the asset loop on `goblin_mech` (item 2, hunters),
  35→37/50, the asset's 4-pass cap: found and fixed the real cause behind
  three passes of "reads as scattered blocks" — the upper-arm and wrist
  limbs' hex end-caps exposed as a sharp zigzag right at their box joints
  (diagnosed by a diagnostic recolour, which also cleared the CHARCOAL
  collar ring of the same suspicion) — smoothed both (`seg` 6→10, Sil
  7→8), and thickened the goggle strap ring, which read as a blade from
  the side (Style 7→8). Freed the +48 tri cost with four small, verified
  cuts elsewhere, 1396→1378, still under budget. `_sil.png` pixel-diff
  0.4% (lit-shading only); in-fight capture diff smaller than pass 3's own
  idle-animation noise floor. Playtest's `hop-flat` fail checked directly
  against the unmodified baseline — fires there too, pre-existing,
  unrelated to this asset. `ALL TESTS PASSED`. See
  `design/progress/goblin_mech.md` for the full pass detail.
- 2026-09-23 — pass 3 of the asset loop on `goblin_mech` (item 2, hunters),
  33→35/50: resolved pass 1/2's "unsure about" (the exhaust pipe reads
  fine in every camera the game uses, only separates in a top-down view
  nobody sees) as a non-issue, ruled out an unrelated pale-blue triangle
  in the live fight screenshot as `combat_3d.gd`'s own hunter-slot pip
  marker rather than an asset bug, and closed the 84-tri budget overage
  (1484→1396) by trimming segment counts on the model's biggest/gentlest
  masses and its thinnest rod — verified pixel-identical at the 64px
  silhouette rubric and unchanged in the live fight camera. Hygiene 5→7.
  `ALL TESTS PASSED`; playtest re-run (40 steps), 0 failing checks. See
  `design/progress/goblin_mech.md` for the full pass detail.
- 2026-09-22 — scored `cinder_jackal`'s fight ground (never scored before,
  despite existing renders), 22→28/50 over two applied fixes: the
  `enclose()` wall recoloured from generic SLATE/PEWTER to CHARCOAL/RUST,
  and the boulder/slab scatter from PEWTER/STONE to BROWN/CLAY, both
  matching the beast's own warm palette instead of a colour dropped in
  from a different biome. Verified in the real fight camera (not just the
  isolated Blender render, which oversold the effect under neutral
  lighting) with a direct pixel sample at the sigil close-up. Stopped
  short of the 44/50 ground stop-line on purpose — the remaining two low
  lines are the same shared-wall-system finding two other grounds already
  flagged for Nick. `ALL TESTS PASSED`; playtest re-run against the
  rebuilt ground. See `design/progress/cinder_jackal_ground.md` for the
  full pass-by-pass log.
- 2026-09-22 — fixed the jackal ear-glare request (texture edit, not a
  shader change — see `## Old`). `ALL TESTS PASSED`; checked every 3D
  camera state, no regression.
- 2026-09-22 — note created by the session.
