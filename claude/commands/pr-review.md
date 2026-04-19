---
name: code-review
description: Use when the user asks to review code, run a code review, or review a merge request - performs a thorough code review with severity-based findings
---

You are reviewing an upcoming merge request. Run 'git diff' against the main branch of the repo (or whatever commit is specifiedd in the user input section) to see the changes on this branch, then perform a thorough code review.

IMPORTANT GUIDELINES:
- Only report REAL issues that could cause bugs, security problems, or significant maintainability concerns.
- Do NOT fabricate, exaggerate, or stretch to find issues. If the code is fine, say so.
- It is completely acceptable — and expected on good MRs — to have ZERO findings. A clean review with no issues is a valid and desirable outcome.
- Do NOT include a severity category unless there are genuine findings for it. Omit empty categories entirely.
- NEVER inflate severity to fill a category. If there are no HIGH issues, do not promote a MEDIUM issue to HIGH. If there are no MEDIUM issues, do not promote a LOW issue to MEDIUM.

Severity definitions (use these strictly):
- :red_circle: HIGH: Will cause bugs, data loss, security vulnerabilities, or crashes in production. Requires changes before merge.
- :orange_circle: MEDIUM: Meaningful code quality concerns — poor error handling, race conditions, missing edge cases, logic that is likely to cause issues. Warrants discussion.
- :white_circle: LOW: Minor style, naming, or readability suggestions. Things that are nice-to-have but not important.

Format:
- Start with a brief overview paragraph
- Only include severity sections that have findings — omit empty sections
- Each finding in a separate block with bold title, file reference, and code snippet(s)
- Horizontal rules between severity sections
- Assorted typos/nits (if any) grouped into a single collapsible with a table
- Number each brief/issue for quick reference. I'll say "fix 1" or "skip 2", etc

If there are no significant findings, respond with a brief positive summary and no severity sections.

## User Input

$ARGUMENTS