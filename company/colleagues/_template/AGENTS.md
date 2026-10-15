# AGENTS.md — <VYPLNIT_JMENO> (person overlay)

Tenhle soubor je **čtvrtá vrstva kaskády** (root → role → osoba →
modul, viz root `AGENTS.md §1`). Drží **jen věci specifické pro
<VYPLNIT_JMENO>**. Generická company policy je v root `AGENTS.md`,
policy pro roli v `company/roles/<VYPLNIT_ROLE>/AGENTS.md`.

## Role

<VYPLNIT_JMENO> je **<VYPLNIT_ROLE_FULL_NAME>** (viz
`company/roles/<VYPLNIT_ROLE>/`).

<VYPLNIT_POPIS_KONTEXT> — proč je tento člověk, co na něj útokuje, jak
mu pomáhat nejlépe.

## Multi-role disambiguace (pokud drží více rolí, jinak smaž)

<VYPLNIT_JMENO> drží <N> rolí: `<role1>`, `<role2>`.

Při víceznačném zadání se agent **doptá**, kterou rolí to brát.
Neodhaduj a nesmíchávej role tiše.

- **`<role1>`** — kdy se aktivuje
- **`<role2>`** — kdy se aktivuje

Když je to zjevné z kontextu, pokračuj bez ptaní.

## <VYPLNIT_TASK_TOOL>

- **Login e-mail** (OAuth identity): `<VYPLNIT>`
- **Kontaktní pracovní e-mail**: `<VYPLNIT>@agentmint.local`
- **<VYPLNIT_TASK_TOOL> user ID**: `<VYPLNIT>`
- **<VYPLNIT_TASK_TOOL> workspace**: `<VYPLNIT>`
- **Default task list**: `<VYPLNIT>`

## Monorepo scope label policy (pokud máte task-driven codebase, jinak smaž)

Pro commit messages, PR title/body a tasky v
`modules/<VYPLNIT_CODEBASE>/` vždy uveď **scope label** z kanonického
seznamu:

`<VYPLNIT>`, `<VYPLNIT>`, ...

Formát: `<Scope>: <short summary>`.

Branch prefix (např. `codex/PLAN-XXXX`) z root `AGENTS.md §6` platí
souběžně.

## Preferovaný jazyk

- **Interní komunikace s agentem**: <VYPLNIT> (čeština / angličtina /
  kombinace)
- **Kód, komentáře, commit message, PR popis**: angličtina,
  conventional commits
- **Externí výstupy**: podle publika

## Preferovaný styl práce

<VYPLNIT_STYL>

Příklady:

- **Stručná shrnutí technických rozhodnutí pro netechnické publikum**
- **<Task tool> slouží pro provozní viditelnost, ownership a komunikaci; Git/Mission Control ledgery drží roadmapu, rozhodnutí a execution stav.**
- **Proaktivně upozorni na blokéry, rizika a chybějící rozhodnutí.**
- **Dopad, ne implementace** — shrnuj dopad na byznys/tým/zákazníka.

## Tone of voice

Pro e-maily, <VYPLNIT_TASK_TOOL> tasky, komentáře a oznámení jménem
<VYPLNIT_JMENO> používej jako **jediný kanonický zdroj**
`company/agents/voice/<VYPLNIT>_TONE_OF_VOICE.md` (pokud existuje,
jinak default na `<VYPLNIT_COMPANY>_BASELINE_VOICE.md`).

Tone of voice sem **neduplikuj** — jeden source of truth.

## Osobní skills a paměť

- **Osobní skills**: `company/colleagues/<jmeno>/.claude/skills/` (volitelně)
- **Osobní napříč-projektová paměť**: volitelný gbrain mimo workspace
  (viz root `AGENTS.md §5.1`)
- **Sdílená firemní znalost**: `modules/knowledgebase/`,
  `modules/wiki/`, skills nebo AGENTS.md — viz root `AGENTS.md §11`
