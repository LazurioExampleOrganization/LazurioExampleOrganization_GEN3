# Generační pravidla (generated)

> Tento soubor je generovaný z `lazurio.organization.json`. Neupravuj ho ručně.

Pravidlo prototypu: The best implementation plan is a prototype. v1 learns, v2 uses v1 as input, v3 uses v2 as input.

## Verze aplikací
- app/v1: Learning/proving generation.
- app/v2: Second generation based on v1 learnings.

## Verze dat
- companydata/v1: First production or prototype data namespace.
- companydata/v2: Next generation namespace after migration and parity checks.

## Migrační pravidla
- A generation migration must define old source of truth, new source of truth, transform, parity check, cutover and rollback or archive readability.
