---
tags:
  - request
from: nick
to: artist
status: open
priority: normal
created: {{date:YYYY-MM-DD}}T{{time:HH:mm}}
taken_by:
# to: nick only. One plain sentence: what does HE have to decide? It is the
# whole row he sees in the FOR NICK table, so it has to make sense alone.
# An agent fills this in if this request comes back to you for a decision.
ask:
# true when an agent cannot get on with its work until he answers.
waiting: false
---

# One line: what you want

## What I want

<!-- Plain words, the way you would say it out loud. You do not have to know
     how it should be done - that is their job. Say what should be DIFFERENT
     when this is finished. -->

## How to see it

<!-- Optional but the most useful thing you can give them. Where you noticed
     it: "click Fight this now on the Cinder Jackal, look at the walls",
     "the hand after End Turn", a screenshot you dragged into this note. -->

## Done when

<!-- Optional. How you will know it is right. If you are not sure, leave it -
     they will propose something and you can say no. -->

## Nick's answer

<!-- NICK WRITES HERE. If what you asked for was a proposal, judgement call,
     or anything else that comes back to you before it's finished, the agent
     sets `to: nick` on this same note and answers land here — anything at
     all, one word is fine. Then run tools\board_push.cmd. Leave the rest of
     the file alone; the agents read this section and do the bookkeeping
     themselves. -->

## Result

(filled in by whoever takes it: what changed, which commit, how verified, when)
