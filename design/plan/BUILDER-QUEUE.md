# Builder queue

One ordered list. The builder (`tools/builder/BRIEF.md`) does the **top
unticked item** and nothing else. Nick reorders, adds, deletes, and ticks.

- `[ ]` open · `[ ] 👀` built, waiting for Nick to look · `[x]` Nick says done

Every item names the shot that must change. If the shot does not change, the
run failed.

## Now — the Cinder Jackal fight

**Reset, Nick 2026-10-07: "reset all rules", "the goal is get to the concept as close as possible, any means necessary", "I want the builder to focus on aesthetic changes."**
Every item from before this line is in `## Archive` at the bottom, and none of its instructions bind you, including the seat-colour glow, the old stone route and the old HUD material. The only references are `design/art/targets/TARGET.png` (the whole frame) and `TARGET-UI.png` (close-up of the cards and HUD). **Aesthetic work only:** change how things look, never rules, card numbers or balance. Shoot the rest frame with `state=3d beast=cinder_jackal` and pair it with `python3 tools/vs_target.py <shot>.png <pair>.png --full` (and `--hand` for cards). Meshy is open with no run cap; log what you spend.

- [ ] 👀 **HUD and cards: TARGET's look, no glow.**
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#HUD and cards: TARGET's look, no glow.|details]]
      Ask: nothing
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-10-08-hud-noglow-after.png|420]] ^hud-and-cards-target-s-look-no-glow

- [ ] 👀 **Stones: TARGET's thin pale slabs, spread as a staircase.**
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Stones: TARGET's thin pale slabs, spread as a staircase.|details]]
      Ask: Grader failed this: slabs read as straight bricks, climb flatter than TARGET's. Keep, or another pass?
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-10-08-slabs-after.png|420]] ^stones-target-s-thin-pale-slabs-spread-a

- [ ] 👀 **Left background: cliff and purple sky, not black.**
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Left background: cliff and purple sky, not black.|details]]
      Ask: nothing
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-10-08-leftbg-after.png|420]] ^left-background-cliff-and-purple-sky-not

- [ ] **Fist fire: flame tongues, not a sun disc.**
      The fire on the raised fist reads as a round glowing disc. TARGET's is licking flame tongues rising off the fist, orange edges and a yellow-white core. Keep it animated (flicker) in idle.
      **Done when** the `--beast` pair shows TARGET's flame shape.
      Test: state=3d beast=cinder_jackal ^fist-fire-flame-tongues-not-a-sun-disc

- [ ] **Frog's rock and the floor: TARGET's pedestal and hex tiles.**
      TARGET's frog sits on a large dark faceted pedestal with its HP bar on the front; the floor is dark hex tiles with faint warm seams running to the lava band. Match both.
      **Done when** the `--full` pair shows TARGET's pedestal size and shape and its floor.
      Test: state=3d beast=cinder_jackal ^frog-s-rock-and-the-floor-target-s-pedes


## Waiting on Nick

The builder skips this section. Answer here or in Home; the item then moves
into Now.


## Open decisions

None. The 2026-10-07 reset voided the old defaults (they are at the end of `## Archive`); TARGET.png decides.


## Later — beast rollout (AI pipeline, see `tools/builder/BRIEF-art-rollout.md`)

Do not start until the jackal fight is ticked. One beast per run through
`design/guide/ai-beast-recipe.md` and `tools/blender/ai_beast.py`.

- [x] `cinder_jackal` — the template
- [ ] `crag_pup`
- [ ] `bramble_hog`
- [ ] `boulder_ram`
- [ ] `yoke_ox`
- [ ] `grove_bear` (elite)
- [ ] `flicker_stag` (elite)
- [ ] `glyph_tortoise` — check the sigil raycast lands on the head, not the shell

Non-quadrupeds need a new body plan in `ai_beast.py`; ask first.
- [ ] (proposed) **Harness frames run slow.** A software-rendered shot frame is ~0.2 s, so timed HUD notes fade within a few frames of a `press=`.
- [ ] (proposed) **Top stones at the sigil's height, not the face.** The last stones sit at jaw/neck height beside the head; raising them moves the climb's end.
- [ ] (proposed) **Stone pair centred on the sigil, not the beast.** The Goblin's line sits further right than the Frog's sits left.
- [ ] (proposed) **Climbs skip the stone of an unsafe Height.** Routes stop only at safe ledges, so a climb from the ground to Height 2 jumps over Height 1's stone in one long hop.
- [ ] (proposed) **Stone-to-stone hops are past the arc's ceiling.** On the jackal each hop is 16-25m against hop_arc's 9.15m; the arc stops growing and playtest's hop-distance-band now reports it.
- [ ] (proposed) **Intent badge over the climbing hunter's head.** At some landings the beast's "Attack 7" chip sits on the Goblin's tank and ears.
- [ ] (proposed) **Loose stones sit above their shadows.** Grader saw air between the big side stones and their ground shadows mid-climb.
- [ ] (proposed) **Hunters too close for two stone lines.** From the Frog's view the Goblin's big stone sits under the climb gauge; narrowing the V covers the jackal's legs.
- [ ] (proposed) **Stones cover the jackal's chest at rest.** From behind the Frog the floating stones hide part of the jackal's chest.
- [ ] (proposed) **Hunter reads bigger at the sigil than at rest.** Camera-to-hunter distance is equal (2.49 vs 2.43 measured) yet the Frog is ~1.8x taller on screen at the top.
- [ ] (proposed) **Intent badge covers the jackal's head at rest.** With the lower ground camera the "Attack 7" chip sits on the head.
- [ ] (proposed) Mid-hop the attack badge still touches the Frog's head despite the hunter-rect clamp.
- [ ] (proposed) Up the side the Frog still reads about 1.5x its rest size at the same camera distance.
- [ ] (proposed) **Hunters hidden behind the cards in the wide shot.** In the establishing view neither hunter shows above the card fan; only the ground ring does.
- [ ] (proposed) **Grader reads the previous run's Ask.** It graded this run against "camera further back", the last run's question, not Nick's newest line.
- [ ] (proposed) **Follow distance is further back than RoR2.** RoR2 puts the survivor ~16% of frame height; FOLLOW_DIST 5.2 gives ~11%.
- [ ] (proposed) **Other hunter off-screen at rest.** With hunters on their own stone lines (~8 apart), the follow camera shows only the selected one.
- [ ] (proposed) Nick's knockback screenshot shows the Frog side-on; the harness knockdown shows it facing the beast. Facing after a real enemy-turn knockback is unverified.
- [ ] (proposed) A cancelled hop resets the body's scale but not its forward lean (rotation.x).
- [ ] (proposed) **Playtest's hop-leftover-squash check is stale.** It still wants body scale 1 after a hop; hunters now rest at their fit scale (0.61/0.38), so it fails every hop.
- [ ] (proposed) The fading "Camera: Dev" note overlaps the beast's "Attack 7" intent chip.
- [ ] (proposed) **beast-behind-stone is flaky.** The same code gives 10 or 12 fails; stones 5-7 sit at 15-24%, straddling the 15% line.
- [ ] (proposed) **route-reversal red on main.** 64 fails: the Goblin's climb rungs 3 and 5 step backward along the sweep (on-body anchors, z 6.2 -> -0.99 -> 3.2).
- [ ] (proposed) **damage-popup-offscreen red on main.** 2-3 fails in the 40-step playtest.
- [ ] (proposed) Settings buttons run right up to the scrollbar with no gap.
- [ ] (proposed) **shot.sh ignores + in console=.** Only play mode decodes "+"; console=climb+5 silently runs no command in a shot.
- [ ] (proposed) beast-behind-stone rose 2 -> 6 fails (worst 17.6%) with the stones set back.
- [ ] (proposed) **3dosu without hold= misses the circle.** Under the cloud's software renderer 26 frames close the window before the shot.
- [ ] (proposed) **Sweep-bar face has no drag.** The Settings bar face gets the cost-based tap count but not the drag.
- [ ] (proposed) **HOLD ON banner covers the log.** With the log open, the grip banner hides the first letters of each log line.
- [ ] (proposed) **Jackal damage rework not started.** Nick asked to rethink how the jackal deals damage; only HP changed.
- [ ] (proposed) After a claw-sweep throw the Frog's party card reads ↑2/5 but the height gauge reads "3 up".
- [ ] (proposed) A hunter's damage number covers that hunter's body at the rest camera (the 7 sits on the Frog).
- [ ] (proposed) The sweep's staged turn (shake, both hunters hop down on the bite) has no frame yet.
- [ ] (proposed) Playtest beast-behind-stone swings 3 to 8 fails run to run; stone drift sits on the 15% line.
- [ ] (proposed) The jackal's attack clip barely reads front-on at rest distance; the bite needs a lunge or a side view.
- [ ] (proposed) The grip bar shows no seconds, so the 5 s grip is only provable in code.
- [ ] (proposed) Timing notes 3-4 and the drag path cover the jackal's intent badge mid-climb.
- [ ] (proposed) The Frog model faces sideways, not the beast, so a pitch lean reads as a roll.
- [ ] (proposed) Cards played through a pick (exhaust/cheapen/meld) still resolve instantly, without the flight.
- [ ] (proposed) A kill from the ground keeps the far rest shot, so the fall reads small behind the first stone.
- [ ] (proposed) The reward screen lays the jackal on its back; the death clip leaves it on its side.
- [ ] (proposed) Beasts with no rig get the slow last hit and the pause, but no fall.
- [ ] (proposed) The playtest's grip-while-away check only caught one hanging step in 40; a scripted hang would pin it.
- [ ] (proposed) Timing notes can still open over the hunter's own body or legs (drag head over the Goblin).
- [ ] (proposed) Timing notes may dip into the card band; clamp the walk's floor to the hand's top edge.
- [ ] (proposed) Stone lines are mirror-symmetric about the jackal's box centre, yet only the Goblin's side covers it (30-47% vs <= 11%).
- [ ] (proposed) The grip clock item is moot while grip is off; close or park it?
- [ ] (proposed) enemyat= in a `play` Test link would still freeze the view and quit the window, same trap as fly=.
- [ ] (proposed) The jackal's wind-up has no pose of its own; the attack clip's first 16 frames barely move front-on.
- [ ] (proposed) The intent badge switches to next round's intent on the bite frame, before the new hand.
- [ ] (proposed) Mid-climb, timing note 1 can sit over the jackal's leg; nothing keeps notes off the beast.
- [ ] (proposed) On the ground the Frog's attack cards read "Deal 1 damage"; at the sigil they read 7.
- [ ] (proposed) The jackal's ear tips keep a thin tan rim-light edge; drop toon rim for it too if Nick wants flatter.
- [ ] (proposed) Every other biome still uses exponential fog that hazes its own arena wall the same way.
- [ ] (proposed) A card tapped while its hunter is mid-hop lays its notes round where the hunter was.
- [ ] (proposed) The Frog's tongue aims at the jackal's middle, not the weak point, even mid-climb.
- [ ] (proposed) **Grader penalises dev-camera frames by rest-shot rules.** It docked the dev zoom for a hidden Frog and cut-off ears, which Dev is meant to allow.
- [ ] (proposed) The beatat= crop strip leaves the Goblin out of frame, so it cannot prove the other hunter stays still.
- [ ] (proposed) The zigzag's second stones sit over the jackal's chest from the rest camera, partly hiding it.
- [ ] (proposed) The named 3dclimb shot starts at the sigil, so it cannot show the stones below the Frog.
- [ ] (proposed) Mid-hop in 3dclimb with `climb 3`, the Frog leaves the top of the frame (screen y -26 to -206).
- [ ] (proposed) shot.sh keeps `+` in console= (only play mode turns it into a space), so queue Test lines fail under shot.sh.
- [ ] (proposed) 3dclimb already sits at Height 5, so its `climb 3` Test hops the Frog down, not up.
- [ ] (proposed) The damage number on a blow to the jackal is ~8 px tall from the strike camera (85 m away), easy to miss.
- [ ] (proposed) A hit-stop's slow motion is skipped if one frame outlasts 0.15 s (timers tick once a frame).
- [ ] (proposed) Playtest `beast-behind-stone` already fails on main (6 times in a 30-step run).
- [ ] (proposed) Floating stones cover the jackal's head and chest from the rest camera, so any head or face change is hidden.
- [ ] (proposed) The jackal's leg flame markings sit outside the toon glow mask; only the ears responded to glow_gain.
- [ ] (proposed) Shots take `console=hp 10` with a real space; `+` only decodes in play mode, so a Test line pasted into shot.sh silently fails.
- [ ] (proposed) **Hurt-pattern notch is faint.** The ember line where the jackal turns to its hurt moves is 1 px and hard to pick out at 1280x720.
- [ ] (proposed) Every intent badge now wears the red rim; Defend reads calm only by its gold icon and text.
- [ ] (proposed) **Gauge covers the Goblin's stone.** The climb gauge panel on the right edge overlaps the Goblin's stone in the climb frame.
- [ ] (proposed) The sheen band is view-anchored, so it sits under the hunter's feet and can read as a halo around them.
- [ ] (proposed) **Goblin off-frame in jackal shots.** The Goblin and its stones sit past the right edge in both the rest and climb frames.
- [ ] (proposed) **Frog stone lost against the jackal.** The dark lava stone has little contrast against the black jackal body behind it.
- [ ] (proposed) **Rest camera flattens the far rim.** At rest the whole trench beyond the floor is a few rows at the horizon.
- [ ] (proposed) **Lava streaks at grazing angles.** From the low camera the lava's noise aliases into horizontal stripes.
- [ ] (proposed) **Seam lights are evenly spaced.** They ring the wall on a fixed pattern, not on the lava seams painted in its texture.
- [ ] (proposed) **8-light cap per mesh.** The Compatibility renderer lights a mesh with 8 omni lights at most; the floor's 8 lava lights use its whole budget.
- [ ] (proposed) **The rest camera sees almost no sky.** Cliffs, the boss bar and the intent badge leave a ~250x100 px notch, so sky work barely shows.
- [ ] (proposed) **Stone beside the Frog sits nearer the lens.** Just after the climb 3 landing, the right-hand stone looks as near the camera as the Frog's own.
- [ ] (proposed) **No max energy in the snapshot.** The orb can only say "3", not Slay the Spire's "3/3".
- [ ] (proposed) **Climb gauge still wears the old panel look.** The right-hand rail is the one HUD piece not redesigned.
- [ ] (proposed) **Energy orb with no card costs.** The orb still says 3 while no card shows what it spends.
- [ ] (proposed) **Card name ribbons still inset for the gem.** The banner and borderless name keep their left gap for a gem that is gone.
- [ ] (proposed) A small "<" chevron shows at the far left edge mid-screen in the hover frame; no owner found.
- [ ] (proposed) The jackal's name and HP plate touches the active hunter's feet at the climb camera.
- [ ] (proposed) The old crown-tracking intent_tag_pos and its ten tests are now unused; delete once the HUD slot sticks.
- [ ] (proposed) The deck list still draws cards in the old baked green frame, not the new border.
- [ ] (proposed) The rail (compact) card form still wears the old baked frame stylebox.
- [ ] (proposed) **Aimed-at and climb info lost with the party panel.** The red "being targeted" edge and the ↑Height/5 line lived only on the party cards.
- [ ] (proposed) **Floor disc edge shows right of the Frog.** With the band gone a diagonal orange edge reads at the far right of the rest frame.
- [ ] (proposed) **No shot shows the hunters' rock and the lava ring together.** A still cannot prove where particles start; the grader failed embers on that alone.
- [ ] (proposed) **The idleat grid is too small for the sky.** Half-size frames hide cloud motion in the notch; a sky crop option would help.
- [ ] (proposed) **Test this now links still carry idleat=.** The shot-only grid argument is harmless now but does nothing in play.
- [ ] (proposed) The ash sky glow pulse (once per 9 s) has no frame proving it shows.
- [ ] (proposed) **A climb stone sits in front of the jackal's face.** At the closer rest camera the third stone covers the head.
- [ ] (proposed) **Standoff is shared by every beast.** GROUND_STANDOFF 4.2 -> 1.75 brings every fight's beast closer, not only the jackal.
- [ ] (proposed) **The jackal is narrow head-on.** A front-facing quadruped is ~17% of frame width; A's beast spans most of it.
- [ ] (proposed) Card faces are still mixed: Tongue Snap, Tongue Flick are pictograms and Scramble a 3D render; needs a painted-art pipeline.
- [ ] (proposed) The beast plate keeps the name inline; picture B sets the name on its own tab above a wide bar.
- [ ] (proposed) Gold HUD frames are bevelled rings, not the scrolled end-caps and crown of picture B.
- [ ] (proposed) **The Frog has no contact shadow on its rock.** The rest rock is lit, but no darker shadow shows under the feet.
- [ ] (proposed) **The jackal's thick outline is ragged.** At width 0.018 the inverted hull frays along the low-poly flanks.
- [ ] (proposed) **The v2 jackal has no rig.** No idle, attack, hit or death clips; the old `_ai` one had all four.
- [ ] (proposed) **The sigil ring sits on the v2 jackal's forehead.** climb_5 at y 1.44 puts the ring over the eyes.
- [ ] (proposed) **Stones still ring the beast.** Two lines flank the body instead of climbing the chest as in A.
- [ ] (proposed) **Jackal eyes too small at rest.** At 1:1 the eyes are 2-3 px; the glowing inner ears outshine them.
- [ ] (proposed) **Jackal rock is red, not A's brown.** The softened texture plus the ember key still reads maroon.
- [ ] (proposed) **Lava ring shows near the camera at a closer standoff.** Below gap ~1.2 an orange slab fills the bottom-left.
- [ ] (proposed) **CAMERA_FLOOR caps the rest tilt.** Pitch below about -0.10 no longer tilts the rest camera up.
- [ ] (proposed) **Stones stay put while the jackal punches.** They float in world space; the body swings out from under them.
- [ ] (proposed) **Idle bows the jackal's head.** At rest the face and eyes tip down out of view.
- [ ] (proposed) **Punch leaves the frame top.** Mid-combo the raised fist and head cross the top edge.
- [ ] (proposed) **enemyat= past the beast's turn runs on wall clock.** Under software render it gets ahead of game time.
- [ ] (proposed) **Sigil above the climb's end.** The jackal's top stone is now at the chest, ~7 units below the head's sigil.
- [ ] (proposed) **Two sigil rings on the jackal's chest.** At rest two gold rings sit over the chest under the staircase's top.
- [ ] (proposed) **Float stone homes never cleared.** `_build_float_stones` clears the stones but not `_float_home`.
- [ ] (proposed) **Floor tone was near black.** `floor_tone` is an sRGB `source_color`, so 0.17 rendered almost black; raised to 0.25.
- [ ] (proposed) **Stones and rest rocks still cobble-textured.** Beside the flat cliffs they are the last detailed-realistic surfaces in frame.
- [ ] (proposed) **Skinned TANGENT is mangled.** Any rigged model's outline must carry welded normals in NORMAL, not TANGENT.
- [ ] (proposed) **Jackal body a shade orange with the outline.** Cracks stand out less than in picture A.
- [ ] (proposed) **Horizon band was the heat haze.** The shimmer cylinder adds glow; dimming the lava pool alone does nothing.
- [ ] (proposed) A brighter jackal body floor (0.36) flattens the body into one orange tone and hides its cracks.
- [ ] (proposed) **Idle pose varies between shots.** The jackal's idle differs frame to frame, so graders credit changes nobody made.
- [ ] (proposed) **Ring markers on the jackal's chest.** Two pale rings sit on its chest at rest; picture A has none.
- [ ] (proposed) A thin magenta streak sits at the far-left horizon in state=3d; picture A has none.
- [ ] (proposed) **Frog's outline is invisible.** Its dark line exists but vanishes against the dark plinth and floor.
- [ ] (proposed) **Embers are random between shots.** Small tone changes drown in ember scatter, so the grader calls them unchanged; seed them in shots.
- [ ] (proposed) **Stones sit beside the drawn jackal.** The climb staircase runs up its left flank, not across its front as in TARGET.
- [ ] (proposed) **Hull code is now dead for the jackal only.** Other beasts still use foothold_anchor's hull, _front_of_beast and stand_z_for, so they stay.
- [ ] (proposed) **Drawn jackal has no idle or attack motion.** The sprite is a still; a bob or squash on its turn would sell it.
- [ ] (proposed) **Slab drop shadows don't show.** A black blur under each slab vanishes against the near-black floor and beast.
- [ ] (proposed) **Near stone smaller than the Frog's plinth.** The rest rock is wider than the first slab; TARGET's first slab is the biggest thing on the floor.
- [ ] (proposed) **Hand fan hides the card footer.** At rest every card is cut at the screen's bottom edge, so a footer or rarity token never shows.
- [ ] (proposed) **Raised card's title clipped in shots.** hover= lifts the card past the top of the fan, cutting off its name plate.
- [ ] (proposed) **Second seat's blue hand unshot.** The rest frame only shows the Frog's green cards; a switch= shot would prove blue.
- [ ] (proposed) **Thin HUD panels lose their stone.** The beast plate, intent, plates and Switch are so short the A1 band reads as an outline.
- [ ] (proposed) **Pile badges still brass.** Draw, discard and burn are the old brown card stacks, the one HUD piece not in A1.
- [ ] (proposed) **Drawn-gap lever is clamped.** DRAWN_GAP_PER_HEIGHT below 0.8 no longer grows the jackal on screen; something else caps it.
- [ ] (proposed) **Grey arc behind End Turn in 3dclimb.** A pale arc shows at x 1000-1150, y 630-720 in the climb shot.
- [ ] (proposed) **Jackal smaller than TARGET.** At rest the beast fills far less of the frame than in TARGET.png.
- [ ] (proposed) **Ring markers on the jackal at rest.** A grey chest ring and a yellow pelvis ring sit on the drawing.
- [ ] (proposed) **Grader can't see sprite_match.** It fails items for numbers it can't read off a frame; hand it the printout?
- [ ] (proposed) **Post chain crushes dark art.** The fight blacks out everything under ~0.14 linear; other dark art may suffer.
- [ ] (proposed) **Lava horizon reads brighter behind the jackal's feet.** Grader saw it brighten this run; the halo may spill on the lava line.
- [ ] (proposed) **Fight reads the climb holds once.** The rig moves its climb_ markers, but stones and hunters stay where they were placed at load.
- [ ] (proposed) **sprite_match aims at the concept, not TARGET.** TARGET's own jackal scores outline 0.0146 / crack 0.182 against its 0.005 / 0.125 targets; the fire layer counts as cracks.
- [ ] (proposed) **Shoulder notch at the attack's impact.** A small dark wedge shows where the swung upper arm leaves the torso.
- [ ] (proposed) **Frog can't stand under the sternum.** The shoulder truck draws a waiting hunter ~100 px left of it; TARGET centres the Frog there.
- [ ] (proposed) **Bevelled slab tops.** TARGET's slab tops show crisp facet planes; ours are smooth.

## Archive — everything in Now before the 2026-10-07 reset (history only; binds nothing)

- [ ] 👀 **Rig the jackal as a 2D cut-out in TARGET's pose: drawn at rest, animated in the fight.**
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Rig the jackal as a 2D cut-out in TARGET's pose: drawn at rest, animated in the fight.|details]]
      Ask: Grader failed this: climb stones don't ride the body. Make the fight re-read holds?
      **Nick, 2026-10-07, overriding everything earlier:** "Override and start with a clean fresh slate. The goal is get to the concept as close as possible, any means necessary. Use Meshy or whatever is needed." Any earlier ruling that conflicts with TARGET.png is void. **Meshy: no run cap for these two items**; log every task and its credits in the notes.
      **Nick, 2026-10-07:** the rest pose and design must match his drawing, `design/art/targets/TARGET.png`, and the jackal must be animated. The camera is essentially front-on, so a flat drawn jackal is fine; it just has to move. This replaces the single static sprite from `tools/beast_sprite.py` and settles the pose question the checker was stuck on: **TARGET's pose IS the rest pose** (hunched, three-quarter turn, left fist raised and on fire).
      **1. Art: layers cut from TARGET itself, not a new drawing.** Source is the jackal in TARGET.png, so the rest frame matches 1:1. Split it into layers: head, neck/torso, each upper arm, forearm and fist, and the fist's fire on its own layer. Repaint only what TARGET hides: the lower torso behind the stones, the chest behind the raised arm, and the overlap at every joint so nothing tears when a part rotates (the tearing is what killed the 2026-10-06 cut-and-rotate). Use Meshy (image-to-image, or anything else that gets closer) or hand paint; say what you spent. Keep TARGET's outline, cracks, colours and facets as drawn. The inking settings the checker tuned in `beast_sprite.py` are reference values, not a filter to run over TARGET.
      **2. Rig:** Godot Skeleton2D/Polygon2D (or Bone2D-parented Sprite2Ds) in a SubViewport drawn onto the existing billboard, so the arena and camera code stay as they are. Climb holds attach to the bones they sit near so they ride the animation.
      **3. Clips:** `idle` (breathing, the fist's fire flickering; loops, never drifts far from the rest pose), `attack` (wind-up, then the raised fist swings down; damage lands on the impact frame, as the punch clip's `hit` did), `hit` (flinch), `death`. Wire them where `_beast_anim` drives Idle/Punch_Combo today.
      **Done when** a rest frame paired with TARGET (`python3 tools/vs_target.py <rest>.png <pair>.png --beast`) shows the same pose and silhouette, and a strip of four frames (idle, wind-up, impact, back to idle) shows the jackal moving without tearing at any joint. Tests green.
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-10-07-rig-after.png|420]] ![[agents/frames/builder/2026-10-07-rig-strip.png|420]] ^rig-the-jackal-as-a-2d-cut-out-in-target

- [ ] 👀 **Stones: TARGET's staircase, in TARGET's place.**
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Stones: TARGET's staircase, in TARGET's place.|details]]
      Ask: nothing
      **Nick, 2026-10-07:** "make sure you are checking all the boxes to get to the concept. Ie stone design and placement." **This replaces the 2026-09-25 / 09-28 route** (first stone by the hunter, last in front of the head). TARGET.png is the route now.
      **Design:** six pale grey slabs, thin and flat with soft bevelled edges, light tops (~160–190) over mid-grey sides, no black outline, each a little smaller and higher than the one below.
      **Placement:** one staircase from the foreground, left of and just above the frog's rock, rising up and to the right across the front of the jackal's body, ending just under the sternum, where the cracks meet in the hot yellow seam. The face stays clear. Measure the slab positions off TARGET.png and match them in the rest shot.
      **The climb ends at the sternum, not the face**, so move the top hold, the sigil/weak point and the climb gauge's top to match, and update the tests that assumed the face ("climb ends at the face"). The Goblin's line gets the same look, mirrored, outside the rest frame.
      **Done when** a `--full` pair of the rest shot against TARGET (`python3 tools/vs_target.py <rest>.png <pair>.png --full`) shows the same slabs in the same places, and a climb from the ground to the top lands on each slab in turn. Tests green. Then append `## Round 2 — rigged jackal, TARGET stones (<date>)` to `design/match-log/log.md`: that heading restarts the checker on the whole frame.
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-10-07-stones-after.png|420]] ![[agents/frames/builder/2026-10-07-stones-climb-strip.png|420]] ^stones-target-s-staircase-in-target-s-pl

- [ ] 👀 **Drive the jackal sprite to 1:1 with the concept. Numbers, not opinions.**
      **Nick, 2026-10-06:** "I want you to automatically take what the builder outputs and reference it against the concept art till it becomes 1:1. The builder shouldnt have to ask me thickness you should see if it matches the concept and get it it to 1:1."
      Checker, 2026-10-07, on 02b55a8: all five measures land.
      `python tools/sprite_match.py` prints: ^drive-the-jackal-sprite-to-1-1-with-the-

          body tone     concept 41.8    game 41.8    ok
          body hue      concept 7.1     game 7.1     ok
          crack cover   concept 0.125   game 0.127   ok
          detail        concept 0.068   game 0.063   ok
          outline       target  0.0050  game 0.0053  ok

          0 of 5 off

      **rim colour (seen in the pair, not measured)** — the rim is the right
      width but it reads as a pale cream-white wire. In the concept the rim is
      warm amber-gold with an orange inner edge and a soft glow falling off
      outside it. Keep the width; warm the line to the concept's gold and give
      it the glow. See `design/agents/frames/checker/2026-10-07-pair.png`.
      Answer to the Ask below: keep TARGET's width — the outline measure says
      it matches. The remaining gap is colour and glow, not thickness.
      **Do not ask Nick about any of these.** They are measured. Fix until
      `tools/sprite_match.py` prints `0 of 5 off`, re-running it after each
      change. Meshy is allowed inside the brief's 60-credit run cap if the
      inking alone cannot get there.
      **Done when** `tools/sprite_match.py` prints `0 of 5 off` and the pair from
      `tools/vs_target.py --beast` shows no difference Nick would name.
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Drive the jackal sprite to 1:1 with the concept. Numbers, not opinions.|details]]
      Ask: Grader failed this: line half TARGET's weight. Thicken past the measured width?
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-10-07-rim-gold-after.png|420]] ^drive-the-jackal-sprite-to-1-1


- [ ] 👀 **Stop the inking from destroying the jackal. Quality, not pose.**
      **Nick, 2026-10-06:** "The jackal should be able to move. So the direction doesnt matter. Its the quality that im looking for."
      **The pose is no longer the job.** Drop pose-matching, and drop the
      `repose` cut-and-rotate in `tools/beast_sprite.py` if it costs quality.
      The jackal will be animated later, so which way it faces does not matter.
      **The job is that the sprite keeps the quality of its own source.**
      `design/art/targets/2026-10-04-jackal-concept.png` already has what Nick
      wants: faceted rock planes, a real snout, sharp eyes, a dark red-brown body
      with hot cracks cut into it. `beast_sprite.py` inks it and the game draws
      something much worse — see ![[art/shots/2026-10-06-head-pair.png|520]] —
      melted ears, a flat muzzle, eyes reduced to two marks, facets gone, and a
      thick cream halo around the figure that is in neither the concept nor
      `TARGET.png`.
      **Fix the inking; do not redraw the beast.** The outline is a thin warm
      line, not a thick cream halo. The facet planes and their tone steps
      survive. The eyes and the muzzle survive. The body stays dark with the
      cracks glowing, instead of the whole figure glowing.
      **Meshy is allowed here.** Nick, 2026-10-06: "If the builder needs to use
      meshy credits to achieve the quality from the concept art it can with my
      approval." If fixing the inking cannot reach the concept's quality, use an
      image pass (`meshy_image_to_image` off the concept, 3-12 credits) to get a
      clean sprite, within the 60-credit run cap in the brief. Say what you spent.
      **Done when** `python tools/vs_target.py <after>.png <pair>.png --beast`
      shows the jackal holding the detail the concept has, and a head crop of the
      sprite is not visibly worse than the same crop of the concept.
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Stop the inking from destroying the jackal. Quality, not pose.|details]]
      Ask: Is the thin warm line thick enough, or thicken it toward TARGET's?
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-10-06-inking-after.png|420]] ^stop-the-inking-destroying-the-jackal

- [ ] 👀 **The jackal becomes a 2.5D sprite, like the reference.**
      **Nick, 2026-10-05:** "the new model still doesn't match the style of the reference. could going to a vector 2d style boss help? have the builder do the 2.5D like in the reference."
      `TARGET.png` is a 2D illustration — hard ink outline, flat colour fills, drawn lava cracks, a painted rim light. None of it is lit geometry, and three weeks of 3D have not reached it: the inverted-hull outline breaks up, per-facet shading reads as noise, and the texture turns to mush at play size. So stop fighting it.
      **Render the Cinder Jackal as a billboard sprite in the existing 3D scene.** Floor, stones, hunters and the climb stay 3D. The sprite is a single high-resolution illustration in `TARGET.png`'s style: thick dark outline, flat fills, hard-edged glowing cracks, warm rim. It always faces the camera. Supersedes the `cinder_jackal_v2.glb` item above — keep both files, ship neither mesh.
      **The climb holds become authored 2D points on that image**, not raycasts against a mesh. This deletes the fragile half of `combat_3d.gd`: `foothold_anchor`'s hull queries, `_front_of_beast`, `stand_z_for`. The route still ends at the head and the face stays visible at rest.
      Accept the flatness: the camera is front-on and locked, which is what the reference shows.
      **Done when** `state=3d` put beside `TARGET.png` reads as the same drawing — same outline weight, same flat fills, same glow — and the climb still plays start to finish.
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#The jackal becomes a 2.5D sprite, like the reference.|details]]
      Ask: Grader failed this: concept's arms-down pose, no flaming fist. Draw TARGET's pose?
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-10-05-jackal-sprite-after.png|420]] ^the-jackal-becomes-a-2-5d-sprite-like-th

- [ ] 👀 **Rebuild the stones to match the reference exactly.**
      **Nick, 2026-10-05:** "make sure it hits the mark on recreating the stones to match the reference."
      In `TARGET.png` the stones are flat, pale grey slabs — wide, thin, slightly irregular, a soft drop shadow under each, no rim and no lid. They climb away from the hunter toward the beast in clear perspective, biggest and lowest at the front. In the game they are pale boxes with an orange top.
      Match the reference: shape, colour, thickness, the shadow, the spacing, and how they diminish with distance. The near one is the biggest thing on the floor; the far one sits at the beast's chest.
      **Done when** the stones in `state=3d` are indistinguishable in style from the ones in `TARGET.png` at 1:1.
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Rebuild the stones to match the reference exactly.|details]]
      Ask: Grader failed this: no visible drop shadow, side face too thin. Thicken slabs?
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-10-05-stones-after.png|420]] ^rebuild-the-stones-to-match-the-referenc

- [ ] 👀 **Ship the A1 card frame, tinted per seat.**
      **Nick, 2026-10-05:** "A1, but i need the orange color to be editable to match the color of different characters. also make sure that things match up within the card. IE the energy numbers need to be reduced in size and fit within the circle and are matched to be inside."
      The frame is already split into two files by `tools/cardframe_a1.py`:
      `game/assets/ui/card_frame_a1_base.png` (neutral stone, no ember) and
      `card_frame_a1_glow.png` (white glow on transparent). Stack them in
      `card_view.gd` and set `self_modulate` on the glow one. **No baked colour
      anywhere** — a blue card must not keep a warm cast.
      The tint comes from the seat, the way `combat_3d.gd`'s `SLOT_TINT` /
      `slot_tint(slot)` already colours the floor markers: extend that table to
      one colour per character rather than inventing a second scheme.
      Author these boxes, normalised against the card, straight from
      `tools/cardframe_a1.py` (they are measured off the generation):
      socket centre `(0.126, 0.0874)` r `0.0478` · title `(0.205, 0.045, 0.945, 0.130)` ·
      art `(0.095, 0.150, 0.905, 0.560)` · type `(0.112, 0.585, 0.900, 0.640)` ·
      text `(0.112, 0.665, 0.900, 0.925)`.
      **The cost number is centred in the socket and fits inside it** — shrink the
      number to the disc, never the disc to the number. Nothing on the card may
      cross a panel edge: name starts clear of the socket, art fills its window
      without touching the frame, rules text wraps inside the text box.
      The frame stretches as a nine-patch; the socket and the corners do not.
      **Done when** a hand in `state=3d` shows every card in its own seat colour,
      the costs sit inside their sockets at hand size, and nothing clips at 1280x720.
      Mockups: ![[art/cards/a1-hand.png|420]] ![[art/cards/a1-tints.png|420]]
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Ship the A1 card frame, tinted per seat.|details]]
      Ask: Grader failed this: resting hand runs off screen bottom. Raise the hand?
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-10-05-a1-frame-after.png|420]] ^ship-the-a1-card-frame-tinted-per-seat

- [x] **Research: card frames, against real TCGs.** — done by the session.
      [[art/card-frame-research]], three mockups, four Meshy passes over A and B.
      **Nick picked A1 (carved obsidian)** on 2026-10-05, so the builder's own
      ask on this item is answered. Superseded by the item above.
      Builder's pass: ![[agents/frames/builder/2026-10-05-card-frames-after.png|420]] ^research-card-frames-against-real-tcgs

- [ ] 👀 **A HUD that matches the chosen card frame.**
      **Nick, 2026-10-05:** "once the research is done use meshy to help design a new overlay hud that matches the new card templates. reference huds of other card games."
      **Nick picked A1 (carved obsidian), 2026-10-05.** Re-theme the whole overlay in that same material: the beast's health bar, the intent badge, the energy orb, the climb gauge, the party health plates, End Turn and Switch.
      Same two-layer rule as the cards: neutral stone plus a glow layer that takes the seat colour, so a player's HUD and their hand light up together.
      Reference how card games lay out and style a HUD — Slay the Spire, Hearthstone, Runeterra, Marvel Snap — and say what you took. `TARGET-UI.png` is Nick's own pick for the cards and HUD and stays the arbiter.
      Meshy may be used for any panel ornament that is genuinely easier sculpted than drawn — a carved frame corner, an energy orb — rendered once to a texture. Ask Nick before spending credits; it is not required, and a drawn panel that matches is worth more than a sculpted one that does not.
      **Done when** every HUD element and the cards read as one set, nothing clips at 1280x720, and the rest frame beside `TARGET-UI.png` shows the same material.
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#A HUD that matches the chosen card frame.|details]]
      Ask: Grader failed this: wants TARGET-UI's grey/gold stone, not seat glow. Which wins?
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-10-05-a1-hud-after.png|420]] ^a-hud-that-matches-the-chosen-card-frame

- [ ] 👀 **Swap in the new upright jackal model.**
      **Nick, 2026-10-04 19:17 ET:** yes generate a new jackal model from picture A
      The model is generated and in the repo: `game/assets/3d/cast/cinder_jackal_v2.glb` (upright rock jackal from picture A, 29,628 triangles, 1.38 wide x 1.90 tall, texture embedded). Run `--import`, then use it for the Cinder Jackal in the fight in place of `cinder_jackal_ai.glb`; keep the old file. In `state=3d` it must fill the upper half of the frame like `design/art/targets/TARGET.png`, with the lava cracks glowing and the warm outline. Re-derive the stone route and the holds for the new shape: the climb still ends at the head, and the face stays visible at rest.
      Concept: ![[art/targets/2026-10-04-jackal-concept.png|300]] Model: ![[renders/cinder_jackal_v2_pass1_front.png|300]] ![[renders/cinder_jackal_v2_pass1_34.png|300]]
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#Swap in the new upright jackal model.|details]]
      Ask: Grader failed this: beast too narrow. Crop its legs to fill A's width?
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-10-04-jackal-v2-after.png|420]] ^swap-in-the-new-upright-jackal-model
- [x] **Scene pass 1 toward picture A: big lit jackal, readable floor.**
      **Nick, 2026-10-04 15:38 ET:** A, but the cards and UI from B
      A, bold flat: ![[art/targets/2026-10-04-target-A-bold-flat.png|420]]
      B, painted: ![[art/targets/2026-10-04-target-B-painted.png|420]]
      C, dusk low-poly: ![[art/targets/2026-10-04-target-C-dusk-lowpoly.png|420]]
      Now: ![[agents/frames/builder/2026-09-30-floor-band-after.png|420]]
      The pictures are square and the game is 16:9: they set the look (beast size, light, colour, outline, card style), not the exact layout.
      Nick picked A for the scene and B for the cards and HUD. Both are saved as `design/art/targets/TARGET.png` and `TARGET-UI.png`, shown on [[JACKAL-BAR]], and the grader compares against them. Build pass 1 toward `TARGET.png`, in `state=3d`: the jackal fills the upper half of the frame, is lit so its shape reads and has the warm outline; the floor is readable instead of black. Cards and HUD are the next item, not this one.
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#Scene pass 1 toward picture A: big lit jackal, readable floor.|details]]
      Ask: Grader failed this: a climb stone hides the face. Move the stones next?
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-10-04-scene-pass1-after.png|420]] ^pick-the-target-picture
- [x] **One HUD style: carved obsidian.**
      **Nick, 2026-09-30 16:59 ET:** yes but game crashes a second after opening
      **Nick, 2026-09-30 11:44 ET:** the cinder jackal health can be in top left. remove the character information. also remove the big intent above the beast and make it small and next to its health. also stop the hunters from moving up and down while idle.
      **Nick, 2026-09-30 09:44 ET:** no. we need to redesign the display of information. reference how slay the spire ii displays information and try to use that as the bar
      **Session, 2026-09-29 22:35 ET:** The HUD is flat outlined panels. Re-theme the top bar, party cards, intent badge, energy orb and the End Turn and Switch buttons in one material: dark glassy fill, bevelled edge, thin ember-orange rim, soft shadow; names in the display font in `assets/fonts`. Same sizes and positions, nothing overlaps at 1280x720. Done-when: the rest frame shows every panel in the new material and no text clips. Source: [[2026-09-29-intense-fight-plan]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal%20slot%3D1%20idleat%3D0%2C0.4%2C0.8%2C1.2) · [[BUILDER-QUEUE-NOTES#One HUD style: carved obsidian.|details]]
      Ask: Window no longer closes after the idle frames. Does it stay open now?
      Test: state=3d beast=cinder_jackal slot=1 idleat=0,0.4,0.8,1.2
      ![[agents/frames/builder/2026-09-30-play-stays-open-after.png|420]] ^one-hud-style-carved-obsidian
- [x] **A sky with ash.**
      **Nick, 2026-09-30 16:59 ET:** yes but game crashes after a few seconds
      **Nick, 2026-09-30 09:44 ET:** sky looks fine, but clouds need to move.
      **Session, 2026-09-29 22:35 ET:** The sky is a two-colour gradient. Add a slow-moving ash cloud layer with a red-lit underside near the horizon and an occasional distant glow pulse, for `quarry_ember` only. Fog behind the wall stays. Done-when: the rest frame shows clouds above the wall with red at their base. Source: [[2026-09-29-intense-fight-plan]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal%20idleat%3D0%2C3%2C6) · [[BUILDER-QUEUE-NOTES#A sky with ash.|details]]
      Ask: Game now stays open with the drifting sky. Still crashing for you?
      Test: state=3d beast=cinder_jackal idleat=0,3,6
      ![[agents/frames/builder/2026-09-30-sky-stays-open-after.png|420]] ^a-sky-with-ash
- [x] **Remove cost.**
      **Nick, 2026-09-30 11:44 ET:** no we still need cost gems. a redesign of the card borders in need.
      **Nick, 2026-09-30 10:59 ET:** remove cost
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#Remove cost.|details]]
      Ask: Gems back; borders now obsidian with brass lines. Keep this border direction?
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-09-30-card-borders-after.png|420]] ^remove-cost
- [x] **The camera swings with each hop.**
      **Nick, 2026-09-30 09:44 ET:** no i dont like this change
      **Session, 2026-09-29 22:35 ET:** With the zigzag, a hop moves the hunter sideways. Pan the locked camera across with the hunter over the hop and settle with a small overshoot (about 0.15 s), so the traverse is felt. Done-when: a two-frame strip, before and after one hop, shows the camera's x differs and the hunter is centred in both. Source: [[2026-09-29-intense-fight-plan]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal%20console%3Dclimb%2B3%20touch%3D1%2C0.075) · [[BUILDER-QUEUE-NOTES#The camera swings with each hop.|details]]
      Ask: Swing removed: camera lands dead on the Frog each hop, as before. Good?
      Test: state=3d beast=cinder_jackal console=climb+3 touch=1,0.075
      ![[agents/frames/builder/2026-09-30-hop-swing-revert-after.png|420]] ^the-camera-swings-with-each-hop
- [x] **Hits stop time.**
      **Nick, 2026-09-30 09:44 ET:** no remove this for now
      **Session, 2026-09-29 22:35 ET:** A landed strike freezes the frame for 0.08 s, shakes the camera in proportion to damage, and bursts embers from the impact point; a weak-point hit adds 0.15 s of slow motion. The jackal's bite gets the same hit-stop on the hunter. Done-when: the strike frame shows the ember burst at the impact point and a frame 0.1 s later shows the camera offset. Source: [[2026-09-29-intense-fight-plan]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3dstrike%20beast%3Dcinder_jackal%20beat%3Dimpact) · [[BUILDER-QUEUE-NOTES#Hits stop time.|details]]
      Ask: Grader failed this: old strike shake still moves lens. Remove that too?
      Test: state=3dstrike beast=cinder_jackal beat=impact
      ![[agents/frames/builder/2026-09-30-hit-stop-remove-after.png|420]] ^hits-stop-time
- [x] **The jackal threatens between turns.**
      **Nick, 2026-09-30 09:44 ET:** no revert this as the game is co op and we cannot make this work in multiplayer
      **Session, 2026-09-29 22:35 ET:** Between turns the jackal only idles. Make its head track the active hunter, brighten the ember cracks as its turn nears, play one growl when the last hunter turn begins, and pulse the intent badge in step. Done-when: rest vs after one End Turn shows the head turned to the hunter, the cracks brighter and the badge larger. Source: [[2026-09-29-intense-fight-plan]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal%20endturn%3D1) · [[BUILDER-QUEUE-NOTES#The jackal threatens between turns.|details]]
      Ask: Reverted: no head turn, crack heat, badge beat or growl. Gone for good?
      Test: state=3d beast=cinder_jackal endturn=1
      ![[agents/frames/builder/2026-09-30-threat-revert-after.png|420]] ^the-jackal-threatens-between-turns
- [x] **Low health shows on screen.**
      **Nick, 2026-09-30 09:44 ET:** no remove the heartbeat
      **Session, 2026-09-29 22:35 ET:** A hunter under 30 % HP gets a red edge vignette that pulses with a heartbeat; the jackal under 30 % streams embers, breathes faster and glows hotter. Add a console command `hp 10` (active hunter) and `hp beast 15` so the frame can be set. Done-when: a frame with the Frog at 10 HP shows the red vignette and one with the jackal at 15 HP shows the ember stream. Source: [[2026-09-29-intense-fight-plan]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal%20console%3Dhp%2B10) · [[BUILDER-QUEUE-NOTES#Low health shows on screen.|details]]
      Ask: Grader failed this: wanted a steady red edge kept. Keep the edge unpulsed?
      Test: state=3d beast=cinder_jackal console=hp+10
      ![[agents/frames/builder/2026-09-30-heartbeat-remove-after.png|420]] ^low-health-shows-on-screen
- [x] **Cards fan and glow.**
      **Nick, 2026-09-30 09:44 ET:** remove this
      **Session, 2026-09-29 22:35 ET:** Fan the hand in a shallow arc with a slight tilt per card; the hovered card lifts, straightens and glows at its edge with `foil.gdshader`'s rim; the cost pip pulses while the card is playable. No card flight (Nick, 20:59). Done-when: the hover frame shows the lifted glowing card above its tilted neighbours. Source: [[2026-09-29-intense-fight-plan]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal%20hover%3D1) · [[BUILDER-QUEUE-NOTES#Cards fan and glow.|details]]
      Ask: Grader failed this: fan tilt and lift still there. Flatten the hand too?
      Test: state=3d beast=cinder_jackal hover=1
      ![[agents/frames/builder/2026-09-30-cards-fan-remove-after.png|420]] ^cards-fan-and-glow
- [x] **The intent badge reads like a warning.**
      **Nick, 2026-09-30 09:44 ET:** remove damage badge and put it somewhere else in the hud.
      **Session, 2026-09-29 22:35 ET:** The intent badge is a small boxed label that sometimes sits on a hunter. Make it bigger, red-rimmed, with an icon per move type, pinned above the jackal's head at every camera and never over a hunter. Done-when: rest and climb frames both show the badge above the head and clear of both hunters. Source: [[2026-09-29-intense-fight-plan]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#The intent badge reads like a warning.|details]]
      Ask: Badge moved off the jackal to a fixed top-centre HUD panel. Right spot?
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-09-30-intent-hud-after.png|420]] ^the-intent-badge-reads-like-a-warning
- [x] **Obsidian floor.**
      **Nick, 2026-09-30 09:44 ET:** remove the band
      **Session, 2026-09-29 22:35 ET:** The arena floor is a flat grey-brown disc. For `quarry_ember` make it black glass: dark base, sharp toon specular band, faint orange emissive in a crack pattern; the plain `Ground` disc gets the same material. Other biomes unchanged. Done-when: the rest frame's floor reads black and glossy with a visible specular band. Source: [[2026-09-29-intense-fight-plan]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#Obsidian floor.|details]]
      Ask: Band removed: plain black floor with faint cracks. Good?
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-09-30-floor-band-after.png|420]] ^obsidian-floor
- [x] **Embers in the air.**
      **Nick, 2026-09-30 09:44 ET:** glow a little too strong and should not be rising on the lava rock everyone is standing on. only from the lava surrounding them.
      **Session, 2026-09-29 22:35 ET:** Rising ember particles across the arena, sparks falling from the wall's lava seams, and omni lights in the seams so they throw orange on the rock. Done-when: the rest frame shows embers in the air and orange light on the wall around the seams. Source: [[2026-09-29-intense-fight-plan]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#Embers in the air.|details]]
      Ask: Grader failed this: a still cannot show where embers start. Now only off the lava, dimmer. Good?
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-09-30-embers-lava-after.png|420]] ^embers-in-the-air
- [x] **Hunters lunge when they attack and flinch when hit.**
      **Nick, 2026-09-29 22:29 ET:** slow down the animation by about 25 %
      **Nick, 2026-09-29 20:59 ET:** it works now. in the lunge can you add a tongue coming out like its attacking with its tongue at the beast?
      **Nick, 2026-09-29 17:14 ET:** the scenario doesn't show this properly also frog is stuck
      **Session, 2026-09-29 11:05 ET:** The Frog and Goblin have no rig; `_hunter_play` for attack and hit does nothing. Build both as tweens like the hop already is: attack = a 0.15 s lunge toward the beast with a scale punch, only on the hunter that played the card; hit = a white flash and a 0.2 s knock-back with a lean. Done-when: a strike frame shows the lunge, a hit frame shows the flinch, and the other hunter does not move. Source: [[2026-09-28-jackal-fight-analysis]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3dstrike%20beast%3Dcinder_jackal%20beat%3Dloop%20beatat%3D0.2%2C0.28%2C0.36%2C0.44) · [[BUILDER-QUEUE-NOTES#Hunters lunge when they attack and flinch when hit.|details]]
      Ask: Lunge and flinch now 25% slower (lunge 0.44 s round trip). Pace right?
      Test: state=3dstrike beast=cinder_jackal beat=loop beatat=0.2,0.28,0.36,0.44
      ![[agents/frames/builder/2026-09-30-lunge-slower-after.png|420]] ^hunters-lunge-when-they-attack-and-flinc
- [x] **One tap for ordinary timed cards?**
      **Nick, 2026-09-29 21:14 ET:** drag no longer touch card tops, but some drag goes over the next click in the timing event. need to make sure they are spaced and lead well
      **Nick, 2026-09-29 12:59 ET:** some of the time events are going behind the cards
      **Nick, 2026-09-29 12:44 ET:** yes and randomize the order for drag. sometimes on one sometimes others
      **Session, 2026-09-29 16:50 ET:** these three answers were stuck on Nick's PC since 12:44 (its sync was jammed) and never reached the builder. Read them in time order, oldest last.
      **Nick, 2026-09-29 11:59 ET:** make it more complex dependent on how much the card cost. add a mechanic of click and drag. also add variety of where the clicks are, but don't have them far from the card.
      **Session, 2026-09-29 11:05 ET:** Today every timed card needs three taps and one bad tap loses it. Default if you say yes: three taps only for cards that print more than one window (Satchel Charge); everything else is one tap. This changes a balance number, so it is yours. Source: [[2026-09-28-jackal-fight-analysis]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal%20hand%3Dflick%2Clash_out%2Cpiston_punch%2Coverload_engine) · [[BUILDER-QUEUE-NOTES#One tap for ordinary timed cards?|details]]
      Ask: Drags now point on to the next tap, never across one. Spaced right?
      Test: state=3d beast=cinder_jackal hand=flick,lash_out,piston_punch,overload_engine
      ![[agents/frames/builder/2026-09-30-drag-clear-after.png|420]] ^one-tap-for-ordinary-timed-cards
- [x] **Make the Jackal be less glossy and more matte.**
      **Nick, 2026-09-29 21:14 ET:** it is matte enough
      **Nick, 2026-09-29 12:14 ET:** Make the Jackal be less glossy and more matte (where: jackal) ![[art/references/Pasted image 20260929121120.png|420]]
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3dclimb%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#Make the Jackal be less glossy and more matte.|details]]
      Ask: You said matte enough, so nothing changed. Tick it off?
      Test: state=3dclimb beast=cinder_jackal
      ![[agents/frames/builder/2026-09-29-jackal-matte-after.png|420]] ^make-the-jackal-be-less-glossy-and-more-
- [x] **Played cards fly to their target.**
      **Nick, 2026-09-29 20:59 ET:** the played cards flying feel really bad please revert.
      **Nick, 2026-09-29 17:29 ET:** the card is stuck
      **Session, 2026-09-29 11:05 ET:** A played card pops out of the hand. Make it scale up and fly to the beast for an attack, to the hunter for block or climb, before its effect resolves, about 0.25 s. Block pops a ring on the hunter and plays the `block` sound that exists and is never played. Done-when: a mid-flight frame shows the card between the hand and its target. Source: [[2026-09-28-jackal-fight-analysis]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal%20hand%3Dslash%2Cbrace%2Crope_up%2Cbunker_down%20fly%3D0%20flyt%3D0.5) · [[BUILDER-QUEUE-NOTES#Played cards fly to their target.|details]]
      Ask: Flight reverted: a tapped card plays at once, nothing flies. Good?
      Test: state=3d beast=cinder_jackal hand=slash,brace,rope_up,bunker_down fly=0 flyt=0.5
      ![[agents/frames/builder/2026-09-30-card-fly-revert-after.png|420]] ^played-cards-fly-to-their-target
- [x] **Let the Frog hang?**
      **Nick, 2026-09-29 17:14 ET:** lets get rid of the grip mechanic for now
      **Nick, 2026-09-29 11:59 ET:** i don't understand this question please re word it.
      **Session, 2026-09-29 11:05 ET:** The Frog's +1 climb makes every one of its climbs land on a safe ledge, so the Frog never meets the grip bar. Default if you say yes: the +1 applies to Climb cards only, not to attacks that climb (Tongue Snap, Pounce). This changes a balance number, so it is yours. Source: [[2026-09-28-jackal-fight-analysis]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3dgrip%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#Let the Frog hang?|details]]
      Ask: Grip is off: no countdown, nobody slips. Does climbing feel right without it?
      Test: state=3dgrip beast=cinder_jackal
      ![[agents/frames/builder/2026-09-29-grip-off-after.png|420]] ^let-the-frog-hang
- [x] **The jackal's turn plays out on screen.**
      **Nick, 2026-09-29 17:14 ET:** re word this question it doesnt make sense
      **Session, 2026-09-29 11:05 ET:** Today the enemy turn resolves in zero seconds and the bite clip plays AFTER the damage number. On End Turn: a 0.4 s hold, the intent badge pulses, the existing `attack` clip plays, the damage and popup land on the bite frame (frame 16 of 40), then the new hand. Same for the sweep, with the shake and both hunters hopping down. No new clips. Done-when: a four-frame strip across one enemy turn shows wind-up, bite, number, new hand in that order. Source: [[2026-09-28-jackal-fight-analysis]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal%20endturn%3D1) · [[BUILDER-QUEUE-NOTES#The jackal's turn plays out on screen.|details]]
      Ask: Grader failed this: wind-up unseen in stills. Press End Turn: jackal lunges, then damage?
      Test: state=3d beast=cinder_jackal endturn=1
      ![[agents/frames/builder/2026-09-29-jackal-turn-reads-after.png|420]] ^the-jackal-s-turn-plays-out-on-screen
- [x] **The grip clock only runs on your own time.**
      **Nick, 2026-09-29 17:14 ET:** remove grip timer for now
      **Session, 2026-09-29 11:05 ET:** The 5 s grip starts at the snapshot and keeps draining through hop animations, the timing mini-game, the other hunter's turn and the enemy turn. Pause it whenever the hanging hunter is not the one being held, or a hop tween or timing window is open. Do not change the 5 seconds. Done-when: the grip bar reads the same value before and after the other hunter's whole turn, and a test pins the pause rule. Source: [[2026-09-28-jackal-fight-analysis]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3dgrip%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#The grip clock only runs on your own time.|details]]
      Ask: Grip timer is gone: no HOLD ON bar, nobody slips. Tick to close?
      Test: state=3dgrip beast=cinder_jackal
      ![[agents/frames/builder/2026-09-29-grip-timer-removed-after.png|420]] ^the-grip-clock-only-runs-on-your-own-tim
- [x] **Timing notes open at the hold on the beast.**
      **Nick, 2026-09-29 17:14 ET:** this question doesnt make sense. i do see timing over the cards still
      **Session, 2026-09-29 11:05 ET:** The hit-circle notes stream up from the tapped card; the code comment says they open at the hold and they do not. Open them beside the climbing hunter so the grip bar, the notes and the hunter are one place on screen. That is the double timing. Done-when: with a timed card open mid-climb, the first note is within a hunter-height of the hunter on screen. Source: [[2026-09-28-jackal-fight-analysis]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3dosu%20beast%3Dcinder_jackal%20hold%3Don) · [[BUILDER-QUEUE-NOTES#Timing notes open at the hold on the beast.|details]]
      Ask: Notes now stay above the cards and off the hunter. Still see any over cards?
      Test: state=3dosu beast=cinder_jackal hold=on
      ![[agents/frames/builder/2026-09-29-notes-off-hand-after.png|420]] ^timing-notes-open-at-the-hold-on-the-bea
- [x] **A missed timed card: keep the card?**
      **Nick, 2026-09-29 12:14 ET:** i dont like the idea of losing a card. a miss play can do a plain value of the card, but hitting the timed can have a small bonus
      **Session, 2026-09-29 11:05 ET:** Today a miss deletes the card for the whole fight with no effect. Default if you say yes: a miss plays the card's printed value with no bonus and it discards like any other card. This changes a balance number, so it is yours. Source: [[2026-09-28-jackal-fight-analysis]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal%20hand%3Dlash_out%2Cpiston_punch%2Coverload_engine%2Cflick%20console%3Dclimb%2B5%20miss%3D1) · [[BUILDER-QUEUE-NOTES#A missed timed card: keep the card?|details]]
      Ask: A miss now plays plain value (8), a hit adds the bonus (12). Right?
      Test: state=3d beast=cinder_jackal hand=lash_out,piston_punch,overload_engine,flick console=climb+5 miss=1
      ![[agents/frames/builder/2026-09-29-miss-keeps-card-after.png|420]] ^a-missed-timed-card-keep-the-card
- [x] **Jackal HP 42 to 70?**
      **Nick, 2026-09-29 11:59 ET:** yes, but we need to adjust how the jackal deals damage. lets start thinking about any special abilities we can give it. potentially bring in a burn mechanic.
      **Session, 2026-09-29 11:05 ET:** With good timing the fight ends in under two rounds and the jackal's hurt pattern and Enrage never happen. Default if you say yes: HP 70, nothing else changes. Say a number if you want a different one. This changes a balance number, so it is yours. Source: [[2026-09-28-jackal-fight-analysis]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#Jackal HP 42 to 70?|details]]
      Ask: Jackal is 70 HP now. Burn bite proposed in Proposed; move it up?
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-09-29-jackal-hp-70-after.png|420]] ^jackal-hp-42-to-70
- [x] **Give the jackal a swipe that cares where you are?**
      **Nick, 2026-09-29 11:59 ET:** yes this sounds great. the attack can be a claw sweep attack and knocks players back that are close.
      **Session, 2026-09-29 11:05 ET:** Its only knockdown is a sweep on round 4 that hits everyone. Default if you say yes: round 4 becomes a high swipe that throws anyone at height 4 or above, so the intent badge makes you ask where you are. This changes a balance number, so it is yours. Source: [[2026-09-28-jackal-fight-analysis]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal%20endturn%3D6%20console%3Dclimb%2B5) · [[BUILDER-QUEUE-NOTES#Give the jackal a swipe that cares where you are?|details]]
      Ask: Round 4 claw sweep hits and throws only Height 4+ down to Height 2. Right?
      Test: state=3d beast=cinder_jackal endturn=6 console=climb+5
      ![[agents/frames/builder/2026-09-29-claw-sweep-after-strip.png|420]] ^give-the-jackal-a-swipe-that-cares-where
- [x] **Can't scroll on the menu.**
      **Nick, 2026-09-29 10:50 ET:** Yes the scroll bar works now
      **Nick, 2026-09-29 00:29 ET:** can't scroll on the menu ![[art/references/Pasted image 20260929001531.png|420]]
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3dsettings%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#Can't scroll on the menu.|details]]
      Ask: You said the scroll bar works now. Tick to close it?
      Test: state=3dsettings beast=cinder_jackal
      ![[agents/frames/builder/2026-09-29-settings-scroll-after.png|420]] ^can-t-scroll-on-the-menu
- [x] **Move the stones and the hunters back from the jackal.**
      **Nick, 2026-09-29 10:44 ET:** No move the stones back. they don't have to be so close to the head
      **Nick, 2026-09-28 23:44 ET:** its ok, but you can move the stones back. the last stone doesnt need to be right in front of the boss. you can move the stones and the characters back enough that if you are on the last stone you can see the chest of the beast
      **Session, 2026-09-29 10:55 ET:** split off the playtest item, where these notes had landed. What Nick wants: the whole staircase, hunters included, slides AWAY from the jackal, so that standing on the last stone you see the jackal's chest and head in front of you, not its snout in your face. The last stone does not have to touch the head. Do not raise the camera, do not move the jackal, do not change the camera distance. The 00:21 run tried two ways that hid the jackal more and reverted; the difference this time is that the top stone itself moves back (further from the beast), it is not the hunters alone.
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal%20console%3Dclimb%2B5) · [[BUILDER-QUEUE-NOTES#Move the stones and the hunters back from the jackal.|details]]
      Ask: On the last stone, do you see the jackal's head and chest now?
      Test: state=3d beast=cinder_jackal console=climb+5
      ![[agents/frames/builder/2026-09-29-stones-back-after.png|420]] ^move-the-stones-and-the-hunters-back
- [x] **The jackal dies on screen.**
      **Session, 2026-09-29 11:05 ET:** The killing blow plays `hit` and the scene cuts to the reward screen. Add a `death` clip with the same Blender script that made idle, attack and hit (`tools/blender/ai_beast.py`), a 0.6 s slow-motion on the final hit, the fall, then the cut. Done-when: a three-frame strip shows the last hit, the fall, the body down, all before the reward screen. Source: [[2026-09-28-jackal-fight-analysis]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3dreward%20beast%3Dcinder_jackal%20console%3Dclimb%2B5%20deathat%3D0.3%2C1.6%2C2.6%2C3.6) · [[BUILDER-QUEUE-NOTES#The jackal dies on screen.|details]]
      Ask: Grader failed this: slow-motion unseen in stills. Kill from top: slow hit, fall?
      Test: state=3dreward beast=cinder_jackal console=climb+5 deathat=0.3,1.6,2.6,3.6
      ![[agents/frames/builder/2026-09-29-jackal-death-after-strip.png|420]] ^the-jackal-dies-on-screen
- [x] **Playtest presses Switch.**
      **Session, 2026-09-29 11:05 ET:** The scripted playtest never switches hunters, so the co-op half of the loop has no coverage. Press Switch at least once per run and add one check: the second hunter's grip did not drain during the first hunter's turn (it depends on the grip item above). Shot: none; the proof is the playtest log showing the switch and the check passing. Source: [[2026-09-28-jackal-fight-analysis]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#Playtest presses Switch.|details]]
      Ask: Test-only, nothing to look at: the playtest now presses Switch. Tick.
      Test: state=3d beast=cinder_jackal ^playtest-presses-switch
- [x] **playtest.cmd green.**
      **Session, 2026-09-28 14:35 ET:** yes. One red check per run until none are left; do not escalate this item again until the count is zero or a check needs a taste call.
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal%20slot%3D1) · [[BUILDER-QUEUE-NOTES#playtest.cmd green.|details]]
      Ask: Goblin's own stairs hide up to half the jackal. Accept, or fan them wider?
      Test: state=3d beast=cinder_jackal slot=1
      ![[agents/frames/builder/2026-09-29-goblin-stairs-cover-jackal.png|420]] ^playtest-cmd-green
- [x] **Dev camera never survives a launch.**
      **Nick, 2026-09-28 20:44 ET:** goes back to player
      **Session, 2026-09-28 21:12 ET:** that is a yes; closed.
      **Session, 2026-09-28 20:35 ET:** you saw Dev because that ticket's Test link pressed F8 for you on launch (it was written to prove the flip). Not a conflict with your own game. Test line changed: no key press. The fix itself landed at 19:40.
      **Nick, 2026-09-28 19:59 ET:** i loaded this test now, then pressed f8 to go to player, then pressed test now again and it loaded in dev. do i need to load my own game to stop conflictions?
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Dev camera never survives a launch.|details]]
      Ask: Click Test, press F8 (Dev), close it, click Test again. Player camera now? Tick, or say.
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-09-28-dev-camera-launch-strip-after.png|420]] ^dev-camera-never-survives-a-launch
- [x] **Stones: first by the hunter, last in front of the head.**
      **Nick, 2026-09-28 18:44 ET:** this is fine. the other character does not need to be on the screen when you select one. IE goblin does not need to be on the screen while selecting the frog. --- side note the came is crashing while testing.
      **Nick, 2026-09-28 18:10 ET:** hunters are not starting in front of the stones.
      **Nick, 2026-09-28 15:44 ET:** I dont understand this question. please re word this. also the last stone for the goblin is not at the head
      **Nick, 2026-09-28 13:34 ET:** no. Stone placement like this, front and top view: two lines, one each side, big stones near the hunters, small near the beast, meeting at the beast. ![[art/references/2026-09-28-nick-stone-layout.webp|420]]
      **Nick, 2026-09-28 12:29 ET:** the pair of stones need more distance between them. then each character can land on a stone that is slightly to the right or left of the beast. you should be able to tell if the stone is in front of the character?
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Stones: first by the hunter, last in front of the head.|details]]
      Ask: The test window closed itself after 10 seconds; fixed. Does it stay open now?
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-09-28-test-window-strip-after.png|420]] ^stones-first-by-the-hunter-last-in-front
- [x] **Hops land on stones.**
      **Nick, 2026-09-28 18:44 ET:** the camera should be consistent. its zooming when you start climbing. I think its at a good distance when you start. but closes in once you start climbing. also the camera should be facing the same direction the character is facing.
      **Nick, 2026-09-28 18:02 ET:** better but not perfect. do research on camera positions and the position specifically from risk of rain 2
      **Nick, 2026-09-28 16:29 ET:** zoom the camera out more
      **Nick, 2026-09-28 15:44 ET:** camera follows more smoothly, but the placement is too close to the character
      **Nick, 2026-09-28 13:59 ET:** cannot be tested till the camera is fixed. camera is not smoothly following the character and is jumping around.
      **Nick, 2026-09-28 12:29 ET:** no the characters are still jumping in mid air
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Hops land on stones.|details]]
      Ask: Grader failed this: misread Frog's back as face. Camera steady while climbing now?
      Test: state=3d beast=cinder_jackal console=climb+5 land=2
      ![[agents/frames/builder/2026-09-28-camera-consistent-strip-after.png|420]] ^hops-land-on-stones
- [x] **Zoom out: stairs visible, beast whole.**
      **Nick, 2026-09-28 18:10 ET:** model of frog got changed when i got knocked back. ![[art/references/Pasted image 20260928180550.png|420]]
      **Nick, 2026-09-28 12:04 ET:** Close. make it more centered on the character selected. the full frame of the beast does not need to be seen in every position. the camera should not be dynamic in how its zoomed. it should be static positioned behind the character about the same range from the risk of rain 2 screenshot.
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Zoom out: stairs visible, beast whole.|details]]
      Ask: After a knockback, is the Frog its normal size and shape now?
      Test: state=3d beast=cinder_jackal console=climb+5;climb+2
      ![[agents/frames/builder/2026-09-28-frog-knockback-strip-after.png|420]] ^zoom-out-stairs-visible-beast-whole
- [x] **F8 flips the camera Player/Dev.**
      **Nick, 2026-09-28 14:14 ET:** f8 now works.
      **Session, 2026-09-28 13:52 ET:** the keyboard problem was on this PC, not in the game: a harness run I killed at 12:05 left `game/override.cfg` behind with no_focus=true, so every launch since ignored the keyboard. Removed, and dev.cmd/play.cmd now clear it. F8 itself was rebuilt at 12:52.
      **Nick, 2026-09-28 13:34 ET:** all my keyboard inputs are not being recorded in game. this could be the cause of f8 not working. please look into this.
      **Nick, 2026-09-28 12:29 ET:** f8 toggle is not working. nothing happens when i press f8
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#F8 flips the camera Player/Dev.|details]]
      Ask: You said F8 works now. Tick to close it?
      ![[agents/frames/builder/2026-09-28-f8-works-after.png|420]] ^f8-flips-the-camera-player-dev
- [x] **Rest camera pulled back to 6.**
      **Closed by the session, 2026-09-28 12:35 ET:** duplicate; Nick's camera answer lives on the Zoom out item below, which is open.
      **Nick, 2026-09-28 12:29 ET:** Close. make it more centered on the character selected. the full frame of the beast does not need to be seen in every position. the camera should not be dynamic in how its zoomed. it should be static positioned behind the character about the same range from the risk of rain 2 screenshot.
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Rest camera pulled back to 6.|details]]
      Ask: Superseded by Zoom out. Tick with it, or say if mid-climb looks wrong.
      ![[agents/frames/builder/2026-09-25-locked-camera-rest-after.png|420]]
      ![[agents/frames/builder/2026-09-25-locked-camera-climb-after.png|420]]
      ![[art/references/2026-09-25-nick-stones-and-zoom.webp|420]]
      ![[art/references/2026-09-25-nick-climb-camera-closer.webp|420]] ^rest-camera-pulled-back-to-6
- [x] **Hunters face the beast.**
      **Nick, 2026-09-28 12:29 ET:** no check the direction the faces are. the faces when at the bottom should be at the beast
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Hunters face the beast.|details]]
      Ask: Do both hunters face the jackal now? Tick, or say who is wrong.
      ![[agents/frames/builder/2026-09-28-hunters-face-beast-after.png|420]] ^hunters-face-the-beast
- [x] **Goblin: one muted trim colour.**
      **Closed by the session, 2026-09-28 12:35 ET:** Nick: "goblin looks okay at this time." That is a yes.
      **Nick, 2026-09-28 12:29 ET:** goblin looks okay at this time.
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Goblin: one muted trim colour.|details]]
      Ask: Does the Goblin read as one figure at this size? Tick, or say what still fights.
      ![[agents/frames/builder/2026-09-25-goblin-reads-after.png|420]] ^goblin-one-muted-trim-colour
- [x] **Playtest: two checks re-derived.**
      **Closed by the session, 2026-09-28 12:35 ET:** test-only work, nothing for Nick to judge; the question should never have been asked.
      **Nick, 2026-09-28 12:29 ET:** I dont understand the question here
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Playtest: two checks re-derived.|details]]
      Ask: Nothing to look at, two test checks fixed. Tick. ^playtest-two-checks-re-derived
- [x] **Weak-point shot, same frame as the sigil.**
      **Closed by the session, 2026-09-28 12:35 ET:** duplicate of the Sigil shot item; judge that one.
      **Nick, 2026-09-28 12:29 ET:** I dont understand the question here
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Weak-point shot, same frame as the sigil.|details]]
      Ask: Same frame as the sigil item. Tick both together.
      ![[agents/frames/builder/2026-09-25-sigil-face-after.png|420]] ^weak-point-shot-same-frame-as-the-sigil
- [x] **Nick judged the 2026-09-25 camera and stones**
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Nick judged the 2026-09-25 camera and stones|details]]
      ![[art/references/2026-09-25-nick-stones-and-zoom.webp|420]] ^nick-judged-the-2026-09-25-camera-and-st
- [x] **Sigil shot: face and eyes in frame.**
      **Closed by the session, 2026-09-28 13:40 ET:** superseded. Nick's camera rule (one fixed distance behind the held character, everywhere) covers the top stone; the Zoom out item rebuilds this shot. The question was jargon he should never have been asked.
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Sigil shot: face and eyes in frame.|details]]
      Ask: Is this the weak-point shot? Tick, or say closer, lower, or what else.
      ![[agents/frames/builder/2026-09-25-sigil-face-after.png|420]]
      ![[agents/frames/builder/2026-09-25-sigil-climb-after.png|420]] ^sigil-shot-face-and-eyes-in-frame
- [x] **Change the fog so it's behind the exterior.**
      **Nick, 2026-09-29 12:14 ET:** Change the fog so it's behind the exterior. I would like to be able to see the mountains (where: environment)
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#Change the fog so it's behind the exterior.|details]]
      Ask: The lava-lit mountains are clear now; haze only in the sky. Right?
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-09-29-fog-behind-after.png|420]] ^change-the-fog-so-it-s-behind-the-exteri
- [x] **More free unrestriced camera movement at higher speed.**
      **Nick, 2026-09-29 21:14 ET:** more free unrestriced camera movement at higher speed. cant zoom in more past picture. (where: in dev movde) ![[art/references/Pasted image 20260929210409.png|420]]
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal%20console%3Dclimb%2B5%20devzoom%3D16%20devorbit%3D-35) · [[BUILDER-QUEUE-NOTES#More free unrestriced camera movement at higher speed.|details]]
      Ask: Grader failed this: stills can't show speed. Try Dev: wheel in, WASD, Shift. Good?
      Test: state=3d beast=cinder_jackal console=climb+5 devzoom=16 devorbit=-35
      ![[agents/frames/builder/2026-09-30-devcam-free-after.png|420]] ^more-free-unrestriced-camera-movement-at
- [x] **The climb zigzags side to side.**
      **Session, 2026-09-29 22:35 ET:** `route_pos` puts all five stones on one straight line, so a climb reads as a staircase. Alternate the rungs LEFT and RIGHT of that line by about one hunter height, ledges on the outer edges, so each hop is a diagonal traverse across the flank. Keep the even hop length and both endpoints (ground gap and sigil, #14). The hunter turns to face the stone it hops to. Done-when: from the resting camera the stones form a zigzag, each on the opposite side of the last, and a test pins alternation plus even hop length. Source: [[2026-09-29-intense-fight-plan]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#The climb zigzags side to side.|details]]
      Ask: Grader failed this: zigzag faint from rest camera. Stones zigzag enough for you?
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-09-30-zigzag-rest-after.png|420]] ^the-climb-zigzags-side-to-side
- [x] **The beast's health bar reacts.**
      **Session, 2026-09-29 22:35 ET:** The beast bar is a plain progress bar. Give it notch marks at each weak-point threshold, a pale ghost segment that lingers 0.4 s after damage and drains, and a crack flash when a threshold is crossed. Done-when: a strike frame shows the ghost segment behind the new value. Source: [[2026-09-29-intense-fight-plan]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3dstrike%20beast%3Dcinder_jackal%20beat%3Dloop) · [[BUILDER-QUEUE-NOTES#The beast's health bar reacts.|details]]
      Ask: Notches every 16 HP, ember line at the hurt pattern. Readable at a glance?
      Test: state=3dstrike beast=cinder_jackal beat=loop
      ![[agents/frames/builder/2026-09-30-beast-bar-after.png|420]] ^the-beast-s-health-bar-reacts
- [x] **The climb gauge stands beside the beast.**
      **Session, 2026-09-29 22:35 ET:** The right-rail ladder is a thin line with ticks. Make it a gauge beside the stage: a portrait pip per hunter at their height, glowing notches at the ledges, the sigil burning at the top, in the obsidian style. Done-when: the climb frame shows both pips at their heights and the sigil glow at the top. Source: [[2026-09-29-intense-fight-plan]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3dclimb%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#The climb gauge stands beside the beast.|details]]
      Ask: Gauge has faces and a burning sigil now. Pips big enough to read?
      Test: state=3dclimb beast=cinder_jackal
      ![[agents/frames/builder/2026-09-30-climb-gauge-after.png|420]] ^the-climb-gauge-stands-beside-the-beast
- [x] **Lava rock under the hunters.**
      **Session, 2026-09-29 22:35 ET:** The climb stones and the hunters' standing slabs are tan boxes. Make them dark basalt with an ember glow at the underside and edges, scoped to the jackal fight. Done-when: the climb frame shows dark stones with orange edge glow under both hunters. Source: [[2026-09-29-intense-fight-plan]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3dclimb%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#Lava rock under the hunters.|details]]
      Ask: Grader failed this: Goblin's stone off-frame. Stones read as lava rock to you?
      Test: state=3dclimb beast=cinder_jackal
      ![[agents/frames/builder/2026-09-30-lava-rock-after.png|420]] ^lava-rock-under-the-hunters
- [x] **Lava flows around the arena.**
      **Session, 2026-09-29 22:35 ET:** Add a lava ring between the floor and the wall: an emissive scrolling shader with noise, slow flow, orange omni lights along it, heat shimmer above it. It must not reach the hunters' slabs. Done-when: the rest frame shows glowing lava between the floor edge and the wall, lighting the floor orange at the rim. Source: [[2026-09-29-intense-fight-plan]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#Lava flows around the arena.|details]]
      Ask: Grader failed this: rim floor not visibly orange. Does the lava ring read?
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-09-30-lava-ring-after.png|420]] ^lava-flows-around-the-arena


- [x] **Cards and HUD in the style of picture B.**
      **Nick, 2026-10-04 15:38 ET:** go with A, but the card and ui from b
      Target: ![[art/targets/TARGET-UI.png|420]]
      Work toward `design/art/targets/TARGET-UI.png`. Cards: one ornate gold frame on every card, a glowing edge on the cards that can be played, and card art in one painted style (repaint the faces that are pictograms or 3D renders). HUD: the jackal's name and health on a carved stone plate, the energy counter and End Turn as gold-framed pieces like the picture. Keep everything the picture dropped: the climb gauge, Switch, Log, Menu, the pile counts, the Attack intent and the cost gems. No bought packs; generate or build the art.
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#Cards and HUD in the style of picture B.|details]]
      Ask: Grader failed this: card art not repainted. Generate painted faces next?
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-10-04-card-hud-after.png|420]] ^cards-and-hud-in-the-style-of-picture-b

- [ ] 👀 **Scene pass 2 toward picture A: grey stone steps, frog on a lit rock.**
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#Scene pass 2 toward picture A: grey stone steps, frog on a lit rock.|details]]
      Ask: Grader failed this: stones still ring the head. End the climb at the chest?
      Checked 2026-10-04 against `design/art/targets/TARGET.png`. Pass 1 got the jackal tall, lit and outlined. Still far from the picture, in `state=3d`: (1) the stones are red-black crates scattered round the head, one over the face; the picture has pale grey flat slabs in one clear line from the hunter up to the chest, and the face stays visible. (2) The frog is flat-lit in front of a black box; the picture has it on a raised rock with a shadow under it and the same warm outline as the beast. (3) The jackal's outline is a thin line; the picture's is thick and glowing. Do not touch the jackal's model or pose: that is Nick's call.
      Target: ![[art/targets/TARGET.png|420]] Now: ![[agents/frames/builder/2026-10-04-scene-pass1-after.png|420]]
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-10-04-scene-pass2-after.png|420]] ^scene-pass-2-toward-picture-a
- [ ] 👀 **Clean shapes: flat planes, a smooth glowing outline.**
      **Nick, 2026-10-04 20:30 ET:** the outlines are really buggy to begin with
      **Nick, 2026-10-04 20:20 ET:** why does this look so different from the reference?
      The outline first. It is an inverted hull pushed out along the normals (`game/assets/3d/outline.gdshader`); on a hard-edged faceted mesh the hull splits at every facet edge, which is the broken, blobby, stair-stepped line round the jackal and the Frog. Fix the cause: push the hull along smoothed normals (weld them or bake them into a spare vertex channel), or replace it with a screen-space edge pass; and turn MSAA on for the 3D view. The jackal keeps a warm outline; the Frog gets a thin dark one, not a yellow halo.
      The jackal's surface is a noisy dark-red texture and the outlines on the jackal and the Frog are jagged, pale and stair-stepped. The picture has flat colour planes (dark brown rock, bright orange cracks), a thick smooth warm outline, and the cracks and eyes glow into the air around them. Done when, at 1:1, no outline shows stair-steps, the rock reads as flat planes, and the cracks and eyes bloom.
      Target: ![[art/targets/TARGET.png|420]] Now: ![[agents/frames/builder/2026-10-04-jackal-v2-after.png|420]]
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#Clean shapes: flat planes, a smooth glowing outline.|details]]
      Ask: Grader failed this: eyes don't read at fight distance. Brighter eyes next?
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-10-04-clean-shapes-after.png|420]] ^clean-shapes-flat-planes-a-smooth-glowing-outline
- [ ] 👀 **The jackal fills the frame like picture A.**
      **Nick, 2026-10-04 20:20 ET:** why does this look so different from the reference?
      In `state=3d` the jackal covers about a sixth of the frame's width; in `design/art/targets/TARGET.png` it covers over half. The beast is sized by height (`_fit_height`), and an upright body sized that way is narrow and far off. Done when, at rest, its shoulders span at least 45% of the frame's width, its head and eyes are inside the frame, and it reads as towering over the hunter. Scale it, bring it nearer or tilt the rest camera up; do not crop the model. Move the sigil ring off the eyes.
      Target: ![[art/targets/TARGET.png|420]] Now: ![[agents/frames/builder/2026-10-04-jackal-v2-after.png|420]]
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#The jackal fills the frame like picture A.|details]]
      Ask: Not built: 45% width can't fit head and Frog. Hide its legs below the floor?
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-10-04-jackal-fills-before.png|420]] ![[agents/frames/builder/2026-10-04-jackal-fills-option-sunk.png|420]] ^the-jackal-fills-the-frame-like-picture-a
- [ ] 👀 **The jackal idles and punches.**
      **Nick, 2026-10-04 20:30 ET:** yes rig the jackal and add the animations
      The jackal now has a skeleton (24 bones) and two clips, all in `game/assets/3d/cast/`: `cinder_jackal_v2_rigged.glb` (the skinned model), `cinder_jackal_v2_idle.glb` (clip `Idle`, 97 frames at 24 fps, loop it) and `cinder_jackal_v2_punch.glb` (clip `Punch_Combo`, 60 frames). Each file carries the same mesh; use the rigged one in the fight and take only the animation from the other two. Run `--import` first. Done when: at rest the jackal plays Idle on a loop; when it attacks it plays Punch_Combo once, the damage lands on the hit, and it returns to Idle; the toon material, the glow and the outline still apply to the skinned mesh; the holds and the stone route still sit on the body. Prove it with two `state=3d` frames a second apart that differ in the jackal's pose, and one frame mid-punch.
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#The jackal idles and punches.|details]]
      Ask: Idle bows the head, hiding the eyes. Hold the head up too?
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-10-05-jackal-idle-after-grid.png|420]] ^the-jackal-idles-and-punches
- [ ] 👀 **Stones are one staircase of chunky blocks.**
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#Stones are one staircase of chunky blocks.|details]]
      Ask: The climb now tops out at the chest, not the head. Keep that?
      **Nick, 2026-10-04 20:20 ET:** why does this look so different from the reference?
      Today thin grey discs float in a ring round the jackal. The picture has thick grey blocks, each about as tall as the Frog, in ONE rising line from the Frog's rock to the jackal's chest, biggest nearest the camera. Done when a player can trace the climb with a finger from the Frog to the chest in `state=3d`, and no stone floats beside or behind the beast.
      Target: ![[art/targets/TARGET.png|420]] Now: ![[agents/frames/builder/2026-10-04-jackal-v2-after.png|420]]
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-10-05-stone-staircase-after.png|420]] ^stones-are-one-staircase-of-chunky-blocks
- [ ] 👀 **Cliffs and floor in picture A's flat style.**
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#Cliffs and floor in picture A's flat style.|details]]
      Ask: Flatten the cobbled stones and hunter rocks the same way next?
      **Nick, 2026-10-04 20:20 ET:** why does this look so different from the reference?
      The cliffs are detailed realistic rock and the floor is a flat dark sheet with thin lines; beside the flat jackal they look like a different game. The picture has dark angular cliffs in two or three flat tones and a floor of big cracked slabs with glowing seams. Done when the cliffs, the floor, the jackal and the Frog read as one style in `state=3d`.
      Target: ![[art/targets/TARGET.png|420]] Now: ![[agents/frames/builder/2026-10-04-jackal-v2-after.png|420]]
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-10-05-cliffs-floor-after.png|420]] ^cliffs-and-floor-in-picture-a-s-flat-style
- [ ] 👀 **Overnight: keep closing the gap to picture A until 8 AM.**
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#Overnight: keep closing the gap to picture A until 8 AM.|details]]
      Ask: Biggest gap left is beast size: bring the jackal closer so it fills the frame?
      **Nick, 2026-10-04 20:30 ET:** i want the builder to do passes over night until it gets it as close to the reference as possible. the outlines are really buggy to begin with
      A standing item (see "Standing items" in the brief). Each run is ONE pass: shoot `state=3d beast=cinder_jackal`; give the grader that frame and `design/art/targets/TARGET.png`; take the biggest difference it names that code can fix; fix that one thing; reshoot; the grader says CLOSER or NOT CLOSER. NOT CLOSER: revert the change and do not push it. Add one line per pass to this item's entry in [[BUILDER-QUEUE-NOTES]]: time, what changed, CLOSER or NOT CLOSER, the after frame. Leave this item `- [ ]`.
      Do not change: the rules or any number, the HUD layout, the cards, the camera sitting behind the hunter, the jackal's model. Skip differences that need new art (card faces, a new pose): list them in the notes instead. Tests stay green on every pass.
      Stop and mark it `👀` when the clock passes 08:00 ET on 2026-10-05, or when three passes in a row were NOT CLOSER. Then embed the first before frame and the last after frame side by side here, and ask Nick about the one biggest thing still different.
      Target: ![[art/targets/TARGET.png|420]]
      Test: state=3d beast=cinder_jackal
      ![[agents/frames/builder/2026-10-05-overnight-p1-before.png|420]] ![[agents/frames/builder/2026-10-05-overnight-p20-after.png|420]] ^overnight-keep-closing-the-gap-to-picture-a

### Old open-decision defaults (void since 2026-10-07)

- #14 stones: five per hunter, as built.
- #19 gap vs lens: keep the gap, narrow the lens until the beast fills the
  upper two-thirds.
- #23 boulder shape: plain rounded boulders, no flat top, no orange rim.
- #27 weak-point shot: locked behind the active hunter, beast untouched.
- Zigzag width: about one hunter height each side of the old line.
- Lava: a ring at the arena's edge, not rivers across the floor.
- HUD palette: black glass, ember-orange rim, gold for energy and the sigil.
- [ ] (proposed) **Left cliffs a shade lighter and bluer than TARGET.** Grader: TARGET's are charcoal planes, ours busier blue-grey spires.
