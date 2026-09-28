# Scripter website

The docs and landing page for Scripter, built with [Astro Starlight](https://starlight.astro.build/).
Live at https://michaelcodetolimit.github.io/scripter/.

```bash
npm install
npm run dev      # http://localhost:4321/scripter/
npm run build    # static site in dist/
```

Needs Node.js 22.12 or newer.

- Pages are Markdown/MDX in `src/content/docs/`; the sidebar is set in `astro.config.mjs`.
- Landing page components are in `src/components/`; theme colors and fonts in `src/styles/theme.css`.
- `scripts/sync-skill.mjs` runs before every `dev` and `build`. It copies the checklists, the full skill text,
  the test results and the downloads from `../scripter`, `../dist` and `../chatgpt`. Those copies are gitignored:
  edit the originals.
- Pushing to `main` deploys the site through `../.github/workflows/deploy-site.yml`.
