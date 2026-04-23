# Session Runbook

이 문서는 이 저장소에서 세션을 어떻게 시작하고, 구현을 어떻게 열고, 어떻게 종료하거나 재개할지 정리한 운영 런북이다.
규칙의 출처는 `AGENTS.md`와 `agents/*.md`이며, 이 문서는 그 규칙을 실제 세션 흐름으로 압축한 것이다.

## 이 저장소의 기본값

- 이 repo는 git repo다.
- `.worktrees/` 디렉터리가 이미 존재하고 `.gitignore`에 의해 무시된다.
- 따라서 비사소한 repo-tracked 변경의 기본 실행 경로는 `.worktrees/` 아래 worktree를 만들고 그 안에서 작업하는 것이다.

## 세션 시작 순서

1. 먼저 `AGENTS.md`를 읽고 언어 정책과 fast routing을 확인한다.
2. fast path가 아니고 bootstrap 상태가 불명확하면 `./bin/check-dev-agents --host codex --phase core`를 먼저 실행한다.
3. 위 점검이 `1`이면 `./bin/setup-dev-agents --host codex --phase core`로 최소 기반을 맞춘다.
4. 요청이 애매하거나 greenfield면 `agents/routing.md`를 읽는다.
5. 설계나 계획을 잠가야 하면 `agents/planning.md`를 읽는다.
6. repo-tracked 변경이 생기면 `agents/execution.md`를 읽는다.
7. 위험한 명령, 배포, 강한 범위 통제가 필요하면 `agents/safety.md`를 읽는다.
8. 완료를 말하기 직전에는 항상 `agents/verification.md`를 다시 확인한다.

## 구현 시작 규칙

- 아래 중 하나라도 해당하면 worktree를 기본값으로 본다.
- 다중 파일 수정
- 문서 구조 개편
- 설정 수정
- 사용자 대상 흐름 변경
- handoff 가능성이 높은 작업
- 현재 저장소 상태를 바꾸는 비사소한 변경
- browser, QA, visual polish처럼 `browse` 의존 skill이 필요하면 구현 전에 `./bin/check-dev-agents --host codex --phase full`로 전체 bootstrap 상태도 같이 확인한다.

## 현재 작업 공간에 남아도 되는 경우

- 아래 네 조건을 모두 만족할 때만 현재 작업 공간에서 바로 진행한다.
- 단일 파일 수정
- 요구가 명확함
- 위험이 낮음
- 사용자 영향이 없음
- 예시는 문서 한 줄 오탈자, 내부 주석 한 줄 수정, 명백한 wording correction 정도로 제한한다.
- fast path라도 완료 직전의 실제 검증은 생략하지 않는다.

## 세션 중 운영 규칙

- 관련 skill이 있으면 skill 호출이 첫 액션이다.
- 범위가 커지면 바로 구현을 계속하지 말고 lane을 다시 분류한다.
- 기존 문서를 복제하지 말고, 각 문서는 자기 역할만 맡긴다.
- unrelated changes는 되돌리지 않는다.
- 현재 세션에서 확인하지 않은 성공을 말하지 않는다.

## 세션 종료 또는 Handoff

- 아래 상황이면 `gstack-context-save`를 기본 경로로 검토한다.
- 오늘 세션을 마무리할 때
- 다른 세션이나 다른 사람에게 넘길 때
- 아직 미완료 상태인데 긴 중단이 생길 때

## context save에 꼭 남길 것

- 현재 branch와 worktree 경로
- 이번 세션에서 잠근 결정
- 아직 남은 작업
- 마지막으로 실행한 검증 상태
- 다음 세션의 첫 액션

## 다음 세션 재개 순서

1. 저장된 context가 있으면 `gstack-context-restore`로 먼저 복원한다.
2. 현재 branch와 worktree가 의도한 위치인지 확인한다.
3. 필요한 문서만 다시 읽는다. 전 문서를 매번 다 읽지 않는다.
4. 남은 작업이 fast path인지, 다시 plan lane으로 올라가야 하는지 재판단한다.
5. browser/QA/visual review가 필요해졌는데 현재가 `core`라면 `full` bootstrap으로 올릴지 먼저 판단한다.
6. 완료 직전이면 새로 검증을 돌린다.

## 과잉 문서화 방지 기준

- 운영 런북은 실제 세션 행동을 빨리 정렬시키는 데 쓰인다.
- 이미 `agents/*`에 있는 규칙을 세부적으로 다시 쓰기 시작하면 과하다.
- 새 문서를 추가할 때는 "이 문서가 없으면 실제 세션에서 흔들리는가?"를 먼저 묻는다.

## Maintenance Trigger

- 아래 문서의 의미가 바뀌면 이 런북도 같은 변경 안에서 다시 읽고 갱신한다.
- `AGENTS.md`
- `agents/planning.md`
- `agents/execution.md`
- `agents/verification.md`
- `agents/safety.md`
- 기본 isolation 수단, fast path 경계, context save/restore 기대치가 바뀌면 이 문서도 즉시 수정한다.
- 수정 뒤에는 운영 문서의 경로, `AGENTS.md`의 참조, 그리고 현재 repo 상태에 대한 설명이 여전히 맞는지 직접 확인한다.
