---
name: git-commit-pr
description: Use when creating a branch, writing a commit message, or opening a GitHub PR in this repo — covers branch checkout/creation, Conventional Commits header+body, and PR creation via gh with a standard template. Triggers on "브랜치 만들어줘", "커밋해줘", "PR 만들어줘", "create branch", "commit this", "open a PR".
---

# Git Commit & PR Workflow

Scripts in `scripts/` do the mechanical git/gh work and validate format; you
do the judgment calls (branch slug, commit subject/body, PR summary) by
reading the diff. Paths below are relative to this skill dir
(`.claude/skills/git-commit-pr/`).

## 1. Branch

Read [reference/branch-naming.md](reference/branch-naming.md) first.

1. Ask the user for an issue/ticket number.
2. If they don't have one, read the diff/task and derive a short kebab-case
   slug yourself — don't ask them to name it.
3. Run:
   ```
   scripts/new-branch.sh <type> <slug> [issue-number]
   ```
   `type` ∈ `feat fix docs refactor chore hotfix`. The script normalizes the
   slug (lowercase, non-alnum → `-`) and rejects invalid types.

## 2. Commit

Read [reference/commit-convention.md](reference/commit-convention.md) first.

1. Stage the relevant files (`git add`).
2. Write the header: `<type>(<scope>): <subject>` (imperative, ≤72 chars).
3. If there's more to explain, write a body to a temp file (what+why,
   wrapped ~72 chars).
4. Run:
   ```
   scripts/commit.sh "<header>" [body-file]
   ```
   The script rejects headers that don't match Conventional Commits and
   refuses to commit when nothing is staged.

## 3. Pull Request

Don't silently fill [templates/pr-template.md](templates/pr-template.md) from
the diff alone — walk through it section by section with the user via
AskUserQuestion (or plain questions) and fill in their answers, using the
diff/commits (`git log main..HEAD`) only as your own draft/suggestion, not
as the final answer. Ask one section at a time, in this order:

1. **Why (배경/문제)** — what problem existed / what was needed. Ask for the
   Jira key too; build the link as `[KEY](https://ktown4u.atlassian.net/browse/KEY)`
   (shows only the key). No ticket → drop the Jira line.
2. **What (변경 요약)** — you can propose a summary from the diff, but confirm
   it with the user rather than asserting it.
3. **How (접근/설계)** — decisions, trade-offs, alternatives rejected.
4. **Test (검증)** — how they verified it (tests run, manual checks,
   screenshots/logs).
5. **TODO (머지/배포 전 필요 작업)** — deploy-time manual steps only (parameter
   store values, DB migrations), as `- [ ]` checkboxes. Ask if there are any;
   drop the section if none.
6. **Review Focus (리뷰어가 봐주셨으면 하는 부분)** — ask what they're unsure
   about or debated internally. Don't skip this by guessing — it's usually
   something only the author knows. Also ask: what's a good entry point for
   a reviewer? → `시작점:` line at the end of this section (e.g.
   `UploadDeliveryTracking, GetDeliveryTrackingUploadHistories 부터 시작`).

Plain `-` bullets everywhere except TODO. Once every section has the user's
actual answer (not just your inference), write the filled template to a
temp file and run:

```
scripts/create-pr.sh "<title>" <filled-body-file> [base-branch]
```

`base-branch` defaults to `main`. The script pushes the current branch with
`-u origin <branch>` and calls `gh pr create`. It refuses to run from the
base branch itself.

## Full flow example

```bash
scripts/new-branch.sh feat login-rate-limit 123
# ...edit files...
git add src/auth/login.ts
scripts/commit.sh "feat(login): add rate limiting to login endpoint" /tmp/body.txt
scripts/create-pr.sh "feat(login): add rate limiting to login endpoint" /tmp/pr-body.md main
```

## Gotchas

- `commit.sh` writes header+body to a temp file and uses `git commit -F` —
  `-m` and `-F` cannot be combined in one `git commit` call.
- `create-pr.sh` requires `gh auth status` to already be logged in and an
  `origin` remote to exist; neither is checked/set up by this skill.
- Branch `type` for branches is a narrower set than commit `type` — no
  `style`/`perf`/`test`/`build`/`ci`/`revert` branch prefixes.
