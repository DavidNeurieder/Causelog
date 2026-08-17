# How to: Run the Demo

## Quick Start

```sh
# Seed the demo database with users, projects, and sample data
cargo run -- seed-demo

# Start the server
cargo run
# → http://127.0.0.1:8080
```

## Demo Credentials

| Username | Password | Role | Status | Notes |
|----------|----------|------|--------|-------|
| `demo` | `demo-password` | admin | approved | Owner of all three projects |
| `alice` | `longenough1` | user | approved | Owner of SQLite project; member of Gloria project |
| `carol` | `longenough1` | user | approved | Member of SQLite and Coffee projects |
| `bob` | `longenough1` | user | **pending** | Registered but not yet approved by admin |

## Demo Projects

### SQLite + Rust API
The Causelog project itself, tracked as a causelog project. Contains the
MVP goal with a checklist of features (some shipped, some pending), a
decision about which datastore to use (SQLite won), and experiments for
FTS5 search and the Axum web layer.

### The Legend of Gloria the Monstera
A plant care project. Gloria is an office monstera that needs to survive
90 days, climb a moss pole, and reach 15 leaves. Contains decisions about
watering schedules and fertilizer, an experiment about repotting, and one
dropped goal (teaching Gloria to clap).

### The Coffee Machine Uprising
An office coffee project. The 11am queue needs eliminating, the bean
budget needs cutting, and someone wanted a second machine in the kitchen
corner (abandoned). Contains a decision about bean-to-cup vs drip
machines, an experiment on batch brew sizes, and a dropped goal about
the second machine.

## Suggested Walkthrough

1. **Login as `demo`** — explore all three projects, click through goals,
   decisions, and experiments. Notice the checkbox checklists in goal
   bodies and the linked decisions/experiments.

2. **Try search** — type a word like "sqlite" or "gloria" in the search
   bar. Notice results are scoped to your projects only.

3. **Check the admin panel** — visit `/admin/users`. You'll see all four
   users. `bob` is pending. Approve or reject him from here.

4. **Logout and login as `bob`** — fails because `bob` is still pending.
   Go back to `demo`, approve `bob`, then login as `bob` succeeds.

5. **Login as `alice`** — notice you can only see the SQLite project
   (you're the owner) and the Gloria project (you're a member). The
   Coffee project is invisible because `alice` isn't a member.

6. **Create your own goal** — go to any project you're a member of,
   create a goal with Markdown checkboxes, link a decision to it.
