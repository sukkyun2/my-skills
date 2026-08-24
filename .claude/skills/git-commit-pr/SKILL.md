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

PR 본문은 한글로 작성한다 (섹션 헤더의 영문 라벨은 유지, 내용만 한글).

Don't silently fill [templates/pr-template.md](templates/pr-template.md) from
the diff alone, but don't interrogate section-by-section either. Work in two
passes:

**Pass 1 — draft.** Read every commit on the branch (`git log <base>..HEAD`,
both subjects and bodies) plus the diff, and write a full first draft of all
six sections yourself. Commit bodies are the primary source — if you wrote
good "what+why" bodies at commit time, most of Why/What/How is already
sitting there; don't discard that context and start from the diff alone.
Show the user the complete draft in one shot.

1. **Why (배경/문제)** — what problem existed / what was needed. Needs a
   Jira key too; build the link as `[KEY](https://ktown4u.atlassian.net/browse/KEY)`
   (shows only the key). No ticket → drop the Jira line.
2. **What (변경 요약)** — summary of the change, from the diff/commits.
3. **How (접근/설계)** — decisions, trade-offs, alternatives rejected.
4. **Test (검증)** — how it was verified (tests run, manual checks,
   screenshots/logs).
5. **TODO (머지/배포 전 필요 작업)** — deploy-time manual steps only (parameter
   store values, DB migrations), as `- [ ]` checkboxes. Omit the whole
   section (heading included) if nothing in the commits implies one — never
   write it with "없음" as filler.
6. **Review Focus (리뷰어가 봐주셨으면 하는 부분)** — what the author was
   unsure about or debated internally. Omit the whole section the same way
   TODO does if nothing in the commits suggests one — but keep the
   `> 시작점:` line (as its own trailing line, not nested under the removed
   heading) whenever an entry point is inferable: `> 시작점:
   UploadDeliveryTracking, GetDeliveryTrackingUploadHistories 부터 시작`.

**Pass 2 — clarify.** Commit history almost never carries *why* (motivation,
rejected alternatives, verification) or Jira key — those are the sections
most likely to need a real question. What/How are often inferable from the
diff and commits; don't ask about those unless the commits genuinely leave
them ambiguous or contradictory. Ask via AskUserQuestion (or plain
questions) about only the sections you're actually unsure of — batch them,
don't go one-by-one. Treat your draft as a suggestion the user corrects, not
the final answer: apply their corrections before writing the file.

Plain `-` bullets everywhere except TODO. A section with real content is never
filled with "없음"/"None" — either it has a real answer (drafted or
user-confirmed) or it's cut entirely. Once the draft is confirmed, write the
filled template to a temp file and run:

```
scripts/create-pr.sh "<title>" <filled-body-file> [base-branch] [label]
```

`base-branch` defaults to the repo's GitHub default branch (via
`gh repo view --json defaultBranchRef`) when omitted. The script pushes the
current branch with `-u origin <branch>`, then calls `gh pr create` with
`--assignee @me` (assigns the PR to the authenticated user) and, if `label`
is given, `--label <label>`. It refuses to run from the base branch itself.

Before calling it, decide the `label` yourself from the diff/commits — pick
exactly one:

- `behavior` — changes what the code does (feature, fix, logic change)
- `structure` — changes how the code is organized without changing behavior
  (refactor, rename, file moves, formatting)
- `bug` — fixes a defect

If it's ambiguous, ask the user which one fits rather than guessing.

## Updating an existing PR

When the user gives an existing PR (number or URL) to update instead of
creating a new one, fill the template the same two-pass way (draft from
`git log`/diff first, then ask only about what's genuinely ambiguous), write
the filled body to a temp file, then run:

```
scripts/edit-pr.sh <pr-number-or-url> <filled-body-file> [title]
```

This calls `gh pr edit` with the new body (and title, if given). It only
assigns the PR to the authenticated user when the PR currently has **no**
assignee — an already-assigned PR is left alone.

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
- `edit-pr.sh` doesn't push or touch branches — it only edits the PR via
  `gh pr edit`, so it works from any branch (or a detached worktree).
- Branch `type` for branches is a narrower set than commit `type` — no
  `style`/`perf`/`test`/`build`/`ci`/`revert` branch prefixes.
