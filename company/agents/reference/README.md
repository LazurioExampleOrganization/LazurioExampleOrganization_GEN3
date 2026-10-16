# Reference

This folder holds **deep technical and operational references** for the
agent.

Unlike `runbooks/` (procedures to carry out) and `voice/` (how to write an
output), `reference/` holds **knowledge for ad hoc consultation**. The agent
reads it when it needs to understand something in depth.

## What belongs here

Companies typically provide:

- technical maps (what lives where in the codebase)
- domain background docs (for new colleagues)
- hardware and system diagrams
- references for specific technologies

The concrete content depends on the company. There are no references yet.
The Mission Control planning model is documented in its upstream,
[Lazurio/mission-control](https://github.com/Lazurio/mission-control)
(`docs/roadmap-planning-model.md` and the operating manual).

## What does not belong here

- processes to carry out (those are skills in `.agents/skills/`)
- tone of voice (that is `company/agents/voice/`)
- domain definitions of terms (that is `GLOSSARY.md`)
- strategy and company decisions (that is `workspace/knowledgebase/`, if the
  company has one)

## When to read the references

The agent should load references ad hoc when:

- the user asks about something specific
- a skill explicitly points to a reference document
- a context-heavy change is coming

They do not have to be read in every session. They are not baseline context.
