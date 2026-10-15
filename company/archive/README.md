# Archive

The `company/archive/` folder is meant for **read-only** or **derived**
archive content of the Organization.

Typical examples:

- exports from Google Drive
- email archives
- CRM snapshots
- one-off mirror datasets
- historical snapshots of documentation or business data

## Important rules

- `company/archive/` is **not automatically** a source of truth
- if the content is only mirrored, it must be clear **where it comes from**
- sensitive sources **should not be copied** here without a clear reason and
  rules
- when committing archive data, always question whether it really belongs in
  Git or only in a local backup flow

## Retention and GDPR

The archive may contain **personal data** (contacts, emails, CRM snapshots)
and is subject to the GDPR. Rules:

- Do not copy personal data here without a clear purpose and legal basis.
- If a colleague (or a client) asks for deletion, you must have a process to
  remove it from Git including the history (BFG Repo-Cleaner or similar).
- When a colleague leaves the company, decide what happens to the archive
  data related to their work.

## Categories of archive content

We recommend keeping three categories:

- **source archive**: a copy of the original source (for example an .mbox
  export of emails), not editable
- **working archive**: data that is still being processed (for example a
  parsed email archive for analysis)
- **derived archive**: derived datasets (for example summary reports from an
  old CRM)

## What `company/archive/` is not

- a dumping ground for unsorted files (those belong in `playgrounds/` or
  `tmp/` and are gitignored)
- a copy of the current production database
- a long-term document store (that belongs in `workspace/knowledgebase/`)
