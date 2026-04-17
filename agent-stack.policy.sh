# shellcheck shell=sh

POLICY_VERSION="1"

GSTACK_REPO="https://github.com/garrytan/gstack.git"
SUPERPOWERS_REPO="https://github.com/obra/superpowers.git"

GSTACK_TRACK_MODE="origin-default-branch"
SUPERPOWERS_TRACK_MODE="origin-default-branch"

SUPPORTED_HOSTS="auto codex claude"
SUPPORTED_PLATFORMS="Darwin Linux"

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

REQUIRED_GSTACK_SKILLS=(
  "gstack-browse"
  "gstack-careful"
  "gstack-checkpoint"
  "gstack-design-review"
  "gstack-freeze"
  "gstack-guard"
  "gstack-office-hours"
  "gstack-plan-ceo-review"
  "gstack-plan-design-review"
  "gstack-plan-eng-review"
  "gstack-qa"
  "gstack-qa-only"
  "gstack-review"
)
