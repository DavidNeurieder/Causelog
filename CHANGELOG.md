# Changelog

## 0.2.0 — 2026-09-07

### Export

- **Canonical export format.** `causelog export <project>` produces a
  versioned snapshot (`causelog-export` v1) of any project — project, goals,
  decisions with resolved status, experiments with raw events, notes, an
  immutable revision history, and typed links.
- **Five output formats** derived on demand from the snapshot, with the export
  page at `/projects/{id}/export` (and `/projects/{id}/export.{format}`):
  - **JSON** — the reference format for backups and future import.
  - **Markdown** — a Git-friendly directory tree, one file per entity.
  - **HTML** — an offline-ready static site.
  - **Archive** — JSON + Markdown + HTML in one deterministic ZIP with a
    manifest.
  - **ODP** — an Impress/LibreOffice- (and PowerPoint-) compatible slideshow
    built from the project story: title, goal, and one slide per decision,
    experiment, and lesson, plus a timeline.
- Downloads are member-only and streamed as attachments; everything is
  regenerated per request, so it is always current.
- New `crates/export` crate holds the format model and pure renderers, keeping
  the export format stable as the database evolves.

### Story configuration

- **Single source of truth for the story.** The project page, Markdown, HTML,
  ODP, one-pager, and CLI all consume the same configured `ProjectStory`, so a
  saved story configuration renders identically in every format.
- **Story editor** shows/hides and reorders sections, decisions, experiments,
  and lessons; sets a custom problem statement; and records a current-state
  summary. Hiding a decision hides its experiments.
- **Export correctness & performance.** A decision's chosen option is matched
  by its ID (not its label), the parent/child relationship is enforced, and
  collection is done with bulk project-level queries behind a single
  consistent database snapshot instead of per-entity N+1 queries.
- **Hardened export boundary.** Archive and presentation builders return
  `Result` instead of panicking; failures surface to the HTTP/CLI layer.

### Packaging

- Prebuilt **Linux x86_64** binary is published with each release to GitHub
  Releases, so you can download and run Causelog without installing Rust.

## 0.1.0 — 2026-08-20

First public release of Causelog: self-hosted engineering decision memory.

### Core features

- **Projects** — create, manage, and archive projects with owner/member roles
- **Goals** — track objectives with status (`open`/`ongoing`/`done`/`dropped`), Markdown body with checkbox checklists, and assignment to project members
- **Decisions** — record what you chose and why, with up to 4 options (pros/cons), immutable revision history, and one-click resolve
- **Experiments** — test hypotheses with `planned` → `ongoing` → `done`/`abandoned` lifecycle, timestamped observations, and captured lessons
- **Notes** — durable knowledge with Markdown rendering and revision history
- **Links** — connect goals → decisions → experiments → notes with typed relationships

### Multi-user

- Admin approval flow: self-registration with pending → approved/rejected states
- Owner/member project roles with role-based access control
- Admin panel at `/admin/users` for user and membership management

### UI

- Kanban board with drag-and-drop status changes
- Inline editing on all detail pages (goal, decision, experiment, note, project) via JSON API
- View/Edit dropdown toggle on detail pages
- Full-text search scoped to user's accessible projects (admin sees all)
- Timeline and graph views for entity relationships

### Infrastructure

- Single Rust binary with embedded SQLite database
- TLS via Let's Encrypt (automatic) or bring-your-own certificate
- Docker Compose deployment with persistent data volume
- Automatic backup script with configurable retention

### Testing

- 130 Rust tests (unit, API integration, e2e, export renderers)
- 10 Playwright browser E2E tests (Chromium)
