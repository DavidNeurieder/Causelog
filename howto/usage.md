# How to: Use Causelog

## First Run

```sh
cargo run -- serve
# → http://127.0.0.1:8080/setup
```

The first account you create at `/setup` becomes the **admin**. This
account cannot be deleted and is the only one who can approve new users.

## Users

### Registering
Visit `/register` to create a new account. The account enters a
**pending** state until an admin approves it at `/admin/users`.

### Roles
- **admin** — full access. Can approve/reject users, promote/demote,
  manage project memberships, delete users. Only one admin minimum is
  enforced.
- **user** — can create and edit content in projects they are members of.

## Projects

Create a project from the dashboard. You become its **owner**.

### Membership
- **owner** — full control over the project. Can add/remove members.
- **member** — can create and edit goals, decisions, and experiments.

Non-members cannot see the project at all. Search results are scoped to
your project memberships.

Manage members from the project page via the "Members" link.

## Goals

A goal is something you want to achieve. Create one from a project page.

- **Status**: `open` → `done` or `dropped`
- **Assignment**: assign to any project member, or leave unassigned
- **Body**: Markdown with checkbox checklists (`- [ ]` / `- [x]`)
- **Links**: a goal can be linked to decisions (how to achieve it) and
  experiments (what you tried)

Edit a goal from its detail page via the collapsible "Edit goal" form.

## Decisions

A decision records what you chose and why. Create one from a project page
or directly from a goal page.

- **Status**: `open` → `decided` or `rejected`
- **Options**: up to 4 options, each with pros and cons
- **Chosen option**: pick one when you decide, with a rationale
- **Links**: a decision can serve a goal (help achieve it) and be tested
  by an experiment

### Revisions
Every edit to a decision appends a snapshot to the revisions table. The
history of what you decided and why is immutable.

## Experiments

An experiment tests whether an approach works. Create one from a project
page or from a linked decision/goal.

- **Status**: `planned` → `running` → `done` or `abandoned`
- **Observations**: append notes as the experiment progresses
- **Lessons**: capture what you learned when the experiment concludes

## Search

Use the search bar in the header. Results include goals, decisions,
experiments, and observations across all projects you're a member of.
Admins see results from all projects.

Full-text search is powered by SQLite FTS5 and updates automatically.

## Admin Panel

Visit `/admin/users` (admin only) to:

- Approve or reject pending users
- Promote or demote user roles
- Add or remove users from projects
- Delete users

## Keyboard Shortcuts

- `/` — focus the search bar
- `Escape` — blur the search bar
