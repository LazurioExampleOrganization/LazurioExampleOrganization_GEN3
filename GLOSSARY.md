# Glossary of Lazurio Example Organization

This document defines the key terms of the Organization. When a term affects
a decision, an experiment, money or agent behaviour, it must not live only in
a chat. The contract for adding terms is
`lazurio.organization.json#extensions.legacy.glossary_contract`.

## Business domain

### Mechanism

A repeatable way in which online income is created. A mechanism is not a
particular foreign brand, text, database or account. It is a model: the offer,
the customer, the channel, the operating steps, the economics and the reason
why someone pays.

### Adaptation

The legal transfer of a mechanism into the company's own context. An
adaptation uses the company's own brand, content, accounts and data and
respects the rules of the platforms.

### Experiment

A small, measurable test of a hypothesis. It has a hypothesis, a metric, a
budget, a stop condition, an owner and a recorded result.

### Evidence

Something that raises confidence that a mechanism works: a real payment, a
conversion, a market response, an auditable metric or a repeatable
observation. A feeling or a viral claim is not evidence on its own.

### Playbook

A verified procedure that can be repeated. A mechanism enters a playbook only
once it has enough evidence; hypotheses belong in research or experiments.

### Unit economics

The basic economics of one unit of income: price, cost, agent and human time,
acquisition cost, margin and risks.

### Guardrail

A rule that protects the company from legal, reputational, platform or
security problems. Guardrails are part of every experiment.

## Lazurio model

### Organization

One company, one root repository, one GitHub Organization and one access
boundary. It is defined by `lazurio.organization.json`
(`company.gen3.json` is only its generated compatibility projection) and is
mounted in a Lazurio Folder as `organizations/<slug>_GEN3/`. This repository
is the root of Lazurio Example Organization. Inside an Organization live
Teams, the `workspace/` layer of modules, the Organization-level
`productionspace/` and the root application modules (Mission Control and the
design system).

### Lazurio Folder

The folder on one Machine in which Lazurio keeps the Organizations a person
works with (`organizations/`) and their private Personalspace. Organizations
stay separate access boundaries inside it.

### Team

A logical, many-to-many group of modules and people inside an Organization,
the same concept as a GitHub Team. A module can belong to several Teams. A
Team has no directory of its own. The roster is declared in
`lazurio.organization.json#teams` and a module's membership in
`modules.manifest.json` (`module_slots[].teams`); which Teams can actually
reach a module is decided by the GitHub grants. This Organization has a
single Team, `workspace`, that covers every workspace module.

### Workspace

The layer of the Organization's working (non-production) modules, mounted
flat in `workspace/<module>/`. The GEN2 meaning of "workspace" (the whole
company repository) corresponds to the Organization today; write "GEN2
workspace" when you mean the old one.

### Module

A Git repository with `lazurio.module.json` in its root and one domain source
of truth, declared as a slot in `modules.manifest.json` and kept up to date by
`lazurio update`. Workspace modules live in `workspace/<module>/`; root
modules (`infra`, `mission-control`, `design-system`) next to it. The root
never tracks module contents or gitlink pointers. A module with an App follows
the Lazurio Module Standard; a document module has no App. A missing module is
not automatically an error: its state is `available`, `missing_access` or
`planned_slot`.

### Productionspace

The Organization-level layer of deployed or public production systems, next
to the workspace layer and outside any Team. A module moves there once it is
really deployed with its own release pipeline. This Organization has none
yet.

### Personalspace

The private personal space of one person, outside every GitHub Organization.
It never holds company truth.

### Launchpad

The part of Lazurio that shows the Organizations and their modules on a
Machine and starts their Apps from `main` or from a worktree. It reads
`lazurio.organization.json`, `modules.manifest.json` and each module's
`lazurio.module.json`.

### Mission Control

The planning centre of the Organization: plans hold the context, scope and
acceptance criteria, and tasks hold the implementation steps that point back
to a plan. It is Mission Control v3: the root application module
`mission-control/` from the public upstream Lazurio/mission-control, with its
data repository `mission-control-data` mounted at `mission-control/db/`.

### Partial workspace

A local clone of the Organization in which some modules are not cloned
(`missing_access`, `planned_slot`). It is intended, not a Git workflow error.

### Skill

The canonical format of a repeatable agent procedure, in
`.agents/skills/<name>/SKILL.md` with its index in
`.agents/skills/manifest.json`; `.claude/skills/` is the mirror.

## Roles

### Founder

Holds the direction of the company and decides on risk, budget and which
mechanism is tested further. Machine description:
`company/roles/founder.role.json`.

### Research operator

Maps online mechanisms, breaks them down into a model and prepares the
evidence for decisions. Machine description:
`company/roles/research-operator.role.json`.

### Experiment operator

Turns a hypothesis into a measurable test, watches the guardrails and records
the result. Machine description:
`company/roles/experiment-operator.role.json`.
