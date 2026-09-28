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
	'folding-stool-sketch': 'Folding-stool sketch to 3D',
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
