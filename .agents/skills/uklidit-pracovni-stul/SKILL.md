---
name: uklidit-pracovni-stul
description: Úklid pracovního stolu v Organizaci AgentMint (default Team). Použij, když uživatel řekne "ukliď pracovní stůl", "ukliď workspace", "srovnej branche", "dej mě na main", "vyřeš doctora" nebo chce dostat workspace do prediktabilního stavu.
---

# Skill: uklidit pracovní stůl

Tento skill dělá samostatný workspace cleanup v Organizaci AgentMint. Je
použitelný kdykoliv během dne a může ho volat i rutina `dobre-rano` nebo
`dobrou-noc`.

Cílem není smazat rozdělanou práci. Cílem je dostat workspace do
pojmenovaného, sdíletelného a prediktabilního stavu: primární checkout na
`main`, feature práce v evidovaných worktrees.

Skill spouštěj z **primárního checkoutu** Organizace — `doctor`, `git switch
main` a `doctor push` (main-only) kroky platí pro něj. Worktree branche jen
inventarizuj a publikuj plain `git push` + PR přes `worktree-stewardship`.

## Kdy použít

- Uživatel řekne „ukliď pracovní stůl", „ukliď workspace", „srovnej branche",
  „dej mě na main" nebo „vyřeš doctora".
- Před předáním práce nebo na konci bloku, kdy chceš prediktabilní stav.
- Když je primární checkout na feature branchi, dirty nebo jsou worktrees
  zapomenuté.

## Cíl

- zjistit stav super-repa, nested repo modulů a worktrees
- vyřešit bezpečné lokální Doctor opravy
- uklidit agentem vytvořený scratch a správně doplnit `.gitignore`
- rozlišit hotovou práci, WIP a unrelated změny
- pushnout hotovou práci nebo otevřít PR z worktree pro review-ready branche
- srovnat primární checkout na aktuální `main`
- dát člověku krátký handoff, co zůstává na stole a v worktrees

## Guardrails

- Nikdy nerevertuj, nemaž ani nestashuj cizí nebo nejasnou práci bez
  výslovného pokynu.
- Reálný commit/push/PR dělej jen pro jasně hotovou práci nebo jednoznačnou
  workspace hygienu.
- Sensitive cesty (`.claude/`, `company/colleagues/`, `infra/`) zahrň jen záměrně a
  podle root `AGENTS.md`.
- Speciální nested repo moduly s vlastním PR workflow nepřeváděj naslepo na direct push.
- `.gitignore` nepoužívej jako koš. Ignoruj jen jasně lokální nebo generované
  artefakty, ne source-of-truth data, konfiguraci, markdown handoffy nebo
  business `data/v2`.
- Dirty, nepushnutý nebo živý PR worktree nemaž — řiď se skillem
  `worktree-stewardship`.

## Postup

1. Ověř root a kontext:

   ```bash
   pwd
   git status --short --branch
   company/scripts/doctor.sh status
   ```

   Windows varianta:

   ```powershell
   git status --short --branch
   .\company\scripts\doctor.ps1 status
   ```

2. Spusť nedestruktivní Doctor repair:

   ```bash
   company/scripts/doctor.sh check --fix
   company/scripts/doctor.sh status
   ```

   Windows varianta:

   ```powershell
   .\company\scripts\doctor.ps1 check --fix
   .\company\scripts\doctor.ps1 status
   ```

   Pokud Doctor hlásí ruční fix, dirty nested repo modul, credentials, konflikt nebo
   access boundary, neobcházej ho. Použij nejbližší skill/fix markdown nebo to
   reportuj jako blocker.

3. Zmapuj pracovní stůl a worktrees:

   ```bash
   git status --short --branch
   git worktree list --porcelain
   # Modulové worktrees jsou registrované pod modulovým repem, ne pod rootem —
   # projdi je per modul:
   jq -r '.module_slots[] | select((.repo // .git.url // "") != "") | .path' modules.manifest.json |
     while read -r m; do [ -d "$m/.git" ] && sh -c 'echo "--- $1"; git -C "$1" status --short --branch; git -C "$1" worktree list --porcelain' _ "$m"; done
   ```

   Rozděl nálezy na:

   - hotové změny k pushi nebo PR
   - WIP, který má zůstat lokálně nebo ve worktree
   - unrelated změny od člověka nebo jiné práce
   - agent scratch/temp/cache/build/log
   - Doctor/pull/push konflikty

4. Uklid `.gitignore` a lokální artefakty:

   - Vlastní jednorázový scratch smaž, pokud je bezpečně tvůj a není potřeba.
   - Opakované artefakty nástroje doplň do nejbližšího správného `.gitignore`
     v owner repu.
   - Před doplněním patternu ověř, co by ignoroval:

     ```bash
     git check-ignore -v <path>
     ```

   - Neignoruj široké patterny typu `data/`, `*.md`, `*.json`, `src/`,
     `config/` nebo celé modulové složky jen proto, že jsou dirty.

5. Pushni hotovou práci:

   - jeden běžný nested repo modul: použij `commit-push-submodule`
   - root nebo kombinovaný scope: použij `doctor-workflow`
   - legacy pointer konflikt: nejdřív odstraň gitlink z root indexu
   - task/PR nested repo modul: použij jeho vlastní PR workflow

   Před širším pushem použij dry-run:

   ```bash
   company/scripts/doctor.sh push -m $'Area: Meaningful summary

   What changed and why.

   Validation and impact.' --include <path> --dry-run
   ```

6. Zpracuj worktree branche, které dávají smysl sdílet:

   - Zkontroluj branche v primárním checkoutu i v každém worktree (`git
     worktree list`) a nested repo modulech, které Doctor hlásí jako skipped
     nebo jsou na non-main branchi.
   - Pokud branch obsahuje review-ready práci, ověř remote policy. AgentMint je
     GitHub-backed; push/PR vytvářej jen pro jasně hotovou práci podle owner
     pravidel daného repa a otevírej ho z worktree (skill
     `worktree-stewardship`).
   - PR nevytvářej pro neověřený WIP, směs nesouvisejících změn nebo práci bez
     jasného ownera.

7. Srovnej primární checkout na prediktabilní základ:

   Primární checkout Organizace i modulů má stát na `main` — feature branch
   žije jen ve worktree. Pokud je primární checkout omylem na feature branchi,
   přesuň práci do worktree nebo ji dokonči a teprve pak se vrať na `main`.

   ```bash
   git switch main   # jen když primární checkout omylem není na main
   company/scripts/doctor.sh sync
   company/scripts/doctor.sh status
   git status --short --branch
   ```

   Pokud `git switch main` nejde kvůli dirty práci, nic nepřepisuj. Pojmenuj,
   co přesně návratu na `main` brání.

## Ověření

Zkontroluj, že finální stav je prediktabilní:

```bash
git status --short --branch
git worktree list --porcelain
```

Primární checkout je na `main` a syncnutý, hotová práce je pushnutá nebo má PR
z worktree, worktrees jsou evidované a rozdělaná práce je pojmenovaná.

## Výstup uživateli

Drž výstup provozní:

```text
Pracovní stůl je uklizený.
Push/PR: ...
Doctor: ...
.gitignore / artefakty: ...
Worktrees: ...
Finální stav: main @ ...
Na stole zůstává: ...
```
