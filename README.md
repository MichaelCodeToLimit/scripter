# Scripter

A plugin for Claude and ChatGPT that makes the AI **understand a design before it builds anything**. Whenever you design, review or ask it to build something, it:

1. works out **how that kind of thing works** (a washing machine, a folding stool, a sync app...);
2. checks your design, or its own idea, against that: **does it make sense, is it physically possible, can it be made, will it work**, with rough numbers where they matter;
3. asks whether it's **the best way** to do it, and suggests improvements;
4. **stops and waits for your OK** before big builds such as 3D models, drawings, full specs or code.

It doesn't praise or congratulate you. The words it saves go into the design instead. Design quality comes before speed.

It turns on by itself for design work and stays off for everything else.

**Website:** https://michaelcodetolimit.github.io/scripter/ (install guides, docs and test results)

## What's in this folder

| Path | What it is |
|---|---|
| `scripter\skills\scripter\` | **The skill**: `SKILL.md` plus four checklists in `references\` |
| `scripter\` | The same skill packaged as a **Claude Code plugin** (`.claude-plugin\plugin.json`), with its test suite in `evals\` |
| `dist\scripter.zip` | The file you upload to claude.ai or ChatGPT |
| `chatgpt\` | Custom GPT version (`instructions.txt`) and setup steps (`setup.md`) |
| `always-on-snippet.md` | Optional: a short no-praise rule for **all** chats |
| `.claude-plugin\marketplace.json` | Lets other people install the plugin with `/plugin` |
| `build.ps1` | Checks everything and rebuilds the zip |
| `scripter\evals\results\` | Test results (also on the website's Test results page) |
| `site\` | The website (Astro Starlight), deployed to GitHub Pages by `.github\workflows\deploy-site.yml` |
| `docs\superpowers\specs\` | The design spec |

## Install

### Claude Code and the Claude desktop app (Code tab)

It's already installed for you as a personal skill in `C:\Users\micha\.claude\skills\scripter`. It loads in every new session. To reinstall after changes, run:

```powershell
.\build.ps1 -Install
```

**Or install it as a plugin** (use this *instead of* the personal skill, not as well, or it loads twice):

```powershell
claude plugin marketplace add C:\Users\micha\Scripter
claude plugin install scripter@scripter
```

### Claude website and apps (claude.ai)

1. Go to **Settings → Capabilities** and turn on **Code execution and file creation**. Skills need it.
2. Go to **Customize → Skills** (claude.ai/customize/skills), choose to upload a skill, and pick `dist\scripter.zip`.
3. Make sure the skill's toggle is on.

### ChatGPT

Follow [`chatgpt\setup.md`](chatgpt/setup.md). Business, Enterprise and Edu plans can upload the zip as a skill. Every other paid plan uses a Custom GPT.

Menu names change from time to time. If a step doesn't match, see Claude's help article [How to create custom skills](https://support.claude.com/en/articles/12512198-how-to-create-custom-skills) or OpenAI's [Skills in ChatGPT](https://help.openai.com/en/articles/20001066-skills-in-chatgpt).

## How to use it

Just describe what you're designing. For example:

- "Here's my idea for a bike trailer that folds into a suitcase. Will it work?"
- "Turn this sketch into a 3D model." (attach the sketch)
- "Design a phone app that splits bills between friends without accounts."

To call it by name:
- Claude Code: `/scripter` (or `/scripter:scripter` when installed as a plugin)
- ChatGPT skill: `@scripter`
- Custom GPT: open **Scripter** from the sidebar

For a big job, you get a short report first: **Verdict** (✅ works / ⚠️ works with changes / ❌ won't work / ❓ need more info), how it works, the numbers, problems, better options, questions, and what it will build next. Reply "OK" (or change something) and it builds. Small questions, like "which material?", get a short direct answer.

## Change it

1. Edit the files in `scripter\skills\scripter\`.
2. Run `.\build.ps1 -Install`. It checks the files, rebuilds `dist\scripter.zip` and reinstalls the skill.
3. Re-upload the zip to claude.ai or ChatGPT. For the Custom GPT, also update `chatgpt\instructions.txt` and paste it in again.
4. Re-run the tests (optional; these use your Claude plan's allowance):

   ```powershell
   cd scripter
   claude plugin eval . --runs 1 --model sonnet --no-publish
   ```

## Limits

- It's a set of instructions: it guides the AI's thinking but can't force it. The tests in `scripter\evals\results\` show how well it works in practice.
- The typical values in the checklists are rough. They're for sanity checks, not final engineering. For structures, gas, mains electricity or pressure, have a qualified professional check the design.
