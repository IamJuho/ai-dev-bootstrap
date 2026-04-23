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

array_contains_value() {
  local needle="$1"
  shift
  local value=""

  for value in "$@"; do
    [ "$value" = "$needle" ] && return 0
  done

  return 1
}

array_lacks_value() {
  local needle="$1"
  shift

  ! array_contains_value "$needle" "$@"
}

codex_superpowers_mode_is_repo_local() {
  [ "$CODEX_SUPERPOWERS_MODE" = "repo_local_checkout_with_home_symlinks" ]
}

make_fake_scattered_gstack_tree() {
  local skills_root="$1"
  shift
  local skill=""

  mkdir -p "$skills_root/gstack/.git"
  for skill in "$@"; do
    mkdir -p "$skills_root/$skill"
    touch "$skills_root/$skill/SKILL.md"
  done
}

make_fake_repo_local_gstack_tree() {
  local skills_root="$1"
  shift
  local skill=""

  mkdir -p "$skills_root/gstack/.git" "$skills_root/gstack/.agents/skills"
  for skill in "$@"; do
    mkdir -p "$skills_root/gstack/.agents/skills/$skill"
    touch "$skills_root/gstack/.agents/skills/$skill/SKILL.md"
  done
}

make_fake_superpowers_repo() {
  local repo_dir="$1"
  shift
  local skill=""

  mkdir -p "$repo_dir/.git" "$repo_dir/skills"
  for skill in "$@"; do
    mkdir -p "$repo_dir/skills/$skill"
    touch "$repo_dir/skills/$skill/SKILL.md"
  done
}

make_fake_codex_config() {
  local config_file="$1"

  mkdir -p "$(dirname "$config_file")"
  cat >"$config_file" <<'EOF'
[features]
multi_agent = true
EOF
}

assert_ok "setup help mentions phase option" setup_help_mentions_phase
assert_ok "check help mentions phase option" check_help_mentions_phase
assert_ok "core phase is supported" phase_is_supported core
assert_ok "full phase is supported" phase_is_supported full
assert_ok "invalid phase is rejected" invalid_phase_is_rejected
assert_ok "codex superpowers mode uses repo-local checkout with home symlinks" codex_superpowers_mode_is_repo_local

tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/phase-bootstrap-test.XXXXXX")"
trap 'rm -rf "$tmpdir"' EXIT

core_root="$tmpdir/core"
full_root="$tmpdir/full"
superpowers_root="$tmpdir/repo/.agents/skills/superpowers"
codex_superpowers_link="$tmpdir/home/.codex/superpowers"
codex_skills_link="$tmpdir/home/.agents/skills/superpowers"
codex_config="$tmpdir/home/.codex/config.toml"

if array_is_defined REQUIRED_GSTACK_SKILLS_CORE; then
  assert_ok "core contract requires context-save skill" array_contains_value "gstack-context-save" "${REQUIRED_GSTACK_SKILLS_CORE[@]}"
  assert_ok "core contract requires context-restore skill" array_contains_value "gstack-context-restore" "${REQUIRED_GSTACK_SKILLS_CORE[@]}"
  assert_ok "core contract excludes deprecated checkpoint skill" array_lacks_value "gstack-checkpoint" "${REQUIRED_GSTACK_SKILLS_CORE[@]}"
  make_fake_repo_local_gstack_tree "$core_root" "${REQUIRED_GSTACK_SKILLS_CORE[@]}"
  assert_ok "core install is valid without browse binary" gstack_install_is_valid "$core_root" core
  assert_fail "full install requires browse binary and full skills" gstack_install_is_valid "$core_root" full
else
  record_failure "core phase skill contract is defined"
fi

if array_is_defined REQUIRED_GSTACK_SKILLS_FULL; then
  make_fake_repo_local_gstack_tree "$full_root" "${REQUIRED_GSTACK_SKILLS_FULL[@]}"
  mkdir -p "$full_root/gstack/browse/dist"
  touch "$full_root/gstack/browse/dist/browse"
  chmod +x "$full_root/gstack/browse/dist/browse"
  assert_ok "full install is valid with browse binary and full skills" gstack_install_is_valid "$full_root" full

  scattered_root="$tmpdir/scattered"
  make_fake_scattered_gstack_tree "$scattered_root" "${REQUIRED_GSTACK_SKILLS_FULL[@]}"
  mkdir -p "$scattered_root/gstack/browse/dist"
  touch "$scattered_root/gstack/browse/dist/browse"
  chmod +x "$scattered_root/gstack/browse/dist/browse"
  assert_fail "gstack install rejects scattered top-level skill links" gstack_install_is_valid "$scattered_root" full
else
  record_failure "full phase skill contract is defined"
fi

if array_is_defined REQUIRED_SUPERPOWERS_SKILLS; then
  make_fake_superpowers_repo "$superpowers_root" "${REQUIRED_SUPERPOWERS_SKILLS[@]}"
  make_fake_codex_config "$codex_config"
  mkdir -p "$(dirname "$codex_superpowers_link")" "$(dirname "$codex_skills_link")"
  ln -s "$superpowers_root" "$codex_superpowers_link"
  ln -s "$superpowers_root/skills" "$codex_skills_link"
  assert_ok "codex superpowers install is valid with repo-local checkout and home symlinks" codex_superpowers_install_is_valid "$superpowers_root" "$codex_superpowers_link" "$codex_skills_link" "$codex_config"
else
  record_failure "superpowers skill contract is defined"
fi

if [ "$failures" -ne 0 ]; then
  printf '\n%s phase bootstrap test(s) failed.\n' "$failures" >&2
  exit 1
fi

printf '\nAll phase bootstrap tests passed.\n'
