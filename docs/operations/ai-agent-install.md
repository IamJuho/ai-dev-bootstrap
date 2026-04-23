# AI Agent Install Guide

이 문서는 사용자가 Codex, Claude, Omo 같은 AI agent에게 git repo 주소를 주고
"설치해줘"라고 요청했을 때 agent가 따라야 하는 설치 절차다.

목표는 `ai-dev-bootstrap`을 진행 중인 target git repo에 안전하게 이식하고,
설치 후 `setup-dev-agents`와 `check-dev-agents`로 실제 동작을 검증하는 것이다.

## User Prompt

사용자는 AI agent에게 아래처럼 요청할 수 있다.

```text
현재 git repo에 아래 bootstrap을 설치해줘.

Bootstrap repo:
https://github.com/IamJuho/ai-dev-bootstrap

기본값:
- host: codex
- phase: core
- 기존 AGENTS.md, CLAUDE.md, README.md는 덮어쓰지 말고 병합해줘.
- 설치 후 check-dev-agents가 0으로 끝나는지 검증해줘.
```

target repo가 현재 작업 디렉터리가 아니라면 target repo 주소도 같이 준다.

```text
아래 target repo에 bootstrap을 설치해줘.

Target repo:
<target-git-url>

Bootstrap repo:
https://github.com/IamJuho/ai-dev-bootstrap
```

## Agent Defaults

- 기본 host는 `codex`다.
- 기본 phase는 `core`다.
- `full`은 browser, QA, visual review가 실제로 필요할 때만 사용한다.
- 지원 shell은 macOS/Linux POSIX shell과 Windows 11 Git Bash/MSYS 계열이다.
- PowerShell native bootstrap은 이 절차의 지원 범위가 아니다.
- target repo가 git repo가 아니면 설치하지 말고 멈춘다.
- 기존 파일은 덮어쓰지 않는다. 특히 `AGENTS.md`, `CLAUDE.md`, `README.md`,
  `.gitignore`는 병합 대상이다.
- remote repo에서 받은 script는 실행 전에 먼저 읽는다.
- 설치 후 검증 없이 "완료"라고 말하지 않는다.

## Install Algorithm

### 1. 대상 repo 확정

현재 디렉터리가 target repo인지 확인한다.

```bash
git rev-parse --show-toplevel
git status --short --branch
```

사용자가 target repo URL을 줬고 현재 디렉터리가 target이 아니면, 별도 작업
디렉터리에 clone한다.

```bash
git clone <target-git-url> <target-dir>
cd <target-dir>
```

기존 변경이 있어도 바로 중단하지 않는다. 다만 bootstrap이 바꿀 파일과 겹치면
멈추고 사용자에게 확인한다.

### 2. bootstrap repo를 임시 clone

source repo는 항상 임시 위치에 clone한다. target repo 안에 바로 clone하지 않는다.

```bash
BOOTSTRAP_SRC="$(mktemp -d)"
git clone --depth 1 <bootstrap-git-url> "$BOOTSTRAP_SRC"
```

다음 파일을 먼저 읽고 설치 정책을 확인한다.

```text
README.md
AGENTS.md
agent-stack.policy.sh
bin/setup-dev-agents
bin/check-dev-agents
bin/_dev-agent-common.sh
```

### 3. 설치 파일 복사

target repo에 아래 파일과 디렉터리를 이식한다.

```text
AGENTS.md
CLAUDE.md
agents/
agent-stack.policy.sh
bin/setup-dev-agents
bin/check-dev-agents
bin/_dev-agent-common.sh
tests/phase-bootstrap.test.sh
docs/operations/session-runbook.md
docs/operations/routing-dry-run.md
docs/operations/ai-agent-install.md
```

병합 규칙:

- `agent-stack.policy.sh`, `bin/*`, `agents/*`, `tests/phase-bootstrap.test.sh`는
  target repo에 없으면 그대로 복사한다.
- 같은 경로의 파일이 이미 있으면 내용을 비교하고, bootstrap 관련 파일인지
  확신할 수 있을 때만 교체한다.
- target repo의 기존 `AGENTS.md`가 있으면 덮어쓰지 않는다. 기존 지침을 보존하고,
  bootstrap 라우팅 섹션만 추가하거나 별도 섹션으로 병합한다.
- target repo의 기존 `CLAUDE.md`가 있으면 덮어쓰지 않는다. 기존 Claude 지침을
  보존하고 bootstrap 진입점만 추가한다.
- target repo의 기존 `README.md`는 기본적으로 수정하지 않는다. 사용자가 원하면
  "AI agent bootstrap" 섹션을 짧게 추가한다.
- `.gitignore`에는 아래 항목이 없을 때만 추가한다.

```gitignore
.agents/
.claude/
.worktrees/
worktrees/
```

### 4. bootstrap 실행

기본 설치는 Codex core다.

```bash
./bin/setup-dev-agents --host codex --phase core
./bin/check-dev-agents --host codex --phase core
```

browser, QA, visual review가 필요하다는 요구가 있으면 그때만 full로 올린다.
Windows 11 Git Bash/MSYS 계열에서 `full` phase를 실행할 때는 `node`가 PATH에 있어야 한다.

```bash
./bin/setup-dev-agents --host codex --phase full
./bin/check-dev-agents --host codex --phase full
```

Claude까지 준비해야 하면 `auto` 또는 `claude`를 쓸 수 있다. 단, Claude의
`superpowers` plugin은 marketplace 수동 설치가 남을 수 있으므로 exit code `2`는
항상 실패가 아니다.

```bash
./bin/setup-dev-agents --host auto --phase core
./bin/check-dev-agents --host auto --phase core
```

### 5. 검증

완료 전에 아래를 실행한다.

```bash
./bin/check-dev-agents --host codex --phase core
bash tests/phase-bootstrap.test.sh
git diff --check
```

성공 기준:

- `check-dev-agents`가 `Result exit code: 0`을 출력한다.
- phase bootstrap test가 `All phase bootstrap tests passed.`를 출력한다.
- `git diff --check`가 whitespace error 없이 끝난다.
- `.agents/`, `.claude/`, `.worktrees/` 산출물이 untracked 변경으로 남지 않는다.

Windows Git Bash/MSYS 계열에서 Codex `full`을 검증한다면 추가로 아래를 확인한다.

```bash
./bin/setup-dev-agents --host codex --phase full
./bin/check-dev-agents --host codex --phase full
.agents/skills/gstack/browse/dist/browse --help
```

upstream 산출물이 `.exe` 이름으로 만들어진 경우 마지막 명령은 `.agents/skills/gstack/browse/dist/browse.exe --help`로 확인한다.

## Safety Rules

- `git reset --hard`, `git checkout --`, 광범위한 `rm`을 쓰지 않는다.
- 기존 target repo 지침을 bootstrap 지침으로 대체하지 않는다.
- target repo에 이미 agent 라우팅 정책이 있으면 병합 충돌로 보고 사용자에게
  확인한다.
- network 오류나 dependency 설치 오류가 나면 로그를 보존하고 재시도 여부를
  사용자에게 확인한다.
- `BOOTSTRAP_GSTACK_REPO`, `BOOTSTRAP_SUPERPOWERS_REPO` override는 사용자가
  명시적으로 요청했을 때만 쓴다.

## Completion Report

설치가 끝나면 agent는 아래 항목을 보고한다.

```text
Status: DONE | DONE_WITH_CONCERNS | BLOCKED
Target repo:
Bootstrap repo:
Host:
Phase:
Files changed:
Verification:
Exit codes:
Manual steps remaining:
Risks or conflicts:
```

`check-dev-agents`가 `1`이면 `DONE`이라고 말하지 않는다. `2`이면 수동 단계가
남은 상태로 보고하고, 출력의 `TODO`를 다음 액션으로 적는다.
