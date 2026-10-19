# 지표 정의 및 조회 참고

도구 이름·스키마는 실행 환경에서 확인한다. 아래 쿼리는 서비스·이벤트 의미를 보존하기 위한 예이며, 과거 실행 결과가 아니다.

## 시간·범위

KST 날짜는 `[당일 00:00, 다음날 00:00)`로 집계한다. 두 경계를 UTC로 변환한다(예: KST 00:00 = 전날 15:00Z). 오늘 부분 집계는 종료 시각을 표시한다. UTC 자정으로 정렬되는 24시간 버킷을 KST 일자로 라벨링하지 않는다. KST 구간별 집계 또는 UTC 시간별 집계를 KST로 재그룹화한다. API의 경계 포함·제외 규칙을 확인해 인접 구간 중복을 방지한다.

## RUM

공통 사용자 필터:

```text
service:foms-fe env:prod @usr.id:* -@usr.id:1
```

| 목적 | 추가 필터 | 집계 |
|---|---|---|
| 사용 확인 계정·클릭 | `@type:action @action.type:click` | 사용자 ID별 COUNT |
| 최초 확인 클릭 | 위 클릭 조건 | timestamp 오름차순 첫 기록; 보존기간 내 최초라고 명시 |
| 조회 제출 | `@type:action @action.type:custom @action.name:"[search] submitted"` | COUNT; 결과 배송 수 아님 |
| 집품 설정 변경 | `@type:action @action.type:custom @action.name:shipments_gms_picking_success` | COUNT 및 SUM(`@context.count`) |
| 포장순번 생성 | `@type:action @action.type:custom @action.name:shipments_packing_sequences_success` | COUNT 및 SUM(`@context.count`) |

사용자별 표의 그룹 키는 `@usr.id`를 기준으로 유지하고 이름·로그인 ID를 표시 정보로 연결한다. 이름 변경으로 나뉜 버킷을 별도 인물로 세지 않는다. 다중 그룹의 버킷 제한·잘림·페이지를 확인하고 식별 사용자 합계와 전체 식별 사용자 COUNT를 대조한다.

변경 업무 수행 계정은 현재 코드의 `shipments_*_success` 중 실제 변경 작업만 포함한다. `shipments_work_order_lookup_success`는 조회이므로 제외한다. 새 이벤트는 이름만 보고 판정하지 말고 호출 지점을 확인한다.

업무 사용 일수(요청 시)는 조회 제출·작업지시서 조회·변경 성공·엑셀 다운로드 중 하나라도 발생한 **서로 다른 KST 날짜 수**다. 그리드 스냅샷은 자동 기록이므로 제외한다. 날짜별 고유 사용자 집계로 구하며 일자별 cardinality를 총계로 합치지 않는다. 페이지 수·기능 수의 cardinality도 일자별 합계와 전체 고유 수를 혼동하지 않는다.

## 서버 로그

```text
service:mario env:prod message:"배송 변경 이벤트 처리 성공"
```

로그 표본에서 실제 형식을 확인한다. 알려진 형식:

```text
배송 변경 이벤트 처리 성공. eventType=ShipmentGmsPickingEnabledChangedEvent, count=...
```

로그 횟수는 실행/처리 성공 로그 수, `count` 합계는 동기화 이벤트 항목 수다. 원천 로그가 Mario 전체임을 표시하며 FOMS 전용 성공 요청 수라고 단정하지 않는다.

`analyze_datadog_logs`처럼 기간을 바인딩한 virtual logs table 도구에서 쓸 수 있는 예:

```sql
SELECT
  TO_CHAR(TO_TIMESTAMP(EXTRACT(EPOCH FROM timestamp) + 32400), 'YYYY-MM-DD') AS kst_date,
  SPLIT_PART(SPLIT_PART(message, 'eventType=', 2), ',', 1) AS event_type,
  COUNT(*) AS executions,
  SUM(CAST(SPLIT_PART(message, 'count=', 2) AS BIGINT)) AS targets
FROM logs
GROUP BY
  TO_CHAR(TO_TIMESTAMP(EXTRACT(EPOCH FROM timestamp) + 32400), 'YYYY-MM-DD'),
  SPLIT_PART(SPLIT_PART(message, 'eventType=', 2), ',', 1)
ORDER BY
  TO_CHAR(TO_TIMESTAMP(EXTRACT(EPOCH FROM timestamp) + 32400), 'YYYY-MM-DD'),
  SPLIT_PART(SPLIT_PART(message, 'eventType=', 2), ',', 1)
```

다른 DDSQL 실행 도구에서는 `dd.logs(...)` PTF 등의 스키마가 필요할 수 있다. 현재 도구 가이드에 맞춘다.

## 表示名対応

| 내부 이름 | 보고서 표시 |
|---|---|
| `shipments_gms_picking_success` / `ShipmentGmsPickingEnabledChangedEvent` | 집품 설정 변경 |
| `shipments_packing_sequences_success` / `ShipmentPackingSequenceChangedEvent` | 포장순번 생성 |
| `ShipmentPackingAgencyChangedEvent` | 포장대행사 변경 |
| `ShipmentPalletNumberChangedEvent` | 팔레트 번호 변경 |
| `ShipmentHoldChangedEvent` | 보류·해제 |
| `ShipmentPackingBoxChangedEvent` | 포장박스 변경 |
| `ShipmentRealWeightChangedEvent` | 실중량 변경 |

## 배송 분모 및 대조

- 배송 수 이미지·SQL 결과에는 원래 컬럼명, 기간, 집계 조건의 확인 여부를 붙인다. `shipping_instruction_created_date`는 배송지시 생성일이며 이벤트 처리일과 동일 배송 집단임을 보장하지 않는다.
- 비율 = 이벤트 대상 수 합계 / 일자별 배송 수 × 100. 분모가 0·미제공·결측이면 미산출로 표시하며 0%로 바꾸지 않는다.
- 일치를 주장하기 전에 기간·관리자 조건·실행 횟수·대상 수를 대조한다. 성공 응답 시각·동기화 완료 시각·지연 재시도에 따라 날짜가 달라질 수 있다.
- 실제 브라우저 활동 시간은 단순 view/session 체류시간으로 측정할 수 없다. 방치된 탭 시간을 생산성에 사용하지 않는다.
