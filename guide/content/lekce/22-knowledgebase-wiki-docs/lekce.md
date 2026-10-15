---
id: 22-knowledgebase-wiki-docs
title: "Knowledgebase, research a playbooky"
section: 5-soucast-ekosystemu
order: 22
prerequisites: ["21-kam-pridat-novou-vec"]
duration_min: 10
quiz: true
ukol: false
---

# Knowledgebase, research a playbooky

**Co se v této lekci naučíš:**
- jaký je rozdíl mezi strategickou znalostí, research poznámkou a playbookem
- kam patří interní rozhodnutí
- kam patří hypotéza, experiment a ověřený postup

## Proč jsou vrstvy oddělené

AgentMint pracuje s nejistotou. Některé věci jsou strategická rozhodnutí,
některé jsou jen hypotézy a některé už mají důkaz. Když se tyto vrstvy smíchají,
začne se hypotéza tvářit jako ověřený mechanismus.

## `modules/knowledgebase/`

Knowledgebase bude držet nejdůležitější interní pravdu: strategii, guardrails,
rozhodnutí, důvody a lessons learned.

Patří sem otázky typu:

- proč jsme zvolili tento směr
- jaké rozhodnutí už padlo
- jaký risk appetite je přijatelný
- jaký je dlouhodobý model firmy

## `modules/research/`

Research bude držet mechanism scans, zdroje a srovnání kandidátů. Tady mohou
být hypotézy, ale musí být tak označené.

Patří sem:

- co někde online vydělává
- jaký je zákazník, nabídka a kanál
- jaký existuje důkaz
- jaká jsou rizika a ToS/legal poznámky

## `modules/experiments/`

Experiments budou držet test specs, run logs, metriky a výsledky. Experiment
musí mít hypotézu, metriku, rozpočet, stop podmínku a výsledek.

## `modules/playbooks/`

Playbooky jsou až pro ověřené opakovatelné mechanismy. Nápad sem nepatří.
Nejprve research, potom experiment, potom teprve playbook.

## Rozhodovací pravidlo

- „Proč jsme se tak rozhodli?" → knowledgebase
- „Co jsme zjistili o mechanismu?" → research
- „Jak dopadl test?" → experiments
- „Jak to zopakovat?" → playbooks

Dokud moduly fyzicky neexistují, používej root task ledgery a issue ledgery.

## Shrnutí

Knowledgebase drží strategii a důvody. Research drží hypotézy a zdroje.
Experiments drží testy a výsledky. Playbooky drží až ověřené opakovatelné
postupy.

**Příště:** vytvoříš svůj první vlastní postup pro agenta.
