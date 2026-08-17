// Spawns the real `causelog serve` process for the Playwright E2E suite.
// Playwright's `webServer` waits for /health, so each run gets a fresh server
// against a throwaway SQLite database. Prefer a prebuilt binary via
// `CAUSELOG_BIN` (e.g. `../target/debug/causelog`) and fall back to `cargo run` so
// `npm run test:e2e` works locally with no extra build step.

import { spawn } from 'node:child_process';
import { mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';

const repoRoot = fileURLToPath(new URL('../', import.meta.url));
const port = process.env.CAUSELOG_PORT ?? '18080';
const dir = mkdtempSync(join(tmpdir(), 'causelog-e2e-'));
const db = join(dir, 'e2e.db');

const serveArgs = ['serve', '--database-url', `sqlite://${db}`, '--addr', `127.0.0.1:${port}`];

const bin = process.env.CAUSELOG_BIN;
const cmd = bin ?? 'cargo';
const args = bin
	? serveArgs
	: ['run', '--quiet', '--manifest-path', join(repoRoot, 'Cargo.toml'), '--bin', 'causelog', '--', ...serveArgs];

const child = spawn(cmd, args, { stdio: 'inherit' });

const shutdown = () => child.kill();
process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
process.on('exit', shutdown);
child.on('exit', (code) => process.exit(code ?? 0));
