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
| Held | Mission Control (data repository, v3 app, activation of the root application slots and its translation) waits for a public Mission Control upstream. Until then the in-tree `mission-control/` stays as it is. |

## Phases

| Phase | Pull requests | What changes |
|---|---|---|
| 0 | none (Owner settings) | Team `workspace` with write access to the workspace modules; rulesets on `main` that forbid force pushes and deletion and require CI where a workflow exists |
| 1 | R1–R5 (root) | This plan; identity, pool and binding; `modules/` to `workspace/`; GEN2 tooling removed; the Organization guide retired |
| 2 | M1 (knowledgebase) | Lazurio Module Standard |
| 3 | O1a, O1b (design system) | New repository from the root's in-tree `design-system/`, then the Module Standard |
| 4 | T1, T2, T4–T7 | English translation of every repository |
| Held | O2–O4, T3 | Mission Control |
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
| Rulesets on `main` | Active on nine repositories: no deletion, no force push. Required status checks are added when a repository gets a CI workflow. `mission-control` is held with Mission Control |
| Lazurio for GitHub | Not installed yet; the Owner installs it |

### Pull requests

| # | Pull request | Repo | Start (UTC) | Merged (UTC) | Agent time | Human wait | Review rounds | Files | +/− | Czech lines before → after | Organization check | MS checks | CI | Broke | Human decisions | Tokens |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| R1 | [#1](https://github.com/LazurioExampleOrganization/LazurioExampleOrganization_GEN3/pull/1) | root | 2026-10-15 22:28 | 2026-10-15 22:31 | 3 min | 0 | 0 | 1 | +103/−0 | 7,297 → 7,297 | ok, `transition` | n/a | no workflow yet | nothing | none | not reported |
| R2 | [#2](https://github.com/LazurioExampleOrganization/LazurioExampleOrganization_GEN3/pull/2) | root | 2026-10-15 22:32 | 2026-10-15 22:35 | 3 min | 0 | 0 | 5 | +54/−23 | 7,297 → 7,294 | ok, `transition`, projection parity | n/a | no workflow yet | The compiler needs a template remote ([HumanAndMachines/Lazurio#556](https://github.com/HumanAndMachines/Lazurio/issues/556)) and writes Czech headings ([#557](https://github.com/HumanAndMachines/Lazurio/issues/557)); local workaround for the first | none | not reported |
| R3 | [#3](https://github.com/LazurioExampleOrganization/LazurioExampleOrganization_GEN3/pull/3) | root | 2026-10-15 22:38 | 2026-10-15 22:41 | 3 min | 0 | 0 | 12 | +322/−309 | 7,294 → 7,188 | ok, `transition`, projection parity | n/a | no workflow yet | `lazurio update` then blocked the root on in-tree App ids ([#4](https://github.com/LazurioExampleOrganization/LazurioExampleOrganization_GEN3/issues/4)), fixed in R3a | none | not reported |

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
