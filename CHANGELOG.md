# Changelog

Date versions: `YYYYMMDD`. This changelog records notable changes delivered
to the Organization root. Modules keep their own changelogs.

## Unreleased

Plan DEV-6593: the Organization is the first subscriber of the Lazurio
Marketplace and adopts three app templates of LazurioTemplates.

### Added

- `workspace/presentations`: the Presentations App, adopted from the template
  LazurioTemplates/presentations v0.2.0, with its sample deck; from `main`
  Lazurio runs its built version. It wears the design system package at the
  template's release `v2.0.0` until the Organization releases its own design
  system.

### Changed

- Mission Control takes the template LazurioTemplates/mission-control 4.1.2
  (formerly Lazurio/mission-control) and the design system the template
  LazurioTemplates/design-system 2.0.0, each by merging the release tag. The
  rules, README, glossary, migration ledger, planning skill and reference
  notes name the new sources.
- Tasks: Mission Control 4.x no longer reads the task ledgers, so a plan's
  tasks are its `proposed_tasks` and the work on them is GitHub Issues of the
  owning repository that link back to the plan. `TODO.tasks.json`,
  `DONE.tasks.json` and the issue ledgers of `mission-control-data` stay
  unchanged as history (#27).

## 20261016

GEN3 migration, plan EX-0001. Every step is a public pull request with a
benchmark row in `MIGRATION.md`.

### Changed

- The Organization has its own identity: display name "Lazurio Example
  Organization", module port pool 25300–25399, and a GitHub binding of the
  Organization, the root repository and the default Team verified by id.
- Modules moved from `modules/` to the flat `workspace/` layer; slots declare
  `teams` and `git.url`. The update model is `standalone`: the Organization
  has no template upstream.
- Root CI checks the Organization manifest, the projection parity and the
  skill mirror with a pinned commit of the public Lazurio Core.
- The root is written in English: rules, map, glossary, manual, roles,
  colleague overlays, agent knowledge, blog and the manifest text. Fictional
  people have international names (Alex Morgan, Sam Taylor, Robin Lee).
- Mission Control v3 replaces the in-tree v1 layer: the App comes from the
  public upstream Lazurio/mission-control (v3.0.1; since moved to
  LazurioTemplates/mission-control) and the plans and tasks
  live in the mission-control-data repository, imported from v1 and
  translated. The design system is its own repository. All three root
  application slots are active, and the restricted infra slot is cloned by an
  Admin install.

### Removed

- The GEN2 doctor, sync and bootstrap scripts, the machine setup notes and
  eleven GEN2 skills; Lazurio replaces them. `.claude/skills` is a real mirror
  instead of a symlink.
- The Organization guide (`guide/`); newcomers use the public Lazurio guide.
- The redirect stubs `ARCHITECTURE.md` and `manual/WORKSPACE_MANUAL.md`.
- The research artefacts in `company/archive/derived/` and
  `company/agents/reference/`; they live in the research module now.
- The in-tree `mission-control/` and `design-system/` copies and the root
  task ledgers; their content lives in the new repositories.

## 20261015

### Changed

- Published as Lazurio's public reference Organization
  `LazurioExampleOrganization`, with a fresh Git history from a cleaned
  snapshot of the GEN2 baseline. People and companies in the data are
  fictional; references to other Organizations and their private repositories
  were removed.

## Before 20261015: GEN2 history (summary)

The fictional company was set up on 2026-05-22 as a local GEN2 workspace from
a Lazurio company template: root documents for its mission (find, model, test
and scale legal online revenue mechanisms for AI agents), the roles
`founder`, `research-operator` and `experiment-operator`, the first person
overlay and planned module slots. On 2026-05-23 it got its GitHub repositories,
nested module repositories instead of submodules, the
`agent-execution-discipline` skill, a `CLAUDE.md` bootstrap and Mission
Control as its YAML-first planning layer. In early June 2026 the daily
morning and evening routines were tightened, and on 2026-06-12 the workspace
was converted in place to an Organization GEN3 with the machine model
`company.gen3.json`, the root `modules.manifest.json`, colleague overlays in
`company/colleagues/` and canonical skills in `.agents/skills/`. That history
is not part of this repository.
