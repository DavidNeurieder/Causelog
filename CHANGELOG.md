# Changelog

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

- 103 Rust tests (unit, API integration, e2e)
- 10 Playwright browser E2E tests (Chromium)
