---
name: module-agent-maintenance
description: Sdílený workflow pro maintenance module-level docs v GEN2/GEN3 nested repo modulech (`modules/<modul>/`) — README.md, ARCHITECTURE.md, AGENTS.md, task ledgery a Mission Control vazby. Použij, když práce uvnitř modulu mění source-of-truth boundaries, data model, contracts, sync workflow nebo runtime behavior.
---

# Skill: module-agent-maintenance

Shared workflow pro udržení dokumentace a ledgerů uvnitř top-level modulu.
Modul je samostatné nested Git repo pod `modules/<slug>/`; super-repo obvykle
netrackuje jeho obsah ani SHA pointer.

## Kdy použít

Použij tenhle skill, když změna v modulu mění nebo odhaluje:

- source-of-truth boundary
- datový model, schema, writer/proposal flow nebo contract shape
- import/export/sync workflow
- runtime behavior, port, Launchpad registraci nebo access/role pravidla
- opakovaný postup, který další agent potřebuje najít bez znalosti chatu

## Preflight

Před větší prací čti:

1. root `AGENTS.md`
2. `modules/AGENTS.md`, pokud v daném workspace existuje
3. modulový `AGENTS.md`, pokud existuje
4. modulový `README.md`
5. modulový `ARCHITECTURE.md`
6. modulové `TODO.tasks.json`, `DONE.tasks.json`, `ISSUES.open.json`
7. navázaný Mission Control plán, pokud práce má `PLAN-XXXX` nebo širší scope

## Document contract

- **`README.md`** — praktické použití, scope, runtime expectations.
- **`ARCHITECTURE.md`** — current design, invarianty, source-of-truth hranice.
- **`AGENTS.md`** — krátká lokální pravidla pro agenty, ne generický runbook.
- **`TODO.tasks.json`** — aktuální vykonatelné kroky.
- **`DONE.tasks.json`** — dokončená práce s evidencí.
- **`ISSUES.open.json`** — otevřené otázky, rozhodnutí a věci, na kterých práce stojí.
- **Mission Control plán** — širší proč/scope/rizika/acceptance criteria pro větší změny.

`TODO.md` ani `IMPLEMENTATION_PLAN.md` nepoužívej jako živý plánovací ledger.
Pokud je ve starém modulu najdeš, ber je jako legacy vstup k migraci do
Mission Controlu a JSON ledgerů.

## Maintenance během práce

Když se current truth mění:

- aktualizuj `ARCHITECTURE.md`, pokud se mění design, contracts nebo boundaries
- aktualizuj `README.md`, pokud se mění praktické použití nebo operator expectation
- aktualizuj `AGENTS.md`, pokud další agent potřebuje nové lokální pravidlo
- zapiš nové kroky do `TODO.tasks.json`
- přesouvej hotovou práci do `DONE.tasks.json` s krátkou evidencí
- zapisuj nevyřešené otázky nebo access/decision gates do `ISSUES.open.json`
- u většího scope udrž vazbu na Mission Control plán (`PLAN-XXXX`)

Nenech důležité poznatky jen v chatu.

## Handoff checklist

Před uzavřením meaningful změny ověř:

- dokumentace odpovídá skutečnému stavu, ne pre-change designu
- aktivní kroky/otázky jsou v JSON ledgerech nebo Mission Controlu
- žádné nové živé checkboxy nevznikly v Markdown TODO souborech
- next recommended step je zřejmý i bez původního chatu
- uvedl jsi relevantní validační příkazy nebo důvod, proč nešly spustit
