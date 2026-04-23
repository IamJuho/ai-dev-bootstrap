# AI Agent Bootstrap

팀원이 `git pull` 직후 현재 프로젝트 정책에 맞는 AI agent stack을 맞추는 bootstrap repo다.

기본 경로는 **Codex + core phase**다. Claude나 browser/QA 기능은 필요할 때만 추가로 준비한다.

## Quick Start

필요한 것:

- `git`
- `bun`
- `codex` CLI
- Windows Git Bash/MSYS 계열에서 `full` phase를 쓰는 경우 `node`

저장소 루트에서 실행한다.

```bash
git pull
./bin/setup-dev-agents --host codex --phase core
./bin/check-dev-agents --host codex --phase core
```

성공 기준:

```text
Result exit code: 0
```

## Install Via AI Agent

Codex, Claude, Omo 같은 AI agent에게 이 repo URL을 주고 진행 중인 git repo에
설치하게 하려면 `docs/operations/ai-agent-install.md`를 기준으로 진행한다.

기본 요청 예시:

```text
현재 git repo에 https://github.com/IamJuho/ai-dev-bootstrap 를 설치해줘.
host는 codex, phase는 core로 시작하고, 기존 AGENTS.md/CLAUDE.md는 덮어쓰지 말고 병합해줘.
설치 후 check-dev-agents가 0으로 끝나는지 검증해줘.
```

## When You Need Browser / QA

`gstack-browse`, `gstack-qa`, `gstack-qa-only`, `gstack-design-review`가 필요할 때만 `full`로 올린다.
Windows 11 Git Bash/MSYS 계열에서는 `gstack browse`가 Node fallback을 쓰므로 `node`가 PATH에 있어야 한다.

```bash
./bin/setup-dev-agents --host codex --phase full
./bin/check-dev-agents --host codex --phase full
```

## Exit Codes

- `0`: 준비 완료
- `1`: bootstrap이 깨졌거나 필수 항목이 없음
- `2`: 수동 단계가 남아 있음

`2`는 항상 실패가 아니다. 특히 Claude는 plugin 설치 확인이 수동이라 `2`가 나올 수 있다.

## Claude Users

Claude용 repo-local `gstack`는 자동 준비된다. `superpowers`는 Claude plugin marketplace에서 직접 설치해야 한다.

```text
/plugin install superpowers@claude-plugins-official
```

공식 marketplace가 보이지 않으면:

```text
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

설치 후 Claude를 재시작하고 확인한다.

```bash
./bin/check-dev-agents --host claude --phase core
```

## Team Pilot

팀원 파일럿 배포는 `TEAM_PILOT.md`를 따른다.

파일럿 기본값:

- 대상: Codex 사용자
- OS: macOS, Linux, 또는 Windows 11 Git Bash/MSYS 계열
- host: `codex`
- phase: `core`
- 성공 기준: `check-dev-agents`가 `Result exit code: 0`

## What This Repo Maintains

- `AGENTS.md`: Codex 기준 라우터
- `CLAUDE.md`: Claude용 얇은 진입 문서
- `agents/*.md`: 라우팅, 계획, 실행, 검증, 안전 규칙
- `agent-stack.policy.sh`: 기계가 읽는 호환 정책
- `bin/setup-dev-agents`: 현재 정책에 맞게 agent stack 준비
- `bin/check-dev-agents`: 현재 설치 상태 검증
- `.agents/skills/gstack`, `.agents/skills/superpowers`: bootstrap이 만드는 repo-local agent checkout
- gstack 개별 skill은 `.agents/skills/gstack/.agents/skills/gstack-*` 아래에 모인다.

## Notes

- 지원 OS는 macOS, Linux, Windows 11 Git Bash/MSYS 계열이다.
- WSL은 기존 Linux 경로로 처리한다.
- PowerShell native bootstrap은 지원 범위 밖이다. Windows에서는 Git Bash/MSYS 계열 shell에서 실행한다.
- 이 repo는 exact version pin 대신 최신 compatible upstream을 따른다.
- bootstrap 산출물인 `.agents/`, `.claude/`, `.worktrees/`는 git에 남지 않도록 ignore된다.
- Codex 호환을 위해 `~/.codex/superpowers`와 `~/.agents/skills/superpowers`는 repo-local `.agents/skills/superpowers`로 연결된다. macOS/Linux에서는 symlink, Windows Git Bash/MSYS에서는 directory junction일 수 있다.
- Codex gstack skill은 repo 최상위 `.agents/skills/gstack-*`로 흩어지지 않는다.
- 상세 계약은 `agents/tool-contract.md`, 운영 예시는 `docs/operations/*`를 본다.

## License

MIT. See `LICENSE`.
