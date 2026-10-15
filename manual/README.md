# Maintenance manual of Lazurio Example Organization

This manual is the source of truth for agents and colleagues who maintain the
Organization. Its operation must never depend on the memory of one person or
one chat.

## What maintenance protects

- the right source of truth for every change;
- the evidence guardrails: a hypothesis is not evidence, and only a verified
  mechanism is scaled;
- the legal and platform guardrails: no spam, fake engagement,
  terms-of-service evasion or misleading claims;
- access boundaries in `infra/access/` in the restricted `infra` repository;
- personal boundaries in `company/colleagues/<os-user>/`;
- valid plans and tasks in Mission Control and the task ledgers;
- the business impact of decisions, per
  `lazurio.organization.json#extensions.legacy.business_context`.

## Reading order

1. `AGENTS.md`
2. `lazurio.organization.json`
3. this manual
4. `GLOSSARY.md`
5. Mission Control and the task ledgers
6. the nearest module or folder `AGENTS.md`

## Source of truth map

- Organization structure: `lazurio.organization.json` and the module
  inventory `modules.manifest.json`. `company.gen3.json` is generated with
  `lazurio migrate organization-manifest <task-worktree> --write`; `generated/`
  with the Lazurio organization compiler.
- Access: `infra/access/` in the `infra` repository.
- Colleagues and personal overlays: `company/colleagues/`.
- Roles: `company/roles/*.role.json`.
- Agent procedures: `.agents/skills/`.
- Voice guide: `company/agents/voice/`.
- Design system: `design-system/`.
- Modules: `workspace/` (inventory in `modules.manifest.json`).
- Planning: Mission Control.
- Shared terms: `GLOSSARY.md`.
- Notable changes: `CHANGELOG.md`.
- Migration to GEN3: `MIGRATION.md`.

## Keeping the root current

- Run `lazurio update` to bring the root and every module you can access to a
  clean `main`. It moves nothing by force: local work, diverged history or a
  dirty checkout stop it with a precise next step.
- Make every change in a task worktree and a pull request. `main` is
  protected: no force push, no deletion, and root CI ("Organization check")
  must pass.
- After a manifest change, regenerate the projection and `generated/` in the
  same pull request; root CI fails when the projection drifts.
- The Organization has no template upstream (update model `standalone`).
  General improvements come from Lazurio itself, not from a template sync.

## Root application modules

`infra` is a restricted root repository for access governance and the
deployment context. Mission Control and the design system are root
application modules; their activation as separate repositories is part of the
GEN3 migration. `lazurio update` clones every active slot; the root never
tracks their contents.

## Colleague overlays

A colleague folder is named after the local OS user name:

```text
company/colleagues/<os-user>/
```

`archive/`, `private/` and local runtime folders are ignored by Git and are
never copied into the shared repository. `samtaylor/` and `robinlee/` are
onboarding scaffolds without a confirmed role.

## Launchpad

The Launchpad lives in Lazurio. The Organization supplies only configuration
(`lazurio.organization.json`, `modules.manifest.json` and the generated
`company.gen3.json`). An App's port is declared only in its module's
`lazurio.module.json`, inside the Organization pool 25300–25399; the App's
`lazurio.runtime.listeners` only refer to that lease.

## The fictional company

The company looks for verifiable ways in which AI agents can earn money
online: legally, with its own brand and its own data. Its working loop: find a
mechanism, break it down into a model, design a legal adaptation, run a small
test, record the result, and scale only with evidence.

## Modules and their boundaries

- `workspace/knowledgebase`: strategy and guardrails, the highest authority.
- `workspace/research`: mechanism scans and evidence; every claim has a source
  and a date.
- `workspace/experiments`: specs, run logs, stop or scale decisions; this is
  where evidence is created.
- `workspace/playbooks`: verified mechanisms only; no hypotheses.
- `workspace/automations`: runtime only after the guardrails are verified by
  hand.
- `workspace/content`: public assets without third-party content and without
  claims that lack evidence.
- `workspace/finance`: unit economics; sensitive data only anonymised,
  otherwise outside Git.
