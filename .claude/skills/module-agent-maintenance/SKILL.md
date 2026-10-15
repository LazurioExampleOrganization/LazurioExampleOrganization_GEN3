---
name: module-agent-maintenance
description: Use when work inside a workspace module changes its source-of-truth boundaries, data model, contracts, sync workflow or runtime behaviour. It keeps the module README, ARCHITECTURE, AGENTS and plans in step.
---

# Module documentation maintenance

A workspace module is its own Git repository, mounted at
`workspace/<module>/`. The root never tracks its contents. This skill keeps
the module's own documentation true while you change it.

## When to use

When a change in a module changes or reveals:

- a source-of-truth boundary;
- a data model, schema, writer flow or contract shape;
- an import, export or sync workflow;
- runtime behaviour, a port lease, App declaration or access rule;
- a repeatable procedure that the next agent must find without this chat.

## Steps

1. Before larger work, read the root `AGENTS.md`, the module's `AGENTS.md`,
   `README.md` and `ARCHITECTURE.md` (when present), and the Mission Control
   plan that the work belongs to.
2. Keep each document to its job:
   - `README.md`: practical use, scope and runtime expectations;
   - `ARCHITECTURE.md`: current design, invariants and source-of-truth
     boundaries;
   - `AGENTS.md`: short local rules for agents, not a generic runbook;
   - the Mission Control plan: the wider why, scope, risks and acceptance
     criteria, plus the tasks derived from it.
3. While the current truth changes, update `ARCHITECTURE.md` for design,
   contract or boundary changes, `README.md` for usage changes and `AGENTS.md`
   for new local rules. Record new steps and open questions as tasks and
   issues linked to the plan.
4. Do not keep a live plan in `TODO.md` or `IMPLEMENTATION_PLAN.md`. If an
   older module still has one, treat it as input to move into Mission Control.
5. For a module with an App, keep it conformant with the Lazurio Module
   Standard and check it with `lazurio module setup <module> --json`.

## Verification

Before you close a meaningful change, check that:

- the documentation describes the actual state, not the pre-change design;
- open steps and questions live in Mission Control or the issue tracker, not
  in Markdown checkboxes;
- the next recommended step is clear without the original chat;
- you listed the validation commands you ran, or why they could not run.
