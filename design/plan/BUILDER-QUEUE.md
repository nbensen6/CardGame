# Builder queue

One ordered list. The builder (`tools/builder/BRIEF.md`) does the **top
unticked item** and nothing else. Nick reorders, adds, deletes, and ticks.

- `[ ]` open · `[ ] 👀` built, waiting for Nick to look · `[x]` Nick says done

Every item names the shot that must change. If the shot does not change, the
run failed.

## Now — the Cinder Jackal fight

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

- [ ] **Scene pass 2 toward picture A: grey stone steps, frog on a lit rock.**
      Checked 2026-10-04 against `design/art/targets/TARGET.png`. Pass 1 got the jackal tall, lit and outlined. Still far from the picture, in `state=3d`: (1) the stones are red-black crates scattered round the head, one over the face; the picture has pale grey flat slabs in one clear line from the hunter up to the chest, and the face stays visible. (2) The frog is flat-lit in front of a black box; the picture has it on a raised rock with a shadow under it and the same warm outline as the beast. (3) The jackal's outline is a thin line; the picture's is thick and glowing. Do not touch the jackal's model or pose: that is Nick's call.
      Target: ![[art/targets/TARGET.png|420]] Now: ![[agents/frames/builder/2026-10-04-scene-pass1-after.png|420]]
      Test: state=3d beast=cinder_jackal ^scene-pass-2-toward-picture-a

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
