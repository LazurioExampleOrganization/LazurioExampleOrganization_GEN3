# <FILL_NAME>

This folder is the **person overlay** for <FILL_NAME>.

## Colleague context

- **Name:** <FILL_NAME>
- **Primary role:** `<FILL_ROLE>` (see `company/roles/<FILL_ROLE>/`)
- **Work email:** `<FILL>@example.local`
- **<FILL_TASK_TOOL> user ID:** `<FILL>`

## How to help most often

<FILL_HOW_TO_HELP>

Describe what this colleague typically needs help with (prioritising,
preparing material, follow-ups, and so on).

## Active roles

If the colleague holds several roles, list them here with the
disambiguation:

- **`<role1>`**: when to come to you in this role
- **`<role2>`**: when in this one

## Default module set

Describe which modules this colleague typically needs. Actual access follows
SSH access and the root `modules.manifest.json`.

## How best to give tasks to the agent

<FILL_HOW_TO_GIVE_TASKS>

## Workspace in VS Code / Cursor

This folder contains a `*.code-workspace` template for a multi-root
workspace. After copying `_template/` to `company/colleagues/<name>/`:

1. rename the file after the company slug, if it is not named that way yet
2. open it in VS Code or Cursor via `File -> Open Workspace from File...`
3. in `folders[1].name`, change `_template` to `<name>`

The workspace file needs no Git submodule settings: the Organization has no
submodules, and modules are nested checkouts that Lazurio finds and clones.

## Preferred language

- Internal communication: <FILL>
- Code and commit messages: English (the Organization standard)
- External outputs: depending on the audience

## Personal skills and memory

- Personal skills (in Git): `company/colleagues/<name>/.claude/skills/`
- Personal local archive outside Git: `company/colleagues/<name>/archive/`
- **Personal memory across projects:** an optional gbrain outside the
  workspace (see the root `AGENTS.md`).
- **Shared company knowledge** goes to `workspace/knowledgebase/`,
  `workspace/wiki/`, skills or AGENTS.md (see the root `AGENTS.md`).

## Links

- Operating rules: [AGENTS.md](AGENTS.md) (person overlay,
  <FILL_NAME>-specific)
- Role details: `company/roles/<role>/`
- Company baseline: root `/AGENTS.md`, `/ARCHITECTURE.md`,
  `/GLOSSARY.md`
