---
name: @unrest/ui migration from legacy packages
description: Ongoing migration of all personal projects from 7 old @unrest/* npm packages to consolidated @unrest/ui. Tracks what's been decided for the shared library.
type: project
---

Migrating personal projects from `@unrest/css`, `@unrest/vue`, `@unrest/vue-auth`, `@unrest/vue-form`, `@unrest/vue-mousetrap`, `@unrest/vue-storage`, `@unrest/tailwind` → single `@unrest/ui` package.

**Why:** Old packages were fragmented, used outdated patterns (Options API mixins, global plugins, JS-generated CSS classes). New package uses Vue 3 composables, headlessui, tanstack, FormKit.

**How to apply:** When working in any personal project that imports `@unrest/*`, refer to ~/projects/unrest-ui/docs/legacy.md for the migration map. New features should use @unrest/ui APIs. hive.js is the first migration target.

Key decisions:
- Dark mode: `prefers-color-scheme` media query + `data-theme` attribute override (not CSS class)
- Z-index: CSS custom properties scale in @unrest/ui, apps add local layers
- Forms: FormKit via UnrestSchemaForm wrapper, drop old `.form-group`/`.form-control`
- Auth: composables only (useUser, useLogin, etc.), no global $auth plugin, no OAuth in shared lib
- Alerts: always use store.alert() / UnrestDialog, no inline .alert CSS classes
- Icons: font-awesome classes directly, no css.icon() wrapper
- CSS vars: `--color-*` naming convention (not `--bg`/`--text`)
