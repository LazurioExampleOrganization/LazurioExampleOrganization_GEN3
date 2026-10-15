---
name: design-system-lookup
description: Use before producing anything visual or formatted (web page, presentation, document, offer, table, email template or UI). It finds the Organization source of truth first and then points the agent to the design system.
---

# Design system lookup

## When to use

- The user wants a web layout, a hero section, a landing page or a UI
  component.
- The user wants a presentation, document, offer, report, table or merchandise.
- The user says "in our identity", "on brand", "lay it out nicely", "with the
  design system" or similar.
- You change a visual rule, colour, font, spacing, logo usage or the format of
  a repeatable output.

Do not use it for a backend fix without UI impact, plain internal Markdown
without a custom format, or a one-off technical diff that produces no visual
output.

## Steps

1. Open the design system's `README.md` and `BASELINE.md`.
2. Open `content/brand/colors/tokens.json` and
   `content/brand/typography/typography.md`.
3. If a production source exists, open it as well: the owning workspace
   module, `workspace/knowledgebase/` or `company/agents/voice/`.
4. Pick the source of truth for the output:

   | Output | Primary source of truth | Design system reference |
   |---|---|---|
   | Web or UI | the production module | `content/examples/` |
   | Document or offer | the module that generates the document | `content/examples/` |
   | Presentation | the brand brief | `content/examples/` |
   | Table or report | the module that owns the data | `content/examples/` |
   | Tone and copy | `company/agents/voice/` and the knowledgebase | `BASELINE.md` |

The design system lives in the root's `design-system/` today. Its standalone
repository [`design-system`](https://github.com/LazurioExampleOrganization/design-system)
becomes the mounted `design-system/` checkout once the root application slots
are activated; the paths inside it stay the same.

## Rules

- Never copy another company's brand assets.
- Do not invent colours or fonts when a production source exists.
- When sources conflict, the production source of truth wins and the design
  system is updated.
- The design system App is a read-only viewer, not an authoring tool.
- Record stable design decisions in the design system, not only in chat.

## Verification

- The output uses the tokens and typography from the design system, or the
  production source that overrides them.
- To preview the design system, start its App through Lazurio
  (`lazurio module start` or the Launchpad); the listener comes from the
  module's own `lazurio.module.json`. Never copy the port into a skill or a
  local `.env`.
