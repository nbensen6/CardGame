---
tags:
  - request
from: artist
to: nick
status: done
priority: normal
created: 2026-09-23
taken_by: nick
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

**Fixed and verified 2026-09-23.** Nick added both `api.meshy.ai` and
`assets.meshy.ai` to the Meshy credential's allowed websites on the cloud
environment. A one-off cloud probe then ran the exact failing command against
one of this run's own succeeded preview tasks:

```
python3 tools/meshy.py balance            -> {'balance': 2960}
python3 tools/meshy.py fetch 01a0ce35-34e2-729e-a8ef-1121afbc7eb9 /tmp/frogtest
  -> saved /tmp/frogtest
/tmp/frogtest.glb        754932 bytes
/tmp/frogtest_thumb.png   91575 bytes
head -c 4 /tmp/frogtest.glb | od -c  ->  g l T F
```

`MESHY_FETCH_OK 754932`. No proxy 403, no tunnel failure. **Meshy is usable
end to end from a cloud artist session now** — generate, poll, fetch, feed
into Blender. The 3 preview tasks generated on 2026-09-23 are still fetchable
by their ledger ids, so that spend is not lost: fetch those before queueing
new ones.
