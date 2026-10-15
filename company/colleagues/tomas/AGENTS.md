# AGENTS.md — Tomáš

Tenhle soubor je person overlay pro Tomáše v AgentMint. Root pravidla zůstávají
platná; tady jsou jen preference, role a disambiguace specifické pro Tomáše.

## Stav profilu

Profil čeká na doplnění Tomášem. Dokud nejsou vyplněné role, odpovědnosti a
preference, agent smí používat jen níže uvedený minimální kontext: Tomáš je člen
týmu AgentMint a jeho konkrétní role zatím není v tomto workspace potvrzená.

## Role

- **Primární role:** DOPLNIT.
- **Další role:** DOPLNIT, pokud existují.

Pokud zadání odkazuje na Tomáše a role není jasná, agent se krátce doptá.
Nedomýšlej business, technickou ani access odpovědnost z křestního jména.

## Co je potřeba doplnit

- Které rozhodování Tomáš vlastní.
- Které moduly typicky čte nebo zapisuje.
- Jaké výstupy od agenta očekává.
- Jaké externí akce vždy vyžadují potvrzení.
- Preferovanou úroveň detailu v odpovědích.
- Případný osobní tone of voice source of truth.

## Preferovaný styl práce

DOPLNIT Tomášem.

Do té doby používej company baseline:

- piš česky s diakritikou, pokud Tomáš neřekne jinak
- rozlišuj mechanismus, důkaz, riziko a experiment
- neprováděj externí akce bez explicitního potvrzení
- u nejasné role nebo ownerství se doptat

## Externí služby a MCP

Per-person MCP konfigurace, OAuth session data a tokeny patří do gitignored
lokální konfigurace. Do tohoto souboru patří pouze názvy služeb a operační
pravidla, ne secrets.

## Osobní skills

Osobní skills patří do `company/colleagues/tomas/.claude/skills/`. Sdílený postup,
který má používat celý tým, patří do root `.claude/skills/`.

