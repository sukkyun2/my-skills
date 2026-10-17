---
name: datadog-my-services
description: Apply the user's mario and gms-java-api service defaults and prod environment when querying Datadog logs, traces, metrics, or service health. Use for Datadog investigations of these services, requests about the user's services, or operational investigations in their repositories.
---

# Datadog 담당 서비스

Datadog 조회에 아래 기본값을 자동 적용한다. 기존 Datadog MCP 연결을 사용한다.

## 기본 범위

| 저장소 이름 | Datadog service | 기본 환경 |
| --- | --- | --- |
| mario | mario | prod |
| gms-java-api | gms-java-api | prod |

- 요청에 서비스나 환경이 명시되어 있으면 각각 해당 값을 우선한다. 다른 서비스나 `dev` 조회도 가능하다.
- 서비스가 생략되면 현재 작업 저장소의 루트 이름으로 위 표에서 선택한다. worktree에서는 원본 저장소를 확인한다.
- 위 두 저장소가 아니거나 저장소 문맥이 없으면 두 서비스를 함께 조회한다. 예: FBK에서 서비스명을 생략한 Datadog 요청.
- 시간 범위가 생략되면 최근 1시간부터 조회한다. 사용자가 지정한 범위는 유지한다. 사용자에게 시간을 표시할 때는 Asia/Seoul(KST)을 사용한다.
- 기본값 때문에 서비스나 환경을 다시 묻지 않는다. 적용한 서비스·환경·기간은 결과에 짧게 표시한다.

## 조회

- 사용 가능한 Datadog MCP 도구를 사용하고, 도구가 요구하는 도메인별 가이드를 조회 전에 로드한다. 이 스킬은 개인 기본값만 추가하며 도메인 가이드를 복제하지 않는다.
- 로그·스팬 검색의 기본 필터는 아래와 같다. 추가 조건에 OR가 있으면 괄호로 묶어 서비스·환경 범위를 유지한다.

```text
service:mario env:prod
service:gms-java-api env:prod
(service:mario OR service:gms-java-api) env:prod
```

- 메트릭은 해당 도구의 태그 필터 문법으로 service·env를 적용한다. 서비스 카탈로그 등 환경 필터를 지원하지 않는 도구에 억지로 붙이지 않는다.
- 사용자가 제공한 trace ID나 Datadog 링크는 해당 대상을 우선 조회한다. 전체 trace에서 다른 서비스의 관련 span도 확인할 수 있도록 기본 서비스 필터로 호출 관계를 잘라내지 않는다.
- 결과가 비어도 서비스·환경 필터를 몰래 제거하지 않는다. 조회 범위와 데이터 유무를 구분해 알리고, 필요하면 같은 서비스·환경의 기간을 넓힌다.
- 로그 표본만으로 전체 오류 건수나 장애 부재를 단정하지 않는다. 건수·비율에는 집계 도구를 사용한다.
- 조사 결과는 확인된 증거와 추정을 구분하고 Datadog 결과 링크 또는 trace ID를 붙인다. 로그의 토큰·비밀번호·개인정보는 출력에 그대로 복사하지 않는다.

## 적용 예

- mario 저장소에서 “Datadog 에러 확인해줘” → mario / prod / 최근 1시간.
- gms-java-api 저장소에서 “dev 로그 봐줘” → gms-java-api / dev / 최근 1시간.
- 다른 저장소에서 “내 서비스들 상태 확인해줘” → mario와 gms-java-api / prod / 최근 1시간.
- “mario 어제 오후 3~4시 로그 봐줘” → mario / prod / 어제 15:00~16:00 KST.

이 스킬의 자동 설정은 조회 기본값이다. 모니터·대시보드 생성이나 Agent·MCP 설정 변경은 별도 요청이 있을 때 수행한다.
