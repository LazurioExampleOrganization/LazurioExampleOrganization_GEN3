---
id: 07-agents-readme-map
title: "Soubory, které tě navedou"
section: 2-prvni-den
order: 7
prerequisites: ["06-pet-vrstev"]
duration_min: 8
quiz: true
ukol: false
---

# Soubory, které tě navedou

**Co se v této lekci naučíš:**
- kdy otevřít `README.md`
- proč existuje `AGENTS.md`
- jak ti pomůže `MAP.md`
- kdy sáhnout po `WORKSPACE_MANUAL.md`

## `README.md`: úvod pro člověka

Když poprvé otevřeš neznámou část workspace, hledej `README.md`. Je to úvod psaný pro lidi. Měl by ti říct, co v dané složce je, k čemu slouží a jak s ní bezpečně začít.

Není ostuda se do README vracet. Naopak. Dobrý workspace počítá s tím, že lidé si věci připomenou.

## `WORKSPACE_MANUAL.md`: proč workspace funguje právě takhle

Když už víš, kde co najít, ale chceš pochopit celý systém, otevři
`WORKSPACE_MANUAL.md`. Ten vysvětluje mental model Workspace GEN2: proč
existují generace, jak spolu souvisí lidé a agenti, proč jsou aplikace
verzované jako `app/v1`, jak se zachází s daty a proč se důležité poznatky
zapisují zpátky do markdown dokumentů.

Není to náhrada za `ARCHITECTURE.md` ani `GLOSSARY.md`. Je to čitelný průvodce,
který tě provede souvislostmi a odkáže na správné source-of-truth soubory.

## `AGENTS.md`: instrukce pro agenta

`AGENTS.md` je podobný úvod, ale pro AI agenta. Říká mu, jak se má v dané části chovat, co nesmí udělat a jaké postupy má použít.

Ty ho nemusíš číst celý. Je ale dobré vědět, že existuje. Když agent říká „musím nejdřív udělat preflight" nebo „tady se nesmí ručně měnit nested repo stav", často to ví právě z `AGENTS.md`.

Agent čte pravidla ve vrstvách:

1. společná pravidla workspace
2. pravidla tvé role
3. tvoje osobní pravidla
4. pravidla konkrétního modulu

Bližší pravidlo má přednost. Díky tomu může mít obchodník jiný způsob práce než technik a modul `automations` může mít přísnější pravidla než běžná dokumentace.

## `MAP.md`: rychlý rozcestník

`MAP.md` je soubor pro chvíli, kdy nevíš, kde co hledat. Neřeší detaily. Ukáže směr.

Typicky odpoví na otázky:

- kde se řeší nabídka experimentu
- kde je ověřený playbook
- kde najdu interní návody
- kde jsou výsledky experimentů
- co je kořen workspace a co je modul

## Jak postupovat, když se ztratíš

Použij jednoduchý pořádek:

1. otevři `MAP.md`
2. najdi oblast, která odpovídá tvému úkolu
3. pokud chceš pochopit širší kontext, přečti `WORKSPACE_MANUAL.md`
4. otevři příslušný modul nebo složku
5. v ní si přečti lokální `README.md`
6. když má pracovat agent, nech ho přečíst i lokální `AGENTS.md`

## Shrnutí

`README.md` vede člověka, `AGENTS.md` vede agenta, `MAP.md` je rozcestník pro chvíli, kdy nevíš, kam jít, a `WORKSPACE_MANUAL.md` vysvětluje, proč celý Workspace GEN2 funguje právě tímto způsobem.

**Příště:** projdeme si `GLOSSARY.md`, firemní slovník, který pomáhá lidem i agentům mluvit stejným jazykem.
