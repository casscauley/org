# Projects audit — served sites, ownership, and supervision

Working document. Survey done 2026-07-25. Check items off as they land.

Goal: know exactly what this box serves, archive what is dead, run everything as
`clepsy`, and replace the screen/tmux supervision with systemd units that log to
`<project_root>/logs/uwsgi.log`.

---

## 1. Everything currently served

13 hostnames across 10 nginx configs in `/etc/nginx/sites-enabled/`.

| Hostname | Status | Backend | Runs as | Repo | Supervision |
| --- | --- | --- | --- | --- | --- |
| `weather.unrest.io` | 200 | uwsgi `:8080` + `client/dist` | clepsy | `~/projects/weather` | screen `weather` → tmux 5:0 |
| `wpr.unrest.io` | **TLS fail** | same block as weather | clepsy | `~/projects/weather` | — |
| `tempo.unrest.io` | 200 | uwsgi `:8435` + `client/dist` | clepsy | `~/projects/tempo` | screen `tempo` → tmux 4:0 |
| `jerbs.unrest.io` | 302 | uwsgi unix socket | clepsy | `~/projects/job-app` | screen `jerbs` → tmux 1:0 |
| `portfolio.unrest.io` | 200 | static only (`client/dist`) | — | `~/projects/portfolio` | none needed |
| `cdn.unrest.io` | 200 | static alias (357M) | — | `~/cdn` | none needed |
| `maptroid.unrest.io` | 200 | uwsgi `:8943` | **django** | `/home/django/projects/maptroid` | screen `maptroid` → `su django` |
| `barcamp.unrest.io` | 200 | uwsgi `:8909` | **django** | `/home/django/projects/bc-sched` | screen `barcamp` → `sudo su django` ×2 |
| `bop-recorder.unrest.io` | 302 | uwsgi unix socket | **django** | `/home/django/projects/stream-recorder` | screen `stream-recorder` → tmux |
| `txrx.unrest.io` | 200 | uwsgi `:3033` | **django** | `/home/django/projects/txrx.org` | **systemd** ✅ |
| `hive.unrest.io` | **502** | proxy `:8239` — nothing listening | — | `/home/django/projects/hive.js` | dead since 2026-03 |
| `bc-sched.unrest.io` | **502** | *not this box* | — | — | see §2.1 |
| `schedule.barcampphilly.org` | **502** | *not this box* | — | — | see §2.1 |

Projects under `~/projects` with **no** nginx site (not served, not in scope
unless you want them gone): `@unrest`, `_maptroid-sink`, `dd`, `dwiki`,
`journals`, `my_book`, `unrest-cv`, `unrest-server`, `unrest-ui`, `maptroid`
(a second, clepsy-owned checkout distinct from the django-owned one that is
actually served).

---

## 2. Findings

### 2.1 Two hostnames are answered by a different server

`bc-sched.unrest.io` and `schedule.barcampphilly.org` resolve to
**64.225.25.49**, not this box (138.197.29.247). Proof — the `Server:` header
differs, and this box runs 1.24.0:

```
barcamp.unrest.io   -> HTTP/1.1 200  Server: nginx/1.24.0   (this box)
bc-sched.unrest.io  -> HTTP/1.1 502  Server: nginx/1.14.0   (64.225.25.49)
```

So `*.unrest.io` is **not** uniformly pointed here — `bc-sched` has its own A
record aimed at an older droplet that is still running and currently broken.

**Update 2026-07-25: the old droplet was snapshotted and deleted.** Both
hostnames still have A records pointing at 64.225.25.49, so they went from 502
to `000` — hard down, nothing answers at all.

```
bc-sched.unrest.io          -> 64.225.25.49  (deleted)  000
schedule.barcampphilly.org  -> 64.225.25.49  (deleted)  000
barcamp.unrest.io           -> 138.197.29.247           200
```

All three names front the *same* app, which is alive here as `barcamp`. So this
is now purely a DNS decision — nothing needs building.

To revive them, per hostname:

- `bc-sched.unrest.io` — repoint DNS here and it works immediately. Its server
  block already exists in `bc-sched/config/nginx.conf` **and this box already
  holds its certificate** (nginx loads that block today without complaint, which
  it could not do if the cert were missing).
- `schedule.barcampphilly.org` — repoint DNS, but its block is `listen 80;`
  only with no cert, so it would serve plain http until `certbot` is run for it.
  This is an external domain, not `*.unrest.io`, so its DNS lives elsewhere.

- [x] Fate of 64.225.25.49 — snapshotted and deleted
- [ ] **Decide**: repoint both hostnames here, or retire them and delete the
      blocks. Currently they are dead either way.

### 2.2 `wpr.unrest.io` has no certificate

It is listed in weather's `server_name` alongside `weather.unrest.io`, but the
certbot cert is `CN=weather.unrest.io` only, so TLS fails before HTTP happens.
Either add it to the cert or drop it from `server_name`.

- [ ] Fix or remove `wpr.unrest.io`

### 2.3 `hive.unrest.io` is down — being revived, not archived

nginx proxies to `:8239`; nothing listens. Last commit 2026-03-26.

**Decision 2026-07-25: keep.** It's wanted as a portfolio piece and a separate
Claude session will bring it back, so it is deliberately left completely
untouched — nginx symlink, stale `hive` screen session, and tree all in place.

State for whoever picks it up:

- Owned by **`clepsy`**, despite living in `/home/django/projects/` — no chown
  needed, but it should move to `~/projects/hive.js` during Phase B.
- Branch `master`, tracking `origin/master`, **nothing unpushed**, no stashes.
  Remote `github.com/chriscauley/hive.js` is reachable.
- Uncommitted: `server/nginx.conf` (+18/−5) and an untracked `yarn.lock`.
- No sqlite db, no `.env`, no `local_settings.py`.
- 615M, of which 410M is `client/` (node_modules).
- Per its README it needs python3 + postgres + redis/docker, and the
  multiplayer server binds `:8239` — which is what nginx already expects.

- [x] Decided: keep and revive (separate session)

### 2.4 Supervision is a nested mess

**9 screen sessions** wrapping **3 separate tmux servers**, with `su django` /
`sudo su django` chains inside several. Nothing except txrx survives a reboot,
and nothing restarts on crash.

```
screen maptroid  → bash → su django → bash → uwsgi
screen barcamp   → bash → sudo su django → sudo su django → su django → bash → uwsgi
screen tempo     → tmux 4 → window 0 → uwsgi
screen weather   → tmux 5 → window 0 → uwsgi
```

Stale screens with nothing useful inside: `hive` (2026-03), `book`, and the
long-dead uwsgi under `barcamp`.

This is the core problem systemd solves, and it also dissolves the user question
— `User=` becomes one line rather than a login-account decision.

### 2.5 Disk

Root is at 90% (8.1G free). Largest served projects:

| Path | Size |
| --- | --- |
| `/home/django/projects/maptroid` | **33G** |
| `/home/django/projects/stream-recorder` | **8.1G** |
| `~/projects/tempo` | 3.1G |
| `/home/django/projects/hive.js` | 615M |
| `~/cdn` | 357M |

maptroid's 30G of media is already tracked as a DO Spaces candidate in
`portfolio/docs/backlog/standardize-project-layout.md`.

> **Corrected 2026-08-30: it is one now** — `~/projects/portfolio/.git` dates from
> 2026-08-12 and tracks `git@github.com:casscauley/portfolio.unrest.io.git`. The
> finding below is superseded.

### 2.6 `portfolio` is not a git repository

`~/projects/portfolio` has no `.git`, yet it serves `portfolio.unrest.io` and
holds the backlog doc that tracks this very work. It is unversioned and
unbacked-up.

- [ ] `git init` portfolio and push it somewhere

---

## 3. Decisions needed before migration

Nothing below gets touched until these are answered.

| Site | Decision | Decided |
| --- | --- | --- |
| `hive.unrest.io` | **Keep** — portfolio piece, separate session reviving it | ☑ 07-25 |
| `wpr.unrest.io` | **Dropped** from `server_name` | ☑ 07-25 |
| `barcamp.unrest.io` | Keep — live and healthy here | ☑ 07-25 |
| `bc-sched.unrest.io` | Repoint DNS here, or retire? Cert already on this box | ☐ |
| `schedule.barcampphilly.org` | Repoint DNS + certbot, or retire? External domain | ☐ |
| `bop-recorder` | Keep? Untouched since 2026-06-10 | ☐ |
| `maptroid` | Keep, but 33G needs the Spaces migration | ☐ |
| `txrx.org` | Keep — already systemd, the model to copy | ☐ |
| `cdn.unrest.io` | Keep — static, no process | ☐ |

Archiving follows the pattern used for `arms` on 2026-07-25: push all commits,
`VACUUM INTO` any sqlite db and copy it plus `local_settings.py`/`.env` to
`~/backups/`, verify row counts match, then delete the tree.

---

## 4. Plan

### Phase A — clear the dead ends ✅ (except one DNS decision)
- [x] `hive.js` — **not** archived; kept as a portfolio piece, left untouched
      for a separate session (§2.3)
- [x] `wpr.unrest.io` dropped from weather's `server_name` (commit `0f2d3a1`)
      — **needs an nginx reload to take effect**
- [ ] `bc-sched.unrest.io` / `schedule.barcampphilly.org` — repoint DNS here or
      retire; blocked on your call, not on any work here (§2.1)

### Phase B — consolidate ownership to `clepsy` ✅ 2026-07-25

Done, including full relocation. `/home/django/projects` is empty; all 15 trees
now live under `~/projects`, owned and run by `clepsy`. Eight sites live under
systemd — hive.unrest.io came back too, after being down since 2026-03.

**Four things bit during the cutover, all the same underlying mistake:** I kept
enumerating *the things being changed* rather than *everywhere the old process
had written*.

1. **`logs/` created as clepsy** in django-owned repos — three services couldn't
   write to their own log directory. Caught before the cutover.
2. **`chown -R` scoped by top-level owner.** txrx.org and hive.js were
   clepsy-owned *directories* that the django process had written into for
   months — 103 and 14,626 files. txrx crash-looped 108 times unable to reopen
   `logs/uwsgi.log`, then self-healed once the file cleared. That recovery is
   `Restart=on-failure` earning its keep; pre-systemd it would have stayed dead.
3. **`_maptroid-sink` never moved**, so it wasn't on any list — but maptroid had
   been writing into it as django via a symlink. 72,784 files. Fixed by
   switching from a hardcoded list to `find -user django` over the whole tree.
4. **venv `bin/` shebangs.** The path rewrite covered `*.ini *.conf *.service
   *.py *.pth` — not console scripts. 84 broken across four venvs, plus hive's
   editable-install finder. Services never noticed because uwsgi is a compiled
   ELF with no shebang; it would have surfaced later as an inexplicable failure
   the first time someone ran a management command.

**Also required, and easy to miss:**

- Four `sites-enabled` entries were symlinks *into* the moved repos. Left
  dangling, nginx refuses to **start** at boot — all sites down, not just those.
- django's crontab ran stream-recorder's `start_scheduled` every minute.
  Stranded, it fails silently: the site serves, recordings just stop.
- **Socket group was load-bearing by accident.** `chmod-socket = 660` with no
  `chown-socket` inherited the process user. As `django` that worked because
  `www-data` is in the django group; as `clepsy` it 502'd. Now named explicitly.
- Postgres peer auth: `maptroid` and `txrx` connect with no `USER`, so they
  authenticate as the OS user. Needed `REASSIGN OWNED` + `ALTER DATABASE OWNER`.
  Two *other* databases (`hive`, `txrx_align`) still held django-owned objects —
  harmless at runtime, but the next `migrate` altering a table would have failed.

### Phase B — original plan (kept for reference)
Four projects currently run as `django`: maptroid, bc-sched, stream-recorder,
txrx.org.

- [ ] `chown -R clepsy:clepsy` each moved tree (metadata-only; fast even for 33G)
- [ ] Move `/home/django/projects/<x>` → `~/projects/<x>` (or leave in place and
      only change the running user — decide per project)
- [ ] Update `uid`/`chown-socket` lines in each `uwsgi.ini`
- [ ] Update nginx `alias`/`root`/socket paths that reference `/home/django`
- [ ] Recreate each venv if any embed absolute paths
- [ ] Drop the `safe.directory` entries and the `django` group workaround once
      nothing is co-owned

Note: the security argument for a separate `django` account is already void —
`clepsy` is in the `django` group and the trees are group-writable. Real
isolation should come from systemd hardening (§C), not a second login account.

### Phase C — systemd units
One unit per app at `/etc/systemd/system/<app>.service`, `User=clepsy`.

```ini
[Unit]
Description=<app> uwsgi
After=network.target postgresql.service

[Service]
Type=notify
User=clepsy
Group=clepsy
WorkingDirectory=/home/clepsy/projects/<app>
ExecStart=/home/clepsy/projects/<app>/.venv/bin/uwsgi --ini uwsgi.ini
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=5s
KillSignal=SIGQUIT          ; uwsgi's clean-shutdown signal, not SIGTERM
NotifyAccess=all

; hardening — better isolation than the django account ever gave
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=full
ProtectHome=read-only
ReadWritePaths=/home/clepsy/projects/<app>
MemoryMax=400M              ; kernel-level backstop under reload-on-rss

[Install]
WantedBy=multi-user.target
```

Requires `uwsgi.ini` to gain:

```ini
need-app = true             ; fail loudly instead of serving 500s
die-on-term = true          ; systemd stop means stop
```

For `Type=notify`, add `notify-socket` support or fall back to `Type=simple`.

- [x] **Phase C is done.** All seven apps under systemd, proven across a real
      reboot on 2026-07-25: every unit came back unattended with `restarts=0`,
      `journalctl -b -p err` was empty, and all nine sites served. Swap went
      1561 MB → **0**, memory used 2814 MB → **1422 MB**.

      | app | unit | commit |
      | --- | --- | --- |
      | weather | `weather.service` | `8cee7b1` |
      | tempo | `tempo.service` | `8a86fcc` |
      | job-app | `jerbs.service` | `748b219` |
      | maptroid | `maptroid.service` | `7a6164f` |
      | bc-sched | `barcamp.service` | `f41904c` |
      | stream-recorder | `bop-recorder.service` | `0a0bbd5` |
      | txrx.org | `txrx.service` | `9f94ddad` |

      Two things this turned up that the plan had wrong:

      - **txrx was never under systemd.** Its master's parent was PID 1, but as
        an *orphan* in a login-session scope, not as a service. Orphans and
        supervised processes look identical by parent alone. The earlier "already
        systemd ✅" note in this doc was wrong.
      - **maptroid's ini was the only one without `die-on-term`**, so the SIGTERM
        used to hand its port to systemd was read as "brutal reload". The old
        master kept `:8943`, the unit crash-looped, and the site kept answering
        200 off the old process the whole time. Only `systemctl is-active`
        exposed it — an HTTP check alone would have passed. Cleared with SIGQUIT.
- [x] Roll out to tempo, job-app, maptroid, bc-sched, stream-recorder
- [x] txrx.org converted (it had no unit at all — see above)
- [x] `systemctl enable` each so they survive reboot
- [x] **Rebooted 2026-07-25 16:31** — all seven back unattended, 0 restarts

### Phase D — logging to `<project_root>/logs/uwsgi.log`
- [x] `logs/` created in all seven, `logs/*.log` gitignored, `logs/.gitkeep`
      tracked (except job-app, which already ignored the whole directory — its
      unit's `ExecStartPre` mkdir covers it)
- [x] `logto` + `log-reopen` in all seven inis; all seven writing there now
- [x] **logrotate now covers everything** — Phase B's relocation fixed this
      structurally. The existing glob `/home/clepsy/projects/*/logs/uwsgi.log`
      matches all eight apps now that nothing lives under `/home/django`.
- [x] Confirmed `journalctl -u <unit>` shows lifecycle and the file has requests
- [ ] Old original:
      ```ini
      logto = /home/clepsy/projects/<app>/logs/uwsgi.log
      log-reopen = true       ; reopen after logrotate moves the file
      ```
- [ ] Add `/etc/logrotate.d/uwsgi-projects` — these currently grow unbounded:
      ```
      /home/clepsy/projects/*/logs/uwsgi.log {
          weekly
          rotate 4
          compress
          missingok
          notifempty
          copytruncate
      }
      ```
- [ ] Confirm `journalctl -u <app>` and the file both work

Note: with `logto` set, uwsgi stops writing to stdout, so `journalctl` will show
only startup/crash output. That is the right split — file for request logs,
journal for lifecycle — but worth knowing before wondering where the logs went.

### Phase E — tear down the old supervision ✅ 2026-07-25

- [x] All 9 screen sessions and 3 tmux servers gone; nothing recreated them
      across two reboots
- [x] `start-prod.sh` in weather and tempo turned into signposts pointing at
      `systemctl` (`0f628a0`, `4b6dbc6`). Not deleted — left executable they
      would start a second uwsgi that loses a race for the port against the
      running service, which is a baffling failure for something that looks like
      the documented way to start the app.
- [x] `~/.claude/CLAUDE.md` rewritten: the unit table (four units are named for
      the *site*, not the directory), where logs actually live, the three
      load-bearing ini settings and why, and the fact that a repo move dangles
      the nginx symlink and stops nginx starting at boot.

**Second reboot 2026-07-25 18:12** — all eight units active, `restarts=0`, no
boot errors, ten sites serving, swap 0. This one mattered more than the first:
every unit's `ExecStart`, `WorkingDirectory` and `ReadWritePaths` changed in
Phase B, and four nginx symlinks were re-pointed.

---

## 4b. Open follow-ups (2026-07-25)

> **Superseded 2026-07-26 by `~/projects/backlog.md`**, which carries the live
> actionable list. This section is kept as the record of what the investigations
> found; several items below are now done — the Spaces key was rotated and the
> old one deleted, track 1 of the media migration shipped, `bc-sched.unrest.io`
> was repointed, and the editor backups holding credentials were deleted.

Not blocking anything, but each would be missed if not written down.

**Reboot still pending.** Every unit's `ExecStart`, `WorkingDirectory` and
`ReadWritePaths` changed in Phase B, and four nginx symlinks were re-pointed.
The 16:31 reboot only proved the *pre-move* paths came back.

**maptroid — from the investigation:**
- `maptroid-dev` (formerly `~/projects/maptroid`) is not a git repository and
  holds ~23 KB of unversioned work — `load_asmr_bundle.py`, `CLAUDE.md`, five
  `docs/backlog/` docs. **Decided 2026-07-25: not worth preserving.** Its
  counterpart repo `~/projects/asmr` no longer exists on this box, so the loader
  had nothing to load. The whole 1.3G directory is therefore disposable.
- The live repo is **2 commits ahead and unpushed**, with today's deploy config
  uncommitted, against a remote last contacted **August 2024**.
- `server/main/settings/local.py` contains a **live GitHub OAuth client secret in
  plaintext**. Gitignored, but it just moved between home directories and was
  readable by two accounts. Rotate it.
- **30G of generated media has no off-box copy and no backup job.** No
  django-storages/S3/Spaces config anywhere, no backup cron or timer. Breakdown:
  `sm_zone` 12G, `sm_cache` 11G, `trash` 4.2G, `temp` 1.6G — actual user
  `uploads` is only 9.8M. This is the real risk, not duplication.
- Safe to reclaim ~3.0G: `server/_.venv` (694M, verified broken — its
  `bin/python` does not exist), `_backups/` (1013M, nothing newer than Sep 2022),
  `maptroid-dev/server/.media` (1.3G, regenerable render cache).
- `_maptroid-sink` is a **live dependency**, symlinked from `.media/`. Not
  deletable — but it is level with its GitHub remote, so it is backed up.

**hive — from the investigation:**
- Working tree left uncommitted for review. Recommended: discard the
  `server/nginx.conf` diff (certbot cruft that appended a duplicate port-80
  block with no newline — the source of the long-standing
  `conflicting server name` warning) and the root `yarn.lock` stub plus
  `node_modules/` (someone ran `yarn install` in the repo root instead of
  `client/`; the README's instructions cause this).
- Two real bugs in `server/consumers.py`: `disconnect()` reads
  `self.room_group_name`, which `connect()` never sets on its early-return path,
  so any anonymous websocket connect throws; and line 23 calls `self.send(...)`
  un-awaited on an async consumer.
- `dist/index.html` pulls Font Awesome from cdnjs — the same render-blocking
  third-party dependency bundled out of weather earlier today.
- It runs **daphne, not uwsgi** (Channels/ASGI websockets), so it has no
  `touch-reload` and no worker recycling. A restart is required to pick up Python
  changes, and it drops open websockets.

**Elsewhere:**
- `/home/django/maptroid_dump.sql` (200M, May 2026) was left behind by the move.
  It is maptroid's newest dump but sits on the same disk as the database.
  Move it to `~/backups/` with the txrx and arms archives.
- **weather still cannot send sign-in codes.** `postfix@-.service` fails to start
  and nothing listens on `:25`; weather's `EMAIL_BACKEND` falls back to SMTP
  against localhost, and email-code is now its only auth path. tempo is fine —
  it has real Gmail SMTP credentials.

## 4c. Cross-project conventions (2026-08-29)

Two things every served frontend should have, recorded here because the gaps
only show up when you look at all the projects side by side.

### Every project needs a favicon

A site with no `<link rel="icon">` gets the browser's grey globe, and with four
of these open in a tab strip they are indistinguishable. An inline SVG in the
app's public directory is enough — no PNG set, no manifest — referenced as
`<link rel="icon" type="image/svg+xml" href="/favicon.svg">`.
`weather/client/public/favicon.svg` is the reference.

Checked by fetching each live site and reading the `<link rel="icon">` out of
the served HTML. **Do it that way, not by looking for `client/public/favicon.*`
on disk** — that path assumes the Vite layout and a file named `favicon`, and it
gets both maptroid (Vue CLI, so `client/public/index.html`, and its `.ico` is
served from `server/.static/`) and job-app (icon inlined as a `data:` URI, no
file at all) wrong.

| Project | Favicon |
| --- | --- |
| `weather` | ✅ `/favicon.svg` |
| `hive.js` | ✅ `/static/favicon.svg` |
| `tempo` | ✅ `/favicon.svg` (2026-08-29) |
| `emap` | ✅ `/favicon.svg` (2026-08-29) |
| `maptroid` | ✅ `/favicon.ico` — the in-game map icon |
| `job-app` | ✅ inline `data:image/svg+xml` |
| `portfolio` | ❌ — the only one actually missing (repo: `casscauley/portfolio.unrest.io`) |

### Every project should share one app chrome

Header, nav, auth menu and the pre-auth loading gate are the same problem in
every app, and four apps solve it four ways. Push as much as will go into
`@unrest/ui` (and `unrest_api` for whatever the client needs handed to it), so
a fix like the AuthNav backlog item lands everywhere at once instead of being
re-pasted per repo.

| Project | Shell today |
| --- | --- |
| `tempo` | `AppNav` + `AuthNav` from the library — closest to the target |
| `weather` | `AppNav` + `AuthNav`, plus its own `auth.loaded` gate and `.app-loading` |
| `emap` | **no `AppNav`** — hand-rolled `<header class="app__header">` with a brand link, plus its own copy of the same gate |
| `hive.js` | **its own `components/AppNav.vue`, 152 lines** against the library's 105 — bespoke brand, two dropdown menus, then the library's `AuthNav` |

Concrete duplication to collapse, easiest first:

- **The pre-auth loading gate.** weather and emap both hold the whole shell
  behind `v-if="!auth.loaded"` and paint a centered spinner, with the same
  reasoning in the comment (without it the shell mounts anonymous and the router
  paints the login screen for a frame). Both define their own `.app-loading` —
  weather in `css/app.css`, emap in `css/layout.css`. This wants to be one
  library component wrapping the default slot.
- **emap's bare header.** Its nav is a brand link and the auth menu, which is
  `AppNav` with an empty `items` list. It predates the app having any nav at
  all; there is no reason left for it to be bespoke.
- **hive's AppNav.** The 47 extra lines are two `game`/`config` dropdowns. The
  library's `AppNav` already takes group (dropdown) items, so most of this is a
  data reshape rather than a rewrite — and hive would pick up the mobile shelf
  and hamburger it currently has no equivalent of.

Do this **after** the auth-flow item below, not before: hive is the biggest
chrome divergence and also the app on the odd auth flow, and both changes land
in the same `App.vue`.

### Every project should be on the same auth flow

`unrest_api.email_auth` — passwordless sign-in code + click-through link, plus
guest accounts — is the flow three of four apps already use. It is the one
that gets maintained; the older `unrest_api.urls` register/password suite is
not. Mount it as `path('api/auth/', include('unrest_api.email_auth.urls'))`
and render `UnrestLoginPanel` on the client.

| Project | Auth |
| --- | --- |
| `weather` | `unrest_api.email_auth` |
| `tempo` | `unrest_api.email_auth` |
| `emap` | `unrest_api.email_auth` |
| `hive.js` | **`unrest_api.urls`** — register + password, the odd one out |

`hive.js/backlog/email-login.md` is already the task for this.

**hive.js is the migration.** Note the coupling to §4b: weather still cannot
send sign-in codes because `postfix@-.service` will not start and nothing
listens on `:25`. Moving another app onto email-code auth without fixing that
strands its users the same way — tempo works only because it has real Gmail
SMTP credentials. Fix the mail path first, or give hive the same credentials.

---

## 5. Progress log

- **2026-07-25** — **Phase B complete.** All 15 trees relocated to `~/projects`,
  everything owned and run by `clepsy`, `/home/django/projects` empty. Eight
  sites live under systemd — hive.unrest.io recovered after being down since
  March. Databases reassigned across all six. 84 broken venv shebangs repaired.
  Two subagents investigated maptroid's duplicate copies and revived hive; their
  findings are in §4b. Phases C and D are done; **E is next**, plus the pending
  reboot.
- **2026-07-25** — Phase A closed out. `wpr.unrest.io` dropped from weather's
  nginx (`0f2d3a1`, pending reload). `hive.js` kept rather than archived. Old
  droplet 64.225.25.49 snapshotted and deleted, leaving `bc-sched.unrest.io` and
  `schedule.barcampphilly.org` pointing at nothing — one DNS decision outstanding.
  Next up: Phase B/C. Recommended order is **C before B** — a systemd unit's
  `User=` line makes the ownership move a one-word edit per service rather than
  a coordinated cutover, so it is cheaper to get everything under systemd first
  and flip users second.
- **2026-07-25** — Survey complete. Earlier the same day: all uwsgi apps gained
  worker recycling (`max-requests=500`, `reload-on-rss=250`) and dropped to
  `processes=1`; weather migrated to `unrest_api` and rebased onto origin;
  tempo's Django restored (had been down with a dead `unrest_api.backlog`
  import), given a real `SECRET_KEY`, `DEBUG=false`, and switched off its Vite
  dev server; `arms` archived and deleted (1.2G reclaimed).
