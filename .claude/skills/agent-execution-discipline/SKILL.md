---
name: agent-execution-discipline
description: Použij v AgentMintu před netriviální změnou kódu, dokumentace nebo workflow — vede agenta od zodpovědnosti za výsledek přes plán v Mission Control a worktree k udržitelné, ověřené změně.
---

# Skill: agentní disciplína při změnách

Tahle skill vede agenta, jak brát zodpovědnost za práci: od záměru přes plán
a worktree až po udržitelnou změnu, kterou po tobě někdo rád převezme.
Nejsi tu od toho, abys udělal nejlevnější možný zásah — jsi tu od toho,
abys odvedl dobrou práci, za kterou se postavíš.

## Kdy použít

Za netriviální změnu, na kterou tahle skill míří, ber hlavně:

- refactor, feature nebo změnu workflow, která přesahuje jeden zřejmý soubor
- úpravu access hranice, research schématu, experiment metriky, stop
  condition nebo evidence destination
- úpravu více než jednoho `AGENTS.md`, skillu, task ledgeru nebo workflow
  pravidla
- cokoliv s legal/platform/reputation rizikem nebo možnou externí akcí

Drobná oprava (překlep, rozbitý odkaz, jasná jednořádková chyba) plán
v Mission Control nepotřebuje — použij úsudek, ale i tu pracuj ve worktree a
přes PR (skill `worktree-stewardship`). Když váháš, ber změnu jako
netriviální a projdi tuhle skill zkráceně.

## Postup

### 1. Vezmi zodpovědnost za výsledek

Než začneš, umíš odpovědět:

- Co má po mé práci platit a jak to poznám? (ověřitelný cíl)
- Kdo je owner té oblasti a kde je source of truth — nejbližší `AGENTS.md`,
  `modules/knowledgebase` nebo `ISSUES.open.json`?
- Jaký je business kontext — komu to slouží a co se rozbije, když to udělám
  špatně?
- Které předpoklady si domýšlím? Domněnka, která mění správnost, bezpečnost,
  zákaznický dopad nebo owner hranici, není domněnka — je to otázka na
  Principála.

Zodpovědnost znamená: když nevíš, zjistíš; když to nejde zjistit, zeptáš se;
a co slíbíš v handoffu, je pravda.

### 2. Netriviální práce začíná plánem v Mission Control

Refactor, feature, změnu workflow nebo access hranici si nejdřív naplánuj
v `mission-control/` (in-tree vrstva přímo v tomto repu, skill
`mission-control-planning`): YAML plán s kódem, cílem a acceptance
kritérii v `mission-control/plans/`. Plán není byrokracie — je to kotva,
přes kterou tvou práci najde další agent i Principál, a dává jméno tvému
worktree (`<PLAN-kód>-<slug>`). Pokud plán chybí nebo je nejasný, založ
nebo aktualizuj task přímo v `TODO.tasks.json` a plánovací detail dopiš
do `mission-control/plans/`, jakmile bude jasný.

### 3. Pak worktree — nikdy primární checkout

Primární checkout Organizace i každého nested repo modulu je referenční
strom a zůstává na `main`. Práce žije v dedikovaném worktree podle skillu
`worktree-stewardship`: `.worktrees/root/<PLAN-kód>-<slug>/` pro Organization
root, `.worktrees/<module-path>/<PLAN-kód>-<slug>/` pro nested repo modul
(kanonické cesty a sidecar metadata dle decision 0049). Jeden plán = jeden
worktree = jedna branch = jeden PR. Rozdělaná práce mimo worktree je dluh,
který po tobě někdo musí uklidit.

### 4. Dělej udržitelné změny

Udržitelná změna je taková, kterou za půl roku někdo pochopí, zvaliduje
a rozšíří:

- Řeš příčinu, ne symptom. Quick hack, který obchází pravidla nebo maskuje
  problém, není hotová práce — i kdyby prošel testem.
- Drž hranice změny: měň, co patří k cíli plánu. Sousední problémy zapiš
  jako follow-up do `TODO.tasks.json`, `ISSUES.open.json` nebo Mission
  Control plánu, nemíchej je do diffu.
- Udržitelnost není gold-plating: nezaváděj spekulativní abstrakce pro
  neexistující use case. Je to čitelnost, správný datový tok a respekt
  k owner hranicím — business data patří do owner modulu a zapisují se přes
  jeho canonical writer; u v3 modulů přes repository-db publikační flow.
- Zanech workspace pravdivější, než jsi ho našel: poznatky do
  `modules/knowledgebase`, rozhodnutí do `ISSUES.open.json`, změny pravidel
  práce do nejbližšího `AGENTS.md`.

## Ověření

- Předem urči nejmenší přesvědčivé ověření a spusť ho; když nejde spustit,
  napiš proč — nikdy nepředstírej zelený výsledek.
- Handoff: co se změnilo, proč je řešení udržitelné, co bylo ověřeno a co
  zůstává jako follow-up. Bez secrets a bez reasoning dumpu.
- Tvoje práce končí PR — je to Draft a merge patří Principálovi nebo
  Stewardovi, který ho reviewuje (viz root `AGENTS.md`, blok Model
  spolupráce).
