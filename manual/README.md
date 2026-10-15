# Maintenance manuál Organizace AgentMint

Tento manuál je source of truth pro maintenance agenty, kteří udržují
AgentMint jako Organizaci GEN3. Provoz se nesmí opírat o paměť jednoho
člověka ani o jeden chat.

## Co maintenance agent chrání

- správný source of truth pro každou změnu
- forkability template a company overrides
- evidence guardrails: hypotéza ≠ důkaz, škáluje se jen ověřený mechanismus
- legal/platform guardrails: žádný spam, fake engagement, obcházení ToS ani
  klamavé claimy
- přístupové hranice v `infra/access` v restricted nested repu `infra/`
- osobní hranice v `company/colleagues/<os-user>/`
- validní tasky v `TODO.tasks.json` a `DONE.tasks.json`
- otevřené nerozhodnuté otázky v `ISSUES.open.json`
- business dopad rozhodnutí podle
  `lazurio.organization.json#extensions.legacy.business_context`

## První pořadí čtení

1. `AGENTS.md`
2. `lazurio.organization.json`
3. tento manuál
4. `GLOSSARY.md`
5. `TODO.tasks.json`, `DONE.tasks.json` a `ISSUES.open.json`
6. nejbližší modulový nebo složkový `AGENTS.md`

## Source of truth map

- Struktura firmy: `lazurio.organization.json` (+ inventář modulů v
  `modules.manifest.json`); `company.gen3.json` je generovaná kompatibilní
  projekce a mění se jen přes
  `lazurio migrate organization-manifest <task-worktree> --write`
- Přístupy: `infra/access/` v nested repu `infra/`
- Kolegové a osobní overlaye: `company/colleagues/`
- Role: `company/roles/*.role.json`
- Agentní procesy: `.agents/skills/`
- Voice guide: `company/agents/voice/`
- Design systém firmy: `design-system/`
- Moduly: `modules/` (deskriptor: root `modules.manifest.json`)
- Plánování: `mission-control/` (nested repo)
- Živá práce: `TODO.tasks.json`
- Hotová práce: `DONE.tasks.json`
- Nerozhodnuté problémy: `ISSUES.open.json`
- Sdílené pojmy: `GLOSSARY.md`
- Významné změny: `CHANGELOG.md`

## Template upstream režim

AgentMint vznikl z GEN2 Lazurio company template linie (repo nevzniklo jako
fork GEN3 template). Remote model:

```text
origin   -> git@github.com:LazurioExampleOrganization/LazurioExampleOrganization_GEN3.git
```

Remote `template` se přidává lokálně (`git remote add template …`) a slouží
pro budoucí template sync. Maintenance agent nemá dělat lokální změny, které
by zbytečně rozbíjely future template sync; sync musí být branch s čitelným
diffem a review.

## Infra a mission-control

`infra/` je restricted root nested repo
(`git@github.com:LazurioExampleOrganization/infra.git`) pro access governance a deployment
kontext. `mission-control/` je nested repo
(`git@github.com:LazurioExampleOrganization/mission-control.git`) pro plánovací vrstvu. Obě
spravuje doctor podle root `modules.manifest.json`; super-repo
jejich obsah netrackuje.

## Colleagues overlay pravidlo

Složka kolegy se jmenuje podle lokálního OS username:

```text
company/colleagues/<os-user>/
```

`archive/`, `private/` a lokální runtime složky jsou ignorované Gitem a
nesmí se kopírovat do sdíleného repozitáře. Složky `tomas/` a `petr/`
jsou onboardingové scaffoldy bez potvrzené role.

## Launchpad pravidlo

Shared Launchpad GEN3 je v Launchpad rootu. Organizace dodává jen
konfiguraci (`lazurio.organization.json`, `modules.manifest.json` a pro starší
čtečky generovanou projekci `company.gen3.json`), package
manifesty a pluginy. Pokud aplikace běží na portu, port musí být
deklarovaný pouze v jejím modulovém `lazurio.module.json`; package
`lazurio.runtime.listeners` na pojmenovaný lease jen odkazuje. In-tree
`launchpad/` je jen redirect po GEN2.

## AgentMint jako experimentální firma

AgentMint hledá ověřitelné cesty, jak mohou AI agenti vydělávat peníze
online — legálně, s vlastním brandem a vlastními daty. Pracovní smyčka:
najít mechanismus → rozložit na model → navrhnout legální adaptaci →
spustit malý test → zapsat výsledek → škálovat jen s důkazem.

Zároveň je AgentMint testovací Organizace pro GEN2 → GEN3 migrační
pipeline; tato veřejná kopie začíná vyčištěným snapshotem GEN2 baseline a migruje
na GEN3 přímo zde.

## Moduly a hranice

- `modules/knowledgebase` — strategie a guardrails, nejvyšší autorita.
- `modules/research` — mechanism scans a evidence; každý claim má zdroj a
  datum.
- `modules/experiments` — specs, run logy, stop/scale rozhodnutí; tady
  vzniká důkaz.
- `modules/playbooks` — jen ověřené mechanismy; hypotézy sem nepatří.
- `modules/automations` — runtime až po ručním ověření guardrails.
- `modules/content` — veřejné assets bez cizího obsahu a bez claimů bez
  důkazu.
- `modules/finance` — unit economics; citlivá data jen anonymizovaná, jinak
  mimo Git.
