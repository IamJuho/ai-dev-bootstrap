# Planning Lane

이 문서는 pre-code 단계에서 어떤 lane으로 들어가야 하는지 정한다.
이 문서가 결정하는 것은 `지금 아이디어 단계인지`, `spec 단계인지`, `plan 단계인지`다.
이 문서는 각 skill의 세부 절차를 복제하지 않는다.

## Planning Lanes

### Idea Lane

- 언제 들어오나:
- 신규 아이디어
- 가치 검증
- problem framing
- scope가 흔들리는 요청
- 첫 스킬:
- `gstack-office-hours`
- 종료 조건:
- 무엇을 풀지, 누구를 위한 일인지, scope를 어느 정도까지 잡을지 설명할 수 있다.
- 다음 단계:
- 구현 가능한 설계로 내려가야 하면 `Spec Lane`으로 간다.

### Spec Lane

- 언제 들어오나:
- 기능은 정해졌지만 요구, 구조, 흐름이 아직 모호하다.
- 구현 전에 설계와 승인 게이트가 필요하다.
- 첫 스킬:
- `brainstorming`
- 종료 조건:
- 설계 설명이 정리됐고, 사용자가 spec 수준으로 승인했다.
- 다음 단계:
- 구현 계획이 필요하면 `Plan Lane`으로 간다.

### Plan Lane

- 언제 들어오나:
- 승인된 spec이 있다.
- 이제 구현 순서와 실행 단위를 잠가야 한다.
- 첫 액션:
- git repo 여부를 먼저 판단한다.
- git repo이면 `using-git-worktrees`
- git repo가 아니면 바로 `writing-plans`
- 종료 조건:
- 구현 순서, 주요 경계, 검증 방식이 plan 수준으로 정리됐다.
- 다음 단계:
- 구현으로 넘어가면 `agents/execution.md`를 따른다.

## Required Artifacts

- `Idea Lane`의 산출물은 문제 정의와 scope 결정이다. 후속 설계나 구현이 이어질 예정이면 다음 세션에서 복원 가능한 짧은 요약을 반드시 남긴다.
- `Spec Lane`의 산출물은 승인된 설계 또는 spec이다.
- `Plan Lane`의 산출물은 승인된 구현 계획이다.
- spec과 plan의 파일 위치는 각 skill의 기본 규칙을 따른다. 이 repo 문서는 경로를 다시 정의하지 않는다.

## Approval Gates

- `Idea Lane`에서 `Spec Lane`으로 갈 때:
- 해결할 문제와 범위가 설명 가능해야 한다.
- `Spec Lane`에서 `Plan Lane`으로 갈 때:
- 사용자가 설계 방향에 동의해야 한다.
- `Plan Lane`에서 구현으로 갈 때:
- 작업 단위와 검증 방식이 plan에 들어 있어야 한다.
- git repo인 경우 isolation 결정까지 끝나 있어야 한다.
- 조건부 review 삽입 규칙:
- 제품 방향이나 wedge가 흔들리면 `gstack-plan-ceo-review`
- 구현 구조와 경계를 잠그기 직전이면 `gstack-plan-eng-review`
- UI/UX가 핵심이면 `gstack-plan-design-review`

## Git / Non-Git Fallback

- git repo이고 이후 구현이 이어질 예정이면, `Plan Lane` 진입 시점에 `using-git-worktrees`를 기본 경로로 먼저 적용한다.
- git repo가 아니거나 worktree를 만들 수 없으면, 구현 단계에서 `gstack-freeze` 또는 명시적 scope 선언으로 대체한다.
- worktree는 기본 경로다. 절대 강제 규칙은 아니다.
