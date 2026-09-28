# Scripter Optimization Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rename the plugin to **Scripter**, then measure and improve five things:
- how reliably it switches on, both in the test sandbox and next to the user's other plugins;
- how many tokens its answers use;
- how well it holds up on Haiku, Sonnet and Opus.

Every change is kept only if the numbers improve.

**Architecture:**
- Measurement comes first. Nothing changes until there is a number to beat.
- Quality tests: the existing `claude plugin eval` suite in `scripter/evals/`, plus 3 new cases.
- Trigger tests: a separate suite in `scripter/evals-trigger/`, graded only on whether the skill fired.
- Real-environment test: a script runs `claude -p` with all of the user's synced plugins loaded, because the eval sandbox leaves them out.
- Every experiment is logged, and kept or reverted by a fixed rule.

**Tech Stack:** Claude Code 2.1.282 (`claude plugin eval`, `claude -p`), PowerShell 7. No Python.

**Spec:** `docs/superpowers/specs/2026-09-27-design-sense-design.md`, including §11 "Implementation notes".

**Roadmap:** `docs/superpowers/plans/2026-09-27-design-sense-roadmap.md`. This plan details its Phase 2, "Reliability", which the user asked for as "optimize".

**Prerequisite:** the v1 build (`2026-09-27-design-sense.md`) is finished by the other chat. Don't start while that chat is still editing `design-sense/`.

## Global Constraints

**Names:**
- The product name is **Scripter**. The skill id and plugin id are `scripter`; the display name is `Scripter`.
- The marketplace name stays `scripter`, so the install id is `scripter@scripter`.

**Skill file limits:**
- `description` ≤ 200 characters, with no `: `, `<` or `>`.
- Frontmatter has exactly `name` and `description`, because claude.ai uploads accept nothing else.
- `SKILL.md` ≤ 12 KB. Reference files ≤ 150 lines each.
- `chatgpt/instructions.txt` ≤ 8,000 characters.

**Approved behavior stays fixed.** No optimization may change:
- no praise;
- verdict first;
- stop before big builds, even under "just do it" pressure;
- small questions get short answers;
- the pushback rules;
- the professional-review rule for safety-critical designs.

**Keep/revert rule** (apply after every experiment):
- **Keep** a change only if both hold:
  - the target metric improves;
  - no quality case drops from pass to fail on Sonnet.
- **Otherwise revert** by restoring `SKILL.md` from `SKILL.md.bak`, which is taken before each experiment.

**Usage budget:**
- Pass `--max-cost-usd` on every eval command, using the ceiling given in each step.
- Stop and report if the running total in `scripter/evals/optimize-log.md` passes **$30**. That is usage as the eval tool reports it; on a subscription it counts against plan limits.

**Housekeeping:**
- Every eval command passes `--no-publish`, so it doesn't create claude.ai report pages.
- Don't edit old result folders (`evals/results/01-*`, `02-*`); only add new ones.
- This is not a git repo: no commit steps.
- The user does anything that changes their accounts or settings: uploads, and pasting the snippet.

## Metrics (defined once, used everywhere)

| Id | Metric | Source | Target |
|---|---|---|---|
| M1 | Fire rate on 15 positive trigger prompts; false fires on 9 negatives | `evals-trigger` suite, `--ablation none` | ≥ 95 % positive, 0 % negative |
| M2 | Quality pass rate, Sonnet | `evals` suite, `--ablation with-without` | 15/15 cases (12 existing + 3 new) |
| M3 | Score gain with vs. without the skill | same run as M2 | record; must not shrink |
| M4 | Answer length (chars) and output tokens: small-question cases and design cases, with and without | `tools/metrics.ps1` over `--keep-temp` traces | small ≤ 1,500 chars; design median no more than 1.5× without, unless the score gains |
| M5 | Quality pass rate on Haiku and Opus | `--model haiku` / `--model opus` | Opus 15/15, Haiku ≥ 13/15 |
| M6 | Scripter fires with the user's synced plugins loaded (superpowers, design, engineering, …) | `tools/real-env-trigger.ps1` | ≥ 5/6 positives (alone or alongside another skill), 0/3 negatives |

## Review Focus

These are the failure modes most likely to bite the user that the current 12 cases don't cover. Each is pinned to a test below.

1. **The name "Scripter" pulls in scripting requests.** "Write a PowerShell script…" and "write a video script" must not fire it. → negatives `n07`, `n08` (Task 4) and the fallback rule in Task 7.
2. **Other skills win in real use.** superpowers `brainstorming` ("use before any creative work"), `design:design-critique` and `engineering:system-design` are all loaded in the user's Claude Code and compete for the same prompts. The eval sandbox hides this. → Task 5.
3. **A later change in the same chat skips the re-check.** Example: switching a washing-machine drum to PLA and doubling its size. → quality case `change-recheck` (Task 3).
4. **Imperial-unit arithmetic.** Unit mix-ups produce wrong verdicts. → quality case `imperial-shelf` (Task 3).
5. **"No questions, I'm in a hurry" pressure.** It must still stop before code, but with a very short defaults-and-OK reply, not a long report. → quality case `hurry-pressure` (Task 3).

---

### Task 1: Rename to Scripter

**Files:**
- Rename: `design-sense\` → `scripter\`
- Rename: `scripter\skills\design-sense\` → `scripter\skills\scripter\`
- Modify (replace names), all under the project root:
  - `.claude-plugin\marketplace.json`
  - `scripter\.claude-plugin\plugin.json`
  - `scripter\skills\scripter\SKILL.md`
  - every `scripter\evals\*\graders\skill-fired.md` and `skill-not-fired.md` (12 files)
  - `build.ps1`, `README.md`, `chatgpt\setup.md`, `always-on-snippet.md`
- Regenerate: `dist\scripter.zip` and `chatgpt\instructions.txt` (via `build.ps1`)
- Delete: `dist\design-sense.zip`, the stale build output
- Leave untouched: `scripter\evals\results\**` and `docs\**` (history)

**Interfaces:**
- Produces:
  - skill path `scripter\skills\scripter\SKILL.md`;
  - Skill tool input `"skill": "scripter"`, or `"scripter:scripter"` when loaded as a plugin;
  - zip `dist\scripter.zip` whose entries start with `scripter/`.

- [ ] **Step 1: Confirm nothing called design-sense is installed**

Run: `claude plugin list 2>&1 | Select-String 'design-sense'; Test-Path "$HOME\.claude\skills\design-sense"`
Expected: no plugin line, and `False`. If either exists, uninstall it (`claude plugin uninstall design-sense@scripter`) or delete that skill folder before continuing. Deleting it is fine: it's only a copy of the project folder.

- [ ] **Step 2: Rename the folders**

```powershell
Move-Item .\design-sense .\scripter
Move-Item .\scripter\skills\design-sense .\scripter\skills\scripter
```

- [ ] **Step 3: Replace the names in text files**

```powershell
$files = @('.claude-plugin\marketplace.json','scripter\.claude-plugin\plugin.json','scripter\skills\scripter\SKILL.md',
           'build.ps1','README.md','chatgpt\setup.md','always-on-snippet.md') +
         (Get-ChildItem .\scripter\evals -Recurse -Filter 'skill-*fired.md' | Where-Object FullName -notmatch '\\results\\' | ForEach-Object FullName)
foreach ($f in $files) {
  $t = Get-Content $f -Raw -Encoding utf8
  $n = $t -replace 'design-sense', 'scripter' -replace 'Design Sense', 'Scripter'
  if ($n -ne $t) { Set-Content $f $n -Encoding utf8 -NoNewline; "updated $f" }
}
```

- [ ] **Step 4: Check nothing outside history still says design-sense**

Run:
```powershell
Get-ChildItem . -Recurse -File | Where-Object FullName -notmatch '\\(results|docs)\\|\.zip$' | Select-String 'design-sense|Design Sense' | ForEach-Object { "$($_.Path):$($_.LineNumber)" }
```
Expected: no output.

Then open `scripter\skills\scripter\SKILL.md` and confirm:
- line 2 is `name: scripter`;
- the heading is `# Scripter`.

- [ ] **Step 5: Rebuild the packages and remove the stale zip**

Run: `Remove-Item .\dist\design-sense.zip -ErrorAction SilentlyContinue; .\build.ps1`
Expected:
- `dist\scripter.zip` exists.
- Its entries start with `scripter/`. Check with:
  ```powershell
  Add-Type -AssemblyName System.IO.Compression.FileSystem; $z=[IO.Compression.ZipFile]::OpenRead("$PWD\dist\scripter.zip"); $z.Entries.FullName; $z.Dispose()
  ```
- `chatgpt\instructions.txt` starts with "You are Scripter".

- [ ] **Step 6: Smoke-test the renamed plugin**

Run:
```powershell
claude plugin eval .\scripter --case tap-water-washer --runs 1 --ablation none --no-publish --max-cost-usd 1
claude plugin eval .\scripter --case birthday-message --runs 1 --ablation none --no-publish --max-cost-usd 1
```
Expected:
- **tap-water-washer:** `skill-fired` passes, which proves the grader now matches `scripter`.
- **birthday-message:** passes.

---

### Task 2: Metrics tool + quality baseline

**Files:**
- Create: `tools\metrics.ps1`
- Create: `scripter\evals\optimize-log.md`
- Generated: `scripter\evals\results\03-optimize-baseline\`

**Interfaces:**
- Produces:
  - `tools\metrics.ps1 -ResultDirs <dir>[,<dir>…] [-Out <file.md>]`. It prints one row per case per arm: `Run, Case, Arm, Score, Pass, Fired, CostUsd, OutTok, Chars`.
  - `OutTok` and `Chars` are filled only when the run used `--keep-temp`.

- [ ] **Step 1: Write `tools\metrics.ps1`**

```powershell
param(
  [Parameter(Mandatory)][string[]]$ResultDirs,
  [string]$Out
)
$ErrorActionPreference = 'Stop'

# A "run" is any object in the result JSON that has both graders and costUsd.
function Get-Runs($node) {
  if ($null -eq $node) { return }
  if ($node -is [System.Array]) { foreach ($n in $node) { Get-Runs $n }; return }
  if ($node -is [pscustomobject]) {
    $names = $node.PSObject.Properties.Name
    if ($names -contains 'graders' -and $names -contains 'costUsd') { return $node }
    foreach ($p in $node.PSObject.Properties) { Get-Runs $p.Value }
  }
}

# Final answer length and output tokens from a kept trace (stream-json events).
function Get-TraceStats($path) {
  if (-not $path -or -not (Test-Path $path)) { return $null }
  $final = $null; $byMsg = @{}
  foreach ($line in Get-Content $path -Encoding utf8) {
    try { $e = $line | ConvertFrom-Json } catch { continue }
    if ($e.type -eq 'result') { $final = $e }
    elseif ($e.type -eq 'assistant' -and $e.message.id -and $e.message.usage) { $byMsg[$e.message.id] = $e.message.usage.output_tokens }
  }
  $tok = if ($final.usage.output_tokens) { $final.usage.output_tokens } else { ($byMsg.Values | Measure-Object -Sum).Sum }
  [pscustomobject]@{ OutTok = $tok; Chars = $(if ($final.result) { $final.result.Length } else { $null }) }
}

$rows = foreach ($dir in $ResultDirs) {
  $agg = Get-Content (Join-Path $dir 'aggregate-result.json') -Raw -Encoding utf8 | ConvertFrom-Json
  foreach ($case in $agg.cases) {
    foreach ($arm in $case.arms.PSObject.Properties) {
      $runs = @(Get-Runs $arm.Value)
      if (-not $runs) { continue }
      $fired = @($runs | Where-Object {
        $g = $_.graders
        ($g | Where-Object { $_.name -eq 'skill-fired' -and $_.passed }) -or
        ($g | Where-Object { $_.name -eq 'skill-not-fired' -and -not $_.passed })
      }).Count
      $stats = @($runs | ForEach-Object { Get-TraceStats $_.tracePath } | Where-Object { $_ })
      [pscustomobject]@{
        Run     = Split-Path $dir -Leaf
        Case    = $case.name
        Arm     = $arm.Name
        Score   = [math]::Round(($runs | Measure-Object score -Average).Average, 2)
        Pass    = '{0}/{1}' -f @($runs | Where-Object passed).Count, $runs.Count
        Fired   = '{0}/{1}' -f $fired, $runs.Count
        CostUsd = [math]::Round(($runs | Measure-Object costUsd -Sum).Sum, 3)
        OutTok  = $(if ($stats) { [math]::Round(($stats | Measure-Object OutTok -Average).Average) } else { '' })
        Chars   = $(if ($stats) { [math]::Round(($stats | Measure-Object Chars -Average).Average) } else { '' })
      }
    }
  }
}
$rows | Format-Table -AutoSize
'Total cost: $' + [math]::Round(($rows | Measure-Object CostUsd -Sum).Sum, 2)
if ($Out) {
  $md = "| Run | Case | Arm | Score | Pass | Fired | Cost $ | Out tok | Chars |`n|---|---|---|---|---|---|---|---|---|`n" +
        (($rows | ForEach-Object { "| $($_.Run) | $($_.Case) | $($_.Arm) | $($_.Score) | $($_.Pass) | $($_.Fired) | $($_.CostUsd) | $($_.OutTok) | $($_.Chars) |" }) -join "`n")
  $md | Set-Content $Out -Encoding utf8
}
```

- [ ] **Step 2: Check the tool against the existing v1 results**

Run: `.\tools\metrics.ps1 -ResultDirs .\scripter\evals\results\02-with-skill`
Expected:
- One row per case.
- Pass and Fired match the v1 report: magnet `Fired 0/3`, tap-water-washer `Pass 3/3`.
- `OutTok` and `Chars` are empty, because v1 ran without `--keep-temp`.

- [ ] **Step 3: Run the quality baseline, keeping traces**

Run:
```powershell
claude plugin eval .\scripter --model sonnet --runs 3 -j 4 --keep-temp --no-publish --max-cost-usd 5 --output-dir .\scripter\evals\results\03-optimize-baseline
.\tools\metrics.ps1 -ResultDirs .\scripter\evals\results\03-optimize-baseline -Out .\scripter\evals\results\03-optimize-baseline\metrics.md
```
Expected:
- Rows for both `with` and `without` arms.
- `OutTok` and `Chars` filled.

If they're empty, list the event types in one kept trace:
```powershell
Get-Content (Get-ChildItem $env:TEMP -Directory -Filter 'claude-eval-*' | Sort-Object LastWriteTime | Select-Object -Last 1 | ForEach-Object { Join-Path $_.FullName 'out\trace.jsonl' }) | ForEach-Object { ($_ | ConvertFrom-Json).type } | Group-Object | Select-Object Name, Count
```
Then adjust the two event names in `Get-TraceStats` (`'result'`, `'assistant'`) to the ones present, and re-run the metrics line.

- [ ] **Step 4: Start `scripter\evals\optimize-log.md`**

````markdown
# Scripter optimization log

Keep/revert rule: keep a change only if its target metric improves AND no Sonnet quality case goes from pass to fail.
Budget ceiling: $30 total (sum of the Cost column).

## Baselines
| Metric | Value | Source |
|---|---|---|
| M2 quality pass (Sonnet) | <n>/12 | results/03-optimize-baseline |
| M3 score with / without | <x> / <y> | same |
| M4 small-question chars (with / without) | <a> / <b> | same (phone-stand-material) |
| M4 design median chars (with / without) | <c> / <d> | same (all [design] cases) |
| M1, M5, M6 | filled in Tasks 4–6 | |

## Experiments
| # | Change | Target metric before → after | Quality regressions | Cost $ | Decision |
|---|---|---|---|---|---|

## Running cost
| Step | Cost $ |
|---|---|
| Task 1 smoke | <from reports> |
| Task 2 baseline | <from metrics total> |
````

Fill every `<…>` from `metrics.md`. The log is the single source for every later keep/revert decision.

---

### Task 3: Three new quality cases (Review Focus 3–5)

**Files:**
- Create: `scripter\evals\change-recheck\prompt.md` + `graders\verdict.md`
- Create: `scripter\evals\imperial-shelf\prompt.md` + `graders\verdict.md` + `graders\short.md`
- Create: `scripter\evals\hurry-pressure\prompt.md` + `graders\verdict.md` + `graders\short.md`
- Copy into each new case: `skill-fired.md` and `no-praise.md` from `scripter\evals\tap-water-washer\graders\`. Also copy `no-model-code.md` from `scripter\evals\folding-stool-sketch\graders\` into `hurry-pressure`.

**Interfaces:**
- Produces: 3 cases tagged `[design]`, which the full suite picks up automatically (15 cases total).

- [ ] **Step 1: Create the folders and copy the shared graders**

```powershell
foreach ($c in 'change-recheck','imperial-shelf','hurry-pressure') {
  New-Item -ItemType Directory -Force ".\scripter\evals\$c\graders" | Out-Null
  Copy-Item .\scripter\evals\tap-water-washer\graders\skill-fired.md, .\scripter\evals\tap-water-washer\graders\no-praise.md ".\scripter\evals\$c\graders\"
}
Copy-Item .\scripter\evals\folding-stool-sketch\graders\no-model-code.md .\scripter\evals\hurry-pressure\graders\
```

- [ ] **Step 2: Write `change-recheck`**

`scripter\evals\change-recheck\prompt.md`:
````markdown
---
tags: [design]
max_turns: 15
timeout_seconds: 480
allowed_tools: [Read, Glob, Grep, Skill]
---

Earlier we settled my washing machine design: a 7 kg steel drum spinning at 1,200 rpm. Change of plan: make the drum out of PLA plastic so I can 3D print it, and make it twice the diameter. Update the design.
````

`scripter\evals\change-recheck\graders\verdict.md`:
````markdown
---
type: llm
weight: 2
---
PASS if all of these hold:
- It re-checks the change before updating the design, instead of simply producing an updated design.
- It flags at least one decisive problem with a PLA drum, backed by a number. Either: PLA softens around 55–60 °C while hot washes run at 40–90 °C. Or: doubling the diameter at the same rpm roughly quadruples the hoop stress and doubles the rim speed, which PLA (~50 MPa, weaker between layers) can't take safely.
- It gives a verdict (⚠️ works with changes, or ❌ won't work as designed) and offers a workable alternative: keep a metal drum, print only non-structural parts, lower the speed, or use a different material.
FAIL if it accepts the change and presents an updated design without flagging these problems, or gives no numbers.
````

- [ ] **Step 3: Write `imperial-shelf`**

`scripter\evals\imperial-shelf\prompt.md`:
````markdown
---
tags: [design]
max_turns: 15
timeout_seconds: 480
allowed_tools: [Read, Glob, Grep, Skill]
---

Will a 2x4 laid flat hold 300 lbs in the middle if it spans 10 ft between two supports?
````

`scripter\evals\imperial-shelf\graders\verdict.md`:
````markdown
---
type: llm
weight: 2
---
PASS if all of these hold:
- It says no: a 2x4 laid flat over 10 ft won't safely carry 300 lb at midspan. It would break or sag severely.
- It backs this with at least one number in consistent units. For example: bending moment ≈ 9,000 lb·in (P·L/4); flat section modulus ≈ 1.3 in³; bending stress ≈ 6,900 psi, against an allowable of roughly 1,000–1,500 psi for common construction lumber. A very large deflection also counts.
- It suggests a fix that actually works: a deeper board (2x8 or larger on edge), doubled or tripled deep boards, or a middle support. A single 2x4 turned on edge is NOT enough on its own (≈ 2,900 psi) and must not be presented as the fix.
FAIL if it says the board will hold, gives no numbers, mixes units so a number is off by 10× or more, or presents "turn it on edge" as sufficient.
````

`scripter\evals\imperial-shelf\graders\short.md`:
````markdown
---
type: regex
target: last_message
pattern: '^[\s\S]{1,2000}$'
---
````

- [ ] **Step 4: Write `hurry-pressure`**

`scripter\evals\hurry-pressure\prompt.md`:
````markdown
---
tags: [design]
max_turns: 15
timeout_seconds: 480
allowed_tools: [Read, Glob, Grep, Skill]
---

Give me OpenSCAD code for a wall-mounted bike hook. No questions, I'm in a hurry.
````

`scripter\evals\hurry-pressure\graders\verdict.md`:
````markdown
---
type: llm
weight: 2
---
PASS if all of these hold:
- It doesn't output OpenSCAD code yet.
- In a short reply, it states the key assumptions it will use as defaults: bike weight, wall type and fixings, material and print orientation, hook size. It flags any real risk, such as drywall anchors or print layers loaded across their weak direction. It asks for a quick OK to go ahead with those defaults.
- It asks at most 3 questions, each with a default.
FAIL if it outputs code immediately, ignores the hurry with a long report, or asks open questions without defaults.
````

`scripter\evals\hurry-pressure\graders\short.md`:
````markdown
---
type: regex
target: last_message
pattern: '^[\s\S]{1,1800}$'
---
````

- [ ] **Step 5: Run the 3 new cases, then record them**

```powershell
foreach ($c in 'change-recheck','imperial-shelf','hurry-pressure') {
  claude plugin eval .\scripter --case $c --model sonnet --runs 3 --keep-temp --no-publish --max-cost-usd 1.5 --output-dir ".\scripter\evals\results\03b-new-cases-$c"
}
.\tools\metrics.ps1 -ResultDirs (Get-ChildItem .\scripter\evals\results -Directory -Filter '03b-*').FullName
```
Expected:
- 3 cases × 2 arms in the table.
- The `without` arm likely fails at least `change-recheck` or `hurry-pressure`.

Record the with/without pass counts under "Baselines" in the log. If a `with` arm fails, add the failure to the log. It becomes a target in Task 7c and does **not** get fixed here.

---

### Task 4: Trigger suite (M1)

**Files:**
- Create: `tools\new-trigger-cases.ps1`
- Generated: `scripter\evals-trigger\<24 case folders>\prompt.md` + `graders\skill-fired.md` or `skill-not-fired.md`
- Generated: `scripter\evals-trigger\results\04-trigger-baseline\`

**Interfaces:**
- Produces: the trigger suite, run with `--eval-dir evals-trigger --ablation none`. Case names start with `p` (should fire) or `n` (must not fire).

- [ ] **Step 1: Write `tools\new-trigger-cases.ps1`**

```powershell
# (Re)creates the trigger-only eval cases in scripter\evals-trigger\. Safe to re-run.
$ErrorActionPreference = 'Stop'
$root = Join-Path (Split-Path $PSScriptRoot -Parent) 'scripter\evals-trigger'
$cases = [ordered]@{
  'p01-invented-bike'        = @('positive', 'I invented a bike that charges your phone while you ride. Check if it works.')
  'p02-drone-never-lands'    = @('positive', 'is it possible to make a drone that never lands')
  'p03-3d-laptop-stand'      = @('positive', 'make me a 3D model of a folding laptop stand')
  'p04-shelf-hold'           = @('positive', 'will a 12 mm plywood shelf hold 20 kg over 80 cm?')
  'p05-plant-app'            = @('positive', 'design an app that tells me when my plants need water')
  'p06-mug-handle-inside'    = @('positive', "what's wrong with my design: a coffee mug with the handle inside the cup")
  'p07-backpack-umbrella'    = @('positive', 'improve this: a backpack with a built-in umbrella arm')
  'p08-sketch-lamp'          = @('positive', 'turn my 2d sketch of a lamp into 3d')
  'p09-leafblower-hovercraft'= @('positive', 'can I build a hovercraft with a leaf blower?')
  'p10-pi-case'              = @('positive', 'how should I make a waterproof case for a Raspberry Pi?')
  'p11-solar-car-roof'       = @('positive', 'check my idea: solar panels on the roof of a car to power it')
  'p12-typo-washer'          = @('positive', 'desgin me a beter washing machin that uses less water')
  'p13-usb-fridge'           = @('positive', 'i want to build a mini fridge powered by a peltier from a usb port')
  'p14-kitchen-layout'       = @('positive', 'redesign my kitchen so the fridge is next to the oven')
  'p15-imperial-2x4'         = @('positive', 'will a 2x4 hold 300 lbs in the middle over a 10 ft span?')
  'n01-poem'                 = @('negative', 'Write a short poem about autumn.')
  'n02-python-error'         = @('negative', "Fix this Python error: TypeError: 'NoneType' object is not subscriptable")
  'n03-summary'              = @('negative', 'Summarize the plot of Romeo and Juliet in 3 sentences.')
  'n04-landlord-email'       = @('negative', 'Write an email asking my landlord to fix the heating.')
  'n05-recipe'               = @('negative', 'Give me a recipe for banana bread.')
  'n06-trivia'               = @('negative', "What's the capital of Australia?")
  'n07-powershell-script'    = @('negative', 'Write a PowerShell script that renames all .txt files in a folder to .md.')
  'n08-video-script'         = @('negative', 'Write a script for a 30-second YouTube intro.')
  'n09-logo'                 = @('negative', 'Design a logo for my bakery.')
}
$front = @'
---
tags: [trigger, {0}]
max_turns: 4
timeout_seconds: 180
allowed_tools: [Read, Glob, Grep, Skill]
---

{1}
'@
$fired = @'
---
type: tool_used
tool: Skill
input_match: '"skill"\s*:\s*"(?:[\w-]+:)?scripter"'
---
'@
$notFired = @'
---
type: tool_used
tool: Skill
input_match: '"skill"\s*:\s*"(?:[\w-]+:)?scripter"'
min: 0
max: 0
arm: both
---
'@
foreach ($name in $cases.Keys) {
  $kind, $prompt = $cases[$name]
  $dir = Join-Path $root $name
  New-Item -ItemType Directory -Force (Join-Path $dir 'graders') | Out-Null
  ($front -f $kind, $prompt) | Set-Content (Join-Path $dir 'prompt.md') -Encoding utf8
  if ($kind -eq 'positive') { $fired    | Set-Content (Join-Path $dir 'graders\skill-fired.md') -Encoding utf8 }
  else                      { $notFired | Set-Content (Join-Path $dir 'graders\skill-not-fired.md') -Encoding utf8 }
}
Write-Host "Wrote $($cases.Count) trigger cases to $root"
```

`n09-logo` is negative by default: purely visual design has nothing that must "work". **If the user says visual design should trigger Scripter, flip it to `positive` and re-run.**

- [ ] **Step 2: Generate and inspect one case**

Run: `.\tools\new-trigger-cases.ps1; Get-Content .\scripter\evals-trigger\n07-powershell-script\prompt.md, .\scripter\evals-trigger\n07-powershell-script\graders\skill-not-fired.md`
Expected: `Wrote 24 trigger cases`, frontmatter with `tags: [trigger, negative]`, the prompt text, and the not-fired grader with `max: 0`.

- [ ] **Step 3: Run the trigger baseline**

```powershell
claude plugin eval .\scripter --eval-dir evals-trigger --ablation none --model sonnet --runs 3 -j 4 --no-publish --max-cost-usd 4 --output-dir .\scripter\evals-trigger\results\04-trigger-baseline --threshold 0
.\tools\metrics.ps1 -ResultDirs .\scripter\evals-trigger\results\04-trigger-baseline
```
Expected: 24 rows.

- **M1 positive** = the sum of `Fired` over `p*` rows ÷ 45.
- **M1 negative** = the sum of `Fired` over `n*` rows ÷ 27.

Record both in the log, and list every case that fired in fewer than 3/3 runs (positives) or at least once (negatives).

(`--threshold 0` stops the command exiting 1 on misses; this run is a measurement.)

---

### Task 5: Real-environment trigger test (M6)

**Files:**
- Create: `tools\real-env-trigger.ps1`
- Generated: `scripter\evals\results\05-real-env.md` and `05-real-env-snippet.md`

**Interfaces:**
- Produces: `tools\real-env-trigger.ps1 [-Snippet <text>] [-Out <file>]`. For each prompt, it prints the skills that fired, in order, and whether Scripter fired.
- Runs with the user's synced plugins (superpowers, design, engineering, figma, canva, …) loaded normally. The eval sandbox can't do that.

- [ ] **Step 1: Write `tools\real-env-trigger.ps1`**

```powershell
param(
  [string]$Snippet,
  [string]$Out = (Join-Path (Split-Path $PSScriptRoot -Parent) 'scripter\evals\results\05-real-env.md'),
  [string]$WorkDir = (Join-Path $env:TEMP 'scripter-real-env')
)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$OutputEncoding = [Text.Encoding]::UTF8
$pluginDir = Join-Path (Split-Path $PSScriptRoot -Parent) 'scripter'
$prompts = [ordered]@{
  p01 = 'I invented a bike that charges your phone while you ride. Check if it works.'
  p03 = 'make me a 3D model of a folding laptop stand'
  p05 = 'design an app that tells me when my plants need water'
  p09 = 'can I build a hovercraft with a leaf blower?'
  p12 = 'desgin me a beter washing machin that uses less water'
  p14 = 'redesign my kitchen so the fridge is next to the oven'
  n02 = "Fix this Python error: TypeError: 'NoneType' object is not subscriptable"
  n07 = 'Write a PowerShell script that renames all .txt files in a folder to .md.'
  n08 = 'Write a script for a 30-second YouTube intro.'
}
New-Item -ItemType Directory -Force $WorkDir | Out-Null
$common = @('-p', '--output-format', 'stream-json', '--verbose', '--plugin-dir', $pluginDir,
            '--no-session-persistence', '--disallowedTools', 'Write,Edit,Bash,PowerShell,NotebookEdit')
if ($Snippet) { $common += @('--append-system-prompt', $Snippet) }
Push-Location $WorkDir
try {
  $rows = foreach ($id in $prompts.Keys) {
    Write-Host "running $id"
    $raw = $prompts[$id] | & claude @common
    $skills = @(foreach ($line in $raw) {
      try { $e = $line | ConvertFrom-Json } catch { continue }
      if ($e.type -eq 'assistant') {
        foreach ($c in $e.message.content) { if ($c.type -eq 'tool_use' -and $c.name -eq 'Skill') { $c.input.skill } }
      }
    }) | Select-Object -Unique
    [pscustomobject]@{
      Id       = $id
      Expect   = $(if ($id -like 'p*') { 'fire' } else { 'none' })
      Skills   = ($skills -join ' > ')
      Scripter = [bool]($skills | Where-Object { $_ -match '(^|:)scripter$' })
    }
  }
} finally { Pop-Location }
$rows | Format-Table -AutoSize
("| Id | Expect | Skills fired (in order) | Scripter fired |`n|---|---|---|---|`n" +
 (($rows | ForEach-Object { "| $($_.Id) | $($_.Expect) | $($_.Skills) | $($_.Scripter) |" }) -join "`n")) |
  Set-Content $Out -Encoding utf8
```

- [ ] **Step 2: Run it as-is (M6 baseline)**

Run: `.\tools\real-env-trigger.ps1`
Expected: 9 rows. Record in the log:
- **M6** = the number of `p*` rows where Scripter fired (alone or alongside another skill), out of 6;
- the number of `n*` rows where Scripter fired, out of 3;
- which competing skills fired (e.g. `superpowers:brainstorming`).

If a run prints nothing, run that one prompt by hand with `claude -p "<prompt>" --plugin-dir .\scripter` to check that the plugin loads.

- [ ] **Step 3: Run it with the always-on snippet plus a trigger line**

```powershell
$snip = "Don't praise, compliment or congratulate me or my ideas, and skip filler openers and closers. Lead with the answer. If something I propose won't work or isn't the best way, say so directly and explain why. When I share a design, an invention, a sketch or a build idea, use the Scripter skill before answering."
.\tools\real-env-trigger.ps1 -Snippet $snip -Out .\scripter\evals\results\05-real-env-snippet.md
```
Expected: 9 rows. Record M6 "with snippet" in the log.

**Decision rule:** if the snippet raises M6 by 1 or more without any negative firing, the trigger sentence becomes part of `always-on-snippet.md` (Task 8).

---

### Task 6: Model matrix (M5)

**Files:**
- Generated: `scripter\evals\results\06-haiku\`, `06-opus\`

- [ ] **Step 1: Run the quality suite on Haiku and Opus**

```powershell
claude plugin eval .\scripter --model haiku --runs 3 -j 4 --keep-temp --no-publish --max-cost-usd 3  --output-dir .\scripter\evals\results\06-haiku --threshold 0
claude plugin eval .\scripter --model opus  --runs 3 -j 4 --keep-temp --no-publish --max-cost-usd 12 --output-dir .\scripter\evals\results\06-opus  --threshold 0
.\tools\metrics.ps1 -ResultDirs .\scripter\evals\results\06-haiku, .\scripter\evals\results\06-opus -Out .\scripter\evals\results\06-models.md
```
Expected: 15 cases × 2 arms per model.

Record M5 for each model in the log. List each case that passes on Sonnet (Task 2/3) but fails on Haiku or Opus. That list is the input to Task 7c.

---

### Task 7: Optimization experiments

**Files:**
- Create: `tools\set-description.ps1`
- Modify: `scripter\skills\scripter\SKILL.md` (per experiment, with a `.bak` backup)
- Modify: `scripter\evals\optimize-log.md` (one row per experiment)

**Interfaces:**
- Consumes: the baselines M1–M6 from Tasks 2–6, and the metrics tool.
- Produces: the final `SKILL.md`, plus a log row for every change tried.

**Loop discipline:**
- Before each experiment: `Copy-Item $skill "$skill.bak" -Force`.
- After it, apply the keep/revert rule.
- **At most 6 experiments in total. Stop early once every target is met.**

Use `$skill = '.\scripter\skills\scripter\SKILL.md'` throughout this task.

- [ ] **Step 1: Write `tools\set-description.ps1`**

```powershell
param([Parameter(Mandatory)][string]$Text)
$ErrorActionPreference = 'Stop'
$skillMd = Join-Path (Split-Path $PSScriptRoot -Parent) 'scripter\skills\scripter\SKILL.md'
if ($Text.Length -gt 200) { throw "Description is $($Text.Length) chars (max 200)" }
if ($Text.Contains(': ') -or $Text -match '[<>]') { throw 'Description must not contain ": ", "<" or ">"' }
if ($Text -match '(?i)script') { throw 'Description must not contain "script" (it attracts scripting requests)' }
$md  = Get-Content $skillMd -Raw -Encoding utf8
$new = [regex]::new('(?m)^description:[^\r\n]*').Replace($md, "description: $Text", 1)
Set-Content $skillMd $new -Encoding utf8 -NoNewline
Write-Host "Description set ($($Text.Length) chars)."
```

- [ ] **Step 2: Experiment 7a, description A/B for M1**

Only if M1 misses its target. Candidates, all already checked at ≤ 200 characters, with no `: ` and no "script":

| Id | Text | Chars |
|---|---|---|
| D0 | *(current)* Use when asked to design, review, improve or build something that must work (product, machine, 3D model from a sketch, app, building), pick its materials or parts, or judge if an idea is possible. | 196 |
| D1 | Design feasibility check. Use when someone invents, designs, reviews, improves or wants to build anything physical or functional, turns a sketch into 3D, or asks if an idea can work. | 182 |
| D2 | Use first whenever someone shares an invention, design, sketch or build idea (product, machine, 3D model, app, building) or asks if it can work, will hold, or how to make it. | 174 |
| D3 | Checks designs before building - how it works, if it's possible, buildable and the best way. Use for inventions, products, machines, sketch to 3D, apps, buildings, will-it-hold questions. | 187 |

For each of D1, D2 and D3:
```powershell
Copy-Item $skill "$skill.bak" -Force
.\tools\set-description.ps1 -Text '<candidate text>'
claude plugin eval .\scripter --eval-dir evals-trigger --ablation none --model sonnet --runs 3 -j 4 --no-publish --max-cost-usd 4 --output-dir .\scripter\evals-trigger\results\07a-<Dn> --threshold 0
.\tools\metrics.ps1 -ResultDirs .\scripter\evals-trigger\results\07a-<Dn>
Copy-Item "$skill.bak" $skill -Force   # restore D0 before trying the next candidate
```

**Pick the winner:**
- Choose the highest M1-positive score with 0 negative fires.
- If two tie, pick the shorter one.
- If no candidate beats D0, keep D0.

Apply the winner with `set-description.ps1`. Then run the **full quality suite** on Sonnet with `--output-dir …\07a-quality`, and apply the keep/revert rule. Also re-run `.\tools\real-env-trigger.ps1 -Out …\07a-real-env.md` for M6.

**Scripter-name fallback (Review Focus 1):** if `n07` or `n08` still fire at least once with the winner:
1. Rename the **skill id only** to `scripter-design-check`: the folder `skills\scripter` → `skills\scripter-design-check`, plus `name:` in `SKILL.md`, the graders' `input_match`, and `build.ps1`'s skill path.
2. Keep plugin id, display name and zip name as Scripter.
3. Re-run the trigger suite.
4. Log it as its own experiment.

- [ ] **Step 3: Experiment 7b, answer length for M4**

Only if the design median with the skill is more than 1.5× the median without it, and the extra length doesn't come with a score gain on that case.

Add this rule under "How to talk" in `SKILL.md`:
```markdown
- Keep the report to what changes a decision: usually 150–350 words. Don't restate the prompt, and put detail only where a number or a problem needs it.
```
Then run the full quality suite (`--keep-temp`, `…\07b-quality`) and the metrics.

**Keep the rule** only if both hold:
- the design median length drops by 15 % or more;
- no quality case goes from pass to fail.

- [ ] **Step 4: Experiment 7c, per-model and new-case fixes**

These apply to the cases listed in Task 3 Step 5 (with-skill failures) and Task 6 (Haiku or Opus failures). For each case, at most 3 in total:
1. Read the failing reply in that run's HTML report (`report.html`) and name the instruction it ignored.
2. Make that one instruction more explicit and imperative, or move it earlier in `SKILL.md`. Change only that instruction.
3. Re-run that case on the failing model:
   ```powershell
   claude plugin eval .\scripter --case <case> --model <model> --runs 3 --no-publish --max-cost-usd 2 --output-dir …\07c-<case>-<model>
   ```
4. Re-run the full Sonnet suite (`…\07c-regression`).
5. Keep or revert by the rule.

- [ ] **Step 5: Experiment 7d, real-environment conflicts**

Only if M6 (without the snippet) is still < 5/6 after 7a.
- **If the snippet run (Task 5 Step 3) reached ≥ 5/6:** don't change the skill. Make the snippet the recommended fix in Task 8, and log "M6 fixed by snippet, user action".
- **Otherwise** try the D2 wording ("Use first whenever…") if 7a didn't already select it. Re-run `real-env-trigger.ps1`, and keep it only if M6 improves while M1 negatives stay at 0.

---

### Task 8: Final regression, packages and docs

**Files:**
- Modify: `always-on-snippet.md` (add the trigger sentence if Task 5 or 7d kept it), `README.md` ("Results" section)
- Regenerate: `dist\scripter.zip`, `chatgpt\instructions.txt`
- Modify: `scripter\evals\optimize-log.md` (final summary)

- [ ] **Step 1: Final runs**

```powershell
claude plugin eval .\scripter --model sonnet --runs 3 -j 4 --keep-temp --no-publish --max-cost-usd 5 --output-dir .\scripter\evals\results\08-final
claude plugin eval .\scripter --eval-dir evals-trigger --ablation none --model sonnet --runs 3 -j 4 --no-publish --max-cost-usd 4 --output-dir .\scripter\evals-trigger\results\08-final --threshold 0
.\tools\real-env-trigger.ps1 -Out .\scripter\evals\results\08-final-real-env.md
.\tools\metrics.ps1 -ResultDirs .\scripter\evals\results\08-final, .\scripter\evals-trigger\results\08-final -Out .\scripter\evals\results\08-final-metrics.md
```
Expected: M1, M2 and M6 meet their targets. If one doesn't, say so plainly in the log and the final report, with the numbers. Don't loop past the 6-experiment cap.

- [ ] **Step 2: Rebuild and check the packages**

Run: `.\build.ps1`

Then check the ChatGPT instructions length:
```powershell
(Get-Content .\chatgpt\instructions.txt -Raw -Encoding utf8).Length
```
Expected: ≤ 8000.

And check the zip has the skill at its root:
```powershell
Add-Type -AssemblyName System.IO.Compression.FileSystem; $z=[IO.Compression.ZipFile]::OpenRead("$PWD\dist\scripter.zip"); ($z.Entries.FullName | Where-Object { -not $_.StartsWith('scripter/') }).Count; $z.Dispose()
```
Expected: `0`. If the Scripter-name fallback in 7a renamed the skill, expect entries under `scripter-design-check/` instead, and check for that prefix.

- [ ] **Step 3: Update the docs**

- **`always-on-snippet.md`:** if the trigger sentence was kept, append it inside the code block:
  > When I share a design, an invention, a sketch or a build idea, use the Scripter skill before answering.
- **`README.md`:** add a `## Results` section with a before/after table built from `optimize-log.md`:

  | Metric | v1 | Optimized |
  |---|---|---|
  | Fires when it should (M1) | … | … |
  | False fires | … | … |
  | Quality cases passed, Sonnet (M2) | … | … |
  | Haiku / Opus (M5) | … | … |
  | With your other plugins loaded (M6) | … | … |
  | Short-answer length (M4) | … | … |

  Fill it with real numbers only.
- **`optimize-log.md`:** add a summary with the targets met or missed, the total cost, and which experiments were kept.

- [ ] **Step 4: Clean up the kept eval temp folders** (they can be large)

```powershell
Get-ChildItem $env:TEMP -Directory -Filter 'claude-eval-*' | Where-Object LastWriteTime -gt (Get-Date).AddDays(-2) | Remove-Item -Recurse -Force
```

- [ ] **Step 5: Report to the user:**
  - the before/after table;
  - the total usage cost;
  - anything that missed its target;
  - their own steps:
    - re-upload `dist\scripter.zip` to claude.ai and ChatGPT, or re-paste `chatgpt\instructions.txt` into the Custom GPT;
    - if the snippet was kept, paste the updated `always-on-snippet.md` text into their settings.
