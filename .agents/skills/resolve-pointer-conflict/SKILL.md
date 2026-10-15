---
name: resolve-pointer-conflict
description: Legacy diagnostic for old GEN2 submodule pointer conflicts. In AgentMint this should only be used to identify and remove accidental .gitmodules or 160000 gitlink state, because modules are nested Git repositories managed by doctor and the manifest.
---

# Skill: resolve-pointer-conflict

AgentMint nepoužívá Git submoduly. `modules/*` jsou nested Git repozitáře
ignorované super-repem a popsané v root
`modules.manifest.json`.

Tento skill je v AgentMintu jen legacy pojistka pro situaci, kdy se do root
indexu omylem dostane `.gitmodules` nebo `160000` gitlink pointer.

## Co ověřit

```bash
git status --short
git ls-files -s modules | awk '$1 == "160000" { print }'
test ! -f .gitmodules
company/scripts/doctor.sh check --quick
```

## Co platí

- Neřeš pointer konflikty rebasem jako běžný workflow.
- Nevytvářej pointer update commit v super-repu.
- Nepoužívej `git submodule update`.
- Pokud root trackuje gitlink, odstraň ho z indexu přes `git rm --cached`
  pro danou cestu a nech fyzický nested repo adresář na disku.
- Pak ověř, že `.gitignore` obsahuje `/modules/*/` a že manifest má pro modul
  správné `git.url` a `git.branch`.

Po opravě musí platit: `doctor.sh check --quick` hlásí, že `.gitmodules`
neexistuje a super-repo netrackuje module gitlink pointery.
