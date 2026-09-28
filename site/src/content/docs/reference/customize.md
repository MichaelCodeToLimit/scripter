---
title: Customize and rebuild
description: Change the skill, rebuild the zip, run the tests, and work on this website.
---

Scripter is plain Markdown. To change how it thinks, edit the files and rebuild.

## What's in the repo

| Path | What it is |
|---|---|
| [`scripter/skills/scripter/`](https://github.com/MichaelCodeToLimit/scripter/tree/main/scripter/skills/scripter) | **The skill:** `SKILL.md` plus four checklists in `references/` |
| `scripter/` | The same skill packaged as a Claude Code plugin (`.claude-plugin/plugin.json`), with its test suite in `evals/` |
| `scripter/evals-trigger/` | Tests that check when the skill turns on, and when it stays off |
| `dist/scripter.zip` | The file you upload to claude.ai or ChatGPT |
| `chatgpt/` | The Custom GPT version (`instructions.txt`) and its setup steps |
| `always-on-snippet.md` | The optional [no-praise instruction](/scripter/guides/always-on/) for every chat |
| `.claude-plugin/marketplace.json` | Lets people install the plugin with `/plugin` |
| `build.ps1` | Checks everything and rebuilds the zip |
| `site/` | This website |

## Change the skill

1. Fork the repo, or clone your own copy.

2. Edit the files in `scripter/skills/scripter/`.

3. Run the build script. It works in Windows PowerShell 5.1 and in PowerShell 7 on any OS:

   ```powershell
   ./build.ps1            # check the files and rebuild dist/scripter.zip
   ./build.ps1 -Install   # also copy the skill to ~/.claude/skills/scripter
   ```

   It checks that `SKILL.md` has valid frontmatter, that the description is at most 200 characters, that every referenced checklist exists, and that `chatgpt/instructions.txt` fits ChatGPT's 8,000-character limit. If the `claude` CLI is installed, it also validates the plugin and marketplace manifests.

4. Re-upload `dist/scripter.zip` wherever you use it. For a Custom GPT, update `chatgpt/instructions.txt` too, paste it in again, and re-upload any changed checklists.

## Run the tests

```bash
cd scripter
claude plugin eval . --runs 1 --model sonnet --no-publish
```

Each case in `scripter/evals/<case>/` has a `prompt.md` and a `graders/` folder. A grader is a regex check, a tool-use check or an AI-judged rubric. Results land in `scripter/evals/results/`. The tests use your Claude plan's allowance, so start with `--runs 1`.

## Work on this website

The site is built with [Astro Starlight](https://starlight.astro.build/) and lives in `site/`. You need Node.js 22.12 or newer.

```bash
cd site
npm install
npm run dev
```

The checklist pages, the full skill text, the test results and the downloads are **copied from the skill** by `site/scripts/sync-skill.mjs` every time you run `dev` or `build`. Edit the originals in `scripter/`, `dist/` or `chatgpt/`, not the copies. Everything else is Markdown in `site/src/content/docs/`.

Every push to `main` rebuilds the site and publishes it to GitHub Pages through `.github/workflows/deploy-site.yml`.
