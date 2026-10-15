# Modules

`modules/` je registry vrstva pro nested Git repozitáře AgentMint. Kromě
tohoto souboru, `AGENTS.md` a případné `.gitkeep` super-repo obsah modulů
netrackuje.

Každý top-level adresář pod `modules/<slug>/` má být samostatný repozitář s
vlastní historií, pravidly a přístupovou hranicí. Konkrétní seznam očekávaných
modulů drží výhradně root `modules.manifest.json`.

## Aktivní repozitáře

AgentMint používá manifest-only nested repo model bez `.gitmodules`.
Aktivní sloty s deklarovaným repozitářem (`repo` nebo `git.url` v root
`modules.manifest.json`):

- `modules/knowledgebase/` — strategie, guardrails, lessons learned
- `modules/research/` — mechanism scans, zdroje a market maps
- `modules/experiments/` — specs, run logs, metriky a výsledky
- `modules/playbooks/` — ověřené opakovatelné mechanismy
- `modules/automations/` — agentní workflow a runtime
- `modules/content/` — veřejné publikační a acquisition assets
- `modules/finance/` — unit economics, náklady, výnosy a audit

Nový modul se přidá až tehdy, když má jasný owner, source-of-truth roli,
GitHub repo a důvod existovat jako samostatné repo.

## Chybějící moduly

Chybějící modul není automaticky chyba. Doctor a manifest rozlišují:

- `available` — modul je naklonovaný a použitelný
- `missing_access` — modul existuje v modelu, ale kolega nemá Git/SSH přístup
- `planned_slot` — slot je v root `modules.manifest.json`, ale ještě nemá
  `repo`/`git.url`

Dokud je modul `planned_slot`, používej root task ledgery a issue ledgery.

Mission Control není modul v `modules/`; je to root-level control-plane repo
na cestě `mission-control/`.
