# How to: Deploy Causelog

## Prerequisites

- **Rust 1.85+** (for building from source), or **Docker** (for containers)
- **SQLite** — embedded, no separate database server needed

## Option A: Build and Run Directly

```sh
# Build the release binary
cargo build --release --bin causelog

# Run with defaults (SQLite file, localhost:8080)
./target/release/causelog serve
# → http://127.0.0.1:8080
```

### First-time setup
Visit `/setup` to create the admin account. Or seed the demo:

```sh
./target/release/causelog seed-demo
./target/release/causelog serve
```

## Option B: Docker Compose

```sh
docker compose -f deploy/docker-compose.yml up -d --build
docker compose -f deploy/docker-compose.yml run --rm causelog seed-demo
# → http://localhost:8080
```

Data lives in `./data/causelog.db` on the host.

## TLS / HTTPS

### Let's Encrypt (recommended for public servers)

```sh
causelog serve \
  --addr 0.0.0.0:8443 \
  --tls-domain causelog.example.com
```

Certificates are obtained automatically and renewed. The HTTP→HTTPS
redirect runs on port 80 by default.

### Bring your own certificate

```sh
causelog serve \
  --addr 0.0.0.0:8443 \
  --tls-cert /path/to/fullchain.pem \
  --tls-key /path/to/privkey.pem
```

### Reverse proxy (Caddy, nginx, Traefik)

Run Causelog on localhost without TLS and let the proxy handle
termination:

```sh
causelog serve --addr 127.0.0.1:8080
```

Then configure your reverse proxy to forward to `127.0.0.1:8080`.

## Environment Variables

| Variable | Flag | Default | Description |
|----------|------|---------|-------------|
| `DATABASE_URL` | `--database-url` | `sqlite://causelog.db` | Database path or `sqlite::memory:` |
| `CAUSELOG_ADDR` | `--addr` | `127.0.0.1:8080` | Bind address |
| `CAUSELOG_TLS_DOMAIN` | `--tls-domain` | — | Let's Encrypt domain |
| `CAUSELOG_TLS_CERT` | `--tls-cert` | — | TLS certificate file |
| `CAUSELOG_TLS_KEY` | `--tls-key` | — | TLS private key file |
| `CAUSELOG_TLS_CACHE_DIR` | `--tls-cache-dir` | `./tls` | ACME cache directory |
| `CAUSELOG_HTTP_REDIRECT_PORT` | `--http-redirect-port` | `80` | HTTP redirect port |

## Backups

SQLite is a single file. Use the included backup script:

```sh
./deploy/backup.sh data/causelog.db data/backups 14
# Retention: 14 daily copies
```

The script uses `sqlite3 .backup` (safe against a live writer) when
available and falls back to a plain copy.

### Schedule with cron

```
0 3 * * * /srv/causelog/deploy/backup.sh /srv/causelog/data/causelog.db /srv/causelog/data/backups 14
```

### Restore

Stop the server, replace the database file, start again:

```sh
# Docker
docker compose -f deploy/docker-compose.yml stop
cp data/backups/causelog-2026-08-15.db data/causelog.db
docker compose -f deploy/docker-compose.yml start

# Direct binary
# Stop the causelog process, then:
cp /srv/causelog/data/backups/causelog-2026-08-15.db /srv/causelog/data/causelog.db
./target/release/causelog serve
```

## Windows

The binary builds and runs on Windows. You need:

- **MSVC** (Visual Studio Build Tools) or **MinGW** for compiling SQLite
- Adjust paths: `--database-url "sqlite://C:\data\causelog.db"`
- The backup script is bash — write a PowerShell equivalent or use
  `sqlite3` directly
- Docker containers are Linux-only (no Windows container support)

## Platform Support

| Platform | Binary | Docker | Notes |
|----------|--------|--------|-------|
| Linux (x86_64) | Yes | Yes | Primary target |
| Linux (ARM64) | Yes | Yes | Builds natively or via cross-compilation |
| macOS | Yes | Yes | Docker Desktop works; native binary preferred |
| Windows | Yes | No | Needs MSVC/MinGW; scripts need adaptation |
