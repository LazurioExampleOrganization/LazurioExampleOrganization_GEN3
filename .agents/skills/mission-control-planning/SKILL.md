---
name: mission-control-planning
description: Use when the user plans a new feature, an experiment, a larger change in how the Organization works or cross-scope work. It anchors the plan in Mission Control first and only then derives implementation steps.
---

# Mission Control planning

This skill turns a vague intent into two separate layers:

- **A Mission Control plan**: why the work is done, for whom, its scope,
  decisions and acceptance criteria.
- **Tasks**: concrete implementation steps that point back to the plan.

Today the Organization plans in the in-tree layer `mission-control/` (YAML
plans in `mission-control/plans/`) and keeps tasks in the root
`TODO.tasks.json`, `DONE.tasks.json` and `ISSUES.open.json`. When the
Organization adopts Mission Control v3, plans and tasks move to its data
repository mounted at `mission-control/db/`, and this skill follows them.

## When to use

When the user says, for example:

- "plan a feature", "let's build something new";
- "turn this into tasks", "break it down";
- "prepare an experiment";
- "this is going to be a bigger change".

Do not hold up a simple bug fix with this flow when its scope is obvious and
no product or operating decision changes.

## Steps

1. Read the root `AGENTS.md`, `MAP.md` and the nearest relevant `AGENTS.md`.
2. Find an existing plan for the intent in `mission-control/plans/`. Do not
   create a duplicate.
3. If none exists, create one. A plan has at least: `id`, `title`, `type`,
   `status`, `owner`; the goal and the business reason; scope and non-goals;
   decisions and open questions; acceptance criteria; risks and guardrails;
   links to the relevant files; the derived task ids; and the outcome once it
   is done.
4. Derive small tasks with one main result each in `TODO.tasks.json`. Link
   every task back to the plan through its `planning` field and put the
   relevant repository files, not the chat, into `links`.
5. Record missing decisions in `ISSUES.open.json`.

Example `planning` reference in a task:

```json
"planning": {
  "plan_id": "plan-2026-05-23-001",
  "path": "mission-control/plans/2026/05/agent-automation-desk.yaml",
  "source": "mission-control",
  "role": "planning_source"
}
```

If Mission Control cannot be read, do not pretend a plan exists. Record a task
with a clear `next_action` to restore it, and move the planning context into
Mission Control as soon as it is available again.

## Verification

- The plan exists once, in Mission Control, and every derived task links to
  it.
- No feature plan lives only in chat, and no long strategic brief lives only
  in a task.
- Mission Control holds no secrets, tokens, customer data or local runtime
  details.
