---
name: mission-control-planning
description: Použij v AgentMintu, když uživatel plánuje novou feature, experiment, větší změnu fungování nebo cross-scope práci. Skill ukotví plán v lokálním Mission Control/YAML modelu a teprve potom z něj odvodí implementační kroky do TODO.tasks.json.
---

# Mission Control planning

Tento skill převádí nejasný feature záměr na dvě oddělené vrstvy:

- **Mission Control plan** — lokální YAML plán ve workspace: proč se věc dělá,
  pro koho, jaký je scope, rozhodnutí a acceptance criteria.
- **`TODO.tasks.json`** — konkrétní implementační kroky v Git workspace.

Mission Control je root-level control-plane repo `mission-control/`. Drží
plánovací kontrakt ve workspace YAML souborech a task ledgery na něj odkazují
přes `planning`.

## Kdy použít

Použij skill, když uživatel řekne například:

- „naplánuj feature“
- „pojďme udělat novou věc“
- „z toho udělej tasky“
- „rozpadni to do TODO“
- „připrav experiment“
- „tohle bude větší změna“

Jednoduchý bug fix tímto flow neblokuj, pokud je scope zřejmý a nemění se
produktové nebo provozní rozhodnutí.

## Preflight

1. Přečti root `AGENTS.md`, `MAP.md`, `WORKSPACE_MANUAL.md` a nejbližší
   relevantní `AGENTS.md`.
2. Ověř, jestli `mission-control/` existuje jako dostupné nested repo.
3. Pokud existuje, najdi nebo založ YAML plan v `mission-control/plans/`.
4. Pokud Mission Control není dostupný, vytvoř nebo aktualizuj task v root
   `TODO.tasks.json` a drž plánovací detaily v nejbližším schváleném scope.
5. Teprve potom uprav nejbližší `TODO.tasks.json`.

## Mission Control plan obsahuje

Každý feature plan má mít minimálně:

- `id`, `title`, `type`, `status`, `owner`
- cíl a business důvod
- scope a non-goals
- rozhodnutí a otevřené otázky
- acceptance criteria
- rizika a guardrails
- odkazy na relevantní workspace soubory
- odvozené `TODO.tasks.json` task IDs
- outcome po dokončení

Mission Control neobsahuje secrets, tokeny, zákaznická data ani lokální runtime
detaily, které patří do gitignored konfigurace nebo bezpečného vaultu.

## Rozpad do `TODO.tasks.json`

Po vytvoření nebo nalezení Mission Control plánu:

1. Najdi nejbližší task ledger podle scope.
2. Vytvoř malé tasky s jedním hlavním výsledkem.
3. Každý task propoj zpět na plán přes pole `planning`.
4. Do `links` přidej relevantní repo soubory, ne celý chat.
5. Pokud chybí rozhodnutí, přidej nebo aktualizuj `ISSUES.open.json`.

Příklad `planning` reference v tasku:

```json
"planning": {
  "plan_id": "plan-2026-05-23-001",
  "path": "mission-control/plans/2026/05/agent-automation-desk.yaml",
  "source": "mission-control",
  "role": "planning_source"
}
```

## Když Mission Control není dostupný

Pokud `mission-control/` chybí nebo nejde číst:

1. Nehaluzuj, že plan YAML existuje.
2. Zapiš TODO task pro opravu dostupnosti nebo vytvoření prvního planu.
3. Do tasku napiš jasný `next_action`.
4. Jakmile je repo dostupné, přesuň trvalý plánovací kontext do
   `mission-control/plans/`.

Lokální fallback je jen dočasná stopa, ne nový trvalý source of truth.

## Co nedělat

- Nevytvářej feature plán jen v chatu.
- Nedávej dlouhé strategické zadání jen do `TODO.tasks.json`.
- Nekopíruj do Mission Control secrets ani privátní zákaznická data.
- Nevytvářej duplicitní YAML plány, pokud už existuje odpovídající položka.
- Nepoužívej Notion nebo ClickUp pro AgentMint planning, pokud to uživatel
  explicitně neřekne pro jednorázovou práci.
