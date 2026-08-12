# Branch Naming

```
<type>/<issue-number>-<slug>     # issue number known
<type>/<slug>                     # no issue number
```

- `type` — same set as commit types, narrowed to: `feat` `fix` `docs` `refactor` `chore` `hotfix`
- `issue-number` — bare number, no `#` (e.g. `123`, not `#123`)
- `slug` — lowercase, kebab-case, 2-5 words, no issue number inside it

## Deciding the slug

1. **Ask the user for an issue/ticket number first.**
2. If they have none, **do not ask for a name** — read the staged/unstaged diff (or the task description) and derive a short kebab-case slug yourself from what actually changed (e.g. touching `src/auth/login.ts` to add throttling → `login-rate-limit`). Confirm the generated branch name with the user before creating it if it's non-obvious.

## Examples

- `feat/123-login-rate-limit` — issue #123, new feature
- `fix/null-check-checkout` — no issue, bug fix, name derived from the diff
- `docs/git-workflow-guide` — no issue, docs change
