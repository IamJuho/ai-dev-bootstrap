# AI Agent Bootstrap

이 저장소는 프로젝트별 AI 개발 라우팅 문서와, 팀원이 `git pull` 직후 현재 프로젝트 정책에 맞는 최신 agent stack으로 정렬할 수 있는 bootstrap 스크립트를 함께 제공한다.

기준 문서는 다음 두 가지다.

- `AGENTS.md`: Codex 기준 라우터이자 저장소의 단일 기준 문서
- `CLAUDE.md`: Claude용 얇은 진입 문서. 핵심 규칙은 `AGENTS.md`를 따른다

## 목표

- 저장소 안에서 공통 라우팅 문서(`AGENTS.md`, `agents/*.md`)를 유지한다.
- repo-local `gstack`는 최신 upstream 기준으로 자동 준비한다.
- `superpowers`는 Codex에서는 최신 compatible 상태로 자동 준비하고, Claude에서는 marketplace 설치를 안내한다.
- 새 팀원이 기존 세션 맥락 없이도 동일한 초기 상태를 빠르게 맞출 수 있게 한다.

## 지원 범위

- OS: macOS, Linux

자동 준비:

- Codex용 repo-local `gstack`
- Claude용 repo-local `gstack`
- Codex용 `superpowers` checkout, symlink, `multi_agent = true`

수동 준비:

- Claude용 `superpowers` plugin 설치와 확인

## 빠른 시작

저장소 루트에서 실행한다.

```bash
./bin/setup-dev-agents --host codex
./bin/check-dev-agents --host codex
```

자주 쓰는 모드:

- `--host codex`: 가장 단순한 기본 권장 경로다.
- `--host auto`: Codex + Claude 경로를 모두 준비한다. Claude `superpowers`는 수동 단계가 남으므로 정상 동작이어도 종료 코드는 `2`가 될 수 있다.
- `--host claude`: Claude 기준으로만 준비하고 점검한다.

## 필요한 도구

- 공통: `git`, `bun`

선택:

- Codex를 실제로 사용할 경우 `codex`
- Claude를 실제로 사용할 경우 `claude`

`setup-dev-agents`는 에이전트 바이너리가 없어도 repo-local bootstrap은 가능한 범위까지 진행한다. 다만 해당 에이전트를 실제로 쓰려면 각 CLI가 설치되어 있어야 한다.

## 스크립트가 하는 일

`bin/setup-dev-agents`

- policy 파일(`agent-stack.policy.sh`)을 기준으로 현재 프로젝트가 기대하는 contract를 읽는다.
- 각 upstream repo의 default branch 최신 상태를 가져와 최신 compatible 설치를 시도한다.
- `.agents/skills/gstack`
- `.claude/skills/gstack`
- 각 checkout 안에서 upstream `./setup`을 호출해 repo-local skill entry를 생성한다.
- repo-local `gstack` 업데이트는 해당 `gstack` checkout 디렉토리만 교체하고, 같은 skills 루트의 다른 내용은 보존한 채 필요한 sibling skill entry를 다시 생성한다.
- Codex 경로에서는 `superpowers`를 `~/.codex/superpowers`에 최신 compatible 상태로 맞추고, `~/.agents/skills/superpowers` symlink를 만든다.
- `~/.codex/config.toml`의 `[features]` 아래에 `multi_agent = true`를 보장한다.
- Claude용 `superpowers`는 자동 설치하지 않고 marketplace 명령을 출력한다.
- 업데이트 도중 새 설치가 정책을 만족하지 못하면 이전 정상본으로 복구한다.

`bin/check-dev-agents`

- 현재 로컬 설치가 `agent-stack.policy.sh`의 contract를 만족하는지 확인한다.
- ref pin 여부는 확인하지 않는다.
- Codex `superpowers` symlink와 `multi_agent = true` 상태를 확인한다.
- Claude `superpowers`는 자동 검증하지 않는다.
- 수동 확인이 남아 있으면 종료 코드 `2`를 반환한다.

종료 코드:

- `0`: 자동으로 검증 가능한 항목이 모두 준비됨
- `1`: bootstrap이 깨졌거나 필수 산출물이 누락됨
- `2`: 수동 단계가 남아 있음

## Claude `superpowers` 수동 단계

Claude에서 `superpowers`는 repo가 아니라 plugin marketplace 설치가 기준이다. 이 저장소는 그 단계만 안내하고, 설치 자체는 자동으로 하지 않는다.

권장 경로:

```text
/plugin install superpowers@claude-plugins-official
```

공식 marketplace가 보이지 않으면 fallback:

```text
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

설치 후 Claude를 다시 시작한다.

## 호환 정책

이 저장소는 exact version pin보다 **호환 정책 기반**으로 agent stack을 운영한다.
기계가 읽는 기준은 `agent-stack.policy.sh`, 사람이 읽는 기준은 `agents/tool-contract.md`다.

공식 운영 흐름:

```bash
git pull
./bin/setup-dev-agents --host codex
./bin/check-dev-agents --host codex
```

branch를 바꾸거나 프로젝트 문서가 업데이트된 뒤에는 `setup-dev-agents`를 다시 실행해 현재 프로젝트 정책에 맞는 최신 compatible 상태로 재정렬한다.

## 참고

- `docs/operations/*`는 운영 예시다. 초기 bootstrap 경로의 필수 문서는 아니다.
- repo-local vendored checkout은 `.gitignore`에 포함되어 있어, bootstrap 실행 후에도 working tree에 bootstrap 산출물이 untracked로 남지 않는다.
