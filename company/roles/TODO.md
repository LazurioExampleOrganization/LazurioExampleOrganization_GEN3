# Roles TODO

Role overlay tasks are tracked long-term in Mission Control. This
file is only a local signpost for the role layer.

## Current state

The Organization has three canonical roles:

- `founder`
- `research-operator`
- `experiment-operator`

## When the role model changes

1. Update `company/roles/README.md`.
2. Add or change the specific `README.md` and `AGENTS.md` of the role.
3. Reflect the change in the root `modules.manifest.json` if it changes access
   to or ownership of modules, and regenerate the `company.gen3.json`
   projection with
   `lazurio migrate organization-manifest <task-worktree> --write`.
4. Update the person overlays that use the role.
