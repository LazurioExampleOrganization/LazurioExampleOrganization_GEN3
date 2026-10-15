# Voice

Tato složka drží **tone of voice guidance** pro všechny výstupy, které
agent píše **jménem AgentMint** nebo jménem kolegy.

Je to **single source of truth** pro tón. Neduplikuj tone of voice do
`AGENTS.md`, `README.md` ani skill souborů — odkazuj sem.

## Co sem patří

### Baseline

- `AGENTMINT_BASELINE_VOICE.md` — firemní baseline tone pro
  výstupy jménem AgentMint (announcementy, shared docs,
  interní zápisy bez specifického autora).

  **Tip:** jako výchozí bod použij stručný rozhovor s ownerem firmy:
  komu firma píše, jak formálně mluví, kterým frázím se vyhýbá a jaké
  příklady výstupů už považuje za dobré. Nekopíruj cizí firemní identitu
  ani interní tone of voice z jiné firmy.

### Per-person tone (volitelné)

- `<PERSON>_TONE_OF_VOICE.md` pro každého kolegu, který má výrazně
  odlišný osobní styl, za kterého agent píše. Typicky CEO, osobnosti
  v PR/marketingu.

## Co sem NEpatří

- proces, jak napsat e-mail (to je skill, pokud je to opakovatelné)
- šablony konkrétních e-mailů (to jsou templates, patří do skill
  podpůrných souborů)
- strategie marketingu (to je `modules/marketing/` modul nebo
  `modules/knowledgebase/`, pokud firma má)

## Kaskáda tónu

Když existuje víc tone zdrojů, **bližší vyhrává**. Agent čte od
specifického k obecnému:

1. Pokud píše jménem konkrétní osoby → `<PERSON>_TONE_OF_VOICE.md`
2. Pokud osoba nemá vlastní tone → role-specific tone (volitelně)
3. Pokud ani role nemá → `AGENTMINT_BASELINE_VOICE.md`

## Stav

Baseline existuje v `AGENTMINT_BASELINE_VOICE.md`. Per-person tone přidej jen
tehdy, když se má psát jménem konkrétní osoby výrazně jiným stylem.
