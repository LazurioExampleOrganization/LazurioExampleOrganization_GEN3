# Map of Lazurio Example Organization

A short guide to where things are and where to change them. The machine model
is `lazurio.organization.json`; this file is its human companion.

## Root surfaces

```text
LazurioExampleOrganization_GEN3/
├── README.md, MAP.md, AGENTS.md, CLAUDE.md, GLOSSARY.md, CHANGELOG.md
├── MIGRATION.md                                        # GEN3 migration plan and benchmark ledger
├── lazurio.organization.json, modules.manifest.json    # Organization model and module inventory
├── company.gen3.json                                   # generated compatibility projection; never edit
├── generated/          # outputs of the Lazurio organization compiler; never edit
├── TODO.tasks.json, DONE.tasks.json, ISSUES.open.json  # task ledgers (until Mission Control v3)
├── manual/             # maintenance manual
├── .agents/skills/     # Organization skills (.claude/skills is the mirror)
├── company/            # roles, colleague overlays, agent voice and reference
├── mission-control/    # in-tree planning layer (YAML plans) and its v1 App
├── design-system/      # in-tree design system (moving to its own repository)
├── blog/               # internal insights (drafts)
├── workspace/          # workspace modules, each its own repository
├── productionspace/    # Organization-level production systems (none yet)
└── infra/              # restricted infrastructure and access repository
```

The root is not a dumping ground. Something new belongs in one of these
surfaces, in a module or in a skill.

## Quick routing

| Question | Where to look |
|---|---|
| How does the Organization work as a whole? | `README.md` and `lazurio.organization.json` |
| What does a term mean? | `GLOSSARY.md` |
| Which rule applies to an agent? | the nearest `AGENTS.md` (cascade: root, role, colleague, module) |
| What is in progress, done or waiting for a decision? | Mission Control and the task ledgers |
| What changed? | `CHANGELOG.md` in the scope |
| How far is the GEN3 migration? | `MIGRATION.md` |
| Where to plan a feature or experiment? | Mission Control (`mission-control-planning` skill) |
| Business context, decision rights, metrics? | `lazurio.organization.json#extensions.legacy.business_context` |
| Strategy and guardrails? | `workspace/knowledgebase/` |
| Mechanism research with evidence? | `workspace/research/` |
| An experiment spec, log or result? | `workspace/experiments/` |
| A verified, repeatable procedure? | `workspace/playbooks/` |
| Public text? | `workspace/content/` |
| Unit economics? | `workspace/finance/` (restricted) |
| An internal insight? | `blog/` |
| Visual or formatted output? | the design system (use the `design-system-lookup` skill first) |
| Onboarding? | the public Lazurio guide at https://documentation.lazurio.ai/en/ |
| A repeatable agent procedure? | `.agents/skills/` (index `manifest.json`) |
| Which modules exist and in what state? | `modules.manifest.json` |
| Who may access what? | `infra/access/` in the `infra` repository |

## `company/`

The company skeleton, tracked in this repository.

- `company/roles/`: reusable role overlays and `*.role.json`.
- `company/colleagues/`: personal overlays, one folder per local OS user.
- `company/agents/`: voice and reference knowledge for agents.
- `company/archive/`: rules for derived archive content.

## `workspace/`

Each `workspace/<module>/` is a nested Git repository with its own history and
access boundary. The root never tracks module contents or pointers;
`modules.manifest.json` is the only inventory. Do substantive work inside the
module and read its own `AGENTS.md` first.

## When something does not work

Run `lazurio update` to bring the root and every module you can access to a
clean `main`, and `lazurio doctor` for a diagnosis. For a module with an App,
`lazurio module setup <module> --json` checks it against the Lazurio Module
Standard.

## Missing modules

A missing module is not automatically an error:

- `available`: the module is cloned and usable;
- `missing_access`: your GitHub account cannot reach the repository;
- `planned_slot`: the slot in `modules.manifest.json` has no repository yet.
