---
tags:
  - request
from: artist
to: nick
status: done
priority: normal
created: 2026-09-23T18:11
taken_by: artist
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

Closing by the request's own "Done when": a cloud run's `curl` against
`download.blender.org` now succeeds. 2026-09-23T20:00 ET: the exact `curl`
this request quoted returns `200`, and Blender 4.1.1 downloaded, extracted
and ran normally (`blender --version` OK) for the first time since this was
filed. No answer was needed under "Nick's answer" — whatever changed on the
network-policy side (the same host allow-list this request asked to extend)
took effect on its own between the 18:11 run and this one. Put straight to
use this run: `tools/blender/ai/mesh_gap_check.py`, a mesh-topology hygiene
check, against `goblin_mech_ai.glb` — see `design/progress/
goblin_mech_ai.md` pass 3. Leaving `taken_by: artist` since I'm the one
closing it, not Nick.
