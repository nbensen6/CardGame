---
tags:
  - agent-status
agent: artist
updated: 2026-09-24T11:10
working_on: Called the plateau on cinder_jackal_ai (40/50, three identical scores) and goblin_mech_ai (41/50, two identical scores) -- both hit this project's own "stop repassing, ask Nick" rule. Wrote a VERDICT: REBUILD section on each progress file (score, why it's not a shape/silhouette problem, what the real fix -- a full UV re-unwrap -- would need) and filed one to:nick request covering both, asking him to either accept the current scores or greenlight the risky re-unwrap as its own dedicated pass.
---

# artist

## This run — 2026-09-24 11:10 ET

- **Did:** no open or answered `to: artist` request this run (checked every
  request's frontmatter -- three open notes in `requests/`, all `to: fixer`
  or `to: nick`, none mine). Went to `JACKAL-BAR.md`'s own queue and, before
  starting another routine pass on the two remaining blocked items (the
  jackal's Silhouette line, the hunters' fidelity line -- both stuck behind
  the same "needs a scoped UV re-unwrap" refrain for 8+ runs now), reread
  `design/guide/asset-loop.md`'s own stop-the-loop rule: two consecutive
  scored passes gaining under 2 points means stop passing and write a
  verdict for Nick, not try again. Checked both progress files' own score
  history against that rule directly rather than assume.
- **Worked?** Yes -- both assets meet the rule, literally, and neither had
  ever had the verdict written down despite it being true for a while.
  `cinder_jackal_ai`: three separate scores (pass 2, pass 3, pass 6) all
  landed on the identical 40/50. `goblin_mech_ai`: its last two scored
  passes (7, 8) both landed on the identical 41/50. In both cases the
  blocker is the same shared cause -- a tri-budget/UV-seam ceiling from the
  Meshy build pipeline, not the shape or colour, which are already good.
  Wrote the verdict on both progress files and one `to: nick` request
  presenting the actual decision (leave them, or greenlight the risky
  re-unwrap) instead of letting a ninth near-identical "needs a scoped pass"
  note go by unresolved.
- **Next:** waiting on Nick's answer on the new request. Until then, nothing
  on my own brief is blocked -- the only other open lever (cards) stays
  parked per his standing order, so the next run should re-check for an
  answer first, then fall back to whatever `JACKAL-BAR.md` line hasn't had a
  dedicated look yet.
- **Need from you:** the new request -- accept the jackal/goblin scores as
  they are, or greenlight the risky texture-remap redo.

## Now

No open `to: artist` request this run (checked every request's frontmatter
-- the three open notes in `requests/` are `to: fixer` (two) and `to: nick`
(the playtester's sigil-cheek ask, still unanswered, not mine). None of my
own `to: nick` notes had a fresh unhandled answer either (all `status:
done`, per `COMMON.md` 1b).

**Set up fresh** (fresh sandbox): Godot 4.7.1 + `--import`, confirmed
`ALL TESTS PASSED` before touching anything. No Blender or Meshy needed --
this run touched no asset or geometry file, only design docs.

**Why this over another routine `goblin_mech_ai`/`cinder_jackal_ai` attempt.**
Every recent run on either asset (jackal passes 2/3/6, goblin passes 6/7/8)
independently concluded the same thing -- Silhouette/Proportion/Style are
fine, Build hygiene is capped by a UV-seam-fragmentation ceiling, and the
one lever that could move it (a full re-unwrap) is too risky to attempt
blind in an unattended run -- and then filed that conclusion as "needs a
future scoped pass" without ever invoking this project's own written rule
for exactly this situation (`design/guide/asset-loop.md`, "the rebuild
verdict": two consecutive passes gaining under 2 points means stop and
write the verdict, it's Nick's call). Re-reading the actual score tables
confirmed both assets already meet that rule's letter, more than once each
-- this wasn't new investigation, it was applying a rule that already
existed and already fit, which nobody had checked literally before.

**Confirmed the plateau from the score tables themselves, not from
memory or the prose summaries.**

    cinder_jackal_ai: pass 2 = 40/50 (first score)
                       pass 3 = 40/50 ("score unchanged")
                       pass 6 = 40/50 ("score unchanged")
    goblin_mech_ai:    pass 7 = 41/50 ("Total: 41/50, unchanged")
                       pass 8 = 41/50 ("Score: unchanged, 41/50")

Both meet "two consecutive scored passes each gained fewer than 2 points"
(0 points, twice, in both cases) while both sit below their tier's stop
line (jackal: 40 vs 44 beast stop line, 4 short; goblin: 41 vs 42 hunter
stop line, 1 short). Neither meets the loop's OTHER trigger ("Silhouette
or Proportion scored 5 or below, fix is a shape rebuild") -- both score 8/8
on those two lines, checked fresh more than once on each asset -- so the
verdict text on both files says plainly that the real fix isn't a body
rebuild, it's a UV re-unwrap, adapting the rule's own remedy language
honestly rather than forcing a "primitive shape" diagnosis that isn't true
here.

**Checked this wasn't already raised and sitting unanswered somewhere.**
Grepped every request and status note for "VERDICT" and "rebuild" -- no
prior `VERDICT: REBUILD` section exists anywhere in the repo, and the one
closely related prior request
(`2026-09-23-0325-artist-to-nick-hunters-at-pass-cap-below-stop-line.md`)
is a different, already-`done` question (lifting the 4-pass cap, not
calling a plateau) -- but its answer is exactly the standing authorization
for this: Nick, 2026-09-23, "keep passing them... until they clear the
stop line or you call a real plateau." This run is calling it.

**Wrote the verdict on both files**, each covering: the current score and
which rubric line is capping it, why it isn't the "rebuild the shape"
scenario the rule's example describes, the actual shared root cause (Meshy
export tri-count and the exporter's own UV-seam-driven island
refragmentation -- already independently diagnosed across three prior
passes on three different cast members, cited by number: jackal 12,079
tris vs. 2,600 beast budget, goblin ~5,199 vs. 1,400 hunter budget, both
~3.7-4.6x over), and what the untried fix would actually require (a full
UV re-unwrap, not another tri-count or weld attempt -- both already tried
and ruled out on the goblin, same conclusion the jackal independently
reached). Did not touch either `.glb`, `.blend`, or any shader/script --
this run is a documentation and escalation call, not an asset change.

**Filed one `to: nick` request** covering both assets together, since
they share the identical cause and the identical decision -- written in
plain language per this project's own `to: nick` rules (no file paths or
scores in the ask itself, a clear recommendation, the real tradeoff stated
plainly): leave both at their current, already-good-looking scores, or
greenlight the re-unwrap as its own separately scoped, revertible pass.
Set `waiting: false` -- nothing else on my brief is blocked by his answer,
since the cards item stays parked regardless and every other bar line
either needs a request-driven fix (not mine) or has already been checked.

**Updated `JACKAL-BAR.md`'s two affected lines** (Silhouette, hunter
fidelity) with a short pointer to the new verdict sections and the request,
without deleting any of the existing evidence trail -- both stay unticked,
correctly; nothing about the asset itself changed, only the record of the
decision now waiting on Nick.

`ALL TESTS PASSED` (`run_tests.gd`), confirmed before this run's edits (no
code touched, so no reason to expect it to change) -- `git status` before
this push shows only the two progress-doc verdicts, `JACKAL-BAR.md`, this
status note, and the one new request file. No asset, scene, shader or
script touched, so no playtest re-run needed -- nothing in the live fight
can differ.

## Old: 2026-09-24 10:20 ET

- **Did:** picked up my own last run's "Next" -- `JACKAL-BAR.md`'s "the
  fight, read at a glance" section had never had a dedicated artist look
  (four bullets: intent unmissable, damage/climb numbers land where the hit
  happened, both hunters always findable including mid-climb, nothing
  behind the hand/rail/party panel at any hand size). No open `to: artist`
  request this run either (checked every request's frontmatter -- the three
  open notes in `requests/` are `to: fixer` (two) and `to: nick` (the
  playtester's sigil-cheek ask, unchanged, not mine).
- **Worked?** Yes, all four lines, with real evidence rather than a rubber
  stamp. The automated side was already mostly built by the fixer/
  playtester's recent work on this exact area (`hand-over-hud`,
  `intent-hidden`, `damage-popup-missing/offscreen`, `party-roster-
  incomplete`, `hunter-behind-camera`) -- ran a fresh full 80-step fight and
  a fresh `mode=hands` (hand sizes 1-10) and every one of those checks came
  back 0 fails, on top of the two already-known, already-filed items
  (`hop-distance-band`, `intent-tag-vs-hunter`'s tiny residual, neither
  mine). Then did the part the check math can't do: looked at real frames.
  Caught a genuine damage popup alive mid-hop landing exactly on the beast
  at the hit point (pale for a boss hit, a distinct orange-red for a hunter
  hit -- same colour rule, same "at the hit" placement, both real, both
  photographed), confirmed a 10-card hand -- the largest this deck
  realistically holds -- still leaves the boss HP bar, intent tag, party
  panel and climb gauge fully clear at true resolution, and confirmed both
  hunters still read as distinct small portrait markers on their footholds
  even at the tightest 3D shot (the sigil close-up).
- **Next:** every bar line this brief's own scope can reach with a routine
  run is now ticked except two: the cards section (parked, Nick's standing
  order) and `goblin_mech_ai`'s last hunter-fidelity point, which needs a
  scoped, risk-budgeted UV re-unwrap, not another routine pass. Worth
  weighing whether that re-unwrap is worth scoping as its own dedicated run
  now that the bar's other sections are this close to fully closed.
- **Need from you:** nothing.

![[frames/artist/2026-09-24-glance-boss-damage-lands-on-beast.png]]
![[frames/artist/2026-09-24-glance-hunter-damage-and-marker.png]]
![[frames/artist/2026-09-24-glance-10card-hand-nothing-hidden.png]]
![[frames/artist/2026-09-24-glance-sigil-both-hunters-findable.png]]

## Now

No open `to: artist` request this run (checked every request's frontmatter
-- the three open notes in `requests/` are `to: fixer` (two,
`dropped-slider-shows-wrong-timing-label` and `intent-tag-still-grazes-
hunter-at-hop-start`) and one `to: nick` from the playtester
(`sigil-hunter-clings-to-the-cheek`), still unanswered -- none mine to act
on). None of my own `to: nick` notes had a fresh unhandled answer either
(all `status: done`, per `COMMON.md` 1b). Worked `JACKAL-BAR.md`'s "the
fight, read at a glance" section, exactly where my own last run's "Next"
pointed.

**Set up fresh** (fresh sandbox): Godot 4.7.1 + `--import`, `pip install
pillow numpy`. Blender not needed this run -- no geometry touched, this was
a rendering/observation pass only.

**Why this section over another `goblin_mech_ai` attempt.** My last run's
"Next" named two live options: the goblin's UV re-unwrap (already flagged
across three prior passes as needing its own separately-risk-budgeted run,
not a routine one) and this section (never looked at by a human eye at all,
four concrete, checkable bullets, no asset risk). Picked the lower-risk,
higher-certainty win.

**Read the existing automated coverage before assuming anything was
missing.** `playtest.gd`'s `_check()` already carries real checks for three
of the four bullets, built by the fixer and playtester across the last two
days chasing specific bugs in this exact area: check 5b `hand-over-hud`
(a resting card against `_intent_tag`/`_hp_bar`/`_party`/`_gauge`), check 5c
`intent-hidden` (the tag against the party panel), check 7b
`party-roster-incomplete` (the party panel's own row count vs. the model),
check 9 `hunter-behind-camera` (the active hunter, once settled), and a
dedicated `_poll_popup` mechanism (`damage-popup-missing`/`damage-popup-
offscreen`) that watches every live `Label3D` damage number every frame a
hit is resolving, not just once. None of this had ever been run as a single
deliberate pass against this section's own wording, and none of it had ever
been looked at with real eyes -- exactly the gap this run closes.

**Ran the checks fresh, not trusted from memory.** `mode=hands beast=
cinder_jackal` (hand sizes 1 through 10, the top of what this deck
realistically holds): only the already-known `hop-distance-band` (22 fails,
the fixer's own open stone-route item, unrelated to this section) --
`hand-over-hud`, `intent-hidden`, `party-roster-incomplete` all 0 across
every size. `mode=play beast=cinder_jackal steps=80`, foreground with a
10-minute timeout per `COMMON.md` 4b: `PLAYTEST FAIL: 2 failing check(s)
{ "hop-distance-band": 62, "intent-tag-vs-hunter": 1 }` -- both already
open, already filed to the fixer (the second is the playtester's own tiny
residual from this morning), neither this section's concern. Every check
this section cares about -- `hand-over-hud`, `intent-hidden`,
`party-roster-incomplete`, `hunter-behind-camera`, `damage-popup-missing`,
`damage-popup-offscreen` -- 0 fails across a full fight that took the boss
from 42 HP to dead, i.e. plenty of real hits landing.

**Then looked, since a check proves the math, not that it reads right**
(this project's own standing rule, the same one that caught the goblin's
skin-desaturation bug a check missed). Read the full 80-step run's saved
`hop_NNN_NN.png` frames looking specifically for a live damage popup, since
the settled `step_NNN.png` shots are taken after the ~0.85s popup tween has
already finished and never show one. Found it in `hop_000_10.png`/
`hop_000_14.png` -- a pale "1" sitting directly on the beast's own chest,
right at the frog's Tongue Snap attack point, rising slightly between the
two frames (the popup's own rise tween, caught mid-flight, not a static
crop). Then rendered `state=3dgrip wide` fresh and it happened to also
catch a live popup -- this time a hunter taking a hit, orange-red "3" at
the hunter's own position, the colour-coded "your blood, not the beast's"
distinction `_damage_popup`'s own code comment describes, confirmed for
real rather than just read from source.

![[frames/artist/2026-09-24-glance-boss-damage-lands-on-beast.png]]
![[frames/artist/2026-09-24-glance-hunter-damage-and-marker.png]]

**Checked "climb numbers" honestly rather than assume a gap.** Grepped
`combat_3d.gd` for any climb-specific popup and found none -- by design, not
an oversight: climb has no `_damage_popup`-style transient number, only the
persistent 2D gauge (`✦ <N>` label) this brief already verified earlier
today under "the weak point is obvious." Said so plainly in the bar rather
than force a false parallel with the damage popup or claim a defect that
isn't real.

**Rendered the two remaining cases by hand** rather than rely only on
`playtest.gd`'s own saved frames. `mode=hands`'s own `step_010.png` (a real
10-card hand, the largest size that mode tests): boss HP bar, intent tag,
climb gauge and party panel all read fully clear of the fan at true
resolution -- matches the 0-fail check result with an actual look.
`state=3dclimb` (the tightest 3D framing this fight has, the sigil
close-up): both hunters still read as distinct small portrait markers on
their own footholds, clear of the rock and the glow -- confirms "findable
mid-climb" holds even in the one camera state with the least room to work
with.

![[frames/artist/2026-09-24-glance-10card-hand-nothing-hidden.png]]
![[frames/artist/2026-09-24-glance-sigil-both-hunters-findable.png]]

**Ticked all four `JACKAL-BAR.md` "read at a glance" lines** with this
evidence -- check results plus a real look for each. The section is now
fully closed; nothing left unticked on it.

`ALL TESTS PASSED` (`run_tests.gd`) -- no game code or asset touched this
run, only `JACKAL-BAR.md`, this status note, and four new frames (`git
status` confirms). No further playtest needed beyond the two runs above,
which already cover everything this run claims.

## Old: 2026-09-24 09:24 ET

- **Did:** picked up my own last run's "Next" — the fixer's fix for the
  jump-hides-behind-intent-tag bug had landed
  (`2026-09-24-0822-...jump-hides-behind-intent-tag.md`, commit `73ae6b4`),
  so re-rendered a real fight to verify it live (not just trust the
  fixer's own test suite) and finish the Motion section's two remaining
  unticked lines — camera-holds-the-hunter and no-pops — which my last run
  had deliberately left un-graded pending that fix.
- **Worked?** Yes, all three lines. The exact repro hop (step 0's opening
  Tongue Snap) now shows the frog sitting fully clear above "† Attack 7",
  not swallowed by it — a live re-render, not just reading the fixer's own
  write-up. Camera-hold and no-pops: ran a full 80-step real fight,
  sampled 8 real hops across it, and both `hunter-lost-mid-hop` and
  `hop-position-pop` fired 0 times (coverage 94-100% on-screen per hop,
  worst frame-to-frame step 3.07m and still read as smooth, not a spike).
  Then did the actual eyes-on pass this line has always needed — tiled two
  real hops (the opening ground hop, and the run's biggest single-frame
  delta, a cross-arena Grappling Hook hop) into strips and read them at
  true resolution: the hunter stays visible and readable through the
  whole arc in both, no frame where it disappears, teleports, or snaps.
- **Next:** `JACKAL-BAR.md`'s Motion section is now fully ticked — nothing
  left on this line. The loudest remaining items on my own brief:
  `goblin_mech_ai` still sits one point under its hunter stop line (needs
  a scoped UV re-unwrap, not a routine-run fix), and the bar's "the fight,
  read at a glance" section (intent unmissable, damage numbers land where
  things happen, hunters always findable, nothing hidden behind the hand/
  rail/party panel) has never had a dedicated artist look.
- **Need from you:** nothing.

![[frames/artist/2026-09-24-jump-tag-fix-verified.png]]
![[frames/artist/2026-09-24-motion-camera-hold-hop000.png]]
![[frames/artist/2026-09-24-motion-no-pop-hop027.png]]

## Now

No open `to: artist` request this run (checked every request's
frontmatter — the two open notes in `requests/` are `to: fixer` and
`to: nick`, neither mine, and neither `to: nick` note under my own name has
a fresh unhandled answer per `COMMON.md` 1b). Worked `JACKAL-BAR.md`'s
Motion section, exactly where my own last run's "Next" pointed once the
fixer's tag fix landed.

**Set up fresh** (fresh sandbox): Godot 4.7.1 + `--import`, `pip install
pillow numpy`. Blender not needed this run — no geometry touched, this was
a rendering/observation pass only, same as last run.

**Verified the tag fix live before trusting it.** The fixer's own
write-up (`2026-09-24-0822-...jump-hides-behind-intent-tag.md` `## Result`)
already showed a re-render clearing the exact repro hop and four new unit
tests, all passing (`ALL TESTS PASSED` confirmed again this run, clean
tree, no code touched). Re-ran it myself anyway rather than take that on
faith: fresh `mode=play beast=cinder_jackal steps=80`, read
`hop_000_08.png` (one of the original six frames the bug report was built
on) at true 1:1 — the frog now sits clearly above "† Attack 7", full body
visible, nothing occluded. Independent confirmation, not a rubber stamp.

**Ran the same fight to also close the two Motion lines my last run left
open on purpose.** `JACKAL-BAR.md`'s own text said these were "worth a
future run once the tag fix lands, since re-rendering the same hops is
nearly free at that point" — that future run is this one. Sampled 8 real
hops spread across the full 80 steps (0, 1, 2, 9, 10, 11, 16, 19, 20, 27 —
different heights, different cards, both hunters), read the check output
for each:

    mid-hop camera coverage -- 29-118/29-118 sampled frames on screen
      (0% off on 7 of 8; 6% off on step 0, the opening hop, comfortably
      under the 50%-off "lost" threshold the check itself documents as the
      line between a real complaint and "a single-frame graze at the edge
      of a big arc")
    hop position continuity ok -- worst frame-to-frame step 3.070m (step
      27's Grappling Hook, the run's biggest), still read as smooth
      against its own local neighbours, not an isolated spike

Zero `hunter-lost-mid-hop` or `hop-position-pop` fails anywhere in the
full log (`grep -c` on both against the run's own output, not eyeballed).

**Then did the part the check math can't do — looked.** Per this brief's
own standing rule (a check proves the number is in range, not that it
reads right), tiled two real hops into strips at true native resolution
and read them frame by frame: `hop_000` (the opening ground→foothold hop,
the same one the tag bug lived on) and `hop_027` (the Goblin's Grappling
Hook, the run's largest single-frame position delta, the likeliest place
a real pop would show if the check's threshold were hiding one). Both
read as one continuous, readable motion — the hunter is never lost behind
UI or the arena, and nothing teleports or snaps between frames anywhere
in either strip.

![[frames/artist/2026-09-24-motion-camera-hold-hop000.png]]
![[frames/artist/2026-09-24-motion-no-pop-hop027.png]]

**Ticked all three `JACKAL-BAR.md` Motion lines** with this evidence —
the jump-reads line (now that its one real defect is fixed and verified),
camera-holds-the-hunter, and no-pops. The Motion section is now fully
closed; nothing left unticked on it.

`ALL TESTS PASSED` (`run_tests.gd`) — no code or asset touched this run,
only `JACKAL-BAR.md`, this status note, and three new frames (`git status`
confirms). No further playtest needed beyond the one 80-step baseline
above, which already covers everything this run claims.

## Old: 2026-09-24 08:22 ET

- **Did:** picked up the one thing my own last run's "Next" named as
  never having had a dedicated artist look: `JACKAL-BAR.md`'s Motion
  section (does the jump read, does the camera hold the active hunter,
  are there any pops) — every other lever on hunter fidelity is either
  ticked or waiting on a scoped, risky UV re-unwrap, not a routine-run
  thing. Ran a real fight (`mode=play beast=cinder_jackal`) and read the
  actual hop frames it saves (`hop_NNN_NN.png`), frame by frame, at true
  1:1.
- **Worked?** Yes, and it paid for itself twice over. First: the jump
  itself reads well — a real anticipation crouch, a real airborne arc, a
  clean landing on the floating stone, all legible at native resolution.
  I nearly reported the opposite — a shrunk composite grid made the
  hunter look like a barely-visible speck mid-air — until I checked the
  same frames at true 1:1 and found it reads fine; worth remembering for
  any future motion check. Second, a real defect no prior check (logic or
  eye) had caught: on the opening hop, the hunter's own arc passes
  directly through the boss's intent tag ("† Attack 7"), and the tag
  renders on top, hiding a real chunk of the jumping hunter's body for six
  consecutive real frames — right at the peak of the jump, the one moment
  that most needs to read clearly. Measured the overlap in raw pixels
  before filing anything (frog bbox vs. tag bbox, ~half the tag's height
  and half the frog's width overlapping) and confirmed it's real but
  position-dependent, not universal (a different hop in the same run
  cleared the tag by ~40px once checked at true res, not the grid).
- **Next:** filed `to: fixer` — this is game code
  (`_position_intent_tag`/`intent_tag_pos` in `combat_3d.gd`), not an
  asset, and it's the same shape of bug the fixer already fixed once for
  the party panel, just never extended to the active hunter. Left
  `JACKAL-BAR.md`'s three Motion lines unticked: the jump-reads line has
  a real, filed defect; the other two (camera holds the hunter, no pops)
  aren't contradicted by anything found this run, but hadn't had a
  dedicated eyes-on pass either — worth a future run once the tag fix
  lands, since re-rendering the same hops is nearly free at that point.
- **Need from you:** nothing.

![[frames/artist/2026-09-24-jump-hides-behind-intent-tag-full.png]]
![[frames/artist/2026-09-24-jump-hides-behind-intent-tag-crop.png]]

## Now

No open `to: artist` request this run (checked every request's
frontmatter — the only open notes in `requests/` are `to: fixer` and one
`to: nick` from the playtester, still unanswered — not mine to act on).
None of my own `to: nick` notes had a fresh unhandled answer either (all
`status: done`). Worked `JACKAL-BAR.md`'s Motion section — my own last
run's "Next" named it as the one part of the bar that had never had a
dedicated artist look, since every remaining hunter-fidelity lever short
of a full, separately-risk-budgeted UV re-unwrap is now tried and closed.

**Set up fresh** (fresh sandbox): Godot 4.7.1 + `--import`, `pip install
pillow numpy`. Blender not needed this run — no geometry touched, this was
a rendering/observation pass only.

**Ran a real fight, not a synthetic pose.** `mode=play beast=cinder_jackal
steps=80` under `xvfb-run`, foreground with a 10-minute timeout per
COMMON.md 4b (the harness's own default 120s window had already moved an
earlier attempt to background once, losing the run's own foreground
guarantee — killed it and restarted properly). Result:
`PLAYTEST FAIL: 1 failing check(s) { "hop-distance-band": 62 }` — the
already-open, already-known stone-route item 2 (the two short hops nearest
the sigil), not a regression, not something this run touched.

**`playtest.gd`'s own `_watch_hop` already saves real per-frame PNGs of
every hop it samples** (`hop_<step>_<NN>.png`, up to 24 shots per hop,
capped low on purpose per its own doc comment) — nobody had ever pointed a
human eye at these before; every prior motion claim in this project came
from the check math (arc height, squash deviation, position-continuity),
never a look. Picked several real hops across the run (steps 0, 9, 11, 16,
19, 20, 27 — different heights, different cards, different cameras) and
read them.

**First pass, at half-scale in a composite grid, gave a wrong impression.**
Tiling 9-24 frames per hop into one sheet (to eyeball the whole arc at
once) made the hunter read as a tiny, hard-to-parse blob for most of a big
climb — looked like a real "doesn't read at the size it plays" defect.
Before writing that up, opened the SAME frames individually at their true
native 1280×720 (per `status/README.md`'s own "never judge from a zoomed
crop" — the same rule cuts the other way too: never judge from a SHRUNK
composite either). At true size the hunter reads clearly through the whole
arc: a crouched anticipation pose on the ground, a stretched airborne pose
at the peak, a settled landing pose on the stone. The grid wasn't lying
about relative scale, but it was small enough to blur past detail a real
player's screen wouldn't lose. Correcting this before filing anything
avoided reporting a defect that isn't real.

**The real defect turned up while re-checking individual frames at true
scale.** Step 0's opening hop (`Tongue Snap`, ground → foot 2, six
consecutive real frames — `hop_000_03.png` through `hop_000_08.png`):
the boss's intent tag ("† Attack 7") sits fixed near the beast's own
crown for the whole turn, and this hop's arc rises directly through that
same screen region. Cropped tight at native resolution (no upscale beyond
NEAREST for visibility, source pixels untouched) and it's unambiguous —
the frog's lower body is genuinely behind the tag panel, not just grazing
it.

**Measured before writing it up, the same discipline this project's
requests already hold to.** Sampled the raw pixels of `hop_000_06.png`
directly (no Blender, no in-editor tool): frog's own on-screen bbox
`[282,141]..[364,222]`, tag's own rect `[295,168]..[450,204]` — an overlap
of roughly `[295,168]..[364,204]`, about half the tag's own height and
half the frog's own width. Checked it wasn't universal before calling it
structural: step 19 (same run, sigil close-up camera) shows the hunter
NEAR the tag but — checked at true resolution, not the half-scale grid
that first suggested otherwise — actually clears it by ~40px. Real,
reproducible, but position-dependent: exactly why nothing caught it
before (a check would need to know where the active hunter is on screen
relative to the tag, and nothing does).

**Read the actual code before filing, not just the symptom.**
`intent_tag_pos` (`combat_3d.gd`) already clamps the tag away from the HP
bar, the hand, and — since `2026-09-23-2141`'s fix — the party panel, but
never checks it against a hunter's own screen position, in flight or
standing. Same shape of gap as the already-fixed bug, just never widened
to cover this case. Filed `to: fixer`,
`2026-09-24-0822-artist-to-fixer-jump-hides-behind-intent-tag.md`, with
both frames and the measured rects — not my fix to make (game code, not an
asset, per this brief's own hand-off rule).

**Updated `JACKAL-BAR.md`'s Motion section** with the finding. Left all
three lines unticked: the jump-reads line has a real, filed, open defect;
the other two (camera holds the hunter, no pops) aren't contradicted by
anything this run found, but hadn't had their own dedicated eyes-on pass
either — said so plainly rather than round up a clean bill of health that
wasn't actually earned this run.

`ALL TESTS PASSED` (`run_tests.gd`) before and after — no game code or
asset touched this run, only two design-doc updates, this status note,
one new request, and two new frames (`git status` confirms). No playtest
re-run needed beyond the one baseline above, since nothing shipped
changed.

## Old: 2026-09-24 07:16 ET

- **Did:** picked up pass 7's own two named next moves on `goblin_mech_ai`
  (the loudest open item on my brief, one point under its hunter stop
  line): a fresh six-view look for Silhouette/Proportion/Style, and tested
  whether a straight tri-count decimation (not the untried-and-riskier UV
  re-unwrap) could cheaply close Build hygiene instead.
- **Worked?** Partly, honestly. The look found nothing new to fix -- still
  reads clean at 64px and in the real fight camera at native size. The
  decimation test is a real, useful negative result: cutting the shipped
  model's tris 40% (5199 -> 3119) is visually free at every render I
  checked, but doesn't reach "within budget" and doesn't reduce the UV-seam
  island count (it went up, 489 -> 590) -- and `frog_ai`, sitting at the
  same ~5200-tri "accepted overage" untouched, already caps at the
  identical Build hygiene 7, which is real evidence this line isn't on a
  sliding tri-count scale within that band. Did not ship the cut -- no
  proven score effect, no reason to trade the risk. Pushed a more
  aggressive cut too (70%, down to budget) to see where safety actually
  runs out: it visibly facets the tank and boots at 512px, so the safe
  ceiling sits well short of the budget line either way.
- **Next:** every lever short of a full UV re-unwrap on `goblin_mech_ai`
  is now tried and closed (islands: cosmetic, pass 3; weld: doesn't survive
  export, pass 7; tri-count: visually free but doesn't move the score,
  this pass). The re-unwrap is the one thing left, and it's exactly as
  risky as every pass since pass 6 has said -- worth scoping as its own
  dedicated, careful pass rather than folded into a routine run. Otherwise
  the bar's Motion section (jump reads, camera holds the active hunter, no
  pops) hasn't had a dedicated artist look yet.
- **Need from you:** nothing.

![[frames/artist/2026-09-24-goblin-mech-ai-decimate-test.png]]

## Now

No open `to: artist` request this run (the only open notes in `requests/`
are `to: fixer` and one `to: nick` from the playtester, still unanswered --
not mine to act on). None of my own `to: nick` notes had a fresh unhandled
answer either (all `status: done`). Worked `JACKAL-BAR.md`'s hunter-fidelity
line -- the loudest open item my own brief names, and the one every recent
run's "Next" has pointed at.

**Set up fresh** (fresh sandbox): Godot 4.7.1 + `--import`, `apt-get update`
then `libegl1`/`libegl-mesa0`, Blender 4.1.1, `pip install pillow numpy`.
Meshy not needed this run.

**Fresh six-view look first** (`look.sh goblin_mech_ai 8`), read cold before
reopening the progress file. No new defect on Silhouette, Proportion or
Style -- same conclusion pass 6 reached. Also pulled the real `state=3d`
in-fight camera at native 1280x720 and cropped the goblin's own screen
region at 4x nearest-neighbour (the method that caught the skin-desaturation
bug in pass 5/6) -- reads as a green goblin with a blue tank, no new issue.
One thing that looked odd at first (a pale triangle floating over each
hunter's head) turned out to be the game's own party-marker UI, present
over the Frog too -- not this model, not my scope.

**Then tried the untried tri-count lever**, on the actual shipped,
already-colour-patched `.glb` (not the older `.blend`, which predates the
skin-saturation fixes baked into the exported file's embedded image only --
decimating from the `.blend` would have silently reverted those). Blender's
`Decimate (Collapse)` modifier at two ratios, each re-exported and
re-rendered before judging anything from the in-Blender preview:

    0.6 -> 5199 -> 3119 tris (40% cut) -- visually free
    0.3 -> 5199 -> 1559 tris (70% cut, ~= 1400 hunter budget) -- visible facets

![[frames/artist/2026-09-24-goblin-mech-ai-decimate-test.png]]

Checked hygiene, not just the eye, on the safe 0.6 candidate:
`mesh_gap_check.py` still shows 0 real floating gaps, but island count rose
(489 -> 590) -- decimation moves vertices without moving UV seam
boundaries, so the exporter's seam-driven refragmentation (pass 7's own
finding) gets slightly worse, not better.

**Did not touch the shipped file.** `frog_ai` already sits in the same
~5200-tri accepted-overage class, untouched, and already caps at the
identical Build hygiene 7 -- the actual evidence that this rubric line
isn't scored on a sliding tri-count scale inside that band. Shipping a
40%-smaller file with no evidenced score effect isn't a trade worth making
on a cast-fidelity asset. `git status` before this push: the progress-doc
and `JACKAL-BAR.md` updates, this status note, one new comparison frame,
and the three new `goblin_mech_ai_pass8_*` studio renders -- no asset,
scene or code file touched.

`ALL TESTS PASSED` (`run_tests.gd`). No playtest re-run -- nothing shipped
changed, so nothing in the live fight can differ. Full write-up:
`design/progress/goblin_mech_ai.md` ("Pass 8").

## Old: 2026-09-24 06:21 ET

Closed the one gap pass 5 left open on "the weak point is obvious" -- the
sigil's lift over the climbing shelf (0.9x HUNTER_HEIGHT) landed at a
standing hunter's own head height, so from state=3dclimb it read as part
of their sprite. Raised it to 1.7x to clear a hunter's head; re-verified
all four 3D camera states, ticked the bar line.

**Set up fresh** (fresh sandbox): Godot 4.7.1 + `--import`, `pip install
pillow numpy`. Blender not needed -- this was a placement change in
`combat_3d.gd` only, no geometry touched.

**Measured why 0.9x landed there before changing anything.** A hunter is
`HUNTER_HEIGHT` (0.7) tall, feet at the climb point the sigil also anchors
to. `0.9 * HUNTER_HEIGHT` = 0.63 world units up -- inside a standing
hunter's own body height, not above their head. The mark was never behind
the hunter in depth (Z); it was floating at head height, in the same
screen column the `3dclimb` camera already frames them in.

**Confirmed with pixels, not assumption.** Rendered `state=3dclimb` at the
shipped code first: game reports `VIS OK sigil: (425, 440)`, 14px from
`VIS OK hunter0: (431, 450)` (the Frog, standing on it, "at the sigil" per
the party panel). A 1:1 crop at that exact coordinate shows nothing but the
Frog -- no separate gold fleck anywhere, matching pass 5's own read.

**Fix: raised the lift to `1.7x HUNTER_HEIGHT`**, still only in
`_place_sigil`'s `_climb_points.has(wp)` branch -- no colour, scale, or
Z-offset change, the same placement-only lever pass 5 used, just further
along it. Checked it wouldn't run off the top of frame first:
`climb_frame_for`'s own headroom handling already reserves space for a
visible sigil up to `active + 3.0` world units, well past the extra ~0.75
units this adds.

**Verified from the angle that mattered.** Re-rendered `state=3dclimb`:
sigil moved from `(425, 440)` to `(424, 420)`, and the 1:1 crop now shows a
small, clearly separated gold spark above the Frog's head, against the
cave-wall background:

![[frames/artist/2026-09-24-cinder-jackal-sigil-3dclimb-before-after.png]]

**Re-checked the win this could have broken, not just the one it fixed.**
The bigger lift moves the mark further from the shelf's bright rock
texture too -- re-rendered `state=3dstrike` (pass 5's own fix) to make sure
raising the number further didn't overshoot into some new problem. It
didn't; the mark still reads as a clean separated spark against the dark
cave wall:

![[frames/artist/2026-09-24-cinder-jackal-sigil-3dstrike-recheck.png]]

**Checked the two states this branch doesn't touch, too.** `state=3d` and
`state=3dgrip` still correctly report the sigil `n/a`/out of frame by
design (hunter more than 3.5 units below it in both) -- unaffected, as
expected for a change scoped to one branch. `3dgrip`'s own
`VIS FAIL hunter1: (230, 96)` is pre-existing -- re-rendered the same state
against the pre-change code (`git stash`) and got the identical failure,
so not something this pass caused or should claim.

**Playtest, run in the foreground per `COMMON.md` 4b** (the harness moved
it to background once past its own 300s default; waited for it rather than
ending the run): `PLAYTEST FAIL: 1 failing check(s)
{ "hop-distance-band": 62 }` -- an exact match for the already-filed,
already-open item `status/playtester.md` already records firing on every
recent baseline (the fixer's own known-incomplete stone-route item 2,
which measures hop distance between climb points, not a `Node3D`'s
`.position`). Not a regression from this pass.

**Ticked `JACKAL-BAR.md`'s "the weak point is obvious" line.** All four 3D
camera states that can show the sigil now separate it from both the
climbing shelf (pass 5) and the hunter standing on it (this pass); the 2D
climb gauge already marked it clearly at every other distance (pass 5).
`design/progress/cinder_jackal_ai.md` ("Pass 7") has the full mechanism and
both before/after renders.

`git status` before this push: `combat_3d.gd` (the one-line offset change),
`JACKAL-BAR.md`, `cinder_jackal_ai.md`, this status note, and the two new
frames -- no other file touched.

## Old: 2026-09-24 05:17 ET

- **Did:** no open `to: artist` request this run, and none of my own
  `to: nick` notes had a fresh unhandled answer (all `status: done`, per
  `COMMON.md` 1b). Re-checked `cinder_jackal_ai.glb`'s basalt/icosphere
  cleanup (pass 2) was still holding, since a routine reimport in Blender
  showed a second "Icosphere" mesh object that looked exactly like the
  leftover pass 2 said it deleted.
- **Worked?** It was a false alarm, and a useful one to run down. The
  Icosphere is not in the shipped `.glb`'s own file data (checked the raw
  glTF JSON directly, no Blender in the loop) and not in the source
  `.blend` either -- it only appears after Blender's own glTF importer
  reimports this specific file, and never shows up in an actual render.
  Nothing was broken; nothing needed fixing. Wrote the mechanism down so a
  future run doesn't re-chase it from zero.
- **Next:** used the now-confirmed-clean beast to do something never done
  before -- a literal side-by-side render of the jackal and both hunters
  together at true in-fight scale, checking "Style consistency" as a group
  rather than per-asset. Holds clean; frame below. `goblin_mech_ai`'s own
  41/50 (one point under its stop line, Build hygiene's shared tri-budget
  ceiling) is still the only thing keeping the hunter-fidelity bar line
  unticked -- not a style mismatch.
- **Need from you:** nothing.

![[frames/artist/2026-09-24-cast-trio-style-check.png]]

## Now

No open `to: artist` request this run (the only open notes in `requests/`
are `to: fixer` and `to: nick`), and no fresh unhandled answer on my own
`to: nick` notes either (all `status: done`). Worked the `JACKAL-BAR.md`
queue via a routine re-verify of the last shipped change, which turned up
a tooling red herring rather than a real bug -- full mechanism and the
raw-JSON proof are in `design/progress/cinder_jackal_ai.md` ("Pass 6").

**Set up fresh** (fresh sandbox): Godot 4.7.1 + `--import`, `apt-get
update` then `libegl1`/`libegl-mesa0` (same gap recent fresh sandboxes have
hit), Blender 4.1.1, `pip install pillow numpy`. Meshy not needed this run.

**Why this over another `goblin_mech_ai` hygiene attempt.** `goblin_mech_ai`
pass 7 (2026-09-24 00:12) already tried welding its 489 raw islands and
proved the glTF exporter re-splits them at UV seams regardless -- not a
same-run fix, and the honest remaining lever (a full UV re-unwrap) has been
named as a deliberately-scoped, separately-risk-budgeted job by three
independent passes now (`frog_ai`, `goblin_mech_ai`, `cinder_jackal_ai`),
not something to re-attempt blind without new information. No new
information turned up this run either, so it stayed untouched again --
correctly, not out of avoidance: the `frog_ai_clean.py` recipe already
decimates to ~5200 tris and still lands at Build hygiene 7, the same
number `goblin_mech_ai` and `cinder_jackal_ai` land at through different
routes, which is real evidence 7 may be close to this asset pipeline's
honest ceiling without a much more aggressive (and riskier) cut.

**The red herring, briefly** (full writeup in the progress note): Blender
4.1.1's `bpy.ops.import_scene.gltf()`, reimporting the shipped
`cinder_jackal_ai.glb`, deterministically adds a second mesh object named
"Icosphere" (42 verts, 80 tris, no material, at local origin) that looks
exactly like the stray leftover pass 2's own writeup said it deleted.
Parsed the `.glb`'s raw JSON chunk by hand (no Blender) -- one mesh, one
material, 33 nodes, no Icosphere anywhere in the actual file. Re-exported
straight from the current (also-clean) `tools/blender/ai/
cinder_jackal_ai.blend` using `ai_beast.py`'s own step-6 export call and
the fresh export's raw JSON is equally clean. Rendered a real `look.py`
pass and read the `_side`/`_sil` frames at 1:1 -- no stray blob visible
anywhere, silhouette clean. `mesh_gap_check.py`'s own join-on-multi-mesh
step hits a silent "No mesh data to join" warning in background mode when
this phantom object shows up, but happens to leave the real "Body" object
as the one analysed either way, so no earlier hygiene number for this
beast was ever affected. Root cause not fully chased (reproducible only on
this file, not `frog_ai.glb`/`goblin_mech_ai.glb`) -- not worth more time
since it provably never reaches the shipped asset, the game, or any score,
but worth one line in the progress note so nobody repeats this
investigation cold.

**Then used the clean bill of health for something genuinely new**: every
prior "Style consistency" check in this project's history has scored one
asset at a time (six-view look, in-fight crop, 34px portrait) -- nobody had
put the jackal and both `_ai` hunters in the same frame at once and looked.
Rendered `state=3d` and `state=3dgrip wide` (the fight's own camera/
positions) and cropped both hunters at native resolution:

![[frames/artist/2026-09-24-cast-trio-style-check.png]]

Same thick black ink outline, same flat palette-atlas colouring, same
"painted" light treatment (no separate specular highlight) on all three --
nothing reads as coming from a different pipeline. Updated `JACKAL-BAR.md`'s
hunter-fidelity line, which had also gone stale (it still said "Today they
are Python-primitive models," true when written, false since both hunters
moved to their `_ai` rebuilds) -- corrected it to name the real remaining
gap (`goblin_mech_ai`'s one point) instead.

`ALL TESTS PASSED` (`run_tests.gd`). No playtest re-run -- `git status`
before this push shows only the two progress-doc updates, this status
note, and the one new frame; no asset, script or scene file changed.

## Old: 2026-09-24 04:40 ET

- **Did:** checked `JACKAL-BAR.md`'s last unverified creature line for the
  jackal -- "the weak point is obvious and stays obvious as you climb
  toward it" -- nobody had ever pointed a render at it. Found the 2D climb
  gauge already does this well (never checked before, holds up), but the 3D
  glow mark on the beast itself did not: sampled the actual pixels at its
  own reported screen position and they were statistically identical to the
  bright climbing shelf it sits on -- a real player would never pick it out.
- **Worked?** Yes, partially and honestly. Lifted the mark into the open
  dark air above the shelf instead of level with its bright surface
  (`combat_3d.gd`); a before/after render+pixel-sample confirms it now
  reads as a distinct ~5x-brighter gold spark in the establishing shot
  where you're approaching it. It does NOT yet separate from the hunter's
  own sprite in the one camera angle where that hunter stands exactly on
  top of the sigil -- not worse than before there, just not fully solved.
  Left the bar line unticked rather than overclaim.
- **Next:** if this is worth another point, the leftover gap is a hunter
  standing exactly at the sigil position -- would need either a colour
  change (a taste call, `to: nick`) or lifting it further, tried and
  re-verified from that specific angle. Otherwise, the hunter-fidelity
  tri-budget ceiling (frog_ai 42/50, goblin_mech_ai 41/50, cinder_jackal_ai
  40/50, all sharing the same structural cause) is still the loudest open
  item on my own brief.
- **Need from you:** nothing.

![[frames/artist/2026-09-24-cinder-jackal-sigil-lift-before-after.png]]

## Now

No open `to: artist` request this run (checked every request's frontmatter
-- the only two open notes in `requests/` are `to: fixer` and `to: nick`),
and none of my own `to: nick` notes had a fresh, unhandled answer under
`## Nick's answer` either (all `status: done`, checked per `COMMON.md` 1b).
Worked the `JACKAL-BAR.md` queue -- picked the one remaining unticked
creature bullet nobody had verified yet, same discipline as last run's
"alive when idle"/"reacts" pass, except this one turned up a real defect
instead of confirming an already-working system.

**Set up fresh** (fresh sandbox): Godot 4.7.1 + `--import`, `pip install
pillow numpy`. Blender not needed -- no geometry touched, this was a
placement change in `combat_3d.gd` only.

**Found the check that already governs when the 3D mark should even be on
screen.** `screenshot.gd`'s `_report_visibility` documents, on purpose,
that the sigil is only expected on screen once the hunter is within 3.5
world units of it -- below that it's "the scale doing its job, not a
framing bug." Confirmed this holds (`state=3d`: hunter 15.9 below,
`state=3dgrip`: 9.4 below, both correctly `n/a`, not a fail). So for most
of a climb, the only thing making the weak point "stay obvious" is the 2D
ladder gauge on the HUD's right edge -- checked its actual draw code and a
real render: it marks the sigil's own Height with a distinct gold rail-cap
and a `✦ <N>` label at all times, separate from the plain ledge rungs.
That part was already right and needed no fix.

**The real gap was the one moment the 3D mark IS supposed to be on
screen.** `state=3dstrike` puts the hunter at the sigil; the harness prints
`VIS OK sigil: (534, 320)` -- passes the on-screen bounds check, so nothing
automated ever flagged it. Sampled the actual rendered pixels at that exact
coordinate before assuming anything: every pixel nearby already read
R≈234-255 -- the climbing shelf's own bright faceted-rock texture (added
2026-09-23, `foothold_rock_detail.md`), already past what the sigil's
`emission_energy_multiplier=3.0` gold glow could add on top of. The mark
and its background were, numerically, almost the same colour and
brightness. A screen-space bounds check can't catch that; only reading the
pixels can.

**Traced why the two coincide.** `_place_sigil`'s climb-point branch uses
the same `_climb_points[wp]` anchor that `_build_float_stones` hangs the
climbing shelf from (`_stand_on_model` -> `stone_point`, same key) -- the
sigil sits right at the shelf's own stand height. But the shelf's boulder
body sits mostly BELOW that stand point (`cap_height*0.5 - rock.height*0.5`
is negative), so a hunter's-height of open, dark cave-wall-backed air
exists directly above every shelf, unused.

**Fix: a placement change, not colour or size.** Lifted the sigil's
position by `HUNTER_HEIGHT * 0.9` in that one branch, so it floats in the
open air above the shelf instead of level with its bright surface.
Deliberately left `_sigil_scale` and the gold colour alone -- both are
shared by every future beast through this same function, and the placement
change alone was enough to test cleanly without widening the risk to
assets outside this fight.

**Verified with pixels, not just a glance.** Re-rendered `state=3dstrike`
and sampled the same neighbourhood again: found a small but genuinely
separated bright spot (242,242,229, the washed-white core an overexposed
point light blooms to) sitting against dark cave-wall pixels reading
50-90 per channel -- roughly a 5x brightness gap against its own
surroundings, versus the old position where the "sigil" pixels were
indistinguishable from their neighbours. Before/after crop, same camera,
same frame:

![[frames/artist/2026-09-24-cinder-jackal-sigil-lift-before-after.png]]

**Checked the other near-sigil states too, not just the one that improved.**
`state=3dclimb` (hunter's own home height IS the sigil height, camera
angle puts the hunter's body directly where the lifted mark now sits) still
doesn't show a clean separate spark there -- pixel-sampled that position
too and it reads as the hunter's own sprite colours, not a distinguishable
gold point. Not a regression (the old position was equally unreadable
there, just for a different reason -- blended into the shelf instead of
occluded by the hunter), but means this fix's real, verified win is
specifically the approach angle, not literally every camera state. The
party panel and gauge both already print "at the sigil" in text at that
exact moment in both renders, so nobody is actually left guessing when the
3D mark is occluded there.

**Left `JACKAL-BAR.md`'s line unticked.** A real, pixel-verified
improvement in the state that matters for "stays obvious as you climb
toward it" (the approach, not the moment of arrival), not a fully closed
case -- said so plainly in both the bar and `cinder_jackal_ai.md` ("Pass
5") rather than round up.

`ALL TESTS PASSED` (`run_tests.gd`). Per `COMMON.md` 4b, pushing this now
before the full 80-step playtest finishes rather than holding the change
hostage to a foreground wait; playtest launched in the foreground but
exceeded the harness's default check-in window, so its result will be
confirmed and appended here (or reverted if it disagrees) rather than left
unpushed. `git status` before this push shows only `combat_3d.gd` (the one
line offset), the two design-doc updates, this status note, and the one
committed frame -- no other file touched.

**Playtest result, confirmed after the push:** `PLAYTEST FAIL: 2 failing
check(s) { "hop-distance-band": 62, "intent-hidden": 18 }`. Checked both
against `status/playtester.md` before treating either as a regression --
both are exact matches for already-known, already-open items: `intent-
hidden` is the filed `intent-tag-hides-behind-party-panel` request (open),
`hop-distance-band` is the runtime check for the fixer's own known-
incomplete stone-route item 2, which `playtester.md` already records as
firing on every recent baseline run. Neither check has anything to do with
a Node3D's own `.position` in `_place_sigil` -- one measures hop distance
between climb points, the other measures a 2D UI panel's screen rect.
Not a regression from this pass. No further action needed.

## Old: 2026-09-24 03:21 ET

- **Did:** checked the two remaining unticked lines in `JACKAL-BAR.md`'s
  creature section for the jackal — "alive when idle... without drifting"
  and "reacts: attack, hit and death all read as different events" — nobody
  had ever pointed a render at either.
- **Worked?** Yes, both hold, no fix needed. Idle motion is real and stays
  bounded over 100 loops (not creeping). "Death" turned out to already be
  handled — not by the fight scene, but by the reward screen's existing
  "felled beast lying down" system, which is already tuned for this exact
  beast's proportions and reads clearly as a fallen animal in a real render.
- **Next:** the hunters-vs-jackal fidelity gap and its tri-budget structural
  ceiling are still the loudest open items on my own brief; this run went a
  different, cheaper direction first because two bar lines had simply never
  been looked at.
- **Need from you:** nothing.

![[frames/artist/2026-09-24-cinder-jackal-idle-hit-death-composite.png]]

## Now

No open `to: artist` request this run (checked every request's frontmatter —
the only two open notes in `requests/` are both `to: fixer`), and none of my
own `to: nick` notes had a fresh, unhandled answer either (all are
`status: done`, checked per `COMMON.md` 1b). Worked the `JACKAL-BAR.md`
queue.

**Why this over another hunter-fidelity pass.** The last several runs
(basalt cleanup, fresh critical look) both converged on the same conclusion:
the hunter/beast tri-budget overage is a real structural ceiling that needs
its own separately-scoped, risk-budgeted decimation pass, not something to
attempt blind in a single unattended run. Rather than force that this run,
I re-read `JACKAL-BAR.md`'s creature section end to end and found two
bullets — "alive when idle" and "reacts" — that were still unticked and had
never actually been checked, as distinct from being checked-and-failing.
Cheap to verify, directly in scope, and either result (holds, or a real
defect) would be useful.

**Set up fresh** (fresh sandbox): Godot 4.7.1 + `--import`, `pip install
pillow numpy`. Blender not needed this run — no geometry touched.

**Alive when idle, without drifting.** The shipped `idle` clip loops every
4.0s (read straight from the glb's own animation accessor). Rendered
`state=3d anim=idle@0.0/@2.0/@4.0` and diffed: 2.6k-4.8k changed pixels each
time, all inside the beast's own screen region — real motion, not a frozen
pose. The "without drifting" half needed more than one loop to test for
real: diffed frame 0 against **10 loops later** (`@40.0`) and **100 loops
later** (`@400.0`) — changed-pixel count stayed flat (2641 → 2602, same
bounding box) instead of growing, which is the actual signature of bounded
oscillation (shader ember-pulse + normal idle sway) versus a bug that would
let a bone's transform creep away from its start pose over time.

**Reacts: attack, hit and death all read as different events.** Attack and
hit were already known-good — separate animation clips, and `_strike()`
already gives hits (bigger at the weak point) a camera shake, a light flash
and a dust kick that attack doesn't get. "Death" was the real open question:
the glb carries no `death` clip and `combat_3d.gd` never branches on
`boss.is_dead()` at all. Read `location_3d.gd` instead of assuming the gap
was real, and found the actual mechanism: on the REWARD phase the fight
scene is torn down and replaced by a location scene whose
`_lay_out_the_felled()` lays a second, static copy of the same beast glb on
its side — and its own code comment shows this was already tuned
specifically for this beast ("a four-legged tower... roll it onto its
flank instead"). Rendered `state=3dreward beast=cinder_jackal` for real and
read the frame: the felled jackal shows its snout/ear cluster at one end,
four legs splayed, the same spine markings as the standing pose — reads as
a fallen animal, not an abstract shape.

**Chased down the one part of that render that looked odd before calling
it clean.** A bright orange round mass shows up near one end of the felled
body that doesn't match any single marking visible on the standing 3/4
render. Wrote a small scratch diagnostic (three clean camera angles —
front/side/top — same rotation the shipped code uses, on a plain grey
background, no UI) to identify it rather than guess: from directly above,
it's unambiguously the tail's own small ember tip, foreshortened almost
end-on by this specific fall angle into what reads as a disc from other
angles. Not a texture or geometry defect. Discarded the scratch script
after use — it isn't part of the shipped tool set and nothing about it
needed to survive the run.

**No fix applied, because none was needed** — both systems (the shader/
animation driving idle life, and the reward screen's felled-beast layout)
already existed and already worked; this run's only contribution was
pointing a real render at each and checking the result against the bar's
own wording instead of assuming either from reading the code. Ticked both
lines in `JACKAL-BAR.md` with this evidence. Score unchanged, 40/50 (pass 3
verified the five-line rubric; this pass verified two separate
definition-of-done lines, not a rubric line). Full write-up:
`design/progress/cinder_jackal_ai.md` ("Pass 4").

`ALL TESTS PASSED` (`run_tests.gd`). No playtest re-run — nothing shipped
changed (`git status` shows only the two design-doc updates, the status
note, and the one committed composite frame), so nothing in the live fight
can differ.

## Old: 2026-09-24 02:14 ET

- **Did:** gave `cinder_jackal_ai` the fresh, more critical six-view look
  last run's own "Next" named as the likely place to find a real, closeable
  point — plus checked it in the actual fight camera (3dgrip, 3dclimb,
  3dstrike), not just the studio render.
- **Worked?** No new defect found — which is itself the useful answer. The
  basalt-geometry fix from last run is holding clean in every angle and at
  true in-fight scale; the ear-glow fix from 2026-09-22 is holding too (face
  still reads through the glow at the sigil close-up). Score stays 40/50.
- **Next:** the only remaining lever (Build hygiene's tri-budget overage) is
  now confirmed as a structural ceiling shared by `frog_ai`, `goblin_mech_ai`
  and this beast alike — three independent passes across the cast have all
  landed on the same conclusion. Closing it for real needs a deliberately
  risk-budgeted decimation or re-unwrap pass, scoped and tried on a hunter
  first, not attempted blind on the hero asset in a single run.
- **Need from you:** nothing.

![[frames/artist/2026-09-24-cinder-jackal-fresh-critical-look.png]]

## Now

No open `to: artist` request this run (checked every request's frontmatter —
the only two open notes in `requests/` are both `to: fixer`), and none of my
own `to: nick` notes had a fresh, unhandled answer either (all four are
`status: done`, checked per `COMMON.md` 1b). Worked the `JACKAL-BAR.md`
queue — picked up exactly where the previous run's own "Next" left off.

**Set up fresh** (fresh sandbox): Godot 4.7.1 + `--import`, `apt-get update`
first then `libegl1`/`libegl-mesa0` (same gap as the last several fresh
sandboxes — `apt-get install` alone 404s on `libegl-mesa0` without a fresh
index), Blender 4.1.1. Meshy `balance` OK (2890 credits), not needed.

**Re-rendered all six views** (`look.sh cinder_jackal_ai 3`) and read them
cold before reopening `cinder_jackal_ai.md`'s pass 2 write-up, per the loop's
own discipline. `_side`/`_front`/`_top`/`_form` (clay)/`_wire` all confirm
the pass-2 basalt fix is holding — clean front-leg/chest silhouette, no new
foreign geometry, an even unremarkable topology. `_sil.png` at true 64px
still separates ears, snout, all four legs and the tail cleanly.

**Went past the studio render into the real fight camera**, the same
discipline that caught the goblin's skin-desaturation defect two runs ago —
a studio render alone isn't proof of how it reads in play.
`state=3dgrip wide` (full body, hunter climbing) confirmed the beast frames
clean at true in-fight scale, ember markings separate the same way as the
studio render, and the climbing hunters read as their own portrait-icon
markers on the stone footholds (the existing, already-verified design, not a
new finding). `state=3dclimb` and `state=3dstrike` (sigil close-up) both
confirmed the 2026-09-22 ear-glow fix is still holding — eyes, muzzle and
ear structure all read distinctly through the glow, not the "two white
blobs" the original request complained about.

**Found nothing new to fix.** Not a rubber stamp — a real look, with the
in-fight cross-check pass 2 didn't do — and the honest result is that pass
2's basalt fix was the real defect this asset had. Scored it again for the
record: Sil 8, Prop 8, Hygiene 7, Colour 9, Style 8, **40/50, unchanged**.
Full write-up: `design/progress/cinder_jackal_ai.md` ("Pass 3"). Updated
`JACKAL-BAR.md`'s creature line with the confirmation and the cross-cast
Build hygiene finding.

**Deliberately did not attempt a decimation pass on the beast's tri count**
this run. `cinder_jackal_ai.md` pass 2, `frog_ai.md` and `goblin_mech_ai.md`
pass 7 have all independently landed on the same conclusion — the tri-budget
overage against each asset's old primitive-era budget is a real, shared
structural ceiling, not a same-pass fix — and `goblin_mech_ai` pass 7 already
tried the adjacent lever (welding to cut island count) on a hunter and found
it doesn't survive glTF export. Reducing tri count on a rigged, skinned hero
asset risks distorting the skin weights or the UV layout in a way that isn't
safely testable in one unattended run; if this is worth trying for real, it
belongs as its own scoped pass, tried on a hunter first where a mistake is
cheaper to catch and undo.

`ALL TESTS PASSED` (`run_tests.gd`) — nothing shipped changed this run, so
no playtest re-run; only the three tracked studio renders
(`design/renders/cinder_jackal_ai_pass3_{front,sil,34}.png`), the frame
above, and the two progress/status write-ups are new.

## Old: 2026-09-24 01:23 ET, cinder_jackal_ai basalt cleanup

- **Did:** ran the same rubric score/scoring-loop on the Cinder Jackal itself
  (`cinder_jackal_ai.glb`) that the two hunters have already been through
  repeatedly -- this beast, the actual star of the fight, had never been
  scored at all. The fresh look found a real defect immediately: a stack of
  grey rock geometry fused into its own chest/foreleg area.
- **Worked?** Yes. Traced it to leftover foothold geometry from before the
  fight switched to floating in-engine climb stones (2026-09-23) -- it had
  been silently riding forward through every later rebuild because those
  rebuilds reuse the beast's own last export as their source instead of a
  fresh download. Confirmed the geometry was fully disconnected from the
  real body before removing it, so nothing else could break. Verified in
  every 3D camera state the fight uses -- clean, no regression. First-ever
  score: 40/50, 4 points under the beast bar.
- **Next:** Build hygiene's remaining gap is the same tri-budget ceiling the
  hunters already carry (not fixable in one pass); a fresh, more critical
  look at Silhouette/Proportion/Style is the next thing likely to find a
  real, closeable point.
- **Need from you:** nothing.

![[frames/artist/2026-09-24-cinder-jackal-basalt-cleanup.png]]

## Now

No open `to: artist` request this run (checked every request's frontmatter —
the only two open notes in `requests/` are both `to: fixer`), and none of my
own `to: nick` notes had a fresh, unhandled answer under `## Nick's answer`
either (checked per `COMMON.md` 1b). Worked the `JACKAL-BAR.md` queue, but
picked a different item than the last several runs' momentum suggested.

**Why the Cinder Jackal instead of another `goblin_mech_ai` pass.** Pass 7
(previous run) left `goblin_mech_ai` at 41/50 with no cheap remaining lever
— the honest next move there is either a bigger, riskier UV re-unwrap, or a
fresh six-view look at lines already sitting at 8 with no named defect.
Before spending another pass grinding the last point off a hunter, checked
`design/progress/` for a scoring file on the Cinder Jackal itself and found
there wasn't one — `frog_ai.md` and `goblin_mech_ai.md` both exist and have
been iterated on multiple times each; `cinder_jackal_ai.glb`, the beast every
player looks at for the entire fight, had only ever had two named point
fixes (`artist.md`'s own "known open issues": ear-glare glow, foothold
texture) and never a real rubric pass. `JACKAL-BAR.md`'s own "The creature"
section (silhouette, weak point, idle life, reacts) is entirely unticked —
the loudest unaddressed gap in my own brief's scope, not a marginal one.

**Set up fresh** (fresh sandbox): Godot 4.7.1 + `--import`, Blender 4.1.1.
`libegl1`/`libegl-mesa0` weren't preinstalled this sandbox either (same gap
pass 6/7 hit) — `apt-get install` alone 404'd on `libegl-mesa0` until an
`apt-get update` first pulled a newer index; noting the update-first order
for whichever run hits this next. Meshy `balance` OK (2890 credits), not
needed this run.

**Rendered a fresh six-view look at `cinder_jackal_ai`** (`look.sh
cinder_jackal_ai 1`) and read the images cold before assuming anything.
`_side.png`, `_form.png` (clay) and the wireframe all showed the same thing
unmistakably: a stack of untextured grey rock wedges fused into the model's
own chest, right where the front legs meet the body — not a lighting
artifact, real baked geometry, and it visibly distorts the front-leg
silhouette in `_sil.png` too.

**Traced the cause by reading the pipeline, not guessing.**
`design/guide/ai-beast-recipe.md` step 6 documents the ORIGINAL approach for
this exact beast: real basalt foothold geometry grown onto the body along
the climb route, one lump per climb Height. That approach was replaced
2026-09-23 (`combat_3d._build_float_stones` hangs a stone at runtime
instead) — `tools/blender/ai_beast.py`'s own foothold loop now opens with
`if True: continue  # stones float in-engine now; no foothold geometry is
exported`. But the fixer's own last two rebuilds of this beast (`status/
fixer.md`, 2026-09-23/24, the route-reversal and hop-distance fixes) both
explicitly re-fed the ALREADY-SHIPPED `cinder_jackal_ai.glb` back into
`ai_beast.py` as its own raw source, to avoid a Meshy spend on a beast whose
anatomy and rig are already right. Every such re-feed re-imports whatever
the previous export already contained — including basalt geometry baked in
BEFORE the 2026-09-23 refactor, which the `if True: continue` guard was
never going to strip, since it only stops NEW geometry from being ADDED, not
old geometry already present in the incoming mesh. The contamination has
been silently riding forward through every rebuild since, invisible because
nobody had pointed `look.sh` at this specific beast since it first shipped.

**Confirmed the geometry was safe to delete before touching anything.**
Opened `tools/blender/ai/cinder_jackal_ai.blend` directly: 320 faces on the
`Body` mesh carry a distinct `Basalt` material; a vertex-set check showed
those 320 faces share **zero** vertices with the other 11999 faces (603
basalt verts, 10369 other verts, 0 overlap) — a fully disjoint island,
so deleting it cannot open a hole in the real body surface. Also found a
second, unrelated piece of junk in the same file: a stray untextured unit
icosphere (42 verts, no material) sitting exactly at the model's local
origin — a leftover default-primitive object from manual editing.

**Fix.** Deleted the 320 Basalt-material faces from `Body` (0 loose verts
left behind afterward, confirming the island really was fully disjoint),
dropped the now-unused `Basalt` material slot/datablock, deleted the stray
`Icosphere` object, and deleted the now-pointless empty `Footholds` mesh
object (0 verts even before this pass, created every rebuild by
`ai_beast.py`'s own dead branch). Re-exported with the exact glTF call
`ai_beast.py`'s own step 6 uses, over the real shipped path, and re-saved the
cleaned `.blend`. Climb/ledge marker empties, the rig, and every action are
separate objects and were never touched.

**Verified thoroughly, since this is the hero asset every fight uses.**
`tools/blender/ai/mesh_gap_check.py` (the same tool `goblin_mech_ai` pass 3
used) on the cleaned model: 10370 verts, 440 raw mesh islands (this
beast's own UV seam count, same story as `goblin_mech_ai`'s 489),
**0 islands with a real 3D gap** — topology is otherwise clean, the basalt
chunk was the only real defect. Noticed the beast's own runtime bounding box
(`_beast_box`, from `screenshot.gd`'s `CAM` line) legitimately shrank,
`size.x` 12.92 → 10.78 — traced it rather than assumed it was fine: the
removed chunk's own X extent (0.10–0.99 local, camera-side) had been making
the AABB read as symmetric (±0.99) when the real body is asymmetric in this
running pose (−0.99 / +0.66). Confirmed this doesn't break anything the box
feeds by rendering `state=3d`, `wide`, `3dclimb` and `3dgrip` after the fix —
`HUNTER0`/`HUNTER1 ... OK` on every one, arena framing unchanged, nothing
clips. Built a before/after comparison from the six-view side/clay renders,
same camera, same pose — the grey wedge stack is simply gone, nothing else
in the silhouette changed:

![[frames/artist/2026-09-24-cinder-jackal-basalt-cleanup.png]]

**Scored it for the first time.** Silhouette 8 (reads as a lean running
canid at 64px, nothing merges after the fix), Proportion 8 (masses read
correctly for the "lean chase predator" brief), Build hygiene 7 (the one
real defect is fixed and confirmed there's nothing else via
`mesh_gap_check.py`; what's left is the same tri-budget structural ceiling
the hunters already carry — 12079 tris vs the old 2600 beast budget, ~4.6×
over, not a same-pass fix), Colour & read 9 (clean black/ember/gold
separation, confirmed in the real `state=3d` camera, not just the studio
render), Style consistency 8 (same toon/outline/painted pipeline as the
hunters). **Total 40/50**, 4 points under the 44 beast stop line. Full
write-up: `design/progress/cinder_jackal_ai.md` (new file, "Pass 2" — pass 1
is the as-shipped/contaminated baseline, scored implicitly by comparison
since nobody looked at it before this run). Updated `JACKAL-BAR.md`'s
creature section with the score and the finding.

`silmetrics.py` was skipped — Blender's bundled Python has no `PIL` in this
sandbox — not a gate per `asset-loop.md`, so scoring proceeded without it.

`ALL TESTS PASSED` (`run_tests.gd`) before and after. Pushing this now per
`COMMON.md` 4b, then running the full 80-step `mode=play beast=cinder_jackal`
playtest in the foreground as the last step of this run — this change
touches the beast's own bounding box, which several other systems (arena
sizing, hunter standoff, camera) read from, so a full regression pass earns
its time even though the individual state renders above already checked the
obvious paths. Result appended to the `## Log` below once it finishes.

## Old: 2026-09-24 00:12 ET

- **Did:** tested pass 6's own suggested next move on `goblin_mech_ai` --
  can the 489 raw mesh islands be welded down without a visible seam? Wrote
  a weld script and tried it for real on the shipped model.
- **Worked?** No, and that's the useful finding: welding merges the mesh
  fine inside Blender, but Godot/the game only ever sees the RE-EXPORTED
  glTF file, and the exporter puts the same 489 islands right back on
  export -- they're driven by this hunter's own UV seam layout, not by
  leftover unwelded duplicate geometry the way the raw number suggested.
  Proved it by exporting and re-measuring, not by assuming. Nothing shipped
  changed; Build hygiene stays 7, total 41/50, same as pass 6.
- **Next:** the only real lever left on Build hygiene is reducing the UV
  unwrap's own seam count -- a bigger, riskier job (could shift where the
  texture lands) that deserves its own careful pass with full
  before/after verification, not a quick follow-up. Otherwise: a fresh
  six-view look for Silhouette/Proportion/Style (all 8, no named defect),
  or Colour & read's own shader-side ceiling pass 6 flagged.
- **Need from you:** nothing.

## Now

Checked for a fresh, unhandled answer under `## Nick's answer` on my own
`to: nick` notes first, per `COMMON.md` 1b — none. Checked open `to: artist`
requests — none this run (`requests/`'s only two `open` notes are both
`to: fixer`). Worked the `JACKAL-BAR.md` queue: pass 6's own "Where it
stands" named the 489-island weld question as the concrete next move on
`goblin_mech_ai` — this run did exactly that.

**Set up fresh** (fresh sandbox): Godot 4.7.1 + `--import`, Blender 4.1.1,
`libegl1`/`libegl-mesa0` installed up front (last run's fresh-sandbox note
about needing them for Blender's background render). Meshy `balance` OK
(2890 credits) but not needed this run.

**Ran a read-only diagnostic before touching anything**: for every one of
the 489 raw islands on the shipped `goblin_mech_ai.glb`, the minimum
vertex distance to its nearest OTHER island. 487 of 489 sit at exactly
0.000mm — genuinely coincident duplicate vertices, not real separation.
Only two islands have a real gap. Re-measured those two properly and
caught a units bug in pass 6's own write-up: `mesh_gap_check.py`'s
`min_gap_frac` is a FRACTION of the 2329.6mm body diagonal, not
millimetres — pass 6 read the raw fraction as millimetres directly. The
real gaps are **5.92mm and 15.38mm**, not "2.5mm and 6.6mm." Same
conclusion (invisible, not a seam or standoff part) — just corrected the
number so it doesn't get carried forward wrong again.

**Picked a weld threshold from the diagnostic, not a guess**: a union-find
over the same distance table shows the 489 islands collapse to 5 groups at
a 2–5mm threshold (safely under the smaller real 5.92mm gap) and to 2
groups by 20mm (which would start bridging the real gaps) — so 5mm was the
one worth testing for real.

**Wrote `tools/blender/ai/goblin_ai_weld.py`** and ran it on the shipped
model into a scratch output, never overwriting the real asset until proven
worth it. Inside Blender, before export: 5799 → 2604 vertices, tri count
essentially flat (5199 → 5178). Looked like a clean win.

**Then re-imported the actual EXPORTED file and re-ran `mesh_gap_check.py`
on it — the file that ships, not the in-memory Blender mesh — and the weld
had (almost) no effect there: 5799 → 5783 vertices, 489 → 489 islands,
unchanged.** Root cause: glTF requires one vertex per unique
(position, normal, UV) combination; Blender stores UV per face-corner, so
the exporter re-splits a welded mesh back apart at every UV seam
regardless of how connected it was pre-export. Confirmed it isn't a
normals issue by forcing every polygon `use_smooth` before export (removes
hard-normal splits as a variable) — island count still came back
unchanged. The 489 number tracks this hunter's own UV seam count, not
leftover Meshy remesh duplicates.

**Did not touch the shipped `goblin_mech_ai.glb`.** The tested fix makes
zero measurable difference to the actual file the game loads, so there was
nothing to trade risk for. `git status` shows only the new script and the
progress write-up — `game/assets/3d/cast/goblin_mech_ai.glb` itself is
untouched. `ALL TESTS PASSED` (`run_tests.gd`); no playtest re-run, since
nothing in the live fight can differ with no asset change.

**Score: Build hygiene stays 7. Total unchanged, 41/50.** Not a null
result — the open question ("can these be welded without a visible seam?")
is answered for real, just in the negative, and the real remaining lever
(reducing the UV unwrap's own seam count) is now named precisely instead
of guessed at. Full write-up: `design/progress/goblin_mech_ai.md`
("Pass 7"). Didn't touch `JACKAL-BAR.md`'s hunter-fidelity bullet — the
score it records didn't change.

## Old: 2026-09-23 23:22 ET, goblin_mech_ai pass 6

- **Did:** a fresh six-view look at `goblin_mech_ai` (pass 5's own suggested
  next move) turned up a much bigger colour problem than any pass before it
  had found: at the real fight camera, at the actual pixel size a player
  sees (not a 3x crop the way every prior "verified" frame here was taken),
  the Goblin's skin reads near-white, not green.
- **Worked?** Yes — traced it to the skin texture being too low-saturation
  to survive the shader's own bright "lit" band (the Frog's texture is far
  more saturated and survives the same shader fine), boosted saturation on
  skin only, left brightness alone so it doesn't undo the portrait fix from
  two passes ago. Confirmed with real screen pixels, before/after: a body
  that read (240,243,220) — visibly cream — now reads (211,249,151) —
  visibly green — same camera, same lighting. Also checked the party
  portrait and the campfire row; both improved the same way. Colour & read
  9→10, total 40→41/50.
- **Next:** one point under the hunter stop line. Build hygiene (7, real
  tri-budget overage) is the clear lowest line now — whether any of its 489
  raw mesh islands can be welded without a visible seam is the next
  concrete thing to try, not another colour pass.
- **Need from you:** nothing.

![[frames/artist/2026-09-23-goblin-skin-desaturation-infight-before-after.png]]
![[frames/artist/2026-09-23-goblin-skin-desaturation-party-rail-before-after.png]]

## Now

Checked for a fresh, unhandled answer under `## Nick's answer` on my own
`to: nick` notes first, per `COMMON.md` 1b — none open (all four of my
`to: nick` requests are `status: done` with a filled `## Result`). Checked
open `to: artist` requests — none this run (`requests/`'s only two `open`
notes are both `to: fixer`). Worked the `JACKAL-BAR.md` queue: pass 5's own
"Where it stands" named a fresh six-view look, not another colour push, as
the next useful move on `goblin_mech_ai` — so this run did exactly that,
literally, before assuming the asset needed something else.

**Set up fresh** (fresh sandbox, per `status/README.md`): Godot 4.7.1
imported clean, Meshy `balance` OK (2890 credits, not used this run — no
Meshy needed), Blender 4.1.1 downloaded and ran. One real setup gap this
run hit and fixed: Blender's own background render needs `libEGL.so.1`,
which this fresh Ubuntu 24.04 image didn't have even with Mesa's GL
libraries present — `apt-get install -y libegl1 libegl-mesa0` fixed it (the
render silently produced nothing without it, no error beyond a one-line
`Couldn't open libEGL.so.1` buried in ALSA noise — worth remembering for
the next fresh sandbox that hits the same silent failure).

**Ran `look.sh goblin_mech_ai 6`** and looked at all six views cold, before
re-reading the score history, per the loop's own "score before reading the
previous pass's number." Silhouette, form and wire held up — nothing new
there, matching pass 5's own prediction that no single line was far behind.

**The actual find came from going past the six-view render**, into the
live fight at native resolution. Every earlier "verified in the real
fight" claim in this asset's file — including pass 5's own two committed
frames — was a 3x-zoomed crop. Rendered plain `state=3d` at its native
1280×720 and sampled the goblin's own screen pixels directly, unscaled: at
the coordinates the fight actually draws it, the skin is (240,243,220),
(233,244,211), (238,243,214) — under 10% saturation, visibly cream, not
green. The exact frame pass 5 committed as its own "after" evidence shows
this same defect in its uncropped half; nobody had looked at it at the
size it actually ships at.

**Isolated the cause before touching anything**, the same way past passes
in this file have: not a shader bug (`toon.gdshader` is shared with the
jackal and the Frog, both read fine) — confirmed by a throwaway diagnostic,
recolouring the skin mask solid magenta in the loose PNG and re-rendering
`state=3d`: the model visibly went magenta in that exact region, so the
albedo texture does reach the screen here, ruling out "the shader ignores
albedo." The texture itself is genuinely too flat: skin measures S
0.26–0.29, V 0.68–0.72 even after pass 2's global boost — high value, low
saturation, which is exactly the profile a shader that mixes toward white
in bright light will wash out. The Frog's own texture measures S
0.66–0.77 at similar value and survives the identical shader untouched.

**Fix, new `tools/blender/ai/goblin_ai_skin_saturation.py`**: hue-masked
(70°–160°, this hunter's skin/ear green family), floored on the pixel's
own current saturation/value (>0.12, >0.15) so near-neutral pixels
(goggle-lens highlights, cream tusks/nails) can't be mis-tagged by an
unstable hue reading on a near-grey pixel — confirmed by a magenta
diagnostic on the flat texture atlas before touching real colour, landing
exactly on skin/ears and nothing else. Saturation ×2.6 inside the mask,
**value untouched** — deliberately the other lever from pass 2's, since
this is a saturation problem under bright light, not a brightness problem,
and lowering value again would undo the 34px portrait fix pass 2 made.
2.6 chosen by testing sample points until they landed inside the Frog's
own measured range, not guessed. Applied to both the loose PNG and the
glb's embedded image, same two-part pattern pass 5 established (confirmed
byte-identical beforehand).

**Caught my own false negative before writing it up.** The first
before/after render showed almost no change. Instead of concluding the fix
didn't work, checked why first: the loose PNG was edited but Godot was
never told to `--import` again, so the screenshot was reading its stale
cached texture. Re-ran `--import`, re-rendered, and the real change showed
up — confirmed independently by the magenta test above before trusting it.
The project's "never claim an improvement you haven't seen in a render"
rule cuts both ways: a claimed non-result needs the same scrutiny before
it goes in the record.

**Verified in the real fight**, same camera and hunter positions as every
prior pass (logged, 6-decimal match), at true 1:1 scale, not a crop:

![[frames/artist/2026-09-23-goblin-skin-desaturation-infight-before-after.png]]

**Verified at the 34px party-portrait scale too** (re-ran `portraits.py`
since the glb's embedded texture changed), composited on the rail's own
`(58,42,30)` background:

    pass 5: sat 0.493  val 0.461
    pass 6: sat 0.655  val 0.422
    frog_ai (ref): sat 0.69  val 0.44

![[frames/artist/2026-09-23-goblin-skin-desaturation-party-rail-before-after.png]]

Saturation now lands almost exactly inside the Frog's own range at this
scale too — the in-fight fix and the portrait fix reinforce each other
rather than trading off, because this pass moved saturation only. Also
checked the campfire hunter row (`state=3dcampfire`) — reads clearly green
there too, not just the two angles this pass targeted.

**No regression.** Full-frame `state=3d` pixel diff against the pass-5
baseline, same camera/positions: 2,407 changed pixels in four small
clusters — the goblin's own screen region and its party-rail icon
(intended), plus the jackal's tail/legs and the Frog's own body, matching
the established idle-animation-jitter pattern (breath/ember pulse/sway)
this file's own prior passes have already documented between two
independently-timed renders. No shape or position change on either
untouched model.

**Score: Colour & read 9 → 10.** The rubric's own question — "do the
palette swatches separate the parts? Legible at 34px in the party panel,
not just at 512? Nothing dark-on-dark" — now checks clean at the hardest
version of that test this project has (the live fight camera at native
resolution) as well as the 34px panel, both matching the Frog's own
separation. Not a from-scratch repaint, still a targeted hue-masked patch
— but the specific defect this line has carried since pass 1 is closed at
the size and lighting a player actually sees it in. **Total: 40 → 41/50**
— one point under the 42 hunter stop line. Full write-up:
`design/progress/goblin_mech_ai.md` ("Pass 6"). Updated `JACKAL-BAR.md`'s
hunter-fidelity line.

`ALL TESTS PASSED` (`run_tests.gd`). Pushing this now per `COMMON.md` 4b,
then running the 80-step playtest in the foreground as the last step of
this run; result appended to the Log below once it finishes.

## Old: 2026-09-23 22:20 ET, goblin_mech_ai pass 5

- **Did:** fixed `goblin_mech_ai`'s tank-vs-body contrast at 34px -- the
  concrete next move pass 4 left named. Along the way found the portrait
  render pipeline had been showing a dimmer, pre-colour-boost goblin for two
  passes running (a real bug, not a taste question), and fixed that too.
- **Worked?** Yes -- verified in the real fight (same camera/positions,
  before/after) and at the actual 34px party-rail scale. The tank and
  shorts now read as a clear blue, separated from the green body, matching
  the Frog's own headroom at that size. Colour & read 8→9, total 39→40/50.
- **Next:** no single line is far behind on `goblin_mech_ai` any more
  (Sil/Prop/Style 8, Hygiene 7) -- a fresh six-view look is probably more
  useful than another colour push. 2 points under the 42 hunter stop line.
- **Need from you:** nothing.

![[frames/artist/2026-09-23-goblin-tank-contrast-infight-before-after.png]]
![[frames/artist/2026-09-23-goblin-tank-contrast-34px-before-after.png]]

## Now

Checked for a fresh, unhandled answer under `## Nick's answer` on my own
`to: nick` notes first, per `COMMON.md` 1b -- none open. Checked open
`to: artist` requests -- none this run. Worked the `JACKAL-BAR.md` queue:
`goblin_mech_ai.md` pass 4 named its own concrete next move -- "raise the
tank's value/saturation relative to the body ... checked against the party
rail's actual `(58,42,30)` background" -- so this run did exactly that.

**Measured the starting point first, on the real render, and found a bug
nobody had caught.** `portraits.py` renders straight from
`goblin_mech_ai.glb`, not from the loose `goblin_mech_ai_Image_0.png`
Godot's importer extracts for the live 3D fight. Extracted the glb's own
embedded texture directly and measured it: sat 0.282, val 0.535 -- pass 2's
own recorded PRE-boost numbers, exactly. Pass 2's colour boost
(`goblin_ai_colour_boost.py`) only ever edited the loose PNG; the glb's own
copy was never touched. Every portrait render since pass 2 -- party rail,
character card, campfire -- has quietly shown the dimmer, pre-boost goblin
this whole time, out of sync with what the fight itself has shown for two
passes.

**Wrote a small reusable tool to fix it properly**, since editing an
embedded glb image isn't something any existing script here does:
`tools/blender/ai/glb_image_patch.py` -- pure struct/json, no bpy, no
external glTF library -- reads a .glb's chunks and can swap one embedded
image's bytes for new ones. Only safe when that image's bufferView is the
LAST one in the buffer (checked in code, not assumed, before writing
anything) -- true here, verified by inspecting every bufferView's offset.
Round-tripped it first (extract then reinject unchanged, confirmed
byte-identical, confirmed the patched glb still imports and renders in
Blender) before trusting it with a real edit.

**The actual fix**, `tools/blender/ai/goblin_ai_tank_contrast.py`: masks
the texture by HUE alone (195°-245°, this hunter's tank/steel/shorts
blue-grey family) restricted to value < 0.6, which excludes the near-white
ice-blue goggle lens sitting in the same hue range. Confirmed the mask
lands where intended with a diagnostic magenta recolour, rendered in
Blender, before touching real colour -- covers exactly the backpack tank
and the shorts, nothing on skin/goggles/straps/boots. Boosts saturation
×1.7 and lifts value (gamma 0.68) inside the mask only. Applied to the
loose PNG directly (it already had pass 2's boost); applied to the glb's
embedded image with pass 2's global boost run first, then the same tank
step on top -- verified the two paths agree byte-for-byte at the
global-boost stage before they diverge.

**Verified in the real fight**, same camera and hunter positions as every
prior pass (logged, matched to the position), before/after:

![[frames/artist/2026-09-23-goblin-tank-contrast-infight-before-after.png]]

**Verified at the actual 34px party-portrait scale** -- the exact
measurement pass 4 held Colour & read down on -- composited on the rail's
own `(58,42,30)` background:

    goblin_mech_ai  before: sat 0.263  val 0.398
    goblin_mech_ai  after:  sat 0.493  val 0.461
    frog_ai (ref):          sat 0.69   val 0.44

![[frames/artist/2026-09-23-goblin-tank-contrast-34px-before-after.png]]

Value now matches the Frog's own 34px reading almost exactly; saturation
is well over halfway there, from under half before.

**No regression.** Only the three touched files changed
(`git status` confirmed). Full-frame pixel diff against the immediately
prior baseline, same camera/positions: changed pixels are the goblin's own
screen region (intended), the party rail's goblin portrait icon (intended),
and thin scattered edge pixels elsewhere matching the idle-animation-jitter
pattern this file's prior passes have already documented (jackal tail/ember
pulse, frog sway) -- not a shape or position change.

**Score: Colour & read 8→9, total 39→40/50** -- still 2 points under the 42
hunter stop line. Full write-up: `design/progress/goblin_mech_ai.md`
("Pass 5"). Updated `JACKAL-BAR.md`'s hunter-fidelity line with the new
number and the bug finding.

`ALL TESTS PASSED` (`run_tests.gd`). 80-step playtest
(`mode=play beast=cinder_jackal steps=80`) kicked off after this write-up
and the push, per `COMMON.md` 4b -- nothing in this diff touches gameplay
code or hunter positioning (texture/asset-embed data only), so a regression
here would be a surprise.

**Playtest result: `PLAYTEST FAIL: 2 failing check(s) { "intent-hidden":
26, "damage-popup-offscreen": 1 }`.** Checked before treating either as a
regression, per the standing practice this file's own prior passes use: both
are exact matches for already-open, already-filed `to: fixer` requests --
`intent-hidden` is
`requests/2026-09-23-2141-playtester-to-fixer-intent-tag-hides-behind-party-panel.md`
(filed 21:41, still open), `damage-popup-offscreen` is
`requests/2026-09-23-1735-playtester-to-fixer-boss-damage-popup-offscreen-at-sigil.md`
(filed 17:35, still open). Neither has anything to do with a hunter
texture/portrait change -- one is the boss's intent-tag UI overlapping the
party panel, the other is a damage-number screen projection at the sigil.
Not a regression from this pass; not reopening or duplicating either
request.

## Old: 2026-09-23 21:12 ET, portraits.py AI_ART table fix

- **Did:** the party rail's portraits for the Frog and the Goblin Engineer
  were still the OLD Python-primitive models — even though `combat_3d.gd`
  wired both hunters to their Meshy `_ai` rebuilds a while back,
  `portraits.py` (the separate tool that renders the 34px party-rail/
  campfire portrait) never got the same table update. A real fight
  screenshot showed the mismatch directly: the icon in the corner didn't
  match the hunter standing in the arena. Fixed the table, re-rendered both
  portraits.
- **Worked?** Yes — verified in the real party rail, before/after, same
  camera and state (frame below). This also happened to be the exact 34px
  Colour & read check both `frog_ai.md` and `goblin_mech_ai.md` had named
  as still-open (couldn't be measured until the portrait actually came from
  the right model): `frog_ai` measures clean and **crosses the 42 hunter
  stop line (41→42/50)**; `goblin_mech_ai` measures confirmed-still-duller,
  not worse, not better (stays 39/50) — named the concrete next fix (the
  tank reads too close to the body at that size).
- **Next:** `goblin_mech_ai`'s tank-vs-body contrast at 34px, or the
  193-island Hygiene question both hunter notes still list.
- **Need from you:** nothing.

![[frames/artist/2026-09-23-hunter-portraits-34px-old-vs-new.png]]
![[frames/artist/2026-09-23-hunter-portraits-party-rail-before-after.png]]

## Now

Checked for a fresh, unhandled answer under `## Nick's answer` on my own
`to: nick` notes first, per `COMMON.md` 1b — none. Checked open `to: artist`
requests — none this run. Worked the `JACKAL-BAR.md` queue: both hunter
notes (`frog_ai.md` pass 2, `goblin_mech_ai.md` pass 2/3) named the same
concrete open item — Colour & read "not verified at the 34px party-portrait
scale — `portraits.py`'s `AI_ART` table is beast-only" — so this run closed
that gap for both at once, one table edit.

**Confirmed the bug first, in the real game, not just in the code.**
Rendered `state=3d beast=cinder_jackal` and looked at the party rail next to
the hunters actually standing in the arena: the rail's frog was the flat
primitive green blob, the rail's goblin was the flat primitive green-and-
grey figure — neither matched the mottled, painted `_ai` models visibly
standing on the arena floor two inches away in the same screenshot.

**The cause**, in `tools/blender/portraits.py`: `AI_ART = {"cinder_jackal":
"_ai"}` — this table decides which `.glb` a portrait renders from, and it
only ever had the beast. `combat_3d.gd`'s own `HUNTER_AI_ART = {"frog":
"_ai", "goblin_mech": "_ai"}` has pointed the fight itself at the rebuilt
hunter models for a while; nothing kept the portrait tool's table in sync
with it.

**Fix:** merged the hunter entries into `portraits.py`'s own `AI_ART`
(`{"cinder_jackal": "_ai", "frog": "_ai", "goblin_mech": "_ai"}`),
`painted=True` for both — an AI model's texture already carries painted
light/shade, the same reason `look()` already drops the specular highlight
for `painted=True` models. Re-ran `portraits.py` for just these two; the
existing `FOCUS`/`FOCUS_XY` entries framed the `_ai` mesh correctly with no
retuning needed. Copied the two output PNGs over
`game/assets/portraits/{frog,goblin_mech}.png` — same 512×512 RGBA shape,
so nothing downstream (`characters.json`'s `portrait` paths, the party
rail's `_portrait_of(p, 34)`, the campfire hunter row) needed a code change.

**Verified in the real party rail**, same camera/state, before vs after:

![[frames/artist/2026-09-23-hunter-portraits-party-rail-before-after.png]]

**This closes the 34px Colour & read verification both hunter notes had
open**, now actually measured instead of assumed, because the portrait the
rail draws finally IS the shown model. Downsampled each render to the real
34px and measured mean saturation/value over the non-transparent pixels,
composited on the rail's own dark-brown background to judge legibility the
way the eye actually sees it:

    frog_ai         sat 0.69  val 0.44  — clean: eye/body/belly separate
    goblin_mech_ai  sat 0.27  val 0.40  — reads goblin-shaped, but the
                                          cool body and navy tank crowd
                                          together with little contrast

![[frames/artist/2026-09-23-hunter-portraits-34px-old-vs-new.png]]

`frog_ai`'s own Colour & read line was held at 8 explicitly pending this
check — now clean, bumped to 9, **total 41→42/50, at the hunter stop
line** (`design/progress/frog_ai.md` pass 3). `goblin_mech_ai`'s own line
was held at 8 the same way — verified, and the verification confirms pass
2's original "measurably duller than the Frog's own" finding rather than
improving on it, so it stays 8, **total unchanged, 39/50**
(`design/progress/goblin_mech_ai.md` pass 4). No texture touched this
pass — the scope was the tooling gap, not a colour fix; the concrete next
move for `goblin_mech_ai` is named with real numbers now: raise the tank's
value/saturation relative to the body, checked against the rail's own
`(58,42,30)` background specifically.

Updated `JACKAL-BAR.md`'s hunter-fidelity bullet with both new numbers and
this pass's write-up links.

`ALL TESTS PASSED` (`run_tests.gd`; no game code changed, a Blender tool
table and two portrait PNGs only). No playtest re-run — nothing moves or
renders differently in the 3D scene itself, only a 2D portrait texture the
party rail and campfire already knew how to draw (same reasoning past
texture-only passes here used).

## Old: 2026-09-23 20:11 ET, mesh-topology gap check

- **Did:** Blender's download wall (blocked 3 runs running, request filed
  `to: nick`) cleared on its own this run — no answer needed, the network
  policy fix just landed. Used it for the thing it was blocking:
  `goblin_mech_ai`'s Build hygiene score has been stuck since pass 1 on an
  unanswered question — "no floating islands, no part spaced away from the
  body," unverified since the original build. Wrote a proper check for it
  (`tools/blender/ai/mesh_gap_check.py`) and ran it on the real shipped
  model.
- **Worked?** Yes, a clean answer either way would have been useful, and
  this one came back clean: 489 raw mesh islands (unwelded topology,
  Meshy's normal remesh output), but a measured 3D distance check says
  **zero** of them are actually floating away from the body — the two
  closest-to-flagging are 2.5mm and 6.6mm gaps on a 1.85m-tall model,
  invisible even zoomed in. Build hygiene 6→7, total 37→38→**39/50** — real
  progress, still 3 points under the 42 hunter stop line.
- **Next:** no single line is the clear worst any more (Sil 8, Prop 8,
  Hygiene 7, Colour 8, Style 8) — closing the stop line needs the 34px
  party-portrait colour check pass 2 named as still open (`portraits.py`'s
  `AI_ART` table is beast-only), or a fresh six-view look for something
  this run didn't find. Also closed the Blender-wall request as done.
- **Need from you:** nothing.

## Now

Checked for a fresh, unhandled answer under `## Nick's answer` on my own
`to: nick` notes first, per `COMMON.md` 1b — none. Checked open `to: artist`
requests — none this run. Worked the `JACKAL-BAR.md` queue.

**Set up Blender and Godot fresh (per `status/README.md`), and both worked
without the network wall this time** — `curl` against
`download.blender.org` returned `200` (vs the clean `403` the last three
runs hit), so the request filed at 18:11
(`requests/2026-09-23-1811-artist-to-nick-blender-download-blocked.md`) is
resolved; marked it `status: done` with the proof in its own `## Result`
rather than leave it sitting open with nothing to answer. Meshy also
confirmed working (`balance` OK, 0/8 tasks spent today — the daily ledger
rolled over) but wasn't needed this run.

**Picked the loudest remaining hunter-fidelity gap that Blender specifically
unblocks.** `design/progress/goblin_mech_ai.md` (the shipped, wired-in
Meshy rebuild — not `goblin_mech.md`, the older primitive one, already past
its own stop line) named Build hygiene as its lowest line twice running (6,
pass 1 and pass 2), both times explicitly because the mesh-topology check
`frog_ai.md` pass 2 ran on the Frog had never been run on this model — "an
open question, not a confirmed clean bill."

**Ran a stronger version of that check, not just the same one.** `frog_ai`
pass 2's own check walked the mesh into 193 raw connected components and
confirmed them "silhouette-safe" — a 2D check, and its own "still open"
list admits it never verified in 3D whether any of them are real gaps.
Wrote `tools/blender/ai/mesh_gap_check.py` instead: same connected-component
walk, then (numpy) the minimum 3D distance from every island to the nearest
vertex in a DIFFERENT island. An island that's just unwelded from its
neighbours (harmless, the normal cost of a decimated Meshy remesh) sits at
~0 gap; a genuinely floating part — spaced away from the body, the actual
defect the rubric line names — would show a real fraction of the model's
own bounding-box diagonal as its gap.

    blender -b --python tools/blender/ai/mesh_gap_check.py -- game/assets/3d/cast/goblin_mech_ai.glb

    REPORT total_verts 5799
    REPORT total_islands 489
    REPORT body_diag 2.3296
    REPORT islands_with_real_gap_total 0 (of 489 islands, verts>=3, threshold=0.010)

**489 islands, zero real gaps at a 1%-of-body-diagonal threshold (~23mm).**
Didn't stop at the first clean number — re-ran at 10x tighter (0.1%,
~2.3mm) to find the honest floor: two 4-vert islands show up, at 2.5mm and
6.6mm gaps near the backpack/compressor-tank region. Looked at both
locations in the existing six-view renders at that spot: invisible even
zoomed in, sub-centimetre gaps between decimated micro-facets, not a seam
or a standoff part.

**No fix to apply — the finding itself is the result.** Build hygiene's
open question was "is this confirmed clean," not "here's a known defect to
fix." It's now confirmed clean, with a sharper test than the one `frog_ai`
itself still has outstanding (that asset's own "still open" item 1 is this
exact 3D-gap question, unresolved). Scored Build hygiene 6→7 — matched to
`frog_ai`'s own 7, on the same logic: real tri-budget overage (5199 vs the
1400 hunter budget) still costs a point at this tier, but the topology
uncertainty that was `goblin_mech_ai`'s own extra gap versus `frog_ai` is
now closed. **Total 38→39/50**, still under the 42 hunter stop line.
Nothing else touched — no geometry, texture or code changed, so `ALL TESTS
PASSED` needed no playtest re-run (ran it anyway: no game-visible change,
confirmed by `git status` showing only the new script and the two progress/
status notes).

Full write-up: `design/progress/goblin_mech_ai.md` ("Pass 3").

## Old: 2026-09-23 19:20, floating-stone shelves

- **Did:** took the playtester's request to make the climb stones read as
  shelves, not floating markers — added a flat, level cap and a thin warm
  rim-light edge on top of each stone's existing rock body.
- **Worked?** Yes — clearly better in the wide establishing shot, the exact
  frame the request complained about: before, four round pebbles; after,
  a visible stack of pale-topped ledges with a warm lip. Before/after below.
- **Next:** the playtester's own build request
  (`2026-09-23-1846-...-build-the-one-directional-stone-route.md`, fixer's)
  covers placement/spacing — that's someone else's half, not touched here.
  I left the stones' slow idle bob/spin alone (motion, not look) — flagged
  for the playtester in case a "fixed shelf" that still slowly spins reads
  oddly now that the shape says "stationary."
- **Need from you:** nothing.

![[frames/artist/2026-09-23-stones-shelf-wide-before-after.png]]
![[frames/artist/2026-09-23-stones-shelf-close-before-after.png]]

Took the one open `to: artist` request
(`2026-09-23-1846-playtester-to-artist-make-ledges-read-as-shelves.md`) —
top of the queue per `COMMON.md` 2, and the only one open this run (checked
my own `to: nick` notes for a fresh, unhandled answer too; the Blender-wall
one is still open with nothing written under its answer heading, so left
alone).

**The ask:** the playtester found that after Nick approved the stone-route
proposal, the climb holds themselves still read as "four scattered pebbles,"
not a path — specifically because a round boulder alone doesn't say
"footing" the way Breath of the Wild's climbable rock does (lighter
material/colour on the actual holds, visible from a distance). Material
pass only; placement is the fixer's half of the same approved proposal.

**What changed**, in `_build_float_stones` (`combat_3d.gd`): each stone went
from one boulder mesh to three parts —

- **Body** — the original boulder, shape/colour untouched, still random
  tilt+squash so a run of stones doesn't clone.
- **Cap** — new. A flat, perfectly level cylinder on top (no random tilt,
  unlike the body), pale worn-sandstone tone, deliberately lighter than the
  body AND the jackal's own near-black skin. This is the actual "footing"
  cue, and it stays level regardless of how the body under it is squashed.
- **Rim** — new. A thin unshaded warm-ember ring at the cap's edge. This is
  what carries the shelf's silhouette at wide-shot distance, where the
  cap/body colour difference alone gets small on screen.

**First pass had a visible gap** between cap and body — the boulder mesh is
very low-poly (`rings=3`, so its "top" is a faceted point, not a smooth
dome), and its own random tilt swings that point sideways by more than the
cap's thickness at this radius. Fixed by overlapping the body further up
into the cap rather than placing them flush; re-rendered and confirmed no
daylight gap in the wide shot, `3dgrip`, or a close crop.

**Checked the request's other bullet** — "ledges (real footing) and mid-air
pass-through points ... look distinguishably different": read
`_build_float_stones`/`_build_ledge_marks` closely. Every climb point
already gets one of these stones; there's no separate "no footing, mid-fall"
stone today. The existing safe-ledge ring (drawn only on `boss.ledges`
heights, a strict subset) already marks which ones are secure. Left that
system alone — it already satisfies this bullet.

Verified: `state=3d ... wide` (the request's own repro command), `3dgrip`
(hunter standing on a stone — feet still land flush on the new cap),
`3dstrike` (sigil close-up, no stones in frame, unaffected). `ALL TESTS
PASSED`. Pushing this now per COMMON.md 4b, then running the 80-step
playtest in the foreground (not backgrounded) as the last step of this run;
result appended to the Log below once it finishes.

Marked the request `status: done` with the before/after frames embedded in
its own `## Result`.

## Old: 2026-09-23 18:16, Goblin Engineer colour boost

- **Did:** made the Goblin Engineer's colours read better — boosted
  saturation and lifted the shadows on its texture directly (no Blender, no
  Meshy spend), since the palette was measurably flatter and darker than
  the Frog's own.
- **Worked?** Yes, a real if modest improvement — the backpack tank, goggles
  and strap all read more distinctly now, verified in the real fight and
  the campfire screen; frames in the write-up. Scored it: Colour & read
  7→8, total 37→38/50 — closer, but still under this fight's own 42 bar for
  a hunter.
- **Next:** the remaining gap needs Blender (a mesh-cleanliness check, the
  lowest-scoring line) — blocked again this run.
- **Need from you:** Blender downloads have failed three runs running now
  (roughly 16:24, 17:19, and this one) — same fix as the Meshy one earlier
  today would likely clear it. Filed a request with the details; not
  blocking anything urgent, but it's the reason today's hunter-fidelity
  work has been limited to texture tweaks instead of real geometry.

## Now

**No open `to: artist` request this run**, and none of my own `to: nick`
requests had a fresh, unhandled answer either — checked both per
`COMMON.md` 1b/2 before picking work. Worked the `JACKAL-BAR.md` queue.

**Both Meshy (8/8 daily tasks already spent, ledger-confirmed) and Blender
were unavailable again — third run in a row on the exact same Blender
wall**, so this is the one to file, per the last run's own threshold:
`requests/2026-09-23-1811-artist-to-nick-blender-download-blocked.md`
(`to: nick`, not blocking, but flags the recurring pattern).

**Picked the one thing that needed neither tool.** `goblin_mech_ai`'s pass-1
score (37/50, `design/progress/goblin_mech_ai.md`) named two lowest lines:
Build hygiene (needs Blender — still blocked) and Colour & read (texture
"measurably duller than the Frog's own"). The second one doesn't actually
need Blender or Meshy: the runtime texture is a plain PNG Godot's importer
already extracted to disk (`embedded_image_handling=1`), the same fact the
jackal ear-glare fix relied on to edit a texture directly with no
re-export needed.

**Re-measured the gap on the real files first**, rather than trust pass 1's
carried-over number (which turned out to be from Blender's own linear-space
pixel data, not the shipped sRGB asset): HSV saturation 0.284 vs the Frog's
0.671, value 0.535 vs 0.702 — real, reproducible, just smaller than the
original "80 vs 156 luminance" framing suggested. Fixed with a direct HSV
edit on `goblin_mech_ai_Image_0.png` — saturation ×1.55, value gamma 0.80 —
moving about 40% of the way to the Frog's own numbers, deliberately not all
the way (risk of reading oversaturated against this hunter's own palette).
Script kept at `tools/blender/ai/goblin_ai_colour_boost.py` (no `bpy`
despite the folder — it's the goblin-AI-texture family of scripts, this one
just doesn't need Blender).

Verified in the real fight and the campfire row, before/after at true
in-fight size:

![[../agents/frames/artist/2026-09-23-goblin-colour-boost-infight-crop.png]]
![[../agents/frames/artist/2026-09-23-goblin-colour-boost-campfire-crop.png]]

The backpack tank, goggles and strap all separate more clearly. Modest, not
dramatic — the toon shader's own shadow ramp compresses colour range on top
of whatever the texture carries, so part of the ceiling here is shader-side,
not texture-side.

**No regression** — only the one PNG changed (`git status` confirmed);
full-frame pixel diff against the immediately-prior render shows nothing
outside the goblin's own screen region beyond thin edge pixels on the
jackal's legs and the Frog, consistent with ordinary idle-animation jitter
between two independently-timed renders (same pattern the outline-width
pass documented). `ALL TESTS PASSED` (`run_tests.gd`) — texture-only change,
no logic touched, so no playtest needed.

**Score: Colour & read 7→8, total 37→38/50** — still under the 42 hunter
stop line. `design/progress/goblin_mech_ai.md` ("Pass 2") has the full
write-up including what's still open: the portrait-scale colour check, and
Build hygiene, still blocked on Blender.

## Old: 2026-09-23 17:19, outline-width fix / goblin_mech_ai shipped and scored

**Both Meshy and Blender were unavailable again.** `python3 tools/meshy.py
balance` succeeds (the credential still works), but the daily task ledger
(`design/progress/meshy-ledger.md`) already shows 8/8 spent for
2026-09-23, and the date hasn't rolled over — confirmed, not assumed, same
conclusion the last run reached. Tried Blender fresh this run rather than
trust the last run's note that it might have cleared:
`curl https://download.blender.org/...` → clean `403`, `connect_rejected` /
"organization policy" per `$HTTPS_PROXY/__agentproxy/status`, same wall,
still up. Not filing a fresh `to: nick` for this — two runs in a row on the
same wall starts to look like it's worth flagging, but nothing changed
since the last run's own note said not to yet; if a third run hits the
same wall, that's the one to file.

**Picked the loudest thing that needed neither.** With no model-building
budget, went looking at what a shader/material change could still fix — the
outline-width request I'd filed to the fixer
(`requests/2026-09-23-1540-artist-to-fixer-hunter-scale-outline-swallows-thin-hunters.md`)
was still `open`, untaken, hours after filing, and blocking the single
loudest line on `JACKAL-BAR.md` ("Frog and Goblin match the jackal's
fidelity") — the Goblin Engineer's Meshy rebuild was already built,
tested, and sitting on disk, unshippable purely because of this one shader
parameter. Decided to implement it myself rather than wait longer: it's a
material/shader change on an asset I own, the same kind of edit past runs
have already made directly in `combat_3d.gd` (the ear-glare fix, the
footholds texture, `HUNTER_AI_ART`/`ENV_AI_ART` itself), not a gameplay
bug fix outside my own scope.

**The fix.** `OUTLINE_WIDTH_SCALE` in `combat_3d.gd`: a dict of model id to
a multiplier on `outline.gdshader`'s own default line width (`0.0045`), not
the flat global override the original request explicitly said not to ask
for. Read at both places a toon-shaded model's outline material gets built
— `toon_material()` (called from `_shade_model` for the live fight, and
`toon_all` for the reward-screen felled beast and the campfire hunter row)
— so a tagged hunter reads the same everywhere it appears, not just in
combat. An id with no entry gets the implicit `1.0` and the code never
calls `set_shader_parameter` at all, so the jackal and the already-shipped
Frog draw through the exact same call they always did — nothing about
their outline changed, in code or in the render.

**`goblin_mech`: 0.33.** Matches the manual local test the original
diagnosis reported (width `0.0015` against the `0.0045` default) — but
re-verified fresh this run rather than carried over on trust: wired
`"goblin_mech": "_ai"` into `HUNTER_AI_ART`, rendered `state=3d
beast=cinder_jackal`, cropped the hunter at 3x.

![[../agents/frames/artist/2026-09-23-goblin-outline-width-fix-crop.png]]

Left: the primitive Goblin (unchanged, still the shipped fallback). Right:
the Meshy rebuild, outline scaled — mint skin, gold goggles, dark slate
tank rig and a raised clawed hand all legible, matching the Frog's own
level of read.

**Checked every place this model shows, not just the one screenshot that
started the diagnosis.** The campfire hunter row (`toon_all`'s other call
site, `_place_hunters` in `location_3d.gd`) reads just as clearly:

![[../agents/frames/artist/2026-09-23-goblin-outline-width-fix-campfire.png]]

**No regression on the jackal or the Frog** — full-frame `state=3d`
before/after, pixel-diffed. Outside the Goblin's own screen region, the
only pixels that moved are consistent with ordinary idle-animation timing
jitter between two independently-run screenshots (breath/ember-pulse/idle
sway, all time-driven); a tight crop of the jackal's legs and the Frog
confirms both are shape-for-shape identical, not just "diff is small":

![[../agents/frames/artist/2026-09-23-goblin-outline-width-fix-before-after.png]]

**Scored for real, for the first time.** The original build pass was
explicitly left unscored (not shown to players the way they'd see it yet);
now it is. Full rubric breakdown in
`design/progress/goblin_mech_ai.md` ("Shipped and scored") — short version:
Silhouette 8, Proportion 8, Build hygiene 6, Colour & read 7, Style
consistency 8. **Total 37/50**, under the 42 hunter stop line, an honest
number rather than a rounded-up one (`frog_ai` landed 41/50 on its own
first wired-in pass, for comparison). Lowest two lines for whoever picks
this up next: Build hygiene (needs Blender for a mesh-cleanliness check
this run couldn't do) and Colour & read (the texture is still measurably
duller than the Frog's own — 80.1 vs 156.5 mean luminance, unchanged by
this pass; needs either a Meshy budget reset or manual texture work).

**Ticked `JACKAL-BAR.md`'s "each hunter reads at fight distance, not a
green blob"** — true now for both hunters, with evidence. Left the bigger
"Frog and Goblin match the jackal's fidelity" line unticked — 37/50 is a
real hunter on screen, not yet at the tier's own bar.

**`ALL TESTS PASSED`.** An 80-step `mode=play beast=cinder_jackal steps=80`
playtest was kicked off against the wired-in model but ran past this
run's foreground window — per `COMMON.md` 4b, pushed the code, the frames
and every write-up first rather than let a background run hold up
everything else this session did. Result appended to
`design/progress/goblin_mech_ai.md` and the `## Log` below the moment it
lands.

Filed the result on the original request
(`requests/2026-09-23-1540-artist-to-fixer-hunter-scale-outline-swallows-thin-hunters.md`,
now `status: done`) rather than leave it open under the fixer's name for
work already finished.

## Old: 2026-09-23 16:24, floating-foothold rock-detail texture

- **Did:** gave the jackal's (and every beast's, shared code) floating
  climb footholds real surface detail — generated a faceted-rock texture
  and multiplied it onto the stones, which had only ever had one flat
  colour. Fixes `artist.md` item 1's own "footholds are plain basalt".
- **Worked?** Yes — before/after in the real fight (same camera, same
  state) shows the stone going from a flat orange blob to a visibly
  cracked, faceted rock, still the same warm palette. Frame below.
- **Next:** the hunter-fidelity item (Goblin Engineer) is still blocked on
  the fixer's outline-width fix, untouched since last run. If a future run
  gets Blender back, the stones could get real geometry too, not just a
  texture.
- **Need from you:** nothing.

**Both Meshy and Blender were unavailable this run.** Checked first, before
picking work: `design/agents/status/artist.md`'s own last entry already
recorded 8/8 daily Meshy tasks spent (confirmed no reset since — Meshy
budget is a hard daily cap, not per-run). Tried Blender next —
`curl https://download.blender.org/...` came back a clean `403 Forbidden`
through the proxy, twice, not a timeout or a flaky retry (`curl -sS
"$HTTPS_PROXY/__agentproxy/status"` confirmed `connect_rejected` /
"organization policy" on that host this session, distinct from the Meshy
network wall other runs have filed before). Prior runs built real beasts
under this exact wall with Blender working fine today, so this reads as a
this-session network policy quirk, not a standing block — not worth a
fresh `to: nick` request for a one-off that may not recur; noted here so
the next run knows to just try again rather than assume it's permanent.

**Picked the next thing that needed neither.** The hunter-fidelity item
(the loudest open line on `JACKAL-BAR.md`) is blocked on the fixer's
outline-width fix (`requests/2026-09-23-1540-...`, still open, untouched
since I filed it). Went looking for a real gap I could still close and
found one by rendering, the same way the ear-glare bug was found: the
`3dgrip` state (a hunter mid-climb, a real reachable state, not a
synthetic edge case) shows the floating stone under the Frog as one flat
solid-orange blob with a hard shadow — no surface variation at all. This
is exactly `artist.md` item 1's own named issue ("footholds are plain
basalt"), never actually fixed, only recoloured (2026-09-23, brown to
match the arena's own boulders — colour was right, surface detail never
was).

**Ruled out reusing the arena's own Meshy texture first.** The env
model's `cinder_jackal_ai_Image_0.jpg` (the crater wall's baked texture)
has real rock detail, but it's vertical striated wall rock, UV-unwrapped
for that specific wall mesh — slapping it onto a `SphereMesh`'s own
lat-long UV via its default mapping would stretch/misalign into an obvious
smear, not read as rock. Building a real from-scratch rock mesh is the
right fix but needs Blender, which wasn't available.

**Built a generated (not modelled) detail texture instead** — pure
numpy/PIL, no Blender, no Meshy: a toroidal Voronoi (seed points wrapped
9x so the pattern has no seam crossing the sphere's own UV wrap),
per-cell random brightness, and a distance-based darkening near each cell
edge for a crack line — the same low-poly **faceted** look every other
rock/beast asset in this fight already established, not an invented style.
512×512 grayscale, `game/assets/3d/rock_detail.png`.

**Wired into `_build_float_stones()`** (`combat_3d.gd`, shared by every
beast — verified specifically in the Cinder Jackal fight per this fight's
own scope rule): added `mat.albedo_texture = ROCK_DETAIL` next to the
existing per-stone `albedo_color` tint, which stays exactly as it was — the
texture multiplies it, so the already-tuned BROWN palette and its
"lighter than the beast's own CHARCOAL legs" contrast rule are untouched.
One texture shared by every stone; the existing per-stone random rotation
(unrelated code, already there) turns a different facet forward on each,
so neighbouring stones still don't clone.

**Verified.** `ALL TESTS PASSED` (`run_tests.gd`, material-only change, no
logic touched). Before/after at the exact same camera and state
(`state=3dgrip beast=cinder_jackal`, a real reachable mid-climb position):

![[../agents/frames/artist/2026-09-23-foothold-rock-detail-before-after-crop.png]]

Full frame, after:
![[../agents/frames/artist/2026-09-23-foothold-rock-detail-after-full.png]]

Full write-up, including why texture over geometry and what was ruled out:
`design/progress/foothold_rock_detail.md`.

**Playtest: clean.** Kicked off a full 80-step `mode=play` as the general-
regression check (this touches a shared code path used by every beast's
climb, even though the change itself is a pure `material_override` swap
with no position/index logic touched) — it ran past the 590s foreground
cap and moved to the background, so pushed everything first per COMMON.md
4b rather than let it run unwitnessed. Result, once it finished:
`PLAYTEST OK: 0 failing check(s) {  }`, full 80 steps, exit code 0 — Meld,
Catapult+Burn Coal, Leapfrog, Brace, Take Aim, Scramble, several real
climbs/hops with position-continuity checks, a real fall (foot 10→4, hp
20→14 at step 71) all clean. No regression.

**Also looked at, and deliberately did NOT file:** the `3dgrip` state also
shows the OTHER hunter (not the one the camera follows) going behind the
top HUD bar — flagged it as a possible bug at first, then found
`playtest.gd`'s own `check 9` comment (2026-09-23) explicitly documents
this as settled, not a gap: only the camera-followed hunter is required to
stay on screen, after an earlier version of this exact check "false-fired
on the OTHER hunter mid-climb" and was deliberately narrowed. Re-filing it
would be re-litigating already-closed work, so left alone.

## Old: 2026-09-23 15:40, Goblin Engineer Meshy rebuild — blocked on outline width

**Picked up the loudest remaining item on `JACKAL-BAR.md`**: "Frog and
Goblin match the jackal's fidelity." The Frog already has a shipped Meshy
rebuild (`frog_ai.md` pass 2, 41/50); the Goblin Engineer had no Meshy
attempt yet. Both blockers that note left open — Meshy fetch, the
hunter-display-path — were already `status: done`, so this was the natural
next move, not a new investigation.

**Budget was tight.** 6 of 8 daily Meshy tasks were already spent before
this run (frog previews/refine, arena preview/refine). That left exactly
one preview and one refine — no room to try three candidates the way
`frog_ai.md` pass 1 did. Wrote one careful prompt pulled straight from
`goblin_mech.py`'s own docstring (oversized mech arm, ordinary arm,
compressor tank, goggles, tusks) instead. What came back reinterprets that
as a mechanical tank-and-hose backpack rig rather than a second giant arm —
a different read of the brief, not what was literally asked for, but still
unmistakably "goblin with visible machinery," and Nick's 2026-09-23 brief
explicitly allows a style change, not just a literal rebuild. Accepted
rather than spend the last task on a reroll. Refined with a texture prompt
built from this hunter's own established palette, sampled from the shared
atlas, not guessed. **8 of 8 daily Meshy tasks now spent — none left
today.**

**Cleaned in Blender** (`tools/blender/ai/goblin_ai_clean.py`, the same
weld/centre/scale/decimate recipe `frog_ai_clean.py` proved): welded
doubles, scaled to the current `goblin_mech.glb`'s own measured height
(1.85, read off a real bounds probe), decimated 27,422 → 5,199 tris
(matches `frog_ai`'s own already-accepted overage). One mesh, one material.
Reads clearly as a goblin with visible machinery in isolation — mint skin,
gold goggles, dark slate tank rig, brown straps — under `look.py`'s neutral
lighting, six-view render below.

![[../renders/goblin_mech_ai_pass1_front.png]]

**Wired in to test, and found a real problem — not shipped.** Tagged
`goblin_mech` into `HUNTER_AI_ART` and compared the real fight, same camera
and state, before/after. The toon shading and ink outline apply correctly —
same code path the Frog already uses — but **at true in-fight size it
reads as a near-solid black blob**, worse than the primitive it would
replace:

![[../agents/frames/artist/2026-09-23-goblin-mech-ai-infight-before-after.png]]

Measured, not just eyeballed: the exported texture's mean luminance is 80.1
against `frog_ai`'s own shipped texture at 156.5. Tried the obvious fix —
a gamma lift on the baked texture, no new Meshy spend
(`tools/blender/ai/goblin_ai_brighten.py`) — and it barely moved the
in-fight read. Isolated the real cause instead: `toon.gdshader`'s shadow
colour is a cool blue-grey by design, not black, so the black is coming
from the second pass, `outline.gdshader`'s inverted-hull ink line. Its
`width` (0.0045, distance-scaled) is tuned for thick, rounded masses — the
jackal, the Frog. The Goblin's own design is deliberately the opposite
(many thin parts: straps, tank fittings, limb segments), and at hunter
scale those individual outline strokes start overlapping and eating the
model. Confirmed by a throwaway local test — dropped `width` to 0.0015,
reverted immediately, `git diff` clean before committing anything — and the
identical asset read clearly:

![[../agents/frames/artist/2026-09-23-goblin-mech-ai-crop-outline-width-diagnosis.png]]

**A hunter that renders worse than what it replaces is a regression, not a
win** — reverted `HUNTER_AI_ART` back to `{"frog": "_ai"}` (confirmed via
`git diff`, clean on both `combat_3d.gd` and `outline.gdshader`) before
committing. The built asset (`goblin_mech_ai.glb`, `.blend`, both scripts)
ships in this commit regardless, same as `frog_ai` pass 1's own spike did —
ready to wire in the moment the outline question is resolved. Not scored
against the asset-loop rubric, same reasoning `frog_ai.md` pass 1 gave:
scoring a model that isn't shown to players the way they'll see it would be
misleading. Full build log, prompts and measurements in
`design/progress/goblin_mech_ai.md`.

**Filed to the fixer**
(`requests/2026-09-23-1540-artist-to-fixer-hunter-scale-outline-swallows-thin-hunters.md`):
the outline width needs to vary by hunter scale/part-thickness — this will
block every future detailed hunter, not just this one.

`ALL TESTS PASSED`. 80-step playtest (`mode=play beast=cinder_jackal
steps=80`) re-run against the final, reverted state to confirm no
regression — nothing in the committed diff touches gameplay code or
hunter/beast positioning (`HUNTER_AI_ART` is byte-for-byte what was already
shipped), so a regression here would be a surprise, but the result is
appended the moment it lands rather than assumed.

**Playtest result: clean.** `PLAYTEST OK: 0 failing check(s) {  }` — all 80
steps (Meld, Catapult+Burn Coal, Leapfrog, Brace, Take Aim, Scramble, Build
Grapple, several climbs and hops with position-continuity checks passing),
exit code 0. Confirms the prediction above: the committed diff never
touched `HUNTER_AI_ART` or any gameplay/positioning code, only added new,
unreferenced asset files and docs.

## Next

**Hunter fidelity** (still the loudest `JACKAL-BAR.md` line): blocked on
the fixer's outline-width fix
(`requests/2026-09-23-1540-artist-to-fixer-hunter-scale-outline-swallows-thin-hunters.md`,
still open). Once it lands: re-wire `goblin_mech` into `HUNTER_AI_ART`,
re-verify, score it for real.

Blender's own network wall cleared this run (`download.blender.org` fetched
clean — the first artist run in three not to hit the 403). Worth
re-confirming next run before relying on it; if it holds, the footholds'
underlying geometry (still a smooth sphere under the new cap/rim, this run
only touched the visual dressing) is the obvious next real-geometry pass.

## Log

- 2026-09-24 09:24 EDT — closed `JACKAL-BAR.md`'s Motion section: verified
  the fixer's jump-hides-behind-intent-tag fix (commit `73ae6b4`) live with
  a fresh render, then did a dedicated eyes-on pass on camera-hold and
  no-pops across 8 real hops in a full fight — 0 check fires, and the real
  frames read clean by eye too. All three Motion lines ticked.
- 2026-09-24 08:22 EDT — first dedicated artist look at Motion: real hops
  read well at true 1:1, but found the boss's intent tag can render on top
  of a jumping hunter and hide part of it at the arc's peak. Filed
  `to: fixer`; left all three Motion lines unticked pending that fix.
- 2026-09-24 07:16 EDT — `goblin_mech_ai` pass 8: fresh six-view look found
  no new Sil/Prop/Style defect; tested tri-count decimation as a cheaper
  substitute for the UV re-unwrap Build hygiene needs — 40% fewer tris is
  visually free but doesn't move the score (`frog_ai`, same accepted-overage
  tri class, untouched, already caps at the same Build hygiene 7) and
  doesn't reduce the UV-seam island count. Did not ship it. Score unchanged
  41/50; the re-unwrap is the one lever left, still not attempted blind.
- 2026-09-24 02:14 EDT — fresh critical six-view look at `cinder_jackal_ai`
  (pass 3) plus an in-fight check (3dgrip/3dclimb/3dstrike): the pass-2
  basalt fix and the 2026-09-22 ear-glow fix are both holding, no new
  defect found on Sil/Prop/Style. Score unchanged 40/50. Deliberately did
  not attempt a decimation pass on the beast's tri count — the tri-budget
  overage is now a confirmed structural ceiling across all three Meshy-built
  cast members, and a rigged hero asset is the wrong place to test that
  first. No shipped asset changed; `ALL TESTS PASSED`, no playtest re-run
  needed (nothing gameplay-visible touched).
- 2026-09-24 01:38 EDT — 80-step `mode=play beast=cinder_jackal` playtest for
  the basalt-geometry cleanup finished: `PLAYTEST FAIL: 2 failing check(s) {
  "hop-distance-band": 62, "intent-hidden": 18 }`. Checked both against the
  known record before treating either as a regression: `intent-hidden` is
  the same still-open `to: fixer` request filed 2026-09-23 21:41 (intent tag
  vs party panel). `hop-distance-band` is a check the playtester added THIS
  run (commit `1313708`, after my own run started) confirming the fixer's own
  still-open finding from their last run's status note — Height 3→4 measures
  2.39m and 4→5 measures 1.52m against a 2.42m floor, the EXACT numbers the
  fixer already reported as unfixed ("the two hops nearest the sigil stay
  short"). Climb marker positions are untouched by this pass's fix (they're
  separate empties from the Body mesh I edited), so this can't be a
  regression from removing the basalt geometry — confirmed by the numbers
  matching exactly, not just "plausibly pre-existing." No `hunter-off-marker`,
  `route-reversal`, `damage-popup-offscreen` or `script-error` fails despite
  the beast's own bounding box legitimately shrinking this pass — the
  systems that read `_beast_box` (arena sizing, hunter standoff, camera) all
  held. Commit `c4c25a8`.
- 2026-09-23 23:35 EDT — 80-step playtest for the skin-saturation change
  finished: `PLAYTEST FAIL: 2 failing check(s) { "intent-hidden": 26,
  "damage-popup-offscreen": 1 }` — the same two pre-existing, already-filed
  `to: fixer` requests every recent pass has hit (intent tag vs party
  panel, filed 21:41; boss damage popup at the sigil, filed 17:35), neither
  touching a hunter texture. Not a regression. Commit `68de1c2`.
- 2026-09-23 23:22 EDT — `goblin_mech_ai` pass 6: a fresh six-view look
  (pass 5's own suggested next move) found the skin reads near-white, not
  green, at the real fight camera and native pixel size -- every prior
  "verified in the real fight" frame in this thread had been a 3x crop that
  hid it. Root cause: skin texture S 0.26-0.29 even after pass 2's boost,
  low enough that `toon.gdshader`'s bright lit band washes it toward white;
  the Frog's own texture (S 0.66-0.77) survives the same shader. New
  `tools/blender/ai/goblin_ai_skin_saturation.py`: hue-masked (70-160°)
  saturation ×2.6 on skin only, value untouched. Verified with a magenta
  diagnostic first, then real before/after screen pixels: (240,243,220) ->
  (211,249,151), visibly cream to visibly green. Also fixed the party
  portrait (glb's embedded texture changed) -- now matches the Frog's own
  saturation range at both scales. Colour & read 9->10, total 40->41/50,
  one point under the 42 hunter stop line. `ALL TESTS PASSED`. Commit
  `68de1c2`. Lease released.
- 2026-09-23 22:33 EDT — 80-step playtest for the tank-contrast change
  finished: `PLAYTEST FAIL: 2 failing check(s) { "intent-hidden": 26,
  "damage-popup-offscreen": 1 }`. Both exact matches for already-open,
  already-filed `to: fixer` requests (intent tag vs party panel, filed
  21:41; boss damage popup at the sigil, filed 17:35) -- UI/HUD bugs
  unrelated to a hunter texture/portrait change. Not a regression, not
  reopened or duplicated. Commit `370b1b2`.
- 2026-09-23 22:20 EDT — `goblin_mech_ai` pass 5: fixed the tank-vs-body
  contrast at 34px (pass 4's named next move) and found/fixed a real bug
  along the way -- the glb's embedded texture never got pass 2's colour
  boost, only the loose extracted PNG did, so every portrait render has
  shown a dimmer goblin than the fight for two passes. New
  `tools/blender/ai/glb_image_patch.py` (safe embedded-image swap, GLB last-
  bufferView case) + `goblin_ai_tank_contrast.py` (hue-masked sat/val boost
  on the tank/shorts only, confirmed by a diagnostic recolour). Colour & read
  8→9, total 39→40/50. Verified in the real fight and at the actual 34px
  scale, before/after. `ALL TESTS PASSED`. Commit `370b1b2`. Lease released.
- 2026-09-23 21:12 EDT — fixed `portraits.py`'s `AI_ART` table (beast-only,
  `{"cinder_jackal": "_ai"}`) to also cover `frog`/`goblin_mech`, so the
  party-rail/campfire portraits finally render from the same `_ai` models
  the fight itself has used for a while, not the old Python-primitives.
  Verified in the real party rail before/after. This closed the 34px
  Colour & read check both hunter notes had left open: `frog_ai` 8→9,
  total 41→42/50 — **at the hunter stop line**
  (`design/progress/frog_ai.md` pass 3); `goblin_mech_ai` stays 8, 39/50,
  confirmed still duller than the Frog's own at that scale, next move named
  with real numbers (`design/progress/goblin_mech_ai.md` pass 4). Updated
  `JACKAL-BAR.md`. `ALL TESTS PASSED`; no playtest re-run (texture/tooling
  only, nothing moves differently). Lease released.
- 2026-09-23 20:11 EDT — Blender's download wall cleared on its own
  (`download.blender.org` now `200`); closed the `to: nick` request that
  flagged it. Wrote `tools/blender/ai/mesh_gap_check.py` (a measured 3D
  nearest-different-island-gap check, stronger than `frog_ai`'s own
  silhouette-only one) and ran it on `goblin_mech_ai.glb`: 489 raw topology
  islands, 0 with a real spatial gap (>1% of body diagonal); even at 10x
  tighter threshold only two 4-vert islands show up, both sub-centimetre
  and invisible in the renders. Closes the open Build hygiene question from
  pass 1/2. Build hygiene 6→7, total 38→39/50, still under the 42 hunter
  stop line. No asset/code change, so no playtest needed; `ALL TESTS
  PASSED`. See `design/progress/goblin_mech_ai.md` ("Pass 3"). Lease
  released.
- 2026-09-23 19:29 EDT — 80-step playtest for the stone-shelf change, run in
  the foreground this time (COMMON.md 4b), after pushing the code/frames
  first: `PLAYTEST FAIL: 1 failing check(s) { "damage-popup-offscreen": 1 }`
  at step 19. Checked before treating it as a regression: this is the exact,
  already-filed, still-open `to: fixer` issue
  (`requests/2026-09-23-1735-playtester-to-fixer-boss-damage-popup-offscreen-at-sigil.md`)
  — a damage number's screen projection, nothing to do with the stones'
  mesh/material. No hop/camera check failed; hop position continuity and
  mid-hop camera coverage were clean on every sampled jump, including onto
  the new shelf-capped stones. Not a regression from this change; not
  reopening or duplicating the fixer's own request. Commit `66d2f4f`.
- 2026-09-23 19:20 EDT — shipped the ledges-read-as-shelves request: added a
  flat cap + warm rim edge on top of each floating stone's existing rock
  body (`_build_float_stones`, `combat_3d.gd`); fixed a cap/body gap the
  first pass had. `ALL TESTS PASSED`. Before/after in the request's own
  `## Result` and above. Request marked `status: done`. Commit `66d2f4f`.
- 2026-09-23 18:16 EDT — boosted saturation (x1.55) and lifted value (gamma 0.80) directly on goblin_mech_ai's extracted PNG texture (tools/blender/ai/goblin_ai_colour_boost.py, no Blender needed) -- HSV sat 0.284->0.433, val 0.535->0.601, toward the Frog's own 0.671/0.702. Verified in the real fight and campfire row, backpack/goggles/strap read more distinctly. Colour & read 7->8, total 37->38/50, still under the 42 hunter stop line. ALL TESTS PASSED; pixel-diff confirms no regression outside the goblin's own region (idle-animation jitter only). Filed to:nick on the Blender wall (3rd run in a row hitting the same 403 on download.blender.org) per the prior run's own filing threshold. See design/progress/goblin_mech_ai.md ("Pass 2"). Lease released.
- 2026-09-23 17:34 EDT — the 80-step playtest for the outline-width/goblin_mech_ai change (below) finished clean: PLAYTEST OK, 0 failing check(s), full 80 steps, exit code 0. Ran slow this session (real CPU time, the same sandbox flakiness status/fixer.md has noted before, not a hang) but finished with no artificial cutoff. No regression. See design/progress/goblin_mech_ai.md. Lease released.
- 2026-09-23 17:19 EDT — gave outline.gdshader's shared ink-outline a per-model width scale (OUTLINE_WIDTH_SCALE in combat_3d.gd, threaded through toon_material/toon_all/_shade_model), took the still-open to:fixer request myself since it was blocking JACKAL-BAR's loudest line and neither Meshy (0/8 today) nor Blender (network wall, reconfirmed) had budget for anything else. Wired goblin_mech_ai into HUNTER_AI_ART at scale 0.33 -- went from a near-solid black blob to a clearly-readable hunter in the real fight and the campfire row, jackal/Frog confirmed unaffected (pixel-diff outside the goblin's own region matches ordinary idle-animation jitter). Scored for real for the first time: 37/50, under the 42 hunter stop line -- see design/progress/goblin_mech_ai.md ("Shipped and scored"). Ticked JACKAL-BAR's "reads at fight distance, not a green blob" line for both hunters. ALL TESTS PASSED. 80-step playtest kicked off, ran past the foreground window -- pushed code/frames/write-ups first per COMMON.md 4b, result to follow. Marked the request done.
- 2026-09-23 16:27 EDT — the background 80-step playtest for the foothold-texture change (below) finished clean: PLAYTEST OK, 0 failing check(s), full 80 steps, exit code 0. Confirms the change (a pure material_override/albedo_texture swap) touches no position/foothold-index logic. See design/progress/foothold_rock_detail.md.
- 2026-09-23 16:24 EDT — gave the shared floating footholds a generated (numpy/PIL toroidal-Voronoi) faceted-rock detail texture, mat.albedo_texture on _build_float_stones' SphereMesh, multiplied over the existing per-stone BROWN tint (unchanged). Both Meshy (0/8 left) and Blender (download.blender.org hard-403 this session) unavailable, so pure 2D texture, no geometry/logic touched. ALL TESTS PASSED. Before/after verified in the real fight at state=3dgrip (a real reachable mid-climb state) -- flat orange blob to visibly cracked/faceted rock. 80-step playtest pushed to background past the 590s cap; pushed code first per COMMON.md 4b, result to follow. See design/progress/foothold_rock_detail.md. Lease released.
- 2026-09-23 15:48 EDT — playtest for the above finished clean: PLAYTEST OK, 0 failing check(s), all 80 steps, exit code 0. Confirms the committed diff (goblin_mech_ai asset + docs, HUNTER_AI_ART reverted to shipped state) touches no gameplay code. Lease released.
- 2026-09-23 15:40 EDT — built the Goblin Engineer's Meshy rebuild (1 preview + 1 refine, 8/8 daily Meshy tasks now spent), cleaned/decimated in Blender to goblin_mech_ai.glb. Wired into HUNTER_AI_ART to test: reads as a near-solid black blob at true in-fight size, not a texture problem -- isolated the cause to outline.gdshader's fixed ink-outline width overlapping on this hunter's many thin parts (jackal/frog are thick rounded masses, this one isn't). Reverted HUNTER_AI_ART (git diff clean), kept the built asset committed unwired. Filed to:fixer with the diagnosis and a before/after frame. ALL TESTS PASSED; 80-step playtest re-run against the final reverted state. See design/progress/goblin_mech_ai.md.
- 2026-09-23 18:34 UTC — took the answered arena-wall-accent request: rebuilt the Cinder Jackal arena's enclosing wall with a Meshy-generated crater rim (2 Meshy tasks), left the floor untouched, shipped as cinder_jackal_ai.glb via a new ENV_AI_ART table in combat_3d.gd. Scored 37/50 (design/progress/cinder_jackal_ground.md pass 6), up from 28. ALL TESTS PASSED, 80-step playtest clean (PLAYTEST OK, 0 failing checks). Ticked both JACKAL-BAR.md arena lines. Request marked done.

- 2026-09-23 — Meshy network wall confirmed down (the to:nick request landed,
  re-verified independently: fetched all 3 logged Frog previews, no proxy
  403). Fresh six-view arena look found nothing new (systemic wall issue
  still open, still Nick's call). Built `frog_ai` pass 1: fetched Meshy
  candidate A, wrote `tools/blender/ai/frog_ai_spike.py` (hunter-specific,
  not `ai_beast.py`), welded/oriented/scaled-to-1.15/decimated to 5200 tris.
  Reads as a frog immediately, even at 64px silhouette. Deliberately not
  textured, not rigged, not wired into `cast/frog.glb`/`AI_ART` — the
  hunter-display-path request (to fixer) was still open when this pass
  started (the fixer took it mid-run, per a concurrent push). Committed and
  pushed (a prior run apparently spiked this and lost it by not pushing).
  ALL TESTS PASSED (no game code touched).
- 2026-09-23 — (a concurrent run, log entry not left by its own author —
  added here for the record) jackal footholds recoloured from a cool grey
  to BROWN (`combat_3d.gd` `_build_float_stones()`), matching the arena's
  own scattered-boulder swatch. See `## Old: jackal footholds` above.
- 2026-09-23 — `goblin_mech` pass 8: fresh six-view look at the last open
  Style candidate (goggle strap at oblique angles) found a real defect pass
  4 never saw — the strap's own Y-radius put its front edge ahead of the
  goggle barrel/lens it's mounted to (measured: -0.290 vs -0.262 vs -0.228),
  reading as a blade/beak at the fight-camera (3/4) and profile angles.
  Pulled Y-radius 0.180→0.105, verified tri budget/silhouette/portrait/
  in-fight, no tri cost. Style 8→9, 39→40/50. ALL TESTS PASSED; playtest
  re-run, one pre-existing `hunter-off-marker` FAIL (already filed, no code
  path from a decorative-ring radius to foothold placement).
- 2026-09-23 — Meshy hunter rebuild attempt hit a network-policy wall:
  `api.meshy.ai` works, `fetch`'s `assets.meshy.ai` is denied by the
  sandbox; 3 Frog previews generated, unretrievable. Filed to:nick (network)
  and to:fixer (hunters never get the beast toon/anim display path — a
  rigged Meshy hunter would render worse than today's primitives without
  it). Pivoted to `goblin_mech` pass 7: did the rig-scale-up experiment pass
  6 flagged, scaled every rig coordinate+size from one pivot in the
  generator (not a post-hoc mesh transform), verified every risk pass 6
  named, Proportion 7→8, 38→39/50. Matched-pair playtest (rebuilt vs stock,
  same seed) confirmed both playtest FAILs found are pre-existing. ALL
  TESTS PASSED.
- 2026-09-23 — pass 6 on `goblin_mech` (item 2, hunters, cap lifted): fresh
  six-view check found no new defect. Re-confirmed pass 4's crown-zigzag
  fix wasn't oversold (compared its own before/after renders directly),
  confirmed the whole silhouette including the ordinary arm is one
  connected component (`scipy.ndimage.label`), and measured the
  rig-vs-ordinary-arm size disparity as real but moderate — Prop/Hygiene's
  existing 7s hold up, not hidden defects. Considered and declined a
  rig-scale-up experiment for Proportion as too risky without a full
  iterate cycle. Score unchanged, 38/50. Separately: verified the arena's
  open "RUST wall accent visibility" question across all 5 real fight
  camera states plus a wide framing — confirmed it never shows in play
  (only in the loop's own scoring camera) — and filed
  `to: nick` (`requests/2026-09-23-1200-artist-to-nick-arena-wall-accent-never-shows.md`)
  since the fix lives in shared `env.py` code. No code changed;
  `ALL TESTS PASSED`. See `design/progress/goblin_mech.md` pass 6,
  `design/progress/cinder_jackal_ground.md` pass 4, and `## Now`/`## Next`
  above for the full write-up.
- 2026-09-23 — pass 5 on `goblin_mech` (item 2, hunters, cap lifted),
  37→38/50: checked pass 4's two open candidates (wrist-joint curvature,
  claw/piston distinctness) fresh and ruled both non-issues, not fixed.
  Found and fixed a real one instead — GRAPHITE and CHARCOAL, the rig's two
  largest single-colour masses (compressor box, hose ring), sample at
  near-identical luminance (59.4/56.4) against this same rig's own STONE/
  PEWTER (114.1/139.5), leaving little headroom for the toon-shaded bevel
  highlight the model's own docstring says is the rig's whole job. Moved
  both to STONE, no new hue, no geometry/tri change (`_sil.png`
  pixel-identical, 1378 tris both builds). **Got the first in-game
  verification wrong and corrected it on the record**: an initial
  mid-strike camouflage claim (13.8-luminance-gap sample) turned out to be
  a misidentified pixel — the sampled point was pixel-identical before and
  after the fix, and a diagnostic recolour confirmed it was the jackal's
  own wing membrane, not the rig, which is mostly self-occluded in that
  pose. Re-verified properly: isolated renders show a real (if
  shader-compressed, +6.9 mean luminance) lightening, and a genuinely
  unoccluded in-game pose (`state=3dgrip slot=1`) confirms it without
  repeating the earlier mistake. Colour 7→8. `ALL TESTS PASSED`; playtest
  re-run, the one failure (`hunter-off-marker`, foothold 4) matches the
  already-open fixer request by exact coordinates, pre-existing. See
  `design/progress/goblin_mech.md` and `## Now` above for the full
  write-up, including the misidentified-pixel correction in full.
- 2026-09-23 — pass 8 on `frog` (item 2, hunters), 41→43/50: fixed pass 7's
  own named candidate — the front legs never broke the silhouette the way
  the haunch does since pass 5. Three attempts, each looked at in a render
  before the next: a fatter limb radius (marginal, mostly the foot), a
  shoulder ball placed by a local surface calc (still barely visible — the
  scoring camera's compound silhouette hides more than one ellipsoid's own
  local surface implies), a much bigger ball placed away from the limb
  (broke the silhouette but read as a glued-on third lump in `_side.png`).
  Landed on a shoulder ball placed almost exactly where the limb starts —
  the same relationship pass 5's own knee ball has with the hindleg — which
  reads as an integrated shoulder in `_side`/`_form` and still gives a real,
  if modest, 670px `_sil` diff. Cost: +336 tris (4800→5136), a further
  increase on the model's already-deliberate overage. Sil 8→9, Prop 8→9 —
  **clears the 42 hunter stop line.** Verified in isolated renders (`_sil`,
  `_side`, `_front`, `_top`, unchanged footprint), the live fight camera
  (real, localised diff on the frog, not the goblin or the jackal's own
  idle pulse), and the 34px portrait (honestly does not show this fix,
  unlike some earlier passes — reported, not hidden). `ALL TESTS PASSED`;
  playtest re-run, the one failure (`hunter-off-marker` at foothold 4)
  matches the already-open fixer request by exact coordinates, pre-existing.
  `frog` is now past its stop line — next run moves to `goblin_mech` or the
  Meshy-rig fixer request unless something new is found. See
  `design/progress/frog.md` and `## Now` above for the full write-up.
- 2026-09-23 — pass 7 on `frog` (item 2, hunters) under Nick's wider "make
  the characters CLEAN, pull from AAA games" brief, 40→41/50: diagnosed
  Style (never had a dedicated pass) using a named greyscale/value-contrast
  technique — measured every colour boundary on the model off the atlas's
  own pixels and found the AMBER toes vs the MINT foot pad were the
  weakest on the whole model (18.8 luminance gap, against 38–100+
  everywhere else), on the one feature the model's own docstring calls
  its foot's main read. Fixed with a single colour swap, AMBER→RUST (a
  43-point gap, and this fight's own established warm accent), no geometry
  change. Verified in a greyscale render, a live-fight before/after
  (real, localised diff on both hunters), and — a first — the 34px party
  portrait, which actually shows this fix where it didn't show pass 6's.
  Considered and explicitly declined a heavier option this run: a
  Meshy-generated, jackal-fidelity rigged hunter, blocked on game code
  only the fixer can build (`COMMON.md`'s own rule against forcing hunters
  through `ai_beast.py`) — flagged as a future `to: fixer` request, not
  attempted blind. `ALL TESTS PASSED`; playtest re-run, one failure
  (`hunter-off-marker` at foothold 4) matched the already-open fixer
  request by exact coordinates. See `design/progress/frog.md` and `## Now`
  above for the full write-up.
- 2026-09-23 — pass 6 of the asset loop on `frog` (item 2, hunters, cap
  lifted), 38→40/50: fixed pass 5's two tied-lowest lines, one concrete fix
  each. Colour: added the GREEN dorsal saddle the file's own docstring had
  always promised but never built, solved against the body/head ellipsoids'
  own surface equations so it reads on the back without touching the
  pass-5 haunch notch (`frog_pass6_sil.png` pixel-identical to pass 5's).
  Hygiene: found the two nostril balls were fully submerged inside the
  head's own surface — tris spent on zero pixels — and moved them out
  until they clear it. Cost: +100 tris for the new marking (4700→4800),
  named as a real addition to the model's already-deliberate overage, not
  buried. Verified in isolated renders, a live-fight before/after (real,
  localised diff on both hunters), and the 34px party portrait — which
  honestly does NOT show either fix, left open for a future pass rather
  than claimed. `ALL TESTS PASSED`; playtest re-run, both failures
  (`hop-flat`, `hunter-off-marker` at foothold 4) matched already-on-record
  pre-existing issues by exact coordinate/pattern, not new. See
  `design/progress/frog.md` and `## Now` above for the full write-up.
- 2026-09-23 — pass 5 of the asset loop on `frog` (item 2, hunters, cap
  lifted), 36→38/50: applied the pass-4 diagnosis in full — narrowed the
  trunk ball's depth and pushed the haunch knee outward in X — so the
  haunch reads as a bulge breaking the silhouette instead of merging into
  one round mass. Wrote the missing ANCHOR sentence. Verified in
  `_sil.png`/`_form.png` and a live-fight before/after pixel diff (change
  is real and confined to the hunter's footprint). Sil 7→8, Prop 7→8;
  geometry count unchanged. `ALL TESTS PASSED`; playtest re-run, the one
  failure (`hunter-off-marker` at foothold 4) matches the already-open
  fixer request exactly (same coordinates), confirmed pre-existing. See
  `design/progress/frog.md` and `## Now` above for the full write-up.
- 2026-09-23 — took the standing `to: artist` request, the leap-style
  recreate test: studied `leap.png`'s style in words (flat shapes, no
  outlines, atmospheric-perspective depth, full-height tree-corridor
  composition, tiny off-centre subject), then built one new card
  (`Hop`, Frog's starter deck, previously a bare icon) in that style via a
  pure 2D procedural paint (`tools/cardpaint.py`) — not a Blender render,
  since `leap.png` itself has no 3D shading cue to render toward. Palette
  sampled from `leap.png`'s own pixel histogram, not invented. Took three
  full rewrites (empty-sky gap → inverted/hanging trees → lobed canopies on
  bare trunks, the fix that actually read as leap's style) before it held
  together. Verdict, written into the request: gets the surface cues close
  enough to read as "the same family," especially at card size, but not
  Nick's hand — recommend NOT scaling this to the rest of the deck. Not
  shipped into `cardart/`, no second card, per the request's own limits.
  `ALL TESTS PASSED`. See the request
  (`requests/2026-09-23-0500-nick-to-artist-recreate-leap-style.md`) for
  the full writeup and `## Now` above for the short version.
- 2026-09-23 — cards (item 4), first pass: built a model-rendered card art
  pipeline (`tools/blender/cardart.py`, `tools/cardbg.py`) instead of
  waiting on Nick's Canva paintings, proved it on the Goblin Engineer's
  `Piston Punch` (zero painted cards on that hunter previously). Verified
  in a real hand next to both a bare-icon card and generated cards, in the
  inspector, `ALL TESTS PASSED`, playtest clean. Filed `to: nick` before
  scaling to the other ~30 cards — a style/taste call, not a code one. See
  `## Now` for the full write-up.
- 2026-09-23 — pass 4 of the asset loop on `goblin_mech` (item 2, hunters),
  35→37/50, the asset's 4-pass cap: found and fixed the real cause behind
  three passes of "reads as scattered blocks" — the upper-arm and wrist
  limbs' hex end-caps exposed as a sharp zigzag right at their box joints
  (diagnosed by a diagnostic recolour, which also cleared the CHARCOAL
  collar ring of the same suspicion) — smoothed both (`seg` 6→10, Sil
  7→8), and thickened the goggle strap ring, which read as a blade from
  the side (Style 7→8). Freed the +48 tri cost with four small, verified
  cuts elsewhere, 1396→1378, still under budget. `_sil.png` pixel-diff
  0.4% (lit-shading only); in-fight capture diff smaller than pass 3's own
  idle-animation noise floor. Playtest's `hop-flat` fail checked directly
  against the unmodified baseline — fires there too, pre-existing,
  unrelated to this asset. `ALL TESTS PASSED`. See
  `design/progress/goblin_mech.md` for the full pass detail.
- 2026-09-23 — pass 3 of the asset loop on `goblin_mech` (item 2, hunters),
  33→35/50: resolved pass 1/2's "unsure about" (the exhaust pipe reads
  fine in every camera the game uses, only separates in a top-down view
  nobody sees) as a non-issue, ruled out an unrelated pale-blue triangle
  in the live fight screenshot as `combat_3d.gd`'s own hunter-slot pip
  marker rather than an asset bug, and closed the 84-tri budget overage
  (1484→1396) by trimming segment counts on the model's biggest/gentlest
  masses and its thinnest rod — verified pixel-identical at the 64px
  silhouette rubric and unchanged in the live fight camera. Hygiene 5→7.
  `ALL TESTS PASSED`; playtest re-run (40 steps), 0 failing checks. See
  `design/progress/goblin_mech.md` for the full pass detail.
- 2026-09-22 — scored `cinder_jackal`'s fight ground (never scored before,
  despite existing renders), 22→28/50 over two applied fixes: the
  `enclose()` wall recoloured from generic SLATE/PEWTER to CHARCOAL/RUST,
  and the boulder/slab scatter from PEWTER/STONE to BROWN/CLAY, both
  matching the beast's own warm palette instead of a colour dropped in
  from a different biome. Verified in the real fight camera (not just the
  isolated Blender render, which oversold the effect under neutral
  lighting) with a direct pixel sample at the sigil close-up. Stopped
  short of the 44/50 ground stop-line on purpose — the remaining two low
  lines are the same shared-wall-system finding two other grounds already
  flagged for Nick. `ALL TESTS PASSED`; playtest re-run against the
  rebuilt ground. See `design/progress/cinder_jackal_ground.md` for the
  full pass-by-pass log.
- 2026-09-22 — fixed the jackal ear-glare request (texture edit, not a
  shader change — see `## Old`). `ALL TESTS PASSED`; checked every 3D
  camera state, no regression.
- 2026-09-22 — note created by the session.
