# Fix: super-repo diverged

Doctor hlásí: **`[fail] super-repo pull --ff-only selhal (možná diverged)`**.

## Co to znamená

Super-repo má lokální commity, které **nejsou upstream**, a upstream má
commity, které **nejsou lokálně**. Fast-forward merge není možný — větve
se rozešly.

## Diagnóza

```bash
cd <cesta-k-workspace>
git log --oneline origin/main..HEAD      # tvoje lokální commity
git log --oneline HEAD..origin/main      # upstream commity
```

## Fix

### Nejčastější: doctor sync --rebase

Doctor má `--rebase` flag, který to vyřeší bezpečně:

```bash
doctor sync --rebase
```

To provede `git pull --rebase origin main`, který:

- přesune tvoje lokální commity na vrchol upstream historie
- zachová lineární historii (bez merge commit)

Pokud rebase projde čistě, `doctor sync` pokračuje se submodule updatem.

### Pokud rebase narazí na konflikt

Doctor sync --rebase zavolá interně git pull --rebase. Pokud konflikt:

- git ti řekne, které soubory
- edituj je, vyřeš konflikt, `git add <file>`, `git rebase --continue`
- pak retry `doctor sync`

### Konflikt na submodule pointeru

Pokud konflikt je na submodule pointeru (dva různí lidé pushli pointer
stejného submodulu), použij skill:

```
resolve-pointer-conflict
```

Viz `.claude/skills/resolve-pointer-conflict/SKILL.md`.

**NIKDY** nepoužívej `git reset --hard origin/main` pro "vyřešení" —
ztratíš lokální práci. Vždy rebase nebo explicit merge.
