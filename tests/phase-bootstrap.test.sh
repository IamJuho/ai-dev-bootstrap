#!/usr/bin/env bash

set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck disable=SC1091
. "$ROOT/bin/_dev-agent-common.sh"

load_agent_stack_policy

failures=0

record_failure() {
  printf 'FAIL  %s\n' "$1" >&2
  failures=$((failures + 1))
}

record_success() {
  printf 'OK    %s\n' "$1"
}

assert_ok() {
  local name="$1"
  shift

  if "$@"; then
    record_success "$name"
  else
    record_failure "$name"
  fi
}

assert_fail() {
  local name="$1"
  shift

  if "$@"; then
    record_failure "$name"
  else
    record_success "$name"
  fi
}

setup_help_mentions_phase() {
  "$ROOT/bin/setup-dev-agents" --help | grep -q -- '--phase core|full'
}

check_help_mentions_phase() {
  "$ROOT/bin/check-dev-agents" --help | grep -q -- '--phase core|full'
}

phase_is_supported() {
  local phase="$1"
  type ensure_supported_phase >/dev/null 2>&1 || return 1
  (ensure_supported_phase "$phase") >/dev/null 2>&1
}

invalid_phase_is_rejected() {
  type ensure_supported_phase >/dev/null 2>&1 || return 1
  if (ensure_supported_phase nope) >/dev/null 2>&1; then
    return 1
  fi
}

array_is_defined() {
  local name="$1"
  declare -p "$name" >/dev/null 2>&1
}

make_fake_skill_tree() {
  local skills_root="$1"
  shift
  local skill=""

  mkdir -p "$skills_root/gstack/.git"
  for skill in "$@"; do
    mkdir -p "$skills_root/$skill"
    touch "$skills_root/$skill/SKILL.md"
  done
}

assert_ok "setup help mentions phase option" setup_help_mentions_phase
assert_ok "check help mentions phase option" check_help_mentions_phase
assert_ok "core phase is supported" phase_is_supported core
assert_ok "full phase is supported" phase_is_supported full
assert_ok "invalid phase is rejected" invalid_phase_is_rejected

tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/phase-bootstrap-test.XXXXXX")"
trap 'rm -rf "$tmpdir"' EXIT

core_root="$tmpdir/core"
full_root="$tmpdir/full"

if array_is_defined REQUIRED_GSTACK_SKILLS_CORE; then
  make_fake_skill_tree "$core_root" "${REQUIRED_GSTACK_SKILLS_CORE[@]}"
  assert_ok "core install is valid without browse binary" gstack_install_is_valid "$core_root" core
  assert_fail "full install requires browse binary and full skills" gstack_install_is_valid "$core_root" full
else
  record_failure "core phase skill contract is defined"
fi

if array_is_defined REQUIRED_GSTACK_SKILLS_FULL; then
  make_fake_skill_tree "$full_root" "${REQUIRED_GSTACK_SKILLS_FULL[@]}"
  mkdir -p "$full_root/gstack/browse/dist"
  touch "$full_root/gstack/browse/dist/browse"
  chmod +x "$full_root/gstack/browse/dist/browse"
  assert_ok "full install is valid with browse binary and full skills" gstack_install_is_valid "$full_root" full
else
  record_failure "full phase skill contract is defined"
fi

if [ "$failures" -ne 0 ]; then
  printf '\n%s phase bootstrap test(s) failed.\n' "$failures" >&2
  exit 1
fi

printf '\nAll phase bootstrap tests passed.\n'
