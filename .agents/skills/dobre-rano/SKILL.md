---
name: dobre-rano
description: Ranní rutina Organizace AgentMint (default Team). Použij, když uživatel řekne "dobré ráno", "začni den", "připrav workspace" nebo chce bezpečně stáhnout/pullnout aktuální změny a srovnat primární checkout na `main`, i při lokální rozdělané práci.
---

# Skill: dobré ráno

Ranní rutina připraví Organizaci AgentMint na práci. Workspace je sdílený
office pro lidi i agenty; osobní paměť, osobní asistent nebo gbrain řeš jen
tehdy, když to uživatel výslovně zmíní.

Rutinu spouštěj z **primárního checkoutu** Organizace (ten drží `main`);
`doctor sync`, `git switch main` a další kroky níže platí pro primární
checkout. Feature práci ve worktrees jen inventarizuj a řeš přes skill
`worktree-stewardship`.

Pro detailní úklid pracovního stolu použij samostatný skill
`uklidit-pracovni-stul`.

## Kdy použít

- Uživatel řekne „dobré ráno", „začni den", „připrav workspace".
- Chce bezpečně stáhnout aktuální změny a začít den s primárním checkoutem na
  aktuálním `main`, i když má lokální rozdělanou práci.

## Cíl

- zkontrolovat stav workspace, nested repo modulů a worktrees
- stáhnout aktuální změny bezpečným doctor flow
- při rozdělaných změnách na `main` pullnout latest tak, aby lokální WIP zůstal
- vyřešit agent-safe Doctor opravy a běžný workspace nepořádek
- srovnat primární checkout na aktuální `main`
- pojmenovat rozdělanou práci, worktrees, skipy a co jim brání
- dát kolegovi krátký ranní briefing

## Postup

1. Ověř, že jsi v rootu Organizace AgentMint.
2. Přečti relevantní `AGENTS.md` kaskádu, pokud ji ještě nemáš v kontextu.
3. Spusť ranní status:

   ```bash
   company/scripts/doctor.sh status
   ```

   Windows varianta:

   ```powershell
   .\company\scripts\doctor.ps1 status
   ```

4. Spusť sync:

   ```bash
   company/scripts/doctor.sh sync
   ```

   Windows varianta:

   ```powershell
   .\company\scripts\doctor.ps1 sync
   ```

   Doctor může přeskočit dirty super-repo nebo dirty nested repo modul. To není chyba.
   Znamená to, že je potřeba vědomě rozhodnout, co s rozdělanou prací.

   Pokud Doctor přeskočí repo jen proto, že je na `main` rozdělaná lokální
   práce, ranní rutina tím nekončí. V super-repu i v každém fyzicky přítomném
   nested repu, které má `origin/main`, proveď řízený dirty-main pull:

   - Nejdřív zapiš stav: `git status --short --branch`, `git diff --stat` a
     podle potřeby relevantní diff.
   - Vytvoř lokální safety snapshot bez pushování:

     ```bash
     git stash push --include-untracked -m "morning-sync-wip-YYYYMMDD-HHMM"
     git pull --ff-only origin main
     git stash apply --index stash@{0}
     ```

   - Pokud `stash apply` vyvolá konflikty, vyřeš je ručně. V konfliktních
     hunks zachovej intent rozdělané lokální změny; upstream změny zapracuj jen
     tam, kde nepoškodí WIP. Nepoužívej `reset --hard`, nemaž soubory naslepo a
     neshazuj stash, dokud není ověřené, že lokální změny zůstaly.
   - Po čistém apply nebo po ručním vyřešení ověř `git status --short --branch`
     a až potom smaž použitý stash přes `git stash drop stash@{0}`. Pokud stash
     nejde bezpečně zahodit, nech ho a napiš přesný stash záznam do briefingu.
   - Když konflikt nejde vyřešit bez znalosti intentu, secrets, accessu nebo
     rizika ztráty dat, zastav se u konkrétního souboru a pojmenuj další krok.

5. Pokud Doctor hlásí lokální agent-safe opravy, spusť nedestruktivní repair a
   znovu ověř stav:

   ```bash
   company/scripts/doctor.sh check --fix
   company/scripts/doctor.sh status
   ```

   Windows varianta:

   ```powershell
   .\company\scripts\doctor.ps1 check --fix
   .\company\scripts\doctor.ps1 status
   ```

   Pokud Doctor řekne, že oprava vyžaduje rozhodnutí člověka, dirty nested repo modul,
   credentials, konflikt nebo ruční fix markdown, neobcházej ho. Pojmenuj, co
   tomu brání, a doporučený další krok.

6. Pokud máš pokračovat v práci, ověř kontext:

   ```bash
   company/scripts/doctor.sh check-my-context
   ```

7. Znovu projdi stav a worktrees:

   ```bash
   company/scripts/doctor.sh status
   git status --short --branch
   git worktree list --porcelain
   ```

8. Dostaň workspace na prediktabilní ranní základ:

   - Primární checkout Organizace i modulů má stát na `main`; feature práce
     žije ve worktree (skill `worktree-stewardship`). Pokud je primární
     checkout omylem na feature branchi, srovnej ho na `main`:

     ```bash
     git switch main   # jen když primární checkout omylem není na main
     ```

   - Potom stáhni latest bezpečným doctor flow:

     ```bash
     company/scripts/doctor.sh sync
     ```

   - Pokud návrat na `main` blokuje dirty práce, nic nerevertuj. Rozděl ji
     na: hotové k pushi/PR, rozdělané k handoffu, nebo lokální bordel k
     úklidu. Hotové věci sdílej podle večerního PR/push flow, zbytek jasně
     reportuj.

9. Zkontroluj worktrees a lokální větve, které mohou být zapomenutá hotová
   práce. Dělej to v primárním checkoutu i v každém worktree a fyzicky
   přítomném nested repo modulu, který je na non-main branchi, má lokální
   commity nebo ho Doctor hlásí jako skipped:

   ```bash
   git worktree list --porcelain
   git branch --sort=-committerdate --format='%(refname:short) %(committerdate:relative)'
   ```

   Pokud najdeš branch s hotovou sdílitelnou prací, nejdřív ověř remote
   policy. AgentMint je GitHub-backed workspace, ale PR/push dělej jen pro
   jasně hotovou práci, podle owner pravidel daného repa a z worktree (skill
   `worktree-stewardship`). WIP branch/worktree bez jasného dokončení jen
   pojmenuj v briefingu.

10. Připrav ranní briefing:

    - co se podařilo synchronizovat
    - co Doctor přeskočil a proč
    - jestli primární checkout běží na aktuálním `main`, nebo proč ne
    - jaké worktree branche mají PR / čekají na rozhodnutí
    - kde je rozdělaná práce
    - jestli existují pull/push konflikty nebo co jim brání
    - doporučený první krok dne

## Pracovní stůl

`Vyčistit pracovní stůl` neznamená smazat, revertovat nebo stashnout změny.
Znamená to dostat workspace do pojmenovaného stavu:

- hotové věci jsou pushnuté
- hotové feature branche mají PR z worktree, pokud repo policy nebo smysl
  změny nechce direct push na `main`
- rozdělané věci a worktrees jsou jasně pojmenované
- temp soubory vytvořené agentem v aktuální práci jsou uklizené nebo správně
  ignorované
- long-running procesy, které už nejsou potřeba, neběží
- člověk ví, kde má navázat

Když se opakovaně objevují untracked build/cache/log soubory, které nemají být
commitem, uprav nejbližší správný `.gitignore` v owner repu. Ignoruj jen jasně
lokální nebo generované artefakty; nikdy nepřidávej široké patterny, které by
mohly schovat source, data, konfiguraci nebo handoff dokumenty.

Nikdy nerevertuj ani nemaž rozdělanou práci bez výslovného pokynu.

## Ověření

Ranní stav je prediktabilní:

```bash
git status --short --branch
git worktree list --porcelain
```

Primární checkout je na `main`, syncnutý na latest dostupný commit; rozdělaná
práce, worktrees a Doctor skipy jsou pojmenované v briefingu.

## Výstup uživateli

Drž výstup krátký:

```text
Dobré ráno. Workspace je synchronizovaný kromě ...
Finální stav: main @ ...
PR / worktrees: ...
Rozdělané věci: ...
Co tomu brání: ...
Doporučený první krok: ...
```
