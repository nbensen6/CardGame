## 3D combat view — the SAME authoritative snapshots, rendered in a 3D scene.
##
## This is CLAUDE.md §2's layering rule paying off: /core and /session don't know
## or care that the game became 3D. It began as a second client beside the 2D
## `combat_view.gd`, reading identical `shared`/`private` dicts; that one has
## since been retired, and this is the only fight screen.
##
## The climb stops being an abstraction here — Height IS vertical position on the
## beast's body, so a hunter at the weak point is literally up at the weak point.
##
## The models are static low-poly props, so everything that moves is procedural:
## breathing, idle sway, climb hops, recoil, flashes, camera shake. That reads far
## better than static toys and costs no animation budget.
extends Node3D

const CAST := "res://assets/3d/cast/"
## The stylized creature shader every beast and hunter renders through. See
## _shade_model, and game/assets/3d/creature.gdshader for what it does and why
## each part of it is safe on the gl_compatibility renderer.
const CREATURE := preload("res://assets/3d/creature.gdshader")
# Graphics spike, 2026-09-22: a toon ramp + inverted-hull outline for models
# that carry their own painted texture (AI image-to-3D, asset packs). Off unless
# the harness asks — see screenshot.gd variant= / toon.
const TOON := preload("res://assets/3d/toon.gdshader")
const OUTLINE := preload("res://assets/3d/outline.gdshader")
## Faceted rock detail for the floating footholds (_build_float_stones) — a
## generated (not modelled) grayscale multiply so a stone reads as cut rock
## instead of one flat colour. See design/progress/foothold_rock_detail.md.
const ROCK_DETAIL := preload("res://assets/3d/rock_detail.png")
## The floating foothold's body mesh — an irregular convex-hull rock with a
## flat landing face, replacing the old SphereMesh (#17: "the current sphere
## reads as a pot; this reads as rock"). See design/progress/foothold_rock.md.
## Geometry only, no material/colour of its own — _build_float_stones keeps
## applying the #12 palette and ROCK_DETAIL via material_override at runtime.
const FOOTHOLD_ROCK := preload("res://assets/3d/env/foothold_rock.glb")
## Beasts that have been rebuilt from AI image/text-to-3D (design/ai-beast-
## recipe.md). They load <id><suffix>.glb and shade with TOON. Kept beside the
## Python-built model rather than over it, so `build.cmd cast` can never
## silently put the old one back.
const AI_ART := {"cinder_jackal": "_ai"}
## Hunters rebuilt the same way (design/guide/ai-beast-recipe.md), the parallel table
## the 2026-09-23 hunter-display-path request asked for: a character id listed
## here loads <id><suffix>.glb over cast/<id>.glb (Cast.model_path's own
## stand-in rule still applies first — see _spawn_hunter) and takes the same
## toon-shaded, rigged path AI_ART beasts do, instead of the plain CREATURE
## shader the Python-primitive hunters render with. Kept separate from AI_ART
## rather than merged into it: AI_ART's own doc comment and every reader of it
## (_show_beast, location_3d.gd's felled-beast lookup) means "beast", and nothing
## here changes that. Empty until an artist ships a rigged hunter .glb.
const HUNTER_AI_ART := {"frog": "_ai", "goblin_mech": "_ai"}
## outline.gdshader draws one fixed screen-space line weight on every model,
## tuned against thick rounded masses (the jackal, the Frog). A HUNTER_AI_ART
## model built from many thin parts (straps, tank fittings, limb segments)
## gets that same-width stroke on each one, and at hunter scale the strokes
## overlap and eat the model — measured on goblin_mech_ai: mean luminance
## 80.1 against the Frog's shipped 156.5, isolated to the outline pass, not
## the texture (design/progress/goblin_mech_ai.md). A multiplier here, not a
## second shader, keeps the jackal and the already-shipped Frog untouched —
## both stay at implicit 1.0 (outline.gdshader's own uniform default) unless
## given an entry. 0.33 matches the manual test that diagnosed this
## (0.0015 against the shader's 0.0045 default); re-verified in the real
## fight camera, not just carried over from that note.
const OUTLINE_WIDTH_SCALE := {"goblin_mech": 0.33}
## Grounds rebuilt with a generated wall instead of env.py's primitive
## enclose() (Nick, 2026-09-23, answering the arena-wall-accent request:
## "the environment needs a rehaul. use meshy to create an environment to
## replace the one created in blender."). Same shape as AI_ART/HUNTER_AI_ART:
## a beast id listed here loads env/<id><suffix>.glb over env/<id>.glb, so the
## old procedural ground stays on disk untouched and reverting is one entry.
## See tools/blender/ai/cinder_jackal_env_ai.py.
const ENV_AI_ART := {"cinder_jackal": "_ai"}
## Idle life for those beasts, in the toon shader (no rig yet). Uniform names
## from toon.gdshader; the masks default to the jackal's tail. Kept small: the
## body moves under hunters standing on it, and 2.5cm of breath on a Titan
## reads as alive without anyone's feet visibly lifting off the footholds.
const AI_MOTION := {
	# Rigged (2026-09-22): tail and breath are bone animation now, so the
	# shader only keeps the ember pulse.
	# glow_gain down from 1.2: the Meshy jackal paints its inner ears the same
	# hot orange as its markings, and at full gain they read as two flames.
	"cinder_jackal": {"glow_pulse": 0.25, "glow_gain": 0.55},
}
## Harness switches. `model_variant` loads <beast><variant>.glb when it exists
## (e.g. "_ai"); `toon` shades the beast with TOON instead of CREATURE.
## `classic` forces the old Python-built model, for before/after shots.
static var model_variant := ""
static var toon := false
static var classic := false
var _beast_toon := false
## The beast's own AnimationPlayer, when its model is rigged (AI_ART beasts).
## Plays "idle" on a loop; "attack" and "hit" are one-shots that fall back to it.
var _beast_anim: AnimationPlayer = null

## Jump-point rings. Dim for "you could stand here", warm for the next rung up.
## Both deliberately low-alpha: these sit on the beast all fight, and a marker
## that competes with the beast is worse than no marker.
const LEDGE_COLOR := Color(0.78, 0.84, 0.96, 0.55)
const LEDGE_NEXT := Color(1.0, 0.84, 0.38, 0.95)

## Which palette swatches GLOW, per beast.
##
## Mirrors kenney.swatch(px, py) == (px/512, 1 - (py+16)/512), so a name here is
## the same cell the Blender script painted with. Keyed by swatch rather than by
## colour because a colour key cannot tell the jackal's TANGERINE spine ridge
## from its RUST body.
##
## Nick, 2026-09-08, on the Sea of Thieves megalodon: its whole design hangs off
## white-hot cracks against a near-black body, and measured, only 2.5% of our
## jackal sat above 80% luminance with nothing telling the eye where to look.
## cinder_jackal.py already asks for this in words — "a low ember-coloured ridge
## down the spine, the smouldering-not-yet-on-fire read" — and rendered none.
const SWATCH_TANGERINE := Vector2(48.0 / 512.0, 1.0 - 208.0 / 512.0)
const SWATCH_AMBER := Vector2(496.0 / 512.0, 1.0 - 336.0 / 512.0)
const EMBERS := {
	"cinder_jackal": [SWATCH_TANGERINE, SWATCH_AMBER],   # spine ridge, eyes
}

## Per-beast value range (BUILDER-QUEUE.md item 1): darkens the lit body and
## lifts the ember gain in the same change, so the gap to the reference opens
## from both ends. Both are uniforms on creature.gdshader that default to a
## no-op (body_gain 1.0, the shader's own ember_gain 2.6); a beast only
## renders differently once it has an entry here. A swatch swap was tried
## first and could not move the top of the range at all — see
## design/plan/BUILDER-QUEUE.md for the measurement.
const VALUE_RANGE := {
	"cinder_jackal": {"body_gain": 0.55, "ember_gain": 4.5},
}
const ENV := "res://assets/3d/env/"
## Every environment is built to this floor radius — see tools/blender/env.py.
const ENV_RADIUS := 6.0
## Which model plays each BEAST, until real art exists. Hunters are not in here:
## they come from ui/cast.gd, which prefers your own art, and keeping a second
## copy of that mapping is what kept the Frog looking like a bunny on the
## character select long after frog.glb existed.
const MODELS := {
	# every beast gets its OWN body — the map's variety is pointless if ten of
	# the fourteen fights look like the same elephant. Chosen to echo the 2D
	# portrait where a Cube Pet exists, and to never reuse a hunter's model.
	"stone_warden": "elephant", "gale_serpent": "caterpillar",
	"drowned_colossus": "polar", "sunken_warden": "lion",
	"crag_pup": "dog", "bramble_hog": "pig", "bounder": "fox",
	"root_lurker": "beaver", "sky_snapper": "parrot", "riftling": "cat",
	"mire_snapper": "crab", "frost_sentinel": "penguin",
	"grove_bear": "panda", "shifting_idol": "tiger",
}
## Models are sized to a TARGET WORLD HEIGHT, measured off each mesh, never by a
## fixed multiplier. Two reasons. The Cube Pets already vary 1.55-2.13 units
## tall, so one multiplier made the two hunters differ by ~24% for no reason.
## And it means a model built in Blender at any scale drops straight in — the
## art pipeline shouldn't require matching someone else's units.
##
## A beast's height comes from how far you climb it, so a Titan with its sigil at
## Height 8 physically towers over a Crag Pup you can hit from the ground.
##
## Far bigger than they were (Nick, 2026-08-06: "much bigger, to feel like you are
## climbing something massive"). A Titan is ~17 hunters tall now instead of ~6 —
## the difference between a large animal and a colossus.
##
## Scale ALONE would have changed nothing, which is the part worth remembering:
## the camera used to fit the whole body in frame, so doubling a beast's size just
## pushed the camera twice as far back and looked identical. A shot that always
## contains the whole creature is a shot that says "toy on a table". See
## VIEW_WINDOW_* — the camera now shows a fixed slice of world, and a big beast
## simply overflows it.
## Beasts should read as COLOSSAL, not merely big (Nick, 2026-08-15). Raised from
## 4.0 / 1.2 — a final Titan now stands ~16 units rather than ~11, and the camera
## framing below follows the beast's measured height so it pulls back to suit.
## Retuned 2026-08-16 alongside the deeper climbs. Sigils moved from 1-8 to 4-13,
## and at the old 2.8-per-Height a Titan would have stood 46 units — half again
## the size Nick signed off on. Raising the base and flattening the slope keeps
## the biggest beast at the ~33 units that already read as colossal, while every
## lesser beast grows: the shallowest is now 18 units rather than 13, so nothing
## in the game reads as small any more.
const BEAST_BASE_HEIGHT := 12.0
const BEAST_HEIGHT_PER_CLIMB := 1.6
## How much vertical world the camera frames, in units — the constant that makes
## size legible. A beast shorter than this fits with air around it; a Titan runs
## off the top of the screen and you only ever see the stretch you're climbing.
## The vertical slice of world the camera tries to hold. Widened (Nick,
## 2026-08-15: "camera should start zoomed out more") — and it has to grow anyway
## now the beasts are half again as tall.
const VIEW_WINDOW_MIN := 9.0
const VIEW_WINDOW_MAX := 28.0
## How far the camera slides toward the hunter you are HOLDING, as a fraction of
## their offset from the beast's axis (Nick, 2026-08-23: the shot is too centred,
## and switching hunter should show you who you now control).
##
## Now 1.0 — a real lock rather than a lean (Nick, 2026-08-24: "make sure the
## camera locks on to a character when you select it"). The earlier 0.55 hedged
## against shoving the beast out of frame, but the hunters sit only a fifth of the
## body's width off its spine, so a full lock slides the shot about 8% of a frame:
## plainly "this one is mine", nowhere near enough to lose the body.
##
## The lock is also what makes free look survivable. The camera orbits AROUND the
## hunter you hold, so dragging changes your angle ON them instead of wandering
## off them.
const CAMERA_LOCK := 1.0

## The bottom strip the hand now occupies. The camera frames into what is LEFT of
## the screen and lifts its aim to match, so the beast stands in clear air instead
## of behind the cards. Without this, moving the hand to the bottom simply hid the
## lower third of every beast.
const HUD_BOTTOM_FRACTION := 0.34
## Real-time grip (SotC), the same client-side skill layer the 2D view runs: the
## instant a hunter leaves a safe hold a timer starts full and drains live; reach
## the next ledge before it empties or this client reports a fall. The host is
## told the OUTCOME, never the ticking timer.
const GRIP_SECONDS := 5.0
## Hunters are the scale reference — a beast only looks colossal NEXT TO something.
## Dropped from 0.8 (Nick, 2026-08-15: "beasts much bigger than the hunters"), which
## widens the ratio from both ends at once: a lesser beast is now ~22x a hunter and a
## Titan ~38x, where before it was 14x and 24x. Lowering this is cheaper than raising
## the beasts alone, because it costs no extra camera pull-back.
const HUNTER_HEIGHT := 0.7
## Orbit camera (Nick's call, 2026-08-05). The beast is a PLACE, so you can walk
## the camera around it. Auto-framing still sets the opening shot off the model's
## own size; dragging only takes over from there, and never below the ground or
## over the top.
const ORBIT_PITCH_MIN := -0.12   # radians below level — never under the floor
const ORBIT_PITCH_MAX := 1.32    # nearly overhead, but never gimbal-locked
const ORBIT_SENSITIVITY := 0.006
## Damping for the DEV free camera only (drag/wheel — see _unhandled_input and
## _aim_camera's _free_cam_engaged block). Same 1-exp(-delta*k) shape the follow
## camera already uses on _pivot/_dist; at a real 60fps frame (~0.017s) that's
## ~63% closed on the first frame and ~99% by five, tens of milliseconds — well
## under Nick's own "under half a second" (2026-09-25). Tuned this high (not a
## gentler k~8-25) because this sandbox's own xvfb+software-GL render is far
## slower than 60fps (~0.1s/frame measured) and screenshot.gd's own 3dfreecam
## sweep checks each screen spot within a handful of such frames — a gentler
## constant settles fine in real play but leaves enough of a tail in THIS
## sandbox that the next spot's check reads a stale drag as "still moving."
const FREE_CAM_EASE := 60.0
## Below this remaining gap, snap instead of lerping: an un-snapped exponential
## never actually reaches its target, and "no drift after the hand comes off"
## needs the chase to actually stop, not just shrink forever.
const FREE_CAM_SETTLE := 0.0005
const PAN_SENSITIVITY := 0.0018   # world units per pixel, per unit of distance
## WASD fly speed, in world units per second per unit of camera distance. Scaled
## by distance because a step that reads as a step next to a Crag Pup is a
## twitch next to a Titan, and the camera is 40 units out there.
const FLY_SPEED := 0.34
## World-units of height the camera holds around a hunter you have picked.
##
## An ABSOLUTE window, not a fraction of the working shot, and this is the whole
## fix: a fraction of a Titan's framing is still a Titan's distance away, so on a
## big beast "52% closer" left the hunter a speck (Nick, 2026-08-24: "still
## doesnt centar closely"). Four units is about six hunter-heights, so a hunter
## reads at roughly a fifth of the frame whatever they are standing on.
##
## Sliding the frame across was not enough, and measuring it proved why rather
## than disproving it: the lock does put the hunter dead centre, but on the
## ground a hunter is about 4% of the frame's height beside a beast that fills
## it, so a lateral slide of a sixth of a frame is a change nobody can see
## (Nick, 2026-08-24: "it still doesnt feel like ... it centers the camera on
## them"). So the camera CUTS to an absolute window around the hunter and holds
## there — a cut is the one move the eye cannot miss, and holding is what makes
## it a lock rather than a flourish.
##
## 6.5 units, about nine hunter-heights. A first pass at 4 was close enough to
## lose the fight around them (Nick: "zoom the camera out a bit"); at 6.5 the
## hunter still plainly owns the frame and you can see what they are standing on.
const FOCUS_WINDOW := 6.5

## The DEFAULT third-person shot, as opposed to the deliberate hold above.
##
## Nick, 2026-09-09: "make the camera mainly 3rd person." Reusing FOCUS_WINDOW
## for that was wrong and looked it — at 6.5 the Frog filled the middle of the
## screen at ground level and the beast was three legs and a shadow off the top
## edge, which is a close-up, not a third-person camera. A third-person shot has
## to hold BOTH the hunter and the thing they are climbing.
##
## 15 units: the hunter still reads clearly at the bottom of the frame and the
## beast owns the rest of it, which is the composition the whole fight is about.
const THIRD_WINDOW := 8.0     # world units tall. 15 left a hunter 4% of the frame — a wide shot, not third person (Nick, 2026-09-23).
## Over the shoulder, at rest as well as mid-jump.
##
## Nick, 2026-09-23: "make the resting camera third person too." THIRD_WINDOW
## already held the hunter and the beast in one frame, but the lens sat dead
## behind the hunter and aimed AT them, so the hunter was a centred dot with the
## beast behind their head — a follow cam, not an over-the-shoulder shot. Every
## third-person game that frames a fight (RE4 onward, Gears, TLOU) does two
## things this did not: it trucks the lens off the subject's spine, and it aims
## past them at what they are fighting. The subject then sits in a third of the
## frame, in the foreground, with the target clear over the shoulder.
##
## Both are in world units per unit of camera distance, so the shot holds its
## composition at every zoom — a fixed world-unit offset would centre the hunter
## when zoomed out and shove them off the edge when zoomed in.
##
## TRUCK moves the LENS off the hunter's spine. That is the parallax alone: it
## is what lets you see the beast past the hunter instead of through them, and
## on its own it does not move the hunter in frame at all.
const SHOULDER_TRUCK := 0.15
## AIM moves what the lens LOOKS AT, sideways. This is the one that composes the
## shot: the hunter's offset from the centre of the frame works out to exactly
## AIM, whatever TRUCK does. At fov 48 on 16:9 a frame is ~1.58 * distance wide,
## so 0.26 puts the hunter a third of the way in from the left edge.
##
## Sideways only — never toward the beast. Sliding the aim INTO the scene changes
## the camera's pitch as well as its yaw, which dropped the hunter from y=507 to
## y=602 on a 720 frame, behind the card strip (measured, first attempt at this).
## The vertical belongs to the jump's hold and dead zone; this must not touch it.
const SHOULDER_AIM := 0.26
const ZOOM_STEP := 0.12
## Sideways truck, in world units per unit of camera distance, that pushes the
## beast right so it centres in the space left of the HUD rather than on the
## screen. The rail claims ~300 of 1280px, so the free middle is ~11% right of
## centre; at fov 48 on 16:9 a frame width is ~1.58 * distance, so 0.11 of a frame
## costs ~0.17 per unit of distance.
##
## Now 0. This compensated for a hand RAIL down the left edge, and the cards moved
## to the bottom on 2026-08-15 — so for a week the camera has been trucking
## sideways to dodge a UI element that no longer exists, which is most of why the
## shot read as subtly off (Nick, 2026-08-23). The left is now the party panel and
## the right is the climb gauge, which balance each other, so the scene's centre
## and the screen's centre are the same place again.
##
## Kept as a constant rather than deleted: if a future layout claims one edge
## again, this is the knob, and the derivation above is the reason it is 0.09-ish
## rather than arbitrary.
const SCENE_SHIFT := 0.0
## Downward lens shift per unit of distance while a hunter is on the ground, which
## lifts the whole shot so tiny hunters at a Titan's feet aren't pressed into the
## bottom edge. See _apply_orbit for why this can't be done by moving the pivot.
const GROUND_LIFT := 0.07
## Lowest the camera may sit, in world units. Below this it is under the ground
## plane and the shot looks up through the floor.
const CAMERA_FLOOR := 0.8
## The furthest the camera may get from the middle of the arena, in floor radii.
##
## Must stay under env.ENCLOSE_CLEAR (2.55), which is the radius env.py
## guarantees it builds no wall inside of. Those two numbers are one feature in
## two files and this comment is the seam.
##
## Nick, 2026-08-31: "make sure the camera doesnt collide with the environment."
## It did. The wall ring sat at 2.90 R with pieces jittered inward and up to
## 0.58 R wide, so its innermost face was at 2.15 R while this clamp allowed
## 2.46 R — four world units of rock in the same place as the lens. env.py now
## guarantees a clear 2.55 and jitters pieces outward only; 2.40 sits inside
## that with room, and still clears the ~30 units of standoff a Titan needs to
## frame (the smallest arena is 12.9 across, and 12.9 * 2.40 = 31.0).
const CAMERA_MAX_R := 2.40
## How far behind the hunters the camera sits when they are on the ground, in
## hunter-heights. Nick: "move the characters back away from the beast so we can
## place the camera just behind them" — this is the "just behind" number.
const OVER_SHOULDER := 4.2
## How far in FRONT of the beast the hunters stand on the ground, as a fraction
## of the beast's own front-edge distance from the arena's centre (see
## ground_standoff_for). They used to stand at 0.9 of its front face, which is
## close enough to touch it and left nowhere to put a camera except further out
## than the whole arena.
## How far the hunters stand off the beast's front face, as a fraction of its
## own depth. Was 0.62, which put them under its chin -- Nick, 2026-09-24:
## "there is just not enough space between the characters and the beast."
## His reference has a wide stretch of empty ground between the two, and the
## stone path crosses it.
const GROUND_STANDOFF := 4.2
## How far LEFT of the top hold's own x the nearest approach stone starts
## (route_pos) -- the lateral half of Nick's diagonal sweep (#14, live,
## 2026-09-24 22:25 EDT). Sized off the HUNTER, like every other stone
## dimension here, not the beast's own width.
##
## 2026-09-25 02:00 (director, near-stone-hides-beast-from-chest-to-paws, not
## yet mirrored to a ticket number): at 3.0 the sweep cleared the "stacked"
## complaint but left the near stone's own near-camera closeness fully
## revealed for the first time -- it covered the beast from chest to paws,
## worse than the original stacked-pot look, because nothing was hiding it any
## more. Widened to 6.5: rendered 3.0/3.5/4.0/4.5/5.0/5.5/6.0/7.0 (and, again,
## the full beast-width offset `_beast_box.size.x * 0.5` = 5.4) and looked at
## each one at 1:1 -- 4.0 still grazed the front leg, 6.0 already pushes the
## stone half off the LEFT edge of a 1280-wide frame, and the full beast-width
## offset stretches it into the exact "clay pot" silhouette #16 already fixed
## once. 6.5 is the smallest width in that sweep with the near stone fully
## clear of the beast's ears-to-paws rect (confirmed both by eye and by a
## pixel diff against a stones-disabled render) while still reading as one
## rock, not a bucket, and still fully on screen.
const STONE_SWEEP_WIDTH := HUNTER_HEIGHT * 6.5
## The camera's fixed standoff behind the active hunter, in world units --
## at rest AND mid-climb alike (Nick, 2026-09-25, two drawings: "zoom out" at
## rest; "camera closer, should be locked to character" mid-climb). One
## number for both is the point: the old resting value (3.0) sat right on
## the near stone, and the old climbing shot instead re-fit a window around
## the BEAST's own height (_dist_for_window(want.y)), which on a tall beast
## pulled the lens back until the hunter was a speck on its chest -- locked
## to the beast, not to the hunter it was supposed to follow. A hunter who
## reads the same size on the ground and three storeys up IS "locked to the
## character." See the long note at its use in _aim_camera.
const ACTIVE_HUNTER_DIST := 6.0
const GROUND_VIEW_EYE := 1.05
const GROUND_VIEW_PITCH := 0.08
## How long a coach hint stays up before dismissing itself. Long enough to read
## twice, short enough that it never becomes a thing you have to click away
## (Nick, 2026-08-06: the tips are annoying). Acting also dismisses it — if you
## already know what to do, the lesson has served its purpose.
const COACH_SECONDS := 7.0
## The two hunters are told apart by COLOUR, everywhere it matters: the pip
## floating over their model in the scene, the frame around the portrait in the
## rail, their party card. One source so those can never drift apart — the whole
## point is that the green frame and the green pip are obviously the same hunter.
const SLOT_TINT := [Color(0.45, 0.95, 0.5), Color(0.55, 0.82, 1.0)]

var _client: GameClient
var _beast: Node3D
var _env: Node3D
var _beast_id := ""
## The boss's own data id, as passed to _show_beast — kept separate from
## `_beast_id` (the resolved MODEL key, which several beasts can share via
## fallback art) so a rebuild is gated on "is this actually a different
## beast" rather than on the render height derived from it. backlog #86
## duty 2: shift_sigil (Combat._enemy_turn) moves boss.weak_point_height
## mid-fight, and _show_beast used to re-derive its target height from that
## live value on every refresh — so the moment a boss with a shift_sigil
## move (several in bosses.json) used it, the guard below saw a changed
## height, and the "first spawn" path ran again in full: the beast was
## freed and reloaded, the hull/ledges/environment rebuilt, and
## _frame_beast() reset the camera to the wide establishing shot, mid-fight,
## for a beast that never actually changed.
var _beast_boss_id := ""
var _beast_box := AABB(Vector3(-1, 0, -1), Vector3(2, 2, 2))
## Height -> where a hunter at that Height actually stands, in rig space.
##
## Read out of the model. tools/blender/beast.py drops an empty called
## `climb_<Height>` on every ledge and on the sigil, glTF carries empties
## through as plain nodes, so the route ships WITH the art: move a shoulder in
## Blender and the hunter standing on it moves too.
##
## Empty means an older model with no anchors, and the bounding-box fallback
## below takes over — which is what every beast used to do, and why hunters
## hovered in FRONT of a body instead of standing on the shelves it already had.
var _climb_points: Dictionary = {}
## The subset of Heights that have real flat footing under them — a shelf the
## model actually builds, not just a spot on the skin. Hunters JUMP between
## these; the rest are places they can be, not places they land.
var _ledges: Dictionary = {}
## The Heights /core actually treats as safe rest stops (Boss.ledges, the same
## data is_secure()/next_safe_height() read) — NOT the same set as `_ledges`
## above, which is purely "does the model have a shelf here" with zero
## connection to the fight's own safety data. #86 duty 2 (two copies of one
## truth): a beast's Blender export can name a "ledge_N" empty at a Height
## bosses.json never lists as safe (verified directly against shipped .glb
## node names — mire_snapper's model carries ledge_0/1/2/3/5/6 while its
## `ledges` array is only `[3]`; husk_beetle, gale_serpent and stone_warden
## all diverge the same way), and `_ledges` used to be the ONLY thing deciding
## which Heights got a glowing "safe" ring drawn on the beast. A hunter could
## see a lit ring at a Height where is_secure() returns false and their grip
## timer keeps draining regardless. Set from the snapshot each `_refresh()`.
var _safe_ledges: Array = []
## One ring per LEDGE, drawn on the beast where a hunter can actually land.
##
## Nick, 2026-09-08: "having clear jump points for characters to jump to." The
## data was already there and nothing drew it — `_ledges` has been the subset of
## Heights with real footing since it was written, and the only way to find out
## where you could go was to try.
var _ledge_marks: Dictionary = {}
## The live climb tween per hunter slot, so a new one can cancel the old.
## Without this two tweens drive the same node at once and the hunter is dragged
## between two disagreeing positions — Nick, 2026-08-31: "not quite a smooth
## animation, it jumps to random places".
var _climb_tw: Dictionary = {}
## The card under the pointer, lifted out of the fan.
var _hand_hover: Control = null
## The card actively running the sweep-bar timing minigame, lifted out of the
## fan the same way hover does — see card_is_raised(). A handheld tap never
## fires mouse_entered, so without this a touch player starting a timed card's
## sweep never sees the strip at all (bugs.md Finding 3, 2026-09-08).
var _timing_card: CardView = null
## How big the pulsing marker is. It used to be a fixed 1.0, which was tuned
## when it hung above the body at 88% of the bounding box and was mostly seen
## edge-on. Now it sits ON the mark the model wears, at eye level, where a fixed
## size swallowed a small beast's whole head — so it scales with the body.
var _sigil_scale := 1.0
var _beast_scale := 1.0
## The floating stepping stones and where each one hangs at rest.
var _float_stones: Array = []
var _float_home: Array = []
var _beast_height := 0.0
var _hunters: Array = []          # slot -> {node, home}
var _active_slot := 0

# --- feel state ---
var _shake := 0.0                 # camera shake energy, decays each frame
var _cam_home := Vector3.ZERO
# --- orbit state ---
var _yaw := 0.0
var _pitch := 0.26
var _dist := 12.0
var _pivot := Vector3(0, 2.0, 0)
var _dragging := false
var _pivot_target := Vector3(0, 2.0, 0)  # where the camera is drifting its aim to
var _user_framed := false   # the player has dragged/zoomed — stop auto-pitching
# Dev free camera (drag/wheel/WASD) only — see _unhandled_input, _take_manual_control
# and _aim_camera. _unhandled_input writes the *_target values; _aim_camera is the
# only place that actually moves _yaw/_pitch/_dist, chasing the targets with
# FREE_CAM_EASE so a drag settles instead of snapping. _free_cam_engaged is true only
# once a drag/wheel/WASD event has fired — it is what tells this apart from
# _focus_camera's own _user_framed=true (the locked player camera mid-climb), which
# must keep moving _pitch/_dist directly, unchased, exactly as before.
var _yaw_target := 0.0
var _pitch_target := 0.26
var _free_dist_target := 12.0
var _free_cam_engaged := false
var _lock_slot := 0         # the hunter the camera is locked onto (CAMERA_LOCK)
var _circle: HitCircle      # the osu-style timing face, when that setting is on
var _circle_index := -1     # the hand index whose window the circle is holding open
var _focused := false       # the camera is held close on the hunter you picked
## How much of the over-the-shoulder truck is applied, 0..1, eased rather than
## switched: the shot has to give it up for the establishing wide and for a jump
## whose whole arc has to fit, and a hard cut between the two reads as a pop.
var _shoulder := 0.0
## Third person is the DEFAULT now, not a thing you opt into by clicking a
## hunter. Set when a fight opens; cleared the moment the shot actually settles
## onto someone, or the moment the player takes the camera themselves.
var _want_third := false
## How far above the hunter the focused shot aims, in world units. Held as state
## rather than passed once, because _aim_camera recomputes _pivot_target from
## the hunter's height EVERY frame — a lift applied only in _focus_camera was
## silently undone on the next one, and the shot looked identical to not having
## done it at all.
var _focus_lift := 0.0
## Jump framing: whether this hop has already left the camera's dead zone (so
## the follow stiffens), and how far past it the hunter got (so the shot widens).
var _air_chase := false
var _air_span := 0.0
var _air_settle := 0.0
## The world-height band one jump covers, set when the hop starts so the
## camera can frame the whole arc as a single shot.
var _jump_lo := 0.0
var _jump_hi := 0.0
## Free offset from whatever the camera is locked to. Orbiting alone can only
## ever look AT the subject from a new angle; panning is what lets you go and
## look at something else, which is the difference between an orbit and a free
## camera. Cleared whenever you select a hunter, so picking one is also how you
## get back — no "reset camera" button to find.
var _pan := Vector3.ZERO
var _panning := false
var _establishing := false  # easing from the opening wide shot into the working one
var _working_dist := 12.0   # the shot the establishing pull-in settles at
## The floor radius of the arena the current beast stands in — the same number
## _show_env scales the environment by. The camera clamp is measured off this,
## so it has to be remembered rather than recomputed from the beast box, which
## is not the same thing for a long low creature.
var _arena_r := 12.0
## The biome name the light rig is currently set to, for the dev overlay.
var _dev_biome := "crag"
## 0 while everyone is on the ground, ->1 as the hunter you're playing ascends.
## Derived from the HUNTERS, never from the camera's own height: the two come
## apart whenever the shot aims high at a small beast, and reading it off the
## pivot silently switched the ground lens shift off in exactly that case.
var _climb_t := 0.0
var _beast_punch := 0.0           # recoil when the beast is struck
var _time := 0.0
## backlog #86 duty 2: two damage popups spawned close together (a weak-point
## hit and the hunter's own hit on the same swing) used to land on top of each
## other at Titan scale -- see popup_offset() below. _last_popup_guard counts
## down each frame; while it's positive, the popup it was set for is still
## fresh enough on screen that a new one has to steer clear of it.
var _last_popup_at := Vector3.ZERO
var _last_popup_guard := 0.0
const POPUP_OVERLAP_WINDOW := 0.5  # seconds a popup counts as "still there" for the next one to avoid
const POPUP_TOP_PAD := 30.0  # px kept clear at the top of frame -- see popup_rise_scale
# snapshot deltas drive the juice, exactly like the 2D view
var _prev_hp := -1
var _prev_foot: Array = []
var _prev_reached: Array = []
var _prev_php: Array = []   # per-hunter hp last frame, so a hit on YOU pops a number too
var _detail: ColorRect = null   # the card inspector overlay, when one is open
## The climb gauge on the right edge, and the snapshot it draws from.
var _gauge: Control = null
var _gauge_data := {}
## The move type currently telegraphed, so right-clicking the tag can explain it.
var _intent_kind := ""
## The keybind action waiting for a key press, or "" when nothing is rebinding.
var _rebinding := ""
var _rebind_btns := {}          # action id → the button showing its key
var _prev_encounter := -1
# slot -> {g: remaining 0..1, target: the Height that ends the climb}. Solo
# tracks BOTH hunters, since you can switch while a timer runs.
var _climb: Dictionary = {}
# Card selection (Burn Coal / Catapult / Meld): tapping a selection card starts a
# local pick flow, and the chosen hand indices are bundled into ONE play_card.
# Empty = idle. Without this, those cards simply can't be played.
var _selecting: Dictionary = {}
var _coach_id := ""   # the onboarding hint currently on screen
var _coach_left := 0.0  # seconds before it dismisses itself
var _log_expanded := false

@onready var _rig: Node3D = %BeastRig
@onready var _cam: Camera3D = %Camera
@onready var _flash: OmniLight3D = %Flash
@onready var _dust: CPUParticles3D = %Dust
@onready var _sigil: Node3D = %Sigil
@onready var _hud: Control = %Root
@onready var _title: Label = %Title
@onready var _hp: Label = %HpLabel
@onready var _hp_bar: ProgressBar = %HpBar
## RichTextLabel, not Label: the move's NAME is a keyword, and a keyword has to
## be able to wear an underline and carry the id a right-click looks up.
@onready var _intent: RichTextLabel = %Intent
@onready var _intent_tag: PanelContainer = %IntentTag
@onready var _hand_row: Control = %Hand
@onready var _status: Label = %StatusLabel
@onready var _energy_orb: PanelContainer = %EnergyOrb
@onready var _energy_label: Label = %EnergyLabel
@onready var _piles: Label = %Piles
@onready var _end_btn: Button = %EndTurn
@onready var _switch_btn: Button = %SwitchBtn
@onready var _grip_bar: PanelContainer = %GripBar
@onready var _grip_label: Label = %GripLabel
@onready var _grip_meter: ProgressBar = %GripMeter
@onready var _party: VBoxContainer = %Party
@onready var _run_label: Label = %RunLabel
@onready var _coach: PanelContainer = %Coach
@onready var _coach_text: Label = %CoachText
@onready var _coach_ok: Button = %CoachOk
@onready var _coach_off: Button = %CoachOff
@onready var _menu_btn: Button = %MenuBtn
@onready var _log_label: Label = %LogLabel
@onready var _log_toggle: Button = %LogToggle
@onready var _log_panel: PanelContainer = %LogPanel


## Let a camera drag pass through a whole subtree.
##
## Setting mouse_filter on a container does nothing for its children, and a
## child that is a plain Control still defaults to STOP — which is why marking
## the top bar IGNORE in the scene left it a dead strip anyway. Walking the
## subtree also means a label added there later cannot quietly reintroduce one.
static func _let_drags_through(root: Node) -> void:
	if root == null:
		return
	if root is Control:
		(root as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in root.get_children():
		_let_drags_through(child)


## Hud/Root children with nothing to click on them — a camera drag anywhere
## over their rect should reach the camera, not stop dead.
##
## HandScroll belongs here for the same reason TopBar does, but it took
## longer to notice: _layout_hand() tucks a resting card FAN_TUCK+52 (~78px)
## below the top of HandScroll's own rect on desktop, so that strip renders as
## bare ground between the party panel and the boss — yet %Hand only carries
## MOUSE_FILTER_IGNORE on itself, never on HandScroll, the ScrollContainer
## that actually owns the taller rect and still defaulted to STOP. Individual
## cards are unaffected: each CardView sets its own mouse_filter back to STOP
## when it is added, after this subtree walk has already run once in _ready().
const DRAG_THROUGH_PATHS := ["TopBar", "HandScroll"]


func _ready() -> void:
	Screen.fit(self)   # a phone gets a physically larger interface
	for path in DRAG_THROUGH_PATHS:
		_let_drags_through(get_node_or_null("Hud/Root/%s" % path))
	_circle = HitCircle.new()
	_circle.name = "HitCircle"
	var hud := get_node_or_null("Hud/Root") as Control
	if hud != null:
		hud.add_child(_circle)
		# Connected once, not per card: there is one circle and it is told which
		# card it is holding a window open for.
		_circle.resolved.connect(_on_circle_resolved)
	if Screen.is_handheld():
		# The hand's band is sized for a 224-tall card. Handheld cards are 186, so
		# hand the difference back to the beast rather than leaving a dead strip.
		var scroll := _hand_row.get_parent() as Control
		if scroll != null:
			scroll.offset_top = -206.0
	# Backtick opens it. Given the refresh callable so a command that changes
	# the world - a new hand, a different beast - is on screen by the time you
	# have finished reading what it printed.
	DevConsole.attach(self, _refresh)
	_cam_home = _cam.position
	# The active hunter's climb tween updates node.position during its own
	# per-frame step, which this node's _process() runs ahead of -- reading
	# it from _process (even at the very end, even deferred) still sees last
	# frame's position, so the tag's hunter-avoidance clamp was one step
	# behind whatever actually got drawn (request 2026-09-24, "still grazes
	# hunter at hop start"). frame_pre_draw fires once everything driving
	# this frame -- process, physics, tweens -- has already run, right before
	# it is actually rendered, so this is the first point where the tag can
	# see the same hunter position the frame is about to show.
	RenderingServer.frame_pre_draw.connect(_position_intent_tag)
	_client = Session.client
	if _client == null:
		return
	_client.state_updated.connect(func(_s: Dictionary, _p: Dictionary) -> void: _refresh())
	_end_btn.pressed.connect(_end_turn)
	_switch_btn.pressed.connect(func() -> void: _switch_to(1 - _active_slot))
	_log_toggle.pressed.connect(func() -> void:
		_log_expanded = not _log_expanded
		_refresh())
	_menu_btn.pressed.connect(_open_settings)
	_coach_ok.pressed.connect(_dismiss_coach)
	# The off switch lives ON the tip, because that is the exact moment you want
	# it. Burying it in a menu means being annoyed now and fixing it later, which
	# in practice means never.
	_coach_off.pressed.connect(func() -> void:
		Progress.set_hints_enabled(false)
		_coach_id = ""
		_coach_left = 0.0
		_coach.visible = false)
	_build_gauge()
	# Right-click the telegraph to ask what the move does — the tag itself names
	# it and prints the number, and nothing more.
	_intent_tag.mouse_filter = Control.MOUSE_FILTER_STOP
	_intent_tag.gui_input.connect(func(e: InputEvent) -> void:
		if not (e is InputEventMouseButton):
			return
		var mb := e as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed and _intent_kind != "":
			_intent_tag.accept_event()
			_show_keyword(Content.keyword(_intent_kind)))
	if not _client.shared.is_empty():
		_refresh()


# --- the climb gauge -------------------------------------------------------
#
# "It's not very intuitive on how far you still need to climb" (Nick,
# 2026-08-16). It never was: the party panel printed a bare Height and nothing
# said what Height you were aiming AT, so the number had no scale. With sigils
# now sitting at 4-13 instead of 1-3 that gap stops being cosmetic — a climb is
# several turns of planning and you have to be able to see where you are in it.
#
# A ladder, drawn to scale, on the right edge: the sigil at the top, ledges as
# rungs, and each hunter as a dot in their own colour. Position, distance and the
# next safe hold are all one glance, and the shape of the climb is visible before
# you commit to it.

const GAUGE_W := 62.0
const GAUGE_H := 330.0
const GAUGE_MARGIN := 14.0
const GAUGE_PAD_TOP := 30.0     # room for the sigil mark above the rail
const GAUGE_PAD_BOTTOM := 34.0  # room for the "N to go" line below it


func _build_gauge() -> void:
	# A panel, not a bare line on the background: at 3 pixels wide against a sky
	# the first version read as a scratch on the screen rather than as a reading.
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	panel.offset_left = -(GAUGE_W + GAUGE_MARGIN)
	panel.offset_right = -GAUGE_MARGIN
	panel.offset_top = -GAUGE_H * 0.5
	panel.offset_bottom = GAUGE_H * 0.5
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.09, 0.075, 0.06, 0.66)
	st.set_border_width_all(1)
	st.border_color = Color(0.42, 0.35, 0.26, 0.8)
	st.set_corner_radius_all(6)
	panel.add_theme_stylebox_override("panel", st)

	_gauge = Control.new()
	_gauge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_gauge.draw.connect(_draw_gauge)
	panel.add_child(_gauge)
	panel.visible = false
	_hud.add_child(panel)


## Feed the gauge from a snapshot. Hidden entirely for a beast with no weak point
## to climb to, because an empty ladder is worse than no ladder.
func _update_gauge(s: Dictionary) -> void:
	if _gauge == null or not is_instance_valid(_gauge):
		return
	var boss: Dictionary = s.get("boss", {})
	var top := int(boss.get("weak_point_height", 0))
	var panel: Control = _gauge.get_parent() as Control
	if top <= 0:
		panel.visible = false
		return
	var heights: Array = []
	for p in s.get("players", []):
		heights.append(int((p as Dictionary).get("foothold", 0)))
	_gauge_data = {"top": top, "ledges": gauge_ledge_heights(boss.get("ledges", [])), "heights": heights}
	panel.visible = true
	_gauge.queue_redraw()


## Normalize a raw `ledges` array (bare ints/floats, or the Dictionary hold
## shape from Boss.hold_height()/hold_safe() — backlog #24 unsafe named holds)
## into plain int Heights. `_draw_gauge` used to call `ledges.has(h)` directly
## on the raw array: Array.has() compares with `==`, and an int Height never
## equals a Dictionary hold, so any Dictionary-shaped ledge silently drew as
## "no ledge here" on the gauge even though /core treated it correctly
## everywhere else. #86 duty 2 (two copies of one truth).
static func gauge_ledge_heights(ledges: Array) -> Array:
	var out: Array = []
	for l in ledges:
		out.append(Boss.hold_height(l))
	return out


## The subset of a raw `ledges` array /core actually treats as safe rest
## stops — the same `Boss.hold_safe()` filter `Combat.is_secure()` and
## `Combat.next_safe_height()` apply (core/combat.gd:210-234). `_safe_ledges`'
## own doc comment already promises this ("the same data is_secure()/
## next_safe_height() use"), but it was being fed `gauge_ledge_heights()`
## instead, which normalizes heights without dropping unsafe ones — correct
## for the gauge (every Height should tick the ladder, safe or not) but wrong
## reused as "safe holds," so an unsafe named hold (backlog #24, "safe":
## false) would still get `_build_ledge_marks`' glowing safe-rest ring even
## though a hunter standing there has their grip timer draining regardless.
## #86 duty 2 (two copies of one truth).
static func safe_ledge_heights(ledges: Array) -> Array:
	var out: Array = []
	for l in ledges:
		if Boss.hold_safe(l):
			out.append(Boss.hold_height(l))
	return out


## Whether this hunter's climb-rail dot steps aside from its neighbour's, and
## which way — the gauge's own copy of hunter_side_offset's job, for the flat
## 2D dots instead of the 3D hunter models. Same root as the hunters-overlap-
## at-sigil fix (backlog #86): `y_of` clamps every foothold >= `top` to the
## same rung, but this used to compare the RAW heights before that clamp, so
## two hunters both drawn AT the sigil with different raw footholds (13 and
## 16 on a Height-13 sigil) read as two different rungs and the offset never
## fired — both dots landed on the exact same point and the second tint
## painted over the first, so only one hunter's colour ever showed.
static func gauge_dot_dx(heights: Array, i: int, top: int) -> float:
	var dx: float = -8.0 if i == 0 else 8.0
	if heights.size() <= 1:
		return dx
	var cap: int = maxi(top, 1)
	if mini(int(heights[0]), cap) != mini(int(heights[1]), cap):
		return 0.0
	return dx


func _draw_gauge() -> void:
	if _gauge_data.is_empty():
		return
	var top: int = int(_gauge_data["top"])
	var ledges: Array = _gauge_data["ledges"]
	var heights: Array = _gauge_data["heights"]
	var size := _gauge.size
	var x := size.x * 0.5
	var y_top := GAUGE_PAD_TOP
	var y_bot := size.y - GAUGE_PAD_BOTTOM
	var font := ThemeDB.fallback_font
	var rail := Color(0.55, 0.47, 0.36, 0.95)
	var gold := Color(1.0, 0.84, 0.42)

	# `h` in Height units -> a y on the rail. Height 0 is the ground, at the bottom.
	var y_of := func(h: float) -> float:
		return y_bot - (y_bot - y_top) * clampf(h / float(top), 0.0, 1.0)

	_gauge.draw_line(Vector2(x, y_top), Vector2(x, y_bot), rail, 3.0)

	# Rungs. Every Height gets a small one so the ladder has a SCALE — without
	# them a climb of 2 up a sigil of 13 looks the same as one up a sigil of 4.
	for h in range(1, top):
		var y: float = y_of.call(float(h))
		var is_ledge: bool = ledges.has(h)
		var w: float = 13.0 if is_ledge else 6.0
		_gauge.draw_line(Vector2(x - w, y), Vector2(x + w, y),
			Color(0.78, 0.68, 0.5, 0.95) if is_ledge else rail, 3.0 if is_ledge else 1.5)

	# The sigil, its Height, and the ground you fall back to.
	_gauge.draw_line(Vector2(x - 15, y_top), Vector2(x + 15, y_top), gold, 3.0)
	_gauge.draw_string(font, Vector2(0, y_top - 10), "✦ %d" % top,
		HORIZONTAL_ALIGNMENT_CENTER, size.x, 13, gold)
	_gauge.draw_line(Vector2(x - 11, y_bot), Vector2(x + 11, y_bot), rail, 3.0)

	# Each hunter, and — for the one you are holding — how much climb is left.
	for i in range(heights.size()):
		var h: int = heights[i]
		var y: float = y_of.call(float(h))
		var tint: Color = _slot_color(i)
		var dx: float = gauge_dot_dx(heights, i, top)
		_gauge.draw_circle(Vector2(x + dx, y), 6.0, tint)
		_gauge.draw_arc(Vector2(x + dx, y), 6.0, 0.0, TAU, 16, Color(0.1, 0.09, 0.07), 2.0)

	var mine: int = int(heights[_me()]) if _me() < heights.size() else 0
	var left: int = top - mine
	var label := "at sigil" if left <= 0 else "%d up" % left
	_gauge.draw_string(font, Vector2(0, y_bot + 22), label,
		HORIZONTAL_ALIGNMENT_CENTER, size.x, 13,
		gold if left <= 0 else Color(0.92, 0.88, 0.78))


## The circle landed (or ran out). Identical to the card face's path — same
## grading, same command — which is the point: nothing downstream knows or cares
## which face the player used.
func _on_circle_resolved(quality: int) -> void:
	if _circle_index < 0:
		return
	Sfx.play("nail" if quality > Combat.TIMING_MISS else "slip")
	_client.play_card(_circle_index, quality > Combat.TIMING_MISS, _cmd_slot(), -1, -1, quality)
	_circle_index = -1


## How much Climb makes a card a HOLD rather than a tap. A long haul up the body
## should feel sustained; a short hop should not.
## Fewest notes a timed card ever asks for.
##
## This is the whole reason the osu face did not feel like osu: `timed_hits` is 1
## for 28 of the 41 timed cards, so almost every card showed ONE circle and one
## circle is not a rhythm (Nick, 2026-08-25: "the osu circles still only have 1
## circle"). In osu you are always hitting a sequence — the pattern IS the
## instrument. A card that wants more windows still gets them; this is a floor,
## not an override, so Satchel Charge keeps its three.
const NOTE_MIN := 3


## Climb 2 and up. At 3 only two cards in the whole game would ever have been a
## slider, so the feature would have shipped effectively dead; at 2 it is five,
## and the rule still reads honestly — a real haul is a hold, a hop is a tap.
const SLIDER_CLIMB := 2


## How far this card climbs, as PRINTED on it.
##
## Under `base`, not at the top level: the snapshot puts a card's printed values
## in their own dict so the face can compare live numbers against them. Reading
## `card.grip` returns 0 for every card in the game, silently, which is exactly
## how the slider path came out flat until the harness could not find a climb
## card either.
static func card_climb_for(card: Dictionary) -> int:
	return int((card.get("base", {}) as Dictionary).get("grip", 0))


## Should this timed card's HitCircle window be one held slider, or a tap chain?
##
## `card_climb_for` and `hits` (timed_hits) are printed independently and no
## shipped, un-melded card carries both a slider-eligible climb AND more than
## one real timing window -- but Meld sums `grip` and takes the max of
## `timed_hits` across its two cards (combat.gd's `_meld_cards`), so fusing a
## climb card (e.g. Winch, grip 2) with a multi-hit card (e.g. Satchel Charge,
## timed_hits 3) reaches it for real. `HitCircle.begin()` used to let `slider`
## win outright, collapsing `_hits_needed` to 1 regardless of `points.size()`
## -- a card that should demand 3 separately-graded windows instead resolved
## as a single 0.85s hold with SLIDE_RESCUE forgiveness, a much easier check
## than its own `timed_hits` promises and than the sweep-bar CardView face
## (`start_timing(hits)`, unconditional on grip) already gives the identical
## melded card. Only a genuinely single-window climb stays a slider; anything
## melded past one window falls back to the tap chain both faces otherwise
## agree on.
static func card_is_slider(card: Dictionary, hits: int) -> bool:
	return card_climb_for(card) >= SLIDER_CLIMB and hits <= 1


## Screen-space spacing between consecutive notes, in pixels.
##
## About a circle and a half apart — an osu stream, where the next note is close
## enough that you flick to it rather than travel to it. The first version ran
## the chain from the card all the way up to the hold, which was a journey across
## the frame and put notes off the edge of it (Nick, 2026-08-25: "dont make them
## acros the screen. they should be in quick succesion").
const NOTE_STEP := 92.0
## How far the zigzag swings either side of the line.
const NOTE_SWAY := 42.0


## The pattern this card asks you to tap: a short stream rising from the card you
## tapped, in screen space so the spacing is the same whatever the camera is
## doing and whatever you are fighting.
##
## Built as screen offsets and projected into the world, because HitCircle draws
## from world points — project_position is the exact inverse of the unproject it
## uses, so a note lands where the arithmetic says it will.
func _hold_points(card: Dictionary, hits: int, from_screen: Vector2) -> PackedVector3Array:
	var out := PackedVector3Array()
	if _cam == null:
		return out
	var count := maxi(hits, NOTE_MIN)
	if card_climb_for(card) >= SLIDER_CLIMB:
		count = maxi(count, 3)      # a slider needs a path to travel along
	# One depth for the whole pattern, so the spacing stays in pixels rather than
	# stretching with perspective.
	var depth := maxf(_dist * 0.55, 3.0)
	# Keep the stream inside the frame even when the card that started it sits in
	# a corner: shove the whole pattern, rather than bending it out of shape.
	# A different shape every time. The same three positions on every card turned
	# a rhythm test into muscle memory you only had to learn once (Nick,
	# 2026-08-25: "the circles are in the same position everytime"). The stream
	# still rises — you are climbing — but it leans, curves and steps differently
	# on each play.
	var rng := RandomNumberGenerator.new()
	var lean := rng.randf_range(-0.55, 0.55)          # radians off vertical
	var curve := rng.randf_range(-0.9, 0.9)           # how much the line bends
	var flip := 1.0 if rng.randf() < 0.5 else -1.0    # which side the zigzag starts
	var pattern := PackedVector2Array()
	var lo := Vector2(1e9, 1e9)
	var hi := Vector2(-1e9, -1e9)
	for i in range(count):
		var step := float(i)
		var along := Vector2(sin(lean), -cos(lean)) * (NOTE_STEP * step)
		var side := Vector2(cos(lean), sin(lean))
		var wobble := flip * (1.0 if i % 2 == 0 else -1.0) * NOTE_SWAY
		var bend := curve * NOTE_SWAY * sin(step / maxf(float(count - 1), 1.0) * PI)
		var at := from_screen + along + side * (wobble + bend)
		pattern.append(at)
		lo = Vector2(minf(lo.x, at.x), minf(lo.y, at.y))
		hi = Vector2(maxf(hi.x, at.x), maxf(hi.y, at.y))

	# Shove the whole pattern back on screen rather than bending it out of shape.
	var pad := 96.0
	var view := get_viewport().get_visible_rect().size
	var shove := pattern_shove(lo, hi, view, pad)
	for at in pattern:
		out.append(_cam.project_position(at + shove, depth))
	return out


## The pure half of the on-screen shove above, lifted out so it's provable
## without a camera, a viewport, or a scene tree: a hitstream note you can't
## reach is a note you can't play (Nick, 2026-08-25, on notes landing across
## the screen from each other and off the edge of it). `lo`/`hi` bound the
## pattern before the shove; a corner already inside [pad, view - pad] on both
## axes needs no push at all.
static func pattern_shove(lo: Vector2, hi: Vector2, view: Vector2, pad: float) -> Vector2:
	return Vector2(
		maxf(0.0, pad - lo.x) - maxf(0.0, hi.x - (view.x - pad)),
		maxf(0.0, pad - lo.y) - maxf(0.0, hi.y - (view.y - pad)))


## The one place a turn ends, so the button and the key can never drift apart.
func _end_turn() -> void:
	if _end_btn.disabled:
		return                                   # already ended; waiting on your ally
	Sfx.play("end_turn")
	_dismiss_coach()
	_client.end_turn(_cmd_slot())
	_apply_solo_turn_flip()
	_refresh()


## The solo half of ending a turn: hand the view to whichever hunter you now
## hold. This used to inline `_active_slot = 1 - _active_slot` here with no
## guard at all -- `_switch_to` (below) refuses to flip the active hunter
## while a sweep-bar or HitCircle timing window is open, because that window
## resolves against `_cmd_slot()` read LIVE, against a hand index captured
## when it opened. End Turn is a second, independent path to that same flip
## and had no such guard: tap a timed card, then End Turn before the sweep
## resolves, and the window would resolve moments later against the OTHER
## hunter's hand at the first hunter's old index. #86 duty 2.
func _apply_solo_turn_flip() -> void:
	if not _is_solo():
		return
	if switch_blocked_by_timing(_timing_card != null and is_instance_valid(_timing_card)
			and _timing_card.is_timing(), _circle_index):
		return
	_active_slot = 1 - _active_slot
	_lock_slot = _active_slot   # the camera follows the hand you now hold
	_focus_camera()


## Keyboard accelerators, all remappable from the settings menu (Progress.KEYBINDS).
##
## Space ends the turn — it is the action you take every single turn, and the
## button for it sits in the far bottom corner (Nick, 2026-08-16). Swapping is
## time-critical for the same reason: both grip timers drain at once in solo, so
## reaching for a corner button while a bar empties is the wrong input for it.
## TAB toggles; 1 and 2 jump straight to a hunter, which beats toggling when you
## know who you want.
##
## An accelerator, never the only path: CLAUDE.md §5 keeps every action reachable
## by tap, because there is no keyboard on the mobile target. Every button stays
## exactly as it was.
##
## _input rather than _unhandled_input: TAB is ui_focus_next and Space activates
## the focused button, and the viewport's GUI layer consumes both before unhandled
## input ever runs — which, on a HUD you drive by clicking, is always.
func _input(event: InputEvent) -> void:
	# A card in hand is being carried. This has to be in _input, not
	# _unhandled_input, and for the same reason the keys below are: a dragged
	# card sits UNDER the pointer, so the GUI layer hands the release to the
	# card and consumes it, and unhandled input never runs. The drag would start
	# fine and then never end - the card would stay stuck to the cursor.
	#
	# It is also ahead of the camera, or dragging a card orbits the fight
	# behind it.
	if _drag != null and _drag_input(event):
		get_viewport().set_input_as_handled()
		return
	if not (event is InputEventKey) or not event.is_pressed() or event.is_echo():
		return
	var code: int = (event as InputEventKey).keycode

	# The dev console owns the keyboard while it is open. This has to be here
	# and not in _unhandled_input for the same reason the rest of this function
	# is: _input runs before the focused LineEdit sees the key, so without it
	# every character typed into the console was also a game command.
	if DevConsole.open:
		return

	# Rebinding runs first and swallows everything: while the settings menu is
	# waiting for a key, that key must land in the binding rather than firing the
	# action it is currently bound to.
	if _rebinding != "":
		_apply_rebind(code)
		get_viewport().set_input_as_handled()
		return

	# Beast check: [ and ] swap the Titan you are standing in front of, without
	# leaving the fight or playing a run to reach it.
	#
	# Nick asked for a way to "go directly to each boss to check on this" — there
	# are fourteen beasts and fourteen grounds now, and the only way to see the
	# fourth Titan's was to win three fights first. This swaps the boss the same
	# way tools/screenshot.gd does, so it exercises the real model, the real
	# ground and the real climb points rather than a preview of them.
	#
	# Host-only, because only the host owns the run — on a joined client the keys
	# do nothing rather than desyncing the two of you.
	if code == KEY_BRACKETLEFT or code == KEY_BRACKETRIGHT:
		_cycle_beast(1 if code == KEY_BRACKETRIGHT else -1)
		get_viewport().set_input_as_handled()
		return
	if _detail != null and is_instance_valid(_detail):
		return                                   # an overlay owns the keyboard

	# The keypad digits are aliases, not bindings — nobody expects to have to map
	# both, and nothing else wants them.
	if code == KEY_KP_1:
		code = KEY_1
	elif code == KEY_KP_2:
		code = KEY_2

	match Progress.action_for_key(code):
		"end_turn":
			_end_turn()
		"swap":
			_switch_to(1 - _active_slot)         # solo-only, guarded in _switch_to
		"hunter_1":
			_switch_to(0)
		"hunter_2":
			_switch_to(1)
		_:
			return
	get_viewport().set_input_as_handled()


## The one place the active hunter changes, so the button and the keys can never
## drift apart. A swap mid-pick would strand the half-finished selection on the
## other hunter's hand, so it cancels first.
func _switch_to(slot: int) -> void:
	if not _is_solo() or slot < 0 or slot > 1:
		return
	# Asking for the hunter you are already holding is not a no-op: it means
	# "show me them", which is the whole point of a lock-on and the natural thing
	# to do after flying the camera somewhere else.
	if slot == _active_slot:
		_focus_camera()
		return
	# A timing window (sweep-bar CardView or HitCircle) resolves against
	# _cmd_slot() read LIVE at resolution time, but the hand index it carries
	# (captured at tap time, in the resolution closures in _on_card_tapped/
	# _on_circle_resolved) belongs to whichever hunter was active when the
	# window opened. `should_rebuild_hand` already keeps a mid-swing CardView
	# alive across an unrelated refresh for exactly this reason -- its state
	# lives only on that one node. Switching hunters mid-window would leave
	# that stale index paired with the NEW active slot, so play_card lands
	# on the wrong hunter's hand (or a hand index that doesn't even exist
	# there) with no warning. #86 duty 2.
	if switch_blocked_by_timing(_timing_card != null and is_instance_valid(_timing_card)
			and _timing_card.is_timing(), _circle_index):
		return
	if not _selecting.is_empty():
		_selecting = {}
	_active_slot = slot
	_lock_slot = slot          # selecting a hunter IS aiming the camera at them
	_focus_camera()
	Sfx.play("card")
	_refresh()


## Put the camera on the hunter you just picked, hard enough to notice.
##
## The pivot CUTS rather than glides, and the shot STAYS close. It used to push
## in and ease back out to the beast framing, which Nick reported as the camera
## "moving away after selecting" — and he is right that it is wrong: a lock-on
## you have to keep re-triggering is not a lock-on. Now the close shot holds, and
## follows the hunter up the beast as they climb.
##
## Zoom or drag whenever you want the fight back; picking a hunter is how you
## return, and a new beast opens wide again.
##
## Also the one way back from free look, which is why it clears the pan and the
## manual framing rather than only re-aiming.
## `lift` raises the aim point by a fraction of the window, which is what turns
## a close hold into a third-person shot. At 0 the hunter sits dead centre and
## half the frame is floor; at 0.3 they sit low and the beast owns everything
## above them, which is the composition the fight is actually about.
## `is_inside_tree()` closes the same race location_3d.gd's `_refresh()` already
## documents (backlog #7, 0934ea9915b2): `_client.end_turn()` (and any other
## command send) can resolve synchronously all the way through the host and
## back to `state_updated.emit()` before returning, and game_3d.gd's router
## listens on that same signal and, on a phase change, `remove_child(_view)`s
## the OLD view *immediately* -- mid-command, before `_end_turn()`'s own
## `_apply_solo_turn_flip()` -> `_focus_camera()` call even runs. This view's
## `_refresh()` already dodges that by bailing the moment `phase` no longer
## names it (see its own top), but `_focus_camera()` is reachable straight from
## `_end_turn()`/`_switch_to()` with no phase check at all, and its only guard
## was `_cam == null` -- true for "never had a camera," never for "my camera's
## node just left the tree." `_apply_orbit()` below has no guard of its own and
## calls `_cam.look_at()`, which requires the tree; reaching it after a
## same-turn teardown is exactly the crash filed in
## 2026-09-23-1000-playtester-to-fixer-end-turn-crash-at-sigil-solo-flip.md.
func _focus_camera(window := FOCUS_WINDOW, lift := 0.0) -> void:
	_pan = Vector3.ZERO
	_establishing = false
	# Selecting a hunter always hands framing back to the normal camera, dev
	# free cam included — so a stale _free_cam_engaged from an earlier drag
	# can never leak into the climb-focus lock this function sets below (its
	# own _user_framed = true is NOT a free-cam re-engagement).
	if _free_cam_engaged:
		# Finish the dev camera's in-flight chase before handing over, rather
		# than freezing _yaw/_pitch/_dist wherever the ease happened to be —
		# a click that interrupts a still-settling drag (e.g. re-selecting a
		# hunter mid-ease) must land exactly where the drag was headed, the
		# same place an un-eased drag always landed instantly.
		_yaw = _yaw_target
		_pitch = _pitch_target
		_dist = _free_dist_target
	_free_cam_engaged = false
	if _hunters.is_empty() or _cam == null or not is_inside_tree():
		return
	if not anyone_off_ground(_hunters):
		# Nobody has left the ground: hold #11's composition (the whole beast
		# and both hunters, small, in one wide frame) instead of cutting to a
		# tight lock on whoever you just picked. _aim_camera's own per-frame
		# ground framing (climb_frame_for, `not _focused`) already draws this
		# shot — clearing the flags here just lets it keep doing so instead of
		# being overridden a moment later. The instant anyone actually climbs,
		# the next selection re-engages the tight over-the-shoulder follow
		# below, unchanged.
		_focused = false
		_user_framed = false
		return
	_focused = true
	# Hold the shot: _aim_camera only eases distance back to the beast framing
	# while it still owns framing, so taking it away is what stops the drift.
	_user_framed = true
	var lock := _lock_point()
	_pivot.x = lock.x
	_pivot.z = lock.y
	# Aim at the HUNTER's own height, not the beast-framing height _climb_frame
	# hands back. Pushing in while still aimed at the beast's middle just filled
	# the screen with beast and left the hunter under the cards, which answers the
	# wrong question — the whole point is showing you WHO you are holding.
	var slot: int = lock_slot_for(_lock_slot, _hunters.size(), _me())
	_focus_lift = window * lift
	if slot >= 0 and slot < _hunters.size():
		_pivot.y = float((_hunters[slot]["home"] as Vector3).y) \
			+ HUNTER_HEIGHT * 1.4 + _focus_lift
	# Same fixed standoff the ground shot uses (ACTIVE_HUNTER_DIST), not a window
	# fit around `window` -- fitting the beast's own height is exactly what put
	# the hunter a speck on a tall beast's chest (Nick, 2026-09-25: "camera
	# closer, should be locked to character"). One number, on the ground and up
	# the side, is what makes the hunter read as the same size in both.
	#
	# The clearance term reads the hold's OWN local surface (_front_of_beast at
	# the hunter's actual column), not the whole beast's bounding box front
	# face. The sigil sits on top of the body, near the world-z centreline, far
	# short of `_beast_box.end.z` (measured at the chest) -- charging the box's
	# full depth there added ~13 units of clearance nothing was in the way of,
	# and pushed the hunter down behind the card fan at the top hold.
	_dist = minf(climb_dist_for(_front_of_beast(_pivot.x, _pivot.y), _pivot.z), _cam_reach())
	_apply_orbit()


# --- solo helpers ---------------------------------------------------------
#
# Solo is one physical screen holding BOTH hunters' private hands (couch
# co-op, no networking): _active_slot picks which hunter's hand this client
# is currently looking at, and _client.private carries both hands at once
# under "slots" rather than the single hand a real remote peer gets. Get the
# routing wrong and switching hunters either freezes on the old hand or
# leaks the other hunter's cards into view — the exact "private hand" promise
# CLAUDE.md §2 exists to keep, just tested on the single-screen path instead
# of the network path #86 duty 3 already proved for GameClient.
#
# location_3d.gd needs the identical routing (the reward/shop/campfire
# screens are solo-aware too) and used to carry its own hand-typed copy —
# the "two copies of one truth" bug class duty 2 hunts. The three funcs
# below are pure (no _client, no scene tree) so both views — and
# run_tests.gd, headless — can share one implementation instead.

func _is_solo() -> bool:
	return bool(_client.shared.get("solo", false))

func _me() -> int:
	return solo_view_slot(_is_solo(), _active_slot, _client.you)

func _cmd_slot() -> int:
	return solo_cmd_slot(_is_solo(), _active_slot)

func _my_private() -> Dictionary:
	return solo_private_view(_is_solo(), _active_slot, _client.private)

## Which hunter's hand this client is looking at: itself in solo (switchable
## by the switch button), otherwise whichever slot the host addressed this
## peer as. #86 duty 3.
static func solo_view_slot(is_solo: bool, active_slot: int, client_you: int) -> int:
	return active_slot if is_solo else client_you

## The slot a chat/dev command should stamp onto its payload: solo has no
## peer identity to fall back on, so it must say explicitly which hunter
## issued it; a networked client leaves it unset (-1) and lets the host
## resolve the command from the connection itself. #86 duty 3.
static func solo_cmd_slot(is_solo: bool, active_slot: int) -> int:
	return active_slot if is_solo else -1

## In solo, one client's private snapshot carries BOTH hunters' hands under
## "slots" (there is no second peer to address a second snapshot to), so the
## active hunter's hand has to be sliced out by index; a networked client's
## private snapshot is already addressed to exactly one hunter and is
## returned as-is. Out-of-range (a stale slot from a snapshot that arrived
## before the second hunter's slot did) returns {} rather than crashing on
## an Array index. #86 duty 3.
static func solo_private_view(is_solo: bool, active_slot: int, private: Dictionary) -> Dictionary:
	if is_solo:
		var slots: Array = private.get("slots", [])
		return slots[active_slot] if active_slot >= 0 and active_slot < slots.size() else {}
	return private


# --- per-frame feel -------------------------------------------------------

## Everything alive in the scene is driven from here: the beast breathes, the
## hunters sway, and any shake or recoil decays back to rest.
func _process(delta: float) -> void:
	_time += delta
	# The stones drift. Each on its own phase so they never pulse as one block.
	# Hunters keep their eyes on the boss. A body that never turns is the
	# loudest 'this is a prop, not a character' tell, and every third-person
	# game with a locked target turns the body, not just the camera. Eased
	# rather than snapped (about 540 deg/s on a right-angle error), and only
	# yaw - the hop owns pitch.
	for h in _hunters:
		var hb := h.get("body") as Node3D
		if hb == null or not is_instance_valid(hb) or _beast == null:
			continue
		var holder := h["node"] as Node3D
		var at_beast := _beast_box.get_center() - holder.position
		if Vector2(at_beast.x, at_beast.z).length() < 0.05:
			continue
		var want := atan2(at_beast.x, at_beast.z)
		hb.rotation.y = lerp_angle(hb.rotation.y, want, 1.0 - exp(-delta * 9.0))

	for i in _float_stones.size():
		var st := _float_stones[i] as Node3D
		if not is_instance_valid(st):
			continue
		var home: Vector3 = _float_home[i]
		st.position.y = home.y + sin(_time * 1.1 + float(i) * 1.7) * HUNTER_HEIGHT * 0.12
		st.rotation.y += delta * 0.25
	if _beast != null:
		# No breathing pulse. Nick, 2026-09-08: "for whatever reason the beast
		# gets bigger and smaller. we can get rid of that." It was
		# `1.0 + sin(_time * 1.6) * 0.02` multiplied into the beast's UNIFORM
		# scale, which is the wrong shape for the idea twice over: real breathing
		# swells a chest, it does not resize an animal, and scaling uniformly
		# about the origin lifts the feet off the ground every cycle. On a Titan
		# filling the frame, 2% is plainly visible.
		#
		# The recoil stays: that is a hit landing, and it is meant to be seen.
		# If an idle is wanted back, it belongs in the ember pulse in
		# creature.gdshader, which breathes LIGHT rather than size.
		var recoil := 1.0 - _beast_punch * 0.10
		_beast.scale = Vector3.ONE * _beast_scale * recoil
		_beast.position.z = -_beast_punch * 0.35
	_beast_punch = maxf(0.0, _beast_punch - delta * 3.5)
	_last_popup_guard = maxf(0.0, _last_popup_guard - delta)
	for i in range(_hunters.size()):
		var h: Dictionary = _hunters[i]
		var node: Node3D = h["node"]
		# Skip the sway while a climb/glide tween owns this hunter. `h["home"]`
		# is written to the FINAL target the instant _place_hunters decides to
		# move (see the "climb"/"glide" branches there), before the tween that
		# eases node.position toward it has taken a single step — so an
		# unconditional write here every frame snapped node.position.y straight
		# to the destination on frame one and fought the tween for the rest of
		# its run. Every climb read as a flat slide instead of a jump.
		if is_instance_valid(node) and not _tween_is_live(_climb_tw.get(i) as Tween):
			# a gentle out-of-phase idle so the two hunters don't look cloned
			node.position.y = float((h["home"] as Vector3).y) + sin(_time * 2.3 + i * 1.7) * 0.045
	if _sigil != null and _sigil.visible:
		_sigil.scale = Vector3.ONE * _sigil_scale * (1.0 + sin(_time * 3.0) * 0.14)
	_fly(delta)
	_track_climb(delta)
	if _coach_left > 0.0:
		_coach_left -= delta
		# fade the last second, so it leaves rather than blinking out
		_coach.modulate.a = clampf(_coach_left, 0.0, 1.0)
		if _coach_left <= 0.0:
			_dismiss_coach()
			_coach.modulate.a = 1.0
	if _shake > 0.001:
		_shake = maxf(0.0, _shake - delta * 2.6)
		var amp := _shake * 0.42
		_cam.position = _cam_home + Vector3(
			randf_range(-amp, amp), randf_range(-amp, amp), randf_range(-amp, amp) * 0.4)
	elif _cam.position != _cam_home:
		_cam.position = _cam_home
		_cam.look_at(_pivot, Vector3.UP)
	if _flash != null:
		_flash.light_energy = maxf(0.0, _flash.light_energy - delta * 9.0)
	_tick_grip(delta)


## How long the party can cling, including any grip relics.
func _grip_seconds() -> float:
	return GRIP_SECONDS + float(int(_client.shared.get("mods", {}).get("grip_seconds", 0)))


## The pure arithmetic behind a single climb-timer tick: how much grip is left
## after `delta` seconds of clinging out of `grip_seconds` total (relics push
## `grip_seconds` up, never `g` itself). Pulled out static so the "did this
## frame let go" threshold is provable without a scene tree, Sfx, or
## `_client.fall`.
static func grip_after_tick(g: float, delta: float, grip_seconds: float) -> float:
	return g - delta / grip_seconds


## Every climbing hunter's timer ticks, whoever is active. An empty timer is a
## fall — and in 3D that is worth SEEING, so a slipping hunter shakes harder the
## closer they are to letting go.
func _tick_grip(delta: float) -> void:
	if _climb.is_empty():
		return
	for slot in _climb.keys().duplicate():
		var st: Dictionary = _climb[slot]
		st["g"] = grip_after_tick(float(st["g"]), delta, _grip_seconds())
		if float(st["g"]) <= 0.0:
			_climb.erase(slot)
			Sfx.play("shake")
			_client.fall(int(slot) if _is_solo() else -1)
			continue
		var i := int(slot)
		if i < _hunters.size():
			var node: Node3D = (_hunters[i] as Dictionary)["node"]
			# Same guard as the idle sway above (~line 1322): while a climb tween
			# owns this hunter, `home.x` now moves leg by leg (home_after_leg,
			# #0420) instead of sitting still at the final stop -- writing
			# node.position.x from it here, unconditionally, raced that tween
			# every frame and produced a same-frame snap the moment a leg
			# boundary moved `home.x` (playtest's hop-position-pop, found live
			# chasing the first version of this fix).
			if is_instance_valid(node) and not _tween_is_live(_climb_tw.get(i) as Tween):
				# steady at full grip, scrabbling as it runs out
				var slip: float = 1.0 - clampf(float(st["g"]), 0.0, 1.0)
				var amp: float = slip * slip * 0.075
				node.position.x = float(((_hunters[i] as Dictionary)["home"] as Vector3).x) 					+ sin(_time * 34.0 + i) * amp
	_update_grip_bar()


## The pure decision behind one hunter's "secure" flag: erase the climb timer
## on a genuine hold (secure), start a fresh full timer on a genuine
## hold -> climbing transition (not secure, wasn't already climbing), or —
## the rule the doc comment on `_update_climb_state` names and nothing tested
## before this — leave a timer already draining ALONE and only refresh its
## target, so reaching an intermediate ledge mid-hop never grants a free
## regrip. Returns null to mean "erase."
static func climb_state_after_secure_update(had_state: bool, prior_g: float,
		secure: bool, target: int) -> Variant:
	if secure:
		return null
	if not had_state:
		return {"g": 1.0, "target": target}
	return {"g": prior_g, "target": target}


## Derive climb bursts from the "secure" flags: leaving a hold starts that
## hunter's timer full, reaching one (or falling) ends it. Grip only resets on a
## genuine hold -> climbing transition, so it drains continuously across a hop.
func _update_climb_state(s: Dictionary) -> void:
	var players: Array = s.get("players", [])
	var slots: Array = [0, 1] if _is_solo() else [_client.you]
	for slot in slots:
		if slot < 0 or slot >= players.size():
			continue
		var p: Dictionary = players[slot]
		var target: int = int(p.get("next_safe", int(p.get("foothold", 0))))
		var prior_g: float = float(_climb[slot]["g"]) if _climb.has(slot) else 1.0
		var next_state: Variant = climb_state_after_secure_update(
			_climb.has(slot), prior_g, bool(p.get("secure", true)), target)
		if next_state == null:
			_climb.erase(slot)
		else:
			_climb[slot] = next_state
	_update_grip_bar()


## Show the ACTIVE hunter's grip if they're climbing, else any other climbing
## hunter's (named), so a ticking ally timer is never invisible after a switch.
func _update_grip_bar() -> void:
	if _grip_bar == null:
		return
	_grip_bar.visible = not _climb.is_empty()
	if _climb.is_empty():
		return
	var slot: int = _me() if _climb.has(_me()) else int(_climb.keys()[0])
	var st: Dictionary = _climb[slot]
	var g := clampf(float(st["g"]), 0.0, 1.0)
	_grip_meter.value = g
	_grip_meter.modulate = Color(0.9, 0.33, 0.28).lerp(Color(0.55, 0.85, 0.5), g)
	var who := "" if slot == _me() else "%s — " % _hunter_name(slot)
	var extra := "   (both hunters climbing!)" if _climb.size() > 1 else ""
	_grip_label.text = "⚠ %sHOLD ON — reach Height %d before your grip gives out!%s" % [
		who, int(st.get("target", 0)), extra]


## Which hunter's cards are on screen — the one whose border the hand wears.
##
## Off _client.shared like every other read in this view; there is no
## _client.state(), which an earlier version of this assumed and which failed
## at runtime while the screenshot harness still reported SHOT SAVED.
func _my_character() -> String:
	var players: Array = _client.shared.get("players", [])
	var me := _me()
	if me < 0 or me >= players.size():
		return ""
	return String((players[me] as Dictionary).get("character", ""))


func _hunter_name(slot: int) -> String:
	var players: Array = _client.shared.get("players", [])
	if slot < 0 or slot >= players.size():
		return "Hunter %d" % (slot + 1)
	return String((players[slot] as Dictionary).get("name", "Hunter %d" % (slot + 1)))


func _refresh() -> void:
	var s := _client.shared
	if s.is_empty() or String(s.get("phase", "")) != "combat":
		_hud.visible = false
		_climb.clear()
		_selecting = {}
		_coach.visible = false
		return
	_hud.visible = true
	var boss: Dictionary = s["boss"]
	_title.text = String(boss["name"])
	_hp.text = "%d / %d" % [int(boss["hp"]), int(boss["max_hp"])]
	_hp_bar.max_value = int(boss["max_hp"])
	_hp_bar.value = int(boss["hp"])
	_set_intent(boss, s)
	# Before _show_beast, which needs it ready for _build_ledge_marks.
	_safe_ledges = safe_ledge_heights(boss.get("ledges", []))
	_show_beast(String(boss.get("id", "")), String(boss["name"]),
		int(boss.get("weak_point_height", 0)))
	_place_sigil(s)
	_place_hunters(s)
	# After placement, so "the ledge under the active hunter" and "the next rung
	# up" are both read from where the hunters actually ended up.
	_refresh_ledge_marks()
	_update_climb_state(s)
	_update_gauge(s)
	_render_party(s, int(boss.get("target", -1)), String(boss.get("intent", {}).get("type", "")),
		any_add_attacking(boss.get("adds", [])))
	_update_coach(s)
	_render_log(s)
	_react(s)
	_render_hand()


## The telegraph belongs ABOVE THE BEAST, not in a bar at the top of the screen
## (Nick, 2026-08-15). Slay the Spire puts intent on the enemy for a reason: it is
## the one thing you must read before choosing a card, and you are already looking
## at the thing that's about to hit you. In the top bar it sat beside the HP
## readout, competing with the name, the numbers and the Menu button.
##
## Aggressive moves wear the alarm colour; defensive and utility ones don't, so a
## turn where the beast isn't swinging reads as safe at a glance.
func _set_intent(boss: Dictionary, s: Dictionary) -> void:
	var txt := _intent_text(boss, s)
	_intent.text = "[center]%s[/center]" % txt
	_intent_tag.visible = txt != ""
	if txt == "":
		return
	var kind := String(boss.get("intent", {}).get("type", ""))
	_intent_kind = kind
	var hostile: bool = intent_is_hostile(kind)
	_intent.add_theme_color_override("default_color",
		Color(0.98, 0.55, 0.44) if hostile else Color(0.72, 0.84, 0.62))
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.18, 0.07, 0.06, 0.88) if hostile else Color(0.09, 0.14, 0.09, 0.85)
	style.set_border_width_all(2)
	style.border_color = Color(0.86, 0.36, 0.28) if hostile else Color(0.46, 0.62, 0.42)
	style.set_corner_radius_all(5)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 4.0
	style.content_margin_bottom = 4.0
	_intent_tag.add_theme_stylebox_override("panel", style)


## The pure placement rule behind _position_intent_tag, pulled out static so it
## is provable without a camera or a scene tree.
##
## `party_rect` is the top-left party panel's own global rect (or a
## zero-size Rect2 when it doesn't apply). The X clamp alone can land the tag
## squarely inside it: `lo_y` (70) already sits inside the party panel's own
## y-range (request 2026-09-23-2141), so nothing before this pushed the tag
## clear on the one axis Y never covers. Only tighten `lo_y` when the tag's
## X-range would actually overlap the panel -- an off-centre or right-side
## crown never pays for a panel it isn't near.
##
## `hunter_rect` is the active hunter's own projected screen rect (or a
## zero-size Rect2 when there is none). Unlike the party panel, a hunter is
## not fixed to one corner -- a hop's arc can carry it through the tag's
## rect from any side (request 2026-09-24, "jump-hides-behind-intent-tag":
## a hop's peak put the hunter's own bbox stretched both above AND below the
## tag's fixed y-range) -- so this needs a real 2D overlap test, not a
## one-sided push like the party panel's. Prefers pushing the tag to sit
## just ABOVE the hunter (closer to where it already tracks the crown);
## falls back to just BELOW when there is no room above; leaves the
## party/HP/hand clamp's own answer alone when neither side has room (a
## hunter tall enough to fill the whole legal band) rather than pick a worse
## spot arbitrarily.
static func intent_tag_pos(p: Vector2, sz: Vector2, vp: Vector2, party_rect: Rect2,
		hunter_rect: Rect2 = Rect2()) -> Vector2:
	var lo_y := 70.0                                   # clear of the boss HP bar
	var hi_y: float = maxf(lo_y, vp.y - sz.y - 250.0)  # clear of the hand
	# A crown that lands IN the HP-bar's own clear band (director, 2026-09-24:
	# "the beast's face is behind the Attack tag") has no room for "above" at
	# all -- that slot clamps to lo_y, which sits AT OR BELOW the crown itself,
	# so the tag lands on the head instead of clearing it. A crown further up
	# (off the top of frame, e.g. a Titan) or further down (plenty of room
	# above) isn't this bug and keeps the ordinary "above" placement.
	var near_top := p.y >= lo_y and p.y <= lo_y + sz.y
	var x: float
	if near_top:
		var side_lo_x := 12.0
		var side_hi_x := maxf(side_lo_x, vp.x - sz.x - 12.0)
		x = clampf(p.x + 40.0, side_lo_x, side_hi_x) if p.x < vp.x * 0.5 \
			else clampf(p.x - sz.x - 40.0, side_lo_x, side_hi_x)
	else:
		x = clampf(p.x - sz.x * 0.5, 12.0, maxf(12.0, vp.x - sz.x - 12.0))
	if party_rect.size.x > 0.0 and party_rect.size.y > 0.0 \
			and x < party_rect.position.x + party_rect.size.x \
			and x + sz.x > party_rect.position.x:
		lo_y = maxf(lo_y, party_rect.position.y + party_rect.size.y + 10.0)  # clear of the party panel
		hi_y = maxf(lo_y, hi_y)
	var y := clampf(p.y - sz.y * 0.5, lo_y, hi_y) if near_top \
		else clampf(p.y - sz.y - 10.0, lo_y, hi_y)
	if hunter_rect.size.x > 0.0 and hunter_rect.size.y > 0.0 \
			and x < hunter_rect.position.x + hunter_rect.size.x \
			and x + sz.x > hunter_rect.position.x \
			and y < hunter_rect.position.y + hunter_rect.size.y \
			and y + sz.y > hunter_rect.position.y:
		var above := hunter_rect.position.y - sz.y - 10.0
		var below := hunter_rect.position.y + hunter_rect.size.y + 10.0
		if above >= lo_y:
			y = above
		elif below <= hi_y:
			y = below
	return Vector2(x, y)


## The active hunter's own on-screen bounding rect, for `intent_tag_pos`'s
## hunter clamp -- empty when there is no camera, no active hunter, or the
## hunter has no visible model to bound. Projects the hunter's real,
## currently-tweened AABB (mid-hop included, since `_merged_aabb` reads the
## node's live global transform), not its resting foothold, so the check
## covers the exact moment a jump's arc carries it through the tag's rect.
static func hunter_screen_rect(cam: Camera3D, box: AABB) -> Rect2:
	var pts: Array = []
	for i in range(8):
		var corner := box.position + Vector3(
			box.size.x if (i & 1) else 0.0,
			box.size.y if (i & 2) else 0.0,
			box.size.z if (i & 4) else 0.0)
		if cam.is_position_behind(corner):
			continue
		pts.append(cam.unproject_position(corner))
	if pts.is_empty():
		return Rect2()
	var r := Rect2(pts[0], Vector2.ZERO)
	for i in range(1, pts.size()):
		r = r.expand(pts[i])
	return r


## Follow the beast's crown in screen space, clamped so it is always readable.
##
## The clamp matters more than the tracking: a Titan's head is off the top of the
## frame by design, so an untethered tag would sit off-screen for exactly the
## fights where knowing what's coming matters most.
func _position_intent_tag() -> void:
	if _intent_tag == null or not _intent_tag.visible or _cam == null:
		return
	if _beast_box.size.y <= 0.0:
		return
	var c := _beast_box.get_center()
	var crown := Vector3(c.x, _beast_box.end.y + _beast_box.size.y * 0.05, c.z)
	if _cam.is_position_behind(crown):
		return
	var p := _cam.unproject_position(crown)
	var sz := _intent_tag.size
	# Node3D has no get_viewport_rect(); that lives on Control.
	var vp: Vector2 = get_viewport().get_visible_rect().size
	var party_rect := Rect2()
	if _party != null and is_instance_valid(_party) and _party.is_visible_in_tree():
		party_rect = _party.get_global_rect()
	var hunter_rect := Rect2()
	if _active_slot >= 0 and _active_slot < _hunters.size():
		var hnode: Node3D = (_hunters[_active_slot] as Dictionary).get("node") as Node3D
		if hnode != null and is_instance_valid(hnode) and (_hunters[_active_slot] as Dictionary).get("body") != null:
			hunter_rect = hunter_screen_rect(_cam, _merged_aabb(hnode))
	_intent_tag.position = intent_tag_pos(p, sz, vp, party_rect, hunter_rect)


## What the beast is about to do, in numbers the player does not have to derive.
##
## "It currently says wrench apart five. I'm not sure what that means" (Nick,
## 2026-08-16). It meant 5 plus 2 for every Height between the hunters, and the
## "+" was the whole explanation. A telegraph that hides its own arithmetic is
## not a telegraph — so every move now prints the real figure and, where the
## number depends on where you are standing, says what to do about it.
##
## Which move kinds the intent tag's alarm styling (_set_intent) should treat
## as dangerous. backlog #86 duty 2: this used to be an inline list on
## _set_intent with no test of its own, and it silently omitted "frail" and
## "curse" (backlog #69) — real, targeted debuff moves (combat.gd's
## _enemy_turn hits players[boss_target_index()] with both, chipping Block or
## dumping a curse card in the hunter's discard pile) that combat_3d's OWN
## intent_text_for below already telegraphs with real numbers. A hunter would
## read the calm green/"safe" banner intent_text_for and _set_intent's caller
## both feed from, right before losing Block or gaining a junk card — the
## exact "two copies of one truth" this rotation's duty 2 hunts for: one list
## (what to print) got fixed for frail/curse, the sibling list (how alarming
## to make it look) did not.
static func intent_is_hostile(kind: String) -> bool:
	return kind in ["attack", "attack_all", "swipe_high", "swipe_low", "leech", "rift", "frail", "curse"]


## "⚔" (U+2694 CROSSED SWORDS) has no glyph in Godot's fallback font chain on
## this build and draws as a bare "×" — indistinguishable from a broken icon,
## on the one line that's supposed to be "the single most time-critical fact
## on the screen" (_party_card's own words). Confirmed with a probe render:
## every other symbol this file already leans on for the same HUD — ⚠ ⛨ ◈ ✦
## ↑, even the neighbouring ◆ ▲ ✚ ▼ for block/enrage/regen/frail two lines
## down — comes through clean; only this one codepoint is missing. † (U+2020
## DAGGER) is confirmed to render in the same probe and reads as "this will
## cut you" well enough paired with the move name it always sits beside.
const ATTACK_GLYPH := "†"


## backlog #86 duty 3 (twenty-fourth pass): lifted to a static, testable twin —
## this instance method's only non-pure input was _height_gap(s), so the whole
## body moves and the instance just supplies that one number. Writing the test
## found the match statement silently dropping two move types combat.gd
## actually resolves — "curse" (backlog #69) and "frail" (backlog #69) both
## have keyword entries and both fell through every branch to the blank
## `return ""` at the bottom, so a boss about to curse or weaken a hunter
## telegraphed nothing at all. Fixed in the same commit: a red test is not
## something this rotation commits.
static func intent_text_for(boss: Dictionary, height_gap: int) -> String:
	var move: Dictionary = boss.get("intent", {})
	var v := int(move.get("value", 0)) + int(boss.get("strength", 0))
	var kind := String(move.get("type", ""))
	var kw: Dictionary = Content.keyword(kind)
	if kw.is_empty():
		return ""
	var name := String(kw.get("name", kind))
	# The number, and nothing else. The move's NAME is the keyword; what it means
	# is a right-click away, the same deal the cards make (Nick, 2026-08-16: "it's
	# still giving a description for what the boss is gonna do").
	# Underlined, like every other keyword in the game, so it reads as something
	# you can ask about rather than as a label.
	var term := "[u]%s[/u]" % name
	match kind:
		"attack", "attack_all", "swipe_high", "swipe_low", "leech":
			return "%s %s %d" % [ATTACK_GLYPH, term, v]
		"rift":
			# The real total, gap included, the same way a card face shows what it
			# will actually do rather than the formula behind it.
			return "%s %s %d" % [ATTACK_GLYPH, term, v + height_gap * Combat.RIFT_PER_GAP]
		"block": return "◆ %s %d" % [term, int(move.get("value", 0))]
		"enrage": return "▲ %s %d" % [term, int(move.get("value", 0))]
		"regen": return "✚ %s %d" % [term, int(move.get("value", 0))]
		"shift_sigil": return "✦ %s — Height %d" % [term, int(move.get("value", 0))]
		"frail": return "▼ %s %d" % [term, int(move.get("value", 0))]
		"curse":
			# combat.gd's own resolution floors the card count at 1 even when
			# `value` is 0 — match that so the telegraph never promises zero
			# cards and then hands over one.
			return "☠ %s %d" % [term, maxi(int(move.get("value", 0)), 1)]
	return ""


func _intent_text(boss: Dictionary, s: Dictionary) -> String:
	return intent_text_for(boss, _height_gap(s))


## Height between the two hunters — what a rift is priced on.
##
## Lifted to a static, testable twin of Combat.incoming_for's rift branch in
## /core (combat.gd:511-519), which prices the SAME move with the SAME
## `maxi(0, hi - lo)` over `foothold`. That is a second copy of one truth —
## the intent HUD computes its own gap instead of reading the one /core
## already priced the move on — and the two had zero shared test coverage
## between them, so a formula edit on one side could silently mismatch the
## number a player is shown against the damage that actually lands.
static func height_gap_between(players: Array) -> int:
	if players.size() < 2:
		return 0
	var lo := 9999
	var hi := 0
	for p in players:
		var f := int((p as Dictionary).get("foothold", 0))
		lo = mini(lo, f)
		hi = maxi(hi, f)
	return maxi(0, hi - lo)


func _height_gap(s: Dictionary) -> int:
	return height_gap_between(s.get("players", []))


# --- the beast ------------------------------------------------------------

## Whether _show_beast needs to tear down and rebuild the beast — lifted out as
## a pure decision (backlog #86 duty 2) so run_tests.gd can prove shift_sigil
## does not retrigger it, with no scene tree needed. Gated on the boss's own
## id, not the height it would be rendered at: shift_sigil changes
## weak_point_height for the SAME beast mid-fight (see _beast_boss_id's own
## comment on the field), and that must not read as a new beast appearing.
static func beast_changed(beast_id: String, current_boss_id: String, beast_built: bool) -> bool:
	return beast_id != current_boss_id or not beast_built


func _show_beast(beast_id: String, beast_name: String, weak_point: int) -> void:
	if not beast_changed(beast_id, _beast_boss_id, is_instance_valid(_beast)):
		return
	_beast_boss_id = beast_id
	var key := _model_key(beast_id, beast_name)
	var want := BEAST_BASE_HEIGHT + BEAST_HEIGHT_PER_CLIMB * float(weak_point)
	_beast_id = key
	_beast_height = want
	if _beast != null:
		_beast.queue_free()
	var path := CAST + key + ".glb"
	var variant: String = model_variant if model_variant != "" \
		else ("" if classic else String(AI_ART.get(key, "")))
	_beast_toon = toon
	if variant != "" and ResourceLoader.exists(CAST + key + variant + ".glb"):
		path = CAST + key + variant + ".glb"
		_beast_toon = _beast_toon or AI_ART.has(key)
	if not ResourceLoader.exists(path):
		return
	_beast = (load(path) as PackedScene).instantiate()
	# Footholds baked into a model are gone — the stones float now (below), and
	# one set of rules for every boss beats a mesh each beast has to grow.
	for baked in _beast.find_children("Footholds*", "", true, false):
		baked.queue_free()
	_rig.add_child(_beast)
	_beast_anim = _find_anim(_beast)
	if _beast_anim != null and _beast_anim.has_animation("idle"):
		_beast_anim.get_animation("idle").loop_mode = Animation.LOOP_LINEAR
		_beast_anim.play("idle")
	_shade_model(_beast)
	_beast_scale = _fit_height(_beast, want)
	_beast_box = _merged_aabb(_beast)
	_read_climb_points()
	_build_float_stones()
	_build_hull()
	_build_ledge_marks()   # needs the hull, so it goes after it
	# Grow the arena with its occupant. A 9-unit disc was generous under a bear and
	# is a dinner plate under a Titan — it ran out mid-frame and left the bottom of
	# the shot as void, which reads as a hole rather than as ground.
	# How big the world is, from how TALL the beast is — not from how far it
	# sprawls. A Mire Snapper is mostly jaw and tail, so sizing the ground off its
	# footprint gave it a floor sixty units across and an apron the camera stood
	# inside; you could not see the beast for its own scenery. Height is the
	# measure that means something, with a floor under it so a long beast still
	# has ground beneath every part of itself.
	# The arena has to be big enough to actually HOLD the ground standoff
	# _place_hunters wants (ground_standoff_for below), or its own clamp there
	# (`_arena_r * 0.86`) silently overrides it back down — exactly what
	# cramped the Cinder Jackal's hunters against its legs (1.1-unit gap,
	# request 2026-09-23-1423). Dividing by that same 0.86 here is what
	# guarantees the clamp never has to bite.
	var want_r := maxf(_beast_height * 0.85,
		maxf(maxf(_beast_box.size.x, _beast_box.size.z) * 0.62,
			ground_standoff_for(_beast_box.end.z) / 0.86))
	_arena_r = want_r
	var ground := get_node_or_null("Ground") as CSGCylinder3D
	if ground != null:
		ground.radius = maxf(9.0, want_r)
	_show_env(beast_id, want_r, ground)
	_light_for(beast_id)
	_frame_beast()


## The ground this particular beast is fought on.
##
## Every Titan used to stand on the same blank grey disc, which is why the
## fights all looked like the same fight in a different costume — a beast reads
## as colossal only next to something, and "something" was one hunter and a
## circle.
##
## Same rule as the cast: `env/<beast_id>.glb` if you made one, nothing if you
## have not, and the plain disc stays underneath either way so a beast with no
## ground yet still has a floor. Making one is exporting a file. ENV_AI_ART
## beats the plain path the same way AI_ART beats a beast's own cast/<id>.glb.
## Light, per place.
##
## Nick, 2026-08-31: "one directional light and flat ambient make a stone golem
## and an ice wall the same value of pale grey."
##
## That was exactly it. Every fight ran the same neutral key over the same
## neutral ambient, so the palette did all the separating and the palette is
## deliberately flat — which left the Frost Sentinel's crevasse and the Bramble
## Hog's clearing the same washed-out value. Colour of LIGHT is the cheapest
## identity in the game: nothing is rebuilt, nothing is re-exported, and every
## screenshot changes.
##
## Each biome names a key colour and strength, the ambient it sits in, the fog
## that eats the distance, and the sky behind the wall. Read them as film stock,
## not as decoration — "cold overcast", "under a canopy", "lit by its own rift".
const BIOME := {
	"crag": {
		"key": Color(1.0, 0.94, 0.84), "energy": 1.20,
		"fill": Color(0.52, 0.64, 0.86), "ambient": Color(0.26, 0.31, 0.40),
		"fog": Color(0.38, 0.45, 0.55), "density": 0.007,
		"top": Color(0.34, 0.44, 0.62), "horizon": Color(0.70, 0.71, 0.68),
	},
	"quarry": {
		"key": Color(1.0, 0.88, 0.68), "energy": 1.30,
		"fill": Color(0.58, 0.62, 0.80), "ambient": Color(0.34, 0.29, 0.24),
		"fog": Color(0.52, 0.44, 0.34), "density": 0.008,
		"top": Color(0.44, 0.50, 0.62), "horizon": Color(0.82, 0.72, 0.55),
	},
	# Same place as "quarry" (bounder, stone_warden, gale_serpent, yoke_ox stay
	# on that one, untouched), but with the two things style C borrows from
	# candidate B: distance fog, purely for depth (Nick, 2026-09-24 — "take
	# C, and steal one thing from B: a light distance fog purely for depth,
	# not mood"), and now a cool dusk sky/ambient/fog (Nick, 2026-09-24 —
	# request #12: "the stones are pale, the ground is dark, the sky is cool
	# — purple into pink" — sampled straight off his reference image
	# (design/art/references/2026-09-24-nick-target-composition.webp): sky
	# top ~(52,58,104), the pink glow low in the sky ~(209,90,93)). `key`
	# stays quarry's own warm ember tone on purpose — the jackal's own heat
	# is what's supposed to read as the hottest thing in frame, against this
	# now-cool backdrop, not another warm light washing it out. `ambient`
	# and `fog` move off quarry's warm dust into the same cool dusk family
	# as the sky, or the ground/wall recolour below would sit in a
	# warm-tinted haze that undoes the point. Scoped to the Cinder Jackal
	# fight alone via BEAST_BIOME.
	"quarry_ember": {
		"key": Color(1.0, 0.88, 0.68), "energy": 1.30,
		"fill": Color(0.58, 0.62, 0.80), "ambient": Color(0.24, 0.22, 0.32),
		"fog": Color(0.34, 0.28, 0.38), "density": 0.014,
		"top": Color(0.20, 0.23, 0.41), "horizon": Color(0.80, 0.36, 0.38),
		# #19: at this beast's low, close ground camera, ProceduralSkyMaterial's
		# engine-default curves (sky 0.15 / ground 0.02) put the ENTIRE transition
		# from this horizon colour to sky_top/ground_bottom inside 1-2 screen rows
		# — the "hard red line", confirmed by elimination to be neither the Wall
		# mesh (still there with Wall AND Floor hidden), nor fog, nor the Wall's
		# texture filtering. Proven by direct measurement (recolouring the horizon
		# neon green made the line follow, isolating it to these two properties)
		# that ANY curve > ~0.0001 still renders as a hard edge at this camera's
		# per-pixel angular resolution — there is no "softer but still visible"
		# middle value here, only "hard line" or "smooth". 0.0 is the only value
		# that reads as a broad blend rather than a debug stripe; see
		# design/agents/requests/2026-09-24-2257-...-horizon-line.md for the
		# render-by-render elimination. Scoped to this biome only, not the shared
		# default, so a beast whose horizon never showed this artifact keeps
		# ProceduralSkyMaterial's normal falloff.
		"sky_curve": 0.0, "ground_curve": 0.0,
	},
	"forest": {
		"key": Color(1.0, 0.96, 0.74), "energy": 1.15,
		"fill": Color(0.42, 0.62, 0.48), "ambient": Color(0.18, 0.27, 0.20),
		"fog": Color(0.20, 0.32, 0.24), "density": 0.013,
		"top": Color(0.26, 0.40, 0.30), "horizon": Color(0.62, 0.70, 0.48),
	},
	"marsh": {
		"key": Color(0.92, 0.94, 0.70), "energy": 1.00,
		"fill": Color(0.46, 0.60, 0.52), "ambient": Color(0.21, 0.26, 0.21),
		"fog": Color(0.30, 0.35, 0.26), "density": 0.016,
		"top": Color(0.40, 0.46, 0.40), "horizon": Color(0.70, 0.70, 0.52),
	},
	"ice": {
		"key": Color(0.94, 0.97, 1.0), "energy": 1.10,
		"fill": Color(0.55, 0.72, 1.0), "ambient": Color(0.28, 0.37, 0.50),
		"fog": Color(0.48, 0.60, 0.74), "density": 0.010,
		"top": Color(0.42, 0.58, 0.78), "horizon": Color(0.86, 0.91, 0.96),
	},
	"ruin": {
		"key": Color(1.0, 0.85, 0.62), "energy": 1.20,
		"fill": Color(0.48, 0.58, 0.78), "ambient": Color(0.29, 0.27, 0.26),
		"fog": Color(0.40, 0.36, 0.32), "density": 0.010,
		"top": Color(0.38, 0.42, 0.52), "horizon": Color(0.78, 0.70, 0.58),
	},
	"drowned": {
		"key": Color(0.66, 0.90, 0.94), "energy": 1.05,
		"fill": Color(0.30, 0.58, 0.66), "ambient": Color(0.14, 0.27, 0.31),
		"fog": Color(0.12, 0.30, 0.34), "density": 0.019,
		"top": Color(0.16, 0.34, 0.42), "horizon": Color(0.40, 0.62, 0.64),
	},
	"rift": {
		"key": Color(0.84, 0.72, 1.0), "energy": 1.05,
		"fill": Color(0.62, 0.42, 0.86), "ambient": Color(0.23, 0.19, 0.33),
		"fog": Color(0.24, 0.18, 0.36), "density": 0.014,
		"top": Color(0.22, 0.18, 0.36), "horizon": Color(0.58, 0.42, 0.68),
	},
}

## Which place each beast is fought in. Anything unlisted gets "crag", which is
## the neutral daylight the game had before — a new beast looks no worse than it
## used to until someone picks it a home.
const BEAST_BIOME := {
	"crag_pup": "crag", "sky_snapper": "crag", "boulder_ram": "crag",
	"bounder": "quarry", "stone_warden": "quarry", "gale_serpent": "quarry",
	"cinder_jackal": "quarry_ember", "yoke_ox": "quarry",
	"bramble_hog": "forest", "root_lurker": "forest", "grove_bear": "forest",
	"flicker_stag": "forest", "silk_widow": "forest", "eyrie_hawk": "forest",
	"mire_snapper": "marsh", "bog_leech": "marsh", "clot_toad": "marsh",
	"riptide_eel": "marsh",
	"frost_sentinel": "ice",
	"shifting_idol": "ruin", "glyph_tortoise": "ruin", "husk_beetle": "ruin",
	"thrasher": "ruin",
	"drowned_colossus": "drowned", "sunken_warden": "drowned",
	"brine_urchin": "drowned",
	"riftling": "rift", "gloom_moth": "rift",
}

func _show_env(beast_id: String, want_r: float, ground: CSGCylinder3D) -> void:
	if _env != null:
		_env.queue_free()
		_env = null
	var path := ENV + beast_id + String(ENV_AI_ART.get(beast_id, "")) + ".glb"
	if beast_id == "" or not ResourceLoader.exists(path):
		if ground != null:
			ground.visible = true
		return
	_env = (load(path) as PackedScene).instantiate()
	_rig.add_child(_env)
	# The ground gets the same shader as its occupant. Nick, 2026-09-08: with only
	# the creatures shaded, a beast carried more finish than the arena it stood
	# in, which reads as two art passes in one frame.
	_shade_model(_env, true)
	# tools/blender/env.py builds every floor to ENV_RADIUS. Scaling by a
	# CONSTANT rather than by measured bounds is deliberate: an environment's
	# apron and props deliberately overhang its floor, so its bounds say nothing
	# useful about how big the floor is.
	_env.scale = Vector3.ONE * (want_r / ENV_RADIUS)
	_rig.move_child(_env, 0)
	if ground != null:
		# The disc would z-fight with the floor sitting on top of it.
		ground.visible = false


## Scale a freshly added model so it stands `want` units tall, and report the
## factor used. Measured, so it holds for any mesh from any source.
## Put the fight in a place, with light.
func _light_for(beast_id: String) -> void:
	var name: String = String(BEAST_BIOME.get(beast_id, "crag"))
	var b: Dictionary = BIOME.get(name, BIOME["crag"])
	# The creatures' rim belongs to the same lighting decision as the sun and the
	# fog, so it is set here rather than left on whatever biome was loaded when
	# the models happened to be built.
	_tint_rims()
	var sun := get_node_or_null("%Sun") as DirectionalLight3D
	if sun != null:
		sun.light_color = b["key"]
		sun.light_energy = float(b["energy"])
	var fill := get_node_or_null("%Fill") as DirectionalLight3D
	if fill != null:
		fill.light_color = b["fill"]
	var we := get_node_or_null("WorldEnvironment") as WorldEnvironment
	if we == null or we.environment == null:
		return
	var e: Environment = we.environment
	e.ambient_light_color = b["ambient"]
	e.fog_light_color = b["fog"]
	e.fog_density = float(b["density"])
	# The sky still shows above the wall, and a warm horizon over a blue-lit ice
	# crevasse is the sort of mismatch that reads as "engine default" even when
	# everything else is right.
	var sky: Sky = e.sky
	if sky != null and sky.sky_material is ProceduralSkyMaterial:
		var m: ProceduralSkyMaterial = sky.sky_material
		m.sky_top_color = b["top"]
		m.sky_horizon_color = b["horizon"]
		m.ground_horizon_color = b["horizon"]
		# ProceduralSkyMaterial's own engine defaults (0.15 / 0.02) unless a
		# biome overrides them (#19) — every beast but the jackal keeps the
		# falloff it always had.
		m.sky_curve = float(b.get("sky_curve", 0.15))
		m.ground_curve = float(b.get("ground_curve", 0.02))
	_dev_biome = name


func _fit_height(node: Node3D, want: float) -> float:
	var raw := _merged_aabb(node).size.y
	var factor: float = want / maxf(raw, 0.001)
	node.scale = Vector3.ONE * factor
	return factor


## Frame a SLICE of the world, not the whole animal.
##
## The old version fitted the entire body, which is why the beasts never felt big:
## fitting is normalising, and a normalised colossus is a bear. Now the camera
## shows a roughly constant window of world, so how much of a beast is visible IS
## how big it is. A Crag Pup fits inside the window; the Sunken Warden runs off
## the top of the screen and you meet it a stretch at a time.
func _frame_beast() -> void:
	var tall := maxf(_beast_box.size.y, 1.0)
	var window := _window_for(tall * 1.18)
	_working_dist = _dist_for_window(window)
	_yaw = 0.0          # a new beast is always introduced from the front
	_yaw_target = 0.0
	_user_framed = false
	_free_cam_engaged = false
	_lock_slot = _me()
	_pan = Vector3.ZERO
	# A new beast is still met WIDE — the establishing shot is the one moment you
	# get to see the whole thing — but the camera no longer waits to be asked to
	# come in. Nick, 2026-09-09: "make the camera mainly 3rd person." So the wide
	# is now a beat, not a mode: `_settle_third` below drops into the over-the-
	# shoulder shot the instant the establishing push finishes.
	_focused = false
	_want_third = true
	# Open on the whole creature, however far back that has to be, then fall in to
	# the working shot. You get to see what you've picked a fight with once —
	# after that, the climb is the subject and the rest of it is off-screen.
	_dist = _dist_for_window(_window_for(tall * 1.35))
	_free_dist_target = _dist
	_establishing = _dist > _working_dist + 0.1
	_pivot = Vector3(0.0, _ground_pivot(window), 0.0)
	_pivot_target = _pivot
	_pitch = 0.24
	_pitch_target = _pitch
	_apply_orbit()


## Walk the camera, on the keys, wherever you want it.
##
## The orbit could always TURN, and right-drag could slide it, but it stayed tied
## to a point — you could look at the fight from any angle and never go anywhere
## (Nick, 2026-08-24: "currently its locked to a fix point"). WASD moves it, E/Q
## lift and drop it.
##
## Movement is on the ground plane rather than along the lens, so holding W walks
## toward what you are facing instead of burrowing into the floor when you happen
## to be looking down. Picking a hunter puts it back.
func _fly(delta: float) -> void:
	# Same local-dev-tool gate as the drag/pan/zoom controls in
	## _unhandled_input — WASD/QE is the other half of the free camera.
	if not free_camera_allowed(OS.is_debug_build(), Progress.dev_camera_enabled()):
		return
	var overlay := _detail != null and is_instance_valid(_detail)
	if _rebinding != "" or DevConsole.open or overlay:
		return                       # a menu owns the keyboard
	if _cam == null:
		return
	var step := Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		step.z += 1.0
	if Input.is_key_pressed(KEY_S):
		step.z -= 1.0
	if Input.is_key_pressed(KEY_D):
		step.x += 1.0
	if Input.is_key_pressed(KEY_A):
		step.x -= 1.0
	if Input.is_key_pressed(KEY_E):
		step.y += 1.0
	if Input.is_key_pressed(KEY_Q):
		step.y -= 1.0
	if step == Vector3.ZERO:
		return
	_take_manual_control()
	var b := _cam.global_transform.basis
	var fwd := Vector3(-b.z.x, 0.0, -b.z.z)
	fwd = fwd.normalized() if fwd.length() > 0.001 else Vector3.FORWARD
	var right := Vector3(b.x.x, 0.0, b.x.z)
	right = right.normalized() if right.length() > 0.001 else Vector3.RIGHT
	var speed := FLY_SPEED * maxf(_dist, 4.0) * delta
	_pan += (fwd * step.z + right * step.x + Vector3.UP * step.y) * speed
	# Walk the camera anywhere inside the arena, and nowhere outside it. The
	# orbit clamp alone is not enough: it holds the ORBIT, and flying moves
	# the point the orbit is around, so W held down would carry the pivot
	# out through the wall and take the lens with it.
	var flat := Vector2(_pan.x, _pan.z)
	var room := maxf(_arena_r * 0.80, 1.0)
	if flat.length() > room:
		flat = flat.normalized() * room
		_pan.x = flat.x
		_pan.z = flat.y
	# Not up over the wall's top either, or you look down on the whole arena
	# and straight out at the sky beyond it.
	_pan.y = clampf(_pan.y, -_arena_r * 0.2, _arena_r * 0.9)


## Ride the camera up the beast as the hunter climbs. Smoothed rather than
## snapped, because the drift IS the feedback — a cut would just teleport you and
## you'd learn nothing about how far up you are.
##
## Only the AIM is automatic. Distance and angle stay the player's once they've
## touched them, so following the action can never wrestle the orbit away.
func _track_climb(delta: float) -> void:
	_aim_camera(delta, false)


## Settle the camera instantly, wherever it was easing to.
##
## For the screenshot harness: it drives frames far faster than real time, so a
## time-based ease can never finish there and every shot would show a camera
## caught mid-glide. Called twice because the ground framing reads the current
## distance, so one pass leaves it one step behind.
func snap_camera() -> void:
	_aim_camera(0.0, true)
	_aim_camera(0.0, true)


## Where the camera is locked, on the ground plane: (x, z) of the hunter you are
## holding. The frame answers "who am I?" without a label — and answers it by
## MOVING, which is the part a static badge cannot do.
##
## It does NOT yield to _user_framed any more, and that was the bug. The moment
## you looked around, selecting a hunter stopped moving the camera at all — so the
## one gesture that should always answer "who am I?" went dead at exactly the
## moment the shot was least familiar. Free look owns the ANGLE and the DISTANCE;
## the lock owns what you are angled at.
##
## Both x and z, not just x: under a rotated yaw a hunter's screen position is no
## longer a function of world x alone, so an x-only lock silently stops centring
## anyone the moment you orbit.
func _lock_point() -> Vector2:
	if _hunters.is_empty():
		return Vector2.ZERO
	var slot := lock_slot_for(_lock_slot, _hunters.size(), _me())
	if slot < 0 or slot >= _hunters.size():
		return Vector2.ZERO
	var home := _hunters[slot]["home"] as Vector3
	return Vector2(home.x, home.z) * CAMERA_LOCK


## Which hunter slot the camera should actually track: the explicit lock, if it
## still points at a real hunter, else fall back to your own slot. Backlog #86
## duty 3 -- this exact fallback used to be three separate copies of the same
## expression (here, _focus_camera and _aim_camera below), each written out
## inline, and none of them had a test: the rule that decides WHO the camera
## follows every time you switch hunters or tap Focus had zero coverage. Static
## and pure so run_tests.gd can drive the whole fallback chain -- explicit lock,
## lock gone stale, lock never set -- with no scene tree and no hunters spawned.
## Is the hunter the camera follows mid-jump right now? Its climb tween is
## what "in the air" means - the same tween _hop drives.
func _followed_is_airborne() -> bool:
	var fs: int = lock_slot_for(_lock_slot, _hunters.size(), _me())
	return fs >= 0 and _tween_is_live(_climb_tw.get(fs) as Tween)


static func lock_slot_for(lock_slot: int, hunter_count: int, me: int) -> int:
	if lock_slot >= 0 and lock_slot < hunter_count:
		return lock_slot
	return me


## The single gate _unhandled_input and _fly both call before letting the
## free camera (drag/pan/zoom/WASD) touch anything — see their own doc
## comments, and request 2026-09-23-1423-nick-to-fixer-stones-camera-and-
## hunter-spacing.md. Takes the OS call as a parameter, like every other pure
## rule in this file, rather than reading OS.is_debug_build() itself, so
## run_tests.gd can pin the identity down (true stays allowed, false stays
## blocked) with no exported Release build to actually flip that value —
## nothing in the agents' sandbox can produce one. That does not prove
## OS.is_debug_build() itself reads false in a real Steam export (verify
## that once a build exists to check); it proves the RULE built on top of it
## is not accidentally inverted.
##
## dev_camera_enabled is the Menu's Camera: Dev / Player toggle (request
## 2026-09-24-2155, Progress.dev_camera_enabled) — false wins even in a debug
## build, which is the whole point: it is what lets Nick, who always plays a
## debug build through tools/dev.cmd, see the exact locked camera a player
## gets without needing an exported Release template to check it in.
static func free_camera_allowed(is_debug_build: bool, dev_camera_enabled: bool) -> bool:
	return is_debug_build and dev_camera_enabled


func _aim_camera(delta: float, snap: bool) -> void:
	if _client == null or _beast == null:
		return
	var want := _climb_frame()
	var lock := _lock_point()
	_pivot_target.y = want.x + _pan.y
	if _focused:
		# Aim at the hunter and keep aiming at them, so the close shot rides up
		# the body as they climb instead of sliding back to the beast's framing.
		var fs: int = lock_slot_for(_lock_slot, _hunters.size(), _me())
		if fs >= 0 and fs < _hunters.size():
			_pivot_target.y = float((_hunters[fs]["home"] as Vector3).y) \
				+ HUNTER_HEIGHT * 1.2 + _focus_lift + _pan.y
	_pivot_target.x = lock.x + _pan.x
	_pivot_target.z = lock.y + _pan.z
	# A camera that rises exactly as fast as the jumper shows no jump at all:
	# the hunter stays pinned to the same pixel and only the background moves.
	# So hold the vertical aim while they are in the air, and settle on the new
	# height once they land - Mario Odyssey holds Y through a jump; SMW/DKC pan
	# only after touchdown. `home` is already the LANDING spot, so the target
	# below is exactly where the camera eases to the moment the hop ends.
	if not snap and _followed_is_airborne():
		# ... but only while they stay inside a window. Holding it flat sent a
		# long Leap clean off the top of the screen (playtest check
		# 'hunter-offscreen', 2026-09-23). This is the dead zone every camera
		# source pairs with the hold: free movement in the middle band, and the
		# camera only starts following once the jumper reaches its edge.
		var fs2: int = lock_slot_for(_lock_slot, _hunters.size(), _me())
		if fs2 >= 0 and fs2 < _hunters.size():
			var node2 := _hunters[fs2]["node"] as Node3D
			if is_instance_valid(node2):
				var eye := node2.position.y + HUNTER_HEIGHT * 1.2 + _focus_lift
				var span: float = _jump_hi - _jump_lo
				if span > THIRD_WINDOW * 0.55:
					# BIG LEAP: frame the whole arc at once — aim at the middle
					# of the band the jump covers and open the shot to hold it.
					# One shot for the flight beats chasing, which always lands
					# late; on this Titan a Leap is taller than the frame.
					_pivot_target.y = (_jump_lo + _jump_hi) * 0.5 + _focus_lift * 0.5
					_air_span = span
				else:
					# SMALL HOP between stones: hold still and let them move
					# inside a dead zone — a camera that rises with the jumper
					# shows no jump at all.
					var dead := THIRD_WINDOW * 0.18
					_pivot_target.y = clampf(_pivot.y, eye - dead, eye + dead)
					_air_span = 0.0
				_air_chase = true
		_air_settle = 0.45   # keep the stiffer follow briefly after touchdown
	elif not snap:
		# The stiff follow outlives the jump by a beat: a big climb lands with
		# the camera still metres behind, and easing that last gap at the lazy
		# rate left the hunter off the top of the frame after landing
		# (playtest 'hunter-offscreen', 2026-09-23).
		_air_settle = maxf(_air_settle - delta, 0.0)
		_air_chase = _air_settle > 0.0
		if _air_settle <= 0.0:
			_air_span = 0.0
	var grounded := not _user_framed and not anyone_off_ground(_hunters)
	if not _user_framed:
		# THE CAMERA DOES NOT FIT THE BEAST, on the ground or up its side. It
		# stands a fixed distance behind the active hunter and lets the beast
		# be however big it happens to be from there, and it follows every hop.
		#
		# Nick, 2026-09-24, with a drawing: the hunter is close to camera in the
		# foreground and the beast is far away across a wide gap. Fitting the
		# beast to the frame makes that picture impossible to reach -- the fixer
		# proved it by hand, pushing the hunter from z=26 to z=544 and finding
		# the composition unchanged at every step, because a window sized off
		# the beast's height simply zooms back out by however much you moved.
		# The gap can only appear if the camera stops compensating for it.
		#
		# Never further out than the wall. This is where the enclosure stops
		# being scenery and starts being a rule: the framing maths would
		# happily ask for 30 units on a Titan in a 17-unit arena, and did.
		_working_dist = minf(ACTIVE_HUNTER_DIST, _cam_reach())
		if grounded:
			var gs: int = lock_slot_for(_lock_slot, _hunters.size(), _me())
			if gs >= 0 and gs < _hunters.size():
				_pivot_target.y = float((_hunters[gs]["home"] as Vector3).y) \
					+ HUNTER_HEIGHT * GROUND_VIEW_EYE + _pan.y
	elif _focused and _air_span > THIRD_WINDOW * 0.55:
		# A focused shot owns its own distance (_user_framed), but a leap taller
		# than a third of the frame cannot be watched from inside it — let the
		# camera out far enough to hold the whole arc, then the landing framing
		# pulls it back in.
		_working_dist = minf(_dist_for_window(_air_span * 1.25), _cam_reach())
		_dist = lerpf(_dist, _working_dist, 1.0 - exp(-delta * 6.0))
	if snap:
		_pivot = _pivot_target
		if not _user_framed:
			_dist = _working_dist
		_establishing = false
	else:
		if _establishing or (not _user_framed and absf(_dist - _working_dist) > 0.02):
			_dist = lerpf(_dist, _working_dist, 1.0 - exp(-delta * 1.6))
			if _establishing and absf(_dist - _working_dist) < 0.05:
				_establishing = false
		if _pivot.distance_to(_pivot_target) > 0.005 or _establishing:
			# frame-rate independent ease: the same feel at 30fps and 144. A
			# jump already past the dead zone gets a much stiffer follow, or
			# the camera arrives after the hunter has landed.
			_pivot = _pivot.lerp(_pivot_target, 1.0 - exp(-delta * (9.0 if _air_chase else 3.2)))
	# Once the establishing push has landed, fall in behind the active hunter
	# without being asked. Deliberately AFTER the ease above rather than at fight
	# start: cutting straight to the shoulder shot throws away the one moment the
	# player gets to see the size of the thing they picked a fight with.
	# The over-the-shoulder truck, eased. Off for the establishing wide (that shot
	# is of the BEAST, and trucking would slide it off centre), and off while a
	# jump is being framed whole — mid-arc the subject is the arc, not a shoulder.
	# On the ground it is on too (director, 2026-09-24 22:56): the resting shot
	# is over-the-shoulder like the climbing one, not a dead-centre lock, or the
	# hunter/stones/beast all sit on one vertical line and the depth reads as
	# height instead of distance.
	var want_ots := want_shoulder_truck(_focused, grounded, _establishing, _air_chase,
			_air_span, THIRD_WINDOW)
	if snap:
		_shoulder = want_ots
	else:
		_shoulder = lerpf(_shoulder, want_ots, 1.0 - exp(-delta * 2.2))
	if _want_third and not _establishing and not _user_framed and not _hunters.is_empty():
		_want_third = false
		# 0.20, measured against the card fan rather than guessed. At 0.30 the
		# hunters landed at y=538 on a 720 frame, which is behind the hand; at 0
		# they sat dead centre with half the screen given to floor. 0.20 puts
		# them just clear of the cards with the beast owning the rest.
		_focus_camera(THIRD_WINDOW, 0.20)
		return
	if not _user_framed:
		if grounded:
			# The Risk of Rain shot (director, 2026-09-24 22:56 / Nick, 22:25):
			# a touch above the active hunter, looking slightly down at their
			# back, not tilted up at the beast the way the climb does.
			_pitch = GROUND_VIEW_PITCH
		else:
			# Tilted up at the base, flattening out as you gain height — and only ever
			# flattening. A camera that tips DOWN at the top looks at a Titan's scalp,
			# which reads as a floor; near-level keeps the silhouette against the sky,
			# and a silhouette is what makes something look big.
			_pitch = lerpf(ORBIT_PITCH_MIN, 0.10, _climb_t)
	if _free_cam_engaged and _user_framed:
		# The dev free camera (request 2026-09-25-0956): _unhandled_input above
		# only moves the *_target values now, so this is the one place that
		# actually moves _yaw/_pitch/_dist, chasing them with the same damped-
		# exponential shape _pivot/_dist already use elsewhere. Gated on BOTH
		# flags, not just _user_framed, so the locked player camera's own
		# _focus_camera (which also sets _user_framed, for a climbing hunter)
		# keeps moving _pitch/_dist directly and unchased, exactly as before —
		# and so a harness reset that clears _user_framed (screenshot.gd's
		# 3dfreecam sweep) turns this back off too, even before _free_cam_engaged
		# itself is next cleared.
		if snap:
			_yaw = _yaw_target
			_pitch = _pitch_target
			_dist = _free_dist_target
		else:
			# "No drift after the hand comes off" (the ticket's own words) means
			# the exponential's tail has to actually END, not just shrink forever
			# — an un-snapped lerp never reaches its target and leaves a
			# vanishingly small nudge every single frame after release. Below
			# FREE_CAM_SETTLE, snap outright: it's a fraction of a degree /
			# world unit, below anything a player (or a threshold-based check
			# like screenshot.gd's own FREECAM sweep) can tell apart from zero.
			var ease := 1.0 - exp(-delta * FREE_CAM_EASE)
			_yaw = _yaw_target if absf(angle_difference(_yaw, _yaw_target)) < FREE_CAM_SETTLE \
				else lerp_angle(_yaw, _yaw_target, ease)
			_pitch = _pitch_target if absf(_pitch_target - _pitch) < FREE_CAM_SETTLE \
				else lerpf(_pitch, _pitch_target, ease)
			_dist = _free_dist_target if absf(_free_dist_target - _dist) < FREE_CAM_SETTLE \
				else lerpf(_dist, _free_dist_target, ease)
	_apply_orbit()


## Camera distance that makes `window` world-units of height fill the frame.
## Derived from the lens rather than hand-tuned, so changing fov can't silently
## break the framing.
## Camera distance that makes `window` world-units of height fill the frame.
##
## Measured from the beast's FRONT, not its centre. The orbit is anchored at the
## body's axis, but the hunters cling to its near face — on a Titan that's 5 units
## nearer the camera, so standing off by the window alone put the lens practically
## against them and threw both hunters off opposite edges of the screen.
## The window the camera must hold for `want` world-units to stay visible ABOVE the
## card strip, clamped to the framing range.
static func _window_for(want: float) -> float:
	return clampf(want / (1.0 - HUD_BOTTOM_FRACTION), VIEW_WINDOW_MIN, VIEW_WINDOW_MAX)


## How far to lift the aim so the subject sits in the clear band rather than centred
## on a screen whose bottom third is cards.
## Aim so the GROUND lands on the top edge of the card strip.
##
## Both ground shots want this and neither used to have it. Aiming lower left a
## Titan's feet floating a third of the way up the screen with a dead lane of desert
## under them; aiming higher pushed a lesser beast's whole body behind the hand. One
## rule fixes both: the beast stands ON the cards, so every pixel of clear screen is
## beast, and anything too tall to fit runs off the top — which is the whole point.
##
## Derivation: for world y=0 to sit at screen fraction (1 - HUD_BOTTOM_FRACTION),
## the pivot must be (0.5 - HUD_BOTTOM_FRACTION) * window. The small margin keeps
## the feet just clear of the card edge rather than tangent to it.
## Where an over-the-shoulder lens sits and what it looks at.
##
## `amount` is the eased 0..1 blend. Returns the sideways truck to ADD to an
## orbit camera's position, and the point to aim at: the pivot slid horizontally
## toward the beast, never vertically (the jump owns the vertical).
##
## How many climb rungs this beast has, and where one sits in that order.
## Both are tiny, but they are asked for in two places (the stones and the
## hunters) and the two MUST agree or a hunter lands beside its own stone.
func _rung_count() -> int:
	var n := 0
	for h in _climb_points.keys():
		if int(h) > 0:
			n += 1
	return n


## Where the highest rung sits on the body -- the end of the route, and the one
## hold that is still ON the beast. `side` shifts it the same way
## stand_offset_x always has (Nick, 2026-09-25: "two sets of stones, one set
## for each character") -- default 0.0 keeps every existing caller centred.
func _top_hold(side: float = 0.0) -> Vector3:
	var top := 0
	for h in _climb_points.keys():
		top = maxi(top, int(h))
	var p: Vector3 = foothold_anchor(_climb_points, top)
	var x: float = stand_offset_x(p.x, side, _beast_box.size.x)
	return stone_point(Vector3(x, p.y, p.z))


func _rung_index(foot: int) -> int:
	var rungs: Array[int] = []
	for h in _climb_points.keys():
		if int(h) > 0:
			rungs.append(int(h))
	rungs.sort()
	var i := rungs.find(foot)
	# An off-anchor height (mid-climb, between two rungs) sits at the nearest
	# rung below it rather than snapping to the start of the route.
	if i == -1:
		for k in range(rungs.size()):
			if rungs[k] <= foot:
				i = k
	return maxi(i, 0)


## Static and pure so the composition can be proven headless: truck right of the
## lens axis, aim left of the hunter, and at amount 0 both reduce to exactly the
## old shot.
static func shoulder_frame(pivot: Vector3, yaw: float, dist: float,
		amount: float) -> Dictionary:
	var a := clampf(amount, 0.0, 1.0)
	# The camera's own right on the ground plane. The orbit puts the lens at
	# pivot + (sin yaw, ., cos yaw) * dist, so it looks along -(sin yaw, 0, cos yaw)
	# and its right is (cos yaw, 0, -sin yaw).
	var right := Vector3(cos(yaw), 0.0, -sin(yaw))
	return {
		"truck": right * (SHOULDER_TRUCK * dist * a),
		"aim": pivot + right * (SHOULDER_AIM * dist * a),
	}


static func _ground_pivot(window: float) -> float:
	return window * (0.5 - HUD_BOTTOM_FRACTION + 0.04)


## The lens/standoff maths lifted out below, taking the three instance fields
## it actually reads (fov, beast front, pivot z) as arguments so it can be
## proven from headless without a Camera3D or a built beast model.
static func dist_for_window_for(window: float, fov_deg: float, beast_front_z: float,
		pivot_target_z: float) -> float:
	var lens := maxf(window, 1.0) / (2.0 * tan(deg_to_rad(fov_deg) * 0.5))
	# Stand off from the beast's FRONT rather than its centre — but only by the
	# part the pivot has not already covered. Locking onto a hunter puts the pivot
	# out on that front face, and charging the whole standoff on top of it would
	# back the camera off by the beast's depth twice over.
	return lens + maxf(beast_front_z * 0.85 - pivot_target_z, 0.0)


func _dist_for_window(window: float) -> float:
	return dist_for_window_for(window, _cam.fov, _beast_box.end.z, _pivot_target.z)


## The climbing camera's own stand-off: ACTIVE_HUNTER_DIST, fixed, plus the
## same beast-front clearance dist_for_window_for's standoff term adds -- a
## hold near the front face needs none, one buried in the climb (near the top
## of a reared-up beast) still needs the lens pulled back far enough to clear
## the mesh, or the camera renders from inside it. Static and pure so this
## exact rule -- one fixed number, not a window fit around the beast's own
## height -- is provable headless (Nick, 2026-09-25: "camera closer, should
## be locked to character").
static func climb_dist_for(beast_front_z: float, pivot_z: float) -> float:
	return ACTIVE_HUNTER_DIST + maxf(beast_front_z * 0.85 - pivot_z, 0.0)


## Whether any hunter has left the ground — the same 0.05 epsilon
## climb_frame_for's own "nobody has climbed yet" branch uses on `home.y + eye`
## (eye being a constant added to every hunter alike, so it drops out of a
## bare `home.y` comparison). Pulled out as its own pure check (request #11)
## so _focus_camera can ask this directly rather than trust `_climb_t` — a
## field `_aim_camera` alone refreshes, so it reads stale (its default 0.0,
## whatever the real hunters are doing) the moment anything calls
## _focus_camera before `_aim_camera` has run even once, e.g. straight off a
## freshly built view in a test.
static func anyone_off_ground(hunters: Array) -> bool:
	for h in hunters:
		if float((h["home"] as Vector3).y) >= 0.05:
			return true
	return false


## Whether the over-the-shoulder truck should be engaged this frame: while
## climbing (`focused`) exactly as before, and now also at rest (`grounded`) --
## the Risk of Rain shot (director, 2026-09-24 22:56 EDT, relaying Nick 22:25
## EDT) is over-the-shoulder on the active hunter at rest AND mid-climb, not a
## dead-centre lock only while climbing. Off during the establishing wide (that
## shot is of the beast, trucking would slide it off centre) and while a big
## leap is framed whole (mid-arc the subject is the arc, not a shoulder),
## exactly as the climbing case already required.
static func want_shoulder_truck(focused: bool, grounded: bool, establishing: bool,
		air_chase: bool, air_span: float, third_window: float) -> float:
	return 1.0 if ((focused or grounded) and not establishing and not air_chase
			and air_span <= third_window * 0.55) else 0.0


## What the camera should be looking at, and how much world to fit around it:
## returns (focus height, window height).
##
## Two different shots, because the fight has two different subjects.
##
## On the ground the subject is the BEAST: aim low, near your hunters' own eye
## level, and let the body rear up out of the top of the frame. (Aiming at its
## middle instead is what made it look like a pet.)
##
## Once anyone is climbing, the subject is the HUNTERS: frame the pair, biased
## toward the one you're playing but never dropping the other. Aiming at the
## active hunter alone put a Titan's blank scalp on screen and lost the ally off
## the edge — and "where is my partner" is the question this game is about.
func _climb_frame() -> Vector2:
	var tall := maxf(_beast_box.size.y, 1.0)
	var eye := HUNTER_HEIGHT * 0.6
	var ys: Array[float] = []
	for h in _hunters:
		ys.append(float((h["home"] as Vector3).y) + eye)
	var sigil_visible := _sigil != null and _sigil.visible
	var sigil_y := _sigil.position.y if sigil_visible else 0.0
	var out := climb_frame_for(tall, ys, _me(), sigil_visible, sigil_y)
	_climb_t = out.z
	return Vector2(out.x, out.y)


## Pure half of _climb_frame above, lifted out (backlog #86 duty 3) so it's
## provable headless, with no beast, camera or scene tree — the climb camera
## framing had zero coverage of its own despite being exactly where "where is
## my partner" (bugs.md, 2026-09-05: the ally hunter thrown off three separate
## camera frames) actually lives. `ys` is every hunter's eye-line height
## (already `home.y + eye`, same as the caller builds); `active_slot` indexes
## it the way `_me()` does. Returns (focus height, window height, climb_t) —
## climb_t is the same 0..1 "how far up the beast" ratio `_climb_frame` used to
## set as a side effect, folded into the return here instead of split across
## two places that have to agree.
static func climb_frame_for(tall: float, ys: Array, active_slot: int,
		sigil_visible: bool, sigil_y: float) -> Vector3:
	var eye := HUNTER_HEIGHT * 0.6
	if ys.is_empty():
		var w0 := _window_for(tall * 1.18)
		return Vector3(_ground_pivot(w0), w0, 0.0)
	var lo: float = ys.min()
	var hi: float = ys.max()
	if hi < eye + 0.05:  # nobody has left the ground
		var window := _window_for(tall * 1.18)
		# A beast small enough to fit the window is met face to face — cropping a
		# Crag Pup's head isn't imposing, it just looks like a mistake. Only the
		# ones too big to hold get the looming shot, which makes towering a thing
		# the act Titans do rather than something every fight does.
		return Vector3(_ground_pivot(window), window, 0.0)
	var active: float = ys[active_slot] if active_slot < ys.size() else hi
	var climb_t := clampf(active / maxf(tall * 0.55, 1.0), 0.0, 1.0)
	# Look a little way up the road — from where YOU are, not from wherever the
	# party's highest climber got to. Framing purely on hunters put the sigil just
	# off the top of the screen for the whole ascent, so you climb toward a target
	# you can't see. Headroom is capped, so from partway up a Titan the weak point
	# is still over the horizon of the frame (honest, and part of why it feels
	# tall), but it slides into view as you close on it.
	#
	# Strictly after the ground test: applied before it, a hunter standing at the
	# feet already "sees" 3 units of headroom, the ground branch never fires, and
	# the looming shot this whole change exists for is silently lost.
	if sigil_visible:
		hi = maxf(hi, minf(sigil_y, active + 3.0))
	# Enough air around the pair to read the body they're clinging to, then aim so
	# the HIGHER hunter lands around 42% down the frame rather than centred. The
	# top ~200px belong to the grip bar and the coach, and the higher hunter is
	# usually the one at the sigil — centre the pair and the payoff of the whole
	# climb sits behind a HUD panel. Framing off the top hunter also means the
	# lower one is always below them, so both stay on screen by construction.
	# The offset is bigger than "half the frame" arithmetic suggests, and measured
	# rather than derived: hunters cling to the FRONT of the body, much nearer the
	# camera than the pivot plane, so parallax throws them further from centre than
	# their world height alone predicts. tools/screenshot.gd prints where they
	# actually land — tune this against that, not against algebra.
	var window := _window_for((hi - lo) * 1.5 + 4.0)
	# When a carry is going well the pair can be most of a Titan apart — further
	# than any window that still feels big. Something has to fall off the edge, and
	# it is never the hunter whose cards you are holding. This clamp pins the
	# active hunter inside the middle 60% of frame; the ally can drift off, which
	# is itself the read that they are a very long way below you. The party panel
	# still has their HP and Height.
	# Climbing: the subject is the hunters, so bias the pair into the clear band
	# above the hand rather than the middle of the whole screen.
	var focus := clampf(hi - window * (0.19 + HUD_BOTTOM_FRACTION * 0.5),
		active - window * 0.30, active + window * 0.30)
	return Vector3(focus, window, climb_t)


## Spherical position around the beast. Everything else (shake, the strike flash)
## composes on top of _cam_home, so the orbit is the only thing that decides
## where the camera fundamentally is.
## The furthest the lens may get from the middle of the arena, on the flat.
##
## This is what makes the wall mean something. The geometry alone cannot enclose
## anything — a camera is not stopped by a mesh — so the wall and this number are
## one feature in two files, and CAMERA_MAX_R vs env.ENCLOSE_CLEAR is the seam.
##
## Lifted to a static, testable twin (backlog #86 duty 3) — `_arena_r` was the
## only non-pure input either of these two functions ever read, so passing it
## in explicitly makes both provable headless, with no camera or scene tree.
## Nothing had ever pinned that the reach scales with the arena, floors at 1.0
## for a degenerate/unset radius, or that the wall clamp actually preserves
## height and direction while pulling the flat radius in — exactly the shape
## of bug that would send the lens straight through the arena wall with
## nothing on screen to say why.
static func cam_reach_for(arena_r: float) -> float:
	return maxf(arena_r, 1.0) * CAMERA_MAX_R


static func inside_wall_at(p: Vector3, arena_r: float) -> Vector3:
	var flat := Vector2(p.x, p.z)
	var reach := cam_reach_for(arena_r)
	if flat.length() > reach:
		flat = flat.normalized() * reach
	return Vector3(flat.x, p.y, flat.y)


func _cam_reach() -> float:
	return cam_reach_for(_arena_r)


## Pull a camera position back inside the wall, keeping its direction.
##
## Clamps the FLAT radius only. Height is left alone: looking down into the
## arena from up near the wall's top is a shot worth having, and it cannot see
## out past anything.
func _inside_wall(p: Vector3) -> Vector3:
	return inside_wall_at(p, _arena_r)


func _apply_orbit() -> void:
	_pitch = clampf(_pitch, ORBIT_PITCH_MIN, ORBIT_PITCH_MAX)
	_dist = minf(_dist, _cam_reach())
	var flat := cos(_pitch) * _dist
	_cam_home = _pivot + Vector3(sin(_yaw) * flat, sin(_pitch) * _dist, cos(_yaw) * flat)
	var lift := _dist * lerpf(GROUND_LIFT, 0.0, _climb_t)
	# Never dip under the floor. Aiming low at the foot of something 13 units tall
	# drives the camera below y=0, and then you're looking up THROUGH the ground.
	# The lens shift is added in because Godot applies it after this, moving the
	# camera down by exactly that much.
	_cam_home.y = maxf(_cam_home.y, CAMERA_FLOOR + lift)
	# Stay inside the arena wall. Without this the orbit happily walks the
	# lens out past the scenery and the fight goes back to being a plate in
	# an open sky, however much wall env.py built.
	var ots := shoulder_frame(_pivot, _yaw, _dist, _shoulder)
	_cam_home = _inside_wall(_cam_home + (ots["truck"] as Vector3))
	_cam.position = _cam_home
	_cam.look_at(ots["aim"] as Vector3, Vector3.UP)
	# The hand rail owns the left edge, so the screen's centre is not the SCENE's
	# centre any more. h_offset trucks the camera sideways without re-aiming it, so
	# the beast sits in the middle of the space it actually has. It scales with
	# distance because that's what a fixed fraction of the frame costs in world
	# units — zoom in and the shift shrinks with it.
	# It earns its keep in the wide ground shot, where the beast is broad and the
	# rail would crowd it. Up on the body it mostly pushes the right-hand climber
	# toward the party panel, so it eases off as you climb.
	_cam.h_offset = -lerpf(SCENE_SHIFT, SCENE_SHIFT * 0.3, _climb_t) * _dist
	# Lens shift DOWN while you're at the beast's feet, which lifts everything in
	# frame — the hunters stop hugging the bottom edge without the camera having to
	# tilt down and lose the looming angle. Moving the pivot can't do this: it
	# carries the camera with it, so the ground stays exactly where it was. Fades
	# out as you climb, where the hunter should simply be centred.
	_cam.v_offset = -lift


## Drag anywhere the HUD didn't already claim. Cards and buttons are Controls, so
## they consume their own clicks before this ever runs — the hand and the camera
## never fight over the same drag.
## Swap to the next (or previous) beast in bosses.json, in place.
func _cycle_beast(step: int) -> void:
	if Session.host == null or Session.host._run == null 			or Session.host._run.combat == null:
		_dev_note("[ ] only work while the HOST is in a fight")
		return
	var ids: Array = Content.boss_ids()
	if ids.is_empty():
		return
	var here: int = ids.find(String(Session.host._run.combat.boss.id))
	var next: int = posmod(here + step, ids.size())
	var id := String(ids[next])
	Session.host._run.combat.boss = Content.build_boss(id)
	Session.host._broadcast_state()
	_dev_note("%d/%d  %s   —  [ and ] to change" % [next + 1, ids.size(),
		Content.build_boss(id).name])


## A line of text at the top of the screen that goes away on its own. Deliberately
## built here rather than added to the scene: it is a tool, and a tool that only
## exists when you press its key cannot be left switched on by accident.
func _dev_note(text: String, seconds: float = 2.6) -> void:
	var old := get_node_or_null("DevNote")
	if old != null:
		old.queue_free()
	var l := Label.new()
	l.name = "DevNote"
	l.text = text
	l.add_theme_color_override("font_color", Color(1.0, 0.86, 0.45))
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	l.add_theme_constant_override("outline_size", 6)
	l.set_anchors_preset(Control.PRESET_CENTER_TOP)
	l.position.y = 96.0
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	var tw := create_tween()
	tw.tween_interval(seconds)
	tw.tween_property(l, "modulate:a", 0.0, 0.8)
	tw.tween_callback(l.queue_free)


func _unhandled_input(event: InputEvent) -> void:
	# F9 walks the card treatments: framed, borderless, borderless foil, foil.
	#
	# Both are rare pulls on purpose, so the only way to judge one used to be to
	# play until the dice agreed. And the interesting question is never "does
	# the borderless one look good", it is "does it look BETTER than the framed
	# one" - which is a comparison you can only make by flipping between them on
	# the same card, a second apart. Hence live, rather than a launch flag.
	if DevConsole.open:
		return
	var key := event as InputEventKey
	if key != null and key.pressed and key.keycode == KEY_F9:
		print("DEV cards: %s" % Dev.cycle())
		_render_hand()
		return
	# F8 flips the Menu's own Camera: Player/Dev toggle live. Nick, 22:25 EDT:
	# "I still cannot find the toggle" -- it is three taps deep in the settings
	# panel, so give it a key too, the same way F9 saves a trip to the console
	# for the thing IT flips. Not gated on free_camera_allowed: the whole point
	# is turning Dev ON when the free camera is currently off.
	if key != null and key.pressed and key.keycode == KEY_F8:
		var next := not Progress.dev_camera_enabled()
		Progress.set_dev_camera_enabled(next)
		_dev_note("Camera:  %s" % ("Dev" if next else "Player"), 1.0)
		return
	# The free camera (drag to orbit, right/middle-drag to pan, wheel to zoom,
	## WASD/QE to fly — see _fly()) is a LOCAL DEV TOOL, not something normal
	## play can end up in. Nick, 2026-09-23 14:35 EDT: "in normal play the
	## camera is LOCKED in third person on the active hunter — it does not
	## drift back to the wide shot and the player cannot leave it... A free
	## camera is fine as a LOCAL dev tool, just not something normal play can
	## end up in." Gated on OS.is_debug_build(), the same switch
	## console.gd's own doc comment already names for exactly this ("when
	## there is a build to ship, gate it on OS.is_debug_build()") — true here
	## in the editor and every unexported dev/test run (verified: prints true
	## under --headless), false only in an exported Release template. Without
	## this, dragging or scrolling (_take_manual_control) is the ONLY way
	## _user_framed/_yaw/_pitch/_dist ever move off the auto-follow shoulder
	## shot _process already settles into on its own (want_ots there does not
	## check _user_framed) — so gating the input is what actually locks the
	## camera, not a change to the follow logic itself.
	if not free_camera_allowed(OS.is_debug_build(), Progress.dev_camera_enabled()):
		return
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		match mb.button_index:
			MOUSE_BUTTON_LEFT:
				_dragging = mb.pressed
			MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_RIGHT:
				# Right-drag pans. Right-CLICK on a card opens its keyword, but a
				# card is a Control and eats its own clicks before this runs, so
				# the two never meet.
				_panning = mb.pressed
			MOUSE_BUTTON_WHEEL_UP:
				_take_manual_control()
				# A target, not _dist itself — _aim_camera chases it every frame
				# (FREE_CAM_EASE) instead of the step landing all at once.
				_free_dist_target = maxf(_free_dist_target * (1.0 - ZOOM_STEP), 4.0)
			MOUSE_BUTTON_WHEEL_DOWN:
				_take_manual_control()
				_free_dist_target = minf(_free_dist_target * (1.0 + ZOOM_STEP), 60.0)
	elif event is InputEventMouseMotion and (_dragging or _panning):
		var mm: InputEventMouseMotion = event
		_take_manual_control()
		if _panning:
			# In the camera's own axes, so a drag moves the world the way the
			# hand moves, whatever angle you are viewing from. Scaled by distance
			# so panning feels the same close in and far out.
			var basis := _cam.global_transform.basis
			var k := _dist * PAN_SENSITIVITY
			_pan -= basis.x * mm.relative.x * k
			_pan += basis.y * mm.relative.y * k
			# _pan already eases in — it only ever moves the camera through
			# _pivot_target, and _aim_camera's own _pivot.lerp(...) chases that
			# every frame (see below). Nothing more to do here.
		else:
			# Targets only. _aim_camera is the one place that actually moves
			# _yaw/_pitch (FREE_CAM_EASE) — see its own doc comment.
			_yaw_target -= mm.relative.x * ORBIT_SENSITIVITY
			_pitch_target += mm.relative.y * ORBIT_SENSITIVITY


## The moment the player touches the camera it stops second-guessing them: no more
## auto-pitch, and the opening pull-in gives up rather than dragging them back.
## Following the climb keeps working — that's help, not interference.
##
## Only ever called from the dev free camera's own input (drag/wheel/WASD below),
## never from _focus_camera — so _free_cam_engaged is a clean way to tell "Nick is
## driving the dev camera" apart from "the locked player camera focused a climb,"
## which also sets _user_framed but must keep moving _pitch/_dist unchased.
func _take_manual_control() -> void:
	if not _free_cam_engaged:
		# Coming from the automatic camera — grounded auto-pitch, the climb/
		## establishing dist ease, or _focus_camera's own climb lock, all of
		## which move _pitch/_dist (and clear _free_cam_engaged themselves; see
		## _focus_camera) without the dev camera's say-so: seed the free-cam
		## targets from wherever the camera actually is right now, not
		## wherever they were last left. Without this, engaging (or
		## re-engaging) the dev camera would start the chase from a stale
		## target and produce exactly the kind of jump this ticket is about.
		_yaw_target = _yaw
		_pitch_target = _pitch
		_free_dist_target = _dist
	_user_framed = true
	_free_cam_engaged = true
	_establishing = false


## The beast's data id picks its model. The old guess read the portrait PATH,
## which cannot work — several beasts share one portrait (two use crocodile.png),
## so half the roster resolved to the wrong body or fell back to the elephant.
## The name is kept only as a fallback for a beast added without a mapping.
##
## Static and split from the ResourceLoader.exists probe below so run_tests.gd
## can prove the fallback ladder headless, with no scene tree and no files on
## disk. #86 duty 3 — the ladder itself (id has its own art / id is mapped /
## name substring-matches a mapped id / give up to elephant) had zero coverage;
## only its sibling ladder, _card_icon, had ever been tested.
static func model_key_for(beast_id: String, beast_name: String, has_own_art: bool) -> String:
	if has_own_art:
		return beast_id
	if MODELS.has(beast_id):
		return String(MODELS[beast_id])
	var lower := beast_name.to_lower()
	for id in MODELS:
		if lower.contains(String(id).replace("_", " ")):
			return String(MODELS[id])
	return "elephant"


func _model_key(beast_id: String, beast_name: String) -> String:
	# Your own art wins, exactly as it does for hunters (ui/cast.gd): a file named
	# cast/<beast_id>.glb replaces the Kenney stand-in with no code change, so
	# making a beast is exporting a file and nothing else.
	var has_own_art := beast_id != "" and ResourceLoader.exists(CAST + beast_id + ".glb")
	var key := model_key_for(beast_id, beast_name, has_own_art)
	var matched := has_own_art or MODELS.has(beast_id)
	if not matched:
		var lower := beast_name.to_lower()
		for id in MODELS:
			if lower.contains(String(id).replace("_", " ")):
				matched = true
				break
	if not matched:
		push_warning("combat_3d: no model for beast '%s' — falling back" % beast_id)
	return key


## World-space bounds of a model, so hunters can be placed ON it whatever its
## shape — no per-beast hand-tuning. Everything downstream of _beast_box (hunter
## side-offsets, the sigil's position and scale, the camera window, damage
## popups, dust) reads THIS box, so a wrong merge here is wrong everywhere at
## once — the same "one system" shape as the shader/build-step changes that
## actually moved the whole cast (backlog #86 duty 1's own framing). Lifted
## pure (#86 duty 3) alongside its own helper below: neither reads `self`, and
## MERGE walks each mesh's global_transform, not the local one _bounds()
## (location_3d.gd) uses, since a beast's climb/sigil markers are ordinary
## children that can sit rotated or offset under a rig node.
static func _merged_aabb(root: Node3D) -> AABB:
	var out := AABB()
	var first := true
	for node in _all_meshes(root):
		var vi := node as VisualInstance3D
		var box: AABB = vi.global_transform * vi.get_aabb()
		if first:
			out = box
			first = false
		else:
			out = out.merge(box)
	if first:
		return AABB(Vector3(-1, 0, -1), Vector3(2, 2, 2))
	return out


static func _all_meshes(node: Node) -> Array:
	var out: Array = []
	if node is VisualInstance3D:
		out.append(node)
	for c in node.get_children():
		out.append_array(_all_meshes(c))
	return out


# --- hunters --------------------------------------------------------------

## Pull the climb route out of the model that just spawned.
## How far FORWARD the beast's body reaches, sampled off its actual mesh.
##
## Nick, 2026-08-31: "make sure beasts/characters are not colliding with the
## environment. they are still meshing inside the beast."
##
## Every previous attempt at this pushed the hunter out by a fraction of the
## bounding BOX — 0.055 of its width, 0.025 of its depth — and a box is the one
## thing a creature is not. On anything with a chest, a jaw or a shell the box
## front is metres beyond the actual surface at some heights and metres behind it
## at others, so the same nudge left a hunter hanging in space on the Gale
## Serpent and buried to the waist in the Grove Bear.
##
## So: sample the real surface. One pass over the beast's vertices at spawn
## builds a coarse heightmap of how far each (x band, y band) of the body reaches
## toward the camera, and a hunter is placed against THAT. It costs one walk of a
## 2600-triangle mesh, once per beast.
const HULL_X := 9      # sideways bands across the body
const HULL_Y := 20     # bands up it


## front reach per (x band, y band), in beast-local units, or an empty array
## before the first beast has spawned.
var _hull: PackedFloat32Array = PackedFloat32Array()


## Put every creature on the stylized shader.
##
## Nick, 2026-09-08: "many of the base models are fine, but the quality needs to
## increase." They were — the models were never what made them look cheap. Until
## this, every one of them rendered on one material, one flat palette swatch per
## part, roughness 1.0, no normal map and no shader at all (kenney.py:204). A
## matte flat-coloured blob by construction, which is why six beasts each gained
## three points of geometry polish and still read as an asset pack.
##
## Measured on cinder_jackal in a real fight before this landed: the shader
## moved 8.8% of the pixels of the beast (mean 6.22/255). A baked-AO pass on top
## of it moved almost nothing at this camera distance and was left out; see
## tools/blender/aobake.py, which is kept for portraits where the camera is
## close enough for a crease to survive.
##
## The texture comes off the model's OWN material rather than a hardcoded atlas
## path, so a model that ever ships its own texture keeps it.
## The toon material for one mesh of an AI_ART beast, outline included. Static
## so the reward screen's felled beast (location_3d) wears the same look.
## outline_scale multiplies outline.gdshader's own default line width — see
## OUTLINE_WIDTH_SCALE. 1.0 (the default) sets nothing, so the jackal and the
## Frog draw exactly as they did before this parameter existed.
static func toon_material(mi: MeshInstance3D, tex: Texture2D,
		motion: Dictionary = {}, outline_scale: float = 1.0) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = TOON
	var line := ShaderMaterial.new()
	line.shader = OUTLINE
	if outline_scale != 1.0:
		line.set_shader_parameter("width", 0.0045 * outline_scale)
	if tex != null:
		mat.set_shader_parameter("albedo_tex", tex)
		# Motion only on the painted body. The footholds are a separate, flat
		# mesh; breathing them would jiggle the thing a hunter is standing on.
		for k in motion:
			mat.set_shader_parameter(k, motion[k])
			if not k.begins_with("glow_"):
				line.set_shader_parameter(k, motion[k])
	else:
		# An untextured part (the footholds) keeps its flat colour.
		var had0 := mi.mesh.surface_get_material(0)
		if had0 is StandardMaterial3D:
			mat.set_shader_parameter("tint", (had0 as StandardMaterial3D).albedo_color)
	mat.next_pass = line
	return mat


## Every mesh under `root`, toon-shaded. For a model loaded outside the fight.
## model_id looks up OUTLINE_WIDTH_SCALE the same way _shade_model does, so a
## thin-parted hunter reads the same in the reward-screen row (_place_hunters)
## and the felled-beast pose (_lay_out_the_felled) as it does in the fight.
static func toon_all(root: Node, model_id: String = "") -> void:
	var outline_scale: float = OUTLINE_WIDTH_SCALE.get(model_id, 1.0)
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		stack.append_array(n.get_children())
		var mi := n as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		var tex: Texture2D = null
		for s in range(mi.mesh.get_surface_count()):
			var had := mi.mesh.surface_get_material(s)
			if had is StandardMaterial3D and (had as StandardMaterial3D).albedo_texture != null:
				tex = (had as StandardMaterial3D).albedo_texture
				break
		mi.material_override = toon_material(mi, tex, {}, outline_scale)


## Whether a mesh under `root` takes the toon-shaded, rigged path instead of
## the plain CREATURE shader — the branch that used to be hardcoded to
## `root == _beast`, generalized (2026-09-23 hunter-display-path request) so a
## HUNTER_AI_ART hunter can opt in via `force_toon` the same way an AI_ART
## beast already does via `beast_toon`. Pure so run_tests.gd can prove a
## tagged hunter resolves through it, and a plain one still doesn't, with no
## scene tree needed.
static func wants_toon(beast_here: bool, beast_toon: bool, force_toon: bool) -> bool:
	return force_toon or (beast_here and beast_toon)


## model_id is only for a forced-toon hunter's OUTLINE_WIDTH_SCALE lookup
## (_spawn_hunter passes its cid); the beast finds its own scale off
## _beast_id, same as it already does for AI_MOTION/EMBERS below.
func _shade_model(root: Node, is_ground := false, force_toon := false,
		model_id := "") -> void:
	if CREATURE == null:
		return
	var beast_here := not is_ground and root == _beast
	var toon_here := wants_toon(beast_here, _beast_toon, force_toon)
	var outline_scale: float = OUTLINE_WIDTH_SCALE.get(
		_beast_id if beast_here else model_id, 1.0)
	for node in _all_meshes(root):
		var mi := node as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		var tex: Texture2D = null
		for s in range(mi.mesh.get_surface_count()):
			var had := mi.mesh.surface_get_material(s)
			if had is StandardMaterial3D and (had as StandardMaterial3D).albedo_texture != null:
				tex = (had as StandardMaterial3D).albedo_texture
				break
		if toon_here:
			# AI_MOTION's uniforms are the beast's own shader-driven idle life
			# (no rig yet); a HUNTER_AI_ART hunter is rigged from the start, so
			# its motion comes off its own AnimationPlayer instead (_spawn_hunter)
			# and it takes the toon material with nothing pumped into it here.
			mi.material_override = toon_material(mi, tex,
				AI_MOTION.get(_beast_id, {}) if beast_here else {}, outline_scale)
			continue
		var mat := ShaderMaterial.new()
		mat.shader = CREATURE
		if tex != null:
			mat.set_shader_parameter("atlas", tex)
		# Only the beast glows. A hunter standing beside it painted from the same
		# palette would otherwise light up for sharing a swatch.
		if beast_here:
			var lit: Array = EMBERS.get(_beast_id, [])
			if not lit.is_empty():
				var uvs := PackedVector2Array()
				for uv in lit:
					uvs.append(uv as Vector2)
				# The shader's array is fixed at 4; pad so the tail is never a
				# stale value from whatever the driver had there.
				while uvs.size() < 4:
					uvs.append(Vector2(-1.0, -1.0))
				mat.set_shader_parameter("ember_uv", uvs)
				mat.set_shader_parameter("ember_count", mini(lit.size(), 4))
			var vr: Dictionary = VALUE_RANGE.get(_beast_id, {})
			if vr.has("body_gain"):
				mat.set_shader_parameter("body_gain", vr["body_gain"])
			if vr.has("ember_gain"):
				mat.set_shader_parameter("ember_gain", vr["ember_gain"])
		if is_ground:
			# Ground wants the shading but not the outline. A rim traces every
			# edge it is given, and a floor made of slabs has hundreds — lit up,
			# they pull the eye off the fight and onto the scenery.
			mat.set_shader_parameter("rim_strength", 0.10)
			mat.set_shader_parameter("spec", 0.04)
			mat.set_shader_parameter("ground_strength", 0.10)
		mi.material_override = mat
	_tint_rims()


## The rim has to belong to the biome it is standing in.
##
## A cool blue rim reads as sky bounce on a crag and as nothing at all on a lava
## floor. The biome already names a `fill` colour — the light coming from
## everywhere that is not the sun — which is exactly what a rim is picking up,
## so take it from there rather than inventing a second table to keep in sync.
## Walks the rig rather than keeping a list of the materials it handed out. A
## ShaderMaterial is a Resource, so an array of them keeps every material from
## every beast this fight ever loaded alive for the life of the view — the list
## can never shrink, because holding the reference is exactly what stops it
## being freed. The scene already knows which meshes exist; ask it.
func _tint_rims() -> void:
	if _rig == null:
		return
	var name: String = String(BEAST_BIOME.get(_beast_id, "crag"))
	var b: Dictionary = BIOME.get(name, BIOME["crag"])
	var rim: Color = (b["fill"] as Color).lightened(0.35)
	for node in _all_meshes(_rig):
		var mi := node as MeshInstance3D
		if mi == null:
			continue
		var mat := mi.material_override as ShaderMaterial
		if mat != null and mat.shader == CREATURE:
			mat.set_shader_parameter("rim_color", rim)


func _build_hull() -> void:
	_hull = PackedFloat32Array()
	if _beast == null:
		return
	_hull.resize(HULL_X * HULL_Y)
	_hull.fill(-1e9)
	var box := _beast_box
	if box.size.x <= 0.0001 or box.size.y <= 0.0001:
		_hull = PackedFloat32Array()
		return
	for node in _all_meshes(_beast):
		var mi := node as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		var xf := mi.global_transform
		for surf in range(mi.mesh.get_surface_count()):
			var arrays: Array = mi.mesh.surface_get_arrays(surf)
			if arrays.is_empty():
				continue
			var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			for v in verts:
				var w: Vector3 = xf * v
				var idx := hull_index_for(w.x, w.y, box, HULL_X, HULL_Y)
				var at := idx.y * HULL_X + idx.x
				if w.z > _hull[at]:
					_hull[at] = w.z


## The pure half of _build_hull's own scatter and of _front_of_beast below:
## world (x, y) to the hull cell it falls in. Clamped to [0, 0.999) before
## scaling so a point exactly on the box's far edge lands in the last cell
## instead of one past it (which would read past the array in _build_hull's
## `at` index). A degenerate box — zero width or height — would otherwise
## divide by zero into NaN, and int(NaN) is undefined rather than merely
## wrong; both axes fall back to the first cell instead of trusting that
## division. _build_hull already refuses to build a hull over a degenerate
## box, so this branch is a guarantee for callers that come later, not a
## path production exercises today.
static func hull_index_for(x: float, y: float, box: AABB, hull_x: int, hull_y: int) -> Vector2i:
	var ix := 0
	if box.size.x > 0.0:
		ix = int(clampf((x - box.position.x) / box.size.x, 0.0, 0.999) * float(hull_x))
	var iy := 0
	if box.size.y > 0.0:
		iy = int(clampf((y - box.position.y) / box.size.y, 0.0, 0.999) * float(hull_y))
	return Vector2i(ix, iy)


## The front of the body at (x, y), or the bounding box front where the mesh has
## nothing in that band — a limb sticking out into empty air must not drag the
## hunter forward with it, and an empty band means there is no body there at all.
func _front_of_beast(x: float, y: float) -> float:
	if _hull.is_empty():
		return _beast_box.end.z
	var box := _beast_box
	var idx := hull_index_for(x, y, box, HULL_X, HULL_Y)
	return hull_front_at(_hull, HULL_X, HULL_Y, idx.x, idx.y, box)


## The pure half of _front_of_beast: given a band already resolved to hull
## indices, the deepest of that band and the eight around it. Sampling the
## hunter's own column alone is not enough and the Grove Bear proves why: at
## the sigil the chest reaches 8.5 and the hunter stood at 9.5, correctly
## outside it — and was still invisible, because the muzzle in the next
## column along reaches 11.4 and the hunter was standing behind its face.
##
## A 3x3 neighbourhood is the local surface rather than one thin slice. Wider
## than that and a single outflung limb starts dragging hunters out into open
## air on the other side of the body, which is the opposite failure and looks
## just as wrong.
static func hull_front_at(hull: PackedFloat32Array, hull_x: int, hull_y: int,
		ix: int, iy: int, box: AABB) -> float:
	var best := -1e9
	for dy: int in [-2, -1, 0, 1, 2]:
		var j: int = iy + dy
		if j < 0 or j >= hull_y:
			continue
		for dx: int in [-1, 0, 1]:
			var i: int = ix + dx
			if i < 0 or i >= hull_x:
				continue
			var f: float = hull[j * hull_x + i]
			if f > best:
				best = f
	if best < -1e8:
		return box.position.z    # no body in this column: the back of the box
	return best


func _read_climb_points() -> void:
	_climb_points.clear()
	_ledges.clear()
	if _beast == null:
		return
	_gather_climb(_beast, Transform3D.IDENTITY)


## Pure form of the marker-naming rule below: what a single child node's NAME
## means for climb anchors, decoupled from walking the model's tree. #86 duty
## 3 — this is the step upstream of route_between_rungs and foothold_anchor
## (both already covered): those assume _climb_points/_ledges are already
## right, and this is the rule that actually reads them off a beast's own
## Blender export. A marker a beast.py script misnames — "climb5" with no
## underscore, "climb_" with nothing after it, a stray "Climb_5" with the
## wrong case — silently drops that Height's anchor with no error anywhere,
## which is exactly the kind of first-pass hole duty 2 keeps finding: nothing
## crashes, the beast just has one fewer place to stand.
static func climb_marker_for(node_name: String) -> Dictionary:
	if node_name.begins_with("climb_"):
		var tail := node_name.substr(6)
		if tail.is_valid_int():
			return {"kind": "climb", "height": tail.to_int()}
	elif node_name.begins_with("ledge_"):
		var tail := node_name.substr(6)
		if tail.is_valid_int():
			return {"kind": "ledge", "height": tail.to_int()}
	return {"kind": "none", "height": 0}


## Walks the transform down rather than reading global_position, which is only
## meaningful once the node is in the tree and settled.
func _gather_climb(n: Node, xf: Transform3D) -> void:
	for c in n.get_children():
		var next := xf
		if c is Node3D:
			next = xf * (c as Node3D).transform
			var marker := climb_marker_for(String(c.name))
			match String(marker["kind"]):
				"climb":
					_climb_points[int(marker["height"])] = next.origin * _beast_scale
				"ledge":
					_ledges[int(marker["height"])] = true
		_gather_climb(c, next)


## The Heights this beast has anchors for, in order.
func _climb_rungs() -> Array:
	var keys: Array = _climb_points.keys()
	keys.sort()
	return keys


## Pure form of the bracket-and-lerp rule above: given the model's anchors
## (Height -> Vector3) and a foothold, which two anchors bracket it and where
## between them the foothold actually sits. Split out static, like
## route_between_rungs below, so run_tests.gd can prove the rule with no
## scene tree and no model loaded. #86 duty 3.
##
## The side-offset and body-clearance math in _stand_on_model stays on the
## instance because it reads the live beast box; this is only the part of the
## rule that decides a POSITION on the model, not how far off its surface a
## hunter stands from that position.
static func foothold_anchor(anchors: Dictionary, foot: int) -> Vector3:
	var rungs: Array = anchors.keys()
	rungs.sort()
	var lo: int = int(rungs[0])
	var hi: int = int(rungs[rungs.size() - 1])
	for k in rungs:
		if int(k) <= foot:
			lo = int(k)
		if int(k) >= foot:
			hi = int(k)
			break
	var a: Vector3 = anchors[lo]
	var b: Vector3 = anchors[hi]
	if hi == lo:
		return a
	return a.lerp(b, clampf(float(foot - lo) / float(hi - lo), 0.0, 1.0))


## Pure form of the lateral spacing rule below: given the anchor's own x, which
## side a hunter stands on (-1/0/+1, see hunter_side_offset) and the beast's
## own width, the world-space x a hunter actually stands at. Split out static
## like foothold_anchor above, so run_tests.gd can prove two hunters land on
## opposite, symmetric sides of one shared foothold with no scene tree and no
## model loaded. #86 duty 3.
static func stand_offset_x(anchor_x: float, side: float, beast_width: float) -> float:
	return anchor_x + side * (beast_width * 0.055 + 0.30)


## How far out (world z, from the arena's own centre) a hunter stands at
## Height 0, given the beast's own front-edge distance from that same centre.
## The one rule both `_show_beast`'s arena sizing and `_place_hunters`'
## ground clamp below now share — see the request this fixes,
## 2026-09-23-1423-nick-to-fixer-stones-camera-and-hunter-spacing.md
## ("move the characters away from the titan").
##
## `front_edge` off `_beast_box.end.z`, not off `size.z` (the old formula
## here, before this fix): a beast's box is centred on the world origin, so
## `end.z` already IS roughly half of `size.z` for a squat creature and the
## two read the same — but the Cinder Jackal is a long, low quadruped, most
## of whose `size.z` runs BEHIND the front edge into the tail, not toward the
## hunters at all. The old `end.z + size.z * GROUND_STANDOFF` counted that
## tail twice: once in `end.z` implicitly (the box is symmetric, so `end.z`
## already reflects the whole length) and again by adding a further
## `GROUND_STANDOFF` of the SAME full length on top. Scaling off `front_edge`
## alone still grows with a bigger beast, just without double-counting the
## half of it hunters never stand anywhere near.
##
## This alone does not fix the cramped stand seen live (before this fix:
## hunters at world z=17.59, front edge at z=16.49 — a 1.1-unit gap the
## jackal's own legs read as "standing on it"): the ground clamp below
## (`minf(back, _arena_r * 0.86)`) was overriding it, because `_arena_r`
## (`_show_beast`'s `want_r`) was sized only off the beast's own footprint,
## never off how far out a hunter needs to stand. Wiring the SAME formula
## into `want_r`'s own max() is what stops the clamp from silently winning.
static func ground_standoff_for(front_edge: float) -> float:
	return front_edge * (1.0 + GROUND_STANDOFF)


## The pure decision inside _stand_on_model: which z a hunter's clearance
## should come from. An EXACT rung's anchor is already on the body's real
## surface — beast.py's export (`_decorate`, tools/blender/beast.py) raycasts
## every anchor out to the mesh itself, clearance for a standing hunter
## already included (`push = (reach + hs * 0.80) - here`). The coarse in-game
## hull estimate (`_front_of_beast`) exists only for a foothold BETWEEN two
## rungs, where `foothold_anchor` lerps a straight line across the body's
## curve and the result can land back inside the mesh or short of the skin —
## that's the one case with no baked, raycast-true anchor to trust.
##
## Trusting the hull on an exact rung too let one bad hull cell override a
## correct, already-placed anchor: `hull_front_at`'s neighbourhood search
## (widened past the anchor's own row/column to avoid the opposite failure,
## see its own doc comment) picked up the Cinder Jackal's ear — a thin,
## disconnected feature two hull bands above foothold 4's own row — and used
## it as "the front of the body" there, pushing the hunter's z from the
## anchor's authored 6.47 out to 13+, well past the model and the arena wall
## behind it, with nothing under the hunter at all.
static func stand_z_for(anchors: Dictionary, foot: int, anchor_z: float, hull_clear: float) -> float:
	if anchors.has(foot):
		return anchor_z
	return maxf(anchor_z, hull_clear)


## Whether `_stand_on_model` should even ask the hull for a foot -- true only
## when `foothold_anchor()` genuinely interpolates for it (strictly between
## two DIFFERENT anchors), never when it clamps to an edge.
##
## 2026-09-25, director (#0802, reopened a second time): every Height PAST
## the model's highest climb marker counted as "not an exact rung" too --
## `_climb_points` stops at the weak point (Height 5 on the Cinder Jackal;
## FOOTHOLD_MAX reaches 16, so Heights 6-16 are real, reachable foothold
## values, all spent fighting the weak point rather than climbing further).
## `foothold_anchor` already clamps every one of them to the SAME top anchor
## (its own "clamps above the highest rung" contract, tested above) -- there
## is no lerp across the body's curve to rescue there, so the hull had
## nothing to add, exactly the exact-rung case above. It got asked anyway,
## found the same kind of stray hull cell the doc comment above blames for
## the ear, and put the hunter at z=13.92 while the sigil's own stone
## (`_top_hold()`, built from the same anchor) sat at z=0.53 -- 13+ units
## away with nothing under the hunter at all, on every Height past 5.
static func stand_needs_hull_clearance(anchors: Dictionary, foot: int) -> bool:
	if anchors.is_empty() or anchors.has(foot):
		return false
	var rungs: Array = anchors.keys()
	rungs.sort()
	return foot > int(rungs[0]) and foot < int(rungs[rungs.size() - 1])


## Where a hunter at `foot` stands, from the model's own anchors.
##
## Exactly on a rung when the Height matches one, and between the two that
## bracket it otherwise — so a hunter part-way up a long haul is on the line
## between the ledge below and the ledge above rather than on a number.
## `route_side` is the FIXED per-hunter offset for the approach line (Nick,
## 2026-09-25: "two sets of stones, one set for each character") -- distinct
## from `side`, which stays the dynamic on-ledge nudge (zero for a lone
## hunter, only splitting the two apart when they share a foothold) that the
## sigil/top hold and every other caller of stand_offset_x still use.
## Defaults to 0.0 (centred, today's behaviour) for callers that don't climb
## the gap -- the ledge-ring marker below is the one that leans on that.
func _stand_on_model(foot: int, side: float, route_side: float = 0.0) -> Vector3:
	var p: Vector3 = foothold_anchor(_climb_points, foot)
	# Two hunters on one ledge stand apart rather than inside each other.
	var x: float = stand_offset_x(p.x, side, _beast_box.size.x)
	# Only a lerped, off-anchor foothold needs the hull's guess — see
	# stand_z_for above. Skip the hull query on an exact rung AND on any foot
	# past the model's highest climb marker (stand_needs_hull_clearance,
	# #0802 reopened): both land on a clamped, already-correct anchor with
	# nothing for the hull to add, and asking it anyway is what put a hunter
	# 13+ units from the sigil's own stone on every Height past the weak point.
	var z: float = p.z
	if stand_needs_hull_clearance(_climb_points, foot):
		# And OUT to the body's real surface at that spot, not a fraction of
		# the bounding box. The anchors are authored on the surface in
		# Blender, but a point ON a surface is still half a hunter inside it,
		# and the old nudge (0.025 of the box depth) was a box-sized guess
		# about a shape that is not a box — too small on a deep chest, far
		# too large beside a thin limb.
		var clear: float = _front_of_beast(x, p.y) + HUNTER_HEIGHT * 0.45
		z = stand_z_for(_climb_points, foot, p.z, clear)
	# Out onto the floating stone (Nick, 2026-09-23: "make sure the characters
	# actually land on the stones"). The stone hangs at stone_point() and the
	# hunter has to stand on it, so one rule places both.
	#
	# And then out ACROSS THE GAP. The route is no longer a ladder against the
	# beast's flank: rung by rung it walks from the ground in front of the
	# hunters up and back to the body, so the first hop is a low stone near you
	# and the last lands on the beast (Nick, 2026-09-24, with a drawing). This
	# is deliberately inside _stand_on_model rather than only on the decorative
	# rock, because the stone and the hunter standing on it have to be one rule
	# -- move only the rock and hunters hop onto empty air beside it.
	var on_body := stone_point(Vector3(x, p.y, z))
	var n := _rung_count()
	var i := _rung_index(foot)
	# The TOP hold is the one place the route must still touch the beast -- it
	# is the sigil, the thing you are climbing to. Every rung below it is a step
	# on the line leading there, so the top is what that line is drawn to.
	if n <= 1 or i >= n - 1:
		return on_body
	return route_pos_cleared(_top_hold(route_side), ground_standoff_for(_beast_box.end.z), i, n,
		STONE_SWEEP_WIDTH)


## The LEDGES strictly between two footholds — the flat ground a hunter can
## actually land on climbing from the ankle to the shoulder.
##
## This used to walk every Height in between, and every Height is anchored (see
## beast.py's _rungs: a hunter shaken off half way has to have somewhere to be
## that is not inside the chest). But most of those are a spot on the skin with
## no footing, and hopping onto each in turn is what made the climb look like it
## was landing in random places. A hunter passes THROUGH those and lands on a
## shelf. Falls back to every anchor on a beast built before ledges were
## exported, which is the old behaviour rather than no route at all.
func _route_between(from_foot: int, to_foot: int) -> Array:
	var rungs: Array = _ledges.keys() if not _ledges.is_empty() else _climb_rungs()
	return route_between_rungs(rungs, from_foot, to_foot)


## Pure form of the above: takes the rung set explicitly instead of reading
## `_ledges`/`_climb_points` off a live beast, so run_tests.gd can prove the
## routing rule headless, with no scene tree and no model loaded. #86 duty 3.
static func route_between_rungs(rungs: Array, from_foot: int, to_foot: int) -> Array:
	var out: Array = []
	var sorted_rungs: Array = rungs.duplicate()
	sorted_rungs.sort()
	if to_foot > from_foot:
		for k in sorted_rungs:
			if int(k) > from_foot and int(k) < to_foot:
				out.append(int(k))
	else:
		for i in range(sorted_rungs.size() - 1, -1, -1):
			var k := int(sorted_rungs[i])
			if k < from_foot and k > to_foot:
				out.append(k)
	return out


## Height becomes literal: on the ground they stand in front of the beast; as
## they climb they move UP its flank, hugging the model's actual bounds.
## One leg of a climb, as a JUMP rather than a slide.
##
## Nick, 2026-08-31: "add a small animation of a jump as characters are
## climbing." Hunters travelled between ledges on a straight tween, which reads
## as a model dragged up a wall on a wire — the one moment this game is about,
## letting go of one hold and catching the next, had no weight at all.
##
## A parabola in two halves: decelerating up to the apex, accelerating down onto
## the ledge. Two eased segments are indistinguishable from a real arc at this
## size, and cost nothing — a method-tween sampling a curve every frame would
## run for every hunter on every client.
##
## The squash rides in parallel on the BODY, never the holder, because the pip
## that marks a hunter through the beast is a child of the holder and has to
## stay exactly the size it was.
func _hop(tw: Tween, node: Node3D, body: Node3D, from: Vector3, to: Vector3,
		step: float) -> void:
	var arc := hop_arc(from, to, step)
	var apex: Vector3 = arc["apex"]
	var rise: float = arc["rise"]
	var hang: float = arc["hang"]
	var fall: float = arc["fall"]
	var live: bool = body != null and is_instance_valid(body)
	var flight := rise + hang + fall

	# ANTICIPATION. A jump that starts the instant it is asked for reads as a
	# teleport with an arc drawn on it; the crouch is what says the hunter
	# DECIDED to go. 60-100ms is the window the animation literature gives:
	# shorter cannot be seen, longer reads as input lag.
	if live:
		tw.tween_property(body, "scale", Vector3(1.10, 0.86, 1.10), 0.09) 			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# THE ARC, one axis at a time.
	#
	# This is the fix Nick's "the jumping animation is poor" pointed at. The old
	# hop eased the WHOLE position vector — horizontal and vertical together —
	# through two segments, which is a symmetric swoop: the hunter slowed down
	# sideways at the top as well as vertically, and every jump read as a float
	# on a wire. Real jumps are two independent motions: horizontal at a
	# constant speed (nothing pushes you sideways in the air), vertical under
	# gravity. Tweening x/z LINEARLY across the whole flight while y runs its
	# own eased rise / hang / fall is that, and costs the same.
	tw.tween_property(node, "position:x", to.x, flight).set_trans(Tween.TRANS_LINEAR)
	tw.parallel().tween_property(node, "position:z", to.z, flight).set_trans(Tween.TRANS_LINEAR)
	# UP: decelerating into the apex.
	tw.parallel().tween_property(node, "position:y", apex.y, rise) 		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# HANG: the frame the player reads the height by. Celeste halves gravity
	# near the apex for exactly this; a tween's version is a short hold.
	tw.parallel().tween_property(node, "position:y", apex.y, hang).set_delay(rise)
	# DOWN: accelerating, and faster than the rise — asymmetric gravity is the
	# single biggest readability win in the jump literature (Mario multiplies
	# gravity past the peak; hop_arc sizes `fall` shorter than `rise` for it).
	tw.parallel().tween_property(node, "position:y", to.y, fall) 		.set_delay(rise + hang).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	if live:
		# TAKEOFF STRETCH, decaying back to neutral by the apex. Past ~1.2 a
		# low-poly body reads as rubber rather than force.
		tw.parallel().tween_property(body, "scale", Vector3(0.92, 1.16, 0.92), 0.08) 			.set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(body, "scale", Vector3.ONE, rise - 0.08) 			.set_delay(0.08).set_ease(Tween.EASE_IN_OUT)
		# BODY ATTITUDE: lean into the arc on the way up, nose down on the way
		# in. An upright, rigid body is the loudest "there is no animation here"
		# tell there is, and a lean costs one more tween.
		var lean := clampf(Vector3(to.x - from.x, 0.0, to.z - from.z).length() * 0.10, 0.0, 0.35)
		tw.parallel().tween_property(body, "rotation:x", -lean, rise) 			.set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(body, "rotation:x", lean * 0.8, fall) 			.set_delay(rise + hang).set_ease(Tween.EASE_IN)

	# LANDING. Impact is a SNAP, not an ease — the asymmetry (in fast, out
	# slow) is what reads as weight rather than as a slide into place.
	if live:
		tw.chain().tween_property(body, "scale", Vector3(1.18, 0.78, 1.18), 0.05) 			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(body, "rotation:x", 0.0, 0.05)
		tw.tween_property(body, "scale", Vector3.ONE, 0.17) 			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Pure form of the arc above: the apex the hop rises to and the two halves'
## durations, from nothing but the two endpoints and the step time -- no
## Tween, no node, no scale. #86 duty 3 (verify a mechanic actually works) --
## Nick's own named example was "the jump mechanic on hunters"; this is the
## one part of that jump that is not pure presentation (the squash/tween
## calls right above stay untested, correctly, since Tween timing itself
## isn't something a headless run can observe). This is the shape of the arc
## itself: how high it rises and where its two halves split, both real rules
## with real failure modes (an unclamped hop over a long haul would arc
## absurdly high; a fall half that hit zero would snap the landing instead of
## easing into it).
##
## Fixer, 2026-09-22: found live by the playtester's hop-flat check
## (`_check_hop` in tools/playtest.gd) -- a big single-leg climb (e.g. Leap,
## which can cover most of the jackal's flank in one hop with no intermediate
## ledge to break the trip into shorter legs, `_route_between`) rose from
## y=8.99 to y=18.17 and the sampled peak (18.13) never cleared either
## endpoint: "reads as a slide, not a jump". The apex used to be built as
## `lerp(from, to, 0.58) + UP * hop` -- only 58% of the CLIMB's own vertical
## span plus a hop height that is deliberately clamped small (2.5 hunter
## heights, so a long haul does not arc absurdly high, per the doc above).
## For a short hop the 42% of vertical span still owed is small enough that
## `hop` alone covers it, so every existing test here (all of them flat,
## X-only moves) passed. For a climb whose OWN vertical span already exceeds
## a couple of hunter heights, 42% of that span dwarfs the capped hop, so the
## apex lands below `to.y` -- the "rise" tween never actually rises past the
## landing height, and the parabola looks like a rising slide with a wobble
## at the end, not a jump onto a hold. The apex's height only ever has to
## clear whichever endpoint is higher by `hop`, independent of how far along
## the lean sits -- so this now takes the height straight from `maxf(from.y,
## to.y) + hop` instead of leaning it along with x/z, and reproduces exactly
## with `hop_arc(Vector3(0,8.99,0), Vector3(0.3,18.17,-0.4), 0.34)`, which
## used to return apex.y=15.97 (below to.y=18.17) and now returns apex.y=
## 19.82 (above both endpoints).
## The distance past which hop_arc()'s own clamp (HUNTER_HEIGHT * 3.4 above)
## stops growing the arc with distance -- mirrors playtest.gd's HOP_MAX_WORLD
## and route.py's own copy (neither file can import a .gd class, so both
## carry the same number as a literal; see either one's own doc comment).
## Derived from the SAME clamp rather than typed as a third literal, so this
## copy at least can never drift from hop_arc() itself.
const HOP_MAX_LEG := HUNTER_HEIGHT * 3.4 / 0.26


## Splits one long hop into several, each inside hop_arc()'s own proportional
## band, so a hunter crossing a wide gap plays as several readable jumps
## instead of one the arc cannot keep up with.
##
## The fix for "every ordinary climb hop now measures ~20m, 2-8x hop_arc()'s
## own ceiling" (2026-09-24-2344): b0648db's straight-line route_pos() spaced
## its rungs evenly by COUNT, not by hop_arc()'s own reach, so widening the
## gap between the hunters and the beast (#14) widened every leg right along
## with it. hop_arc()'s arc height and duration are both fixed per hop
## regardless of distance (its own doc comment: "the same jump should take
## the same time however many of them there are") precisely so a long climb
## reads as a CHAIN of hops, not one stretched-out one -- this is what turns
## that chain into more than one hop when a single leg is too long to be one.
##
## A straight lerp only: the two points the caller passes in already decide
## the ROUTE (on the route_pos() line, on the body, at the sigil) -- this
## never bends it, only adds more stops along the same segment, at even
## spacing so no sub-leg is shorter than the others (the same "one line, even
## steps" reasoning route_pos()'s own tests already pin down). A leg already
## inside the band is untouched: steps=1 and the single output point IS `to`,
## so this is a no-op everywhere it was not needed, byte-for-byte.
##
## Pure and static, like hop_arc beside it, so run_tests.gd and playtest.gd's
## own hop-distance-band check can both call it and agree on what the route
## actually plays as -- the same reasoning that already keeps route_pos() and
## STONE_SWEEP_WIDTH shared between the two files.
static func hop_subpoints(from: Vector3, to: Vector3, max_leg: float) -> Array[Vector3]:
	var out: Array[Vector3] = []
	var steps: int = maxi(1, int(ceil(from.distance_to(to) / maxf(max_leg, 0.001))))
	for k in range(1, steps + 1):
		out.append(from.lerp(to, float(k) / float(steps)))
	return out


## The new `home` once a climb has advanced onto `leg`, one sub-hop at a time.
## X/Z only -- `_lock_point()` is the sole reader that needs to move mid-flight
## (the camera's horizontal aim); `home.y` stays the climb's real final height,
## which `_pivot_target.y`/`_jump_lo`/`_jump_hi` already handle for the whole
## flight, not leg by leg, and retargeting it here would fight that.
##
## #0420: `home` used to move once, to the FINAL stop, before the climb's tween
## even started (`_place_hunters`), so `_lock_point()` aimed at where the hop
## was going to end for the entire flight -- on a chained multi-leg climb the
## hunter was still near the START while the camera already sat at the finish.
## This is what a tween_callback per sub-hop now feeds, so the camera advances
## leg by leg instead of jumping straight to the destination.
static func home_after_leg(home: Vector3, leg: Vector3) -> Vector3:
	return Vector3(leg.x, home.y, leg.z)


static func hop_arc(from: Vector3, to: Vector3, step: float) -> Dictionary:
	# Higher than it was (0.18 / 2.5 cap): Nick, 2026-09-23 — the jump has to
	# read as a jump at a glance, and a flat arc over a long climb reads as a
	# slide with a bump in it.
	var hop: float = clampf(from.distance_to(to) * 0.26, HUNTER_HEIGHT * 0.9,
		HUNTER_HEIGHT * 3.4)
	# Lean the apex toward the landing on the flat plane, so it reads as a
	# jump ONTO something rather than a lob -- straight up the middle looks
	# like a fountain. The HEIGHT is separate: it must clear both endpoints
	# by `hop`, not just `from`'s, or a climb whose own vertical span already
	# exceeds the capped hop rises to a point below the landing.
	var lean := from.lerp(to, 0.58)
	var apex := Vector3(lean.x, maxf(from.y, to.y) + hop, lean.z)
	# Asymmetric, and with a hold at the top. Gravity on the way down is what
	# every jump-feel source raises (Mario ~3x, Celeste halves it near the
	# apex instead) — so the fall is the SHORT half, and the hang between them
	# is the moment the height is readable. 0.46 / 0.14 / 0.40 of the step.
	var rise := step * 0.46
	var hang := step * 0.14
	var fall: float = maxf(step - rise - hang, 0.05)
	return {"apex": apex, "rise": rise, "hang": hang, "fall": fall, "hop": hop}


## Slides a hunter to `to` for a move that is NOT a climb — the beast rescaled,
## the sigil settled, see the `elif moved:` branch in _place_hunters. Split out,
## and made static, so a headless test can prove the glide actually plays.
##
## `Tween.tween_property` reads its "from" value LAZILY, the first time the
## tween steps — not when tween_property() is called. The bug that shipped set
## `node.position = pos` on the very next line after starting the tween, which
## runs synchronously, so by the time the tween took its first step the
## "current" position already WAS `pos`: it interpolated pos -> pos and every
## glide played as a snap. `_place_hunters`'s comment above the sibling
## `elif not placed:` branch already tells this story once (5b63bf4, hunters
## spawning at the beast's centre because nothing ran on the first pass) — this
## is the same shape of bug, an order-of-operations gap, in the other branch.
static func _start_glide(tw: Tween, node: Node3D, to: Vector3, dur: float) -> void:
	tw.tween_property(node, "position", to, dur) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


## Kills whatever tween last owned this hunter's slot in `climb_tw` and puts
## its body back to Vector3.ONE. Shared by the `climb` and `glide` branches
## of _place_hunters: an old tween left running while a new one starts keeps
## driving the SAME node.position (and, if it was a climb, the SAME
## body.scale) in parallel with the new one, so the hunter is dragged between
## two places that disagree instead of playing one clean move in its place.
## Pulled out static, like _start_glide beside it, so a headless test can
## prove the cancellation actually happens without a live tween running real
## frames.
static func _cancel_pending_tween(climb_tw: Dictionary, i: int, body: Node3D) -> void:
	var old_tw: Tween = climb_tw.get(i) as Tween
	if old_tw != null and old_tw.is_valid():
		old_tw.kill()
	if body != null and is_instance_valid(body):
		body.scale = Vector3.ONE


## Whether `tw` (a `_climb_tw[i]` entry, or null) is still actively driving a
## hunter's `node.position` this frame. A killed tween is invalid; a finished
## one is valid but not running; either way nothing is left to race, so the
## per-frame idle sway in `_process` is free to touch `node.position.y` again.
## Pulled out static, like its neighbours above, so "the sway backs off while
## a climb/glide is live" is provable with a real Tween and no scene frame run.
static func _tween_is_live(tw: Tween) -> bool:
	return tw != null and tw.is_valid() and tw.is_running()


## Decides how a hunter's position update should be animated, given only the
## bookkeeping _place_hunters already has to hand — no Node3D required, so a
## headless test can pin the rule down directly.
##
## A JUMP is for a change of HEIGHT. Nothing else.
##
## This used to hop whenever the target moved more than 0.05, and the target
## moves for all sorts of reasons that are not the hunter climbing: the sigil
## settles, the beast is rescaled, the surface sampler returns a slightly
## different point as the body shakes. Every one of those fired a full leap.
## That is Nick's "bouncing in random places at an awkward cadence" — the
## cadence was random because the trigger was.
##
## `was != foot` outranks `moved`: a foothold change climbs even if the two
## world positions happen to coincide, and a same-foothold reshuffle never
## climbs no matter how far the point moved.
static func hunter_move_kind(placed: bool, was: int, foot: int, moved: bool) -> String:
	if placed and was != foot:
		return "climb"
	if not placed:
		return "first"
	if moved:
		return "glide"
	return "none"


## Step aside ONLY when someone else is on this Height.
##
## Nick, 2026-09-08: hunters "are floating in mid air". Part of it was the
## union remesh melting the grown steps (fixed in union.txt), and part was
## this: the offset was unconditional, so a lone hunter was pushed a third
## of a body-width off the anchor the step was grown at, and stood beside
## their own footing rather than on it. Two hunters sharing a ledge still
## need to not occupy each other.
##
## Compares footholds CLAMPED to `height`, not the raw stored value. A
## foothold keeps climbing past the sigil (core/combat.gd: "foothold can
## reach FOOTHOLD_MAX, not just weak_point_height"), but `_place_hunters`
## clamps `t` to 1.0 and draws every foothold >= height at the same sigil
## spot. Two hunters at, say, 13 and 16 with a Height-13 sigil are drawn on
## top of each other — the same rendered point — but compared as raw
## footholds they read as different holds, so the offset never fired and
## the Goblin stood inside the Frog at the sigil.
static func hunter_side_offset(players: Array, i: int, height: int) -> float:
	var cap: int = maxi(height, 1)
	var foot: int = mini(int((players[i] as Dictionary).get("foothold", 0)), cap)
	for j in range(players.size()):
		if j != i and mini(int((players[j] as Dictionary).get("foothold", 0)), cap) == foot:
			return -1.0 if i == 0 else 1.0
	return 0.0


## Tween-callback wrapper for home_after_leg(): fired once per sub-hop, right
## as that leg's own flight starts, so the camera's lock point advances with
## the climb instead of sitting at the destination for the whole chain.
func _advance_climb_home(slot: int, leg: Vector3) -> void:
	if slot < 0 or slot >= _hunters.size():
		return
	var h: Dictionary = _hunters[slot]
	h["home"] = home_after_leg(h["home"] as Vector3, leg)


func _place_hunters(s: Dictionary) -> void:
	var players: Array = s.get("players", [])
	var boss: Dictionary = s.get("boss", {})
	var height: int = maxi(int(boss.get("weak_point_height", 1)), 1)
	while _hunters.size() < players.size():
		_hunters.append(_spawn_hunter(_hunters.size(), players))
	for i in range(players.size()):
		var p: Dictionary = players[i]
		var foot: int = int(p.get("foothold", 0))
		var t: float = clampf(float(foot) / float(height), 0.0, 1.0)
		var side: float = hunter_side_offset(players, i, height)
		var pos: Vector3
		if t <= 0.01:
			# At the feet, close in. Flanking scales with the body, and the bodies
			# are colossal now — a hunter parked half a Titan's width out lands
			# under the hand rail on one side or the party panel on the other.
			# Standing right at the foot also reads better: you're about to climb
			# this thing, not square up to it.
			# Back off the beast, so there is somewhere to put a camera.
			#
			# They used to stand at 0.9 of the beast's front face — close enough
			# to touch it, which left no room behind them and forced the lens
			# further out than the entire arena to see anything. Standing off by
			# a fraction of the beast's own front-edge distance scales with the
			# creature (ground_standoff_for above), and the clamp keeps them on
			# the floor rather than out in the apron.
			var back: float = ground_standoff_for(_beast_box.end.z)
			# Narrow, not the beast's own half-width: the grounded camera now
			# stands 9 units behind the active hunter, and at that range a split
			# sized off a 10-unit-wide beast threw the second hunter off the
			# right edge of the frame (VIS FAIL hunter1, measured).
			pos = Vector3(side * (_beast_box.size.x * 0.06 + 0.5), 0.0,
				minf(back, _arena_r * 0.86))
		elif not _climb_points.is_empty():
			# The model says where its ledges are, so stand on one. Fixed per
			# slot (not the dynamic `side` above), so a hunter's own approach
			# line never depends on where the ally happens to be standing --
			# Nick, 2026-09-25: "two sets of stones, one set for each character".
			pos = _stand_on_model(foot, side, -1.0 if i == 0 else 1.0)
		elif t >= 0.92:
			# at the weak point — stand ON the sigil, the thing the climb was for.
			# Scaled off the body: a fixed nudge that cleared a 2-unit-deep bear
			# leaves a hunter buried inside a 12-unit-deep Titan.
			var sx: float = _sigil.position.x + side * (_beast_box.size.x * 0.10 + 0.3)
			var sy: float = _sigil.position.y - 0.12
			pos = Vector3(sx, sy, maxf(_sigil.position.z,
				_front_of_beast(sx, sy) + HUNTER_HEIGHT * 0.45))
		else:
			var y := _beast_box.position.y + _beast_box.size.y * lerpf(0.18, 0.80, t)
			# closer to the spine than they used to be — a third of a Titan's width
			# out puts the right-hand climber behind the party panel, and hugging
			# the body reads more like climbing than like hanging off the edges
			var x := side * (_beast_box.size.x * 0.20)
			# out on the FRONT of the body, not a quarter of the way into it —
			# otherwise the hunter is behind the mesh and simply isn't there
			pos = Vector3(x, y, _front_of_beast(x, y) + HUNTER_HEIGHT * 0.45)
		var h: Dictionary = _hunters[i]
		var node: Node3D = h["node"]
		var from_pos: Vector3 = h["home"]
		var moved: bool = from_pos.distance_to(pos) > 0.05
		var was: int = int(h.get("foot", foot))
		var placed: bool = bool(h.get("placed", false))
		# A JUMP is for a change of HEIGHT. Nothing else — see hunter_move_kind.
		var kind := hunter_move_kind(placed, was, foot, moved)
		h["home"] = pos
		h["foot"] = foot
		# The SAME Height the grip label already reaches for (/core's
		# next_safe_height(), relayed here as p["next_safe"] — see
		# game_host.gd's snapshot build). _refresh_ledge_marks used to
		# rederive "the next rung" itself from the model's own ledge_N
		# markers; storing the real value here lets it read one number
		# instead of recomputing a second, disagreeing one. #86 duty 2.
		h["next_safe"] = int(p.get("next_safe", foot))
		h["placed"] = true
		if kind == "climb":
			# Climb VIA the ledges in between, not through the body. Going from
			# the ankle to the shoulder means stopping on the platform on the way,
			# which is the whole reason the anchors exist — a straight tween
			# between two heights walks a hunter through the beast's chest.
			var way: Array = []
			if not _climb_points.is_empty() and was != foot:
				way = _route_between(was, foot)
			var body: Node3D = h.get("body") as Node3D
			# Cancel whatever the last move was still doing. Two live tweens on one
			# node fight over its position every frame, and the hunter gets dragged
			# between two places that disagree — which is most of why the climb
			# looked like it was teleporting rather than jumping.
			_cancel_pending_tween(_climb_tw, i, body)
			var tw := create_tween()
			_climb_tw[i] = tw
			tw.set_trans(Tween.TRANS_QUAD)
			# Per HOP, not split across the whole route. Dividing a fixed budget
			# by the number of legs made a long climb a blur of tiny twitches and
			# a short one a slow float — the same jump should take the same time
			# however many of them there are.
			# 0.34 was quick enough to miss. Nick, 2026-09-23: slower and
			# clearer — you should be able to watch the whole arc.
			var step := 0.62
			# From where they were STANDING, not from node.position. If a hop was
			# interrupted the node is somewhere in mid-air, and arcing from there
			# starts the next jump at a point nobody chose.
			var at: Vector3 = from_pos
			node.position = from_pos
			var lo_y: float = minf(from_pos.y, pos.y)
			var hi_y: float = maxf(from_pos.y, pos.y)
			# Every named stop along the way (the in-between ledges, then the
			# final Height itself), THEN split each stop-to-stop leg with
			# hop_subpoints -- so a leg the route already agrees is one stop
			# (e.g. an ordinary Height N->N+1 on route_pos()'s line, now ~20m
			# since #14 widened the gap) plays as however many hops
			# hop_arc()'s own band asks for, not one stretched-out one. A leg
			# already short enough is untouched (hop_subpoints is a no-op).
			#
			# The `step` BUDGET for that one named-rung leg is shared across
			# however many sub-hops it got split into, not repeated for each
			# -- "per HOP, not split across the whole route" (the comment
			# above) already fixed this once for named-rung counts; splitting
			# a leg further and still charging each piece the FULL 0.62s
			# broke the same rule a second way; found live, first version of
			# this fix: a 3-named-rung climb (e.g. foot 2->5) split into 9
			# sub-hops at 0.62s each played for ~5.6s and lost the hunter off
			# the top of the frame for 71% of it (playtest's own
			# hunter-lost-mid-hop, step 16, 2026-09-25). Distance still
			# decides the ARC HEIGHT (hop_arc reads `from`/`to`, not `step`),
			# so a shared, smaller step keeps each piece reading as real
			# effort -- only the total climb's own length stops ballooning.
			var stops: Array[Vector3] = []
			for wp in way:
				stops.append(_stand_on_model(int(wp), side, -1.0 if i == 0 else 1.0))
			stops.append(pos)
			for stop in stops:
				var subs: Array[Vector3] = hop_subpoints(at, stop, HOP_MAX_LEG)
				var sub_step: float = step / float(subs.size())
				for sub in subs:
					# Advance the camera's lock point onto THIS leg before it
					# flies, not the climb's final stop -- see home_after_leg.
					tw.tween_callback(_advance_climb_home.bind(i, sub))
					_hop(tw, node, body, at, sub, sub_step)
					lo_y = minf(lo_y, sub.y)
					hi_y = maxf(hi_y, sub.y)
					at = sub
			# Tell the camera the whole arc BEFORE it starts, so it can frame
			# the jump as one shot instead of chasing it. Reacting per frame
			# always arrives late: on this Titan a single Leap covers more
			# height than the whole third-person frame, and the hunter simply
			# left the top of the screen for half the flight (filmstrip,
			# 2026-09-23). The apex adds the hop's own rise on top.
			if i == lock_slot_for(_lock_slot, _hunters.size(), _me()):
				var top: float = float(hop_arc(from_pos, pos, step)["hop"])
				_jump_lo = lo_y - HUNTER_HEIGHT
				_jump_hi = hi_y + top + HUNTER_HEIGHT * 1.6
		elif kind == "first":
			# FIRST placement: be there, with no animation.
			#
			# Nick, 2026-09-01: "hunters have been spawning underneath the
			# beast." They were, and this is why. Neither branch above could run
			# on the first pass - `climbed` needs `placed`, and so did the glide
			# below - so nothing assigned node.position at all, and the hunter
			# stayed at the Vector3.ZERO it was created with. Zero is the
			# BEAST'S OWN CENTRE, so every fight opened with both hunters
			# standing inside the Titan, and they only snapped out later when a
			# climb or a rescale finally moved them.
			#
			# It hid for so long because `h["home"]` was always correct: the
			# camera framed the right spot, the hold maths measured from the
			# right spot, and every check that asked the GAME where a hunter was
			# got the right answer. Only the drawing was wrong.
			node.position = pos
		elif kind == "glide":
			# The world moved under them — the beast rescaled, the sigil settled.
			# Slide, do not leap: they have not gone anywhere.
			#
			# The climb branch above cancels whatever tween _climb_tw[i] still
			# holds before it starts a new one; this branch overwrote the same
			# dict entry without ever doing that. A rescale/settle landing while
			# an earlier climb (or glide) is still mid-flight for this hunter
			# left BOTH tweens driving node.position — and, when the pre-empted
			# tween was a climb, body.scale too — every frame, so the hunter got
			# dragged between two places that disagree: the exact symptom the
			# climb branch's own comment exists to prevent, just unguarded here.
			var body: Node3D = h.get("body") as Node3D
			_cancel_pending_tween(_climb_tw, i, body)
			var glide := create_tween()
			_climb_tw[i] = glide
			_start_glide(glide, node, pos, 0.18)
		# ground hunters stand three-quarter on, turned in toward the beast
		node.rotation.y = (PI + 0.7 * side) if t <= 0.01 else (PI * 0.5 * -side)


## Hunters come from ui/cast.gd, the one place that knows which body plays which
## character — and that prefers cast/<id>.glb, your own art, over the stand-in.
## Exporting a model is the whole job; no code edit makes it show up.
func _spawn_hunter(slot: int, players: Array) -> Dictionary:
	var p: Dictionary = players[slot]
	var cid := String(p.get("character", ""))
	var holder := Node3D.new()
	_rig.add_child(holder)
	# Your own cast/<character>.glb wins over the Kenney stand-in (see ui/cast.gd),
	# so exporting a model is the whole job — no code edit to make it show up.
	var path := Cast.model_path(cid)
	# HUNTER_AI_ART beats even your own cast/<id>.glb, the same order AI_ART
	# takes over a beast's Python-built model in _show_beast — the rigged,
	# toon-shaded build is the upgrade, so it wins when it exists.
	var hunter_toon := false
	if HUNTER_AI_ART.has(cid):
		var ai_path := CAST + cid + String(HUNTER_AI_ART[cid]) + ".glb"
		if ResourceLoader.exists(ai_path):
			path = ai_path
			hunter_toon = true
	var body: Node3D = null
	var anim: AnimationPlayer = null
	if ResourceLoader.exists(path):
		var m := (load(path) as PackedScene).instantiate()
		holder.add_child(m)
		_shade_model(m, false, hunter_toon, cid)
		_fit_height(m, HUNTER_HEIGHT)
		body = m
		# Same idle-loop wiring _show_beast gives a rigged beast — a no-op for
		# a model with no AnimationPlayer (every hunter today).
		anim = _find_anim(m)
		if anim != null and anim.has_animation("idle"):
			anim.get_animation("idle").loop_mode = Animation.LOOP_LINEAR
			anim.play("idle")
	holder.add_child(_hunter_pip(slot))
	# The BODY is kept apart from the holder because the climb hop squashes it,
	# and the pip is a child of the holder too — squashing that would pump the
	# one marker that has to stay readable from across the arena.
	return {"node": holder, "home": Vector3.ZERO, "body": body, "anim": anim}


## Orbiting means a hunter can end up behind the beast's body. A pip that draws
## THROUGH the beast keeps both of them findable from any angle — otherwise the
## camera freedom costs you the one thing you always need to know.
func _hunter_pip(slot: int) -> Node3D:
	var pip := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 0.12
	cone.height = 0.22
	cone.radial_segments = 8
	pip.mesh = cone
	var mat := StandardMaterial3D.new()
	mat.albedo_color = _slot_color(slot)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.no_depth_test = true
	mat.render_priority = 2
	pip.material_override = mat
	pip.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	pip.rotation.z = PI  # point down at the hunter it marks
	pip.position = Vector3(0, 0.72, 0)
	return pip


## Which climb-point Heights get a safety ring: the real safe holds
## (`_safe_ledges`, straight off `boss.ledges` — the same data
## is_secure()/next_safe_height() use) intersected with the Heights the
## model actually has physical footing for (`_climb_points`). #86 duty 2 (two
## copies of one truth) — before this, the ring set came ONLY from the
## model's own "ledge_N" node names, with no connection to which Heights
## combat.gd treats as safe; see the doc comment on `_safe_ledges` for the
## divergence confirmed against shipped beasts. Sorted so callers get a
## stable, climb-order list.
static func safe_ledge_marks(safe_heights: Array, climb_point_heights: Array) -> Array:
	var climbable := {}
	for h in climb_point_heights:
		climbable[int(h)] = true
	var out: Array = []
	for h in safe_heights:
		var height := int(h)
		if climbable.has(height) and height not in out:
			out.append(height)
	out.sort()
	return out


## Draw a ring on every ledge a hunter could stand on.
##
## Placed with `_stand_on_model`, the same call that puts a hunter there, so the
## ring is exactly where you would arrive rather than near it. Flat to the
## ground and slightly proud of the surface, because a ring standing upright on
## a beast's flank reads as a part of the beast.
##
## Built after `_build_hull`, not with the climb points: `_stand_on_model` needs
## `_front_of_beast`, which needs the hull.
## Floating stepping stones, one per climb anchor: the thing a hunter jumps
## onto. Built here rather than modelled into each beast (Nick, 2026-09-23) —
## every boss gets them for free, they never deform with the body, and a jump
## target that hangs in the air reads as a jump target.
## Where a floating stone hangs for a point on the beast's skin: pushed
## forward off the surface, same direction _front_of_beast/GROUND_STANDOFF
## already treat as "away from the body" everywhere else in this file, so it
## sits proud of the skin rather than embedded in it. Shared so the jump ring
## and the stone can never drift apart.
##
## Used to push radially away from world origin in the XZ plane instead
## (normalize on_skin.x/z, scale by HUNTER_HEIGHT). That reads as "away from
## the model's own vertical axis" for a point near the spine, but every climb
## anchor already carries its own real x (stand_offset_x's side spacing is
## added on TOP of it before this runs) — so for an anchor already off-axis
## in x, like foothold 4 on the Cinder Jackal's ear (anchor x=3.9), the radial
## push added its OWN x-drift on top of stand_offset_x's already-budgeted
## side spacing. Harmless alone (well under playtest.gd check 8's
## tolerance), but compounding with a second hunter's side offset at a shared
## foothold pushed the total past it —
## 2026-09-23-fixer-to-fixer-shared-foothold-side-spacing-clears-the-model.
## A pure forward push carries zero x-component, so it can never add to
## stand_offset_x's own spacing regardless of an anchor's x.
static func stone_point(on_skin: Vector3) -> Vector3:
	return on_skin + Vector3(0.0, 0.0, HUNTER_HEIGHT)


## Where a rung's stone sits once the route is a PATH ACROSS THE GAP rather
## than a ladder bolted to the beast's flank.
##
## Nick, 2026-09-24, with a drawing: the stones climb away from the hunter
## toward a distant beast, big and near in the foreground, smaller as they go.
## Every stone used to sit at its climb point on the skin, so the whole route
## was a vertical smear against the body and read as scattered rocks.
##
## `top` is the climb point (where the hunter must end up, unchanged -- the
## hop still has to land on the body). `ground_z` is where the hunters stand.
## Rung `i` of `n` is placed that fraction of the way in, so the first stone
## is out near the hunters and the last is at the beast. Height comes from the
## climb point untouched, so the path rises as it recedes.
##
## Nick, live, 2026-09-24 22:25 EDT (relayed by the director, #14): a straight
## line AHEAD (this function's first version, `start.x = top.x * 0.2`, barely
## off centre) reads as stones stacked one over the other when the resting
## camera sits behind the hunter -- his drawing is a diagonal across the
## picture, first stone low and LEFT of the hunter, each next one further
## RIGHT and higher, the last at the head. `half_width` (STONE_SWEEP_WIDTH at
## the one call site -- sized off the hunter, not the beast; see its own doc
## comment for why a beast-width sweep stretched badly this close to the
## camera) sets how far left of the top hold's own x the sweep starts; this
## is still ONE straight line (start to top, lerped by `t`), just angled in x
## as well as z/y, so the "one line, even steps" spacing Nick measured
## (b0648db) is unchanged -- a straight line has the same even Euclidean
## spacing wherever it points.
static func route_pos(top: Vector3, ground_z: float, i: int, n: int,
		half_width: float) -> Vector3:
	if n <= 1:
		return top
	# ONE straight line from the ground to the top hold, with the rungs spaced
	# evenly along it. Lerping each rung toward its OWN body anchor instead was
	# the obvious version and it was wrong: five different destinations make
	# five different step lengths, and the playtest measured consecutive hops
	# of 2.38m and 1.51m against its own 2.42m floor. Even spacing is the whole
	# point of a staircase -- it is what lets you read the route as a route.
	var t := clampf(float(i) / float(n - 1), 0.0, 1.0)
	# The near end: LEFT of the top hold's own x (the sideways sweep above),
	# just in front of the hunters, barely off the ground. Height matters as
	# much as depth -- keeping the climb point's own y put the very first
	# stone six units in the air right beside the hunter, which reads as a
	# floating rock, not a first step.
	var start := Vector3(top.x - half_width, HUNTER_HEIGHT * 1.6,
		ground_z - HUNTER_HEIGHT * 6.0)
	return start.lerp(top, t)


## Extra sideways clearance for the low-to-mid stretch of the approach, on
## top of route_pos()'s own straight sweep.
##
## 2026-09-25, director (#0658): route_pos()'s line has to land exactly on
## the gap's own near end (t=0, #14/#0505) and exactly on the sigil (t=1,
## the beast's real anchor) -- neither endpoint can move -- but nothing
## requires the line's own middle to stay dead straight. Measured on the
## live route: the worst on-screen overlap with the beast (43% on one
## stone, 25-30% on its neighbours) sits low and early, roughly a sixth to
## a third of the way up the climb; by the point route_pos's own sweep has
## closed to within 40% of the sigil, the beast is already clear (12% and
## falling). This bulges exactly that early stretch further along the same
## direction route_pos already sweeps, fading linearly to zero by t=0.6 so
## the stones from there to the sigil (already reading clean) are untouched.
##
## 2026-09-25, director (#0802): the first version of this push applied to
## the DECORATIVE rock only (_build_float_stones), leaving the hunter's own
## foot (`_stand_on_model`, still plain route_pos) up to CHEST_CLEAR_PUSH
## (5.6 units) away from the stone it was supposed to be standing on -- the
## Frog landed on air beside its own rock at the first hold. "Neither
## endpoint can move" was about the GAP'S OWN WIDTH and the sub-hop split
## (#14/#0505/#0420), never about this push: #0802 asks for exactly this
## lever to move the real landing too, not a new one.
##
## 2026-09-25, director (#0802 follow-up): a version that moved the FOOT at
## i=0 only shipped next, because moving every rung's own foot moves the
## resting camera too (`_lock_point` reads `home.x/z`) and one run measured
## that swinging `beast-behind-stone` on an unrelated, far-away stone. That
## traded a visible defect (hunters hanging 1.3-4.7 hunter-heights off their
## own stone at every rung above the first) for a check number on a stone
## nobody was ever meant to be standing near -- backwards, per the ticket
## this reopened it. The occluding stone was always free to move on its own
## (see NEAR_LEG_CLEAR below, next to `_build_float_stones`); the hunter's
## foot was never the thing that had to give.
## Nick, 2026-09-25 (stones queue item): projecting rung 0 to screen under the
## LOCKED third-person cam (`state=3d`, dist=3 -- the camera sits almost on
## top of the near stone) showed it at x=-545 on a 1280-wide frame -- the
## CHEST_CLEAR_PUSH of 8.0 above, stacked on STONE_SWEEP_WIDTH's own sweep,
## threw the one stone that is supposed to read as "in front of the hunter"
## clean out of frame, which is the actual cause of "stones cluster beside
## the flank, ground between Frog and jackal empty": every rung this push
## still reaches (t < CHEST_CLEAR_TAPER) was invisible, leaving only the
## rungs past the taper on screen, all bunched near the sigil. Zeroed rather
## than deleted -- the beast-overlap problem this push fixed (#0658) may
## still be real once the queued zoom-out lands and the camera is no longer
## sitting on the near stone; re-measure then, don't just restore the number.
const CHEST_CLEAR_TAPER := 0.6
const CHEST_CLEAR_PUSH := HUNTER_HEIGHT * 0.0
static func chest_clear_push(t: float) -> float:
	return CHEST_CLEAR_PUSH * clampf(1.0 - t / CHEST_CLEAR_TAPER, 0.0, 1.0)


## route_pos(), with chest_clear_push's own push folded in at EVERY rung, not
## only the first -- the point `_stand_on_model` hands the hunter to stand on
## must match what `_build_float_stones` hands the decorative rock at that
## same landing (both read the same `t = i/(n-1)`), or the two disagree about
## where a rung's stone actually is and the hunter stands on air beside it.
## Past the taper (t >= CHEST_CLEAR_TAPER, i.e. the top hold too) the push is
## already zero, so this changes nothing there. route_pos() itself stays
## pure and untouched (its own "one line, even steps" tests keep pinning the
## un-pushed geometry).
static func route_pos_cleared(top: Vector3, ground_z: float, i: int, n: int,
		half_width: float) -> Vector3:
	var p := route_pos(top, ground_z, i, n, half_width)
	if n <= 1:
		return p
	var t := clampf(float(i) / float(n - 1), 0.0, 1.0)
	p.x += signf(-half_width) * chest_clear_push(t)
	return p


func _build_float_stones() -> void:
	for st in _float_stones:
		(st as Node3D).queue_free()
	_float_stones.clear()
	if _beast == null:
		return
	# One stone per named climb Height, one set per hunter -- Nick,
	# 2026-09-25: "I would like the amount of stones be the amount of spaces
	# needed to climb to reach the sigil... try making two sets of stones,
	# one set for each character." The previous version also dropped a
	# stone under every hop_subpoints() sub-landing between two named rungs
	# (#0505, so a long leg's animation never touched open air mid-flight),
	# which put 15-20 stones on this beast (5 Heights, several sub-hops
	# each) against his drawing's five. hop_subpoints still splits a long
	# leg into several real hops for _place_hunters' own animation,
	# unchanged -- only the DECORATIVE footing goes back to one per Height,
	# matching what he actually asked to see. `route_pos_cleared` is the
	# SAME call `_stand_on_model`'s `route_side` branch makes for a hunter's
	# real foot at this same rung and side, so a hunter always lands
	# exactly on its own line's own stone, top hold included (t=1 there is
	# `top_pt` itself, already `_top_hold(side)` -- no separate case needed).
	var ground_z: float = ground_standoff_for(_beast_box.end.z)
	var n := _rung_count()
	for side in [-1.0, 1.0]:
		var top_pt: Vector3 = _top_hold(side)
		for index in range(n):
			var pos: Vector3 = route_pos_cleared(top_pt, ground_z, index, n, STONE_SWEEP_WIDTH)
			_add_float_stone(pos, index, n)


## One decorative rock+cap+rim at `pos`, sized by how far along its own route
## (`index` of `count`) it sits -- big near the hunter, smaller toward the
## beast (Nick, 2026-09-24, with a drawing). Pulled out of _build_float_stones
## so building one hunter's line and then the other's is one call each, not a
## duplicated block.
func _add_float_stone(pos: Vector3, index: int, count: int) -> void:
	# A wrapper, not a mesh directly, so the bob/spin in _process (which
	# reads/writes `st.position`/`st.rotation.y` by array index — see the
	# loop over `_float_stones` above) still moves the whole shelf as one
	# rigid piece, while the flat cap and rim below stay level and don't
	# inherit the boulder's own random tilt/squash (see BODY below).
	var stone := Node3D.new()
	stone.position = pos
	_rig.add_child(stone)

	# BODY: an irregular convex-hull rock (FOOTHOLD_ROCK, the artist's
	# asset, #17: "the current sphere reads as a pot; this reads as
	# rock" — replaces the old SphereMesh, which is why this stayed a
	# `MeshInstance3D` far longer than it needed to). The CAP below is
	# unaffected — it stays a true flat, standable plane regardless of
	# the body under it.
	#
	# Sized off the HUNTER — it is a place a person stands, so it must
	# stay the same size under a Crag Pup and a Titan. About three
	# hunters wide at the near end (Nick, 2026-09-23 — "make the stones
	# bigger"), as tall as it is wide (#16: "a teacup and a saucer" was
	# the old squashed-sphere complaint). #0505: "big near the Frog,
	# smaller as they recede -- the drawing's path" -- shrinks toward
	# the beast, landing by landing, not a flat size for every stone.
	var recede: float = float(index) / float(maxi(count - 1, 1))
	var rock_radius := lerpf(HUNTER_HEIGHT * 1.5, HUNTER_HEIGHT * 1.0, recede)
	var rock_height := rock_radius * 2.0
	# Sunk enough that the CAP below (not the bare rock) is what a
	# hunter visually lands on, with no gap between the two.
	var cap_height := HUNTER_HEIGHT * 0.22
	var body := (FOOTHOLD_ROCK as PackedScene).instantiate()
	# The mesh's own origin is at its base centre (this project's usual
	# contract), not centred like the old SphereMesh — its flat top
	# (the landing face) sits at local height ~1.74 before scale
	# (design/progress/foothold_rock.md, pass 2). Scale to the target
	# diameter/height off that native size, then sit the base low
	# enough that the scaled top reaches the underside of the cap.
	var body_scale: float = (rock_radius * 2.0) / 1.74
	body.position = Vector3(0.0, cap_height * 0.5 - rock_height, 0.0)
	body.scale = Vector3.ONE * body_scale
	# Y-axis spin only (no per-instance tilt/squash, unlike the old
	# sphere): a hull mesh's irregular shape already reads as a
	# different rock at each facet a spin lands on, and the artist's
	# own handoff dropped tilt/squash on purpose — tuned for a sphere,
	# it would distort this mesh's shape unpredictably.
	body.rotation.y = randf_range(0.0, TAU)
	stone.add_child(body)
	# Geometry only — no colour/texture of its own (foothold_rock.md) —
	# so the #12 palette and the ROCK_DETAIL multiply below still apply
	# exactly as they did to the old sphere, via whichever MeshInstance3D
	# the imported scene actually holds.
	var body_mesh: MeshInstance3D = body as MeshInstance3D
	if body_mesh == null:
		var found := body.find_children("*", "MeshInstance3D", true, false)
		if not found.is_empty():
			body_mesh = found[0] as MeshInstance3D
	var body_mat := StandardMaterial3D.new()
	# Was BROWN basalt — matched the fight's old warm UMBER ground and
	# beast so closely it disappeared into both (Nick, 2026-09-24, #12:
	# "basalt brown against brown ground... the stones are pale, nearly
	# white... they are the brightest thing in the picture after the
	# beast's own heat"). Now a pale warm-neutral grey sampled off his
	# reference (design/art/references/2026-09-24-nick-target-
	# composition.webp, the stepping-stones: ~(174,171,165)), pushed a
	# touch paler still since this is the body, not the lit cap below.
	# Small per-stone jitter so a run of stones at neighbouring heights
	# doesn't read as the same clone.
	var tint := randf_range(-0.05, 0.05)
	body_mat.albedo_color = Color(0.72 + tint, 0.70 + tint, 0.65 + tint)
	# Generated faceted-rock multiply (ROCK_DETAIL, a toroidal Voronoi
	# grayscale) so the stone reads as cut rock instead of one flat
	# colour — "footholds are plain basalt" (artist.md item 1). Every
	# stone shares the one texture; the per-stone spin above already
	# turns it to a different facet each time, so they still don't read
	# as clones.
	body_mat.albedo_texture = ROCK_DETAIL
	body_mat.roughness = 1.0
	if body_mesh != null:
		body_mesh.material_override = body_mat

	# CAP: the flat top face the playtester's request asked for
	# (`2026-09-23-1846-...make-ledges-read-as-shelves`). A round boulder
	# alone reads as a loose rock you jump ONTO; a flat plane sitting on
	# top reads as a surface you stand ON, from Breath of the Wild's own
	# cue for "this is footing" (the request's named reference). Left
	# level (no random tilt) so it always reads as a true horizontal
	# shelf no matter how the body under it is squashed/rotated, and its
	# top face sits exactly at the local origin — the same anchor
	# `_stand_on_model` puts the hunter's feet at.
	var cap := MeshInstance3D.new()
	var cap_mesh := CylinderMesh.new()
	cap_mesh.top_radius = rock_radius * 0.92
	cap_mesh.bottom_radius = rock_radius * 1.05
	cap_mesh.height = cap_height
	cap_mesh.radial_segments = 8
	cap.mesh = cap_mesh
	var cap_mat := StandardMaterial3D.new()
	# Nearly white — was a warm sandstone tan, lighter than the body
	# under it but still close enough to the fight's old orange-brown
	# family to blend in (Nick, 2026-09-24, #12). Pushed paler than the
	# body above so the worn top face, the part a foot actually lands
	# on, is unmistakably the lightest thing on screen after the beast's
	# own glow, per the request's own "Done when": readable as the
	# lightest thing at a glance, even at the wide shot's distance.
	var cap_tint := randf_range(-0.04, 0.04)
	cap_mat.albedo_color = Color(0.88 + cap_tint, 0.86 + cap_tint, 0.82 + cap_tint * 0.7)
	cap_mat.albedo_texture = ROCK_DETAIL
	cap_mat.roughness = 0.75   # a touch less rough than the raw body: worn, not raw rock
	cap.material_override = cap_mat
	cap.position = Vector3(0.0, -cap_height * 0.5, 0.0)
	cap.rotation.y = randf_range(0.0, TAU)
	stone.add_child(cap)

	# RIM: a thin warm edge along the cap's lip. This is the "rim
	# light or edge highlight" the request asked for — unshaded so it
	# reads the same regardless of which way the key light is falling,
	# and it is what actually carries the shelf's silhouette at the
	# distance/size of the wide shot, where the cap/body colour
	# difference alone gets small on screen.
	var rim := MeshInstance3D.new()
	var rim_mesh := TorusMesh.new()
	rim_mesh.inner_radius = cap_mesh.top_radius * 0.86
	rim_mesh.outer_radius = cap_mesh.top_radius * 1.02
	rim_mesh.rings = 24
	rim_mesh.ring_segments = 5
	rim.mesh = rim_mesh
	var rim_mat := StandardMaterial3D.new()
	rim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rim_mat.albedo_color = Color(0.95, 0.55, 0.18, 0.9)   # warm ember edge, matches this fight's palette
	rim_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rim.material_override = rim_mat
	rim.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	rim.position = Vector3(0.0, -0.005, 0.0)   # just under the cap's own top face, at its edge
	stone.add_child(rim)

	_float_stones.append(stone)
	_float_home.append(stone.position)


func _build_ledge_marks() -> void:
	for m in _ledge_marks.values():
		(m as Node3D).queue_free()
	_ledge_marks.clear()
	if _beast == null:
		return
	for h in safe_ledge_marks(_safe_ledges, _climb_points.keys()):
		var height := int(h)
		var ring := MeshInstance3D.new()
		var torus := TorusMesh.new()
		# Sized off the hunter, not the beast: it marks a place a PERSON stands,
		# and it has to stay legible on a Titan without swallowing a small beast.
		torus.inner_radius = HUNTER_HEIGHT * 0.46
		torus.outer_radius = HUNTER_HEIGHT * 0.60
		torus.rings = 16
		torus.ring_segments = 6
		ring.mesh = torus
		var mat := StandardMaterial3D.new()
		mat.albedo_color = LEDGE_COLOR
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		# Depth test ON, unlike the hunter pips: a jump point behind the beast is
		# not a jump point you can take, and drawing it through the body would
		# say the far side is reachable.
		ring.material_override = mat
		ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var p := _stand_on_model(height, 0.0)
		# UPRIGHT, not flat on the ledge. A TorusMesh lies in XZ by default, and
		# the fight camera looks at a beast's flank from roughly level — so a
		# flat ring presents almost no area and the first version was invisible
		# on screen even though it was drawn exactly where it should be. Standing
		# it up trades physical plausibility for being seeable, which is the
		# entire job of a marker.
		ring.rotation.x = PI * 0.5
		# Clear of the skin so the body does not eat the lower half of it.
		# _stand_on_model already returns the point ON the stone, so no second
		# push out here; just lift the ring clear of the stone's face.
		ring.position = Vector3(p.x, p.y + HUNTER_HEIGHT * 0.40, p.z)
		_rig.add_child(ring)
		_ledge_marks[height] = ring
	_refresh_ledge_marks()


## Which rings are lit, and how brightly.
##
## The ledge the active hunter is standing on is hidden outright — a marker
## under your own feet is clutter, not information. Everything else is dim
## except the next rung up, which is the one the climb is actually asking about.
## Pure decision behind _refresh_ledge_marks() below: a ring exactly under the
## active hunter's own feet is hidden outright (a marker under your own feet
## is clutter, not information — see that function's own doc comment), the
## next safe rung up the /core climb label is already pointing at gets
## highlighted, and every other rung stays plain. Split out static, the same
## reason route_between_rungs/foothold_anchor already are (#86 duty 3): this
## is the exact rule #86 duty 2 fixed here (the highlight used to come from a
## second, model-only search that could disagree with the grip label), and it
## had never been pinned with a test of its own — only touched indirectly,
## through the scene-tree-dependent function around it.
static func ledge_mark_state(height: int, foot: int, next_safe: int) -> Dictionary:
	return {"visible": height != foot, "highlighted": height == next_safe}


func _refresh_ledge_marks() -> void:
	if _ledge_marks.is_empty():
		return
	var foot := -1
	# The exact Height the grip label already says to reach for
	# (/core's next_safe_height(), relayed as h["next_safe"] in
	# _place_hunters) — not a second search over `_ledges` for "the nearest
	# model-marked ledge above me", which used to disagree with the label
	# whenever a beast's ledge_N node names didn't match its real safe
	# heights. #86 duty 2.
	var next := -1
	if _active_slot >= 0 and _active_slot < _hunters.size():
		var active: Dictionary = _hunters[_active_slot]
		foot = int(active.get("foot", 0))
		next = int(active.get("next_safe", foot))
	for h in _ledge_marks.keys():
		var height := int(h)
		var ring: MeshInstance3D = _ledge_marks[height]
		var state := ledge_mark_state(height, foot, next)
		ring.visible = bool(state["visible"])
		var mat := ring.material_override as StandardMaterial3D
		if mat == null:
			continue
		mat.albedo_color = LEDGE_NEXT if bool(state["highlighted"]) else LEDGE_COLOR


## The weak point sits atop the beast and pulses, so the target of the whole
## climb is a place you can see rather than a number.
func _place_sigil(s: Dictionary) -> void:
	var boss: Dictionary = s.get("boss", {})
	var on: bool = int(boss.get("weak_point_height", 0)) > 0
	_sigil.visible = on
	if not on:
		return
	# The model carries its own gold mark now, at the Height its data says. Put
	# the marker THERE rather than at 88% of the bounding box, or the beast wears
	# two sigils in different places and the floating one wins the eye.
	var wp := int(boss.get("weak_point_height", 0))
	_sigil_scale = clampf(_beast_box.size.y * 0.016, 0.28, 0.85)
	if _climb_points.has(wp):
		# Just in FRONT of the mark the model already wears, so the pulsing glow
		# reads as a highlight ON the weak point rather than as a second sigil
		# floating near it.
		#
		# Lifted above the climb point, not level with it: the same anchor is
		# also where `_build_float_stones` hangs the shelf a hunter stands on
		# (`_stand_on_model` -> `stone_point`, same `_climb_points[wp]`), and
		# that stone got a bright faceted-rock texture 2026-09-23
		# (foothold_rock_detail.md). A real render at the sigil
		# (`state=3dstrike`) showed the gold glow sitting almost exactly on
		# that shelf's own surface, both already near-peak brightness in the
		# same warm hue -- sampled pixels there never exceeded the shelf's
		# own (255,*,*) values, so `emission_energy_multiplier=3.0` had
		# nothing left to stand out against. A hunter's own height of open
		# air sits above every shelf (the boulder's bulk is mostly BELOW the
		# stand point, not above it), against the dark cave wall/ceiling
		# rather than the shelf -- moving the mark there costs no colour
		# change and no taste call, only a placement fix.
		#
		# 0.9x cleared the shelf but not the hunter: from `state=3dclimb`, the
		# camera that follows whoever is AT the sigil, the lift landed at that
		# hunter's own torso/head height (a hunter is HUNTER_HEIGHT tall,
		# feet at the climb point) and the mark read as part of their sprite,
		# not a separate thing (pass 5, 2026-09-24). 1.7x clears a standing
		# hunter's head at that same anchor, so the mark shows above their
		# shoulder instead of behind their body -- still a placement number,
		# no colour or scale change, and still well inside the headroom
		# `climb_frame_for` already reserves for a visible sigil (up to
		# active + 3.0 world units).
		_sigil.position = (_climb_points[wp] as Vector3) + Vector3(0.0, HUNTER_HEIGHT * 1.7,
			_beast_box.size.z * 0.05)
		return
	# On the FRONT of the body. A quarter-depth offset put it inside the mesh —
	# survivable when a beast was 2 units deep, invisible now one is 12.
	_sigil.position = Vector3(_beast_box.get_center().x,
		_beast_box.position.y + _beast_box.size.y * 0.88,
		_beast_box.end.z * 0.86)


# --- reactions (the same snapshot deltas the 2D view uses) ----------------

## Pure decision half of _react(): given the previous snapshot and the new
## one, what changed and what the view should do about it. No node access,
## no Sfx/_damage_popup calls, so it's provable from headless.
##
## backlog #86 duty 2: _react() used to compute `php` (per-hunter hp) only
## AFTER the encounter/party-size guard, so the very first state update of
## every fight synced foots/reached with a real baseline but left `_prev_php`
## at its default `[]`. The NEXT update (the fight's first real action) then
## hit a second guard -- "_prev_php.size() != php.size()" -- that existed
## only to catch that self-inflicted mismatch, and it re-synced and returned
## instead of reacting. Net effect: the boss's first hit of every fight never
## flashed or popped a damage number, and a first-turn climb never played its
## sound -- not because those systems were wrong, but because the reaction
## code ate its own first real frame. Computing php in the same pass as
## foots/reached (both here and in _react below) means there's only ever one
## kind of "first pass" -- the encounter/party-size guard -- and it now syncs
## a COMPLETE baseline, so the very next update reacts normally.
static func react_plan(prev_enc: int, prev_foot: Array, prev_reached: Array,
		prev_php: Array, prev_hp: int, enc: int, hp: int, foots: Array,
		reached: Array, php: Array) -> Dictionary:
	if enc != prev_enc or prev_foot.size() != foots.size():
		return {"resync": true}
	var boss_hit := hp < prev_hp
	var hunter_dmg: Array = []
	var foot_actions: Array = []
	for i in range(foots.size()):
		hunter_dmg.append(prev_php[i] - php[i] if php[i] < prev_php[i] else 0)
		if not prev_reached[i] and reached[i]:
			foot_actions.append("reach")
		elif foots[i] > prev_foot[i]:
			foot_actions.append("climb")
		elif foots[i] < prev_foot[i]:
			foot_actions.append("fall")
		else:
			foot_actions.append("")
	return {
		"resync": false,
		"boss_hit": boss_hit,
		"weak": (reached.has(true) or prev_reached.has(true)) if boss_hit else false,
		"boss_dmg": (prev_hp - hp) if boss_hit else 0,
		"hunter_dmg": hunter_dmg,
		"foot_actions": foot_actions,
	}


func _react(s: Dictionary) -> void:
	var boss: Dictionary = s["boss"]
	var players: Array = s["players"]
	var enc := int(s.get("encounter", 0))
	var hp := int(boss.get("hp", 0))
	var foots: Array = []
	var reached: Array = []
	var php: Array = []
	for p in players:
		foots.append(int(p.get("foothold", 0)))
		reached.append(bool(p.get("reached", false)))
		php.append(int(p.get("hp", 0)))
	var plan := react_plan(_prev_encounter, _prev_foot, _prev_reached, _prev_php,
		_prev_hp, enc, hp, foots, reached, php)
	if not bool(plan["resync"]):
		if plan["boss_hit"]:
			_strike(plan["weak"])
			_damage_popup(plan["boss_dmg"],
				_sigil.position if plan["weak"] else _beast_box.get_center(), plan["weak"])
			# A hunter's card just landed on the beast. The shared diff this
			# reacts to (same as _strike above) carries no per-hunter attribution
			# for WHICH hunter's play connected — only that the boss took a hit —
			# so every hunter takes its own "attack" beat together, at the same
			# granularity _beast_play("attack") below already uses for the
			# beast's side of a hit. A no-op for any hunter without a
			# HUNTER_AI_ART model wired to an AnimationPlayer (every hunter today).
			for hi in range(_hunters.size()):
				_hunter_play(hi, "attack")
		var hunter_dmg: Array = plan["hunter_dmg"]
		var foot_actions: Array = plan["foot_actions"]
		# The beast bit someone: that is its attack landing, so it is seen doing it.
		if hunter_dmg.any(func(d): return int(d) > 0):
			_beast_play("attack")
		for i in range(foots.size()):
			if hunter_dmg[i] > 0 and i < _hunters.size() \
					and is_instance_valid((_hunters[i] as Dictionary)["node"]):
				# Hunters bleed too, and how hard you were hit is the thing you most
				# need to know before deciding next turn.
				var hnode: Node3D = (_hunters[i] as Dictionary)["node"]
				_damage_popup(hunter_dmg[i],
					hnode.position + Vector3(0.0, HUNTER_HEIGHT * 1.4, 0.0), false, true)
				_hunter_play(i, "hit")
			match String(foot_actions[i]):
				"reach": Sfx.play("reach_sigil")
				"climb": Sfx.play("climb")
				"fall": _beast_shake()
	_sync(enc, hp, foots, reached, php)


func _sync(enc: int, hp: int, foots: Array, reached: Array, php: Array = []) -> void:
	_prev_encounter = enc
	_prev_hp = hp
	_prev_foot = foots
	_prev_reached = reached
	_prev_php = php


## Everything that isn't playing a card, behind one button. Settings live here
## rather than as their own HUD controls precisely because the screen was already
## too busy — the cure for clutter is not more buttons.
## One row of the keybind list: what it does on the left, the key on the right.
func _keybind_row(spec: Dictionary) -> Control:
	var id := String(spec["id"])
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var name_lbl := _detail_label(String(spec["name"]), 13, Color(0.9, 0.86, 0.78))
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_lbl)

	var btn := Button.new()
	btn.custom_minimum_size = Vector2(104, 34)
	# FOCUS_NONE matters here: a focused Button eats Space and Enter as "press me",
	# so binding Space would re-open the very button you just clicked.
	btn.focus_mode = Control.FOCUS_NONE
	btn.text = _key_name(Progress.keybind(id))
	btn.pressed.connect(func() -> void:
		# Cancel any other row already listening, so only one key is ever captured.
		if _rebinding != "" and _rebind_btns.has(_rebinding):
			(_rebind_btns[_rebinding] as Button).text = _key_name(Progress.keybind(_rebinding))
		_rebinding = id
		btn.text = "press a key")
	_rebind_btns[id] = btn
	row.add_child(btn)
	return row


## Finish a rebind with the key the player just pressed. Escape cancels — it is
## the one key nobody should be able to bind, because it is how you back out.
func _apply_rebind(code: int) -> void:
	var id := _rebinding
	_rebinding = ""
	if code != KEY_ESCAPE:
		Progress.set_keybind(id, code)
	# Every row, not just this one: binding a key steals it from whoever held it.
	for other: String in _rebind_btns:
		var b: Button = _rebind_btns[other]
		if is_instance_valid(b):
			b.text = _key_name(Progress.keybind(other))


static func _key_name(code: int) -> String:
	if code == KEY_NONE:
		return "unbound"
	if code == KEY_SPACE:
		return "Space"          # OS_get_keycode_string gives "Space" already, but be sure
	return OS.get_keycode_string(code)


## One keyword, on its own. Right-clicking the word "Poison" should answer
## "what does Poison do" and nothing else — the full card inspector is the answer
## to a different question, and burying one term in it makes you hunt.
func _show_keyword(kw: Dictionary) -> void:
	if kw.is_empty():
		return
	_close_overlay()
	_detail = ColorRect.new()
	_detail.color = Color(0.04, 0.03, 0.02, 0.55)
	_detail.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_detail.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay_root().add_child(_detail)
	_detail.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and (e as InputEventMouseButton).pressed:
			_close_overlay())

	var centre := CenterContainer.new()
	centre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_detail.add_child(centre)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(360, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.13, 0.105, 0.08, 0.99)
	st.set_border_width_all(2)
	st.border_color = Color(0.62, 0.5, 0.3)
	st.set_corner_radius_all(6)
	for side in ["left", "right", "top", "bottom"]:
		st.set("content_margin_" + side, 16.0)
	panel.add_theme_stylebox_override("panel", st)
	centre.add_child(panel)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(col)
	col.add_child(_underlined(String(kw.get("name", "")), 18, Color(1, 0.86, 0.5)))
	var body := _detail_label(String(kw.get("text", "")), 13, Color(0.86, 0.82, 0.74), true)
	body.custom_minimum_size = Vector2(328, 0)
	col.add_child(body)
	col.add_child(_detail_label("tap anywhere to close", 11, Color(0.6, 0.56, 0.5)))


func _open_settings() -> void:
	_close_overlay()
	_detail = ColorRect.new()
	_detail.color = Color(0.04, 0.03, 0.02, 0.72)
	_detail.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_detail.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay_root().add_child(_detail)
	_detail.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and (e as InputEventMouseButton).pressed:
			_close_overlay())

	var centre := CenterContainer.new()
	centre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_detail.add_child(centre)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(320, 0)
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.13, 0.105, 0.08, 0.99)
	st.set_border_width_all(2)
	st.border_color = Color(0.62, 0.5, 0.3)
	st.set_corner_radius_all(6)
	for side in ["left", "right", "top", "bottom"]:
		st.set("content_margin_" + side, 18.0)
	panel.add_theme_stylebox_override("panel", st)
	centre.add_child(panel)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	panel.add_child(col)
	col.add_child(_detail_label("Settings", 20, Color(1, 0.94, 0.8)))
	col.add_child(_detail_rule())

	var music := Button.new()
	music.custom_minimum_size = Vector2(0, 42)
	music.text = "Music:  %s" % ("On" if Progress.music_enabled() else "Off")
	music.pressed.connect(func() -> void:
		Progress.set_music_enabled(not Progress.music_enabled())
		Music.refresh()   # audible on the tap, not at the next scene change
		music.text = "Music:  %s" % ("On" if Progress.music_enabled() else "Off"))
	col.add_child(music)

	var tips := Button.new()
	tips.custom_minimum_size = Vector2(0, 42)
	tips.text = "Tips:  %s" % ("On" if Progress.hints_enabled() else "Off")
	tips.pressed.connect(func() -> void:
		Progress.set_hints_enabled(not Progress.hints_enabled())
		tips.text = "Tips:  %s" % ("On" if Progress.hints_enabled() else "Off")
		if not Progress.hints_enabled():
			_coach_id = ""
			_coach.visible = false)
	col.add_child(tips)

	# The camera has four gestures and, until now, nothing anywhere said so. A
	# control nobody is told about is a control nobody has, which is indistinguishable
	# from one that does not work.
	var timing := Button.new()
	timing.custom_minimum_size = Vector2(0, 34)
	timing.focus_mode = Control.FOCUS_NONE
	timing.text = "Timing:  %s" % ("Hit circle" if Progress.timing_style() == Progress.TIMING_CIRCLE
		else "Sweep bar")
	timing.tooltip_text = "Where a timed card asks you to hit: an osu-style circle out on the beast, or the bar under the card."
	timing.pressed.connect(func() -> void:
		var next := Progress.TIMING_BAR if Progress.timing_style() == Progress.TIMING_CIRCLE 			else Progress.TIMING_CIRCLE
		Progress.set_timing_style(next)
		timing.text = "Timing:  %s" % ("Hit circle" if next == Progress.TIMING_CIRCLE else "Sweep bar"))
	col.add_child(timing)

	col.add_child(_detail_rule())
	col.add_child(_detail_label("Camera", 14, Color(1, 0.86, 0.5)))
	var cam_help := _detail_label(
		"W A S D  move the camera.  E / Q raise and lower it.
"
		+ "Drag to look around.  Right-drag to slide.  Wheel to zoom.
"
		+ "Picking a hunter puts the camera back on them.",
		11, Color(0.72, 0.68, 0.6), true)
	cam_help.custom_minimum_size = Vector2(284, 0)
	col.add_child(cam_help)

	col.add_child(_detail_rule())
	col.add_child(_detail_label("Keys", 14, Color(1, 0.86, 0.5)))
	var hint := _detail_label(
		"Tap a key, then press the one you want. Escape cancels. Every action still has a button.",
		11, Color(0.72, 0.68, 0.6), true)
	hint.custom_minimum_size = Vector2(284, 0)  # this panel is 320 wide, not the inspector's 430
	col.add_child(hint)

	# Nick, live, 22:25 EDT: "The camera should be locked to 3rd person on
	# the character. I still cannot find the toggle." Player is the default
	# with nothing set (Progress.dev_camera_enabled), in every build debug
	# included — drag/pan/zoom/WASD all go dead, per free_camera_allowed
	# above, until this button is flipped to Dev.
	var cam_mode := Button.new()
	cam_mode.custom_minimum_size = Vector2(0, 34)
	cam_mode.focus_mode = Control.FOCUS_NONE
	cam_mode.text = "Camera:  %s" % ("Dev" if Progress.dev_camera_enabled() else "Player")
	cam_mode.tooltip_text = "Player is exactly what a released build sees: no drag-orbit, pan, wheel or WASD."
	cam_mode.pressed.connect(func() -> void:
		var next := not Progress.dev_camera_enabled()
		Progress.set_dev_camera_enabled(next)
		cam_mode.text = "Camera:  %s" % ("Dev" if next else "Player"))
	col.add_child(cam_mode)

	_rebind_btns = {}
	for k in Progress.KEYBINDS:
		col.add_child(_keybind_row(k as Dictionary))

	var reset := Button.new()
	reset.custom_minimum_size = Vector2(0, 32)
	reset.focus_mode = Control.FOCUS_NONE
	reset.text = "Reset keys"
	reset.add_theme_font_size_override("font_size", 12)
	reset.add_theme_color_override("font_color", Color(0.72, 0.68, 0.6))
	reset.pressed.connect(func() -> void:
		_rebinding = ""
		Progress.reset_keybinds()
		for id: String in _rebind_btns:
			(_rebind_btns[id] as Button).text = _key_name(Progress.keybind(id)))
	col.add_child(reset)

	col.add_child(_detail_rule())
	var quit := Button.new()
	quit.custom_minimum_size = Vector2(0, 42)
	quit.text = "Abandon the hunt"
	quit.add_theme_color_override("font_color", Color(0.95, 0.55, 0.45))
	quit.pressed.connect(_confirm_quit)
	col.add_child(quit)

	var back := Button.new()
	back.custom_minimum_size = Vector2(0, 38)
	back.text = "Back"
	back.flat = true
	back.pressed.connect(_close_overlay)
	col.add_child(back)


func _close_overlay() -> void:
	if _detail != null and is_instance_valid(_detail):
		_detail.queue_free()
	_detail = null
	# Closing mid-rebind must not leave the capture armed — it would swallow the
	# next key press and bind it to whatever row happened to be listening.
	_rebinding = ""
	_rebind_btns = {}


## Overlays must live in their OWN CanvasLayer, above the HUD's.
##
## Parenting them to this Node3D put them on the root canvas (layer 0) while the
## Hud CanvasLayer sits above it — so the settings panel rendered behind the hand
## and its Back button was unclickable under a card.
func _overlay_root() -> CanvasLayer:
	var found := get_node_or_null("OverlayLayer")
	if found is CanvasLayer:
		return found
	var layer := CanvasLayer.new()
	layer.name = "OverlayLayer"
	layer.layer = 20
	add_child(layer)
	return layer


## Asks first: a run is long, and a mis-tap that binned it silently would be worse
## than having no way out at all.
func _confirm_quit() -> void:
	var d := ConfirmationDialog.new()
	d.title = "Leave the hunt?"
	d.dialog_text = "This run ends here. Progress in it is lost."
	d.ok_button_text = "Leave"
	d.cancel_button_text = "Keep hunting"
	add_child(d)
	d.confirmed.connect(func() -> void:
		get_tree().change_scene_to_file("res://views/menu.tscn"))
	d.canceled.connect(d.queue_free)
	d.popup_centered()


## The full rules for one card, on demand — the home that lets the card FACE stop
## being a rulebook.
##
## Shows what it does right now (live, from Combat.preview), the authored text, and
## every keyword it touches with the mechanic explained. Before this, each card
## re-taught its own mechanics on the face forever, which is why card text kept
## growing. See design/notes/feel-and-readability.md.
func _show_card_detail(data: Dictionary) -> void:
	if _detail != null and is_instance_valid(_detail):
		_detail.queue_free()

	_detail = ColorRect.new()
	_detail.color = Color(0.04, 0.03, 0.02, 0.72)
	_detail.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_detail.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay_root().add_child(_detail)
	# Tap anywhere to dismiss — one gesture, no close button to aim at on a phone.
	_detail.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and (e as InputEventMouseButton).pressed:
			if _detail != null and is_instance_valid(_detail):
				_detail.queue_free()
				_detail = null)

	# A CenterContainer, not a CENTER anchor preset: the panel's height depends on how
	# many keywords the card touches, and an anchored panel grows off the bottom of
	# the screen instead of staying centred.
	var centre := CenterContainer.new()
	centre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_detail.add_child(centre)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(430, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.13, 0.105, 0.08, 0.99)
	st.set_border_width_all(2)
	st.border_color = Color(0.62, 0.5, 0.3)
	st.set_corner_radius_all(6)
	for side in ["left", "right", "top", "bottom"]:
		st.set("content_margin_" + side, 18.0)
	panel.add_theme_stylebox_override("panel", st)
	centre.add_child(panel)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(col)

	col.add_child(_detail_label("%s   ✦%d" % [String(data.get("name", "")),
		int(data.get("cost", 0))], 21, Color(1, 0.94, 0.8)))

	var rarity := String(data.get("rarity", ""))
	if rarity != "":
		var rc := Color(0.72, 0.68, 0.6)
		if rarity == "uncommon":
			rc = Color(0.55, 0.78, 0.92)
		elif rarity == "rare":
			rc = Color(1, 0.84, 0.42)
		col.add_child(_detail_label(rarity.to_upper(), 11, rc))

	col.add_child(_detail_rule())
	# What it does right now — the same one sentence the card face shows, from the
	# same formatter, so the two can never disagree.
	var live := RichTextLabel.new()
	live.bbcode_enabled = true
	live.text = CardView.face_text(data, true)  # same colouring as the card face
	live.fit_content = true
	live.scroll_active = false
	live.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	live.mouse_filter = Control.MOUSE_FILTER_IGNORE
	live.custom_minimum_size = Vector2(394, 0)
	live.add_theme_font_size_override("normal_font_size", 15)
	live.add_theme_color_override("default_color", Color(0.94, 0.9, 0.82))
	col.add_child(live)

	# The authored line explains the card's SHAPE ("3 more damage per Rhythm") —
	# the part a single live number can't convey. It belongs here, where there is
	# room, not crammed onto the face beside the numbers it produces. shape_text
	# drops the clauses the live line above already stated.
	var authored := CardView.shape_text(data)
	if authored != "":
		col.add_child(_detail_label(authored, 12, Color(0.76, 0.72, 0.64), true))

	var kws: Array = data.get("keywords", [])
	if not kws.is_empty():
		col.add_child(_detail_rule())
		for k in kws:
			var kd: Dictionary = k
			# Underlined here too. A keyword wears the same face wherever it
			# appears, or the underline stops meaning "this is a keyword".
			col.add_child(_underlined(String(kd.get("name", "")), 14, Color(1, 0.86, 0.5)))
			col.add_child(_detail_label(String(kd.get("text", "")), 12,
				Color(0.8, 0.76, 0.68), true))

	col.add_child(_detail_rule())
	col.add_child(_detail_label("tap anywhere to close", 11, Color(0.6, 0.56, 0.5)))


## A keyword heading. A plain Label cannot underline, so the one place in the UI
## that needs the mark takes a RichTextLabel to get it.
func _underlined(txt: String, size: int, tint: Color) -> Control:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.text = "[u]%s[/u]" % txt
	r.fit_content = true
	r.scroll_active = false
	r.autowrap_mode = TextServer.AUTOWRAP_OFF
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.add_theme_font_size_override("normal_font_size", size)
	r.add_theme_color_override("default_color", tint)
	return r


func _detail_label(txt: String, size: int, tint: Color, wrap: bool = false) -> Label:
	var l := Label.new()
	l.text = txt
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", tint)
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(394, 0)
	return l


func _detail_rule() -> Control:
	var r := ColorRect.new()
	r.color = Color(0.4, 0.33, 0.22, 0.7)
	r.custom_minimum_size = Vector2(0, 1)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


## A damage number at the point of impact.
##
## Until now the only place a hit's SIZE appeared was a line of text in the log,
## four lines down in the corner — so the loop was: play a card, see a flash, then
## READ to find out what happened. See design/notes/feel-and-readability.md.
##
## Sized against the beast's own height so it stays legible whether you're fighting
## a pup or a Titan (the camera pulls back with the beast, so a fixed size shrinks).
## backlog #86 duty 2: a weak-point hit and the hunter's own hit on the same
## swing spawn two popups within a frame of each other, and the fixed
## world-space gap the screenshot harness nudges them apart by
## (`tools/screenshot.gd`'s 1.6/1.2-unit offset) does not scale — the glyph
## grows with `reach` two lines below, but a fixed gap next to a Titan-scaled
## glyph shrinks to nothing relative to the text, and the two numbers render
## as one unreadable blur. Pure so it can be proven headless: the minimum
## separation it enforces has to grow with `reach` the same way the glyph does.
static func popup_offset(new_at: Vector3, prev_at: Vector3, reach: float) -> Vector3:
	var min_sep: float = reach * 0.5
	var delta: Vector3 = new_at - prev_at
	delta.y = 0.0
	if delta.length() >= min_sep:
		return new_at
	var dir: Vector3 = Vector3(1.0, 0.0, 0.0) if delta.length() < 0.0001 else delta.normalized()
	return prev_at + dir * min_sep + Vector3(0.0, new_at.y - prev_at.y, 0.0)


## How far a popup is allowed to travel -- its rise, and (via popup_offset above)
## how far it has to scoot to clear a sibling popup -- before it strays off
## whatever it landed on. `beast_reach` (the Titan's own height) is right for a
## hit ON the beast: the glyph and its float both have to read against a body
## that can be 20+ units tall. A hunter is HUNTER_HEIGHT (0.7) tall regardless
## of the beast, so reusing beast_reach for a hunter hit sent the number
## rocketing several beast-heights into the air (the rise alone) or, when two
## hunters were hit the same frame, flung apart by half a Titan's width
## (popup_offset's min_sep) -- both landed the popup off the top of the screen
## or off to the side, the camera correctly staying on the (tiny) hunter the
## whole time. Pure so it is provable without a beast, a hunter, or a frame.
static func popup_move_reach(beast_reach: float, on_hunter: bool) -> float:
	return HUNTER_HEIGHT * 3.0 if on_hunter else beast_reach


## What fraction of a popup's full world-space rise to actually use, so the
## risen number never lands above `pad` px from the top of frame.
##
## `popup_move_reach` fixed the rise being scaled off the wrong target (a
## Titan's height on a hunter hit); this is a second, independent way the
## SAME rise can still go off-screen even at the right scale, because the
## rise is a fixed WORLD distance while how many pixels that covers depends
## on how close the camera is. A boss hit's rise reads fine from this fight's
## normal, wider shots -- the bug is the tight, near-vertical close-up the
## climb ends on at the sigil, where the frame is already mostly jackal head
## and the same rise pokes a few px past the top edge (2026-09-23,
## boss-damage-popup-offscreen-at-sigil: 676,-5 on a 720-tall frame -- 5px
## over, reproduced 3/3 runs at the same step and the same spot).
##
## `screen_y_at`/`screen_y_full` are the ALREADY-PROJECTED screen Y of the
## popup's start and of its full, unscaled rise destination -- pure so it is
## provable with no camera or frame at all. 1.0 (no change) whenever the full
## rise already clears `pad`; 0.0 only if the START itself is already past
## `pad` -- nothing a rise can fix without moving where the hit is drawn.
static func popup_rise_scale(screen_y_at: float, screen_y_full: float, pad: float) -> float:
	if screen_y_full >= pad:
		return 1.0
	if screen_y_at <= pad:
		return 0.0
	return clampf((screen_y_at - pad) / (screen_y_at - screen_y_full), 0.0, 1.0)


func _damage_popup(amount: int, at: Vector3, weak_point: bool, on_hunter: bool = false) -> void:
	if amount <= 0:
		return
	var reach: float = maxf(_beast_box.size.y, 2.0)
	var move_reach: float = popup_move_reach(reach, on_hunter)
	var placed_at := at
	if _last_popup_guard > 0.0:
		placed_at = popup_offset(at, _last_popup_at, move_reach)
	_last_popup_at = placed_at
	_last_popup_guard = POPUP_OVERLAP_WINDOW
	var lbl := Label3D.new()
	lbl.text = str(amount)
	lbl.font_size = 128
	lbl.outline_size = 30
	lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lbl.no_depth_test = true          # never lost inside the beast's mesh
	lbl.fixed_size = false
	lbl.pixel_size = (0.0010 if not weak_point else 0.0014) * reach
	if on_hunter:
		lbl.pixel_size = 0.0009 * reach
		lbl.modulate = Color(1.0, 0.45, 0.38)      # your blood, not the beast's
	elif weak_point:
		lbl.modulate = Color(1.0, 0.86, 0.36)      # the sigil hit — the big one
	else:
		lbl.modulate = Color(0.95, 0.93, 0.88)
	lbl.outline_modulate = Color(0.08, 0.05, 0.04, 0.95)
	lbl.position = placed_at
	_rig.add_child(lbl)

	var rise := move_reach * 0.22
	if _cam != null:
		var screen_at: float = _cam.unproject_position(placed_at).y
		var screen_full: float = _cam.unproject_position(placed_at + Vector3(0.0, rise, 0.0)).y
		rise *= popup_rise_scale(screen_at, screen_full, POPUP_TOP_PAD)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(lbl, "position", placed_at + Vector3(0.0, rise, 0.0), 0.85) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.45).set_delay(0.4)
	tw.chain().tween_callback(lbl.queue_free)


static func _find_anim(n: Node) -> AnimationPlayer:
	if n is AnimationPlayer:
		return n
	for c in n.get_children():
		var hit := _find_anim(c)
		if hit != null:
			return hit
	return null


## Play one of the beast's own animations, then settle back into its idle.
## A no-op for the unrigged (Python-built) beasts.
func _beast_play(anim: String) -> void:
	if _beast_anim == null or not _beast_anim.has_animation(anim):
		return
	_beast_anim.play(anim, 0.08)
	if _beast_anim.has_animation("idle"):
		_beast_anim.queue("idle")


## _beast_play's own twin for a hunter: play one of THAT hunter's animations,
## then settle back into its idle. A no-op for a hunter with no AnimationPlayer
## at all (every hunter today, until HUNTER_AI_ART names one) or an out-of-
## range slot, same shape as the beast's is_instance_valid guards elsewhere in
## this file.
func _hunter_play(slot: int, anim: String) -> void:
	if slot < 0 or slot >= _hunters.size():
		return
	var player := (_hunters[slot] as Dictionary).get("anim") as AnimationPlayer
	if player == null or not player.has_animation(anim):
		return
	player.play(anim, 0.08)
	if player.has_animation("idle"):
		player.queue("idle")


## A hit on the beast: recoil, a flash of light, a kick of camera shake — much
## bigger when it lands on the weak point.
func _strike(weak_point: bool) -> void:
	_beast_play("hit")
	Sfx.play("strike_weakpoint" if weak_point else "attack")
	_beast_punch = 1.0 if weak_point else 0.45
	_shake = maxf(_shake, 0.85 if weak_point else 0.3)
	_flash.position = _sigil.position if weak_point else _beast_box.get_center()
	_flash.light_energy = 7.0 if weak_point else 2.5
	if weak_point:
		_dust.position = _sigil.position
		_dust.restart()


## The beast bucks: a heavy jolt and dust off its hide.
func _beast_shake() -> void:
	Sfx.play("shake")
	_shake = maxf(_shake, 1.0)
	_beast_punch = 0.6
	_dust.position = _beast_box.get_center()
	_dust.restart()


# --- hand -----------------------------------------------------------------

## Fan the hand: an arc of overlapping cards, tucked low, rising on hover.
##
## Nick sent a Slay the Spire 2 hand and said: "the cards are out of the way
## until you hover it." That is the whole reason to do this. A flat row of five
## cards is a wall across the bottom of the screen and the fight is happening
## behind it; an arc that overlaps and sits low gives the beast its room back,
## and lifting one on hover is what makes the hidden part readable on demand.
##
## The Hand node is a plain Control rather than an HBoxContainer because a
## container re-sorts its children every layout pass and would overwrite every
## position this sets. Rotation would have survived; position would not.
## 0.84, not 0.72. At 0.72 the next card covered nearly a third of the one
## before it, including the right end of its name plate - so half the hand
## had its title hidden. The overlap has to leave the NAME readable, which is
## the only thing you scan a fanned hand for.
const FAN_OVERLAP := 0.84     # of a card's width - how far the next one sits along
const FAN_TILT := 0.085       # radians per card away from centre
const FAN_DROP := 7.0         # px each card sinks per step from centre, making the arc
const FAN_TUCK := 26.0        # px the whole hand sits below its band, out of the way
## Enough to clear the screen edge. The fan deliberately lets the bottom of a
## card fall off the bottom of the screen - that is what "out of the way"
## means and the reference does exactly the same - so a hover has to lift far
## enough to bring the rules text back into view, not just nudge it.
const FAN_RISE := 96.0        # px a hovered card lifts, clear of the deep tuck
## How much a hovered card GROWS.
##
## Nick, on the Slay the Spire hand: "you cannot even see the information of the
## card until you highlight it... somehow their cards still feel larger." Both
## halves are the same mechanism. In the reference a card in hand shows its name
## and its art and nothing else; hovering blows it up to about a third again its
## size and THAT is where the rules become readable. Their cards feel larger
## because the one you are looking at is.
const FAN_HOVER_SCALE := 1.34

## Pure form of _layout_hand's squeeze: how far apart two neighbouring cards
## sit. Shrinks below the fan's natural overlap only when drawing it at that
## spacing would run past `room` — never on an unmeasured room (0 or less,
## the Control's first frame before a size is ever assigned), which would
## squeeze every hand to the floor before the real width is known. #86 duty 3.
static func hand_fan_step(n: int, w: float, room: float, base_step: float) -> float:
	if room > 1.0 and base_step * float(n - 1) + w > room:
		return maxf((room - w) / maxf(float(n - 1), 1.0), w * 0.30)
	return base_step


## Pure form of a resting card's X in _layout_hand — centred on `room`, the
## ScrollContainer's own fixed width, never on the hand's content width.
## Nick, 2026-09-08: centring on content instead made every layout that
## widened the content walk the fan further right on the next call, ending a
## turn with the hand pinned in the bottom-right corner over the End Turn
## button. #86 duty 3.
static func hand_card_x(i: int, n: int, w: float, step: float, room: float) -> float:
	var mid := (float(n) - 1.0) * 0.5
	var off := float(i) - mid
	return room * 0.5 - w * 0.5 + off * step


## The cards that take a slot in the fan: children not already on their way
## out. Static so the rule is provable without a scene (see _render_hand).
static func live_hand_cards(row: Node) -> Array:
	return row.get_children().filter(
		func(c: Node) -> bool: return not c.is_queued_for_deletion())


func _layout_hand() -> void:
	if _hand_row == null:
		return
	# Only live cards. Anything already on its way out must not take a slot in
	# the fan (see _render_hand).
	var cards: Array = live_hand_cards(_hand_row)
	var n := cards.size()
	if n == 0:
		return
	var w: float = maxf((cards[0] as Control).custom_minimum_size.x, 60.0)
	var step := w * FAN_OVERLAP
	# Squeeze further if the hand is wider than the band it has to live in, so a
	# big hand overlaps more rather than running off the screen.
	#
	# ROOM IS THE VIEWPORT, NOT THE CONTENT. %Hand is a plain Control inside a
	# ScrollContainer, and cards are placed by absolute position — which does not
	# feed a Control's minimum size, but the ScrollContainer still sizes its
	# content child around what it holds. Centring on `_hand_row.size.x` centred
	# the fan on the CONTENT, so every layout that widened the content moved the
	# centre right, which placed the next fan further right again. Nick, 2026-09-08,
	# reproduced it by booting a run and ending the first turn: the hand ends up
	# in the bottom-right corner over the End Turn and Switch buttons.
	#
	# The scroll viewport's width is fixed by the HUD, so it cannot run away.
	var scroller := _hand_row.get_parent() as Control
	var room: float = scroller.size.x if scroller != null else _hand_row.size.x
	var mid := (float(n) - 1.0) * 0.5
	# The outer cards are TILTED about a pivot well below them, which swings
	# their top corners outward past where an upright card would end. Squeeze
	# for that too, or a six-card hand leans over End Turn (the playtester,
	# 2026-09-22, after Take Aim drew a sixth card).
	var h: float = (cards[0] as Control).custom_minimum_size.y
	var overhang: float = h * 1.35 * sin(mid * FAN_TILT)
	step = hand_fan_step(n, w, maxf(room - 2.0 * overhang, w), step)
	# Desktop tucks DEEP - at rest you see the name and the art and the rules
	# are below the screen edge, which is precisely the Slay the Spire hand:
	# their resting cards show the top half and nothing else, and that is why
	# the hand reads as a row of paintings. A handheld keeps the shallow tuck:
	# no hover means whatever is hidden at rest is hidden forever.
	var tuck := FAN_TUCK if Screen.is_handheld() else FAN_TUCK + 52.0
	for i in range(n):
		var c := cards[i] as Control
		if c == null:
			continue
		var off := float(i) - mid
		c.size = c.custom_minimum_size
		c.pivot_offset = Vector2(w * 0.5, c.custom_minimum_size.y * 1.35)
		var raised := card_is_raised(c, _hand_hover, _timing_card)
		var lift: float = FAN_RISE if raised else 0.0
		var rest := Vector2(hand_card_x(i, n, w, step, room), tuck + absf(off) * FAN_DROP)
		c.position = rest - Vector2(0.0, lift)
		# A raised card keeps its resting spot as hover area (CardView.hover_hold):
		# the resting pose's global transform, tilt and all.
		if c is CardView:
			var pose := Transform2D(off * FAN_TILT, rest + c.pivot_offset) * Transform2D(0.0, -c.pivot_offset)
			(c as CardView).hover_hold = (_hand_row.get_global_transform() * pose) if raised else null
		# A hovered card straightens up as it rises, so the face you are reading
		# is square to you rather than tilted.
		c.rotation = 0.0 if raised else off * FAN_TILT
		# Grow from the BOTTOM CENTRE, so a lifted card rises out of the fan
		# instead of swelling in all directions and shoving its neighbours.
		c.scale = (Vector2.ONE * FAN_HOVER_SCALE) if raised else Vector2.ONE
		# The panel stays on the card always; the TUCK is what hides it at
		# rest, exactly as in the reference. Toggling visibility instead made a
		# resting card read as borderless full art (Nick's screenshots).
		# and comes to the front, or its neighbours overlap the thing you lifted.
		c.z_index = 10 if raised else i


## Whether a hand rebuild should run at all this refresh. A `state_updated`
## snapshot reaches every peer on EVERY player's action (GameHost._broadcast_state
## sends to all `_peers` on every play_card/end_turn/use_potion), not only the
## acting player's own client — so a teammate ending their turn used to reach
## this client too, mid-swing, while THIS player's own card was running the
## sweep-bar timing minigame. `_render_hand` unconditionally `queue_free()`'d
## every CardView and rebuilt fresh ones from the snapshot; Godot frees a freed
## node's _process along with it, so the sweep just silently stopped -- no
## timing_resolved, no command ever sent, the replacement card came back
## resting as if nothing had been tapped, and the player had no idea why their
## tap did nothing. The timing minigame's state (_timing/_t/_hits_done) lives
## only on that one CardView node, nowhere in the snapshot, so a blanket
## resync cannot tell "the hand actually changed" from "someone else acted"
## without asking first. Pulled out static, same as render_hand_status/
## card_is_raised above, so the gate is provable without a scene tree.
static func should_rebuild_hand(timing_card_active: bool) -> bool:
	return not timing_card_active


func _render_hand() -> void:
	if not should_rebuild_hand(_timing_card != null and is_instance_valid(_timing_card)
			and _timing_card.is_timing()):
		return
	# Detach, THEN free. queue_free() alone leaves the old cards as children
	# until the end of the frame, so the _layout_hand that follows this rebuild
	# counted old + new: ten cards for a hand of five, and laid the real five
	# out as positions 5..9 — the right half of a ten-card fan, tilted as the
	# outer cards of one. That is the hand Nick kept seeing pushed right over
	# End Turn after a fall, a hit, or any mid-turn refresh (2026-09-22,
	# measured by screenshot.gd HANDGEO: centre +215px, z 5..9).
	for c in _hand_row.get_children():
		# Unhook first. Every card's hover/tap handlers are lambdas that capture
		# the card; removing a card that is under the mouse (a pick during Burn
		# Coal or Meld rebuilds the hand from inside the tap) queues a
		# mouse_exited that lands after the card is freed — "Lambda capture at
		# index 0 was freed", caught by the playtester 2026-09-22.
		for sig in ["mouse_entered", "mouse_exited", "tapped", "gui_input"]:
			for con in c.get_signal_connection_list(sig):
				c.disconnect(sig, con["callable"])
		if _hand_hover == c:
			_hand_hover = null
		_hand_row.remove_child(c)
		c.queue_free()
	var priv := _my_private()
	var selecting := not _selecting.is_empty()
	for card in priv.get("hand", []):
		var cv := CardView.new()
		_hand_row.add_child(cv)
		var idx := int(card["index"])
		# while picking, EVERY card is tappable — the pick is the point — except
		# the ones already spoken for
		var playable: bool = bool(card["playable"])
		if selecting:
			playable = idx != int(_selecting.get("sac", -1))
		# Portrait form along the bottom (Nick, 2026-08-15). The left rail was
		# chosen in Aug to keep the 3D scene clear; with the camera pulled back and
		# the beasts scaled up, the bottom strip is affordable again and the cards
		# read far better at portrait size.
		# The border is the hunter's, so the card has to know whose hand it is
		# in. Card data is per-CARD and carries no owner; the hand does.
		card["character"] = _my_character()
		cv.setup(card, playable, false)
		var c_card: Dictionary = card
		cv.tapped.connect(func() -> void: _on_card_tapped(c_card, cv))
		# Press starts a candidate drag; the view's _input carries it from there.
		cv.gui_input.connect(func(e: InputEvent) -> void: _card_pressed(e, cv, c_card))
		# Hover lifts the card out of the fan. Bound here rather than inside
		# CardView because the fan is a property of the HAND, not of a card:
		# only the row knows which of its children is on top.
		cv.mouse_entered.connect(func() -> void:
			_hand_hover = cv
			_layout_hand())
		cv.mouse_exited.connect(func() -> void:
			if _hand_hover == cv:
				_hand_hover = null
				_layout_hand())
		cv.inspect_requested.connect(_show_card_detail)
		cv.keyword_requested.connect(_show_keyword)
		cv.timing_resolved.connect(func(quality: int) -> void:
			# The clip is still binary (nailed it / missed it) — a "good" vs.
			# "perfect" distinction is the display half (backlog #34), not this one.
			Sfx.play("nail" if quality > Combat.TIMING_MISS else "slip")
			_client.play_card(idx, quality > Combat.TIMING_MISS, _cmd_slot(), -1, -1, quality))
	var players: Array = _client.shared.get("players", [])
	var me: Dictionary = players[_me()] if _me() < players.size() else {}
	# selecting and non-selecting used to be two branches, one of which
	# `return`ed before reaching the hover-reset/layout tail below — so every
	# card built while a pick (exhaust/cheapen/meld) was in progress sat at
	# Control's default (0,0), stacked in the hand's corner, until a mouse
	# hover incidentally repaired it. Handheld has no hover, so the stack was
	# permanent there. Pulled the outcome into a pure function so "layout
	# always runs, regardless of selecting" is something a test can pin down.
	var outcome := render_hand_status(selecting)
	_status.text = _selection_prompt() if selecting else ""
	_status.visible = bool(outcome["status_visible"])   # a transient instruction, not an identity
	_render_energy(me)
	_show_switch_target(players)
	_end_btn.disabled = bool(priv.get("ended", false))
	if bool(outcome["hover_reset"]):
		_hand_hover = null
		_timing_card = null
	if bool(outcome["layout_needed"]):
		# Positions are set by hand, so nothing lays the fan out unless we do.
		# Deferred: the cards have no size until the frame after they are added,
		# and an arc built on zero-width cards stacks them all at the centre.
		_layout_hand.call_deferred()


static func render_hand_status(selecting: bool) -> Dictionary:
	return {
		"status_visible": selecting,
		"layout_needed": true,
		"hover_reset": true,
	}

## A card is "raised" — lifted clear of the fan's deep tuck, squared to the
## screen instead of tilted — if the mouse is hovering it OR it is the card
## actively running the sweep-bar timing minigame. Before `_timing_card`
## existed only hover raised a card, and the timing strip is anchored near the
## card's own bottom edge (card_view.gd, anchor 0.86) — inside that tuck. A
## handheld tap never fires mouse_entered (CLAUDE.md §5: no hover-only info),
## so starting a timed card's sweep on touch left the strip clipped off-screen
## for the whole minigame. bugs.md Finding 3 (2026-09-08). #86 duty 2 (two
## copies of one truth: "the card in focus" had two real causes, one checked).
static func card_is_raised(card: Variant, hover: Variant, timing: Variant) -> bool:
	return card == hover or card == timing

## Whether `_switch_to` must refuse a hunter swap because a timing window
## (sweep-bar CardView, or the HitCircle whose `circle_index` is the hand
## index it will eventually play) is still open. See the call site in
## `_switch_to` for why: the window's hand index and `_cmd_slot()`'s live
## active-slot read would otherwise disagree the moment a switch lands
## between them. #86 duty 2.
static func switch_blocked_by_timing(card_timing: bool, circle_index: int) -> bool:
	return card_timing or circle_index >= 0

## The timing-window bonus a played card actually gets, as a fraction (10% ==
## 0.10): the team-wide relic mod (`mods.timing_zone`, a percent) plus, if
## THIS card carries the "Wide" enchant (data/enchants.json: effect
## "timing_zone", "A much wider timing window for this card"), its own value
## on top. Before this existed, `_on_card_tapped` only ever read the relic
## mod — enchanting a card Wide attached fine (Card.enchanted_copy is
## generic, backlog #12) and `_test_enchanted_copy_attaches_to_any_card`
## confirmed the DATA was right, but nothing downstream ever read
## `enchant_effect`/`enchant_value` off the card: game_host.gd's hand dict
## never sent them (only a bare "enchant" keyword for the inspect tooltip),
## so a Wide-enchanted card graded PERFECT/GOOD/MISS on exactly the same
## window as an unenchanted one. The enchant was real, attached, and did
## nothing (backlog #86 duty 2).
static func timing_zone_bonus(team_mod_pct: int, card_enchant_effect: String, card_enchant_value_pct: int) -> float:
	var pct := team_mod_pct
	if card_enchant_effect == "timing_zone":
		pct += card_enchant_value_pct
	return float(pct) / 100.0


func _on_card_tapped(card: Dictionary, cv: CardView) -> void:
	_dismiss_coach()   # you're playing; you don't need to be told to play
	var index := int(card["index"])
	if not _selecting.is_empty():  # this tap is a pick for the active card
		_pick_for_selection(index)
		return
	if bool(card.get("timed", false)):
		# a relic can widen the window for the whole team, and this one card can
		# carry its own "Wide" enchant on top — combine both into the one bonus
		# HitCircle/CardView actually read.
		var bonus := timing_zone_bonus(int(_client.shared.get("mods", {}).get("timing_zone", 0)),
			String(card.get("enchant_effect", "")), int(card.get("enchant_value", 0)))
		var hits := int(card.get("timed_hits", 1))
		if Progress.timing_style() == Progress.TIMING_CIRCLE and _circle != null:
			# Same grading, a different face: the circle opens ON the beast at the
			# hold this card is reaching for, so the tensest moment of the turn
			# happens where you are looking instead of in a strip under the cards.
			_circle_index = index
			var anchor := cv.get_global_rect().get_center() - Vector2(0.0, cv.size.y * 0.62)
			_circle.begin(bonus, _cam, _hold_points(card, hits, anchor),
				card_is_slider(card, hits))
			return
		cv.zone_bonus = bonus
		# Raise the card the same way hover would -- a handheld tap never fires
		# mouse_entered, and the sweep strip lives inside the deep tuck a
		# resting card sits in (see card_is_raised).
		_timing_card = cv
		_layout_hand()
		cv.start_timing(hits)
		return
	if bool(card.get("exhaust_pick", false)) or bool(card.get("cheapen_pick", false)) 			or bool(card.get("meld", false)):
		# Nothing else in hand to pick: play it as it stands rather than open
		# a pick that can never be answered.
		if (_my_private().get("hand", []) as Array).size() <= 1:
			Sfx.play("card")
			_client.play_card(index, true, _cmd_slot())
			return
		_start_selection(card)
		return
	Sfx.play("card")
	_client.play_card(index, true, _cmd_slot())


func _selection_prompt() -> String:
	var mode := String(_selecting.get("mode", "exhaust"))
	var step := int(_selecting.get("step", 0))
	var nm := String(_selecting.get("name", "card"))
	var cancel := "   (tap %s again to cancel)" % nm
	match mode:
		"meld":
			return "%s — tap the %s card to meld%s" % [nm, "FIRST" if step == 0 else "SECOND", cancel]
		"exhaust_cheapen":
			if step == 0:
				return "%s — tap a card to SACRIFICE%s" % [nm, cancel]
			return "%s — tap a card to make CHEAPER" % nm
		"cheapen":
			return "%s — tap a card to make CHEAPER%s" % [nm, cancel]
		_:
			return "%s — tap a card to SACRIFICE%s" % [nm, cancel]


## Derives the selection mode/pick-count for a card that needs a hand-card tap
## (exhaust_pick/cheapen_pick/meld), mirroring core/combat.gd's own play_card()
## gates exactly rather than a hand-copied if/elif chain: a sac index is only
## consulted if exhaust_pick or meld is set (combat.gd:864), a target index only
## if cheapen_pick or meld is set (combat.gd:867). No shipped card sets
## cheapen_pick alone today (burn_coal pairs it with exhaust_pick; only meld
## sets meld) -- the old if/elif fell into its cheapen_pick branch for that case
## too, which would have asked for two picks and filed the only one that
## mattered as "sac" instead of "target" (backlog #86 duty 3).
static func selection_mode_for(card: Dictionary) -> Dictionary:
	var meld: bool = bool(card.get("meld", false))
	var needs_sac: bool = meld or bool(card.get("exhaust_pick", false))
	var needs_target: bool = meld or bool(card.get("cheapen_pick", false))
	if meld:
		return {"mode": "meld", "picks": 2}
	if needs_sac and needs_target:
		return {"mode": "exhaust_cheapen", "picks": 2}
	if needs_target:
		return {"mode": "cheapen", "picks": 1}
	return {"mode": "exhaust", "picks": 1}


func _start_selection(card: Dictionary) -> void:
	var sel := selection_mode_for(card)
	_selecting = {"play_index": int(card["index"]), "name": String(card.get("name", "card")),
		"mode": String(sel["mode"]), "picks": int(sel["picks"]), "step": 0, "sac": -1, "target": -1}
	Sfx.play("card")
	_render_hand()


## What one tap does to an in-progress meld/exhaust_pick/cheapen_pick selection.
## Its one hard invariant: the two picks must land on different cards — the
## same rule `core/combat.gd` enforces server-side with `target_index !=
## sac_index` (combat.gd:621). Tapping the already-chosen sac card again is not
## a second pick; the state does not advance and no target is ever recorded.
## A "cheapen"-mode card (selection_mode_for's cheapen_pick-alone case) has
## only one pick and it is the TARGET, not the sac -- every other mode's first
## pick is the sac, so this is the one place that has to ask which is which.
static func next_selection_state(selecting: Dictionary, idx: int) -> Dictionary:
	if idx == int(selecting.get("play_index", -1)):
		return {"action": "cancel"}
	var next: Dictionary = selecting.duplicate()
	if int(selecting.get("step", 0)) == 0:
		if String(selecting.get("mode", "exhaust")) == "cheapen":
			next["target"] = idx
		else:
			next["sac"] = idx
	elif idx == int(selecting.get("sac", -1)):
		return {"action": "ignore"}
	else:
		next["target"] = idx
	next["step"] = int(selecting.get("step", 0)) + 1
	if int(next["step"]) >= int(selecting.get("picks", 1)):
		return {"action": "fire", "play_index": int(selecting.get("play_index", -1)),
			"sac": int(next.get("sac", -1)), "target": int(next.get("target", -1))}
	return {"action": "continue", "selecting": next}


func _pick_for_selection(idx: int) -> void:
	var result := next_selection_state(_selecting, idx)
	match String(result.get("action", "")):
		"cancel":
			_selecting = {}  # tapped the selection card again — cancel
			_render_hand()
		"ignore":
			pass  # the two picks must be different cards
		"fire":
			var play_index := int(result["play_index"])
			var sac := int(result["sac"])
			var target := int(result["target"])
			_selecting = {}
			Sfx.play("card")
			_client.play_card(play_index, true, _cmd_slot(), sac, target)
		"continue":
			_selecting = result["selecting"]
			# Nothing left to pick (Burn Coal with one other card: you burn it and
			# there is no second card to cheapen) — play with what was chosen
			# instead of waiting on a pick that cannot happen.
			var left := 0
			for hc in _my_private().get("hand", []):
				var hi := int((hc as Dictionary)["index"])
				if hi != int(_selecting["play_index"]) and hi != int(_selecting["sac"]):
					left += 1
			if left == 0:
				var fire: Dictionary = _selecting
				_selecting = {}
				Sfx.play("card")
				_client.play_card(int(fire["play_index"]), true, _cmd_slot(), int(fire["sac"]), -1)
				return
			_render_hand()


# --- the party and the run's standing ------------------------------------

## Which move kinds put every hunter's card in the red "aimed at" border,
## regardless of who boss_target_index() names.
##
## "rift" was missing here: Combat._enemy_turn's own "rift" case hits every
## player unconditionally (`for ps3 in players: _boss_hits(ps3, dr)`), the
## exact same shape as "attack_all" right above it, and Combat.incoming_for()
## already knows this — its own match statement prices "rift" for every `pi`
## with no boss_target_index() check, the fix that comment dates to
## 2026-08-16. This sibling list, which decides the red border rather than the
## ⚔ number, never got the same fix: a party card showed the correct nonzero
## incoming damage next to a border that read "safe" for whichever hunter
## wasn't boss_target_index() the moment the pattern rolled around to Rift —
## the single fact its own doc comment calls "the most time-critical... on the
## screen," wrong for the one move a co-op team most needs to see coming.
##
## backlog #86 duty 2 — a THIRD copy of "who does this move hit" drifted the
## other way: swipe_high/swipe_low were lumped in here as if they were
## unconditional sweeps like attack_all/rift, but Combat._enemy_turn's own
## swipe_high/swipe_low cases (and Combat.incoming_for(), which prices the
## ⚔ number on the very same card) only hit whichever hunter's `foothold`
## does or doesn't clear the ground. Any co-op fight where the two hunters
## are at different heights when a swipe is telegraphed — completely
## ordinary climb-together play — put a red "you're about to be hit" border
## on BOTH cards while only one of them actually takes damage, right next to
## an ⚔ number that (correctly) read 0 for the safe hunter. Only attack_all
## and rift genuinely hit every hunter no matter what; swipe_high/swipe_low
## need the same per-hunter foothold check their own damage does.
static func move_hits_every_hunter(move_type: String) -> bool:
	return move_type in ["attack_all", "rift"]


## Whether THIS hunter is the one a foothold-gated swipe actually catches —
## the same condition Combat._enemy_turn()/incoming_for() price the hit with,
## re-read here so the red border and the ⚔ number never disagree again.
static func swipe_catches(move_type: String, foothold: int) -> bool:
	match move_type:
		"swipe_high": return foothold > 0   # only hunters off the ground
		"swipe_low": return foothold <= 0   # only hunters still on the ground
		_: return false


## Move kinds where boss_target_index() genuinely names a hunter this move
## does something TO. "attack"/"leech" deal HP damage to that hunter;
## "frail"/"curse" (backlog #69) don't touch HP but still land squarely on
## them (a Block debuff, a curse card in their discard). Deliberately NOT
## here: "block"/"enrage"/"regen"/"shift_sigil" (Combat._enemy_turn()'s own
## cases for these touch only `boss`, never `players[]`) — see
## hunter_is_aimed_at() below for why that matters.
const SINGLE_TARGET_KINDS: Array[String] = ["attack", "leech", "frail", "curse"]


## backlog #86 duty 2 — a FOURTH copy of "who does this move hit" drifted the
## same wrong way as the swipes above: _render_party's `i == boss_target`
## fired unconditionally for ANY move_type that wasn't already caught by
## move_hits_every_hunter() or swipe_catches(), including "block", "enrage",
## "regen" and "shift_sigil" — four move types whose own Combat._enemy_turn()
## cases only ever touch `boss` (gain_block/strength/hp/weak_point_height),
## never any entry in `players[]`. Whichever hunter happened to satisfy
## boss_target_index() that round got a red "about to be hit" border next to
## an ⚔ number that (correctly, via Combat.incoming_for()'s own match
## statement, which has no case for those four kinds either) read 0 — the
## same contradictory-HUD shape the swipe and rift fixes above both closed,
## on a fourth path nothing had gated yet.
##
## backlog #86 duty 2 (this rotation) — a FIFTH copy, and the one #89 left
## behind: Combat.incoming_for() has added a living add's own "attack" move
## to the ⚔ number at boss_target_index() since #89, but this function, the
## sibling that decides the red border, never gained the matching check —
## it only ever looks at the MAIN boss's move_type, exactly as it did before
## #89. Root Lurker's Root Tendril (the same add #89's own commit message
## names) can attack while the main boss's own move is "block"/"enrage"/
## "regen"/"shift_sigil" (none of which are SINGLE_TARGET_KINDS), which
## produced the identical contradiction the four fixes above all closed: a
## nonzero ⚔ number next to a border that reads "safe". `add_attacking` is
## true when ANY living add's telegraphed move is "attack" — adds have no
## target of their own (_adds_turn(), Combat.incoming_for()'s own add
## branch), they always land on whoever boss_target already names.
static func hunter_is_aimed_at(move_type: String, boss_target: int, i: int, foothold: int,
		add_attacking: bool = false) -> bool:
	return move_hits_every_hunter(move_type) or swipe_catches(move_type, foothold) \
		or (i == boss_target and (move_type in SINGLE_TARGET_KINDS or add_attacking))


## Whether any living add's telegraphed move will actually land — the same
## "attack" gate Combat.incoming_for()'s own add branch uses (adds only ever
## honour "attack" and "block" per _adds_turn()). Reads `adds` in the shape
## game_host.gd's `_build_shared` puts on the wire: each a Dictionary with
## "hp" and "intent" (itself a Dictionary with "type").
static func any_add_attacking(adds: Array) -> bool:
	for add_v in adds:
		var add: Dictionary = add_v
		if int(add.get("hp", 0)) <= 0:
			continue
		if String((add.get("intent", {}) as Dictionary).get("type", "")) == "attack":
			return true
	return false


## Co-op means your ally's state is not optional information: HP, block,
## Energy, how high they've climbed, whether they're hanging, and whether the
## beast is about to hit them. The 3D scene shows WHERE they are; this says how
## they're doing.
func _render_party(s: Dictionary, boss_target: int, move_type: String, add_attacking: bool) -> void:
	for c in _party.get_children():
		c.queue_free()
	var players: Array = s.get("players", [])
	for i in range(players.size()):
		var p: Dictionary = players[i]
		var aimed: bool = hunter_is_aimed_at(move_type, boss_target, i, int(p.get("foothold", 0)),
			add_attacking)
		_party.add_child(_party_card(p, i, aimed))
	var bits: Array = ["Gold %d" % int(s.get("gold", 0))]
	var relics: Array = s.get("relics", [])
	if not relics.is_empty():
		bits.append(", ".join(relics))
	_run_label.text = "  •  ".join(bits)


## Solo only: the Switch button wears the face of the hunter you'd switch TO, so
## the swap is a picture rather than a word. Knowing who you're holding and who
## you'd get should both be glanceable.
func _show_switch_target(players: Array) -> void:
	_switch_btn.visible = _is_solo()
	if not _is_solo():
		return
	var other := 1 - _me()
	if other >= players.size():
		return
	var path := String((players[other] as Dictionary).get("portrait", ""))
	if path != "" and ResourceLoader.exists(path):
		_switch_btn.icon = load(path)
		_switch_btn.expand_icon = true
	# Name the shortcut on the control it accelerates — a keybind nobody is told
	# about is a keybind nobody uses.
	_switch_btn.text = "Switch  ⇥"
	_switch_btn.tooltip_text = "Swap hunter.  Tab, or 1 / 2 to pick one directly."
	_switch_btn.add_theme_color_override("font_color", _slot_color(other))


func _slot_color(slot: int) -> Color:
	return SLOT_TINT[slot % SLOT_TINT.size()]


## Energy, big, beside the hand — Slay the Spire's one un-shrunken HUD number.
##
## This replaced a panel in the top-left that restated the active hunter's entire
## row: portrait, HP, energy, Height, incoming, piles. All of it was already in the
## party panel, so the screen said everything twice (Nick, 2026-08-15: "still have
## some clutter"). The party panel now owns hunter state, and the only thing lifted
## out is the number you consult before every single card.
func _render_energy(p: Dictionary) -> void:
	var out := int(p.get("energy", 0))
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.16, 0.12, 0.07, 0.92) if out > 0 else Color(0.11, 0.1, 0.1, 0.85)
	style.set_border_width_all(3)
	style.border_color = Color(0.82, 0.66, 0.34) if out > 0 else Color(0.34, 0.32, 0.30)
	# A rounded SQUARE, not a disc. It was a disc — "it should read as an orb" —
	# right up until the osu face started drawing dark circles with a gold rim and
	# a big number in them, at which point the most permanent thing on the HUD and
	# the most urgent thing on the screen were speaking the same language (Nick,
	# 2026-08-25: "the number in the corner is confusing a bit. its the same
	# design as the osu numbers"). Two things cannot share one shape, and the one
	# you have to react to in half a second wins it.
	style.set_corner_radius_all(14)
	_energy_orb.add_theme_stylebox_override("panel", style)
	_energy_label.text = str(out)
	_energy_label.add_theme_color_override("font_color",
		Color(1, 0.87, 0.5) if out > 0 else Color(0.55, 0.52, 0.5))

	# Pile counts tucked under the orb. Small on purpose: they matter to the Goblin,
	# whose kit scales off the burn pile, and to nobody else most turns.
	var priv := _my_private()
	_piles.visible = priv.has("draw")
	if priv.has("draw"):
		_piles.text = "draw %d\ndisc %d · burn %d" % [int(priv.get("draw", 0)),
			int(priv.get("discard", 0)), int(priv.get("exhaust", 0))]
		# Clicking the pile counts opens the deck. That is where Slay the Spire
		# puts it and where a hand reaches for it — the number of cards left is
		# the thing that makes you want to look at what they are.
		_piles.mouse_filter = Control.MOUSE_FILTER_STOP
		_piles.tooltip_text = "Look through your deck"
		if not _piles.gui_input.is_connected(_piles_clicked):
			_piles.gui_input.connect(_piles_clicked)




func _piles_clicked(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb != null and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
		open_deck()


## The deck screen. Public because the dev console opens it too.
##
## Returns whether a DeckView is now actually showing — same contract fix as
## location_3d.gd's sibling (backlog #86 duty 2): console.gd's `_cmd_deck()`
## duck-types this method on either view and needs to tell "opened it" apart
## from "nothing to open" rather than trusting a void call always worked.
func open_deck() -> bool:
	if get_node_or_null("DeckView") != null:
		return true                 # already open; do not stack two of them
	var deck: Array = _my_private().get("deck", [])
	if deck.is_empty():
		return false
	DeckView.open(self, deck)
	return true


## A character's face at a fixed size, tinted frame optional. Portraits are baked
## large, so the texture is always told to ignore its own size.
func _portrait_of(p: Dictionary, px: int, ring: Color = Color(0, 0, 0, 0)) -> Control:
	var path := String(p.get("portrait", ""))
	if path == "" or not ResourceLoader.exists(path):
		var dot := ColorRect.new()   # never leave the slot unidentified
		dot.color = ring if ring.a > 0.0 else Color(0.5, 0.45, 0.4)
		dot.custom_minimum_size = Vector2(px, px)
		return dot
	var tex := TextureRect.new()
	tex.texture = load(path)
	tex.custom_minimum_size = Vector2(px, px)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return tex


## The party card's name line: "<name>" for the ally, "<name>  (you)" for the
## viewer's own hunter. Lifted out (backlog #86 duty 3) so the exact "(you)"
## suffix logic can be proven headless, the same way intent_text_for and
## selection_mode_for already were — a string built inline in a Node-returning
## function is otherwise invisible to run_tests.gd until someone clicks it.
static func party_card_name(p: Dictionary, slot: int, me: int) -> String:
	return "%s%s" % [String(p.get("name", "")), "  (you)" if slot == me else ""]


## The party card's stats line — the text half of _party_card(), pulled out
## pure (backlog #86 duty 3) because this exact spot has already shipped a
## silent bug once: "it currently says wrench apart five. I'm not sure what
## that means" (Nick, 2026-08-16) was intent_text_for's bug, but the fix that
## followed it here — "↑2 / 6, never a bare ↑2" — was a raw string edit in this
## same Node-returning function, with nothing in run_tests.gd able to catch a
## regression to the bare form. Six independent pieces (HP, Block, the ally's
## own Energy, Height, incoming damage, and a status tag) assemble into one
## joined line; any one silently dropping or misordering reads as a missing
## number on a screen nobody is failing a test over.
static func party_card_stats(p: Dictionary, slot: int, me: int) -> String:
	var parts: Array = ["HP %d/%d" % [int(p.get("hp", 0)), int(p.get("max_hp", 0))]]
	if int(p.get("block", 0)) > 0:
		parts.append("◈%d" % int(p.get("block", 0)))
	# Energy only for the ALLY — yours is the orb beside your hand, and printing it
	# in both places is exactly the doubling this pass exists to remove.
	if slot != me:
		parts.append("✦%d" % int(p.get("energy", 0)))
	# "↑2 / 6", never a bare "↑2" — a Height with nothing to measure it against
	# tells you where you are and not how far is left (Nick, 2026-08-16).
	#
	# The numerator is `foothold` CLAMPED to `wp`, not the raw stored value —
	# same root as hunter_side_offset() above: foothold keeps climbing past
	# the sigil (core/combat.gd: FOOTHOLD_MAX, not weak_point_height), so a
	# hunter sitting at the sigil could read "↑16 / 5", which is nonsense
	# (backlog request 2026-09-22, frames/fixer/…-hunters-overlap-at-sigil-before.png).
	var wp := int(p.get("weak_point_height", 0))
	var foot := int(p.get("foothold", 0))
	parts.append("↑%d / %d" % [mini(foot, wp), wp] if wp > 0
		else "↑%d" % foot)
	# What the telegraphed move costs THIS hunter, after their Block. The red border
	# already says "aimed at"; this says whether they survive it.
	var inc: Dictionary = p.get("incoming", {})
	var through := int(inc.get("through", 0))
	if int(inc.get("raw", 0)) > 0:
		# ATTACK_GLYPH, not a literal "⚔" — see its own doc comment above
		# intent_text_for: the real crossed-swords glyph is missing from this
		# font and draws as a bare, easy-to-miss "×" on this exact readout.
		parts.append((ATTACK_GLYPH + "%d") % through if through > 0 else "⛨ blocked")
	if bool(p.get("reached", false)):
		parts.append("at the sigil")
	elif not bool(p.get("secure", true)):
		parts.append("hanging!")
	if bool(p.get("ended", false)):
		parts.append("done")
	return "   ".join(parts)


func _party_card(p: Dictionary, slot: int, aimed: bool) -> Control:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.13, 0.1, 0.08, 0.8)
	style.set_border_width_all(2 if slot == _me() else 1)
	# the hunter in the beast's sights is outlined in red — the single most
	# time-critical fact on the screen
	# red when the beast is aiming at them, else their own identity colour so the
	# card, the portrait in the rail and the pip in the scene all agree
	style.border_color = Color(0.85, 0.32, 0.26) if aimed else _slot_color(slot)
	style.set_corner_radius_all(5)
	style.content_margin_left = 8.0
	style.content_margin_right = 10.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	panel.add_theme_stylebox_override("panel", style)
	var outer := HBoxContainer.new()
	outer.add_theme_constant_override("separation", 8)
	panel.add_child(outer)
	outer.add_child(_portrait_of(p, 34))
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 2)
	outer.add_child(box)
	var who := Label.new()
	who.text = party_card_name(p, slot, _me())
	who.add_theme_font_size_override("font_size", 13)
	who.add_theme_color_override("font_color", Color(1, 0.93, 0.78))
	box.add_child(who)
	var bar := ProgressBar.new()
	bar.max_value = maxi(int(p.get("max_hp", 1)), 1)
	bar.value = int(p.get("hp", 0))
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 12)
	box.add_child(bar)
	var stats := Label.new()
	stats.text = party_card_stats(p, slot, _me())
	stats.add_theme_font_size_override("font_size", 12)
	stats.add_theme_color_override("font_color", Color(0.86, 0.82, 0.72))
	box.add_child(stats)
	# Tapping a hunter's card holds that hunter, and the camera locks onto them.
	# The card already shows who they are and what is about to hit them, so it is
	# the thing you are looking at when you decide to swap — asking you to look
	# away to a separate button was the long way round (Nick: "make things more
	# clickable"). Solo only: in multiplayer you cannot hold your ally's hand.
	if _is_solo():
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
		panel.tooltip_text = "Hold this hunter — the camera locks on."
		panel.gui_input.connect(func(e: InputEvent) -> void:
			if not (e is InputEventMouseButton):
				return
			var mb := e as InputEventMouseButton
			if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
				_switch_to(slot))
	return panel


## Contextual onboarding, shared with the 2D client: the rule that matters right
## now announces itself once, then never again. The armoured-hide gate is the
## one that most needs saying — without it, hitting a beast from the ground
## reads as the cards being broken rather than as the climb being the point.
func _update_coach(s: Dictionary) -> void:
	# Gated here rather than inside Coach so Coach stays a pure function of the
	# snapshot — its tests must not depend on whatever this machine's config says.
	if not Progress.hints_enabled():
		_coach_id = ""
		_coach.visible = false
		return
	var hint := Coach.hint_for(s, _my_private(), _me())
	if hint.is_empty():
		_coach_id = ""
		_coach.visible = false
		return
	if String(hint["id"]) == _coach_id:
		return           # already up — don't restart its clock on every snapshot
	_coach_id = String(hint["id"])
	_coach_text.text = String(hint["text"])
	_coach.visible = true
	_coach_left = COACH_SECONDS


## Hints teach once and then get out of the way — they should never be a chore.
## Anything that dismisses one also marks it seen, exactly as the button does:
## running out the clock and pressing "Got it" mean the same thing.
func _dismiss_coach() -> void:
	if _coach_id == "":
		return
	Progress.mark_hint_seen(_coach_id)
	_coach_id = ""
	_coach_left = 0.0
	_coach.visible = false


## What just happened, in words. The 3D scene shows the blow landing but not
## WHY it was small — the armoured-hide flag that explains a chipped hit only
## exists here, which is exactly the confusion the log was added to fix.
func _render_log(s: Dictionary) -> void:
	var entries: Array = s.get("log", [])
	var n := 16 if _log_expanded else 4
	_log_label.text = "
".join(entries.slice(maxi(entries.size() - n, 0)))
	# Collapsed by default: Slay the Spire shows no combat log at all, and a panel
	# reading "— Round 1 —" beside the beast is pure noise. The toggle stays, so the
	# history is one tap away when something surprising happens.
	_log_panel.visible = _log_expanded and not entries.is_empty()
	_log_toggle.text = "Log ▾" if _log_expanded else "Log ▸"

# --- dragging a card out of the hand ---------------------------------------
#
# Nick: "you can highlight a card to have it raised up, but then when you click
# and drag a card, you can drag it anywhere on the screen... if you drag it to
# the left hand on the screen, you're kinda looking from the left hand into this
# window of the card... when you let go of the card it is played unless you slot
# it back into your hand."
#
# So: press and move to pick a card up, release over the fight to play it,
# release back over the hand to put it down. And while it is up, WHERE IT IS
# drives the foil and the 3D window, so carrying a rare across the screen walks
# your eye around the scene inside it.
#
# A press that never moves is still a tap, and a tap still plays the card. That
# is not a nicety: on a phone there is no other way to play one, and making
# release-over-the-hand mean "put it back" would have made a plain tap a no-op.

## How far the pointer must travel before a press becomes a drag rather than a
## tap. Below this the card has not really been picked up.
const DRAG_SLOP := 9.0
## The band along the bottom that counts as "still in your hand". Release inside
## it and the card goes back; release above it and it is played. Generous,
## because dropping a card you did not mean to play is the expensive mistake and
## putting it back costs nothing.
const HAND_BAND := 210.0
## How far a carried card turns at the edges of the screen, in degrees.
##
## Nick: "I would like for the rotation to be a little bit more heavy so you'd
## see a little bit more view of the card. Right now, it's just a small
## rotation, and you don't see much." The card was not turning AT ALL - only its
## picture was shifting, and a picture that moves inside a rectangle that plainly
## still faces you reads as the art being loose. This is the same |cos| squash
## the deck screen uses, which is what makes it read as a card being angled.
const DRAG_TILT_DEG := 34.0
## And a little roll with it. Carrying something in one hand tips it; a card
## that stays perfectly upright while being swung across a table looks pinned.
const DRAG_ROLL := 0.085

var _drag: CardView = null
var _drag_data: Dictionary = {}
var _drag_grab := Vector2.ZERO     # where in the card you took hold of it
var _drag_from := Vector2.ZERO     # where the press landed, for the slop test
var _drag_at := Vector2.ZERO       # the latest pointer position, from the event
var _drag_index := 0               # its place in the fan, to put it back
var _drag_live := false            # past the slop, actually carrying it


## One motion sample's effect on whether a press has become a real drag yet.
## Matches the `<` in `_drag_input` below (so `distance_from_press == slop`
## already counts) — below that, the pointer might still be settling into a
## tap, which is the ONLY way to play a card on a device with no right-click.
static func card_drag_becomes_live(distance_from_press: float, slop: float) -> bool:
	return distance_from_press >= slop


## Whether letting go plays the card, as opposed to putting it back in the
## fan. A release that never went live is a tap — left alone here so the
## card's own Button press plays it, never this path — and a live drag only
## plays when it lands above the HAND_BAND floor along the bottom; released
## inside the band, it goes home instead.
static func drag_release_plays_card(was_live: bool, release_y: float, floor_y: float) -> bool:
	return was_live and release_y < floor_y


## Called from every card's gui_input. Only starts the candidate — the drag
## itself is not live until the pointer has moved DRAG_SLOP.
func _card_pressed(event: InputEvent, cv: CardView, data: Dictionary) -> void:
	var mb := event as InputEventMouseButton
	if mb == null or mb.button_index != MOUSE_BUTTON_LEFT or not mb.pressed:
		return
	if not _selecting.is_empty() or cv.disabled:
		return                       # picking a card for another card, or unplayable
	_drag = cv
	_drag_data = data
	_drag_live = false
	_drag_at = mb.global_position
	_drag_from = mb.global_position
	_drag_grab = cv.get_global_rect().position - mb.global_position
	_drag_index = cv.get_index()


## Motion and release while a card is held. On the VIEW rather than on the card:
## a fast drag outruns the node, and once it does the card stops receiving the
## motion that is supposed to be moving it.
func _drag_input(event: InputEvent) -> bool:
	if _drag == null or not is_instance_valid(_drag):
		return false
	# The EVENT's position, never get_viewport().get_mouse_position(). The
	# cursor is an OS-level thing: it lags a warp, it is wrong when the window
	# is not focused, and a synthetic event carries no cursor at all - which is
	# how the first version of this passed on one drag and silently failed on
	# the next, lifting nothing and reporting success.
	var mm := event as InputEventMouseMotion
	if mm != null:
		_drag_at = mm.global_position
		if not _drag_live:
			if not card_drag_becomes_live(_drag_at.distance_to(_drag_from), DRAG_SLOP):
				return false
			_lift()
		_drag.global_position = _drag_at + _drag_grab
		_aim_dragged()
		return true

	var mb := event as InputEventMouseButton
	if mb != null and mb.button_index == MOUSE_BUTTON_LEFT and not mb.pressed:
		var here := mb.global_position
		var card := _drag
		var data := _drag_data
		var live := _drag_live
		_drop()
		if not live:
			return false             # a tap; let the Button's own press play it
		var floor_y: float = get_viewport().get_visible_rect().size.y - HAND_BAND
		if drag_release_plays_card(live, here.y, floor_y):
			_on_card_tapped(data, card)
		return true
	return false


## Take the card out of the fan and put it on the overlay, so it can go
## anywhere. It cannot simply be moved where it sits: the hand lives in a
## ScrollContainer, which CLIPS, so a card lifted out of the row would be sliced
## off at the top edge of the band the moment it rose.
func _lift() -> void:
	_drag_live = true
	_hand_hover = null
	# The HUD root, NOT the overlay CanvasLayer. A Control inside a CanvasLayer
	# lives in that layer's coordinate space, so a global_position computed from
	# a viewport-space event lands somewhere else entirely - the card was going
	# to the right place on the wrong canvas. Staying in the HUD keeps one
	# coordinate space, and z_index alone is enough to lift it above the fan.
	_drag.reparent(_drag_layer())
	_drag.z_index = 200
	_drag.scale = Vector2.ONE       # cancel the hover lift; the drag is the lift now
	_drag.rotation = 0.0
	_drag.tilt_overridden = true
	_drag.set_process(true)         # a plain card does not tick until it has to
	# Squash about the middle, or angling the card walks it sideways.
	_drag.pivot_offset = _drag.size * 0.5
	# Stop it taking hover events while it is in the air: CardView sets its own
	# scale on mouse_entered, and the pointer is permanently over a card it is
	# carrying - so the hover would overwrite the tilt every frame.
	_drag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layout_hand()                  # the fan closes over the gap


## Somewhere in the same canvas as the hand, but outside the ScrollContainer
## that clips it.
func _drag_layer() -> Control:
	var hud := get_node_or_null("Hud/Root") as Control
	return hud if hud != null else _hand_row


## Where the card IS becomes where you are STANDING.
##
## Nick: "if you drag it to the right hand, you see into the left hand part of
## the scene inside the card." So the card's own position across the screen is
## the viewing angle, and the sign follows from what a window does: standing to
## the right of one, you see the left of the room through it. rare3d.py's +1
## slides the painting right, which reveals exactly that.
func _aim_dragged() -> void:
	var view: Vector2 = get_viewport().get_visible_rect().size
	var at: Vector2 = _drag.get_global_rect().get_center()
	var nx: float = clampf(at.x / maxf(view.x, 1.0) * 2.0 - 1.0, -1.0, 1.0)
	var ny: float = clampf(at.y / maxf(view.y, 1.0) * 2.0 - 1.0, -1.0, 1.0)
	_drag.turn_override = nx
	# The foil gets the vertical too. A window only has a horizontal view baked,
	# but a sheen has no such limit and a card carried UP the screen catching the
	# light differently is most of what sells the thing as a physical object.
	_drag.tilt_override = Vector2(nx * 1.35, ny * 0.75)
	# And the card itself turns, which is the part that was missing. Same
	# mechanism as the deck screen: a card seen at an angle is a card that has
	# got narrower, and doing that in step with the parallax is what makes the
	# two read as one object rather than as a picture sliding in a frame.
	_drag.scale = Vector2(cos(nx * deg_to_rad(DRAG_TILT_DEG)), 1.0)
	_drag.rotation = -nx * DRAG_ROLL


## Put everything back the way the hand expects it, whatever happens next.
func _drop() -> void:
	var card := _drag
	_drag = null
	_drag_data = {}
	var live := _drag_live
	_drag_live = false
	if card == null or not is_instance_valid(card):
		return
	card.tilt_overridden = false
	card.turn_override = 2.0
	card.z_index = 0
	card.scale = Vector2.ONE
	card.rotation = 0.0
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	if not live:
		return
	# Home first, THEN play. A dragged card is a child of the overlay and the
	# play path expects a card in the fan - the timing strip anchors to it, the
	# hit circle measures from its rect. Returning it and calling the ordinary
	# tap path means drag-to-play and tap-to-play are the same code, so one
	# cannot rot while the other works.
	if is_instance_valid(_hand_row):
		card.reparent(_hand_row)
		_hand_row.move_child(card, mini(_drag_index, _hand_row.get_child_count() - 1))
		_layout_hand()
