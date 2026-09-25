---
tags:
  - agent-status
agent: director
updated: 2026-09-25T06:05
working_on: The camera fix landed at 05:56 and the Frog is drawn through the opening of the Leap; the rest of the flight is still proven only by projection, so 0506 settles it.
---

# director

## This run — 2026-09-25 05:57 EDT

- **Did:** better, as of 05:56: the Frog is now drawn leaping at the beast's feet, where it was invisible before.
- **Worked?** Yes for the opening of the Leap, which I counted myself; the rest of the flight is still unproven.
- **Next:** playtester spreads the shots over the whole flight and counts pixels; fixer puts stones under the landings.
- **Need from you:** the same five rows; the lens-vs-gap one unblocks the stones and the sigil shot.

## Now

**What a player sees, before I read anyone's note (05:57, on
`e9196c3`).** Pixel-diffed against my 05:00 frames: resting 4%, sigil 0.4%,
grip 3% of pixels moved, all of it idle breath and tail. Same three shots,
so I am not committing them again. Resting: the black jackal a third of the
frame tall, upper-middle, ears in the sky, "Attack 7" beside the head; the
Frog huge in profile bottom-left, the Goblin facing the camera on the right;
the pale box with the orange lid on the left, and at the beast's chest two
beige lumps with a gold ring that read, at play size, as a bag the jackal is
carrying. Sigil: four-fifths purple sky, "Attack 7" over nothing, the beast a
black lump behind the cards, the Frog a speck on a plate, the Goblin out of
frame. Grip: the Frog behind a red "3", the beast's skull behind the boss bar.

![[frames/director/2026-09-25-0500-director-resting-shot.png]]
![[frames/director/2026-09-25-0500-director-at-the-sigil.png]]
![[frames/director/2026-09-25-0500-director-grip.png]]

**Against the drawing:** the beast should fill the upper two thirds with
white stones on its limbs and the Frog tiny; we have the beast at a third,
the Frog at a quarter, and the stones in the gap between them. Every one of
those is the gap-vs-lens question sitting in Nick's column since 21:55
yesterday. Nick has said the drawing is placement only, not colour, so the
black jackal and the purple sky are right and stay.

**Did the fight get better for Nick, or did a score go up?** Neither, as of
this note's first draft — see the addendum below for what landed at 05:56. Since 05:12 one commit touched the game and it was a check
(`playtest.gd`), no view. That is correct: the artist has three tickets with
Nick and built nothing rather than something; the fixer claimed at 05:19 and
is, by its own queue, on the camera lock (`0420`, high) — its result may
land after this note. Nothing to push on either.

**The one real finding this hour is the playtester's, and it is a
composition fact, not a check bug.** The small stone that looks like it sits
on the beast's chest is one of the route's floating waypoints, 42 world
units in front of the beast's nearest surface — most of the way back across
the gap — and it lines up with the chest only from the resting camera. I had
told both the fixer and the playtester it was "on the body" because that is
how it reads. It reads that way by foreshortening. So: the drawing's
stones-on-the-limbs is not built yet, only mimicked from one angle, and it
cannot be built until Nick answers the gap question. Recorded on #18 (mine).

**Answered the playtester's question (`0257`, handed to me at 05:31).**
Neither of its two options. Not a named exemption — that hides the exact
class of bug the check exists for. Not a route bend — the stones' depth is
Nick's gap, and the check does not move stones. The lever is the metric:
its own crop shows a corner graze where the rectangle says 23%, because a
quadruped's rect is mostly air. Folded it into `0506`: one drawn-pixel
primitive, used by both `hunter-lost-mid-hop` and `beast-behind-stone`;
print rect and pixel numbers side by side for a run so the old figure dies
honestly. Thresholds untouched, no rebuild. Re-addressed `to: playtester`,
normal, after `0506`.

**Addendum, 06:05 — the fixer landed the camera lock at 05:56, after
the note above was written, and I looked rather than trusted it.** Reran
the same 24-step play on `a6f97ed` and counted Frog pixels in the 24 Leap
frames with the same detector as last run: 200-400 in every frame, where
last run found zero in all 24. At 1:1 the mid-Leap shot is the best frame
this fight has produced: the whole beast, face clear, tag above the head,
the Frog in the air between its forelegs with a stone under it. A player
sees a frog leaping at a jackal. That is the fight getting better, and it
is the fixer's, with tests.

![[frames/director/2026-09-25-0605-director-leap-frog-visible.png]]

![[frames/director/2026-09-25-0605-director-leap-sheet-after-camera-fix.png]]

**The honest limit, which nobody's number states:** the 24 shots are the
FIRST 24 frames of a 167-frame flight, one per frame (`shots < 24` in the
harness), so both my old "0 of 24" and the fixer's "24 of 24" describe the
opening 14% of the Leap. The Frog's centroid across those frames dips and
rises about 90 px and comes back — one sub-hop at the beast's feet. Whether
it stays visible on the way up to the head is proven only by the projection
check (`167/167`), which is the very thing `0506` says is not visibility.
Added one bullet to `0506`: spread the shots across the flight; cap and
counting unchanged. That is my second filed thing this run; the third slot
stays empty.

**Audit of what closed since 05:12:** nothing closed. **Stuck:** nothing
new; `2356` (face behind the tag) is still `taken` with an eta of "this run"
from 23:56 — it rides #14's handback by my own 05:12 call and the head is
clear in the resting shot, so I am leaving it, but if it is still `taken`
with no movement at my next run it comes off the fixer's plate and into a
plain "close or say what is left". Nick's five rows are unchanged and none
has an answer; nothing of his was decided without him this hour.

**Filed:** one thing (the `0257` answer and re-route). Two of my three
slots unused on purpose — the fixer's queue is set and live, the artist's
is with Nick, and the playtester's next two are already `0506` then this.

**What is working:** the artist confirming nothing is unblocked instead of
inventing work; the playtester printing real numbers, then reverting to
prove which line clears the sigil. Do not optimise either away.

**Not filed (kept for later):** a dark-blue wedge behind the beast's
shoulder in the resting shot (wall geometry or sky accent, harmless at play
size); the sigil shot's empty sky and the Goblin out of frame there — #18
step 3, after the gap and the stones, per Nick's own order.

## Log

- 2026-09-25 06:05 EDT — addendum: fixer's camera lock landed 05:56; verified by my own pixel count, Frog drawn in 24/24 opening Leap frames (was 0/24) and the mid-Leap shot is the best frame yet; found the 24 shots are the first 24 frames only, added to 0506.
- 2026-09-25 05:57 EDT — nothing visible moved (frames identical to 05:00 bar idle); fixer live on camera lock; answered the playtester's chest-stone handback (pixel metric via 0506, no exemption, no route bend) — the chest stone is a floating waypoint that only lines up from one camera, recorded on #18; nothing closed, nothing stuck, Nick's five rows unchanged.
- 2026-09-25 05:12 EDT — fight not better; hop split landed correct-but-invisible (Frog drawn in 0/24 Leap frames, lands on air twice). Raised fixer's camera-lock to high, filed stones-under-landings (fixer) and drawn-pixels check (playtester); #14 eta un-staled.
- 2026-09-25 04:08 EDT — nothing reached the game this hour; camera ask to Nick rewritten to name the gap-vs-two-thirds collision; hunters-face-the-beast filed to fixer after the hops; fixer told stone 2/5 are on-body; playtester pointed at the on-body split.
- 2026-09-25 02:58 EDT — fight better (whole beast back, fixer 02:49; red horizon line gone, artist 02:35), no scores moved; the near stone's box-with-a-lid shape is two of Nick's own inputs in conflict — filed to him with options; playtester told the tree moved under it and a stone on the body is not a failure; fixer told Height 2 stays, close the ticket, hops next; popup-on-the-Frog filed to fixer for after the hops.
- 2026-09-25 02:05 EDT — Goblin reads beside the Frog (artist, #13 handed back right); the fixer's stone sweep landed mid-run and the near rock now hides the beast chest-to-paws — filed the placement fix to the fixer, the occlusion check to the playtester, unblocked #19 for the artist. My miss: #14's visible half ("beast stays visible") was never stated.
- 2026-09-25 01:00 EDT — fight better again (Frog reads and matches the drawing; beast's head clear of the HUD, fixer 00:52); no scores moved; named the style-C vs smooth contradiction for Nick on #13 with options; artist sequenced (Goblin next, do not touch the Frog, do not decimate); #14 now the only blocker.
- 2026-09-25 00:03 EDT — fight visibly better (close shot landed: Frog quarter-frame, diagonal); beast head behind the HUD filed to fixer; #13 told it is unblocked; #19 re-routed to artist with the artist's correct cause; #14 sequenced (head → stones → 20 m hop).
- 2026-09-24 22:58 EDT — nothing visible moved; camera lock (fixer) and boulder mesh (artist) both landed correct-but-invisible by my own scoping. Advised the fixer on the over-the-shoulder framing, filed the horizon line to the artist, asked Nick for the RoR picture as a ticket.
- 2026-09-24 22:35 EDT — Nick live: three asks by morning. Camera ticket rewritten (locked by default, RoR shot), #14 re-aimed on his route_pos, #13 re-aimed smooth, playtester told its checks read the old route.
- 2026-09-24 21:58 EDT — no movement on #14; relayed Nick's camera-switch ask to the fixer, closed #3 into #14/#18, filed stones-shape (artist) and jackal keep/revert (nick).
- 2026-09-24 20:09 EDT — took #18; reorganised #4/#5/#11/#14/#15/#17 (one live stones ticket, Nick's column cleared).
- 2026-09-24 19:20 EDT — Nick could not see my question; refiled it as a `to: nick` request (black jackal vs hot orange). Rule recorded above.

- 2026-09-24 18:40 EDT — first run. Rendered 3d/3dclimb/3dgrip, compared with Nick's drawing, filed 3 requests (2 fixer, 1 artist).
