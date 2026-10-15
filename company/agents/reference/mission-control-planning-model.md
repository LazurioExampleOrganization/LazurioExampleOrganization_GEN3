# Mission Control planning model

Mission Control je lokální planning/orchestration centrum AgentMintu jako
root-level control-plane repo vedle `launchpad/`. Má nahradit roli externího
task manageru pro feature kontext, ale zůstat plně čitelné a editovatelné pro
agenty přes souborový systém.

## Kanonické místo

- Workspace repo: `mission-control/`
- Data: YAML soubory ve workspace
- UI: lokální aplikace spouštěná přes Launchpad
- Execution output: nejbližší `TODO.tasks.json`

Trvalé plány nevytvářej mimo schválený workspace scope. `mission-control/`
je vlastní repo a jeho data jsou filesystem DB pro plánování.

## Source-of-truth kontrakt

Mission Control drží:

- feature a experiment plány
- rozhodnutí a otevřené otázky k plánům
- scope, non-goals a acceptance criteria
- vazbu na implementační TODO tasky
- outcome po dokončení

Git task ledgery drží:

- konkrétní implementační tasky v `TODO.tasks.json`
- hotovou práci v `DONE.tasks.json`
- otevřená rozhodnutí v `ISSUES.open.json`
- kód, dokumentaci, skills a modulový obsah

## Cílová struktura modulu

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

`app/` je editor a dashboard nad soubory. Není autoritativní databáze. Pokud
UI a YAML nesouhlasí, pravdu má YAML.

## Minimální feature plan YAML

```yaml
schema_version: agentmint.mission_control.feature_plan.v1
id: plan-2026-05-23-001
title: Agent Automation Desk pilot
type: experiment
status: shaping
owner: jannovak
created_at: 2026-05-23
updated_at: 2026-05-23

context: |
  Chceme ověřit, jestli firmy zaplatí za produktizovanou agentní automatizaci.

goals:
  - Získat první kvalifikovaný zájem.
  - Ověřit cenu a ICP.

scope:
  in:
    - offer draft
    - prospect criteria
    - manually approved outreach
  out:
    - automated outreach without approval
    - paid ads

acceptance_criteria:
  - Existuje landing/offer draft.
  - Existuje prospect list nebo jasná prospect kritéria.
  - Existuje ručně schválený outreach script.

todo_outputs:
  - task-2026-05-23-010
  - task-2026-05-23-011

links:
  - label: Experiment spec
    path: modules/experiments/specs/2026-05-23-agent-automation-desk.md
```

## Mapování na `TODO.tasks.json`

Každý implementační task odvozený z Mission Control planu má mít:

- `summary` jako konkrétní implementační výsledek, ne business esej
- `acceptance_criteria` zredukovaná na ověřitelné kroky
- `links` na lokální soubory nebo GitHub výstupy
- `planning` objekt s `plan_id` a `path`, jakmile existuje YAML plan

Doporučená reference:

```json
{
  "plan_id": "plan-2026-05-23-001",
  "path": "mission-control/plans/2026/05/agent-automation-desk.yaml",
  "source": "mission-control",
  "role": "planning_source"
}
```

## Provozní pravidlo

Když uživatel plánuje novou feature, agent nejdřív vytvoří nebo najde Mission
Control plan a až potom rozpadne práci do `TODO.tasks.json`. Když se
implementace dokončí, agent aktualizuje task ledger a doplní YAML plan o
outcome a odkazy na výsledky.
