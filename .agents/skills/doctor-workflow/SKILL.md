---
name: doctor-workflow
description: Bezpečná práce s doctor toolingem AgentMint (`company/scripts/doctor.sh`) pro status, sync, health checks, scoped push, dependency checks a workspace maintenance. Použij, když uživatel zmíní doctor, `doctor push`, `doctor sync`, workspace sync/push, nested repo moduly, dirty workspace, nebo chce commit/push přes kanonický doctor flow.
---

# Skill: doctor-workflow

Kanonický workflow pro práci s workspace doctorem AgentMint.

Doctor je hlavní entrypoint pro každodenní maintenance workspace:

```bash
company/scripts/doctor.sh <command>
```

Nepředpokládej, že alias `doctor` existuje v shellu. V agentích během používej
explicitní cestu `company/scripts/doctor.sh`.

## Kdy použít

- Uživatel zmíní `doctor`, `doctor push`, `doctor sync`, `doctor check`.
- Potřebuješ zjistit stav workspace nebo nested repo modulů.
- Potřebuješ bezpečně pushnout root/super-repo změny přes doctor.
- Řešíš dirty nested repo moduly, pullable modules nebo sync.
- Potřebuješ vysvětlit, proč doctor něco skipnul.

## Postup

### Základní pravidlo

Doctor má chránit před překvapivými změnami. Neobcházej ho ručními Git
příkazy napříč workspace, pokud root `AGENTS.md` říká, že daný flow patří
přes doctor nebo jiný skill.

`doctor push` publikuje na `origin main` (je to **main-only** flow) — používej
ho pro drobnosti a scoped modulové změny **přímo na `main`** z primárního
checkoutu, který je na `main`. Feature branch ve worktree přes `doctor push`
NEpublikuj: pushnul by `main`, ne tvou branch. Worktree branch publikuj plain
`git push -u origin <branch>` z worktree a otevři PR (viz `worktree-stewardship`).

Před reálným commitem/pushem musí uživatel dát explicitní svolení
(`pushni`, `zacommituj`, `do toho`, apod.). Pro kontrolní příkazy a
`--dry-run` svolení nepotřebuješ.

### Push flow

Nepoužívej starý pattern `doctor push "message"` jako batch všech změn bez
přemýšlení. Použij explicitní scope:

```bash
company/scripts/doctor.sh push -m $'Area: Meaningful change summary

Explain what changed, why it changed, and what operational impact or validation matters for release notes.'   --module modules/experiments   --include guide   --dry-run
```

#### Commit message kvalita

Commit messages se používají pro release notes a týmový přehled. Agent
nesmí poslat vágní zprávu jen proto, že Git ji přijme.

Použij tvar:

```text
Area: Specific change in human language

What changed and where.

Why it changed, plus impact, migration note, validation, or follow-up.
```

Špatně: `fix`, `update`, `cleanup`, `changes`, `WIP`.

Když změna zasahuje více modulů, nejdřív si polož otázku: „Je to jeden
release-note item?" Pokud ne, pusť více samostatných `doctor push` kroků s
vlastními zprávami.

#### Volba scope

- `--module <path>`: nested repo modul, který se má commitnout a pushnout.
- `--include <path>`: root/super-repo cesta, kterou chceš přibrat.
- `--include-sensitive <path>`: citlivější root cesta jako `.claude`,
  `company`, `company/colleagues`, `infra`.
- `--dry-run`: preview bez commitu a pushe.
- `--yes`: potvrzení pro non-interactive shell po kontrole preview.

## Guardrails

- Necommituj bez explicitního svolení uživatele.
- Nepoužívej root `git add -A` jako náhradu za doctor push.
- Nepřidávej `modules/<modul>` do root commitu jako pointer. AgentMint
  super-repo netrackuje module gitlinky.
- `infra`, `.claude`, `company/colleagues` a broad `company` jsou sensitive
  scope. Přiber je jen přes `--include-sensitive` a jen záměrně.
- Pokud doctor skončí s warningem kvůli unrelated dirty změnám, neznamená
  to automaticky selhání pushnutého scope. Ověř `git log` a `git status`.
- Pokud se objeví `.gitmodules` nebo `160000` gitlink v root indexu, zastav se
  a oprav migraci na nested repo model.

## Ověření

Po pushi vždy ověř:

```bash
git status --short --branch
git log --oneline --decorate -3
git show --name-status --oneline HEAD
```

Uživatelům reportuj commit SHA, co bylo součástí commitu, co zůstalo dirty a
jestli doctor skončil s warningem nebo čistě.
