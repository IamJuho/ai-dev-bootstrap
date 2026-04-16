# Codex Router

이 파일은 이 repo의 기본 세션 라우터다. 목적은 간단하다. 첫 액션이 흔들리지 않게 하고, 범위를 좁게 유지하고, 검증 없이 끝났다고 말하지 않게 만든다.

## Language Policy

- 이 프로젝트의 사용자 대상 커뮤니케이션은 기본적으로 한국어로 작성한다.
- 진행 상황, 최종 응답, 리뷰, 계획, 요약, 위험, 가정, 오픈 질문도 특별한 요청이 없으면 한국어로 작성한다.
- 코드, 명령어, 파일 경로, 식별자, API 이름, 로그와 에러 원문은 원문을 유지한다.
- 내부 도구 사용이나 스킬 문서가 영어여도, 사용자에게 보여주는 결과는 한국어로 정리한다.

## Workflow Contract

- relevant skill이 있으면 스킬 호출이 첫 액션이다. 먼저 파일을 뒤지거나 바로 구현부터 시작하지 않는다.
- 기본 우선순위는 `superpowers` 먼저, `gstack-*`는 그 다음이다.
- gstack skill 이름은 항상 `gstack-` prefix로 쓴다.
- 예외는 신규 아이디어, scope 탐색, 제품 방향 논의다. 이런 요청은 `gstack-office-hours`를 첫 액션으로 둔다.
- 비사소한 구현은 승인된 설계나 계획 없이 바로 시작하지 않는다.
- git repo에서는 worktree를 기본 isolation 경로로 본다.
- 코드 변경, 문서 개편, 설정 수정처럼 repo 상태를 바꾸는 작업은 항상 가장 작은 범위로 끝낸다.
- 완료, 해결, 통과를 주장하기 전에는 반드시 `verification-before-completion` 기준으로 실제 검증을 먼저 한다.
- fast path는 아래 네 조건을 모두 만족할 때만 허용한다.
- 단일 파일 수정
- 요구가 명확함
- 위험이 낮음
- 사용자 영향이 없음
- 여러 단계이거나 위험이 있거나 애매하면 라우팅 결정을 짧게 밝히고 관련 문서를 먼저 읽는다.
- 세션을 종료하거나 다른 세션으로 넘길 때는 `checkpoint`를 기본 경로로 검토한다.
- 첫 스킬과 첫 운영 단계는 다를 수 있다. 예를 들어 승인된 계획 구현의 첫 스킬은 `subagent-driven-development`이고, git repo의 기본 운영 단계는 worktree 준비부터 시작한다.

## Fast Routing

- 신규 아이디어, 가치 검증, 방향 탐색: `gstack-office-hours`
- 비사소한 기능 설계, 요구 정제, 구현 전 구조 정리: `brainstorming`
- 승인된 계획의 구현: `subagent-driven-development`, 단 git repo에서는 `using-git-worktrees`가 기본 실행 경로이고 세부 fallback은 `agents/execution.md`를 따른다.
- 버그, 회귀, flaky behavior, 원인 분석: `systematic-debugging`
- UI/UX 계획: `brainstorming`, 이후 필요 시 `gstack-plan-design-review`
- 구현 후 UI polish: `gstack-design-review`
- 코드 리뷰, 정확성 리뷰: `gstack-review`
- 완료 직전 검증: `verification-before-completion`
- 세션 종료, handoff, 작업 재개 준비: `checkpoint`

## Lazy-Loaded References

- `agents/routing.md`: 요청 유형별 첫 스킬, 다음 단계, fast path 예외
- `agents/planning.md`: 아이디어, spec, plan 단계의 게이트와 승인 조건
- `agents/execution.md`: 승인된 작업을 어떻게 실행할지, git/non-git fallback 포함
- `agents/verification.md`: 완료 주장 전 검증, 사용자 영향 변경 검증, shipping 전 확인
- `agents/safety.md`: isolation 우선순위, destructive command 규칙, 기존 변경 충돌 처리
