# Role: <VYPLNIT_ROLE_NAME>

**Scope:** <VYPLNIT_SCOPE>

Tahle složka definuje reusable role overlay. Konkrétní člověk na ni
odkazuje z `company/colleagues/<jméno>/`.

## Co role dělá

<VYPLNIT_ROLE_NAME> ve AgentMint vede/zajišťuje:

- <VYPLNIT>
- <VYPLNIT>
- <VYPLNIT>

## Ownership

Role vlastní:

- **Moduly / vrstvy:** <VYPLNIT>
- **Výstupy:** <VYPLNIT>
- **Rozhodování:** <VYPLNIT>
- **Eskalace:** <VYPLNIT>

## Typické moduly

<VYPLNIT_MODULY>

Příklad:

- `modules/<VYPLNIT>/` — <proč role tenhle modul potřebuje>
- `modules/<VYPLNIT>/` — <proč>

## Typické výstupy

- <VYPLNIT_VYSTUP>
- <VYPLNIT_VYSTUP>

## Source of truth

- Primární zdroj faktů: <VYPLNIT>
- Pracovní systém / tasky: <VYPLNIT>
- Dokumentace nebo wiki: <VYPLNIT>

## Handoff hranice

- **→ <jiná role>** — <kdy se handover děje a co se předává>
- **← <jiná role>** — <kdy přebírá od ostatních>
- **Eskalace na <role>** — <kdy role nesmí rozhodovat sama>

## Multi-role poznámka

Pokud konkrétní člověk drží víc rolí, disambiguace patří do
`company/colleagues/<člověk>/AGENTS.md`. Tady popisuj čistou roli, ne osobní mix.

## Co NEdělat

- <hranice scope proti jiným rolím>
- <citlivé nebo zakázané akce>
- <typický scope creep>

## Odkazy

- Operační pravidla: `company/roles/<VYPLNIT_ROLE_NAME>/AGENTS.md`
- Company baseline: root `/AGENTS.md`
- Starter katalog: `company/roles/_starter/`

## Stav

Základ funkční. Plné rozšíření role se doplňuje průběžně podle potřeby
(viz `company/roles/TODO.md`).
