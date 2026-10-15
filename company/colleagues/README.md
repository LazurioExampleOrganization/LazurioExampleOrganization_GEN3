# Colleague overlays

This folder holds **personal workspace overlays** for the colleagues of the
Organization. Each colleague has their own folder,
`company/colleagues/<os-user>/`.

`<os-user>` must match the user name on the computer. When the OS user name
is `alexmorgan`, the colleague folder is `company/colleagues/alexmorgan/`.
The GEN2 `company/team/` folder is no longer used.

## Format

```
company/colleagues/
├── README.md             # this file
├── TODO.md               # tasks and the state of the overlays
├── _template/            # pattern for a new colleague
│   ├── README.md         # scaffold for the personal README
│   ├── AGENTS.md         # scaffold for the person overlay
│   ├── *.code-workspace  # VS Code/Cursor multi-root workspace template
│   └── .claude/skills/   # personal skills
└── <os-user>/            # one for each colleague
    ├── README.md
    ├── AGENTS.md
    ├── *.code-workspace  # personal VS Code/Cursor workspace
    ├── .claude/skills/   # the colleague's personal skills
    ├── archive/          # local storage outside Git (gitignored)
    ├── private/          # private local layer (gitignored)
    ├── tools/            # personal scripts (optional)
    └── voice/            # personal tone of voice (optional, otherwise
                          # in company/agents/voice/)
```

## What `company/colleagues/<you>/` is

- **A normal folder in the super-repo**: tracked directly, not a submodule.
- A place for **personal configuration and preferences** (preferred
  language, multi-role disambiguation).
- A place for **personal skills** that only that colleague uses.
- A slot for **per-person MCP configuration** (in `.claude/settings.json`,
  gitignored, secrets outside Git).
- A slot for local **`archive/`** and **`private/`** folders outside Git.

## What `company/colleagues/<you>/` is not

- It is not **a separate Git submodule**: that would be overhead.
- It is not **a secrets store**: tokens and API keys belong in the
  gitignored `.claude/settings.json`, the OS keychain or `.env.local`.
- It is not **agent memory**: no `memory/` and no `MEMORY.md`.
- It is not **a copy of company knowledge**: shared material belongs in
  `workspace/knowledgebase/` or in skills.

## AGENTS.md cascade

The person overlay is the third layer of the cascade:

1. root `/AGENTS.md`: company baseline
2. `/company/roles/<role>/AGENTS.md`: role baseline
3. `/company/colleagues/<os-user>/AGENTS.md`: **person override**
4. `/workspace/<module>/AGENTS.md`: module scope override

**Rule:** the closer one wins. A person overlay can override a role, and a
module can override anything for its own scope.

## How to add a new colleague

1. Copy `_template/` to `company/colleagues/<os-user>/`.
2. Fill in `README.md` and `AGENTS.md` to match reality (role, contact,
   preferences).
3. In the personal `*.code-workspace`, change the second folder name from
   `_template` to the colleague's OS user name.
4. Add the colleague to
   `lazurio.organization.json#extensions.legacy.colleague_overlays.active_colleagues`
   with a confirmed primary role, and regenerate the `company.gen3.json`
   projection with
   `lazurio migrate organization-manifest <task-worktree> --write` (do not
   edit it by hand).
5. Commit in a worktree and open a pull request against the root repository;
   the new colleague then sets up `.claude/settings.json` (OAuth, MCP tokens)
   locally. Those are **never committed**.

## What a colleague must fill in

A person overlay should be useful to agents, but it must not contain secrets
or unverified assumptions about the person. Each colleague fills in their own
folder:

- **role**: the primary role, other roles and the disambiguation of when each
  one applies
- **ownership**: what they own, what they may decide and when they escalate
- **modules**: which nested repositories they typically need
- **work identity**: work email and external services, without tokens
- **preferences**: language, length of answers, level of detail and working
  style
- **external actions**: what the agent must not do without confirmation
- **handoff**: to whom they hand work and from whom they take it

Until the role or the ownership is filled in, the agent asks and must not
guess them from the name.

## Current colleagues

| Folder | Colleague | Primary role |
|---|---|---|
| `alexmorgan/` | Alex Morgan | `founder` (also holds the research and experiment operator work of the first phase) |
| `samtaylor/` | Sam Taylor | onboarding scaffold, role not confirmed |
| `robinlee/` | Robin Lee | onboarding scaffold, role not confirmed |

Active colleagues with a confirmed role are listed in
`lazurio.organization.json#extensions.legacy.colleague_overlays.active_colleagues`.
