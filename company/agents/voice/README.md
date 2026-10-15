# Voice

This folder holds the **tone of voice guidance** for every output that an
agent writes **on behalf of the Organization** or on behalf of a colleague.

It is the **single source of truth** for tone. Do not duplicate the tone of
voice in `AGENTS.md`, `README.md` or skill files: link here.

## What belongs here

### Baseline

- `EXAMPLE_BASELINE_VOICE.md`: the company baseline tone for outputs on
  behalf of the Organization (announcements, shared docs, internal notes
  without a specific author).

  **Tip:** as a starting point, have a short conversation with the company
  owner: whom the company writes to, how formally it speaks, which phrases it
  avoids and which example outputs it already considers good. Do not copy
  another company's identity or internal tone of voice.

### Per-person tone (optional)

- `<PERSON>_TONE_OF_VOICE.md` for each colleague with a clearly different
  personal style whom the agent writes for. Typically the CEO or public faces
  in PR and marketing.

## What does not belong here

- the process for writing an email (that is a skill, if it is repeatable)
- templates of specific emails (those are templates and belong in a skill's
  supporting files)
- marketing strategy (that is the `workspace/marketing/` module or
  `workspace/knowledgebase/`, if the company has them)

## Tone cascade

When there are several tone sources, **the closer one wins**. The agent reads
from the specific to the general:

1. When writing on behalf of a specific person → `<PERSON>_TONE_OF_VOICE.md`
2. When the person has no tone of their own → the role-specific tone
   (optional)
3. When the role has none either → `EXAMPLE_BASELINE_VOICE.md`

## Status

The baseline exists in `EXAMPLE_BASELINE_VOICE.md`. Add a per-person tone only
when writing on behalf of a specific person in a clearly different style.
