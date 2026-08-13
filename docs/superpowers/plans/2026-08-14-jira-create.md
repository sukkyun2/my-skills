# Jira 티켓 생성 스킬 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `.claude/skills/jira-create/`에 Jira 티켓을 자동 생성하는 스킬을 추가한다 — 프로젝트/이슈 타입 확인, 대화 기반 내용 초안, 리포터 자동 할당까지 처리.

**Architecture:** 이미 연결된 `mcp__atlassian__*` MCP 도구만 사용하는 순수 프롬프트/문서 스킬. 커스텀 스크립트 없음 — `SKILL.md`가 흐름을 정의하고, 이슈 타입별 내용 템플릿 2개를 참조한다.

**Tech Stack:** Markdown (SKILL.md, YAML frontmatter), Atlassian MCP 도구 (`getVisibleJiraProjects`, `getJiraProjectIssueTypesMetadata`, `lookupJiraAccountId`, `createJiraIssue`).

## Global Constraints

- 스킬 경로: `.claude/skills/jira-create/` (spec: 파일 구조).
- `scripts/` 디렉터리를 두지 않는다 — 모든 동작은 MCP 도구 호출 + 판단으로 처리한다 (spec: 파일 구조 근거).
- 담당자는 항상 리포터(현재 사용자) 고정. 매핑표 없음 (spec: 담당자 지정).
- 라벨/우선순위/마감일/컴포넌트/서브태스크/에픽 링크는 범위 밖 (spec: 범위 밖 (YAGNI)).
- 프로젝트와 이슈 타입은 매번 사용자에게 확인한다 (spec: 흐름 1).
- 티켓 내용은 대화 기반 초안 → 사용자 확인 후에만 생성한다 (spec: 흐름 2).

---

이 스킬에는 실행 가능한 코드가 없으므로(순수 Markdown + MCP 도구 오케스트레이션), "테스트"는 pytest류 자동화 테스트가 아니라 **문서 무결성 검증**(frontmatter 파싱, 템플릿 파일 참조 존재 확인)과 **실제 MCP 도구 dry-run**(읽기 전용 호출로 스킬이 참조하는 도구가 실제로 응답하는지 확인)이다. 각 태스크는 이 검증으로 끝난다.

### Task 1: 이슈 타입별 내용 템플릿 작성

**Files:**
- Create: `.claude/skills/jira-create/templates/bug-template.md`
- Create: `.claude/skills/jira-create/templates/task-template.md`

**Interfaces:**
- Produces: `SKILL.md`가 참조할 두 템플릿 파일 경로 — `templates/bug-template.md`, `templates/task-template.md`. 각 파일은 Jira 설명(description) 필드에 그대로 채워 넣을 수 있는 마크다운 섹션 구조.

- [ ] **Step 1: `bug-template.md` 작성**

`git-commit-pr`의 `templates/pr-template.md`와 동일한 스타일(HTML 주석으로 안내, `-` 불릿)로 작성한다.

```markdown
## 재현절차

<!-- 어떻게 하면 재현되는지, 순서대로 -->

- 

## 기대결과

<!-- 원래 어떻게 동작해야 하는지 -->

- 

## 실제결과

<!-- 실제로 어떻게 동작했는지 (에러 메시지, 스크린샷 등) -->

- 
```

- [ ] **Step 2: `task-template.md` 작성**

```markdown
## 배경

<!-- 왜 필요한가 / 어떤 논의에서 나왔나 -->

- 

## 요구사항

<!-- 무엇을 해야 하는가 -->

- 

## 완료조건

<!-- 어떻게 되면 끝난 건지 -->

- 
```

- [ ] **Step 3: 파일 존재 및 마크다운 헤더 검증**

Run:
```bash
test -f .claude/skills/jira-create/templates/bug-template.md && \
test -f .claude/skills/jira-create/templates/task-template.md && \
grep -q "^## 재현절차" .claude/skills/jira-create/templates/bug-template.md && \
grep -q "^## 배경" .claude/skills/jira-create/templates/task-template.md && \
echo OK
```
Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add .claude/skills/jira-create/templates/bug-template.md .claude/skills/jira-create/templates/task-template.md
git commit -m "feat(jira-create): add bug/task issue content templates"
```

---

### Task 2: `SKILL.md` 작성

**Files:**
- Create: `.claude/skills/jira-create/SKILL.md`
- Test: 수동 검증 (아래 Step 참고) — 별도 테스트 파일 없음

**Interfaces:**
- Consumes: Task 1에서 만든 `templates/bug-template.md`, `templates/task-template.md` (경로만 참조, 상대경로는 스킬 디렉터리 기준).
- Produces: `name: jira-create` 스킬. frontmatter의 `description`이 `/reload-skills` 로 로드되는 진입점.

- [ ] **Step 1: frontmatter + 본문 작성**

```markdown
---
name: jira-create
description: Jira 티켓을 자동으로 생성할 때 사용. 버그 발견, 요구사항/기획 논의 정리 후 바로 티켓으로 등록하고 싶을 때 트리거. "Jira 티켓 만들어줘", "티켓 등록해줘", "버그 등록해줘", "create jira ticket" 등의 요청에 반응. mcp__atlassian__* MCP 도구로 프로젝트 확인, 내용 초안 작성 후 사용자 확인, 리포터 본인 할당까지 처리.
---

# Jira 티켓 생성

`mcp__atlassian__*` MCP 도구만 사용한다. 별도 스크립트 없음 — 아래 순서를
그대로 따르되, 3단계(내용 확인)는 절대 생략하지 않는다.

## 1. 프로젝트 & 이슈 타입 확인

1. 사용자에게 프로젝트(키 또는 이름)와 이슈 타입(Task/Bug/Story 등)을 묻는다.
2. 프로젝트가 불확실하면 `getVisibleJiraProjects`로 후보 목록을 보여주고
   선택받는다.
3. 선택된 프로젝트에서 해당 이슈 타입이 유효한지
   `getJiraProjectIssueTypesMetadata`로 확인한다. 유효하지 않으면 그
   프로젝트에서 사용 가능한 타입 목록을 보여주고 다시 묻는다.

## 2. 내용 초안 작성

1. 지금까지의 대화 내용을 바탕으로 제목과 설명 초안을 작성한다.
2. 이슈 타입에 맞는 템플릿을 사용한다:
   - Bug → [templates/bug-template.md](templates/bug-template.md)
   - Task/Story → [templates/task-template.md](templates/task-template.md)
3. 초안(제목 + 채운 템플릿)을 사용자에게 보여준다. 대화 내용만으로
   단정하지 말고, 빈 항목이나 불확실한 부분은 사용자에게 직접 물어서
   채운다.
4. 사용자가 확인하거나 수정 요청을 반영해 최종본이 될 때까지 3단계로
   진행하지 않는다.

## 3. 담당자 지정

- 항상 리포터(현재 사용자, "나")로 지정한다. 컴포넌트별 매핑표는 사용하지
  않는다.
- `lookupJiraAccountId`로 본인 계정 ID를 확인해 담당자로 사용한다. 실패하면
  사용자에게 본인 이메일/이름을 물어서 다시 조회한다.

## 4. 티켓 생성

`createJiraIssue`를 호출한다:
- 프로젝트: 1단계에서 확정한 프로젝트
- 이슈 타입: 1단계에서 확정한 타입
- 제목/설명: 2단계에서 사용자가 확정한 내용
- 담당자: 3단계에서 확인한 계정 ID

라벨, 우선순위, 마감일, 컴포넌트, 서브태스크, 에픽 링크는 넣지 않는다
(범위 밖 — 필요하면 사용자가 별도로 요청).

## 5. 결과 보고

생성된 이슈 키와 링크(`https://<사이트>.atlassian.net/browse/<KEY>`)를
사용자에게 전달한다.

## Gotchas

- `createJiraIssue` 호출 전에 반드시 2단계(내용 확인)를 거친다 — 대화
  내용을 그대로 밀어넣지 않는다.
- 프로젝트/이슈 타입은 매번 새로 묻는다. 이전 대화에서 썼던 프로젝트를
  기본값으로 재사용하지 않는다.
```

- [ ] **Step 2: YAML frontmatter 파싱 검증**

Run:
```bash
python3 -c "
import re, sys
text = open('.claude/skills/jira-create/SKILL.md').read()
m = re.match(r'^---\n(.*?)\n---\n', text, re.S)
assert m, 'frontmatter not found'
import yaml
data = yaml.safe_load(m.group(1))
assert data['name'] == 'jira-create', data
assert 'description' in data and len(data['description']) > 20
print('OK', data['name'])
"
```
Expected: `OK jira-create`

- [ ] **Step 3: 템플릿 참조 링크가 실제 파일을 가리키는지 검증**

Run:
```bash
cd .claude/skills/jira-create && \
grep -o '](templates/[a-z-]*\.md)' SKILL.md | tr -d '](' | tr -d ')' | while read f; do
  test -f "$f" && echo "OK $f" || { echo "MISSING $f"; exit 1; }
done
```
Expected: `OK templates/bug-template.md` and `OK templates/task-template.md`, no `MISSING` lines.

- [ ] **Step 4: Commit**

```bash
git add .claude/skills/jira-create/SKILL.md
git commit -m "feat(jira-create): add Jira ticket creation skill"
```

---

### Task 3: 실제 MCP 도구로 dry-run 검증

**Files:**
- 없음 (코드 변경 없음, 검증만)

**Interfaces:**
- Consumes: Task 2에서 만든 `SKILL.md`의 흐름, 세션에 연결된
  `mcp__atlassian__getVisibleJiraProjects`, `mcp__atlassian__lookupJiraAccountId`
  도구.

- [ ] **Step 1: 스킬 재로드**

Run (사용자 세션에서, 로컬 커맨드로):
```
/reload-skills
```
Expected: 출력에 `jira-create`가 새로 추가된 스킬로 나타남 (또는 스킬 개수가 1 증가).

- [ ] **Step 2: 읽기 전용 도구로 프로젝트 목록 조회 dry-run**

`mcp__atlassian__getVisibleJiraProjects`를 호출해 실제 프로젝트 목록이
반환되는지 확인한다 (쓰기 작업 없음, 안전).

Expected: 최소 1개 이상의 프로젝트(키+이름)가 반환됨. 실패 시 Atlassian
MCP 연결/권한 문제이므로 SKILL.md가 아니라 MCP 서버 설정 문제로 기록한다.

- [ ] **Step 3: 본인 계정 조회 dry-run**

`mcp__atlassian__lookupJiraAccountId`를 현재 사용자 이메일
(`goobghd@gmail.com`)로 호출해 계정 ID가 반환되는지 확인한다.

Expected: accountId 문자열 반환. 이것이 3단계(담당자 지정)에서 스킬이
실제로 사용할 값이다.

- [ ] **Step 4: 실제 티켓 생성은 사용자 승인 하에만**

`createJiraIssue`는 실제 Jira에 쓰기 작업이므로, 사용자에게 "지금 실제
테스트 티켓을 하나 만들어서 전체 흐름을 검증해볼지" 먼저 물어본다.
승인하면 Step 2에서 확인한 프로젝트 중 하나에 SKILL.md 4단계 그대로
따라 실제 이슈를 생성하고, 반환된 키/링크를 사용자에게 보여준 뒤 필요하면
사용자가 직접 삭제/닫기 하도록 안내한다. 승인하지 않으면 이 단계는
건너뛰고 Step 2~3의 읽기 전용 검증만으로 충분한 것으로 기록한다.

- [ ] **Step 5: 결과 기록**

검증 결과(성공/실패, 실제 생성 여부)를 사용자에게 요약해서 보고한다.
코드 변경이 없으므로 별도 커밋 없음.

---

## Self-Review 결과

- **Spec coverage:** 흐름 1(프로젝트/타입 확인)~5(결과 보고) 모두 Task 2의
  SKILL.md 본문에 반영됨. 파일 구조(spec)는 Task 1+2로 정확히 일치.
  범위 밖 항목은 SKILL.md 4단계에 명시적으로 "넣지 않는다"로 남겨 향후
  실수로 추가되지 않도록 함.
- **Placeholder scan:** TBD/TODO 없음. 모든 코드 블록은 실제 내용.
- **Type/참조 일관성:** SKILL.md가 참조하는 템플릿 파일명
  (`bug-template.md`, `task-template.md`)이 Task 1의 산출물과 정확히
  일치. MCP 도구 이름(`getVisibleJiraProjects`,
  `getJiraProjectIssueTypesMetadata`, `lookupJiraAccountId`,
  `createJiraIssue`)은 세션에 실제 등록된 deferred 도구 목록과 일치하는
  것을 확인함.
