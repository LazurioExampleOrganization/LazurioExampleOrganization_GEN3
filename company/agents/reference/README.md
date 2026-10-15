# Reference

Tato složka drží **hluboké technické a provozní reference** pro agenta.

Na rozdíl od `runbooks/` (postupy k vykonání) a `voice/` (jak psát
výstup), `reference/` drží **knowledge k ad hoc konzultaci**. Agent
si to čte, když potřebuje porozumět něčemu do hloubky.

## Co sem patří

Firmy typicky dodávají:

- technické mapy (co kde je v codebase)
- doménové background docs (pro nové kolegy)
- HW/systémové diagramy
- reference specifických technologií

Konkrétní obsah závisí na firmě. Aktuální reference:

- [`mission-control-planning-model.md`](mission-control-planning-model.md) —
  kontrakt mezi lokálními Mission Control YAML plány a implementačními
  `TODO.tasks.json` tasky

## Co sem NEpatří

- procesy k vykonání (to jsou skills v `/.claude/skills/`)
- tone of voice (to je `company/agents/voice/`)
- doménové definice pojmů (to je `GLOSSARY.md`)
- strategie a firemní rozhodování (to je `modules/knowledgebase/`
  pokud firma má)

## Kdy reference přečíst

Agent by měl reference načíst ad hoc, když:

- uživatel se ptá na něco specifického
- skill explicitně odkazuje na reference dokument
- chystá se kontext-náročná změna

Nemusí se číst v každé session. Není to baseline kontext.
