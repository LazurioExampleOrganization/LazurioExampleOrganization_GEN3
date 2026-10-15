---
id: 08-glossary
title: "Slovník firmy"
section: 2-prvni-den
order: 8
prerequisites: ["07-agents-readme-map"]
duration_min: 10
quiz: true
ukol: false
---

# Slovník firmy

**Co se v této lekci naučíš:**
- proč má AgentMint vlastní slovník
- jaké pojmy potkáš nejčastěji
- kdy nový pojem doplnit do `GLOSSARY.md`

## Proč slovník existuje

Každá firma má vlastní jazyk. Slova jako mechanismus, experiment, důkaz nebo playbook zní obyčejně, ale v AgentMint mají přesný význam.

Proto máme v rootu soubor `GLOSSARY.md`. Je to slovník pojmů pro lidi i
agenty. Když se řekne mechanismus, adaptace, experiment, důkaz nebo interní role,
všichni by měli chápat totéž.

## Pár pojmů, které budeš vídat

**Mechanismus** je opakovatelný způsob, jak vzniká online příjem.

**Adaptace** je legální převedení mechanismu do vlastního kontextu AgentMint.

**Experiment** je malý měřitelný test hypotézy.

**Důkaz** je evidence, která zvyšuje jistotu, že mechanismus funguje.

**Playbook** je ověřený postup, který lze opakovat.

**Unit economics** je základní ekonomika jedné jednotky výdělku.

**Guardrail** je pravidlo, které chrání firmu před právním, reputačním,
platformním nebo bezpečnostním problémem.

**Module** v GEN2 znamená top-level nested Git repo modul pod `modules/<nazev>/`.
Má vlastní repo, historii a přístup. Neznamená to běžný programátorský modul
v kódu.

**Launchpad modul** je takový modul, který Launchpad umí spouštět nebo
spravovat jako lokální aplikaci. Jeho aplikace typicky žije v `app/v1/`
uvnitř modulu.

Nemusíš si to pamatovat nazpaměť. Stačí vědět, že když pojem potkáš, otevřeš `GLOSSARY.md`.

## Proč je to důležité pro agenta

Agent používá stejný slovník. Když mu řekneš „ověř mechanismus", potřebuje
vědět, že nemá kopírovat cizí firmu, ale rozebrat model příjmu. Když řekneš
„zapiš důkaz", má vědět, že pocit nestačí a že výsledek patří do task ledgeru
nebo budoucího `modules/experiments/`.

Slovník snižuje nedorozumění. U lidí i u AI.

## Kdy pojem doplnit

Nový pojem doplň do `GLOSSARY.md`, když:

- mate víc lidí
- používá se napříč firmou
- má jeden význam, který stojí za to zapsat

Naopak tam nepatří jednorázové poznámky, osobní zkratky ani detail platný jen
pro jeden experiment. Takové věci patří do experiment logu nebo nejbližšího
task ledgeru.

## Shrnutí

`GLOSSARY.md` je firemní slovník. Pomáhá lidem i agentům používat stejná slova pro stejné věci.

**Příště:** spustíme doctor, nástroj pro kontrolu zdraví workspace.
