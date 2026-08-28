# Art waiting for a second pass

Anything the cloud routine builds in Blender lands here, because a run has no
display and cannot judge what it made. It can prove a model meets the contract —
holds where the data says, sigil at its Height, budget, one mesh, one material —
and it renders three angles so a human can look. It cannot tell you the thing is
a murky blob, or that the base reads as a spring, or that the sigil is hidden
behind the head. Every one of those got past every automated check we had.

So: the routine BUILDS and PROVES. We LOOK.

**Update, 2026-08-26.** A session with a display can now do the looking, and the
first thing it found was that the looking tool was broken. `look.py` rolled its
cameras 90° on any level shot, so the three-quarter view every judgement was
read off showed a crouching frog as a hunched quadruped. Fixed; details in
`design/progress/frog.md`.

Treat every "NEEDS A PASS" note below as **possibly describing the camera rather
than the model**. The frog scored 30/50 on the broken view and about 35 on the
fixed one without a single edit. Re-shoot before believing any of them.

The loop these now go through is `design/asset-loop.md`:
`tools\blender\look.cmd <asset> <pass>`, then open the images and score.

## How a run adds to this

One block per asset, newest at the top, appended by the run that made it:

```
### <name> — NEEDS A PASS
- built: 2026-08-25 by the routine, from tools/blender/<name>.py
- checks: assetcheck 4/4, holds PASS (3 holds + sigil), 2140 tris, 1 mesh, 1 material
- previews: design/art-previews/<name>_0.png (three-quarter), _1.png (front), _2.png (side)
- intent: one or two lines on what it was TRYING to be, so a reviewer can judge
  it against that rather than against a guess
- unsure about: whatever the run could not verify — silhouette, colour, whether
  the shape reads at fight distance. Say it plainly; this is the useful part.
```

Move the heading to `### <name> — DONE` once someone has looked and either
accepted it or done the pass. Do not delete the block: what a first pass got
wrong is the most useful thing in this file for the next one.

## What a reviewer is actually looking for

The failures that have happened, all of which passed every check:

- **Too dark to read.** The Stone Warden's two zones were dark and darker, so the
  seam that exists to explain its limiter was invisible.
- **Parts that do not touch.** The Vine-Weaver stood on a spike with hoops
  orbiting it; the Goblin's arm was spaced at arm's length and read as a rock
  standing beside him.
- **Detail hidden behind other detail.** The Warden's sigil sat on the crown
  behind its own head, invisible from the angle you fight it.
- **Slabs that overhang the silhouette**, reading as handles bolted on rather
  than as ledges cut from the body.
- **A silhouette that cannot be fixed by fixing the model.** The Vine-Weaver was
  rebuilt once, well, and still read as a lamp — because a stalk with a bloom on
  it is a line with a dot on it. When three passes all land somewhere weak, ask
  whether the design is wrong before tuning it a fourth time.

---

### boulder_ram — NEEDS A PASS

- built: 2026-08-27 by the routine, from `tools/blender/boulder_ram.py` — the
  sixth beast built end to end this way (backlog #55/#74: the "at least six
  new beasts" bar is now met — zero left to go, though all six, this one
  included, are still unreviewed). Fight pool. Bent rule: the first beast to
  spend the `max_height` `when` condition (backlog #40 named it in
  `boss.gd`, nothing had used it before this). A heavy `attack_all` (14) only
  fires if a hunter is still at Height 1 or below when it comes up in the
  pattern; otherwise it falls back to a single mild `attack` (9). Crag Pup
  punishes camping the sigil, Thrasher punishes camping either height by
  alternating swipes; this is the first beast that punishes camping the
  GROUND — climb clear before this move comes up, or eat the sweep. Blender
  install/route reused unchanged from the five beasts before it (`apt-get
  install blender python3-numpy libegl1 libgl1-mesa-dri libglx-mesa0`).
- checks: assetcheck 4/4 PASS — holds (2 ledges + sigil), a gold mark at the
  sigil's Height, sigil visible from the front (46% occluded, under the 50%
  bar), silhouette distinct (closest match `crag_pup.glb` at 78%, checked 42
  models). 1180 tris / 2600 beast budget, 1 mesh, 1 material, origin at the
  feet, no `finish()` "parts that don't touch" warning. Full `run_tests.gd`
  green (ALL TESTS PASSED, including `_test_everyone_wears_their_own_art`
  and the content-integrity test that walks `bosses.json`'s new
  `"boulder_ram"` entry and its `fight`-pool membership).
  **One real bug worth reading before the next beast, found by a debug pass
  against `AssetContract` itself rather than guesswork.** The sigil came
  back 54-55% occluded on the first four attempts, and neither moving the
  mark further forward along its own facing axis, nor moving its supporting
  crest/bridge geometry entirely below the sigil's own height band, changed
  the number by more than a point — the same "moving the mark doesn't move
  the number" symptom Silk Widow's own block already named. Rather than
  guess again, this run wrote a throwaway Godot script
  (`game/tools/_debug_sigil.gd`, deleted before commit — not part of the
  toolchain) that reused `AssetContract`'s own `z_at_xy`/`is_occluded_from_front`
  to name, per hidden gold triangle, which OTHER triangle actually blocks
  it. The answer: `beast.py`'s `mark()` helper's own AMBER parts, sitting a
  hair closer to the camera than the GOLD parts they frame — confirming
  Silk Widow's guess, not a new bug, but this time proven rather than
  inferred. Silk Widow fixed it by dropping `size` from 0.19 to 0.16; that
  same 0.16 still gave this beast 54-55%, and only dropping further to
  `size=0.12` got it under the bar (45-46%). Two things to take from that:
  first, the "safe" mark size the earlier write-up implied (0.16) is not a
  universal fix, only a size that happened to work for that beast's own
  `H`/`span` — the self-occlusion scales against the model's fixed-width
  contract band (`size.y * 0.055`, NOT proportional to the mark's own `w`),
  so a beast with a smaller overall span needs a smaller mark to clear the
  same absolute band. Second, and worth checking on EVERY beast rather than
  assumed fixed: this run also caught a real bolted-on-antenna failure by
  actually looking at the rendered preview after passing the contract at
  size=0.16 — the crest+bridge, kept clear of the band to protect the
  occlusion number, produced a grey ball on a long stick with the mark at
  its tip, reading exactly as the "periscope" this file already warns
  about. The contract cannot see that; only the render caught it. It was
  rebuilt as a small STONE plate recessed flush into the hump's own front
  face with the mark sitting just proud of it (a mounted shoulder-sigil
  rather than an antenna), which is what shipped.
- previews: `design/art-previews/boulder_ram_0.png` (three-quarter), `_1.png`
  (front), `_2.png` (side). Portrait: `game/assets/portraits/boulder_ram.png`
  (`portraits.py` regenerates all 22 by design; only the new one was copied
  into the repo, the other 21 left untouched on disk). `FOCUS["boulder_ram"]
  = (0.34, 1.35)` in `portraits.py` — needed a wider span than most
  quadrupeds to fit the raised hump and the lowered head in the same frame.
- intent: a low, block-shouldered quadruped built for a charge rather than a
  bite — four thick stubby legs, a wide boxy barrel chest, a raised stony
  hump over the front shoulders carrying curled ram horns and a lowered
  head, in boxy stone-plate colours (STONE, CLAY, UMBER, TAN) rather than
  the smoother organic palette the elite-pool beasts wear, so the
  silhouette reads "boulder" before it reads "animal" — distinct from
  Thrasher's low elongated newt and Husk Beetle's domed shell, the other two
  fight-pool additions.
- unsure about: looking at the three rendered angles myself (not a claim
  this is good — that call is Nick's), three things stood out. First, the
  overall read leans more "boxy robot on legs" than "beast" from the
  three-quarter and side angles (`_0.png`, `_2.png`) — the barrel-chest box
  is large and flat-sided relative to the rounded hump and head, and the
  four black stubby legs read almost mechanical against the warm brown
  body; whether that's a fair "boulder" reading or needs breaking up with
  more shape variety is a judgement call this run can't make. Second, the
  curled ram horns read reasonably clearly from the front (`_1.png`) but
  nearly disappear from the three-quarter angle (`_0.png`), where only a
  thin pale sliver near the neck hints at them — they may be too thin, or
  need a stronger colour break from the body, to read at fight distance
  from most angles. Third, the shoulder-mounted sigil plate that replaced
  the antenna reads fine face-on but from the side (`_2.png`) still shows a
  short grey nub ahead of the gold mark that could pass for a stuck-out
  eye rather than a mounted plate — smaller than the antenna problem it
  replaced, but not fully gone, and worth a second look once there's a
  screen to judge it against the fight camera's actual angle rather than
  these three fixed previews.

---

### silk_widow — NEEDS A PASS

- built: 2026-08-27 by the routine, from `tools/blender/silk_widow.py` — the
  fifth beast built end to end this way (backlog #55/#74 — five of the at
  least six #55 asks for; one still to go). Elite pool. Bent rule: `frail`
  paired with an `undefended`-gated `attack`. Two Frail applications a cycle
  chip away at Block gained, and the one move that spikes hard (18 vs a
  baseline 10-11) only spikes if a hunter has ZERO Block when it comes up.
  Stone Warden already has one `undefended` move, but it sits alongside a
  `height_split` limiter that is the actual centrepiece there; this is the
  first beast where staying defended against something actively eroding your
  Block IS the whole puzzle. None of the other five elites touch that
  strategy: Mire Snapper drains, Frost Sentinel wards with Artifact, Grove
  Bear enrages, Shifting Idol moves the sigil, Gloom Moth clogs the deck.
  Blender install/route reused from the four beasts before it
  (`apt-get install blender python3-numpy libegl1 libgl1-mesa-dri
  libglx-mesa0`), no new setup needed.
- checks: assetcheck 4/4 PASS — holds (2 ledges + sigil), a gold mark at the
  sigil's Height, sigil visible from the front (47% occluded, under the 50%
  bar), silhouette distinct (closest match `penguin.glb` at 64%, checked 41
  models). 1464 tris / 2600 beast budget, 1 mesh, 1 material. Full
  `run_tests.gd` green (ALL TESTS PASSED, including
  `_test_everyone_wears_their_own_art`).
  **Two real bugs hit building this one, both worth reading before the
  next beast.** First, a two-lobe body (a spider's cephalothorax and
  abdomen, built as two separate balls joined at a waist) needs the JOIN
  itself sized generously — a first attempt's waist-pinch ball left a
  0.14-unit gap between the two lobes' bounding boxes, and `finish()` came
  back with the ENTIRE front half (cephalothorax, fangs, eyes, and the two
  front legs anchored to it — nine parts) as its own floating island,
  because nothing in that whole cluster touched the abdomen at all. A
  two-lobe body is not two single-ball beasts glued together; the piece
  between them has to be sized to actually bridge both AABBs, not just look
  like it does in the numbers. Second, and the more interesting one: the
  sigil passed every OTHER check on the first two real builds but came back
  86% occluded, and moving the mark 0.3 units further forward changed
  NOTHING (still 51%, to the percentage point) — because the occluder
  wasn't the body at all, it was `beast.py`'s own `mark()` helper. `mark()`
  draws three parts (a GOLD taper, an AMBER taper, an AMBER ring), and the
  visibility check only excludes the GOLD triangles from counting as
  occluders against themselves — the AMBER ring and second taper count as
  ordinary body geometry, and with this beast's `facing` value they landed
  slightly IN FRONT of the gold face they're meant to frame. Bog Leech and
  Thrasher pass at 47-48% with the exact same `facing=(0, -0.94, 0.30)`,
  which says this self-occlusion is baked into `mark()` for every beast
  and normally sits just under the 50% bar — mine tipped over it not from
  body placement but from `size=0.19` versus their `0.16-0.18`; dropping to
  `size=0.16` (unchanged position) took it from 51% to 47% with no other
  change. Worth checking early next time: if the sigil comes back buried
  and moving the mark doesn't move the number, the culprit may be the mark
  itself, not the body — try shrinking `size` before adding more forward
  clearance.
- previews: `design/art-previews/silk_widow_0.png` (three-quarter), `_1.png`
  (front), `_2.png` (side). Portrait: `game/assets/portraits/silk_widow.png`
  (`portraits.py` regenerates all 21 by design; only the new one was copied
  into the repo, the other 20 left untouched on disk).
- intent: a low, splayed spider — a small forward cephalothorax with fangs
  and a huddle of eyes, a big swollen abdomen behind it carrying a red
  hourglass mark on the underside, six long bent-kneed legs, and the gold
  sigil on a small off-centre crest atop the abdomen. The bent-kneed leg
  silhouette (an elevated knee above both the hip and the foot) is meant to
  read as "spider" against the four straight-legged beasts already in the
  cast.
- unsure about: looking at the three rendered angles myself (not a claim
  this is good — that call is Nick's), three things stood out worth a human
  checking specifically. First, the side view (`_2.png`) shows the
  sigil-crest bridge as a long thin rod poking sideways out of the body with
  the gold mark sitting at its tip — it reads as a spike or an antenna
  rather than a mark ON the creature, the same "stalk is a visible cost, not
  a free fix" problem Bog Leech's own block already named, just from a
  different beast. Second, the small grey crest ball that carries that rod
  sits above the shoulder in a way that reads as a loose sphere perched on
  the body rather than grown from it, most visible in the three-quarter and
  side angles. Third, the red belly hourglass — two mirrored tapers meeting point to
  point — reads in the previews as a small red wedge rather than a
  recognisable hourglass; it may need to be bigger or flatter to read as
  the intended marking rather than as a red smudge, at fight distance.

---

### thrasher — NEEDS A PASS

- built: 2026-08-27 by the routine, from `tools/blender/thrasher.py` — the
  fourth beast built end to end this way (backlog #55/#74 — four of the at
  least six #55 asks for; two still to go). Fight pool. Bent rule: pure
  repositioning pressure. `swipe_low` (hits anyone ON the ground) and
  `swipe_high` (hits anyone OFF it) alternate as its whole pattern, so no
  height is ever safe two turns running — Root Lurker punishes staying low,
  Sky Snapper punishes staying high, and this is the fight-pool beast that
  punishes staying ANYWHERE. Reading the telegraph and climbing or
  descending before it lands is the entire fight. Blender install/route
  reused from husk_beetle/gloom_moth/bog_leech's own notes (`apt-get install
  blender python3-numpy libegl1 libgl1-mesa-dri libglx-mesa0`), no new setup
  needed.
- checks: assetcheck 4/4 PASS — holds (2 ledges + sigil), a gold mark at the
  sigil's Height, sigil visible from the front (47% occluded, under the 50%
  bar), silhouette distinct (closest match `bog_leech.glb` at 59%, checked 40
  models). 1280 tris / 2600 beast budget, 1 mesh, 1 material. Full
  `run_tests.gd` green (ALL TESTS PASSED, including
  `_test_everyone_wears_their_own_art`).
  **Two things worth reading before the next beast.** First, a body built
  around one long, low, symmetric torso (a legless-underneath, elongated
  mass, the same instinct a newt or lizard invites) hits a DIFFERENT failure
  than Bog Leech's — not sigil burial, but a runaway "outward push": a
  climb-point anchor placed ON the spine's own centreline reads its
  "outward" direction as running the FULL LENGTH of the torso (beast.py's
  auto-placement can't tell "outward from a hump" from "outward along a long
  axis" when the anchor sits exactly on that axis), so a shelf at Height 4
  first came back pushed out by 1.5 units — more than the whole body's own
  height — with grown filler steps stretching the model's bounding box from
  roughly 2.5 units deep to over 4. Anchoring the ridge shelves off to ONE
  side of the centreline (mirroring Bog Leech's own sigil-crest fix, but for
  a HOLD rather than the mark) cut that push to a much smaller, still
  nonzero, ~0.5. Second, this beast's own version of Bog Leech's sigil-crest
  lesson: placing the crest ball's centre exactly at the sigil's own Height —
  which reads as the "obviously correct" choice — recreates the exact
  burial Bog Leech already wrote up (62%, then 69% occluded on two attempts),
  because a low-poly ball's widest cross-section sits at its own centre
  regardless of how far sideways the mark is nudged. What actually worked,
  again, was real forward clearance (the mark sits roughly a ball-diameter
  in front of the crest's own edge) bridged by a thin stalk, not a
  hand-measured "just past the surface."
- previews: `design/art-previews/thrasher_0.png` (three-quarter), `_1.png`
  (front), `_2.png` (side). Portrait: `game/assets/portraits/thrasher.png`
  (rendering `portraits.py` regenerates all 21 by design; only the new one
  was copied into the repo, the other 20 left untouched on disk).
- intent: a low, crouched newt — four short splayed legs, a long flat body,
  a bright orange warning-colour throat and belly, and a tail that curls up
  and back over its own spine as if mid-lash, wearing the fight's own
  up/down motion as its silhouette. Two ridge-humps step up the spine for
  the climb, in cool steel/slate against the warm dark hide.
- unsure about: looking at the rendered previews (this run can read the PNGs
  it produces, though not the live 3D scene `screenshot.gd` would show), the
  result reads more like a stag-beetle-crossed-with-rat than the intended
  newt — the head is closer to a rodent snout than a lizard's, and the long
  smooth black torso doesn't obviously say "amphibian." The two climb
  shelves are small pale-grey/steel nubs against a near-black body; from the
  side angle especially they read closer to this file's own "handles bolted
  on" failure than to a ridge growing out of the spine, and the automatic
  filler steps grown to close the gap between each shelf and the body's real
  surface (a consequence of the off-centre-anchor fix above) add a couple of
  additional small flat tabs that were not hand-placed and were not checked
  by eye at fight distance. The sigil's forward stalk is a visible, thin
  protrusion for the same reason Bog Leech's is — a direct cost of clearing
  the burial check, not a free result. Whether the near-black base colour
  reads as intended (rather than too dark, this file's most common recorded
  failure) and whether the tail's curl is legible against the fight
  background are both unconfirmed; a human pass with the model in-engine,
  under the game's actual lighting and at actual fight-camera distance, is
  needed before any of this counts as good rather than merely contract-legal.

---

### bog_leech — NEEDS A PASS

- built: 2026-08-27 by the routine, from `tools/blender/bog_leech.py` — the
  third beast built end to end this way (backlog #55/#74 — three of the at
  least six #55 asks for; three still to go). Elite pool, bent rule pairs
  `leech` with `enrage`: every bite it lands both drains and heals it AND
  feeds its own strength, so the fight escalates the longer it runs rather
  than staying flat — none of the other elites make that pairing their whole
  pattern (Mire Snapper spends leech as one move among five generalist ones;
  Frost Sentinel wards with Artifact; Grove Bear enrages but never heals off
  it; Shifting Idol moves the sigil; Gloom Moth clogs the deck instead of the
  health bar). Husk Beetle (fight pool) also punishes slow play, but
  passively — it just heals; nothing it does gets stronger by hurting you.
  Blender install/route reused from husk_beetle/gloom_moth's own notes
  (`apt-get install blender python3-numpy libegl1 libgl1-mesa-dri
  libglx-mesa0`), no new setup needed.
- checks: assetcheck 4/4 PASS on the final build — holds (2 ledges + sigil),
  sigil colour, sigil visibility (48% occluded, under the 50% bar), silhouette
  distinct (closest match `shifting_idol.glb` at 79%, checked 39 models). 1868
  tris / 2600 beast budget, 1 mesh, 1 material. Full `run_tests.gd` green
  (ALL TESTS PASSED).
  **Worth reading before the next beast**: this one did NOT pass on the first,
  second, or several following tries, and the reason is worth knowing before
  reaching for the same shape again. First, a real bug in this run's own
  workflow, not the model: Godot only reimports a changed `.glb` when the
  editor opens (the README already says this) — every rebuild after the
  first was silently checked against a STALE cached mesh, so five or six
  fixes in a row reported the exact same "100% buried" verdict no matter what
  changed, because none of them were actually being tested. Re-running
  `--headless --path game --import` before every check surfaced the real,
  moving number. Second, once real feedback was flowing, the actual defect:
  a sigil mark placed at the CENTRE of its own hosting ball (the same shape
  `gloom_moth.py`'s forehead crest uses successfully) only clears that ball's
  own front hemisphere when the ball's centre HEIGHT doesn't coincide with
  the sigil's own height — this ball's did, by construction, so the ball's
  widest, most-forward cross-section sat exactly where the mark needed to be,
  no matter how the ball's size or position was tuned. The fix that actually
  worked was pulling the mark clearly forward of that surface (not just past
  the ball's centre) and bridging the resulting gap with a thin separate
  taper, rather than trying to reshape the ball itself. A second, smaller
  find along the way: an earlier "vein seam" design used boxes thin in only
  ONE axis, which read fine in the contract but rendered as a giant flat red
  wall covering the whole model from the front — caught by looking at the
  rendered preview, not by any automated check.
- previews: `design/art-previews/bog_leech_0.png` (three-quarter), `_1.png`
  (front), `_2.png` (side). Portrait: `game/assets/portraits/bog_leech.png`
  (rendering portraits.py regenerates all 20 by design; only the new one was
  copied into the repo, the other 19 left untouched on disk).
- intent: a squat, swollen leech hunched low over its own puddle — a ringed
  body with thin blood-red vein-stripes, a wet sucker-mouth ring at the
  front-bottom with two small dark eye-spots above it, six tiny sucker-pads
  underneath instead of legs (a leech grips with its body, not limbs), two
  fed-fat body-segments stepping up its back for the climb, and a small
  crest — off to one side, on a thin bridging stalk — where the sigil sits.
- unsure about: the sigil reads clearly from the front (confirmed by looking
  at the render, not just trusting the 48%-occluded number), but in the side
  view it sits out on a visible thin stalk that reads more like a stuck-on
  lollipop or antenna than a mark grown out of the body's own surface — a
  direct cost of the fix above, and the most honest thing to flag here: the
  fix that passed the automated check is not obviously the best-looking
  answer, and a human pass may want to rebuild that crest as a wider, flatter
  growth rather than a ball-on-a-stick once there's a display to judge it by
  eye instead of by area percentage. The body reads as round and soft rather
  than distinctly "leech-shaped" — recognisable as a wet, ringed creature but
  it leans generic-blob more than the brief wanted; the mouth ring and
  vein-stripes are doing most of the work of saying "leech" rather than the
  silhouette itself. The two climb shelves are small, pale grey tabs against
  a dark body — likely readable up close but worth checking against #81's
  already-flagged "ledges read as scaffolding" at real fight distance. Legs
  (sucker-pads) are tiny by design; worth checking they don't vanish against
  a dark background in the game's actual lighting, the same gap husk_beetle's
  own review flagged for its antennae.

---

### gloom_moth — NEEDS A PASS

- built: 2026-08-27 by the routine, from `tools/blender/gloom_moth.py` — the
  second beast built end to end this way (backlog #55/#74 — two of the at
  least six #55 asks for; four still to go). Elite pool, bent rule `curse`:
  rather than hit hard it hands a hunter two Bruised Grips a turn and chips
  Block with `frail` between doses, so the fight pressures your DECK rather
  than your HP — none of the other three elites (Mire Snapper, Frost
  Sentinel, Grove Bear) or Shifting Idol make curse their whole pattern.
  Blender install and route were already proven by husk_beetle earlier this
  run (`apt-get install blender python3-numpy libegl1 libgl1-mesa-dri
  libglx-mesa0`), so this build reused it directly.
- checks: assetcheck 4/4 PASS — holds (2 ledges + sigil), sigil colour
  (0.2141 of footprint), sigil visibility (46% occluded, under the 50% bar),
  silhouette distinct (closest match `shifting_idol.glb` at 72%, checked
  against all 38 existing models). 1856 tris / 2600 beast budget, 1 mesh,
  1 material. Full `run_tests.gd` green (484 passed).
- previews: `design/art-previews/gloom_moth_0.png` (three-quarter), `_1.png`
  (front), `_2.png` (side). Portrait: `game/assets/portraits/gloom_moth.png`
  (rendering it regenerated all 19 other portraits too — a Blender-version
  rendering difference, not a content change — so those were reverted and
  only the new one is committed).
- intent: a big fuzzy-thorax moth on six thin insect legs, a soft rounded
  mass of folded wings draped over its back doubling as the two holds,
  antennae and a pale dust-marking on its forehead where the sigil sits.
- what changed mid-build, and why it's worth reading: the first two attempts
  built the wings as free-standing flat boxes (the same `shelf()` pattern
  `husk_beetle.py` uses for its shell plates) placed on the model's own
  centreline. Looking at the rendered previews — actually looking, not just
  trusting the contract, same as `husk_beetle`'s own note — both attempts
  read as loose slabs bolted onto a ball, exactly the "reads as handles
  bolted on" failure this file's own review section names. The root cause,
  worked out from `beast.py`'s own source rather than guessed at: the
  auto-push/auto-fill machinery in `_decorate()` pushes an unanchored climb
  point radially outward from the model's own bounding-box centre, and a
  centreline anchor (x=0) on a body with a big round head bulging forward of
  it gets pushed FORWARD toward the head rather than sideways onto the
  wing — which is what was growing extra stray filler boxes reaching toward
  the face. Fixed by rebuilding the wings as one big soft ridge-shaped mass
  (the same "hump, then a small flat step on its front slope" trick
  `crag_pup.py` already uses successfully) with the two climb anchors placed
  off-centre, standing on ONE side of the ridge rather than on the seam
  between two. This is not a guess that it looks better — it visibly does,
  compared side by side across three rebuilds — but it is still only judged
  against a static render, not the game's own live camera.
- unsure about: whether the wing-hump reads as *wings specifically* rather
  than just a second fuzzy hump — there's no fold-line or wing-tip detail
  differentiating it from a shoulder or a growth, so a player may not clock
  "moth" from the silhouette alone without the antennae and portrait doing
  most of that work. The two flat climb steps are small and close to the
  ridge's own colour band, which fixed the "bolted-on slab" problem but may
  have swung the other way — they could be too subtle to read as a place to
  climb TO at fight distance, the opposite failure from #81's
  already-flagged "ledges read as scaffolding" on other beasts. The
  proboscis is a small curled taper tucked under the head; it may read as a
  stray dark mark rather than a mouthpart at a glance. Legs are
  deliberately hair-thin per the brief ("moth legs read the thinnest in the
  cast") — worth checking they don't disappear entirely against a dark
  background in the actual game lighting, which is brighter than this
  preview's flat studio light per `husk_beetle`'s own note on that gap.

---

### husk_beetle — NEEDS A PASS

- built: 2026-08-27 by the routine, from `tools/blender/husk_beetle.py` — the
  first beast built end to end by a cloud run with a genuinely working Blender
  (backlog #74's last bar): `download.blender.org` is still policy-blocked
  through the egress proxy, but `apt-get install blender` reaches Ubuntu's own
  archive and installs 4.0.2 headless with no display — a route no prior run
  tried. It needed `apt-get install python3-numpy libegl1 libgl1-mesa-dri
  libglx-mesa0` on top: the glTF exporter dies with `ModuleNotFoundError:
  numpy` without the first, and `preview.py`/`portraits.py`'s offscreen render
  needs the second two. Adds a 7th fight-pool beast (backlog #55 — one of the
  at least six it asks for; five still to go), whose bent rule is `regen`
  (heals 6 HP a turn unless the fight ends fast) — the one fight-pool idiom
  none of the other six use yet.
- checks: assetcheck 4/4 PASS — holds (2 ledges + sigil), sigil colour, sigil
  visibility (47% occluded, under the 50% bar), silhouette distinct (closest
  match crag_pup.glb at 72%, checked against all 37 existing models). 1384
  tris / 2600 beast budget, 1 mesh, 1 material. Full `run_tests.gd` green
  (484 passed) — including a real regression this addition exposed and fixed,
  not dodged: growing the fight pool from 6 to 7 entries shifted
  `_make_session()`'s seeded RNG roll onto the Root Lurker (which already
  carries its own add) for a test that assumed a bare beast and then appended
  one of its own, so the size check failed. Fixed in `run_tests.gd` by
  clearing `combat.adds` before the test appends Grub, so the assertion no
  longer depends on which beast a seed happens to roll.
- previews: `design/art-previews/husk_beetle_0.png` (three-quarter), `_1.png`
  (front), `_2.png` (side).
- intent: a stout, low ground beetle climbing its own back — four stubby legs,
  a two-segment shell forming the two ledges, mandibles up front, the sigil on
  a raised tail-plate just behind the second shelf.
- unsure about, and this time actually looked rather than only trusting the
  contract (the Read tool renders a PNG for me; that is real vision on a
  static image, not the same as the game's own live camera, and worth flagging
  as a change from how every earlier NEEDS-A-PASS block in this file was
  written): the two shell segments pass the hold contract — a hunter really
  can stand there — but do not read as visually distinct plates in the render;
  the body still looks like one smooth rounded mass with faint ridges rather
  than a clearly plated beetle. The antennae visually cross over the body from
  the three-quarter angle (a perspective artefact of two symmetric limbs, not
  an actual mesh collision — the front and side angles read cleanly) and still
  look a little odd there. The sigil is sized down to 0.16 world units
  (against the `mark()` default of `H * 0.115 ≈ 0.35`) specifically to clear
  the 50%-occluded bar after three larger sizes failed it at 100%, 61%, and
  54% in turn — at that size it may read as a small badge rather than a
  landmark at fight distance. On balance it reads more like a rounded
  pill-bug than an armoured ground beetle; a flatter carapace with a sharper
  shell-split down the spine is the honest next step if it doesn't hold up
  next to the other thirteen.

---

### the twenty-eight card icons — NEEDS A PASS

Built 2026-08-26 by `tools/blender/icons.py`. Each is a tiny 3D scene in the
shared palette, rendered orthographic and HEAD-ON — an icon is read at 42 pixels
as a silhouette, and a three-quarter view of a small object is a smudge.

They replace 28 Kenney glyphs that were recoloured by a tint table to tell them
apart. These carry their own colour, so `card_view.TINT` is gone.

- **What to judge:** open a hand and look at the cards, not at the source PNGs.
  The only question is whether you can tell two cards apart at a glance, because
  a hand is read by shape, fast.
- The brief for each is the comment beside it in `card_view.ICONS` — what a card
  wearing it DOES, not what it is about. An icon showing flavour instead of
  mechanic is worse than none.
- **the crowded families are where this will fail if it fails.** Six icons are
  about going up (`climb`, `ascend`, `peak`, `rope`, `lift`, `rally`) and four
  are about not dying (`shield`, `guard`, `wall`, `support`). They were drawn to
  differ in silhouette rather than colour, but that is the pair to check first.
- unsure about: whether they read a touch pale against the brown card, and
  whether `guard` (a shield with a clock face) is distinguishable from `shield`
  at 42px, which is the closest pair in the set.
- two were redrawn already after looking at them at size: `lift` was a green Z
  and is now two figures with one hauling the other up; `rally` was a crown and
  is now a horn.

---

### four defensive-keyword icons (intangible, buffer, plated_armour, thorns) — NEEDS A PASS

Built 2026-08-28 by `tools/blender/icons.py`, batch 2 (backlog #76 — "one batch
per run"). Not a new gap this time, a wrong answer: `ghost_step`, `overhang`,
`hardshell` and `barbed_hide` grant Intangible, Buffer, Plated Armour and
Thorns respectively — none of them Block — and all four were wearing `shield`,
the Block icon, because `shield` was the closest defensive glyph on hand at
the time. A player reading a hand by shape would see four Block cards that
aren't. Also reassigned `sure_footing` (a pure Dexterity card, no Block
either) from `shield` to `flask`, matching the existing convention `sharpen`/
`oil_can` already use for a pure Strength card — no new art, just the same
mismatch, one line.

- **What to judge:** the same question as the first batch — can you tell these
  four apart from `shield`/`guard`/`wall` at 42px, and does each one look like
  what its card actually does.
- `intangible`: three overlapping diamonds on a diagonal, fading light-to-dark
  toward one corner — an afterimage/phase-out. Untested at 42px whether the
  palest diamond (near-white on a light card face) disappears rather than
  reading as "faded."
- `buffer`: a hex-faceted ring (6-sided, not round, so it can't be mistaken for
  `guard`'s ring) with a red shard bouncing off the top-right edge — the hit
  that got cancelled. Unsure whether the shard reads as "deflected" or just as
  a stray triangle stuck to the hexagon; it's the one part of this batch drawn
  without a clear precedent to copy.
- `plated_armour`: three stacked overlapping plates, wide/dark at the bottom
  to narrow/pale at the top, with three rivet dots. Meant to read as lamellar
  scale rather than the brick-grid `wall` or the kite-shaped `shield`.
- `thorns`: a spiked ball with two spikes tipped red. The first build centred
  every spike ON the ball's own origin, which buried half of each spike inside
  the mesh and left it reading as a smooth ball with faint bumps — caught by
  rendering and looking, not by the contract, since icons have no assetcheck.
  Rebuilt with each spike's base offset out to the ball's own radius instead,
  so the half that's meant to be visible is the half that actually clears the
  surface. The fix is in the file now; still unverified how it reads at 42px
  next to `expose` (also spiky, also red-accented) and `peak` (also has spikes
  radiating from a point).
- Not touched this batch, left for a future one if it's worth it:
  `sure_footing`'s new `flask` assignment repeats the pre-existing oddity that
  `flask` (a potion) is also the icon for a pure stat-buff card. That
  inconsistency already shipped with `sharpen`/`oil_can`; this batch matched
  it rather than relitigating it.

---

### Strength and Dexterity icons (strength, dexterity) — NEEDS A PASS

Built 2026-08-28 by `tools/blender/icons.py`, batch 5 (backlog #76). Not a new
gap, the one batch 2 explicitly left open: `sharpen`, `oil_can`, `alpine_focus`
and `old_grudge` grant Strength, and `sure_footing` grants Dexterity — five
cards, and every one of them wore `flask`, the potion icon, though none
touches a potion at all. Batch 3's own note ("the card doesn't touch Strength
or Dexterity or a flask at all") and batch 2's own closing line ("left for a
future one if it's worth it") both already named this. Built two icons, not
one folded-together "buff" glyph, because Strength and Dexterity are already
distinct keywords with their own tooltip text in `keywords.json`, and merging
them would just trade one wrong answer (a potion) for a vaguer one. After this
batch nothing wears `flask` — it's not deleted, just currently unused, the
same as any other Kenney glyph nothing points at — and backlog #76's own
numeric bar ("at least eight new icons") is met for the first time: intangible,
buffer, plated_armour, thorns, light, frail, strength, dexterity is eight.

- **What to judge:** whether `strength` and `dexterity` read as two different
  things from across a hand, not just different from `flask`.
- `strength`: a dumbbell — two dark ringed weight plates joined by a rust bar
  with a gold grip wrap. Checked at both the 256px render and a downsampled
  42px pass; it reads clearly as a dumbbell at both sizes, the cleanest read
  in this batch.
- `dexterity`: went through three builds, the first two wrong in ways only the
  render caught (icons have no assetcheck). First attempt: a column of small
  flat plates fanned off a central quill — rendered as a fir tree, not a
  feather, because a flat plate's own silhouette is a diamond and a stack of
  diamonds reads as branches. Second attempt: two single wide-based tapered
  blades flaring from the shaft's foot — rendered as a tent, with the barb
  texture lines floating clear of the shape because they were sized for the
  first design's footprint, not the second's. Third (shipped): one soft
  vane built from two overlapping balls (the same two-tone trick `flask`'s
  own body already uses), a thin quill poking through both ends, and four
  thin grooves pulled in front of the vane's own front surface (`y=-0.22`,
  ahead of the lit ball's `y=-0.19` front face — a groove left at `y=0` the
  way the first two attempts had it sits BEHIND the ball from the camera and
  is invisible, the same "camera is at -Y, nearer wins" trap `rally`'s own
  comment already names) so the barb lines actually show up on top instead
  of being buried inside the mesh.
- unsure about: `dexterity` reads clearly as an oval vane with diagonal
  texture and a small stem at both the 256px render and a downsampled 42px
  pass, but the 42px pass also shows the barb grooves fading to a faint
  texture and the quill nearly disappearing — so what's confidently verified
  is "a distinct blue-toned oval, not confusable with `flask` or any other
  icon," not "unmistakably a feather" the way `strength`'s dumbbell is
  unmistakably a dumbbell. Whether it reads as *Dexterity* specifically,
  rather than just "some other stat," next to `strength` in an actual hand
  is exactly the judgement this file can't make.
- Rendered with `apt-get install blender` (4.0.2) again, same as batches 3
  and 4 — `download.blender.org` is still a policy 403 through the egress
  proxy (backlog #74). This run's apt install also needed `numpy` (missing
  from the system Python `blender` now links against, not bundling its own
  the way the tarball build does) and `libegl1`/`libegl-mesa0` (headless
  rendering failed with `Couldn't open libEGL.so.1` until installed) — worth
  naming since neither shows up until you actually try to render, not at
  import. A full re-render of all 36 icons showed pixel differences against
  every one of the 34 other committed PNGs, the same rendering-version drift
  batches 3 and 4 already found, not a code change. Only `strength.png` and
  `dexterity.png` were copied out; the other 34 committed files are
  untouched.

---

### one Frail icon (`frail`) — NEEDS A PASS

Built 2026-08-28 by `tools/blender/icons.py`, batch 4 (backlog #76). One card:
`crippling_blow` ("Deal 5 damage. Frail 2.") wore `sword`, which isn't wrong —
it is a plain attack — but `sword` is also what every OTHER plain hit with no
second effect wears, so the one card in the game that debuffs a Titan's own
Block looked identical to a card that does nothing but hit. Same shape of
finding as batch 2's four (Intangible/Buffer/Plated Armour/Thorns wearing
`shield` while granting no Block): Frail is that family's fifth member — a
Block-adjacent status — and was the only one of the five still unmarked.

- **What to judge:** does `frail` read as *broken/weakened* rather than
  *whole* next to `shield`/`guard`/`wall`/`plated_armour` — all four are a
  single intact silhouette, so the split was meant to be the signal, not the
  colour (still STEEL/SILVER, the same family's palette, on purpose — Frail
  IS about Block).
- Built as a kite shield broken into two halves along a jagged dark crack,
  each half nudged apart (rotated and offset outward) so they visibly no
  longer meet, plus one small chip already broken free and drifting down and
  clear of the shield below-right.
- This run could actually open the rendered PNG and look at it directly —
  the Read tool displays image files inline, which earlier icon batches
  either didn't try or worked around with pixel-alpha sampling instead. Two
  iterations: the first pass (flat rounded rectangles, no shield point) read
  as a stack of cracked bricks rather than a shield at all; giving each half
  its own tapered point at the bottom, the way `shield()` itself does,
  fixed that — the second pass reads clearly as two shield-halves with a
  crack and a falling chip, at both the 256px render and a downsampled
  42px card-size check against `shield.png` at the same scale for contrast.
  Flagged as NEEDS A PASS regardless: looking at a render is not the same
  judgement Nick would apply looking at it live in-game, on an actual card
  face, next to a real hand — this file's own standing rule (a `cloud-art`
  item is never ticked by the routine) holds even when the routine can see
  the image.
- unsure about: whether "broken shield" reads as *Frail* specifically versus
  just "something bad happened to my Block" in general, without the keyword
  tooltip open next to it; whether the crack is thick enough to survive
  in-game lighting/modulate at actual card size, since the downsample check
  here used a flat resize, not the game's own rendering path; and whether
  the floating chip at bottom-right gets cropped or crowded once it sits
  next to the card's cost pip and text, which this render doesn't show.
- Same version-drift note as batch 3: rendered with `apt-get install
  blender` (4.0.2), not `download.blender.org`'s 4.1.1 (still a policy 403
  through the egress proxy, unchanged from backlog #74). A full re-render of
  all 34 icons showed pixel differences against every one of the 33 other
  committed PNGs, confirming that's rendering-version drift and not a code
  change (`icons.py` was only added to, nothing existing was edited). Only
  `frail.png` was copied out; the other 33 committed files are untouched.

### one Light icon (`light`) — NEEDS A PASS

Built 2026-08-28 by `tools/blender/icons.py`, batch 3 (backlog #76). One card,
not a new gap but the same "wrong answer" shape as batch 2: `spark` — 0 cost,
"Gain 2 Light." and nothing else — wore `flask`, the potion icon, because
`flask` was the closest self-buff glyph on hand when the Lightbearer's cards
were first stamped. It touches no potion at all. The other seven Light cards
(`warm_glow`, `kindled_strike`, `beacon`, `guiding_light`, `steady_flame`,
`flare`, `sunburst`) all pair Light with a second effect — heal, block,
damage — that's their real read, so their existing `support`/`shield`/`sword`
icons still tell the truth and were left alone; only the pure-Light card was
actually lying.

- **What to judge:** does `light` read as its own thing next to `fire`
  (orange flame tongues, for burning damage), `expose`/`target` (rings), and
  `bomb` (a round shell) — the icons nearest it in the "burst from a point"
  family — and does it read as *light* rather than, say, a compass rose or an
  asterisk.
- Built as an 8-point starburst: a pale core ball with four long gold rays on
  the cardinals and four shorter amber rays on the diagonals, all straight
  tapers rather than `fire`'s curved ones, so the silhouette can't be
  confused with a flame.
- Repeats, and this time catches in the same run, the exact trap `thorns`'
  own comment already named: `taper()`/`spike()` centres a ray's length on
  its base point, so a ray based AT the ball's own centre only pokes out by
  half its length, and half of THAT is still buried inside the ball. The
  first build did exactly this and rendered as a plain cross — the four
  diagonal rays were short enough to vanish entirely inside the core, and
  even the four cardinal rays cleared the surface by far less than intended.
  Confirmed by sampling pixel alpha outward from centre along each ray angle
  (not by eye — this was caught before ever spending a render on the "does
  it look right" question), not just by looking at the thumbnail. Fixed by
  basing every ray out at the ball's own radius (0.15, just inside its 0.16
  scale) the way `thorns` does, so the near half embeds into the ball and
  the far half is the part that actually shows.
- unsure about: whether the long/short ray contrast reads at 42px on a card
  face, or whether it just looks like eight identical spikes; whether gold
  rays on amber rays is enough colour separation once card-face lighting is
  applied, versus needing a starker two-tone split; and whether an 8-point
  star is confusable with `expose`'s ring-plus-four-ticks design from across
  a real hand of cards, since both are "radiating from a centre" shapes.
- Not rebuilt against the rest of the icon set: re-running `icons.py` here
  used `apt-get install blender` (4.0.2), not the `download.blender.org`
  4.1.1 build earlier batches used (still a policy 403 through the egress
  proxy — unchanged from backlog #74's note), and a pixel diff against the
  32 already-committed PNGs showed real rendering differences, not just file
  metadata — almost certainly a Blender-version shading difference, not a
  code change, since `icons.py` itself was only added to, not edited for any
  existing icon. Only `light.png` was copied out of this run's render; the
  other 32 committed files are untouched, so this batch cannot have shifted
  how anything else on a card face looks. Worth a note for whoever next has
  a real `4.1.1`: a full re-render diverges from what's committed even with
  no source change, so treat version drift itself as something to watch, not
  just individual icon content.

### the nineteen portraits — NEEDS A PASS

Rendered 2026-08-25 from the models themselves by `tools/blender/portraits.py`.
Five hunters and fourteen beasts, one each, replacing fifteen Kenney animal
photos that had to cover nineteen characters — so the Mire Snapper and the Root
Lurker were the same crocodile, and two beasts shared a penguin.

Rendered orthographic, three-quarter from the front and a little above (the
angle the fight camera uses), on transparency, at 512px. Because they come from
the models they stay right: change a beast and its portrait changes with it,
which a painted one never would.

- **What to judge:** they are shown at **34 pixels** in the party panel and about
  76 on a card. Look at them there, not at the source files. The question is
  only ever "can I tell which one this is at a glance" — a portrait that is
  beautiful at 512 and a smudge at 34 has failed.
- `FOCUS` in the script is the one hand-tuned thing: where on each body to point
  and how much to fit. "The face" is not a fraction of the bounding box on a
  creature that is mostly jaw or mostly tail, so a few say where to look. If one
  is framed wrong, that is a two-number change.
- **unsure about:** the darker beasts. Exposure is lifted for the small size,
  but the Stone Warden, the Bounder and the Shifting Idol are grey creatures on
  a grey render and may still read as one shape at panel size. Also whether the
  gold sigil ring dominating several beast portraits is a feature (they all wear
  the same mark) or a sameness.

### the overworld map — NEEDS A PASS

Built 2026-08-25, all seventeen models from `tools/blender/hexes.py` in one
Blender run. Nine tiles (grass, forest, hill, stone, stone-hill, mountain, sand,
dirt, water), seven landmarks (cabin, market, tower, castle, wizard tower, mine,
village) and the loose tree.

`ui/tiles.gd` prefers `hexown/<name>.glb` over the Kenney tile of the same name,
the same rule and for the same reason as `ui/cast.gd`: it lets the map be
replaced one tile at a time instead of in one commit that either works or leaves
the map full of holes, and it keeps the Kenney set as a reference rather than
deleting it.

- previews: shoot them with `screenshot.gd -- state=3dmap` and `state=3dcampfire`
- intent: each node type readable at map size from its silhouette and one
  colour — the camp by its fire, the shop by its striped awning, the event by
  the only violet on the map and the only building that leans, the elite by
  being the only thing with a banner, treasure by a cut into a hillside.
- unsure about: **the green.** The palette's GREEN is strong, and a whole map of
  it next to orange tile sides is loud. It matches the Kenney tiles it replaced
  almost exactly, so it may just be the look this game already had — but it is
  the first thing to change if the map feels garish.
  Also unjudged: whether the tile-top scatter (tufts and pebbles) reads as
  texture or as litter when forty tiles are on screen at once.
- known: the campfire plot's cabin sits at the edge of frame and may be cropped.
  That framing predates these models; the landmark itself is fine on the map.

### the fourteen fight grounds — ALL NEED A PASS

Built 2026-08-25, from `tools/blender/env/<beast_id>.py` on the `env.py` helper.
Every beast now fights somewhere rather than on the same blank disc.

| beast | where it fights |
|---|---|
| stone_warden | a quarry somebody stopped working — everything has a straight edge |
| crag_pup | a scree hollow ringed with standing stones, the rock it is made of |
| bounder | a dry riverbed of rounded cobbles, flat so you can watch it land |
| bramble_hog | a thicket floor trodden into a hollow; the brambles at rest |
| root_lurker | forest floor growing the same roots it is hiding among |
| mire_snapper | shallow water over silt, with logs it is pretending to be |
| sky_snapper | bare cliff-top rock, wind-scoured, with its nest and bones |
| frost_sentinel | a frozen lake, cracks running out from where it stands |
| shifting_idol | a plaza somebody built and left; the only made ground |
| grove_bear | a clearing in old woodland it half disappears into |
| gale_serpent | a ridge whose rock winds in the same spiral the beast does |
| drowned_colossus | a tidal flat at low water, pools and kelp and ribs |
| sunken_warden | a drowned temple, the only fight with walls |
| riftling | ground come apart into drifting plates, lit from below |

**What to judge, in this order:**

- **Do they read as fourteen PLACES or as fourteen palettes?** The intent was
  that each beast fights somewhere that explains it — the Pup on its own
  hillside, the Snapper among logs it could be mistaken for. Judge that as a set;
  it is the thing that cannot be seen one at a time.
- **The Mire Snapper's water.** STEEL on CLAY silt is the weakest colour call in
  the batch and may not read as water at all from the fight camera.
- **The Grove Bear may work too well.** It was deliberately made to half
  disappear against its treeline, and there is a real chance that crosses from
  atmospheric into hard-to-read.
- **The Riftling's floating shards.** The only environment with things in mid
  air on purpose. If they read as a bug rather than as the beast's effect on the
  world, they should go.

**Unjudged:** whether the aprons are too visible at the edges of a wide shot,
and whether any ground is busy enough to fight the creature standing on it.

### What building the grounds taught

- **Anything tall belongs BEHIND the beast** (`env.BACK`). The camera sits about
  as far from a beast as its ground is wide, so a standing stone on the front rim
  is not scenery, it is a wall. The first build without that rule filled the
  screen with the inside of a boulder.
- **Size the world off the beast's HEIGHT, not its footprint.** The Mire Snapper
  is mostly jaw and tail; sizing its ground off how far it sprawls gave it a floor
  sixty units across and an apron the camera stood inside.
- **Scale by a constant, not by measured bounds.** An environment's props and
  apron overhang its floor on purpose, so its bounds say nothing about how big
  the floor is.
- **The island check is the wrong tool for a ground.** It exists to catch a limb
  in mid-air on a character; on a field of scattered rocks it reports "35 pieces
  do not touch" and that is how a real warning gets missed. `Env` turns it off
  and says why.

### lightbearer — NEEDS A PASS

The cloud added a fifth hunter (#47) with no model, so it was on screen as a
bunny. `Cast.PLACEHOLDER` did not even have an entry for it, which is why the
fallback was the default rather than something chosen.

- built: 2026-08-25 by hand, from tools/blender/lightbearer.py
- checks: 1312 tris (inside the 1400 hunter budget), 1 mesh, 1 material, all
  parts touching, assetcheck 4/4
- previews: design/art-previews/lightbearer_0.png (three-quarter), _1, _2
- intent: the class banks a resource and spends it in one go, so the read is a
  VESSEL — a lantern held high on a staff and a second light already caught in
  the chest. Two lights, one stored and one carried. Silhouette-wise it is the
  shape the cast did not have: a tall narrow triangle, and the only hunter whose
  highest point is not part of its body.
- unsure about: whether the hood reads as a hood or as a party hat (the dark
  face under it is doing all the work), and whether a robe with no legs reads as
  deliberate or as unfinished at fight distance.

### the eleven beasts that had no body — ALL NEED A PASS

Built 2026-08-25 by hand, from `tools/blender/<id>.py`, on the new `beast.py`
helper. Every beast in the game now has its own body: fourteen of fourteen, none
of them a Kenney farm animal.

All eleven pass the hold contract **in Godot**, not just in Blender:
`assetcheck.gd -- file=... beast=<id>` reports "every hold and the sigil have a
shelf at their Height" for all fourteen beasts including the three older ones.

| beast | holds / sigil | tris | the one-line idea |
|---|---|---|---|
| bounder | 2 / 4 | 1580 | almost all legs; a boulder slung between them |
| bramble_hog | 2 / 5 | 1796 | no creature under the brambles — the brambles are it |
| root_lurker | 2 / 5 | 2046 | a cage of roots you can see daylight through |
| mire_snapper | 3 / 6 | 2080 | the only horizontal beast; you stand IN its mouth |
| sky_snapper | 3 / 5 | 1580 | top-heavy: a hooked beak and folded plates on thin legs |
| frost_sentinel | 2,5 / 7 | 1112 | the only angular one; a lit core in an open gap |
| shifting_idol | 2,4 / 6 | 1280 | stacked blocks that never line up — the overhang IS the ledge |
| grove_bear | 3,5 / 7 | 2212 | weight; a hill that stood up, no head, a hollow instead |
| gale_serpent | 3,6 / 9 | 1922 | a spiral — the only shape that says climb AROUND me |
| drowned_colossus | 3,6,9 / 11 | 2506 | three terraces, kelp hanging off each so holds read from below |
| sunken_warden | 3,6,9,11 / 13 | 3054 | four tiers tightening toward the crown; one arm already broken off |

**What a reviewer should look at first**, because these are the calls I made that
could reasonably go the other way:

- **The Mire Snapper's hold is inside its mouth.** That is either the best or the
  worst idea in the roster and I cannot tell which without playing it.
- **The Sunken Warden is 1.2x the beast budget** (3054 of 2600), down from 4302.
  Four tiers of coral is what costs it. Same call as the Ent: accept, or say what
  goes.
- **The ledges are visibly ledges** — grey slabs stepping out of the body. Honest
  about where you stand, but on the Warden and the Colossus they read a little
  like scaffolding. Worth deciding whether that is a feature.
- **Silhouette spread.** The set was designed so no two share an outline: legs,
  bramble, cage, horizontal, top-heavy, angular, stacked, mass, spiral, terraced,
  tower. Judge that as a GROUP rather than one at a time — it is the only thing
  here that cannot be checked one model at a time.

**Not judged at all**: colour at fight distance, whether the amber eyes read as
eyes or as hot spots, and whether any of the eleven is simply boring.

### What building eleven at once taught

- **A sigil that passes every check can still hang in mid air.** Four of the
  first five had the mark floating off the body, because `mark()` placed it at
  80% of the height whether or not there was body there. It now checks for
  geometry near the anchor and says so, and the disc faces OUT rather than lying
  flat — every sigil in the game before today was a gold pancake balanced on the
  beast, inherited from the Stone Warden.
- **Ask the geometry where it is.** The Gale Serpent's ledges were placed by hand
  at the height the data wanted and came out hanging beside the coil, because a
  helix has moved on by the time it reaches that height. Computing the position
  from the coil itself fixed it and cannot drift again.
- **A bevel on a 12-sided drum triples its cost and changes nothing.** Most of
  the Sunken Warden's 4302 triangles were bevels and coral nobody would count.

### vine_weaver — NEEDS A PASS (redesigned as an ENT)

Not a rebuild, a **redesign**, at Nick's call on 2026-08-25: the Vine-Weaver is
now a walking tree rather than a flower on a stalk. The old silhouette was a
vertical line with a dot on top — the same outline as a lamp — and no amount of
rebuilding was going to fix that, because the shape itself was the problem.

- built: 2026-08-25 by hand, from tools/blender/vine_weaver.py
- checks: 1704 tris (**304 over the 1400 hunter budget — see below**), 1 mesh,
  1 material, all parts touching, assetcheck 4/4
- previews: design/art-previews/vine_weaver_0.png (three-quarter), _1, _2
- intent: the Ent read is carried by four things — a face cut INTO the wood with
  a jutting brow so the eyes sit in their own shadow, root feet with three toes
  each reaching the ground at different lengths, arms that FORK rather than
  bend, and a canopy wider than the trunk so the top of the silhouette is a mass
  and not a point. The vines stay, wound up the trunk with leaves on them, so
  the class name still means something.
- **the budget overage is a decision, not an oversight.** An Ent has a canopy,
  two forked arms, six root toes and two vines. Getting it under 1400 means
  losing one of those. Accept it, or say which one goes.
- unsure about: the vines took three passes and are still the weakest part —
  thin they read as moss, thick they read as green shelves, and this is the
  compromise. Also unjudged: whether the canopy is too big for the trunk, and
  whether the amber eyes read as eyes or as knots at fight distance.

### mountain_climbers — NEEDS A PASS
- built: 2026-08-25 by hand, from tools/blender/mountain_climbers.py
- checks: 1436 tris (36 over), 1 mesh, 1 material, all parts touching,
  assetcheck 4/4
- previews: design/art-previews/mountain_climbers_0.png (three-quarter), _1, _2
- intent: the rope is the class, so it is an actual rope — one limb wound twice
  round the chest on a helix whose radius follows the torso's own curve, so it
  lies ON him. Two horizontal tori read as a barrel. The pack is a bevelled box
  because a pack is a box, the beard is a taper, the boots are wedges, and the
  carabiner is a torus you can see through.
- unsure about: whether the beard now reads as a beard or as a bib, and whether
  the rope is legible against the blue at fight distance or just texture.

### goblin_mech — NEEDS A PASS
- built: 2026-08-25 by hand, from tools/blender/goblin_mech.py
- checks: 1484 tris (84 over the 1400 hunter budget), 1 mesh, 1 material, all
  parts touching, assetcheck 4/4
- previews: design/art-previews/goblin_mech_0.png (three-quarter), _1 (front),
  _2 (side)
- intent: the rebuild onto the wider vocabulary. The organic half stays soft —
  ball body, cone ears, ball head — and the rig is entirely bevelled boxes and
  cylinders, so the two halves of the silhouette disagree with each other and
  the asymmetry survives being 40px tall.
- unsure about: **the rig arm, and it is the weakest thing in the cast.** From
  the front it works. From three-quarters it still reads as three grey boxes
  stacked beside him rather than as an arm attached to him, and four passes of
  shrinking, swinging and angling it did not fix that. This is a proportion
  problem, which is the exact thing a reference settles and guessing does not —
  see design/art-references/README.md. Any picture of a mech arm, a piston claw
  or a power loader would end it.
  Also unjudged: whether the ears are now too large, and whether the exhaust
  pipe reads as a pipe or as an orange handle.

### frog — DONE (looked at 2026-08-26, 36/50)
- built: 2026-08-25 by hand, from tools/blender/frog.py
- checks: 1456 tris (56 over the 1400 hunter budget), 1 mesh, 1 material, all
  parts touching, assetcheck 4/4
- previews: design/art-previews/frog_0.png (three-quarter), _1 (front), _2 (side)
- intent: the head is now ONE broad wedge that narrows to a blunt snout, split
  across its full width by a grin with a jaw under it, rather than a ball with a
  stripe painted on. Legs bend — one limb() each, folded at the knee — and every
  foot has three splayed toes. Eyes bulge through the skull with a brow capping
  the back of each, so gold still faces the camera.
- unsure about: whether the head now overhangs the body too far (it was widened
  to fix a pinched look and may have gone past it), and whether the pupils read
  as pupils or as heavy black eyebrows at fight distance. The muzzle went
  through three shapes — brick, then shelf, then wedge — and only the last one
  is defensible from the side.

### What the first two rebuilds taught

Worth keeping, because both cost several passes:

- **A box half-extent is not a sphere radius.** Converting a model from
  ellipsoids to boxes one-for-one inflates every part by its corners. About 0.72
  of the old radius matches the old volume.
- **A bevel changes the silhouette width.** The Frog's jaw and grin were given
  the head's nominal width and came out sticking past it on both sides, because
  the head carried a heavy bevel that pulled its outline in and they did not.
