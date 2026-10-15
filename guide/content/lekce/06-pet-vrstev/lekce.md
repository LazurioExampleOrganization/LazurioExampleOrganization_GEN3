---
id: 06-pet-vrstev
title: "Co je kde ve workspace"
section: 2-prvni-den
order: 6
prerequisites: ["05-slop-a-jak-se-mu-vyhnout"]
duration_min: 12
quiz: true
ukol: false
---

# Co je kde ve workspace

**Co se v této lekci naučíš:**
- jak vypadá hlavní složka firmy
- k čemu slouží nejdůležitější části
- kam jít, když něco hledáš

## Pohled shora

Když otevřeš root workspace `AgentMint/`, uvidíš několik hlavních míst:

```text
AgentMint/
├── README.md, MAP.md, WORKSPACE_MANUAL.md, AGENTS.md, ARCHITECTURE.md,
│   GLOSSARY.md, TODO.md, TODO.tasks.json, DONE.tasks.json,
│   ISSUES.open.json, CHANGELOG.md
├── .claude/
├── .agents/
├── company/
├── design-system/
├── guide/
├── launchpad/
└── modules/
```

Nemusíš znát každý soubor. Pro začátek stačí vědět, k čemu tyto části slouží.

## Root soubory

Root znamená horní úroveň workspace. Soubory jako `README.md`, `MAP.md`, `AGENTS.md` nebo `GLOSSARY.md` jsou vstupní orientace.

- `README.md` je lidský úvod.
- `MAP.md` je rozcestník, když nevíš, kam jít.
- `AGENTS.md` jsou pravidla pro AI agenta.
- `GLOSSARY.md` je slovník firemních pojmů.
- `TODO.tasks.json` drží aktuální vykonatelné kroky.
- `DONE.tasks.json` drží hotovou nebo archivovanou práci.
- `ISSUES.open.json` drží otázky čekající na rozhodnutí.
- `TODO.md` je lidský pointer na task ledgery a setup postupy.
- `CHANGELOG.md` drží datumový přehled významných změn a jejich dopadu.

Když se ztratíš, nezačínej hledat naslepo. Otevři `MAP.md`.

`.agents/skills` je kanonická sdílená knihovna postupů pro agenty.
`.claude/skills` není druhá kopie, ale symlink na ni, aby ji Claude Code
viděl na své cestě.

## `company/`

Tady je firemní kostra: tým, role, společné skripty, hlas značky, pomocné nástroje a archiv. Tvoje osobní složka bude v `company/colleagues/<ty>/`.

Tohle není katalog produktů ani ceník. Je to spíš provozní část firmy: kdo jsme, jaké máme role a jak agent pozná, komu pomáhá.

## `launchpad/`

Launchpad je lokální spouštěč interních aplikací. Přes něj se otevírá například
Guide, Design System a firemní appky z modulů. Pro netechnického člověka je to
pohodlnější než ručně spouštět příkazy.

## `modules/`

Tady je nejvíc obsahu firmy. Modul v GEN2 znamená samostatný nested Git repo modul
pod `modules/<nazev>/`, tedy vlastní repozitář s vlastní historií a přístupem.
Přímo v `modules/` jsou jen registry dokumenty `README.md` a `AGENTS.md`
a potom submoduly.

- `modules/knowledgebase/` bude držet strategii, guardrails a lessons learned
- `modules/research/` bude držet mechanism scans a zdroje
- `modules/experiments/` bude držet měřitelné testy a výsledky
- `modules/playbooks/` bude držet ověřené opakovatelné mechanismy
- `modules/automations/` bude držet agentní workflow a runtime
- `modules/content/` bude držet publikační a acquisition assets
- `modules/finance/` bude držet unit economics a audit výsledků

AgentMint je zatím GitHub-backed a tyto moduly jsou planned slots. Až vzniknou
reálné repozitáře, přístup se bude řídit skutečným Git/SSH přístupem, ne tím,
co je napsané v README. Doctor umí rozlišit, jestli modul chybí kvůli
přístupu, nebo je to jen plánovaný slot.

Když má modul aplikaci, typicky žije v `app/v1/` uvnitř modulu a spouští se
přes Launchpad. Díky tomu může později vzniknout `app/v2/` vedle stabilní v1.

## Shrnutí

Root soubory tě orientují, `company/` drží firemní kostru, `launchpad/` spouští aplikace a `modules/` drží reálný obsah a kód firmy. Když nevíš, kam jít, začni v `MAP.md`. Když chceš pochopit, co se už významně změnilo, otevři `CHANGELOG.md`.

**Příště:** ukážeme si tři soubory, které tě nejčastěji navedou: `README.md`, `AGENTS.md` a `MAP.md`.
