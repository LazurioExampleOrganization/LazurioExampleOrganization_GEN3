# Roles

The `company/roles/` folder holds **reusable role overlays** for the
Organization. A role is a **reusable pattern**: it sits above a specific person
in `company/colleagues/<you>/` and gives a baseline for working in that role.

## What a role is

- **The second layer of the AGENTS.md cascade**: a role overrides the root
  baseline (see the cascade of instructions in the root `AGENTS.md`)
- **Reusable** across people (several colleagues can share the same role)
- **A definition of responsibility**: what the role owns, which modules it
  reads or writes, which outputs it delivers
- **A handoff boundary**: who takes over from you and from whom you take over

## What a role is not

- It is not person-specific: personal matters belong in `company/colleagues/`.
- It is not a module: a role is about people, a module is code.
- It is not a set of Git or SSH permissions: repository access on GitHub
  decides those.

## AGENTS.md cascade

A role is the second layer:

1. root `/AGENTS.md` (company baseline)
2. `/company/roles/<role>/AGENTS.md`: **role baseline** (this layer)
3. `/company/colleagues/<you>/AGENTS.md` (person override)
4. `/workspace/<module>/AGENTS.md` (module scope override)

## Structure

```
roles/<role>/
├── README.md   # who this is, what it does, which outputs
└── AGENTS.md   # role-specific operating rules
```

Template: `company/roles/_template/`.

Starter catalogue: `company/roles/_starter/`. It is not an active role
overlay; it is a safe source of generic role archetypes for setting up a new
company.

## Canonical roles

### Core roles

- `founder`: company direction, choice of mechanisms, budget, risk appetite
  and the decision on what gets tested next.
- `research-operator`: mapping online mechanisms, working with sources,
  breaking a model down and preparing the evidence for a decision.
- `experiment-operator`: turning a hypothesis into a small measurable test,
  guardrails, metrics, a run log and a stop or scale recommendation.

### Restricted access

- `founder` holds the more sensitive decisions and future financial data.
- Other roles must not write sensitive exports, credentials or platform
  accounts into Git.

## How to create roles during setup

1. Ask the company owner about the real work and the decision boundaries.
2. Use `company/roles/_starter/` as a catalogue of archetypes.
3. For each chosen role, copy `_template/` to `company/roles/<role>/`.
4. Fill in `README.md` for people: what the role does, typical modules,
   outputs, handoff boundaries.
5. Fill in `AGENTS.md` operationally: how an agent works in the role, when to
   ask, when to escalate.
6. For each person in `company/colleagues/<person>/`, set the primary role and
   any multi-role disambiguation.

Do not create roles without an owner, outputs and handoff boundaries. If a
role is not clear yet, leave it in TODO and come back to it after the first
real week of work.

## Multi-company consideration

Roles with generic names (`sales`, `technical-lead`, `marketing`) should be
reusable in other companies of the portfolio as well. Domain specifics belong
in each role's `AGENTS.md` and stay company-specific.
