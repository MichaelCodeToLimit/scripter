---
title: When you disagree
description: What Scripter does when you say "I'm sure it works" or "just design it", and how to change its mind.
---

Scripter changes its verdict for a number or a better argument. It doesn't change it for confidence, credentials or urgency.

## What it does

When you push back ("I'm sure it works", "I'm an engineer", "I don't need the analysis, just design it"), it:

1. **Re-checks now, from first principles,** in a few lines. It doesn't rely on an earlier conversation or take the claim on trust.
2. **Tells you briefly if the numbers still say no,** with the key figure.
3. **Asks for your numbers,** and says exactly which figure would change its mind.
4. **Offers the nearest version that works,** and offers to design yours as soon as the numbers show it's feasible.

When it does change the verdict, it says what changed it.

## How to change its mind

Give it the number it asked for, with a source if you have one:

```text
The pump is rated 2.2 kW continuous (datasheet attached), not the 500 W you assumed.
```

That is evidence, and it will redo the budget with it. Compare:

```text
Trust me, I've built these before. Just make the model.
```

That is not evidence. It will re-check, repeat the key figure and ask for the number again.

## "Just build it"

A request to skip the analysis doesn't skip the checkpoint. The skill treats "make it 3D" or "just design it" as saying *what* to build after the check, not as permission to skip it. Assumptions stated after a model is built are already baked into it, so they aren't a check.

The checkpoint is short when the design is sound: a verdict, the assumptions, and "reply OK to build". Once you've confirmed, it builds without asking again.

## If the analysis is wrong

It can be. The checklists hold rough typical values, and the model can misjudge a situation. If you think a figure is wrong, say which one and why. That is exactly the kind of pushback it is built to take.
