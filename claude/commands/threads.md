Take your previous response and walk me through it **one item at a time**. Do not restate the whole list.

## The queue file

Everything is tracked in `~/threads/<repo>/<branch>.md`, where:

- `<repo>` is the basename of `git rev-parse --show-toplevel`
- `<branch>` is `git rev-parse --abbrev-ref HEAD`, kept verbatim — a branch like `debt/css-wrapper` nests as `~/threads/incentfit-website/debt/css-wrapper.md`
- if the cwd isn't a git repo, use `~/threads/_no-repo/<basename of cwd>.md`

`mkdir -p` the parent directory before writing. Resolve both values with one shell call at the start of the turn; don't guess them from context.

Format — a markdown checklist, one line per item, newest appended at the bottom:

```
- [ ] Nav bar still uses raw <button> — vue-jsapp/src/components/Nav.vue:24
- [x] Extract the duplicated date helper
- [~] Rename the Cybertron model fields (deferred 2026-07-30)
- [-] Add a Storybook story for BaseCard (skipped)
```

`[ ]` pending, `[x]` done, `[~]` deferred, `[-]` skipped. Write dates absolute, never "yesterday".

This file outlives the session. Read it first, every time.

## Step 1 — build the queue

Read the queue file if it exists. Carry forward every `[ ]` and `[~]` item; leave `[x]` and `[-]` lines in place as history.

Then re-read your last substantive response and extract every distinct thing that wants a decision or an action from me: proposed changes, open questions, options you offered, caveats you flagged, follow-up work you suggested. Append each as a new `[ ]` item.

Rules for splitting:

- One item = one decision. If a bullet bundled two independent changes, split it.
- If several bullets are really one decision (e.g. three files that all get the same rename), merge them into one item.
- Drop anything that was pure explanation with nothing to decide.
- Don't re-add an item that's already in the file. If the response revisits an existing item, update that line instead.

If `/threads` is invoked with no prior response to mine — I just typed it cold — skip the extraction and work the existing queue.

Then tell me the count and nothing else: `5 threads (2 carried over). Starting.`

## Step 2 — the loop

For each pending item, in the order I'm most likely to care about (carried-over items first, then blockers and cheap wins, speculative nice-to-haves last):

1. Show **only that item**: `[2/5]` plus two or three sentences of context — what it is, why it came up, what changes if we do it. Include the file:line if there is one.
2. Ask what I want via AskUserQuestion. Options should be the real choices for *that* item, not a generic yes/no — e.g. two concrete implementations if it's a design call, or `Do it / Skip / Later` if it's a straightforward task.
3. Act on my answer immediately:
   - **Do it** — make the change, run whatever verifies it, show me the result briefly.
   - **Skip / Later** — record it, say nothing more.
4. Update that item's checkbox in the queue file before moving on. Don't batch the writes to the end — if the session dies mid-loop the file has to be accurate.
5. Move to the next item. Do not summarize progress between items. Do not preview what's coming.

If acting on an item turns up new work, append it to the queue and mention it in one line — don't silently expand scope.

If I answer something that isn't one of the options (a question, a correction, "wait, why?"), drop out of the loop and just talk to me. Resume when I say so.

## Step 3 — end

When nothing is pending, give me one short block: what got done, what I skipped, what's deferred. Deferred items stay `[~]` in the file, so the next `/threads` on this branch picks them up.

## Hard rules

- Never show me more than one pending item at a time. That's the entire point of this command.
- Never bundle "and while I was in there I also…" — that's a new item, and it goes in the queue.
- If I say stop, stop. Don't finish the current item first — just write the queue file and stop.

## User Input

$ARGUMENTS
