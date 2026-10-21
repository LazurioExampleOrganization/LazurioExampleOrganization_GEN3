# Personal skills: <FILL_NAME>

This folder holds **personal skills** that only <FILL_NAME> uses. They are not
shared with the team; shared skills live in `.agents/skills/` at the workspace
root (mirrored to `.claude/skills/`).

## When to use a personal skill and when a shared skill

- **Shared skill** (`.agents/skills/`): a process that several users follow
  (for example `mission-control-planning`)
- **Personal skill** (`company/colleagues/<you>/.claude/skills/`): a process
  or preference that is for one colleague only (for example a specific
  workflow with personal tooling, OAuth-gated operations)

## Activation

A personal skill is available to the agent when Claude Code is started **from
the personal folder** (`company/colleagues/<you>/`).

## Format

The same as shared skills: frontmatter plus the flow documentation:

```markdown
---
name: <skill-name>
description: <when to use it, in 1–3 sentences>
---

# Skill: <skill-name>

...
```
