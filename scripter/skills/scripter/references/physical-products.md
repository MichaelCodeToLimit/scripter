# Physical products, machines and mechanisms

Checklists and rough numbers for the working model (step 2) and the feasibility budget (step 4). Every value here is **rough**: use it for sanity checks, not final decisions.

## Function checklist

Work through the ones that apply:

- **Energy:** where it comes from, how it's converted, where it goes. Include losses and the peak demand.
- **Material and fluid flow:** what goes in and out (water, air, food, fuel, waste), and where it's stored.
- **Signals and control:** sensing, timing, user input, feedback, and what happens on a fault.
- **Load paths:** how every force travels through the parts to the ground or the hand.
- **Motion:** what moves, and what constrains it (bearing, hinge, slide, guide). Check the range, end stops, clearances and wear.
- **Sealing:** where liquids, gases or dust must be kept in or out.
- **Heat:** what produces heat, where it goes, and the maximum temperatures of the parts.
- **Power supply:** mains, battery or human power, and for how long.
- **User interface:** controls, feedback, reach and force.
- **Safety:** pinch points, sharp edges, electrical shock, hot surfaces, tip-over, stored energy (springs, pressure), children.
- **Maintenance:** access for cleaning, filters, wear parts and repair.

## Quick formulas

| Quantity | Formula | Note |
|---|---|---|
| Rotational speed | ω = rpm × 2π / 60 | in rad/s |
| Centripetal acceleration | a = ω² r | a spin drum at 1000 rpm and r = 0.25 m ≈ 280 g |
| Rotating power | P = τ ω | τ = torque in N·m |
| Linear power | P = F v | |
| Hydraulic power | P = Δp × Q | 3 bar × 12 L/min = 300 000 Pa × 0.0002 m³/s = 60 W |
| Heating | Q = m c ΔT | water c ≈ 4.18 kJ/(kg·K); 10 L by 40 K ≈ 1.7 MJ ≈ 0.46 kWh |
| Kinetic energy | E = ½ m v², rotating: ½ I ω² | the energy to reach a speed is not the power to hold it |
| Potential energy | E = m g h | 1 kg lifted 1 m ≈ 10 J |
| Stress | σ = F / A | compare with yield strength ÷ safety factor |
| Pressure force | F = p × A | 1 bar on 10 cm² = 100 N |
| Energy ↔ power | 1 kWh = 3.6 MJ; 1 W = 1 J/s | |

## Typical values (rough, verify)

**Power sources**
- Mains: EU 230 V / 16 A ≈ 3.7 kW per circuit (UK plug 13 A ≈ 3 kW); US 120 V / 15 A ≈ 1.8 kW.
- Tap water: 2–4 bar static, about 6–15 L/min at a tap, so **tens of watts** of hydraulic power at most.
- A person: pedalling about 75–100 W sustained (fit adult); hand crank about 20–50 W; bursts of a few hundred W.
- Sun: about 1000 W/m² at noon on a clear day; panels about 20% efficient, so about 200 W/m² peak and roughly 0.6–1 kWh per m² per day.
- Batteries: Li-ion about 150–250 Wh/kg; lead-acid about 30–40 Wh/kg; AA alkaline about 3 Wh.

**What things use**
- Washing machine: spin motor 300–500 W; water heater about 2 kW; about 40–60 L of water per wash.
- Fridge: about 1 kWh/day. Kettle: 2–3 kW. Microwave: about 1 kW. LED bulb: 5–10 W. Phone charging: 5–20 W.
- Multirotor drone hover: about 150–200 W per kg.

**Human factors**
- Comfortable repeated push or pull with the hand: about 20–50 N. Button press: about 2–10 N. Max grip: about 300–500 N.
- Comfortable carry with one hand: under about 10 kg. Standing work surface: about 90–100 cm. Seat height: about 42–48 cm.

**Materials** (density; yield or tensile strength; notes)

| Material | kg/m³ | Strength (MPa) | Notes |
|---|---|---|---|
| Mild steel | 7850 | yield ~250 | E ≈ 200 GPa; rusts |
| Stainless 304 | 8000 | yield ~215 | corrosion resistant |
| Aluminium 6061-T6 | 2700 | yield ~275 | E ≈ 69 GPa; 1/3 the stiffness of steel |
| PLA (printed) | 1240 | ~30–50 | stiff and brittle; softens around 55–60 °C |
| PETG (printed) | 1270 | ~30–45 | tougher; softens around 75–80 °C |
| ABS / ASA (printed) | 1050 | ~25–40 | softens around 90–100 °C; ASA is UV resistant |
| Nylon (PA) | 1010–1140 | ~40–70 | tough, low friction, absorbs moisture |
| Softwood (pine) | ~500 | bending ~40–80 | along the grain; much weaker across it |
| Hardwood (oak, beech) | ~700 | bending ~80–110 | |
| Concrete | 2400 | compression 20–40 | weak in tension (~10%); needs rebar |

- 3D-printed parts are much weaker **between layers** than along them. Orient the part so the main load runs along the layers.
- Safety factor: about 1.5–2 for known loads and well-understood materials; 3–4 or more for people, uncertain loads, shock, or brittle and printed parts.

## Manufacturing

Choose the process for the quantity and the means:

| Process | Good for | Key rules |
|---|---|---|
| FDM printing | 1–100 parts, prototypes | overhangs over ~45° need support; walls ≥ ~1.2 mm; holes print undersize; about 0.2–0.5 mm clearance between mating parts; bed size limits part size |
| SLA / resin printing | fine detail, small parts | brittle; hollow parts need drain holes |
| CNC machining | metal and plastic, 1–1000 parts | internal corners have a radius equal to the tool's; deep narrow pockets are hard; the tool must reach every face |
| Injection moulding | 1000+ parts | tooling costs thousands to tens of thousands; draft 1–2°; even walls about 1.5–3 mm; avoid undercuts; ribs ≤ 60% of wall thickness |
| Sheet metal | enclosures, brackets | inside bend radius ≥ thickness; holes at least 2× thickness from a bend |
| Casting | complex metal shapes in volume | draft, even sections, generous fillets |
| Welding | steel frames | torch access, heat distortion, weaker heat-affected zone |
| Woodworking | furniture, frames | load along the grain; joints carry the load; wood moves with humidity |

**Design for assembly:** fewer parts; parts that locate themselves; standard fasteners; one assembly direction; parts that can't go in the wrong way.

## Failure modes to check

- Fatigue under repeated loads, especially at sharp corners and holes.
- Wear at sliding and rotating contacts. Plastic parts creep under constant load.
- Corrosion, especially mixed metals in water.
- Vibration, resonance and imbalance at speed. Spinning loads amplify any imbalance.
- Thermal expansion between different materials.
- Leaks at every seal and joint. Water together with mains electricity is a hazard.
- Loosening fasteners, and misuse: overload, the wrong user, children.

## "Why do existing products do it this way?"

Before replacing a conventional solution, find the reason it exists. The usual reasons are cost, safety regulations, reliability, manufacturing limits or physics. If the new design removes a part, check that the part's job is still done somewhere.
