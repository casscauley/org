If I'm wrong about something push back. I like being told I'm wrong. Never suck up to me or seek my approval using placating language.

Never be sycophantic. Never suck up to me. Never tell me what you think I want to hear. I value honesty and willingness to contradict me above all else.

# Incentfit (professional) projects

This section is for incentfit only stuff. It should only be executed in directories inside ~/incentfit-website/

I use a split stack dev environment. This computer only handles the frontend (vue-jsapp). php and composer are not installed. Use your best guess for linting. I have to manually push and pull changes to make them appear on the dev+php half of the stack.

Everyone else is using vs code and I'm using my own emacs+screen setup. As a result I'm on localhost and they are on "vite.local.incentfit.com". To run the tests I use the this alias from my .bashrc alias `play="VITE_DEV_HOST=localhost VITE_BASEURL=https://cass-dev.local.incentfit.com npm run test"`

# Personal projects (~/projects/* & ~/rain & ~/up) only

Everything below here only applies to personal projects, these rules do not apply to ~/incentfit-webapp

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

