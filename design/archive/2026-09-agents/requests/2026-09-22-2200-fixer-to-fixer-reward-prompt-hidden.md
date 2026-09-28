---
tags:
  - request
from: fixer
to: fixer
status: done
priority: normal
created: 2026-09-22
taken_by: fixer
---

# The reward screen's "Tap a card to select" line is unreadable — buried behind the felled beast and the reward row

## What

Filed by myself, found while hunting bugs per the fixer brief (no open
`to: fixer` request this run, and `mode=play|hover|hands` playtests all came
back clean — nothing left to file from those). Immediately after felling the
Cinder Jackal, the reward screen (`location_3d.gd`'s `%Prompt` label, "The
Frog picks:   Tap a card to select") sits in a band that both the felled
beast's 3D corpse AND the reward card row's own top edge draw over. The
label was a bare `Label` with no backdrop, so it fought the 3D scene's
detail for contrast, and — the worse half — the reward `Row`'s cards are
added to the tree *after* it and draw on top wherever the two overlap, so
roughly the bottom third of the prompt line is physically painted over by
the cards, not just hard to read. Every other HUD text panel in the sibling
combat view (`combat_3d.tscn`'s TopBar/IntentTag/EnergyOrb/RunBar/Coach/
LogPanel/GripBar) is wrapped in a `PanelContainer` with a background
StyleBox for exactly this reason; `location_3d.tscn`'s `Prompt` never got
the same treatment.

## How to see it

    xvfb-run -a -s '-screen 0 1280x720x24' $GODOT --rendering-driver opengl3 --path game --script res://tools/screenshot.gd -- out=/tmp/s.png state=3dreward beast=cinder_jackal size=1280x720

The prompt line reads "The Fro[?]... [?]ks... Tap a card to [?]ct" — legible
only in fragments between the card frames and the beast's tail.

## Done when

The prompt line reads cleanly against any background the 3D scene puts
behind it, and never collides with the reward row's cards.

## Result

**Cause.** Two stacked problems, confirmed with a throwaway probe render
(`state=3dreward beast=cinder_jackal`) and a pixel-column scan of the PNG:
1. `Prompt` (`location_3d.tscn`) was a bare `Label`, so its legibility
   depended entirely on what the 3D camera happened to have behind it —
   fine over plain sky (Title/Subtitle at the very top), broken over the
   felled beast's detailed corpse.
2. Worse: `Prompt`'s own vertical band (`offset_top=-302` to
   `offset_bottom=-276`, i.e. y≈418–444 on a 720-tall shot) overlapped the
   reward `Row`'s rendered top edge (cards visibly start around y≈422,
   thanks to the cost-orb badge's intentional overhang past the card's own
   top border — `card_view.gd`'s `_cost_orb()`, `position = Vector2(-5,-6)`).
   `Row` is added to `Hud/Root` after `Prompt`, so wherever they overlapped
   the cards painted over the text outright — a backdrop panel alone would
   not have fixed this half.

## Fix

`game/views/location_3d.tscn`:
- Added a `prompt_panel` `StyleBoxFlat` (same look as combat's `card_panel`:
  `bg_color=(0.13,0.1,0.08,0.8)`, thin bronze border, 5px corners) so the
  prompt reads over any 3D background, matching the pattern every combat HUD
  text panel already uses.
- Wrapped `Prompt` in a new `PromptBox` `PanelContainer` using that style,
  and moved its band from y≈412–443 up to y≈380–410 (`offset_top -308→-340`,
  `offset_bottom -276→-310`) — clear of the reward row's actual top edge
  (~422) with an 8px margin, found empirically by scanning the rendered
  PNG's pixel columns for the panel border and the card frame's own top
  edge, not by trusting the container's nominal offsets alone (the cost-orb
  overhang isn't visible from the layout numbers).

`game/views/location_3d.gd`:
- New `@onready var _prompt_box: Control = %PromptBox`.
- `_render_reward()` now sets `_prompt_box.visible = not _prompt.text.is_empty()`
  alongside `_prompt.text` — a `PanelContainer` always paints its background
  regardless of its child's content, so without this every OTHER screen
  that reuses this same Hud (`_render_event`, `_render_over`, `_clear_ui`,
  all of which set `_prompt.text = ""`) would show a floating empty dark bar
  with nothing in it. Those three call sites now explicitly set
  `_prompt_box.visible = false` alongside clearing the text.

## Proof

- `$GODOT --headless --path game --script res://tools/run_tests.gd` →
  `ALL TESTS PASSED` (no logic change touches a tested pure function; this
  is a scene-layout + node-visibility fix, proven visually like the
  artist's ear-glare fix rather than with a new pure-function test).
- Before/after renders at the exact repro (`state=3dreward
  beast=cinder_jackal`):
  `design/agents/frames/fixer/2026-09-22-reward-prompt-hidden-before.png` /
  `-after.png` (full frames), `-before-crop.png` / `-after-crop.png` (1:1
  crops of the prompt band). Before: "The Fro...ks... Tap a card to ...ct",
  fragmented by the reward cards. After: "The Frog picks:   Tap a card to
  select", fully legible, sitting clear above the cards.
- Re-checked the two OTHER screens that share this Hud and clear the prompt
  text, to prove the visibility gate doesn't regress them into an empty
  floating bar: `state=3devent` and `state=3dwon` (a boss/relic reward,
  still exercises `_render_reward` with `is_relic=true` — "The Frog picks:
  Tap a relic to select" reads clean there too) both render with no
  stray panel. Not saved as frames (nothing to see — that's the point);
  looked at directly with the Read tool during the fix.

Commit: see the commit that introduces this Result section.

### Frames

![[frames/fixer/2026-09-22-reward-prompt-hidden-after.png]]
![[frames/fixer/2026-09-22-reward-prompt-hidden-after-crop.png]]
![[frames/fixer/2026-09-22-reward-prompt-hidden-before.png]]
![[frames/fixer/2026-09-22-reward-prompt-hidden-before-crop.png]]
