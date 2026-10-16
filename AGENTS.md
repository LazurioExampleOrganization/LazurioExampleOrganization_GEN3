# Lazurio Example Organization: rules for agents

This repository is the root of **Lazurio Example Organization**
(`LazurioExampleOrganization`), Lazurio's public reference Organization. In a
Lazurio Folder it is mounted as `organizations/LazurioExampleOrganization_GEN3`.
All data is fictional. The Organization started from a cleaned GEN2 snapshot
and migrates to the current GEN3 model in public pull requests; the plan and
the benchmark ledger are in [`MIGRATION.md`](MIGRATION.md).

The fictional company looks for verifiable ways in which AI agents can earn
money online: legally, with its own brand and its own data.

## Collaboration model

How people and agents work together (the Operator, Colleagues, Task Agents,
Drafts and Publication) is defined once, in the collaboration model section of
the [Lazurio root `AGENTS.md`](https://github.com/HumanAndMachines/Lazurio/blob/main/AGENTS.md#model-spolupr%C3%A1ce-oper%C3%A1tor-a-agenti).
It applies here unchanged. This file does not keep a translated copy; when the
Lazurio root ships an English version of that section, it is embedded here
verbatim.

## Language

This Organization works in English. Everything written in its repositories
(documents, skills, manifests, plans, tasks, commit messages and pull
requests) is English. Fictional people have international names without
diacritics.

## Cascade of instructions

Read from the general to the specific; the closer rule wins:

1. the root `AGENTS.md` (this file);
2. `company/roles/<role>/AGENTS.md` and `company/roles/<role>.role.json`;
3. `company/colleagues/<os-user>/AGENTS.md`, the personal overlay;
4. the module's own `AGENTS.md` in `workspace/<module>/`.

- A colleague folder `company/colleagues/<os-user>/` matches the local OS user
  name. `archive/`, `private/` and similar folders inside it stay local and
  ignored; never copy them into shared Git.
- `samtaylor/` and `robinlee/` are onboarding scaffolds without a confirmed
  role; do not infer their responsibilities.
- Before substantive work, read the context: the root documents,
  `lazurio.organization.json`, `GLOSSARY.md`, the plan in Mission Control and
  the nearest `AGENTS.md`. Do not invent company facts; ask when the context
  is not enough.

## Rules

- Write the structure of the Organization only to `lazurio.organization.json`
  and the module inventory only to `modules.manifest.json`.
  `company.gen3.json` is a generated compatibility projection (state
  `transition`): never edit it by hand. Regenerate it with
  `lazurio migrate organization-manifest <task-worktree> --write` and commit
  both files together; a hand edit ends in `projection_drift` or `conflict`,
  and `lazurio update` refuses such a `main`. Root CI checks the parity.
- `generated/` is written by the Lazurio organization compiler. Regenerate it
  after a manifest change; never edit it by hand.
- Before a decision with business impact, read
  `lazurio.organization.json#extensions.legacy.business_context`. When you
  change the manifest, keep the business context, decision rights, risks,
  metrics and the source-of-truth matrix concrete.
- When a term is unclear, read or extend `GLOSSARY.md` (its contract is
  `lazurio.organization.json#extensions.legacy.glossary_contract`).
- When you change an App, an API, data or a runtime boundary, follow
  `lazurio.organization.json#extensions.legacy.generation_policy` and the
  Lazurio Module Standard.
- Access governance lives in `infra/access/` in the restricted `infra`
  repository. An agent may propose an access change; an Admin of the
  Organization approves it.
- The Launchpad and every runtime live in Lazurio, not in this repository. The
  Organization supplies only manifests; each module owns its listener in its
  own `lazurio.module.json` and its App contract in `package.json`.
- Be an active colleague: point out a risk, contradiction or opportunity
  briefly (what you see, why it matters, the recommended fix, who owns the
  next step). Fix a small, safe problem within your scope directly; leave a
  decision with business or security impact to a person, with one to three
  options.
- Never bring secrets, OAuth session data, private overlays or another
  company's data into this Organization.

## Evidence and legal guardrails

This is the core of the company and applies to every piece of research, every
experiment, all content and every automation:

- Copy the mechanism, never another company's identity: no foreign brand,
  content, databases, reviews, personas or account setups.
- No spam, phishing, fake engagement, terms-of-service evasion or misleading
  claims. Stop a borderline case and escalate it to the Founder.
- A hypothesis is not evidence. Every experiment has a hypothesis, a metric, a
  budget, a stop condition, an owner and a recorded result in
  `workspace/experiments`.
- Only a mechanism with a verified signal is scaled; only a verified procedure
  goes to `workspace/playbooks`.
- Confirm every financial step and every externally visible action with a
  person first.
- Sensitive financial data enters Git only safely anonymised
  (`workspace/finance`); everything else stays out of Git.
- Online market claims age quickly: every research output lists its sources
  and the date of verification.

## Mission Control and tasks

- Plans live in Mission Control: why something is done, for whom, its scope,
  decisions and acceptance criteria. Concrete implementation steps are tasks
  linked to a plan. Use the `mission-control-planning` skill.
- Mission Control v3 is the root application module `mission-control/`, the
  public upstream [Lazurio/mission-control](https://github.com/Lazurio/mission-control)
  with this Organization's overlay. Its data repository `mission-control-data`
  (branch `v3`) is mounted at `mission-control/db/`: plans in
  `data/mission-control/plans/<year>/<month>/EX-XXXX-<slug>.yaml`, tasks in
  `data/mission-control/TODO.tasks.json` and `DONE.tasks.json`.
- Write plans and tasks through the Mission Control App (a reviewed draft,
  published as one fast-forward commit) or a pull request to
  `mission-control-data`. Open technical problems are GitHub Issues of the
  owning repository.
- The Mission Control UI is Czech-only for now
  ([Lazurio/mission-control#1](https://github.com/Lazurio/mission-control/issues/1));
  the data is English.
- Do not hold up a simple bug fix with planning ceremony.

## Missing modules

Not every colleague has every module cloned; that is intended.

- `available`: the module is present; work in it normally.
- `missing_access`: the module is declared, but your GitHub account cannot
  reach it. Do not invent its content or copy data from elsewhere; say what
  you need.
- `planned_slot`: the slot is declared without a repository. Say that it is
  planned.

Never pretend that a missing module is a Git workflow error.

## Skills

- `.agents/skills/` is the canonical skill library and
  `.agents/skills/manifest.json` its index. `.claude/skills/` is a
  byte-for-byte mirror for Claude Code; root CI checks it.
- Lazurio itself ships the general skills (worktrees, the Module Standard,
  workstation install) in the Lazurio root. Skills here cover only what is
  specific to this Organization.
- For non-trivial code, documentation or workflow changes use
  `agent-execution-discipline`.
- A new repeatable procedure becomes a skill, not a longer `AGENTS.md`.
- `company/agents/reference/` is knowledge to read when needed;
  `company/agents/voice/` is the source of truth for tone.

## Integrations

- The Organization has no external task manager; planning stays in Mission
  Control.
- External applications are connected per Environment as Lazurio
  Integrations, never committed. Personal assistant settings live in the
  gitignored `company/colleagues/<os-user>/.claude/settings.json` or in
  `~/.claude/settings.json`.
- When a service is not connected, say so and point the person to connect it.
- `example.local` is a local placeholder, not an OAuth identity.

## Git rules

- Prepare every change in a worktree, never in a primary checkout:
  `.worktrees/root/<slug>/` for the root and
  `.worktrees/workspace/<module>/<slug>/` for a module. One change, one
  worktree, one branch, one pull request. Commit and push only what belongs to
  the task; never `git add -A` over someone else's changes.
- Commit messages and pull request descriptions are English and feed the
  release notes: subject `Area: concrete change`, a blank line, then one to
  three paragraphs (what, why, impact). No `fix`, `update` or `WIP` subjects.
- Modules are nested Git repositories declared in `modules.manifest.json`
  and kept up to date by `lazurio update`. The root never uses submodules,
  `.gitmodules` or gitlink pointers and never tracks module contents. A change
  inside a module is a pull request in that module's repository.
- `main` is protected in every repository: no force push, no deletion, and
  the CI check is required where a workflow exists.
- Never reset nested module checkouts by hand.

## Security and destructive operations

- Destructive operations (`rm -rf`, forced resets, bulk deletion) only on an
  explicit instruction; prefer recoverable steps.
- Confirm actions that leave the local Environment (email, public post,
  external message, paid ad) with a person first.
- Secrets, tokens and OAuth data never go to Git. A secret an App needs lives
  in the Environment's vault and is declared by name in the App's
  `lazurio.runtime.secrets`.
- Never use a machine-specific absolute path in shared configuration; use
  `${HOME}` or repository-relative paths.

## Where to write what

There is no personal memory in this repository (`memory/`, `MEMORY.md`).

- a repeatable procedure: a skill in `.agents/skills/<name>/SKILL.md`;
- a strategic or experiment plan: Mission Control;
- a concrete next step or finished work: a Mission Control task linked to the
  plan;
- an open business decision: Mission Control; an open technical problem: a
  GitHub Issue of the owning repository;
- a rule of behaviour: the nearest `AGENTS.md`;
- strategy and guardrails: `workspace/knowledgebase/`;
- mechanism research with evidence: `workspace/research/`;
- an experiment spec, log or result: `workspace/experiments/`;
- a verified procedure: `workspace/playbooks/`;
- public text: `workspace/content/`; an internal insight: `blog/`;
- a term: `GLOSSARY.md`;
- a delivered notable change: `CHANGELOG.md`.

Do not create ad-hoc note files in the root.

## Cross-Organization isolation

An Organization is one GitHub Organization and one access boundary. This
repository never imports another Organization; Organizations are mounted next
to each other in a Lazurio Folder, never inside each other. Technical patterns
are shared through Lazurio; company data stays separate. When someone mentions
another Organization's work, point them there instead of copying data here.

## Source of truth

- Organization model: `lazurio.organization.json`
- Business context: `lazurio.organization.json#extensions.legacy.business_context`
- Generations and versions: `lazurio.organization.json#extensions.legacy.generation_policy`
- Vocabulary: `GLOSSARY.md` and `lazurio.organization.json#extensions.legacy.glossary_contract`
- Module inventory: `modules.manifest.json`
- Compatibility projection (generated): `company.gen3.json`
- Migration plan and benchmark: `MIGRATION.md`
- Maintenance manual: `manual/`
- Planning and tasks: Mission Control, data in `mission-control/db/` (repository `mission-control-data`)
- Agent skills: `.agents/skills/` (mirror in `.claude/skills/`)
- Voice guide: `company/agents/voice/`
- Access governance: `infra/access/` in the `infra` repository
- Colleague overlays: `company/colleagues/`
- Roles: `company/roles/` and `company/roles/*.role.json`
- Design system: `design-system/` (repository `design-system`)
- Internal blog: `blog/`
- Compiler outputs: `generated/`
