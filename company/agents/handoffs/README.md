# Handoffs

Tato složka drží **self-contained briefingy** pro delegované task
sessions. Každý soubor je prompt, který může Claude Code session
(nebo jiný agent) přečíst a vykonat **bez dalšího kontextu**.

## Formát

Každý handoff je markdown s:

1. **Task** — jedna věta, co se má stát
2. **Working directory** — kde agent pracuje
3. **Canon to read first** — které docs přečíst před akcí
4. **Scope** — co je v scope, co není
5. **Method** — kroky k vykonání
6. **Output** — co commitnout, jak reportovat

## Aktuální handoffs (open tasks)

AgentMint default: **prázdné**. Firma si přidává handoffs ad hoc, když
potřebuje delegovat samostatný task (např. „porovnej tři kandidátní
mechanismy", „zpracuj výsledky experimentu", „udělej jednorázový audit
zdrojů").

## Co se stane po dokončení

Po dokončení handoffu agent:

1. Commitne změny (typicky přes `doctor push "<message>"`)
2. Updatuje relevantní položku v root `TODO.tasks.json` nebo
   `DONE.tasks.json`
3. Pokud handoff vychází z feature plánu, doplní nebo ověří odkaz zpět na
   Mission Control plan
4. **Smaže** handoff file z této složky (nebo archivuje)
5. Pošle user-facing shrnutí

Alternativně (pokud je handoff multi-session): aktualizuje tento file
s current state a `Next session` sekcí.

## Proč ne skills

Skill = opakovaně volaný proces. Handoff = jedna konkrétní task s
konkrétním deliverable. Po dokončení se handoff smaže.

## Vzory handoffů

Pro inspiraci a konkrétní příklady formátu použij interní referenční
workspace nebo nejbližší existující klientskou instanci.
