# gale_serpent — refinement log

**Scored for the first time in Pass 1 below (2026-09-08), after the naming
collision that blocked every earlier attempt was fixed.** The section
immediately following this line is the original, now-historical account of
that block — kept for the record, not current status.

## What happened

`#86` duty 1, 2026-09-08. `tools/blender/silmetrics.py` (added 2026-09-07,
`4578473`) flagged `gale_serpent` as the single worst asset in the cast —
solidity 0.93, distinctness 0.09, "TWIN OF stone_warden" — reading its newest
committed silhouette as `design/renders/gale_serpent_pass1_sil.png`. Went to
diagnose it as this rewrite of duty 1 asks (beasts first) and opened that PNG
plus `gale_serpent_pass1_34.png` before writing anything.

**Both show a ring of grey standing stones around a bare centre — a fight
arena, not a serpent.** `design/progress/gale_serpent_ground.md` confirms it
independently: it documents these exact same files, `design/renders/
gale_serpent_pass1_*.png`, as "captured with `look.sh env gale_serpent 1`" —
the GROUND, not the beast in `game/assets/3d/cast/gale_serpent.glb`.

**Root cause.** `tools/blender/look.sh` (and `look.cmd`) writes every capture
to `design/renders/<name>_pass<N>_*.png` using only the bare asset name — the
`env` in `look.sh env gale_serpent 1` picks the source `.glb` (`game/assets/
3d/env/` vs `.../cast/`) but never reaches the output filename. A beast and
its same-named ground write to the **identical path** at the same pass
number, and whichever was captured most recently silently wins with no
marker of which kind it is. `silmetrics.py` has no way to tell either — it
just reads `<name>_pass<N>_sil.png` for whatever `<name>` is on disk.

This is not gale_serpent-specific. Every real beast that also has a ground
built under item #83 collides the same way — checked with a plain
`ls game/assets/3d/cast/*.glb` vs `game/assets/3d/env/`: 28 of the cast share
a name with an env asset (`gale_serpent`, `stone_warden`, `crag_pup`,
`bounder` among them). The only cast members immune are the five hunters and
the unused raw Kenney animal packs, which have no env counterpart to collide
with.

**Confirmed the same failure on the other three names silmetrics flagged
alongside this one** — see `stone_warden.md`, `crag_pup.md`, `bounder.md`,
each written this same run. All four show the identical ring-arena shape,
not a body, and all four cross-check against an existing `<name>_ground.md`
that names the same files as its own ground capture.

## Why this run doesn't fix it

Fixing `look.sh`/`look.cmd`'s output naming (e.g. suffixing `_env` when
`kind=env`) is shared tooling both lanes call, not this beast's model, and is
shaped like a duty-2 "two copies of one truth" find rather than a duty-1
asset diagnosis — landing it here would be two duties in one run. Left for
the next duty-2 turn or the fixer to pick up. Practical effect until then:
**do not trust `design/renders/<name>_pass*.png` for any of the 28 collided
names without first checking the matching `<name>_ground.md` for which
`look.sh` invocation actually produced the newest pass** — a bare-name
progress file with no cross-check could easily score a ground as a beast the
same way this run almost did.

## What's needed before this beast can be scored

A fresh `look.sh gale_serpent 1` (cast, not `env`) capture, taken and
committed in a run that also confirms no later `look.sh env gale_serpent`
call will land on the same pass number and overwrite it — or the naming fix
above, which removes the risk entirely. Until then this file stays a
placeholder rather than a real diagnosis; `silmetrics`'s "worst in the cast"
verdict for this name should be read as "worst *ground*", which is already
covered by `gale_serpent_ground.md`'s own pass-1 score (not re-litigated
here).

## Update — #86 duty 1, 2026-09-08: this is every original-cast beast, not four

Went looking for the next beast to diagnose and checked the nine remaining
names that have never had a bare-name progress file at all — `bramble_hog`,
`root_lurker`, `mire_snapper`, `sky_snapper`, `frost_sentinel`,
`shifting_idol`, `grove_bear`, `drowned_colossus`, `sunken_warden` — plus
`riftling`, which also has a ground but no beast file. Same check as this
file's own original one: open `<name>_pass1_34.png` and cross-read
`<name>_ground.md`. **All ten are the identical failure.** Every one of
`<name>_ground.md` names `design/renders/<name>_pass1_*.png` as its own
ground capture via `look.sh env <name> 1`, and every one of those PNGs shows
the same ring-of-standing-stones-or-slabs arena this file already described,
not a body. `sunken_warden` even has a `_pass2` — also the ring, near-pixel-
identical to its own `_pass1` (mean channel delta 0.4/255 on the silhouette),
so whatever produced pass 2 didn't change anything either.

Cross-referenced in each name's own new file (`bramble_hog.md`,
`root_lurker.md`, `mire_snapper.md`, `sky_snapper.md`, `frost_sentinel.md`,
`shifting_idol.md`, `grove_bear.md`, `drowned_colossus.md`,
`sunken_warden.md`, `riftling.md`) rather than repeated here.

**That closes out the count.** The 14 original-cast beasts that predate
item #55 (the eleven "had no body until 2026-08-25" plus the three older
`stone_warden`/`crag_pup`/`riftling`) are exactly the 14 names with a
same-named ground built under #83. All 14 are now confirmed contaminated —
4 found this same day earlier in this file, 10 more just now. **Zero of the
original 14 beasts currently have a scoreable body render on disk.** The 14
beasts added later by #55 (`yoke_ox` through `gloom_moth`) have no ground of
their own and are not at risk — that's the entire explanation for why every
bare-name progress file that exists and holds a real multi-pass score belongs
to one of those 14, never one of the original cast.

This raises the floor on why `look.sh`/`look.cmd`'s naming fix matters: it
isn't blocking one flagged beast, it's blocking a first real look at half the
cast. Still not fixed here, for the same reason as above — shared tooling,
duty-2 shaped, not a single beast's diagnosis.

---

## Pass 1 — the first real score, #86 duty 1, 2026-09-08

The block above is now history, not a live blocker. `b2d5d63` fixed
`look.sh`/`look.cmd`'s output naming (grounds now write `<name>_env_pass<N>_*`)
and `2bb3958` bulk re-captured the whole cast under it — `gale_serpent` landed
at `design/renders/gale_serpent_pass2_*.png` (`_34`, `_front`, `_sil`; no
`_side`/`_top`/`_form`/`_wire` were taken for this asset in that sweep,
scoring against what exists rather than blocking on renders nobody has, same
as `husk_beetle.md` pass 3). Confirmed this is a real cast capture, not
another collision: `gale_serpent_env_pass1_sil.png` exists alongside it as a
separate file for the first time, and `gale_serpent_pass2_34.png` actually
shows a serpent — head, hood, coiled body — not a ring of stones.

**What is actually there.** A tall, tapering spiral: a horned, hooded head at
the top with two amber eyes and a gold sigil ring at the throat, the body one
continuous coiling limb narrowing from a wide base to the neck, a paler belly
band on the inside of the coil, small periwinkle fins along the outer spine,
and two flat silver ledges jutting off the coil at two heights.

| Pass | Sil | Prop | Hygiene | Colour | Style | Total |
|---|---|---|---|---|---|---|
| 1 | 6 | 7 | 5 | 7 | 7 | **32** |

- **Silhouette (6):** `gale_serpent_pass2_sil.png` reads as an unmistakable
  coiled S-shape at 64px — nothing else in the cast turns, per the script's
  own docstring, and this is the one place that claim actually pays off.
  Held below the 8-9 anchor band because the outline isn't a clean taper: a
  handful of small hard points break it along the upper-right of the coil,
  where geometry sits proud of the tube surface (see Hygiene below for the
  measured cause of at least two of them). Anchor band 6-7: "the forms have
  been worked... but a specific part still fails" — the read is strong, the
  failing part is real.
- **Proportion (7):** the coil narrows convincingly from a wide floor base to
  a slim throat, matching the docstring ("no body under the coil, the coil is
  the body"), and the hooded head sits at a believable scale against the
  taper beneath it. Not higher because the two ledges (see Hygiene) sit
  noticeably wider than the coil they're mounted on, which reads as added
  mass the taper doesn't actually have.
- **Build hygiene (5):** `b.shelf(3, on_coil(b.z_for(3)), (0.62, 0.52), ...)`
  and `b.shelf(6, on_coil(b.z_for(6)), (0.54, 0.46), ...)` are sized without
  reference to the coil tube's own local radius at those points. Computed it
  directly from `beast.py`'s `z_for` and the script's own `radii` formula:
  `z_for(3)` = 1.930 model-z, which lands at `t=0.4951` along the coil
  parametrisation, where the tube radius is `0.52 - 0.20*0.4951 = 0.421`.
  `z_for(6)` = 3.015, `t=0.8508`, tube radius `0.52 - 0.20*0.8508 = 0.350`.
  Both shelves are centred ON the coil centreline (`on_coil` returns the
  centreline x/y) but sized bigger than the tube around it: shelf 3's
  half-width `0.62` exceeds the `0.421` tube radius by `0.199` (47% over),
  half-depth `0.52` exceeds it by `0.099`; shelf 6's half-width `0.54`
  exceeds `0.350` by `0.190` (54% over), half-depth `0.46` exceeds it by
  `0.110`. That is a box overhanging the tube it sits on by roughly a fifth
  to half its own radius on every side — the same "part spaced away from the
  body" fault named on Yoke Ox, Silk Widow and Husk Beetle's earlier passes,
  here on a flat slab instead of a rod. `gale_serpent_pass2_34.png` and
  `_front.png` show it directly: two grey rectangular plates projecting past
  the coil's edge rather than sitting flush as a worn step in it.
- **Colour & read (7):** sky-blue coil, pale ice belly, indigo/blue hood,
  gold sigil ring and silver ledges all separate cleanly by value in
  `_34.png`; nothing dark-on-dark.
- **Style consistency (7):** kenney-primitive vocabulary (tapers, wedges,
  balls), sits fine beside the rest of the cast.

## Diagnosis — two lowest

Both trace to the same measured root cause (the shelf boxes' overhang past
the tube surface), same "one visual unit" precedent as `husk_beetle.md` and
`bog_leech.md`:

1. **Build hygiene (5).** Concrete fix: shrink both shelf sizes to sit inside
   (with a small margin, not flush-exact) the coil tube's local radius rather
   than the coil's spiral radius. Change
   `b.shelf(3, on_coil(b.z_for(3)), (0.62, 0.52), SILVER, thickness=0.12)`
   to `(0.46, 0.42)`, and
   `b.shelf(6, on_coil(b.z_for(6)), (0.54, 0.46), SILVER, thickness=0.12)`
   to `(0.38, 0.36)` — both now sit just outside their local tube radius
   (0.421 and 0.350) by 0.03-0.04 instead of 0.10-0.20, reading as a lip worn
   into the coil rather than a plank bolted onto it.
2. **Silhouette (6).** Same edit — the shelves are the largest, most cleanly
   measured deviation from the tube surface, so shrinking them is the honest
   first attempt at the silhouette notches too, rather than inventing a
   second, unmeasured fix.

Not applying either — this is a diagnosis pass; `tools/blender/
gale_serpent.py` is the fixer's file (`tools/fixer/BRIEF.md`).

**Flag for whoever applies this:** `shelf()`'s `size[1]` (half-depth) also
sets the climb anchor's lip offset (`at[1] - size[1] * lip`), so shrinking
`size` moves the exact spot a hunter stands, not just the visual box. That's
expected — re-run `run_tests.gd` and check the build log's `HOLD` lines after
rebuild, same as every other shelf/hold edit in this project, rather than
assuming the contract survives untouched.

## Unsure about

Whether the silhouette notches are entirely explained by the two shelves or
whether the periwinkle spine fins (`b.wedge` calls, `for i in range(9, N-4,
5)`) also contribute — there are more fin insertions (7) than shelves (2)
spread across more of the coil's height, and their own overhang past the
tube wasn't separately measured this pass; the shelf math was clean and
computable, the fin geometry (rotated wedges via `aim()`) is not, without
rendering the change. If shrinking the shelves doesn't clear the remaining
notches, look at the fins next.
