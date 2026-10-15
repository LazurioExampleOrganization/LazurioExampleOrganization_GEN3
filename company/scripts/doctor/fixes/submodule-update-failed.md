# Fix: submodule update failed

Doctor hlásí: **`[warn] <modul> submodule update selhal`** během `doctor sync`.

## Co to znamená

`git submodule update --remote --merge -- <modul>` selhal. Typické příčiny:

1. **Submodul je dirty** (lokální změny nebo uncommitted soubory) —
   merge by je přepsal.
2. **Missing_access** — SSH ACL změnilo a modul už není dostupný.
3. **Branch divergence** — submodul má lokální commity, které nejsou
   upstream, a merge by vytvořil unclean historii.
4. **Network/SSH výpadek** — dočasná chyba.

## Diagnóza

Běž do submodulu a podívej se:

```bash
cd modules/<modul>
git status
git log --oneline origin/main..HEAD
git log --oneline HEAD..origin/main
```

Interpretace:

- `git status` nečistý → fix podle bodu 1 níže
- lokální commity ahead → fix podle bodu 3 níže
- `origin` nedostupný → fix podle bodu 2 nebo 4 níže

## Fix

### 1. Dirty submodul

Commit nebo stash lokální změny, pak retry:

```bash
cd modules/<modul>
# buď:
git add -A && git commit -m "WIP local changes"
git push origin main
# nebo:
git stash
```

Pak `doctor sync` znovu.

### 2. Missing access (SSH)

```bash
ssh -T git@github.com
```

Pokud SSH neodpovídá nebo říká, že nemáš access na repo:

- zkontroluj `~/.ssh/config` a `~/.ssh/id_*`
- požádej workspace admine o přidání SSH klíče k repo ACL
- označ modul v manifestu jako role-based a pokračuj bez něj

### 3. Branch divergence

Pokud máš lokální commity, které ještě nejsou upstream:

```bash
cd modules/<modul>
git branch --show-current   # měl by být main
git pull --rebase origin main
# vyřeš případné konflikty
git push origin main
```

Pak `doctor sync` znovu.

### 4. Network / dočasný výpadek

Zkus znovu za chvíli:

```bash
doctor sync
```

Pokud stále fail, ověř připojení:

```bash
ping github.com
ssh -T git@github.com
```
