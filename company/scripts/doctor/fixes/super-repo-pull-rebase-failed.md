# Fix: super-repo pull --rebase failed

Doctor hlásí: **`[fail] super-repo pull --rebase selhal`**.

## Co to znamená

`git pull --rebase origin main` na super-repu narazil na konflikt nebo
jinou chybu. Typicky:

1. **Konflikt v textovém souboru** (AGENTS.md, TODO.md, GLOSSARY.md)
2. **Konflikt na submodule pointeru** (stejný modul pushly dvě strany)
3. **Pre-rebase check selhal** (dirty working tree — ale doctor sync
   by tohle měl zachytit dřív)

## Diagnóza

```bash
cd <cesta-k-workspace>
git status
```

Git ti řekne:

- `You are currently rebasing branch 'main' on ...`
- jaké soubory mají konflikt

## Fix

### Konflikt v textovém souboru

1. Otevři každý konfliktní soubor v editoru.
2. Najdi sekce `<<<<<<<`, `=======`, `>>>>>>>`.
3. Vyřeš konflikt (spoj obě změny smysluplně; nezahazuj upstream).
4. `git add <file>` pro každý vyřešený soubor.
5. `git rebase --continue`

### Konflikt na submodule pointeru

Použij skill `resolve-pointer-conflict`:

```
.claude/skills/resolve-pointer-conflict/SKILL.md
```

Skill automaticky detekuje, jestli je konflikt:

- **Case A** (nekolidující submoduly): Git to vyřeší sám.
- **Case B** (`.gitmodules` merge): ruční merge .gitmodules
- **Case C** (stejný submodul z dvou stran): eskaluje uživateli, ať
  rozhodne — **nikdy automaticky nemerge**.

### Abort rebase a zkus jinak

Pokud se situace zamotala:

```bash
git rebase --abort
```

Vrátí tě do stavu před rebasem. Pak:

```bash
git fetch origin
git log --oneline origin/main..HEAD
git log --oneline HEAD..origin/main
```

A rozhodni, jak pokračovat podle toho, co vidíš.

## Co NIKDY nedělej

- `git push --force` pro "vyřešení" — zničíš historii pro ostatní
- `git reset --hard origin/main` — ztratíš lokální commity
- `git rebase --skip` bez porozumění — můžeš ztratit commit
