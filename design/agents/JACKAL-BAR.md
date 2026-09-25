---
tags:
  - agents
---

# The bar for the Cinder Jackal fight

Nick, 2026-09-23: **no bought asset packs — everything here is generated or
built by us** — and the Cinder Jackal fight reaches Slay the Spire quality
before anything else gets attention.

This is the definition of done. Every agent works items from it when no
request is open; tick one only when a frame or a test proves it, and say
which. Nick has the final word on every line: he can untick anything.

## What "Slay the Spire quality" means here

StS is not a pretty game; it is a *legible* one. Everything below is about
reading the fight at a glance, at play size, in motion.

### The cards — the thing you look at most
- [ ] **Every card in both decks has art.** No bare icons. Generated here.
- [ ] **A card reads at hand size** (~160px tall): name, cost, art and effect
      all legible without hovering.
- [ ] **Card art says what the card does** before the text does.
- [ ] **One consistent style across the whole deck** — not a mix of painted
      and flat icons.
- [x] **Play feedback**: a card visibly leaves the hand, the effect lands on
      the beast, and a number or state change follows. No silent plays.
      First dedicated playtester look, 2026-09-24: this line's three parts
      each already have a permanent live check, run on every real card play
      in every full baseline since they were added, not just this run's own
      — `hand-count` (screen card count must match the model's hand size
      after every play, proving the played card actually leaves),
      `damage-popup-missing` (any real boss-hp or hunter-hp loss must show a
      floating number on the beast that same step) and `dead-click`/`stuck`
      (an action that changes nothing — energy, hand, hp, foothold, turn —
      fails outright). A fresh full three-mode baseline this run (a
      complete 30-step fight through to a win, `hover`, `hands` 1-10) shows
      0 fails on all three across roughly two dozen real plays this run
      alone (5 timed hits, several Skills, two End Turns) — consistent with
      every prior run on record; neither check has ever fired except
      during the two already-fixed bugs they were built to catch
      (2026-09-23's boss-damage-popup-offscreen-at-sigil, now fixed and
      confirmed clean). Went past the check math to look at real frames,
      not just the pass count: step 17→18 below, playing Brace, shows the
      card gone from a 5-card hand, energy 3→2, and a `◈5` Block icon
      appear on the Frog's own party row the same step — visible effect and
      visible state change together, not a silent click.
      ![[frames/playtester/2026-09-24-play-feedback-brace-before.png]]
      ![[frames/playtester/2026-09-24-play-feedback-brace-after.png]]
      Real damage landing on the beast itself (a floating number at the hit
      point) is already shown in the artist's own frames from today's
      "read at a glance" pass, same checks, same fight:
      ![[frames/artist/2026-09-24-glance-boss-damage-lands-on-beast.png]]
      ![[frames/artist/2026-09-24-glance-hunter-damage-and-marker.png]]
      Climb has no popup of its own by design (the persistent 2D gauge
      tracks it instead, covered by "the weak point is obvious" above), so
      this line is judged on damage and state-change plays, which is what
      the deck is mostly made of. `hop-distance-band` (climb spacing) and
      `intent-tag-vs-hunter` (a small residual graze, filed, still open)
      are both real but unrelated to this line — camera/climb, not card
      feedback — and don't touch any of the three checks above.

### The fight, read at a glance
- [x] **The beast's intent is unmissable** — what it will do next turn, and
      to whom, readable without hunting for it. First dedicated artist look,
      2026-09-24: `_position_intent_tag` already carries two live guards
      (clear of the party panel, clear of the active jumping hunter — both
      already fought for and fixed this same day), and a full 80-step real
      fight plus `mode=hands` at every hand size 1-10 both show `intent-
      hidden` and `hand-over-hud` at 0 fails throughout. Looked at the actual
      tag in several real frames, not just the check math: "† Attack 7" reads
      clearly, high-contrast (dark red panel, white text) against both the
      orange arena floor and the beast's own black body, in every state
      checked (`3d`, `3dgrip wide`, `3dclimb`, a 10-card hand).
      ![[frames/artist/2026-09-24-glance-10card-hand-nothing-hidden.png]]
- [x] **Damage and climb numbers** appear where the thing happened. Damage:
      `playtest.gd`'s own `damage-popup-missing`/`damage-popup-offscreen`
      checks (poll every frame a hit resolves, not just once) fired 0 times
      across a full fight that took the boss from 42 HP to dead — every
      landed hit produced a popup and it stayed on screen throughout. Went
      past the check math to actually look: caught a real popup alive
      mid-hop and it sits exactly on the beast's own body at the hunter's
      attack point, pale numerals for a boss hit, a distinct orange-red for
      a hunter taking damage — same colour-coding, same "at the hit" rule,
      both confirmed in real frames.
      ![[frames/artist/2026-09-24-glance-boss-damage-lands-on-beast.png]]
      ![[frames/artist/2026-09-24-glance-hunter-damage-and-marker.png]]
      Climb has no separate transient popup — checked the code, this is by
      design, not a gap: the persistent 2D climb gauge (`✦ <N>` label,
      already verified in "the weak point is obvious" above) shows the
      current Height continuously rather than flashing a number and fading
      it, which is a stronger treatment for something a player needs to
      track for the whole climb, not just the instant it changes.
- [x] **Both hunters are always findable**, including mid-climb. The design
      is explicit in the code's own comments: the 3D camera only ever frames
      the ACTIVE hunter (third-person, by intent), and the party panel is
      the thing that guarantees the OTHER hunter stays findable —
      `party-roster-incomplete` (party panel row count matches player count)
      and `hunter-behind-camera`/`hunter-lost-mid-hop` (the active hunter
      specifically) all read 0 fails across the same full fight. Looked at
      the case that matters most — the sigil close-up, where the 3D frame is
      tightest — and both hunters still read as distinct small portrait
      markers on their own footholds, clear of the rock and the glow.
      ![[frames/artist/2026-09-24-glance-sigil-both-hunters-findable.png]]
- [x] **Nothing important is behind the hand**, the rail or the party panel,
      in any state, at any hand size. `mode=hands` (hands of 1 through 10,
      the top of what this deck can realistically hold) and the full 80-step
      fight both show `hand-over-hud` (`_intent_tag`, `_hp_bar`, `_party`,
      `_gauge`) and `hand-over-button` at 0 fails throughout — no hand size
      or moment ever covers any of them. A real 10-card hand, the largest
      dealt this run, still leaves the boss HP bar, intent tag, party panel
      and climb gauge fully clear at true resolution.
      ![[frames/artist/2026-09-24-glance-10card-hand-nothing-hidden.png]]

### The creature
- [ ] **Silhouette reads at 250px** — the jackal is recognisable as one shape.
      First rubric score, 2026-09-24: **40/50** (Sil 8, Prop 8, Hygiene 7,
      Colour 9, Style 8), 4 under the 44 beast stop line. This model
      (`cinder_jackal_ai.glb`) had never been scored before — only two named
      fixes (ear glow, foothold texture) had ever been made to it. The look
      found a real defect no prior pass had caught: a stack of leftover
      basalt foothold geometry (320 faces, pre-dating the 2026-09-23 switch
      to floating in-engine stones) was still fused into the model's own
      chest/foreleg region, contaminating the shipped file because every
      rebuild since has re-fed the beast's own prior export back in as its
      source. Removed it (confirmed fully disjoint from the real body
      first), plus a stray unreferenced icosphere. `design/progress/
      cinder_jackal_ai.md` ("Pass 2"). A fresh, more critical six-view look
      plus an in-fight check, 2026-09-24, confirmed that fix is holding and
      found nothing further on Silhouette/Proportion/Style — score stays
      40/50. The one open gap, Build hygiene's tri-budget overage, is now a
      confirmed structural ceiling shared by all three Meshy-built cast
      members (this beast, `frog_ai`, `goblin_mech_ai`); closing it needs a
      deliberately risk-budgeted decimation/re-unwrap pass, not another
      look. `design/progress/cinder_jackal_ai.md` ("Pass 3"). **Plateau
      called, 2026-09-24 11:10 ET**: three separate scores all landed on the
      identical 40/50, which is this project's own signal to stop repassing
      and ask rather than try a fourth time — `design/progress/
      cinder_jackal_ai.md` now opens with a `VERDICT: REBUILD` section, and
      the choice (leave it, or greenlight the risky re-unwrap) is with Nick:
      `2026-09-24-1110-artist-to-nick-jackal-and-goblin-plateaued-below-stop-line.md`.
      **2026-09-24 12:23 ET: Nick greenlit it; tried on the Goblin Engineer
      first (lower risk, same root cause) and it does not work** — the
      "island count" this and every VERDICT blamed on UV seams is actually
      unwelded remesh geometry, confirmed identical on this beast too (440
      raw components = 440 shipped islands, zero UV contribution), and a
      real re-unwrap attempt made the goblin's number 3x worse, not better.
      Not attempted on this beast — proven not to work before risking its
      rig/animation. `design/progress/cinder_jackal_ai.md`'s VERDICT section
      has the correction; `goblin_mech_ai.md` pass 9 has the experiment.
      **2026-09-24 16:30 ET: the tri-budget ceiling this VERDICT is about is
      resolved on the hunters by a style change, not by the re-unwrap this
      VERDICT chased.** Nick picked style C (Risk of Rain 2, low-poly
      flat-shaded) for the whole cast
      (`2026-09-24-1147-nick-to-artist-find-an-art-style-worth-copying.md`).
      This beast shares its shading with both hunters now (`toon.gdshader`'s
      hard band, `design/progress/cinder_jackal_ai.md` pass 8) but not the
      geometry half — it is rigged and animated, unlike the two static
      hunters, so decimating it needs its own careful pass, not the
      copy-paste the hunters got this run. Still unticked: this line's own
      Silhouette hasn't been re-scored under the new direction and the
      geometry itself is unchanged.

      **2026-09-24 21:26 ET: the geometry half landed too.** Cut from 11,999
      to 2,639 tris (the beast's own 2,600 budget, not the hunters' much
      smaller number — this subject is far bigger on screen and showed no
      facet-noise at either tri count), flat-shaded to match style C, rig
      and all three animation clips verified undamaged.
      `design/progress/cinder_jackal_ai.md` ("Pass 9"). **Not ticking this
      line myself** — whether it actually *reads* as matching is Nick's call
      on the frames below, the same fidelity question #13 already burned
      once this fight:
      ![[frames/artist/2026-09-24-jackal-lowpoly-closeup-before-after.png]]
- [x] **The weak point is obvious** and stays obvious as you climb toward it.
      First look, 2026-09-24: the persistent 2D climb gauge already marks it
      clearly at all times (a distinct gold rail-cap and `✦ <N>` label, never
      checked before, holds up). The 3D glow on the beast itself did not —
      pixel-sampled at `state=3dstrike`, it sat exactly on the climbing
      shelf's own 2026-09-23 bright rock texture and was statistically
      indistinguishable from it (both at R≈234-255). Fixed by lifting the
      mark into the open air above the shelf instead of level with it
      (`combat_3d.gd` `_place_sigil`) — verified with a real render+pixel
      sample as a distinct ~5x-brighter spark against the dark cave wall.
      `design/progress/cinder_jackal_ai.md` ("Pass 5"). Left one gap open:
      the same fix (a 0.9x-`HUNTER_HEIGHT` lift) did not separate the mark
      from the hunter's own sprite in the one camera angle where that
      hunter stands exactly on the sigil (`state=3dclimb`) — it landed at
      the hunter's own torso/head height, not above it. Closed 2026-09-24:
      raised the lift to 1.7x `HUNTER_HEIGHT`, clearing a standing hunter's
      head at the same anchor — no colour or scale change, placement only.
      Re-verified all four 3D camera states: `3dclimb` now shows a clean
      gold spark above the hunter's head instead of hidden behind it,
      `3dstrike`'s earlier shelf-separation win still holds (if anything
      cleaner now), `3d`/`3dgrip` are unaffected (sigil correctly `n/a`,
      out of frame by design, in both). `design/progress/
      cinder_jackal_ai.md` ("Pass 7").
- [x] **It is alive when idle** (breath, tail, ember pulse) without drifting.
      Verified 2026-09-24: the shipped `idle` clip (4.0s loop) produces real
      motion every render (`state=3d anim=idle@0/@2/@4`), and diffing frame 0
      against 10 and 100 loops later (`@40`, `@400`) shows the same bounded
      amount of change each time rather than a growing one — the motion
      oscillates, it does not accumulate into drift. `design/progress/
      cinder_jackal_ai.md` ("Pass 4").
- [x] **It reacts**: attack, hit and death all read as different events.
      Attack/hit were already known to differ (separate clips, `_strike()`'s
      camera-shake/flash/weak-point emphasis). Death had never been checked:
      no `death` clip exists and `combat_3d.gd` never branches on
      `boss.is_dead()` — but `location_3d.gd`'s own `_lay_out_the_felled()`
      (already tuned specifically for this beast's proportions) lays the
      jackal on its flank in the reward scene, and a real render
      (`state=3dreward beast=cinder_jackal`) confirms it reads as a fallen
      animal — snout/ears, four splayed legs, the same spine markings — not
      an abstract shape. `design/progress/cinder_jackal_ai.md` ("Pass 4").

### Motion
- [x] **The jump reads** — anticipation, arc, landing, at the size it plays.
      First dedicated artist look, 2026-09-24: real hops (`mode=play
      beast=cinder_jackal`) read well overall at true 1:1 — a clear
      anticipation crouch, a real airborne arc, a clean landing on the
      floating stone, all legible at the size they actually render (a
      shrunk composite grid made the hunter look far smaller/harder to
      read than it actually is at native resolution — worth remembering
      for future motion checks: judge from the real PNG, never a resized
      tile). Found one real defect along the way, not this line's own:
      the boss's intent tag can render on top of and hide a real chunk of
      the hunter mid-arc when the hop's own trajectory happens to cross
      the tag's screen rect (six consecutive real frames of the opening
      hop show the frog's lower body swallowed by "† Attack 7"). Filed
      `to: fixer`,
      `2026-09-24-0822-artist-to-fixer-jump-hides-behind-intent-tag.md`;
      fixed same day (`intent_tag_pos` gained a `hunter_rect` clamp,
      commit `73ae6b4`). Closed 2026-09-24: fresh `mode=play
      beast=cinder_jackal steps=80` re-render of the exact repro hop
      (`hop_000_08.png`) shows the frog sitting fully clear above
      "† Attack 7", not behind it — tag fix verified live, not just by the
      fixer's own test suite.
      ![[frames/artist/2026-09-24-jump-tag-fix-verified.png]]
      Playtester, 2026-09-24 10:05 ET: built a permanent live check
      (`intent-tag-vs-hunter`, `playtest.gd`) rather than take one verified
      frame as proof for every hop, and it found real, if much smaller,
      leftover trouble the single re-render above didn't happen to catch —
      a ~13x34px graze at the very FIRST instant of a ground-level hop
      (before the artist's own checked frame, `hop_000_08`, which is
      further into the same hop), reproduced on three separate full
      80-step runs. Small enough that the main fix is real and holding
      everywhere else, not small enough to call this line done — filed
      separately
      (`2026-09-24-1002-playtester-to-fixer-intent-tag-still-grazes-hunter-at-hop-start.md`)
      so the near-complete fix and the original bug aren't conflated.
      Leaving unticked until that residual closes too.

      **Closed for real, 2026-09-24 15:17 ET.** The fixer's own root-cause
      fix landed (`_position_intent_tag` was reading the hunter's position
      one engine frame stale, off `_process()` instead of
      `RenderingServer.frame_pre_draw`; commit noted in
      `2026-09-24-1002-...`'s own `## Result`). Re-verified independently
      this run rather than trust the write-up alone: fresh `mode=play
      beast=cinder_jackal steps=80` on the current tree, foreground with a
      10-minute timeout, played to its own real ending (Pounce landed,
      screen changed to Location3D). `intent-tag-vs-hunter` — 0 fails, every
      sampled hop, including the exact opening ground-level hop the residual
      lived on (log: "intent tag stayed clear of the jumping hunter across
      28 sampled frames"). Only failing check left is the pre-existing,
      unrelated `hop-distance-band` (62, already the fixer's other
      already-`taken` thread — climb spacing, not this line). Then looked,
      not just trusted the check: tiled the exact `hop_000_03` through
      `hop_000_06` frames (the precise window the residual used to graze in)
      side by side at native crop resolution — the frog sits with a clear,
      visible gap from the tag's left edge in every one, no overlap anywhere
      in the sequence.
      ![[frames/artist/2026-09-24-jump-reads-tag-fix-final-verify.png]]
      Anticipation/arc/landing were already confirmed legible in the first
      look above and untouched by this fix; with the intent-tag defect (both
      the original swallow and this residual graze) now fully closed, every
      part of this line is proven. Ticked.

      **Independently re-confirmed, playtester, 2026-09-24 15:19 ET**
      (crossed with the artist's own close above by a few minutes — both
      landed on the same conclusion separately, not a duplicate check). The
      fixer traced and fixed that
      residual the same day (`_position_intent_tag` was reading the active
      hunter's position one engine frame stale, before that frame's own
      climb tween applied it — moved it to run off
      `RenderingServer.frame_pre_draw` instead of `_process()`, plus two
      tests built on the real captured frame numbers, not synthetic rects).
      Re-ran the full three-mode baseline fresh against that fix: 0
      `intent-tag-vs-hunter` fails anywhere in `play` (80 steps), `hover`,
      or `hands` (1-10) — was 1 real fire in `play` every run since the
      main fix landed, now genuinely zero. Went past the check itself and
      looked at the actual opening hop this residual used to graze
      (`hop_000_03`/`_04`) at 1:1: the frog sits fully clear of "† Attack 7"
      with a real gap on both sides, not just clearing the check's own 8px
      margin.
      ![[frames/playtester/2026-09-24-jump-reads-tag-clear-hop-start.png]]
      With that closed, nothing was left blocking this line specifically —
      did the fresh eyes-on pass the line itself asks for (anticipation,
      arc, landing, at native 1:1, not a shrunk composite) across the same
      opening hop, full arc: a low crouch at launch, a real rising-then-
      falling arc crossing in front of the beast's legs, and a visible
      landing squash on the stone at the far end — no pop or snap anywhere
      in the sequence, the tag tracking clear of the frog the entire way.
      ![[frames/playtester/2026-09-24-jump-reads-full-arc-strip.png]]
      `hop-position-pop` and `hunter-lost-mid-hop` (already-passing checks
      covering the "no pops"/"camera never loses the hunter" lines above)
      both stayed at 0 across the same run, so this line's own remaining
      claims (anticipation, arc, landing specifically) are what's new here.

      **Facing closed, playtester, 2026-09-24 21:16 EDT.** The playtester's
      own brief names a fifth part of this same line — "the hunter faces
      sensibly" — that nothing above checked; `combat_3d.gd`'s own
      `_process` turns every hunter's body to face the beast every frame, on
      purpose, but it had only ever been read, not proven live. New check
      `hunter-not-facing-beast` (`playtest.gd`) recomputes the same facing
      math off the hunter's real position and compares it to the body's real
      rotation: 0 fires across a full three-mode baseline, 18/18 when the
      facing math was broken on purpose (a hard 90° offset), reverted clean.
      ![[frames/playtester/2026-09-24-facing-check-resting-shot.png]]
- [x] **The camera never loses the active hunter**, including mid-jump.
      Dedicated eyes-on pass, 2026-09-24 (this run): 8 real hops sampled
      across a full 80-step fight (steps 0, 1, 2, 9, 10, 11, 16, 19, 20,
      27), `playtester.md`'s own `hunter-lost-mid-hop` check fired 0 times
      — coverage ranged 94%-100% on-screen per hop, all comfortably under
      the 50%-off "lost" threshold. Backed by an actual look, not just the
      check: tiled strips of two real hops (the ground→first-foothold
      opening hop, and a long cross-arena Grappling Hook hop) both show the
      hunter clearly visible and readable through the whole arc, no frame
      where it drops off screen or behind another element.
      ![[frames/artist/2026-09-24-motion-camera-hold-hop000.png]]
- [x] **No pops**: nothing teleports, flickers, or snaps between frames.
      Dedicated eyes-on pass, 2026-09-24 (this run): `hop-position-pop`
      fired 0 times across the same 8 sampled hops (worst frame-to-frame
      step 3.07m on the longest hop, still read as smooth against its own
      neighbours, not an isolated spike). Confirmed by eye on the same two
      strips as the line above — the goblin's Grappling Hook arc (the
      biggest single-frame delta this run) reads as one continuous motion
      frame to frame, no teleport or snap anywhere in the sequence.
      ![[frames/artist/2026-09-24-motion-no-pop-hop027.png]]

### The hunters
- [ ] **Frog and Goblin match the jackal's fidelity.** Both are now the
      Meshy `_ai` rebuilds, not the old Python-primitive models, and score
      close to their hunter stop line (`frog_ai` 42/50, at the line;
      `goblin_mech_ai` 41/50, one point under — both Build hygiene's shared
      tri-budget ceiling, see `goblin_mech_ai.md` pass 7). First literal
      side-by-side check of all three together at true in-fight scale,
      2026-09-24: same outline, palette-atlas colouring and painted-light
      treatment on all three — no stylistic mismatch found, only
      `goblin_mech_ai`'s one remaining point keeps this unticked. 2026-09-24
      pass 8: every cheaper lever short of a full UV re-unwrap is now tried
      and ruled out on that point (a fresh six-view look found no new
      Silhouette/Proportion/Style defect; a tri-count decimation test cuts
      `goblin_mech_ai` 40% with zero visible loss but doesn't reach "within
      budget" and doesn't move the island count the right way — `frog_ai`
      sits in the same accepted-overage tri class untouched and already
      caps at the same Build hygiene 7, which is the evidence this line
      isn't on a sliding tri-count scale within that band). The re-unwrap
      is the one lever left; it needs its own scoped, risk-budgeted pass,
      not another same-run attempt. `goblin_mech_ai.md` pass 8.
      `design/progress/cinder_jackal_ai.md` ("Pass 6"). **Plateau called,
      2026-09-24 11:10 ET**: `goblin_mech_ai`'s last two scored passes (7, 8)
      both landed on the identical 41/50 — two consecutive 0-point passes,
      this project's own signal to stop repassing and ask. `design/progress/
      goblin_mech_ai.md` now opens with a `VERDICT: REBUILD` section
      alongside the jackal's own identical call; the choice is with Nick:
      `2026-09-24-1110-artist-to-nick-jackal-and-goblin-plateaued-below-stop-line.md`.
      **2026-09-24 12:23 ET: Nick greenlit the re-unwrap; tried on the
      Goblin Engineer and it does not work.** `goblin_mech_ai.md` pass 9 —
      the "island count" all three VERDICTs blamed on UV seams is actually
      raw unwelded remesh geometry (confirmed identical on all three cast
      members), a re-unwrap can only add seams to that floor not remove
      them, and a real built-and-baked attempt measured exactly that
      (489→1,586 islands, worse). Not shipped. Still one point under the
      stop line; the only remaining lever is a full manual retopology, a
      different and much bigger job than what was approved, not attempted
      here — back with Nick via the same request's `## Result`.
      **2026-09-24 16:30 ET: Nick answered the follow-on style request —
      style C (Risk of Rain 2, low-poly flat-shaded), plus a light distance
      fog borrowed from candidate B, purely for depth
      (`2026-09-24-1147-...find-an-art-style-worth-copying.md`).** Built it
      for real on both hunters, not another demo: `tools/blender/ai/
      lowpoly_facet.py` (new — same Decimate lever pass 8 already validated
      on the Goblin Engineer, plus flat shading so the facets read on
      purpose instead of being smoothed into a lump) cuts both from ~5,200
      tris to ~1,560 — inside the 1,400 hunter budget for the first time,
      where three passes' worth of re-unwrap attempts never got them.
      Verified in the studio rig and the real fight, both hunters together,
      `ALL TESTS PASSED` and a fresh 80-step playtest with no new fail (only
      the pre-existing, unrelated `hop-distance-band`):
      ![[frames/artist/2026-09-24-style-c-goblin-studio-before-after.png]]
      ![[frames/artist/2026-09-24-style-c-frog-studio-before-after.png]]
      ![[frames/artist/2026-09-24-style-c-infight-grip.png]]
      **Still unticked.** The tri-budget gap between the hunters and the
      jackal that this line has chased all day is gone, but the beast itself
      hasn't had the matching geometry pass yet (it is rigged/animated,
      needs its own careful decimation, not attempted this run —
      `design/progress/cinder_jackal_ai.md` pass 8) — right now the hunters
      are faceted low-poly and the jackal is smooth high-poly, both under the
      same new hard-band shading. "Matches the jackal's fidelity" cannot be
      true until the jackal gets the same treatment or Nick says the
      mismatch is fine.

      **2026-09-24 21:26 ET: the jackal got the same treatment** — cut
      11,999 → 2,639 tris, flat-shaded, rig and all three clips verified
      intact (`design/progress/cinder_jackal_ai.md` pass 9). All three cast
      members now share the same shading and the same "facets are the
      style" geometry treatment, each within its own budget. **Still not
      ticking this line** — whether the three actually read as one style
      together, side by side, in the real fight, is a look only Nick's own
      eyes settle, and this exact question is the one #13 already burned
      once. His call on the frames in the Silhouette line above.
- [ ] **Each is readable at fight distance** as itself, not a green blob.
      **Unticked, 2026-09-24 20:13 ET.** Was ticked 2026-09-23, before the
      style-C low-poly switch and before #13's 09-24 re-open. Fresh
      `state=3d wide` render, read at true 1:1 (no zoom) rather than trust
      the earlier 4x-crop evidence that ticked this: both hunters are
      ~15-20px tall at the camera this state actually uses, which reads as
      a coloured speck regardless of model/colour quality. Same root cause
      as `#18`'s own diagnosis (not enough space between the hunters and
      the beast, so the wide camera has to sit ~74 units back to fit the
      whole beast) — tracked there, not a separate defect. See `#13`'s
      2026-09-24 20:13 follow-up for the frames.
      The Goblin Engineer's Meshy rebuild was wired in and unreadable at true
      size (a near-solid black blob) until the shared ink-outline width was
      given a per-model scale, 2026-09-23 — verified in the real fight and
      the campfire row. `design/progress/goblin_mech_ai.md` ("Shipped and
      scored"). Frog was already there. Fidelity is not fully matched yet —
      see the line above. The party rail's portraits were still the OLD
      Python-primitive models for both hunters even after the fight itself
      moved to the Meshy ones (`portraits.py`'s own `AI_ART` table never
      got the hunters added); fixed 2026-09-23, which also closed the last
      open Colour & read question for both — `frog_ai` **42/50, at the
      stop line**; `goblin_mech_ai` **40/50** (was 39), after fixing the
      tank-vs-body contrast at 34px named as the concrete gap — which also
      surfaced and fixed a real bug: the glb's own embedded texture had
      never received the earlier colour-boost pass, so every portrait
      render (party rail, character card, campfire) had shown a dimmer
      goblin than the fight itself for two passes running.
      `design/progress/frog_ai.md` pass 3,
      `design/progress/goblin_mech_ai.md` pass 5. A fresh six-view look,
      2026-09-23, found a bigger colour defect than any prior pass had
      caught: at the true `state=3d` camera, 1:1, not a zoomed crop, the
      Goblin's skin read near-white, not green — every earlier "verified in
      the real fight" frame in this thread had been a 3x crop, which hid it.
      Fixed with a hue-masked saturation boost (skin only, value untouched)
      that now matches the Frog's own saturation range at both the real
      fight camera and the 34px portrait. `goblin_mech_ai` **41/50** (was
      40), one point under the hunter stop line.
      `design/progress/goblin_mech_ai.md` pass 6.
      **Regressed, 2026-09-24: style C's low-poly cut (16:38 ET) kept the
      full photoreal Meshy texture on the decimated mesh — Nick caught it
      at real fight size (#13), both hunters back to unreadable.** Two
      compounding causes, not one: (1) the texture itself was still
      hundreds of colours of baked micro-shading across a scrambled,
      unpadded UV atlas (489/193 disconnected islands), which bleeds
      across unrelated islands once the mesh is only ~40px tall — any
      texture-based fix inherits this; (2) 1,560 triangles is still too
      many facets for a ~40px character — most are sub-pixel, so
      `toon.gdshader`'s hard lit/shadow edge flips per-facet and reads as
      noise independent of colour. Fixed both: decimated further, from the
      pre-style-C ~5,200-tri source, to ~260 (Frog) / ~310 (Goblin)
      triangles so remaining facets are actually visible on screen, then
      replaced the texture entirely with flat PER-FACE VERTEX COLOUR (a
      handful of swatches per hunter, merged only across ADJACENT faces so
      a region is one real contiguous body part, not a colour-similarity
      guess) — vertex colour can't bleed across UV space because there is
      no texture lookup at all (`tools/blender/ai/flat_paint_dump.py` →
      `flat_paint_region_merge.py` → `flat_paint_bake.py`,
      `toon.gdshader`'s `ALBEDO` gained `* COLOR.rgb`). Also fixed the
      character-select screen showing the OLD Kenney-primitive models
      (`Cast.model_path` never checked for an `_ai` rebuild at all;
      `location_3d.gd`'s roster row never toon-shaded one either).
      Verified: both hunters read as a real shape with 4-7 flat colours at
      the true `state=3d` camera, the ink outline is a mostly-continuous
      line instead of dotted fragments (fewer/bigger facets), and
      character select now shows the exact model the fight does.
      ![[frames/artist/2026-09-24-hunters-zoom-evidence.png]]
      ![[frames/artist/2026-09-24-character-select-matches-fight.png]]
      **Honest residual:** the Goblin still reads darker than the Frog —
      its geometry has more facets angled away from the key light, and the
      arena's own ambient is intentionally darker/cooler since #12's
      palette pass, so a facet with little direct light leans on a dim
      ambient regardless of its assigned colour. Confirmed this is a
      light/geometry interaction, not a leftover colour or outline defect
      (tested with the outline fully off and a much lighter shadow tint —
      neither moved it). Not fixed here — would mean either re-touching
      the recently-approved ambient (out of this request's scope) or a
      geometry pass on which facets face the light, worth its own look if
      Nick still finds the Goblin too dark after seeing this.

### The arena
- [x] **It frames the beast** rather than competing with it. Meshy-generated
      crater wall replaced the primitive `enclose()` slabs, 2026-09-23 —
      verified in every 3D camera state the fight uses, beast stays the
      clear subject with the wall reading as backdrop. `design/progress/
      cinder_jackal_ground.md` pass 6, 37/50.

      2026-09-24 (#12, `to: artist` from Nick): the shape framed the beast
      but the colour didn't — floor, wall and beast were all the same warm
      orange-brown, so nothing separated by value even though the geometry
      was right. Recoloured the ground floor from UMBER to CHARCOAL (both
      `tools/blender/env/cinder_jackal.py` and the shipped
      `cinder_jackal_ai.glb`'s own Floor mesh — the Wall itself was already
      CHARCOAL and untouched), the floating footholds from basalt-brown to
      a pale near-white, and the sky/ambient/fog from warm tan to a cool
      purple-into-pink dusk, sampled straight off Nick's reference. Verified
      at the wide shot, the sigil close-up, and a 160x90 thumbnail — the
      pale stones, dark ground and hot beast now read as three distinct
      values at a glance.

      2026-09-24 (#16, `to: artist` from director): the colour was right but
      the footholds had no mass — `_build_float_stones`'s rock body was a
      `SphereMesh` squashed to a third of a true sphere's height for its
      width (3 hunters wide, 1 hunter tall), reading as a flat pale disc/
      saucer next to the dog rather than a boulder. Fixed with one line:
      `rock.height = rock.radius * 2.0` (a true, un-squashed sphere) instead
      of a fixed `HUNTER_HEIGHT * 1.0` — same width as #13 set, now as tall
      as it is wide. Verified at `state=3d` and `state=3dgrip`, 1:1: both
      footholds read as solid pale lumps under the flat cap. `ALL TESTS
      PASSED` and a fresh 80-step playtest before/after: zero
      `hunter-off-marker`, only the pre-existing `hop-distance-band` (62,
      the fixer's own open thread, unchanged count).
- [x] **It says where this fight is**, not "generic ground". The sigil
      close-up now shows real glowing ember cracks in the rock itself, not a
      flat slab — same evidence as above.

## How to work it

One item per run. Prove it with a rendered frame at 1:1 (never a zoomed
crop) and, where it is a rule, a test. Put the frame in the beast's note and
in your status note. If an item needs a judgement about taste, build the
strongest version you can, show it, and file `to: nick`.
