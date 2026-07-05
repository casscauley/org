If I'm wrong about something push back. I like being told I'm wrong. Never suck up to me or seek my approval using placating language.

Never be sycophantic. Never suck up to me. Never tell me what you think I want to hear. I value honesty and willingness to contradict me above all else.

# Local dev servers

I'm on a Chromebook with Crostini (Linux container inside ChromeOS). The key fact: ChromeOS only forwards ports to Crostini for listeners bound to `0.0.0.0`. A `127.0.0.1`-only listener is reachable inside Linux (curl works) but invisible to Chrome on the host — this is what caused the "hit or miss" port behavior I used to see. Port number is irrelevant once the bind is right.

When you need to spin up a local HTTP server for me to open in Chrome:

- **Bind to `0.0.0.0`, not `127.0.0.1`.** Examples:
  - Django: `manage.py runserver 0.0.0.0:<port>`, or set `runserver.default_addr = "0.0.0.0"` in the project's `manage.py` (see `~/projects/maptroid/server/manage.py`, `~/projects/puz/server/manage.py`).
  - Python http.server: bound to `0.0.0.0` by default in 3.x. Don't pass `--bind 127.0.0.1`.
  - Node: `app.listen(port, '0.0.0.0')` or `vite --host 0.0.0.0`.
- Pick a stable, memorable port so I can rely on `<projectname>.localhost:<port>` autocomplete in Chrome (Chrome auto-resolves `*.localhost` to 127.0.0.1, no `/etc/hosts` edit needed). Record the port in the project's CLAUDE.md.
- Open in Chrome via `http://<projectname>.localhost:<port>/` or `http://localhost:<port>/`.

# Incentfit (professional) projects

This section is for incentfit only stuff. It should only be executed in directories inside ~/incentfit-website/

I use a split stack dev environment. This computer only handles the frontend (vue-jsapp). php and composer are not installed. Use your best guess for linting. I have to manually push and pull changes to make them appear on the dev+php half of the stack.

# Personal projects (~/projects/* & ~/rain & ~/up) only

Everything below here only applies to personal projects, these rules do not apply to ~/incentfit-webapp

## Sibling repo CLAUDE.md

Before editing files in or committing to a sibling repo under `~/projects/*` (most commonly `unrest-ui` or `unrest-server`), read that repo's `CLAUDE.md` first if one exists. Sibling `CLAUDE.md` files are **not** auto-loaded by the startup scan when you launch Claude from a different directory, so repo-specific workflow rules (changelog, release, versioning) are otherwise invisible.

## @unrest/ui shared library

`~/projects/unrest-ui/` is a shared Vue component library used by all personal projects. Projects reference it via a vite alias pointing to its dist output. When fixing or modifying components from `@unrest/ui`, edit the source in `~/projects/unrest-ui/src/` and rebuild with `cd ~/projects/unrest-ui && npm run build`. Always make me aware that `@unrest/ui` has been modified and do not commit changes to this directory when I tell you to commit another project. I will worry about committing it's code separately

## Django project conventions

### Structure

- `server/` - Django project
  - `sever/manage.py`
  - `main/` - contains settings and other files typically in the django project root

### Commands

- Use `.venv/bin/python` to run Python (virtualenv at `.venv/`)

### Conventions

- Always use `.venv/bin/python ./server/manage.py makemigrations` to generate Django migrations. Do not write migration files manually.
- Use `requests` for HTTP calls, not `urllib`.
- functional views over class based views
- leverage models

### .html + .vue conventions

- Use self-closing tags for empty HTML elements
- Prefer compact single-line elements when they fit. Don't expand short attribute lists to multiple lines.
- Prefer inline expressions over named constants when the expression is short and used once.
- Don't destructure and reconstruct objects just to pass them through. Minimize data reshaping between layers.
- Push validation to boundaries rather than duplicating it at every layer.
- Use `const fn = () => {}` instead of `function fn() {}`. One-line the body when it's a single statement.
- Use Vue 3.4+ same-name shorthand for bindings: `:key` instead of `:key="key"`.
- Prefer `v-model` with unnamed `defineModel()` over named models (`v-model:foo` / `defineModel('foo')`).
- Extract shared select options into client/src/lib/options.js and reference them by name in templates (:options="mediumOptions") rather than inlining arrays in :options props.
- Use `<FormKit type="number" number .../>` (the `number` prop) to coerce number inputs to Number values instead of strings.

## JS conventions

## CSS conventions

- css stored in client/src/css/* is prefered to invidivual style tags inside vue components
- Prefer ABEM with tailwind's @apply to using the utility classes directly. Utility classes can be used sparingly
- Separation should typically be done using flex gap instead of margins whereever possible

