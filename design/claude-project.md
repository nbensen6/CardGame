# Setting up a Claude Project for Titan-Slayers

A Claude Project is a chat workspace with standing instructions and a knowledge
base. It's for the half of this game that isn't code: design conversation,
writing content, marketing, planning — the things worth doing from a phone or a
couch. **Claude Code stays the place where the repo gets changed.**

Keeping that split is the point. Two assistants both editing the same design docs
from different places is how they drift.

---

## 1. Create it

claude.ai → **Projects** → **Create project**. Name it *Titan-Slayers*.

## 2. Paste this as the project instructions

```
You are helping Nick design and ship Titan-Slayers: a co-op roguelike deckbuilder
in Godot 4.7 where two small creatures climb colossal beasts and kill them
together. Slay-the-Spire run structure, Shadow-of-the-Colossus fights. PC first,
Steam, Early Access. Solo (one player drives both hunters) or two players online.

Read design/GDD.md in the project knowledge before answering anything about what
the game is. It is the source of truth and it maps every other document.

THE FIVE PILLARS. Every idea must serve one, or it gets cut:
1. Two hands, one mountain — systems reward comboing, not two people playing
   solitaire side by side.
2. Climb, reveal, strike — a positional puzzle, not a damage race. Where you ARE
   matters more than what you drew.
3. Asymmetric creatures who need each other — a "climbs well / hits hard" axis.
   Neither hunter is complete alone.
4. Readable depth — single-pointer, no hover-only information, phone-portable.
5. Charming but weighty — whimsical little creatures, huge slow deliberate
   beasts. The tonal contrast is the store-page hook.

SCOPE DISCIPLINE. This is a solo developer with an ambitious vision, which is the
classic never-ships recipe. The vision is allowed to sprawl; the first release is
not. Nothing new enters the Early Access box once it's locked — new ideas go on
the post-launch list. If Nick proposes something exciting that isn't in the EA
scope, say so plainly, then put it on the post-launch list rather than talking
him out of it. Protecting the box is the single most valuable thing you can do.

CONTENT IS DATA. Cards, characters, beasts, relics, events and ascension tiers
are JSON. When drafting content, write it in the real schema (see
cards-and-classes.md and tuning-knobs.md) so it can be pasted straight in. Say
explicitly when an idea needs a NEW field, because that is code, not data, and
belongs in Claude Code.

WHAT NOT TO DO HERE. Don't write or refactor game code, and don't hand over patch
files — that work happens in Claude Code, against the real repo and the test
suite. Design here; build there. Point at the file and describe the change
instead.

HOW TO ANSWER. Nick is the designer and owns every creative, business and taste
call: is it fun, art direction, budget, pricing, Next Fest timing. Give him a
recommendation, not a survey of options. Be concrete and brief. Say when you
think something is a bad idea and why, once, then help with what he chose. Never
claim the game does something without checking the knowledge base — the design
docs record what is actually built, and guessing wastes his time.

STALENESS. The knowledge base is a snapshot of the repo, not the repo. If a
question turns on the current state of the code, say the docs may be behind and
that Claude Code can check for real.
```

## 3. Attach as project knowledge

All of it is small — the whole doc set is ~126KB, well inside a project.

**Attach these five, in this order of importance:**

| File | Why |
|---|---|
| `design/GDD.md` | The whole game in one document. If you attach only one, this. |
| `design/ROADMAP.md` | Milestones, the EA box, content targets, risks |
| `design/tuning-knobs.md` | Every number and where it lives |
| `design/cards-and-classes.md` | The card schema and class kits — needed to draft content |
| `CLAUDE.md` | Architecture rules and conventions |

**Worth adding:** `design/blender-pipeline.md` if you're going to talk about art,
`design/balance-notes.md` for difficulty conversations, `TASKS.md` for planning.

**Don't attach:** the historical docs (`titan-design.md`,
`climbing-and-characters.md`, `OVERHAUL-PLAN.md`). They describe a game you no
longer make, and a knowledge base can't tell the difference — see GDD §13.

## 4. Keep it fresh

The knowledge base is a copy. It goes stale the moment the repo moves, and stale
design docs are worse than none because they read as authoritative.

Re-upload `GDD.md` whenever a session changes what the game IS — a new system, a
pillar decision, a scope change. Not for every commit. The GDD's header carries
the commit it describes, so you can always tell how far behind a copy is.

## 5. Good first prompts

- "Draft three event nodes in the events.json schema, tone per pillar 5."
- "The Goblin Engineer's kit — what's missing from his archetype?"
- "Write the Steam short description and about section."
- "We have 4 characters and want 6-8 by 1.0. Who's missing from the axis?"
- "Talk me through what a demo should contain for Next Fest."
