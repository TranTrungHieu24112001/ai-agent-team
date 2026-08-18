#!/usr/bin/env bash
# Installs the community skills.sh skills each role in this plugin references.
# Run once per machine/project after installing the ai-agent-team plugin itself.
set -euo pipefail

echo "Installing community skills from skills.sh for the ai-agent-team roles..."
echo "Note: some of these repos bundle many skills; 'npx skills add' may pull in the"
echo "whole repo rather than a single named skill. Check what lands afterward."
echo

SKILL_REPOS=(
  "mattpocock/skills"      # to-spec, to-issues, improve-codebase-architecture, code-review, diagnosing-bugs
  "obra/superpowers"       # brainstorming, writing-plans, dispatching-parallel-agents, executing-plans,
                            # using-git-worktrees, finishing-a-development-branch, test-driven-development,
                            # systematic-debugging, verification-before-completion, requesting/receiving-code-review
  "anthropics/skills"      # frontend-design
  "microsoft/playwright-cli"
)

for repo in "${SKILL_REPOS[@]}"; do
  echo "-> npx skills add ${repo%% *}"
  npx skills add "${repo%% *}"
done

echo
echo "Done. Verify installed skills under .claude/skills/ (or wherever the CLI reports)."
