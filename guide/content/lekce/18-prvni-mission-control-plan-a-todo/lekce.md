---
id: 18-prvni-mission-control-plan-a-todo
title: "První Mission Control plán a TODO task"
section: 4-prvni-prace
order: 18
prerequisites: ["17-tva-role"]
duration_min: 12
quiz: true
ukol: true
---

# První Mission Control plán a TODO task

**Co se v této lekci naučíš:**
- proč AgentMint odděluje plánování od implementace
- jak Mission Control drží feature kontext jako YAML soubory
- jak `TODO.tasks.json` drží konkrétní vykonatelné kroky

## Proč dvě vrstvy

AgentMint směřuje k Mission Control: lokálnímu plánovacímu centru pro
features, experimenty a větší změny. Mission Control drží širší kontext:

- proč věc existuje
- kdo ji vlastní
- jaký je scope
- jaká rozhodnutí už padla
- podle čeho poznáme hotovo

Git workspace drží implementační stav:

- `TODO.tasks.json` — aktuální vykonatelné kroky
- `DONE.tasks.json` — hotová nebo archivovaná práce
- `ISSUES.open.json` — otázky čekající na rozhodnutí

Když něco řešíš jen v chatu, může to zapadnout. Když plán vznikne jako YAML ve
workspace a implementace má task v ledgeru, další agent dokáže navázat.

## Jak zapojit agenta

Pro novou feature začni takto:

> „Připrav Mission Control plán pro tuhle feature a navrhni implementační kroky do `TODO.tasks.json`. Zatím nic neupravuj."

Agent ověří workspace, přečte root dokumenty a navrhne, kam má práce patřit.

Příklad:

- plán nového experimentu patří do Mission Control jako YAML plan
- implementační kroky patří do `TODO.tasks.json`
- otevřené rozhodnutí patří do `ISSUES.open.json`
- výsledek experimentu patří do `DONE.tasks.json` nebo `modules/experiments/`
- opakovatelný postup patří do skillu nebo později do `modules/playbooks/`

Když si nejsi jistý/á, zeptej se:

> „Co má zůstat v Mission Control planu a co má být konkrétní TODO ve workspace?"

## Malý bezpečný postup

U prvního plánování postupuj pomalu:

1. nech agenta najít nebo navrhnout Mission Control plan
2. nech ho shrnout cíl, scope a acceptance criteria
3. nech ho najít správný source of truth ve workspace
4. požádej o návrh TODO tasků
5. zkontroluj návrh
6. až pak dovol uložení

To je práce na druhém stupni: agent dělá, ty vedeš a schvaluješ.

## Nezapomeň na stopu mezi vrstvami

Task v `TODO.tasks.json` má odkazovat zpět na Mission Control plan přes pole
`planning` nebo aspoň přes link na YAML soubor. Po dokončení práce se
aktualizuje task ledger a do plánu se doplní outcome.

## Shrnutí

Mission Control drží plán a důvod. `TODO.tasks.json` drží proveditelné kroky.
Agent ti pomůže z plánu udělat implementační práci, ale nesmí ztratit stopu
mezi oběma vrstvami.

**Příště:** naučíš se, co znamená commit, push a PR v běžné řeči.
