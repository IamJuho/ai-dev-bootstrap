# Routing Dry Run

이 문서는 라우터를 실제 요청 예시로 빠르게 점검하기 위한 운영 문서다.
새 규칙을 만드는 문서가 아니라, 이미 정의된 `AGENTS.md`, `agents/routing.md`, `agents/planning.md`, `agents/execution.md`가 일관되게 작동하는지 확인하는 샘플 세트다.

## 사용 목적

- 첫 스킬이 흔들릴 때, 실제 요청을 어떤 lane으로 넣어야 하는지 빠르게 검산한다.
- fast path를 허용해도 되는지, 아니면 worktree와 검증이 필요한지 운영 관점에서 확인한다.
- 라우터 수정 전후에 dry run을 돌려서, 문서가 과해졌는지 또는 구멍이 생겼는지 확인한다.

## Dry Run Table

| 요청 예시 | 분류 | 첫 스킬 | 첫 운영 단계 | 왜 이렇게 가는가 |
| --- | --- | --- | --- | --- |
| "이 아이디어가 실제로 만들 가치가 있을까?" | 아이디어 | `gstack-office-hours` | 아이디어 정리와 문제 정의를 남긴다 | 신규 아이디어는 구현보다 problem framing이 먼저다 |
| "기능은 대충 정했는데 요구와 구조가 아직 흐릿해" | 설계 | `brainstorming` | `agents/planning.md`를 따라 `Spec Lane`으로 정리한다 | 구현 전에 요구와 경계를 잠가야 한다 |
| "승인된 계획대로 이번 작업을 진행해줘" | 계획된 구현 | `subagent-driven-development` | git repo 기본 경로인 `using-git-worktrees`부터 시작한다 | 이 repo는 git 기반이며 비사소한 변경은 isolation이 기본이다 |
| "어제부터 로그인 회귀가 생겼는데 원인을 모르겠어" | 버그 | `systematic-debugging` | 증상과 재현 조건을 고정하고, 수정 직전 `test-driven-development`를 적용한다 | 원인 확인 없이 바로 고치면 재발과 오진 위험이 크다 |
| "이 흐름의 UX가 어색한지 구현 전에 봐줘" | UI/UX 설계 | `brainstorming` | 필요 시 `gstack-plan-design-review`를 넣어 설계를 다듬는다 | UX는 구현 전 설계 검증이 비용 대비 효율이 높다 |
| "이미 만든 화면이 좀 AI스럽다. 마감 전에 다듬어줘" | UI polish | `gstack-design-review` | 시각적 증거와 함께 polish 항목을 반영한다 | 구현 후 visual QA는 설계 문서보다 실제 결과물을 봐야 한다 |
| "이 변경셋이 안전한지 리뷰해줘" | 리뷰 | `gstack-review` | 필요한 경우 `verification-before-completion`로 사실 여부를 잠근다 | 리뷰는 정확성, 위험, 누락을 먼저 본다 |
| "이제 끝난 것 같은데 완료라고 말해도 돼?" | 완료 직전 검증 | `verification-before-completion` | 주장에 대응하는 검증 명령을 바로 실행한다 | 증거 없이 완료를 말하면 라우터 목적이 무너진다 |
| "오늘은 여기까지 하고 다음 세션에서 이어가자" | 세션 종료 | `checkpoint` | 현재 branch, worktree, 결정 사항, 남은 작업을 저장한다 | handoff 복원성이 없으면 다음 세션에서 맥락 비용이 커진다 |
| "문서 한 줄 오탈자만 고쳐줘" | 작은 로컬 수정 | 관련 스킬 없음 또는 현재 컨텍스트 유지 | 현재 작업 공간에서 바로 수정하고 최소 검증만 한다 | 네 가지 fast path 조건을 모두 만족하는 예외다 |

## Fast Path Sanity Check

- 아래 네 조건을 모두 만족하면 현재 작업 공간에서 바로 수정할 수 있다.
- 단일 파일 수정
- 요구가 명확함
- 위험이 낮음
- 사용자 영향이 없음
- 하나라도 아니면 fast path가 아니다. 이 문서의 목적은 "될 것 같음"이 아니라 "조건이 모두 맞는지"를 확인하는 데 있다.

## Drift Signals

- 설계가 비어 있는데 바로 구현 스킬부터 호출한다.
- git repo인데 다중 파일 변경을 main 작업 공간에서 바로 시작한다.
- `agents/*`의 규칙을 새 운영 문서가 다시 장황하게 복제한다.
- `gstack-*` 이름에서 prefix를 빼먹는다.
- 완료 주장 전에 검증 명령이 없다.
- 세션을 끊는데 `checkpoint`를 전혀 고려하지 않는다.

## 유지 원칙

- 이 문서는 새 규칙을 추가하지 않는다.
- dry run 예시는 자주 들어오는 요청 유형만 남기고, 드문 케이스는 기존 라우팅 문서에 맡긴다.
- 예시가 늘어날수록 품질이 좋아지는 문서가 아니다. 현재 라우터를 흔드는 경계 사례만 유지한다.

## Maintenance Trigger

- 아래 문서의 의미가 바뀌면 이 문서도 같은 브랜치에서 함께 점검한다.
- `AGENTS.md`
- `agents/routing.md`
- `agents/planning.md`
- `agents/execution.md`
- 첫 스킬, fast path 기준, git repo 기본 실행 경로가 바뀌면 Dry Run Table을 즉시 갱신한다.
- 점검 후에는 `scripts/validate-operations-docs.sh`를 실행해 경로와 핵심 계약이 살아 있는지 확인한다.
