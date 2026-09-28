# Builder queue

One ordered list. The builder (`tools/builder/BRIEF.md`) does the **top
unticked item** and nothing else. Nick reorders, adds, deletes, and ticks.

- `[ ]` open · `[ ] 👀` built, waiting for Nick to look · `[x]` Nick says done

Every item names the shot that must change. If the shot does not change, the
run failed.

## Now — the Cinder Jackal fight

- [ ] 👀 **F8 flips the camera Player/Dev.** ^f8-flips-the-camera-player-dev
      **Nick, 2026-09-28 14:14 ET:** f8 now works.
      **Session, 2026-09-28 13:52 ET:** the keyboard problem was on this PC, not in the game: a harness run I killed at 12:05 left `game/override.cfg` behind with no_focus=true, so every launch since ignored the keyboard. Removed, and dev.cmd/play.cmd now clear it. F8 itself was rebuilt at 12:52.
      **Nick, 2026-09-28 13:34 ET:** all my keyboard inputs are not being recorded in game. this could be the cause of f8 not working. please look into this.
      **Nick, 2026-09-28 12:29 ET:** f8 toggle is not working. nothing happens when i press f8
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#F8 flips the camera Player/Dev.|details]]
      Ask: You said F8 works now. Tick to close it?
      ![[agents/frames/builder/2026-09-28-f8-works-after.png|420]]
- [ ] 👀 **Hops land on stones.** ^hops-land-on-stones
      **Nick, 2026-09-28 13:59 ET:** cannot be tested till the camera is fixed. camera is not smoothly following the character and is jumping around.
      **Nick, 2026-09-28 12:29 ET:** no the characters are still jumping in mid air
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Hops land on stones.|details]]
      Ask: Grader failed this: intent badge over the Frog; mid-hop panel "floats". Camera now follows smoothly?
      ![[agents/frames/builder/2026-09-28-camera-follows-hop-after.png|420]]
- [ ] 👀 **Stones: first by the hunter, last in front of the head.** ^stones-first-by-the-hunter-last-in-front
      **Nick, 2026-09-28 13:34 ET:** no. Stone placement like this, front and top view: two lines, one each side, big stones near the hunters, small near the beast, meeting at the beast. ![[art/references/2026-09-28-nick-stone-layout.webp|420]]
      **Nick, 2026-09-28 12:29 ET:** the pair of stones need more distance between them. then each character can land on a stone that is slightly to the right or left of the beast. you should be able to tell if the stone is in front of the character?
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Stones: first by the hunter, last in front of the head.|details]]
      Ask: Grader failed this: Goblin's big stone hides under the gauge. Spread hunters wider?
      ![[agents/frames/builder/2026-09-28-stone-lines-wide-after.png|420]]
      ![[agents/frames/builder/2026-09-28-stone-lines-after.png|420]]
- [x] **Rest camera pulled back to 6.** ^rest-camera-pulled-back-to-6
      **Closed by the session, 2026-09-28 12:35 ET:** duplicate; Nick's camera answer lives on the Zoom out item below, which is open.
      **Nick, 2026-09-28 12:29 ET:** Close. make it more centered on the character selected. the full frame of the beast does not need to be seen in every position. the camera should not be dynamic in how its zoomed. it should be static positioned behind the character about the same range from the risk of rain 2 screenshot.
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Rest camera pulled back to 6.|details]]
      Ask: Superseded by Zoom out. Tick with it, or say if mid-climb looks wrong.
      ![[agents/frames/builder/2026-09-25-locked-camera-rest-after.png|420]]
      ![[agents/frames/builder/2026-09-25-locked-camera-climb-after.png|420]]
      ![[art/references/2026-09-25-nick-stones-and-zoom.webp|420]]
      ![[art/references/2026-09-25-nick-climb-camera-closer.webp|420]]
- [ ] 👀 **Hunters face the beast.** ^hunters-face-the-beast
      **Nick, 2026-09-28 12:29 ET:** no check the direction the faces are. the faces when at the bottom should be at the beast
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Hunters face the beast.|details]]
      Ask: Do both hunters face the jackal now? Tick, or say who is wrong.
      ![[agents/frames/builder/2026-09-28-hunters-face-beast-after.png|420]]
- [x] **Goblin: one muted trim colour.** ^goblin-one-muted-trim-colour
      **Closed by the session, 2026-09-28 12:35 ET:** Nick: "goblin looks okay at this time." That is a yes.
      **Nick, 2026-09-28 12:29 ET:** goblin looks okay at this time.
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Goblin: one muted trim colour.|details]]
      Ask: Does the Goblin read as one figure at this size? Tick, or say what still fights.
      ![[agents/frames/builder/2026-09-25-goblin-reads-after.png|420]]
- [x] **Playtest: two checks re-derived.** ^playtest-two-checks-re-derived
      **Closed by the session, 2026-09-28 12:35 ET:** test-only work, nothing for Nick to judge; the question should never have been asked.
      **Nick, 2026-09-28 12:29 ET:** I dont understand the question here
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Playtest: two checks re-derived.|details]]
      Ask: Nothing to look at, two test checks fixed. Tick.
- [x] **Weak-point shot, same frame as the sigil.** ^weak-point-shot-same-frame-as-the-sigil
      **Closed by the session, 2026-09-28 12:35 ET:** duplicate of the Sigil shot item; judge that one.
      **Nick, 2026-09-28 12:29 ET:** I dont understand the question here
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Weak-point shot, same frame as the sigil.|details]]
      Ask: Same frame as the sigil item. Tick both together.
      ![[agents/frames/builder/2026-09-25-sigil-face-after.png|420]]
- [ ] **Zoom out: stairs visible, beast whole.** ^zoom-out-stairs-visible-beast-whole
      **Nick, 2026-09-28 12:04 ET:** Close. make it more centered on the character selected. the full frame of the beast does not need to be seen in every position. the camera should not be dynamic in how its zoomed. it should be static positioned behind the character about the same range from the risk of rain 2 screenshot.
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Zoom out: stairs visible, beast whole.|details]]
      Ask: Is this the camera range? Tick, or say closer or further.
      ![[agents/frames/builder/2026-09-28-camera-behind-after.png|420]]
      ![[agents/frames/builder/2026-09-28-camera-behind-climb-after.png|420]]
- [x] **Nick judged the 2026-09-25 camera and stones** ^nick-judged-the-2026-09-25-camera-and-st
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Nick judged the 2026-09-25 camera and stones|details]]
      ![[art/references/2026-09-25-nick-stones-and-zoom.webp|420]]
- [x] **Sigil shot: face and eyes in frame.** ^sigil-shot-face-and-eyes-in-frame
      **Closed by the session, 2026-09-28 13:40 ET:** superseded. Nick's camera rule (one fixed distance behind the held character, everywhere) covers the top stone; the Zoom out item rebuilds this shot. The question was jargon he should never have been asked.
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#Sigil shot: face and eyes in frame.|details]]
      Ask: Is this the weak-point shot? Tick, or say closer, lower, or what else.
      ![[agents/frames/builder/2026-09-25-sigil-face-after.png|420]]
      ![[agents/frames/builder/2026-09-25-sigil-climb-after.png|420]]

- [ ] **playtest.cmd green.** ^playtest-cmd-green
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#playtest.cmd green.|details]]

## Waiting on Nick

The builder skips this section. Answer here or in Home; the item then moves
into Now.

## Open decisions, with the default the builder takes if Nick says nothing

- #14 stones: five per hunter, as built.
- #19 gap vs lens: keep the gap, narrow the lens until the beast fills the
  upper two-thirds.
- #23 boulder shape: plain rounded boulders, no flat top, no orange rim.
- #27 weak-point shot: locked behind the active hunter, beast untouched.

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
