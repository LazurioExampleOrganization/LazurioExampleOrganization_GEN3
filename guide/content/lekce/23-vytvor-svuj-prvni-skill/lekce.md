---
id: 23-vytvor-svuj-prvni-skill
title: "Vytvoř si první postup pro agenta"
section: 5-soucast-ekosystemu
order: 23
prerequisites: ["22-knowledgebase-wiki-docs"]
duration_min: 15
quiz: true
ukol: true
---

# Vytvoř si první postup pro agenta

**Co se v této lekci naučíš:**
- kdy má smysl vytvořit skill
- jak vypadá jednoduchý skill
- jak si nechat pomoct agentem

## Proč skill vytvářet

Když něco děláš poprvé, stačí běžné zadání agentovi. Když stejný postup děláš potřetí, stojí za to přemýšlet o skillu.

Skill uloží pracovní know-how do podoby, kterou může agent znovu použít. Tím se tvoje zkušenost nestane jen jednorázovým řešením, ale součástí workspace.

## Jak vypadá

Skill je soubor `SKILL.md` s krátkou hlavičkou a postupem:

```markdown
---
name: weekly-report
description: Použij, když uživatel chce připravit týdenní report z dashboardu.
---

# Skill: weekly-report

## Postup
1. Najdi zdrojová data.
2. Připrav návrh reportu.
3. Označ nejasnosti.
4. Počkej na review.
```

Nejdůležitější část je `description`. Podle ní agent pozná, kdy se má skill použít.
Piš ji česky s diakritikou, stejně jako tělo skillu. Anglické technické
termíny nech jen tam, kde jsou přirozenější nebo přesnější než překlad.

## Kdy skill dává smysl

Vytvoř ho, když:

- postup se opakuje
- má víc kroků
- záleží na pořadí
- chyba by stála čas nebo peníze
- postup se může hodit i kolegům

Nevytvářej skill pro jednorázovou poznámku, definici pojmu nebo dlouhou teorii. To patří jinam.

## Začni osobně

Pro první pokus je nejlepší osobní skill v `company/colleagues/<ty>/.claude/skills/`.
I osobní skill patří do Gitu. Neznamená to, že ho mají používat všichni;
znamená to, že je součástí tvého profilu ve workspace a dá se zkontrolovat.

Když se ukáže, že ho používá víc lidí, může se přesunout mezi sdílené firemní
skills v kanonické root `.agents/skills/`. Claude Code ho uvidí přes symlink
`.claude/skills`, protože obě cesty vedou na stejnou knihovnu.

Nemusíš ho psát sám/sama. Řekni agentovi:

> „Pomoz mi vytvořit osobní skill pro postup, který často opakuju. Nejdřív se mě zeptej na kroky a rizika."

## Otestuj ho

Po vytvoření skill vyzkoušej na malé situaci. Pokud se agent neaktivuje, uprav `description`. Pokud postup vynechává důležitý krok, doplň ho.

## Shrnutí

Skill je uložený postup pro agenta. Vytvářej ho pro opakovanou práci, kde se vyplatí držet přesné kroky.

**Příště:** ukážeme si, jak pomáhat kolegům, aby workspace nebyl jen složka, ale společný pracovní systém.
