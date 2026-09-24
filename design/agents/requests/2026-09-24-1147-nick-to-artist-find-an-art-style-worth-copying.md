---

tags:
  - request
from: nick
to: nick
status: open
priority: high
beast: cinder_jackal
created: 2026-09-24T11:47
taken_by: artist
ask: Four real art-style directions, two shown on the actual jackal fight — which one (if any) should I build toward?
waiting: false
issue: 8
---



# Research art styles and bring me ones we could actually use

▶ **[Fight this now](obsidian://shell-commands/?vault=design&execute=fight-request-beast)** — opens the fight this note is about.

## What I want

The style we have is **nice, but we can do better**. I am not asking you to
polish what is here — I want to see what else this game could look like.

Go and research art styles. Come back with a handful we could actually use,
and show me, do not describe:

- **3 to 5 candidates**, each a real, named style with real games or artists
  behind it — not "stylised" or "painterly" as a word, but "this specific
  look, which these games achieve like this."
- **For each one:** why it suits a co-op game about two small hunters climbing
  a huge beast, and what it would cost us — can our pipeline (Meshy, Blender,
  the toon shader) actually produce it, or does it need something we do not
  have?
- **Show it on OUR content.** A style I cannot picture on the Cinder Jackal is
  not a candidate. Even a rough pass on one beast or one hunter beats a
  paragraph — shader tweaks, palette swaps, an outline change, a texture
  treatment, whatever gets it closest cheaply.
- **Say which ONE you would pick and why.** I want your opinion, not a menu.

Not a rebuild. I am choosing a direction first; nothing gets restyled for real
until I say yes.

## How to see it

Click the link above and look at the fight as it is now — that is the baseline
you are beating.

## Done when

- 3-5 named candidates, each with: the look, who does it, why it fits us, what
  it costs, and whether our pipeline can do it.
- At least one rough visual per candidate, on our own content, at real fight
  size.
- Your recommendation, with the reason.
- Filed back to me to pick.

## Nick's answer

<!-- (I pick a direction here) -->

## Result — artist, 2026-09-24 13:12 EDT

Four real, named styles. I actually built two of them on the live Cinder
Jackal fight (shader and light values only, nothing shipped — reverted the
moment I had the screenshots, `git status` is clean) so the two you can most
cheaply have are also the two you can see below, not just read about. The
other two I describe and cost honestly rather than fake a render for
something our pipeline can't currently produce.

### A. Bold cel — The Legend of Zelda: The Wind Waker (Nintendo EAD, 2002)

A thick, hand-inked black outline around every character and creature, hard
flat colour bands instead of a soft gradient, and a warm, saturated palette.
It is the style people mean when they say "cartoon 3D" — Genshin Impact and
Hearthstone's own 3D cinematics lean on the same idea today.

**Why it could fit:** we already have an inverted-hull ink outline and a
banded toon shader — this is not a new system, it is turning the two knobs
we already have further in the direction they already point. Free
readability at a distance, which matters when a player is picking a hunter
out against a huge beast.

**What it costs:** nothing new to build — it's two numbers (`outline.gdshader`'s
line width, `toon.gdshader`'s band softness) plus a punchier palette. I
turned both up and rendered the jackal:

![[frames/artist/2026-09-24-style-A-windwaker-close.png]]

**The real cost showed up immediately, and it's useful to know now rather
than after a full rebuild:** the same bold line that reads great on the
jackal's thick legs turns the Frog into a black blob at the hunter's actual
on-screen size:

![[frames/artist/2026-09-24-style-A-windwaker-hunter-cost.png]]

Not a dead end — the game already has a per-model outline-width knob
(`OUTLINE_WIDTH_SCALE`, already used to thin the Goblin Engineer's own
line), so a bold-line direction is buildable, it just needs each hunter
tuned down separately rather than one global number. Worth knowing before
picking this one: it's cheap in shader terms, but not a single global
slider — every small character needs its own pass.

### B. Atmospheric scale-drama — Shadow of the Colossus / Team ICO (Fumito Ueda)

Muted, almost desaturated colour, heavy haze eating the distance, soft
continuous light instead of hard bands, and a nearly invisible outline. The
whole visual language exists to sell ONE thing: something enormous, and you,
very small, in front of it. This is not a loose comparison — it is
literally our own premise, two small hunters climbing a huge beast.

**What it costs:** also nothing new — the opposite three knobs from A
(thinner outline, wider soft band so the shading reads as one continuous
gradient instead of steps, less rim) plus turning up the fog density this
biome already has a slot for (`BIOME.quarry.density`). Rendered on the same
jackal, same camera:

![[frames/artist/2026-09-24-style-B-sotc-wide.png]]
![[frames/artist/2026-09-24-style-B-sotc-close.png]]

The far cave wall now recedes into real haze instead of sitting flat and
equally lit at every distance, and the jackal's legs read as one solid,
weighty form instead of three hard-edged colour steps. No hunter-scale
problem here either — a thin line only gets MORE forgiving on a small
character, never less, which is the opposite of candidate A's trap.

### C. Low-poly flat-shaded — Risk of Rain 2 (Hopoo Games)

Deliberately low, faceted geometry, one hard light band with no gradient at
all, bright flat colour, emissive accents doing the "this is dangerous/hot"
work instead of texture detail. It reads as confident rather than cheap
because it never pretends to be more detailed than it is.

**Why it could fit us specifically, not just generically:** this is the one
candidate that would fix a real, already-open problem instead of costing us
something new. Every cast member we've built (jackal, Goblin Engineer, Frog)
is stuck under its own tri-budget/file-hygiene ceiling because Meshy ships
far more geometry than our stated budget — three separate progress notes
have independently hit this wall, and the honest fix is a full manual
retopology none of us has attempted. A style that WANTS low-poly geometry
turns that liability into the actual visual identity instead of a debt we
keep almost paying off.

**What it costs — real numbers, from an actual test on our own
Goblin Engineer** (`design/progress/goblin_mech_ai.md`, pass 8, 2026-09-24
07:16 run): cutting the shipped model 40% (5,199 → 3,119 tris) looked
completely free at every camera distance I checked; cutting it 70% (down
near our actual hunter budget) started visibly faceting the tank and boots.
So the honest cost is: **a real style, not a free one** — it would mean
deliberately embracing the facets at the higher cut rather than fighting
them, which is a genuine geometry/shader pass on every cast member, not a
number tweak. I did not render a fresh demo this run (the safe cut is
already photographed in that pass's own frame) rather than spend more
Meshy/Blender time on a third full render when the existing evidence
already answers "can our pipeline do this."

### D. Hand-painted readable-at-distance — World of Warcraft / Hearthstone (Blizzard)

Warm, saturated, hand-painted-looking textures with the shading baked
straight into the paint, exaggerated silhouettes built specifically so a
small character stays readable in a crowd or at a distance. This is the
AAA benchmark for exactly our problem — telling two small hunters apart
against one huge, detailed boss.

**What it costs — the honest answer: something we do not have.** This look
comes from an actual painter hand-painting every texture with the lighting
built in; it is not a shader trick or a palette swap. Meshy gives us a
photoreal-leaning auto-texture, not a hand-painted one, and nobody on this
project paints textures today (the card-art painting flow is Nick's own
Canva work, parked, and is 2D card faces, not 3D model textures). Doing
this for real would mean either a new AI image-to-texture step we haven't
built, or actual paint-over work on every model by hand. I'm not
recommending this one to start — it's the strongest look on the list and
the most expensive, flagged honestly rather than talked up with a render
that isn't really it.

### My recommendation: B, Shadow of the Colossus

It is the cheapest of the four (light, fog and two existing shader knobs —
no new textures, no new geometry, no Meshy spend), it is thematically the
most honest fit we could pick (this genre's whole reason to exist is small
figures against something huge), and it sidesteps candidate A's real
problem for free instead of creating one (a thin line never swallows a
small hunter; a thick one always risks it). It also doesn't fight the
mobile-performance budget this project is committed to (`CLAUDE.md` §5) —
if anything it's lighter than what we render today.

If you want punch as well as mood, A's bold outline is a real, buildable
follow-on once each hunter has its own tuned width — not exclusive with B,
just a second pass once B's base direction is settled.

### What I need

- **Pick one of the four (or say "none of these, try again")** — A (bold
  cel, Wind Waker), B (atmospheric scale-drama, Shadow of the Colossus, my
  pick), C (low-poly flat-shaded, Risk of Rain 2), or D (hand-painted,
  Blizzard).
- This is a direction only — nothing above is shipped; both demoed
  candidates were reverted the moment their screenshots were taken
  (`git status` clean, confirmed before this note was written).
- Once you pick, I'll scope the real build as its own request — a shader
  and biome-light pass for A or B, a scoped geometry pass for C, or (if D)
  a look at what an added texture-painting step would actually take before
  promising it.
