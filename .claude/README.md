# `.claude/`: Claude Code configuration

This directory holds the shared Claude Code configuration of the
Organization. It lives in the root so that Claude Code loads it when it opens
the repository.

- `skills/` is a byte-for-byte mirror of the skill directories in
  `.agents/skills/`, which is canonical. Change a skill there and copy it
  here in the same pull request; root CI checks that both are equal.
- The root `CLAUDE.md` only points to `AGENTS.md`; rules are never kept in two
  copies.

Personal settings, tokens, session data and caches do not belong here. They
live in the gitignored `company/colleagues/<os-user>/.claude/` or in
`~/.claude/`.
