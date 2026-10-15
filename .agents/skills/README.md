# Organization skills

This directory holds the Organization's shared agent skills. It is the only
Git-tracked source of truth for repeatable agent processes in this
Organization. The index is `manifest.json`.

`.agents/skills` is canonical. `.claude/skills` is a byte-for-byte mirror of
the skill directories for Claude Code; OpenAI Codex reads `.agents/skills`
directly. Edit a skill here, then copy the changed directory to
`.claude/skills` in the same pull request. Root CI fails when the two differ.

Lazurio itself ships the general skills (worktrees, the Module Standard,
workstation install) in the Lazurio root. Skills here cover only what is
specific to this Organization.

## Skills

- [`agent-execution-discipline`](agent-execution-discipline/SKILL.md): own the
  outcome of a non-trivial change, from plan and worktree to a verified result.
- [`design-system-lookup`](design-system-lookup/SKILL.md): find the
  Organization's source of truth and design system before visual or
  formatted work.
- [`mission-control-planning`](mission-control-planning/SKILL.md): anchor a
  feature or experiment plan in Mission Control before implementation steps.
- [`module-agent-maintenance`](module-agent-maintenance/SKILL.md): keep a
  workspace module's own documentation in step with its changes.

## Writing a skill

1. Create `<skill-name>/SKILL.md` with frontmatter:

   ```markdown
   ---
   name: <skill-name>
   description: <When to use it, in one to three sentences.>
   ---
   ```

2. Use the sections `## When to use`, `## Steps` and `## Verification`.
3. Add the skill to `manifest.json` and copy the directory to
   `.claude/skills/`.
4. Write in English. Never commit machine-specific paths, tokens or personal
   scratch notes.

A skill is a process to follow. Reference knowledge belongs in
`company/agents/reference/` and tone of voice in `company/agents/voice/`.
Personal skills belong in `company/colleagues/<os-user>/.claude/skills/`.
