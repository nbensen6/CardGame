# Foothold rock detail — artist, 2026-09-23 16:24 EDT

## What this is

`artist.md` item 1 has named the Cinder Jackal's climb footholds ("plain
basalt") as a known open issue since the beast's own AI rebuild. The
floating stones (`combat_3d.gd`'s `_build_float_stones()`, shared by every
beast, not jackal-specific) are a procedural `SphereMesh` with a single flat
`albedo_color` — no surface detail at all, unlike the jackal's own painted
Meshy texture or the arena's Meshy-built crater wall.

## Why texture, not geometry, this run

Both Meshy (8/8 daily tasks already spent, per this run's own read of
`design/agents/status/artist.md`) and Blender (`download.blender.org`
returned a hard 403 through the proxy this session — confirmed twice, not a
one-off timeout) were unavailable this run. A generated 2D texture needs
neither: pure Python (numpy/PIL), applied to the stone's existing geometry
and UVs.

## Build

`tools/blender` wasn't reachable, so this is a one-off Python script (not
committed — the output PNG is the artifact, same convention the ear-glare
fix's one-off `pygltflib` script used):

- Toroidal Voronoi (9 wrapped copies of ~90 random seed points, so the
  pattern has no seam when it wraps around the sphere's own UV) —
  matches the low-poly **faceted** rock look already established by every
  other beast/ground asset in this fight, not an unrelated style.
- Per-cell random brightness (0.82–1.05) for facet-to-facet variation.
- A distance-based darkening near each cell edge (a "crack" between
  facets), clamped so the seam stays narrow rather than muddying the whole
  cell.
- Saved grayscale, 512×512, replicated to RGB:
  `game/assets/3d/rock_detail.png`.

## Wired in

`combat_3d.gd`'s `_build_float_stones()`: added `const ROCK_DETAIL` and set
`mat.albedo_texture = ROCK_DETAIL` alongside the existing per-stone
`albedo_color` tint (kept as-is — the texture multiplies it, so the
established BROWN palette and the "lighter than the beast's own CHARCOAL
legs" contrast rule are untouched, only the flat-colour surface gets real
variation). One texture shared by every stone; the sphere's own per-stone
random rotation (already existing code, a few lines down) puts a different
facet forward each time, so neighbouring stones still don't read as clones.

## Verified

- `ALL TESTS PASSED` (`run_tests.gd`) — no logic touched, material only.
- Before/after, same camera, same seed, `state=3dgrip beast=cinder_jackal`
  (a real reachable state: a hunter mid-climb, one foothold below the
  weak point): the stone under the Frog goes from one flat orange blob to
  a visibly faceted, cracked rock surface, still reading as the same warm
  BROWN as before. Two stones visible in the full frame, both improved,
  nothing else in the shot changed.

![[../agents/frames/artist/2026-09-23-foothold-rock-detail-before-after-crop.png]]

Full frames:
![[../agents/frames/artist/2026-09-23-foothold-rock-detail-after-full.png]]

- 80-step `mode=play` playtest kicked off to confirm no regression on the
  shared foothold system across a full fight (footholds are touched by
  climb/positioning code elsewhere in the same file) — this is a pure
  `MeshInstance3D.material_override` change, no position/foothold-index
  logic touched, so a regression here would be a surprise; result appended
  to this note and the status log the moment it lands, not assumed.
  **Result: clean.** `PLAYTEST OK: 0 failing check(s) {  }`, full 80 steps
  (exit code 0) — Meld, Catapult+Burn Coal, Leapfrog, Brace, Take Aim,
  Scramble, several real climbs/hops with position-continuity checks all
  passing, a real fall (foot 10→4, hp 20→14 at step 71) landing cleanly.
  Confirms the prediction: nothing in this change touches position or
  foothold-index logic, only the stone's own material.

## Not done

No normal/roughness map (the faceted look above already reads as rock
without one), and no geometry change — the low `radial_segments=7,
rings=3` sphere is untouched. If a future pass wants actual chunky-rock
silhouette (not just surface colour), that needs real geometry and is
Blender work, blocked this run by the network wall above.
