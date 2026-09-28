---
title: Limits and safety
description: What Scripter can and can't guarantee.
---

## It guides; it can't force

Scripter is a set of instructions. It shapes how the AI approaches a design, but it can't guarantee the AI follows every step, gets every number right, or turns on every time. The [test results](/scripter/reference/test-results/) show how well it works in practice, including the cases where it doesn't.

## The numbers are rough

The typical values in its checklists, such as power draws, material strengths, span rules and clearances, are for sanity checks. They're good for telling a 10× shortfall from a close call. They aren't a substitute for datasheets, codes or measurement. Verify them before any real decision.

## Get a professional for safety-critical work

For structures, gas, mains electricity, pressure vessels and heavy moving machinery, Scripter is told to recommend a review by a qualified professional, and you should get one. Building rules differ by country. Anything that carries people or a building needs a structural engineer.

## It won't catch everything

It checks the design against a working model it builds itself. If that model is wrong, or a failure mode isn't in its checklists, the verdict can be wrong too. Treat a ✅ as "no problem found at this level of detail", not as a certificate.
