#!/usr/bin/env bash

set -euo pipefail

DEV_AGENT_SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEV_AGENT_REPO_ROOT="$(CDPATH= cd -- "$DEV_AGENT_SCRIPT_DIR/.." && pwd)"
DEV_AGENT_HOME="${DEV_AGENT_HOME:-$HOME}"
DEV_AGENT_POLICY_FILE="$DEV_AGENT_REPO_ROOT/agent-stack.policy.sh"

log() {
  printf '%s\n' "$*"
}

warn() {
  printf 'warning: %s\n' "$*" >&2
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

load_agent_stack_policy() {
  [ -f "$DEV_AGENT_POLICY_FILE" ] || die "policy file not found: $DEV_AGENT_POLICY_FILE"

  # shellcheck disable=SC1090
  . "$DEV_AGENT_POLICY_FILE"

  : "${POLICY_VERSION:?missing POLICY_VERSION}"
  : "${GSTACK_REPO:?missing GSTACK_REPO}"
  : "${SUPERPOWERS_REPO:?missing SUPERPOWERS_REPO}"
  : "${GSTACK_TRACK_MODE:?missing GSTACK_TRACK_MODE}"
  : "${SUPERPOWERS_TRACK_MODE:?missing SUPERPOWERS_TRACK_MODE}"
  : "${SUPPORTED_HOSTS:?missing SUPPORTED_HOSTS}"
  : "${SUPPORTED_PLATFORMS:?missing SUPPORTED_PLATFORMS}"
  : "${SUPPORTED_PHASES:?missing SUPPORTED_PHASES}"
  : "${DEFAULT_BOOTSTRAP_PHASE:?missing DEFAULT_BOOTSTRAP_PHASE}"
  : "${REQUIRED_GSTACK_PREFIX:?missing REQUIRED_GSTACK_PREFIX}"
  : "${REQUIRED_CODEX_FEATURE_MULTI_AGENT:?missing REQUIRED_CODEX_FEATURE_MULTI_AGENT}"
  : "${CLAUDE_SUPERPOWERS_MODE:?missing CLAUDE_SUPERPOWERS_MODE}"
  : "${CODEX_SUPERPOWERS_MODE:?missing CODEX_SUPERPOWERS_MODE}"

  GSTACK_REPO="${BOOTSTRAP_GSTACK_REPO:-$GSTACK_REPO}"
  SUPERPOWERS_REPO="${BOOTSTRAP_SUPERPOWERS_REPO:-$SUPERPOWERS_REPO}"

  validate_policy_contract
}

current_platform_raw() {
  if [ -n "${DEV_AGENT_UNAME_OVERRIDE:-}" ]; then
    printf '%s\n' "$DEV_AGENT_UNAME_OVERRIDE"
    return 0
  fi

  uname -s
}

normalize_platform() {
  local raw="$1"

  case "$raw" in
    Darwin) printf 'Darwin\n' ;;
    Linux) printf 'Linux\n' ;;
    MINGW*|MSYS*|CYGWIN*|Windows_NT) printf 'Windows\n' ;;
    *) printf '%s\n' "$raw" ;;
  esac
}

current_platform() {
  normalize_platform "$(current_platform_raw)"
}

platform_is_windows() {
  [ "$(current_platform)" = "Windows" ]
}

value_in_word_list() {
  local needle="$1"
  shift
  local item=""

  for item in "$@"; do
    [ "$item" = "$needle" ] && return 0
  done

  return 1
}

platform_is_supported() {
  local platform=""

  platform="$(current_platform)"
  # shellcheck disable=SC2086
  value_in_word_list "$platform" $SUPPORTED_PLATFORMS
}

ensure_supported_platform() {
  platform_is_supported || die "unsupported platform: $(current_platform) (supported: $SUPPORTED_PLATFORMS)"
}

ensure_supported_host() {
  local host="$1"

  # shellcheck disable=SC2086
  value_in_word_list "$host" $SUPPORTED_HOSTS || die "unsupported host: $host (supported: $SUPPORTED_HOSTS)"
}

ensure_supported_phase() {
  local phase="$1"

  # shellcheck disable=SC2086
  value_in_word_list "$phase" $SUPPORTED_PHASES || die "unsupported phase: $phase (supported: $SUPPORTED_PHASES)"
}

ensure_command() {
  command -v "$1" >/dev/null 2>&1 || die "'$1' is required"
}

host_includes_codex() {
  case "$1" in
    auto|codex) return 0 ;;
    *) return 1 ;;
  esac
}

host_includes_claude() {
  case "$1" in
    auto|claude) return 0 ;;
    *) return 1 ;;
  esac
}

git_head() {
  git -C "$1" rev-parse HEAD
}

git_remote_default_branch() {
  local repo="$1"
  local ref=""

  ref="$(git ls-remote --symref "$repo" HEAD 2>/dev/null | awk '/^ref:/ {print $2; exit}')"
  [ -n "$ref" ] || die "failed to resolve default branch for $repo"

  printf '%s\n' "${ref#refs/heads/}"
}

git_clone_latest_default_branch() {
  local repo="$1"
  local target="$2"
  local branch=""

  [ ! -e "$target" ] || die "target already exists: $target"

  branch="$(git_remote_default_branch "$repo")"
  mkdir -p "$(dirname "$target")"
  git clone --depth 1 --single-branch --branch "$branch" "$repo" "$target"
}

windows_path() {
  local path="$1"

  if command -v cygpath >/dev/null 2>&1; then
    cygpath -w "$path"
  else
    printf '%s\n' "$path"
  fi
}

windows_reparse_point_exists() {
  local path="$1"
  local fsutil_cmd=""
  local path_win=""

  platform_is_windows || return 1

  if windows_reparse_point_target "$path" >/dev/null 2>&1; then
    return 0
  fi

  fsutil_cmd="$(command -v fsutil.exe 2>/dev/null || command -v fsutil 2>/dev/null || true)"
  [ -n "$fsutil_cmd" ] || return 1

  path_win="$(windows_path "$path")"
  "$fsutil_cmd" reparsepoint query "$path_win" >/dev/null 2>&1
}

windows_reparse_point_target() {
  local path="$1"
  local fsutil_cmd=""
  local powershell_cmd=""
  local path_win=""
  local target=""

  platform_is_windows || return 1

  path_win="$(windows_path "$path")"
  powershell_cmd="$(command -v powershell.exe 2>/dev/null || command -v pwsh.exe 2>/dev/null || true)"
  if [ -n "$powershell_cmd" ]; then
    target="$("$powershell_cmd" -NoProfile -Command 'param([string]$Path) $item = Get-Item -LiteralPath $Path -Force; if ($item.Target) { $item.Target } elseif ($item.LinkTarget) { $item.LinkTarget }' "$path_win" 2>/dev/null | tr -d '\r' | sed -n '1p')"
    if [ -n "$target" ]; then
      printf '%s\n' "$target"
      return 0
    fi
  fi

  fsutil_cmd="$(command -v fsutil.exe 2>/dev/null || command -v fsutil 2>/dev/null || true)"
  [ -n "$fsutil_cmd" ] || return 1

  "$fsutil_cmd" reparsepoint query "$path_win" 2>/dev/null | awk '
    /^[[:space:]]*Print Name[[:space:]]*:/ {
      sub(/^[^:]*:[[:space:]]*/, "")
      print
      found = 1
      exit
    }
    END { exit found ? 0 : 1 }
  '
}

normalize_windows_path_for_compare() {
  printf '%s\n' "$1" |
    tr '\\' '/' |
    sed 's#^/??/##; s#^//[?]/##; s#/*$##' |
    tr '[:upper:]' '[:lower:]'
}

windows_paths_match() {
  local actual="$1"
  local expected="$2"

  [ "$(normalize_windows_path_for_compare "$actual")" = "$(normalize_windows_path_for_compare "$expected")" ]
}

path_is_link_dir() {
  local path="$1"

  [ -L "$path" ] || windows_reparse_point_exists "$path"
}

remove_link_dir() {
  local path="$1"
  local cmd_cmd=""
  local path_win=""

  [ -n "$path" ] || return 0
  [ -e "$path" ] || [ -L "$path" ] || return 0

  if [ -L "$path" ]; then
    rm -f "$path"
    return 0
  fi

  if windows_reparse_point_exists "$path"; then
    cmd_cmd="$(command -v cmd.exe 2>/dev/null || command -v cmd 2>/dev/null || true)"
    [ -n "$cmd_cmd" ] || die "cmd.exe is required to remove Windows junction: $path"
    path_win="$(windows_path "$path")"
    MSYS2_ARG_CONV_EXCL='*' "$cmd_cmd" /d /c rmdir "$path_win" >/dev/null || die "failed to remove Windows junction: $path"
    return 0
  fi

  die "refusing to remove non-link directory path: $path"
}

create_windows_junction_dir() {
  local src="$1"
  local dst="$2"
  local cmd_cmd=""
  local src_win=""
  local dst_win=""

  [ -d "$src" ] || die "junction source directory does not exist: $src"

  cmd_cmd="$(command -v cmd.exe 2>/dev/null || command -v cmd 2>/dev/null || true)"
  [ -n "$cmd_cmd" ] || die "cmd.exe is required to create Windows junction: $dst"

  src_win="$(windows_path "$src")"
  dst_win="$(windows_path "$dst")"
  MSYS2_ARG_CONV_EXCL='*' "$cmd_cmd" /d /c mklink /J "$dst_win" "$src_win" >/dev/null || die "failed to create Windows junction: $dst -> $src"
}

ensure_symlink_dir() {
  local src="$1"
  local dst="$2"

  [ -d "$src" ] || die "link source directory does not exist: $src"
  mkdir -p "$(dirname "$dst")"

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ -d "$dst" ] && path_dir_resolves_to "$dst" "$src"; then
      return 0
    fi
    remove_link_dir "$dst"
  fi

  if platform_is_windows; then
    create_windows_junction_dir "$src" "$dst"
  else
    ln -snf "$src" "$dst"
  fi
}

path_dir_resolves_to() {
  local actual_path="$1"
  local expected_path="$2"
  local actual_resolved=""
  local expected_resolved=""
  local actual_windows_target=""
  local expected_windows_path=""

  [ -d "$expected_path" ] || return 1

  actual_resolved="$(readlink -f -- "$actual_path" 2>/dev/null || true)"
  expected_resolved="$(readlink -f -- "$expected_path" 2>/dev/null || true)"
  if [ -n "$actual_resolved" ] && [ -n "$expected_resolved" ]; then
    if [ "$actual_resolved" = "$expected_resolved" ]; then
      return 0
    fi
    if platform_is_windows && windows_paths_match "$actual_resolved" "$expected_resolved"; then
      return 0
    fi
  fi

  if platform_is_windows; then
    actual_windows_target="$(windows_reparse_point_target "$actual_path" 2>/dev/null || true)"
    if [ -n "$actual_windows_target" ]; then
      expected_windows_path="$(windows_path "$expected_path")"
      windows_paths_match "$actual_windows_target" "$expected_windows_path" && return 0
    fi
  fi

  [ -d "$actual_path" ] || return 1

  actual_resolved="$(CDPATH= cd -- "$actual_path" 2>/dev/null && pwd -P)" || return 1
  expected_resolved="$(CDPATH= cd -- "$expected_path" 2>/dev/null && pwd -P)" || return 1

  if [ "$actual_resolved" = "$expected_resolved" ]; then
    return 0
  fi

  return 1
}

config_has_multi_agent_true() {
  local config_file="$1"

  [ -f "$config_file" ] || return 1

  awk '
    BEGIN { in_features = 0; found = 0 }
    /^\[features\][[:space:]]*$/ { in_features = 1; next }
    /^\[[^]]+\][[:space:]]*$/ { in_features = 0 }
    in_features && /^[[:space:]]*multi_agent[[:space:]]*=[[:space:]]*true([[:space:]]*#.*)?$/ { found = 1 }
    END { exit found ? 0 : 1 }
  ' "$config_file"
}

ensure_codex_multi_agent() {
  local config_file="$1"
  local tmp_file=""

  mkdir -p "$(dirname "$config_file")"

  if [ ! -f "$config_file" ]; then
    cat > "$config_file" <<'EOF'
[features]
multi_agent = true
EOF
    return 0
  fi

  tmp_file="$(mktemp)"

  awk '
    BEGIN {
      in_features = 0
      features_seen = 0
      multi_written = 0
    }
    function write_multi() {
      print "multi_agent = true"
      multi_written = 1
    }
    {
      if ($0 ~ /^\[features\][[:space:]]*$/) {
        features_seen = 1
        in_features = 1
        print
        next
      }

      if (in_features && $0 ~ /^\[[^]]+\][[:space:]]*$/) {
        if (!multi_written) {
          write_multi()
        }
        in_features = 0
        print
        next
      }

      if (in_features && $0 ~ /^[[:space:]]*multi_agent[[:space:]]*=/) {
        if (!multi_written) {
          write_multi()
        }
        next
      }

      print
    }
    END {
      if (in_features && !multi_written) {
        write_multi()
      }

      if (!features_seen) {
        if (NR > 0) {
          print ""
        }
        print "[features]"
        print "multi_agent = true"
      }
    }
  ' "$config_file" > "$tmp_file"

  mv "$tmp_file" "$config_file"
}

safe_remove_dir() {
  local target="$1"

  [ -n "$target" ] || return 0
  [ -e "$target" ] || [ -L "$target" ] || return 0

  if path_is_link_dir "$target"; then
    remove_link_dir "$target"
    return 0
  fi

  rm -rf "$target"
}

validate_policy_contract() {
  local skill=""

  for skill in "${REQUIRED_GSTACK_SKILLS_FULL[@]}"; do
    case "$skill" in
      "$REQUIRED_GSTACK_PREFIX"*) ;;
      *)
        die "gstack skill does not match required prefix '$REQUIRED_GSTACK_PREFIX': $skill"
        ;;
    esac
  done
}

list_missing_skills() {
  local skills_root="$1"
  shift
  local skill=""
  local missing=0

  for skill in "$@"; do
    if [ ! -f "$skills_root/$skill/SKILL.md" ]; then
      printf '%s\n' "$skill"
      missing=1
    fi
  done

  return "$missing"
}

gstack_generated_skills_root() {
  local skills_root="$1"

  printf '%s\n' "$skills_root/gstack/.agents/skills"
}

phase_requires_browse_binary() {
  local phase="$1"

  case "$phase" in
    full) return 0 ;;
    core) return 1 ;;
    *)
      die "unsupported phase for browse requirement: $phase"
      ;;
  esac
}

phase_requires_node() {
  local phase="$1"

  [ "$phase" = "full" ] && platform_is_windows
}

gstack_browse_binary_path() {
  local checkout_dir="$1"
  local candidate=""

  for candidate in "$checkout_dir/browse/dist/browse" "$checkout_dir/browse/dist/browse.exe"; do
    if [ -f "$candidate" ] && { [ -x "$candidate" ] || platform_is_windows; }; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

gstack_browse_binary_hint() {
  local checkout_dir="$1"

  printf '%s\n' "$checkout_dir/browse/dist/browse[.exe]"
}

phase_excludes_gstack_skill() {
  local phase="$1"
  local skill_name="$2"
  local excluded_skill=""

  case "$phase" in
    full)
      return 1
      ;;
    core)
      for excluded_skill in "${CORE_EXCLUDED_GSTACK_SKILLS[@]}"; do
        [ "$excluded_skill" = "$skill_name" ] && return 0
      done
      return 1
      ;;
    *)
      die "unsupported phase for excluded skill lookup: $phase"
      ;;
  esac
}

list_missing_phase_gstack_skills() {
  local skills_root="$1"
  local phase="$2"
  local generated_skills_root=""

  generated_skills_root="$(gstack_generated_skills_root "$skills_root")"

  case "$phase" in
    core)
      list_missing_skills "$generated_skills_root" "${REQUIRED_GSTACK_SKILLS_CORE[@]}"
      ;;
    full)
      list_missing_skills "$generated_skills_root" "${REQUIRED_GSTACK_SKILLS_FULL[@]}"
      ;;
    *)
      die "unsupported phase for gstack skill listing: $phase"
      ;;
  esac
}

gstack_install_is_valid() {
  local skills_root="$1"
  local phase="${2:-$DEFAULT_BOOTSTRAP_PHASE}"
  local generated_skills_root=""

  generated_skills_root="$(gstack_generated_skills_root "$skills_root")"

  [ -d "$skills_root/gstack/.git" ] || return 1
  [ -d "$generated_skills_root" ] || return 1
  if phase_requires_browse_binary "$phase"; then
    gstack_browse_binary_path "$skills_root/gstack" >/dev/null 2>&1 || return 1
  fi

  list_missing_phase_gstack_skills "$skills_root" "$phase" >/dev/null 2>&1
}

codex_superpowers_install_is_valid() {
  local repo_dir="$1"
  local repo_link="$2"
  local skills_link="$3"
  local config_file="$4"

  [ -d "$repo_dir/.git" ] || return 1
  path_dir_resolves_to "$repo_link" "$repo_dir" || return 1
  path_dir_resolves_to "$skills_link" "$repo_dir/skills" || return 1
  list_missing_skills "$repo_dir/skills" "${REQUIRED_SUPERPOWERS_SKILLS[@]}" >/dev/null 2>&1 || return 1

  if [ "$REQUIRED_CODEX_FEATURE_MULTI_AGENT" = "true" ]; then
    config_has_multi_agent_true "$config_file" || return 1
  fi

  return 0
}

print_claude_superpowers_manual_steps() {
  cat <<'EOF'
Claude superpowers는 자동 설치하지 않습니다.

권장:
  /plugin install superpowers@claude-plugins-official

공식 marketplace가 보이지 않으면:
  /plugin marketplace add obra/superpowers-marketplace
  /plugin install superpowers@superpowers-marketplace

설치 후 Claude를 다시 시작하세요.
EOF
}
