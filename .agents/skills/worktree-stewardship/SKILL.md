---
name: worktree-stewardship
description: "Vytváří, eviduje, předává a bezpečně uklízí dočasné Git worktrees v Organizaci AgentMint podle Lazurio decision 0049. Použij pro každou branch, PR, review či rebase práci, paralelní agenty nebo cleanup: drž primární checkout na `main`, zakládej worktree pod `.worktrees/`, používej sidecar `companiesascode.worktree.v1` a nemaž dirty, nepushnutou ani živou PR práci."
---

# Worktree stewardship AgentMint

Worktree je dočasný pracovní preview pro Draft před PR, ne staging ani
dlouhodobý source of truth. Každý worktree má vlastnický plán (Mission Control
nebo task ledger) a právě jednoho aktivního writer ownera.

## Kdy použít

- Zakládáš branch, PR, review nebo rebase práci.
- Běží víc agentů/writerů paralelně nad stejným repem.
- Doctor hlásí worktree warning nebo je potřeba cleanup po merge.
- Chceš připravit věcnou změnu root Organizace nebo nested repo modulu, aniž
  bys sáhl na `main` primárního checkoutu.

AgentMint je single-team Organizace. Vlastnická repa jsou dvě rodiny: root
Organizace (`AgentMint`) a doctor-managed nested repo moduly
(`modules/<modul>/`). Productionspace je zatím prázdný.

## Postup

### Invariant primárního checkoutu

Primární Organization checkout je adresář, kde je tahle Organizace naklonovaná
— v Launchpad rootu mount `organizations/LazurioExampleOrganization_GEN3`. Je to adresář, který drží
kanonický manifest `lazurio.organization.json`. Generovaná projekce
`company.gen3.json` ho označuje jen jako fallback pro root ve stavu `legacy`
nebo `transition`; root ve stavu `current` ji už nemá:

```text
<launchpad-root>/organizations/LazurioExampleOrganization_GEN3
```

Drž ho na `main` a ve stavu odpovídajícím `origin/main`. Stejný invariant
platí pro primární checkout každého nested repo modulu. Nezakládej feature
branch přes `git switch -c` v primárním checkoutu.

Před založením i před handoffem ověř:

```bash
git -C <organization-primary> status --short --branch
git -C <organization-primary> branch --show-current
```

Pokud je primární checkout dirty, ahead nebo na jiné branchi, nic nezahazuj a
nepoužívej ho jako base. Nejdřív zachovej cizí práci na branchi/remote nebo
v jiném worktree a teprve potom obnov `main`.

### Urči vlastnické repo a kanonickou cestu

Použij právě jeden Git worktree pro každé repo dotčené plánem. Cesty jsou pod
rootem Organizace AgentMint; sidecar leží vedle checkoutu:

Cesta vlastnického repa je jeho `module_slots[].path` z `modules.manifest.json`
— většina modulů leží pod `modules/<modul>`, ale root-level nested repo `infra`
leží přímo v `infra`. Worktree i sidecar zrcadlí tuhle cestu:

| Scope změny | Vlastnické repo (`path`) | Worktree |
|---|---|---|
| Organization root | `.` (root Organizace `AgentMint`) | `.worktrees/root/<PLAN-kód>-<slug>/` |
| Root-level nested repo | `infra` | `.worktrees/infra/<PLAN-kód>-<slug>/` |
| Nested repo modul | `modules/<modul>` | `.worktrees/modules/<modul>/<PLAN-kód>-<slug>/` |

```text
.worktrees/root/<PLAN-kód>-<slug>.worktree.json
.worktrees/<module-path>/<PLAN-kód>-<slug>.worktree.json
```

Nested repo změnu vytvoř jako worktree skutečného vlastnického repa (dle jeho
`path`), ne jako root worktree s později naklonovaným modulem uvnitř.
Cross-module plán má jeden worktree pro každé repo, vždy se stejným kódem
plánu. Nevytvářej worktrees v `/tmp`, `.claude/worktrees` ani mimo Organization
root.

### Branch a vytvoření

Branch nese kód vlastnického plánu; base je `origin/main`. Doporuč
`codex/<PLAN-kód>-<slug>` (tool prefix je povolený, není součást kanonické
worktree cesty).

Oba snippety níž jsou fail-closed. `ORG` je primární checkout Organizace
AgentMint: hledá se nejdřív podle kanonického `lazurio.organization.json`,
`company.gen3.json` je jen fallback pro `legacy`/`transition` root. Funguje
z podadresáře i z modulu; z worktree se normalizuje zpět na primární root nad
`.worktrees/`. Když marker chybí, snippet končí na řádku `: "${ORG:?…}"`:
neinteraktivní shell (tak je spouští Agent) skončí s chybou a nenulovým exit
kódem, interaktivní shell jen přeruší příkaz a terminál nechá žít — `exit` by
ho zavřel a `return` mimo funkci v bashi nic nezastaví. Stejnou pojistku
`${ORG:?}`, `${REPO:?}` a `${WT:?}` má každý další příkaz, takže prázdná
hodnota se nikdy nedostane do `git -C ""`, ani když vložíš jen druhou půlku
snippetu. Komentáře uvnitř snippetů záměrně neobsahují backticky ani jiné
shellové metaznaky: interaktivní zsh komentáře ve výchozím nastavení
nepřeskakuje a vložený text by vykonal.

Organization root:

```bash
# ORG je primární checkout Organizace, viz odstavec výše
ORG=""; WT=""; REPO=""
for MARKER in lazurio.organization.json company.gen3.json; do
  DIR="$PWD"; while [ "$DIR" != / ] && [ ! -f "$DIR/$MARKER" ]; do DIR="$(dirname "$DIR")"; done
  if [ "$DIR" != / ]; then ORG="$DIR"; break; fi
done
# Fail-closed - bez rootu snippet tady končí a žádný git se nespustí
: "${ORG:?Root Organizace nenalezen: chybí lazurio.organization.json i legacy company.gen3.json}"
case "$ORG" in *"/.worktrees/"*) ORG="${ORG%%/.worktrees/*}";; esac
PLAN="RM-0010"
SLUG="worktree-stewardship"
BRANCH="codex/$PLAN-$SLUG"
WT="${ORG:?}/.worktrees/root/$PLAN-$SLUG"

git -C "${ORG:?}" fetch origin main
git -C "${ORG:?}" worktree add -b "$BRANCH" "${WT:?}" origin/main
git -C "${WT:?}" status --short --branch
git -C "${ORG:?}" status --short --branch
```

Nested repo modul (`ORG` je root Organizace, ne modul — proto ho hledej podle
`lazurio.organization.json` s legacy fallbackem `company.gen3.json`, ne přes
`git rev-parse` z modulu):

```bash
ORG=""; WT=""; REPO=""
for MARKER in lazurio.organization.json company.gen3.json; do
  DIR="$PWD"; while [ "$DIR" != / ] && [ ! -f "$DIR/$MARKER" ]; do DIR="$(dirname "$DIR")"; done
  if [ "$DIR" != / ]; then ORG="$DIR"; break; fi
done
# Fail-closed - bez rootu snippet tady končí a žádný git se nespustí
: "${ORG:?Root Organizace nenalezen: chybí lazurio.organization.json i legacy company.gen3.json}"
case "$ORG" in *"/.worktrees/"*) ORG="${ORG%%/.worktrees/*}";; esac
# MODULE_PATH je path slotu z root modules.manifest.json - root-level nested repo je infra
MODULE_PATH="modules/experiments"
NAME="$(basename "$MODULE_PATH")"
PLAN="RM-0021"
SLUG="growth-loop"
REPO="${ORG:?}/$MODULE_PATH"
BRANCH="codex/$PLAN-$NAME-$SLUG"
WT="${ORG:?}/.worktrees/$MODULE_PATH/$PLAN-$SLUG"

git -C "${REPO:?}" fetch origin main
git -C "${REPO:?}" worktree add -b "$BRANCH" "${WT:?}" origin/main
git -C "${WT:?}" status --short --branch
git -C "${REPO:?}" status --short --branch
```

Nevytvářej worktree bez dohledatelného plánu; planless checkout je
`orphan_missing_plan` / invalid.

### Sidecar metadata

Použij schema `companiesascode.worktree.v1`. Povinné klíče:
`schema_version`, `organization`, `organization_path`, `module`,
`module_path`, `repo_kind`, `base_branch`, `branch`, `plan_code`,
`plan_path`, `worktree_path`, `created_at`, `created_by`, `status`.

```json
{
  "schema_version": "companiesascode.worktree.v1",
  "organization": "AgentMint",
  "organization_path": "organizations/LazurioExampleOrganization_GEN3",
  "module": "<repo-name>",
  "module_path": "<module_slots[].path, např. modules/experiments nebo infra>",
  "repo_kind": "module",
  "base_branch": "main",
  "branch": "codex/<PLAN-kód>-<repo-name>-<slug>",
  "plan_code": "<PLAN-kód>",
  "plan_path": "<organization-relative-plan-path>",
  "worktree_path": ".worktrees/<module_path>/<PLAN-kód>-<slug>",
  "created_at": "<ISO-8601>",
  "created_by": "<active-writer>",
  "status": "active",
  "pr_url": null,
  "notes": "<purpose-and-cleanup-context>"
}
```

Pro Organization root použij `repo_kind: "organization_root"`,
`module: "AgentMint"`, `module_path: "."` a root worktree path. Používej
jen statusy `active`, `pr_open`, `merged_cleanup_needed`, `stale`,
`orphan_missing_plan`, `invalid`.

### Práce, publikace a PR

- Udržuj jednoho aktivního writer ownera; při předávce commitni a pushni
  branch a aktualizuj ownera v plánu.
- Commituj logické celky, nenechávej důležitou práci jen dirty v worktree.
- Commit + push pracovní branche NENÍ Publikace — v kódové dráze je všechno
  až do merge Draft. Otevření PR je samostatný krok a PR je pořád Draft;
  publikací se stává až merge, a ten patří Principálovi/Stewardovi (viz root
  `AGENTS.md`, blok Model spolupráce).
- Standardní dokončení je branch pushnutá na `origin` a plnohodnotný PR proti
  `main`. Po otevření PR nastav `pr_url` a `status: "pr_open"`.
- Worktree bez aktivity sedm dní je `stale` warning, ne oprávnění k mazání.

### Bezpečný cleanup

Cleanup povol jen když současně platí:

1. worktree je clean včetně relevantních untracked souborů;
2. všechny požadované commity jsou pushnuté;
3. PR je merged, nebo closed bez merge a owner výslovně potvrdil opuštění;
4. worktree nepoužívá jiný proces/agent a plán už nemá aktivního writera;
5. sidecar odpovídá skutečné branchi a po cleanupu může být odstraněn.

Po splnění gate odstraň registrovaný worktree přes vlastnické repo:

```bash
git -C <owner-repo-primary> worktree remove <worktree-path>
git -C <owner-repo-primary> worktree prune
```

Sidecar odstraň až po úspěšném `git worktree remove`. Lokální branch maž přes
`git branch -d` až po merge. `--force`, `git branch -D` ani `rm -rf
.worktrees/*` nepoužívej bez explicitního, doloženého rozhodnutí o opuštění
práce.

## Lokální conversation provenance a recovery

Nově vytvořený nebo adoptovaný sidecar kromě plánu a Git identity zapisuje:

- `conversation_origin`: agentní `surface`, čitelný `agent_label`, opaque
  `thread_id` nebo výslovný `thread_locator_status` (`unavailable` /
  `not_applicable`), `captured_at` a `local_only: true`;
- `recovery_handoff`: `state`, stručné netajné `summary`, `blocker`,
  nejbližší `next_action` a `updated_at`.

Stabilní locator poskytovaný povrchem, například `CODEX_THREAD_ID`, zachyť
automaticky. Thread ID je lokální pomůcka pro otevření původního chatu na stejné
mašině, ne credential, portable URL ani source of truth. Neukládej raw
transcript, chain-of-thought, secrets, citlivá data ani absolutní transcript
path. Legacy v1 sidecar bez těchto polí zůstává čitelný; doplň je při nejbližším
bezpečném dotyku, ale jejich absence sama není důvod k invalidaci nebo smazání.

Při pauze, blockeru, předání a před koncem agentního běhu aktualizuj
`last_touched`, conversation origin aktuálního writer ownera a recovery
handoff. Ranní, večerní a cleanup agent nejdřív přečte sidecar a dostupný lokální
thread, ale před commitem, pushem, PR rozhodnutím nebo cleanupem ověří Git
status/diff, remote zachování, PR/checks, runtime a Mission Control. Nedostupný
nebo nedokončený thread není důkaz opuštění práce.


## Ověření

Před PR i před cleanupem ověř oba stavy a inventuru:

```bash
git -C <worktree> status --short --branch
git -C <worktree> log --oneline origin/<branch>..<branch>
git -C <owner-repo-primary> worktree list --porcelain
git -C <owner-repo-primary> status --short --branch
```

Dirty worktree, chybějící upstream, nepushnuté commity, otevřený PR, nejasný
owner nebo chybějící metadata nemaž — aktualizuj sidecar/plán a napiš přesný
handoff. Finální handoff vždy uveď: stav primárního checkoutu a potvrzení
`main`; worktree path, owner repo, branch, plán a sidecar; push/PR URL a stav;
provedené testy; co zůstává a proč; zda cleanup proběhl bezpečně, nebo které
gate mu brání.
