---
name: upstream-rebase-fork
description: Rebase fork nested repo modulu proti upstreamu (např. modules/<parent>/<fork> proti <upstream-org>/<parent>.git podle manifest.fork_upstream). Ověří 3-remote setup + rerere, fetchne upstream, rebaseuje main, při konfliktu eskaluje uživateli (nikdy auto-merge). Po úspěšném rebase nabídne --force-with-lease push s explicit user confirm. AgentMint super-repo po pushi necommitujte jako pointer update.
---

# Skill: upstream-rebase-fork

Standardní flow pro synchronizaci **fork nested repo modulu** s jeho upstreamem
v GEN2 Workspace. Fork moduly poznáš podle pole
`fork_upstream` v root `modules.manifest.json` (viz root
`ARCHITECTURE.md §19`).

## Kdy tenhle skill použít

- Fork nested repo modul je lag za `upstream/main` (typicky `doctor check` to
  hlásí jako info)
- Uživatel řekl „rebasuj studio proti upstreamu" nebo ekvivalent
- Nový upstream release / security patch

## Kdy tenhle skill **NE**použít

- **Interní firemní nested repo moduly** (většina v `modules/`) — nemají
  upstream, rebase se neaplikuje; použij normální Git flow
- **`modules/monorepo/`, `modules/firmware/`** — task-driven workflow
  přes `codex/PLAN-XXXX` PR (viz skill `monorepo-fix`)
- Řešení běžného non-fast-forward konfliktu s kolegou v interním
  modulu — to je `resolve-pointer-conflict` skill

## Preflight

Proměnné:

- `$FORK` — cesta fork nested repo modulu (např. `modules/content/studio`)
- `$ROOT` — absolutní cesta root super-repa

Ověř v tomto pořadí:

### 1. Modul je reálně fork (manifest check)

```bash
jq -e ".module_slots[] | select(.path == \"${FORK}\") | .fork_upstream" \
  "$ROOT/modules.manifest.json" >/dev/null
```

Pokud exit code ≠ 0 → modul není fork podle manifestu. **Zastav se**.

### 2. Tři remoty jsou nakonfigurované

```bash
cd "$ROOT/$FORK"
git remote -v
```

Musí obsahovat:

- `origin` — firemní fork
- `upstream` — firemní mirror parent repa (`fork_upstream.mirror`)
- `<parent>-origin` — původní upstream (`fork_upstream.source`)

Pokud některý chybí, auto-nastav z manifest pole:

```bash
MIRROR="$(jq -r ".module_slots[] | select(.path==\"${FORK}\") | .fork_upstream.mirror" "$ROOT/modules.manifest.json")"
SOURCE="$(jq -r ".module_slots[] | select(.path==\"${FORK}\") | .fork_upstream.source" "$ROOT/modules.manifest.json")"
# Parent-origin name z URL basename
PARENT_NAME="$(basename -s .git "$MIRROR")"

git remote add upstream "$MIRROR"             2>/dev/null || true
git remote add "${PARENT_NAME}-origin" "$SOURCE"   2>/dev/null || true
```

### 3. `rerere` zapnuté

```bash
git config --get rerere.enabled   # musí vrátit 'true'
git config --get rerere.autoupdate # doporučeno 'true'
```

Pokud není:

```bash
git config rerere.enabled true
git config rerere.autoupdate true
```

### 4. Jsme na `main` a worktree je clean

```bash
git branch --show-current          # musí vrátit 'main'
git status --porcelain             # musí být prázdné
```

Pokud ne — **zastav**. Uživatel má dirty state; commit/stash/reset
podle kontextu, pak spusť znovu.

## Flow

### Krok 1: Fetch upstream

```bash
cd "$ROOT/$FORK"
git fetch upstream
```

Zjisti, jak daleko je `origin/main` za `upstream/main`:

```bash
UP_AHEAD="$(git rev-list --count main..upstream/main)"
UP_BEHIND="$(git rev-list --count upstream/main..main)"
echo "origin/main je $UP_AHEAD commits za upstream/main a $UP_BEHIND commits ahead (lokální firemní changes)."
```

### Krok 2: Rebase

```bash
git rebase upstream/main
```

### Krok 3: Zhodnoť výsledek

#### Case A — Rebase projde čistě

Lokální commity se elegantně aplikují na upstream. `rerere` si
možná pamatovalo konflikty z minula a vyřešilo je automaticky.

Přejdi na krok 4 (push).

#### Case B — Konflikt, který rerere vyřešil automaticky

Pokud `rerere.autoupdate=true`, Git znovu aplikuje zapamatované
řešení. Výstup obsahuje:

```
Auto-merging <file>
Recorded resolution for '<file>'.
```

Ověř, že resolution dává smysl:

```bash
git diff --cached
```

Pokud OK:

```bash
git add <files>   # pro jistotu
git rebase --continue
```

Pokud rerere aplikovalo špatně, **zastav se** a eskaluj (viz Case C).

#### Case C — Konflikt, který vyžaduje rozhodnutí

**ESKALUJ UŽIVATELI.** Nikdy automaticky neslučuj divergent change.

Výstup skillu:

```
❌ Rebase konflikt v ${FORK}:

Upstream: ${UPSTREAM_SHA} — "${UPSTREAM_MSG}"
Tvůj:     ${LOCAL_SHA}    — "${LOCAL_MSG}"

Konfliktní soubory:
  - <file1>
  - <file2>

Rerere memory status: ${RERERE_STATUS}

Možnosti:
1. Vyřeš konflikty ručně, pak:
   git add <files>
   git rebase --continue
2. Přerušit rebase:
   git rebase --abort
3. Nabít rerere cache (pokud víš, že řešení z minule je správné):
   # (není běžná operace, jen pro edge case)

Chceš abych konflikt vyřešil podle konkrétního výběru, nebo to
vyřešíš ručně?
```

**NIKDY** nedělej ani jednu z těchto operací bez user confirmation:

- `git checkout --theirs` / `--ours` (zahazuje cizí změny)
- `git rebase --skip` (může ztratit commit)
- destruktivní edit konfliktního souboru

### Krok 4: Push s `--force-with-lease`

Po úspěšném rebase je potřeba push na origin. Protože rebase přepsal
historii, fast-forward push selže.

**Carve-out pravidlo** (viz `ARCHITECTURE.md §19.6`): `--force-with-lease`
je legitimní **jen** po rebase proti upstreamu, jen na fork nested repo modul,
jen s user confirmation.

```bash
# Safety: fetch origin znovu, ať víme, jestli někdo mezitím nepushnul
git fetch origin
ORIGIN_MAIN="$(git rev-parse origin/main)"

# User confirmation obligatoryhonestly
echo "Chystám se přepsat origin/main ve fork nested repo modulu ${FORK}."
echo "  Před rebase:  ${ORIGIN_MAIN}"
echo "  Po rebase:    $(git rev-parse HEAD)"
echo "  Upstream base: $(git rev-parse upstream/main)"
echo ""
echo "Použiju: git push --force-with-lease=origin/main:${ORIGIN_MAIN} origin main"
echo ""
echo "Potvrdíš? [y/N]"
```

Pokud user potvrdí `y`:

```bash
git push --force-with-lease=origin/main:"${ORIGIN_MAIN}" origin main
```

Pokud ne — `git rebase --abort` a hlas, že rebase zůstal lokálně.

### Krok 5: Super-repo bez pointer commitu

Po push fork nested repo modulu se super-repo nemění. AgentMint používá nested
repo model, takže se necommitují module pointery.

- Ověř `git -C "$ROOT" status --short`, že root není dirty kvůli gitlinku.
- Ověř `company/scripts/doctor.sh check --quick`.
- Pokud se objeví `.gitmodules` nebo `160000` gitlink, je to migrační chyba,
  ne běžný rebase výsledek.

Commit message by měla obsahovat, proti kterému upstream SHA se rebaseovalo:

```
${FORK}: rebase against upstream/main (${UPSTREAM_SHA})

Synchronizace s <upstream-org>/<parent>.git upstream z YYYY-MM-DD.
${N} lokálních commitů rebased čistě, ${M} konfliktů vyřešeno ručně.
```

## Krok 6: Report uživateli

```
✓ ${FORK} rebased proti upstream/main @ ${UPSTREAM_SHA}
✓ ${N} lokálních commitů aplikováno na upstream
✓ ${M} konfliktů (${RERERE_AUTO_SOLVED} auto-resolved přes rerere,
  ${M_MANUAL} ručně)
✓ origin/main pushnuto přes --force-with-lease
✓ Super-repo zůstalo bez module pointer commitu
```

## Edge cases

### Fork má diverged history (rebase explodoval)

Může nastat, když fork držel rozsáhlou modifikaci base a nový upstream
má konfliktní rozsáhlé změny. V tom případě může být
**merge lepší než rebase** — ale to je strategická rozhodnutí, ne
rutinní skill flow.

Akce: `git rebase --abort`, hlas uživateli, diskuze o strategii
(merge commit výjimečně? Opustit jeden commit jako handoff? Sloučit
lokální branch a přijmout squash loss?).

### Upstream mirror není aktuální

Firemní `upstream` remote je mirror parent repa. Pokud je starý
(ještě nefetchnul), rebase proti němu nezískáš nejnovější upstream
changes.

Check:

```bash
# Firemní mirror porovnat s <parent>-origin
cd "$ROOT/$FORK"
git fetch "${PARENT_NAME}-origin"
git rev-list --count upstream/main..${PARENT_NAME}-origin/main
```

Pokud > 0, firemní mirror potřebuje update. **Není v scope tohoto
skillu** — eskaluj uživateli, ať někdo s access do parent upstream repa
mirror aktualizoval přes push z `<parent>-origin`.

### Nejsi na `main` v forku

Fork workflow v `ARCHITECTURE §19.3` říká: pracuje se přímo na `main`,
nebo na krátce žijících feature branchech smazaných po merge.

Pokud jsi na feature branchi a chceš ho rebaseovat:

1. Merge feature branch zpět do `main` lokálně (rebase-merge, viz §19.3)
2. Smaž feature branch
3. Teprve pak spusť tenhle skill

## Co tento skill NEDĚLÁ

- **Nefetchne ani neupdatuje `upstream` mirror z původního upstreamu**
  — to je samostatná operace (firemní mirror maintenance)
- **Nesqashne commity** — fork workflow atomic commity vyžaduje
- **Nemerguje** — vždy rebase (viz §19.3)
- **Nepushne bez user confirmation** — force-with-lease vyžaduje
  explicit potvrzení (§19.6)
- **Neřeší konflikty automaticky** mimo rerere memory — eskaluje
  uživateli

## Reference

- `ARCHITECTURE.md §19` — fork submoduly architektura
- Root `AGENTS.md §6` — Git policy + force-push carve-out ref
- root `modules.manifest.json` — `fork_upstream` pole
