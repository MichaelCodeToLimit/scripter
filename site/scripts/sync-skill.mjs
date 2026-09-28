// Copies content from the Scripter skill into the site before every dev or build run,
// so the docs never drift from the skill itself. Everything this script writes is
// gitignored; edit the source files in ../scripter, ../dist or ../chatgpt instead.
//
//   references/*.md     -> src/content/docs/reference/checklists/*.md
//   SKILL.md            -> src/content/docs/reference/skill-text.md
//   eval results (JSON) -> src/data/results.json
//   scripter.zip, GPT instructions -> public/downloads/

import { copyFileSync, existsSync, mkdirSync, readdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { basename, dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const site = join(dirname(fileURLToPath(import.meta.url)), '..');
const repo = join(site, '..');
const skillDir = join(repo, 'scripter', 'skills', 'scripter');
const repoUrl = 'https://github.com/MichaelCodeToLimit/scripter/blob/main';
const editUrl = (relPath) => `https://github.com/MichaelCodeToLimit/scripter/edit/main/${relPath}`;

// The with/without run shown on the Test results page. Change this when a newer
// full with/without run exists.
const RESULTS_RUN = '03-full-with-without';
const RESULTS_NOTE =
	'Earlier version of the skill (then called design-sense). The graders have been tightened since this run.';

function write(path, text) {
	mkdirSync(dirname(path), { recursive: true });
	writeFileSync(path, text);
}

// Splits a Markdown file into its H1 title, first paragraph and the body after the H1.
function parseMarkdown(text) {
	text = text.replace(/\r\n/g, '\n').replace(/^---\n[\s\S]*?\n---\n/, '');
	const h1 = text.match(/^# (.+)$/m);
	if (!h1) throw new Error('no H1 heading found');
	const body = text.slice(h1.index + h1[0].length).trimStart();
	const firstPara = body.split(/\n\s*\n/)[0].replace(/\*\*/g, '').replace(/`/g, '').replace(/\s+/g, ' ').trim();
	return { title: h1[1].trim(), description: firstPara, body };
}

function frontmatter(fields) {
	const lines = Object.entries(fields).map(([k, v]) =>
		typeof v === 'object' ? `${k}:\n${Object.entries(v).map(([k2, v2]) => `  ${k2}: ${JSON.stringify(v2)}`).join('\n')}` : `${k}: ${JSON.stringify(v)}`,
	);
	return `---\n${lines.join('\n')}\n---\n\n`;
}

function sourceNote(relPath) {
	return `:::note[Generated from the skill]\nThis page is copied from [\`${relPath}\`](${repoUrl}/${relPath}), the file Claude actually reads.\n:::\n\n`;
}

// 1. Checklists
const checklistOrder = ['physical-products', 'sketch-to-3d', 'software-systems', 'spaces-structures'];
const checklistOut = join(site, 'src', 'content', 'docs', 'reference', 'checklists');
rmSync(checklistOut, { recursive: true, force: true });
for (const file of readdirSync(join(skillDir, 'references')).filter((f) => f.endsWith('.md'))) {
	const name = basename(file, '.md');
	const { title, description, body } = parseMarkdown(readFileSync(join(skillDir, 'references', file), 'utf8'));
	const order = checklistOrder.indexOf(name);
	write(
		join(checklistOut, file),
		frontmatter({
			title,
			description,
			editUrl: editUrl(`scripter/skills/scripter/references/${file}`),
			sidebar: { order: order === -1 ? 99 : order + 1 },
		}) +
			sourceNote(`scripter/skills/scripter/references/${file}`) +
			body,
	);
}

// 2. Full skill text
{
	const { body } = parseMarkdown(readFileSync(join(skillDir, 'SKILL.md'), 'utf8'));
	write(
		join(site, 'src', 'content', 'docs', 'reference', 'skill-text.md'),
		frontmatter({
			title: 'Full skill text',
			description: 'The exact instructions Claude reads when Scripter turns on.',
			editUrl: editUrl('scripter/skills/scripter/SKILL.md'),
			sidebar: { order: 90 },
		}) +
			`:::note[Generated from the skill]\nThis is [\`scripter/skills/scripter/SKILL.md\`](${repoUrl}/scripter/skills/scripter/SKILL.md), word for word, minus its frontmatter. The four checklists it mentions are under **Checklists** in the sidebar.\n:::\n\n` +
			body,
	);
}

// 3. Eval results: keep only what the site shows.
{
	const src = join(repo, 'scripter', 'evals', 'results', RESULTS_RUN, 'aggregate-result.json');
	const run = JSON.parse(readFileSync(src, 'utf8'));
	// Names of the scored graders that failed in any run of an arm.
	const failed = (runs) => [
		...new Set(runs.flatMap((x) => x.graders.filter((g) => g.scored !== false && !g.passed).map((g) => g.name))),
	];
	const cases = run.cases.map((c) => ({
		name: c.name,
		prompt: c.promptMarkdown.trim(),
		with: { score: c.aggregates.score, passed: c.aggregates.passRate === 1, failed: failed(c.arms.with) },
		without: {
			score: c.aggregates.scoreWithout,
			passed: c.aggregates.passRateWithout === 1,
			failed: failed(c.arms.without),
		},
	}));
	write(
		join(site, 'src', 'data', 'results.json'),
		JSON.stringify(
			{
				run: RESULTS_RUN,
				note: RESULTS_NOTE,
				date: run.startedAt.slice(0, 10),
				model: run.suite.modelOverride,
				runsPerArm: Math.max(...run.cases.map((c) => c.arms.with.length)),
				cases,
				totals: {
					cases: cases.length,
					with: cases.filter((c) => c.with.passed).length,
					without: cases.filter((c) => c.without.passed).length,
				},
			},
			null,
			'\t',
		),
	);
}

// 4. Downloads
{
	const out = join(site, 'public', 'downloads');
	mkdirSync(out, { recursive: true });
	const downloads = [
		[join(repo, 'dist', 'scripter.zip'), 'scripter.zip'],
		[join(repo, 'chatgpt', 'instructions.txt'), 'scripter-gpt-instructions.txt'],
	];
	for (const [from, to] of downloads) {
		if (!existsSync(from)) throw new Error(`missing ${from}: run build.ps1 first`);
		copyFileSync(from, join(out, to));
	}
}

console.log('sync-skill: checklists, skill text, results and downloads updated');
