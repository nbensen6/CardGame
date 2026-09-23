---
tags:
  - request
from: artist
to: nick
status: open
priority: normal
created: 2026-09-23T18:11
taken_by:
ask: Blender downloads have failed for three runs in a row on the cloud sandbox — can you allow download.blender.org the way you allowed the Meshy hosts?
waiting: true
---

# Blender can't download on the cloud sandbox — three runs in a row now

## What I need

- Blender needs one more host allowed on the cloud environment's network
  policy: `download.blender.org`. This is the same kind of fix you already
  made for Meshy (`api.meshy.ai` / `assets.meshy.ai`) a few hours ago — that
  one worked immediately once you added it.
- Until this is allowed, I can't do anything that needs real 3D work: no
  mesh cleanup, no new geometry (e.g. giving the climbing stones real rock
  shape instead of just a texture), and no finishing touches on the Goblin
  Engineer model that's blocking this fight's biggest remaining gap.
- Recommend: add it the same way, then I'll confirm it works on my next run
  the way I confirmed Meshy.

## What

Every run for the last few hours has tried to download Blender at the start
(it's a one-time setup step, same as fetching Godot) and hit the same wall:
a clean `403` on the CONNECT to `download.blender.org:443`, not a timeout or
a flaky retry. Three separate runs today (roughly 16:24, 17:19, and this one
at 18:11 ET) all hit exactly this, so it isn't a one-off blip — it's a
standing block on this host, the same shape of problem the Meshy fetch had
before you fixed it.

## How to see it

    curl -sS -o /dev/null -w "%{http_code}\n" https://download.blender.org/release/Blender4.1/blender-4.1.1-linux-x64.tar.xz

comes back `000` with a `403` on the CONNECT tunnel. The proxy's own status
endpoint confirms it's a policy denial, not a broken connection:

    curl -sS "$HTTPS_PROXY/__agentproxy/status"

shows `"recentRelayFailures"` with `"kind": "connect_rejected"`,
`"detail": "gateway answered 403 to CONNECT (policy denial or upstream
failure)"`, `"host": "download.blender.org:443"`.

## Done when

A cloud run's `curl` against `download.blender.org` succeeds (or the
Blender tarball actually downloads), the same way `MESHY_FETCH_OK 754932`
proved the Meshy fix worked earlier today.

## Nick's answer

## Result
