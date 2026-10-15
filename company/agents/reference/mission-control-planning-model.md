# Mission Control planning model

Mission Control is the Organization's local planning and orchestration centre:
an in-tree layer at the root of the Organization repository. It takes over the
role of an external task manager for feature context, yet stays fully readable
and editable for agents through the file system.

## Canonical location

- Location: `mission-control/` in the Organization root repository (in-tree,
  not a nested repository)
- Data: YAML files in the repository
- UI: a local App started from the Launchpad
- Execution output: the nearest `TODO.tasks.json`

Do not create durable plans outside the approved workspace scope.
`mission-control/` is the planning layer, and its data is the file-system
database for planning.

## Source-of-truth contract

Mission Control holds:

- feature and experiment plans
- decisions and open questions about the plans
- scope, non-goals and acceptance criteria
- the link to the implementation TODO tasks
- the outcome after completion

The Git task ledgers hold:

- concrete implementation tasks in `TODO.tasks.json`
- finished work in `DONE.tasks.json`
- open decisions in `ISSUES.open.json`
- code, documentation, skills and module content

## Target structure

```text
mission-control/
├── README.md
├── AGENTS.md
├── ARCHITECTURE.md
├── TODO.tasks.json
├── CHANGELOG.md
├── schemas/
│   └── feature-plan.schema.json
├── plans/
│   └── YYYY/
│       └── MM/
│           └── <slug>.yaml
├── decisions/
│   └── YYYY/
│       └── MM/
│           └── <slug>.yaml
├── app/
│   └── v1/
└── scripts/
    └── export-todo-tasks.mjs
```

`app/` is an editor and dashboard over the files. It is not the authoritative
database. When the UI and the YAML disagree, the YAML is right.

## Minimal feature plan YAML

```yaml
schema_version: example.mission_control.feature_plan.v1
id: plan-2026-05-23-001
title: Agent Automation Desk pilot
type: experiment
status: shaping
owner: alexmorgan
created_at: 2026-05-23
updated_at: 2026-05-23

context: |
  We want to test whether companies will pay for productized agent automation.

goals:
  - Get the first qualified interest.
  - Validate the price and the ICP.

scope:
  in:
    - offer draft
    - prospect criteria
    - manually approved outreach
  out:
    - automated outreach without approval
    - paid ads

acceptance_criteria:
  - A landing page or offer draft exists.
  - A prospect list or clear prospect criteria exist.
  - A manually approved outreach script exists.

todo_outputs:
  - task-2026-05-23-010
  - task-2026-05-23-011

links:
  - label: Experiment spec
    path: workspace/experiments/specs/2026-05-23-agent-automation-desk.md
```

## Mapping to `TODO.tasks.json`

Every implementation task derived from a Mission Control plan has:

- `summary` as a concrete implementation result, not a business essay
- `acceptance_criteria` reduced to verifiable steps
- `links` to local files or GitHub outputs
- a `planning` object with `plan_id` and `path`, as soon as a YAML plan exists

Recommended reference:

```json
{
  "plan_id": "plan-2026-05-23-001",
  "path": "mission-control/plans/2026/05/agent-automation-desk.yaml",
  "source": "mission-control",
  "role": "planning_source"
}
```

## Operating rule

When the user plans a new feature, the agent first creates or finds a Mission
Control plan and only then breaks the work down into `TODO.tasks.json`. When
the implementation is finished, the agent updates the task ledger and adds the
outcome and links to the results to the YAML plan.
