# Design Sense: roadmap after v1

**Date:** 2026-09-27
**Builds on:** `docs/superpowers/specs/2026-09-27-design-sense-design.md` and `2026-09-27-design-sense.md` (the v1 build plan). The v1 build is happening in another chat. This file only plans what comes next; it changes no v1 files.

## Where v1 stands (from `design-sense/evals/results/`)

| | Without the skill | With the skill |
|---|---|---|
| Cases passed | 1 / 7 | 5 / 7 |
| Overall score | 0.60 | 0.94 |
| Cost per suite run (Sonnet, 3 runs per case) | $0.71 | $0.61 |

**Both remaining failures (magnet wheel, offline to-do sync) happen because the skill didn't fire.** The judge passed the answers themselves. Without the skill, Claude offered to build the magnet-wheel model anyway and skipped the report.

**The skill only helps when it switches on, so triggering is the biggest risk.** On claude.ai, the 200-character `description` is the only thing that controls triggering.

## Phases

Recommended order: 1 → 2 → 3 → 4 → 5. Phase 6 applies only if the plugin is going to be shared. Phase 7 is ongoing.

### Phase 1: Finish v1 (other chat, in progress)

- Get all 7 eval cases passing, including the skill firing.
- Install the skill.
- User acceptance on claude.ai and ChatGPT.

### Phase 2: Reliability (v1.1). Priority: high

Goal: the skill fires whenever it should, works on other models, and doesn't cost extra tokens where it isn't needed.

1. **Trigger suite.**
   - 12 positive phrasings, each 1 line, eval graded only on `skill-fired`: "I invented…", "is it possible to…", "make me a 3D model of…", "will this shelf hold 20 kg?", "design an app that…", "what's wrong with my design", "improve this", "turn my sketch into…", "can I build…", "how should I make…", "check my idea", "desgin me a…" (typos).
   - 6 negatives: poem, bug fix, summarize an article, email, recipe, trivia.
   - **Target:** ≥ 95 % of positives fire and 0 % of negatives, over 3 runs each.
   - Tune only the `description`, keeping it ≤ 200 characters and free of fields that claude.ai won't accept.
2. **A second trigger lever that works on every platform.** Add one line to `always-on-snippet.md`: *"When I bring a design, an invention or a build request, use the design-sense skill before answering."*
   - It works in Claude preferences, ChatGPT custom instructions and `CLAUDE.md` alike, and needs no code.
   - Add an eval arm that includes the line, to measure the lift.
3. **Review Focus cases as evals** (from the v1 plan; the other chat dropped them when it switched harnesses):
   - own idea (no-drill bike rack);
   - vague + typos ("desgin me a beter chair");
   - safety-critical (2x4 loft over a stairwell, 3.5 m span);
   - already sound (PETG hook);
   - approval → build + re-check. If `claude plugin eval` can't run two turns, write a self-contained prompt that contains the earlier report and "go ahead".
4. **Cross-model check.**
   - Run the suite with `modelOverride` Haiku and Opus as well as Sonnet, and record the pass rate per model.
   - A skill that only works on one model won't carry over to ChatGPT.
5. **Token check.**
   - Record average answer length with and without the skill for the small-question cases, and add a length grader to each.
   - Keep `SKILL.md` ≤ 12 KB. It is 9.4 KB now, about 2.4k tokens each time it loads.
6. **ChatGPT acceptance sheet.**
   - `chatgpt/acceptance.md` holds the 7 prompts and a tick-box copy of each grader.
   - The user pastes the prompts into the Custom GPT or skill and ticks the boxes. ChatGPT can't be automated from here.

### Phase 3: Sketch → 3D workflow (v2). Priority: high for the user's own use

This is the user's headline example, and Blender MCP is already connected on this PC.

1. **Real image input.**
   - Add 3 sketch fixtures: a phone photo of a hand sketch, a clean line drawing, and a perspective sketch.
   - Check whether `claude plugin eval` accepts image attachments. If it doesn't, keep a manual test sheet.
2. **`references/blender-build.md`.** Loaded only when Blender tools are available. It covers:
   - one named object per part, real units, origins at the joints;
   - after building, a bpy re-check script:
     - intersections between parts, using BVH overlap;
     - each joint rotated through its range, testing for collisions at each step;
     - floating parts (touching nothing);
     - minimum wall thickness;
     - a result table in the reply;
   - export to STL or 3MF for printing only after the re-check passes.
3. **End-to-end acceptance test.** Sketch → report → OK → Blender model → re-check table. Done by hand, because eval runs are sandboxed without MCP servers.

### Phase 4: Better numbers (v2). Priority: medium

1. **Compute, don't estimate.**
   - When a code tool is present (claude.ai code execution, which skills need anyway; ChatGPT Code Interpreter; Claude Code), do the budget arithmetic in code and show the inputs.
   - Eval: a grader checks that available/needed figures are consistent with their inputs.
2. **No MCP calculator server.** Every platform already has a code tool, so a server would add hosting and upkeep for no gain.
3. **Typical values.** Add a source link to each typical value in the references.

### Phase 5: Long projects (v2). Priority: medium

A **design record**, so the AI keeps understanding a design across chats:
- `DESIGN-RECORD.md` holds the goal, requirements, assumptions, decisions with reasons, verdict history and open questions.
- The skill reads it first and updates it after each decision.
- Where it lives:
  - Claude Code: a file in the project.
  - claude.ai: a Project knowledge file.
  - ChatGPT: Project files.
- Eval: a 2-step case where the second prompt contradicts a recorded decision, and the skill must point that out.

### Phase 6: Share it (v3). Priority: only if others will use it

1. **GitHub repo.**
   - MIT licence.
   - A README with the before/after eval table as proof.
   - Remove personal paths (`C:\Users\micha…`) from docs and scripts.
2. **Claude Code install.** `/plugin marketplace add <owner>/design-sense`. `marketplace.json` already exists.
3. **ChatGPT plugin package** for the shared plugin directory, so it works on web and mobile on every plan. Add `agents/openai.yaml` (display name, short description, icon).
4. **Versions.** Semver in `plugin.json` plus a `CHANGELOG.md`. The full eval suite must pass before each release.

### Phase 7: Keep improving (ongoing)

1. **Every real-world miss becomes an eval case before it is fixed**, so the test suite grows from real use.
2. **Re-run the suite on each new model release** and compare with the last results.
3. **Add a domain reference only when that domain has come up twice without one.** Likely candidates: electronics/PCBs, plumbing/fluids, vehicles.

## Decisions needed from the user

- Should purely visual design (logos, posters, the look of a UI) trigger the skill? This decides the negative cases in Phase 2.1.
- Share it publicly (Phase 6), or keep it personal?
- Which domains beyond the four existing ones come up in your work?
