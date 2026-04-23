# Repo-Local Superpowers Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `superpowers` a repo-local bootstrap artifact next to `gstack`, while Codex home paths point to it through symlinks.

**Architecture:** `setup-dev-agents` clones `superpowers` into `.agents/skills/superpowers`. Codex compatibility is preserved by linking `~/.codex/superpowers` to that repo-local checkout and `~/.agents/skills/superpowers` to its `skills` directory. `check-dev-agents` validates the repo-local checkout and both symlinks.

**Tech Stack:** Bash scripts, git, symlinks, existing phase bootstrap shell tests.

---

### Task 1: Lock the Contract in Tests

**Files:**
- Modify: `tests/phase-bootstrap.test.sh`
- Modify: `agent-stack.policy.sh`

- [ ] **Step 1: Add failing assertions**

Add test assertions that `CODEX_SUPERPOWERS_MODE` is `repo_local_checkout_with_home_symlinks` and that fake superpowers installs are valid only when `~/.codex/superpowers` points at repo-local `.agents/skills/superpowers` and `~/.agents/skills/superpowers` points at `.agents/skills/superpowers/skills`.

- [ ] **Step 2: Verify RED**

Run: `bash tests/phase-bootstrap.test.sh`

Expected: FAIL because the policy still says `global_checkout_with_symlink` and the test fixture still models the old home-local checkout.

- [ ] **Step 3: Update the policy**

Set `CODEX_SUPERPOWERS_MODE="repo_local_checkout_with_home_symlinks"` and bump `POLICY_VERSION`.

- [ ] **Step 4: Verify GREEN**

Run: `bash tests/phase-bootstrap.test.sh`

Expected: PASS.

### Task 2: Move Bootstrap Ownership to Repo-Local

**Files:**
- Modify: `bin/setup-dev-agents`
- Modify: `bin/check-dev-agents`

- [ ] **Step 1: Update setup paths**

Change Codex superpowers setup so the checkout target is `$DEV_AGENT_REPO_ROOT/.agents/skills/superpowers`, with home symlinks at `$DEV_AGENT_HOME/.codex/superpowers` and `$DEV_AGENT_HOME/.agents/skills/superpowers`.

- [ ] **Step 2: Update validation paths**

Change Codex superpowers checking so it validates the repo-local checkout and both home symlinks.

- [ ] **Step 3: Run setup/check locally**

Run with an isolated `DEV_AGENT_HOME`: `./bin/setup-dev-agents --host codex --phase core` and `./bin/check-dev-agents --host codex --phase core`.

Expected: both finish with `Result exit code: 0` or setup exits `0` and check prints `Result exit code: 0`.

### Task 3: Update Docs and Clean-Room Verify

**Files:**
- Modify: `README.md`
- Modify: `agents/tool-contract.md`
- Modify: any operation docs that mention Codex superpowers location

- [ ] **Step 1: Update documentation**

Document that `.agents/skills/superpowers` is repo-local and ignored, while `~/.codex/superpowers` and `~/.agents/skills/superpowers` are symlinks.

- [ ] **Step 2: Run local verification**

Run: `bash tests/phase-bootstrap.test.sh`, `git diff --check`, and isolated `core`/`full` setup-check.

Expected: all pass.

- [ ] **Step 3: Push and clean-room verify**

Commit, push to `origin/main`, clone `https://github.com/IamJuho/ai-dev-bootstrap.git` into a fresh temp directory, and run `core`/`full` setup-check plus `bash tests/phase-bootstrap.test.sh`.

Expected: clean-room pilot passes from the public repository.
