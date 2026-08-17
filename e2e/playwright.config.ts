import { defineConfig, devices } from '@playwright/test';
import { spawnSync } from 'node:child_process';
import { mkdirSync, readFileSync, statSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';

// Playwright's config must export a plain object, so port allocation has to be
// synchronous. Bind an ephemeral socket in a child process and print its port.
function freePort(): number {
	const script = `
		const n = require('node:net');
		const s = n.createServer();
		s.on('error', () => process.exit(2));
		s.listen(0, '127.0.0.1', () => {
			const p = s.address().port;
			s.close(() => process.stdout.write(String(p)));
		});
		setTimeout(() => process.exit(3), 2000);
	`;
	const result = spawnSync(process.execPath, ['-e', script], { encoding: 'utf8' });
	const port = Number(result.stdout);
	if (!port) throw new Error(`freePort failed: ${result.stderr}`);
	return port;
}

const lockFile = join(tmpdir(), 'causelog-e2e-port.json');

// The whole app is served by one `causelog` process on a single port. Playwright
// loads this config once to start the webServer and again in each worker
// process; allocate once and reuse so the baseURL matches the running server.
function reservePort(): number {
	try {
		const file = readFileSync(lockFile, 'utf8');
		const stale = Date.now() - statSync(lockFile).mtimeMs > 10 * 60_000;
		if (!stale) return JSON.parse(file) as number;
	} catch {
		// no lock file yet — first load
	}
	const port = freePort();
	mkdirSync(dirname(lockFile), { recursive: true });
	writeFileSync(lockFile, JSON.stringify(port));
	return port;
}

const port = reservePort();

export default defineConfig({
	testDir: '.',
	fullyParallel: false,
	workers: 1,
	timeout: 90_000,
	expect: { timeout: 10_000 },
	reporter: [['list']],
	use: {
		baseURL: `http://127.0.0.1:${port}`,
		trace: 'on-first-retry',
		screenshot: 'only-on-failure'
	},
	webServer: {
		command: 'node start-backend.mjs',
		url: `http://127.0.0.1:${port}/health`,
		reuseExistingServer: !process.env.CI,
		env: { CAUSELOG_PORT: String(port) }
	},
	projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }]
});
