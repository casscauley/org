Audit this repo against the latest `~/projects/unrest-server` and `~/projects/unrest-ui`. Produce a written report — do not change any code in this pass.

## Step 1 — find the versions this repo thinks it's on

- **unrest-ui**: `client/package.json` → `localDependencies["@unrest/ui"]` (it's a string label like `"0.5.1 (~/projects/unrest-ui via vite alias)"`, not a real npm dep — the vite alias always points at the working copy, so this label can be stale)
- **unrest-server**: check `client/package.json` `localDependencies["unrest-server"]`, `requirements.txt`/`pyproject.toml` at the repo root if they exist, and `.venv/bin/pip show unrest-server` (editable-install metadata is often stale — note the discrepancy if the venv version disagrees with the pyproject)

## Step 2 — find the actual latest versions

- `~/projects/unrest-ui/package.json` → `version`
- `~/projects/unrest-server/pyproject.toml` → `version`

## Step 3 — read the changelogs

Read `~/projects/unrest-ui/CHANGELOG.md` and `~/projects/unrest-server/CHANGELOG.md`. Both repos write a `## Bleeding edge` section at the top for unreleased work, then versioned sections below it.

Cover everything between the version this repo is pinned to and the tip — **including Bleeding edge** (consuming projects are on HEAD via the vite alias / editable install, so Bleeding edge is live code).

If the repo's pinned version looks suspiciously behind (e.g. it's more than one or two versions back), the project may have skipped previous migrations. In that case:
- Read up to **two versions further back** than the pinned one, in case earlier entries were missed
- If that still looks incomplete or you find evidence of older unmigrated patterns (legacy class names, removed APIs still in use), **stop and ask the user** before reading deeper into history

## Step 4 — produce the audit report

Structure:

### Version status
One line per unrest repo: pinned version → latest version. Flag label-vs-reality mismatches (e.g. stale `pip show` metadata).

### Required migrations (breaking changes)
For each Breaking Change in the covered range, grep this repo for the affected pattern and list concrete call sites. If nothing in this repo uses it, say so — don't pad.

### Worth adopting (new features)
For each New Feature: one sentence on what it does and whether this repo has a place that would benefit. Be specific (file paths, not "could be used somewhere"). If nothing obvious, skip it rather than inventing a use case.

### Fixes picked up for free
One-liners for each Fixed entry — no action needed since consuming via vite alias / editable install, but good to know.

### Open questions
Anything ambiguous that needs the user to decide before implementing.

## Rules

- **Do not modify code in this pass.** The command is an audit, not an upgrade. The user will direct follow-up changes.
- **Use file paths and line numbers** when pointing at call sites, so they can navigate directly.
- **Cross-check the changelog against the code.** If a changelog entry says "removed `foo()`" and `grep foo` returns hits, that's a required migration — don't take the changelog's word for it being "done" just because a version was bumped.

## User Input

$ARGUMENTS
