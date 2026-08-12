# Commit Convention (Conventional Commits)

## Header

```
<type>(<scope>): <subject>
```

- `type` — one of: `feat` `fix` `docs` `style` `refactor` `perf` `test` `build` `ci` `chore` `revert`
- `scope` — optional, lowercase kebab-case, the module/dir the change touches (e.g. `auth`, `api`)
- `subject` — imperative mood ("add", not "added"/"adds"), no trailing period, ≤ 72 chars total header

Breaking change: append `!` after type/scope — `feat(api)!: drop v1 endpoints`.

## Language

`type`/`scope`는 Conventional Commits 규격이라 영어 키워드를 그대로 쓴다
(`feat`, `fix`, ...). `subject`와 body는 **한글**로 작성한다.

## Body

- Blank line between header and body.
- Wrap lines at ~72 chars (한글은 줄당 대략 36자 기준).
- Explain **what** changed and **why**, not how (the diff already shows how).
- Bullet points (`- `) are fine for multiple points.

## Footer (optional)

- `BREAKING CHANGE: <description>`
- `Closes #123` / `Refs #123`

## Example

```
feat(login): 로그인 API에 rate limiting 추가

반복된 로그인 실패 요청을 제한하지 않아 무차별 대입 공격에 노출되어
있었음. 기존 Redis rate-limit 스토어를 활용해 IP당 분당 5회로 제한.

Closes #482
```

## Type reference

| type | when to use |
|---|---|
| feat | new user-facing feature |
| fix | bug fix |
| docs | documentation only |
| style | formatting, no logic change |
| refactor | code change that neither fixes a bug nor adds a feature |
| perf | performance improvement |
| test | adding/fixing tests |
| build | build system or dependencies |
| ci | CI configuration |
| chore | maintenance, no src/test change |
| revert | reverts a previous commit |
