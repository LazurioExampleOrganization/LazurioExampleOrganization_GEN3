# Shared agent docs

The `company/agents/` folder is the **shared agent library** for the whole
Organization workspace.

It is a **knowledge layer** above `company/colleagues/` and `company/roles/`,
not a replacement for them.

## Layout

- `runbooks/`: **LEGACY slot**, empty by default. **Skills**
  (`.agents/skills/`, mirrored to `.claude/skills/`) are the canonical format
  for repeatable procedures, not runbooks. The slot is kept only for a
  consistent structure.
- `reference/`: deeper technical and operational maps. Knowledge to consult,
  not processes to carry out.
- `voice/`: communication guidance, tone of voice for emails, task manager
  messages and announcements. The **single source of truth** for tone: do
  not duplicate it.
- `handoffs/`: self-contained briefings for delegated one-off task sessions.
  Each handoff is a prompt that an agent reads and carries out without
  further context. The handoff is deleted when it is done.

## Relation to skills

**Skills** (in `.agents/skills/`, mirrored to `.claude/skills/`) are the
canonical format for repeatable procedures, because Claude Code can invoke
them directly.

- **Skill** = a process to carry out (how-to)
- **Reference** = knowledge to consult (ad hoc lookup)
- **Voice** = how to write an output
- **Handoff** = a one-off task briefing for another session

If you find that a procedure is repeatable, propose a skill, not a runbook or
a text document.

## Who owns what

- The content of `runbooks/`, `reference/` and `voice/` is **company-wide**.
  Changes affect everyone.
- `company/colleagues/<you>/voice/` may exist for person-specific tone
  overrides (optional).
- `handoffs/` are one-off artefacts: they are deleted when done.

## How to find the right source

An agent in a session:

1. **A process to carry out?** → look for a skill in `.agents/skills/`
   (shared) and in `company/colleagues/<you>/.claude/skills/` (personal).
2. **Deep technical knowledge?** → `company/agents/reference/`.
3. **How to write an output?** → `company/agents/voice/`.
4. **A domain term?** → `GLOSSARY.md` (root).
5. **Strategy, rules, decisions?** → `workspace/knowledgebase/`
   (if the company has one).
6. **A delegated one-off task?** → `company/agents/handoffs/`.
