# Role: <FILL_ROLE_NAME>

**Scope:** <FILL_SCOPE>

This folder defines a reusable role overlay. A specific user refers to it
from `company/colleagues/<name>/`.

## What the role does

In the Organization, <FILL_ROLE_NAME> leads or ensures:

- <FILL>
- <FILL>
- <FILL>

## Ownership

The role owns:

- **Modules / layers:** <FILL>
- **Outputs:** <FILL>
- **Decisions:** <FILL>
- **Escalation:** <FILL>

## Typical modules

<FILL_MODULES>

Example:

- `workspace/<FILL>/`: <why the role needs this module>
- `workspace/<FILL>/`: <why>

## Typical outputs

- <FILL_OUTPUT>
- <FILL_OUTPUT>

## Source of truth

- Primary source of facts: <FILL>
- Work system / tasks: <FILL>
- Documentation or wiki: <FILL>

## Handoff boundaries

- **→ <other role>**: <when the handover happens and what is handed over>
- **← <other role>**: <when it takes over from others>
- **Escalation to <role>**: <when the role must not decide on its own>

## Multi-role note

If a specific user holds several roles, the disambiguation belongs in
`company/colleagues/<person>/AGENTS.md`. Describe the pure role here, not a
personal mix.

## What not to do

- <scope boundary against other roles>
- <sensitive or forbidden actions>
- <typical scope creep>

## Links

- Operating rules: `company/roles/<FILL_ROLE_NAME>/AGENTS.md`
- Company baseline: root `/AGENTS.md`
- Starter catalogue: `company/roles/_starter/`

## Status

The basics work. The full role is filled in over time as needed (see
`company/roles/TODO.md`).
