# Bug hunt log — fixer lane

Findings from looking at the actual game (`tools/screenshot.gd`), not from the
score sheets. Per `tools/fixer/BRIEF.md`: fix it only if it's inside
`tools/blender/**` / `game/assets/3d/**`; anything in `game/**` GDScript gets
written up here for the session, not touched.

## 2026-09-09 — Pass B (temporal): nothing found in the five states the last Pass B run flagged as unchecked — every diff traces to the same already-accepted sub-pixel idle sway, none of it visible without diffing

**Pass B (temporal) — rotation choice.** Per-pass last-run times from `git log
--format='%h %ad %s' --date=format:'%Y-%m-%d %H:%M:%S' -- design/progress/bugs.md`:
A 2026-09-08 17:08:40, B 2026-09-08 16:05:26, C 2026-09-09 15:57:53, D 2026-09-09
15:05:16. B was oldest by a wide margin (over a day, and the only pass not run
since the 8th), so it's due.

**Subject: the five states the last Pass B entry (2026-09-08 16:05:26) explicitly
listed as not gotten to** — `3dsettings`, `3devent`, `3dsel`, `3dswap`, `3drebind` —
rather than re-running states that entry already cleared (`3dselect`, `3d`,
`3dmap`, `3dcampfire`, `menu`, `3dwon`, `3dshop`).

**Method, same as the prior Pass B entry:** `game/tools/screenshot.gd` captures
once and exits, so "twice, a few seconds apart" means two process launches
(~4s apart, real wall-clock time), same args, different `out=`, then a pixel
diff. Used Python 3.14 (`C:\Python314\python.exe`) with PIL/NumPy — the
`python3`/`python` names on this machine's PATH resolve to the Microsoft Store
alias shim, not a real interpreter (`Python was not found; run without
arguments to install from the Microsoft Store`); the working copy has to be
invoked by its full path. Threshold: per-channel diff > 10/255. Opened every
resulting PNG pair, plus 2x-zoomed crops of every diff bounding box, not just
the pixel counts.

**Commands (one pair per state, ~4s apart):**
```
%GODOT% --path game --script res://tools/screenshot.gd -- out=C:/fixer_shots/3dsettings_A.png state=3dsettings
%GODOT% --path game --script res://tools/screenshot.gd -- out=C:/fixer_shots/3dsettings_B.png state=3dsettings

%GODOT% --path game --script res://tools/screenshot.gd -- out=C:/fixer_shots/3devent_A.png state=3devent
%GODOT% --path game --script res://tools/screenshot.gd -- out=C:/fixer_shots/3devent_B.png state=3devent

%GODOT% --path game --script res://tools/screenshot.gd -- out=C:/fixer_shots/3dsel_A.png state=3dsel
%GODOT% --path game --script res://tools/screenshot.gd -- out=C:/fixer_shots/3dsel_B.png state=3dsel

%GODOT% --path game --script res://tools/screenshot.gd -- out=C:/fixer_shots/3dswap_A.png state=3dswap
%GODOT% --path game --script res://tools/screenshot.gd -- out=C:/fixer_shots/3dswap_B.png state=3dswap

%GODOT% --path game --script res://tools/screenshot.gd -- out=C:/fixer_shots/3drebind_A.png state=3drebind
%GODOT% --path game --script res://tools/screenshot.gd -- out=C:/fixer_shots/3drebind_B.png state=3drebind
```

**What the harness printed:** `3dsettings`, `3dswap`, `3drebind` all print the
same `CAM`/`HUNTER0`/`HUNTER1`/`VIS OK` lines as ordinary `3d` combat (this is
combat with an overlay on top); `3dswap` additionally prints `SWAP start=0
tab=1 key1=0 key2=1  OK` and `SPACE slot=1 ended false -> true  OK`;
`3drebind` prints `REBIND listening=end_turn bound=E label=E  OK`. `3devent`
and `3dsel` print nothing beyond `SHOT SAVED` — no self-test for either state
in the harness. No `FAIL` anywhere.

**What I saw, per state:**
- `3dsettings`: **0 pixels differed** between the two launches (threshold
  10/255, full 1280x720 frame) — pixel-identical.
- `3devent` ("The Toll Crow"): 680 px differed, bbox (498,250)-(804,345) —
  matches exactly where the Frog and Goblin Engineer figures stand on the
  hex tile in this event scene. Zoomed crop of both frames side by side:
  could not see a difference by eye.
- `3dsel` (Meld target-pick flow): 239 px, bbox (621,438)-(1010,480) — matches
  the harness's own printed hunter screen positions, `(640, 476)` and
  `(1000, 476)`. Zoomed crop: no visible difference by eye.
- `3dswap`: 134 px, but scattered essentially randomly across the *entire*
  frame (`x` from 7 to 1270, `y` from 5 to 674, no spatial clustering) —
  checked the actual differing coordinates, not just the bbox, because a
  bbox that size on a 134-pixel diff is a flag for scattered noise rather
  than a moving object. Viewed both full frames side by side: identical by
  eye, same shape as the single stray pixel the 2026-09-08 Pass B entry
  found in `3dshop` and attributed to compression/dither noise.
- `3drebind`: 6 px, bbox (990,444)-(1006,475) — matches only `HUNTER1`'s
  printed position, not `HUNTER0`'s; too small to see even zoomed 2x.

**Why none of this is a finding:** every non-zero diff lands either exactly on
a hunter's printed on-screen position or (for `3dswap`) shows no spatial
pattern at all, and none was visible by eye in a zoomed crop or a full-frame
side-by-side. This is the same conclusion and the same magnitude the prior
Pass B entry reached for `location_3d.gd:91` and `combat_3d.gd:889`'s
documented "gentle idle" sway — this run just confirms it holds, without
surprises, across five more states layered on top of that same combat/board
scene (a settings modal, a rebind listen, a Meld pick, a swap, a forced
event). Reporting sub-pixel sway that requires a diff tool to see would be
exactly the "two-point fix nobody could see" failure mode this brief was
rewritten to stop.

**One thing noticed but not reportable as a visual finding:** both `3dsel`
launches (A and B) printed identical engine-level warnings on exit —
`ERROR: Texture with GL ID of ... leaked ... bytes`, `41 ObjectDB instances
were leaked at exit`, `5 resources still in use at exit` — that none of the
other four states in this run produced. Deterministic across both launches,
so it's not a one-off. Not a screen-visible defect and outside what this
lane evaluates by looking, but consistent and worth the cloud lane's
attention if it greps `combat_3d.gd`'s Meld-pick teardown path — flagging it
here rather than silently dropping it, per the brief's "say what you could
not check" spirit.

**Could not check this pass:** mobile (`size=2340x1080`) temporal diffs for
any state — still not done in either Pass B run. The driven/animated states
this run didn't reach: `goblin`, `3dinspect`, `3dstrike`, `3dgame`,
`3dreward`, `3dfreecam`, `3dfocus`, `3dosu`, `3dbar`, `3dslide`, `3dcross`,
`3dloop`. `3dclimb` and `3dgrip` are still deliberately excluded (per the
prior entry: both have intentional per-launch randomization that would make
a diff show noise, not a bug). Any beast other than whichever the harness
defaults to when `beast=` is omitted (`thrasher`, per the prior entry) —
did not vary `beast=` this run since the point was state coverage, not
per-beast coverage.

## 2026-09-09 — Pass C (cross-surface): the cinder_jackal portrait/model mismatch flagged yesterday wasn't fixed — it was rebuilt on `main` twice more since the flag, and the colour gap has gone from ~40 minutes old to over a day old

**Pass C (cross-surface) — rotation choice.** Per-pass last-run times from `git
log --format='%h %ad %s' --date=format:'%Y-%m-%d %H:%M:%S' -- design/progress/bugs.md`:
A 2026-09-08 17:08:40, B 2026-09-08 16:05:26, C 2026-09-08 15:00:47, D 2026-09-09
15:05:16 (today's entry, below). C was the pass that had gone longest without a
run — older than B and A, and D had just gone — so it's due.

**Subject: `cinder_jackal`, continuing the trace the last Pass C entry (below,
"Second, smaller find") started** rather than opening a new one, because that
entry's own close said the gap was worth re-checking, and the asset has visibly
moved since. That prior entry found the portrait bake (2026-09-08 13:01:57–13:02:00,
the batch run for every beast) already 40 minutes stale against a same-day colour
recolour committed at 13:42:26 (`0db698f`, "darken cinder_jackal's body swatches").

**What changed since that flag was written (2026-09-08 15:00:47) — checked via
`git log --format='%h %ad %s' -- game/assets/3d/cast/cinder_jackal.glb` and file
mtimes, not assumption:**
```
6c01fb2 2026-09-09 14:52:42  Put the hunters back on solid ground        <- on main, rebuilds cinder_jackal.glb
15082b6 2026-09-08 13:02:39  The Frog is frog-sized, portrait is a frog again  <- the portrait batch bake
0db698f 2026-09-08 13:42:26  Phase 1: darken cinder_jackal's body swatches      <- already flagged stale, above
```
(A fourth commit, `7eea909` "a side-flaring hackle-spike anchor for cinder_jackal",
2026-09-09 14:13:31, also rebuilds the glb but lives on
`builder/2026-09-09-side-anchor-proposal` — confirmed with `git merge-base
--is-ancestor 7eea909 HEAD` → not an ancestor of `main`. Not counted below since
it isn't live in the game yet, but it's a second pending rebuild of the same
asset stacked behind the one that already is.)

`game/assets/portraits/cinder_jackal.png` mtime is still 2026-09-08 13:02:00 —
unchanged. So the live model on `main` has been rebuilt **twice** since the
staleness was written up (once for the colour swatches the previous entry
caught, and again today for footing/steps), and the portrait has been rebuilt
**zero** times. The gap the previous entry measured at 40 minutes is now, by
mtime subtraction, **25h50m** (13:02:00 on the 8th to 14:52 on the 9th) and
still growing every time this beast gets touched.

**What I looked at, not just dates:**
```
%GODOT% --path game --script res://tools/screenshot.gd -- ^
    out=C:/fixer_shots/cinder_jackal_3d.png state=3d beast=cinder_jackal
```
opened alongside `game/assets/portraits/cinder_jackal.png`. The live fight
camera is too tight on this beast to read colour confidently by itself (see
today's Pass D entry above — `weak_point_height: 5` beasts get cropped to
mostly-legs at this distance; confirmed the same here, `CAM ... dist=16.85`),
so I also opened the two images the darkening commit itself produced for
comparison, since they're already sitting in the repo and I didn't need to
render anything new: `design/renders/cinder_jackal_valuerange_before.png` and
`..._after.png` (both mtime 2026-09-08 14:36:02, i.e. taken to document
`0db698f`). `_before` is the bright rust-orange torso with a light tan
underbelly; `_after` is visibly darker brick-brown on the torso and near-black
umber on the underbelly, ember ridge unchanged and now standing out more, per
the commit message's own intent. `game/assets/portraits/cinder_jackal.png`
matches `_before` — bright rust-orange body, light tan underbelly — not
`_after`. Three images, one clear mismatch: the portrait is the pre-darkening
colour, and the game has looked like the post-darkening colour in every fight
for over a day.

**Why this is worth a second write-up instead of a one-line "still broken":**
the previous entry logged this as a same-day, 40-minute gap and explicitly
flagged it as "sitting behind a wire nobody has connected to a screen yet" —
i.e. low severity because nothing in the current UI reads `boss_art`/the
portrait for this beast (still true; grepped again, still zero consumers in
`game/views/**`/`game/ui/**`). What's different now is that the *model itself*
has been rebuilt on `main` a second time without anyone touching the portrait
in between, which means whatever process re-bakes portraits either isn't
running per-asset when a cast model changes, or only ran once as a one-off
batch on the 8th and nothing re-triggers it. That's a process gap, not just
one stale file — worth knowing before the day someone does wire `boss_art` up
and ships whichever version of this beast the portrait happens to remember.

**Where to look:** whatever produced the 2026-09-08 13:01:57–13:02:00 portrait
batch (not in `tools/blender/**` under a name I could find by inspection alone —
worth the cloud or builder lane grepping for the actual bake entry point) needs
either to run again for `cinder_jackal` specifically, or to be wired to run
per-beast whenever that beast's `.glb`/`.py` changes instead of as a manual
batch. Not touched — outside this lane's job under the rewritten brief, and the
portrait bake pipeline isn't `tools/blender/**` model geometry even if it lives
nearby.

**Could not check this pass:** whether any beast besides `cinder_jackal` has
been rebuilt since the 09-08 13:01:57–13:02:00 portrait batch — checked all 28
cast `.glb` mtimes and `cinder_jackal` is the only one dated after that window,
but I did not re-open every other portrait against its model to confirm by eye,
only by date, so a same-day rebuild-without-visible-colour-change on another
beast could still be hiding. Card art (`game/assets/cardart/**`) against any
hunter or beast — still not traced this pass either, two Pass C runs running.
The party panel outside of the one combat screenshot above. `mobile`/
`size=2340x1080` for any of this.

## 2026-09-09 — Pass D (proportion): the code's own "Crag Pup fits, Sunken Warden looms" contrast is true for 2 of the game's 28 beasts — everyone else gets the looming crop the comment says is reserved for Titans, and the wide "meet it once" establishing shot never fires for anyone

**Pass D (proportion) — rotation choice.** `git log --format='%h %ad %s' --date=format:'%Y-%m-%d %H:%M:%S' -- design/progress/bugs.md` shows the four post-rewrite passes ran D (2026-09-08 14:02) → C (15:00) → B (16:05) → A (17:08), in that order, and nothing since. D ran longest ago, so it's due.

The prior Pass D entry below (2026-09-08) found the Frog forced to person-height by `_fit_height`'s common `HUNTER_HEIGHT`, and explicitly flagged as unchecked: *"Did not check Titan-vs-Titan proportion this pass ... worth a separate Pass D pass to confirm rather than assumed clean here."* This run is that check — not of hunters, but of how the beasts themselves are framed against each other.

**Commands (10 beasts, same state, only `beast=` varies):**
```
%GODOT% --path game --script res://tools/screenshot.gd -- ^
    out=C:/shot_<name>.png state=3d beast=<name>
```
Run for `crag_pup`, `bounder`, `bog_leech`, `brine_urchin`, `eyrie_hawk`, `boulder_ram`,
`glyph_tortoise`, `stone_warden`, `drowned_colossus`, `sunken_warden`.

**What the harness printed** — the `CAM ... box pos=... size=(...)` line, one per beast. The
box's Y size (height) came out, across the ten: `crag_pup` 18.4, `bounder` 18.4, `boulder_ram`
20.0, `glyph_tortoise` 20.0, `husk_beetle`(see below) 20.0, `bog_leech` 21.6, `brine_urchin`
21.6, `eyrie_hawk` 21.6, `stone_warden` 21.6, `drowned_colossus` 29.6, `sunken_warden` 32.8. The
printed camera `dist` was **31.44 for all ten, to two decimal places, regardless of height** —
the same distance for an 18.4-unit beast as a 32.8-unit one.

**What I saw in the PNGs:** `crag_pup` and `bounder` (both traced to `weak_point_height: 4`,
the lowest value in `bosses.json`) sit fully inside the frame with clear headroom between the
top of the model and the top HUD bar. Every other beast I opened — `boulder_ram`,
`glyph_tortoise`, `stone_warden`, `bog_leech`, `brine_urchin`, `eyrie_hawk`, `drowned_colossus`,
`sunken_warden`, and `husk_beetle` (`weak_point_height: 5`, one step above the two that fit) —
has its head, horns, or crown sliced off flat by the top edge of the screen, several of them
overlapping the top HUD bar with what's left. `stone_warden`'s is the starkest: the whole top of
its head is a flat cut at the frame boundary, mid-model, not a silhouette that happens to reach
the edge.

**Why — traced to three numbers, not a judgement call:**
1. `_show_beast()` (`combat_3d.gd:1230`, called `combat_3d.gd:1060-1061`) sets a beast's height
   to `BEAST_BASE_HEIGHT (12.0) + BEAST_HEIGHT_PER_CLIMB (1.6) * boss["weak_point_height"]`
   (`combat_3d.gd:102-103,1232`) — confirmed against `bosses.json`'s own `weak_point_height`
   field, which every one of the ten boxes above matches exactly (e.g. `crag_pup`
   `weak_point_height: 4` → 12 + 1.6×4 = 18.4; `sunken_warden` `weak_point_height: 13` →
   12 + 1.6×13 = 32.8).
2. `_frame_beast()` (`combat_3d.gd:1441`) sizes the camera window to `tall * 1.18` (working) or
   `tall * 1.35` (establishing), both routed through `_window_for()` (`combat_3d.gd:1613-1614`):
   `clampf(want / (1.0 - HUD_BOTTOM_FRACTION), VIEW_WINDOW_MIN, VIEW_WINDOW_MAX)`, i.e.
   `clampf(want / 0.66, 9.0, 28.0)`.
3. `bosses.json`'s `weak_point_height` ranges from **4 (its own minimum, held by Crag Pup and
   Bounder) to 13**. Solving the clamp: the *working* window only stays under its 28.0 ceiling
   for `tall ≤ 15.66` (`weak_point_height ≤ ~2.29`) and the wider *establishing* window only
   stays under it for `tall ≤ 13.69` (`weak_point_height ≤ ~0.87`). **No beast in the data has a
   `weak_point_height` that low** — the lowest is 4, already past both thresholds. So every
   single beast in the game hits the same `VIEW_WINDOW_MAX = 28.0` ceiling, on both the wide and
   the close shot, and gets the exact same camera distance out of `_dist_for_window()`
   (`combat_3d.gd:1634-1640`) — which is exactly the "31.44 for all ten" the harness printed.
   Only the two shortest beasts (`weak_point_height: 4`) are short enough, in absolute terms, to
   still fit inside that fixed 28-unit window with margin; everything else pokes out the top by
   however much its own height exceeds it.

**A second, sharper consequence of the same clamp:** `_frame_beast()`'s own doc comment
(`combat_3d.gd:1434-1452`) says the game "opens on the whole creature, however far back that has
to be, then falls in to the working shot... you get to see what you've picked a fight with once"
— an eased transition gated by `_establishing = _dist > _working_dist + 0.1` (`combat_3d.gd:1454`,
consumed at `1584-1590`). Since both `_dist` (established via the `*1.35` window) and
`_working_dist` (via `*1.18`) clamp to the identical `28.0` ceiling for every beast in the current
data (per point 3 above), `_dist` and `_working_dist` are numerically equal from the first frame,
`_establishing` evaluates false immediately, and the eased wide-to-working fall-in this comment
describes never plays for any beast currently in `bosses.json`. The "meet it once, full body"
reveal is not a rare thing that only the biggest Titans skip — it's dead code against the whole
roster as it's currently tuned.

**Why this reads as unfinished, not just technically true to the code:** `climb_frame_for()`'s
own comment (`combat_3d.gd:1689-1692`) states the intent in so many words: *"cropping a Crag
Pup's head isn't imposing, it just looks like a mistake. Only the ones too big to hold get the
looming shot, which makes towering a thing the act Titans do rather than something every fight
does."* That line describes a game where most fights look like `crag_pup` (clean, fits) and a
few big Titans loom. The data makes the opposite true: **26 of the 28 beasts in `bosses.json`**
have `weak_point_height ≥ 5` (I checked the field for all 28; only `crag_pup` and `bounder` sit
at the minimum of 4), so 26 of 28 first impressions in this game are the "looks like a mistake"
crop the code was written to avoid, including beasts with no Titan/act-boss framing at all —
`husk_beetle`, `boulder_ram`, and `glyph_tortoise` looked, by eye, like completely ordinary
mid-tier fights, not the towering set-piece the cropped shot is supposed to be reserved for.

**Where to look:** `combat_3d.gd:102-103` (`BEAST_BASE_HEIGHT`, `BEAST_HEIGHT_PER_CLIMB`),
`combat_3d.gd:110-111` (`VIEW_WINDOW_MIN`, `VIEW_WINDOW_MAX`), `combat_3d.gd:1434-1458`
(`_frame_beast`), `combat_3d.gd:1613-1640` (`_window_for`, `_dist_for_window`) — either the
height formula's constants or the window clamp need to move relative to each other so the
`weak_point_height` range that actually exists in `bosses.json` (4–13) produces the fits/looms
split the comments describe, instead of a split that only exists between 4 and 5. Not touched —
`game/**` GDScript.

**Could not check this pass:** the remaining 18 beasts in `bosses.json` by screenshot (I relied
on the `weak_point_height` field, already confirmed to predict the box size exactly for all ten
I did shoot, to extrapolate the other 18 — worth a by-eye pass if that inference is doubted); the
climb-in-progress framing (`_climb_frame`/`climb_frame_for`, `combat_3d.gd:1656-1699`), which
reads the same `_window_for` clamp once a hunter leaves the ground and may or may not hit the
same ceiling differently; and any of this at `mobile`/`size=2340x1080`, where `HUD_BOTTOM_FRACTION`
reserving the same screen fraction on a much narrower frame could plausibly make the crop worse,
not better.

**A tooling note for whoever runs this pass next:** passing `out=` with backslashes
(`C:\fixer_shots\shot.png`) through this session's Bash tool silently produced
`C:fixer_shotsshot.png` — every backslash vanished, not just at drive-root (the already-logged
gotcha below is a different failure). Godot still printed `SHOT SAVED` and no file existed at
the intended path. Forward slashes (`out=C:/fixer_shots/shot.png`) worked every time this run.
If you're driving this from PowerShell directly rather than through this tool, this may not
reproduce — but it cost real time here, so worth knowing.

## 2026-09-08 — Pass A (the walk): two hunters render fully merged into one blob when the Goblin Engineer is picked first, and the free camera refuses to drag from three screen regions it should not refuse

**Pass A (the walk) — first run of this pass since the brief rewrite.** Grepped
this log before starting: B, C, and D each already had a first post-rewrite
entry dated 2026-09-08; A did not (its most recent entries were all
pre-rewrite, 2026-09-05/07). So this is the pass that had gone longest without
a run, per the brief's rotation rule. Walked states not opened by any prior
entry in this log (`3dosu`, `3dbar`, `3dslide`, `goblin`, `3dfreecam`) plus a
beast never checked before (`drowned_colossus`), and re-walked `menu`/`3dselect`
at the mobile size.

### Finding 1 — the Frog and the Goblin Engineer draw fully interpenetrated, standing on top of each other, whenever the Goblin Engineer is the first-picked character

**Command:**
```
%GODOT% --path game --script res://tools/screenshot.gd -- ^
    out=C:\Users\<you>\AppData\Local\Temp\shot.png state=goblin slot=0 beast=drowned_colossus
```
Reproduced a second time with a completely different beast to rule out a
beast-specific cause:
```
%GODOT% --path game --script res://tools/screenshot.gd -- ^
    out=C:\Users\<you>\AppData\Local\Temp\shot2.png state=goblin slot=0 beast=thrasher
```
(`state=goblin` is an existing harness state — `screenshot.gd:143-145` — that
picks `goblin_mech` into slot 0 and `frog` into slot 1, the mirror image of
every other combat state's default order. Nothing beast-specific about it;
identical result on both beasts.)

**What the harness printed:** nothing relevant to hunter placement — see "A
coverage gap," below. No `HUNTER`/`CAM`/`VIS` lines are emitted for this state
at all, on either run.

**What I saw in the PNG:** opened both, then cropped and 2x-zoomed the hunter
area on each. On both beasts, the two hunters are not side by side (as they
are in every other combat-start shot in this log, ~9 units apart on X, one of
them typically off-screen per the already-logged "ally hunter off-screen"
bug) — they are drawn one **inside** the other, both anchored to the same
point in screen space: The Frog's rounded green body and long tongue overlap
directly with the Goblin Engineer's dark armoured torso and legs, the tongue
poking out through the goblin's hip, the goblin's boots visible planted
between the frog's own feet. Confirmed by eye on the zoomed crop, not just a
compression artefact — the two silhouettes are genuinely superimposed, at
matching scale and matching ground shadow, in both screenshots.

**Why this looks like a placement bug, not a camera illusion:** `_place_hunters()`
(`combat_3d.gd:2347`) computes each hunter's `side` purely from its array index
(`side := -1.0 if i == 0 else 1.0`, line 2357) and offsets X by
`side * (_beast_box.size.x * 0.22 + 0.6)` at rest (line 2373) — nothing in that
formula reads which *character* occupies index 0 or 1, so swapping
Goblin-first vs. Frog-first shouldn't change the spacing at all if this path
is what's running. That it visibly does change is why I'm flagging this for
someone who can put a breakpoint or a print on `_place_hunters`/`_spawn_hunter`
rather than guessing further from screenshots alone.

**A coverage gap that let this hide:** `_report_visibility()` — the function
that prints every `HUNTER`/`CAM`/`VIS` line elsewhere in this log — is only
called when `_state.begins_with("3d")` (`screenshot.gd:687-688`). `"goblin"`
does not start with `3d`, so this state has never been checked by the harness's
own contradiction test, on any prior pass. Two hunters standing inside each
other is exactly the shape of bug that test exists to catch (see the comment
at `screenshot.gd:463-471` about hunters once being drawn stacked at the
beast's centre for months, undetected, "because every check asked the game"
instead of comparing the picture) — it just couldn't catch it here because the
state name doesn't match the prefix the check gates on. Not fixed or reported
as a code change per this lane's rules, but worth someone widening that
`begins_with("3d")` gate, or renaming this state, since it's the second time a
state-name mismatch has hidden exactly the class of bug this brief exists to
surface.

**Could not check:** whether `3dosu`, which shares the same
`goblin_mech`-first/`frog`-second character order (`screenshot.gd:143`), has
the same overlap — its shot is a tight `_focus_camera()` close-up on the
active hunter alone (see `shot_osu.png` in Finding 3 below), so the second
hunter is off-frame regardless and the picture can't confirm or rule this out.

### Finding 2 — the free camera refuses to drag from three screen regions the game's own test says it should not, and right-drag-to-slide does nothing

**Command:**
```
%GODOT% --path game --script res://tools/screenshot.gd -- ^
    out=C:\Users\<you>\AppData\Local\Temp\shot.png state=3dfreecam slot=0 beast=drowned_colossus
```
(first time this state has appeared in this log at all)

**What the harness printed:**
```
FREECAM centre        drags
FREECAM sky-left      drags
FREECAM party-panel   DEAD
FREECAM over-cards    DEAD
FREECAM ground-gap    DEAD
FREECAM gauge         DEAD
FREECAM top-bar       DEAD
FREECAM dead: party-panel, over-cards, ground-gap, gauge, top-bar  |  unexpected: ground-gap, gauge, top-bar
FREECAM wasd: all six move the camera
FREECAM pan (0.0, 0.0, 0.0) -> (0.0, 0.0, 0.0) STUCK | select clears it: yes
```
This test's own comment (`screenshot.gd:920-922`) states the rule directly:
*"The party cards and the hand are meant to eat their own clicks... Anywhere
ELSE that refuses a drag is a bug, and the top bar was one."* `party-panel`
and `over-cards` are the only two zones the test expects dead
(`screenshot.gd:923`); everything else it found dead — the gap in the ground
between the hunters and the beast, the ascension/momentum gauge column on the
right edge, and the top HUD bar — is the harness declaring a regression, in
its own "unexpected:" line, not a judgement call I'm adding on top. Separately,
right-drag ("slide," per the Settings screen's own text) produced no pan
change at all across four frames of motion (`pan0 == pan1`, printed `STUCK`).

**What I saw in the PNG:** confirms there's a real, unobstructed 3D scene under
all five zones the test dragged against — the ground gap between hunters and
boss, the gauge, and the top bar are all plainly empty space or translucent
HUD over the 3D view in the captured frame, not solid panels that would
legitimately eat a click the way the party cards or hand do.

**Why it matters:** this is not a debug-only harness feature — the Settings
screen documents this exact control scheme to players verbatim: *"Drag to
look around. Right-drag to slide. Wheel to zoom."* (confirmed by eye this same
run, `state=3dsettings`). It's the camera every player has during every 3D
combat, climb, and reward screen in the game. A player whose mouse happens to
be over the gauge, the top bar, or the gap of ground between the party and the
boss — all ordinary places to rest a cursor — gets a camera that simply will
not turn from there, and right-click-drag to slide the view does not work at
all, anywhere, per this test.

**Where to look:** whatever routes mouse-drag input to the free camera in
`combat_3d.gd` (the `_gui_input`/`_input`-level handling `_yaw`/`_pan`, near
where `3dswap`'s and `3dfocus`'s camera code already live) — this is `game/**`
GDScript, outside `tools/blender/**` / `game/assets/3d/**`, so written up
rather than touched.

### Finding 3 (lower confidence) — the "Sweep bar" timing style may render no visible timing indicator at all

**Command:**
```
%GODOT% --path game --script res://tools/screenshot.gd -- ^
    out=C:\Users\<you>\AppData\Local\Temp\shot_bar.png state=3dbar slot=0 beast=drowned_colossus
```

**What the harness printed:** `TIMING style=bar card=Tongue Snap windows=1
circle_live=false` — the game's own report that a timed card was tapped and
the sweep-bar path (not the hit-circle path) is live for it.

**What I saw in the PNG:** cropped the tapped card ("Tongue Snap") and
pixel-diffed it against the same card in an untouched resting-hand screenshot
taken moments earlier. The diff bounding box is 41x7 pixels out of a
1050x660 crop — nothing a person would call a visible change; side by side the
two crops look identical. No sweep strip, marker, or colour change is visible
anywhere on the card.

**Why, from reading the code, not just the picture:** `start_timing()`
(`card_view.gd:1646`) does set `_strip.visible = true`, but `_strip` is
anchored at `anchor_top = anchor_bottom = 0.86` of the CARD's own height
(`card_view.gd:317-323`) — right near the bottom edge. `_layout_hand()`
(`combat_3d.gd:3092`) deliberately tucks a card DEEP at rest, "below the screen
edge" for anything past the name and art, per its own comment at
`combat_3d.gd:3119-3123` — the only thing that lifts a card clear of that tuck
is `_hand_hover`, which is set exclusively by a `mouse_entered` signal
(`combat_3d.gd:3178-3180`). My repro calls `_on_card_tapped()` directly
(mirroring how `screenshot.gd` drives every other timed-card state), which
never fires `mouse_entered`, so the card stayed in its deep-tucked rest
position for the shot — meaning the strip may simply have been positioned
off past the bottom of the frame, the same place the card's own rules text
gets tucked to.

**Why this is flagged lower-confidence, not a plain finding:** on a real
desktop click, the mouse must pass over the card before it can be clicked,
which fires `mouse_entered` and lifts the card before the tap — so an actual
player's mouse-driven play may never hit this path at all. I could not
simulate that sequence through this harness (it calls the tap handler
directly, not a synthesized hover-then-click), so I don't know whether a real
click leaves the card raised for the sweep that follows. What I can say for
certain: on **handheld, there is no `mouse_entered` at all** — the code's own
comment (`combat_3d.gd:3120-3123`) says so in as many words ("no hover means
whatever is hidden at rest is hidden forever") — so if the strip does depend
on hover-lift to clear the tuck, "Sweep bar" timing would be structurally
unplayable on touch specifically, which is exactly the kind of thing CLAUDE.md
§5's "no hover-only information" rule exists to prevent. **Not confirmed** —
someone who can drive a real mouse (or touch) through this needs to check
whether the strip appears once a card is actually clicked in a live session,
on both desktop and a handheld-sized window.

**Where to look, if confirmed:** `card_view.gd`'s `_build_timing_strip()` /
`start_timing()` (1646, 1783) and its dependency on `_hand_hover` in
`combat_3d.gd` (3092-3146). Not touched — `game/**` GDScript.

**Fixed 2026-09-09 (#86 duty 2), confirmed rather than left at "not confirmed"
above.** The hover dependency was real, not just plausible: `_on_card_tapped`
called `cv.start_timing(hits)` with nothing raising the card first, so on a
handheld tap (no `mouse_entered`, ever) the strip stayed inside the deep tuck
for the whole minigame, exactly as this entry predicted. Added `_timing_card`
alongside `_hand_hover`, set it the moment a bar-style timed card is tapped
(before `start_timing`, so `_layout_hand()` raises it immediately), and
folded the raise decision into a pure `card_is_raised(card, hover, timing)`
so it's provable without building the hand row's UI —
`_test_backlog86_card_is_raised_by_hover` and
`_test_backlog86_card_is_raised_by_active_timing_with_no_hover` in
`run_tests.gd`. Reset alongside `_hand_hover` in `render_hand_status`'s
existing hover-reset path, so it can't outlive a freed CardView across a
hand rebuild. **Could not verify the visual result** — no display in this
session, so nobody has looked at the raised card on either desktop or a
handheld-sized window; the fix is proven at the logic layer (which card the
game decides to raise), not by eye.

### A tooling gotcha for whoever runs this pass next

The brief's own example command writes to `out=C:\shot.png` — directly at the
drive root. On this machine, that **silently fails**: Godot printed
`ERROR: Can't save PNG at path: 'C:/shot_a1.png'` to stderr and then *still*
printed `SHOT SAVED: C:/shot_a1.png (1280x720)` on the next line, and no file
was written (confirmed — `ls` on the path came back "No such file or
directory"). Writing to a subdirectory instead
(`%LOCALAPPDATA%\Temp\<name>.png`, or anywhere else non-root) worked every
time this run. I don't know if this is a permissions quirk specific to this
shell/session or a real gap in `screenshot.gd`'s error handling, but the
harness's own success line cannot be trusted at face value when the output
path is drive-root — which is worth knowing given this brief's own history of
"the log looked fine while the lane was dead."

**Checked and clean, for the record, this run:** `state=3dsettings`,
`state=3dstrike`, `state=3dslide`, `state=3dosu` (aside from Finding 3, all
printed clean self-tests and looked correct by eye) — all captured against
`drowned_colossus`, a beast with no prior fixer or bug-hunt entry against it.
`state=menu` and `state=3dselect` at `mobile size=2340x1080` both reproduce
already-logged bugs (the Sloth/Goat/Monkey/Rhino roster, and the Frog's
oversized proportions) with nothing new at this aspect ratio.

**Could not check this pass:** `3dgame`, `3dcross` at a beast other than
already logged, and any mobile-size capture of `3dfreecam`, `goblin`, or the
timed-card states above — ran out of pass budget after the two headline
finds. `drowned_colossus`'s own model/portrait/menu cross-surface consistency
also wasn't traced (that's Pass C's job, not this one).

## 2026-09-08 — Pass B (temporal), first run of this pass: nothing found beyond two already-intentional, sub-visible idle motions; the beast breathing-pulse bug (fixed 2026-09-08) does not appear to have regressed

**Pass B (temporal) — first run of this pass ever.** Grepped this whole log for
"Pass B" before starting: zero hits (Pass A, C, D all have entries; B did not).
So this is the pass that had gone longest without a run, per the brief's
rotation rule, not a free choice.

**Method:** `game/tools/screenshot.gd` captures once and exits, so "the same
state twice, a few seconds apart" means two separate process launches, several
real seconds apart, same `state=`/`beast=`/`slot=` args, different `out=`
paths, then a pixel diff. Used Python/PIL (`ImageChops.difference` + a NumPy
threshold) since no diff tool ships in this repo. Every state below was
diffed this way; I opened every resulting PNG (both raw shots for the states
that showed a diff, plus zoomed crops of the diff region) rather than trusting
the diff numbers alone.

**Commands (one pair per state, ~3-4s apart):**
```
%GODOT% --path game --script res://tools/screenshot.gd -- out=C:\shot_A.png state=3dselect
%GODOT% --path game --script res://tools/screenshot.gd -- out=C:\shot_B.png state=3dselect

%GODOT% --path game --script res://tools/screenshot.gd -- out=C:\shot_A.png state=3d slot=0 beast=thrasher
%GODOT% --path game --script res://tools/screenshot.gd -- out=C:\shot_B.png state=3d slot=0 beast=thrasher

%GODOT% --path game --script res://tools/screenshot.gd -- out=C:\shot_A.png state=3dmap
%GODOT% --path game --script res://tools/screenshot.gd -- out=C:\shot_B.png state=3dmap

%GODOT% --path game --script res://tools/screenshot.gd -- out=C:\shot_A.png state=3dcampfire
%GODOT% --path game --script res://tools/screenshot.gd -- out=C:\shot_B.png state=3dcampfire

%GODOT% --path game --script res://tools/screenshot.gd -- out=C:\shot_A.png state=menu
%GODOT% --path game --script res://tools/screenshot.gd -- out=C:\shot_B.png state=menu

%GODOT% --path game --script res://tools/screenshot.gd -- out=C:\shot_A.png state=3dwon slot=0 beast=thrasher
%GODOT% --path game --script res://tools/screenshot.gd -- out=C:\shot_B.png state=3dwon slot=0 beast=thrasher

%GODOT% --path game --script res://tools/screenshot.gd -- out=C:\shot_A.png state=3dshop
%GODOT% --path game --script res://tools/screenshot.gd -- out=C:\shot_B.png state=3dshop
```

**What the harness printed:** nothing relevant to this pass — no state has a
temporal self-test, so every finding here is from diffing and looking at the
picture, same as Pass C/D's entries above.

**What I saw:** `menu` and `3dmap` came back pixel-identical between the two
launches (zero pixels over a diff threshold of 10/255) — clean. `3dshop` had
exactly one pixel differ by more than threshold, in the sliver of hex tile
still visible below the trader's card panels; that's compression/dither noise,
not a rendered difference (opened `shot_shop1.png` — the trader screen covers
almost the entire hex map with five gold-cost card panels and three
deck/nav buttons, leaving only a small triangle of ground visible at
bottom-centre; nothing there moved).

`3dselect`, `3d` (combat open), `3dcampfire`, and `3dwon` each showed the same
shape of small, tightly-bounded diff (order of 20-200 pixels out of ~920,000,
always confined to a box a few hundred pixels wide around chest/head height on
a hunter or the sigil) every time. Cropping and zooming those regions 2-3x and
looking at the two frames side by side (not just trusting the diff count), I
could not see the difference by eye in any of them — confirmed on
`3dselect`'s five-hunter row and `3d`'s active-hunter/sigil close-up. Tracing
the code for what's actually moving there:
- `location_3d.gd:91` (`3dselect`, `3dcampfire`, `3dwon`, `3dreward` all
  share this view): `n.position.y = TILE_TOP + sin(_time * 2.1 + i * 1.7) *
  0.035` — a documented "gentle idle" per the same pattern in combat.
- `combat_3d.gd:889`: hunters sway `sin(_time * 2.3 + i * 1.7) * 0.045`,
  explicitly commented "a gentle out-of-phase idle so the two hunters don't
  look cloned."
- `combat_3d.gd:891`: the weak-point sigil pulses scale by `sin(_time * 3.0) *
  0.14` — the biggest amplitude of the three, and still not visible by eye at
  normal viewing size in my crops.

**Specifically checked for a regression of the already-known "beast grew and
shrank" bug** (`combat_3d.gd:868-879`, removed 2026-09-08 per Nick — it was
`1.0 + sin(_time * 1.6) * 0.02` on the beast's uniform scale): the `state=3d`
diff bbox did NOT include the beast's body at all, only the sigil floating
above it. Confirmed by eye on the cropped pair (beast fills most of the crop,
sigil is the small triangle above it) — the beast itself is pixel-identical
between the two captures. No sign this has come back.

**Why none of this is a finding:** the brief's bar is "would a player think
this looks unfinished," and the whole reason the beast pulse counted was that
at 2% on a Titan filling the frame, it was "plainly visible" (the code
comment's own words). These three idle motions are an order of magnitude
smaller in screen-space terms (a few pixels of sub-degree sway on a
728x720-ish render) and I could not see any of them without diffing two
frames and zooming in — which is the opposite of "obviously wrong to anyone
who looks" that Pass D's bar (and this brief's bar generally) sets. Reporting
them as bugs would be the "two-point art fixes nobody could see" failure mode
this brief was rewritten to get the fixer OFF of, just relocated to this lane.

**A caveat on the method, for whoever runs Pass B next:** because
`screenshot.gd` captures after a small fixed frame count from scene-ready
(`_capture()`, ~15 frames plus camera settle) rather than after a fixed
wall-clock delay, two separate launches land at nearly the same *scene* time
(a few tenths of a second in, judging by the hunter-sway values printed by
`SLOT`/`HUNTER` lines across my two `3d` runs: `0.036049` vs `0.035834`) even
though several real seconds separate the two commands. It still caught the
sigil pulse and hunter sway because those cycle in ~2-3 seconds, but a defect
that only becomes visible after many seconds of true idling (someone leaving
a screen up) would need a state with a longer built-in wait before capture,
not just two cold launches — I don't know of one in this harness today.

**Could not check this pass:** mobile (`size=2340x1080`) temporal diffs for
any state; the driven/animated states (`3dclimb`, `3dstrike`, `3dgrip`,
`3dreward`) where two launches don't land at comparable moments because part
of the sequence is itself randomized on purpose (the climb note pattern,
`combat_3d.gd:648-651`, is deliberately re-randomized per Nick, 2026-08-25 —
diffing two launches of `3dclimb` would just show that intentional variety,
not a bug, so I left it out rather than report noise); any beast other than
`thrasher`; and `3dsettings`/`3devent`/`3dsel`/`3dswap`/`3drebind`, which I
did not get to this pass.

## 2026-09-08 — the main menu shows four characters that don't exist in this game (Sloth, Goat, Monkey heroes; a Rhino "Beast"), while the real 5-hunter roster and every Titan are absent from it

**Pass C (cross-surface) — first run of this pass since the brief rewrite.**
Subject: "who/what does the main menu claim this game is about," traced against
`game/data/characters.json` (the real hunter roster) and `game/data/bosses.json`
(the real beast/Titan pools), then against the deeper character-select screen
that already gets this right.

**Command:**
```
%GODOT% --path game --script res://tools/screenshot.gd -- ^
    out=C:\shot_menu.png state=menu
```
No `beast=`/`slot=` needed — this is the title screen, first thing any player
sees before a run starts.

**What the harness printed:** nothing relevant — `state=menu` has no `HUNTER`/`VIS`
self-test, so this is a looking-at-the-picture find like Pass D's, not a `FAIL` line.

**What I saw in the PNG:** Under the "TITAN-SLAYERS" title, the row of four small
"Heroes" icons reads, left to right: a 3D-rendered Frog (correct — matches the
current roster), then three flat, differently-styled cartoon icons captioned
nothing on-screen but sourced (per `game/views/menu.tscn:6-8`) from
`assets/portraits/sloth.png`, `goat.png`, `monkey.png`. To the right, a large
"Beast" showcase image (`menu.tscn:41-54`) fills a third of the screen with
`assets/portraits/rhino.png`, a flat cartoon rhino head.

**Why this is wrong, not a style opinion:** I grepped `game/data/characters.json`
and `game/data/bosses.json` for `"sloth"`, `"goat"`, `"monkey"`, `"rhino"` as ids
— zero matches, in either file, anywhere. The actual 5-hunter roster is The Frog,
The Vine-Weaver, The Mountain Climbers, The Goblin Engineer, The Lightbearer
(`characters.json` name fields). The actual beast pool across regular/elite/titan
is `crag_pup`, `bramble_hog`, `bounder`, `root_lurker`, `sky_snapper`, `riftling`,
`husk_beetle`, `thrasher`, `boulder_ram`, `cinder_jackal`, `glyph_tortoise`,
`yoke_ox`, `mire_snapper`, `frost_sentinel`, `grove_bear`, `shifting_idol`,
`gloom_moth`, `bog_leech`, `silk_widow`, `brine_urchin`, `clot_toad`,
`flicker_stag`, `eyrie_hawk`, `riptide_eel`, `stone_warden`, `gale_serpent`,
`drowned_colossus`, `sunken_warden` — no rhino among them either. Sloth, goat,
monkey and rhino are leftover assets from an older placeholder animal set
(`game/assets/portraits/{sloth,goat,monkey,rhino,...}.png`, all dated Jul 28 —
by a wide margin the oldest files in that whole folder, untouched since,
alongside other unused leftovers of the same set: bear, crocodile, dog, owl,
penguin, pig, rabbit, snake, walrus, whale). This is the same species of bug as
the frog.glb/frog.png staleness this brief was rewritten over, but worse in
kind: not a render that lags its source by a day, but four character slots on
the first screen of the game that were never repointed at the real roster when
it was built out to five named hunters, so the menu still promotes a cast that
was, at best, a very early prototype and, per data, never existed as playable
content at all.

**Confirmed correct for comparison, same run:** `state=3dselect` (the actual
hunter-pick screen, one screen deeper than the menu) shows all five real
hunters — Frog, Vine-Weaver, Mountain Climbers, Goblin Engineer, Lightbearer —
as their current 3D models with correct ability text, so this is not a
roster-wide problem; it's specifically `game/views/menu.tscn` never having
been updated. The little HP-panel hunter icons during combat (`state=3d`) also
correctly show Frog/Goblin Engineer, not the old set. The menu is the one
surface still wrong.

**Not fixed here** — `game/views/menu.tscn` is a scene resource, outside
`tools/blender/**` / `game/assets/3d/**` and outside this lane's job under the
new brief (this lane changes nothing at all now). Whoever picks this up needs
either real portrait art for the current roster's "hero row" use case (the
existing `portraits/*.png` for Frog/Vine-Weaver/Mountain Climbers/Goblin
Engineer/Lightbearer are all 3D renders sized for cards, not small flat icons —
worth deciding whether the menu should reuse those directly or want a distinct
icon-style asset) and a real Titan for the "Beast" showcase (`cinder_jackal` or
whichever the game wants to lead with) in place of `rhino.png`.

**Second, smaller find from the same subject-trace — a portrait that already
went stale within today's own build:** while tracing `cinder_jackal` across
surfaces (3D model in a live fight vs. its baked portrait) to get to the menu
finding above, I caught the model and portrait disagreeing with each other by
about 40 minutes:
```
game/assets/3d/cast/cinder_jackal.glb            2026-09-08 13:42:36
game/assets/portraits/cinder_jackal.png          2026-09-08 13:02:00
```
Commit `0db698f` ("Phase 1: darken cinder_jackal's body swatches, let the ember
ridge scream", 13:42:26) recoloured the model's body swatches (RUST→BRICK,
TAN→UMBER per the commit message) *after* the batch portrait bake at
13:01:57–13:02:00 that produced every other beast's portrait that same run.
I opened both: `assets/portraits/cinder_jackal.png` (the baked portrait, still
bright rust-orange) against a fresh `state=3d beast=cinder_jackal` capture (the
live fight model, visibly the darker brick/umber the commit describes) —
they no longer match. Lower-severity than the menu find because I could not
find anywhere in the current UI that actually displays this portrait: `boss.art`
is threaded all the way from `content.gd` through `game_host.gd`'s
`_boss_art_per_act()` into the client state dict under `"boss_art"`
(`game_host.gd:343,437-441`), but no `game/views/**` or `game/ui/**` file reads
`boss_art` or loads a boss's `.art` texture anywhere — I grepped for both and
found zero consumers. So today this is data that's already wrong, sitting
behind a wire nobody has connected to a screen yet; worth knowing before
someone connects it and inherits a stale asset on day one the way the frog did.
**Checked, not verified further:** whether this class of "rebuilt after the
portrait batch" staleness also hit any other beast besides `cinder_jackal` —
I checked all four Sep-08-dated cast models (`bog_leech`, `husk_beetle`,
`frog`, `cinder_jackal`) against the 13:01:57–13:02:00 portrait-batch window
specifically because those were the only glbs young enough to be in question;
`cinder_jackal` was the only one rebuilt after its own portrait.

**Could not check this pass:** card art (`game/assets/cardart/**`) for any of
the five hunters or any beast — the subject trace this run went model → portrait
→ menu → roster data instead, since that's where the actual finds were. Also
did not check the party panel outside of the one combat screenshot above, and
did not check `mobile`/`size=2340x1080` for either the menu or select screen.



**Pass D (proportion) — first run of this pass under the rewritten brief.**
Rotation so far had only ever done Pass A (single-screenshot contradiction
checks); nothing had compared the cast's sizes against each other or the real
world before this run. This is the exact bug Nick named when the brief changed
("a frog the size of a person") — confirmed here independently, with three
separate repros, before reading that it was already known.

**Commands (three independent repros, same result in each):**
```
%GODOT% --path game --script res://tools/screenshot.gd -- ^
    out=C:\shot_select.png state=3dselect
%GODOT% --path game --script res://tools/screenshot.gd -- ^
    out=C:\shot_reward.png state=3dreward slot=0 beast=thrasher
%GODOT% --path game --script res://tools/screenshot.gd -- ^
    out=C:\shot_won.png state=3dwon slot=0 beast=thrasher
```
(no `beast=` needed for `3dselect`; `thrasher` chosen arbitrarily for the
other two, not beast-specific — the bug is in how hunter bodies are scaled,
which doesn't depend on which Titan is present)

**What the harness printed:** nothing relevant — no self-test covers hunter
proportion, so all three are looking-at-the-picture finds, not `FAIL` lines.

**What I saw in the PNGs:**
- `3dselect` (the five-hunter pick screen): The Frog stands shoulder-to-head
  with the Vine-Weaver, Mountain Climbers, Goblin Engineer, and Lightbearer —
  all five character portraits sit at essentially the same head height on the
  same ground plane. The Frog's body is also roughly 1.5-2x as WIDE as any of
  the four humanoids at that same height (measured on-screen: Frog's footprint
  spans roughly x=290-430px; Mountain Climbers, standing at comparable depth,
  spans roughly x=600-670px).
- `3dreward` (beast-fall reward screen): The Frog and Goblin Engineer stand
  together at the foot of the fallen Titan; the Frog's head is level with the
  Goblin Engineer's.
- `3dwon` (run-clear screen): worst of the three — The Frog is visibly
  LARGER overall than the Goblin Engineer standing right beside it, not just
  equal height. A frog bigger than a goblin, on the screen that's supposed to
  be the triumphant final shot of a run, is the kind of thing that reads as
  unfinished on sight, no code contradiction required.

**Why:** `combat_3d.gd`'s `_fit_height()` (line 1399) scales every hunter body
uniformly — `node.scale = Vector3.ONE * factor` — so that its height matches
the single constant `HUNTER_HEIGHT := 0.7` (line 125), called for each hunter
at line 2476. That comment at line 120 says the quiet part out loud: "Hunters
are the scale reference." Every hunter model, however short or squat its
source art, gets stretched until its head reaches the same fixed height. A
frog's real proportions (short legs, wide flat body, low-slung head) don't
change relative to itself under uniform scaling — but forcing a frog-shaped
body up to person-height makes it read as a person-sized frog, and because
the scale factor applies to width and depth too, it comes out visibly
chunkier than its human-shaped neighbors at the same height, exactly the trap
this brief's Pass D warns about ("every hunter is fitted to a common HEIGHT,
so a squat animal comes out enormous in WIDTH").

**Not fixed here** — `game/**` GDScript (`combat_3d.gd:125,1399,2476`),
outside this lane's job entirely under the new brief (this lane changes
nothing at all now, not just outside `tools/blender/**`/`game/assets/3d/**`).

**Checked, not chased further this pass:** the other four hunters
(Vine-Weaver, Mountain Climbers, Goblin Engineer, Lightbearer) are all
roughly human-shaped, so `HUNTER_HEIGHT` fitting doesn't visibly distort any
of them against each other — The Frog is the only one of the five with a body
plan far enough from human proportions to make the bug obvious to the eye.
Did not check Titan-vs-Titan proportion this pass (beasts are framed by
`_frame_beast()`'s window sizing, not scaled to a common height the way
hunters are, so the same trap may not apply there the same way — worth a
separate Pass D pass to confirm rather than assumed clean here).

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

## 2026-09-05 — right-click card inspector never opens; neither does its own left-click self-test

**Command:**
```
%GODOT% --path game --script res://tools/screenshot.gd -- ^
    out=C:\shot_inspect.png state=3dinspect slot=0 beast=thrasher
```

**What the harness printed:**
```
RIGHTCLICK opened_inspector=false  FAIL
KEYWORD panel=["Timed", "Play it on the sweeping bar. A dead-centre hit pays the bonus in full, catching  OK
LEFTCLICK body=false on_keyword=false  FAIL
```
The middle check (hovering a keyword, then right-clicking) passes — the
keyword-specific popup answers correctly once `_hover_meta` is faked to
`"kw:timed"`. Both of the checks either side of it fail: a right-click
anywhere else on the card body never sets `combat_3d._detail`, and the
follow-up left-click checks (`card._timing` after a body click, and after a
`RichTextLabel.meta_clicked` emit) never set `card._timing` either.

**What I saw in the PNG:** confirmed by eye — no inspector overlay is showing
in the frame at all; just the ordinary hand of five cards, matching
`opened_inspector=false`.

**Why it matters:** `card_view.gd:1600-1608` documents right-click as the
*accelerator* for the tap-driven "?" inspector button, added 2026-08-16 per
Nick ("I would like the ability to right click on things like keywords... For
example, poison. What does poison do?"), with the comment "The '?' button
stays: CLAUDE.md §5 keeps a tap path for everything... This is the
accelerator, not the only way in." The `?` button itself
(`card_view.gd:858`) is a separate code path from what this harness state
drives and isn't shown as failing here — so the tap-first, CLAUDE.md-compliant
path may still work — but the right-click accelerator that was built for it
does not, per the game's own functional self-check, not just my read of the
picture.

**Where to look:** `card_view.gd`'s `_on_card_input()` (~line 1609, connected
to `gui_input` at line 333-334) is wired alongside a second `gui_input`
listener the hand itself adds in `combat_3d.gd` (`_card_pressed`, line 2961,
which early-returns for anything but a left button press, so it shouldn't be
swallowing the right-click) — the fact that even the *keyword* branch works
but the *plain-card* branch (`inspect_requested.emit(_data)`, line 1624)
doesn't suggests the emit itself, or its `combat_3d.gd:2972` connection to
`_show_card_detail`, not the input routing. This is `game/**` GDScript,
outside `tools/blender/**` / `game/assets/3d/**`, so written up rather than
touched.

**Checked and clean, for the record:** `3devent` (a forced narrative event)
rendered correctly this run — both hunters, the hex-tile overworld geometry,
event title/body text and both choice buttons were all visible and legible,
no `VIS FAIL`.

## 2026-09-07 — picking a hunter never actually punches the camera in

**Command:**
```
%GODOT% --path game --script res://tools/screenshot.gd -- ^
    out=C:\shot.png state=3dfocus slot=0 beast=sky_snapper
```
(`sky_snapper` had no prior fixer pass or bug-hunt check on it; first time
this beast has been looked at in either lane)

**What the harness printed:**
```
CAM pos=(-5.016482, 1.310973, 21.867125) pivot=(-5.016482, 0.840000, 14.620000) dist=7.30 pitch=-0.120 h=-0.00 v=-0.51
FOCUS dist 7.3 -> 7.3 (in 100%) -> 7.3 after 90 frames | pivot x -5.02 -> 5.02  FAIL
FOCUS re-pick after flying off: dist 7.3, pan (0.0, 0.0, 0.0)  OK
```
The self-test wants `_switch_to` to punch the distance in to under half of
what it started at (`punched < before * 0.5`). Here it does not move at all —
`before`, `punched`, and `settled` are all exactly `7.3`. Only the pivot's `x`
moves (from the first hunter's position to the second's); nothing about the
zoom changes.

**What I saw in the PNG:** `state=3dsettings` on the same beast this run shows
the game's own help text for this feature: *"Picking a hunter puts the camera
back on them."* That is the punch-in the harness is checking for, and it is
documented player-facing behaviour, not an internal assumption of the test.

**Why it matters, and why it's probably the SAME bug as the very first entry
in this log:** `_focus_camera()` (`combat_3d.gd:788`) sets
`_dist = maxf(_dist_for_window(FOCUS_WINDOW), 2.6)` — a tight, single-hunter
framing. The self-test failing with a flat `7.3 -> 7.3` means that tight
distance is ALREADY what the fight settles to at combat start, for `slot=0`,
before anyone picks anything — there is no wider shot left to punch in FROM.
That is exactly the shape of the "ally hunter off-screen at the start of every
fight" bug logged above: the opening framing is computed as if only the
active hunter needs to fit in frame, so by the time `_switch_to` runs, the
camera has nowhere left to move. One root cause, two symptoms: the ally is
off-screen at rest, AND the explicit "put the camera back on them" gesture the
settings panel promises has no visible effect because it's already there.

**Where to look:** `_focus_camera()` (`combat_3d.gd:788`) and whatever feeds
`_working_dist` / `_dist_for_window` the framing box at combat start
(`combat_3d.gd:1375-1385`, `1510`) — the box that framing is computed against
needs to include both hunters' `home` positions, not just the active one, so
there is an actual wide-to-tight range for `_switch_to` to punch across. This
is `game/**` GDScript, outside `tools/blender/**` / `game/assets/3d/**`, so
written up rather than touched.

**Checked and clean, for the record, this run:** `3dwon` (full run-to-victory,
including `Hunt again` / `Return to menu`), `3dselect` (the five-hunter pick
screen — all five models sit evenly spaced with no overlap or clipping),
`3dswap`, `3drebind`, `3dsettings`, `3dsel`, `3dloop` (router walks
map -> combat -> reward -> map correctly), and `3dcross` (act-boundary framing
at row 5, `Act 2 of 4`) all printed clean harness lines with no new `FAIL`.
`3dswap`/`3drebind`/`3dsettings`/`3dsel` all still show the already-logged
`VIS FAIL hunter1` at combat start (same known cause above, not a new find).

## 2026-09-07 — reward screen's "picks:" prompt is drawn behind the reward cards in solo

**Command:**
```
%GODOT% --path game --script res://tools/screenshot.gd -- ^
    out=C:\shot.png state=3dreward slot=0 beast=mire_snapper
```
(`mire_snapper` had no prior fixer pass or bug-hunt check; reproduces
identically on `beast=thrasher`, so this is not beast-specific — see below)

**What the harness printed:** no dedicated harness line for this screen; this
is a looking-at-the-picture find, not a self-check failure.

**What I saw in the PNG:** the reward screen's status line reads "The Frog
picks:   Tap a card to select" (this run is in solo — one player controls
both hunters, hence the `%s picks:` prefix and the "▶ Switch to The Goblin
Engineer" button also visible), but almost the entire line is hidden behind
the three reward-card panels: only ragged fragments poke out above the cards'
top edge ("The Fro...", "...ki?", "Tap a card to...", a trailing "t"), nothing
readable as a full sentence. Confirmed twice, independently, on two different
beasts (`mire_snapper`, `thrasher`) — pixel-identical overlap in both, so this
is a layout bug, not a render fluke.

**Why:** `location_3d.gd:472-473` sets this text —
```gdscript
_prompt.text = "%sTap a %s to select" % [
    ("%s picks:   " % _hunter_name(_active_slot)) if solo else "", noun]
```
— on the `%Prompt` label, and `location_3d.tscn` anchors `Prompt` and `Row`
(the reward-card container) to the same bottom edge only 34px apart:
`Prompt` at `offset_top = -302.0` (location_3d.tscn:109), `Row` at
`offset_top = -268.0` (location_3d.tscn:129). In co-op, the un-prefixed
"Tap a card to select" fits in that headroom. In solo, the `"<hunter> picks:  "`
prefix this run adds is exactly what's missing from the frame — the label
still exists and still holds the right string (this isn't a logic bug, the
game knows what it wants to say), it is just being visually painted over by
the card row that starts almost immediately below it.

**Why it matters:** solo is a real, reachable mode (the "▶ Switch to X" button
exists specifically for it), and this is the line that tells a solo player
*which of their two hunters* is making the current pick — the one piece of
information this screen most needs to communicate in solo, on the only screen
mode where it's needed at all, unreadable every single time a beast falls.

**Where to look:** `location_3d.gd`'s `_render_reward()` (line 446, prompt set
at 472-473) and/or the `Prompt`/`Row` anchor offsets in `location_3d.tscn`
(109 and 129) — either give the solo prompt more clearance above the row, or
shrink/wrap it to fit the existing 34px gap. This is `game/**` GDScript (and
its `.tscn`), outside `tools/blender/**` / `game/assets/3d/**`, so written up
rather than touched.

## 2026-09-07 — hand of cards renders skewed and cut off during the grip minigame

**Command:**
```
%GODOT% --path game --script res://tools/screenshot.gd -- ^
    out=C:\shot.png state=3dgrip slot=0 beast=mire_snapper
```

**What the harness printed:** `GRIP OK: foothold 1 -> 0 after the timer
emptied` — the grip mechanic itself resolves correctly. No harness line
checks hand layout, so this is a looking-at-the-picture find.

**What I saw in the PNG:** the five-card hand, which sits flat and legible
along the bottom edge in every other state I checked (`3d`, `3dclimb`,
`3dstrike`), is instead drawn as a steep diagonal running from screen centre
up to the top-right, each card cut off mid-face by the screen edge, cost pips
and names sliding off at an angle rather than sitting in a gentle horizontal
fan. Reproduced identically across two independent runs on `mire_snapper`.

**Why this isn't just the normal fan tilt:** `combat_3d.gd`'s `_layout_hand()`
(line 2927) sets `c.rotation = off * FAN_TILT` with `FAN_TILT := 0.085`
(combat_3d.gd:2909) — at most ~2 cards off-centre, that's under 10° of tilt at
either end, which is exactly what the flat fan in `3d`/`3dclimb`/`3dstrike`
shows. What's on screen in `3dgrip` is a much steeper, one-directional skew
that per-card fan tilt alone doesn't account for. I checked `_layout_hand`,
the drag-roll code (`_aim_dragged`, line 3566, which only ever rotates the one
dragged card, and no drag is active in this state) and the `location_3d.tscn`
/ `combat_3d.tscn` node trees for a static rotation on `Hand`, `HandScroll`,
`Root`, or the `Hud` `CanvasLayer` — none carries one, so whatever is doing
this is applied at runtime and I could not pin down where.

**One correlating detail for whoever picks this up:** `3dgrip` is the only
state I checked where `%GripBar` is visible (`_update_grip_bar`,
combat_3d.gd:952, sets `_grip_bar.visible = not _climb.is_empty()`) at the same
time the hand is on screen — none of `3d`, `3dclimb`, or `3dstrike` show both
at once from what I captured. Worth checking whether GripBar becoming visible
changes the `Hand`/`HandScroll` container's available rect in a way that
`_layout_hand()`'s `room`/`step` math (combat_3d.gd:2938-2940) doesn't expect.

**Also noted, not chased down:** `state=3dgrip beast=thrasher` twice hit
`SHOT TIMEOUT` (the harness's 10-second wall-clock failsafe,
`screenshot.gd:1195-1198) instead of saving a PNG, even though the console
showed `GRIP OK` had already printed — i.e. the capture's own post-loop code
ran long enough to lose the race, on `thrasher` specifically, not on
`mire_snapper`. Might be the same underlying cost as the skew above (something
in the grip path doing more work than it should), might be unrelated machine
load. Flagging rather than claiming a connection.

**Where to look:** `combat_3d.gd`'s `_layout_hand()` (2927) and
`_update_grip_bar()` (952) interaction. This is `game/**` GDScript, outside
`tools/blender/**` / `game/assets/3d/**`, so written up rather than touched.
