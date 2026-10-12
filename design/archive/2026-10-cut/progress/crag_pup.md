# crag_pup — refinement log

**Cannot score this pass. Full writeup in `design/progress/gale_serpent.md`
(same finding, discovered together, 2026-09-08) — this file records only what
is specific to `crag_pup`.**

`silmetrics.py` flagged `crag_pup` at solidity 0.92, distinctness 0.13,
"TWIN OF gale_serpent", reading `design/renders/crag_pup_pass2_sil.png` (the
newest of two committed passes). Opened it and the pass-2 `_34/_side/_top`
views: a ring of leaning slate shards around a rust-clay dished floor — an
arena, not a pup. `design/progress/crag_pup_ground.md` confirms it: it
documents `design/renders/crag_pup_pass1_*.png`, "captured with `look.sh env
crag_pup 1`", describing the identical ring shape. A second pass (`pass2`)
exists on disk with no matching entry in `crag_pup_ground.md` at all — either
an env re-capture nobody logged, or a cast capture that the ground's own
later `look.sh env crag_pup 2` silently overwrote. No way to tell which from
the files alone, which is exactly the failure mode: same `look.sh`/`look.cmd`
output-naming collision described in `gale_serpent.md`.

Needs a fresh `look.sh crag_pup 1` (cast) capture — ideally after the naming
collision itself is fixed — before this beast can be scored for real. Not
attempted here: a duty-1 diagnosis pass doesn't build renders, and fixing
shared tooling is duty-2-shaped, not this pass's job.
