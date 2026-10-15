# Mapa Organizace AgentMint

Krátký rozcestník: kam jít, když potřebuješ něco najít nebo změnit. Strojový
model drží `lazurio.organization.json`; tenhle soubor je jeho lidský průvodce.

## Root povrchy

```text
LazurioExampleOrganization_GEN3/
├── README.md, MAP.md, AGENTS.md, ARCHITECTURE.md, GLOSSARY.md, CHANGELOG.md
├── TODO.tasks.json, DONE.tasks.json, ISSUES.open.json   # task ledgery
├── lazurio.organization.json, modules.manifest.json     # strojový model + deskriptor modulů
├── company.gen3.json                                    # generovaná kompatibilní projekce, ručně needitovat
├── manual/          # provozní a migrační manuály (WORKSPACE_MANUAL)
├── .agents/         # kanonická sdílená skill knihovna (.claude/skills je symlink)
├── company/         # role, colleagues, agentní voice/reference, skripty, toolbox
├── mission-control/ # in-tree plánovací vrstva (YAML plány) + UI aplikace
├── design-system/   # vizuální systém, tokeny, šablony, viewer
├── guide/           # interaktivní onboarding
├── blog/            # interní aha momenty (drafty)
├── modules/         # doctor-managed nested repozitáře (knowledgebase, research, experiments, …)
├── workspace/       # registry default Teamu (moduly logicky patří sem, fyzicky do modules/)
├── productionspace/ # org-level release/produkční vrstva (zatím prázdná)
└── generated/       # historické compiler snapshoty — nejsou runtime autorita, needituj ručně
```

Root nemá být odkladiště. Nová věc patří do jednoho z těchto povrchů,
konkrétního modulu, skillu nebo archivu.

## Rychlé routování

| Otázka | Kam se podívat |
|---|---|
| Jak Organizace funguje jako celek? | `README.md` + `lazurio.organization.json` |
| Co znamená pojem? | `GLOSSARY.md` |
| Jaké pravidlo platí pro agenta? | nejbližší `AGENTS.md` (kaskáda root → role → colleague → modul) |
| Co je rozdělané? | root `TODO.tasks.json` nebo nejbližší modulový `TODO.tasks.json` |
| Co je hotové nebo archivované? | `DONE.tasks.json` v daném scope |
| Co čeká na rozhodnutí? | `ISSUES.open.json` v daném scope |
| Jaká je struktura nebo invariant? | `ARCHITECTURE.md` v daném scope |
| Co už se změnilo? | `CHANGELOG.md` v daném scope |
| Kde plánovat feature nebo experiment? | `mission-control/` (YAML plány) |
| Kde je business kontext, decision rights, metriky? | `lazurio.organization.json#extensions.legacy.business_context` |
| Kde zapsat strategii a guardrails? | `modules/knowledgebase/` |
| Kde je mechanism research s evidencí? | `modules/research/` |
| Kde je experiment spec, log a výsledek? | `modules/experiments/` |
| Kde je ověřený opakovatelný postup? | `modules/playbooks/` |
| Kde vzniká veřejný text? | `modules/content/` |
| Kde je interní aha moment? | `blog/` |
| Kde řešit vizuální nebo formátovaný výstup? | `design-system/` (nejdřív skill `design-system-lookup`) |
| Kde je onboarding pro nové kolegy? | `guide/` |
| Kde je opakovatelný agentní postup? | `.agents/skills/` (index `manifest.json` + `company/agents/SKILLS_INVENTORY.md`) |
| Jaké moduly Organizace má a jaký mají stav? | `modules.manifest.json` (`company.gen3.json#modules` se z něj jen generuje) |

## `company/`

Firemní kostra trackovaná přímo v repu.

- `company/roles/` — reusable role overlays + `*.role.json`
- `company/colleagues/` — person overlays (složka podle lokálního OS username)
- `company/agents/` — voice, reference a skills inventory
- `company/scripts/` — Doctor, manifest modulů a check skripty
- `company/toolbox/` — sdílené utility

## `modules/`

`modules/` je registry vrstva pro doctor-managed nested Git repozitáře. Kromě
`modules/README.md` a `modules/AGENTS.md` má každý aktivní modul vlastní repo
a access hranici; super-repo netrackuje jejich obsah ani pointery. Přesný
seznam a očekávané stavy drží `modules.manifest.json`.

Věcnou práci nedělej přímo v `modules/` — přejdi do konkrétního
`modules/<slug>/` a přečti jeho nejbližší `AGENTS.md`.

## Když něco nefunguje

Spusť Doctor. Pro běžnou práci nejdřív srovnej `main` referenci, potom řeš
kontext:

```bash
company/scripts/doctor.sh sync
company/scripts/doctor.sh status
company/scripts/doctor.sh check-my-context
```

Na Windows použij `company/scripts/doctor.ps1`.

## Chybějící moduly

Chybějící modul není automaticky chyba. Doctor a manifest rozlišují:

- `available` — modul je naklonovaný a použitelný
- `missing_access` — kolega nemá SSH/GitHub přístup
- `planned_slot` — slot v root `modules.manifest.json` bez `repo`/`git.url`
  (`company/scripts/modules.manifest.json` je jen GEN2 kompatibilní transport
  a sloty nedefinuje; hranici polí drží `company/scripts/README.md`)

Plný GEN2 rozcestník není součástí tohoto veřejného snapshotu.
