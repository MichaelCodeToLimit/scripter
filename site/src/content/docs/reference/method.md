---
title: The method
description: The seven steps Scripter follows for a new design, a review or a build.
---

**Core principle:** if you can't explain how the thing works through one full cycle of use, with numbers where they decide the outcome, you aren't ready to build it.

This applies to your ideas **and to the AI's own**. Its first idea is a hypothesis, not an answer.

This page explains the steps. The exact wording Claude receives is on [Full skill text](/scripter/reference/skill-text/).

## 1. Understand the request

Find the goal behind it, what you want (a review, improvements, a 3D model, a build) and your limits: size, budget, materials, tools, skills, one-off or mass-produced. Keep what you said separate from what it's assuming. Ask at most three questions, and only ones whose answer would change the design, each with a default.

## 2. Build the working model

Work out how this kind of thing works:

- its main and supporting functions, and the physics or logic behind them;
- its parts and how they connect: the flows of energy, material and signals or data;
- one full cycle of use, from start to finish;
- how existing products do it, and **why**. Conventions usually exist for a reason.

If it doesn't know how something works, it says so and reasons from first principles. It is told never to bluff. For most designs it reads one of the four [checklists](/scripter/reference/checklists/physical-products/) first.

## 3. Map the design onto the model

For each function: how the design achieves it, and what's missing or conflicting. Walk the design through the full cycle and find where it breaks. Apply the main load (sitting, pressing, lifting, pressure) and trace which part resists it, in which direction. Fabric, straps and cables only resist pulling along their length. Infer the hidden parts it needs: hinges, shafts, bearings, rails, seals, clearances.

## 4. Check feasibility with a budget

For each quantity that decides whether it works (power, force, heat, water, data, cost, time), write down what's **available** and what's **needed**, with units.

- "Needed" is the need at the hardest point of the cycle, **including losses**. The energy to reach a speed is not the power to hold it there.
- Add totals over the whole cycle.
- Compare with what existing products use. A figure 10× lower is a reason to look again.
- Also check whether it can be made with your means, reliability and failure modes, safety and misuse, ergonomics and repair, and cost.

The verdict follows from these numbers.

## 5. Ask whether it's the best way

Compare the design with the standard solution and one or two alternatives. Keep your approach if it's better, and say why in one line. Don't change things for the sake of change.

## 6. List improvements

Biggest impact first. Each says what to change, why, and the trade-off.

## 7. Checkpoint, then build, then re-check

Before any big build (a 3D model, modelling code such as OpenSCAD, Blender, Three.js or CAD, drawings, a full spec or app code), show the report and **stop**. Once you've confirmed the verdict and assumptions, build consistently with the working model. Then verify the result: parts fit, nothing intersects, moving parts clear each other through their full range, nothing floats or is missing. Report any deviations.

## Red flags it watches for

The skill lists thoughts that mean it is going wrong. A few of them:

| Thought | Reality |
|---|---|
| "They asked for a 3D model, so I'll build it now." | They asked for a model of a design that works. Check first; build after their OK. |
| "Let me show why this is feasible." | That's deciding the verdict first. Do the budget; the verdict comes from it. |
| "Spinning it up only takes a little energy." | Losses at the operating point usually dominate. Compare the power needed to *hold* it. |
| "They're an engineer and sure of it." | Confidence isn't evidence. Ask for the numbers. |
| "It's a small question, but I'll be thorough." | Small questions get short answers. |
