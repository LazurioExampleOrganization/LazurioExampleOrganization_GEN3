---
name: create-new-module
description: Použij, když má AgentMint přidat nový modul do `modules/` jako nested Git repo spravované doctorem a manifestem. Nepoužívej Git submoduly ani `.gitmodules`.
---

# Skill: create-new-module

AgentMint používá nested repo pattern: `modules/<slug>/` je
samostatné Git repo uvnitř super-repa, ale super-repo netrackuje jeho obsah ani
commit pointer.

## Kdy použít

- Uživatel explicitně řekne „vytvoř modul", „založ repo v modules" nebo
  ekvivalent.
- Planned slot má přejít do skutečného nested repozitáře.
- Je jasná source-of-truth role modulu a GitHub repo v organizaci `LazurioExampleOrganization`.

## Preflight

1. Ověř root:

   ```bash
   pwd
   test -f AGENTS.md
   test -f modules.manifest.json
   ```

2. Přečti:

   - `AGENTS.md`
   - `ARCHITECTURE.md §2`, `§3`, `§12`
   - root `modules.manifest.json` (jediný inventář modulů)
   - nejbližší role/person overlay

3. Ověř slug:

   - lowercase kebab-case
   - cesta `modules/<slug>`
   - žádný konflikt s existujícím souborem/složkou
   - buď existuje jako planned slot, nebo je jasné, proč se přidává

## Standardní postup

1. Založ private GitHub repo `LazurioExampleOrganization/<slug>`.
2. Naklonuj ho do `modules/<slug>/` jako samostatné repo:

   ```bash
   git clone --branch main --single-branch git@github.com:LazurioExampleOrganization/<slug>.git modules/<slug>
   ```

3. V modulu vytvoř minimální skeleton:

   - `README.md`
   - `AGENTS.md`
   - podle potřeby `ARCHITECTURE.md`, `TODO.tasks.json`, `CHANGELOG.md`

4. Commitni a pushni změny v nested repo modulu.
5. Aktualizuj root `modules.manifest.json` v root task worktree: slotu doplň
   `repo` (nebo `git.url` + `git.branch = "main"`). Změnu commitni a projekci
   `company.gen3.json` přegeneruj přes
   `lazurio migrate organization-manifest <task-worktree> --write`; ručně ji
   needituj. Do `company/scripts/modules.manifest.json` smíš stejné `path`,
   `git.url` a `git.branch` jen zopakovat pro legacy `update-workspace`
   (hranice polí: `company/scripts/README.md`); slot tam nikdy nezakládej.
6. Ověř, že super-repo netrackuje module content:

   ```bash
   git status --short --ignored modules
   git ls-files -s modules | awk '$1 == "160000" { print }'
   ```

7. Spusť:

   ```bash
   company/scripts/doctor.sh workspace-tasks
   company/scripts/doctor.sh check --quick
   ```

## Zakázané

- Nepoužívej `git submodule add`.
- Nevytvářej ani needituj `.gitmodules`.
- Necommituj `160000` gitlink pointery do super-repa.
- Nekopíruj cizí data, secrets ani placený obsah do nového modulu.

## Výstup

Na konci řekni:

- jaký modul vznikl
- jaké GitHub repo drží jeho source of truth
- co bylo zapsáno do manifestu
- jaké ověření proběhlo
