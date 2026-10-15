---
id: 14-skills
title: "Skills: uložené postupy pro agenta"
section: 3-komunikace
order: 14
prerequisites: ["13-wispr-flow"]
duration_min: 12
quiz: true
ukol: false
---

# Skills: uložené postupy pro agenta

**Co se v této lekci naučíš:**
- co je skill
- proč pomáhá opakovaným úkolům
- kdy se hodí vytvořit vlastní skill

## Co je skill

Skill je uložený postup pro agenta. Kanonicky žije ve složce
`.agents/skills/<nazev>/SKILL.md`.

Tohle je společný source of truth v Gitu. Codex čte skills přímo odsud.
Claude Code používá cestu `.claude/skills`, ale ta je jen symlink na stejnou
knihovnu. Díky tomu se nemůže stát, že Claude používá jednu verzi postupu a
Codex druhou.

Můžeš si ho představit jako recept. Když nastane určitá situace, agent si recept otevře a postupuje podle něj. Díky tomu nemusí pokaždé znovu hádat, jak se dělá commit, jak se zakládá mechanism scan nebo jak se udržuje guide.

Příklad: když agent vidí, že se měnila data v jednom submodulu a uživatel chce změnu odeslat, použije skill `commit-push-submodule`. Ten drží správný postup, aby se nezapomněl commit v modulu ani posun ve workspace.

Když vzniká úplně nový modul, agent použije skill `create-new-module`.
Ten nejdřív ověří, že planned slot má opravdu přejít na modul. AgentMint je
GitHub-backed, takže bez výslovného rozhodnutí nevzniká GitHub repo ani remote.

Jiný příklad je `workspace-initialization`: agent ho použije po čerstvém
naklonování Workspace. Postará se o Doctora, Launchpad, Guide a o to, aby
případné opakovatelné chyby skončily jako oprava ve workspace, ne jako ruční
poznámka pro jednoho člověka.

Když se z mechanism scanu stane opakovaný postup, má vzniknout nový
AgentMint-specific skill. Třeba pro research checklist nebo experiment
guardrail review.

## Proč to není jen dokumentace

Dokumentace vysvětluje, co něco je. Skill říká, co má agent udělat krok za krokem.

Do skillu patří opakovaný pracovní postup. Nepatří tam definice pojmu ani dlouhá teorie. Když chceš vysvětlit, co znamená mechanismus, patří to do `GLOSSARY.md`. Když chceš popsat, jak agent pokaždé připraví mechanism scan, může to být skill.

## Jak skill použiješ

Často nemusíš říkat nic speciálního. Agent podle situace pozná, že skill potřebuje.

Můžeš mu ale pomoct:

> „Použij skill `guide-maintenance` a uprav lekci podle nové změny."

Nebo:

> „Nevím, jestli na to existuje skill. Najdi vhodný postup."

To je pro netechnického uživatele nejjednodušší: popíšeš situaci a necháš agenta vybrat správný recept.

## Sdílené a osobní skills

Sdílené firemní skills jsou kanonicky v `.agents/skills/`. Vidí je všichni
agenti ve workspace, včetně Claude Code přes symlink `.claude/skills`.

Osobní skills můžeš mít ve své složce `company/colleagues/<ty>/.claude/skills/`.
Jsou také v Gitu, ale mají platit jen pro tvůj lokální assistant setup. Hodí
se pro postupy, které jsou specifické pro tvou práci.

Skills a další instrukce pro agenty ve workspace píšeme česky s háčky a
čárkami. Anglické technické výrazy jako `commit`, `MCP`, `frontmatter` nebo
názvy příkazů zůstávají, když jsou přesnější, ale samotné instrukce mají
působit jako český pracovní postup.

## Kdy vytvořit nový skill

Nový skill dává smysl, když:

- děláš stejný postup opakovaně
- záleží na pořadí kroků
- chyba by měla dopad na kolegy
- postup by se mohl hodit i ostatním

Vlastní skill si vyzkoušíš v lekci 23.

## Shrnutí

Skill je recept pro agenta. Pomáhá opakovat ověřené postupy bez zbytečného vysvětlování. Když nevíš, zda skill existuje, zeptej se agenta.

**Příště:** ukážeme si MCP, tedy napojení agenta na externí služby, pokud je firma opravdu používá.
