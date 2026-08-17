# Kaizen

Self-hosted engineering decision memory. A place to record the trade-offs you
weigh, the experiments that test them, and the lessons you'd otherwise
re-learn the hard way.

Kaizen is a single Rust binary with an embedded SQLite database — no external
services, one machine, one backup to care about.

## What it does

The golden path is: **goal → decision → experiment → lesson → timeline & graph**.

- **Projects & goals** — what "done" looks like, per project.
- **Decisions** — the options you weighed (pros/cons), the choice you made,
  and the rationale. Every change is kept as an immutable revision.
- **Experiments** — a falsifiable hypothesis, a lifecycle
  (planned → running → done/abandoned), and timestamped observations. When
  you finish, capture the lesson as a note.
- **Notes** — durable knowledge, extracted from experiments or written
  directly, with the same revision history.
- **Timeline** — the story of a project: when things started, ended, and what
  you measured along the way.
- **Graph** — how entities connect: what serves a goal, what an experiment
  tests, where a note came from, plus explicit typed links
  (`supports`/`rejects`/`follows`/`related`).
- **Search** — full-text over every entity, kept in sync automatically.

## Quickstart (local)

```sh
cargo run -- serve
# → http://127.0.0.1:8080/setup — create the admin account
```

After setup, register additional users at `/register`. New accounts require
admin approval before they can log in.

Or skip the setup dance with a seeded demo — three projects (two of them
unapologetically funny), with goals, decisions, experiments, notes, links,
and a searchable history:

```sh
cargo run -- seed-demo
# demo / demo-password — admin, owns all three projects
# alice / longenough1  — approved member (Gloria project)
# bob / longenough1    — registered, pending admin approval
```

## Run it

```
Usage: kaizen [COMMAND]

Commands:
  serve       Start the Kaizen server (default)
  seed-demo   Create a first user and a three-project demo, then exit
```

`serve` flags (all also settable via env):

| Flag | Env | Default | Meaning |
| --- | --- | --- | --- |
| `--database-url` | `DATABASE_URL` | `sqlite://kaizen.db` | DB file or `sqlite::memory:` |
| `--addr` | `KAIZEN_ADDR` | `127.0.0.1:8080` | Bind address |
| `--tls-domain` | `KAIZEN_TLS_DOMAIN` | — | Automatic HTTPS via Let's Encrypt |
| `--tls-cert` / `--tls-key` | `KAIZEN_TLS_CERT/KEY` | — | Bring your own cert |
| `--tls-cache-dir` | `KAIZEN_TLS_CACHE_DIR` | `./tls` | ACME cache |
| `--no-http-redirect` | — | off | Skip the 80→443 redirect |

The Let's Encrypt path is the easiest production setup behind a public IP:

```sh
DATABASE_URL=sqlite:///srv/kaizen/kaizen.db \
KAIZEN_ADDR=0.0.0.0:8443 \
KAIZEN_TLS_DOMAIN=kaizen.example.com \
kaizen serve
```

Certificates are renewed automatically and hot-reloaded. Behind a reverse
proxy (Caddy, nginx, Traefik), run plain HTTP on the loopback and let the
proxy terminate TLS.

## Deploy with Docker

```sh
docker compose -f deploy/docker-compose.yml up -d --build
docker compose -f deploy/docker-compose.yml run --rm kaizen seed-demo
# → http://localhost:8080
# demo / demo-password (admin), alice / longenough1 (member), bob / longenough1 (pending)
```

Data lives in `./data/kaizen.db` on the host.

## Backups

SQLite is a single file — back it up consistently with the included script:

```sh
./deploy/backup.sh data/kaizen.db data/backups 14   # retention: 14 daily copies
```

The script uses `sqlite3 .backup` (safe against a live writer) when available
and falls back to a plain copy. Schedule it with cron:

```
0 3 * * * /srv/kaizen/deploy/backup.sh /srv/kaizen/data/kaizen.db /srv/kaizen/data/backups 14
```

### Restore

Stop the container, replace the database file, start it again:

```sh
docker compose -f deploy/docker-compose.yml stop
cp data/backups/kaizen-2026-08-15.db data/kaizen.db
docker compose -f deploy/docker-compose.yml start
```

## Design notes

- **Multi-user with admin approval.** Kaizen starts un-set-up: the first
  account created at `/setup` becomes the admin. Additional users register at
  `/register` and wait for admin approval. Projects can have members (owner
  and member roles); non-members cannot see a project's contents.
- **Immutable history.** Decisions and notes append a Markdown snapshot to a
  `revisions` table on every change, so the record of *what you decided and
  why* can't be silently rewritten.
- **Everything is searchable** through an FTS5 index kept in sync by database
  triggers, including content written before the index existed.
- **AGPL-3.0-only.** This is a tool for thinking out loud about engineering;
  it ships under the same copyleft as the reference implementation it mirrors.

## Testing

Three layers, run with a single `cargo test --workspace`:

- **Unit** — pure functions in the `content` crate (markdown sanitising,
  date parsing) and server helpers (options/link parsing, snippet
  highlighting, password hashing, cookie/CSRF behaviour, registration
  validation).
- **Integration** (`crates/server/tests/api.rs`) — the full HTTP surface
  against an in-memory SQLite database, from setup to search, including
  multi-user flows (registration, admin approval, project membership,
  role-based access control).
- **E2E** (`crates/server/tests/e2e.rs`) — boots the real `kaizen` binary on
  a free port with a temporary database, drives the golden path over HTTP
  with a cookie jar, then restarts the process to prove data survives, plus
  `seed-demo` and CLI smoke tests.
- **Browser E2E** (`e2e/`) — the same journey through a real Chromium via
  Playwright: it clicks the actual buttons, runs the page's JavaScript (the
  password toggles, the `<details>` forms), and shares one owner session.
  This catches UI regressions the HTTP layer can't see. Requires Node and
  Playwright's Chromium:

  ```sh
  cd e2e
  npm ci
  npx playwright install chromium
  npm run test:e2e
  ```

  Set `KAIZEN_BIN=../target/debug/kaizen` to reuse a built binary instead of
  letting the harness run `cargo run`. CI does this in a dedicated job.

`cargo fmt --all --check` and `cargo clippy --workspace --all-targets -- -D warnings`
must stay clean; GitHub Actions enforces all of it on every push and PR.

## License

AGPL-3.0-only. See [LICENSE](LICENSE) for details.
