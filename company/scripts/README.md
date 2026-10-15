# Scripts

Složka `company/scripts/` drží bootstrap, update a doctor tooling pro AgentMint
GEN2 workspace.

AgentMint má GitHub-backed super-repo a nested repo sloty v `infra/`,
`mission-control/` a `modules/*`. Skripty nesmí zavádět `.gitmodules` ani
commitovat nested repo pointery; sloty se řídí manifestem a doctorem.

## Hlavní příkazy

| Soubor | Účel | Platforma |
|---|---|---|
| `doctor.sh` / `doctor.ps1` | hlavní entrypoint pro status, check, init, sync a task ledger validaci | macOS / Windows |
| `bootstrap-macos.sh` | tenký wrapper nad `doctor.sh init` | macOS |
| `bootstrap-windows.ps1` | tenký wrapper nad `doctor.ps1 init` | Windows |
| `update-workspace.sh` / `update-workspace.ps1` | legacy wrapper; preferuj `doctor sync` | macOS / Windows |
| `modules.manifest.json` | GEN2 kompatibilní transport (clone URL a branch) pro legacy `update-workspace`; inventář modulů drží root `modules.manifest.json`, viz „Hranice dvou manifestů" | oba |
| `check-workspace-tasks.mjs` | validace `TODO.tasks.json`, `DONE.tasks.json`, `ISSUES.open.json` včetně volitelných planning referencí | oba |

## Denní použití

```bash
company/scripts/doctor.sh status
company/scripts/doctor.sh check-my-context
company/scripts/doctor.sh workspace-tasks
company/scripts/doctor.sh check --quick
```

Na Windows:

```powershell
.\company\scripts\doctor.ps1 status
.\company\scripts\doctor.ps1 workspace-tasks
.\company\scripts\doctor.ps1 check -Quick
```

## Nested repo modules

Doménové moduly a root-level control plane sloty jsou samostatná nested Git
repozitáře podle root `modules.manifest.json`. Super-repo trackuje
jen manifest a registry dokumenty, ne obsah nested repozitářů:

- `infra`
- `mission-control`
- `modules/knowledgebase`
- `modules/research`
- `modules/experiments`
- `modules/playbooks`
- `modules/automations`
- `modules/content`
- `modules/finance`

Chybějící modul proto není automaticky chyba. `planned_slot` je slot v root
`modules.manifest.json` se `status: planned_slot` nebo bez `repo`/`git.url`.
Doctor klonuje a synchronizuje sloty, které mají v manifestu, který čte,
`git.url`.

## Hranice dvou manifestů

Inventář modulů je jeden: root `modules.manifest.json`. Druhý soubor
`company/scripts/modules.manifest.json` je GEN2 kompatibilní transport a
inventář nedefinuje.

| | root `modules.manifest.json` | `company/scripts/modules.manifest.json` |
|---|---|---|
| Role | jediný inventář modulů a Team membership | kompatibilní transport pro GEN2 skripty |
| Pole, která tu mají autoritu | existence slotu, `path`, `space`, `category`, `status` (včetně `planned_slot`), `workspace`/`teams`, `default_access`, `required_roles`, `source_of_truth`, `upstream_truth`, `app_manifests`, `notes`, identita repozitáře `repo` nebo `git.url` + `git.branch`, `platforms`, `fork_upstream` | žádné; smí jen opakovat `path` (spojovací klíč), `git.url` a `git.branch` slotu, který existuje v root manifestu |
| Kdo ho čte | Lazurio (Launchpad, `lazurio update`, migrátor, compiler); `doctor.sh` / `doctor.ps1` jako první volbu (`path`, `git.url`, `git.branch`, `platforms`, `fork_upstream`) | `update-workspace.sh` / `.ps1` a wrapper `update.sh` (jen `module_slots[].path`, `git.url`, `git.branch`); `doctor.sh` / `doctor.ps1` jen jako fallback, když root manifest chybí |

Pravidla:

- Nový slot, `planned_slot`, změna Teamu, přístupu, role nebo kategorie se
  zapisuje jen do root manifestu. Po jeho změně přegeneruj projekci
  `company.gen3.json` přes
  `lazurio migrate organization-manifest <task-worktree> --write`.
- Do `company/scripts/modules.manifest.json` nepřidávej slot, který v root
  manifestu není, a neodvozuj z něj stav modulu. Jeho `git.url` se musí rovnat
  `repo`/`git.url` stejného `path` v root manifestu; při rozporu platí root.
- Ostatní pole tohoto souboru (`platforms`, `target_repo_name`,
  `firebase_dependent`, `shared_shell`, `access_levels`, `category_reference`)
  jsou GEN2 pozůstatek: při přítomném root manifestu je nečte žádný skript.
- Soubor zanikne spolu s legacy `update-workspace` skripty.

## Git policy

- Super-repo remote je `git@github.com:LazurioExampleOrganization/LazurioExampleOrganization_GEN3.git`.
- Modulové remotes drží root `modules.manifest.json` (`repo` nebo `git.url`);
  `company/scripts/modules.manifest.json` je jen opakuje pro legacy
  `update-workspace`.
- Před commitem vždy zkontroluj diff a scope.
- Task ledgery validuj přes `doctor workspace-tasks`.
