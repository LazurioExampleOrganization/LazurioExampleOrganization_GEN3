---
name: commit-push-submodule
description: Historický název skillu pro scoped commit a push jednoho AgentMint nested repo modulu v `modules/<X>/`. Super-repo netrackuje module pointery, takže skill necommitujte `modules/<X>` do rootu.
---

# Skill: commit-push-submodule

Název je legacy. V AgentMint dnes znamená: **commitni a pushni jeden nested Git
repo modul**.

## Kdy použít

- Udělal jsi změny v jednom modulu `modules/<X>/`.
- Uživatel explicitně svolil commit/push.
- Modul je aktivní slot v root `modules.manifest.json` (má `repo` nebo
  `git.url`).

## Preflight

```bash
cd "$ROOT"
git status --short
git -C "$MODULE" status --short --branch
git -C "$MODULE" remote -v
```

Ověř:

- `$MODULE` je nested repo, ne git submodule pointer.
- `git -C "$MODULE" branch --show-current` vrací `main`, pokud modul nemá
  vlastní schválený workflow.
- Commit message má release-note kvalitu: co, proč, dopad/ověření.

## Standardní flow

```bash
cd "$ROOT/$MODULE"
git add -A
git commit -m "$MSG"
git push origin main
```

Pokud push selže na non-fast-forward:

```bash
git pull --rebase origin main
git push origin main
```

Při konfliktu v souborech konflikt vyřeš v modulu jako běžný Git konflikt.

## Super-repo

Po pushi modulu **necommituj pointer update v super-repu**.

Super-repo má trackovat pouze:

- root dokumenty
- `company/`, `launchpad/`, `design-system/`, `guide/`
- registry dokumenty v `modules/`
- root `modules.manifest.json` a kompatibilní
  `company/scripts/modules.manifest.json`

`modules/<X>/` má být ignorované podle `.gitignore`.

## Preferovaný příkaz

Pro běžnou práci používej doctor:

```bash
company/scripts/doctor.sh push -m "$MSG" --module "$MODULE" --dry-run
company/scripts/doctor.sh push -m "$MSG" --module "$MODULE" --yes
```

## Výstup

Reportuj:

- modul a commit SHA
- remote, kam se pushovalo
- zda zůstaly nějaké root změny
- jaké ověření proběhlo
