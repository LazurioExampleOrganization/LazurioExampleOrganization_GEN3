---
name: dobrou-noc
description: Večerní rutina Organizace AgentMint (default Team). Použij, když uživatel řekne "dobrou noc", "ukonči den", "pushni hotové změny" nebo chce poslat bezpečně commitovatelné změny na GitHub jako drobnosti přímo na `main` nebo PR z worktree pro review.
---

# Skill: dobrou noc

Večerní rutina zavírá pracovní den v Organizaci AgentMint. Cílem není
bezhlavě commitnout vše, ale bezpečně pushnout hotovou práci, otevřít PR
z worktree tam, kde dává smysl review, a zanechat pracovní stůl v pojmenovaném
stavu s primárním checkoutem na `main`.

Rutinu spouštěj z **primárního checkoutu** Organizace AgentMint — ten má být
na `main`. Feature práci ve worktrees jen inventarizuj (`git worktree list`)
a publikuj přes skill `worktree-stewardship`; `doctor`, `git switch` a
`doctor push` kroky níže platí pro primární checkout (`doctor push` je
main-only).

Pro detailní úklid pracovního stolu použij samostatný skill
`uklidit-pracovni-stul`.

## Kdy použít

- Uživatel řekne „dobrou noc", „ukonči den", „pushni hotové změny".
- Chce na konci dne poslat bezpečně commitovatelné změny na GitHub a vrátit
  workspace do prediktabilního stavu.

## Cíl

- projít rozdělanou práci
- ověřit hotové změny přiměřenou kontrolou
- poslat všechny bezpečně commitovatelné změny na GitHub přes kanonický
  doctor flow
- drobnosti pushnout přímo na `main`, pokud jsou malé, jasné a nízkorizikové
- otevřít PR z worktree pro větší, smíšené, behavior-changing nebo nejasné
  změny, které mají projít review
- opravit lokální Doctor problémy a `.gitignore` drift, pokud je fix bezpečný
- srovnat primární checkout zpět na aktuální `main`
- jasně vypsat, co zůstává rozdělané a v jakém worktree
- uklidit dočasné soubory a procesy vytvořené agentem

## Postup

1. Ověř, že jsi v primárním checkoutu Organizace AgentMint (na `main`).
2. Zjisti stav:

   ```bash
   company/scripts/doctor.sh status
   git status --short --branch
   git worktree list --porcelain
   ```

   Windows varianta:

   ```powershell
   .\company\scripts\doctor.ps1 status
   git status --short --branch
   ```

3. Projdi změny podle scope:

   - změny, které patří k aktuální práci
   - unrelated změny od člověka nebo jiné práce
   - sensitive root změny (`.claude/`, `company/colleagues/`, `infra/`)
   - změny uvnitř nested repo modulů
   - legacy root pointery, které v AgentMintu nemají vznikat
   - untracked temp/build/cache/log soubory, které mají být smazané nebo
     zapsané do nejbližšího správného `.gitignore`
   - worktree branche s review-ready prací bez PR

4. Ověř hotovou práci přiměřeně riziku:

   - docs: `git diff --check`
   - guide: `cd guide/app && npm run build`
   - běžná app/code změna: repo-specific test/build/check
   - speciální nested repo modul: použij jeho vlastní pravidla a nejbližší `AGENTS.md`

5. Vyřeš lokální Doctor hygienu:

   ```bash
   company/scripts/doctor.sh check --fix
   company/scripts/doctor.sh status
   ```

   Windows varianta:

   ```powershell
   .\company\scripts\doctor.ps1 check --fix
   .\company\scripts\doctor.ps1 status
   ```

   `check --fix` používej jen pro nedestruktivní lokální opravy. Pokud Doctor
   hlásí dirty nested repo modul, konflikt, access problém nebo ruční fix,
   postupuj podle příslušného skillu/fix markdownu nebo pojmenuj, co tomu brání.

6. Uklid `.gitignore`, když je to správný fix:

   - Pokud se objevily agentem vytvořené temp/cache/build/log soubory, které se
     nemají commitovat, smaž vlastní jednorázový scratch.
   - Pokud jde o opakovaný artefakt nástroje, doplň nejbližší `.gitignore` v
     owner repu a zahrň tu změnu do stejného hygiene commitu.
   - Nikdy neignoruj široce `data/`, `*.md`, config soubory, source soubory ani
     handoff dokumenty jen proto, že jsou nepohodlně untracked.

7. Commit a push dělej přes existující skills a Doctor:

   - Cíl večera je poslat na GitHub všechny změny, které jsou bezpečně
     commitovatelné. Lokálně dirty smí zůstat jen explicitní výjimka: secret,
     lokální runtime stav, konflikt, chybějící access, neznámý cizí binární
     soubor nebo změna, u které by commit/push mohl poškodit data.
   - Drobnost pushni přímo na `main`, pokud je malá, souvislá, nízkoriziková a
     jasně hotová: typo, drobná docs korekce, katalogový update, bezpečná
     `.gitignore` hygiena nebo malý admin fix bez změny chování systému. Jeden
     běžný nested repo modul řeš přes `commit-push-submodule`; root nebo
     kombinovaný scope přes `doctor-workflow`.
   - Větší balík nedávej přímo na `main`: více souborů/scope, změna chování,
     agentní pravidla, Doctor/Git/worktree flow, Launchpad/runtime změna,
     citlivá cesta, nejistý intent, rozdělená práce od více lidí nebo cokoli,
     co má projít review. Připrav worktree (skill `worktree-stewardship`),
     commitni a publikuj branch plain `git push -u origin <branch>` z worktree
     (ne `doctor push`, ten je main-only) a otevři plnohodnotný PR; pokud je
     intent nejistý, otevři normální PR a nejistotu popiš v jeho popisu (ne
     GitHub „draft PR").
   - PR napiš jako samostatný handoff: název problému, dotčené cesty, proč to
     nejde rovnou na `main`, co je ověřené a co má reviewer rozhodnout nebo
     dopracovat.
   - root sensitive cesty zahrň jen záměrně přes `--include-sensitive`
   - pointer-only super-repo commit nedělej; je to chyba proti nested repo modelu

8. Před reálným pushem použij dry-run, pokud je scope širší nebo obsahuje root:

   ```bash
   company/scripts/doctor.sh push -m $'Area: Meaningful summary

   What changed and why.

   Validation and impact.' --include guide --dry-run
   ```

9. Worktree a branch cleanup:

   - Projdi worktrees a branche v primárním checkoutu i v nested repo modulech:

     ```bash
     git worktree list --porcelain
     git branch --show-current
     git branch --sort=-committerdate --format='%(refname:short) %(committerdate:relative)'
     ```

   - Pro každou branch s review-ready prací ověř remote policy. AgentMint je
     GitHub-backed; push/PR vytvářej jen pro jasně hotovou práci podle owner
     pravidel daného repa a otevírej ho z worktree (`worktree-stewardship`).
   - Dokončené worktrees ukliď podle `worktree-stewardship` (nikdy dirty,
     nepushnutý ani živý PR worktree).

   PR nevytvářej pro neověřený WIP, směs nesouvisejících změn nebo práci, kde
   není jasný owner. Takovou branch/worktree pojmenuj ve večerním handoffu.

10. Srovnej primární checkout na `main`:

    Primární checkout má na konci dne stát na `main` (feature branch žije jen
    ve worktree):

    ```bash
    git switch main   # jen když primární checkout omylem není na main
    company/scripts/doctor.sh sync
    ```

11. Ukliď jen věci, které jsi sám vytvořil nebo spustil:

    - dočasné soubory v `/tmp`
    - vlastní build/scratch artefakty
    - dev servery nebo dlouhé procesy spuštěné pro aktuální úkol

## Consent pravidlo

Když uživatel řekne jen `dobrou noc`, ber to jako záměr spustit večerní
rutinu včetně bezpečného push/PR cleanupu a návratu na `main`. Reálný
commit/push/PR proveď pro všechny změny, které jsou bezpečně commitovatelné:

- hotové a ověřené drobnosti pushni kanonickým doctor flow přímo na `main`
- větší nebo review-sensitive změny připrav ve worktree a otevři plnohodnotný PR
- nejasné, ale ověřitelné změny dej do worktree a otevři normální PR
  s popsanou nejistotou (ne GitHub „draft PR")
- nesouvisející změny rozděl podle owner repa nebo scope, nemíchej je do
  jednoho commitu
- secrets, OAuth/session data, lokální runtime stav a neznámé cizí binární
  artefakty nepushuj; vlastní temp/cache/build artefakty smaž

Nezastavuj se jen proto, že chybí poznámky předchozího agenta. Když intent
není jistý, napiš to do commit/PR popisu a otevři normální PR. Zastav se až u
věci, kde by další akce mohla ztratit data, zveřejnit secret, rozbít konflikt
nebo vyžaduje chybějící access.

## Ověření

Po pushi/PR ověř, že finální stav je prediktabilní:

```bash
git status --short --branch
git log --oneline --decorate -3
git worktree list --porcelain
```

Jsi na `main`, `main` je syncnutý na latest dostupný commit a všechny hotové
změny jsou pushnuté nebo mají PR z worktree. Pokud to nejde, napiš přesně,
která dirty práce, branch, konflikt nebo access boundary tomu brání.

## Výstup uživateli

Drž výstup provozní:

```text
Dobrou noc. Pushnul jsem ...
PR: ...
Zkontrolováno: ...
Worktrees: ...
Finální stav: main @ ...
Na stole zůstává: ...
Zítra navázat: ...
```
