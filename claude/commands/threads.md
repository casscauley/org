Take your previous response and walk me through it **one item at a time**. Do not restate the whole list.

Decisions are mine; execution isn't something I want to watch. You ask, I answer, you hand the work to a subagent and immediately show me the next item. I should never be sitting through an edit-and-build cycle.

## The queue file

Everything is tracked in `~/threads/<repo>/<branch>.md`, where:

- `<repo>` is the basename of `git rev-parse --show-toplevel`
- `<branch>` is `git rev-parse --abbrev-ref HEAD`, kept verbatim — a branch like `debt/css-wrapper` nests as `~/threads/incentfit-website/debt/css-wrapper.md`
- if the cwd isn't a git repo, use `~/threads/_no-repo/<basename of cwd>.md`

`mkdir -p` the parent directory before writing. Resolve both values with one shell call at the start of the turn; don't guess them from context.

Format — a markdown checklist, one line per item, newest appended at the bottom:

```
- [ ] Nav bar still uses raw <button> — vue-jsapp/src/components/Nav.vue:24
- [>] Extract the duplicated date helper
- [x] Convert the paginator buttons
- [~] Rename the Cybertron model fields (deferred 2026-07-30)
- [-] Add a Storybook story for BaseCard (skipped)
```

`[ ]` pending, `[>]` dispatched but not confirmed, `[x]` done, `[~]` deferred, `[-]` skipped. Write dates absolute, never "yesterday".

This file outlives the session. Read it first, every time.

A `[>]` left over from a previous session means an agent was dispatched and the session died before its result landed. Don't trust it either way — check whether the change is actually present in the working tree, then mark it `[x]` or reset it to `[ ]`.

## Step 1 — build the queue

Read the queue file if it exists. Carry forward every `[ ]` and `[~]` item; leave `[x]` and `[-]` lines in place as history. Resolve any stale `[>]` as above.

Then re-read your last substantive response and extract every distinct thing that wants a decision or an action from me: proposed changes, open questions, options you offered, caveats you flagged, follow-up work you suggested. Append each as a new `[ ]` item.

Rules for splitting:

- One item = one decision. If a bullet bundled two independent changes, split it.
- If several bullets are really one decision (e.g. three files that all get the same rename), merge them into one item.
- Drop anything that was pure explanation with nothing to decide.
- Don't re-add an item that's already in the file. If the response revisits an existing item, update that line instead.

**Do the reading yourself.** Open the files the queue refers to before you start asking. You need that context to write sharp options, and to defend a recommendation when I push back mid-loop. Delegate the edits, never the analysis — an orchestrator that farmed out the reading can't discuss its own answers.

**Assign lanes.** For each item, note the files it will touch. Items whose file sets intersect share a lane and run on one agent, in order. The sharding key is *files*, not topic — two unrelated-sounding items that both edit `Foo.vue` will clobber each other if they run in parallel. Lanes are ephemeral session state; don't write them into the queue file.

**Cap concurrent lanes at 3** unless I say otherwise (`/threads lanes=5`). This box is 2 cores / 3GB, and while agents mostly sit on model round-trips, their builds don't — a fourth parallel build is where it starts swapping. When every lane is occupied, don't spawn a new one: fold the item into the lane with the least outstanding work. That's always safe, since a lane is sequential by construction and merging two non-overlapping lanes only costs throughput. It does hand one agent two unrelated jobs, so give it enough context to treat them as separate.

Then tell me the count and nothing else: `5 threads (2 carried over). Starting.`

## Step 2 — the loop

For each pending item, in the order I'm most likely to care about (carried-over items first, then blockers and cheap wins, speculative nice-to-haves last):

1. Show **only that item**: `[2/5]` plus two or three sentences of context — what it is, why it came up, what changes if we do it. Include the file:line if there is one.
2. Ask what I want via AskUserQuestion. Options should be the real choices for *that* item, not a generic yes/no — e.g. two concrete implementations if it's a design call, or `Do it / Skip / Later` if it's a straightforward task.
3. Act on my answer:
   - **Do it** — hand it to a subagent (see below), mark the item `[>]`, and move on. Don't wait for it.
   - **Skip / Later** — record it, say nothing more.
4. Update that item's state in the queue file before moving on. Don't batch the writes to the end — if the session dies mid-loop the file has to be accurate.
5. Move to the next item. Do not summarize progress between items. Do not preview what's coming.

### Handing off

- First item in a lane: spawn an Agent in the background. Later items in the same lane: `SendMessage` to that agent so it keeps its context and its edits stay ordered.
- Tell the agent the decision I made, the files it owns, and that it must not touch anything outside them. Tell it not to commit.
- Have it verify narrowly — does its own change compile / pass its tests. **You** run the authoritative full build or test suite once, at the end. Parallel agents running the same build against one output directory clobber each other, and an agent can see a failure caused by someone else's half-written file.
- If an item is a single edit with no verification step, just do it inline. The handoff costs more than the work.
- A newly-discovered item inherits the lane of whatever discovered it, and usually its dependencies too — append it to the queue, mention it in one line, and don't silently expand scope.

### When results land

- **Success** — update the checkbox, say nothing, keep going. I'll read the summary at the end.
- **Failure, or anything surprising** — interrupt immediately. Short report, then ask what I want to do. Don't let me answer three more questions while something's on fire.

If I answer something that isn't one of the options (a question, a correction, "wait, why?"), drop out of the loop and just talk to me. Resume when I say so.

## Step 3 — end

When nothing is pending, wait for any agents still running, then run the full build / test suite once. Give me one short block: what got done, what I skipped, what's deferred, and whether the build is green. Deferred items stay `[~]` in the file, so the next `/threads` on this branch picks them up.

## Hard rules

- Never show me more than one pending item at a time. That's the entire point of this command.
- Never bundle "and while I was in there I also…" — that's a new item, and it goes in the queue.
- Never run two agents against the same file. If you're unsure whether two items overlap, put them in the same lane.
- Never exceed the lane cap. Folding an item into a busy lane is always correct; spawning agent number four is not.
- If I say stop, stop. Don't finish the current item first, don't wait for in-flight agents — write the queue file, tell me what's still running, and stop.

## User Input

$ARGUMENTS
