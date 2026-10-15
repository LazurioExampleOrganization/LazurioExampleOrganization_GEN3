# Scripts TODO

Scripts úkoly drž root `TODO.tasks.json`. Tenhle soubor je jen lokální
rozcestník pro `company/scripts/`.

## Aktuální stav

- `doctor.sh` a `doctor.ps1` jsou inherited GEN2 baseline.
- `check-workspace-tasks.mjs` validuje root task ledgery.
- AgentMint je GitHub-backed workspace v organizaci `LazurioExampleOrganization`; remote/push
  kontroly musí počítat se super-repem i nested repo moduly.

## Při změně script vrstvy

1. Udrž macOS a Windows paritu.
2. Nezapisuj machine-local absolutní cesty.
3. Nepřidávej `.gitmodules` ani module pointery; moduly řeš přes manifest.
4. Ověř `bash -n` pro shell skripty a task validator.
