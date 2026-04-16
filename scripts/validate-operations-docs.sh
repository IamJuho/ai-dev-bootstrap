#!/usr/bin/env bash

set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)

require_file() {
  local path="$1"
  if [[ ! -f "$ROOT/$path" ]]; then
    echo "missing file: $path" >&2
    exit 1
  fi
}

require_text() {
  local path="$1"
  local pattern="$2"
  if ! grep -Fq "$pattern" "$ROOT/$path"; then
    echo "missing text in $path: $pattern" >&2
    exit 1
  fi
}

require_file "AGENTS.md"
require_file "agents/routing.md"
require_file "agents/planning.md"
require_file "agents/execution.md"
require_file "agents/verification.md"
require_file "agents/safety.md"
require_file "docs/operations/routing-dry-run.md"
require_file "docs/operations/session-runbook.md"

require_text "AGENTS.md" "docs/operations/routing-dry-run.md"
require_text "AGENTS.md" "docs/operations/session-runbook.md"

require_text "docs/operations/routing-dry-run.md" "새 규칙을 만드는 문서가 아니라"
require_text "docs/operations/routing-dry-run.md" "using-git-worktrees"
require_text "docs/operations/routing-dry-run.md" "verification-before-completion"
require_text "docs/operations/routing-dry-run.md" "checkpoint"
require_text "docs/operations/routing-dry-run.md" "scripts/validate-operations-docs.sh"

require_text "docs/operations/session-runbook.md" ".worktrees/"
require_text "docs/operations/session-runbook.md" "agents/verification.md"
require_text "docs/operations/session-runbook.md" "fast path라도 완료 직전의 실제 검증은 생략하지 않는다."
require_text "docs/operations/session-runbook.md" "scripts/validate-operations-docs.sh"

require_text ".gitignore" ".worktrees/"

echo "operations docs validation: ok"
