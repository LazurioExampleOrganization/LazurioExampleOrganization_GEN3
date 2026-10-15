# Shared Agent Docs

Složka `company/agents/` je **sdílená agentní knihovna** pro celý
AgentMint workspace.

Je to **knowledge vrstva** nad `company/colleagues/` a `company/roles/`, ne
jejich náhrada.

## Rozdělení

- `runbooks/` — **LEGACY slot**, default prázdný. V GEN2 jsou
  kanonickým formátem pro opakovatelné postupy **skills**
  (`.claude/skills/`), ne runbooks. Slot je zachovaný jen kvůli
  konzistenci struktury.
- `reference/` — hlubší technické a provozní mapy. Knowledge ke
  konzultaci, ne procesy k vykonání.
- `voice/` — komunikační guidance, tone of voice pro e-maily,
  task-manager zprávy, announcementy. **Single source of
  truth** pro tón — neduplikuj.
- `handoffs/` — self-contained briefingy pro delegované one-off task
  sessions. Každý handoff je prompt, který agent přečte a vykoná bez
  dalšího kontextu. Po dokončení se handoff smaže.

## Vztah k skills

V GEN2 jsou **skills** (v `/.claude/skills/`) kanonický formát pro
opakovatelné postupy, protože je Claude Code umí přímo invokovat.

- **Skill** = proces k vykonání (how-to)
- **Reference** = knowledge ke konzultaci (ad hoc lookup)
- **Voice** = jak napsat výstup
- **Handoff** = one-off task briefing pro jinou session

Pokud zjistíš, že postup je opakovatelný, navrhni skill, ne runbook
ani textový dokument.

## Kdo co vlastní

- Obsah `runbooks/`, `reference/`, `voice/` je **company-wide**. Změny
  se týkají všech.
- `company/colleagues/<ty>/voice/` může existovat pro person-specific tone
  overrides (volitelné).
- `handoffs/` jsou one-off artifakty — smažou se po dokončení.

## Jak najít správný zdroj

Agent v session:

1. **Proces k vykonání?** → hledej skill v `/.claude/skills/` (sdílený)
   a `company/colleagues/<ty>/.claude/skills/` (osobní).
2. **Hluboká technická znalost?** → `company/agents/reference/`.
3. **Jak psát výstup?** → `company/agents/voice/`.
4. **Doménový pojem?** → `GLOSSARY.md` (root).
5. **Strategie, pravidla, rozhodování?** → `modules/knowledgebase/`
   (pokud firma má).
6. **Delegovaný one-off task?** → `company/agents/handoffs/`.
