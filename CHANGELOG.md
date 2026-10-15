# Changelog

Date versions: `YYYYMMDD`. This changelog records notable changes delivered
to the Organization root. Modules keep their own changelogs.

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

### Removed

- The GEN2 doctor, sync and bootstrap scripts, the machine setup notes and
  eleven GEN2 skills; Lazurio replaces them. `.claude/skills` is a real mirror
  instead of a symlink.
- The Organization guide (`guide/`); newcomers use the public Lazurio guide.
- The redirect stubs `ARCHITECTURE.md` and `manual/WORKSPACE_MANUAL.md`.
- The research artefacts in `company/archive/derived/` and
  `company/agents/reference/`; they live in the research module now.

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
