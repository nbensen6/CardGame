# Art waiting for a second pass

Anything the cloud routine builds in Blender lands here, because a run has no
display and cannot judge what it made. It can prove a model meets the contract —
holds where the data says, sigil at its Height, budget, one mesh, one material —
and it renders three angles so a human can look. It cannot tell you the thing is
a murky blob, or that the base reads as a spring, or that the sigil is hidden
behind the head. Every one of those got past every automated check we had.

So: the routine BUILDS and PROVES. We LOOK.

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

### frog — NEEDS A PASS
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
