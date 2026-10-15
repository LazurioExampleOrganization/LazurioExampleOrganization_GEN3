# Starter role catalogue

This folder is not an active role overlay. It is a catalogue of proven role
archetypes that an agent can copy into `company/roles/<role>/` when setting up
a new company, and then rewrite to match the company's reality.

Why it is here:

- a new company does not have to invent roles from scratch
- the agent has clear questions for the company owner
- person overlays in `company/colleagues/<person>/` have something to refer to
- `modules.manifest.json` can use stable `required_roles`

## How to use the catalogue

1. First ask the company owner which kinds of work really exist in the
   company.
2. Choose only archetypes that have a real owner or a clear future use case.
3. Copy `_template/` to `company/roles/<role>/`.
4. Use the archetypes below as a content pattern for `README.md` and
   `AGENTS.md`.
5. Write the final list into `company/roles/README.md`.
6. For each person in `company/colleagues/<person>/`, set the primary role and
   any multi-role disambiguation.

Do not create empty roles just because they are in the catalogue. A role
without an owner, outputs and handoff boundaries is noise.

## Starter archetypes

### `founder` / `ceo`

**Scope:** strategy, priorities, business direction, larger decisions, risk.

Typically owns:

- company strategy and the decision framework
- business and financial priorities
- approval of risky or strategic commitments
- executive reporting

Typical outputs:

- decisions and their reasons
- the priority for the next period
- a short executive summary
- approval or rejection of an exception

Handoff:

- hands direction to `technical-lead`, `operations`, `sales` or other owners
- takes escalations when a decision goes beyond one role

What not to do:

- do not work on detailed implementation in place of the role owner
- do not approve sensitive commitments without source material

### `technical-lead`

**Scope:** technical architecture, delivery quality, engineering rules.

Typically owns:

- technical decisions and architecture
- quality of the codebase or technical product
- incidents and technical risks
- connecting technical modules to the business context

Typical outputs:

- technical decision / ADR
- risk review before a change
- implementation plan
- incident summary and follow-up

Handoff:

- takes priorities from `founder` / `product-owner`
- hands customer or content impact to `product-owner` / `marketing`
- escalates business impact to `founder`

What not to do:

- do not take over business decisions just because they have a technical
  detail
- do not put internal strategy into public documentation

### `product-owner`

**Scope:** product or service identity, documentation, the flow of
information to customers.

Typically owns:

- what the company offers and how it is described
- customer documentation
- product and service names and their consistency
- customer feedback into the roadmap

Typical outputs:

- documentation update
- naming decision
- customer-facing explanation
- brief for marketing or the technical team

Handoff:

- takes technical changes from `technical-lead`
- hands communication needs to `marketing`
- takes feedback from `sales`, `support`, `delivery`

What not to do:

- do not invent technical facts without the technical owner
- do not mix internal reasoning into public documentation

### `sales`

**Scope:** client relationships, pipeline, offers, follow-ups, CRM or task
system.

Typically owns:

- new leads and opportunities
- offers and follow-up communication
- client expectations
- the sales forecast and the state of the pipeline

Typical outputs:

- opportunity summary
- follow-up email or message
- material for an offer
- handoff to delivery / operations

Handoff:

- hands technical uncertainties to `technical-lead` or `delivery`
- hands invoicing and administration to `operations`
- hands case-study potential to `marketing`

What not to do:

- do not promise technical, legal or financial commitments without the owner
- do not store client data outside the approved source of truth

### `operations`

**Scope:** administration, operations, finance, logistics, coordination of
work.

Typically owns:

- operating checklists and the state of administration
- invoicing, orders and deliveries, if the company uses them
- coordination of internal deadlines
- operational reporting

Typical outputs:

- operating status
- completion checklist
- material for invoicing or delivery
- a warning about a blocker

Handoff:

- takes material from `sales` or `delivery`
- escalates cash flow and risk to `founder`
- hands operational changes to `wiki` or another internal layer

What not to do:

- do not decide strategy in place of the owner
- do not commit financial or personal data to Git when it does not belong
  there

### `marketing`

**Scope:** content, campaigns, case studies, brand consistency, public
communication.

Typically owns:

- publishable content
- case studies and references
- newsletters, social networks, website copy
- consistency with the tone of voice and the design system

Typical outputs:

- a draft post, article or newsletter
- a brief for graphics or the website
- a case-study outline
- repurposing of existing content

Handoff:

- takes facts from `product-owner`, `sales`, `delivery`
- checks technical claims with `technical-lead`
- for client references, waits for approval from the owner of the
  relationship

What not to do:

- do not invent references, results or client claims
- do not change the design system without `design-system-lookup`

### `delivery`

**Scope:** delivering a service or project to the customer, technical or
process implementation, feedback from practice.

Typically owns:

- the course of a specific client or project
- implementation checklist
- handover of the result
- feedback into the product, documentation or operations

Typical outputs:

- status of a project or order
- technical or process proposal for the implementation
- handoff to operations
- feedback for `product-owner` or `technical-lead`

Handoff:

- takes the approved scope from `sales`
- hands operational details to `operations`
- escalates a product or technical problem to `product-owner` /
  `technical-lead`

What not to do:

- do not change the scope of an order without the business owner
- do not solve system bugs with a local workaround only

### `external-collaborator`

**Scope:** limited, clearly defined tasks for a contractor, a part-time
helper or a temporary collaborator.

Typically owns:

- a specific task with a clear brief
- work only in approved modules or files
- output ready for review

Typical outputs:

- a proposed change
- processed data, content or research
- a short handoff for the internal owner

Handoff:

- takes the brief from the internal owner
- always hands the output to the internal owner for review

What not to do:

- do not assume full workspace access
- do not work with sensitive data without an explicit scope
- do not send outputs outside without internal approval

## Questions for the company owner

During setup, ask briefly:

- Who decides strategy and priorities in the company?
- Who owns technical or expert decisions?
- Who talks to clients and holds the pipeline?
- Who runs operations, invoicing, administration or logistics?
- Who owns the documentation, the product or service and the public copy?
- Who delivers the work to the customer?
- Are there contractors or part-time helpers with limited access?
- Which roles can one person hold at the same time?
- When should the agent ask about the active role instead of guessing?

## A minimal good role model

For a small company this is often enough:

- `founder`
- `technical-lead` or an expert owner of the service
- `sales`
- `operations`
- `external-collaborator`, if the company works with contractors

Marketing, product-owner and delivery can be merged into another role until
the company has enough people or enough work to separate them.
