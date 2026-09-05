# Bug hunt log — fixer lane

Findings from looking at the actual game (`tools/screenshot.gd`), not from the
score sheets. Per `tools/fixer/BRIEF.md`: fix it only if it's inside
`tools/blender/**` / `game/assets/3d/**`; anything in `game/**` GDScript gets
written up here for the session, not touched.

## 2026-09-05 — ally hunter off-screen at the start of every fight

**Command:**
```
%GODOT% --path game --script res://tools/screenshot.gd -- ^
    out=C:\shot.png state=3d slot=0 beast=thrasher
```
(reproduces with `beast=` omitted too — not beast-specific; also reproduces
at `mobile size=2340x1080`, and worse there since the viewport is narrower)

**What the harness printed:**
```
HUNTER0 home=(-4.162253, 0.000000, 14.620000) drawn=(-4.162253, 0.036307, 14.620000) OK
HUNTER1 home=(4.162253, 0.000000, 14.620000) drawn=(4.162253, 0.021686, 14.620000) OK
VIS n/a sigil: hunter is 16.2 below it — out of frame by design
VIS OK hunter0: (640, 396)
VIS FAIL hunter1: (1559, 396)
```
`HUNTER1` is drawn exactly where the game believes it is (`OK`, gap < 0.05) —
this is not a repeat of the old `_place_hunters` "not placed" bug. The
position itself is correct; the opening CAMERA is wrong. `slot=0`'s
combat-start framing sits at `dist=7.30`, tight enough on the active hunter
that the ally — placed a symmetric 4.16 units to the other side — projects to
x=1559 on a 1280-wide screen, off the right edge entirely.

**What I saw in the PNG:** confirmed by eye, not just the number — opened
`state=3d slot=0 beast=thrasher` and `state=3d slot=0` (default beast) side by
side. Both show The Frog alone on the platform; The Goblin Engineer (the
player's actual co-op partner) is not visible anywhere in frame. HP panel top
left correctly shows both are alive and present (Frog 42/42, Goblin Engineer
42/42) — the game has both hunters, the render just doesn't show one of them.

**Why it matters:** this is the very first frame of every fight, for every
beast, on desktop and more so on the mobile aspect. A co-op game where you
cannot see your partner when a fight opens is a first-impression bug, not an
edge case.

**Where to look:** the combat-start camera framing in the 3D combat view
(`combat_3d.gd` or wherever `slot=0`'s opening `dist`/pivot gets set — outside
`design/progress/**` diagnosis and outside this lane's file ownership, since
the beast/hunter models themselves are placed correctly). This is `game/**`
GDScript, so it's written up here rather than touched.

## 2026-09-05 — ally hunter off top edge during the grip minigame

**Command:**
```
%GODOT% --path game --script res://tools/screenshot.gd -- ^
    out=C:\shot.png state=3dgrip slot=0 beast=thrasher
```

**What the harness printed:**
```
HUNTER0 home=(5.554712, 6.086790, 7.906831) drawn=(5.555187, 6.123032, 7.906831) OK
HUNTER1 home=(4.571362, 13.367243, 3.119427) drawn=(4.571362, 13.389025, 3.119427) OK
VIS n/a sigil: hunter is 10.2 below it — out of frame by design
VIS OK hunter0: (640, 401)
VIS FAIL hunter1: (587, 0)
GRIP OK: foothold 1 -> 0 after the timer emptied
```
Same shape as the combat-start bug above: `HUNTER1` is drawn exactly at its
own `home`, so this is a camera problem, not a placement one. During the grip
minigame the camera zooms in tight on the gripping hunter (hunter0) and the
ally (hunter1, higher up near the sigil) projects to the very top pixel row —
effectively invisible, not just tightly cropped.

**What I saw in the PNG:** The Frog mid-grip fills the frame; no sign of The
Goblin Engineer anywhere, including near the top edge.

**Likely same root cause as the combat-start bug** (the close-in single-hunter
framing doesn't budget room for where the OTHER hunter actually is) — noting
both because a session fix for one camera state shouldn't be assumed to fix
the other; they're two different `combat_3d` camera paths (opening framing vs
grip framing).

Not fixed here: both are `game/**` GDScript camera behaviour, outside
`tools/blender/**` / `game/assets/3d/**`.

## 2026-09-05 — ally hunter shrinks into the HUD corner during the climb

**Command:**
```
%GODOT% --path game --script res://tools/screenshot.gd -- ^
    out=C:\shot.png state=3dclimb slot=0 beast=yoke_ox
```

**What the harness printed:**
```
CAM pos=(0.650241, 17.844931, 19.908562) pivot=(0.650241, 16.787361, 9.368150) dist=10.59
HUNTER0 home=(0.650241, 15.947361, 9.368150) drawn=(0.650241, 15.983228, 9.368150) OK
HUNTER1 home=(9.440349, 13.101646, 8.503277) drawn=(9.440349, 13.123976, 8.503277) OK
VIS OK hunter0: (640, 423)
VIS FAIL hunter1: (1241, 604)
VIS OK sigil: (780, 446)
```
`HUNTER1` is drawn exactly at its own `home` again — a third camera path with the
same shape of bug as the two already logged above (opening framing, grip
framing), not a placement problem.

**What I saw in the PNG:** The Frog (active, at the sigil) fills the centre of
the frame as intended. The Goblin Engineer is not off-frame this time — he is
on-screen at (1241, 604), but that point sits inside the bottom-right party +
turn-order HUD block, and in the render he is a barely-visible sliver of a
figure wedged behind/under the "Switch" button and the turn gauge, easy to
miss entirely rather than read as your co-op partner mid-climb.

**Why it matters:** same first-impression problem as the other two — three
separate camera states (combat-start, grip, climb) all independently fail to
budget room for wherever the OTHER hunter happens to be, which suggests the
fix belongs in whatever shared framing logic computes `dist`/pivot from the
active hunter alone, not in three separate per-state patches.

**Checked and clean, for the record:** `3dreward`, `3dshop`, and `3dmap` all
rendered correctly this run — beast-fall reward screen, trader shop, and the
Act 1 overworld all showed both hunters/HUD/nodes exactly where expected, no
`VIS FAIL` and no `WALK FAIL`.

Not fixed here: `game/**` GDScript camera framing, outside
`tools/blender/**` / `game/assets/3d/**`.

## 2026-09-05 — two damage popups land on top of each other at Titan scale

**Command:**
```
%GODOT% --path game --script res://tools/screenshot.gd -- ^
    out=C:\shot_strike.png state=3dstrike slot=0 beast=thrasher
```

**What the harness printed:** all `VIS OK` — hunters, sigil, camera all where
expected. No `VIS FAIL` here; this find is about legibility, not placement.

**What I saw in the PNG:** a huge yellow "34" (the weak-point hit) and a
smaller red "11" (the ally's own hit, `on_hunter=true`) rendered almost fully
overlapping, centred on the sigil. Both numbers are individually legible as
glyphs but stacked, neither is readable as its own number at a glance — you see
a blur of two overlapping digits, not "34" and "11".

**Why:** `screenshot.gd`'s `3dstrike` state fires both popups on purpose to
exercise the juice (`_damage_popup(34, where, true, false)` and
`_damage_popup(11, where + Vector3(-1.6, -1.2, 0.0), false, true)` —
`tools/screenshot.gd:1086`), so a 1.6/1.2-unit spatial offset is intentional
and *should* separate them. It doesn't, because `_damage_popup` in
`combat_3d.gd:2791` sizes its `Label3D` off `_beast_box.size.y` (`reach`) so the
text stays legible against a Titan — but that scaling grows the GLYPH, not the
offset between glyphs. Against a beast tall enough, a fixed 1.6-unit gap
becomes small relative to 128pt text scaled by `reach`, and two popups that
land close together (a weak-point hit and a hunter's own hit on the same
swing, or two hits in the same combo) overlap instead of sitting side by side.
The Thrasher here is a mid-sized beast; a Titan would be worse, not better.

**Where to look:** `_damage_popup()` in `game/views/combat_3d.gd` — the offset
between two popups spawned close in time needs to scale with the same `reach`
factor the font size already does, or popups need a screen-space (not
world-space) minimum separation. This is `game/**` GDScript, outside this
lane's file ownership, so written up rather than touched.

## 2026-09-05 — hand's rightmost card sits flush against the edge on the phone aspect ratio

**Command:**
```
%GODOT% --path game --script res://tools/screenshot.gd -- ^
    out=C:\shot_mobile.png state=3d slot=0 beast=thrasher mobile size=2340x1080
```

**What the harness printed:** the same combat-start `VIS FAIL hunter1`
already logged above (this run just confirms it again on the actual mobile
render, not a new find). No harness line for the hand itself — `screenshot.gd`
does not check card-fan bounds.

**What I saw in the PNG:** on the 1170x540 mobile render (2340x1080 halved),
the same 5-card fan that sits comfortably inset from both edges at 1280x720
desktop now has its rightmost card ("Tongue Flick") cut flush against the
right edge of the screen — its cost badge and card border run off-canvas,
with no margin, where the desktop render leaves roughly 150px of clearance.
The leftmost card's name is truncated to "Tongue Sn..." inside its own card
face, which may be a separate, smaller instance of the same cause (a fan
width sized for the wider desktop viewport, not scaled down for the phone
aspect ratio).

**Why it matters:** CLAUDE.md's mobile-readiness constraints call for
anchor-based, scalable UI across aspect ratios specifically so a phone layout
isn't a rewrite — a hand of cards clipped at the screen edge is exactly the
kind of thing that constraint exists to prevent, and it's on screen every
single turn, not an edge case.

**Where to look:** wherever the hand fan lays out card positions/widths in
`game/views/combat_3d.gd` (or a shared hand-layout helper) — it looks sized
against a fixed pixel width rather than the viewport's actual width. This is
`game/**` GDScript, outside this lane's file ownership, so written up rather
than touched.

**Checked and clean, for the record:** `3dcampfire` rendered correctly this
run — both hunters, the rest-site geometry, and all five campfire actions
were visible and legible, no harness `VIS` line exists for this state but
nothing was off-frame or overlapping.
