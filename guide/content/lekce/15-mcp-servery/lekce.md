---
id: 15-mcp-servery
title: "MCP: napojení na služby"
section: 3-komunikace
order: 15
prerequisites: ["14-skills"]
duration_min: 10
quiz: true
ukol: false
---

# MCP: napojení na služby

**Co se v této lekci naučíš:**
- proč agent potřebuje napojení na externí služby
- co znamená MCP jednoduchou řečí
- proč tokeny a hesla nepatří do Gitu

## Jednoduché vysvětlení

MCP je způsob, jak agent bezpečně používá další služby. Díky tomu nemusí jen hádat z textu, ale může se zeptat konkrétního nástroje.

Příklad: když řekneš „ověř soubor v Google Drive", agent potřebuje napojení na Google. Když plánuješ feature v AgentMintu, výchozí plánovací vrstva je lokální Mission Control, takže agent nejdřív pracuje se soubory ve workspace. Právě k externím službám slouží MCP servery a podobné toolkity.

Technický název je Model Context Protocol. Pro běžnou práci si stačí pamatovat: MCP je most mezi agentem a službou.

## Co máme v AgentMint

AgentMint nemá externí plánovací task manager jako baseline. Plánovací vrstva
má být Mission Control: lokální YAML-first modul ve workspace. Implementační
stav práce zůstává v root task ledgerech: `TODO.tasks.json`,
`DONE.tasks.json` a `ISSUES.open.json`.

Externí MCP se přidává podle reálné potřeby: browser tooling se používá pro
aktuální research a Google Workspace přijde až po vzniku reálné domény a účtů.
Některé věci si nastavuje každý podle své role.

Nemusíš si vše instalovat sám/sama. Když agent zjistí, že mu napojení chybí, řekne ti to a navrhne další krok.

## Osobní napojení

Některá napojení jsou osobní. Třeba přístup do tvého Gmailu nebo Google Drive nemůže být společný pro celou firmu. Nastavuje se přes tvůj účet a žije v soukromé konfiguraci.

To je důležité pro bezpečnost: agent pracuje jménem konkrétního člověka a jen s tím, k čemu má daný člověk oprávnění.

## Co nikdy nedávat do Gitu

Do sdílených souborů nepatří:

- hesla
- API klíče
- přihlašovací tokeny
- OAuth session data
- soubory s tajnými credentials

Tyto věci patří do keychainu, do gitignored konfigurace nebo do bezpečného správce hesel. Když si nejsi jistý/á, zastav se a zeptej se agenta.

## Shrnutí

MCP je most mezi agentem a službami. Díky němu může agent pracovat s Googlem,
task managerem nebo dalšími systémy. Přístupy jsou citlivé, proto hesla a
tokeny nikdy nepatří do Gitu.

**Sekce hotová:** už víš, jak s agentem mluvit, jak zadávat práci a proč existují skills a MCP. Příště začneš první reálnou práci ve workspace.
