# my-skills

sukkyun2's Claude Code skills, distributed as a plugin marketplace.

## Install

```
/plugin marketplace add sukkyun2/my-skills
/plugin install dev-workflow@my-skills
```

## What's included

`dev-workflow` plugin:

- `git-commit-pr` — branch creation, Conventional Commits, PR create/update via `gh`
- `jira-create` — draft and create Jira tickets

## Repo layout

```
.claude/skills/                 canonical skill source (also usable as project-scope skills)
.claude-plugin/marketplace.json marketplace definition
plugins/dev-workflow/           plugin manifest; skills/ is a symlink to .claude/skills
scripts/sync-skills.sh          copies .claude/skills/* into ~/.claude/skills (user scope)
```
