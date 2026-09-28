---
title: Using Scripter
description: When it turns on, how to ask, and how to get the most out of it.
---

## When it turns on

Scripter turns on by itself when you share an invention or design idea, or ask to design, 3D-model, review or build something that has to work: a product, a machine, an app or a building. It also turns on for questions about how something should work, or what to make it from.

| Turns on | Stays off |
|---|---|
| I invented a bike that charges your phone while you ride. Check if it works. | Write a short poem about autumn. |
| Is it possible to make a drone that never lands? | Fix this Python error: TypeError … |
| Make me a 3D model of a folding laptop stand. | Write an email asking my landlord to fix the heating. |
| Will a 12 mm plywood shelf hold 20 kg over 80 cm? | Give me a recipe for banana bread. |
| Design an app that tells me when my plants need water. | Write a PowerShell script that renames .txt files to .md. |
| Turn my 2D sketch of a lamp into 3D. | Design a logo for my bakery. |
| desgin me a beter washing machin that uses less water | What's the capital of Australia? |

These are real prompts from its [trigger tests](https://github.com/MichaelCodeToLimit/scripter/tree/main/scripter/evals-trigger), which check that it turns on for the left column and stays off for the right. The typo is deliberate: it should still turn on. A logo is design work, but nothing in a logo has to *function*, so it stays off.

## Calling it by name

If it doesn't turn on when you want it to, call it:

| Where | How |
|---|---|
| Claude Code, installed as a plugin | `/scripter:scripter` |
| Claude Code, installed as a personal skill | `/scripter` |
| ChatGPT skill | `@scripter` |
| Custom GPT | open **Scripter** from the sidebar |

## How much it does

It scales the effort to the question.

- **A small question** (a material, a dimension, a part, "will this hold?") gets a direct answer in a few sentences, covering the one or two checks that matter.
- **A new design, a review, "is this possible?", or a build** gets the full method: a [report](/scripter/guides/reading-the-report/), then a stop for your OK before anything big is made.

## Getting better answers

**Give the goal, not only the object.** "A shelf" is less useful than "a shelf for about 30 kg of vinyl records, in a rented flat where I can't drill much."

**Give your limits.** Size, budget, materials, the tools and skills you have, and whether it's a one-off or mass-produced. Where you don't say, it states an assumption and marks it as assumed, so check the **Understanding** line.

**Say what "3D" means.** "Make it 3D" could mean a picture, a 3D-printable file or engineering CAD. These are different jobs. Saying which one saves a question.

**Attach the sketch.** It reads the views you give it, lists what is drawn and what must exist but isn't, and asks about the gaps before modelling. See the [sketch-to-3D checklist](/scripter/reference/checklists/sketch-to-3d/).

**Include your own numbers.** If you already know the motor rating, the load or the flow rate, say so. It checks its estimates against yours.

## What it won't do

- **Praise the idea.** No "great idea!", no "hope this helps". If something works, it says so in a short line, so you know to keep it.
- **Change your design without telling you.** Every change is listed.
- **Build before you confirm.** Even if you say "just make the 3D model", it shows the verdict and assumptions first. The request says *what* to build after the check. It doesn't cancel the check.
