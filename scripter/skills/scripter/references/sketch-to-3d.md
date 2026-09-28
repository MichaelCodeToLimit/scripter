# Sketch, photo or drawing to 3D

A sketch shows the designer's intent, not a complete object. Your job is to work out the object that has to exist behind it, and to get the user's OK on the gaps **before** modelling.

## 1. Read the sketch

- **Which views** do you have: front, side, top, perspective, section? Anything a missing view would show is unknown, not free to invent.
- **Scale and units:** given dimensions, a known object for scale, or none at all.
- **Shown vs. hidden:** list what is drawn and what must exist but isn't drawn.

## 2. Break it into parts and joints

- Is it one piece or an assembly? Name every part.
- For each joint: fixed, hinged, sliding, rotating or flexible. How is it attached: bolt, glue, weld, snap, stitching?
- Two parts can't occupy the same space. At every joint, decide which part sits inside or beside the other. For example, two legs that pivot on one bolt sit side by side, offset by their thickness.

## 3. Infer the hidden parts from what each function needs

| Function | Needs |
|---|---|
| Something opens (door, lid) | hinges, a latch, an end stop |
| Something rotates (drum, wheel) | a shaft, bearings, a mounting, clearance |
| Something folds | pivots, a lock or end stop for the open position, and clearance when folded |
| It stands on the floor | a stable footprint in **both** directions. A frame drawn in one view usually has a partner frame behind it, plus rails or stretchers joining them |
| Fabric, straps, belts | something rigid to attach to at both ends, and tension when loaded |
| It holds a liquid | walls with thickness, seals, and a way to fill and empty it |
| It has electronics | space for the board and wiring, a power input, cooling, access |

All walls and members need a real thickness. Every moving part needs clearance.

**Load check before modelling:** apply the main load in your head (someone sitting, a hand pressing, the weight it holds) and trace which part resists it, and in which direction. If the parts you've drawn don't resist it, the interpretation is wrong: re-read the sketch before inventing a different layout. When a part is described as spanning between two points in the sketch, keep it spanning those points.

## 4. Before modelling: show this and wait for the OK

1. **Output type:** ask which one if it isn't clear. It decides how the model is built.

   | Type | What it is | Must have |
   |---|---|---|
   | Picture / render | a visual only | looks right; the parts can be approximate |
   | 3D-printable | STL / 3MF | watertight solids, minimum wall thickness, clearances between moving parts, print orientation, fits the printer bed |
   | Engineering CAD | STEP / parametric | exact dimensions, tolerances, real part structure, standard parts |

2. **Dimension table,** with each value marked **known** (given), **derived** (calculated from given ones, show how) or **assumed** (your default).
3. **Part list:** name, shape, material, key dimensions, and what it connects to.
4. **Motion list:** part, type of motion, range. Check each motion across its full range for collisions.
5. **Open questions:** only ones that change the model, each with a default.

## 5. Model structure (after the OK)

- One named object per real part. Group the assemblies.
- Real-world units. Put each part's origin at its joint or pivot so it can be rotated realistically.
- Model each part the way it would be made: a sawn board, a bent tube, a printed shell.
- If a 3D or CAD tool is connected (Blender, a CAD program), apply the same structure there.
- Meshes from image-to-3D generators are visual only. They aren't engineering geometry.

## 6. After modelling: check it

- The dimensions match the table.
- No part intersects another unless it's meant to (fasteners through holes).
- Moving parts clear each other through the full range of motion, including folded and open.
- No floating parts: everything is attached to something.
- Walls and members meet the minimum thickness for the process.
- Render views matching the original sketch, so the user can compare them.
- Report every place where the model differs from the sketch, and why.
