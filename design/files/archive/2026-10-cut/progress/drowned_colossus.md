# drowned_colossus — refinement log

**Cannot score this pass. Full writeup in `design/progress/gale_serpent.md`
(2026-09-08 update) — this file records only what is specific to
`drowned_colossus`.**

Checked as one of the nine remaining original-cast beasts with no bare-name
progress file. `design/renders/drowned_colossus_pass1_34.png` and `_sil.png`
show a fight-arena ring, not the colossus. `design/progress/
drowned_colossus_ground.md` confirms these are the exact files it scored as
the ground, "captured with `look.sh env drowned_colossus 1`". Same
`look.sh`/`look.cmd` output-naming collision as `gale_serpent.md` describes.

Worth flagging for whoever fixes the naming and re-captures this one:
backlog #88 already names this beast's sigil as 88% occluded, the worst of
the five it lists — that finding came from `assetcheck.gd`'s own in-Godot
occlusion math against the real `.glb`, not from this collided render, so it
stands independently, but a real body capture would let someone actually
look at what #88 only measured.

Needs a fresh `look.sh drowned_colossus 1` (cast) capture — ideally after
the naming collision itself is fixed — before this beast can be scored for
real. Not attempted here: a duty-1 diagnosis pass doesn't build renders, and
fixing shared tooling is duty-2-shaped, not this pass's job.
