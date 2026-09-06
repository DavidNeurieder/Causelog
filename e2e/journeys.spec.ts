import { expect, test, type Browser } from '@playwright/test';

// ── Causelog UX journeys (Phase 20 of ideas/ux_plan2.txt) ─────────────────────
//
// The five critical journeys, tested as a fresh user who records a project the
// way a real creator would. Self-contained: creates its own account and state,
// so it can run alongside app.spec.ts against the same backend.
//
//   A — First project   create project → create goal → see story
//   B — Decision        capture → Decision → save → appears in story
//   C — Experiment      decision → start experiment → complete → create lesson
//   D — Understanding   open project → current state → causal chain → evidence
//   E — Sharing         project → Share → One-pager → preview → export
//
// Runs serially: later journeys lean on entities recorded by earlier ones.

const J_USER = 'journey';
const J_DISPLAY = 'Journey Tester';
const J_PASS = 'journey-pass-123';

// The setup admin created by app.spec.ts (test 1). Only needed when this suite
// runs after it against the same backend: a signup is pending approval then.
const ADMIN = 'dev';
const ADMIN_PASS = 'longenough1';

const PROJECT = 'Field guide to the Dolomites';
const GOAL = 'Ski every valley high route';
const DECISION = 'Which ski wax should we standardize on?';
const EXPERIMENT = 'Test eco wax on north faces for a season';
const OBSERVATION = 'First storm cycle: eco wax holds climbs well.';
const RESULT = 'Eco wax matched race wax on cold, dry snow.';
const LESSON = 'Eco wax wins in powder; keep race wax for races.';

let projectUrl = '';
let experimentUrl = '';

const AUTH_FILE = '.auth-journeys.json';

async function adminPage(browser: Browser) {
	const context = await browser.newContext({ storageState: AUTH_FILE });
	return context.newPage();
}

test.describe('five critical journeys', () => {
	test.describe.configure({ mode: 'serial' });

	test('A — a first project: create a project, add a goal, then see the story', async ({ page }) => {
		await page.goto('/register');
		await page.locator('#username').fill(J_USER);
		await page.locator('#display').fill(J_DISPLAY);
		await page.locator('#password').fill(J_PASS);
		await page.locator('#confirm').fill(J_PASS);
		await page.getByRole('button', { name: /Register|Create account/ }).click();
		// The first-ever account (or the setup account on a fresh database)
		// lands straight on the dashboard. When the setup admin already exists
		// the new signup is pending approval, so approve it as that admin.
		if (page.url().includes('/login')) {
			await expect(page).toHaveURL(/\/login\?flash=registered/);
			await page.locator('#username').fill(ADMIN);
			await page.locator('#password').fill(ADMIN_PASS);
			await page.getByRole('button', { name: 'Log in' }).click();
			await expect(page).toHaveURL(/\/dashboard$/);
			await page.goto('/admin/users');
			const pending = page.locator('.admin-card--pending', { hasText: J_DISPLAY });
			await expect(pending).toBeVisible();
			await pending.getByRole('button', { name: 'Approve' }).click();
			await expect(page).toHaveURL(/\/admin\/users\?flash=approved/);
			await page.getByRole('button', { name: 'Log out' }).click();
			await page.locator('#username').fill(J_USER);
			await page.locator('#password').fill(J_PASS);
			await page.getByRole('button', { name: 'Log in' }).click();
		}
		await expect(page).toHaveURL(/\/dashboard$/);
		await page.context().storageState({ path: AUTH_FILE });

		// Create the project through the disclosure form on the dashboard.
		const create = page.locator('details.create-project');
		await create.locator('summary').click();
		await create.locator('#p-title').fill(PROJECT);
		await create.getByRole('button', { name: 'Create project' }).click();
		await expect(page).toHaveURL(/\/projects\/[0-9a-f-]+$/);
		await expect(page.locator('h1')).toHaveText(PROJECT);
		projectUrl = page.url();

		// An empty project points at the very next step: a goal.
		await expect(page.getByText('How your story grows')).toBeVisible();

		// Add the goal.
		await page.goto(`${projectUrl}/goals`);
		await page.getByRole('link', { name: 'New goal' }).click();
		await page.locator('#gnew-title').fill(GOAL);
		await page.locator('#gnew-body').fill('Catch every high route while the snow holds.');
		await page.getByRole('button', { name: 'Add goal' }).click();
		await expect(page.locator('section.list .row.item', { hasText: GOAL })).toBeVisible();

		// The story page lists the goal under "Everything else".
		await page.goto(projectUrl);
		await page.locator('details summary', { hasText: 'Everything else' }).click();
		await expect(page.getByText(GOAL)).toBeVisible();
	});

	test('B — capture a decision and watch it appear in the story', async ({ browser }) => {
		const page = await adminPage(browser);

		await page.goto('/capture');
		await page.locator('#capture-text').fill(
			'We keep reaching for the wrong wax box. Decide one standard.'
		);
		await page.getByRole('button', { name: 'Capture' }).click();

		// The classify screen routes the capture into a decision.
		await expect(page).toHaveURL(/\/capture\/[0-9a-f-]+/);
		await page.getByRole('link', { name: 'A decision' }).click();
		await expect(page).toHaveURL(/\/projects\/[0-9a-f-]+\/decisions\/new/);
		await expect(page.locator('#dnew-title')).toHaveValue(
			'We keep reaching for the wrong wax box. Decide one standard.'
		);

		await page.locator('#dnew-title').fill(DECISION);
		await page.locator('#dnew-context').fill('Climbs and descents run all day; wax must last the route.');
		await page.locator('#dnew-goal').selectOption({ label: GOAL });
		await page.locator('#dnew-o1').fill('Eco wax');
		await page.locator('#dnew-o1p').fill('Cheap, no toxic fumes.');
		await page.locator('#dnew-o1c').fill('Untested on spring slush.');
		await page.locator('#dnew-o2').fill('Race wax');
		await page.locator('#dnew-o2p').fill('Familiar, fast where tested.');
		await page.locator('#dnew-o2c').fill('Cost and fumes.');
		await page.getByRole('button', { name: 'Create decision' }).click();
		await expect(page).toHaveURL(/\/decisions\/[0-9a-f-]+\?flash=decision_created/);

		// It now anchors the story chain.
		await page.goto(projectUrl);
		await expect(page.locator('.chain-decision-node .chain-title', { hasText: DECISION })).toBeVisible();
		await expect(page.locator('.chain-decision-node .story-mark')).toHaveText('Decision');
	});

	test('C — start an experiment from the decision, complete it, and create a lesson', async ({ browser }) => {
		const page = await adminPage(browser);

		// The experiment is linked to the decision straight from its form.
		await page.goto(`${projectUrl}/experiments`);
		await page.getByRole('link', { name: 'New experiment' }).first().click();
		await page.locator('#enew-title').fill(EXPERIMENT);
		await page.locator('#enew-hypothesis').fill('Eco wax holds climbs and keeps descents fast without fumes.');
		await page.locator('#enew-goal').selectOption({ label: GOAL });
		await page.locator('#enew-decision').selectOption({ label: DECISION });
		await page.getByRole('button', { name: 'Start experiment' }).click();
		await expect(page.locator('section.list .row.item', { hasText: EXPERIMENT })).toBeVisible();
		experimentUrl = (await page.getByRole('link', { name: EXPERIMENT }).getAttribute('href'))!;

		// Log an observation.
		await page.goto(experimentUrl);
		await page.locator('#ev-note').fill(OBSERVATION);
		await page.getByRole('button', { name: 'Log observation' }).click();
		await expect(page.getByText(OBSERVATION)).toBeVisible();

		// Finish it: status done + result + lesson.
		await page.locator('#action-dropdown summary').click();
		await page.locator('[data-action="edit-all"]').click();
		await page.locator('.editable[data-field="status"] select').selectOption('done');
		await page.locator('.editable[data-field="result"] textarea').fill(RESULT);
		await page.locator('.editable[data-field="lesson"] textarea').fill(LESSON);
		await page.locator('.editable[data-field="status"] .editable-save').click();
		await page.locator('.editable[data-field="result"] .editable-save').click();
		await page.locator('.editable[data-field="lesson"] .editable-save').click();
		await expect(page.getByRole('heading', { name: 'Lesson' })).toBeVisible();

		// Capture the lesson as a note, as the real flow does.
		await page.getByRole('button', { name: 'Capture lesson as note' }).click();
		await expect(page).toHaveURL(/\/notes\/[0-9a-f-]+/);

		// The chain grows: decision → experiment → evidence, plus the lesson list.
		await page.goto(projectUrl);
		await expect(page.locator('.chain-experiment-node .chain-title', { hasText: EXPERIMENT })).toBeVisible();
		await expect(page.locator('.chain-evidence-node')).toBeVisible();
		await expect(page.locator('.chain-evidence-node .list plain, .chain-evidence-node li', { hasText: OBSERVATION }).first()).toBeVisible();
		await expect(page.locator('.section-panel', { hasText: 'Lessons' }).getByText(LESSON)).toBeVisible();
	});

	test('D — understand the current state, the causal chain, and the evidence', async ({ browser }) => {
		const page = await adminPage(browser);

		// Settle the decision so the story's "current belief" is meaningful.
		await page.goto(projectUrl);
		const decisionHref = await page
			.locator('.chain-decision-node .chain-title', { hasText: DECISION })
			.getAttribute('href');
		await page.goto(decisionHref!);
		await page.locator('#rstatus').selectOption('decided');
		await page.locator('#roption').selectOption({ label: 'Eco wax' });
		await page.locator('#rrat').fill('Field-season data backed eco wax for everyday touring.');
		await page.getByRole('button', { name: 'Record' }).click();
		await expect(page.getByText(/We chose Eco wax/i)).toBeVisible();

		// Current state: the decision now names the project's current belief.
		await page.goto(projectUrl);
		await expect(page.locator('.state-chips', { hasText: '1 validated' })).toBeVisible();
		await expect(page.locator('h2', { hasText: 'Current belief' })).toBeVisible();
		await expect(
			page.locator('.section-panel', { hasText: 'Current belief' }).getByRole('link', { name: DECISION })
		).toBeVisible();

		// Causal chain: click a chain node to open the side drawer.
		await page.locator('.chain-decision-node', { hasText: DECISION }).click();
		const drawer = page.locator('#story-drawer.side-drawer.open');
		await expect(drawer).toBeVisible();
		await expect(drawer.getByText('State')).toBeVisible();
		await drawer.getByRole('link', { name: 'View full record' }).click();
		await expect(page.locator('main h1').first()).toHaveText(DECISION);

		// Evidence: the chain node lists the observation and looks it up.
		await page.goto(projectUrl);
		await page.locator('.chain-evidence-node').click();
		const evidenceDrawer = page.locator('#story-drawer.side-drawer.open');
		await expect(evidenceDrawer).toBeVisible();
		await expect(evidenceDrawer.getByText(OBSERVATION)).toBeVisible();
		await evidenceDrawer.getByRole('link', { name: 'View full record' }).click();
		await expect(page.locator('main h1').first()).toHaveText(EXPERIMENT);
	});

	test('E — share it: one-pager preview and exports', async ({ browser }) => {
		const page = await adminPage(browser);
		await page.goto(projectUrl);

		// Shared via the Share hero.
		await page.getByRole('link', { name: 'Share' }).first().click();
		await expect(page).toHaveURL(/\/projects\/[0-9a-f-]+\/export$/);

		// One-pager preview renders the story.
		await page.locator('.share-card', { hasText: 'One-pager' }).click();
		await expect(page).toHaveURL(/\/projects\/[0-9a-f-]+\/one-pager$/);
		await expect(page.locator('.one-pager-head h2')).toHaveText(PROJECT);
		await expect(page.getByText(DECISION).first()).toBeVisible();
		await expect(page.getByText(LESSON).first()).toBeVisible();

		// Download the static exports.
		const htmlDownload = page.waitForEvent('download');
		await page.getByRole('link', { name: 'Download HTML' }).click();
		expect((await htmlDownload).suggestedFilename()).toMatch(/\.html$/);

		const pngDownload = page.waitForEvent('download');
		await page.getByRole('link', { name: 'Download SVG' }).click();
		expect((await pngDownload).suggestedFilename()).toMatch(/\.svg$/);
	});
});