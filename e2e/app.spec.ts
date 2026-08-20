import { expect, test, type Browser } from '@playwright/test';

// ── Causelog Playwright E2E Suite ───────────────────────────────────────────
//
// True browser tests against the real `causelog` server. They click buttons,
// fill forms, run page JS (password toggles, <details> disclosure, inline
// editing via editable.js), and verify rendered HTML — things the reqwest-
// driven tests in tests/api.rs cannot exercise.
//
// Architecture
// ────────────
// playwright.config.ts starts a real `causelog serve` on an ephemeral port
// (via start-backend.mjs) with a throwaway SQLite database in /tmp. The
// webServer config waits for /health before running tests.
//
// start-backend.mjs runs `cargo run --bin causelog -- serve --database-url
// sqlite:///tmp/.../e2e.db --addr 127.0.0.1:<port>`. Set CAUSELOG_BIN to a
// prebuilt binary path to skip recompilation.
//
// Port allocation: config picks a free port via net.createServer, writes it
// to /tmp/causelog-e2e-port.json (stale after 10 min), and all workers
// reuse it so the baseURL matches the running server.
//
// Session sharing: test 1 saves storageState to .auth.json. Tests 2-10
// create fresh browser contexts loaded from .auth.json via adminPage().
// Each test closes its context at the end.
//
// Serial execution: tests run in order (test.describe.configure({ mode:
// 'serial' })) because later tests depend on shared state created by
// earlier ones (project URL, goal URL, etc.).
//
// Test flow (10 tests)
// ─────────────────────
//  1. first-run setup        — creates owner account via /setup, tests
//                              password mismatch error and toggle, saves
//                              session to .auth.json
//  2. create project         — opens <details> disclosure, fills title +
//                              summary, verifies redirect to /projects/{id}
//  3. create goal + decision + experiment — creates all three entities
//                              with proper links (goal→decision→experiment),
//                              captures URLs for later tests
//  4. inline edit goal       — enters edit mode via View→Edit in place
//                              dropdown, edits title + body via JSON API,
//                              verifies dropdown toggles View↔Edit, exits
//                              via dropdown View link
//  5. inline edit project    — edits summary via inline editing, verifies
//                              dropdown toggle and exit
//  6. resolve decision       — fills resolve form (status, option,
//                              rationale), verifies resolution text
//  7. experiment observations — logs observation, enters edit mode to set
//                              status/done/result/lesson, saves each field
//                              via JSON API, captures lesson as note
//  8. timeline + graph       — verifies observation text on timeline,
//                              decision + experiment nodes on graph
//  9. search                 — searches for "dilithium", verifies
//                              decision appears with highlighted match
// 10. logout + login         — tests logout flash, wrong password error
//                              keeps username, correct login lands on
//                              dashboard
//
// Key selectors
// ──────────────
//  #action-dropdown          — View/Edit toggle dropdown on detail pages
//  #action-dropdown summary  — label text: "View" or "Edit"
//  [data-action="edit-all"]  — "Edit in place" link (enters edit mode)
//  [data-action="cancel-all"] — "View" link or "Done editing" button
//  #done-editing-bar         — floating bar shown during edit mode
//  .editable[data-field=X]   — inline-editable container for field X
//  .editable-display         — read-only display (hidden during edit)
//  .editable-edit            — edit form (shown during edit)
//  .editable-save            — per-field save button (triggers JSON API)
//  .editable-cancel          — per-field cancel button
//
// Running
// ───────
//   cd e2e && npm run test:e2e
//   # or with prebuilt binary:
//   CAUSELOG_BIN=../target/debug/causelog npm run test:e2e

const AUTH_FILE = '.auth.json';
const USERNAME = 'dev';
const DISPLAY = 'Dev';
const PASSWORD = 'longenough1';
const GOAL = 'Reduce time-to-recall of past decisions';
const DECISION = 'Which datastore should Causelog use?';
const EXPERIMENT = 'Try SQLite with WAL for six weeks';
const LESSON = 'Dilithium crystals are out; SQLite with WAL is fine.';

let projectUrl = '';
let goalUrl = '';
let decisionUrl = '';
let experimentUrl = '';
let noteUrl = '';

async function adminPage(browser: Browser) {
	const context = await browser.newContext({ storageState: AUTH_FILE });
	return context.newPage();
}

async function gotoDashboard(page: import('@playwright/test').Page) {
	await page.goto('/dashboard');
	await expect(page.locator(".who")).toHaveText(DISPLAY);
}

// Guard: the password-visibility toggle actually flips the input type, and the
// aria state follows. Works on both /setup and /login (same markup).
async function expectToggleWorks(page: import('@playwright/test').Page, target: string) {
	const toggle = page.locator(`.toggle-pw[data-target="${target}"]`);
	const field = page.locator(`#${target}`);
	await toggle.click();
	await expect(field).toHaveAttribute('type', 'text');
	await expect(toggle).toHaveAttribute('aria-pressed', 'true');
	await toggle.click();
	await expect(field).toHaveAttribute('type', 'password');
	await expect(toggle).toHaveAttribute('aria-pressed', 'false');
}

test.describe('full creator journey', () => {
	test.describe.configure({ mode: 'serial' });

	test('first-run setup keeps the username on error, then creates the owner', async ({ page }) => {
		await page.goto('/setup');

		await page.locator('#username').fill(USERNAME);
		await page.locator('#display').fill(DISPLAY);
		await page.locator('#password').fill(PASSWORD);
		await page.locator('#confirm').fill('a-different-confirm');

		// The toggles work on the pristine form (they only flip the input type,
		// so the filled values survive).
		await expectToggleWorks(page, 'password');
		await expectToggleWorks(page, 'confirm');

		// Deliberate failure: mismatched confirm -> the server re-renders with the
		// typed values kept, passwords masked and empty.
		await page.getByRole('button', { name: 'Create account' }).click();
		await expect(page.getByText('Passwords do not match.')).toBeVisible();
		await expect(page.locator('#username')).toHaveValue(USERNAME);
		await expect(page.locator('#display')).toHaveValue(DISPLAY);
		await expect(page.locator('#password')).toHaveValue('');

		// The server never echoes passwords, so re-fill both before completing.
		await page.locator('#password').fill(PASSWORD);
		await page.locator('#confirm').fill(PASSWORD);
		await page.getByRole('button', { name: 'Create account' }).click();
		await expect(page).toHaveURL(/\/dashboard$/);
		await expect(page.locator(".who")).toHaveText(DISPLAY);

		await page.context().storageState({ path: AUTH_FILE });
	});

	test('dashboard creates a project through the real form', async ({ browser }) => {
		const page = await adminPage(browser);
		await gotoDashboard(page);

		// The create form lives in a <details> disclosure; the summary is the
		// "New project" button. This is the regression that broke the UI: the
		// button used to submit a hidden empty title, so no project could ever
		// be created (and the page claimed "A title is required.").
		const create = page.locator('details.create-project');
		await create.locator('summary').click();
		const title = create.locator('#p-title');
		await expect(title).toBeVisible();

		await title.fill('SQLite + Rust API');
		await create.locator('#p-summary').fill('Storage for the golden path.');
		await create.getByRole('button', { name: 'Create project' }).click();

		await expect(page).toHaveURL(/\/projects\/[0-9a-f-]+$/);
		await expect(page.locator('h1')).toHaveText('SQLite + Rust API');
		projectUrl = page.url();
		await page.context().close();
	});

	test('a goal, a linked decision, and a linked experiment can be recorded', async ({ browser }) => {
		const page = await adminPage(browser);

		// Goals are listed first; the create form lives on a dedicated page.
		await page.goto(`${projectUrl}/goals`);
		await page.getByRole('link', { name: 'New goal' }).click();
		await expect(page).toHaveURL(`${projectUrl}/goals/new`);
		await page.locator('#gnew-title').fill(GOAL);
		await page.locator('#gnew-body').fill('Search must find decisions by what is at stake.');
		await page.getByRole('button', { name: 'Add goal' }).click();
		await expect(page.locator('section.list .row.item', { hasText: GOAL })).toBeVisible();
		goalUrl = (await page.getByRole('link', { name: GOAL }).getAttribute('href'))!;

		// Decision with two options, tied to the goal.
		await page.goto(`${projectUrl}/decisions`);
		await page.getByRole('link', { name: 'New decision' }).click();
		await expect(page).toHaveURL(`${projectUrl}/decisions/new`);
		await page.locator('#dnew-title').fill(DECISION);
		await page.locator('#dnew-context').fill('The API needs persistence. Dilithium crystals are out.');
		await page.locator('#dnew-goal').selectOption({ label: GOAL });
		await page.locator('#dnew-o1').fill('SQLite');
		await page.locator('#dnew-o1p').fill('One file, zero operations.');
		await page.locator('#dnew-o1c').fill('Single writer only.');
		await page.locator('#dnew-o2').fill('Postgres');
		await page.locator('#dnew-o2p').fill('Battle-tested, concurrent.');
		await page.locator('#dnew-o2c').fill('A server to run.');
		await page.getByRole('button', { name: 'Create decision' }).click();
		await expect(page.locator('section.list .row.item', { hasText: DECISION })).toBeVisible();
		decisionUrl = (await page.getByRole('link', { name: DECISION }).getAttribute('href'))!;

		// Experiment that tests the decision and serves the goal.
		await page.goto(`${projectUrl}/experiments`);
		await page.getByRole('link', { name: 'New experiment' }).click();
		await expect(page).toHaveURL(`${projectUrl}/experiments/new`);
		await page.locator('#enew-title').fill(EXPERIMENT);
		await page.locator('#enew-hypothesis').fill('WAL keeps reads and writes fast enough without a server.');
		await page.locator('#enew-goal').selectOption({ label: GOAL });
		await page.locator('#enew-decision').selectOption({ label: DECISION });
		await page.getByRole('button', { name: 'Start experiment' }).click();
		await expect(page.locator('section.list .row.item', { hasText: EXPERIMENT })).toBeVisible();
		experimentUrl = (await page.getByRole('link', { name: EXPERIMENT }).getAttribute('href'))!;
		await page.context().close();
	});

	test('inline edit the goal title and body', async ({ browser }) => {
		const page = await adminPage(browser);
		await page.goto(goalUrl);

		// The page starts in view mode — no editable should be active.
		await expect(page.locator('.editable.active')).toHaveCount(0);

		// Open the "View" dropdown and click "Edit in place".
		await page.locator('#action-dropdown summary').click();
		await page.locator('[data-action="edit-all"]').click();
		await expect(page.locator('#done-editing-bar.active')).toBeVisible();

		// Dropdown now says "Edit".
		await expect(page.locator('#action-dropdown summary')).toHaveText('Edit');

		// Change the title.
		const titleInput = page.locator('.editable[data-field="title"] input');
		await titleInput.clear();
		await titleInput.fill('Faster recall of past decisions');
		await page.locator('.editable[data-field="title"] .editable-save').click();
		await expect(page.locator('h1')).toHaveText('Faster recall of past decisions');

		// Change the body.
		const bodyTextarea = page.locator('.editable[data-field="body"] textarea');
		await bodyTextarea.clear();
		await bodyTextarea.fill('Decisions must be searchable by what is at stake.');
		await page.locator('.editable[data-field="body"] .editable-save').click();
		await expect(page.locator('.editable[data-field="body"] .editable-display .prose')).toHaveText('Decisions must be searchable by what is at stake.');

		// Exit edit mode via the "View" link inside the "Edit" dropdown.
		await page.locator('#action-dropdown summary').click();
		await page.locator('#action-dropdown [data-action="cancel-all"]').click();
		await expect(page.locator('#done-editing-bar.active')).toHaveCount(0);
		await expect(page.locator('.editable.active')).toHaveCount(0);

		// Dropdown reverts to "View".
		await expect(page.locator('#action-dropdown summary')).toHaveText('View');
		await page.context().close();
	});

	test('inline edit the project summary', async ({ browser }) => {
		const page = await adminPage(browser);
		await page.goto(projectUrl);

		// Open "View" → "Edit in place".
		await page.locator('#action-dropdown summary').click();
		await page.locator('[data-action="edit-all"]').click();
		await expect(page.locator('#done-editing-bar.active')).toBeVisible();
		await expect(page.locator('#action-dropdown summary')).toHaveText('Edit');

		// Change the summary.
		const summaryInput = page.locator('.editable[data-field="summary"] input');
		await summaryInput.clear();
		await summaryInput.fill('Storage layer for the decision journal.');
		await page.locator('.editable[data-field="summary"] .editable-save').click();
		await expect(page.locator('.editable[data-field="summary"] .editable-display')).toHaveText('Storage layer for the decision journal.');

		// Exit via the "View" link in the "Edit" dropdown.
		await page.locator('#action-dropdown summary').click();
		await page.locator('#action-dropdown [data-action="cancel-all"]').click();
		await expect(page.locator('#done-editing-bar.active')).toHaveCount(0);
		await expect(page.locator('#action-dropdown summary')).toHaveText('View');
		await page.context().close();
	});

	test('the decision can be resolved with a choice and rationale', async ({ browser }) => {
		const page = await adminPage(browser);
		await page.goto(decisionUrl);

		await expect(page.getByText('Resolve this decision')).toBeVisible();
		await page.locator('#rstatus').selectOption('decided');
		await page.locator('#roption').selectOption({ label: 'SQLite' });
		await page.locator('#rrat').fill('One file, no ops, and plenty of headroom for a single user.');
		await page.getByRole('button', { name: 'Record' }).click();

		await expect(page.getByText(/Chose SQLite on /)).toBeVisible();
		await expect(page.getByRole('heading', { name: 'Decision' })).toBeVisible();
		await page.context().close();
	});

	test('the experiment logs observations and captures a lesson note', async ({ browser }) => {
		const page = await adminPage(browser);
		await page.goto(experimentUrl);

		await page.locator('#ev-note').fill('First week: WAL keeps writes under a millisecond.');
		await page.getByRole('button', { name: 'Log observation' }).click();
		await expect(page.getByText('First week: WAL keeps writes under a millisecond.')).toBeVisible();

		// Finish it: status done + result + lesson, then capture the lesson.
		// Open the "View" dropdown and click "Edit in place" to activate all fields.
		await page.locator('#action-dropdown summary').click();
		await page.locator('[data-action="edit-all"]').click();
		await expect(page.locator('#done-editing-bar.active')).toBeVisible();
		await expect(page.locator('#action-dropdown summary')).toHaveText('Edit');

		await page.locator('.editable[data-field="status"] select').selectOption('done');
		await page.locator('.editable[data-field="result"] textarea').fill('WAL met the latency target throughout.');
		await page.locator('.editable[data-field="lesson"] textarea').fill(LESSON);

		await page.locator('.editable[data-field="result"] .editable-save').click();
		await page.locator('.editable[data-field="lesson"] .editable-save').click();
		await page.locator('.editable[data-field="status"] .editable-save').click();

		await expect(page.getByRole('heading', { name: 'Lesson' })).toBeVisible();
		await expect(page.getByText(LESSON)).toBeVisible();

		await page.getByRole('button', { name: 'Capture lesson as note' }).click();
		await expect(page).toHaveURL(/\/notes\/[0-9a-f-]+/);
		await expect(page.locator('main h1').first()).toHaveText(`Lesson: ${EXPERIMENT}`);
		noteUrl = page.url();
		await page.context().close();
	});

	test('timeline and graph reflect the experiment and the links', async ({ browser }) => {
		const page = await adminPage(browser);

		await page.goto(`${projectUrl}/timeline`);
		await expect(page.getByRole('heading', { name: 'Timeline' })).toBeVisible();
		await expect(page.getByText('First week: WAL keeps writes under a millisecond.')).toBeVisible();

		await page.goto(`${projectUrl}/graph`);
		await expect(page.locator('a.strong', { hasText: DECISION }).first()).toBeVisible();
		await expect(page.locator('a.strong', { hasText: EXPERIMENT }).first()).toBeVisible();
		await expect(page.getByText(/— tests →/)).toBeVisible();
		await page.context().close();
	});

	test('search finds the decision by a word in its context', async ({ browser }) => {
		const page = await adminPage(browser);
		await gotoDashboard(page);
		await page.getByLabel('Search').fill('dilithium');
		await page.getByLabel('Search').press('Enter');

		await expect(page).toHaveURL(/\/search\?q=dilithium/);
		await expect(page.getByRole('link', { name: DECISION })).toBeVisible();
		await expect(page.locator('mark').first()).toHaveText('Dilithium');
		await page.getByRole('link', { name: DECISION }).click();
		await expect(page.locator('main h1').first()).toHaveText(DECISION);
		await page.context().close();
	});

	test('logout and login keep the username on a bad password', async ({ browser }) => {
		const page = await adminPage(browser);
		await gotoDashboard(page);

		await page.getByRole('button', { name: 'Log out' }).click();
		await expect(page).toHaveURL(/\/login/);
		await expect(page.getByText('You have been logged out.')).toBeVisible();

		// Wrong password: the failure keeps the username and the toggle works.
		await page.locator('#username').fill(USERNAME);
		await page.locator('#password').fill('wrongpassword');
		await expectToggleWorks(page, 'password');
		await page.getByRole('button', { name: 'Log in' }).click();
		await expect(page.getByText('invalid username or password')).toBeVisible();
		await expect(page.locator('#username')).toHaveValue(USERNAME);
		await expect(page.locator('#password')).not.toHaveValue('wrongpassword');

		// Correct login lands on the dashboard with everything intact.
		await page.locator('#password').fill(PASSWORD);
		await page.getByRole('button', { name: 'Log in' }).click();
		await expect(page).toHaveURL(/\/dashboard$/);
		await expect(page.locator(".who")).toHaveText(DISPLAY);
		await page.context().close();
	});
});
