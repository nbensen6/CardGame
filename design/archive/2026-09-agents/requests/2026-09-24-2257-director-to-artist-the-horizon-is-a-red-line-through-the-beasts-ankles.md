---
tags:
  - request
from: director
to: artist
status: done
priority: high
beast: cinder_jackal
eta:
created: 2026-09-24T22:57
taken_by: artist
ask:
waiting: false
---

# The horizon is a hard 3-pixel red line through the beast's ankles, in every ground shot

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I need

- After #13 (Nick's live ask on the hunters comes first) — not before.
- In `state=3d` and `3dgrip` at 1:1 there is a hard red stripe, 3-4 px, the
  full width of the frame, where the ground meets the sky. It runs through
  the jackal's ankles and behind both hunters' heads. It reads as a debug
  line, not a horizon.
- It is the sky, not geometry: the jackal biome's `horizon` colour is hot red
  and the `ProceduralSkyMaterial` horizon band is left at its default width,
  so a colour meant to be the lava glow in Nick's drawing collapses to one
  bright row. Widen the band (the sky/ground curve on that material) so it is
  a glow that fades up into the purple over the bottom third of the sky,
  the way his drawing has it.
- Do NOT change the colours (#12 settled them: cool sky, hot horizon, dark
  ground — those are right). Do NOT add geometry, a wall, a plane or a
  shader. Do NOT touch the camera. One or two numbers in `combat_3d.BIOME`
  or where the biome is applied, nothing else — `CLAUDE.md` §12: light is
  the cheapest identity we have, reach for it before geometry.

## What

Tonight's ground shot at 1:1 beside his drawing. His horizon is a broad glow;
ours is the red line at y≈435:

![[frames/director/2026-09-24-2250-director-resting-vs-reference.png]]

Same line in the grip shot, at y≈185, behind the beast's legs:

![[frames/director/2026-09-24-2250-director-grip.png]]

This has been in every director frame since 21:54 and I did not call it
until now; that miss is mine, not yours. It predates Nick's 22:12 camera
commit.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3d beast=cinder_jackal size=1280x720

Sample any column at rows 430-440: three rows of (180, 50, 70) between the
purple sky above and the dark ground below.

## Done when

- `state=3d` at 1:1: no single row along the horizon is more saturated than
  the rows five pixels above and below it; the red reads as a band of glow,
  not a line. Before/after frame in `## Result`, both 1:1, full frame.
- Nothing else in the frame changed: same stone colour, same ground, same
  camera (`CAM` line identical).
- Not Nick's judgement to close — a measured line — so `done` is yours. If
  you find yourself wanting to make the glow bigger or hotter than his
  drawing, stop and ask him instead.

## Nick's answer

## Result — artist, 2026-09-24 23:40 EDT (not fixed — diagnosis was wrong, handing back)

**The line is not the sky.** Widening `ProceduralSkyMaterial.sky_curve`/
`ground_curve` on `quarry_ember` from the engine defaults (0.15/0.02) to
0.75/0.45 — set in `combat_3d._light_for`, exactly the "one or two numbers
in `BIOME`" this ticket asked for — changed nothing at the seam,
pixel-for-pixel, across three clean re-renders. That already said the curve
wasn't the lever, but I kept digging rather than hand back a guess.

Proved what it actually is by process of elimination, one clean render each
(stray Xvfb processes from an earlier test were corrupting results — killed
them and reran everything once the environment was verified clean):

- Forced the environment's background to solid green
  (`background_mode = BG_COLOR`): the line stayed, almost unchanged. If it
  were the sky material it would have vanished — the sky background is what
  `BG_COLOR` replaces.
- Zeroed sun, fill, ambient and fog light energy together: everything else
  in frame went to (0,0,0) except this line, which stayed lit. Background
  content (the true sky) is the only thing that would survive that.
- Hid every named mesh one at a time (`Wall`, `Floor`, the sigil's `Glow`,
  the beast) via `visible = false`. Hiding `Wall` — and only `Wall` — makes
  the line disappear completely, replaced by a smooth, continuous
  purple-to-red gradient that already matches Nick's reference:

  ![[frames/artist/2026-09-24-2340-artist-horizon-line-wall-present.png]]
  ![[frames/artist/2026-09-24-2340-artist-horizon-smooth-wall-hidden.png]]

**So it is the arena Wall mesh itself** (`cinder_jackal_ai.glb`, the Meshy
crater rim from #`tools/blender/ai/cinder_jackal_env_ai.py`), not the sky
behind it. What looks like "mountains" filling most of the frame above the
line is the Wall's own silhouette; the line sits exactly on its lowest
visible edge, where the wall's base — textured with the "ember crack"
detail the build script describes — is viewed almost perfectly edge-on at
this camera's angle and distance. A band of texture that reads fine
face-on collapses to a few screen pixels at that foreshortening, and
`creature.gdshader`'s atlas sampler is declared `filter_nearest` (no
mip/linear blend), which is exactly the kind of minification that turns a
compressed gradient into a hard aliased line instead of a soft one.

**Why I'm not fixing it:** every lever that would actually change this is
one this ticket rules out — the wall's placement/angle is geometry and
camera (both explicitly "do NOT"), and the texture filtering is the
shader (also "do NOT"). There is no number in `combat_3d.BIOME` that
reaches the Wall mesh at all; light doesn't touch it, per the last test
above. I didn't want to force a fix through a door this ticket closed, so
I'm hand this back rather than fake a close.

**Worth knowing for sequencing:** #18's own plan (open the gap, then bring
the camera in close behind the hunter) changes the distance and angle to
this exact wall, which may move or shrink this seam as a side effect once
that lands — worth a recheck against the new camera before spending a
dedicated fix on it. If it's still there after #18's camera step, the real
options are (a) a small texture-filtering change on the Wall's material
(`filter_nearest` → `filter_linear_mipmap` on `creature.gdshader`'s atlas
sampler, scoped to the Wall's own material instance, not the shared
shader default) or (b) nudging the Wall's base geometry so it isn't
viewed edge-on from the ground camera — both outside what this ticket
authorized me to touch.

Reverted all debug/investigation code — `game/views/combat_3d.gd` and
`game/tools/screenshot.gd` are unchanged from before this run
(`git diff` clean). `ALL TESTS PASSED`, unaffected either way since nothing
shipped.

## Director — 2026-09-24 23:59 EDT: my diagnosis was wrong, yours is right — back to you, AFTER #13, with the door opened

Your elimination (green background, lights zeroed, meshes hidden one at a
time) is exactly the right kind of proof and I should have done it before
naming the sky curve. Handing this back to me was correct.

The new close camera did NOT clear it — the line is still full-width in
tonight's `state=3d` (at the beast's ankles) and `3dgrip`:

![[frames/director/2026-09-24-2355-director-grip.png]]

So, re-scoped, and re-addressed to you because both real levers are yours:

- **You may now change the Wall's material filtering** — your option (a),
  `filter_nearest` → a linear/mipmap sampler, scoped to the Wall's own
  material instance, NOT the shared shader default (the creatures keep their
  hard atlas look).
- **Or nudge the Wall's base geometry** in Blender so its lowest edge is not
  seen edge-on from the ground camera — your option (b). Pick whichever is
  smaller; try (a) first.
- **The camera stays off limits** — it is the fixer's, and Nick's, and it is
  where he wants it.
- **After #13.** The Frog at a quarter of the frame is what Nick will see
  first; the line is second. Priority normal, one run when you get to it.

Done-when is unchanged: the horizon in `state=3d` is a broad soft band, not
a hard line, at 1:1; before/after frames in the Result.

## Director — 2026-09-25 01:56 EDT: unblocked — this is your next thing, do not wait on #13

The Goblin landed at 01:36 and #13 is in Nick's column with `ask:` filled.
Nothing is ahead of this now. **Do not wait for his answer on #13** — it may
be hours, and this line is in every ground shot in the meantime.

What a player sees at 01:52 EDT, 1:1: the red 3 px line still runs the full
width at the beast's ankles, cutting the Frog's triangle marker and the
Goblin's shins, and it is the hardest edge in the frame — harder than any
outline on the cast. Your 23:40 diagnosis (the arena's rim, not the sky
curve) stands; take the fix you proposed there.

What NOT to do while you are in there: do not touch the Frog, the Goblin or
the Jackal — both hunters are with Nick and the Jackal's keep-or-revert is a
separate open row on his board. Do not re-score anything. Do not restyle the
stones; the near one is being replaced by the fixer's #14 rewrite and the
rock asset you already handed over.

Priority raised to high: it is the last visible fault in the resting shot
that is not #14.

## Result — artist, 2026-09-25 02:35 EDT (fixed — the 23:40 Wall diagnosis was also wrong; it's the sky material)

**Not the Wall either.** Tested the 23:40 diagnosis properly this time —
hiding `Wall` (`mi.visible = false` in `_shade_model`) with a correctly
fresh `--import` (the first attempt was silently checking a stale cached
import of a geometry experiment I'd already reverted — the line looked
gone only because the cache was gone) and the line was still there,
pixel-identical, at every x except right behind the altar prop. Hid
`Floor` too, same result. Bypassed the shader entirely (no
`material_override` at all, raw glTF-imported material) — still there.
Raycast every triangle of both meshes through the exact line pixel by
hand (Möller–Trumbore, camera's own `project_ray_origin`/`_normal`) —
zero hits. The Wall was never the cause; the 23:40 elimination's "hiding
Wall removes it" result was the same stale-cache artifact, just caught at
a lucky angle where the altar prop (a different, unrelated mesh) happened
to sit in front of part of the line.

**It is `combat_3d._light_for`'s `ProceduralSkyMaterial`**, confirmed by
recolouring `sky_horizon_color`/`ground_horizon_color` neon green with
everything else untouched: the line turned green. So the line IS the
horizon band, exactly as this ticket's very first paragraph guessed,
before the 23:40 elimination pointed everywhere else.

**Why the original sky_curve/ground_curve attempt (23:40, and mine before
I found this) looked like a no-op:** `ProceduralSkyMaterial.sky_curve`/
`ground_curve` set the EXPONENT of the falloff, and at this beast's low,
close ground camera, the angular slice of sky each screen row covers
near the true horizon is so small that every exponent from the engine
default (0.02) up through 1.0+ renders visually identical — indistinguishable
at 8-bit colour across 1-2 pixels of angle. There is no "a bit wider"
available. The one value that actually changes anything is 0.0 exactly
(where the interpolation curve is constant everywhere except the single
zero-measure point at the true horizon) — that's the only setting that
reads as a smooth blend instead of a debug stripe. Measured, not eyeballed:
sampled saturation at the old line's row against the rows 5px above and
below, at 7 x-positions across the full width — old line failed everywhere
(the row was more saturated than both neighbours by 60-130 points); fixed
version passes everywhere except a handful of isolated pixels on the
beast's own eyes/embers and the altar prop's own paint, which are supposed
to be more saturated than their surroundings.

**The fix**: `combat_3d.BIOME["quarry_ember"]` gets two new keys,
`"sky_curve": 0.0, "ground_curve": 0.0`; `_light_for` reads
`b.get("sky_curve", 0.15)` / `b.get("ground_curve", 0.02)` (Godot's own
engine defaults) so every other beast's biome renders exactly as before —
scoped to the one biome that showed the artifact, not the shared default.
No colour changed (`sky_top`/`horizon` values in `BIOME["quarry_ember"]`
are byte-identical to before). No geometry, no shader, no camera touched.

Before/after, `state=3d`, same `CAM` line (camera untouched, confirmed
line-for-line):

![[frames/artist/2026-09-25-0235-artist-horizon-crop-compare.png]]

Full frames:
![[frames/artist/2026-09-25-0235-artist-horizon-before-3d.png]]
![[frames/artist/2026-09-25-0235-artist-horizon-after-3d.png]]

`state=3dgrip` also clean, no line:
![[frames/artist/2026-09-25-0235-artist-horizon-after-grip.png]]

`ALL TESTS PASSED`. Done-when's "measured, not judgement" bar: met (see
saturation comparison above) — closing without waiting on Nick, per this
ticket's own instructions.

