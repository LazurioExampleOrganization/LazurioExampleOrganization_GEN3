---
name: agent-execution-discipline
description: Use before a non-trivial change to code, documentation or a workflow in this Organization. It takes the agent from owning the outcome through a plan and a worktree to a sustainable, verified change.
---

# Agent execution discipline

This skill shows how an agent owns its work: from intent through a plan and a
worktree to a sustainable change that someone else is glad to take over. You
are not here to make the cheapest possible edit. You are here to do good work
you can stand behind.

## When to use

A non-trivial change is mainly:

- a refactor, feature or workflow change that goes beyond one obvious file;
- a change to an access boundary, a research schema, an experiment metric, a
  stop condition or where evidence is recorded;
- a change to more than one `AGENTS.md`, skill, task ledger or workflow rule;
- anything with legal, platform or reputational risk, or a possible external
  action.

A small fix (a typo, a broken link, an obvious one-line error) needs no
Mission Control plan. Use judgment, but still work in a worktree and open a
pull request. When in doubt, treat the change as non-trivial and run through
this skill briefly.

## Steps

### 1. Own the outcome

Before you start, you can answer:

- What must be true after my work, and how will I know? (a verifiable goal)
- Who owns this area and where is its source of truth: the nearest
  `AGENTS.md`, `workspace/knowledgebase` or a Mission Control plan?
- What is the business context: who does it serve, and what breaks if I get
  it wrong?
- Which assumptions am I making? An assumption that changes correctness,
  safety, customer impact or an ownership boundary is not an assumption; it is
  a question for your Operator.

Owning the outcome means: when you do not know, you find out; when you cannot
find out, you ask; and what you promise in the handoff is true.

### 2. Non-trivial work starts with a plan

Plan a refactor, feature, workflow change or access change first, with the
`mission-control-planning` skill: a plan with a code, a goal and acceptance
criteria. The plan is not bureaucracy. It is the anchor through which the
next agent and your Operator find your work, and it names your worktree
(`<plan-code>-<slug>`).

### 3. Then a worktree, never the primary checkout

The primary checkout of the Organization and of every module stays on
`main`. Work happens in a dedicated worktree: `.worktrees/root/<slug>/` for
the Organization root and `.worktrees/workspace/<module>/<slug>/` for a
module. One plan, one worktree, one branch, one pull request. The Lazurio
root's worktree skill describes the full lifecycle.

### 4. Make sustainable changes

A sustainable change is one someone can understand, validate and extend six
months from now:

- Fix the cause, not the symptom. A quick hack that bypasses rules or masks a
  problem is not finished work, even when a test passes.
- Keep the change bounded: change what belongs to the plan's goal. Record
  neighbouring problems as follow-ups instead of mixing them into the diff.
- Sustainable is not gold-plated: no speculative abstractions for use cases
  that do not exist. It means readability, a correct data flow and respect
  for ownership boundaries. Business data belongs in its owning module and is
  written through that module's own writer.
- Leave the Organization more truthful than you found it: insights go to
  `workspace/knowledgebase`, open decisions to the Mission Control plan,
  technical problems to GitHub Issues, and changes in working rules to the
  nearest `AGENTS.md`.

## Verification

- Decide up front on the smallest convincing check and run it. If it cannot
  run, say why; never pretend a result is green.
- Handoff: what changed, why the solution is sustainable, what was verified
  and what remains as follow-up. No secrets and no reasoning dump.
- Your work ends with a pull request. Publishing it (the merge) belongs to
  your Operator or to a Colleague they ask; see the collaboration model linked
  from the root `AGENTS.md`.
