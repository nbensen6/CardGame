---
tags:
  - request
from: artist
to: nick
status: open
priority: normal
created: 2026-09-23
taken_by:
---

# Meshy generation works, but the cloud sandbox can't download the result

## What

Per this run's brief (rebuild the Frog/Goblin toward the jackal's fidelity), I ran the Meshy
pipeline for a from-scratch Frog: `python3 tools/meshy.py balance` succeeded, and I generated 3
text-to-3d previews — all three reached `SUCCEEDED 100` (task ids logged in
`design/progress/meshy-ledger.md`, 2026-09-23). Everything through `api.meshy.ai` works: the
proxy injects the credential fine for balance/preview/refine/get.

**Fetching the actual model file does not**: `tools/meshy.py fetch <id> <out>` downloads
`model_urls.glb`, which Meshy serves from `assets.meshy.ai` — a different host than
`api.meshy.ai`, and this cloud sandbox's network policy only allows the latter. The download
fails with a proxy 403 (`Tunnel connection failed: 403 Forbidden`, confirmed at the network
layer via the sandbox's own proxy status endpoint — a policy denial, not a credential problem).

So Meshy generation is currently **not usable end-to-end from an artist cloud session** — it can
queue and finish a task, but can never retrieve the model. This is presumably why prior AI-beast
work (the Cinder Jackal) reads as done on a different machine, not this sandbox.

## What I need

Add `assets.meshy.ai` to this environment's allowed network domains (cloud environment menu in
the session's title bar → Edit → Network access), alongside the existing `api.meshy.ai` allow.
I don't have access to change this myself.

## Cost already spent

3 preview tasks today (see `design/progress/meshy-ledger.md`), well under the 8/day cap, but
spent without being retrievable — worth knowing before whoever picks this up next spends more
chasing the same wall.

## What I did instead this run

Pivoted to `goblin_mech` (doesn't need Meshy) — see `design/agents/status/artist.md` `## Now`.

## Done when

`assets.meshy.ai` (or whatever host `tools/meshy.py fetch` needs — check the current failure
first, Meshy's CDN host could differ) is reachable from a cloud artist session, and a `fetch`
against today's already-succeeded preview tasks actually saves a `.glb`.

## Result

(filled in by nick)
