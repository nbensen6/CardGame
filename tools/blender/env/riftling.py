"""Where the Riftling is fought: ground that has come apart.

The beast is debris held together by a field, so the floor is the same event
seen from underneath — black rock split into plates that have drifted off each
other, with violet light coming up through every gap and small pieces hanging
where they should have fallen.

The one rule that keeps it readable: the light comes from BELOW here and nowhere
else in the game. Every other environment is lit from the sky.
"""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from env import Env, BACK, ANY
from kenney import (out_path, point, CHARCOAL, GRAPHITE, MIDNIGHT, NAVY, SLATE,
                    PEWTER, STONE, VIOLET, IRIS, LILAC, ORCHID, PERIWINKLE,
                    ICE, SILVER)

e = Env(seed=211)

e.ground(CHARCOAL, rim=MIDNIGHT, dish=0.14)
e.apron(MIDNIGHT, out=1.35, drop=0.66)

# The floor has come apart into plates. Each is a slab turned off true and
# lifted a little, and the gaps between them are where the light gets out.
for ring, (r, n) in enumerate([(2.5, 7), (3.6, 9), (4.7, 11), (5.5, 12)]):
    for i in range(n):
        a = i * math.tau / n + ring * 0.23
        tilt = 0.06 + (i % 3) * 0.05
        e.box((math.cos(a) * r, math.sin(a) * r, 0.10 + (i % 3) * 0.05),
              (0.62, 0.54, 0.09), GRAPHITE if (i + ring) % 2 else SLATE,
              bevel=0.0,
              rot=(math.cos(a) * tilt, math.sin(a) * tilt, a + 0.15))

# The light in the gaps. Thin, bright, and pointing at the middle — the only
# thing in the game lit from underneath.
for i in range(16):
    a = i * math.tau / 16.0 + 0.1
    pts, rad = [], []
    for j in range(4):
        t = 0.30 + 0.66 * j / 3.0
        wob = (j % 2 - 0.5) * 0.16
        pts.append((math.cos(a + wob) * e.R * t, math.sin(a + wob) * e.R * t, 0.035))
        rad.append(0.075 - 0.03 * t)
    e.limb(pts, rad, VIOLET if i % 2 else IRIS, seg=4, cap=False, flat=0.5)

# Shards hanging where they should have fallen. Small, and mostly at the back —
# a floating rock in front of the camera is a floating rock in the way.
def hover(p, r, rng):
    e.box((p.x, p.y, r * (1.6 + rng.random() * 1.8)),
          (r * 0.42, r * 0.34, r * 0.30), PEWTER if rng.random() < 0.5 else STONE,
          bevel=r * 0.06,
          rot=(rng.uniform(-0.6, 0.6), rng.uniform(-0.6, 0.6),
               rng.random() * math.tau))
    e.ball((p.x, p.y, r * 0.9), (r * 0.09, r * 0.09, r * 0.09), LILAC, 5, 3)


e.scatter(9, hover, near=3.4, far=5.8, arc=BACK, size=0.42)
e.scatter(6, hover, near=2.6, far=5.6, arc=ANY, size=0.18)

# Rubble that stayed down, and motes of the field drifting over it.
e.scatter(12, lambda p, r, rng: e.rock(p, r, MIDNIGHT, sink=0.55),
          near=2.3, far=5.7, size=0.24)
e.scatter(12, lambda p, r, rng: e.ball((p.x, p.y, r * (2.0 + rng.random() * 3.0)),
                                       (r, r, r),
                                       ORCHID if rng.random() < 0.5 else LILAC, 5, 3),
          near=2.2, far=5.6, size=0.075)

e.done(out_path(), name="RiftlingGround")
