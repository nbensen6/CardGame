# Adding detail to a beast — a working guide

Written 2026-09-08 for Nick, who asked how to get his own hands on the models
after a week of the lanes moving them three points at a time.

## The thing to know first

**These beasts are not sculpts. They are Python.** `tools/blender/cinder_jackal.py`
is a hundred lines of "put an ellipsoid here, a tapered tube there", and
`build.cmd` runs it through Blender to produce the `.glb`. Nothing is modelled by
hand and there is no `.blend` to open — the script IS the model.

That is good news for you: adding detail is editing a text file with named
shapes and named colours, not learning a sculpting tool. It is also the reason
the beasts look assembled, because a script can only place primitives.

## The loop

```bash
cd "G:/Co Op Game" && cmd /c tools\blender\build.cmd cinder_jackal
```

Then look at it — six views land in `design/renders/`:

```bash
cd "G:/Co Op Game" && cmd /c tools\blender\look.cmd cinder_jackal 5
```

Then see it in the fight, which is the only view that counts:

```bash
cd "G:/Co Op Game" && cmd /c tools\dev.cmd
```

In a fight, backtick opens the console; `beast cinder_jackal` swaps it in.

`build.cmd` re-imports for you at the end. **Running Blender by hand does not**,
and the game will happily keep drawing the old model while your build reports
success.

## The vocabulary

From `kenney.py`. Six shapes, and the module's own note on why they exist is
worth reading: *"detail does not come from more triangles, it comes from a
vocabulary that can say more than ellipsoid."*

| call | shape | what it is for |
|---|---|---|
| `b.ball(centre, extents, colour, seg_u, seg_v)` | ellipsoid | bodies, heads, joints |
| `b.box(centre, extents, colour, bevel=)` | bevelled cube | plates, slabs, teeth |
| `b.taper(centre, r1, r2, height, colour, seg=, rot=)` | cone or frustum | snouts, horns, claws, spikes |
| `b.wedge(centre, extents, colour, narrow=(x,y))` | box with one end shrunk | beaks, fins, jaws |
| `b.limb([points], [radii], colour, seg=)` | tapered tube along a path | tails, vines, ridges, tentacles |
| `b.ring(...)` | torus | mouths, collars, bands |

Helpers: `mirror(lambda s: ...)` builds one side and gets both, `point((x,y,z))`
aims a cone, `aim(...)` aims a box or wedge.

Coordinates are **-Y forward** — every model faces -Y, and the fight camera,
the portraits and the icons all assume it. Z is up.

## The colours

Never type an RGB value and never edit `colormap.png`. Import a name:

```python
from kenney import RUST, TANGERINE, AMBER, CHARCOAL, GRAPHITE, TAN
```

The full set, three bands of sixteen:

```
ORANGE TANGERINE RED RUST   BLUE INDIGO ICE SKY   LILAC VIOLET PINK ORCHID
STEEL SLATE WHITE SILVER    PEACH CLAY BROWN UMBER   SAND TAN CREAM WHEAT   MINT GREEN GOLD AMBER
BLUSH ROSE PERIWINKLE IRIS  LINEN BISQUE PUMPKIN CARROT   CORAL BRICK CHARCOAL GRAPHITE   PEWTER STONE NAVY MIDNIGHT
```

A colour here is really a UV pointing at one 32px cell of a shared atlas. That
is why the whole cast is one material and one draw call, and it is what makes
the ember channel possible.

## The three details worth adding first

These are not a general list. They are what measurement on 2026-09-08 said this
cast is actually missing, against the Sea of Thieves megalodon as the bar.

### 1. Faces. This is the biggest one.

Put five Kenney animals beside five of ours and the difference is not polycount:
**theirs have faces and ours do not.** Big flat eyes, a defined snout, ears that
read as ears, on a head that is a distinct colour block from the body. Ours have
a featureless head with a sigil disc roughly where a face would go.

In a style with this little geometry the face is the strongest readability
device available and the cast is not using it. The jackal is one of the few with
eyes at all:

```python
mirror(lambda s: b.ball((0.13 * s, -1.42, 1.30), (0.06, 0.05, 0.05), AMBER, 7, 4))
```

Two balls. That is the whole eye. Most beasts do not even have that. Add eyes, a
brow, a jaw line — and give the head its own colour so it separates from the
body.

### 2. Accents that glow

`creature.gdshader` has an ember channel: named palette swatches emit light,
with a white-hot core. Two steps to use it on a new part:

1. Paint the part an accent colour in the script — `TANGERINE`, `AMBER`, `GOLD`,
   `RED` all read as heat.
2. Tell the game that swatch glows, in `combat_3d.gd`:

```gdscript
const EMBERS := {
    "cinder_jackal": [SWATCH_TANGERINE, SWATCH_AMBER],   # spine ridge, eyes
}
```

The constants mirror `kenney.swatch(px, py) == (px/512, 1 - (py+16)/512)`, so
`TANGERINE` is `swatch(48, 192)` in the script and
`Vector2(48.0/512.0, 1.0 - 208.0/512.0)` in GDScript. If you add a swatch that
is not in that table yet, add the constant beside the two that are there.

**Restraint is the point.** On the reference, the glowing area is a few percent
of the animal and it is the brightest thing in the frame. A beast that glows all
over reads as a lamp.

### 3. Chunkier limbs and real joints

Measured, our beasts have *more* negative space than the Kenney reference and
still look worse — their limbs are thick stubs and ours are thin sticks, which
reads as fragile and cheap. And a limb that simply ends inside a torso has no
shoulder; the intersection curve is all there is, and if the leg colour differs
from the body the strongest colour boundary on the model lands exactly where the
eye looks for a joint.

Thicken the radii, and put a mass in the BODY's colour where the limb meets it:

```python
for _sx in (-1, 1):
    for _ly in (-0.56, 0.52):
        b.ball((0.29 * _sx, _ly, 1.00), (0.19, 0.25, 0.21), RUST, 9, 6)
```

## Four things that will bite you

**The triangle budget.** Beasts 2600, hunters 1400 (`kenney.BUDGET`). The build
prints `TRIS ... BUDGET ... ok` or complains. `seg=` on a shape is the cheapest
knob — a `ball` at `(9, 5)` costs a quarter of one at `(18, 10)` and at fight
distance you will not tell.

**Climb and ledge markers.** `climb_<n>` and `ledge_<n>` nodes are how the game
knows where hunters can stand — `combat_3d._read_climb_points` reads them by
name. `beast.py` places them automatically off your masses, so if you move a
haunch you move a foothold. The build prints `GREW ... step(s) out to climb
points` when it has to stretch to reach one. If a beast becomes unclimbable,
this is why.

**If the beast is in `union.txt`, small detail gets eaten.** The union+remesh
pass melts the primitives into one continuous skin, and a voxel remesh cannot
keep a feature thinner than its voxel. Measured on the jackal, it cut the spine
ridge from 2.9% of faces to 0.5% and the eyes from 18.7% to 2.9%. Anything small
enough to matter must be declared an accent swatch on that beast's line:

```
cinder_jackal 48:192 496:320
```

Those are held out of the remesh and rejoined crisp. Right now `cinder_jackal`
is the only beast in that file; every other beast is un-unioned and keeps its
detail either way.

**Never edit a shared constant to make one beast fit.** `kenney.BUDGET`,
`env.ENCLOSE_CLEAR`, `colormap.png`, `palette.py` — moving any of them to suit
one model silently changes every other.

## Worked example

Add a smouldering brow over the jackal's eyes. In `tools/blender/cinder_jackal.py`,
after the eyes:

```python
# A hot brow ridge over each eye — small, TANGERINE so the ember channel
# lights it, and angled down toward the snout so it reads as a scowl.
mirror(lambda s: b.taper((0.15 * s, -1.30, 1.40), 0.05, 0.01, 0.22,
                         TANGERINE, seg=5, rot=point((0.25 * s, -0.6, 0.4))))
```

`TANGERINE` is already an ember swatch for this beast, so it glows with no
further wiring. Then build, look, and swap it into a fight.

## What to hand back

If you change a beast, the useful thing to send is the render, not the file — I
can read `design/renders/<beast>_pass<N>_*.png` and tell you what moved. And if
something you do looks better than what the pipeline produces, say so plainly:
my judgement on what looks *good* has been wrong repeatedly here, and yours is
the one that decides.
