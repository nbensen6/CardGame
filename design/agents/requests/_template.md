---
tags:
  - request
from: playtester
to: fixer
status: open
priority: normal
created: 2026-09-22T14:05
taken_by:
# to: nick only. One plain sentence: what does HE have to decide? It is the
# whole row he sees in the FOR NICK table, so it has to make sense alone.
ask:
# true when an agent cannot get on with its work until he answers.
waiting: false
---

# One-line title of what is wrong or needed

## What I need

<!-- Bullets. One line each. This is the whole request at a glance — if Nick
     or another agent reads only this section, they must still know what to do.
     For `to: nick`: no jargon, no file paths, and say what you RECOMMEND. -->

- 
- 

## What

What you saw, or what you need, in full. One problem per request.

## How to see it

The exact command (and step number / screenshot path) that shows it, e.g.

    xvfb-run -a godot --rendering-driver opengl3 --path game --script res://tools/playtest.gd -- mode=play beast=cinder_jackal out=/tmp/pt

Embed the frame if there is one: `![[frames/<agent>/<file>.png]]`

## Done when

The check that will pass once it is handled.

## Nick's answer

<!-- NICK WRITES HERE. Anything at all, one word is fine. Then run
     tools\board_push.cmd. Leave the rest of the file alone — the agents read
     this section and do the bookkeeping themselves. -->

## Result

(filled in by whoever takes it: what changed, which commit, how verified, when)
