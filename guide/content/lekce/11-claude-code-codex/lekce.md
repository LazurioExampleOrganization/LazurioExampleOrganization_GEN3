---
id: 11-claude-code-codex
title: "Codex, Cursor a Claude Code"
section: 3-komunikace
order: 11
prerequisites: ["10-prvni-prochazka"]
duration_min: 10
quiz: true
ukol: false
---

# Codex, Cursor a Claude Code

**Co se v této lekci naučíš:**
- jaké nástroje se ve workspace používají
- kdy dává smysl Codex
- kdy dává smysl Claude Code
- proč není potřeba znát všechny nástroje najednou

## Nejde o soutěž nástrojů

V běžném AI chatu řešíš hlavně odpověď. Ve workspace řešíš práci nad soubory: najít správný zdroj, navrhnout změnu, ukázat rozdíl a neporušit pravidla.

K tomu se používají agentní nástroje. V AgentMintu potkáš hlavně Codex, Claude Code a někdy Cursor. Všechny mají společný princip: běží nad workspace a umí pracovat s jeho soubory.

## Codex

Codex je agent pro práci ve workspace. Může číst soubory, spouštět kontroly, upravovat obsah a držet se pravidel z `AGENTS.md`.

Pro tebe je důležité toto: Codexu nemusíš vysvětlovat úplně všechno od nuly. Když je spuštěný ve AgentMint workspace, ví, že má číst lokální pravidla, hledat správné zdroje a chránit změny, které nepatří k úkolu.

Codex se hodí, když chceš:

- opravit nebo doplnit text ve workspace
- zkontrolovat strukturu souborů
- projít task ledger a navrhnout další krok
- bezpečně připravit změnu a vysvětlit, co udělal

## Claude Code

Claude Code je podobný typ agenta, jen má svůj nativní vstup přes `CLAUDE.md`. V AgentMintu je `CLAUDE.md` krátký bootstrap: řekne Claude Code, aby četl `AGENTS.md`, spustil preflight a držel stejnou GEN2 kaskádu jako ostatní agenti.

Claude Code se hodí hlavně, když chceš:

- dlouho číst a upravovat markdown dokumenty
- tvořit nebo ladit skills v `.claude/skills/`
- pracovat terminálově nad větším kontextem
- nechat agenta projít pravidla, plán a task ledger před editací

Není to paralelní sada pravidel. Když se mění agentní instrukce, autorita je pořád `AGENTS.md`, případně bližší role, person nebo modulový `AGENTS.md`.

## Cursor

Cursor je editor podobný VS Code s AI panelem. Je praktický, když chceš změny vidět vizuálně, klikat mezi soubory a mít agentní pomoc vedle editoru.

Pro netechnické kolegy je často příjemný, protože ukazuje soubory, změny a náhledy víc „na obrazovce".

## Jak si vybrat

Pro tento kurz si klidně drž jedno hlavní pravidlo: začni s jedním nástrojem a nepřepínej uprostřed úkolu bez důvodu.

Když pracuješ přes Launchpad nebo Codex App, zůstaň v Codexu. Když jsi v terminálu a chceš delší práci s dokumenty, pravidly nebo skills, Claude Code je přirozená volba. V obou případech platí stejné workspace pravidlo: nejdřív kontext a source of truth, potom změna.

Když se zasekneš, zeptej se přímo:

> „Jsem ve AgentMint workspace. Jaký nástroj je pro tento úkol nejlepší a proč?"

Agent ti pomůže vybrat.

## Shrnutí

Codex, Claude Code a Cursor jsou pracovní agentní nástroje nad workspace. Nemusíš ovládat všechny. Důležité je, že AgentMint drží společná pravidla v `AGENTS.md` a Claude Code má `CLAUDE.md` jen jako krátký vstup zpět do stejné kaskády.

**Příště:** naučíš se psát zadání tak, aby agent nejdřív pochopil problém a teprve potom jednal.
