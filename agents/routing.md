# 라우팅 규칙

이 문서는 요청이 애매하거나, greenfield이거나, 비사소한 구현이라 첫 스킬이 흔들릴 때 읽는다.
이 문서가 결정하는 것은 `첫 스킬`과 `다음 단계`다.
이 문서는 각 skill의 내부 절차를 다시 설명하지 않는다.

## Routing Order

- 먼저 요청을 분류한다. `아이디어`, `설계`, `계획된 구현`, `버그`, `리뷰`, `배포`, `작은 로컬 수정`.
- 분류가 끝나면 relevant skill을 첫 액션으로 호출한다.
- fast path는 `단일 파일`, `요구 명확`, `위험 낮음`, `사용자 영향 없음`을 모두 만족할 때만 허용한다.
- 하나라도 아니면 skill-first로 간다.

## Decision Table

| 요청 유형 | 첫 스킬 | 다음 단계 | Fast Path |
| --- | --- | --- | --- |
| 신규 아이디어, 가치 검증, 방향 탐색 | `gstack-office-hours` | `brainstorming` | 불가 |
| 비사소한 기능 설계, 요구 정제, 구현 전 구조 정리 | `brainstorming` | `agents/planning.md` 확인 후, 가능하면 `using-git-worktrees` 검토 뒤 `writing-plans` | 불가 |
| 승인된 spec 또는 plan 기반 구현 | `subagent-driven-development` | 기본 실행 경로와 fallback은 `agents/execution.md`를 따르고, 코드 변경은 그 안에서 `test-driven-development` 적용 | 조건부 |
| 버그, 회귀, flaky behavior, 테스트 실패 | `systematic-debugging` | fix 단계에서 `test-driven-development` | 불가 |
| UI/UX가 포함된 기능 설계 | `brainstorming` | `writing-plans`, 설계 검증이 필요하면 `gstack-plan-design-review` | 불가 |
| 구현 후 UI polish, 시각적 QA | `gstack-design-review` | 필요 시 `gstack-qa` | 불가 |
| 코드 리뷰, 정확성 리뷰, PR 전 점검 | `gstack-review` | 필요 시 `verification-before-completion` | 불가 |
| ship, deploy, release 확인 | `verification-before-completion` | `gstack-review`, `gstack-qa`, 이후 ship/deploy flow | 불가 |
| 세션 종료, handoff, 이후 재개 준비 | `checkpoint` | 다음 세션에서 복원 가능한 상태 저장 | 불가 |
| 작은 로컬 수정 | 없음 또는 관련 skill | 바로 수정 후 검증 | 가능 |

## Fast Path Gate

- 아래 네 조건을 모두 만족할 때만 fast path를 쓴다.
- 단일 파일 수정
- 요구가 명확함
- 위험이 낮음
- 사용자 영향이 없음
- fast path에서도 다음 규칙은 유지한다.
- 범위를 넓히지 않는다.
- unrelated changes는 건드리지 않는다.
- 완료 주장 전에는 실제 검증을 한다.
- fast path 예시:
- 오탈자 수정
- 내부 주석 정리
- 명백한 문서 한 줄 수정
- fast path 비예시:
- 기능 추가
- 버그 수정
- 사용자 흐름 변경
- 다중 파일 수정
- 설정 변경으로 동작이 달라지는 작업

## Anti-Patterns

- 스킬 확인 전에 파일 탐색부터 시작하기
- spec이나 승인 없이 비사소한 구현 시작하기
- root cause 확인 없이 버그를 감으로 고치기
- 테스트나 검증 없이 “완료”, “해결”, “통과”라고 말하기
- multi-step 작업을 fast path로 밀어붙이기
- skill 본문을 로컬 문서가 대신 복제하기
- 아이디어 단계 결론을 기록 없이 대화로만 끝내기
