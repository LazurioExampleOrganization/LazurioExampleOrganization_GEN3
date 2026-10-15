# Runbooks — LEGACY slot

Tato složka je **legacy slot**. V GEN2 jsou kanonickým formátem pro
opakovatelné postupy **Claude Code skills** (viz `/.claude/skills/`),
ne runbooks.

## Status

**Template default: prázdný slot.**

Do `runbooks/` se **nic nepřidává**. Nové opakovatelné postupy se
píší rovnou jako skills v `/.claude/skills/`.

Slot je zachován jen kvůli konzistenci struktury napříč firmami
(`company/agents/{reference, voice, runbooks, handoffs}/`). Firma
klidně může mazat, pokud ví, že ho nebude potřebovat.

## Proč skills místo runbooků

- Claude Code **přímo invokuje skills** — nemusí je parsovat jako
  volný markdown.
- Skills mají **stabilní formát** (frontmatter, definovaný scope,
  related artifacts).
- Skills mohou mít **osobní variantu** v
  `company/colleagues/<ty>/.claude/skills/`.
- Skills se **verzují** jako součást repa, ale invokují se přes ID.

## Pravidlo pro nové postupy

**Nepřidávej nový runbook sem.** Udělej rovnou skill v
`/.claude/skills/`.

Pokud skill nemůže splnit nějaké pravidlo (např. cross-platform
constraints, nebo skill potřebuje dlouhý markdown bez struktury),
založ issue nebo otázku a probereme, proč je to mimo skill.
