# Team TODO

Team overlay úkoly se dlouhodobě drží v root `TODO.tasks.json`. Tenhle soubor
je jen lokální rozcestník pro person overlay vrstvu.

## Aktuální stav

- `jannovak/` existuje jako první person overlay.
- `tomas/` existuje jako onboarding scaffold; Tomáš musí doplnit role,
  ownership, preferovaný styl práce, moduly a externí služby bez secrets.
- `petr/` existuje jako onboarding scaffold; Petr musí doplnit role,
  ownership, preferovaný styl práce, moduly a externí služby bez secrets.
- Workspace směřuje k Mission Control jako lokálnímu planning task manageru;
  implementační kroky zůstávají v root `TODO.tasks.json`.
- Firemní OAuth účty zatím nejsou nastavené; `agentmint.local` je jen lokální
  placeholder.
- Další kolegové se přidají až po rozhodnutí v root task/issue ledgerech.

## Při přidání nového kolegy

1. Zkopíruj `_template/` jako `company/colleagues/<jméno>/`.
2. Vyplň `README.md` a `AGENTS.md` podle reality.
3. V osobním `*.code-workspace` změň druhý folder name z `_template` na jméno
   kolegy.
4. Ověř preflight kaskádu: root → role → person → modul.

## K doplnění Janem / týmem

- Skutečné role Tomáše a Petra.
- Jestli potřebují nové role v `company/roles/`, nebo stačí existující
  `research-operator` / `experiment-operator` / `founder`.
- GitHub access ke konkrétním nested repozitářům podle jejich práce.
- Per-person MCP konfigurace lokálně v jejich `.claude/settings.json`, nikdy v
  Gitu.
