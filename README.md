# ai-agent-team

A reusable, stack-agnostic 5-role AI dev team for Claude Code — packaged as a plugin so it can be installed into any project on any machine, once, from GitHub.

## Roles

| Agent | Role |
|---|---|
| `manager` | Brainstorms and breaks a raw requirement into small, detailed tasks with acceptance criteria and dependencies. Plans only — never edits code. |
| `frontend-dev` | Implements the frontend scope of a task. Skipped entirely for backend-only tasks. |
| `backend-dev` | Implements the backend scope of a task. Spawn two instances in parallel for two independent backend tasks. |
| `tester` | Tests a finished task like an adversarial real user — edge cases, invalid input, races, auth bypass — across both frontend and backend. Doesn't fix code. |
| `qa-qc` | Reviews the task's output against the manager's acceptance criteria and the tester's findings; passes it or bounces it back to a dev agent or the manager. |

Plus one orchestration **skill** (`skills/orchestrate/SKILL.md`) that drives the full manager → dev(s) → tester → qa-qc loop, dispatching independent tasks in parallel and routing rejections back to the exact agent that needs to fix them.

## Install (once per machine)

```
/plugin marketplace add <your-org>/ai-agent-team
/plugin install ai-agent-team
```

Pick **user scope** when prompted so it's available in every project on this machine afterward, not just the one you're in right now.

On a new machine, or for a teammate who's never used it: repeat the two commands above — everything comes straight from this GitHub repo, no per-project copy-pasting of agent files.

## Install the community skills each role references

The agents reference public skills from [skills.sh](https://www.skills.sh/) that already encode this exact workflow (planning, parallel dispatch, git worktrees for concurrent agents, TDD, code review). Install them once per project:

```
./scripts/install-skills.sh
```

This runs `npx skills add <repo>` for:
- `mattpocock/skills` — `to-spec`, `to-issues`, `improve-codebase-architecture`, `code-review`, `diagnosing-bugs`
- `obra/superpowers` — `brainstorming`, `writing-plans`, `dispatching-parallel-agents`, `executing-plans`, `using-git-worktrees`, `finishing-a-development-branch`, `test-driven-development`, `systematic-debugging`, `verification-before-completion`, `requesting-code-review`, `receiving-code-review`
- `anthropics/skills` — `frontend-design`
- `microsoft/playwright-cli` — browser-driven testing for the tester agent

These agents work fine without the community skills installed — they fall back to the instructions written directly in each agent's `.md` file — the skills just sharpen behavior further.

## Use it

```
/ai-agent-team:orchestrate "<describe the feature/requirement>"
```

This spawns `manager` to break the requirement into tasks, dispatches `frontend-dev`/`backend-dev` (in parallel where tasks are independent), runs each finished task through `tester` then `qa-qc`, and loops feedback back to the responsible agent until everything passes.

You can also invoke any single agent directly (e.g. for a small task that doesn't need the full pipeline) via the `Agent` tool with `subagent_type: manager` / `frontend-dev` / `backend-dev` / `tester` / `qa-qc`.

## Why not npm?

Claude Code plugins distribute via a git-based marketplace (`/plugin marketplace add`, `/plugin install`), not npm — this repo *is* the package. The one place npm shows up is `scripts/install-skills.sh`, which shells out to the separate [skills.sh](https://www.skills.sh/) community-skill installer (`npx skills add ...`) — a different, complementary system from Claude Code's own plugin mechanism.

## How parallel work stays safe

`frontend-dev` and `backend-dev` are instructed to use a separate git worktree when another dev agent is active in the same repo at the same time, so concurrent agents never clobber each other's uncommitted edits (see the `using-git-worktrees` skill).
