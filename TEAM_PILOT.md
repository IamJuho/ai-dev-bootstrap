# Team Pilot Guide

이 문서는 팀원에게 `ai-dev-bootstrap`을 파일럿으로 배포할 때 쓰는 실행 가이드다.
목표는 새 팀원이 기존 세션 맥락 없이도 현재 repo 정책에 맞는 agent stack을 설치하고, 결과를 같은 기준으로 보고하게 만드는 것이다.

## Pilot Scope

권장 파일럿 범위는 Codex 중심의 소수 팀원이다.

- 대상: macOS 또는 Linux에서 Codex를 실제로 쓰는 팀원 3-5명
- 기본 host: `codex`
- 기본 phase: `core`
- 확장 phase: browser, QA, visual review가 필요한 경우에만 `full`
- 제외: 완전 무감독 Claude 롤아웃

Claude는 파일럿에 포함할 수 있지만, `superpowers` plugin 설치와 시각 확인이 수동 단계로 남는다. 따라서 Claude 포함 파일럿은 운영자가 동행하는 별도 트랙으로 본다.

## Success Criteria

파일럿을 성공으로 판단하려면 아래 조건을 만족해야 한다.

- 새 팀원이 README와 이 문서만 보고 `./bin/setup-dev-agents --host codex --phase core`를 실행할 수 있다.
- `./bin/check-dev-agents --host codex --phase core`가 `Result exit code: 0`으로 끝난다.
- browser/QA/visual lane을 쓰는 팀원은 `./bin/check-dev-agents --host codex --phase full`도 `Result exit code: 0`으로 끝난다.
- bootstrap 후 `.agents/`, `.claude/`, `.worktrees/` 산출물이 git working tree에 untracked 변경으로 남지 않는다.
- 팀원이 새 세션에서 `AGENTS.md`의 라우팅 규칙을 이해하고, 완료 전 검증 규칙을 따른다.
- 실패 사례가 생기면 아래 Troubleshooting 섹션 기준으로 재현 로그와 함께 보고된다.

## Prerequisites

공통 요구 사항:

- `git`
- `bun`
- GitHub 접근 가능한 네트워크

Codex 파일럿 요구 사항:

- `codex` CLI
- `~/.codex/config.toml`에 `[features]` 아래 `multi_agent = true`를 쓸 수 있는 권한

Claude 파일럿 추가 요구 사항:

- `claude` CLI
- Claude plugin marketplace 접근
- `superpowers` plugin 설치 후 Claude 재시작

## Pilot Owner Checklist

팀원에게 안내하기 전에 파일럿 운영자가 먼저 확인한다.

```bash
git status --short --branch
./bin/check-dev-agents --host codex --phase core
./bin/check-dev-agents --host codex --phase full
bash tests/phase-bootstrap.test.sh
```

기대 결과:

- `git status --short --branch`에 의도하지 않은 변경이 없어야 한다.
- Codex `core`와 `full` check가 모두 `Result exit code: 0`이어야 한다.
- phase bootstrap test가 `All phase bootstrap tests passed.`로 끝나야 한다.

## Team Member Flow

Codex 기준 기본 경로:

```bash
git pull
./bin/setup-dev-agents --host codex --phase core
./bin/check-dev-agents --host codex --phase core
```

browser, QA, visual review가 필요한 팀원만 `full`로 확장한다.

```bash
./bin/setup-dev-agents --host codex --phase full
./bin/check-dev-agents --host codex --phase full
```

Codex와 Claude를 모두 준비하려면 `auto`를 쓸 수 있다.

```bash
./bin/setup-dev-agents --host auto --phase core
./bin/check-dev-agents --host auto --phase core
```

`auto` 또는 `claude`에서 `Result exit code: 2`가 나오면 자동 실패가 아니라 수동 단계가 남았다는 뜻이다. 출력의 `TODO`를 완료한 뒤 다시 check를 실행한다.

## Claude Manual Step

Claude에서 `superpowers`는 repo-local clone이 아니라 plugin marketplace 설치가 기준이다.

권장 경로:

```text
/plugin install superpowers@claude-plugins-official
```

공식 marketplace가 보이지 않으면 fallback:

```text
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

설치 후 Claude를 재시작하고 아래를 실행한다.

```bash
./bin/check-dev-agents --host claude --phase core
```

현재 check는 Claude plugin 설치를 자동으로 검증하지 못한다. 팀원은 Claude 세션에서 `superpowers`가 실제로 노출되는지 시각적으로 확인해야 한다.

## Exit Code Meaning

`check-dev-agents`의 종료 코드는 파일럿 보고 기준이다.

- `0`: 자동 검증 가능한 항목이 준비됨
- `1`: bootstrap 상태가 깨졌거나 필수 산출물이 누락됨
- `2`: 수동 단계가 남아 있음

운영 기준:

- `0`은 해당 host/phase를 사용할 수 있다.
- `1`은 파일럿 운영자에게 로그와 함께 보고한다.
- `2`는 출력의 `TODO`를 먼저 처리한다. Claude 수동 plugin 단계라면 실패로 보지 않는다.

## Troubleshooting

`git` 또는 `bun`이 없다는 오류:

- 필요한 도구를 설치한 뒤 같은 명령을 다시 실행한다.
- `setup-dev-agents`는 `git`과 `bun`을 필수로 요구한다.

`unsupported platform` 오류:

- 지원 OS는 macOS와 Linux다.
- 다른 OS는 파일럿 범위 밖으로 보고한다.

GitHub clone 또는 network 오류:

- 네트워크와 GitHub 접근 권한을 확인한다.
- `BOOTSTRAP_GSTACK_REPO` 또는 `BOOTSTRAP_SUPERPOWERS_REPO` override를 쓰기 전에 운영자와 합의한다.

`candidate does not satisfy repo policy` 오류:

- upstream 최신 상태가 현재 repo contract와 맞지 않는다는 뜻이다.
- 강제로 진행하지 않는다.
- 출력 로그와 함께 `agent-stack.policy.sh`, 실패한 host, phase를 보고한다.

`refusing to replace non-symlink` 또는 `refusing to replace non-directory` 오류:

- 기존 경로가 예상한 bootstrap 산출물이 아니라는 뜻이다.
- 수동으로 삭제하지 말고 운영자에게 경로와 로그를 전달한다.

`browse binary is missing` 오류:

- `full` phase가 필요한데 browser binary가 준비되지 않은 상태다.
- 아래를 다시 실행한다.

```bash
./bin/setup-dev-agents --host codex --phase full
./bin/check-dev-agents --host codex --phase full
```

`Result exit code: 2`:

- 먼저 출력의 `TODO`를 읽는다.
- Claude plugin 설치나 CLI 설치처럼 수동 단계가 남은 상태일 수 있다.
- Codex-only 파일럿이면 `--host codex`로 다시 확인해 범위를 좁힌다.

## Recovery Notes

`setup-dev-agents`는 새 candidate가 repo policy를 만족하지 못하면 이전 정상 checkout을 복구하도록 설계되어 있다.

운영자가 복구 상태를 확인할 때는 아래 순서로 본다.

```bash
git status --short --branch
./bin/check-dev-agents --host codex --phase core
```

복구 후에도 `check-dev-agents`가 `1`을 반환하면 수동 정리를 하지 말고 로그를 보존한다. bootstrap 산출물은 `.gitignore`에 포함되어 있으므로, tracked 문서를 되돌리는 식의 조치와 bootstrap 산출물 정리를 섞지 않는다.

## Pilot Report Template

팀원은 파일럿 종료 후 아래 형식으로 결과를 공유한다.

```text
Host:
Phase:
OS:
Command run:
Final exit code:
Unexpected output:
Manual steps completed:
Time to ready:
Notes:
```

## Rollout Decision

Codex 파일럿은 아래가 충족되면 다음 팀원 그룹으로 넓힌다.

- 참여자 대부분이 README와 이 문서만으로 `core` check `0`에 도달한다.
- `exit 1` 사례가 재현 가능하고 원인이 문서 또는 script 개선 항목으로 정리된다.
- `exit 2` 사례가 Claude 수동 단계처럼 의도된 manual gate로만 발생한다.
- 운영자가 개입하지 않아도 팀원이 다음 행동을 이해한다.

Claude 포함 롤아웃은 별도 기준을 둔다.

- Claude plugin 설치 경로가 팀 환경에서 안정적으로 재현된다.
- 시각 확인 기준이 팀 내부에서 합의된다.
- `check-dev-agents --host claude --phase core`의 `TODO` 해석이 혼동 없이 전달된다.
