# Kaizen

> Never lose the reason behind your decisions.

A self-hosted engineering decision memory: capture decisions, experiments, and
lessons so a project's reasoning survives its creator.

**Status:** MVP planned (`MVP_PLAN.md`), build starts after the Embrig MVP.
**License:** AGPL-3.0-only.

## What it is

Projects, decisions, experiments, lessons, and notes — linked into a timeline
and graph that answers "why is this system built this way?"

## Build

```bash
cargo build --release      # single binary: target/release/kaizen
cargo run -- migrate       # apply schema (SQLite)
cargo test                 # tests
```

Requires Rust 1.85+. No external services; one binary, SQLite on disk.

## Deploy

See `deploy/` (Docker + docker-compose). TLS via automatic HTTPS (rustls-acme);
serve behind Caddy if preferred.

## Docs

- `MVP_PLAN.md` — product definition, scope, data model, milestones, validation.
- `docs/` — user + admin documentation (planned).
