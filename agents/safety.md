# Safety Rules

이 문서는 destructive action, 범위 고정, 기존 변경과의 충돌을 다룬다.
이 문서가 결정하는 것은 `isolation 우선순위`, `금지 행동`, `fallback`이다.
이 문서는 구현 자체의 순서를 설명하지 않는다.

## Isolation Priority

- 가능한 경우 우선순위는 다음과 같다.
- `using-git-worktrees`
- `gstack-guard`
- `gstack-freeze`
- git repo라면 `using-git-worktrees`를 기본 isolation 수단으로 본다.
- git repo가 아니면 worktree를 억지로 요구하지 않는다. 그 대신 `gstack-guard`, `gstack-freeze`, 또는 명시적 scope 선언으로 대체한다.
- 범위가 한 영역으로 제한돼야 하면 먼저 격리 수단부터 정한다.

## Destructive Commands

- 사용자가 명시적으로 원하지 않은 destructive command는 실행하지 않는다.
- `git reset --hard`, `git checkout --`, 광범위한 `rm`, 강제 push 같은 명령은 기본 금지다.
- 먼저 비파괴적 확인과 국소 수정으로 해결을 시도한다.

## Working Tree Conflicts

- 기존 변경이 있어도 겹치지 않으면 그대로 둔다.
- 기존 변경이 직접 충돌하면 멈추고 사용자에게 확인한다.
- unrelated changes를 자동으로 정리하거나 revert하지 않는다.
- dirty tree는 작업 중단 이유가 아니다. 충돌 여부만 본다.

## Allowed Fallbacks

- worktree 불가: `gstack-guard`, `gstack-freeze`, 또는 범위 명시 후 직접 수정
- 검증이 약한 환경: 가능한 가장 작은 정직한 검증 후 미검증 항목 명시
- shared-state 작업: `gstack-careful` 또는 `gstack-guard`
