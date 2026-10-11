# my-skills

sukkyun2's Claude Code and Codex skills.

## Claude Code 설치

```
/plugin marketplace add sukkyun2/my-skills
/plugin install dev-workflow@my-skills
```

## Codex 설치

이 저장소를 내려받은 뒤 다음 명령을 실행하면 `git-commit-pr`와
`github-issue-create` 스킬이 사용자 범위의 Codex에 설치된다.

```bash
scripts/sync-codex-skills.sh
```

기본 설치 경로는 `~/.codex/skills/`이며, `CODEX_HOME`이 설정되어 있으면
`${CODEX_HOME}/skills/`를 사용한다. 스킬을 수정한 뒤에는 같은 명령을 다시
실행한다.

프로젝트 범위에서만 사용하려면 이 저장소의 `.codex/skills/` 폴더를 대상
프로젝트의 같은 경로에 복사하거나 심볼릭 링크로 연결한다.

## Included workflows

Codex는 GitHub Issues 기반으로 다음 워크플로를 제공한다.

- `git-commit-pr` — branch creation, Conventional Commits, PR create/update via `gh`
- `github-issue-create` — GitHub Issue 초안 작성, 사용자 확인, 본인 할당 및 기본 Project 추가

`git-commit-pr`는 브랜치 이름의 `type/<이슈번호>-<slug>` 형식 또는 사용자가
제공한 GitHub Issue 번호를 PR 본문의 `Closes #번호`로 연결한다.

`github-issue-create`는 GMS/WMS 업무를 `wms-plan`(Project 33), FOMS/OMS
업무를 `oms-plan`(Project 37)에 자동 추가한다. 업무 구분이 불명확하면 생성 전에
Project를 물어본다. 대화에서 시작일 또는 목표일이 명시되면 해당 Project의
`Start date`와 `Target date`에도 기록한다.

```text
$github-issue-create 로그인 실패 오류를 GitHub Issue로 등록해줘
$git-commit-pr GitHub Issue #123 기준으로 브랜치와 PR 만들어줘
```

기존 `jira-create`는 하위 호환을 위해 남아 있지만 Codex가 자동으로 선택하지
않는다. Claude Code 플러그인과 과거 설계 문서는 기존 Jira 구성을 유지한다.

## Repo layout

```
.claude/skills/                 canonical skill source (also usable as project-scope skills)
.codex/skills/                  Codex-ready equivalents
.claude-plugin/marketplace.json marketplace definition
plugins/dev-workflow/           plugin manifest; skills/ is a symlink to .claude/skills
scripts/sync-skills.sh          copies .claude/skills/* into ~/.claude/skills (user scope)
scripts/sync-codex-skills.sh    copies .codex/skills/* into ~/.codex/skills (user scope)
```
