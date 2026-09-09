# my-skills

sukkyun2's Claude Code and Codex skills.

## Claude Code 설치

```
/plugin marketplace add sukkyun2/my-skills
/plugin install dev-workflow@my-skills
```

## Codex 설치

이 저장소를 내려받은 뒤 다음 명령을 실행하면 `git-commit-pr`와
`jira-create` 스킬이 사용자 범위의 Codex에 설치된다.

```bash
scripts/sync-codex-skills.sh
```

기본 설치 경로는 `~/.codex/skills/`이며, `CODEX_HOME`이 설정되어 있으면
`${CODEX_HOME}/skills/`를 사용한다. 스킬을 수정한 뒤에는 같은 명령을 다시
실행한다.

프로젝트 범위에서만 사용하려면 이 저장소의 `.codex/skills/` 폴더를 대상
프로젝트의 같은 경로에 복사하거나 심볼릭 링크로 연결한다.

## What's included

Claude Code 플러그인과 Codex 스킬은 다음 워크플로를 동일하게 제공한다.

- `git-commit-pr` — branch creation, Conventional Commits, PR create/update via `gh`
- `jira-create` — Jira 티켓 초안 작성, 사용자 확인, 생성 및 리포터 본인 할당

Codex 버전은 Claude 전용 `AskUserQuestion` 표기 대신, 생성·수정 같은 외부
변경 직전에 일반적인 사용자 확인을 받도록 바꿨다. PR과 Jira의 내용 확인,
템플릿, 보조 스크립트 및 작업 규칙은 동일하다.

## Repo layout

```
.claude/skills/                 canonical skill source (also usable as project-scope skills)
.codex/skills/                  Codex-ready equivalents
.claude-plugin/marketplace.json marketplace definition
plugins/dev-workflow/           plugin manifest; skills/ is a symlink to .claude/skills
scripts/sync-skills.sh          copies .claude/skills/* into ~/.claude/skills (user scope)
scripts/sync-codex-skills.sh    copies .codex/skills/* into ~/.codex/skills (user scope)
```
