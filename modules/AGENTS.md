# Modules — pravidla pro agenta

Tento soubor platí pro registry vrstvu `modules/`. Root `AGENTS.md` zůstává
company baseline; tenhle soubor doplňuje pravidla pro práci s nested repo
moduly.

## Nejdřív urči modul

Nepracuj přímo v `modules/` kromě úprav registry dokumentů nebo manifestové
orientace. Pro věcnou práci vždy přejdi do konkrétního `modules/<slug>/` a
přečti jeho nejbližší `AGENTS.md`, pokud existuje.

Pokud úkol míří na modul s deklarovaným repozitářem (`repo` nebo `git.url`
v root `modules.manifest.json`), pracuj přímo v jeho nested repozitáři. Pokud
jde o plánovaný slot bez `repo`/`git.url`, použij root task/issue ledger nebo
navrhni založení modulu.

## Registry invarianty

- `modules/` není běžná složka pro libovolný kód nebo poznámky.
- Každý top-level modul má být nested Git repo s deklarovaným repozitářem,
  nebo vědomý `planned_slot` — obojí výhradně v root `modules.manifest.json`,
  jediném inventáři modulů. `company/scripts/modules.manifest.json` slot ani
  `planned_slot` nedefinuje; je to jen GEN2 kompatibilní transport (hranici
  polí drží `company/scripts/README.md`).
- Nový top-level modul zakládej až po rozhodnutí foundera o ownerovi, účelu a
  source-of-truth roli.
- Super-repo netrackuje obsah modulů ani gitlink pointery.
- Chybějící modul neobcházej kopírováním dat odjinud. Rozliš `missing_access`
  a `planned_slot`.

## AgentMint bezpečnost

- Research a experiment data nesmí obsahovat secrets, cizí zákaznická data ani
  přihlašovací údaje platforem.
- Nepřenášej do AgentMint interní strategii jiné firmy. Přenositelné jsou jen
  obecné, anonymizované patterny.
- Ověřené mechanismy patří do playbooků až po důkazu; nápady a hypotézy drž v
  research/experiments.
