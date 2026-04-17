# Tool Contract

이 문서는 이 저장소가 기대하는 `gstack`과 `superpowers`의 호환 계약을 사람이 읽는 기준으로 정리한다.
기계가 읽는 기준은 저장소 루트의 `agent-stack.policy.sh`다.

## 목적

- 이 repo가 정확한 version pin이 아니라 **호환 계약**에 의존한다는 점을 명시한다.
- upstream가 바뀌어도 이 계약이 유지되면 repo 문서는 수정하지 않는다.
- 계약이 바뀌는 업데이트일 때만 `AGENTS.md`, `CLAUDE.md`, `README.md`, `agents/*.md`, `agent-stack.policy.sh`를 같이 갱신한다.
- `agent-stack.policy.sh`에 선언된 host/platform 지원 범위가 실제 bootstrap/check 판정에도 그대로 반영된다고 본다.

## Superpowers Contract

- process discipline의 기본 스택으로 `superpowers`를 사용한다.
- 이 repo가 직접 기대하는 핵심 skill은 아래다.
- `brainstorming`
- `executing-plans`
- `subagent-driven-development`
- `systematic-debugging`
- `test-driven-development`
- `using-git-worktrees`
- `verification-before-completion`
- `writing-plans`
- Codex 환경에서는 `~/.codex/config.toml`의 `[features]` 아래 `multi_agent = true`가 유지되어야 한다.
- Codex에서는 `~/.codex/superpowers` checkout과 `~/.agents/skills/superpowers` symlink가 연결되어야 한다.
- 이 repo의 checkpoint workflow는 현재 `gstack-checkpoint`로 충족된다고 본다.
- Claude에서는 `superpowers`를 repo-local clone으로 직접 쓰지 않는다. marketplace/plugin 경로가 canonical이다.

## Gstack Contract

- specialist review, browser QA, release workflow는 `gstack-*`를 사용한다.
- 이 repo는 gstack skill 이름이 항상 `gstack-` prefix를 유지한다고 가정한다.
- 이 repo는 phase별 contract를 구분한다.
- `core`는 planning, review, non-browser specialist 경로를 여는 최소 contract다.
- `full`은 `core` 위에 browser/QA/visual polish contract를 추가한다.

### Gstack Core Contract

- 이 repo가 `core`에서 직접 기대하는 핵심 skill은 아래다.
- `gstack-careful`
- `gstack-checkpoint`
- `gstack-freeze`
- `gstack-guard`
- `gstack-office-hours`
- `gstack-plan-ceo-review`
- `gstack-plan-design-review`
- `gstack-plan-eng-review`
- `gstack-review`
- repo-local bootstrap 후 `gstack` checkout 자체와 core-required sibling skill entry가 `.agents/skills/` 또는 `.claude/skills/`에 생성되어야 한다.
- `core`에서는 browser-dependent skill entry를 repo-local 노출에서 숨겨도 contract 위반이 아니다.

### Gstack Full Contract

- `full`은 `core` 위에 아래 skill을 추가로 기대한다.
- `gstack-browse`
- `gstack-design-review`
- `gstack-qa`
- `gstack-qa-only`
- repo-local `full` bootstrap 후 `.agents/skills/gstack`와 `.claude/skills/gstack` 아래 `browse/dist/browse`가 존재해야 한다.
- repo-local `full` bootstrap 후 browser-dependent sibling skill entry도 `.agents/skills/` 또는 `.claude/skills/`에 생성되어야 한다.

## Update Policy

- `./bin/setup-dev-agents`는 upstream default branch 최신 상태를 가져오고, 현재 repo contract를 만족하는지 확인한 뒤에만 설치를 승격한다.
- 최신 candidate가 contract를 만족하지 못하면 설치를 복구하고 실패로 끝낸다.
- repo-local `gstack` 업데이트는 skills 루트 전체가 아니라 해당 `gstack` checkout 디렉토리만 교체하고, 필요한 sibling skill entry만 다시 생성한다.
- `./bin/check-dev-agents`는 현재 로컬 설치가 contract를 만족하는지만 검증한다. 환경을 변경하지 않는다.
- `core`는 기본 권장 bootstrap phase고, `full`은 browser/QA/visual review가 실제로 필요할 때만 올린다.
- 따라서 이 repo의 공식 운영 흐름은 아래다.
- `git pull`
- `./bin/setup-dev-agents --host <codex|claude|auto> --phase core`
- `./bin/check-dev-agents --host <codex|claude|auto> --phase core`
- browser/QA/visual review가 필요하면 같은 host에 `--phase full`을 다시 실행한다.

## Contract Drift Trigger

아래 중 하나라도 바뀌면 이 문서와 `agent-stack.policy.sh`를 같이 갱신한다.

- skill 이름 변경
- `gstack-` prefix 규칙 변경
- Codex `multi_agent` 요구 변경
- Codex/Claude host activation 방식 변경
- bootstrap phase(`core`/`full`) 의미 변경
- repo-local bootstrap 산출물 경로 변경
- `setup-dev-agents`나 `check-dev-agents`의 의미 변경
