# AGENTS.md: <FILL_NAME> (person overlay)

This file is the **third layer of the cascade** (root → role → person →
module, see the cascade of instructions in the root `AGENTS.md`). It holds **only
what is specific to <FILL_NAME>**. The generic company policy is in the root
`AGENTS.md`, the role policy in `company/roles/<FILL_ROLE>/AGENTS.md`.

## Role

<FILL_NAME> is **<FILL_ROLE_FULL_NAME>** (see `company/roles/<FILL_ROLE>/`).

<FILL_CONTEXT>: why this person is here, what lands on their desk, how to
help them best.

## Multi-role disambiguation (if they hold several roles, otherwise delete)

<FILL_NAME> holds <N> roles: `<role1>`, `<role2>`.

When a request is ambiguous, the agent **asks** which role to take it in.
Do not guess, and do not mix roles silently.

- **`<role1>`**: when it applies
- **`<role2>`**: when it applies

When it is obvious from the context, continue without asking.

## <FILL_TASK_TOOL>

- **Login email** (OAuth identity): `<FILL>`
- **Contact work email**: `<FILL>@example.local`
- **<FILL_TASK_TOOL> user ID**: `<FILL>`
- **<FILL_TASK_TOOL> workspace**: `<FILL>`
- **Default task list**: `<FILL>`

## Monorepo scope label policy (if you have a task-driven codebase, otherwise delete)

For commit messages, PR titles and bodies and tasks in
`workspace/<FILL_CODEBASE>/`, always give a **scope label** from the
canonical list:

`<FILL>`, `<FILL>`, ...

Format: `<Scope>: <short summary>`.

The branch prefix (for example `codex/PLAN-XXXX`) from the root `AGENTS.md`
applies at the same time.

## Preferred language

- **Internal communication with the agent**: <FILL> (English, Czech or a
  mix)
- **Code, comments, commit messages, PR descriptions**: English,
  conventional commits
- **External outputs**: depending on the audience

## Preferred working style

<FILL_STYLE>

Examples:

- **Short summaries of technical decisions for a non-technical audience.**
- **<Task tool> is for operational visibility, ownership and communication; the Git and Mission Control ledgers hold the roadmap, the decisions and the execution state.**
- **Point out blockers, risks and missing decisions proactively.**
- **Impact, not implementation**: summarise the impact on the business, the team or the customer.

## Tone of voice

For emails, <FILL_TASK_TOOL> tasks, comments and announcements on behalf of
<FILL_NAME>, use as the **only canonical source**
`company/agents/voice/<FILL>_TONE_OF_VOICE.md` (if it exists, otherwise fall
back to `<FILL_COMPANY>_BASELINE_VOICE.md`).

Do **not duplicate** the tone of voice here: one source of truth.

## Personal skills and memory

- **Personal skills**: `company/colleagues/<name>/.claude/skills/` (optional)
- **Personal cross-project memory**: an optional gbrain outside the workspace
  (see the root `AGENTS.md`)
- **Shared company knowledge**: `workspace/knowledgebase/`,
  `workspace/wiki/`, skills or AGENTS.md (see the root `AGENTS.md`)
