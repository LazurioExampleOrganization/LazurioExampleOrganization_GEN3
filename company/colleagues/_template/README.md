# <VYPLNIT_JMENO>

Tato složka je **person overlay** pro <VYPLNIT_JMENO>.

## Kontext kolegy

- **Jméno:** <VYPLNIT_JMENO>
- **Primární role:** `<VYPLNIT_ROLE>` (viz
  `company/roles/<VYPLNIT_ROLE>/`)
- **Pracovní e-mail:** `<VYPLNIT>@agentmint.local`
- **<VYPLNIT_TASK_TOOL> user ID:** `<VYPLNIT>`

## Jak nejčastěji pomoci

<VYPLNIT_JAK_POMOCI>

Popiš, s čím tenhle kolega typicky potřebuje pomoci (prioritizace,
příprava podkladů, follow-upy, atd.).

## Aktivní role

Pokud kolega drží více rolí, uveď je zde s disambiguací:

- **`<role1>`** — kdy se na tebe obracet v této roli
- **`<role2>`** — kdy v téhle

## Default module set

Popiš, které moduly tenhle kolega typicky potřebuje. Skutečný přístup
se řídí SSH a root `modules.manifest.json`.

## Jak nejlépe zadávat úkoly agentovi

<VYPLNIT_JAK_ZADAVAT_UKOLY>

## Workspace ve VS Code / Cursoru

Tahle složka obsahuje `*.code-workspace` template pro multi-root
workspace. Po zkopírování `_template/` do `company/colleagues/<jmeno>/`:

1. přejmenuj soubor podle company slugu, pokud už tak není
2. otevři ho ve VS Code/Cursoru přes `File -> Open Workspace from File...`
3. v `folders[1].name` změň `_template` na `<jmeno>`

Workspace soubor i root `.vscode/settings.json` musí ponechat:
`git.autoRepositoryDetection = "subFolders"` a
`git.detectSubmodules = true`, aby editor načítal Git submoduly.

## Preferovaný jazyk

- Interní komunikace: <VYPLNIT>
- Kód a commit message: angličtina (standard GEN2)
- Externí výstupy: podle publika

## Osobní skills a paměť

- Osobní skills (v Gitu): `company/colleagues/<jmeno>/.claude/skills/`
- Osobní lokální archiv mimo Git: `company/colleagues/<jmeno>/archiv/`
- **Osobní paměť napříč projekty:** volitelný gbrain mimo workspace
  (viz root `AGENTS.md §5.1`).
- **Sdílená firemní znalost** jde do `modules/knowledgebase/`,
  `modules/wiki/`, skills nebo AGENTS.md (viz root `AGENTS.md §11`).

## Odkazy

- Operační pravidla: [AGENTS.md](AGENTS.md) (person overlay,
  <VYPLNIT_JMENO>-specific)
- Role detaily: `company/roles/<role>/`
- Company baseline: root `/AGENTS.md`, `/ARCHITECTURE.md`,
  `/GLOSSARY.md`
