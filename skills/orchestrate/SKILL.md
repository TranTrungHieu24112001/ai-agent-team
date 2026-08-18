---
description: Orchestrates the manager → frontend-dev/backend-dev → tester → qa-qc workflow for a requirement — dispatching independent tasks in parallel and looping feedback back to the right agent until QA/QC passes. Use when the user gives a feature/requirement and wants the full agent team to execute it end to end.
---

# Team orchestration workflow

You (the top-level session) are the hub. Subagents don't message each other directly by default — every handoff below routes through you via the `Agent` tool (fresh spawn) or `SendMessage` (resume an existing agent with its prior context intact). Treat this as the operating procedure, not a suggestion to improvise a different flow.

## Procedure

1. **Plan.** Spawn the `manager` agent with the raw requirement. It returns a numbered task list: each task tagged frontend/backend/both, with acceptance criteria, dependencies, and which tasks are parallelizable.

2. **Dispatch.** Walk the task list in dependency order. For each batch of independent tasks, spawn the needed dev agent(s) **in parallel** — multiple `Agent` calls in a single turn:
   - Task scope = frontend only → spawn `frontend-dev` alone.
   - Task scope = backend only → spawn `backend-dev` alone.
   - Task scope = both → spawn `frontend-dev` and `backend-dev` together; tell backend-dev to define its API contract early since frontend-dev depends on it.
   - Two independent backend tasks → spawn two `backend-dev` instances in parallel.
   - Give each dev agent only its specific task + acceptance criteria + relevant context, not the whole plan.

3. **Test.** When a dev agent reports done, spawn `tester` with: the change summary, acceptance criteria, and the dev's "how to exercise it" notes.

4. **Review.** When `tester` reports, spawn `qa-qc` with: acceptance criteria, the tester's findings, and the code diff.

5. **Loop on rejection.**
   - `qa-qc` → REJECT (dev agent): use `SendMessage` to resume that exact dev agent (not a fresh spawn, so it keeps its prior context) with the specific defect. Then repeat steps 3–4 on the fix.
   - `qa-qc` → REJECT (manager): use `SendMessage` to resume `manager` with the conflict. Once it clarifies, relay the clarification to the relevant dev agent via `SendMessage` and repeat steps 3–4.

6. **Close out.** Once every task in the manager's list has a PASS from qa-qc, summarize what shipped and any open follow-ups back to the user.

## Notes

- Prefer resuming an agent via `SendMessage` over re-spawning fresh whenever it already has relevant context (a dev agent fixing its own defect, the manager clarifying its own plan) — a fresh spawn has no memory of the task.
- Only parallelize truly independent work. If a dev agent needs another dev agent's contract/output first, dispatch it after, not alongside.
