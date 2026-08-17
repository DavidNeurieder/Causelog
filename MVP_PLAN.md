# Causelog — MVP Plan

**Working name.** "Causelog" is a placeholder: the name collides with a well-known
business philosophy (trademark/searchability risk, per the source spec). Pick a
brandable name before public launch.

Category: **engineering decision memory** — a project memory system. Not
"open-source Jira", not "better Notion", not "cheap DOORS".

Source material: `~/Projects/new_ideas/openjira/specification/` (openticket,
adoption, mvp2–7). This plan is the decisive distillation; where the spec
wavered, the choice is made here.

---

## 1. Product definition

> **Never lose the reason behind your decisions.**

A self-hosted workspace where people who build things capture decisions,
experiments, and lessons, so a project's reasoning survives its creator.

The sharp initial pain it answers:

> "Why is this system built this way?"

→ The answer is a chain of linked decisions and evidence, not a memory.

**Not:** Jira (tickets), Notion/Confluence (documents), DOORS (verification
only), Miro (ideas), Obsidian (personal notes). Those are inspiration.

---

## 2. Wedge & golden path (the 10-minute magic moment)

Single-user first. The MVP is one habit: *record what you learn while
building.*

Golden path:

1. Create project ("Build my robot").
2. Record a **decision** — context / options / chosen / reason.
3. Log an **experiment** — question / hypothesis / result.
4. Capture a **lesson**.
5. See the **timeline + graph**: *"Your project memory: 3 decisions · 1
   experiment · 1 lesson."*

If a user does not feel "this understands what I'm building" in ~10 minutes,
the MVP fails.

---

## 3. MVP scope

### In
| Area | Details |
|---|---|
| Projects | Name, description, purpose |
| Goals | Simple per-project goals |
| Decisions | Title, context, options, chosen, reason, review-after (date) |
| Experiments | Question, hypothesis, action, result, lesson |
| Lessons / Notes | Markdown, free-form |
| Relationships | Links between objects (source → target, typed) — **the differentiator** |
| Timeline | Auto-generated project memory feed |
| History | Version history on decisions/notes |
| Search | SQLite FTS5 across all object types |
| Auth | Single user, argon2 password (deployment-safe) |
| Import | Markdown files (stretch) |

### Out (deferred)
Teams, roles, permissions · supplier portals / cross-company sharing · AI
assistant · canvas/whiteboard · kanban/sprints/story points · Jira/Confluence
import · compliance/traceability matrices · integrations · hosted service.

---

## 4. Data model (SQLite)

Tables (mirroring Forgepost's `migrations/` pattern):

```
users        id, username, password_hash, created_at
projects     id, name, description, purpose, created_at
goals        id, project_id, title, created_at
decisions    id, project_id, title, context, options (json),
             chosen, reason, review_at, created_at, updated_at
experiments  id, project_id, question, hypothesis, action, result,
             lesson, created_at, updated_at
notes        id, project_id, title, body_md, created_at, updated_at
links        source_id, target_id, relation_type  (e.g. decision→experiment)
revisions    id, object_type, object_id, content (json), created_at
events       id, project_id, object_type, object_id, verb, at  (timeline feed)
notes_fts    FTS5 virtual table over notes/decisions/experiments
```

Relationships are the product: every object links to others, and the timeline
turns events into a living history.

---

## 5. Stack — Forgepost pattern

Mirror `~/Projects/my_blog` (Forgepost) nearly line for line:

- Rust workspace, edition 2024, rust-version 1.85
- Axum 0.8, tokio, sqlx + **SQLite** (`libsqlite3-sys` bundled)
- **askama** server-rendered templates + minimal vanilla JS/htmx (no React build)
- argon2 + password-hash auth, session cookies
- rustls-acme TLS for HTTPS; `axum-server`
- Single binary `causelog`
- **AGPL-3.0-only**
- Docker in `deploy/`

Why not the spec's React/Postgres: one binary to self-host, zero new infra,
proven in this portfolio, matches the brand. A heavy SPA graph UI is not needed
to validate the core habit.

---

## 6. Repo layout

```
causelog/
├── Cargo.toml            # workspace
├── crates/
│   ├── model/            # types + SQLx queries
│   ├── content/          # markdown handling
│   ├── search/           # FTS5 search
│   └── server/           # Axum app, askama templates, auth
├── migrations/           # sqlx migrations
├── deploy/               # Docker / docker-compose
├── docs/
├── LICENSE               # AGPL-3.0-only
├── README.md
└── MVP_PLAN.md
```

---

## 7. Milestones (~6 weeks)

| Week | Deliverable |
|---|---|
| 1 | Workspace scaffold, schema, auth, project + decision CRUD |
| 2 | Experiment + lesson + timeline → **golden path live** |
| 3 | Markdown notes + version history |
| 4 | Links/relationships + simple graph view + FTS5 search |
| 5 | Dashboard, polish, Markdown import |
| 6 | Docker, README, seed content, closed alpha (10–15 devs) |

Dogfood: from Wk2, run real work in it (e.g. the Embrig or Causelog build itself).

---

## 8. Validation

Measure **learning, not tickets**.

- North star: **Knowledge Compounding Rate** (new reusable knowledge ÷ active
  users).
- Alpha success at 4 weeks: ~10 devs recording real decisions/experiments
  weekly · ≥50% return · search used to answer "why is this like this".
- Pivot signal: nobody records a second decision → the wedge is wrong; rethink
  the object model or the audience.

---

## 9. Positioning & launch

- One-liner: *"Never lose the reason behind your decisions."*
- Launch: Show HN, r/rust, r/selfhosted, lobste.rs (STRATEGY.md §4
  "Engineering/embedded" row). Build-in-public as content (same pipeline as the
  portfolio).
- Positioning line (later): "Causelog is the memory system for teams that build
  things." Projects show what you do, decisions show why, knowledge shows what
  you learned.

---

## 10. Monetization (deferred)

Per MONETIZATION.md dev/B2B lane: AGPL core stays full + free; paid hosted
service + team tiers ($5–15/user/mo) + enterprise/compliance later. Nothing in
the MVP needs pricing now.

---

## 11. Sequencing

This MVP plan is authored now. **Build starts after the Embrig MVP** (prior
sequencing decision, unchanged). Promotion docs already reference Causelog as a
future bet; it will ride the same dev/B2B audience and channel.
