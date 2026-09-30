# Builder queue

One ordered list. The builder (`tools/builder/BRIEF.md`) does the **top
unticked item** and nothing else. Nick reorders, adds, deletes, and ticks.

- `[ ]` open · `[ ] 👀` built, waiting for Nick to look · `[x]` Nick says done

Every item names the shot that must change. If the shot does not change, the
run failed.

## Now — the Cinder Jackal fight

- [ ] **Hunters lunge when they attack and flinch when hit.**
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
- [ ] 👀 **More free unrestriced camera movement at higher speed.**
      **Nick, 2026-09-29 21:14 ET:** more free unrestriced camera movement at higher speed. cant zoom in more past picture. (where: in dev movde) ![[art/references/Pasted image 20260929210409.png|420]]
      ▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario=state%3D3d%20beast%3Dcinder_jackal%20console%3Dclimb%2B5%20devzoom%3D16%20devorbit%3D-35) · [[BUILDER-QUEUE-NOTES#More free unrestriced camera movement at higher speed.|details]]
      Ask: Grader failed this: stills can't show speed. Try Dev: wheel in, WASD, Shift. Good?
      Test: state=3d beast=cinder_jackal console=climb+5 devzoom=16 devorbit=-35
      ![[agents/frames/builder/2026-09-30-devcam-free-after.png|420]] ^more-free-unrestriced-camera-movement-at
- [ ] **The climb zigzags side to side.**
      **Session, 2026-09-29 22:35 ET:** `route_pos` puts all five stones on one straight line, so a climb reads as a staircase. Alternate the rungs LEFT and RIGHT of that line by about one hunter height, ledges on the outer edges, so each hop is a diagonal traverse across the flank. Keep the even hop length and both endpoints (ground gap and sigil, #14). The hunter turns to face the stone it hops to. Done-when: from the resting camera the stones form a zigzag, each on the opposite side of the last, and a test pins alternation plus even hop length. Source: [[2026-09-29-intense-fight-plan]].
      Test: state=3dclimb beast=cinder_jackal ^the-climb-zigzags-side-to-side
- [ ] **The camera swings with each hop.**
      **Session, 2026-09-29 22:35 ET:** With the zigzag, a hop moves the hunter sideways. Pan the locked camera across with the hunter over the hop and settle with a small overshoot (about 0.15 s), so the traverse is felt. Done-when: a two-frame strip, before and after one hop, shows the camera's x differs and the hunter is centred in both. Source: [[2026-09-29-intense-fight-plan]].
      Test: state=3dclimb beast=cinder_jackal console=climb+3 ^the-camera-swings-with-each-hop
- [ ] **Hits stop time.**
      **Session, 2026-09-29 22:35 ET:** A landed strike freezes the frame for 0.08 s, shakes the camera in proportion to damage, and bursts embers from the impact point; a weak-point hit adds 0.15 s of slow motion. The jackal's bite gets the same hit-stop on the hunter. Done-when: the strike frame shows the ember burst at the impact point and a frame 0.1 s later shows the camera offset. Source: [[2026-09-29-intense-fight-plan]].
      Test: state=3dstrike beast=cinder_jackal beat=loop ^hits-stop-time
- [ ] **The jackal threatens between turns.**
      **Session, 2026-09-29 22:35 ET:** Between turns the jackal only idles. Make its head track the active hunter, brighten the ember cracks as its turn nears, play one growl when the last hunter turn begins, and pulse the intent badge in step. Done-when: rest vs after one End Turn shows the head turned to the hunter, the cracks brighter and the badge larger. Source: [[2026-09-29-intense-fight-plan]].
      Test: state=3d beast=cinder_jackal endturn=1 ^the-jackal-threatens-between-turns
- [ ] **Low health shows on screen.**
      **Session, 2026-09-29 22:35 ET:** A hunter under 30 % HP gets a red edge vignette that pulses with a heartbeat; the jackal under 30 % streams embers, breathes faster and glows hotter. Add a console command `hp 10` (active hunter) and `hp beast 15` so the frame can be set. Done-when: a frame with the Frog at 10 HP shows the red vignette and one with the jackal at 15 HP shows the ember stream. Source: [[2026-09-29-intense-fight-plan]].
      Test: state=3d beast=cinder_jackal console=hp+10 ^low-health-shows-on-screen
- [ ] **One HUD style: carved obsidian.**
      **Session, 2026-09-29 22:35 ET:** The HUD is flat outlined panels. Re-theme the top bar, party cards, intent badge, energy orb and the End Turn and Switch buttons in one material: dark glassy fill, bevelled edge, thin ember-orange rim, soft shadow; names in the display font in `assets/fonts`. Same sizes and positions, nothing overlaps at 1280x720. Done-when: the rest frame shows every panel in the new material and no text clips. Source: [[2026-09-29-intense-fight-plan]].
      Test: state=3d beast=cinder_jackal ^one-hud-style-carved-obsidian
- [ ] **The beast's health bar reacts.**
      **Session, 2026-09-29 22:35 ET:** The beast bar is a plain progress bar. Give it notch marks at each weak-point threshold, a pale ghost segment that lingers 0.4 s after damage and drains, and a crack flash when a threshold is crossed. Done-when: a strike frame shows the ghost segment behind the new value. Source: [[2026-09-29-intense-fight-plan]].
      Test: state=3dstrike beast=cinder_jackal beat=loop ^the-beast-s-health-bar-reacts
- [ ] **Cards fan and glow.**
      **Session, 2026-09-29 22:35 ET:** Fan the hand in a shallow arc with a slight tilt per card; the hovered card lifts, straightens and glows at its edge with `foil.gdshader`'s rim; the cost pip pulses while the card is playable. No card flight (Nick, 20:59). Done-when: the hover frame shows the lifted glowing card above its tilted neighbours. Source: [[2026-09-29-intense-fight-plan]].
      Test: state=3d beast=cinder_jackal hover=1 ^cards-fan-and-glow
- [ ] **The intent badge reads like a warning.**
      **Session, 2026-09-29 22:35 ET:** The intent badge is a small boxed label that sometimes sits on a hunter. Make it bigger, red-rimmed, with an icon per move type, pinned above the jackal's head at every camera and never over a hunter. Done-when: rest and climb frames both show the badge above the head and clear of both hunters. Source: [[2026-09-29-intense-fight-plan]].
      Test: state=3dclimb beast=cinder_jackal ^the-intent-badge-reads-like-a-warning
- [ ] **The climb gauge stands beside the beast.**
      **Session, 2026-09-29 22:35 ET:** The right-rail ladder is a thin line with ticks. Make it a gauge beside the stage: a portrait pip per hunter at their height, glowing notches at the ledges, the sigil burning at the top, in the obsidian style. Done-when: the climb frame shows both pips at their heights and the sigil glow at the top. Source: [[2026-09-29-intense-fight-plan]].
      Test: state=3dclimb beast=cinder_jackal ^the-climb-gauge-stands-beside-the-beast
- [ ] **Obsidian floor.**
      **Session, 2026-09-29 22:35 ET:** The arena floor is a flat grey-brown disc. For `quarry_ember` make it black glass: dark base, sharp toon specular band, faint orange emissive in a crack pattern; the plain `Ground` disc gets the same material. Other biomes unchanged. Done-when: the rest frame's floor reads black and glossy with a visible specular band. Source: [[2026-09-29-intense-fight-plan]].
      Test: state=3d beast=cinder_jackal ^obsidian-floor
- [ ] **Lava rock under the hunters.**
      **Session, 2026-09-29 22:35 ET:** The climb stones and the hunters' standing slabs are tan boxes. Make them dark basalt with an ember glow at the underside and edges, scoped to the jackal fight. Done-when: the climb frame shows dark stones with orange edge glow under both hunters. Source: [[2026-09-29-intense-fight-plan]].
      Test: state=3dclimb beast=cinder_jackal ^lava-rock-under-the-hunters
- [ ] **Lava flows around the arena.**
      **Session, 2026-09-29 22:35 ET:** Add a lava ring between the floor and the wall: an emissive scrolling shader with noise, slow flow, orange omni lights along it, heat shimmer above it. It must not reach the hunters' slabs. Done-when: the rest frame shows glowing lava between the floor edge and the wall, lighting the floor orange at the rim. Source: [[2026-09-29-intense-fight-plan]].
      Test: state=3d beast=cinder_jackal ^lava-flows-around-the-arena
- [ ] **Embers in the air.**
      **Session, 2026-09-29 22:35 ET:** Rising ember particles across the arena, sparks falling from the wall's lava seams, and omni lights in the seams so they throw orange on the rock. Done-when: the rest frame shows embers in the air and orange light on the wall around the seams. Source: [[2026-09-29-intense-fight-plan]].
      Test: state=3d beast=cinder_jackal ^embers-in-the-air
- [ ] **A sky with ash.**
      **Session, 2026-09-29 22:35 ET:** The sky is a two-colour gradient. Add a slow-moving ash cloud layer with a red-lit underside near the horizon and an occasional distant glow pulse, for `quarry_ember` only. Fog behind the wall stays. Done-when: the rest frame shows clouds above the wall with red at their base. Source: [[2026-09-29-intense-fight-plan]].
      Test: state=3d beast=cinder_jackal ^a-sky-with-ash


## Waiting on Nick

The builder skips this section. Answer here or in Home; the item then moves
into Now.

## Open decisions, with the default the builder takes if Nick says nothing

- #14 stones: five per hunter, as built.
- #19 gap vs lens: keep the gap, narrow the lens until the beast fills the
  upper two-thirds.
- #23 boulder shape: plain rounded boulders, no flat top, no orange rim.
- #27 weak-point shot: locked behind the active hunter, beast untouched.
- Zigzag width: about one hunter height each side of the old line.
- Lava: a ring at the arena's edge, not rivers across the floor.
- HUD palette: black glass, ember-orange rim, gold for energy and the sigil.

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
