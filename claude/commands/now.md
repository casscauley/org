Tell me where I left off.

## How to decide what to look at

Check the current working directory:

- If inside `~/incentfit-website` (any depth — includes `vue-jsapp/` and other subdirs): read `~/incentfit-website/.idea/now.md` and summarize what's outstanding. If the file doesn't exist, fall through to the git-based path.
- Otherwise (or as fallback): inspect the current git repo:
    - `git status` for unstaged/untracked work in progress
    - `git log -5 --oneline` for the most recent commits
    - `git diff HEAD~1` if there's nothing unstaged, to show what the last commit changed
  Summarize what I was working on based on those signals.

## Output

Keep it tight — a short paragraph or a few bullets. Lead with the current state ("you have X unstaged changes to Y" / "last commit was Z"), then what looks like the next step. Do not invent next steps if the signals don't suggest one — just say what you see.

## User Input

$ARGUMENTS
