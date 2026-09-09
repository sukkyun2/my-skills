---
name: git-commit-pr
description: Create a branch, write a Conventional Commit, or open or update a GitHub pull request with this repository's Korean PR format. Use for branch, commit, or PR requests; not for reviewing a PR.
---

# Git Commit & PR Workflow

Use the helper scripts in `scripts/` for the mechanical git and `gh` operations. Make judgment calls from the actual diff and commit history. Obtain the user's confirmation immediately before each external mutation (branch creation, commit, push, PR creation, or PR edit).

## Branch

Read [branch naming](references/branch-naming.md). Ask for an issue or ticket number. If there is none, derive a short kebab-case slug from the diff or task; do not ask the user to invent one. Confirm a non-obvious derived branch name, then run:

```bash
scripts/new-branch.sh <type> <slug> [issue-number]
```

Allowed branch types: `feat`, `fix`, `docs`, `refactor`, `chore`, `hotfix`.

## Commit

Read [commit convention](references/commit-convention.md). Stage only the relevant files, derive the header and optional what-and-why body from the diff, show the proposed commit message, and after confirmation run:

```bash
scripts/commit.sh "<header>" [body-file]
```

## Pull request

Write PR body content in Korean while retaining the English section labels from [the template](templates/pr-template.md).

Ask the user which mode to use whenever starting PR creation or updating:

- **Normal:** Draft from the branch commits and diff, show the complete draft, then ask only about genuinely uncertain information and incorporate corrections before creating or editing.
- **Bypass:** Do not ask content questions. Infer what is supported by history and diff; omit uncertain details rather than inventing them.

For either mode, read all commits from the base branch to `HEAD` (subjects and bodies) plus the diff. Commit bodies are the primary input for Why, What, and How.

- **Why:** state the problem or need. Include a Jira link only when the key is known: `[KEY](https://ktown4u.atlassian.net/browse/KEY)`.
- **What:** summarize the changes.
- **How:** capture key decisions, trade-offs, and rejected alternatives when supported.
- **Test:** report actual tests or manual verification only.
- **TODO:** include only genuine deploy-time manual work as `- [ ]` items; remove this section if absent.
- **Review Focus:** include only real uncertainty or areas worth review; remove the heading if absent. Preserve a standalone `> 시작점:` line when a useful entry point is inferable.

Never use `없음` or `None` as filler. Use ordinary `-` bullets except in TODO. Choose exactly one label: `behavior` for behavior changes, `structure` for organization-only changes, and `bug` for defect fixes. In Normal mode, ask if it is genuinely ambiguous; in Bypass mode, default to `behavior`.

After confirmation in Normal mode, write a filled template to a temporary file and run:

```bash
scripts/create-pr.sh "<title>" <filled-body-file> [base-branch] [label]
```

This pushes the branch, opens the PR, and assigns it to the authenticated user. It requires authenticated `gh` and an `origin` remote.

For an existing PR, use the same drafting rules, then after confirmation in Normal mode run:

```bash
scripts/edit-pr.sh <pr-number-or-url> <filled-body-file> [title]
```

It changes only the PR metadata and adds the authenticated user as assignee only if the PR currently has none.
