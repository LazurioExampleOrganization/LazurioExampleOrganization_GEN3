---
id: 09-doctor
title: "Doctor: kontrola zdraví workspace"
section: 2-prvni-den
order: 9
prerequisites: ["08-glossary"]
duration_min: 12
quiz: true
ukol: true
---

# Doctor: kontrola zdraví workspace

**Co se v této lekci naučíš:**
- co je doctor
- které příkazy budeš používat nejčastěji
- proč je bezpečnější než ruční Git příkazy

## Co je doctor

Doctor je pomocný skript ve `company/scripts/doctor.sh`. Kontroluje stav workspace, umí ho synchronizovat a pomáhá bezpečně odeslat změny.

Workspace je složený z více částí. Když by každý ručně pouštěl náhodné Git příkazy, snadno vzniknou konflikty. Doctor drží jeden doporučený postup, aby se práce lidí a agentů nerozbíjela.

## Tři příkazy pro začátek

Nejdřív si zapamatuj tyto:

```bash
company/scripts/doctor.sh init
company/scripts/doctor.sh status
company/scripts/doctor.sh sync
company/scripts/doctor.sh check --quick
company/scripts/doctor.sh check --fix
```

`init` se používá po čistém naklonování workspace. Připraví submoduly,
zkusí nainstalovat balíčky, na macOS připraví Launchpad GEN2 v Docku a na
konci pustí rychlou kontrolu.

`status` ukáže, co je ve workspace změněné nebo chybějící.

`sync` stáhne poslední změny od ostatních.

`check --quick` udělá rychlou kontrolu, jestli je základ v pořádku. Mimo jiné
hlídá, že příkaz `codex` je dostupný v `PATH`, aby agentní nástroje fungovaly
i po otevření nového terminálu.

`check --fix` je lokální oprava bezpečných bootstrap problémů. Umí vytvořit
chybějící `.env.local` z `.env.example`, doplnit chybějící `node_modules` a
přepnout čistý submodul z detached HEAD zpět na očekávanou větev, pokud to
nezmění obsah. Nedělá commit, push, rebase ani root pull a nesahá do dirty
submodulu. Stejný režim má i čitelnější příkaz:

```bash
company/scripts/doctor.sh repair-local
```

Když potřebuješ opravit jen lokální Launchpad po inicializaci, existuje
samostatný příkaz:

```bash
company/scripts/doctor.sh install-launchpad
```

Ten nainstaluje Launchpad GEN2 jako macOS appku a přidá ji do Docku, aby šla
snadno otevřít.

Když chceš jen vysvětlit, co příkaz dělá, použij nápovědu:

```bash
company/scripts/doctor.sh sync --help
```

Nápověda je bezpečná: nic nestahuje, nic neposílá a nic neopravuje. To je
důležité pravidlo Doctora. Příkazy jako `status`, `check` a `deps-status`
jsou kontrolní. `check --fix` a `repair-local` mění jen lokální soubory, které
jsou bezpečné opravit automaticky. Příkazy jako `sync`, `push`,
`install-deps` nebo `port --kill` už mohou změnit stav workspace výrazněji,
proto mají v nápovědě napsané side efekty.

Když pracuje agent, může navíc spustit:

```bash
company/scripts/doctor.sh check-my-context
```

Tím si ověří, že čte správná pravidla.

## Ukládání změn

AgentMint je zatím GitHub-backed bez remote. Doctor přesto umí připravit bezpečný
náhled změn. Nejdřív vždy dry-run, tedy zkušební běh bez commitu nebo pushe:

```bash
company/scripts/doctor.sh push -m $'Workspace: Update experiment checklist\n\nClarify the first AgentMint experiment guardrails.' \
  --include TODO.tasks.json \
  --include ISSUES.open.json \
  --dry-run
```

Teprve když náhled sedí a člověk chce commit, pokračuje se potvrzeným krokem.
Push se nedělá, dokud workspace nemá remote a člověk ho výslovně neschválí.

## Čemu se vyhnout

Nepouštěj ručně `doctor sync`. V GEN2 je to rizikové, protože submoduly mají vlastní pravidla a jejich ukazatele se musí posouvat správně.

Prakticky: když nevíš, jaký Git příkaz použít, nepoužívej ho. Zeptej se agenta nebo spusť doctor.

## Když doctor něco hlásí

Neznamená to automaticky problém. Třeba „missing access" může jen říkat, že na daný modul nemáš přístup. To je normální stav.

Zkopíruj výpis agentovi a zeptej se: „Co to znamená a co mám udělat dál?"
Agent podle toho zvolí správný postup. Pokud doctor odmítne neznámý flag,
je to dobře: raději se zastaví a pošle tě na `--help`, než aby hádal.

U některých doporučení doctor vypíše i `owner` a `risk`. `agent-safe`
znamená, že agent může pokračovat sám. `needs-approval` znamená, že je potřeba
souhlas nebo review. `GitHub-backed` je jen lokální oprava, `git-sync` se týká
Gitu nebo nested repo stavů a `external-write` už míří mimo tvůj počítač.

## Shrnutí

Doctor je bezpečná kontrola workspace. Pro začátek si pamatuj `status`,
`sync`, `check --quick` a `check --fix`. Ruční Git příkazy nech na agenta nebo
na dohodnutý postup.

**Příště:** projdeš si workspace na vlastní oči.
