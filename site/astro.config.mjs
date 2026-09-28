// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

const repo = 'https://github.com/MichaelCodeToLimit/scripter';

// https://astro.build/config
export default defineConfig({
	site: 'https://michaelcodetolimit.github.io',
	base: '/scripter',
	integrations: [
		starlight({
			title: 'Scripter',
			description:
				'A skill for Claude and ChatGPT that checks how a thing works, and whether your design is possible, buildable and the best approach, before it builds anything.',
			logo: { src: './src/assets/logo.svg' },
			favicon: '/favicon.svg',
			social: [{ icon: 'github', label: 'GitHub', href: repo }],
			editLink: { baseUrl: `${repo}/edit/main/site/` },
			customCss: [
				'@fontsource-variable/ibm-plex-sans',
				'@fontsource/ibm-plex-mono/400.css',
				'@fontsource/ibm-plex-mono/600.css',
				'./src/styles/theme.css',
			],
			components: {
				Hero: './src/components/Hero.astro',
			},
			sidebar: [
				{
					label: 'Start here',
					items: [
						{ label: 'Install', slug: 'start/install' },
						{ label: 'Quick start', slug: 'start/quick-start' },
					],
				},
				{
					label: 'Guides',
					items: [
						{ label: 'Using Scripter', slug: 'guides/using-scripter' },
						{ label: 'Reading the report', slug: 'guides/reading-the-report' },
						{ label: 'When you disagree', slug: 'guides/pushing-back' },
						{ label: 'No praise in every chat', slug: 'guides/always-on' },
					],
				},
				{
					label: 'Reference',
					items: [
						{ label: 'The method', slug: 'reference/method' },
						{
							label: 'Checklists',
							collapsed: false,
							items: [{ autogenerate: { directory: 'reference/checklists' } }],
						},
						{ label: 'Test results', slug: 'reference/test-results' },
						{ label: 'Customize and rebuild', slug: 'reference/customize' },
						{ label: 'Limits and safety', slug: 'reference/limits' },
						{ label: 'Full skill text', slug: 'reference/skill-text' },
					],
				},
			],
		}),
	],
});
