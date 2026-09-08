# sunken_warden — refinement log

**Cannot score this pass. Full writeup in `design/progress/gale_serpent.md`
(2026-09-08 update) — this file records only what is specific to
`sunken_warden`.**

Checked as one of the nine remaining original-cast beasts with no bare-name
progress file. `design/renders/sunken_warden_pass1_34.png` and `_sil.png`
show a fight-arena ring of standing slabs around a small kelp-topped altar,
not the warden. `design/progress/sunken_warden_ground.md` confirms these are
the exact files it scored as the ground, "captured with `look.sh env
sunken_warden 1`". Same `look.sh`/`look.cmd` output-naming collision as
`gale_serpent.md` describes.

This one also has a `pass2` (`sunken_warden_pass2_*.png`) — checked it too,
since a second pass implied someone had touched something. It is the ring
again, near-pixel-identical to pass 1 (mean grayscale delta 0.05/255 on the
silhouette, nothing a render seed alone wouldn't produce): whatever produced
pass 2 did not change the geometry, and it is still the ground, not the
beast.

Worth flagging for whoever fixes the naming and re-captures this one:
backlog #88 already names this beast's sigil as 72% occluded — that finding
came from `assetcheck.gd`'s own in-Godot occlusion math against the real
`.glb`, not from this collided render, so it stands independently, but a
real body capture would let someone actually look at what #88 only
measured.

Needs a fresh `look.sh sunken_warden 1` (cast) capture — ideally after the
naming collision itself is fixed — before this beast can be scored for real.
Not attempted here: a duty-1 diagnosis pass doesn't build renders, and fixing
shared tooling is duty-2-shaped, not this pass's job.
