# Team TODO

Team overlay tasks are tracked long-term in Mission Control. This
file is only a local signpost for the person overlay layer.

## Current state

- `alexmorgan/` exists as the first person overlay.
- `samtaylor/` exists as an onboarding scaffold; Sam Taylor still has to fill
  in roles, ownership, preferred working style, modules and external services
  without secrets.
- `robinlee/` exists as an onboarding scaffold; Robin Lee still has to fill in
  roles, ownership, preferred working style, modules and external services
  without secrets.
- Mission Control is the planning task manager; implementation steps are
  Mission Control tasks.
- Company OAuth accounts are not set up yet; `example.local` is only a local
  placeholder.
- More colleagues are added only after a decision recorded in Mission
  Control.

## When adding a new colleague

1. Copy `_template/` to `company/colleagues/<name>/`.
2. Fill in `README.md` and `AGENTS.md` to match reality.
3. In the personal `*.code-workspace`, change the second folder name from
   `_template` to the colleague's name.
4. Verify the cascade as a preflight: root → role → person → module.

## To be filled in by Alex or the team

- The actual roles of Sam and Robin.
- Whether they need new roles in `company/roles/`, or the existing
  `research-operator` / `experiment-operator` / `founder` are enough.
- GitHub access to the specific nested repositories their work needs.
- Per-person MCP configuration, locally in their `.claude/settings.json`,
  never in Git.
