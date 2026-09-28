// Small helpers shared by the site components.

// Prefixes a site path with the configured base ("/scripter"), so links work on GitHub Pages.
export function url(path: string): string {
	const base = import.meta.env.BASE_URL.replace(/\/$/, '');
	return `${base}/${path.replace(/^\//, '')}`;
}

// "tap-water-washer" -> "Tap water washer"
export function humanize(name: string): string {
	const words = name.replace(/-/g, ' ');
	return words.charAt(0).toUpperCase() + words.slice(1);
}

// Readable names for the eval cases; unknown cases fall back to humanize().
const caseLabels: Record<string, string> = {
	'approved-build': 'Approved phone-stand build',
	'birthday-message': 'Birthday message (not design)',
	'change-recheck': 'Change of plan: PLA drum, twice the size',
	'folding-stool-sketch': 'Folding-stool sketch to 3D',
	'hurry-pressure': '"No questions, I’m in a hurry"',
	'imperial-shelf': 'Imperial 2x4 shelf (small question)',
	'led-tent-battery': 'LED tent light on 4 AA batteries',
	'loft-platform-safety': 'Garage loft safety',
	'magnet-perpetual-motion': 'Magnet perpetual-motion wheel',
	'offline-sync-todo': 'Offline sync to-do app',
	'own-concept-cat': 'Keep the cat off the counter',
	'phone-stand-material': 'Phone-stand material',
	'pushback-tap-water': '"I\'m an engineer" pushback',
	'sound-shelf-review': 'Bookshelf review (sound design)',
	'tap-water-washer': 'Tap-water washing machine',
	'vague-typo-chair': 'Vague, misspelled chair request',
};
export function caseLabel(name: string): string {
	return caseLabels[name] ?? humanize(name);
}

// "2026-09-27" -> "27 Sep 2026"
export function formatDate(iso: string): string {
	const [y, m, d] = iso.split('-').map(Number);
	const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
	return `${d} ${months[m - 1]} ${y}`;
}

// What each grader checks, in words, for "failed: ..." notes.
const graderLabels: Record<string, string> = {
	verdict: 'judged verdict',
	'load-path': 'judged load path',
	message: 'judged message',
	'no-praise': 'praise',
	short: 'length',
	'no-model-code': 'built before checking',
	builds: 'no code',
	'skill-not-fired': 'turned on when it shouldn’t',
};
export function graderLabel(name: string): string {
	return graderLabels[name] ?? name.replace(/-/g, ' ');
}

// "sonnet" -> "Claude Sonnet"
export function modelName(model: string): string {
	return `Claude ${model.charAt(0).toUpperCase()}${model.slice(1)}`;
}
