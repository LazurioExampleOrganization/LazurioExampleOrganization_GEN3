# Doctor fixes

Tato složka drží **fix markdowns** pro problémy, které doctor hlásí jako
`[warn]` nebo `[fail]`. Každý fix je samostatný markdown s konkrétním
postupem řešení.

## Struktura

```
doctor/fixes/<issue-slug>.md
```

Naming konvence: problem-based slug (ne tool-based), aby kolega při čtení
chápal, co řeší. Příklad: `submodule-update-failed.md`, ne `git-pull.md`.

## Kdy je fix ruční vs. subagent-spawn

- **Ruční fix** (běžný případ): markdown obsahuje kroky, které kolega nebo
  agent vykoná. Drží se v téhle složce jako reference.
- **Local repair** (implementováno): `doctor check --fix` /
  `doctor repair-local` opravuje jen nedestruktivní lokální bootstrap
  problémy a na konci spouští re-check.
- **Subagent spawn** (budoucí funkce, zatím neimplementováno): pro komplexní
  `[fail]` kategorie může budoucí doctor předat příslušný fix markdown
  subagentovi. Vyžaduje Claude Code nebo ekvivalentní runtime a nesmí obejít
  `owner` / `risk` klasifikaci ve výstupu.

## Když doctor hlásí problém, co neexistuje jako fix

1. Vytvoř nový markdown `<issue-slug>.md` s popisem problému + fix.
2. Přidej odkaz z relevantní `hint` v `doctor.sh` / `doctor.ps1`.
3. Commit jako doctor update.

## Existující fixes

- [`tooling-missing.md`](tooling-missing.md) — git/jq/bun/node chybí v PATH
- [`submodule-update-failed.md`](submodule-update-failed.md) — submodule
  update --remote selhalo
- [`super-repo-diverged.md`](super-repo-diverged.md) — super-repo pull
  --ff-only selhal
- [`super-repo-pull-rebase-failed.md`](super-repo-pull-rebase-failed.md)
  — pull --rebase narazil na konflikt
- [`pointer-push-conflict.md`](pointer-push-conflict.md) — push super-repa
  selhal kvůli pointer conflict
- [`windows-launchpad-taskbar.md`](windows-launchpad-taskbar.md) — Windows
  Launchpad shortcut existuje, ale taskbar pin nebo ikona se nechová správně
