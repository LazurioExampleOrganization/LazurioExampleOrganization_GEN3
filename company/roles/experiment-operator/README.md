# Experiment Operator

Role `experiment-operator` převádí hypotézy na malé měřitelné testy. Hlídá, aby
experiment měl jasný cíl, rozpočet, stop podmínku a zapsaný výsledek.

## Odpovědnost

- experiment spec
- metrika a success/fail threshold
- rozpočet a časový limit
- guardrail kontrola před spuštěním
- run log a výsledek
- stop/scale doporučení

## Typické zdroje

- `TODO.tasks.json`
- `ISSUES.open.json`
- plánované `modules/experiments/`
- plánované `modules/finance/`

## Výstupy

- experiment checklist
- run log
- výsledkový brief
- doporučení pro další krok
