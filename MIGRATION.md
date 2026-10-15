# GEN2 to GEN3 migration (plan EX-0001)

This Organization is Lazurio's public reference Organization. Its data is
fictional. It starts from a cleaned GEN2 snapshot and migrates to the current
GEN3 model here, in public pull requests. Each pull request records what it
took, so the whole migration doubles as a benchmark that other Organizations
can compare against.

This file holds the plan and the benchmark ledger. When the Organization's
Mission Control data repository exists, the plan moves there; the ledger
stays here.

## Target state

- **Thin root.** The root repository holds manifests, rules, roles, skills and
  documentation. Applications and data live in their own repositories,
  mounted as ignored nested checkouts, never as submodules.
- **Canonical manifest.** `lazurio.organization.json` is canonical and
  `company.gen3.json` is its generated projection (state `transition`). The
  Organization owns the port pool 25300–25399 and a verified GitHub binding.
- **Flat workspace.** Modules live in `workspace/<module>/`; the `modules/`
  layout is gone. Team membership is declared per slot (`teams`), and the
  Team `workspace` holds the matching GitHub grants.
- **Lazurio Module Standard.** Every module with an App (knowledgebase,
  design system) follows the standard: one TypeScript App per generation in
  `app/v<N>/`, a lease inside the pool, declared preparation, a
  single-process `dev` script and `bun run check` plus `bun test` in CI.
  Document modules have no App and declare `tcp_port_policy: none`.
- **English only.** Every surviving file is written in English. The gate is
  a grep for Czech diacritics that returns no hits.
- **No GEN2 tooling.** The Lazurio Platform replaces the GEN2 doctor, sync,
  bootstrap and the Organization guide.

## Decisions

| Id | Decision |
|---|---|
| D2 | The knowledgebase and design system templates have no public upstream. Both repositories are converted by hand and record "no upstream". |
| D3 | Display name "Lazurio Example Organization", identifiers `example-*`, domain `example.local`. Fictional people use international names without diacritics: Alex Morgan (`alexmorgan`), Sam Taylor (`samtaylor`), Robin Lee (`robinlee`) and Kim Park. |
| D4 | Until the Lazurio root ships an English locale of its managed collaboration block, `AGENTS.md` links to that block instead of embedding a translated copy. The Organization's own rules are written in English. |
| D6 | The manifest stays in `transition`. Every pull request that changes a manifest regenerates the projection. |
| D7 | The fictional business concepts stay and are translated. Prices stay placeholders. |
| D8 | Module port pool 25300–25399, disjoint from every other Organization on the maintainer machine. |
| D9 | Plan code `EX-0001`. Private plan codes never appear. |
| D10 | No private tooling is copied. Root CI runs `lazurio organization check` from a pinned commit of the public Lazurio Core. |
| D1 | Mission Control v3 comes from the public upstream [Lazurio/mission-control](https://github.com/Lazurio/mission-control) at release `v3.0.0`. The Organization's `mission-control` repository imports it (decision 0174) and adds only its `lazurio.module.json`; planning data lives in `mission-control-data` (branch `v3`). |
| D5 | The Mission Control v3 UI is Czech-only for now ([Lazurio/mission-control#1](https://github.com/Lazurio/mission-control/issues/1)). The Organization does not fork the UI; this is a known gap of the English gate. |

## Phases

| Phase | Pull requests | What changes |
|---|---|---|
| 0 | none (Owner settings) | Team `workspace` with write access to the workspace modules; rulesets on `main` that forbid force pushes and deletion and require CI where a workflow exists |
| 1 | R1–R5 (root) | This plan; identity, pool and binding; `modules/` to `workspace/`; GEN2 tooling removed; the Organization guide retired |
| 2 | M1 (knowledgebase) | Lazurio Module Standard |
| 3 | O1a, O1b (design system) | New repository from the root's in-tree `design-system/`, then the Module Standard |
| 4 | T1, T2, T4–T7 | English translation of every repository |
| 3 (continued) | O2, O3, O4, T3 | Mission Control data repository and v1 import, the v3 App from the public upstream, activation of the root application slots, translation of the planning data |
| 5 | A1 | Fresh install from GitHub and close-out |

## Benchmark method

Each pull request gets one ledger row:

- start and merge time in UTC, agent working time and time spent waiting on a
  human;
- review rounds, files changed and lines added and removed;
- Czech lines before and after: tracked lines that contain at least one Czech
  letter with a diacritic (the 15 lowercase letters U+00E1, U+010D, U+010F,
  U+00E9, U+011B, U+00ED, U+0148, U+00F3, U+0159, U+0161, U+0165, U+00FA,
  U+016F, U+00FD, U+017E and their capitals), counted over `git ls-files`;
- `lazurio organization check` for root changes, Module Standard checks
  (`lazurio module setup`, MS-01 to MS-13) for modules, and the CI result;
- what broke, with the issue and the fixing pull request;
- human decisions or permissions the step needed;
- agent tokens or cost, when the harness reports them.

A row lands in the same root pull request or in the next one.

## Ledger

### Row zero: baseline (2026-10-16)

| Measure | Result |
|---|---|
| Repositories | 10 public repositories, one commit each. Root 301 files, knowledgebase 84, mission-control 58, experiments 15, infra 6, five document modules with 3 files each |
| `lazurio organization check` | `ok: true`, state `transition` |
| `lazurio migrate organization-manifest` (plan) | `noop`, projection parity true |
| `lazurio organization activate --check` | `action_required: github_app_installation_required` |
| `lazurio module setup` | Not measurable: the Organization is not mounted |
| Czech lines | Root 7,297 in 235 files; mission-control 995; experiments 518; knowledgebase 452; infra 40; research 19; playbooks 14; content 13; automations 12; finance 12 |
| GitHub | Free plan, one member, no Teams, no app installations, `main` unprotected |
| Port leases | Every lease (5286, 55286, 5687, 5693, plus a hardcoded 5292) lies outside the declared pool 24000–24099, and that pool collides with another Organization on the maintainer machine |

### Phase 0: Owner settings (2026-10-15 22:20–22:28 UTC)

| Step | Result |
|---|---|
| Team `workspace` | Created, closed, id 20129625. Write access to knowledgebase, research, experiments, playbooks, content and automations. `finance` and `infra` are declared `restricted` and get no Team grant |
| Rulesets on `main` | Active on nine repositories: no deletion, no force push. Required status checks are added when a repository gets a CI workflow (root: "Organization check" since R4). `mission-control` is held with Mission Control |
| Lazurio for GitHub | Not installed yet; the Owner installs it |

### Pull requests

| # | Pull request | Repo | Start (UTC) | Merged (UTC) | Agent time | Human wait | Review rounds | Files | +/− | Czech lines before → after | Organization check | MS checks | CI | Broke | Human decisions | Tokens |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| R1 | [#1](https://github.com/LazurioExampleOrganization/LazurioExampleOrganization_GEN3/pull/1) | root | 2026-10-15 22:28 | 2026-10-15 22:31 | 3 min | 0 | 0 | 1 | +103/−0 | 7,297 → 7,297 | ok, `transition` | n/a | no workflow yet | nothing | none | not reported |
| R2 | [#2](https://github.com/LazurioExampleOrganization/LazurioExampleOrganization_GEN3/pull/2) | root | 2026-10-15 22:32 | 2026-10-15 22:35 | 3 min | 0 | 0 | 5 | +54/−23 | 7,297 → 7,294 | ok, `transition`, projection parity | n/a | no workflow yet | The compiler needs a template remote ([HumanAndMachines/Lazurio#556](https://github.com/HumanAndMachines/Lazurio/issues/556)) and writes Czech headings ([#557](https://github.com/HumanAndMachines/Lazurio/issues/557)); local workaround for the first | none | not reported |
| R3 | [#3](https://github.com/LazurioExampleOrganization/LazurioExampleOrganization_GEN3/pull/3) | root | 2026-10-15 22:38 | 2026-10-15 22:41 | 3 min | 0 | 0 | 12 | +322/−309 | 7,294 → 7,188 | ok, `transition`, projection parity | n/a | no workflow yet | `lazurio update` then blocked the root on in-tree App ids ([#4](https://github.com/LazurioExampleOrganization/LazurioExampleOrganization_GEN3/issues/4)), fixed in R3a | none | not reported |
| R3a | [#5](https://github.com/LazurioExampleOrganization/LazurioExampleOrganization_GEN3/pull/5) | root | 2026-10-15 22:42 | 2026-10-15 22:44 | 2 min | 0 | 0 | 3 | +11/−2 | 7,188 → 7,188 | ok, `transition` | n/a | no workflow yet | fixes [#4](https://github.com/LazurioExampleOrganization/LazurioExampleOrganization_GEN3/issues/4); the next `lazurio update` was green (155 current, root updated, 0 blocked) | none | not reported |
| R4 | [#6](https://github.com/LazurioExampleOrganization/LazurioExampleOrganization_GEN3/pull/6) | root | 2026-10-15 22:46 | 2026-10-15 22:49 | 3 min | 0 | 0 | 57 | +633/−9,807 | 7,188 → 5,086 | ok, `transition`, projection parity | n/a | pass (first root CI run) | nothing | none | not reported |
| R5 | [#7](https://github.com/LazurioExampleOrganization/LazurioExampleOrganization_GEN3/pull/7) | root | 2026-10-15 22:50 | 2026-10-15 22:52 | 2 min | 0 | 0 | 103 | +101/−9,552 | 5,086 → 3,205 | ok, `transition`, projection parity | n/a | pass | nothing | none | not reported |
| M1 | [knowledgebase#1](https://github.com/LazurioExampleOrganization/knowledgebase/pull/1) | knowledgebase | 2026-10-15 22:55 | 2026-10-15 23:01 | 6 min | 0 | 0 | 53 | +718/−4,071 | 452 → 266 | n/a | 7/13 → 13/13 | pass | nothing | none | not reported |
| O1a | [design-system](https://github.com/LazurioExampleOrganization/design-system) created, `git subtree split` of `design-system/` pushed | design-system | 2026-10-15 23:03 | 2026-10-15 23:05 | 2 min | 0 | 0 | 21 | split | 65 → 65 | n/a | not linked to a slot | none | The split carried a squash commit whose author was the merging account's email; rewritten to the noreply address before the ruleset existed | none | not reported |
| O1b | [design-system#1](https://github.com/LazurioExampleOrganization/design-system/pull/1) | design-system | 2026-10-15 23:06 | 2026-10-15 23:10 | 5 min | 0 | 0 | 24 | +771/−397 | 65 → 31 | n/a | 13/13 (in a scratch Folder; slot still planned) | pass | `gh pr merge --author-email` with the noreply address is rejected; merged by fast-forwarding `main` to the green head | none | not reported |
| T6c | [playbooks#1](https://github.com/LazurioExampleOrganization/playbooks/pull/1) | playbooks | 2026-10-15 23:13 | 2026-10-15 23:16 | 3 min | 0 | 0 | 2 | +17/−17 | 14 → 0 | n/a | 13/13 | none | nothing | none | subagent, 121k tokens for T6b–e |
| T6d | [content#1](https://github.com/LazurioExampleOrganization/content/pull/1) | content | 2026-10-15 23:13 | 2026-10-15 23:17 | 4 min | 0 | 0 | 2 | +16/−16 | 13 → 0 | n/a | 13/13 | none | nothing | none | (T6b–e) |
| T6e | [finance#1](https://github.com/LazurioExampleOrganization/finance/pull/1) | finance | 2026-10-15 23:13 | 2026-10-15 23:17 | 4 min | 0 | 0 | 2 | +16/−14 | 12 → 0 | n/a | 13/13 | none | nothing | none | (T6b–e) |
| T6b | [automations#1](https://github.com/LazurioExampleOrganization/automations/pull/1) | automations | 2026-10-15 23:13 | 2026-10-15 23:18 | 5 min | 0 | 0 | 2 | +16/−15 | 12 → 0 | n/a | 13/13 | none | nothing | none | (T6b–e) |
| T4 | [design-system#2](https://github.com/LazurioExampleOrganization/design-system/pull/2) | design-system | 2026-10-15 23:13 | 2026-10-15 23:20 | 7 min | 0 | 0 | 6 | +86/−70 | 31 → 0 | n/a | 13/13 (scratch Folder) | pass | nothing | none | subagent, 140k tokens |
| T7 | [infra#1](https://github.com/LazurioExampleOrganization/infra/pull/1) | infra | 2026-10-15 23:13 | 2026-10-15 23:21 | 8 min | 0 | 0 | 5 | +130/−67 | 40 → 0 | n/a | n/a (restricted root repository) | none | nothing | none | subagent, 138k tokens |
| T6a | [research#1](https://github.com/LazurioExampleOrganization/research/pull/1) | research | 2026-10-15 23:13 | 2026-10-15 23:23 | 10 min | 0 | 0 | 6 | +923/−23 | 19 → 0 (plus about 830 lines moved out of the root and translated) | n/a | 13/13 | none | nothing | none | subagent, 207k tokens |
| T5 | [experiments#1](https://github.com/LazurioExampleOrganization/experiments/pull/1) | experiments | 2026-10-15 23:13 | 2026-10-15 23:24 | 11 min | 0 | 0 | 14 | +678/−645 | 518 → 0 | n/a | 13/13 | none | nothing | none | subagent, 186k tokens |

### Mount on the maintainer machine (2026-10-15 22:35–22:38 UTC)

| Step | Result |
|---|---|
| `git clone` into `organizations/LazurioExampleOrganization_GEN3` | Root at R2 |
| `lazurio update --json` | Cloned automations, content, experiments, playbooks, research and knowledgebase into `modules/`. Knowledgebase `blocked`: its App id must start with the Organization prefix and collides with an App id of another mounted Organization (fixed in M1) |
| `lazurio organization install LazurioExampleOrganization --json` (Admin, restricted slots included) | Cloned `finance`. `blocked` with `repository_db_not_active`: an Organization that declares Mission Control needs its active `mission-control/db` mount, which is held. `infra` was not cloned |

### Moving checkouts to `workspace/` (2026-10-15 22:41–22:46 UTC)

| Step | Result |
|---|---|
| `lazurio update --json` after R3 | Root fast-forwarded. All seven module checkouts reported `repository_location_mismatch` (checkout in `modules/<slug>`, manifest expects `workspace/<slug>`). Root `blocked` on in-tree App ids ([#4](https://github.com/LazurioExampleOrganization/LazurioExampleOrganization_GEN3/issues/4)) |
| `lazurio repair module-location --org LazurioExampleOrganization --module <slug>` | Check-only plan `ready` for all seven: path change only, origin unchanged |
| Same with `--apply --expect <fingerprint>` | `repaired` for all seven; every checkout is clean `main` at its previous commit in `workspace/<slug>`; the empty `modules/` directory removed by hand |

### Conformance after the move (2026-10-15 22:46 UTC)

`lazurio module setup organizations/LazurioExampleOrganization_GEN3/workspace/<module> --root <Lazurio Folder> --json`:

| Module | Result |
|---|---|
| automations, content, experiments, finance, playbooks, research | `current`, 13/13 |
| knowledgebase | `actionable`, 7/13: MS-01 (leases outside the pool and shared with another Organization), MS-02, MS-04, MS-06, MS-07, MS-08. Fixed in M1 |

### Merge method and commit authorship

GitHub writes the merging account's default web commit email as the author
of a squash merge, and rejects the noreply address as `--author-email` while
the account's email privacy is off. The squash merges of root PRs #1 to #7 and
knowledgebase#1 therefore carry that address; the Owner accepted the
exposure, and history is not rewritten. From design-system#1 on, every pull
request is a single commit authored with the noreply address, and it is
merged by fast-forwarding `main` to that commit once CI is green on it; the
rulesets allow this and GitHub marks the pull request as merged.

### Known gaps

- `generated/` keeps the compiler's Czech headings until the compiler gains
  an English locale ([HumanAndMachines/Lazurio#557](https://github.com/HumanAndMachines/Lazurio/issues/557));
  regenerating it needs a template remote the Organization does not have
  ([HumanAndMachines/Lazurio#556](https://github.com/HumanAndMachines/Lazurio/issues/556)).
- The Mission Control v3 UI is Czech-only
  ([Lazurio/mission-control#1](https://github.com/Lazurio/mission-control/issues/1)).
