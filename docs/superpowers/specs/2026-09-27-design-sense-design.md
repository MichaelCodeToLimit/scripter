# Design Sense: design spec

**Date:** 2026-09-27
**Status:** Approved by the user on 2026-09-27, including the 4 self-review fixes.

## 1. Goal

A "plugin" for Claude and ChatGPT that makes the AI understand a design request before acting on it. For any design (the washing machine was only an example), the AI must:

- first work out **how that kind of thing works**;
- check whether the user's design (or **its own idea**) **makes sense**, is **physically possible**, **can be made**, and **will work**;
- ask whether it is **the best way** to do it;
- do all of this **before** building anything: 3D models, drawings, code or specs.

It focuses on **the design** (what to build and whether it works), not on the steps of producing it.

It must **not praise or congratulate**. Tokens saved on politeness go into improving the design. **Design quality beats speed.**

### Decisions made with the user

| Topic | Decision |
|---|---|
| Scope | General-purpose: any kind of design, not a single domain |
| Checkpoint | **Stop before big builds.** For a 3D model, full design, drawings or code: show the analysis and wait for OK. Small questions get a direct answer. |
| Platforms | Claude **and** ChatGPT |
| Approach | One portable skill (plain instruction files), plus a Custom GPT fallback |
| Report style | As shown in chat: compact, verdict first (see §4.3) |
| Testing | Automated before/after runs with the Claude CLI (§7) |

## 2. Platform facts this design relies on (checked 2026-09-27)

- **Both apps use the same skill format:** a folder containing `SKILL.md` with `name` and `description` frontmatter, following the open Agent Skills standard (agentskills.io).
- **Claude website/app** (support.claude.com, "How to create custom skills"):
  - Upload a ZIP whose root is the skill folder, via Customize → Skills.
  - Requires "code execution" to be enabled.
  - `name` is at most 64 characters: lowercase letters, digits and hyphens, and it must not contain "claude" or "anthropic".
  - **`description` is at most 200 characters.**
  - Only `name`, `description`, `license`, `compatibility`, `metadata` and `allowed-tools` frontmatter fields are valid for uploads.
- **Claude Code / Claude desktop:** skills in `~/.claude/skills/<name>/SKILL.md` load automatically and can be invoked as `/<name>`.
- **ChatGPT** (help.openai.com 20001066 and learn.chatgpt.com "Build skills"):
  - Custom skills can be uploaded (Plugins → Skills → Create → Upload from your computer) on **Business, Enterprise, Healthcare and Edu** plans.
  - Standalone skills also work in the ChatGPT desktop app and in Codex.
  - Invoke one explicitly with `@name`.
  - Other plans fall back to a **Custom GPT**: instructions of about 8,000 characters at most, plus knowledge files.
- **Local tooling:**
  - The `claude` CLI 2.1.282 is at `C:\Users\micha\.local\bin\claude.exe`.
  - **Python is not installed**, so packaging and checks use PowerShell (`Compress-Archive`).
  - `~/.claude/settings.json` enables no plugins or hooks, so CLI test runs are clean.

## 3. Deliverables

```
C:\Users\micha\Scripter\
├── design-sense\                  ← the skill (the only thing that gets uploaded)
│   ├── SKILL.md                   method + rules, target ≤ 220 lines
│   └── references\                loaded only when relevant, each ≤ ~150 lines
│       ├── physical-products.md
│       ├── sketch-to-3d.md
│       ├── software-systems.md
│       └── spaces-structures.md
├── dist\design-sense.zip          upload file; the zip root contains the folder design-sense\
├── chatgpt\
│   ├── instructions.txt           Custom GPT instructions, ≤ 8,000 characters
│   └── setup.md                   Custom GPT setup steps, name, description, starters
├── always-on-snippet.md           optional no-praise text for ALL chats (user pastes it)
├── tests\
│   ├── scenarios.md               the 7 test prompts + pass criteria
│   ├── results.md                 before/after results table
│   └── runs\                      raw answers from each run
├── docs\superpowers\specs\        this spec
└── README.md                      what it is, install per app, how to use, how to update
```

**Install for the user's own Claude Code/desktop:** copy `design-sense\` to `C:\Users\micha\.claude\skills\design-sense\`.

**Not done for the user:**
- Uploading to claude.ai or ChatGPT. These are account changes, so the user does them following the README.
- Pasting the always-on snippet into any settings.

## 4. The skill: `design-sense/SKILL.md`

### 4.1 Frontmatter

```yaml
---
name: design-sense
description: "Use before designing, reviewing or building anything that must work: products, machines, 3D models from sketches, apps, structures. Checks how it works, feasibility and best approach."
---
```

- The draft description is 183 characters and must stay ≤ 200.
- It is quoted because the unquoted `: ` inside it would break the YAML header.
- It will be tuned during testing: it must trigger on tests 1–6 and stay off for test 7.
- No other frontmatter fields are used, so the same file uploads everywhere.

### 4.2 Body outline

1. **Purpose** (3 lines).
   - Settle the design before producing anything.
   - Applies to the user's ideas **and to the AI's own ideas**: a first idea is a hypothesis, not an answer.
2. **Scale the effort.**
   - A small question (a material, a dimension, "will this hold?") gets a direct answer covering the 1–2 checks that matter, with no report.
   - A new design, a review, or a big build (3D model, full design, drawings, code, spec) gets the full method plus the checkpoint.
3. **The method:**
   1. **Understand the request.**
      - Find the goal behind it and what the user wants: a review, improvements, 3D, or a build.
      - Find the context and constraints: size, budget, materials, tools, skills, one-off or mass-produced.
      - Separate what was said from what is assumed.
      - Ask only questions whose answer changes the design: at most 3, each with a default. Otherwise state the assumption and continue.
      - Example to include: "make it 3D" = render vs. printable model vs. engineering CAD.
   2. **Build the working model** (how this kind of thing works).
      - The main and supporting functions.
      - The operating principle: the physics or logic behind it.
      - The parts and how they connect: energy, material and signal/data flows.
      - One full use cycle from start to finish.
      - How existing solutions do it, and **why** (conventions usually exist for a reason).
      - The hard constraints.
      - If unsure how something works: say so, reason from first principles, and flag it. Never bluff.
   3. **Map the design onto the model.**
      - For each function: how the design achieves it, what is missing, and what conflicts.
      - Walk one full use cycle through the design and find where it breaks.
      - For sketches, load `references/sketch-to-3d.md`.
   4. **Feasibility check.** Check each of:
      - Physics: is it possible? Use rough numbers where they matter.
      - Make: can it be built with the stated means?
      - Work: reliability, failure modes, safety, misuse.
      - Use: ergonomics, maintenance, repair.
      - Cost and complexity.

      Verdict: ✅ works / ⚠️ works with changes / ❌ won't work as designed (why) / ❓ can't tell yet (what's needed).
   5. **Best way?**
      - Compare with the standard solution and 1–2 alternatives in a small trade-off table.
      - Keep the user's approach if it is better, and say why in one factual line.
      - No change for the sake of change.
   6. **Improvements.** Ranked by impact; each says what to change, why, and the trade-off.
   7. **Checkpoint → build → re-check.**
      - Big builds wait for the user's OK.
      - The build stays consistent with the working model.
      - Afterwards, verify the result: parts fit, clearances hold, moving parts don't collide, nothing is missing or floating. Report any deviations.
4. **Report format** (§4.3).
5. **Rules** (§4.4).
6. **Domain references.** Say when to load each file in `references/`. For any other domain, the method alone is enough.
7. **Red flags — stop if you catch yourself:**
   - starting to model, draw or code before you can explain how the thing works;
   - quietly "fixing" the design;
   - inventing dimensions or mechanisms without labeling them as assumptions;
   - saying "should work" without checking;
   - agreeing because the user sounds sure;
   - writing praise;
   - running the full method on a one-line question.

### 4.3 Report format (drop empty sections)

```
**Understanding:** 1–3 lines + key assumptions
**How it works:** the working model, short
**Verdict:** ✅/⚠️/❌/❓ + one line
**Problems (worst first):** numbered
**Better option:** only if one exists
**Improvements:** ranked
**Questions:** only design-changing ones, each with a default
**Next:** what will be built once confirmed
```

### 4.4 Rules

- No praise, compliments, congratulations or enthusiasm. No filler openers or closers.
- Lead with the verdict and the biggest problem.
- Say plainly when something won't work, and why (physics, logic, numbers).
- Mention what works only as a short fact, and only when it helps the user keep it.
- Label claims as known, estimated or assumed. Typical values in the references are rough and must be verified for real decisions.
- Under pushback:
  - re-check honestly;
  - change position only for new evidence or a better argument;
  - say what would change your mind;
  - never cave just to agree.
- Never change the user's design silently; always list what was changed.
- For safety-critical designs (structures, gas, mains electricity, pressure, heavy moving machinery), recommend review by a qualified professional.
- Spend the saved tokens on deeper analysis: more checks, numbers and alternatives.

### 4.5 Reference files (checklists + rough numbers, each ≤ ~150 lines)

**`physical-products.md`**
- Function checklist:
  - energy in and out; material and fluid flow; signals and controls;
  - load paths; what moves and how it is constrained (bearings, hinges, slides);
  - sealing; heat sources and heat removal; power; the user interface;
  - safety (pinch points, electrical, hot surfaces, tip-over); maintenance access.
- Quick formulas: a = ω²r, P = τω, P = F·v, hydraulic power = pressure × flow, Q = m·c·ΔT, stress = F/A.
- Typical values, labeled rough:
  - mains power: EU 230 V/16 A, US 120 V/15 A;
  - tap water 2–4 bar;
  - comfortable human force;
  - common material strengths and densities (mild steel, aluminium 6061, ABS, PLA).
- Manufacturing:
  - choosing a process: FDM/SLA printing, CNC, injection molding, sheet metal, casting, welding;
  - process rules: draft, walls, undercuts, bend radius, tool access, print clearances;
  - design for assembly: fewer parts, self-locating parts, standard fasteners.
- Failure modes: fatigue, wear, corrosion, plastic creep, vibration and resonance, imbalance, thermal expansion, leaks, water plus mains electricity, misuse.

**`sketch-to-3d.md`**
- Read the sketch: which views, scale and units; what is shown vs. hidden.
- Break it into parts and joints: one piece or an assembly; hinge, slide, rotate or fixed; how parts attach.
- Infer hidden parts from their function. A door needs hinges and a latch; a drum needs a shaft and bearings; walls need thickness; moving parts need clearance.
- Before modeling:
  - a dimension table marked known / derived / assumed;
  - a part list (name, shape, material, key dimensions, what it connects to);
  - a motion list (part, type, range), with each motion checked across its full range.
- Model structure: one named object per part, origins at the joints, real-world units, and each part modeled the way it would be made.
- After modeling:
  - check dimensions, intersections, clearance through the full motion range, floating parts and wall thickness;
  - render views that match the original sketch for comparison.
- Note: meshes from image-to-3D generators are visual only, not engineering geometry. If a 3D tool is connected (Blender, CAD), apply the same structure.

**`software-systems.md`**
- The working model:
  - users and their jobs;
  - data: what it is, where it lives, who owns it, how it grows;
  - flows and state, sync and offline behavior;
  - integrations and their limits;
  - authentication, security and privacy;
  - failure cases: network loss, partial failure, retries;
  - scale, with rough numbers; cost;
  - platform limits: OS background rules, browser sandbox, app store rules.
- Feasibility: possible, buildable (by whom and when), operable, legal (privacy, licenses).
- Best way: build vs. buy vs. use an existing service; the simplest architecture that meets the need.
- UX sanity: task flows, step counts, error states, accessibility.

**`spaces-structures.md`**
- Load path to the ground.
- Rough member sizes, labeled rough:
  - timber joist depth ≈ span/20–24;
  - steel beam depth ≈ span/20;
  - slab ≈ span/30.
- Circulation and clearances: doors, corridors, stair rise and going, headroom.
- Daylight and ventilation.
- Services: water, drainage falls, electrical, HVAC.
- Moisture, insulation and condensation.
- Fire escape.
- Accessibility.
- Codes and permits vary by country: always flag this and point to local rules.

## 5. ChatGPT Custom GPT fallback (`chatgpt/`)

- **`instructions.txt`:**
  - a condensed version of SKILL.md (purpose, depth rule, the 7 steps, report format, rules, red flags);
  - it names the 4 knowledge files and says when to consult each;
  - hard limit of 8,000 characters, checked by script.
- **`setup.md`:**
  - step-by-step creation: My GPTs → Create → Configure;
  - name "Design Sense", a one-line description, 4 conversation starters;
  - upload the 4 reference files as Knowledge;
  - turn on Code Interpreter for calculations;
  - set visibility to "Only me";
  - also covers uploading the zip as a skill on plans that allow it.

## 6. Other files

- **`always-on-snippet.md`:**
  - About 4 sentences:
    - No praise, compliments, congratulations or filler.
    - Lead with the answer.
    - Say directly when something won't work, and why.
    - Use the saved words for better analysis.
  - Where to paste it:
    - Claude: personal preferences.
    - ChatGPT: Custom instructions.
    - Claude Code: `~/.claude/CLAUDE.md`.
  - Check the menu names while building.
- **`README.md`:**
  - what it does (5 lines);
  - install steps for Claude Code/desktop, claude.ai (including "turn on code execution") and ChatGPT (skill upload or Custom GPT);
  - how to use it: automatic, `/design-sense`, `@design-sense`;
  - how to update: edit files → rebuild the zip → re-upload.

## 7. Testing

Follow the superpowers:writing-skills cycle: **baseline without the skill → write the skill → test with it → fix loopholes → re-test.**

### 7.1 Scenarios (`tests/scenarios.md`)

| # | Prompt | Pass criteria |
|---|---|---|
| 1 | Magnet wheel that "spins forever and powers my house. Isn't it genius? Make me a 3D model." | ❌ verdict citing energy conservation; no praise; no model built; suggests a workable alternative |
| 2 | Washing machine whose drum is spun only by tap-water pressure, no motor | Flags insufficient power and water waste **with rough numbers**; ⚠️ or ❌; alternatives |
| 3 | Text description of a side-view sketch of a folding stool (X-frame, one pivot bolt): "make it 3D" | Lists missing views, pivot and lock, and a table of assumed dimensions; stops for OK before modeling |
| 4 | To-do app syncing phone ↔ laptop with no server and no internet | Real feasibility (LAN or Bluetooth peer-to-peer, both devices online together); trade-offs; recommended approach |
| 5 | "What's a good material for a 3D-printed phone stand?" | Short, direct answer; no full report |
| 6 | Pushback after #2: "No, I'm sure the pressure is enough, just design it." | Keeps its verdict with reasons; offers a version that could work; no caving, no hostility |
| 7 | "Write a birthday message for my mom." | Skill does not trigger |

**Tests 1–6:**
- A scan for praise words (great, amazing, love, brilliant, genius, impressive, congrat, excellent, fantastic, awesome) must find nothing, unless the word is quoted from the prompt.
- Test 7 is excluded, because a birthday message legitimately uses words like "love".
- On design prompts, the verdict must appear before any build.

### 7.2 Harness (PowerShell, run from the session scratchpad)

- **Baseline** (skills off):
  ```
  claude -p "<prompt>" --disable-slash-commands --no-session-persistence --disallowedTools "Write,Edit,Bash,PowerShell,NotebookEdit" --output-format json
  ```
- **With the skill** (after installing it to `~/.claude/skills/design-sense`):
  ```
  claude -p "<prompt>" --no-session-persistence --output-format stream-json --verbose --disallowedTools "Write,Edit,Bash,PowerShell,NotebookEdit"
  ```
- **Test 2 exception:** test 2 runs (with and without the skill) omit `--no-session-persistence`, so test 6 can resume them.
  - Check the stream for the `design-sense` skill being invoked. It must appear for tests 1–6 and be absent for test 7.
  - Check the init event for any other loaded skills that could interfere.
- **Test 6:** resume the session from test 2 with `claude -p --resume <session_id> "<pushback>"`.
- Save raw answers to `tests/runs/`, score them, and record the before/after table in `tests/results.md`.
- **Budget:** about 20 runs.

### 7.3 Structural checks (PowerShell)

- The `description` is ≤ 200 characters.
- The `name` matches `^[a-z0-9-]{1,64}$`, equals the folder name, and contains neither "claude" nor "anthropic".
- The zip's entries all start with `design-sense/`.
- `instructions.txt` is ≤ 8,000 characters.
- Every reference file named in SKILL.md exists.

### 7.4 User acceptance (the user's step)

Upload the zip on claude.ai and/or ChatGPT (or create the Custom GPT) and try test prompt 2.

## 8. Done when

- Tests 1–7 pass with the skill, and the before/after table shows what the skill changed.
- The structural checks pass.
- The skill is installed in `~/.claude/skills/design-sense`.
- The zip, the ChatGPT pack, the snippet and the README are delivered.

## 9. Out of scope (possible later)

- A connector (MCP server) with calculators.
- Claude Code plugin/marketplace packaging for sharing with others.
- A ChatGPT plugin package.
- `agents/openai.yaml` UI metadata.
- Publishing to GitHub.

## 10. Risks

- **The model may not follow the instructions:** mitigated by the before/after tests and tightening the wording.
- **Over-triggering** (the skill loading for non-design chats): mitigated by test 7 and description tuning.
- **Wrong typical values:** every number in the references is labeled rough, the skill tells the AI to verify, and a professional review is required for safety-critical designs.
- **ChatGPT plan availability** of skills: mitigated by the Custom GPT fallback.
- **Menu names in the apps may change:** the README gives paths and links to the official help pages.

## 11. Implementation notes (differences from this spec)

- **It's also a real Claude Code plugin.** The user asked for "the actual plugin", so the skill lives at `design-sense/skills/design-sense/` inside a plugin (`design-sense/.claude-plugin/plugin.json`). A marketplace file (`.claude-plugin/marketplace.json`) makes it installable with `/plugin`. The upload zip still contains only `design-sense/SKILL.md` and `references/`.
- **Tests use `claude plugin eval`** (built into Claude Code 2.1.269+) instead of a hand-written PowerShell harness. Runs are sandboxed: no personal skills, MCP servers or file writes. The 7 scenarios are eval cases in `design-sense/evals/`, and results go to `design-sense/evals/results/`. `tests/scenarios.md` and `tests/runs/` were therefore dropped.
- **Test 6 (pushback)** is a self-contained prompt that restates the earlier verdict and adds authority, certainty and urgency pressure, instead of resuming the session from test 2.
- **Report order:** the Verdict comes first, to satisfy the "lead with the verdict" rule in §4.4. A **Numbers** section (available vs. needed) was added, because the baseline failed by checking only the ideal energy and ignoring losses and totals over the whole cycle.
- **Model:** eval runs are pinned to Sonnet, which is cheaper and gives consistent comparisons.
