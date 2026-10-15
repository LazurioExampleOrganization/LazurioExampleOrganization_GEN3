# Osobní skills — <VYPLNIT_JMENO>

Tato složka drží **osobní skills**, které používá jen
<VYPLNIT_JMENO>. Nesdílí je s týmem — na to je
`/.claude/skills/` v rootu workspace.

## Kdy použít osobní skill vs. sdílený skill

- **Sdílený skill** (`.claude/skills/`) — proces, který použije
  více lidí (např. `commit-push-submodule`)
- **Osobní skill** (`company/colleagues/<ty>/.claude/skills/`) — proces
  nebo preference, které je jen pro jednoho kolegu (např. specifický
  workflow s personal tooling, OAuth-gated operace)

## Aktivace

Osobní skill je agentovi dostupný, když:

1. Claude Code je spuštěný **z osobní složky**
   (`company/colleagues/<ty>/`), nebo
2. osobní skill je **symlinkovaný** do root `.claude/skills/` (méně
   časté)

## Formát

Stejný jako sdílené skills — frontmatter + flow dokumentace:

```markdown
---
name: <skill-name>
description: <kdy použít, v 1–3 větách>
---

# Skill: <skill-name>

...
```
