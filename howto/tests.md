# How to: Run Tests

Causelog has three test layers: Rust unit tests, API integration tests, and
Playwright browser E2E tests. All run against a real server with a throwaway
SQLite database.

## Quick Start

```sh
# Run everything (unit + API + e2e + content)
cargo test

# Run only Rust tests (no browser)
cargo test --lib --tests -- --exclude 'e2e::*'

# Run only Playwright browser tests
cd e2e && npm install && npm run test:e2e
```

## Rust Tests

```sh
cargo test
```

Runs all test binaries in the workspace:

| Crate | Binary | What it tests |
|-------|--------|---------------|
| `causelog-server` | unit (9) | Template rendering, markdown, auth helpers |
| `causelog-server` | API (65) | All HTTP endpoints — setup, auth, CRUD, search, admin, JSON API |
| `causelog-server` | e2e (4) | Full server lifecycle via `reqwest` — setup, create, search, inline edit via JSON API |
| `causelog-content` | content (9) | Markdown rendering, content parsing |

### Running a subset

```sh
# Only API tests
cargo test --test api

# Only a specific test by name
cargo test api_goal_update_fields

# With output (show println! and eprintln!)
cargo test -- --nocapture
```

## Playwright E2E Tests

True browser tests against the real `causelog` server. They click buttons,
fill forms, run page JS (password toggles, inline editing via editable.js),
and verify rendered HTML.

### Setup

```sh
cd e2e
npm install
npx playwright install chromium   # first time only
```

### Running

```sh
npm run test:e2e
# or
npx playwright test
```

### With a prebuilt binary (faster, skips recompilation)

```sh
cargo build --bin causelog
CAUSELOG_BIN=../target/debug/causelog npm run test:e2e
```

### What happens under the hood

1. `playwright.config.ts` picks an ephemeral port and writes it to
   `/tmp/causelog-e2e-port.json`
2. `start-backend.mjs` spawns `causelog serve` on that port with a fresh
   SQLite database in `/tmp/causelog-e2e-*/e2e.db`
3. Playwright waits for `GET /health` to return 200
4. Tests run serially (shared state between tests)
5. Server and database are discarded when tests finish

### Test flow (10 tests)

| # | Test | What it does |
|---|------|--------------|
| 1 | first-run setup | Creates owner via `/setup`, tests password mismatch error, password toggle, saves session |
| 2 | create project | Opens `<details>` disclosure, fills title + summary, verifies redirect |
| 3 | create goal + decision + experiment | Creates all three with proper links, captures URLs |
| 4 | inline edit goal | Enters edit mode via dropdown, edits title + body, verifies dropdown toggles View↔Edit |
| 5 | inline edit project | Edits summary inline, verifies dropdown toggle |
| 6 | resolve decision | Fills resolve form, verifies resolution text |
| 7 | experiment observations | Logs observation, edits status/result/lesson, captures lesson as note |
| 8 | timeline + graph | Verifies observation on timeline, nodes on graph |
| 9 | search | Searches "dilithium", verifies decision appears with highlight |
| 10 | logout + login | Tests logout flash, wrong password error, correct login |

### Debugging failures

```sh
# Show the browser UI (headed mode)
npx playwright test --headed

# Run with full debug logging
DEBUG=pw:api npx playwright test

# Open the Playwright trace viewer for failed tests
npx playwright show-trace test-results/*/trace.zip

# Check the screenshot saved on failure
ls test-results/*/
```

### Configuration

| Setting | Value | File |
|---------|-------|------|
| Browser | Chromium (Desktop Chrome) | `playwright.config.ts` |
| Timeout | 90s per test, 10s per assertion | `playwright.config.ts` |
| Workers | 1 (serial execution) | `playwright.config.ts` |
| Port | Ephemeral, allocated at config load | `playwright.config.ts` |
| Database | Throwaway SQLite in `/tmp` | `start-backend.mjs` |

## CI

In CI, `reuseExistingServer` is disabled so every test run starts a fresh
server. Locally, the config reuses an already-running server if available.

```sh
# Typical CI sequence
cargo build --release --bin causelog
CAUSELOG_BIN=./target/release/causelog cd e2e && npm run test:e2e
```
