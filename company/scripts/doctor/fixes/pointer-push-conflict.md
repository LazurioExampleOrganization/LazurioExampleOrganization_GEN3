# Fix: pointer push conflict

Doctor hlásí během `doctor push`:
**`[warn] super-repo push selhal (možná pointer conflict)`**.

## Co to znamená

Commit pointer update v super-repu se podařil lokálně, ale `git push
origin main` selhal. Typicky protože:

1. **Někdo mezitím pushnul jiný pointer update** (non-fast-forward).
2. **Konflikt na stejném submodule pointeru** (dvě strany posunuly
   pointer stejného modulu jiným směrem).

## Fix — použij skill

```
resolve-pointer-conflict
```

Detailní flow v `.claude/skills/resolve-pointer-conflict/SKILL.md`. Skill
dělá toto:

1. `git pull --rebase origin main`
2. Zhodnotí výsledek:
   - **Case A** (nekolidující submoduly, různé moduly): rebase projde
     automaticky; retry push.
   - **Case B** (konflikt v `.gitmodules`): ruční merge, pak
     `git rebase --continue` a retry push.
   - **Case C** (konflikt na stejném submodule pointeru): **eskaluje
     uživateli**. Nikdy automaticky nemerge — ztratil by se kontext,
     která strana je správná.

## Ruční fix (pokud skill není dostupný)

```bash
cd <cesta-k-workspace>
git pull --rebase origin main
```

### Rebase projde bez konfliktu

```bash
git push origin main
```

Hotovo.

### Rebase narazí na textový konflikt (mimo submodule pointery)

Vyřeš ručně, `git add`, `git rebase --continue`, pak push.

### Rebase narazí na `CONFLICT (submodule): modules/<X>`

Podívej se, jestli upstream verze obsahuje tvoji verzi (nebo naopak):

```bash
cd modules/<X>
git log --oneline <upstream-sha>
git log --oneline <your-sha>
```

Pokud jeden je ancestor druhého, vezmi novější:

```bash
cd <cesta-k-workspace>
git checkout --theirs modules/<X>   # nebo --ours, podle kontextu
git add modules/<X>
git rebase --continue
git push origin main
```

Pokud ani jeden není ancestor (oba jsou divergent commits), **zastav se**
a vrať se k skill `resolve-pointer-conflict` nebo zeptej workspace admine. Nikdy
automaticky neslučuj divergent pointer updates — přepsal bys cizí práci.

## Co NIKDY nedělej

- `git push --force origin main` — přepíšeš cizí pointer update
- `git push --force-with-lease` bez explicitního svolení — totéž, jen
  trošku víc transparentní
