---
id: 12-jak-psat-prompty
title: "Jak zadávat práci agentovi"
section: 3-komunikace
order: 12
prerequisites: ["11-claude-code-codex"]
duration_min: 12
quiz: true
ukol: false
---

# Jak zadávat práci agentovi

**Co se v této lekci naučíš:**
- proč je zadání důležitější než „kouzelný prompt"
- jak začít otázkou místo rozkazu
- jak dát agentovi hranice a kontrolní krok

## Začni sladěním

Když nevíš přesně, co má vzniknout, nezačínej příkazem. Začni otázkou.

Místo:

> „Ověř tenhle online mechanismus."

Zkus:

> „Najdi zdroje k tomuto mechanismu. Řekni mi, jaký je zákazník, nabídka, kanál, důkaz a rizika. Zatím nic nespouštěj."

První zadání nutí agenta rovnou něco změnit. Druhé ho nejdřív vede k pochopení situace. To je bezpečnější a většinou kvalitnější.

## Co má dobré zadání obsahovat

Stačí jednoduchý formát:

1. **Co řeším** — problém nebo cíl.
2. **Z čeho máš vycházet** — soubory, task, dokumentace, poznámky.
3. **Co chci jako výstup** — návrh, seznam, diff, nový text.
4. **Co neměň** — hranice úkolu.
5. **Jak poznáme, že je to dobré** — kritéria kvality.

Příklad:

> „Pracujeme na prvním mechanism scanu. Otevři `TODO.tasks.json`, najdi research task a připrav návrh šablony. Nic neukládej, dokud mi neukážeš návrh změny."

## Dávej malé kroky

Velký úkol rozděl na menší. Agent pak méně hádá a ty máš víc kontrolních bodů.

Špatně:

> „Přidej nový produkt, ceník, dokumentaci a web."

Lépe:

1. najdi vzor podobného produktu
2. navrhni novou strukturu
3. ukaž, které soubory by se měnily
4. připrav první změnu
5. počkej na schválení

## Chtěj kontrolu před uložením

U důležité práce vždy požádej o náhled:

> „Než cokoliv uložíš, ukaž mi, co bys změnil a proč."

Nebo:

> „Po úpravě mi vysvětli, z čeho jsi vycházel a kde si nejsi jistý."

Tak držíš kontrolu bez toho, abys musel/a znát každý technický detail.

## Prompty jako soubory

Když nějaké zadání používáš opakovaně, nenechávej ho jen v historii chatu. Ulož ho jako soubor ve workspace, třeba do své osobní složky. Příště ho agent najde a můžeš ho zlepšovat.

Když se ze zadání stane opakovaný postup o více krocích, může z něj vzniknout skill. K tomu se vrátíme později.

## Shrnutí

Dobrý prompt není kouzelná věta. Je to jasné zadání: cíl, zdroje, hranice, výstup a kontrola. Když si nejsi jistý/á, začni otázkou.

**Příště:** ukážeme si diktování ve Wispr Flow, aby zadávání práce agentovi nebylo pomalé psaní na klávesnici.
