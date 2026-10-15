# Tomáš

Tato složka je person overlay pro Tomáše v AgentMint.

## Stav vyplnění

Tento profil je založený jako onboarding scaffold. Tomáš si má doplnit role,
pracovní identitu, preference a hranice práce s agenty. Dokud nejsou pole níže
vyplněná, agent nesmí domýšlet jeho odpovědnosti ani přístupy.

## Kontext kolegy

- **Jméno:** Tomáš
- **Slug ve workspace:** `tomas`
- **Primární role:** DOPLNIT jednu z existujících rolí v `company/roles/`, nebo
  navrhnout novou roli v `company/roles/TODO.md`.
- **Další aktivní role:** DOPLNIT, pokud bude držet více rolí.
- **Pracovní e-mail:** DOPLNIT. Nepoužívat `agentmint.local` jako OAuth
  identitu; je to jen lokální placeholder.
- **Planning systém:** Mission Control jako lokální YAML-first plánovací vrstva;
  root task ledgery jsou source of truth pro implementační práci.
- **Externí účty / MCP:** DOPLNIT jen názvy služeb. Tokeny a session data
  patří do gitignored lokální konfigurace, ne do Gitu.

## Co má Tomáš doplnit

- Primární roli a případné další role.
- Co v AgentMintu vlastní a o čem smí rozhodovat.
- Které moduly běžně potřebuje.
- Jak má agent poznat, kdy se má doptat.
- Preferovaný styl komunikace a délku shrnutí.
- Jaké externí akce vyžadují jeho potvrzení.
- Případný tone of voice source of truth.

## Jak nejčastěji pomoci

DOPLNIT podle Tomášovy skutečné práce v AgentMintu.

Příklad struktury:

- prioritizace a rozpad práce
- research podklady
- technická implementace
- kontrola kvality
- follow-upy a handoffy

## Aktivní role

Vyplnit po rozhodnutí o odpovědnosti:

- **`DOPLNIT_ROLE`** — kdy se tato role aktivuje

Pokud Tomáš drží více rolí, musí tady být jasná disambiguace. Při nejasném
zadání se agent doptá, kterou rolí má úkol řešit.

## Default module set

DOPLNIT podle reálného přístupu a práce. Skutečný GitHub access se řídí SSH
přístupem a root `modules.manifest.json`.

## Preferovaný jazyk

- Interní komunikace s agentem: DOPLNIT
- Kód a commit message: angličtina
- Externí výstupy: podle publika a kanálu

## Workspace ve VS Code / Cursoru

Použij `agentmint.code-workspace` v této složce. Workspace musí ponechat:
`git.autoRepositoryDetection = "subFolders"` a `git.detectSubmodules = true`,
aby editor načítal root i nested Git repozitáře.

## Osobní skills a paměť

- Osobní skills: `company/colleagues/tomas/.claude/skills/`
- Lokální archiv mimo Git: `company/colleagues/tomas/archiv/`
- Osobní napříč-projektová paměť je mimo workspace.
- Sdílená firemní znalost patří do správného workspace dokumentu, Mission
  Control plánu, knowledgebase nebo sdíleného skillu.

