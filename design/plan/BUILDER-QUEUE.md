# Builder queue

One ordered list. The builder (`tools/builder/BRIEF.md`) does the **top
unticked item** and nothing else. Nick reorders, adds, deletes, and ticks.

- `[ ]` open · `[ ] 👀` built, waiting for Nick to look · `[x]` Nick says done

Every item names the shot that must change. If the shot does not change, the
run failed.

## Now — the Cinder Jackal fight

- [ ] **A missed timed card: keep the card?**
      **Nick, 2026-09-29 12:14 ET:** i dont like the idea of losing a card. a miss play can do a plain value of the card, but hitting the timed can have a small bonus
      **Session, 2026-09-29 11:05 ET:** Today a miss deletes the card for the whole fight with no effect. Default if you say yes: a miss plays the card's printed value with no bonus and it discards like any other card. This changes a balance number, so it is yours. Source: [[2026-09-28-jackal-fight-analysis]].
      Ask: A miss deletes the card for the whole fight. Yes = a miss plays the card's plain value and you keep the card. No = leave it. ^a-missed-timed-card-keep-the-card
- [ ] 👀 **One tap for ordinary timed cards?**
      **Nick, 2026-09-29 11:59 ET:** make it more complex dependent on how much the card cost. add a mechanic of click and drag. also add variety of where the clicks are, but don't have them far from the card.
      **Session, 2026-09-29 11:05 ET:** Today every timed card needs three taps and one bad tap loses it. Default if you say yes: three taps only for cards that print more than one window (Satchel Charge); everything else is one tap. This changes a balance number, so it is yours. Source: [[2026-09-28-jackal-fight-analysis]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal%20hand%3Dflick%2Clash_out%2Cpiston_punch%2Coverload_engine) · [[BUILDER-QUEUE-NOTES#One tap for ordinary timed cards?|details]]
      Ask: Cost 0: 1 tap, 1: 2 taps, 2: 2 + drag, 3: 3 + drag. Right?
      Test: state=3d beast=cinder_jackal hand=flick,lash_out,piston_punch,overload_engine
      ![[agents/frames/builder/2026-09-29-cost-timing-after.png|420]] ^one-tap-for-ordinary-timed-cards
- [ ] **Jackal HP 42 to 70?**
      **Nick, 2026-09-29 11:59 ET:** yes, but we need to adjust how the jackal deals damage. lets start thinking about any special abilities we can give it. potentially bring in a burn mechanic.
      **Session, 2026-09-29 11:05 ET:** With good timing the fight ends in under two rounds and the jackal's hurt pattern and Enrage never happen. Default if you say yes: HP 70, nothing else changes. Say a number if you want a different one. This changes a balance number, so it is yours. Source: [[2026-09-28-jackal-fight-analysis]].
      Ask: The fight ends in under 2 rounds. Yes = jackal HP 70 so its later moves happen. Or give a number. ^jackal-hp-42-to-70
- [ ] **Let the Frog hang?**
      **Nick, 2026-09-29 11:59 ET:** i don't understand this question please re word it.
      **Session, 2026-09-29 11:05 ET:** The Frog's +1 climb makes every one of its climbs land on a safe ledge, so the Frog never meets the grip bar. Default if you say yes: the +1 applies to Climb cards only, not to attacks that climb (Tongue Snap, Pounce). This changes a balance number, so it is yours. Source: [[2026-09-28-jackal-fight-analysis]].
      Ask: The Frog never meets the grip bar. Yes = its attacks that climb can land it on a hanging height. No = leave it. ^let-the-frog-hang
- [ ] **Give the jackal a swipe that cares where you are?**
      **Nick, 2026-09-29 11:59 ET:** yes this sounds great. the attack can be a claw sweep attack and knocks players back that are close.
      **Session, 2026-09-29 11:05 ET:** Its only knockdown is a sweep on round 4 that hits everyone. Default if you say yes: round 4 becomes a high swipe that throws anyone at height 4 or above, so the intent badge makes you ask where you are. This changes a balance number, so it is yours. Source: [[2026-09-28-jackal-fight-analysis]].
      Ask: Yes = round 4 becomes a high swipe that throws anyone at height 4 or above. No = keep the sweep that hits everyone. ^give-the-jackal-a-swipe-that-cares-where
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
- [ ] **The jackal's turn plays out on screen.**
      **Session, 2026-09-29 11:05 ET:** Today the enemy turn resolves in zero seconds and the bite clip plays AFTER the damage number. On End Turn: a 0.4 s hold, the intent badge pulses, the existing `attack` clip plays, the damage and popup land on the bite frame (frame 16 of 40), then the new hand. Same for the sweep, with the shake and both hunters hopping down. No new clips. Done-when: a four-frame strip across one enemy turn shows wind-up, bite, number, new hand in that order. Source: [[2026-09-28-jackal-fight-analysis]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal%20endturn%3D1) · [[BUILDER-QUEUE-NOTES#The jackal's turn plays out on screen.|details]]
      Test: state=3d beast=cinder_jackal endturn=1 ^the-jackal-s-turn-plays-out-on-screen
- [ ] **The grip clock only runs on your own time.**
      **Session, 2026-09-29 11:05 ET:** The 5 s grip starts at the snapshot and keeps draining through hop animations, the timing mini-game, the other hunter's turn and the enemy turn. Pause it whenever the hanging hunter is not the one being held, or a hop tween or timing window is open. Do not change the 5 seconds. Done-when: the grip bar reads the same value before and after the other hunter's whole turn, and a test pins the pause rule. Source: [[2026-09-28-jackal-fight-analysis]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3dgrip%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#The grip clock only runs on your own time.|details]]
      Test: state=3dgrip beast=cinder_jackal ^the-grip-clock-only-runs-on-your-own-tim
- [ ] **Timing notes open at the hold on the beast.**
      **Session, 2026-09-29 11:05 ET:** The hit-circle notes stream up from the tapped card; the code comment says they open at the hold and they do not. Open them beside the climbing hunter so the grip bar, the notes and the hunter are one place on screen. That is the double timing. Done-when: with a timed card open mid-climb, the first note is within a hunter-height of the hunter on screen. Source: [[2026-09-28-jackal-fight-analysis]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3dclimb%20beast%3Dcinder_jackal%20slot%3D1) · [[BUILDER-QUEUE-NOTES#Timing notes open at the hold on the beast.|details]]
      Test: state=3dclimb beast=cinder_jackal slot=1 ^timing-notes-open-at-the-hold-on-the-bea
- [ ] **Hunters lunge when they attack and flinch when hit.**
      **Session, 2026-09-29 11:05 ET:** The Frog and Goblin have no rig; `_hunter_play` for attack and hit does nothing. Build both as tweens like the hop already is: attack = a 0.15 s lunge toward the beast with a scale punch, only on the hunter that played the card; hit = a white flash and a 0.2 s knock-back with a lean. Done-when: a strike frame shows the lunge, a hit frame shows the flinch, and the other hunter does not move. Source: [[2026-09-28-jackal-fight-analysis]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3dstrike%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#Hunters lunge when they attack and flinch when hit.|details]]
      Test: state=3dstrike beast=cinder_jackal ^hunters-lunge-when-they-attack-and-flinc
- [ ] **Played cards fly to their target.**
      **Session, 2026-09-29 11:05 ET:** A played card pops out of the hand. Make it scale up and fly to the beast for an attack, to the hunter for block or climb, before its effect resolves, about 0.25 s. Block pops a ring on the hunter and plays the `block` sound that exists and is never played. Done-when: a mid-flight frame shows the card between the hand and its target. Source: [[2026-09-28-jackal-fight-analysis]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#Played cards fly to their target.|details]]
      Test: state=3d beast=cinder_jackal ^played-cards-fly-to-their-target
- [ ] **The jackal dies on screen.**
      **Session, 2026-09-29 11:05 ET:** The killing blow plays `hit` and the scene cuts to the reward screen. Add a `death` clip with the same Blender script that made idle, attack and hit (`tools/blender/ai_beast.py`), a 0.6 s slow-motion on the final hit, the fall, then the cut. Done-when: a three-frame strip shows the last hit, the fall, the body down, all before the reward screen. Source: [[2026-09-28-jackal-fight-analysis]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3dreward%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#The jackal dies on screen.|details]]
      Test: state=3dreward beast=cinder_jackal ^the-jackal-dies-on-screen
- [ ] **Playtest presses Switch.**
      **Session, 2026-09-29 11:05 ET:** The scripted playtest never switches hunters, so the co-op half of the loop has no coverage. Press Switch at least once per run and add one check: the second hunter's grip did not drain during the first hunter's turn (it depends on the grip item above). Shot: none; the proof is the playtest log showing the switch and the check passing. Source: [[2026-09-28-jackal-fight-analysis]].
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal) · [[BUILDER-QUEUE-NOTES#Playtest presses Switch.|details]]
      Test: state=3d beast=cinder_jackal ^playtest-presses-switch
- [ ] **playtest.cmd green.**
      **Session, 2026-09-28 14:35 ET:** yes. One red check per run until none are left; do not escalate this item again until the count is zero or a check needs a taste call.
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal) · [[BUILDER-QUEUE-NOTES#playtest.cmd green.|details]]
      Shot: none; the proof is `playtest` printing no FAIL. ^playtest-cmd-green
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
- [ ] **Make the Jackal be less glossy and more matte.**
      **Nick, 2026-09-29 12:14 ET:** Make the Jackal be less glossy and more matte (where: jackal) ![[art/references/Pasted image 20260929121120.png|420]]
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d) · [[BUILDER-QUEUE-NOTES#Make the Jackal be less glossy and more matte.|details]]
      Test: state=3d ^make-the-jackal-be-less-glossy-and-more-
- [ ] **Change the fog so it's behind the exterior.**
      **Nick, 2026-09-29 12:14 ET:** Change the fog so it's behind the exterior. I would like to be able to see the mountains (where: environment)
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d) · [[BUILDER-QUEUE-NOTES#Change the fog so it's behind the exterior.|details]]
      Test: state=3d ^change-the-fog-so-it-s-behind-the-exteri


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
