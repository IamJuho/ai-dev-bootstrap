# Execution Rules

이 문서는 승인된 작업을 실제로 어떻게 실행할지 정한다.
이 문서가 결정하는 것은 `기본 실행 체인`, `fallback`, `범위 통제`다.
이 문서는 각 skill의 내부 단계나 git 전략 전체를 다시 설명하지 않는다.

## Entry Conditions

- 아래 중 하나에 해당하면 이 문서를 읽는다.
- 승인된 spec 또는 plan이 있다.
- 다중 파일 수정이 예상된다.
- 문서 개편처럼 범위가 쉽게 커질 수 있다.
- 사용자 영향이 있는 변경이다.
- 비사소한 구현은 바로 코드부터 시작하지 않는다. 먼저 현재 작업이 `plan 기반 구현`인지 `fast path`인지 분류한다.

## Default Execution Chain

- git repo의 기본 경로는 다음 순서다.
- `using-git-worktrees`
- `subagent-driven-development`
- 세션 종료, handoff, 긴 중단 전에는 `gstack-context-save`
- `verification-before-completion`
- 기능 추가나 버그 수정처럼 동작이 바뀌는 구현은, 실제 코드 변경 전에 `test-driven-development`를 먼저 적용한다.
- `test-driven-development`는 기본 실행 체인과 경쟁하는 별도 진입점이 아니라, 코드 변경 직전의 구현 규칙이다.
- 범위가 명확하지 않으면 구현으로 가지 않고 `agents/planning.md`로 되돌아간다.

## Fallback Modes

- git repo가 아니거나 worktree를 만들 수 없으면:
- `gstack-freeze`를 쓰거나, 응답에서 수정 범위를 명시하고 그 범위만 건드린다.
- subagent를 쓸 수 없으면:
- `executing-plans` 흐름으로 inline 실행한다.
- fast path 네 조건을 모두 만족하면:
- inline execution을 허용한다.
- 이 경우에도 검증은 생략하지 않는다.
- fallback이라고 해서 품질 규칙을 낮추지 않는다. 범위와 검증만 더 엄격하게 본다.
- fallback 경로에서도 세션 전환이 생기면 `gstack-context-save`를 사용하고, 다음 세션은 `gstack-context-restore`로 재개한다.

## Scope Creep Rules

- 요청 범위를 넘는 구조 변경이나 리팩터링은 하지 않는다.
- 구현 도중 범위가 커지면 멈추고 새 경계를 설명한다.
- unrelated changes는 유지한다. revert하지 않는다.
- 기존 변경과 직접 충돌하면 `agents/safety.md` 기준으로 멈추고 확인한다.
