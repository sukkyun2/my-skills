# Jira 티켓 자동 생성 스킬 — 설계

## 배경

대화 중 버그를 발견하거나 요구사항/기획 논의가 정리되면, 그 내용을 바로 Jira
티켓으로 등록하고 싶다. 담당자 할당과 티켓 내용(제목/설명) 작성까지 한 번에
처리하는 스킬이 필요하다.

이 세션에는 이미 Atlassian MCP 도구(`mcp__atlassian__*`)가 연결되어 있어
`createJiraIssue`, `lookupJiraAccountId`, `getJiraProjectIssueTypesMetadata`,
`getVisibleJiraProjects` 등을 바로 호출할 수 있다. 별도의 REST 클라이언트나
스크립트를 만들 필요가 없다.

## 트리거

SKILL.md frontmatter의 `description`에 아래 키워드를 포함해 자동 로드되도록
한다:
- "Jira 티켓 만들어줘", "티켓 등록해줘", "버그 등록해줘"
- "create jira ticket", "jira 만들어줘"

## 흐름

1. **프로젝트 & 이슈 타입 확인**
   - 매번 사용자에게 프로젝트(키/이름)와 이슈 타입(Task/Bug/Story 등)을
     물어본다.
   - 확실하지 않으면 `getVisibleJiraProjects`로 후보를 보여주고 선택받는다.
   - 선택된 프로젝트에서 해당 이슈 타입이 유효한지
     `getJiraProjectIssueTypesMetadata`로 확인한다.

2. **내용 초안 작성**
   - 지금까지의 대화 내용을 바탕으로 제목과 설명 초안을 작성한다.
   - 이슈 타입별로 다른 템플릿을 사용한다:
     - Bug: 재현절차 / 기대결과 / 실제결과
     - Task/Story: 배경 / 요구사항 / 완료조건
   - 초안을 사용자에게 보여주고, 확인 또는 수정 요청을 받은 뒤에만 다음
     단계로 진행한다. (`git-commit-pr`의 PR 섹션과 동일한 "확정 전 확인"
     패턴 — 대화 내용만으로 티켓 내용을 단정하지 않는다.)

3. **담당자 지정**
   - 항상 리포터(현재 사용자, "나")로 지정한다. 컴포넌트별 매핑표는 두지
     않는다.
   - `lookupJiraAccountId` 등으로 본인 계정 ID를 확인해 assignee로 넣는다.

4. **티켓 생성**
   - `createJiraIssue`로 프로젝트, 이슈 타입, 제목, 설명, 담당자를 지정해
     생성한다.
   - 라벨, 우선순위 등 추가 필드는 넣지 않는다 (YAGNI — 실제로 필요해지면
     그때 추가).

5. **결과 보고**
   - 생성된 이슈 키와 링크를 사용자에게 전달한다.

## 파일 구조

```
.claude/skills/jira-create/
  SKILL.md
  templates/bug-template.md
  templates/task-template.md
```

`scripts/`는 두지 않는다. 모든 동작이 이미 연결된 MCP 도구 호출과 판단
(프로젝트/타입 확인, 내용 초안 작성)으로 처리되기 때문이다. 이는
`git-commit-pr` 스킬에서 PR 생성 단계(스크립트 없이 판단+확인만 수행)와
branch/commit 단계(실제 git 실행이 필요해 스크립트가 있음)가 다른 것과
같은 이유다.

## 범위 밖 (YAGNI)

- 라벨, 우선순위, 마감일, 컴포넌트 지정
- 컴포넌트/영역별 담당자 자동 매핑
- 서브태스크, 에픽 링크, 이슈 간 연결
- PR/커밋과의 자동 연동 (git-commit-pr와의 통합은 이번 스킬 범위 밖)

필요해지면 별도 요청으로 추가한다.
