# gale_serpent — refinement log

**Cannot score this pass — see below. No diagnosis, no fix proposed.**

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
