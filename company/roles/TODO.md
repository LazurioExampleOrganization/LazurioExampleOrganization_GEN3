# Roles TODO

Role overlay úkoly se dlouhodobě drží v root `TODO.tasks.json`. Tenhle soubor
je jen lokální rozcestník pro role vrstvu.

## Aktuální stav

AgentMint má tři kanonické role:

- `founder`
- `research-operator`
- `experiment-operator`

## Při změně role modelu

1. Uprav `company/roles/README.md`.
2. Přidej nebo změň konkrétní `README.md` a `AGENTS.md` v dané roli.
3. Promítni změnu do root `modules.manifest.json`, pokud mění přístup nebo
   ownerství modulů, a projekci `company.gen3.json` přegeneruj přes
   `lazurio migrate organization-manifest <task-worktree> --write`.
4. Uprav person overlays, které roli používají.
