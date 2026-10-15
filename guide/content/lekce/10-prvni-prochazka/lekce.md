---
id: 10-prvni-prochazka
title: "První procházka po složkách"
section: 2-prvni-den
order: 10
prerequisites: ["09-doctor"]
duration_min: 10
quiz: true
ukol: true
---

# První procházka po složkách

**Co se v této lekci naučíš:**
- jak si workspace fyzicky projít
- na které složky se podívat jako první
- proč nemusíš hned rozumět všemu

## Otevři workspace

Teď už víš, co jednotlivé části znamenají. Tahle lekce je o tom, abys je viděl/a na vlastní oči.

Otevři root workspace `AgentMint/` ve Finderu, ve VS Code, v Cursoru nebo v terminálu. Nejde o test paměti. Cílem je získat pocit: „Aha, tady to opravdu je."

## Začni v rootu

V horní složce si všimni hlavních souborů:

```text
README.md
MAP.md
WORKSPACE_MANUAL.md
AGENTS.md
ARCHITECTURE.md
GLOSSARY.md
TODO.md
TODO.tasks.json
DONE.tasks.json
ISSUES.open.json
CHANGELOG.md
```

Otevři `MAP.md` a jen prolet nadpisy. Pak otevři `README.md`. Nemusíš číst všechno. Hledej orientaci, ne dokonalé pochopení.

## Podívej se do `company/`

Otevři `company/colleagues/`. Uvidíš složky kolegů a `_template`, ze kterého později vznikne tvoje vlastní složka.

Pak otevři `company/roles/`. Tady jsou role `founder`, `research-operator` a `experiment-operator`. Agent díky tomu ví, jaký typ práce člověk řeší.

Nakonec se podívej do `company/scripts/`. Najdeš tam doctor.

## Podívej se do `modules/`

Tady bude nejvíc firemního obsahu. AgentMint má zatím plánované sloty:

- `modules/knowledgebase/`
- `modules/research/`
- `modules/experiments/`
- `modules/playbooks/`
- `modules/automations/`
- `modules/content/`
- `modules/finance/`

Nejdřív ale otevři `modules/README.md`. Vysvětluje, že moduly jsou Git
submoduly nebo planned slots a že chybějící modul kvůli plánu nebo přístupu
není chyba.

V každém modulu hledej `README.md`. Ten ti řekne, k čemu modul slouží.

## Podívej se do `.claude/skills/`

Tady žijí postupy pro agenta. Každá složka má `SKILL.md`. Zatím je nemusíš číst. Stačí vědět, že když agent říká „použiju skill", sahá právě sem.

Uvidíš i `.agents/skills` — to je právě ta kanonická knihovna a pravý zdroj.
`.claude/skills/`, kam se díváš, je symlink na `.agents/skills`, aby ji Claude
Code viděl na své cestě; obě cesty vedou na stejný obsah.

## Shrnutí

Tahle procházka má snížit strach z neznámé struktury. Nemusíš znát všechno. Potřebuješ vědět, že existuje root, `company/`, `modules/`, `launchpad/` a skills.

**Příště:** začne část o komunikaci s agentem: kdy použít Cursor, Claude Code nebo Codex.
