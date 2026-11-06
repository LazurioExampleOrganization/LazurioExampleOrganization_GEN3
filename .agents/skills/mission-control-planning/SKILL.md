---
name: mission-control-planning
description: Use when the user plans a new feature, an experiment, a larger change in how the Organization works or cross-scope work. It anchors the plan in Mission Control first and only then derives implementation steps.
---

# Mission Control planning

This skill turns a vague intent into two separate layers:

- **A Mission Control plan**: why the work is done, for whom, its scope,
  decisions and acceptance criteria.
- **Tasks**: concrete implementation steps that point back to the plan.

The Organization runs Mission Control: the App is the root module
`mission-control/` (the Organization's copy of the Lazurio Marketplace template
[LazurioTemplates/mission-control](https://github.com/LazurioTemplates/mission-control)), and
its data repository `mission-control-data` (branch `v3`) is mounted at
`mission-control/db/`:

- plans: `data/mission-control/plans/<year>/<month>/EX-XXXX-<slug>.yaml`
  (plan prefix `EX`);
- tasks: `data/mission-control/TODO.tasks.json` and `DONE.tasks.json`;
- roadmaps: `data/mission-control/roadmaps/`.

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
2. Find an existing plan for the intent in Mission Control (the App, or the
   plans directory). Do not create a duplicate.
3. If none exists, create one in English: in the Mission Control App ("Nový
   plán" takes the next free `EX-XXXX` code), or as a new file in a pull
   request to `mission-control-data` with the next free code. A plan has a goal and business reason
   (`context`, `current_problem`, `target_state`), scope and non-goals,
   acceptance criteria, validation, risks, decisions and open questions.
4. Derive small tasks with one main result each. Put them in the plan's
   `proposed_tasks` and add them to `TODO.tasks.json` in a pull request to
   `mission-control-data`, so every task links back to the plan through
   `planning` and carries the plan code in its tags. From Mission Control 4.0
   the App neither reads nor writes the task ledgers.
5. Publish the change: in the App as a reviewed draft (one fast-forward commit
   to `v3`), or as a pull request to `mission-control-data` that passes
   `bun scripts/validate.ts`. Publishing data needs your user's instruction.
6. Record an open business decision in the plan's `open_questions`; record an
   open technical problem as a GitHub Issue of the owning repository.

If Mission Control cannot be read, do not pretend a plan exists. Say what is
missing and how to restore it; do not keep a second plan elsewhere.

## Verification

- The plan exists once, in Mission Control, and every derived task links to
  it.
- `bun scripts/validate.ts` in `mission-control/db/` reports
  `Mission Control data: OK`, and `bun run validate` in
  `mission-control/app/v3/` reports `db/: OK` (the rules across records).
- No feature plan lives only in chat, and no long strategic brief lives only
  in a task.
- Mission Control holds no secrets, tokens, customer data or local runtime
  details.
