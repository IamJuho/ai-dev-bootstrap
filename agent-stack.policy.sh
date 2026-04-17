# shellcheck shell=sh

POLICY_VERSION="1"

GSTACK_REPO="https://github.com/garrytan/gstack.git"
SUPERPOWERS_REPO="https://github.com/obra/superpowers.git"

GSTACK_TRACK_MODE="origin-default-branch"
SUPERPOWERS_TRACK_MODE="origin-default-branch"

SUPPORTED_HOSTS="auto codex claude"
SUPPORTED_PLATFORMS="Darwin Linux"
SUPPORTED_PHASES="core full"
DEFAULT_BOOTSTRAP_PHASE="full"

REQUIRED_GSTACK_PREFIX="gstack-"
REQUIRED_CODEX_FEATURE_MULTI_AGENT="true"
CLAUDE_SUPERPOWERS_MODE="manual_marketplace"
CODEX_SUPERPOWERS_MODE="global_checkout_with_symlink"

REQUIRED_SUPERPOWERS_SKILLS=(
  "brainstorming"
  "executing-plans"
  "subagent-driven-development"
  "systematic-debugging"
  "test-driven-development"
  "using-git-worktrees"
  "verification-before-completion"
  "writing-plans"
)

REQUIRED_GSTACK_SKILLS_CORE=(
  "gstack-careful"
  "gstack-checkpoint"
  "gstack-freeze"
  "gstack-guard"
  "gstack-office-hours"
  "gstack-plan-ceo-review"
  "gstack-plan-design-review"
  "gstack-plan-eng-review"
  "gstack-review"
)

REQUIRED_GSTACK_SKILLS_FULL=(
  "${REQUIRED_GSTACK_SKILLS_CORE[@]}"
  "gstack-browse"
  "gstack-qa"
  "gstack-qa-only"
  "gstack-design-review"
)

CORE_EXCLUDED_GSTACK_SKILLS=(
  "gstack-benchmark"
  "gstack-browse"
  "gstack-canary"
  "gstack-connect-chrome"
  "gstack-design-review"
  "gstack-open-gstack-browser"
  "gstack-pair-agent"
  "gstack-qa"
  "gstack-qa-only"
  "gstack-setup-browser-cookies"
)

REQUIRED_GSTACK_SKILLS=(
  "${REQUIRED_GSTACK_SKILLS_FULL[@]}"
)
