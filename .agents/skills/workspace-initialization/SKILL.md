---
name: workspace-initialization
description: "Použij po čerstvém naklonování nebo forku Workspace GEN2 instance, když má agent poprvé připravit workspace pro konkrétního kolegu: ověřit lokální pravidla, spustit Doctor/bootstrap flow, nainstalovat dependencies, ověřit Launchpad/Guide handoff a opravit opakovatelné onboarding bugy."
---

# Skill: workspace-initialization

Použij tenhle skill, když se agent rozeběhne v čerstvě naklonovaném
Workspace GEN2 repu a má ho připravit pro konkrétního kolegu.

Typické situace:

- AgentMint workspace se připravuje na novém počítači
- nový kolega si poprvé otevírá hotový firemní workspace
- maintainer chce ověřit, že onboarding flow je pro netechnického člověka
  opravdu průchozí

Cíl není jen „spustit skript“. Cíl je předat člověku funkční workspace,
funkční základní tooling a jasný další krok v Guide.

## Identita a tón

Na začátku se představ jako **Asistent**:

> Ahoj, jsem Asistent. Připravím ti Workspace GEN2, ověřím, že lokální
> tooling funguje, a na konci tě pošlu do Launchpadu nebo Guide.

Mluv lidsky. Kolega nemusí rozumět nested repo modulům, Dock plistům, Bun lockům ani
Git internals. Technické detaily drž v reportu, ne v hlavní navigaci.

## Povinný preflight

1. Ověř, že jsi v rootu super-repa:

   ```bash
   pwd
   test -f AGENTS.md && test -f company/scripts/doctor.sh
   ```

2. Projdi instrukční kaskádu:
   root `AGENTS.md`, relevantní roli v `company/roles/`, person overlay
   v `company/colleagues/<člověk>/` a případný modulový `AGENTS.md`, pokud
   pracuješ uvnitř modulu.

3. Spusť kontextový check, pokud ho Doctor podporuje:

   ```bash
   company/scripts/doctor.sh check-my-context
   ```

4. Ověř, že OpenAI Codex CLI je v `PATH`:

   ```bash
   command -v codex
   ```

   Pokud příkaz chybí, pomoz uživateli nastavit Codex do user `PATH` tak,
   aby fungoval i v novém terminálu. Nepoužívej ani necommituj absolutní
   cestu z konkrétního počítače do sdíleného workspace.

5. Pokud existuje skill `doctor-workflow`, načti ho. Inicializace workspace
   patří přes Doctora nebo přes jeho dokumentované bootstrap fallbacky.
   Nepouštěj ručně náhodné Git příkazy napříč module repozitáři.

## Kanonický init flow

Nejdřív zjisti, co daná instance podporuje. Každý GEN2 workspace nemusí mít
stejnou úroveň Doctora.

### Varianta A — instance má `doctor init`

Pokud `company/scripts/doctor.sh init --help` nebo dokumentace Doctora
potvrdí subcommand `init`, spusť:

```bash
company/scripts/doctor.sh init
```

`doctor init` má ideálně:

- inicializovat dostupné nested repo moduly podle root
  `modules.manifest.json`
- rozlišit `available`, `missing_access` a `planned_slot`
- nenechat super-repo dirty kvůli obsahu nebo pointerům modulů
- nainstalovat Node/Bun dependencies
- připravit Launchpad, pokud to instance podporuje
- na konci spustit rychlý health check

Když Doctor hlásí `missing_access`, neber to automaticky jako chybu. V GEN2
je partial workspace normální stav: kolega může mít přístup jen k části
modulů.

### Varianta B — instance ještě nemá `doctor init`

Pokud `doctor init` není dostupný, použij dokumentovaný fallback:

```bash
company/scripts/bootstrap-macos.sh
company/scripts/doctor.sh install-deps
company/scripts/doctor.sh check --quick
```

Na Windows použij PowerShell variantu:

```powershell
.\company\scripts\bootstrap-windows.ps1
.\company\scripts\doctor.ps1 install-deps
.\company\scripts\doctor.ps1 check --quick
```

Když bootstrap skript v instanci ještě není vyplněný nebo hlásí planned
slots, reportuj to jako stav setupu, ne jako drama. Smyslem je poznat, co je
připravené pro běžného kolegu a co je ještě úkol pro maintainera.

## Aktivně kontroluj výsledek

Po initu nebo fallbacku ověř nezávisle:

```bash
company/scripts/doctor.sh deps-status
company/scripts/doctor.sh check
git status --short --branch
```

Kontroluj hlavně:

- super-repo není omylem dirty kvůli module pointerům
- dostupné nested repo moduly nejsou v detached HEAD, pokud mají být na větvi
- dependencies jsou zdravé nebo je jasně vysvětlené, co chybí
- `codex` je dostupný v `PATH`
- `guide/app` jde postavit přes `npm run build`
- Launchpad/Guide handoff je pro člověka srozumitelný

Když Doctor tvrdí, že je vše v pořádku, ale stav workspace tomu odporuje,
ber to jako bug v Doctoru nebo onboarding flow. Oprav zdroj problému, ne jen
symptom na počítači kolegy.

## Launchpad a Guide handoff

Po úspěšném initu kolegu naveď na první praktický krok. AgentMint je
GitHub-backed workspace; konkrétní appky a provider integrace vzniknou až po
prvních ověřených mechanismech.

### macOS Launchpad install target

Na macOS je cílový stav: kolega má firemní Launchpad jako lokální aplikaci
a vidí ho v Docku. Pokud instance podporuje `doctor install-launchpad`,
spusť ho:

```bash
company/scripts/doctor.sh install-launchpad
```

Potom ověř:

- Launchpad appka existuje v dokumentovaném user umístění (v GEN3 jde
  o sdílený Conglomerate Launchpad z Launchpad rootu; přesný `.app` bundle
  popisuje daná instance)
- appku jde otevřít běžným macOS způsobem
- Dock instalace/provisioning doběhla, nebo Doctor jasně vysvětluje, že
  Dock pin vyžaduje ruční potvrzení uživatele
- Guide je dostupný z Launchpadu, pokud ho Launchpad registruje

Nepřidávej do repa uživatelské absolutní cesty, lokální `.app` bundle ani
Dock plist. To jsou per-user runtime artifacty.

Pokud instance `doctor install-launchpad` nepodporuje nebo selže,
nepředstírej, že je Launchpad nainstalovaný. Reportuj přesně:

- Launchpad install není v této instanci funkční
- macOS Dock instalace neproběhla automaticky
- dočasný onboarding path vede přímo přes Guide

### Guide fallback

1. Pokud Launchpad registruje appku **Guide**, otevři Guide přes Launchpad.
2. Pokud Launchpad Guide ještě neregistruje, spusť Guide přímo:

   ```bash
   cd guide/app
   npm install
   npm run dev
   ```

3. V Guide projdi úvodní lekce, které vysvětlují, jak s Workspace GEN2
   pracovat.

## Když něco selže

1. Rozliš:
   - očekávaný partial-workspace stav (`missing_access`, `planned_slot`)
   - lokální setup problém (chybí Bun/Node, SSH key, místo na disku)
   - bug v Doctoru, Launchpadu, manifestu, Guide nebo dokumentaci
2. Oprav bug v repu, pokud jde o opakovatelný problém, který potká i další
   kolegy.
3. Znovu spusť relevantní smoke:

   ```bash
   company/scripts/doctor.sh deps-status
   company/scripts/doctor.sh check
   cd guide/app && npm run build
   ```

4. Pokud jsi měnil onboarding, Doctora, Launchpad nebo skills, použij také
   `guide-maintenance` a uprav Guide, pokud se změnil mentální model nováčka.

## PR / handoff změn

Když během inicializace opravíš bug ve sdíleném super-repu:

- drž se git policy z root `AGENTS.md`
- commit message piš anglicky a release-note stylem
- necommituj secrets, osobní cesty ani tokeny
- pokud repo policy vyžaduje PR, vytvoř PR místo direct push

V závěru napiš:

- co je hotové
- které moduly jsou dostupné a které chybí kvůli přístupu nebo plánovanému
  slotu
- jestli Doctor/bootstrapping funguje
- jestli Launchpad funguje, je nainstalovaný a co případně zbylo u Docku
- jestli Guide jde otevřít a postavit
- jaké bugy jsi opravil a kde je commit/PR
- co má kolega udělat jako další lidský krok
